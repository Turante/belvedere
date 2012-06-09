getName(file)
{
	SplitPath, file,,,,fileNameNoExt
	return fileNameNoExt
}

getExtension(file)
{
	StringCaseSense, Off
	SplitPath, file,,,extension
	return extension
}

getSize(file)
{
	global thisRule
	global RuleNum
	IniRead, Units, rules.ini, %thisRule%, Units%RuleNum%
	FileGetSize, fileSize, %file%
	if (Units = "KB")
	{
		fileSize := fileSize/1024 
	}
	if (Units = "MB")
	{
		fileSize := fileSize/1048576
	}
	return fileSize
}

getDateLastOpened(file)
{
	FileGetTime, lastAccess, %file%, A
	return lastAccess
}

getDateLastModified(file)
{
	FileGetTime, lastModified, %file%, M
	return lastModified
}

getDateCreated(file)
{
	FileGetTime, created, %file%, C
	;Msgbox, %created%
	return created
}