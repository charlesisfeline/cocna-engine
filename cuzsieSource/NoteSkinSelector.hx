package;

import flixel.FlxSubState;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.util.FlxTimer;

class NoteSkinSelector extends FlxSubState
{
    var coolNotes:Array<FlxSprite>;
    var animations:Array<String>;
    var skins:Array<String>;
    var curSkin:String = FlxG.save.data.noteSkin;
    var curSelected:Int = 0;
    var allowInput:Bool = true;

    // curSelected = The current selected skin in an int
    // curSkin = The current selected skin in a string

    override public function create()
    {
        FlxG.save.bind('cuzsiemod_data', 'cuzsiedev'); 
        
        if (FlxG.save.data.noteSkin == null || FlxG.save.data.noteSkin == "Arrows")
        {
            FlxG.save.data.noteSkin = "Default";
        }
        trace(FlxG.save.data.noteSkin);
        
        coolNotes = 
        [
            new FlxSprite(450,400),
            new FlxSprite(550,400),
            new FlxSprite(650,400),
            new FlxSprite(750,400)
        ];

        animations = 
        [
            "Left Static",
            "Down Static",
            "Up Static",
            "Right Static"
        ];

        skins =
        [
            "Default",
            "Circles"
        ];

        for (skin in 0...skins.length)
        {
            if (FlxG.save.data.noteSkin == skins[skin])
            {
                curSelected = skin;
                curSkin = skins[skin];
                curSelected = skin;
                trace(curSkin);
            }
        }

       
        for (note in coolNotes)
        {
            note.frames = Paths.getSparrowAtlas('notes/Notes_' + curSkin, 'preload');
        }

        for (note in 0...4)
        {
            coolNotes[note].animation.addByPrefix('static', animations[note]);
            add(coolNotes[note]);
            coolNotes[note].animation.play('static');
        }

        super.create();
    }

    override function update(elapsed:Float)
    {
        if (FlxG.keys.justPressed.LEFT && allowInput)
        {
            updateDisplay(-1);
        }
        if (FlxG.keys.justPressed.RIGHT && allowInput)
        {
            updateDisplay(1);
        }

        if (FlxG.keys.justPressed.ENTER)
        {
            allowInput = false;
            FlxG.sound.play(Paths.sound('confirmMenu'));
            FlxG.save.data.noteSkin = skins[curSelected];
            FlxG.save.data.flush();

            new FlxTimer().start(0.5, function(tmr:FlxTimer)
            {
                // bruh
                close();
            });
        }
        
        
        super.update(elapsed);
    }
    

    function updateDisplay(ammount:Int)
    {
        switch(ammount)
        {
            case -1:
                curSelected--;
            case 1:
                curSelected++;
            case 0:
                trace("nada");
            default:
                curSelected++;
        }

        if (curSelected < 0)
			curSelected = skins.length;
		if (curSelected > skins.length)
			curSelected = 0;

        curSkin = skins[curSelected];
        trace(skins[curSelected]);
        

        for (note in coolNotes)
        {
            note.frames = Paths.getSparrowAtlas('notes/Notes_' + curSkin, 'preload');
        }
        for (note in 0...4)
        {
            coolNotes[note].animation.addByPrefix('static', animations[note]);
            coolNotes[note].animation.play('static');
        }
    }
}