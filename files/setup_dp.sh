#!/bin/bash -xe

DP_IP=
CTRL_IP=
FLASK_PORT="5000"
NGINX_PORT="5001"
PATH_TO_IMAGE=


usage()
{
    echo "usage: setup_dp.sh [[[--dp-ip ip-address ] [--ctrl-ip ip-address ] [--img-path path]] | [--help]]"
}

while [ "$1" != "" ]; do
    case $1 in
        --dp-ip )    shift
                                DP_IP=$1
                                ;;
        --ctrl-ip ) shift  
                                CTRL_IP=$1
                                ;;
        --img-path )  shift  
                                PATH_TO_IMAGE=$1
                                ;;
        --profile )  shift  
                                PROFILE=$1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done


rm -f $PATH_TO_IMAGE/tedp_docker.tar; wget --no-check-certificate -q -T90 http://$CTRL_IP:$NGINX_PORT/tedp_docker.tar -P $PATH_TO_IMAGE
docker images | grep -w tedp | awk '{print $3}' | xargs -I {} docker rmi -f {} && \
	docker load -i $PATH_TO_IMAGE/tedp_docker.tar
docker run --privileged --cap-add=SYS_PTRACE --security-opt seccomp=unconfined \
	-v /tmp/:/te_host/ -v $HOME:/te_root/ -v $HOME/.ssh/:/root/.ssh/ \
	-v /var/run/netns:/var/run/netns \
	-e IPADDRESS=$DP_IP -e CTRL_IPADDRESS=$CTRL_IP \
	-e CTRL_FLASK_PORT=$FLASK_PORT --ulimit core=9999999999 \
	--name tedpv2.0 --net=host -d -it \
	--tmpfs /tmp/ramcache:rw,size=104857600 tedp:v2.0
touch /home/ubuntu/tedp-installed
