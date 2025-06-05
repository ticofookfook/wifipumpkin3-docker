# WiFi Pumpkin3 - Script de Execução

Um script bash estruturado para executar o WiFi Pumpkin3 em container Docker de forma simples e configurável.

## 📋 Pré-requisitos

- **Docker** instalado e em execução
- **Privilégios de administrador** (sudo)
- **Interface WiFi** disponível (ex: wlan0, wlan1)
- **Imagem Docker** do WiFi Pumpkin3

### Instalação do Docker (Ubuntu/Debian)
```bash
sudo apt update
sudo apt install docker.io
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER
```

### Preparação da Imagem WiFi Pumpkin3
```bash
# Opção 1: Pull da imagem oficial (se disponível)
docker pull wifipumpkin3

# Opção 2: Build local (se tiver Dockerfile)
docker build -t wifipumpkin3 .
```

## 🚀 Instalação

1. **Clone ou baixe o script:**
```bash
wget https://seu-repositorio.com/wifipumpkin3.sh
# ou
curl -O https://seu-repositorio.com/wifipumpkin3.sh
```

2. **Torne o script executável:**
```bash
chmod +x wifipumpkin3.sh
```

3. **Crie os diretórios necessários (opcional - o script faz automaticamente):**
```bash
mkdir -p logs config
```

## 📖 Uso

### Sintaxe
```bash
./wifipumpkin3.sh [OPÇÕES] <SSID>
```

### Parâmetros

| Parâmetro | Obrigatório | Descrição |
|-----------|-------------|-----------|
| `SSID` | ✅ | Nome da rede WiFi a ser criada |

### Opções

| Opção | Padrão | Descrição |
|-------|--------|-----------|
| `-i, --interface` | `wlan1` | Interface de rede WiFi |
| `-p, --proxy` | `captiveflask` | Tipo de proxy a ser usado |
| `-n, --name` | `wifipumpkin3` | Nome do container Docker |
| `-d, --dark-login` | `true` | Ativar tema escuro no portal |
| `-h, --help` | - | Mostrar ajuda |

### Exemplos de Uso

#### Uso básico
```bash
./wifipumpkin3.sh "REDE-TESTE-SID"
```

#### Uso com interface personalizada
```bash
./wifipumpkin3.sh -i wlan0 "MeuHotspot"
```

#### Uso completo com todas as opções
```bash
./wifipumpkin3.sh \
    --interface wlan2 \
    --proxy captiveflask \
    --name meu-wifipumpkin \
    --dark-login false \
    "RedeTesteSemTemaEscuro"
```

#### Usar com interface específica e proxy diferente
```bash
./wifipumpkin3.sh -i wlan0 -p noproxy "RedeSimples"
```

## 🔧 Configuração de Interface

### Identificar interfaces disponíveis
```bash
# Listar todas as interfaces de rede
ip link show

# Ou usar iwconfig para interfaces wireless
iwconfig
```

### Verificar se a interface suporta modo monitor
```bash
sudo iw dev wlan1 info
```

## ⚠️ Solução de Problemas

### Problema: Conexão WiFi caindo constantemente

Se você estiver enfrentando problemas com a conexão WiFi caindo ou sendo interrompida pelo NetworkManager, siga estes passos:

#### 1. Configure o NetworkManager para ignorar a interface

Edite o arquivo de configuração do NetworkManager:
```bash
sudo nano /etc/NetworkManager/NetworkManager.conf
```

Adicione ou modifique a seção `[keyfile]`:
```ini
[main]
plugins=keyfile

[keyfile]
unmanaged-devices=interface-name:wlan1
```

> **Nota:** Substitua `wlan1` pela interface que você está usando no script.

#### 2. Reinicie o NetworkManager
```bash
sudo systemctl restart NetworkManager
```

#### 3. Verifique se a configuração foi aplicada
```bash
nmcli device status
```

A interface deve aparecer como "unmanaged" (não gerenciada).

#### 4. Configuração alternativa por MAC Address

Se o método acima não funcionar, você pode usar o endereço MAC:

```bash
# Descobrir o MAC address da interface
ip link show wlan1
```

Adicione no arquivo de configuração:
```ini
[keyfile]
unmanaged-devices=mac:aa:bb:cc:dd:ee:ff
```

#### 5. Desabilitar o NetworkManager temporariamente (última opção)
```bash
# Parar o serviço (cuidado: pode afetar outras conexões)
sudo systemctl stop NetworkManager

# Para reativar depois
sudo systemctl start NetworkManager
```

### Outros Problemas Comuns

#### Docker não está rodando
```bash
sudo systemctl status docker
sudo systemctl start docker
```

#### Permissões insuficientes
```bash
# Adicionar usuário ao grupo docker
sudo usermod -aG docker $USER
# Fazer logout e login novamente
```

#### Interface WiFi não disponível
```bash
# Verificar se o driver está carregado
lsmod | grep -i wifi

# Verificar dispositivos USB (para adaptadores WiFi USB)
lsusb
```

#### Container não consegue acessar a interface
```bash
# Verificar se a interface está UP
sudo ip link set wlan1 up

# Verificar se não há conflitos
sudo airmon-ng check kill
```
