package;

import flixel.input.gamepad.FlxGamepad;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.Lib;
import Options;
import Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;

class OptionsMenu extends MusicBeatState
{
	public static var instance:OptionsMenu;

	var selector:FlxText;
	var curSelected:Int = 0;

	var options:Array<OptionCategory> = [
		new OptionCategory("Cuzsie", [
			new WindowEffects("Disable Window Movement Effects."),
			new FourthWall("Disable fourth wall breaks.")
		]),
		
		new OptionCategory("Gameplay", [
			new DownscrollOption("Change the layout of the strumline."),
			new MiddleScrollOption("Notes scroll in the middle of the screen"),
			new GhostTapOption("Tapping a direction doesnt miss"),
			new ScrollSpeedOption("Change the speed that the notes scroll at"),
			new AccuracyDOption("Change how accuracy is calculated. (Accurate = Simple, Complex = Milisecond Based)"),
			new BotPlay("Showcase your charts and mods with autoplay."),
			new ScoreScreen("Show the score screen after the end of a song"),
			new ShowInput("Display every single input in the score screen."),
			new Optimization("No backgrounds, no characters, centered notes, no player 2."),
			new CustomizeGameplay("Customize the location of UI Elements")
		]),
		new OptionCategory("Graphics", [
			#if desktop
			new FPSCapOption("Cap your FPS"),
			#end

		]),
		new OptionCategory("Input", [
			new DFJKOption(controls),
			new Judgement("Customize your Hit Timings (LEFT or RIGHT)"),
			new ResetButtonOption("Toggle pressing R to gameover."),
		]),
		new OptionCategory("Appearance", [
			new WindowEffects("Allow the windowed mode effects (EG: Window movement, errors, etc)"),
			new DistractionsAndEffectsOption("Disable flashing lights in the current stage"),
			new CamZoomOption("Toggle the camera zoom in-game."),
			new FPSOption("Toggle the FPS Counter"),
			#if desktop
			new RainbowFPSOption("Make the FPS Counter Rainbow"),
			new AccuracyOption("Display accuracy information."),
			new NPSDisplayOption("Shows your current Notes Per Second."),
			new SongPositionOption("Shows the songs current position"),
			#end
		]),
		new OptionCategory("Modifiers", [
			new SuddenDeathOption("Dont miss... ever."),
			new NoMissOption("Misses disabled."),
			new AmplifiedMisses("Misses deal more damage"),
		]),
		
	];

	public var acceptInput:Bool = true;

	private var currentDescription:String = "";
	private var grpControls:FlxTypedGroup<Alphabet>;
	public static var versionShit:FlxText;

	var currentSelectedCat:OptionCategory;
	var blackBorder:FlxSprite;
	override function create()
	{
		instance = this;
		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image("ui/Backgrounds/MenuPoop"));

		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(1280,720);
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		var menuBGOl:FlxSprite = new FlxSprite().loadGraphic(Paths.image("ui/Backgrounds/OptionsOL"));
		menuBGOl.color = 0xFFea71fd;
		menuBGOl.setGraphicSize(1280,720);
		menuBGOl.updateHitbox();
		menuBGOl.screenCenter();
		menuBGOl.antialiasing = true;
		add(menuBGOl);

		var menuOverlayThing:FlxSprite = new FlxSprite().loadGraphic(Paths.image("ui/OptionsOverlay"));
		menuOverlayThing.color = 0xFFea71fd;
		menuOverlayThing.setGraphicSize(1280,720);
		menuOverlayThing.updateHitbox();
		menuOverlayThing.screenCenter();
		menuOverlayThing.antialiasing = true;
		add(menuBG);

		grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

