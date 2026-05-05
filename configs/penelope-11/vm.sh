#!/usr/bin/env bash

ACTION=$1
VM_NAME=vm-01

case $ACTION in
        start)
                virsh start "$VM_NAME"
                ;;
        restart)
                virsh reboot "$VM_NAME"
                ;;
        shutdown)
                virsh shutdown "$VM_NAME"
                ;;
        stop)
                virsh destroy "$VM_NAME"
        *)
                echo "supported actions: "
                echo "  - start"
                echo "  - restart"
                echo "  - shutdown"
                echo "  - stop"
                ;;
esac
