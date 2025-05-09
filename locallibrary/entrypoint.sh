#!/bin/sh

set -e

echo "📦 Aplicando migrações..."
python manage.py migrate --noinput

echo "🧹 Coletando arquivos estáticos..."
python manage.py collectstatic --noinput

# 🧑 Criar superusuário se não existir
if [ "$DJANGO_SUPERUSER_USERNAME" ] && [ "$DJANGO_SUPERUSER_EMAIL" ] && [ "$DJANGO_SUPERUSER_PASSWORD" ]; then
  echo "👤 Verificando ou criando superusuário..."
  python manage.py shell << END
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username="${DJANGO_SUPERUSER_USERNAME}").exists():
    User.objects.create_superuser(
        "${DJANGO_SUPERUSER_USERNAME}",
        "${DJANGO_SUPERUSER_EMAIL}",
        "${DJANGO_SUPERUSER_PASSWORD}"
    )
END
fi

echo "🚀 Iniciando Gunicorn..."
exec gunicorn locallibrary.wsgi:application --bind 0.0.0.0:8000 --workers 3
