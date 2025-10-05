# Diablo IV – Multi-Slot Key Repeater (AHK v2)
Petit utilitaire AutoHotkey v2 pour Windows qui :
- répète les touches 1/2/3/4 (scancodes, fiable en jeu) ;
- (dés)active chaque « slot » via F1/F2/F3/F4 ;
- stoppe un slot si tu appuies physiquement sur sa touche (1/2/3/4) ;
- Esc stoppe tous les slots (sans fermer le script) ;
- n’est actif que si la fenêtre Diablo IV est au premier plan ;
- affiche des overlays image ON/OFF centrés en haut de l’écran pour chaque slot.
>⚠️ Note : l’utilisation d’automatisation peut être régie par les CGU des jeux.<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Tu es responsable de l’usage que tu en fais.

## Fonctionnalités :
- Hotkeys contextuels : ne fonctionnent que lorsque Diablo IV.exe est la fenêtre active.
- Répétition par slot : F1→1, F2→2, F3→3, F4→4.
- Stop sur touche physique : si tu presses 1/2/3/4 au clavier, la répétition du slot correspondant s’arrête.
- Stop global : Esc désactive tous les slots.
- Overlays : 4 images ON/OFF positionnées haut-centre, ~1 cm du bord (paramétrable).
- Scancodes AZERTY : 1=sc002, 2=sc003, 3=sc004, 4=sc005 (fiable en jeu).
- Tray icon : infobulle indiquant les slots actifs.

## Prérequis
- Windows 10/11
- AutoHotkey v2 (installé ou portable) [autohotkey.com](autohotkey.com)

## Installation
- Installer AutoHotkey v2.
- Cloner le repo ou télécharger les fichiers.
- Modifier les icones à afficher
- Lancer le script .ahk

## Configuration rapide
Dans le script, ces variables peuvent être adaptées :
- Délai entre les pressions de touches <br/>
```
intervalMs := 100                                ; délai entre pressions (ms)
```
- Nom de la fenêtre du jeu <br/>
```
targetWin  := { exe: "Diablo IV.exe", class: "", title: "" }
```
- Sous-répertoire contenant les icones de sort :<br/>
```
imageDir := A_ScriptDir "\icons"                 ; dossier des images
```
- Espace entre le haut de l'écran et les icones :<br/>
```
topMarginPx := 40                                ; espace avec le haut de l'écran
slotSpacing := 10                                ; espace horizontal entre icônes
```
- Icones des sorts utilisés :<br/>
```
images := Map(
  1, Map("on",  imageDir "\D_IV_Sorc_blizzard_ON.jpg",           "off", imageDir "\D_IV_Sorc_blizzard_OFF.jpg"),
  2, Map("on",  imageDir "\D_IV_Sorc_ball_lightning_ON.jpg",     "off", imageDir "\D_IV_Sorc_ball_lightning_OFF.jpg"),
  3, Map("on",  imageDir "\D_IV_Sorc_unstable_currents_ON.jpg",  "off", imageDir "\D_IV_Sorc_unstable_currents_OFF.jpg"),
  4, Map("on",  imageDir "\D_IV_Sorc_teleport_ON.jpg",           "off", imageDir "\D_IV_Sorc_teleport_OFF.jpg")
)
```

## Utilisation
- F1/F2/F3/F4 : (dés)active la répétition des touches 1/2/3/4.
- 1/2/3/4 (appui physique) : stoppe le slot correspondant.
- Esc : stoppe tous les slots.
- Les hotkeys sont inactifs hors du jeu (aucun message, aucun effet).
- Les overlays s’affichent ON/OFF selon l’état de chaque slot et se cachent si tu quittes la fenêtre du jeu.

## Overlays (images ON/OFF)
- Chaque slot a deux images : ON et OFF.
- Les images sont affichées en haut-centre, avec une marge topMarginPx.
- Tu peux ajuster la taille de tes images (ex. 64–128 px de hauteur).
- Si une image est manquante, une taille par défaut 64×64 est utilisée pour éviter un crash (tu verras un carré).
