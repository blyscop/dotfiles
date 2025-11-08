#!/bin/bash

# Script de restauration des dotfiles depuis un backup
# Restaure les configurations sauvegardées par backup.sh

set -e

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Restauration des Dotfiles${NC}"
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

print_restore() {
    echo -e "${CYAN}←${NC} Restauration: $1"
}

# Vérifier si un répertoire de backup a été fourni
if [ -z "$1" ]; then
    print_info "Recherche des backups disponibles..."
    echo ""

    BACKUP_BASE_DIR="$HOME/.dotfiles_backups"

    if [ ! -d "$BACKUP_BASE_DIR" ]; then
        print_error "Aucun backup trouvé dans $BACKUP_BASE_DIR"
        echo ""
        echo "Usage: $0 <répertoire_de_backup>"
        exit 1
    fi

    # Lister les backups disponibles
    BACKUPS=($(ls -dt "$BACKUP_BASE_DIR"/backup_* 2>/dev/null))

    if [ ${#BACKUPS[@]} -eq 0 ]; then
        print_error "Aucun backup trouvé"
        exit 1
    fi

    echo -e "${CYAN}Backups disponibles:${NC}"
    echo ""

    for i in "${!BACKUPS[@]}"; do
        BACKUP_NAME=$(basename "${BACKUPS[$i]}")
        BACKUP_DATE=$(echo "$BACKUP_NAME" | sed 's/backup_//' | sed 's/_/ /')
        BACKUP_SIZE=$(du -sh "${BACKUPS[$i]}" | cut -f1)
        echo "  [$i] $BACKUP_DATE (Taille: $BACKUP_SIZE)"

        # Afficher les infos si disponibles
        if [ -f "${BACKUPS[$i]}/backup_info.txt" ]; then
            BACKUP_INFO=$(grep "Backup créé le:" "${BACKUPS[$i]}/backup_info.txt" | cut -d: -f2-)
            echo "      Info:$BACKUP_INFO"
        fi
        echo ""
    done

    read -p "Sélectionnez le numéro du backup à restaurer (ou 'q' pour quitter): " SELECTION

    if [ "$SELECTION" = "q" ] || [ "$SELECTION" = "Q" ]; then
        print_info "Restauration annulée"
        exit 0
    fi

    if ! [[ "$SELECTION" =~ ^[0-9]+$ ]] || [ "$SELECTION" -ge "${#BACKUPS[@]}" ]; then
        print_error "Sélection invalide"
        exit 1
    fi

    BACKUP_DIR="${BACKUPS[$SELECTION]}"
else
    BACKUP_DIR="$1"
fi

# Vérifier que le répertoire de backup existe
if [ ! -d "$BACKUP_DIR" ]; then
    print_error "Le répertoire de backup n'existe pas: $BACKUP_DIR"
    exit 1
fi

echo ""
echo -e "${CYAN}Répertoire de backup:${NC} $BACKUP_DIR"
echo ""

# Afficher les informations du backup si disponibles
if [ -f "$BACKUP_DIR/backup_info.txt" ]; then
    print_info "Informations du backup:"
    cat "$BACKUP_DIR/backup_info.txt" | head -5
    echo ""
fi

echo -e "${YELLOW}ATTENTION: Cette restauration va écraser vos configurations actuelles !${NC}"
echo ""

read -p "Voulez-vous créer un backup de vos configurations actuelles avant la restauration ? (O/n) " -n 1 -r
echo
CREATE_BACKUP=true
if [[ $REPLY =~ ^[Nn]$ ]]; then
    CREATE_BACKUP=false
fi

if [ "$CREATE_BACKUP" = true ]; then
    print_info "Création d'un backup de sécurité..."
    SAFETY_BACKUP="$HOME/.dotfiles_backups/safety_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$SAFETY_BACKUP"

    # Backup rapide des configs actuelles
    [ -d "$HOME/.config/hypr" ] && cp -r "$HOME/.config/hypr" "$SAFETY_BACKUP/"
    [ -d "$HOME/.config/waybar" ] && cp -r "$HOME/.config/waybar" "$SAFETY_BACKUP/"
    [ -d "$HOME/.config/kitty" ] && cp -r "$HOME/.config/kitty" "$SAFETY_BACKUP/"
    [ -d "$HOME/.config/rofi" ] && cp -r "$HOME/.config/rofi" "$SAFETY_BACKUP/"
    [ -d "$HOME/.config/dunst" ] && cp -r "$HOME/.config/dunst" "$SAFETY_BACKUP/"

    print_success "Backup de sécurité créé: $SAFETY_BACKUP"
fi

echo ""
read -p "Continuer avec la restauration ? (o/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[OoYy]$ ]]; then
    print_error "Restauration annulée"
    exit 1
fi

echo ""
print_info "Restauration en cours..."
echo ""

# Fonction pour restaurer un élément
restore_item() {
    local source_name=$1
    local target_path=$2

    if [ -e "$BACKUP_DIR/$source_name" ] || [ -L "$BACKUP_DIR/$source_name" ]; then
        print_restore "$source_name"

        # Supprimer la cible existante
        rm -rf "$target_path" 2>/dev/null || true

        # Créer le répertoire parent si nécessaire
        mkdir -p "$(dirname "$target_path")"

        # Copier depuis le backup
        cp -r "$BACKUP_DIR/$source_name" "$target_path"
        print_success "$source_name restauré"
    else
        print_warning "$source_name non trouvé dans le backup, ignoré"
    fi
}

# Restauration des configurations
print_info "Restauration de Hyprland..."
restore_item "hypr" "$HOME/.config/hypr"

print_info "Restauration de Waybar..."
restore_item "waybar" "$HOME/.config/waybar"

print_info "Restauration des terminaux..."
restore_item "kitty" "$HOME/.config/kitty"
restore_item "alacritty" "$HOME/.config/alacritty"

print_info "Restauration des lanceurs..."
restore_item "rofi" "$HOME/.config/rofi"
restore_item "wofi" "$HOME/.config/wofi"

print_info "Restauration des notifications..."
restore_item "dunst" "$HOME/.config/dunst"
restore_item "mako" "$HOME/.config/mako"

print_info "Restauration des dotfiles shell..."
restore_item ".zshrc" "$HOME/.zshrc"
restore_item ".bashrc" "$HOME/.bashrc"
restore_item ".bash_profile" "$HOME/.bash_profile"
restore_item ".p10k.zsh" "$HOME/.p10k.zsh"

print_info "Restauration des configurations GTK/Qt..."
restore_item ".gtkrc-2.0" "$HOME/.gtkrc-2.0"
restore_item "gtk-3.0" "$HOME/.config/gtk-3.0"
restore_item "gtk-4.0" "$HOME/.config/gtk-4.0"
restore_item "qt5ct" "$HOME/.config/qt5ct"
restore_item "qt6ct" "$HOME/.config/qt6ct"
restore_item "Kvantum" "$HOME/.config/Kvantum"

print_info "Restauration de Swaylock/Swayidle..."
restore_item "swaylock" "$HOME/.config/swaylock"
restore_item "swayidle" "$HOME/.config/swayidle"

print_info "Restauration d'autres configurations..."
restore_item "fuzzel" "$HOME/.config/fuzzel"
restore_item "foot" "$HOME/.config/foot"
restore_item "electron-flags.conf" "$HOME/.config/electron-flags.conf"

echo ""
print_info "Restauration des permissions des scripts..."
if [ -d "$HOME/.config/hypr/scripts" ]; then
    chmod +x "$HOME/.config/hypr/scripts/"*.sh 2>/dev/null || true
    chmod +x "$HOME/.config/hypr/scripts/"*.py 2>/dev/null || true
    print_success "Permissions restaurées"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Restauration terminée avec succès !${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

print_info "Pour appliquer les changements:"
echo "  - Rechargez Hyprland: hyprctl reload"
echo "  - Ou redémarrez votre session (Super + Delete)"
echo "  - Pour Zsh: source ~/.zshrc"
echo ""

# Demander si on veut recharger Hyprland
if command -v hyprctl &> /dev/null; then
    read -p "Voulez-vous recharger Hyprland maintenant ? (o/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[OoYy]$ ]]; then
        hyprctl reload
        print_success "Hyprland rechargé"
    fi
fi

echo ""
print_success "Vos configurations BÉPO sont restaurées !"
