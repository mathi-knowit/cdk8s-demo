#!/bin/sh

# Default values if not set
export SERVICE_NAME=${SERVICE_NAME:-database-service}
export SERVICE_PORT=${SERVICE_PORT:-80}

# Debug: Print environment variables
echo "Environment Variables:"
env | grep DB_SERVICE_NAME
env | grep DB_SERVICE_PORT

# Substitute environment variables in the config file (write to /tmp)
envsubst '$DB_SERVICE_NAME $DB_SERVICE_PORT' < /etc/nginx/nginx.template.conf > /tmp/nginx.conf

# Print the contents of the generated nginx.conf file
echo "Generated nginx.conf:"
cat /tmp/nginx.conf

# Start Nginx using the generated config
exec nginx -c /tmp/nginx.conf -g 'daemon off;'
