package;


import flixel.math.FlxAngle;
import flixel.input.gamepad.FlxGamepad;
import Controls.KeyboardScheme;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;

class MenuCheck
{
    var image:FlxSprite;

    public var checked:Bool;

    public function new(x:Float,y:Float)
    {
        image = new FlxSprite(x,y);
        image.loadGraphic(Paths.image("ui/menuCheckEnabled", 'preload'));
        addShit();
    }


    function addShit()
    {
        add(image);
    }

    public function update(elapsed:Float)
    {
        if (checked)
        {
            image.loadGraphic(Paths.image('ui/menuCheckEnabled', 'preload'));
        }
        else
        {
            image.loadGraphic(Paths.image('ui/menuCheckDisabled', 'preload'));
        }
    }
}