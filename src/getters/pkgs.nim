import os_info
import ../pkg/dnf
import ../pkg/pacman

proc getPkgCount*(): int =
  let osInformation = getOSInfo()
  case osInformation.distroID:
    of "arch", "manjaro":
      return pacmanPkg()
    of "fedora", "centos", "rhel", "ultramarine":
      return dnfPkg()
    else:
      return -1 
