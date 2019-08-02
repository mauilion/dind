### DIND Proof of concept.

The goal of this image is to provide the tooling necessary to work through a couple of exercises that highlight what Docker in Docker means.

There are two definitions that are both viable.

See this twitter poll for a little more color around which of the two folks assume is relevant.

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">When you hear Docker in Docker what do you think of?<br><br>docker socket: Mounting in the underlying docker.sock and allowing a container to make new containers.<br><br>kernel privs: Giving enough privs to a new container that it can make new containers cause it shares a kernel.</p>&mdash; Duffie Cooley (@mauilion) <a href="https://twitter.com/mauilion/status/1145801961666514945?ref_src=twsrc%5Etfw">July 1, 2019</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

to deploy this container on a node you can run:

```
docker run -ti -v /var/run/docker.sock:/var/run/docker.sock --pid=host --privileged quay.io/mauilion/dind:master bash
```

to deploy this as a pod on a Kubernetes cluster

you can deploy this manifest with:

kubectl apply -f https://git.io/dind-pod.yaml
