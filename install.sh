#!/bin/bash

# Script d'installation des dotfiles
# Ce script crée des liens symboliques vers les configurations

set -e

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Répertoire du script
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Installation des Dotfiles${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Fonction pour afficher les messages
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Fonction pour créer un backup
backup_if_exists() {
    local file=$1
    if [ -e "$file" ] || [ -L "$file" ]; then
        mkdir -p "$BACKUP_DIR"
        mv "$file" "$BACKUP_DIR/"
        print_warning "Backup de $(basename "$file") vers $BACKUP_DIR"
    fi
}

# Fonction pour créer un lien symbolique
create_symlink() {
    local source=$1
    local target=$2

    # Créer le répertoire parent si nécessaire
    mkdir -p "$(dirname "$target")"

    # Backup si le fichier existe
    backup_if_exists "$target"

    # Créer le lien symbolique
    ln -sf "$source" "$target"
    print_success "Lien créé: $(basename "$target")"
}

echo -e "${BLUE}Répertoire des dotfiles:${NC} $DOTFILES_DIR"
echo ""

# Demander confirmation
read -p "Voulez-vous continuer avec l'installation ? (o/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[OoYy]$ ]]; then
    print_error "Installation annulée"
    exit 1
fi

echo ""
print_info "Création des liens symboliques..."
echo ""

# Liens symboliques pour les fichiers à la racine
print_info "Configuration des dotfiles racine..."
create_symlink "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
create_symlink "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
create_symlink "$DOTFILES_DIR/.bash_profile" "$HOME/.bash_profile"
create_symlink "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh"
create_symlink "$DOTFILES_DIR/.gtkrc-2.0" "$HOME/.gtkrc-2.0"

echo ""
print_info "Configuration Hyprland..."
create_symlink "$DOTFILES_DIR/.config/hypr" "$HOME/.config/hypr"

echo ""
print_info "Configuration Waybar..."
create_symlink "$DOTFILES_DIR/.config/waybar" "$HOME/.config/waybar"

echo ""
print_info "Configuration Kitty..."
create_symlink "$DOTFILES_DIR/.config/kitty" "$HOME/.config/kitty"

echo ""
print_info "Configuration Rofi..."
create_symlink "$DOTFILES_DIR/.config/rofi" "$HOME/.config/rofi"

echo ""
print_info "Configuration Dunst..."
create_symlink "$DOTFILES_DIR/.config/dunst" "$HOME/.config/dunst"

echo ""
print_info "Rendre les scripts Hyprland exécutables..."
if [ -d "$DOTFILES_DIR/.config/hypr/scripts" ]; then
    chmod +x "$DOTFILES_DIR/.config/hypr/scripts/"*.sh 2>/dev/null || true
    chmod +x "$DOTFILES_DIR/.config/hypr/scripts/"*.py 2>/dev/null || true
    print_success "Scripts rendus exécutables"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Installation terminée avec succès !${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

if [ -d "$BACKUP_DIR" ]; then
    print_info "Les anciennes configurations ont été sauvegardées dans:"
    echo -e "  ${YELLOW}$BACKUP_DIR${NC}"
    echo ""
fi

print_info "Pour appliquer les changements:"
echo "  - Redémarrez votre session Hyprland (Super + Delete puis reconnectez-vous)"
echo "  - Ou rechargez Hyprland: hyprctl reload"
echo "  - Pour Zsh: source ~/.zshrc"
echo ""

print_info "Dépendances recommandées:"
echo "  hyprland waybar kitty rofi dunst swaylock"
echo "  dolphin firefox code playerctl cliphist swww"
echo ""
