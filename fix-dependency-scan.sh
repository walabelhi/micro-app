#!/bin/bash

echo "🚀 Starting FULL Dependency Scan Fix..."

# Step 1: Go to project
cd ~/micro-app || exit

# Step 2: Create reports folder
mkdir -p dependency-reports

# Step 3: Set NVD API KEY
export NVD_API_KEY="63C8EF73-2F28-F111-8369-129478FCB64D"

# Step 4: Install dependencies (VERY IMPORTANT)
echo "📦 Installing node_modules for all services..."

services=("auth" "client" "orders" "payments" "tickets" "expiration")

for service in "${services[@]}"; do
  echo "➡️ Installing dependencies for $service"
  cd "$service" || continue
  npm install
  cd ..
done

# Step 5: Run Dependency-Check (FAST MODE)
echo "🔍 Running OWASP Dependency-Check..."

for service in "${services[@]}"; do
  echo "➡️ Scanning $service"

  dependency-check \
    --project "$service" \
    --scan "./$service" \
    --format HTML \
    --out "./dependency-reports/${service}-deps.html" \
    --nvdApiKey "$NVD_API_KEY" \
    --disableAssembly \
    --disableRetireJS \
    --noupdate
done

# Step 6: Create index.html (dashboard)
echo "📄 Creating index page..."

cat <<EOF > ./dependency-reports/index.html
<!DOCTYPE html>
<html>
<head>
    <title>Dependency Reports</title>
</head>
<body>
    <h1>OWASP Dependency Reports</h1>
    <ul>
        <li><a href="auth-deps.html">Auth Service</a></li>
        <li><a href="client-deps.html">Client Service</a></li>
        <li><a href="orders-deps.html">Orders Service</a></li>
        <li><a href="payments-deps.html">Payments Service</a></li>
        <li><a href="tickets-deps.html">Tickets Service</a></li>
        <li><a href="expiration-deps.html">Expiration Service</a></li>
    </ul>
</body>
</html>
EOF

echo "✅ ALL DONE!"
echo "📂 Open reports with:"
echo "firefox ~/micro-app/dependency-reports/index.html"
