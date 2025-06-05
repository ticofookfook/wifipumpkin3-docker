#!/bin/bash

# WiFi Pumpkin3 - Script Estruturado
# Autor: [Seu Nome]
# Data: $(date +%Y-%m-%d)

set -e  # Sair em caso de erro
set -u  # Sair se variável não definida for usada

# Configurações padrão
DEFAULT_INTERFACE="wlan1"
DEFAULT_PROXY="captiveflask"
DEFAULT_CONTAINER_NAME="wifipumpkin3"
DEFAULT_IMAGE="wifipumpkin3"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para mostrar ajuda
show_help() {
    echo -e "${BLUE}WiFi Pumpkin3 - Script de Execução${NC}"
    echo ""
    echo "Uso: $0 [OPÇÕES] <SSID>"
    echo ""
    echo "Parâmetros obrigatórios:"
    echo "  SSID                 Nome da rede WiFi a ser criada"
    echo ""
    echo "Opções:"
    echo "  -i, --interface      Interface de rede (padrão: $DEFAULT_INTERFACE)"
    echo "  -p, --proxy          Tipo de proxy (padrão: $DEFAULT_PROXY)"
    echo "  -n, --name           Nome do container (padrão: $DEFAULT_CONTAINER_NAME)"
    echo "  -d, --dark-login     Ativar tema escuro no login (padrão: true)"
    echo "  -h, --help           Mostrar esta ajuda"
    echo ""
    echo "Exemplos:"
    echo "  $0 \"SID-EXEMPLO-AQUI\""
    echo "  $0 -i wlan0 -p captiveflask \"MeuSSID\""
    echo "  $0 --interface wlan2 --dark-login false \"RedeTest\""
}

# Função para log
log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

# Função para log de erro
log_error() {
    echo -e "${RED}[ERRO]${NC} $1" >&2
}

# Função para log de aviso
log_warning() {
    echo -e "${YELLOW}[AVISO]${NC} $1"
}

# Função para validar se o Docker está rodando
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        log_error "Docker não está rodando ou não está acessível"
        exit 1
    fi
}

# Função para validar se a imagem existe
check_image() {
    local image="$1"
    if ! docker image inspect "$image" > /dev/null 2>&1; then
        log_error "Imagem Docker '$image' não encontrada"
        log "Execute: docker pull $image"
        exit 1
    fi
}

# Função para limpar containers anteriores
cleanup_container() {
    local container_name="$1"
    if docker ps -a --format '{{.Names}}' | grep -q "^${container_name}$"; then
        log_warning "Removendo container existente: $container_name"
        docker rm -f "$container_name" > /dev/null 2>&1
    fi
}

# Função para criar diretórios necessários
create_directories() {
    local dirs=("./logs" "./config")
    for dir in "${dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            log "Criando diretório: $dir"
            mkdir -p "$dir"
        fi
    done
}

# Função principal para executar o WiFi Pumpkin3
run_wifipumpkin3() {
    local interface="$1"
    local ssid="$2"
    local proxy="$3"
    local container_name="$4"
    local image="$5"
    local dark_login="$6"
    
    log "Iniciando WiFi Pumpkin3 com as seguintes configurações:"
    echo -e "  ${BLUE}Interface:${NC} $interface"
    echo -e "  ${BLUE}SSID:${NC} $ssid"
    echo -e "  ${BLUE}Proxy:${NC} $proxy"
    echo -e "  ${BLUE}Container:${NC} $container_name"
    echo -e "  ${BLUE}Dark Login:${NC} $dark_login"
    echo ""
    
    # Construir comando do WiFi Pumpkin3
    local wp3_command="wifipumpkin3 --xpulp \"set interface $interface; set ssid $ssid; set proxy $proxy; set $proxy.DarkLogin $dark_login; start\""
    
    # Executar container
    log "Executando container Docker..."
    docker run \
        --privileged \
        -ti \
        --rm \
        --name "$container_name" \
        -v ./logs:/root/.config/wifipumpkin3/logs \
        -v ./config:/root/.config/wifipumpkin3/config \
        --net host \
        "$image" \
        sh -c "$wp3_command"
}

# Função principal
main() {
    # Variáveis para parâmetros
    local interface="$DEFAULT_INTERFACE"
    local proxy="$DEFAULT_PROXY"
    local container_name="$DEFAULT_CONTAINER_NAME"
    local image="$DEFAULT_IMAGE"
    local dark_login="true"
    local ssid=""
    
    # Parse dos argumentos
    while [[ $# -gt 0 ]]; do
        case $1 in
            -i|--interface)
                interface="$2"
                shift 2
                ;;
            -p|--proxy)
                proxy="$2"
                shift 2
                ;;
            -n|--name)
                container_name="$2"
                shift 2
                ;;
            -d|--dark-login)
                dark_login="$2"
                shift 2
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            -*)
                log_error "Opção desconhecida: $1"
                show_help
                exit 1
                ;;
            *)
                if [[ -z "$ssid" ]]; then
                    ssid="$1"
                else
                    log_error "SSID já foi definido. Argumento extra: $1"
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    # Validar SSID obrigatório
    if [[ -z "$ssid" ]]; then
        log_error "SSID é obrigatório"
        echo ""
        show_help
        exit 1
    fi
    
    # Validar dark_login (deve ser true ou false)
    if [[ "$dark_login" != "true" && "$dark_login" != "false" ]]; then
        log_error "dark-login deve ser 'true' ou 'false'"
        exit 1
    fi
    
    # Verificações pré-execução
    log "Realizando verificações..."
    check_docker
    check_image "$image"
    cleanup_container "$container_name"
    create_directories
    
    # Executar WiFi Pumpkin3
    run_wifipumpkin3 "$interface" "$ssid" "$proxy" "$container_name" "$image" "$dark_login"
}

# Tratamento de sinais para limpeza
trap 'log_warning "Script interrompido pelo usuário"; exit 130' INT TERM

# Executar função principal
main "$@"
