; =========================================
;  Diablo IV – Repeater + Overlays (AHK v2)
; =========================================

; ---------- CONFIG ----------
intervalMs := 100
; GARDER les 3 clés pour éviter tout accès manquant
targetWin  := { exe: "Diablo IV.exe", class: "", title: "" }

; Dossier des images
imageDir := A_ScriptDir "\icons" 

; Noms des images
images := Map(
  1, Map("on",  imageDir "\D_IV_Sorc_blizzard_ON.jpg",           "off", imageDir "\D_IV_Sorc_blizzard_OFF.jpg"),
  2, Map("on",  imageDir "\D_IV_Sorc_ball_lightning_ON.jpg",     "off", imageDir "\D_IV_Sorc_ball_lightning_OFF.jpg"),
  3, Map("on",  imageDir "\D_IV_Sorc_unstable_currents_ON.jpg",  "off", imageDir "\D_IV_Sorc_unstable_currents_OFF.jpg"),
  4, Map("on",  imageDir "\D_IV_Sorc_teleport_ON.jpg",           "off", imageDir "\D_IV_Sorc_teleport_OFF.jpg")
)

; Positionnement des overlays
topMarginPx := 20        ; espace avec le haut de l'écran
slotSpacing := 5         ; espace horizontal entre icônes

; Scancodes (fiables en jeu, AZERTY)
sc := Map(1, "sc002"  ; 1 / &
        , 2, "sc003"  ; 2 / é
        , 3, "sc004"  ; 3 / "
        , 4, "sc005") ; 4 / '

; États des slots
running := Map(1,false, 2,false, 3,false, 4,false)

; ---------- ÉTAT OVERLAYS ----------
global GUIs := Map()
global Pics := Map()
global PicW := Map()
global PicH := Map()

; ---------- Timers d’envoi (non bloquants) ----------
SetTimer Slot1Loop, 10
SetTimer Slot2Loop, 10
SetTimer Slot3Loop, 10
SetTimer Slot4Loop, 10

; ---------- Overlays ----------
InitOverlays()      ; crée les 4 overlays et les positionne
UpdateOverlays()    ; charge l’état OFF/ON initial
; cache/affiche les overlays suivant activité du jeu
SetTimer OverlayWatcher, 250

; ---------- Tray / statut ----------
InitTray()

; ---------- HOTKEYS CONTEXTUELS ----------
; Les hotkeys ci-dessous ne sont actifs QUE si IsGameActive() renvoie true
#HotIf IsGameActive()

; Toggles : F1..F4
~F1:: ToggleSlot(1)
~F2:: ToggleSlot(2)
~F3:: ToggleSlot(3)
~F4:: ToggleSlot(4)

