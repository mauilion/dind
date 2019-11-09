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
docker exec docker-priv /import.sh 1>/dev/null
pe "docker ps"
p  "the docker process in the node and the container show the same thing!"
p  "but there's more! "
clear
p  "all of the volumes we mount are from the context of the docker.socket."
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
p  "in this case we don't see the same!"
clear
p  "Because this is all still process isolation we can still see the processes in ps!"
pe "pgrep -a true-blue"
pe "pstree -aps $(pgrep true-blue)"
pe "pgrep -a true-red"
pe "pstree -aps $(pgrep true-red)"
p  "this output describes that the process are isolated differently!"
clear
p  "one more thing! Now that we are using this form of dind"
p  "we can only expose what's running in the context of the container!"
pe "docker exec -ti docker-priv touch /etc/flag"
p  "this file doesn't exist on the node only in the container"
pe "ls -al /etc/flag"
pe "docker exec -ti docker-priv docker run --rm -v /etc:/host/etc bash:flat rm /host/etc/flag"
pe "docker exec -ti docker-priv ls -al /etc/flag"
p  "it's gone!"
p  "that's all for now"

# show a prompt so as not to reveal our true nature after
# the demo has concluded
p ""
make clean_docker
