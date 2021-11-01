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


class GirlfriendStyleState extends FlxState
{
	public var daCharacter:Character;
	public var current:Int;
	public var notemodtext:FlxText;
	public var characterText:FlxText;
	public var credText:FlxText;
	public var descText:FlxText;

	public var isDebug:Bool = false;

	public var PressedTheFunny:Bool = false;


	public static var CharactersList:Array<String> = ["gf","gf-christmas","niko","hilda","carol","gf-invis"];
	public static var CharacterNoteMs:Array<Array<Float>> = [[1,1,1,1],[1,1,1,1],[2,0.5,0.5,0.5],[0.25,0.25,2,2],[0,0,3,0],[2,2,0.25,0.25]];
	public var polishedCharacterList:Array<String> = ["Girlfriend","Christmas","Whitty","Carol","put one here","No Girlfriend"];

	public function new() 
	{
		super();
	}
	
	override public function create():Void 
	{
		super.create();
		var end:FlxSprite = new FlxSprite(0, 0);
		add(end);
		FlxG.camera.fade(FlxColor.BLACK, 0.8, true);
		
		
		// Draw BG		
		var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('parkMain', 'shared'));
		bg.antialiasing = true;
		bg.scrollFactor.set(0.9, 0.9);
		bg.active = false;
		add(bg);

		FlxG.camera.zoom = 0.75;


		// Put Da GF
		daCharacter = new Character(FlxG.width / 2, FlxG.height / 2, "bf");
		daCharacter.screenCenter();
		daCharacter.y = FlxG.height / 2;
		add(daCharacter);



		notemodtext = new FlxText((FlxG.width / 3.5) + 80, 40, 0, "do skins work lmao?", 30);
		notemodtext.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		notemodtext.scrollFactor.set();
		// add(notemodtext);

		characterText = new FlxText((FlxG.width / 9) - 50, (FlxG.height / 8) - 225, "Girlfriend");
		notemodtext.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		characterText.autoSize = false;
		characterText.size = 90;
		characterText.fieldWidth = 1080;
		characterText.alignment = FlxTextAlign.CENTER;
		add(characterText);
	}



	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		//FlxG.camera.focusOn(FlxG.ce);
		if (FlxG.keys.justPressed.ENTER){
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
			new FlxTimer().start(1.5, endIt);
		}


		notemodtext.text = FlxStringUtil.formatMoney(CharacterNoteMs[current][0]) + "x       " + FlxStringUtil.formatMoney(CharacterNoteMs[current][3]) + "x        " + FlxStringUtil.formatMoney(CharacterNoteMs[current][2]) + "x       " + FlxStringUtil.formatMoney(CharacterNoteMs[current][1]) + "x";

		if (FlxG.keys.justPressed.LEFT){
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

		if (FlxG.keys.justPressed.RIGHT){
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
		daCharacter.destroy();
		daCharacter = new Character(FlxG.width / 2, FlxG.height / 2, CharactersList[current]);
		daCharacter.screenCenter();
		daCharacter.y = FlxG.height / 2;
		add(daCharacter);
	}
	
	
	public function endIt(e:FlxTimer=null){
		trace("ENDING");
		FlxG.save.data.curGfSkin = CharactersList[current];
		FlxG.switchState(new MainMenuState());
	}
	
}