; Stop par appui PHYSIQUE (laisse passer au jeu / ignore Send)
~$*sc002:: StopSlot(1)   ; 1 (&)
~$*sc003:: StopSlot(2)   ; 2 (é)
~$*sc004:: StopSlot(3)   ; 3 (")
~$*sc005:: StopSlot(4)   ; 4 (')

; ~Esc = stoppe tout (et passe au jeu)
~Esc:: StopAll()

#HotIf   ; fin du contexte : en dehors du jeu, ces hotkeys n'existent pas


; ========== FONCTIONS ==========
ToggleSlot(slot) {
    global running
    running[slot] := !running[slot]
    UpdateTray()
    UpdateOverlaySlot(slot)
    Tip("Slot " slot ": " (running[slot] ? "ON" : "OFF"))
}

StopSlot(slot) {
    global running
    if running[slot] {
        running[slot] := false
        UpdateTray()
        UpdateOverlaySlot(slot)
        Tip("Slot " slot ": OFF (touche)")
    }
}

StopAll() {
    global running
    running[1] := false, running[2] := false, running[3] := false, running[4] := false
    UpdateTray()
    UpdateOverlays()
    Tip("Tous les slots : OFF")
}

; Envoi sécurisé (uniquement si jeu au premier plan)
SendIfActive(slot) {
    global sc
    if !IsGameActive()
        return
    Send "{" sc[slot] "}"
}

; Détection stricte de la fenêtre : compare les HWND
IsGameActive() {
    global targetWin
    winSpec := ""
    if (targetWin.title != "")
        winSpec .= targetWin.title " "
    if (targetWin.class != "")
        winSpec .= "ahk_class " targetWin.class " "
    if (targetWin.exe != "")
        winSpec .= "ahk_exe " targetWin.exe
    if (winSpec = "")
        return false

    hwndActive := DllCall("GetForegroundWindow", "ptr")
    hwndGame   := WinExist(winSpec)
    return hwndActive = hwndGame
}

; ---------- Overlay : création/position/MAJ ----------
InitOverlays() {
    global GUIs, Pics, PicW, PicH, images, topMarginPx, slotSpacing
    ; créer les 4 GUI (click-through, sans bord, au-dessus de tout)
    Loop 4 {
        slot := A_Index
        ; E0x20 = WS_EX_TRANSPARENT (click-through)
        g := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20 +OwnDialogs")
        ; Charge d'abord l'image OFF (valeur par défaut)
        p := g.AddPicture("vPic" slot " AltSubmit", images[slot]["off"])
        g.Show("Hide AutoSize")                 ; calcule la taille sans afficher
        p.GetPos(,, &w, &h)
        ; si image introuvable => w/h peuvent être 0 → taille par défaut
        if (w=0 || h=0)
            w := 64, h := 64
        PicW[slot] := w, PicH[slot] := h
        GUIs[slot] := g, Pics[slot] := p
    }
    PositionOverlays()
}

PositionOverlays() {
    global GUIs, PicW, PicH, slotSpacing, topMarginPx
    totalW := (PicW[1] + PicW[2] + PicW[3] + PicW[4]) + (3 * slotSpacing)
    startX := Round((A_ScreenWidth - totalW) / 2)
    y := topMarginPx

    x := startX
    Loop 4 {
        slot := A_Index
        GUIs[slot].Show("x" x " y" y " AutoSize NoActivate")
        x += PicW[slot] + slotSpacing
    }
}

UpdateOverlaySlot(slot) {
    global running, images, Pics
    Pics[slot].Value := running[slot] ? images[slot]["on"] : images[slot]["off"]
}

UpdateOverlays() {
    Loop 4
        UpdateOverlaySlot(A_Index)
}

OverlayWatcher() {
    global GUIs
    if IsGameActive() {
        ; montrer les overlays si cachés
        Loop 4
            GUIs[A_Index].Show("NoActivate")
    } else {
        ; cacher quand le jeu n'est pas au premier plan
        Loop 4
            GUIs[A_Index].Hide()
    }
}

; ---------- Utilitaires visuels ----------
Tip(text) {
    ToolTip text
    SetTimer () => ToolTip(), -900   ; auto-hide 0,9 s
}

InitTray() {
    TraySetIcon()
    A_IconTip := "Diablo IV Repeater — OFF"
    Tray := A_TrayMenu
    Tray.Delete()
    Tray.Add("Stop All", (*) => StopAll())
    Tray.Add("Reposition Overlays", (*) => PositionOverlays())
    Tray.Add("Exit", (*) => ExitApp())
}

UpdateTray() {
    global running
    on := []
    for k, v in running
        if v
            on.Push(k)

    if (on.Length) {
        list := ""
        for i, v in on
            list .= (i=1 ? "" : ", ") v
        A_IconTip := "ON → Slots: " list
    } else {
        A_IconTip := "OFF"
    }
}

; ---------- Timers des slots ----------
Slot1Loop() {
    static last := 0
    global running, intervalMs
    if running[1] && (A_TickCount - last >= intervalMs) {
        SendIfActive(1), last := A_TickCount
    }
}
Slot2Loop() {
    static last := 0
    global running, intervalMs
    if running[2] && (A_TickCount - last >= intervalMs) {
        SendIfActive(2), last := A_TickCount
    }
}
Slot3Loop() {
    static last := 0
    global running, intervalMs
    if running[3] && (A_TickCount - last >= intervalMs) {
        SendIfActive(3), last := A_TickCount
    }
}
Slot4Loop() {
    static last := 0
    global running, intervalMs
    if running[4] && (A_TickCount - last >= intervalMs) {
        SendIfActive(4), last := A_TickCount
    }
}
