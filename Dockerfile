# Dockerfile (root of your repo)
FROM python:3.11

# Set DNS servers via environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Update pip and setup tools
RUN pip install --upgrade pip setuptools wheel

# 1) Copy only requirements, install them with retries and better error handling
COPY requirements.txt .

# Install packages with network timeout and retry configuration
RUN pip install --no-cache-dir \
    --timeout 300 \
    --retries 5 \
    --default-timeout=300 \
    -r requirements.txt || \
    (echo "First attempt failed, trying with different index..." && \
     pip install --no-cache-dir \
     --timeout 300 \
     --retries 3 \
     --index-url https://pypi.org/simple/ \
     --trusted-host pypi.org \
     --trusted-host pypi.python.org \
     --trusted-host files.pythonhosted.org \
     -r requirements.txt)

# 2) Now copy the rest of your application
COPY . .

# Do not create a separate frontend directory or copy files
# The original frontend folder at /app/frontend will be used directly

# Verify the contents
RUN echo "Contents of the workspace:" && ls -la && \
    echo "Contents of frontend directory:" && ls -la /app/frontend

# 3) Start Uvicorn with debugging information
CMD ["uvicorn", "backend.main:app", "--host", "0.0.0.0", "--port", "8002", "--log-level", "debug"]
