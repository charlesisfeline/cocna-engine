package;

import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.FlxState;
import flixel.FlxSubState;

class DevDebugMenu extends FlxSubState
{
    override public function create()
    {
        var box:FlxSprite = new FlxSprite(0,0).makeGraphic(600,600,FlxColor.BLACK);
        box.screenCenter();
        box.alpha = 0.5;
        add(box);

        var text:FlxText = new FlxText(0,0,0,"Welcome to the\nCuzsie Engine Debugger\n\nA - Test Dialogue");
        text.screenCenter();
        add(text);
        super.create();
    }


    override public function update(elapsed:Float) 
    {
        if (FlxG.keys.justPressed.A)
        {
            FlxG.switchState(new TextBoxDebug());
            close();
        }
        
        super.update(elapsed);
    }
}