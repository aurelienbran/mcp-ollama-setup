# Script d'installation MCP, Ollama et DeepSeek

# Vérifier les prérequis
function Test-Prerequisites {
    $pythonVersion = python --version 2>&1
    $goVersion = go version 2>&1
    $nodeVersion = node --version 2>&1

    Write-Host "Vérification des versions :"
    Write-Host "Python : $pythonVersion"
    Write-Host "Go : $goVersion"
    Write-Host "Node.js : $nodeVersion"
}

# Installer Ollama
function Install-Ollama {
    Write-Host "Téléchargement d'Ollama..."
    $ollamaUrl = "https://ollama.ai/download/windows"
    Invoke-WebRequest -Uri $ollamaUrl -OutFile "ollama_installer.exe"
    
    Write-Host "Installation d'Ollama..."
    Start-Process -FilePath ".\ollama_installer.exe" -Wait
}

# Récupérer le modèle DeepSeek
function Install-DeepSeek {
    ollama pull deepseek/chat
}

# Créer le serveur MCP
function Create-MCPServer {
    # Créer le répertoire du projet
    New-Item -Path "C:\mcp_server" -ItemType Directory -Force
    Set-Location "C:\mcp_server"

    # Créer un environnement virtuel
    python -m venv venv
    .\venv\Scripts\Activate

    # Installer les dépendances
    pip install json-rpc-server requests

    # Créer le fichier main.py
    @"
# main.py
from jsonrpc_server import method, dispatch
import json
import subprocess

@method
def register_tool(tool_name: str, config: dict) -> str:
    print(f"Outil {tool_name} enregistré avec la configuration : {config}")
    return f"Tool {tool_name} registered successfully"

@method
def handle_request(params: dict) -> dict:
    try:
        result = subprocess.run(
            ['ollama', 'run', params.get('model', 'deepseek/chat')],
            input=params.get('prompt', '').encode(),
            capture_output=True,
            text=True
        )
        
        return {
            "answer": result.stdout.strip(),
            "error": result.stderr.strip() if result.stderr else None
        }
    except Exception as e:
        return {
            "answer": None,
            "error": str(e)
        }

def application(request):
    try:
        content_length = int(request.environ.get('CONTENT_LENGTH', 0))
        body = request.environ['wsgi.input'].read(content_length)
        json_request = json.loads(body.decode('utf-8'))
        
        response = dispatch(json_request)
        response_body = json.dumps(response).encode('utf-8')
        
        return [response_body]
    except Exception as e:
        error_response = json.dumps({
            "jsonrpc": "2.0",
            "error": {
                "code": -32603,
                "message": str(e)
            },
            "id": None
        }).encode('utf-8')
        return [error_response]

if __name__ == "__main__":
    from wsgiref.simple_server import make_server

    httpd = make_server('', 8000, application)
    print("Serveur MCP démarré sur le port 8000...")
    httpd.serve_forever()
"@ | Out-File -FilePath main.py -Encoding UTF8
}

# Fonction principale
function Main {
    Test-Prerequisites
    Install-Ollama
    Install-DeepSeek
    Create-MCPServer
    
    Write-Host "Installation terminée !"
}

# Exécuter le script
Main
