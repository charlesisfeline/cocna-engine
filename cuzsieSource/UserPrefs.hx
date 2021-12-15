package;

import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;


// Controls are in another class, see controls.hx
class UserPrefs
{
	
	// stuff i gotta port to the new system //
	
	// ghost taps (bool)
	// note skin (string)
	// downscroll (bool)
	// dfjk (bool)
	// accuracy display (bool)
	// offset (int)
	// song position (bool)
	// FPS (bool)
	// Changed Hit??? What (int)
	// Fps Cap (int)
	// Scroll Speed (float)
	// Safe Frames (int)
	// Distractions (bool)
	// Flashing Lights 
	// Reset Key
	// Autoplay
	// Score Screen
	// Middlescroll
	

	public static var ghostTapping:Bool = false;
	public static var noteSkin:String = "Default";
	public static var downScroll:Bool = false;
	public static var dfjk:Bool = false;
	public static var accuracyDisplay:Bool = false;
	public static var offset:Int = 0;
	



	public static var downScroll:Bool = false;
	

	public static var comboOffset:Array<Int> = [0, 0, 0, 0];
	public static var keSustains:Bool = false; //i was bored, okay?
	
	public static var ratingOffset:Int = 0;
	public static var sickWindow:Int = 45;
	public static var goodWindow:Int = 90;
	public static var badWindow:Int = 135;
	public static var safeFrames:Float = 10;

	public static var defaultKeys:Map<String, Array<FlxKey>> = null;

	/*public static function saveSettings() 
    {
		FlxG.save.data.downScroll = downScroll;
		FlxG.save.data.middleScroll = middleScroll;
		FlxG.save.data.showFPS = showFPS;
		FlxG.save.data.flashing = flashing;
		FlxG.save.data.globalAntialiasing = globalAntialiasing;
		FlxG.save.data.noteSplashes = noteSplashes;
		FlxG.save.data.lowQuality = lowQuality;
		FlxG.save.data.framerate = framerate;
		FlxG.save.data.camZooms = camZooms;
		FlxG.save.data.noteOffset = noteOffset;
		FlxG.save.data.hideHud = hideHud;
		FlxG.save.data.arrowHSV = arrowHSV;
		FlxG.save.data.imagesPersist = imagesPersist;
		FlxG.save.data.ghostTapping = ghostTapping;
		FlxG.save.data.timeBarType = timeBarType;
		FlxG.save.data.scoreZoom = scoreZoom;
		FlxG.save.data.noReset = noReset;
		FlxG.save.data.healthBarAlpha = healthBarAlpha;
		FlxG.save.data.comboOffset = comboOffset;
		FlxG.save.data.achievementsMap = Achievements.achievementsMap;
		FlxG.save.data.henchmenDeath = Achievements.henchmenDeath;

		FlxG.save.data.ratingOffset = ratingOffset;
		FlxG.save.data.sickWindow = sickWindow;
		FlxG.save.data.goodWindow = goodWindow;
		FlxG.save.data.badWindow = badWindow;
		FlxG.save.data.safeFrames = safeFrames;
		FlxG.save.data.gameplaySettings = gameplaySettings;
	
		FlxG.save.flush();

		var save:FlxSave = new FlxSave();
		save.bind('controls_v2', 'ninjamuffin99'); //Placing this in a separate save so that it can be manually deleted without removing your Score and stuff
		save.data.customControls = keyBinds;
		save.flush();
		FlxG.log.add("Settings saved!");
	}

	public static function loadPrefs() 
	{
		if(FlxG.save.data.newInput != null) {
			downScroll = FlxG.save.data.newInput;
		}
		

		var save:FlxSave = new FlxSave();
		save.bind('controls_v2', 'ninjamuffin99');
	}*/
}