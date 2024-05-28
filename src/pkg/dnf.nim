#[
    Most efficient rpm reading.
    The majority of fetch programs use some varient of an RPM command. Such as;
    - "rpm -qa | wc -l" = 1.4s
    Yet, I have not seen any fetch program use SQLite.
    - This (SQLite) = 0.014s
]#

import db_connector/db_sqlite

# Open a connection to the SQLite database
let dbPath = "/var/lib/rpm/rpmdb.sqlite"
let db = open(dbPath, "", "", "")

# Execute the query to count the number of packages
let result = db.getValue(sql"SELECT count(*) FROM Packages")

# Print the result
echo "Number of packages: ", result

# Close the database connection
db.close()

