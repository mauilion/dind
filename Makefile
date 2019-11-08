
SHELL := /bin/bash
CLUSTER_NAME=blue

DIND_IMAGE=quay.io/mauilion/dind
MOUNT_TAG=mount
PRIV_TAG=priv


KUBEADM_TOKEN = $(shell sudo docker exec $(CLUSTER_NAME)-control-plane kubeadm token create --print-join-token)

KUBECONFIG=$(shell kind get kubeconfig-path --name='$(CLUSTER_NAME)')
export KUBECONFIG

.PHONY: cache_docker cache_k8s build_images push_images init_k8s clean_k8s init_docker clean_docker install_cni load_images deploy_apps join unjoin clean_all 

#BUILD STUFF

build_images:
	docker build -f build/dind-mount/Dockerfile -t $(DIND_IMAGE):$(MOUNT_TAG) .
	docker build -f build/dind-priv/Dockerfile -t $(DIND_IMAGE):$(PRIV_TAG) .

push_images:
	docker push $(DIND_IMAGE):$(MOUNT_TAG)
	docker push $(DIND_IMAGE):$(PRIV_TAG)

update_tags:
	git tag blue -f
	git tag red -f
	git tag $(MOUNT_TAG) -f
	git tag $(PRIV_TAG) -f
	git push origin blue red $(MOUNT_TAG) $(PRIV_TAG) -f

#DOCKER STUFF
cache_docker:
	docker pull $(DIND_IMAGE):$(MOUNT_TAG)
	docker pull $(DIND_IMAGE):$(PRIV_TAG)

init_docker:
	docker run --rm -d --name docker-mount -v /var/run/docker.sock:/var/run/docker.sock $(DIND_IMAGE):$(MOUNT_TAG)
	docker run --rm -d --name docker-priv --privileged $(DIND_IMAGE):$(PRIV_TAG)

clean_docker:
	docker stop docker-mount 2>/dev/null || true
	docker stop docker-priv 2>/dev/null || true

#KUBERNETES STUFF
cache_k8s:
	cat kind/cni/images | xargs -I {} docker pull {}

init_k8s: load_images install_cni
	kind create cluster --name=$(CLUSTER_NAME) --config=kind/configs/blue.yaml

clean_k8s:
	kind delete cluster --name=$(CLUSTER_NAME) || exit 0


install_cni:
	cat kind/cni/images | xargs -I {} kind load docker-image {} --name=$(CLUSTER_NAME)
	kind get nodes --name=$(CLUSTER_NAME) | xargs -n1 -I {} docker exec {} sysctl -w net.ipv4.conf.all.rp_filter=0
	kubectl apply -f kind/cni/canal.yaml

load_images:
	kind load docker-image $(DIND_IMAGE):$(MOUNT_TAG) --name=$(CLUSTER_NAME)
	kind load docker-image $(DIND_IMAGE):$(PRIV_TAG) --name=$(CLUSTER_NAME)

deploy_apps: join
	export KUBECONFIG=$(shell kind get kubeconfig-path --name='$(CLUSTER_NAME)')
	kubectl apply -f kind/manifests/

join:
	sudo systemctl unmask kubelet
	sudo $(shell docker exec $(CLUSTER_NAME)-control-plane kubeadm token create --print-join-command) --ignore-preflight-errors=all

unjoin:
	sudo systemctl mask kubelet
	sudo kubeadm reset -f

clean_all: unjoin clean_k8s clean_docker
