#!/usr/bin/env bash

########################
# include the magic
########################
. lib/demo-magic.sh


########################
# Configure the options
########################

#
# speed at which to simulate typing. bigger num = faster
#
# TYPE_SPEED=20

#
# custom prompt
#
# see http://www.tldp.org/HOWTO/Bash-Prompt-HOWTO/bash-prompt-escape-sequences.html for escape sequences
#
DEMO_PROMPT="${GREEN}➜ ${CYAN}\W "

# put your demo awesomeness here
#if [ ! -d "stuff" ]; then
#  pe "mkdir stuff"
#fi

#pe "cd stuff"

clear
pe "make init_docker"
p  "let's start up a process in the dind container"
pe "docker exec -ti docker-mount docker run --rm -d --name red quay.io/mauilion/dind:red"
pe "docker exec -ti docker-mount docker ps"
pe "docker ps"
p  "the docker process in the node and the container show the same thing!"
p  "but there's more! "
clear
p  "all of the mount commands are in the context of the docker.socket."
pe "sudo touch /etc/flag"
pe "docker exec docker-mount docker run --rm -v /etc:/host/etc bash rm /host/etc/flag"
pe "ls -al /etc/flag"
p  "what happens to the red container if I shut down the docker-mount container?"
pe "docker stop docker-mount"
pe "docker ps -f name=red"
p  "it's left behind! just like all those intermediate containers used"
p  "when building containers!"
clear
p  "now let's play with the other version of docker in docker"
pe "docker exec -ti docker-priv docker run --rm -d --name blue quay.io/mauilion/dind:blue"
pe "docker exec -ti docker-priv docker ps"
pe "docker ps"
clear
p  "since the docker socket is running in the container directly we can only expose what the container has access to :)"
pe "docker exec -ti docker-priv touch /etc/flag"
pe "ls -al /etc/flag"
pe "docker exec -ti docker-priv docker run --rm -v /etc:/host/etc mauilion/bash:flat rm /host/etc/flag"
pe "docker exec -ti docker-priv ls -al /etc/flag"
p  "it's gone!"
clear
p  "Becuase this is all still process isolation we can still see the processes in ps!"
pe "pgrep -a true-blue"
pe "pstree -aps $(pgrep true-blue)"
pe "pgrep -a true-red"
pe "pstree -aps $(pgrep true-red)"


# show a prompt so as not to reveal our true nature after
# the demo has concluded
p ""
make clean_docker
docker stop red