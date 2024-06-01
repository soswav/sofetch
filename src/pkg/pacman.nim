# why not something simpler?
# [Pacman - Q | wc -l] = 0.009s
# [find /var/lib/pacman/local -mindepth 1 -maxdepth 1 -type d | wc -l] = 0.003
# [THIS] = 0.001
import os

proc countItemsInDir(dirPath: string): int =
  var itemCount = 0
  for _ in walkDir(dirPath):
    inc(itemCount)
  return itemCount

let dirPath = "/var/lib/pacman/local"
let itemCount = countItemsInDir(dirPath)
echo itemCount

