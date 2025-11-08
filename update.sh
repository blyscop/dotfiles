#!/bin/bash

# Script de mise à jour des dotfiles depuis GitHub
# Ce script pull les dernières modifications et recharge les configurations

set -e

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Répertoire du script
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Mise à jour des Dotfiles${NC}"
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

cd "$DOTFILES_DIR"

# Vérifier si c'est un dépôt git
if [ ! -d ".git" ]; then
    print_error "Ce répertoire n'est pas un dépôt Git"
    exit 1
fi

print_info "Vérification des modifications locales..."

# Vérifier s'il y a des modifications non commitées
if ! git diff-index --quiet HEAD -- 2>/dev/null; then
    print_warning "Vous avez des modifications locales non commitées"
    read -p "Voulez-vous les stasher avant de pull ? (o/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[OoYy]$ ]]; then
        git stash push -m "Auto-stash avant update $(date +%Y-%m-%d_%H:%M:%S)"
        print_success "Modifications stashées"
        STASHED=true
    else
        print_error "Mise à jour annulée"
        exit 1
    fi
fi

echo ""
print_info "Récupération des dernières modifications depuis GitHub..."

# Pull les dernières modifications
if git pull origin main; then
    print_success "Dotfiles mis à jour avec succès"
else
    print_error "Erreur lors du pull"
    if [ "$STASHED" = true ]; then
        print_info "Restauration du stash..."
        git stash pop
    fi
    exit 1
fi

# Restaurer le stash si nécessaire
if [ "$STASHED" = true ]; then
    echo ""
    print_info "Restauration de vos modifications locales..."
    if git stash pop; then
        print_success "Modifications locales restaurées"
    else
        print_warning "Conflit lors de la restauration. Résolvez les conflits manuellement."
        print_info "Utilisez 'git stash list' pour voir vos stashes"
    fi
fi

echo ""
print_info "Mise à jour des permissions des scripts..."
if [ -d "$DOTFILES_DIR/.config/hypr/scripts" ]; then
    chmod +x "$DOTFILES_DIR/.config/hypr/scripts/"*.sh 2>/dev/null || true
    chmod +x "$DOTFILES_DIR/.config/hypr/scripts/"*.py 2>/dev/null || true
    print_success "Permissions mises à jour"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Mise à jour terminée !${NC}"
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
