#!/usr/bin/env bash

path="/images/quay.io/mauilion"
name="quay.io/mauilion"

docker import ${path}/dind\:blue ${name}/dind:blue
docker import ${path}/bash\:flat ${name}/bash:flat
