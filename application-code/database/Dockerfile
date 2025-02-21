# Use official Nginx base image
FROM nginx:alpine

# Remove default Nginx config and replace with our custom config
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 8080

# run as non root user
USER nginx

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
