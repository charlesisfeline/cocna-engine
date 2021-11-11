package;

import Song.SwagSong;
import flixel.input.gamepad.FlxGamepad;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxObject;
import flixel.FlxBasic;

class SongTab extends FlxSprite
{
    public function new(x:Float,y:Float)
    {
        var songBG:FlxSprite = new FlxSprite(x,y).loadGraphic(Paths.image("ui/songBG", "preload"));
		songBG.color = FlxColor.BLACK;
		songBG.setGraphicSize(550,191);
        super();
    }
}