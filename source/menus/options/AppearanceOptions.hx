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

class AppearanceOptions extends OptionCategory
{
	public function new()
	{
		title = 'Appearance Settings';
		rpcTitle = 'Appearance Settings Menu';
		
		var option:Option = new Option
		(
			'Classic Title',
			'Uses the Ludem Dare Demo title screen. (Will be active next time you relaunch the game.)',
			'classicTitle',
			'bool',
			false
		);
		addOption(option);

		var option:Option = new Option
		(
			'Osu! Seasonal Backgrounds',
			'Replace the default Friday Night Funkin menu backgrounds with the Osu! Seasonal Backgrounds)',
			'seasonalBackgrounds',
			'bool',
			false
		);
		addOption(option);


		super();
	}
}