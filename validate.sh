#!/bin/bash
#
# CodeDeploy Lifecycle Hook: ValidateService
#
# This script performs three critical checks to ensure the application 
# deployed to the EC2 instance is running and accessible:
# 1. Check local access via http://localhost:8080.
# 2. Check access via the Private IP address of the instance.
# 3. Check access via the Public IP address of the instance.
#
# All checks must return an HTTP status code of 200 (OK).

APP_PORT=8080
LOG_FILE="/tmp/codedeploy_validation_$(date +%Y%m%d%H%M%S).log"
MAX_ATTEMPTS=5
SLEEP_TIME=5
URLS=()

# ==============================================================================
# 1. Fetch IP Addresses using AWS Metadata Service
# ==============================================================================
echo "--- Fetching instance metadata ---" | tee -a $LOG_FILE

PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 || echo "N/A")

echo "Private IP: $PRIVATE_IP" | tee -a $LOG_FILE
echo "Public IP: $PUBLIC_IP" | tee -a $LOG_FILE

# Define the URLs to check
URLS+=("http://localhost:${APP_PORT}")

if [ "$PRIVATE_IP" != "" ]; then
    URLS+=("http://${PRIVATE_IP}:${APP_PORT}")
fi

if [ "$PUBLIC_IP" != "N/A" ] && [ "$PUBLIC_IP" != "" ]; then
    URLS+=("http://${PUBLIC_IP}:${APP_PORT}")
fi

# ==============================================================================
# 2. Validation Function
# ==============================================================================

check_url() {
    local url="$1"
    local attempt=0

    echo "Attempting to reach $url..." | tee -a $LOG_FILE

    while [ $attempt -lt $MAX_ATTEMPTS ]; do
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X GET -m 5 "$url")

        if [ "$HTTP_CODE" -eq 200 ]; then
            echo "SUCCESS: $url returned HTTP $HTTP_CODE" | tee -a $LOG_FILE
            return 0
        else
            echo "Attempt $((attempt + 1)): $url returned HTTP $HTTP_CODE. Retrying in ${SLEEP_TIME}s..." | tee -a $LOG_FILE
            sleep $SLEEP_TIME
            attempt=$((attempt + 1))
        fi
    done

    echo "FAILURE: $url failed to return HTTP 200 after $MAX_ATTEMPTS attempts." | tee -a $LOG_FILE
    return 1
}

# ==============================================================================
# 3. Execute Checks and Determine Final Status
# ==============================================================================
VALIDATION_FAILED=0

for url_to_check in "${URLS[@]}"; do
    check_url "$url_to_check"
    if [ $? -ne 0 ]; then
        VALIDATION_FAILED=1
    fi
done

# ==============================================================================
# 4. Final Result
# ==============================================================================
if [ $VALIDATION_FAILED -eq 0 ]; then
    echo "--- All verifications passed successfully (HTTP 200) ---" | tee -a $LOG_FILE
    exit 0
else
    echo "--- One or more verifications failed. CodeDeploy deployment will fail. ---" | tee -a $LOG_FILE
    exit 1
fi
