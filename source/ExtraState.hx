package;
import flixel.FlxG;

class ExtraState extends MusicBeatState
{
	override function create()
	{
		// EXTRA STATE IS OLD, USE FREEPLAY
		FlxG.switchState(new MainMenuState());
	}
}