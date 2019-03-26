state("PPSSPPWindows64")
{
	int balloonsPopped : 0xD91250, 0x9F6A338;
}

startup
{
	
}

init
{

}

update
{

}

split
{
	if (current.balloonsPopped > old.balloonsPopped)
	{
		return true;
	}
}

reset
{
	if (current.balloonsPopped < old.balloonsPopped)
	{
		return true;
	}
}