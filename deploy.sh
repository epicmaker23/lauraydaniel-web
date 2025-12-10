#!/bin/bash

# Script de despliegue para Laura & Daniel Web
# Uso: ./deploy.sh

set -e  # Salir si hay algún error

echo "🚀 Iniciando despliegue de Laura & Daniel Web..."

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Verificar que estamos en el directorio correcto
if [ ! -f "docker-compose.yml" ]; then
    echo -e "${RED}❌ Error: No se encuentra docker-compose.yml${NC}"
    echo "Asegúrate de estar en el directorio del proyecto."
    exit 1
fi

# Verificar que existe build/web
if [ ! -d "build/web" ]; then
    echo -e "${RED}❌ Error: No se encuentra build/web${NC}"
    echo "Primero compila la aplicación con: flutter build web --release"
    exit 1
fi

echo -e "${YELLOW}📦 Deteniendo contenedor existente...${NC}"
docker-compose down || true

echo -e "${YELLOW}🐳 Iniciando contenedor Docker...${NC}"
docker-compose up -d

echo -e "${YELLOW}⏳ Esperando a que el contenedor inicie...${NC}"
sleep 3

# Verificar que el contenedor está corriendo
if docker ps | grep -q lauraydaniel-web; then
    echo -e "${GREEN}✅ Contenedor iniciado correctamente${NC}"
    echo ""
    echo "📊 Estado del contenedor:"
    docker-compose ps
    echo ""
    echo "📝 Logs recientes:"
    docker-compose logs --tail=20
    echo ""
    echo -e "${GREEN}🎉 ¡Despliegue completado!${NC}"
    echo ""
    echo "La aplicación debería estar disponible en:"
    echo "  - http://localhost:8043 (si accedes directamente)"
    echo "  - http://tu-dominio.com (a través de Nginx)"
else
    echo -e "${RED}❌ Error: El contenedor no se inició correctamente${NC}"
    echo "Revisa los logs con: docker-compose logs"
    exit 1
fi
