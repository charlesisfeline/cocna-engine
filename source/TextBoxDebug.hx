package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.Lib;
import flixel.FlxSprite; 
import flixel.FlxBasic;

class TextBoxDebug extends MusicBeatSubstate
{
	var dialogueBox:DialogueBox;
    public var dialogue:Array<String> = ['cuzsie:This is a test dialogue!', 'bf: Cool!'];


    override public function create()
    {
        var dialogueBox = new DialogueBox(false, dialogue,true);
		dialogueBox.scrollFactor.set();

        super.create();
        
        startDialogue(dialogueBox);
    }
    
    
    function startDialogue(?dialogueBox:DialogueBox):Void
    {
        var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
        black.scrollFactor.set();
        add(black);

        new FlxTimer().start(0.3, function(tmr:FlxTimer)
        {
            black.alpha -= 0.15;
    
            if (black.alpha > 0)
            {
                tmr.reset(0.3);
            }
            else
            {
                // If there is a dialogue box
				if (dialogueBox != null)
                {
                    // Add the dialogue box
                    add(dialogueBox);
                }
                else
                {
                    trace("doo doo feces");

                }
                remove(black);
            }
        });
    }



    function doTheStuff()
    {
        var pic:FlxSprite = new FlxSprite(0,0).loadGraphic(Paths.image("ui/Backgrounds/MenuPoop"));
        trace("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA new fokin dialogue");
        var loldialogue:Array<String> = ['dad:blah blah blah', 'bf:coolswag'];
        var dialogueBox = new DialogueBox(false, loldialogue,true,'dialogueFinaleW1');
    }
}