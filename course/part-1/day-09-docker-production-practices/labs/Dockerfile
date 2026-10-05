FROM python:3.11-slim
WORKDIR /app
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt && useradd --create-home --shell /usr/sbin/nologin appuser
COPY app.py .
USER appuser
EXPOSE 5000
CMD ["python", "app.py"]
