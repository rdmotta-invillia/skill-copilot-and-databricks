# Guia de Setup: Databricks Free Edition + VS Code + Copilot

## 1. Criando sua Conta Gratuita no Databricks

### Passo 1 — Acesse o Databricks Free Edition

1. Acesse: https://login.databricks.com/?dbx_source=docs&intent=CE_SIGN_UP
2. Clique em **"Sign Up"** e crie sua conta gratuita
3. Preencha nome, e-mail e senha
4. Confirme o e-mail e faça login

> **Limites da Free Edition:**
> - Ambiente serverless-only e quota limitada
> - Suporte a Unity Catalog e Volumes para os exercícios deste treinamento
> - Sem necessidade de DBFS root ou mounts para os arquivos do curso

---

## 2. Configurando o Cluster

1. No Databricks, acesse **Compute → Create compute**
2. Configure o compute serverless disponível na interface da Free Edition
3. Clique em **Create compute**
4. Aguarde o compute iniciar (ícone verde)

---

## 3. Instalando o VS Code e Extensões

Antes de seguir localmente, garanta Python 3.12 ou superior e Java 11+ instalados na sua máquina.

### VS Code
- Baixe em: https://code.visualstudio.com/

### Extensão Databricks
```
Ctrl+Shift+X → buscar "Databricks" → instalar "Databricks" (by Databricks)
```

### GitHub Copilot
```
Ctrl+Shift+X → buscar "GitHub Copilot" → instalar
```
Faça login com sua conta GitHub quando solicitado.

---

## 4. Conectando VS Code ao Databricks

### Método: Personal Access Token

1. No Databricks, acesse **Settings → Developer → Access Tokens**
2. Clique em **"Generate new token"**
   - Comment: `vscode-training`
   - Lifetime (days): 90
3. Copie e salve o token gerado (não será exibido novamente)

### Configurando a extensão no VS Code

1. Pressione `Ctrl+Shift+P` → digite **"Databricks: Configure workspace"**
2. Selecione **"Databricks Free Edition"**
3. Informe a URL do seu workspace: `https://community.cloud.databricks.com`
4. Cole o Personal Access Token gerado
5. Selecione o cluster criado anteriormente

### Verificando a conexão

No VS Code, o painel lateral da extensão Databricks deve mostrar:
- Status do cluster (Running/Terminated)
- Arquivos do Volume
- Jobs disponíveis

---

## 5. Estrutura de Pastas no Databricks Workspace

Crie um Volume no Databricks Workspace:
```
/Workspace/Users/{seu-email}/databricks-training/
├── 01_intro/
├── 02_copilot_integration/
├── 03_pipeline_optimization/
└── 04_project_hands_on/
```

---

## 6. Verificando o GitHub Copilot

1. Abra qualquer arquivo `.py` no VS Code
2. Comece a digitar um comentário: `# Crie uma função que lê um CSV`
3. O Copilot deve sugerir código automaticamente (texto acinzentado)
4. Pressione `Tab` para aceitar a sugestão

### Atalhos Principais do Copilot
| Ação | Atalho |
|------|--------|
| Aceitar sugestão | `Tab` |
| Rejeitar sugestão | `Esc` |
| Próxima sugestão | `Alt+]` |
| Sugestão anterior | `Alt+[` |
| Abrir painel de sugestões | `Ctrl+Enter` |
| Abrir Copilot Chat | `Ctrl+Alt+I` |

---

## 7. Checklist Final

- [ ] Conta Databricks Free Edition criada e funcionando
- [ ] Compute serverless criado e no status "Running"
- [ ] VS Code instalado
- [ ] Extensão Databricks instalada e conectada ao workspace
- [ ] GitHub Copilot instalado e ativo
- [ ] Teste de sugestão do Copilot funcionando

Você está pronto para o treinamento!
