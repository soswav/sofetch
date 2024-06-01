import getters/os_info, getters/ram, getters/pkgs
import strformat

let osInformation = getOSInfo()
let memoryInfo = getMemoryInfo()
echo fmt("Total Memory: {memoryInfo.total} MB")
echo fmt("Free Memory: {memoryInfo.free} MB")
echo fmt("Available Memory: {memoryInfo.available} MB")
echo fmt("Buffers: {memoryInfo.buffers} MB")
echo fmt("Cached: {memoryInfo.cached} MB")

echo fmt("User: {osInformation.user}")
echo fmt("Hostname: {osInformation.hostname}")
echo fmt("Operating System: {osInformation.operatingSystem}")
echo fmt("Kernel Version: {osInformation.kernelVersion}")
echo fmt("Machine Name: {osInformation.machineName}")
echo fmt("Uptime: {osInformation.uptime}")
echo fmt("Distro ID: {osInformation.distroID}")

echo fmt("Package Count: {getPkgCount()}")
