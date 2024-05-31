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

type
  ThreadData[T] = ref object
    value: T

proc createAndJoinThread[T](procPtr: proc (data: ThreadData[T]) {.thread.}, data: ThreadData[T]): Thread[ThreadData[T]] =
  var thread: Thread[ThreadData[T]]
  createThread(thread, procPtr, data)
  joinThread(thread)
  return thread

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

proc fetchDistroIDThread*(data: ThreadData[string]) {.thread.} =
  let osRelease = "/etc/os-release".loadConfig
  data.value = osRelease.getSectionValue("", "ID", "")

proc getOSInfo*(): OSInfo =
  var
    userData = ThreadData[string](value: "")
    hostnameData = ThreadData[string](value: "")
    osData = ThreadData[string](value: "")
    kernelData = ThreadData[string](value: "")
    machineData = ThreadData[string](value: "")
    uptimeData = ThreadData[string](value: "")
    distroIDData = ThreadData[string](value: "")

  let threadFuncs: seq[proc (data: ThreadData[string]) {.thread.}] = @[
    fetchUserThread, fetchHostnameThread, fetchOSThread,
    fetchKernelVersionThread, fetchMachineNameThread, fetchUptimeThread,
    fetchDistroIDThread
  ]

  var threadData: seq[ThreadData[string]] = @[
    userData, hostnameData, osData, kernelData, machineData, uptimeData, distroIDData
  ]

  for i in 0..<threadFuncs.len:
    discard createAndJoinThread(threadFuncs[i], threadData[i])

  return OSInfo(user: userData.value, hostname: hostnameData.value,
                operatingSystem: osData.value, kernelVersion: kernelData.value,
                machineName: machineData.value, uptime: uptimeData.value,
                distroID: distroIDData.value)

