# Build stage — gcc/binutils stay here, not in final image
FROM python:3.10-alpine3.23 AS builder

RUN apk update && \
  apk upgrade && \
  apk add gcc musl-dev libev-dev && \
  pip install --no-cache-dir --upgrade "pip>=26.1.2" "setuptools>=80.9.0" "wheel>=0.46.2" && \
  pip install --no-cache-dir cqlsh

# Runtime stage — no gcc, no binutils
FROM python:3.10-alpine3.23

RUN adduser -D appuser

# sqlite 3.53.2 (CVE-2026-11822/11824) not yet backported to alpine3.23; pull from edge
RUN apk update && \
  apk upgrade && \
  apk add bash libev && \
  apk add --repository=https://dl-cdn.alpinelinux.org/alpine/edge/main sqlite-libs

# Copy compiled Python packages (cassandra-driver .so linked against libev)
COPY --from=builder /usr/local/lib/python3.10/site-packages /usr/local/lib/python3.10/site-packages

# Explicit upgrade clears stale dist-info dirs left by COPY overlay.
# Also updates vendored jaraco.context inside setuptools (CVE-2026-23949).
RUN pip install --no-cache-dir --upgrade "pip>=26.1.2" "setuptools>=80.9.0" "wheel>=0.46.2"

ADD cqlsh /usr/local/bin/cqlsh
ADD cqlsh.py /usr/local/bin/cqlsh.py

RUN chmod +x /usr/local/bin/cqlsh /usr/local/bin/cqlsh.py && \
  chown -R appuser:appuser /usr/local/bin/cqlsh /usr/local/bin/cqlsh.py

USER appuser
