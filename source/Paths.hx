package;

import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import haxe.Json;

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;
	inline public static var VIDEO_EXT = "mp4";

	static var currentLevel:String;


	static public function doesSoundAssetExist(path:String)
	{
		if (path == null || path == "")
			return false;
		return OpenFlAssets.exists(path, AssetType.SOUND) || OpenFlAssets.exists(path, AssetType.MUSIC);
	}
	
	inline static public function doesTextAssetExist(path:String)
	{
		return OpenFlAssets.exists(path, AssetType.TEXT);
	}


	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	static function getPath(file:String, type:AssetType, library:Null<String>)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function loadImage(key:String, ?library:String):FlxGraphic
		{
			var path = image(key, library);
	
			#if FEATURE_FILESYSTEM
			if (Caching.bitmapData != null)
			{
				if (Caching.bitmapData.exists(key))
				{
					Debug.logTrace('Loading image from bitmap cache: $key');
					// Get data from cache.
					return Caching.bitmapData.get(key);
				}
			}
			#end
	
			if (OpenFlAssets.exists(path, IMAGE))
			{
				var bitmap = OpenFlAssets.getBitmapData(path);
				return FlxGraphic.fromBitmapData(bitmap);
			}
			else
			{
				trace('Could not find image at path $path');
				return null;
			}
		}
	

	static public function listSongsToCache()
	{
		var soundAssets = OpenFlAssets.list(AssetType.MUSIC).concat(OpenFlAssets.list(AssetType.SOUND));
		var songNames = [];
		
		for (sound in soundAssets)
		{
			var path = sound.split('/');
			path.reverse();
		
			var fileName = path[0];
			var songName = path[1];
		
			if (path[2] != 'songs')
				continue;
		
			// Remove duplicates.
			if (songNames.indexOf(songName) != -1)
				continue;
		
			songNames.push(songName);
		}
		
		return songNames;
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	inline static function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function lua(key:String,?library:String)
	{
		return getPath('data/$key.lua', TEXT, library);
	}

	inline static public function luaImage(key:String, ?library:String)
	{
		return getPath('data/$key.png', IMAGE, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	inline static public function chart(key:String, ?library:String)
	{
		return getPath('$key.funkin', TEXT, library);
	}

	static public function sound(key:String, ?library:String)
	{
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String)
	{
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	inline static public function voices(song:String)
	{
		var songLowercase = StringTools.replace(song, " ", "-").toLowerCase();
		songLowercase = Utility.songLowercase(songLowercase);

		return 'assets/songs/${songLowercase}/Voices.$SOUND_EXT';
	}
	static public function video(key:String)
	{
		return 'assets/videos/$key.$VIDEO_EXT';
	}
	

	inline static public function inst(song:String)
	{
		var songLowercase = StringTools.replace(song, " ", "-").toLowerCase();
		songLowercase = Utility.songLowercase(songLowercase);

		return 'assets/songs/${songLowercase}/Inst.$SOUND_EXT';
	}

	inline static public function image(key:String, ?library:String)
	{
		return getPath('images/$key.png', IMAGE, library);
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function stages(key:String)
	{
		return 'assets/stages/$key.png';
	}

	inline static public function getSparrowAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}

	static public function loadJSON(key:String, ?library:String):Dynamic
	{
			var rawJson = OpenFlAssets.getText(Paths.json(key, library));
			try
			{
				// Attempt to parse and return the JSON data.
				return Json.parse(rawJson);
			}
			catch (e)
			{
				trace("AN ERROR OCCURRED parsing a JSON file.");
				trace(e.message);
	
				// Return null.
				return null;
			}
	}
}
