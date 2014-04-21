#!/usr/bin/bash

# configuration
VNIC=vnic3
HDD=/dev/zvol/rdsk/rpool/KVM/windows/disk0
CD=/data/media/Downloads/archlinux-2014.03.01-dual.iso
VNC=6
TNET=$VNC$VNC$VNC$VNC
MEM=4096

mac=`dladm show-vnic -po macaddress $VNIC`

/usr/bin/qemu-system-x86_64 \
-name "$(basename $CD)" \
-monitor telnet:127.0.0.1:$TNET,server,nowait \
-boot cd \
-enable-kvm \
-vnc 0.0.0.0:$VNC \
-smp 2 \
-m $MEM \
-no-hpet \
-localtime \
-drive file=$HDD,if=ide,index=0 \
-drive file=$CD,media=cdrom,if=ide,index=2  \
-net nic,vlan=0,name=net0,model=e1000,macaddr=$mac \
-net vnic,vlan=0,name=net0,ifname=$VNIC,macaddr=$mac \
-vga std \
-daemonize

#/usr/bin/screen -S qemu-$VNC -d -m telnet 127.0.0.1 $TNET

if [ $? -gt 0 ]; then
    echo "Failed to start VM"
fi

port=`expr 5900 + $VNC`
public_nic=$(dladm show-vnic|grep vnic1|awk '{print $2}')
public_ip=$(ifconfig $public_nic|grep inet|awk '{print $2}')

echo "Started VM:"
echo "Public: ${public_ip}:${port}"
#echo "QEMU/Monitor: screen -r qemu-${VNC}"
echo "QEMU/Monitor: 127.0.0.1:${TNET}"
