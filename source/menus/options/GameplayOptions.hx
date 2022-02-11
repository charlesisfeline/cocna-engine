package menus.options;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

using StringTools;

class GameplayOptions extends OptionCategory
{
	public function new()
	{
		title = 'Gameplay Settings';
		rpcTitle = 'Gameplay Settings Menu';
		
		var option:Option = new Option
		(
			'Downscroll',
			'If checked, notes go Down instead of Up, simple enough.',
			'downScroll',
			'bool',
			false
		);
		addOption(option);

		var option:Option = new Option
		(
			'Middlescroll',
			'If checked, your notes get centered.',
			'middleScroll',
			'bool',
			false
		);
		addOption(option);

		var option:Option = new Option
		(
			'Ghost Tapping',
			"If checked, you won't get misses from pressing keys\nwhile there are no notes able to be hit.",
			'ghostTapping',
			'bool',
			true
		);
		addOption(option);

		var option:Option = new Option
		(
			'Framerate',
			"Change the ammount of frames per second your\ngame runs at.",
			'framerate',
			'int',
			60
		);
		addOption(option);

		super();
	}
}