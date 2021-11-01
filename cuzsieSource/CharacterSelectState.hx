package;
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
	public var daCharacter:Boyfriend;
	
	public var current:Int;
	
	public var characterText:FlxText;
	public var descriptionText:FlxText;
	public var credText:FlxText;
	public var descText:FlxText;

	public var isDebug:Bool = false;

	public var PressedTheFunny:Bool = false;


	public static var CharactersList:Array<String> = ["bf","bf-christmas"];
	public var polishedCharacterList:Array<String> = ["Boyfriend","Christmas BF"];
	public var descriptionList:Array<String> = ["Default","Jolly BF!"];

	public function new() 
	{
		super();
	}
	
	override public function create():Void 
	{
		super.create();

		FlxG.save.bind('cuzsiemod_data', 'cuzsiedev');
		
		FlxG.camera.zoom = 0.75;
		FlxG.camera.fade(FlxColor.BLACK, 0.8, true);
		
		var end:FlxSprite = new FlxSprite(0, 0);
		add(end);
	
		var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('ui/SkinBG', 'shared'));
		bg.antialiasing = true;
		bg.scrollFactor.set(0.9, 0.9);
		bg.active = false;
		add(bg);

		var overlay:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('ui/SkinSetOverlay'));
		overlay.setGraphicSize(Std.int(overlay.width * 1));
		overlay.updateHitbox();
		overlay.screenCenter();
		overlay.antialiasing = true;
		add(overlay);

		daCharacter = new Boyfriend(FlxG.width / 2, FlxG.height / 2, "bf");
		daCharacter.screenCenter();
		daCharacter.y = FlxG.height / 2;
		add(daCharacter);

		characterText = new FlxText((FlxG.width / 9) - 50, (FlxG.height / 8) - 225, "Boyfriend");
		characterText.autoSize = false;
		characterText.size = 90;
		characterText.fieldWidth = 1080;
		characterText.alignment = FlxTextAlign.CENTER;
		add(characterText);

		descriptionText = new FlxText((FlxG.width / 9) - 50, 40, 0, "Default", 5);
		descriptionText.autoSize = false;
		descriptionText.size = 90;
		descriptionText.fieldWidth = 1080;
		add(descriptionText);
		descriptionText.alignment = FlxTextAlign.CENTER;
	}



	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.switchState(new MainMenuState());
		}
		if (FlxG.keys.justPressed.ENTER)
		{	
			if (PressedTheFunny)
			{
				return;
			}	
			else
			{
				PressedTheFunny = true;
			}
			if (daCharacter.animation.getByName("hey") != null)
			{
				daCharacter.playAnim('hey',true);
			}
			else
			{
				daCharacter.playAnim('singUP',true);
			}

			FlxG.sound.play(Paths.sound('confirmMenu'));
			FlxG.save.data.curSkin = CharactersList[current];
			FlxTween.tween(daCharacter, {y: daCharacter.y + 800}, 1, {ease: FlxEase.quadInOut, startDelay: 0.3});
			FlxTween.tween(FlxG.camera, {zoom: 5}, 1, {ease: FlxEase.expoIn});
			FlxG.save.flush();
			new FlxTimer().start(1.5, endIt);
		}

		if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A)
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

		if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D)
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
		daCharacter.destroy();
		daCharacter = new Boyfriend(FlxG.width / 2, FlxG.height / 2, CharactersList[current]);
		daCharacter.screenCenter();
		daCharacter.y = FlxG.height / 2;
		add(daCharacter);
	}
	
	public function endIt(e:FlxTimer=null)
	{
		trace("Closing Character Select");
		LoadingState.loadAndSwitchState(new MainMenuState());
	}

	override public function beatHit()
	{
		super.beatHit();

		daCharacter.dance();
	}
}