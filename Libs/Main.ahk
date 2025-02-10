
StartUp() {
    if GetRobloxHWND() {
		WinActivate, ahk_exe RobloxPlayerbeta.exe
		WinGetPos, , , Width, Height, ahk_exe RobloxPlayerbeta.exe
		if (Width >= A_ScreenWidth && Height >= A_ScreenHeight) {
			Send {f11}
			Sleep 1000
		}
		WinMove, ahk_exe RobloxPlayerBeta.exe,, 0, 0, 100, 100
		if !WinActive("ahk_exe RobloxPlayerBeta.exe") {
			Msgbox, Failed to activate the Roblox window.
			ExitApp
		}
	} else {
		Msgbox, Roblox must be open to continue.
		ExitApp
	}
}
InGameCheck() {
	; Close Leaderboard
	PixelSearch,,, 559, 100, 559+21, 100+21, 0xffffff , 5, Fast RGB
	If (ErrorLevel = 0) {
		Send {Tab}
		Return True
	}
}
SafeNum(Var) {
	return Var ? Var : 0
}
BetterClick(x, y) {
	MouseMove, x, y
	MouseMove, 1, 0 ,, R
	MouseClick , Left, -1, 0,,,, R
	Sleep, 50
}

GetRobloxHWND() {
	if (hwnd := WinExist("Roblox ahk_exe RobloxPlayerBeta.exe"))
		return hwnd
}

AutoEat() {
	Send {sc029}
	Sleep 188
	SlotColor := {"0x473717": 0} 
	For ColorID, Variation in SlotColor {
		PixelSearch, xSlotPos,, 65, 525, 65+686, 525+62, ColorID , Variation, FastRGB
		If (ErrorLevel = 0) {
			SlotPos := {74:"sc2", 143:"sc3", 214:"sc4", 277:"sc5", 352:"sc6", 416:"sc7", 491:"sc8", 560:"sc9", 629:"scA", 693:"scB"}
			For PixelTarget, Slot in SlotPos {
                If (Abs(xSlotPos - PixelTarget) <= 10) {
                    Send, {%Slot%}
					Sleep 188
                    Break
                } 
            }
		}
	}
	IniRead, FoodSlot, % A_ScriptDir "/../MO_Config.ini" , %ENV_MACRO% , FoodSlot
	If (FoodSlot = "ERROR") {
		FoodSlot := "sc2,sc3,sc4,sc5,sc6,sc7,sc8,sc9,scA,scB"
		IniWrite, %FoodSlot%, % A_ScriptDir "/../MO_Config.ini" , %ENV_MACRO% , FoodSlot
	}
	xSlotPos := False
	HoldingColor := 
	Loop, Parse, FoodSlot, `, 
	{
		For Index, Key in BlacklistKey {
			If (Key = A_LoopField) {
				Continue
			}
		}
		CurrentKey := A_LoopField
		Send {%A_LoopField%}
		Sleep 188
		For ColorID, Variation in SlotColor {
			PixelSearch, xSlotPos,, 65, 525, 65+686, 525+62, ColorID , Variation, FastRGB
			If (ErrorLevel = 0) {
				Break 2
			}
		}
	}
	If (!xSlotPos) {
		FoodDrag := False
		Loop, Parse, FoodSlot, `, 
		{
			For Index, Key in BlacklistKey {
				If (Key = A_LoopField) {
					Continue
				}
			}
			For Index, Bitmap in FoodNumber {
				; ImageSearch
				If (Bitmap) {
					Click, %FoodPotionX% %PositionY% Down
					Sleep 100
					For xTarget, Key in SlotPos {
						If (xTarget = A_LoopField) {
							Click, %xTarget% 580 Up
							FoodDrag := True
						}
					}
				}
			}
		}
		If (!FoodDrag) {
			; All Food is gone
		}
		Send {sc029}
		Return True
	}
	StartEatingTime := A_TickCount
	PixelSearch, OldHungerPos,, 17, 166, 17+126, 166, 0x444444, 5, FastRGB
	IniRead, MaxEatTimer, % A_ScriptDir "/../MO_Config.ini" , Eating, MaxEatTimer, 30000
	Loop, {
		Click, 15, 265
		Sleep 100
		PixelSearch, CurrentBar,, 17, 166, 17+126, 166, 0x444444, 5, FastRGB
		If (ErrorLevel = 0) {
			IniRead, TargetStop, % A_ScriptDir "/../MO_Config.ini" , Eating, StopEatingAt, 80
			CurrentBar := ((CurrentBar - 17) / 126) * 100
			If (CurrentBar >= SafeNum(TargetStop)) {
				Msgbox Finished Eating
				Break
			}
		}
		For ColorID, Variation in SlotColor {
			PixelSearch, xSlotPos,, 65, 525, 65+686, 525+62, ColorID , Variation, FastRGB
			If (ErrorLevel = 1) {
				Msgbox Slotcolor gone
				Break 2
			}
		}
		If (A_TickCount - StartEatingTime >= MaxEatTimer) {
			Msgbox Eat too long
			Break
		}
	}
	If (OldHungerPos = CurrentBar) {
		BlacklistKey.Push(CurrentKey)
	}
	For ColorID, Variation in SlotColor {
		PixelSearch, xSlotPos,, 65, 525, 65+686, 525+62, ColorID , Variation, FastRGB
		If (ErrorLevel = 0) {
			For PixelTarget, Slot in SlotPos {
                If (Abs(xSlotPos - PixelTarget) <= 10) {
                    Send, {%Slot%}
					Sleep 188
                    Break
                } 
            }
		}
	}
	Send {sc029}
	Return True
}

InDanger() {
	Msgbox player in combat 
	Return
}

