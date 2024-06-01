#[
    Most efficient rpm reading.
    The majority of fetch programs use some varient of an RPM command. Such as;
    - "rpm -qa | wc -l" = 1.4s
    Yet, I have not seen any fetch program use SQLite.
    - This (SQLite) = 0.014s
]#

import db_connector/db_sqlite
import std/strutils

proc dnfPkg*(): int =
  let dbPath = "/var/lib/rpm/rpmdb.sqlite"
  let db = open(dbPath, "", "", "")
  let dbstr = db.getValue(sql"SELECT count(*) FROM Packages")
  let res = parseInt(dbstr)
  db.close()
  return res
