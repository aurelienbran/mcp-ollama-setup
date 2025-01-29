# Installation de MCP, Ollama et DeepSeek

## Prérequis

- Python 3.11+
- Go
- Node.js 22.10+
- PowerShell (avec droits administrateur)

## Instructions d'installation

1. Cloner le dépôt :
```powershell
git clone https://github.com/aurelienbran/mcp-ollama-setup.git
cd mcp-ollama-setup
```

2. Exécuter le script d'installation :
```powershell
.\setup.ps1
```

## Composants installés

- Ollama
- Modèle DeepSeek
- Serveur MCP local
- Dépendances Python

## Tester l'installation

1. Démarrer le serveur MCP :
```powershell
cd C:\mcp_server
.\venv\Scripts\Activate
python main.py
```

2. Tester avec curl ou Invoke-RestMethod :
```powershell
Invoke-RestMethod -Uri "http://localhost:8000" -Method Post -Body (@{
    jsonrpc = "2.0"
    method = "handle_request"
    params = @{
        prompt = "Bonjour"
        model = "deepseek/chat"
    }
    id = 1
} | ConvertTo-Json) -ContentType "application/json"
```

## Résolution des problèmes

- Vérifiez que tous les prérequis sont installés
- Assurez-vous d'exécuter PowerShell en mode administrateur
- Consultez les logs pour plus de détails

## Contributions

Les contributions sont les bienvenues ! Ouvrez une issue ou soumettez une pull request.
