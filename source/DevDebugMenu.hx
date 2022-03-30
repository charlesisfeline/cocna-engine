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

        var text:FlxText = new FlxText
        (
            0,0,0,
            "Welcome to the\n
            Cocna Engine Debugger\n\n
            
            One - Test Dialogue\n
            Two - External List Test\n
            Three - Base List Test\n
            Four - Error Failsave\n
            Five - MenuBuilder\n
            Six - Character Select", 
            20
        );
        text.screenCenter();
        add(text);
        super.create();
    }


    override public function update(elapsed:Float) 
    {
        if (FlxG.keys.justPressed.ONE)
        {
            FlxG.switchState(new TextBoxDebug());
            close();
        }
        if (FlxG.keys.justPressed.TWO)
        {
            FlxG.switchState(new menus.BaseListExternalTest());
        }
        if (FlxG.keys.justPressed.THREE)
        {
            FlxG.switchState(new menus.BaseListTest());
        }
        if (FlxG.keys.justPressed.FOUR)
        {
            FlxG.switchState(new ErrorFailsave());
        }
        if(FlxG.keys.justPressed.FIVE)
        {
            FlxG.switchState(new menus.MenuBuilder());
        }
        if(FlxG.keys.justPressed.SIX)
        {
            FlxG.switchState(new CharacterSelectState());
        }
        
        super.update(elapsed);
    }
}
