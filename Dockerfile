FROM mcr.microsoft.com/devcontainers/python:1-3.11-bullseye

ENV PYTHONUNBUFFERED=1

ENV PYTHONDONTWRITEBYTECODE=1

# Copy default endpoint specific user settings overrides into container to specify Python path
COPY .vscode/settings.json /root/.vscode-remote/data/Machine/settings.json

# Install Python Requirements
ADD requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

# Clean VS Code Remote Server
RUN rm -rf /root/.vscode-server

# Configure Django project
ADD larsaofrancisco /code/larsaofrancisco
ADD docker-entrypoint.sh /code
WORKDIR /code

# Expose ports
# 8000 = gunicorn
EXPOSE 8000

# Enable production settings by default; for development, this can be set to
# `false` in `docker run --env`
ENV DJANGO_PRODUCTION=true
ENV DJANGO_SETTINGS_MODULE=settings.settings

ENTRYPOINT ["/bin/bash", "/code/docker-entrypoint.sh"]
CMD ["web"]
