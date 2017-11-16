#!/bin/bash

function _csrDecode ()
{
        openssl req -in $1 -noout -text | grep "Subject:" 
}

case $1 in
        *csr)
                _csrDecode $1 
                ;;
        *)
                echo $"Usage: $0 {file.csr}"
                exit 1
esac
