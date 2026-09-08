FROM python:3.14-slim

# Prevent Python from creating .pyc files
# and enable unbuffered logs
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set working directory
WORKDIR /app

# System dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy dependency file first
# This allows Docker to cache the dependency layer
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . .

# Create runtime directories
RUN mkdir -p chroma_db uploads logs

# Streamlit port
EXPOSE 8501

# Start Streamlit
CMD ["streamlit", "run", "app.py", "--server.address=0.0.0.0", "--server.port=8501"]