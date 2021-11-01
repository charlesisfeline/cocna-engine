package;

import flixel.addons.ui.FlxUIInputText;
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
import flixel.addons.ui.FlxInputText;
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

class NamePlayerState extends MusicBeatState
{
    var textPart1:FlxText;
    var inputThingy:FlxUIInputText;
    var canEnter:Bool = false;
    var name:String;

	override public function create()
	{
        textPart1 = new FlxText(500,-400,0,"A boy wakes up...",30);
		textPart1.setFormat(Paths.font("cursive.ttf"), 50, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
        textPart1.screenCenter();
        textPart1.y = textPart1.y - 100;
		textPart1.scrollFactor.set();


        inputThingy = new FlxUIInputText(0, 0, 400, "Boyfriend", 30,FlxColor.WHITE,FlxColor.BLACK,true);
        inputThingy.screenCenter();
        inputThingy.alignment = FlxTextAlign.CENTER;
        inputThingy.y = inputThingy.y + 200;

        add(textPart1);
        doStuff();
      
        FlxG.sound.playMusic(Paths.music('dialogueMain', 'shared'), 1);
        super.create();
	}

    function doStuff()
    {
        new FlxTimer().start(3, function(tmr:FlxTimer)
        {      
            textPart1.text = "A boy wakes up...\nWhat is his name?";
            add(inputThingy);
		});
    }

    override public function update(elapsed:Float)
    {
        
        if (FlxG.keys.justPressed.ENTER && !canEnter)
        {
            canEnter = true;
            remove(inputThingy);
            name = inputThingy.text;
            textPart1.text = "His name was " + name + "?\nY - Yes\n N - No"; 
        }
        if (FlxG.keys.justPressed.N && canEnter)
        {
            canEnter = false;
            textPart1.text = "A boy wakes up...\nWhat is his name?";
            add(inputThingy);
        }

        if (FlxG.keys.justPressed.Y && canEnter)
        {
            FlxG.save.data.playersName = name;
            FlxG.save.data.loadedFirst = false;
            FlxG.save.flush();
            FlxG.sound.music.fadeOut(2, 0);
            FlxG.camera.fade(FlxColor.BLACK, 3, false);
            new FlxTimer().start(4, function(tmr:FlxTimer)
            {
                FlxG.switchState(new StartingState());
            });
        }
        

        super.update(elapsed);
    }
}
