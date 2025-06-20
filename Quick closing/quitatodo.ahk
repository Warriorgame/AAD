; --- Función para forzar que CapsLock esté OFF (desactivado) realmente ---
ForceCapsLockOff() {
    if GetKeyState("CapsLock", "T")  ; Si está activo
    {
        SetCapsLockState, Off
        Sleep, 50
        SetCapsLockState, Off
    }
}

#UseHook
SetCapsLockState, AlwaysOff
#SingleInstance Force

modoActivo := "ninguno"

; --- Función para cerrar programas ---
CloseOnlyPrograms() {
    ; Primero cerrar Chrome de forma ordenada (con Ctrl+W primero)
    CloseChromeGracefully()
    Sleep, 500
    
    ; Luego cerrar otros programas
    Run, taskkill.exe /F /IM GeometryDash.exe, , Hide
    Run, taskkill.exe /F /IM RobloxPlayerBeta.exe, , Hide
    Run, taskkill.exe /F /IM Discord.exe, , Hide
}

; --- Función para cerrar pestaña actual + cerrar ventanas de Chrome ---
CloseChromeGracefully() {
    ; Activar Chrome
    WinActivate, ahk_exe chrome.exe
    Sleep, 300
    
    ; Intentar cerrar la pestaña actual con Ctrl+W
    SendInput, ^w
    Sleep, 800  ; Dar tiempo a que Chrome cierre la pestaña
    
    ; Obtener lista de ventanas de Chrome
    WinGet, id, List, ahk_exe chrome.exe
    
    ; Cerrar cada ventana con PostMessage (cierre limpio, sin usar taskkill /F)
    Loop, %id%
    {
        this_id := id%A_Index%
        
        ; Activar cada ventana antes de cerrarla
        WinActivate, ahk_id %this_id%
        Sleep, 300
        
        ; Enviar mensaje de cierre limpio
        PostMessage, 0x112, 0xF060,,, ahk_id %this_id%
        Sleep, 500  ; Dar tiempo a cada ventana para guardar su estado
    }
}

; --- Función para cerrar programas y cambiar de escritorio ---
CloseAndSwitchDesktops() {
    CloseOnlyPrograms()
    Send, ^#{d}
    Sleep, 500
    Send, ^#{F4}
}

; --- Tecla º para alternar modos ---
SC029::  
    if (modoActivo = "clase") {
        modoActivo := "juego"
        ToolTip, Modo cambiado a JUEGO
    } else if (modoActivo = "juego") {
        modoActivo := "estatico"
        ToolTip, Modo cambiado a ESTATICO
    } else {
        modoActivo := "clase"
        ForceCapsLockOff()
        ToolTip, Modo cambiado a CLASE
    }
    SetTimer, QuitarToolTip, -1500
Return

; --- Quitar ToolTip ---
QuitarToolTip:
    ToolTip
Return

; --- Comportamiento de CapsLock según el modo ---
CapsLock::
    if (modoActivo = "juego") {
        CloseAndSwitchDesktops()
    } else if (modoActivo = "estatico") {
        CloseOnlyPrograms()
        ; NO cambiar de escritorio
    } else if (modoActivo = "clase") {
        SendInput, {CapsLock}  ; comportamiento normal del bloc mayúsculas
    }
Return

; --- Ctrl + Shift + Esc ---
^+Esc::
    if (modoActivo = "juego") {
        CloseOnlyPrograms()
        Sleep, 1000
        Run, taskmgr.exe
    } else if (modoActivo = "estatico") {
        CloseOnlyPrograms()
        Sleep, 1000
        Run, taskmgr.exe
    } else {
        SendInput, ^+{Esc}
    }
Return

; --- Ctrl + Esc ---
^Esc::
    if (modoActivo = "juego") {
        CloseOnlyPrograms()
        Sleep, 500
        Run, taskmgr.exe
    } else if (modoActivo = "estatico") {
        CloseOnlyPrograms()
        Sleep, 500
        Run, taskmgr.exe
    } else {
        SendInput, ^{Esc}
    }
Return

; --- F10 anulado ---
F10::Return

; --- Win + L anulado ---
#l::Return

; --- Win + Tab ---
#Tab::
    if (modoActivo = "juego") {
        CloseOnlyPrograms()
        Sleep, 2000
        SendInput, #{Tab}
    } else if (modoActivo = "estatico") {
        CloseOnlyPrograms()
        Sleep, 2000
        SendInput, #{Tab}
    } else {
        SendInput, #{Tab}
    }
Return

; --- Hotstrings para activar función al escribir "pero" en modo juego ---
:*:pero::
:*:Pero::
:*:PERO::
    if (modoActivo = "juego") {
        CloseAndSwitchDesktops()
    }
Return

; --- Timer para detectar ventanas de confirmación de Chrome y pulsar Enter ---
SetTimer, CloseChromeConfirm, 500

CloseChromeConfirm:
    WinGet, id, List, ahk_class Chrome_WidgetWin_1
    Loop, %id%
    {
        this_id := id%A_Index%
        WinGetTitle, title, ahk_id %this_id%
        if (title ~= "¿Quieres salir?" || title ~= "Confirmar salida" || InStr(title, "Salir"))
        {
            WinActivate, ahk_id %this_id%
            Sleep, 100
            SendInput, {Enter}
        }
    }
Return

:*:fsd::
    CloseOnlyPrograms()
Return
