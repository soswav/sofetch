import os, strutils, strformat

type
  OSInfo* = object
    user*: string
    hostname*: string
    operatingSystem*: string
    kernelVersion*: string
    machineName*: string
    uptime*: string

type
  ThreadData[T] = ref object
    value: T

proc fetchUserThread(data: ThreadData[string]) {.thread.} =
  data.value = getenv("USER")

proc fetchHostnameThread(data: ThreadData[string]) {.thread.} =
  data.value = readFile("/proc/sys/kernel/hostname").strip()

proc fetchOSThread(data: ThreadData[string]) {.thread.} =
  let content = readFile("/etc/os-release")
  for line in content.splitLines():
    if line.startsWith("PRETTY_NAME="):
      data.value = strip(split(line, "=")[1], chars={'"'})
      break

proc fetchKernelVersionThread(data: ThreadData[string]) {.thread.} =
  data.value = readFile("/proc/sys/kernel/osrelease").strip()

proc fetchMachineNameThread(data: ThreadData[string]) {.thread.} =
  for line in readFile("/proc/cpuinfo").splitLines():
    if line.startsWith("model name"):
      data.value = line.split(":")[1].strip()
      break

proc fetchUptimeThread(data: ThreadData[string]) {.thread.} =
  let uptimeContent = readFile("/proc/uptime").split()[0]
  let uptimeSeconds = parseFloat(uptimeContent).int
  let days = uptimeSeconds div (24 * 3600)
  let hours = (uptimeSeconds mod (24 * 3600)) div 3600
  let minutes = (uptimeSeconds mod 3600) div 60
  let seconds = uptimeSeconds mod 60
  data.value = fmt"{days}d {hours}h {minutes}m {seconds}s"

proc getOSInfo*(): OSInfo =
  var
    userData = ThreadData[string](value: "")
    hostnameData = ThreadData[string](value: "")
    osData = ThreadData[string](value: "")
    kernelData = ThreadData[string](value: "")
    machineData = ThreadData[string](value: "")
    uptimeData = ThreadData[string](value: "")
    tUser, tHostname, tOS, tKernel, tMachine, tUptime: Thread[ThreadData[string]]

  createThread(tUser, fetchUserThread, userData)
  createThread(tHostname, fetchHostnameThread, hostnameData)
  createThread(tOS, fetchOSThread, osData)
  createThread(tKernel, fetchKernelVersionThread, kernelData)
  createThread(tMachine, fetchMachineNameThread, machineData)
  createThread(tUptime, fetchUptimeThread, uptimeData)

  joinThread(tUser)
  joinThread(tHostname)
  joinThread(tOS)
  joinThread(tKernel)
  joinThread(tMachine)
  joinThread(tUptime)

  return OSInfo(user: userData.value, hostname: hostnameData.value,
                operatingSystem: osData.value, kernelVersion: kernelData.value,
                machineName: machineData.value, uptime: uptimeData.value)

