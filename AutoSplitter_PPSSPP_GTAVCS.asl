state("PPSSPPWindows64") { }
state("PPSSPPWindows64", "1.7.x") { }
state("PPSSPPWindows64", "1.8.0") { }

startup {

}

init
{
	vars.watchers = new MemoryWatcherList();
	vars.offset = 0;

	if (game.MainWindowTitle.StartsWith("PPSSPP v1.7"))
	{
		version = "1.7.x";
		vars.offset = 0xD91250;
	} else if (game.MainWindowTitle.StartsWith("PPSSPP v1.8.0"))
	{
		version = "1.8.0";
		vars.offset = 0xDC8FB0;
	} else {
		version = "";
	}
	
	vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(vars.offset, 0x9F6A338)) { Name = "BalloonsPopped" });
}

update
{
	if (version == "")
	{
		return;
	}
	
	vars.watchers.UpdateAll(game);
}

split
{
	if (vars.watchers["BalloonsPopped"].Current > vars.watchers["BalloonsPopped"].Old)
	{
		return true;
	}
}

reset
{
	if (vars.watchers["BalloonsPopped"].Current < vars.watchers["BalloonsPopped"].Old)
	{
		return true;
	}
}