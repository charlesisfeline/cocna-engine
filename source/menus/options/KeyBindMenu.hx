package menus.options;

import game.StrumNote;
import utilities.PlayerSettings;
import flixel.text.FlxText;
import utilities.CoolUtil;
import flixel.tweens.FlxEase;
import utilities.NoteVariables;
import flixel.tweens.FlxTween;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import openfl.utils.Assets;

class KeyBindMenu extends MusicBeatSubstate
{
    // ALRIGHT FUCK LEATHER IM CODING THIS MYSELF
    var keyAmmount:Int = 4;
    var arrows:FlxTypedGroup<FlxSprite> = [];





    private function generateStrumline(player:Int = 0):Void
	{
		for (i in 0...keyAmmount)
		{
			var staticArrow:FlxSprite = new FlxSprite(0, 300);
	
			staticArrow.frames = Paths.getSparrowAtlas('notes/${FlxG.save.data.noteSkin.toLowerCase()}/${Note.staticKeyAnimations[keyAmmount][i]}', 'preload');
			staticArrow.animation.addByPrefix('static', Note.staticKeyAnimations[keyAmmount][i] + " Static");
			staticArrow.animation.addByPrefix('pressed', Note.staticKeyAnimations[keyAmmount][i] + ' Pressed', 24, false);
			staticArrow.animation.addByPrefix('confirm', Note.staticKeyAnimations[keyAmmount][i] + " Hit", 24, false);
				
			staticArrow.antialiasing = true;
			staticArrow.setGraphicSize(Std.int(staticArrow.width * Note.sizes[keyAmmount]));
			staticArrow.scrollFactor.set();
			staticArrow.x += Note.swagWidth * Note.widths[keyAmmount] * i;
			staticArrow.updateHitbox();
			staticArrow.y -= 10;
			staticArrow.alpha = 0;
			staticArrow.ID = i;
					
			FlxTween.tween(staticArrow, {y: staticArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.cubeInOut, startDelay: 0.5 + (0.2 * i)});
	
			arrows.add(staticArrow);
			
			var overrideWidth:Float = (FlxG.width / 1.45); 

		    staticArrow.animation.play('static');
			staticArrow.x += overrideWidth;
            staticArrow.x -= 275;
	
			strumLineNotes.add(staticArrow);
		}
	}
}