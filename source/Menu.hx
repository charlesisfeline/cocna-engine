package;

import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;
import Sys;

using StringTools;


typedef SwagMenu =
{
	var Buttons:Array<FlxMenuButton>;
}

class Menu
{
	public var Buttons:Array<FlxMenuButton> = [new FlxMenuButton("storymode", new StoryMenuState()), new FlxMenuButton("freeplay", new FreeplayState())];


	public static function loadFromJson(?file:String):SwagMenu
	{
		try
		{
			trace('Loading menu file from: assets/data/menus/ $file');
			
			var rawJson = Assets.getText(Paths.dat('menus/$file'));

			while (!rawJson.endsWith("}"))
			{
				rawJson = rawJson.substr(0, rawJson.length - 1);
			}
	
			return parseJSONshit(rawJson);
		}
		catch(ex)
		{
			trace(ex);
			return null;
		}
	}

	public static function parseJSONshit(rawJson:String):SwagMenu
	{
		var swagShit:SwagMenu = cast Json.parse(rawJson).song;
		return swagShit;
	} 
}
