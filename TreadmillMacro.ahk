/*
# Mighty Omega Macro  The source code for this macro is open and freely accessible.
# Please ensure to download the Mighty Omega Macro Form only from the official source.
# Avoid downloading from unknown websites or sources to prevent potential security risks.
# If needed, always redownload the macro from the official source to ensure its authenticity and safety.
# discord.gg/mightyomega
*/
global ENV_MACRO
ENV_MACRO := "Treadmill"
#Include, Libs/Bitmaps.ahk
#Include, Libs/Gdip_All.ahk
#Include, Libs/Gdip_ImageSearch.ahk
#Include, Libs/Main.ahk
#SingleInstance, force
#NoEnv
ListLines, Off
setkeydelay, -1
setmousedelay, -1
setbatchlines, -1
SetCapsLockState, Off
CoordMode, Mouse, Screen

Visits := "https://pastebin.com/raw/qveKcD53"
httpReq := ComObjCreate("WinHttp.WinHttpRequest.5.1")
try {
    httpReq.Open("GET", Visits)
    httpReq.Send() 
}
StartUp()
InGameCheck()
Loop, {
    IniRead, TargetFood, % A_ScriptDir "/MO_Config.ini" , Eating, StartEatingAt, 50
    TargetFood := ((SafeNum(TargetFood) / 100) * 126) + 17
    Loop, 2 {
        PixelSearch,,, TargetFood, 166, TargetFood+2, 166, 0x434343, 15, FastRGB
        If (ErrorLevel = 0) {
            Sleep 1000
            BetterClick(408, 355)
            If AutoEat() {
                Click, 408, 300, 10
                Break
            }
        } else {
            Break
        }
        If (A_Index == 2) {
            ; Failed
        }
    }
    PixelSearch,,, 64, 120, 64+8, 120, 0x833434, 5, FastRGB ; In Danger
    If (ErrorLevel = 0) {
        InDanger()
    }
    /*
    NoStaminaColor := {
        "0x3E3E3E": 15,  ; Darker gray variation for 0x444444
        "0x444444": 12,  ; Base dark gray
        "0x4A4A4A": 12,  ; Slightly lighter than 0x444444
        "0x4F4F4F": 12,  ; Mid-gray
        "0x555555": 15,  ; Between 0x4F4F4F and 0x5A5A5A
        "0x5A5A5A": 15,  ; Lighter gray
        "0xA84848": 45,  ; A slight variation of 0xAC5151
        "0xAC5151": 40,  ; Midpoint between gray and red
        "0xD44545": 35,  ; Between 0xAC5151 and 0xFF4949
        "0xFF4949": 30   ; Bright red
    }
    */
    WillContinue := False
    NoStaminaColor := {"0x444444": 15, "0x4F4F4F": 15, "0x5A5A5A": 15, "0xAC5151": 45, "0xFF4949": 35} ; Optimized 100 ms loop
    For Color, Variation in NoStaminaColor {
        PixelSearch,,, 247, 151, 247, 157, Color, Variation, FastRGB ;
        If (ErrorLevel = 0) {
            WillContinue := True
        }
    }
    If (WillContinue) {
        Continue
    }
    IniRead, Training, % A_ScriptDir "/MO_Config.ini" , Treadmill, Training, Stamina
    BetterClick((Training == "RunningSpeed") ? 474 : 342, 321)
    Sleep 500
    IniRead, Level, % A_ScriptDir "/MO_Config.ini" , Treadmill, Level, Auto
    If (Level == "Auto") {
        Loop, 5 {
            PixelSearch,,, 403, 413 - (A_Index * 30), 403+10, (413 - (A_Index * 30)) + 15, 0xFFFFFF , 3, FastRGB
            If (ErrorLevel = 0) {
                BetterClick(408, 413 - (A_Index * 30))
                Break
            }
        }
    } else {
        BetterClick(408, 413 - (SafeNum(Level) * 30))
    }
    HandSearch := A_TickCount
    Loop, {
        PixelSearch,,, 388, 336, 388 + 40, 336 + 40, 0x79ff98 , 5, FastRGB
        If (ErrorLevel = 0) {
            BetterClick(408, 360)
            Break
        }
        If (A_TickCount - HandSearch >= 10000) {
            ; Can't Start Treadmill for some reason
        }
    }
    Sleep, 3000 
    Tread_StartTimer := A_TickCount
    KeyTimer := A_TickCount
    IniRead, TrainingMethod, % A_ScriptDir "/MO_Config.ini" , Treadmill, TrainingMethod, Optimized
    DoOnce := False
    NoStamCheck := False
    Counted := False
    Loop, {
        Switch TrainingMethod {
            case "Optimized": {
                If (!WaitSaveStamina) {
                    If (!Counted) {
                        Counted := True
                        DoOnce := True
                        WaitSaveStaminaCount := A_TickCount
                    }
                } else {
                    NoStamCheck := True
                    If (!DoOnce) { ; Probably do Alert Instead
                        Tooltip, Wait %WaitSaveStaminaCount%ms `nOptimize Treadmill by Cweamya  
                        Sleep, % WaitSaveStaminaCount
                        DoOnce := True
                    }
                }
                StatusLetter := Gdip_BitmapFromScreen(208 "|" 260 "|" 400 "|" 32)
                For Letter, KeyBitmap in TreadmillLetter {
                    If (Gdip_ImageSearch(StatusLetter, KeyBitmap,,,,,, 15,"0x000000") == 1) {
                        Send {%Letter%}
                        Break
                    }
                }
                Gdip_DisposeImage(StatusLetter)
                If (!NoStamCheck) {
                    For Color, Variation in NoStaminaColor {
                        PixelSearch, CurrentBar,, 22, 151, 260, 157, Color, Variation, FastRGB ;
                        If (ErrorLevel = 0) {
                            IniRead, TargetStop, % A_ScriptDir "/MO_Config.ini" , Treadmill, StopRunningAt, 30
			                CurrentBar := ((CurrentBar - 22) / 239) * 100
                            If (CurrentBar <= TargetStop) {
                                WaitSaveStaminaCount := A_TickCount - WaitSaveStaminaCount
                                WaitSaveStamina := True
                                If (WaitSaveStaminaCount <= 30000) {
                                    ; Stam Not good enough switch to Weak
                                    TrainingMethod := "Weak"
                                    IniWrite, Weak, % A_ScriptDir "/MO_Config.ini" , Treadmill, TrainingMethod
                                }
                                WaitStamina := A_TickCount
                                Loop, {
                                    Click, 408, 300
                                } Until (A_TickCount - WaitStamina >= 7000) or (A_TickCount - Tread_StartTimer >= 60000)
                            }
                            
                        }
                    }
                }
                
            }
            case "Weak": {
                StatusLetter := Gdip_BitmapFromScreen(208 "|" 260 "|" 400 "|" 32)
                For Letter, KeyBitmap in TreadmillLetter {
                    If (Gdip_ImageSearch(StatusLetter, KeyBitmap,,,,,, 15,"0x000000") == 1) {
                        Send {%Letter%}
                        Break
                    }
                }
               
                For Color, Variation in NoStaminaColor {
                    PixelSearch, CurrentBar,, 22, 151, 260, 157, Color, Variation, FastRGB
                    If (ErrorLevel = 0) {
                        IniRead, TargetStop, % A_ScriptDir "/MO_Config.ini" , Treadmill, StopRunningAt, 30
                        CurrentBar := ((CurrentBar - 22) / 239) * 100
                        If (CurrentBar <= TargetStop) {
                            Loop, {
                                IniRead, TargetStart, % A_ScriptDir "/MO_Config.ini" , Treadmill, StartRunningAt, 90
                                PixelSearch, CurrentBar,, 22, 151, 260, 157, Color, Variation, FastRGB
                                If (ErrorLevel = 0) {
                                    CurrentBar := ((CurrentBar - 22) / 239) * 100
                                    If (CurrentBar >= TargetStart)  {
                                        Break
                                    }
                                }
                                If (A_TickCount - Tread_StartTimer > 55000) {
                                    Click, 408, 300
                                }
                            }
                        }
                    }
                }
            }
            case "Pro": {
                StatusLetter := Gdip_BitmapFromScreen(208 "|" 260 "|" 400 "|" 32)
                For Letter, KeyBitmap in TreadmillLetter {
                    If (Gdip_ImageSearch(StatusLetter, KeyBitmap,,,,,, 15,"0x000000") == 1) {
                        Send {%Letter%}
                        Break
                    }
                }
            }
        }
        If (A_TickCount - Tread_StartTimer > 55000) {
            Click, 408, 300, 10
        }
    } Until (A_TickCount - Tread_StartTimer >= 60000)
    Loop, {
        Click, 408, 300, 10
    } Until (A_TickCount - Tread_StartTimer >= 65000)
}

$Space::
	Gdip_Shutdown(pToken)
	ExitApp
Return