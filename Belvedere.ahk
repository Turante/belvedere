;
; AutoHotkey Version: 1.x
; Language:       English
; Platform:       Windows
; Author:         Adam Pash <adam.pash@gmail.com>
;
; Script Function:
;	Automated file manager
;

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance force
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
StringCaseSense, On
SetFormat, float, 0.2
GoSub, SetVars
GoSub, TRAYMENU
GoSub, MENUBAR
Gosub, BuildINI
IniRead, Folders, rules.ini, Folders, Folders
IniRead, FolderNames, rules.ini, Folders, FolderNames
IniRead, AllRuleNames, rules.ini, Rules, AllRuleNames
IniRead, SleepTime, rules.ini, Preferences, SleepTime
IniRead, Traytip, rules.ini, Preferences, Traytip
IniRead, Loghistory, rules.ini, Preferences, Loghistory
if (AllRuleNames = "ERROR")
{
	AllRuleNames=
}

;main execution loop
Loop
{
	;msgbox, running
	;Loops through all the rule names for execution
	Loop, Parse, AllRuleNames, |
	{
		thisRule = %A_LoopField%
		;msgbox, %thisrule%
		NumOfRules := 1
		;Loops to determine number of subjects within a rule
		Loop
		{
			IniRead, MultiRule, rules.ini, %thisRule%, Subject%A_Index%
			if (MultiRule != "ERROR")
			{
				NumOfRules++ 
			}
			else
			{
				break
			}
		}
		if (thisRule = "ERROR") or (thisRule = "")
		{
			continue
		}
		;msgbox, %thisRule% has %Numofrules% rules
		IniRead, Folder, rules.ini, %thisRule%, Folder
		IniRead, Enabled, rules.ini, %thisRule%, Enabled
		IniRead, ConfirmAction, rules.ini, %thisRule%, ConfirmAction, 0
		IniRead, Recursive, rules.ini, %thisRule%, Recursive, 0
		IniRead, Mirror, rules.ini, %thisRule%, Mirror, 0
		IniRead, OneTime, rules.ini, %thisRule%, OneTime, 0
		IniRead, Action, rules.ini, %thisRule%, Action
		IniRead, Destination, rules.ini, %thisRule%, Destination, 0
		IniRead, Matches, rules.ini, %thisRule%, Matches
		
		;If rule is not enabled, just skip over it
		if (Enabled = 0)
		{
			continue
		}
		;MsgBox, %thisRule% is currently running
		;Loop to read the subjects, verbs and objects for the list defined
		Loop
		{
			if ((A_Index-1) = NumOfRules)
			{
				break
			}
			if (A_Index = 1)
			{
				RuleNum =
			}
			else
			{
				RuleNum := A_Index - 1
			}
			IniRead, Subject%RuleNum%, rules.ini, %thisRule%, Subject%RuleNum%
			IniRead, Verb%RuleNum%, rules.ini, %thisRule%, Verb%RuleNum%
			IniRead, Object%RuleNum%, rules.ini, %thisRule%, Object%RuleNum%
		}
		;msgbox, %subject%, %subject1%, %subject2%
		if (Destination != "0")
		{
			IniRead, Overwrite, rules.ini, %thisRule%, Overwrite
		}
		
		;Msgbox, %Subject% %Verb% %Object% %Action% %ConfirmAction% %Recursive%

		;Loop through all of the folder contents
		Loop %Folder%, 0, %Recursive%
		{
			Loop
			{
				if ((A_Index - 1) >= NumOfRules)
				{
					break
				}
				if (A_Index = 1)
				{
					RuleNum =
				}
				else
				{
					RuleNum := A_Index - 1
				}
				;msgbox, % subject subject1 subject2
				file = %A_LoopFileLongPath%
				;MsgBox, %file%
				fileName = %A_LoopFileName%
				;Subject1 = Fart
				;msgbox, % subject%rulenum%
				; Below determines the subject of the comparison
				if (Subject%RuleNum% = "Name")
				{
					thisSubject := getName(file)
					;msgbox, %thisSubject%
				}
				else if (Subject%RuleNum% = "Extension")
				{
					thisSubject := getExtension(file)
					;Msgbox, extension: %thissubject%
				}
				else if (Subject%RuleNum% = "Size")
				{
					thisSubject := getSize(file)
					;msgbox, size %thissubject%
				}
				else if (Subject%RuleNum% = "Date last modified")
				{
					thisSubject := getDateLastModified(file)
				}
				else if (Subject%RuleNum% = "Date last opened")
				{
					thisSubject := getDateLastOpened(file)
				}
				else if (Subject%RuleNum% = "Date created")
				{
					thisSubject := getDateCreated(file)
				}
				else
				{
					MsgBox, Subject does not have a match
					;msgbox, % subject %rulenum%
				}
				
				; Below determines the comparison verb
				if (Verb%RuleNum% = "contains")
				{
					result%RuleNum% := contains(thisSubject, Object%RuleNum%)
				}
				else if (Verb%RuleNum% = "does not contain")
				{
					result%RuleNum% := !(contains(thisSubject, Object%RuleNum%))
				}
				else if (Verb%RuleNum% = "is")
				{
					result%RuleNum% := isEqual(thisSubject, Object%RuleNum%)
					;msgbox, % result%rulenum% . "is rule" . rulenum
					;if result%RuleNum%
					{
						;msgbox, true for %thissubject% and %object%
					}
				}
				else if (Verb%RuleNum% = "matches one of")
				{
					result%RuleNum% := isOneOf(thisSubject, Object%RuleNum%)
					;msgbox, % result%rulenum% . "is rule" . rulenum
				}
				else if (Verb%RuleNum% = "does not match one of")
				{
					result%RuleNum% := !(isOneOf(thisSubject, Object%RuleNum%))
					;msgbox, % result%rulenum% . "is rule" . rulenum
				}
				else if (Verb%RuleNum% = "is less than")
				{
					result%RuleNum% := isLessThan(thisSubject, Object%RuleNum%)
					;msgbox, % result%rulenum%
				}
				else if (Verb%RuleNum% = "is greater than")
				{
					result%RuleNum% := isGreaterThan(thisSubject, Object%RuleNum%)
				}
				else if (Verb%RuleNum% = "is not")
				{
					result%RuleNum% := !(isEqual(thisSubject, Object%RuleNum%))
				}
				else if (Verb%RuleNum% = "is in the last")
				{
					result%RuleNum% := isInTheLast(thisSubject, Object%RuleNum%)
				}
				else if (Verb%RuleNum% = "is not in the last")
				{
					result%RuleNum% := !isInTheLast(thisSubject, Object%RuleNum%)
					;msgbox, % result%RuleNum%
				}
			}
			; Below evaluates result and takes action
			Loop
			{
				;msgbox, %a_index%
				if (NumOfRules < A_Index)
				{
					;msgbox, over
					break
				}
				if (A_Index = 1)
				{
					RuleNum=
				}
				else
				{
					RuleNum := A_Index - 1
				}
				;msgbox, % result%rulenum% . "is rule " . rulenum
				if (Matches = "ALL")
				{
					if (result%RuleNum% = 0)
					{
						result := 0
						break
					}
					else
					{
						result := 1
						continue
					}
				}
				else if (Matches = "ANY")
				{
					if (result%RuleNum% = 1)
					{
						result := 1
						;msgbox, 1
						break
					}
					else
					{
						result := 0
						continue
					}
				}
			}
			;Msgbox, result is %result%
			if result
			{
				MirrorDestination :=
				if (ConfirmAction = 1)
				{
					MsgBox, 4, Action Confirmation, Are you sure you want to %Action% %fileName% because of rule %thisRule%?
					IfMsgBox No
						break
				}
				if (Action = "Move file") or (Action = "Rename file")
				{
					StringLen, out1, A_LoopFileDir
					StringLen, out2, Folder
					out2-=1
					count := out1-out2
					if (count>0)
					{
						StringRight, out3, A_LoopFileDir, count
						MirrorDestination = %Destination%\%out3%
					}
					if (Mirror == 1)
						mirrormove(file, MirrorDestination, Overwrite, Traytip)
					else
						move(file, Destination, Overwrite, Traytip)
					if (errorCheck == 1)
					{
						errorCheck := 0
						break
					}
					if ((errorCheck == -1) && (Loghistory == 1))
					{
						if (Mirror = 1)
							log(file, MirrorDestination, "Move/Rename", logfile)
						else
							log(file, destination, "Move/Rename", logfile)
					}
				}
				else if (Action = "Send file to Recycle Bin")
				{
					if (Traytip == 1)
						TrayTip, %APPNAME% - Recycling..., %fileName%, 1, 1
					recycle(file)
					if ((errorCheck == -1) && (Loghistory == 1))
					{
						log(file, destination, "Recycle", logfile)
					}
				}
				else if (Action = "Delete file")
				{
					if (Traytip == 1)
						TrayTip, %APPNAME% - Deleting..., %fileName%, 1, 1
					;msgbox, delete it!
					delete(file)
					if ((errorCheck == -1) && (Loghistory == 1))
					{
						log(file, destination, "Delete", logfile)
					}
				}
				else if (Action = "Copy file")
				{
					StringLen, out1, A_LoopFileDir
					StringLen, out2, Folder
					out2-=1
					count := out1-out2
					if (count>0)
					{
						StringRight, out3, A_LoopFileDir, count
						MirrorDestination = %Destination%\%out3%
					}
					if (Mirror == 1)
						mirrorcopy(file, MirrorDestination, Overwrite, Traytip)
					else
						copy(file, Destination, Overwrite, Traytip)
					if (errorCheck == 1)
					{
						errorCheck := 0
						break
					}
					if ((errorCheck == -1) && (Loghistory == 1))
					{
						log(file, destination, "Copy File", logfile)
					}
				}
				else if (Action = "Open file")
				{
					if (Traytip == 1)
						TrayTip, %APPNAME% - Opening..., %fileName%, 1, 1
					Run, %file%
					if ((errorCheck == -1) && (Loghistory == 1))
					{
						log(file, destination, "Open File", logfile)
					}
				}
				else if (Action = "Zip file")
				{
					; https://github.com/mshorts/belvedere/issues/68
					if (Traytip == 1)
						TrayTip, %APPNAME% - Zipping..., %fileName%, 1, 1
					FilesToZip := file
					StringRight, output, Destination, 1
					if (output != "\")
						ZipFile =  %Destination%\%A_YYYY%-%A_MM%-%A_DD%.zip
					else
						ZipFile =  %Destination%%A_YYYY%-%A_MM%-%A_DD%.zip
					/*
					if (Mirror == 1)
					{
						StringLen, out1, A_LoopFileDir
						StringLen, out2, Folder
						out2-=1
						count := out1-out2
						if (count>0)
						{
							StringRight, out3, A_LoopFileDir, count
							MirrorDestination = %Destination%\%out3%
						}
					}
					*/
					RunWait,"%7z%" u "%ZipFile%" "%FilesToZip%" -mx9,, Hide UseErrorLevel
					if (ErrorLevel == 0)
						errorCheck := -1
					if ((errorCheck == -1) && (Loghistory == 1))
					{
						log(file, ZipFile, "Zip File", logfile)
					}
				}
				else
				{
					if (Traytip == 1)
						TrayTip, %APPNAME%, No action to take..., 1, 1
				}
				Sleep 50
			}
			else
			{
				;msgbox, no match
			}	
			StringCaseSense, On
		}
		if (OneTime == 1 && errorCheck == -1)
		{
			IniWrite, 0, rules.ini, %thisRule%, Enabled
			if (Traytip == 1)
				TrayTip, %APPNAME%, Disabling rules '%thisRule%'..., 1, 1
			if (Loghistory == 1)
			{
				StringTrimRight, output, Folder, 1
				log(thisRule, output, "Rule Off", logfile)
			}
		}
		errorCheck :=
	}
	;msgbox, run
	Sleep, %SleepTime%
}


SetVars:
	APPNAME = Belvedere
	Version = 0.4.8
	AllSubjects = Name||Extension|Size|Date last modified|Date last opened|Date created|
	NoDefaultSubject = Name|Extension|Size|Date last modified|Date last opened|Date created|
	NameVerbs = is||is not|matches one of|does not match one of|contains|does not contain|
	NoDefaultNameVerbs = is|is not|matches one of|does not match one of|contains|does not contain|
	NumVerbs =	is||is not|is greater than|is less than|
	NoDefaultNumVerbs = is|is not|is greater than|is less than|
	DateVerbs = is in the last||is not in the last| ; removed is||is not| for now... needs more work implementing
	NoDefaultDateVerbs = is in the last|is not in the last|
	AllActions = Move file||Rename file|Send file to Recycle Bin|Delete file|Copy file|Open file|Zip file|
	AllActionsNoDefault = Move file|Rename file|Send file to Recycle Bin|Delete file|Copy file|Open file|Zip file|
	SizeUnits = MB||KB
	NoDefaultSizeUnits = MB|KB|
	DateUnits = minutes||hours|days|weeks
	NoDefaultDateUnits = minutes|hours|days|weeks|
	MatchList = ALL|ANY|
	DeleteApproach = Oldest First|Youngest First|Largest First|Smallest First
	IfNotExist,resources
	{
		FileCreateDir,resources
	}
	FileInstall, resources\belvedere.ico, resources\belvedere.ico
	FileInstall, resources\belvederename.png, resources\belvederename.png
	FileInstall, resources\both.png, resources\both.png
	Menu, TRAY, Icon, resources\belvedere.ico
	BelvederePNG = resources\both.png
	7z = %A_ScriptDir%\includes\7za.exe
	logfile = %A_ScriptDir%\log.txt
	Sleep 200
return

BuildINI:
	IfNotExist, rules.ini
	{
		IniWrite,%A_Space%,rules.ini, Folders, Folders
		IniWrite,%A_Space%,rules.ini, Rules, AllRuleNames
		IniWrite,300000,rules.ini, Preferences, Sleeptime
		IniWrite,0,rules.ini, Preferences, Traytip
		IniWrite,0,rules.ini, Preferences, Loghistory
		IniWrite,0,rules.ini, Preferences, RBEnable
	}
return

TRAYMENU:
	Menu,TRAY,NoStandard 
	Menu,TRAY,DeleteAll 
	Menu, TRAY, Add, &Manage, MANAGE
	Menu, TRAY, Default, &Manage
	;Menu,TRAY,Add,&Preferences,PREFS
	;Menu,TRAY,Add,&Help,HELP
	Menu,TRAY,Add
	Menu,TRAY,Add,&About...,ABOUT
	Menu,TRAY,Add,&Reload,Reloadz
	Menu,TRAY,Add,E&xit,EXIT
	Menu,Tray,Tip,%APPNAME% %Version%
	;Menu,TRAY,Icon,resources\tk.ico
Return

MENUBAR:
	Menu, FileMenu, Add,E&xit,EXIT
	Menu, HelpMenu, Add,&About %APPNAME%,ABOUT
	Menu, MenuBar, Add, &File, :FileMenu
	Menu, MenuBar, Add, &Help, :HelpMenu
Return

PREFS:
	msgbox, tk
return

HELP:
	msgbox, tk
return

HOMEPAGE:
	Run, http://lifehacker.com/341950/
return

WCHOMEPAGE:
	Run, http://what-cheer.com/
return

ABOUT:
	Gui,4: Destroy
	Gui,4: +Owner
	Gui,4: Color, F8FAF0
	GUi,4: Margin, 20, 10
	Gui,4: Add, Picture, Section, %BelvederePNG%
	Gui,4: Font, s8, Courier New
	Gui,4: Add, Text, x230 y+-30, v%Version%
	Gui,4: Font, s9, Arial 
	Gui,4: Add, Text, xs Center w260, Belvedere is an automated file management application that performs actions on files based on user-defined criteria.
	Gui,4: Add, Text, xs Center w260, For example, if a file in your downloads folder hasn't been opened in 4 weeks and it's larger than 10MB, you can tell Belvedere to automatically send it to the Recycle Bin.
	Gui,4: Add, Text, xs Center w260, Belvedere is written by Adam Pash and distributed by Lifehacker under the GNU Public License.
	Gui,4: Add, Text, xs Center w260, For details on how to use Belvedere, check out:
	Gui,4: Font, cBlue Underline Bold
	Gui,4: Add, Text, xs Center w260 gHOMEPAGE, Belvedere Homepage
	Gui,4: Add, Text, xs Center w260 gWCHOMEPAGE, Icon design by What Cheer
	Gui,4: Show, AutoSize, About Belvedere
Return

Reloadz:
Reload

#Include includes\verbs.ahk
#Include includes\subjects.ahk
#Include includes\actions.ahk
#Include includes\Main_GUI.ahk

EXIT:
	ExitApp