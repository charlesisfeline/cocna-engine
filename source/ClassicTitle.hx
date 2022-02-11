package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import io.newgrounds.NG;
import lime.app.Application;
import openfl.Assets;
import polymod.Polymod;

using StringTools;

class ClassicTitle extends MusicBeatState
{
	static var initialized:Bool = false;
	static public var soundExt:String = ".mp3";

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	override public function create():Void
	{
		Polymod.init({modRoot: "mods", dirs: ['introMod']});
		PlayerSettings.init();

		super.create();

		NGio.noLogin(APIStuff.API);

		#if ng
		var ng:NGio = new NGio(APIStuff.API, APIStuff.EncKey);
		trace('NEWGROUNDS LOL');
		#end

		FlxG.save.bind('cuzsie-engine', 'cuzsie');

		Highscore.load();

		if (FlxG.save.data.weekUnlocked != null)
		{
			if (StoryMenuState.weekUnlocked.length < 4)
				StoryMenuState.weekUnlocked.insert(0, true);

			if (!StoryMenuState.weekUnlocked[0])
				StoryMenuState.weekUnlocked[0] = true;
		}

        if (!initialized)
        {
            FlxG.sound.playMusic(Paths.music("oldTitle", "preload"), 0);
            FlxG.sound.music.fadeIn(4, 0, 0.7);
        }
        
        Conductor.changeBPM(102);
        persistentUpdate = true;
        
        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("title/oldBG", 'preload'));
        bg.antialiasing = true;
        bg.setGraphicSize(Std.int(bg.width * 0.6));
        bg.updateHitbox();
        add(bg);
        
        
        var logo:FlxSprite = new FlxSprite().loadGraphic('assets/images/title/oldLogo.png');
        logo.screenCenter();
        logo.antialiasing = true;
        add(logo);
        
        FlxTween.tween(logo, {y: logo.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float) 
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (FlxG.keys.justPressed.F)
			FlxG.fullscreen = !FlxG.fullscreen;

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;
		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (pressedEnter && !transitioning)
		{
			FlxG.camera.flash(FlxColor.WHITE, 1);

			transitioning = true;
            FlxG.sound.play(Paths.image("title/titleShoot", 'preload'), 0.7);
			FlxG.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}
}