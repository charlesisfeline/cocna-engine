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

#if windows
import Discord.DiscordClient;
#end

#if cpp
import sys.thread.Thread;
#end

using StringTools;

class StartingState extends MusicBeatState
{
    var dcText:FlxText;
    var bg:FlxSprite;


	override public function create()
	{
        bg = new FlxSprite(0,0);
        bg.loadGraphic(Paths.image("ui/ONESHOT REFRENCE LMAO", 'preload'));
        bg.screenCenter();
        bg.setGraphicSize(1280,720);
       
        dcText = new FlxText(0,0,0,"This mod is\nbest experienced\nin windowed mode",50);
		dcText.setFormat(Paths.font("opensans.ttf"), 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
        dcText.screenCenter();
		dcText.scrollFactor.set();

        add(bg);
        add(dcText);

        FlxG.sound.play(Paths.sound("selectAlt", 'preload'));

        doStuff();
        super.create();
	}

    function doStuff()
    {
        new FlxTimer().start(4, function(tmr:FlxTimer)
        {      
            MainMenuState.firstStart = true;
            FlxG.camera.fade(FlxColor.BLACK, 5, false);
                new FlxTimer().start(5, function(tmr:FlxTimer)
                {
                    
                    LoadingState.loadAndSwitchState(new TitleState());
                });
		});
    }
}