		for (i in 0...options.length)
		{
			var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, options[i].getName(), true, false, true);
			controlLabel.isMenuItem = true;
			controlLabel.targetY = i;
			grpControls.add(controlLabel);
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
		}

		currentDescription = "none";

		versionShit = new FlxText(0, 0, 1000, currentDescription, 20);
		versionShit.scrollFactor.set();

		versionShit.setFormat(Paths.font("opensans.ttf"), 16, FlxColor.WHITE, FlxTextAlign.RIGHT);
		versionShit.screenCenter(Y);
		versionShit.screenCenter(X);

		add(versionShit);


		super.create();
	}

	var isCat:Bool = false;
	

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		versionShit.screenCenter(Y);
		versionShit.screenCenter(X);

		if (acceptInput)
		{
			if (controls.BACK && !isCat)
				FlxG.switchState(new MainMenuState());
			else if (controls.BACK)
			{
				isCat = false;
				grpControls.clear();
				for (i in 0...options.length)
				{
					var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, options[i].getName(), true, false);
					controlLabel.isMenuItem = true;
					controlLabel.targetY = i;
					grpControls.add(controlLabel);
					// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
				}
				
				curSelected = 0;
				
				changeSelection(curSelected);
			}

			var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

			if (gamepad != null)
			{
				if (gamepad.justPressed.DPAD_UP)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeSelection(-1);
				}
				if (gamepad.justPressed.DPAD_DOWN)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeSelection(1);
				}
			}
			
			if (FlxG.keys.justPressed.UP)
				changeSelection(-1);
			if (FlxG.keys.justPressed.DOWN)
				changeSelection(1);
			
			if (isCat)
			{
				if (currentSelectedCat.getOptions()[curSelected].getAccept())
				{
					if (FlxG.keys.pressed.SHIFT)
						{
							if (FlxG.keys.pressed.RIGHT)
								currentSelectedCat.getOptions()[curSelected].right();
							if (FlxG.keys.pressed.LEFT)
								currentSelectedCat.getOptions()[curSelected].left();
						}
					else
					{
						if (FlxG.keys.justPressed.RIGHT)
							currentSelectedCat.getOptions()[curSelected].right();
						if (FlxG.keys.justPressed.LEFT)
							currentSelectedCat.getOptions()[curSelected].left();
					}
				}
				else
				{	
					versionShit.text = currentDescription;
				}
				if (currentSelectedCat.getOptions()[curSelected].getAccept())
					versionShit.text =  currentDescription;
				else
					versionShit.text = currentDescription;
			}
			else
			{
				if (FlxG.keys.pressed.SHIFT)
				{
					if (FlxG.keys.justPressed.RIGHT)
						FlxG.save.data.offset += 0.1;
					else if (FlxG.keys.justPressed.LEFT)
						FlxG.save.data.offset -= 0.1;
				}
				else if (FlxG.keys.pressed.RIGHT)
					FlxG.save.data.offset += 0.1;
				else if (FlxG.keys.pressed.LEFT)
					FlxG.save.data.offset -= 0.1;
				
				versionShit.text = currentDescription;
			}
		

			if (controls.RESET)
					FlxG.save.data.offset = 0;

			if (controls.ACCEPT)
			{
				if (isCat)
				{
					if (currentSelectedCat.getOptions()[curSelected].press()) 
					{
						grpControls.members[curSelected].reType(currentSelectedCat.getOptions()[curSelected].getDisplay());
						trace(currentSelectedCat.getOptions()[curSelected].getDisplay());
						FlxG.sound.play(Paths.sound('clickText', 'shared'));
					}
				}
				else
				{
					currentSelectedCat = options[curSelected];
					isCat = true;
					grpControls.clear();
					for (i in 0...currentSelectedCat.getOptions().length)
						{
							var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, currentSelectedCat.getOptions()[i].getDisplay(), true, false);
							
							controlLabel.isMenuItem = true;
							controlLabel.targetY = i;
							grpControls.add(controlLabel);
							// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
						}
					curSelected = 0;
				}
				
				changeSelection();
			}
		}
		FlxG.save.flush();
	}

	var isSettingControl:Bool = false;

	function changeSelection(change:Int = 0)
	{
		#if !switch
		// NGio.logEvent("Fresh");
		#end
		
		FlxG.sound.play(Paths.sound("scrollMenu"), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;

		if (isCat)
			currentDescription = currentSelectedCat.getOptions()[curSelected].getDescription();
		else
			currentDescription = "Please select a category";
		if (isCat)
		{
			if (currentSelectedCat.getOptions()[curSelected].getAccept())
				versionShit.text = currentDescription;
			else
				versionShit.text = currentDescription;
		}
		else
			versionShit.text = currentDescription;
		// selector.y = (70 * curSelected) + 30;

		var bullShit:Int = 0;

		for (item in grpControls.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}
