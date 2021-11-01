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
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;

#if windows
import Discord.DiscordClient;
#end

#if cpp
import sys.thread.Thread;
#end

using StringTools;

class ChartersBuild extends MusicBeatState
{ 
    var dcText:FlxText;
    var stepperVal:Int;
    var inputThingy:FlxUIInputText;


	override public function create()
	{
        dcText = new FlxText(0,0,0,"Welcome to the VS CUZSIE Charters Build!\nEnter a song code below.\nEnter to Confirm",30);
		dcText.setFormat(Paths.font("opensans.ttf"), 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
        dcText.screenCenter();
		dcText.scrollFactor.set();

        inputThingy = new FlxUIInputText(0, 300, 400, "0000", 30,FlxColor.BLACK,FlxColor.WHITE,true);
        inputThingy.screenCenter(X);
        inputThingy.alignment = FlxTextAlign.CENTER;
        inputThingy.y = inputThingy.y + 200;


        add(dcText);
        add(inputThingy);

        super.create(); 
	}
}


