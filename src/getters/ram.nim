import strutils, std/locks

type
  MemoryInfo* = object
    total*: int64
    free*: int64
    available*: int64
    buffers*: int64
    cached*: int64

var lock: Lock

proc parseMemoryValue(line: string): int64 =
  let
    parts = line.split(":")
    valueStr = parts[1].strip().split()[0]
  # Convert from kB to MB
  result = int64(parseInt(valueStr) div 1024)

proc getMemoryInfo*(): MemoryInfo =
  var memInfo = MemoryInfo()
  for line in readFile("/proc/meminfo").splitLines():
    let key = line.split(":")[0]
    case key
    of "MemTotal": memInfo.total = parseMemoryValue(line)
    of "MemFree": memInfo.free = parseMemoryValue(line)
    of "MemAvailable": memInfo.available = parseMemoryValue(line)
    of "Buffers": memInfo.buffers = parseMemoryValue(line)
    of "Cached": memInfo.cached = parseMemoryValue(line)
  return memInfo

initLock(lock)

proc fetchMemoryInfoThread*(memInfoPtr: ptr MemoryInfo) {.thread.} =
  var localMemInfo = getMemoryInfo()
  acquire(lock)
  memInfoPtr[] = localMemInfo
  release(lock)

deinitLock(lock)

