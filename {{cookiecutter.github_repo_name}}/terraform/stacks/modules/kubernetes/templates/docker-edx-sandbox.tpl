#include <tunables/global>

profile docker-edx-sandbox-3.8.6 flags=(attach_disconnected,mediate_deleted) {
  #include <abstractions/base>

  network,
  capability,
  file,
  umount,
  signal (receive) peer=unconfined,
  signal (receive) peer=cri-containerd.apparmor.d,
  signal (send,receive) peer=docker-edx-sandbox-3.8.6,

  deny @{PROC}/* w,   # deny write for all files directly in /proc (not in a subdir)
  # deny write to files not in /proc/<number>/** or /proc/sys/**
  deny @{PROC}/{[^1-9],[^1-9][^0-9],[^1-9s][^0-9y][^0-9s],[^1-9][^0-9][^0-9][^0-9]*}/** w,
  deny @{PROC}/sys/[^k]** w,  # deny /proc/sys except /proc/sys/k* (effectively /proc/sys/kernel)
  deny @{PROC}/sys/kernel/{?,??,[^s][^h][^m]**} w,  # deny everything except shm* in /proc/sys/kernel/
  deny @{PROC}/sysrq-trigger rwklx,
  deny @{PROC}/mem rwklx,
  deny @{PROC}/kmem rwklx,
  deny @{PROC}/kcore rwklx,

  deny mount,
  deny /sys/[^f]*/** wklx,
  deny /sys/f[^s]*/** wklx,
  deny /sys/fs/[^c]*/** wklx,
  deny /sys/fs/c[^g]*/** wklx,
  deny /sys/fs/cg[^r]*/** wklx,
  deny /sys/firmware/** rwklx,
  deny /sys/kernel/security/** rwklx,

  ptrace (trace,read) peer=docker-edx-sandbox-3.8.6,

  /sandbox/venv/bin/python Cx -> child,
  profile child flags=(attach_disconnected,mediate_deleted){
    #include <abstractions/base>

    #
    # Python abstractions adapted from https://gitlab.com/apparmor/apparmor/-/raw/master/profiles/apparmor.d/abstractions/python
    #
    /opt/pyenv/versions/3.[0-9].*/lib/python3.[0-9]/**.{pyc,so} mr,
    /opt/pyenv/versions/3.[0-9].*/lib/python3.[0-9]/**.{egg,py,pth} r,
    /opt/pyenv/versions/3.[0-9].*/lib/python3.[0-9]/site-packages/ r,
    /opt/pyenv/versions/3.[0-9].*/lib/python3.[0-9]/lib-dynload/*.so mr,

    /opt/pyenv/versions/3.[0-9].*/include/python3.[0-9]*/pyconfig.h r,


    #
    # Whitelist particiclar shared objects from the system
    # python installation
    #
    /sandbox/venv/** mr,
    /opt/pyenv/versions/3.8.6_sandbox/** mr,
    /tmp/codejail-*/ rix,
    /tmp/codejail-*/** wrix,
    /tmp/* wrix,

    #
    # Whitelist particular shared objects from the system
    # python installation
    #
    /home/sandbox/** wrix,
    /sandbox/venv/.config/ wrix,
    /sandbox/venv/.cache/ wrix,
    /sandbox/venv/.config/** wrix,
    /sandbox/venv/.cache/** wrix,

    # Matplot lib needs fonts to make graphs
    /usr/share/fonts/ r,
    /usr/share/fonts/** r,
    /usr/local/share/fonts/ r,
    /usr/local/share/fonts/** r,

    #
    # Allow access to selections from /proc
    #
    /proc/*/mounts r,
  }
}
