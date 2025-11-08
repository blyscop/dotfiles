#!/bin/bash

# Script de backup complet avant installation de DankLinux
# Sauvegarde toutes les configurations importantes

set -e

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
BACKUP_BASE_DIR="$HOME/.dotfiles_backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$BACKUP_BASE_DIR/backup_$TIMESTAMP"
ARCHIVE_NAME="dotfiles_backup_$TIMESTAMP.tar.gz"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Backup Complet des Dotfiles${NC}"
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

print_backup() {
    echo -e "${CYAN}→${NC} Backup: $1"
}

# Créer le répertoire de backup
mkdir -p "$BACKUP_DIR"

echo -e "${YELLOW}ATTENTION: Ce script va créer un backup complet de vos configurations${NC}"
echo -e "${YELLOW}avant l'installation de DankLinux ou autre système qui pourrait${NC}"
echo -e "${YELLOW}écraser vos configurations personnalisées.${NC}"
echo ""
echo -e "Répertoire de backup: ${CYAN}$BACKUP_DIR${NC}"
echo ""

read -p "Voulez-vous continuer ? (o/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[OoYy]$ ]]; then
    print_error "Backup annulé"
    exit 1
fi

echo ""
print_info "Création du backup..."
echo ""

# Fonction pour backup un fichier ou dossier
backup_item() {
    local source=$1
    local name=$2

    if [ -e "$source" ] || [ -L "$source" ]; then
        print_backup "$name"
        cp -rL "$source" "$BACKUP_DIR/" 2>/dev/null || cp -r "$source" "$BACKUP_DIR/" 2>/dev/null
        print_success "$name sauvegardé"
    else
        print_warning "$name n'existe pas, ignoré"
    fi
}

# Backup des configurations principales
print_info "Sauvegarde des configurations Hyprland..."
backup_item "$HOME/.config/hypr" "hypr"

print_info "Sauvegarde des configurations Waybar..."
backup_item "$HOME/.config/waybar" "waybar"

print_info "Sauvegarde des configurations terminal..."
backup_item "$HOME/.config/kitty" "kitty"
backup_item "$HOME/.config/alacritty" "alacritty"

print_info "Sauvegarde des lanceurs et menus..."
backup_item "$HOME/.config/rofi" "rofi"
backup_item "$HOME/.config/wofi" "wofi"

print_info "Sauvegarde des notifications..."
backup_item "$HOME/.config/dunst" "dunst"
backup_item "$HOME/.config/mako" "mako"

print_info "Sauvegarde des dotfiles shell..."
backup_item "$HOME/.zshrc" ".zshrc"
backup_item "$HOME/.bashrc" ".bashrc"
backup_item "$HOME/.bash_profile" ".bash_profile"
backup_item "$HOME/.p10k.zsh" ".p10k.zsh"

print_info "Sauvegarde des configurations GTK/Qt..."
backup_item "$HOME/.gtkrc-2.0" ".gtkrc-2.0"
backup_item "$HOME/.config/gtk-3.0" "gtk-3.0"
backup_item "$HOME/.config/gtk-4.0" "gtk-4.0"
backup_item "$HOME/.config/qt5ct" "qt5ct"
backup_item "$HOME/.config/qt6ct" "qt6ct"
backup_item "$HOME/.config/Kvantum" "Kvantum"

print_info "Sauvegarde de Swaylock/Swayidle..."
backup_item "$HOME/.config/swaylock" "swaylock"
backup_item "$HOME/.config/swayidle" "swayidle"

print_info "Sauvegarde d'autres configurations utiles..."
backup_item "$HOME/.config/fuzzel" "fuzzel"
backup_item "$HOME/.config/foot" "foot"
backup_item "$HOME/.config/electron-flags.conf" "electron-flags.conf"

echo ""
print_info "Création d'un fichier d'informations système..."

# Créer un fichier avec les infos du système
cat > "$BACKUP_DIR/backup_info.txt" <<EOF
Backup créé le: $(date)
Hostname: $(hostname)
User: $(whoami)
Kernel: $(uname -r)
Distribution: $(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d '"')

Packages Hyprland installés:
$(pacman -Q | grep -E "(hypr|waybar|rofi|dunst|kitty|swaylock)" || echo "N/A")

Ce backup a été créé avant une installation potentiellement destructive.
Pour restaurer, utilisez le script restore.sh fourni avec ce backup.
EOF

print_success "Fichier d'informations créé"

echo ""
print_info "Création de l'archive compressée..."

# Créer une archive compressée
cd "$BACKUP_BASE_DIR"
tar -czf "$ARCHIVE_NAME" "backup_$TIMESTAMP"

if [ $? -eq 0 ]; then
    print_success "Archive créée: $ARCHIVE_NAME"

    # Calculer la taille
    ARCHIVE_SIZE=$(du -h "$BACKUP_BASE_DIR/$ARCHIVE_NAME" | cut -f1)
    BACKUP_SIZE=$(du -sh "$BACKUP_DIR" | cut -f1)

    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  Backup terminé avec succès !${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "${CYAN}Répertoire de backup:${NC}"
    echo -e "  $BACKUP_DIR"
    echo -e "  Taille: $BACKUP_SIZE"
    echo ""
    echo -e "${CYAN}Archive compressée:${NC}"
    echo -e "  $BACKUP_BASE_DIR/$ARCHIVE_NAME"
    echo -e "  Taille: $ARCHIVE_SIZE"
    echo ""

    print_info "Pour restaurer vos configurations:"
    echo -e "  cd ~/dotfiles"
    echo -e "  ./restore.sh $BACKUP_DIR"
    echo ""

    print_warning "Gardez ce backup en lieu sûr avant d'installer DankLinux !"
    echo ""

    # Créer un script de restauration rapide dans le backup
    cat > "$BACKUP_DIR/restore_quick.sh" <<'RESTORE_EOF'
#!/bin/bash
# Script de restauration rapide
BACKUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Restauration depuis: $BACKUP_DIR"
echo ""
read -p "Êtes-vous sûr de vouloir restaurer ces configurations ? (o/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[OoYy]$ ]]; then
    cp -r "$BACKUP_DIR/hypr" "$HOME/.config/" 2>/dev/null && echo "✓ Hyprland restauré"
    cp -r "$BACKUP_DIR/waybar" "$HOME/.config/" 2>/dev/null && echo "✓ Waybar restauré"
    cp -r "$BACKUP_DIR/kitty" "$HOME/.config/" 2>/dev/null && echo "✓ Kitty restauré"
    cp -r "$BACKUP_DIR/rofi" "$HOME/.config/" 2>/dev/null && echo "✓ Rofi restauré"
    cp -r "$BACKUP_DIR/dunst" "$HOME/.config/" 2>/dev/null && echo "✓ Dunst restauré"
    cp "$BACKUP_DIR/.zshrc" "$HOME/" 2>/dev/null && echo "✓ .zshrc restauré"
    cp "$BACKUP_DIR/.bashrc" "$HOME/" 2>/dev/null && echo "✓ .bashrc restauré"
    cp "$BACKUP_DIR/.p10k.zsh" "$HOME/" 2>/dev/null && echo "✓ .p10k.zsh restauré"
    echo ""
    echo "✓ Restauration terminée ! Rechargez Hyprland avec: hyprctl reload"
else
    echo "Restauration annulée"
fi
RESTORE_EOF

    chmod +x "$BACKUP_DIR/restore_quick.sh"
    print_success "Script de restauration rapide créé dans le backup"

else
    print_error "Erreur lors de la création de l'archive"
    exit 1
fi
