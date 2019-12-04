### DIND Proof of concept.

The goal of this image is to provide the tooling necessary to work through a couple of exercises that highlight what Docker in Docker means.

There are two definitions that are both viable.

See this twitter poll for a little more color around which of the two folks assume is relevant.

[]![](./tweet.png)](https://twitter.com/mauilion/status/1145801961666514945?s=20)
to deploy this container on a node you can run:

For the mount version you can run:

```
docker run -d --name dind-mount -v /var/run/docker.sock:/var/run/docker.sock quay.io/mauilion/dind:mount
```

For the Priv version:
```
docker run -d --name dind-priv --privileged quay.io/mauilion/dind:priv
```


Copyright © 1998 - 2019 VMware, Inc. All rights reserved.


