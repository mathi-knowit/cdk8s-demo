# Use the official Nginx image as the base
FROM nginx:alpine

# Install gettext for envsubst
RUN apk add --no-cache gettext

# Copy the Nginx template configuration file
COPY nginx.template.conf /etc/nginx/nginx.template.conf

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose port 80
EXPOSE 8080

# run as non root user
USER nginx

# Set the entrypoint script
ENTRYPOINT ["/entrypoint.sh"]
