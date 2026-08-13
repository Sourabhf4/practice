# Use the official lightweight Nginx image
FROM nginx:alpine

# Copy your local index.html into the Nginx public folder
COPY index.html /usr/share/nginx/html/index.html
