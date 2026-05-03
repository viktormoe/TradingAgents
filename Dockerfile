FROM python:3.12-slim

# Install system dependencies including libcurl for curl_cffi and ttyd
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    libcurl4-openssl-dev \
    libssl-dev \
    sqlite3 \
    ca-certificates \
    tmux \
    && curl -fsSL https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64 -o /usr/local/bin/ttyd \
    && chmod +x /usr/local/bin/ttyd \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /home/appuser/app

# Create non-root user
RUN useradd -m appuser && chown -R appuser:appuser /home/appuser/app

# Copy dependency files first for caching
COPY pyproject.toml ./
# Create dummy package directories to allow dependency installation from pyproject.toml
RUN mkdir -p tradingagents cli && touch tradingagents/__init__.py cli/__init__.py
RUN pip install --no-cache-dir .

# Now copy the actual application code
COPY --chown=appuser:appuser . .

# Re-install the project with the actual code
RUN pip install --no-cache-dir .

# Ensure static and data directories exist
RUN mkdir -p static data && chown -R appuser:appuser static data

USER appuser

EXPOSE 5050

# Default command if not overridden by docker-compose
CMD ["tradingagents"]
