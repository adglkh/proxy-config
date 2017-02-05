# proxy-config

An easy tool to setup https and http proxy for snapd.
User failed to install snap on the devices under the restricted network, this snap helps user easy to setup proxy for snapd so that "snap install" works in such situation.

## Usage
$ sudo proxy-config -s https_proxy -h http_proxy

## Note 
It's just a workaround for the time being. There might be available environment variable STORE_PROXY for snapd in the future.
