#!/bin/bash

# Script para configurar ambiente virtual Python
# Autor: Sistema automatizado
# Data: $(date +%Y-%m-%d)

set -e  # Parar execução em caso de erro

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para imprimir mensagens coloridas
print_message() {
    echo -e "${2}${1}${NC}"
}

print_message "🐍 Configurador de Ambiente Virtual Python" $BLUE
print_message "===========================================" $BLUE

# Verificar se Python está instalado
if ! command -v python3 &> /dev/null; then
    print_message "❌ Python3 não encontrado. Por favor, instale o Python3 primeiro." $RED
    exit 1
fi

PYTHON_VERSION=$(python3 --version)
print_message "✅ $PYTHON_VERSION encontrado" $GREEN

# Diretório do ambiente virtual
VENV_DIR=".venv"
REQUIREMENTS_FILE="requirements.txt"

# Verificar se o ambiente virtual já existe
if [ -d "$VENV_DIR" ]; then
    print_message "📁 Ambiente virtual encontrado em $VENV_DIR" $YELLOW
    print_message "🔄 Atualizando dependências existentes..." $YELLOW
    
    # Ativar ambiente virtual existente
    source $VENV_DIR/bin/activate
    
    # Atualizar pip
    print_message "📦 Atualizando pip..." $BLUE
    pip install --upgrade pip
    
    # Instalar/atualizar dependências do requirements.txt
    if [ -f "$REQUIREMENTS_FILE" ]; then
        print_message "📋 Atualizando dependências do $REQUIREMENTS_FILE..." $BLUE
        pip install --upgrade -r $REQUIREMENTS_FILE
    else
        print_message "⚠️  Arquivo $REQUIREMENTS_FILE não encontrado!" $YELLOW
    fi
    
else
    print_message "🆕 Criando novo ambiente virtual..." $BLUE
    
    # Criar ambiente virtual
    python3 -m venv $VENV_DIR
    
    # Ativar ambiente virtual
    source $VENV_DIR/bin/activate
    
    print_message "✅ Ambiente virtual criado em $VENV_DIR" $GREEN
    
    # Atualizar pip
    print_message "📦 Atualizando pip..." $BLUE
    pip install --upgrade pip
    
    # Instalar dependências se o arquivo requirements.txt existir
    if [ -f "$REQUIREMENTS_FILE" ]; then
        print_message "📋 Instalando dependências do $REQUIREMENTS_FILE..." $BLUE
        pip install -r $REQUIREMENTS_FILE
    else
        print_message "⚠️  Arquivo $REQUIREMENTS_FILE não encontrado. Criando arquivo básico..." $YELLOW
        print_message "📝 Instalando dependências básicas..." $BLUE
        pip install pandas pathlib
    fi
fi

# Mostrar informações do ambiente
print_message "\n📊 Informações do Ambiente:" $BLUE
print_message "Localização do Python: $(which python)" $GREEN
print_message "Versão do Python: $(python --version)" $GREEN
print_message "Localização do pip: $(which pip)" $GREEN
print_message "Versão do pip: $(pip --version)" $GREEN

# Listar pacotes instalados
print_message "\n📦 Pacotes instalados:" $BLUE
pip list

# Gerar/atualizar requirements.txt
print_message "\n💾 Atualizando $REQUIREMENTS_FILE..." $BLUE
pip freeze > $REQUIREMENTS_FILE

print_message "\n🎉 Configuração concluída!" $GREEN
print_message "🔧 Para ativar o ambiente virtual manualmente, execute:" $YELLOW
print_message "   source $VENV_DIR/bin/activate" $YELLOW
print_message "🚀 Para desativar o ambiente virtual, execute:" $YELLOW
print_message "   deactivate" $YELLOW

# Verificar se estamos em um ambiente ativado
if [[ "$VIRTUAL_ENV" != "" ]]; then
    print_message "\n✅ Ambiente virtual está ATIVO" $GREEN
    print_message "📁 Localização: $VIRTUAL_ENV" $GREEN
else
    print_message "\n⚠️  Ambiente virtual NÃO está ativo" $YELLOW
fi
