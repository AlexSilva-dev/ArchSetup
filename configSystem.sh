#!/bin/bash

# configurações do sistema

sudo modprobe v4l2loopback uvcvideo  # para a camera usb funcionar


# Ativar serviços:
sudo systemctl enable bluetooth.service

sudo systemctl enable NetworkManager

sudo systemctl enable bluetooth.service


# Shell Fish
chsh -s $(which fish) # Define o shell padrão como o fish
curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish # Instalar o oh my fish
omf install bobthefish # Isso instala o tema
