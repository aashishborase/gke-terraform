# Use the official Nginx image from the Docker Hub
FROM nginx:latest

# Remove the default Nginx static files (optional step)
RUN rm /usr/share/nginx/html/*

# Copy your custom index.html to the appropriate directory
COPY ./application/index.html /usr/share/nginx/html/index.html

# Expose port 80 to access the Nginx server
EXPOSE 80

# Start Nginx when the container starts
CMD ["nginx", "-g", "daemon off;"]
