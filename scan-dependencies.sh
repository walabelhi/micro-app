#!/bin/bash

echo "Starting OWASP Dependency-Check scan..."

# Your NVD API Key
API_KEY="63C8EF73-2F28-F111-8369-129478FCB64D"

# Services list
services=("auth" "orders" "payments" "tickets" "expiration" "client")

# Base directory
BASE_DIR=~/micro-app
REPORT_DIR=$BASE_DIR/dependency-reports

# Create report directory if not exists
mkdir -p $REPORT_DIR

# Clean old reports
rm -f $REPORT_DIR/*.html

# Loop through services
for service in "${services[@]}"; do
    echo "----------------------------------------"
    echo "Scanning $service service..."
    
    dependency-check \
        --project "$service Service" \
        --scan "$BASE_DIR/$service" \
        --format HTML \
        --out "$REPORT_DIR/$service-deps.html" \
        --nvdApiKey $API_KEY

    echo "$service scan completed!"
done

# Create index.html
echo "Generating main report page..."

cat <<EOL > $REPORT_DIR/index.html
<!DOCTYPE html>
<html>
<head>
    <title>OWASP Dependency Reports</title>
</head>
<body>
    <h1>OWASP Dependency-Check Reports</h1>
    <ul>
EOL

for service in "${services[@]}"; do
    echo "<li><a href=\"$service-deps.html\">$service Service Report</a></li>" >> $REPORT_DIR/index.html
done

echo "
    </ul>
</body>
</html>" >> $REPORT_DIR/index.html

echo "----------------------------------------"
echo "ALL SCANS COMPLETED ✅"
echo "Open this file in your browser:"
echo "$REPORT_DIR/index.html"
