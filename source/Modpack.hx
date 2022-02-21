package;

import Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;
import Sys;

using StringTools;


typedef ModPack =
{
	
}

class Mod
{
	

	public function new(song, notes, bpm )
	{
		
	}

	public static function loadFromJson(?song:String, difficulty:String):SwagSong
	{
		try
		{
			var songFile = '$song/$difficulty';
			
			trace('Loading song file: assets/songs/$songFile');
			
			var rawJson = Assets.getText('songs/$song/$difficulty.funkin');

			while (!rawJson.endsWith("}"))
			{
				rawJson = rawJson.substr(0, rawJson.length - 1);
			}
	
			return parseJSONshit(rawJson);
		}
		catch(ex)
		{
			trace(ex);
			return null; // you suck and it returned null
		}
	}

	public static function parseJSONshit(rawJson:String):SwagSong
	{
		var swagShit:SwagSong = cast Json.parse(rawJson).song;
		swagShit.validScore = true;
		return swagShit;
	} 
}
