# Use official Python image as base
FROM python:3.10-alpine3.17

# Set environment variables
#ENV PYTHONDONTWRITEBYTECODE=1
#ENV PYTHONUNBUFFERED=1

# Install cqlsh from PyPI
#RUN pip install --no-cache-dir cqlsh
RUN apk update
RUN apk upgrade
RUN pip install cqlsh

ADD cqlsh /usr/local/bin/cqlsh
ADD cqlsh.py /usr/local/bin/cqlsh.py
# Make cqlsh executable
RUN chmod +x /usr/local/bin/cqlsh /usr/local/bin/cqlsh.py

# Set default command
ENTRYPOINT ["cqlsh"]
CMD ["--help"]