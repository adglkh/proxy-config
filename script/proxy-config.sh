#!/bin/sh

PROXY_FILE=proxy.conf
SNAPD_FOLDER=/etc/systemd/system/snapd.service.d
SNAPD_OVERRIDE_FILE=${SNAPD_FOLDER}/${PROXY_FILE}
HTTP_PROXY=""
HTTPS_PROXY=""

usage() {
    echo "Usage: $0 -s <https_proxy> -h <http_proxy>"
    echo "       This script does basic proxy setup by creating override unit environment for snapd.\n"
    echo "       -s https_proxy, e.g: https://user:pwd@proxy.xxx:8080"
    echo "       -h http_proxy,  e.g: http://iuser:pwd@proxy.xxx:8080"
    echo "       -d disable proxy and restore to original environment file"
    exit
}

#check_root() {
    #if [ "$(id -u)" != "0" ]; then
        #echo "You need to run this script as root"
        #exit 1
    #fi
#}

#sed -i in-place option is not available by default on some other distro.
modify() {
    sed -u "$1" "${SNAPD_OVERRIDE_FILE}" > "${SNAPD_OVERRIDE_FILE}".bak && mv "${SNAPD_OVERRIDE_FILE}".bak "${SNAPD_OVERRIDE_FILE}"
}


enable_proxy() {
    echo "create ${SNAPD_FOLDER} if it doen't exist."
    test -d ${SNAPD_FOLDER} || mkdir -p ${SNAPD_FOLDER}
    test -f ${SNAPD_OVERRIDE_FILE} && rm ${SNAPD_OVERRIDE_FILE}

    cat <<EOF | tee -a /etc/systemd/system/snapd.service.d/proxy.conf
[Service]
Environment="https_proxy=${HTTPS_PROXY}"
Environment="http_proxy=${HTTP_PROXY}"
EOF

    test -z ${HTTP_PROXY}   && modify "/http_proxy/d"
    test -z ${HTTPS_PROXY}  && modify "/https_proxy/d"

    echo "trigger systemd to reload"

    systemctl daemon-reload
    systemctl restart snapd.service

    exit
}

disable_proxy() {
    test -d ${SNAPD_FOLDER} && rm -fr ${SNAPD_FOLDER}

    echo "disable proxy and restore to original environment file."

    systemctl daemon-reload
    systemctl restart snapd.service
    
    exit
}

#check_root

while [ "$1" != "" ]; do
case $1 in
    -s ) shift
         HTTPS_PROXY=$1
         ;;
    -h ) shift
         HTTP_PROXY=$1
         ;;
    -d ) shift
         disable_proxy
         ;;
esac
shift
done

test -z ${HTTP_PROXY} && test -z ${HTTPS_PROXY} && usage 

enable_proxy
