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

class NoteSkinSelector extends FlxSubState
{
    var coolNotes:Array<FlxSprite>;
    var animations:Array<String>;
    var skins:Array<String>;
    var curSkin:String = FlxG.save.data.noteSkin;

    override public function create()
    {
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
            ""
        ]

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
    

    function updateDisplay()
    {
        for (note in coolNotes)
        {
            note.frames = Paths.getSparrowAtlas('notes/Notes_' + curSkin, 'preload');
        }
    }
}