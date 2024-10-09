# Use an official PHP runtime as a parent image
FROM php:8.2-cli

# Set the working directory in the container
WORKDIR /var/www/html

# Copy the current directory contents into the container at /var/www/html
COPY . /var/www/html

# Ensure the file has the correct permissions
RUN chmod 644 /var/www/html/index.php

# Make port 8080 available to the world outside this container
EXPOSE 8080

# Run PHP built-in server when the container launches
CMD ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/html"]