#!/usr/bin/bash

# configuration
VNIC=vnic2
HDD=/dev/zvol/rdsk/rpool/KVM/ubuntu/disk0
CD=/data/backups/iso/ubuntu-14.04-server-amd64.iso
VNC=7
TNET=$VNC$VNC$VNC$VNC
MEM=1024

mac=`dladm show-vnic -po macaddress $VNIC`

/usr/bin/qemu-system-x86_64 \
-name "$(basename $CD)" \
-monitor telnet:127.0.0.1:$TNET,server,nowait \
-boot dc \
-enable-kvm \
-vnc 0.0.0.0:$VNC \
-smp 2 \
-m $MEM \
-no-hpet \
-drive file=$HDD,if=virtio,index=0 \
-drive file=$CD,media=cdrom,if=ide,index=2  \
-net nic,vlan=0,name=net0,model=virtio,macaddr=$mac \
-net vnic,vlan=0,name=net0,ifname=$VNIC,macaddr=$mac \
-vga std \
-daemonize

if [ $? -gt 0 ]; then
    echo "Failed to start VM"
fi

port=`expr 5900 + $VNC`
public_nic=$(dladm show-vnic|grep vnic1|awk '{print $2}')
public_ip=$(ifconfig $public_nic|grep inet|awk '{print $2}')

echo "Started VM:"
echo "Public: ${public_ip}:${port}"
echo "QEMU/Monitor: 127.0.0.1:${TNET}"
