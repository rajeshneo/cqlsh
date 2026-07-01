# Build stage — gcc/binutils stay here, not in final image
FROM python:3.10-alpine3.21 AS builder

RUN apk update && \
    apk upgrade && \
    apk add gcc musl-dev libev-dev && \
    pip install --no-cache-dir --upgrade "pip>=25.3" "setuptools>=80.9.0" "wheel>=0.46.2" && \
    pip install --no-cache-dir cqlsh

# Runtime stage — no gcc, no binutils
FROM python:3.10-alpine3.21

RUN adduser -D appuser

# apk upgrade patches sqlite-libs (CVE-2026-11822/11824) and libuuid (CVE-2026-27456)
RUN apk update && \
    apk upgrade && \
    apk add bash libev

# Copy compiled Python packages (includes cassandra-driver .so linked against libev)
COPY --from=builder /usr/local/lib/python3.10/site-packages /usr/local/lib/python3.10/site-packages
COPY --from=builder /usr/local/bin/cqlsh* /usr/local/bin/

ADD cqlsh /usr/local/bin/cqlsh
ADD cqlsh.py /usr/local/bin/cqlsh.py

RUN chmod +x /usr/local/bin/cqlsh /usr/local/bin/cqlsh.py && \
    chown -R appuser:appuser /usr/local/bin/cqlsh /usr/local/bin/cqlsh.py

USER appuser
