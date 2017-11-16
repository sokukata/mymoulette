#! /bin/bash

#mkdir -p /sys/fs/cgroup/memory/mymoulette
#mkdir -p /sys/fs/cgroup/cpu/mymoulette
#mkdir -p /sys/fs/cgroup/pids/mymoulette

#echo $$ > /sys/fs/cgroup/memory/mymoulette/tasks
#echo $$ > /sys/fs/cgroup/cpu/mymoulette/tasks
#echo $$ > /sys/fs/cgroup/pids/mymoulette/tasks

#echo 1G > /sys/fs/cgroup/memory/mymoulette/memory.limit_in_bytes
#echo 10000 > /sys/fs/cgroup/cpu/mymoulette/cpu.cfs_quota_us
#echo 100 > /sys/fs/cgroup/pids/mymoulette/pids.max

#mkdir newroot && debootstrap stable newroot/ http://httpredir.debian.org/debian/

#chroot newroot setcap cap_net_raw-epi $(which $1)


#chroot newrooot unshare -C -i -m -n -p -u -U $@

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

cmd=$cmd"/sbin/capsh --drop=cap_net_raw --chroot=/ -- -c \"unshare -U /bin/bash -c '/home/$name $@' \";"

unshare -C -i -m -n -p -u  -f --mount-proc /bin/bash -c "$cmd"

rm /mnt/newroot/home/$name
