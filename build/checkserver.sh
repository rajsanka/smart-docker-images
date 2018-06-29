#!/bin/bash
SUCCESSFUL_ATTEMPTS=0
MIN_SUCCESSFUL=5
check_server_started() {
    nc -z localhost 9081
    if [ $? -eq 0 ]; then
        SUCCESSFUL_ATTEMPTS=$((SUCCESSFUL_ATTEMPTS+1))
    fi
}

check_server_started
while [ $SUCCESSFUL_ATTEMPTS -lt $MIN_SUCCESSFUL ]; do
    check_server_started
    echo "$SUCCESSFUL_ATTEMPTS successful connections. Need $MIN_SUCCESSFUL. Sleeping for 1 second and retrying..."
    sleep 2
done

