package;
#if html
import js.html.FileSystem;
#end
import openfl.utils.Future;
import openfl.media.Sound;
import flixel.system.FlxSound;
#if sys
import sys.FileSystem;
import sys.io.File;
#end
import Song.SwagSong;
import flixel.input.gamepad.FlxGamepad;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;


#if windows
import Discord.DiscordClient;
#end

using StringTools;

class NoteSkinList extends MusicBeatState
{
	public static var noteSkins:Array<String> = [];

	public static var currentSelected:Int = 0;
	public static var currentDifficulty:Int = 1;

	var bg:FlxSprite;

	
	private var groupSkins:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	public static var openedPreview = false;

	override function create()
	{
		persistentUpdate = true;
		
		#if sys
		var Skins = sys.FileSystem.readDirectory("mods/note_skins");
		#else
		var Skins = Utility.coolTextFile(Paths.txt('data/freeplaySonglist'));
		#end

		for (i in 0...Skins.length)
		{
			noteSkins.push(Skins[i]);
			trace(Skins[i]);
			
			trace('Loaded ' + Skins[i]);
		}


		bg = new FlxSprite().loadGraphic(Paths.image('ui/Backgrounds/BackgroundFreeplay', 'preload'));
		add(bg);

		groupSkins = new FlxTypedGroup<Alphabet>();
		add(groupSkins);

		var loadedSongs:Int = 0;


		for (i in 0...Skins.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, Skins[i], true, false, true);
			songText.isMenuItem = true;
			songText.targetY = i;
			groupSkins.add(songText);
		}

	
	
		super.create();
		
		changeSelection();
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var upP = FlxG.keys.justPressed.UP;
		var downP = FlxG.keys.justPressed.DOWN;
		var accepted = FlxG.mouse.pressed;

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.DPAD_UP)
			{
				changeSelection(-1);
			}
			if (gamepad.justPressed.DPAD_DOWN)
			{
				changeSelection(1);
			}
		}
		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (controls.BACK)
		{
			FlxG.switchState(new MainMenuState());
		}

		if (accepted)
		{
			// we gotta set your noteskin to the noteskin you selected
			trace("The Noteskin You Chose: " + Skins[currentSelected]);
		}
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);



		currentSelected += change;

		if (currentSelected < 0)
		{
			currentSelected = songs.length - 1;
		}
		if (currentSelected >= songs.length)
		{
			currentSelected = 0;
		}
			






		for (item in groupSkins.members)
		{
			item.targetY = bullShit - currentSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}
	}
}
