#!/bin/bash

# Atualiza o sistema antes de instalar os pacotes
sudo pacman -Syu

# Lista de pacotes a serem instalados pelo Pacman
pacotes=(
    # Hyprland
    "hyprlock"                  # Tela de bloqueio
    "hyprutils"                 # Utilitários

    # Integração e drivers de vídeo
    "xdg-desktop-portal-hyprland" # Integra Hyprland com Flatpak e serviços de desktop.
    "xf86-video-amdgpu"           # Driver para GPUs AMD modernas.
    "xf86-video-ati"              # Driver para GPUs AMD antigas.
    "xf86-video-fbdev"            # Driver genérico para fallback de vídeo. -> responsavel por resolver o erro de tela preta na tela de bloqueio sddm quando tem 2 monitores

    # Ferramentas básicas e utilitários
    "dolphin" # Gerenciador de arquivos
    "kservice" # Lembrar dos apps que abre determinalda extensão no dolphin
    "polkit-kde-agent" # Popup de pedir premissão de super usuario
    "hyprsysteminfo" # Apenas exibe informações do sistema
    "hyprland-qtutils-git" # Para exibir dialogs e popups
    "wl-clip-persist" # Persistir historico de copias
    "zip" "tar"                   # Compactação e extração de arquivos (.zip, .tar).
    "zsh"                         # Shell alternativo avançado.
    "flatpak"                     # Gerenciador de pacotes Flatpak
    "arandr"                      # Configuração gráfica de monitores.
    "htop"                        # Monitor de recursos do sistema.
    "archlinux-xdg-menu"          # Integra o sistema de menus do Arch com os padrões XDG.
    "wireplumber"                 # Gerenciador de áudio.
    "pipewire"                    # Gerenciador de áudio e vídeo de baixa latência.
    "pipewire-alsa"               # Suporte para ALSA via PipeWire.
    "pipewire-pulse"              # Suporte para PulseAudio via PipeWire.
    "qpwgraph" # Controle de saida de audio
    "pavucontrol" # Controle de qual dispositivo de audio ira usar
    "easyeffects" # Controle de ruidos e fitlros de audio
    "polkit-kde-agent"            # Autenticação por interface (modals de autenticação).
    "virtualbox-host-dkms" # para virtualbox
    "virtualbox"
    "fuse" # Para ativar o AppImage

    # Desenvolvimento e compilação
    "make" "git" "base-devel"     # Ferramentas essenciais para desenvolvimento e compilação.
    "npm"
    "docker" "docker-compose"     # Contêinerização e orquestração de aplicativos.
    "dbeaver"

    # Bluetooth e integração de dispositivos
    "bluez" "bluez-utils"         # Pilha e utilitários para Bluetooth.
    "blueman"                     # Interface para configurar Bluetooth.
    "kdeconnect"                  # Integração entre Linux e Android.

    # Codecs de mídia
    "ffmpeg"                      # Biblioteca de codecs multimídia (H.264, AAC, VP9, etc.).
    "gst-libav"                   # Plugin GStreamer com suporte para decodificação de mídia via libav/FFmpeg.
    "gst-plugins-good"            # Conjunto de plugins GStreamer com boa qualidade.
    "gst-plugins-bad"             # Plugins experimentais do GStreamer.
    "gst-plugins-ugly"            # Plugins GStreamer com codecs proprietários, como MP3 e MPEG.

    # Produtividade e multimídia
    "ark"                         # Gerenciador de arquivos compactados.
    "keepassxc"                   # Gerenciador de senhas seguro.
    "kate"                        # Editor de texto avançado.
    "vivaldi"                     # Navegador web personalizável.
    "vlc"                         # Reprodutor multimídia versátil.

    # Work
    "openvpn"                     # Cliente VPN para conexões seguras.

    # Customização
    "qt6ct" # para configurar no hyprland
    "kvantum" # Interface para aplicar tema e custommizar
)

# Lista de Flatpaks a serem instalados
flatpaks=(
    "com.rtosta.zapzap"         #
    "org.flameshot.Flameshot" # Prints
)

snaps=(
    "code --classic"             # Editor de código Visual Studio Code
    "postman"                    # Ferramenta para APIs
)


# yay @todo
# "hyprsome" # Usado para configurar o Hyprland para ter 10 workspace por monitor, cada monitor vai ter suas 10 workspaces

###
### PACMAN ###
###
# Função para verificar se um pacote está instalado (Pacman)
pacote_instalado() {
    pacote="$1"
    if pacman -Q "$pacote" &>/dev/null; then
        return 0  # Pacote está instalado
    else
        return 1  # Pacote não está instalado
    fi
}

# Função para instalar pacotes via Pacman
instalar_pacote() {
    pacote="$1"
    if pacote_instalado "$pacote"; then
        echo "$pacote já está instalado. Pulando instalação."
    else
        echo "Instalando $pacote..."
        for tentativa in {1..3}; do
            sudo pacman -S --noconfirm "$pacote"
            if [ $? -eq 0 ]; then
                echo "$pacote instalado com sucesso!"
                break
            else
                echo "Erro ao instalar $pacote. Tentativa $tentativa falhou. Tentando novamente em 5 segundos..."
                sleep 5
            fi
        done
        if [ $? -ne 0 ]; then
            echo "Falha permanente ao instalar $pacote. Continuando com os demais."
        fi
    fi
}

# Loop para instalar pacotes do Pacman
for pacote in "${pacotes[@]}"; do
    instalar_pacote "$pacote"
done

###
### FLATPAK ###
###
# Função para verificar se um Flatpak está instalado
flatpak_instalado() {
    flatpak="$1"
    if flatpak list | grep -q "$flatpak"; then
        return 0  # Flatpak está instalado
    else
        return 1  # Flatpak não está instalado
    fi
}

# Instalar Flatpaks
for flatpak in "${flatpaks[@]}"; do
    if flatpak_instalado "$flatpak"; then
        echo "Flatpak $flatpak já está instalado. Pulando instalação."
    else
        echo "Instalando Flatpak $flatpak..."
        flatpak install -y flathub "$flatpak"
    fi
done

# Ativa o Snap
ativar_snap() {
    echo "Ativando Snap..."
    git clone https://aur.archlinux.org/snapd.git
    cd snapd
    makepkg -si
    sudo systemctl enable --now snapd.socket
    sudo ln -s /var/lib/snapd/snap /snap
}


###
### SNAP ###
###
# Ativa o Snap
if ! command -v snap &>/dev/null; then
    ativar_snap
fi

# Instalar Snaps
for snap in "${snaps[@]}"; do
    if snap list | grep -q "$(echo "$snap" | awk '{print $1}')"; then
        echo "Snap $snap já está instalado. Pulando instalação."
    else
        echo "Instalando Snap $snap..."
        sudo snap install $snap
    fi
done

echo "Instalação concluída!"
