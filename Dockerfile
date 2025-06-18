# Use official Python image as base
FROM python:3.10-alpine3.17

# Set environment variables
#ENV PYTHONDONTWRITEBYTECODE=1
#ENV PYTHONUNBUFFERED=1

# Create a non-root user
RUN adduser -D appuser

# Install cqlsh from PyPI
RUN apk update && \
  apk upgrade && \
  pip install --no-cache-dir --upgrade pip==23.3.0 setuptools==78.1.1 && \
  pip install cqlsh==5.0.4

ADD cqlsh /usr/local/bin/cqlsh
ADD cqlsh.py /usr/local/bin/cqlsh.py

# Make cqlsh executable
RUN chmod +x /usr/local/bin/cqlsh /usr/local/bin/cqlsh.py

# Change ownership of the application files to appuser
RUN chown -R appuser:appuser /usr/local/bin/cqlsh /usr/local/bin/cqlsh.py

# Switch to appuser
USER appuser

# Set default command
#ENTRYPOINT ["cqlsh"]
#CMD ["--help"]