package;

import flixel.FlxSprite;
#if windows
import sys.FileSystem;
#end

class FreeplayIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;

	public function new(song:String = 'fresh', isPlayer:Bool = false)
	{
		super();

        var path:String = "songs/" + song + "/icon.png";
		
        if (FileSystem.exists(path))
            loadGraphic(path, true, 150, 150);

        else
            loadGraphic(Paths.image("credits/icons/Cuzsie"), true, 150, 150); // teeeeeeeeeeest fix latr
           
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
