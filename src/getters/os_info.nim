import os, strutils, std/locks

type
  OSInfo* = object
    user*: string
    hostname*: string
    operatingSystem*: string
    kernelVersion*: string
    machineName*: string

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

proc getOSInfo*(): OSInfo =
  var
    userData = ThreadData[string](value: "")
    hostnameData = ThreadData[string](value: "")
    osData = ThreadData[string](value: "")
    kernelData = ThreadData[string](value: "")
    machineData = ThreadData[string](value: "")
    tUser, tHostname, tOS, tKernel, tMachine: Thread[ThreadData[string]]

  createThread(tUser, fetchUserThread, userData)
  createThread(tHostname, fetchHostnameThread, hostnameData)
  createThread(tOS, fetchOSThread, osData)
  createThread(tKernel, fetchKernelVersionThread, kernelData)
  createThread(tMachine, fetchMachineNameThread, machineData)

  joinThread(tUser)
  joinThread(tHostname)
  joinThread(tOS)
  joinThread(tKernel)
  joinThread(tMachine)

  return OSInfo(user: userData.value, hostname: hostnameData.value,
                operatingSystem: osData.value, kernelVersion: kernelData.value,
                machineName: machineData.value)

