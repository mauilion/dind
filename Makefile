CLUSTER_NAME=blue

DIND_IMAGE=quay.io/mauilion/dind
MOUNT_TAG=mount
PRIV_TAG=priv


KUBEADM_TOKEN = $(shell sudo docker exec $(CLUSTER_NAME)-control-plane kubeadm token create --print-join-token)

KUBECONFIG=$(shell kind get kubeconfig-path --name='$(CLUSTER_NAME)')
export KUBECONFIG

.PHONY: cache build_images push_images build_k8s build_k8s build_cluster load_images deploy_apps join unjoin clean clean_all
cache:
	docker pull $(DIND_IMAGE):$(MOUNT_TAG)
	docker pull $(DIND_IMAGE):$(PRIV_TAG)

build_images:
	docker build -f build/dind-mount/Dockerfile -t $(DIND_IMAGE):$(MOUNT_TAG) .
	docker build -f build/dind-priv/Dockerfile -t $(DIND_IMAGE):$(PRIV_TAG) .

push_images:
	docker push $(DIND_IMAGE):$(MOUNT_TAG)
	docker push $(DIND_IMAGE):$(PRIV_TAG)

build_k8s: cache build_cluster load_images install_cni
build_docker: 
	docker run --rm -ti -v /var/run/docker.sock:/var/run/docker.sock --pid=host --privileged quay.io/mauilion/dind:master bash

build_cluster:
	kind create cluster --name=$(CLUSTER_NAME) --config=kind/configs/blue.yaml

install_cni:
	kind get nodes --name=$(CLUSTER_NAME) | xargs -n1 -I {} docker exec {} sysctl -w net.ipv4.conf.all.rp_filter=0
	kubectl apply -f kind/cni/canal.yaml

load_images:
	kind load docker-image $(DIND_IMAGE):$(MOUNT_TAG) --name=$(CLUSTER_NAME)
	kind load docker-image $(DIND_IMAGE):$(PRIV_TAG) --name=$(CLUSTER_NAME)

deploy_apps:
	export KUBECONFIG=$(shell kind get kubeconfig-path --name='$(CLUSTER_NAME)')
	kubectl apply -f manifests/dind.yaml

join:
	sudo systemctl unmask kubelet
	sudo $(shell docker exec $(CLUSTER_NAME)-control-plane kubeadm token create --print-join-command) --ignore-preflight-errors=all

unjoin:
	sudo systemctl mask kubelet
	sudo kubeadm reset -f

clean:
	# Delete kind clusters
	kind delete cluster --name=$(CLUSTER_NAME) || exit 0

clean_all: clean unjoin
