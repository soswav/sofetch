import os, strutils, std/parsecfg, strformat

type
  OSInfo* = object
    user*: string
    hostname*: string
    operatingSystem*: string
    kernelVersion*: string
    machineName*: string
    uptime*: string
    distroID*: string

proc getUser(): string =
  return getenv("USER")

proc getHostname(): string =
  return readFile("/proc/sys/kernel/hostname").strip()

proc getOS(): string =
  let content = readFile("/etc/os-release")
  for line in content.splitLines():
    if line.startsWith("PRETTY_NAME="):
      return strip(split(line, "=")[1], chars={'"'})
  return ""

proc getKernelVersion(): string =
  return readFile("/proc/sys/kernel/osrelease").strip()

proc getMachineName(): string =
  for line in readFile("/proc/cpuinfo").splitLines():
    if line.startsWith("model name"):
      return line.split(":")[1].strip()
  return ""

proc getUptime(): string =
  let uptimeContent = readFile("/proc/uptime").split()[0]
  let uptimeSeconds = parseFloat(uptimeContent).int
  let days = uptimeSeconds div (24 * 3600)
  let hours = (uptimeSeconds mod (24 * 3600)) div 3600
  let minutes = (uptimeSeconds mod 3600) div 60
  let seconds = uptimeSeconds mod 60
  return fmt"{days}d {hours}h {minutes}m {seconds}s"

proc getDistroID(): string =
  let osRelease = "/etc/os-release".loadConfig
  return osRelease.getSectionValue("", "ID", "")

proc getOSInfo*(): OSInfo =
  return OSInfo(
    user: getUser(),
    hostname: getHostname(),
    operatingSystem: getOS(),
    kernelVersion: getKernelVersion(),
    machineName: getMachineName(),
    uptime: getUptime(),
    distroID: getDistroID()
  )

