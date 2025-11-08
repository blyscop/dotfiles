# Dotfiles Arch Linux - Configuration Hyprland

Configuration personnalisée pour Arch Linux avec Hyprland, optimisée pour clavier BÉPO.

## 📋 Contenu

- **Hyprland** : Gestionnaire de fenêtres Wayland avec configurations personnalisées
- **Waybar** : Barre de statut personnalisée
- **Kitty** : Émulateur de terminal
- **Rofi** : Lanceur d'applications
- **Dunst** : Gestionnaire de notifications
- **Zsh** : Configuration shell avec Powerlevel10k

## 🚀 Installation

### Installation automatique (recommandée)

```bash
# Cloner le dépôt
git clone https://github.com/blyscop/dotfiles.git ~/dotfiles

# Lancer le script d'installation
cd ~/dotfiles
./install.sh
```

Le script d'installation va :
- Créer un backup de vos configurations existantes
- Créer des liens symboliques vers les configurations du dépôt
- Rendre les scripts exécutables
- Vous guider pour appliquer les changements

### Installation manuelle

Si vous préférez installer manuellement :

```bash
# Cloner le dépôt
git clone https://github.com/blyscop/dotfiles.git ~/dotfiles

# Créer des liens symboliques
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.bashrc ~/.bashrc
ln -sf ~/dotfiles/.p10k.zsh ~/.p10k.zsh
ln -sf ~/dotfiles/.bash_profile ~/.bash_profile
ln -sf ~/dotfiles/.gtkrc-2.0 ~/.gtkrc-2.0

# Lier les configurations
ln -sf ~/dotfiles/.config/hypr ~/.config/hypr
ln -sf ~/dotfiles/.config/waybar ~/.config/waybar
ln -sf ~/dotfiles/.config/kitty ~/.config/kitty
ln -sf ~/dotfiles/.config/rofi ~/.config/rofi
ln -sf ~/dotfiles/.config/dunst ~/.config/dunst
```

## 🔄 Mise à jour

Pour mettre à jour vos configurations depuis GitHub :

```bash
cd ~/dotfiles
./update.sh
```

Le script de mise à jour va :
- Sauvegarder vos modifications locales (stash)
- Récupérer les dernières modifications depuis GitHub
- Restaurer vos modifications locales
- Proposer de recharger Hyprland

## ⌨️ Keybindings Hyprland (Clavier BÉPO)

### Gestion des fenêtres et sessions
- `Super + Q` : Fermer la fenêtre active
- `Alt + F4` : Fermer la fenêtre active
- `Super + Delete` : Quitter Hyprland
- `Super + W` : Basculer en mode flottant
- `Super + G` : Basculer le groupement
- `Alt + Return` : Plein écran
- `Super + L` : Verrouiller l'écran
- `Super + Backspace` : Menu de déconnexion
- `Ctrl + Escape` : Activer/Désactiver Waybar

### Applications
- `Super + T` : Terminal (Kitty)
- `Super + E` : Gestionnaire de fichiers (Dolphin)
- `Super + C` : Éditeur de code (VSCode)
- `Super + F` : Navigateur (Firefox)
- `Ctrl + Shift + Escape` : Moniteur système

### Rofi
- `Super + A` : Lanceur d'applications
- `Super + Tab` : Changeur de fenêtres
- `Super + R` : Explorateur de fichiers
- `Super + V` : Presse-papier (cliphist)
- `Super + K` : Changer la disposition du clavier

### Navigation
- `Super + ←/→/↑/↓` : Déplacer le focus
- `Super + 1-9,0` : Changer d'espace de travail
- `Super + Ctrl + ←/→` : Espace de travail relatif
- `Super + Ctrl + ↓` : Premier espace vide

### Redimensionnement
- `Super + Shift + ←/→/↑/↓` : Redimensionner la fenêtre

### Déplacement de fenêtres
- `Super + Shift + 1-9,0` : Déplacer vers espace de travail
- `Super + Shift + Ctrl + ←/→/↑/↓` : Déplacer fenêtre

### Audio et luminosité
- `F10` / `XF86AudioMute` : Muet
- `F11` / `XF86AudioLowerVolume` : Volume -
- `F12` / `XF86AudioRaiseVolume` : Volume +
- `XF86MonBrightnessUp/Down` : Luminosité

### Captures d'écran
- `Super + P` : Capture de zone
- `Super + Ctrl + P` : Capture de zone (écran gelé)
- `Super + Alt + P` : Capture du moniteur
- `Print` : Capture de tous les moniteurs

### Personnalisation
- `Super + Shift + T` : Sélection de thème
- `Super + Shift + W` : Sélection de fond d'écran
- `Super + Shift + D` : Activer/Désactiver Wallbash
- `Super + Alt + →/←` : Fond d'écran suivant/précédent
- `Super + Alt + G` : Mode jeu (désactiver les effets)

### Workspaces spéciaux
- `Super + S` : Afficher/Masquer workspace spécial
- `Super + Alt + S` : Déplacer vers workspace spécial silencieusement
- `Super + J` : Basculer le split (dwindle)

### Souris
- `Super + Scroll` : Changer d'espace de travail
- `Super + Click gauche` : Déplacer fenêtre
- `Super + Click droit` : Redimensionner fenêtre

## 📁 Structure

```
dotfiles/
├── install.sh                     # Script d'installation automatique
├── update.sh                      # Script de mise à jour depuis GitHub
├── README.md                      # Documentation
├── .config/
│   ├── hypr/
│   │   ├── hyprland.conf          # Configuration principale
│   │   ├── keybindings.conf       # Raccourcis clavier
│   │   ├── animations.conf        # Animations
│   │   ├── monitors.conf          # Configuration moniteurs
│   │   ├── windowrules.conf       # Règles des fenêtres
│   │   ├── workspaces.conf        # Espaces de travail
│   │   ├── userprefs.conf         # Préférences utilisateur
│   │   ├── scripts/               # Scripts personnalisés
│   │   └── themes/                # Thèmes
│   ├── waybar/
│   ├── kitty/
│   ├── rofi/
│   └── dunst/
├── .zshrc
├── .bashrc
├── .bash_profile
├── .p10k.zsh
└── .gtkrc-2.0
```

## 🛠️ Dépendances

### Essentielles
- `hyprland` : Gestionnaire de fenêtres
- `waybar` : Barre de statut
- `kitty` : Terminal
- `rofi` : Lanceur d'applications
- `dunst` : Notifications
- `swaylock` : Verrouillage d'écran

### Utilitaires
- `dolphin` : Gestionnaire de fichiers
- `firefox` : Navigateur
- `code` : VSCode
- `playerctl` : Contrôle média
- `cliphist` : Gestionnaire presse-papier
- `swww` : Gestionnaire de fond d'écran

## 💡 Notes

- Configuration optimisée pour clavier **BÉPO**
- Thème et fond d'écran gérés par Wallbash
- Scripts personnalisés dans `.config/hypr/scripts/`
- Utilise Powerlevel10k pour Zsh

## 📝 License

Configuration personnelle - Utilisez et modifiez librement !
