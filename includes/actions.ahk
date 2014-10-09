delete(file)
{
	global errorCheck
	FileDelete, %file%
	if (ErrorLevel == 0)
		errorCheck := -1
}

move(file, destination, overwrite, Traytip)
{
	global thisRule
	global errorCheck
	IfExist, %destination%
	{
		FileMove, %file%, %destination%, %overwrite%
		if (ErrorLevel == 0)
		{
			errorCheck := -1
			if (Traytip == 1)
			{
				TrayTip, Belvedere - Moving/Renaming..., %file%, 1, 1
			}
		}
	}
	else
	{
		Msgbox,,%APPNAME%: Missing Folder,A folder you're attempting to move or copy files to with %APPNAME% does not exist. Check your "%thisRule%" rule in %APPNAME% and verify that %destination% exists.
		errorCheck := 1
	}
}

copy(file, destination, overwrite, Traytip)
{
	global thisRule
	global errorCheck
	IfExist, %destination%
	{
		FileCopy, %file%, %destination%, %overwrite%
		if (ErrorLevel == 0)
		{
			errorCheck := -1
			if (Traytip == 1)
			{
				TrayTip, Belvedere - Copying..., %file%, 1, 1
			}
		}
	}
	else
	{
		Msgbox,,%APPNAME%: Missing Folder,A folder you're attempting to move or copy files to with %APPNAME% does not exist. Check your "%thisRule%" rule in %APPNAME% and verify that %destination% exists.
		errorCheck := 1
	}
}

mirrormove(file, mirrordestination, overwrite, Traytip)
{
	global thisRule
	global errorCheck
	IfNotExist, %mirrordestination%
	{
			FileCreateDir, %mirrordestination%
	}
	IfExist, %mirrordestination%
	{
		FileMove, %file%, %mirrordestination%, %overwrite%
		if (ErrorLevel == 0)
		{
			errorCheck := -1
			if (Traytip == 1)
			{
				TrayTip, Belvedere - Moving/Renaming..., %file%, 1, 1
			}
		}
	}
}

mirrorcopy(file, mirrordestination, overwrite, traytip)
{
	global thisRule
	global errorCheck
	IfNotExist, %mirrordestination%
	{
			FileCreateDir, %mirrordestination%
	}
	IfExist, %mirrordestination%
	{
		FileCopy, %file%, %mirrordestination%, %overwrite%
		if (A_LastError == 0)
		{
			errorCheck := -1
			if (traytip == 1)
			{
				TrayTip, Belvedere - Copying..., %file%, 1, 1
			}
		}
	}
}

recycle(file)
{
	global errorCheck
	FileRecycle, %file%
	if (ErrorLevel == 0)
		errorCheck := -1
}

log(file, destination, mode, logfile)
{
	FileAppend, `n%A_YYYY%-%A_MM%-%A_DD% %A_Hour%:%A_Min%:%A_sec%:%A_MSec%`t[%mode%]`t%file%`t-->`t%destination%, %logfile%
}