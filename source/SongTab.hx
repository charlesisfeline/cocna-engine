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
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;

class SongTab extends FlxObject
{
    var songBG:FlxSprite;
    var songText:FlxText;
   
   
    public function new(song:String)
    {
        var songBG:FlxSprite = new FlxSprite(0,0).loadGraphic(Paths.image("ui/songBG", "preload"));
		songBG.screenCenter(X);
		songBG.x + 100;
		songBG.setGraphicSize(900,200);

        songText = new FlxText(songBG.x, songBG.y, 0, song, 40);
        super();
    }

}