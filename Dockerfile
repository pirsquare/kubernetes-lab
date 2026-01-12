# Multi-stage Dockerfile for FastAPI application using AlmaLinux

# Build stage
FROM almalinux:9 as builder

WORKDIR /build

RUN dnf install -y python3.11 python3.11-pip python3.11-devel gcc && dnf clean all

COPY app/requirements.txt .

RUN python3.11 -m pip install --user --no-cache-dir -r requirements.txt

# Runtime stage
FROM almalinux:9

# Install Python runtime
RUN dnf install -y python3.11 && dnf clean all

WORKDIR /app

# Copy Python dependencies from builder
COPY --from=builder /root/.local /root/.local

# Set environment variables
ENV PATH=/root/.local/bin:$PATH \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PORT=8000

# Copy application code
COPY app/ .

# Create non-root user for security
RUN useradd -m -u 1000 appuser && \
    chown -R appuser:appuser /app

USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python3.11 -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health').read()"

EXPOSE ${PORT}

CMD ["python3.11", "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
