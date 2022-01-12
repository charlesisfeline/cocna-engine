package;


import Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import openfl.utils.Assets;

using StringTools;


typedef KadeSwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var gfVersion:String;
	var noteStyle:String;
	var stage:String;
	var validScore:Bool;
}

class KadeSong
{
	public var song:String;
	public var notes:Array<SwagSection>;
	public var bpm:Float;
	public var needsVoices:Bool = true;
	public var speed:Float = 1;

	public var player1:String = 'bf';
	public var player2:String = 'dad';
	public var gfVersion:String = '';
	public var noteStyle:String = '';
	public var stage:String = '';

	public function new(song, notes, bpm)
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	public static function loadFromJson(jsonInput:String, ?folder:String):KadeSwagSong
	{
		trace(jsonInput);

        var folderLowercase = StringTools.replace(folder, " ", "-").toLowerCase();

		trace('loading ' + folderLowercase + '/' + jsonInput.toLowerCase());

		var rawJson = Assets.getText(Paths.json(folderLowercase + '/' + jsonInput.toLowerCase())).trim();

		while (!rawJson.endsWith("}"))
			rawJson = rawJson.substr(0, rawJson.length - 1);

		return Song.parseJSONshit(rawJson);
	}
}

class PsychSong // Psych Engine
{

}

class ForeverSong // Forever Engine
{

}

class FunkinSong // Base Friday Night Funkin'
{

}