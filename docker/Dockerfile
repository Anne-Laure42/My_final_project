# Uses python:3.9 image to build the Docker image
FROM python:3.9

# Defines the working directory (all the following commands will be executed into this directory)
WORKDIR /python-app

# Updates packages and install packages for "python3-dev" and "python3-pip" inside the container
RUN apt-get update && apt-get install -y \
    python3-dev \
    python3-pip

# Copy the "requirements.txt" from the local repo to the container's working directory "/python-app"
COPY python-app/requirements.txt /python-app/requirements.txt

# Executes the command "pip3 install" to install Python dependancies listed into requirements.txt
RUN pip3 install -r requirements.txt

# Copy all the current directory into the container's working directory /python-app
COPY python-app/ /python-app/

# Specifies the port the container is listening to
EXPOSE 3000

# Run commands within the container
CMD ["python3", "my-app.py"]