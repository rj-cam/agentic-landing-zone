#!/bin/sh
set -e

ENVIRONMENT="${ENVIRONMENT:-unknown}"

case "$ENVIRONMENT" in
  nonprod)
    cp /usr/local/apache2/pages/nonprod.html /usr/local/apache2/htdocs/index.html
    ;;
  prod)
    cp /usr/local/apache2/pages/prod.html /usr/local/apache2/htdocs/index.html
    ;;
  *)
    cat > /usr/local/apache2/htdocs/index.html <<EOF
<!DOCTYPE html>
<html lang="en">
<head><meta charset="utf-8"><title>Landing Zone - ${ENVIRONMENT}</title></head>
<body style="font-family:sans-serif;text-align:center;padding:4rem;">
<h1>AWS Landing Zone</h1>
<p>Environment: <strong>${ENVIRONMENT}</strong></p>
</body>
</html>
EOF
    ;;
esac

echo "Starting httpd (env=${ENVIRONMENT})"
exec httpd-foreground
