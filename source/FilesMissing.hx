package;

import flash.system.System;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
#if sys
import sys.FileSystem;
import sys.io.File;
#end

class FilesMissing extends MusicBeatState
{
	var warnText:FlxText;
    var cool:String;
    public static var badFiles:Array<String>;

	override function create()
	{
		super.create();

        for(file in badFiles)
        {
            cool + '\n' + file;
        }

		warnText = new FlxText
        (
            0, 0, FlxG.width,

			'A fatal error occured\n' +
			'Important files not found:\n' +
            cool + "\n" +
            'Error code: 303_FILE-NOT-FOUND\n\n' +
            'ENTER - Continue with built-in failsave assets\n' +
            'ESCAPE - Close the game',

			20
        );
		warnText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		warnText.screenCenter(Y);
		add(warnText);
	}

	override function update(elapsed:Float)
	{
			
        if (FlxG.keys.justPressed.ENTER) 
        {
			TitleState.skipCheck = true;
            FlxG.switchState(new TitleState());
        }
        else if (FlxG.keys.justPressed.ESCAPE)
        {
            System.exit(0);
        }
        
		super.update(elapsed);
	}
}