#!/usr/bin/env bash

path="/images/quay.io/mauilion"
name="quay.io/mauilion"

docker load -i ${path}/dind\:blue
docker load -i ${path}/bash\:flat
