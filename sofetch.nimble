version       = "0.1.0"
author        = "soswav"
description   = "So? Fetch!"
license       = "BOLA"
srcDir        = "src"

bin = @["sofetch"]
requires "nim >= 1.4.0", "db_connector"

task build, "Build the project":
  exec "nim c --threads:on src/sofetch.nim"
