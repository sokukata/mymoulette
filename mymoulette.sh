#! /bin/bash

mkdir /mnt/newroot  #debootstrap stable /mnt/newroot/ http://httpredir.debian.org/debian/
mount -t tmpfs none /mnt/newroot
cp -r /mnt/debootstrap/* /mnt/newroot/

cp $1 /mnt/newroot/home/

cp /usr/bin/unshare /mnt/newroot/usr/bin/unshare
cp /sbin/capsh /mnt/newroot/sbin/

name=$(basename $1)
shift

cmd="mount --make-rslave /;"

cmd=$cmd"mount -t proc proc /mnt/newroot/proc;"

cmd=$cmd"find / -mindepth 1 -maxdepth 1 -type d | grep -Ev \"/dev|/sys|/proc|/run\" | xargs -i umount -R {};"
cmd=$cmd"find / -mindepth 1 -maxdepth 1 -type d | grep -E \"/dev|/sys|/proc|/run\" | xargs -i mount --rbind {} /mnt/newroot{};"

cmd=$cmd"cd /mnt/newroot;"
cmd=$cmd"mkdir old_root;"
cmd=$cmd"pivot_root . old_root;"


#cmd=$cmd"/sbin/setcap cap_net_raw-epi $(which $1);"

#cmd=$cmd"/sbin/capsh --drop=cap_net_raw --;"

cmd=$cmd"mkdir -p /sys/fs/cgroup/memory/mymoulette;"
cmd=$cmd"mkdir -p /sys/fs/cgroup/cpu/mymoulette;"
cmd=$cmd"mkdir -p /sys/fs/cgroup/pids/mymoulette;"

cmd=$cmd"echo \$\$ > /sys/fs/cgroup/memory/mymoulette/tasks;"
cmd=$cmd"echo \$\$ > /sys/fs/cgroup/cpu/mymoulette/tasks;"
cmd=$cmd"echo \$\$ > /sys/fs/cgroup/pids/mymoulette/tasks;"

cmd=$cmd"echo 1G > /sys/fs/cgroup/memory/mymoulette/memory.limit_in_bytes;"
cmd=$cmd"echo 10000 > /sys/fs/cgroup/cpu/mymoulette/cpu.cfs_quota_us;"
cmd=$cmd"echo 100 > /sys/fs/cgroup/pids/mymoulette/pids.max;"

cmd=$cmd"hostname $(uuidgen);"

cmd=$cmd"ip netns add mymoul;"
cmd=$cmd"ip netns exec mymoul ip link;"


#cmd=$cmd"unshare -U -n -f --map-root-user capsh --drop=cap_net_raw,cap_sys_chroot,cap_setfcap,cap_setpcap --chroot=/ -- -c \"/bin/bash -c 'cd home/;$name $@'\";"
cmd=$cmd"unshare -f capsh --drop=cap_net_raw,cap_sys_chroot,cap_setfcap,cap_setpcap --chroot=/ -- -c \"/bin/bash -c 'cd home/;$name $@'\";"

unshare -C -i -m -p -u -f --mount-proc /bin/bash -c "$cmd"

rm /mnt/newroot/home/$name
