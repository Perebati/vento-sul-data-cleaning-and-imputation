# 🐍 Configuração do Ambiente Python - Wind Data Analysis

Este projeto inclui um script automatizado para configurar o ambiente virtual Python com todas as dependências necessárias para análise de dados de vento.

## 📋 Arquivos Criados

- **`setup_env.sh`** - Script executável para configurar o ambiente virtual
- **`requirements.txt`** - Lista de dependências Python
- **`txt_to_csv_converter.ipynb`** - Notebook para conversão de dados

## 🚀 Como Usar

### 1. Primeira Execução (Criar Ambiente)

```bash
./setup_env.sh
```

### 2. Execuções Subsequentes (Atualizar Dependências)

```bash
./setup_env.sh
```

O script automaticamente:
- ✅ Detecta se o ambiente virtual já existe
- 🆕 Cria um novo ambiente virtual se não existir
- 🔄 Atualiza dependências se o ambiente já existir
- 📦 Instala/atualiza todas as bibliotecas do `requirements.txt`
- 💾 Gera um novo `requirements.txt` com versões atualizadas

## 🛠️ Funcionalidades do Script

### Primeira execução:
1. Verifica se Python3 está instalado
2. Cria ambiente virtual em `.venv/`
3. Ativa o ambiente virtual
4. Atualiza pip para a versão mais recente
5. Instala todas as dependências do `requirements.txt`
6. Exibe informações do ambiente configurado

### Execuções subsequentes:
1. Detecta ambiente virtual existente
2. Ativa o ambiente virtual
3. Atualiza pip
4. Atualiza todas as dependências para versões mais recentes
5. Atualiza `requirements.txt` com versões instaladas

## 📦 Dependências Incluídas

### Core Libraries
- **pandas** - Manipulação e análise de dados
- **numpy** - Computação numérica
- **matplotlib** - Gráficos básicos
- **seaborn** - Visualizações estatísticas
- **plotly** - Gráficos interativos

### Jupyter Ecosystem
- **jupyter** - Jupyter Notebook
- **jupyterlab** - Interface moderna do Jupyter
- **ipykernel** - Kernel Python para Jupyter

### Análise Específica de Dados de Vento
- **scipy** - Computação científica
- **statsmodels** - Análise de séries temporais
- **windrose** - Análise de dados meteorológicos

### Utilitários
- **openpyxl** - Leitura de arquivos Excel
- **requests** - Download de dados
- **black** - Formatação de código
- **flake8** - Análise de código

## 🎯 Ativação Manual do Ambiente

Após executar o script, você pode ativar o ambiente manualmente:

```bash
# Ativar ambiente virtual
source .venv/bin/activate

# Desativar ambiente virtual
deactivate
```

## 🔧 Estrutura do Projeto

```
wind_data_analysis/
├── setup_env.sh              # Script de configuração
├── requirements.txt           # Dependências Python
├── txt_to_csv_converter.ipynb # Notebook de conversão
├── .venv/                     # Ambiente virtual (criado pelo script)
├── raw_data/                  # Dados originais em TXT
│   ├── Dir.txt
│   ├── U.txt
│   ├── V.txt
│   ├── W.txt
│   └── WS.txt
└── csv_data/                  # Dados convertidos em CSV
    ├── Dir.csv
    ├── U.csv
    ├── V.csv
    ├── W.csv
    └── WS.csv
```

## ⚠️ Requisitos do Sistema

- **Linux** (Ubuntu, Debian, CentOS, etc.)
- **Python 3.6+** instalado
- **pip** disponível
- Permissões para criar diretórios e instalar pacotes Python

## 🐛 Solução de Problemas

### Erro de Permissão
```bash
chmod +x setup_env.sh
```

### Python não encontrado
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install python3 python3-pip python3-venv

# CentOS/RHEL
sudo yum install python3 python3-pip
```

### Atualizar apenas uma dependência específica
```bash
source .venv/bin/activate
pip install --upgrade nome_da_biblioteca
```

## 🎉 Pronto para Usar!

Após executar o script, seu ambiente estará configurado e pronto para:
- Executar notebooks Jupyter
- Converter dados TXT para CSV
- Analisar dados de vento
- Criar visualizações e gráficos

Execute `./setup_env.sh` sempre que quiser atualizar as dependências!
