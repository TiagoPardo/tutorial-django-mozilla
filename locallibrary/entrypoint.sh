#!/bin/sh

set -e

echo "📦 Aplicando migrações..."
python manage.py migrate --noinput

echo "🧹 Coletando arquivos estáticos..."
python manage.py collectstatic --noinput

echo "🚀 Iniciando Gunicorn..."
exec gunicorn locallibrary.wsgi:application --bind 0.0.0.0:8000 --workers 3
