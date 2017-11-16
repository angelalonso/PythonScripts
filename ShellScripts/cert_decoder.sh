#!/bin/bash

function _crtDecode ()
{
        openssl x509 -in $1 -text -noout | grep -e 'DNS:\|Subject:'
}

case $1 in
        *crt)
                _crtDecode $1 
                ;;
        *)
                echo $"Usage: $0 {file.crt}"
                exit 1
esac
