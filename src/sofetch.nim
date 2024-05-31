import getters/ram, getters/os_info
import strformat

var memoryInfo = MemoryInfo()
var memoryThread: Thread[ptr MemoryInfo]

createThread(memoryThread, fetchMemoryInfoThread, addr(memoryInfo))
joinThread(memoryThread)

echo fmt("Total Memory: {memoryInfo.total} MB")
echo fmt("Free Memory: {memoryInfo.free} MB")
echo fmt("Available Memory: {memoryInfo.available} MB")
echo fmt("Buffers: {memoryInfo.buffers} MB")
echo fmt("Cached: {memoryInfo.cached} MB")

let osInformation = getOSInfo()

echo fmt("User: {osInformation.user}")
echo fmt("Hostname: {osInformation.hostname}")
echo fmt("Operating System: {osInformation.operatingSystem}")
echo fmt("Kernel Version: {osInformation.kernelVersion}")
echo fmt("Machine Name: {osInformation.machineName}")
echo fmt("Uptime: {osInformation.uptime}")
echo fmt("Distro ID: {osInformation.distroID}")

