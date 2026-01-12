#!/bin/bash

# Bootstrap script for local development

set -e

echo "🚀 Setting up Kubernetes Lab..."

# Check prerequisites
echo "📋 Checking prerequisites..."
command -v python >/dev/null 2>&1 || { echo "Python is required but not installed."; exit 1; }
command -v docker >/dev/null 2>&1 || { echo "Docker is required but not installed."; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "kubectl is required but not installed."; exit 1; }
command -v kustomize >/dev/null 2>&1 || { echo "kustomize is required but not installed."; exit 1; }

echo "✅ All prerequisites found"

# Create Python virtual environment
echo "🐍 Creating Python virtual environment..."
python -m venv venv
source venv/bin/activate

# Install dependencies
echo "📦 Installing dependencies..."
pip install --upgrade pip
pip install -r app/requirements.txt
pip install pytest pytest-cov httpx

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file..."
    cp .env.example .env
    echo "⚠️  Please update .env with your configuration"
fi

# Run tests
echo "🧪 Running tests..."
pytest app/tests/ -v --cov=app

echo "✨ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Update .env with your configuration"
echo "2. Run 'python app/main.py' to start the application"
echo "3. Visit http://localhost:8000/docs for API documentation"
