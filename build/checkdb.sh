#!/bin/bash
SUCCESSFUL_ATTEMPTS=0
MIN_SUCCESSFUL=5
check_db() {
    python -c "import MySQLdb, os; MySQLdb.connect(host='localhost', port=3306, user='smarttest', passwd='smarttest');"
    if [ $? -eq 0 ]; then
        SUCCESSFUL_ATTEMPTS=$((SUCCESSFUL_ATTEMPTS+1))
    fi
}

check_db
while [ $SUCCESSFUL_ATTEMPTS -lt $MIN_SUCCESSFUL ]; do
    check_db
    echo "$SUCCESSFUL_ATTEMPTS successful connections. Need $MIN_SUCCESSFUL. Sleeping for 1 second and retrying..."
    sleep 1
done

