FROM python:3.11-slim as builder

WORKDIR /app

COPY requirements.txt .
# Install dependencies
RUN pip install --no-cache-dir --user -r requirements.txt

FROM python:3.11-slim

WORKDIR /app

COPY --from=builder . .

COPY app.py .

EXPOSE 5000

CMD ["python", "app.py" ]

