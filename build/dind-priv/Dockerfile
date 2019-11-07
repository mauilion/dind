FROM jpetazzo/nsenter as nsenter
FROM k8s.gcr.io/pause:3.1 as pause
FROM gliderlabs/alpine:latest
COPY --from=nsenter /nsenter /usr/local/bin/nsenter
COPY --from=pause /pause /pause
RUN apk-install openssl iproute2 openssh-client sudo docker tshark bash bash-completion iputils bind-tools curl ca-certificates
RUN mkdir  /etc/docker && echo -e "{\n\t\"storage-driver\": \"vfs\"\n}" > /etc/docker/daemon.json
CMD ["/usr/bin/dockerd"]
