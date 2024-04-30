FROM python:3.9

WORKDIR /python-app

RUN apt-get update && apt-get install -y \
    python3-dev \
    python3-pip

COPY requirements.txt requirements.txt

RUN pip3 install -r requirements.txt

COPY . .

EXPOSE 80

CMD ["python3", "my-app.py"]