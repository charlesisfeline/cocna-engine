package;

import Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;
import Sys;

using StringTools;


typedef SwagSong =
{
	var song:String;
	var artist:String;
	var notes:Array<SwagSection>;
	var bpm:Float;
	var needsVoices:Bool;
	var charFly:Bool;
	var bfFly:Bool;
	var speed:Float;
	var dadFlyX:Float;
	var dadHasTrail:Bool;
	var hasDialogue:Bool;
	var keyAmmount:Int;

	var player1:String;
	var player2:String;
	var player3:String;
	var gfVersion:String;
	var noteStyle:String;
	var readySetStyle:String;
	var readySetAnimation:String;
	var stage:String;
	var validScore:Bool;
}

class Song
{
	public var song:String;
	public var notes:Array<SwagSection>;
	public var bpm:Float;
	public var needsVoices:Bool = true;
	public var charFly:Bool = false;
	public var bfFly:Bool = false;
	public var speed:Float = 1;
	public var dadFlyX:Float = 0.1;
	public var dadHasTrail:Bool = false;
	public var shasDialogue:Bool = false;
	public var keyAmmount:Int = 4;

	public var player1:String = 'bf';
	public var player2:String = 'dad';
	public var player3:String = 'none';
	public var gfVersion:String = '';
	public var noteStyle:String = '';
	public var readySetStyle:String = '';
	public var readySetAnimation:String = '';
	public var stage:String = '';

	public function new(song, notes, bpm )
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	public static function loadFromJson(?song:String, difficulty:String):SwagSong
	{
		try
		{
			var songFile = '$song/$difficulty';
			
			trace('Loading song file: assets/songs $songFile');
			
			var rawJson = Assets.getText('assets/songs/$song/$difficulty.funkin');

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
