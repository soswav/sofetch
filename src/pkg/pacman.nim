import os

proc countItemsInDir(dirPath: string): int =
  var itemCount = 0
  for _ in walkDir(dirPath):
    inc(itemCount)
  return itemCount

let dirPath = "/var/lib/pacman/local"
let itemCount = countItemsInDir(dirPath)
echo itemCount

