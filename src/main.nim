import getters/ram
import strformat

var memoryInfo = MemoryInfo()
var t: Thread[ptr MemoryInfo]

createThread(t, fetchMemoryInfoThread, addr(memoryInfo))
joinThread(t)

echo fmt("Total Memory: {memoryInfo.total} MB")
echo fmt("Free Memory: {memoryInfo.free} MB")
echo fmt("Available Memory: {memoryInfo.available} MB")
echo fmt("Buffers: {memoryInfo.buffers} MB")
echo fmt("Cached: {memoryInfo.cached} MB")

