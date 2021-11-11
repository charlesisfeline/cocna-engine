package;

import haxe.macro.Expr.Catch;
import flixel.text.FlxText;
import flixel.system.FlxSoundGroup;
import flixel.math.FlxPoint;
import openfl.geom.Point;
import flixel.*;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import flixel.util.FlxStringUtil;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;


class CharacterSelectState extends MusicBeatState
{
	public var character:Character;
	
	public var current:Int;
	
	public var characterText:FlxText;
	public var descriptionText:FlxText;
	public var credText:FlxText;
	public var descText:FlxText;

	public var isDebug:Bool = false;

	public var PressedTheFunny:Bool = false;
	var bg:FlxSprite;
	public var icon:FlxSprite;


	public static var CharactersList:Array<String> = 
	[
		"bf",
		"bf-christmas",
		"bf-pixel"
	];
	public var polishedCharacterList:Array<String> =
	[
		"Boyfriend",
		"Boyfriend Christmas",
		"Boyfriend Pixel"
	];
	public var descriptionList:Array<String> =
	[
		"Funkin!",
		"Its time to get Jolly!",
		"Retro Style!"
	];
	public var colorList:Array<FlxColor> = 
	[
		FlxColor.CYAN,
		FlxColor.CYAN,
		FlxColor.CYAN
	];

	public var unlockedCharacterList:Array<Bool> = 
	[
		true,
		true,
		true
	];


	override public function create():Void 
	{
		super.create();

		FlxG.save.bind('cuzsiemod_data', 'cuzsiedev');
		
		FlxG.camera.zoom = 0.75;
		FlxG.camera.fade(FlxColor.BLACK, 0.8, true);
		
		var end:FlxSprite = new FlxSprite(0, 0);
		add(end);
	
		bg = new FlxSprite(0, 0, Paths.image('ui/SkinSelect/bg'));
		bg.antialiasing = true;
		bg.scrollFactor.set(0.9, 0.9);
		bg.screenCenter();
		bg.setGraphicSize(2560,1440);
		bg.color = colorList[0];	
		add(bg);

		var overlay:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('ui/SkinSelect/SkinSetOverlay'));
		overlay.setGraphicSize(Std.int(overlay.width * 1));
		overlay.updateHitbox();
		overlay.screenCenter();
		overlay.setGraphicSize(1280,720);
		overlay.antialiasing = true;
		add(overlay);

		character = new Character(FlxG.width / 2, FlxG.height / 2, "bf");
		character.screenCenter();
		character.y = FlxG.height / 2;
		add(character);

		characterText = new FlxText((FlxG.width / 9) - 50, (FlxG.height / 8) - 225, "Boyfriend");
		characterText.autoSize = false;
		characterText.size = 90;
		characterText.fieldWidth = 1080;
		characterText.alignment = FlxTextAlign.CENTER;
		add(characterText);

		descriptionText = new FlxText((FlxG.width / 9) - 50, character.y - 140, 0, "Funkin!", 30);
		descriptionText.autoSize = false;
		descriptionText.fieldWidth = 1080;
		add(descriptionText);
		descriptionText.alignment = FlxTextAlign.CENTER;

		icon = new FlxSprite(0,character.y - 500).loadGraphic(Paths.image("ui/skinSelection/icons/icon-" + CharactersList[current],"preload"));
		icon.screenCenter(X);
		icon.setGraphicSize(371,414);
		add(icon);
	}



	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.switchState(new MainMenuState());
		}
		if (FlxG.keys.justPressed.ENTER && unlockedCharacterList[current])
		{	
			if (PressedTheFunny)
			{
				return;
			}	
			else
			{
				PressedTheFunny = true;
			}
			if (character.animation.getByName("hey") != null)
			{
				character.playAnim('hey',true);
			}
			else
			{
				character.playAnim('singUP',true);
			}

			FlxG.sound.play(Paths.sound('confirmMenu'));
			FlxTween.tween(character, {y: character.y + 800}, 1, {ease: FlxEase.quadInOut, startDelay: 0.3});
			FlxTween.tween(FlxG.camera, {zoom: 5}, 1, {ease: FlxEase.expoIn});
			new FlxTimer().start(1.5, endIt);
		}

		if (FlxG.keys.justPressed.LEFT && !PressedTheFunny || FlxG.keys.justPressed.A && !PressedTheFunny)
		{
			current--;
			if (current < 0)
			{
				current = 0;
			}
			else if (current > CharactersList.length - 1)
			{
				current = CharactersList.length - 1;
			}
			UpdateBF();
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		}

		if (FlxG.keys.justPressed.RIGHT && !PressedTheFunny || FlxG.keys.justPressed.D && !PressedTheFunny)
		{
			current++;
			if (current < 0)
			{
				current = 0;
			}
			else if (current > CharactersList.length - 1)
			{
				current = CharactersList.length - 1;
			}
			UpdateBF();
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		}
		
	}

	public function UpdateBF()
	{
		characterText.text = polishedCharacterList[current];
		descriptionText.text = descriptionList[current];
		try
		{
			character.changeCharacter(CharactersList[current]);
		}
		catch(ex)
		{
			trace(ex);
			character.changeCharacter("bf");
		}
		
		bg.color = colorList[current];
		
		try
		{
			icon.loadGraphic(Paths.image("selectScreen/icons/icon-" + CharactersList[current],"preload"));
			trace("Successfully Changed Icon");
		}
		catch(ex)
		{
			icon.loadGraphic(Paths.image("selectScreen/icons/icon-bf","preload"));
			trace(ex);
		}
		
		icon.screenCenter(X);
		icon.setGraphicSize(371,414);
		
		
		if (unlockedCharacterList[current])
		{
			trace("Current Character Unlocked");
			character.color = FlxColor.WHITE;
			icon.color = FlxColor.WHITE;
		}
		else if (!unlockedCharacterList[current])
		{
			trace("Current Character Not Unlocked");
			character.color = FlxColor.BLACK;
			icon.color = FlxColor.BLACK;
			characterText.text = "???";
			switch(CharactersList[current]) // put descriptions for locked characters here i guess?
			{
				default:
					descriptionText.text = "???";
			}
		}
		
	}
	
	public function endIt(e:FlxTimer=null)
	{
		trace("Closing Character Select");
		FlxG.save.data.curSkin = CharactersList[current];

		LoadingState.loadAndSwitchState(new MainMenuState());
	}

	override public function beatHit()
	{
		character.dance(); // funky dancing!!!
		
		super.beatHit();
	}
}