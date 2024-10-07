# Use an official Python runtime as a parent image
FROM python:3.12-slim

# Set the working directory in the container
WORKDIR /app

# Install Flask
RUN pip install --no-cache-dir flask==3.0.0

# Copy the current directory contents into the container at /app
COPY . /app

# Make port 8080 available to the world outside this container
EXPOSE 8082

# Run app.py when the container launches
CMD ["python", "svc.py"]