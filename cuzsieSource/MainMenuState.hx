package;


import flixel.addons.ui.FlxUI.Rounding;
import flixel.math.FlxAngle;
import flixel.input.gamepad.FlxGamepad;
import Controls.KeyboardScheme;
import flixel.FlxG;
import flixel.addons.display.FlxExtendedSprite;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import io.newgrounds.NG;
import lime.app.Application;
import Song;



import flixel.group.FlxGroup;
import flixel.graphics.FlxGraphic;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import openfl.Assets;
import flixel.addons.display.FlxBackdrop;

#if windows
import Discord.DiscordClient;
#end

using StringTools;

class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;
	var currentSelectedSidebar:Int = 0;

	static var initialized:Bool = false;
	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var curWacky:Array<String> = [];
	var wackyImage:FlxSprite;
	var skippedIntro:Bool = false;
	var danceLeft:Bool = false;


	var menuItems:FlxTypedGroup<FlxSprite>;
	var optionShit:Array<String> = 
	[
		'story mode', 
		'freeplay', 
		'donate', 
		'options'
	];
	
	var sideButtons:Array<String> = 
	[
		'skin'
	];
	var sideItems:FlxTypedGroup<FlxSprite>;

	var newGaming:FlxText;
	var newGaming2:FlxText;
	public static var firstStart:Bool = true;
	public static var kadeEngineVer:String = "1.0 (Beta)";
	public static var gameVer:String = "0.2.7.1"; 
	var camFollow:FlxObject;
	public static var finishedFunnyMove:Bool = false;
	var gfDance:FlxSprite;
	var skinButton:FlxSprite;
	var canClickStuff:Bool;
	var hasInnitiated = false;
	var logoBl:FlxSprite;
	var titleText:FlxSprite;
	var checkeredBackground:FlxBackdrop;

	override function create()
	{
		FlxG.save.bind('cuzsiemod_data', 'cuzsiedev'); 
		KadeEngineData.initSave();

		FlxG.mouse.visible = true;
		Conductor.changeBPM(102);

		
		PlayerSettings.init();
		
		#if windows
		DiscordClient.initialize();
		DiscordClient.changePresence("In the Menus", null);
		#end
		
		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('chillMenu'));
		}


		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(0).loadGraphic(Paths.image('ui/Backgrounds/MainBG', "preload"));
		bg.scrollFactor.set(0.1, 0.1);
		bg.screenCenter();
		bg.setGraphicSize(1280,720);
		add(bg);

		checkeredBackground = new FlxBackdrop(Paths.image('ui/checkeredBG', "preload"), 0.2, 0.2, true, true);
		add(checkeredBackground);
		checkeredBackground.scrollFactor.set(0, 0.07);
		
		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		sideItems = new FlxTypedGroup<FlxSprite>();
		add(sideItems);




		var sideButtonPaths;

		for (i in 0...optionShit.length)
		{
			var tex = Paths.getSparrowAtlas('main_menu/Button_${optionShit[i]}');
			
			var menuItem:FlxSprite = new FlxSprite(0, FlxG.height * 1.6);
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
			menuItem.scrollFactor.x = 0;
			menuItem.scrollFactor.y = 0.10;
			FlxTween.tween(menuItem,{y: 60 + (i * 160)},2,{ease: FlxEase.expoInOut, onComplete: function(flxTween:FlxTween) 
			{ 
				canClickStuff = true;
				trace("omg buttons are here lol!");
			}});
		}


		for (i in 0...sideButtons.length)
		{
			sideButtonPaths = Paths.getSparrowAtlas('ui/' + sideButtons[i] + "Icon");
			
			var button:FlxSprite = new FlxSprite(0,0);
			button.frames = sideButtonPaths;
			button.animation.addByPrefix('idle', "basic", 24);
			button.animation.addByPrefix('selected',"white", 24);
			button.animation.play('idle');
			button.ID = i;
			trace("putting button in the world");
			button.x = -200;
			button.y = i * 100;
			sideItems.add(button);
			button.antialiasing = true;
			trace("changing the size");
			button.setGraphicSize(60,60);
		}


		

		firstStart = false;


		var versionShit:FlxText = new FlxText(5, FlxG.height - 25, 0, "Cuzsie Engine " + kadeEngineVer);
		versionShit.antialiasing = true;
		versionShit.scrollFactor.set();
		versionShit.setFormat(Paths.font("opensans.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);


		if (FlxG.save.data.dfjk)
			controls.setKeyboardScheme(KeyboardScheme.Solo, true);
		else
			controls.setKeyboardScheme(KeyboardScheme.Duo(true), true);

		changeItem();

		super.create();

		FlxG.camera.flash(FlxColor.WHITE, 4);
	}

	var selectedSomethin:Bool = false;

	
	var canClick:Bool = true;
	var usingMouse:Bool = true;
	
	function selectSomething(selectType:Int)
	{
		selectedSomethin = true;
		FlxG.sound.play(Paths.sound('confirmMenu'));
		canClick = false;

		if (selectType == 0)
		{
			menuItems.forEach(function(spr:FlxSprite)
			{
				if (curSelected != spr.ID)
				{
					FlxG.camera.fade(FlxColor.BLACK, 0.7, false);
					FlxTween.tween(spr, {alpha: 0}, 1.3, {
						ease: FlxEase.quadOut,
						onComplete: function(twn:FlxTween)
						{
							spr.kill();
						}
					});
				}
				else
				{
					FlxTween.tween(FlxG.camera, {zoom: 20}, 1, {ease: FlxEase.expoIn});
					FlxTween.tween(FlxG.camera, {angle: 90}, 1, {ease: FlxEase.expoIn});
					FlxG.camera.fade(FlxColor.BLACK, 1, false);
					new FlxTimer().start(1.1, function(tmr:FlxTimer)
					{
						goToState(0);
					});
				}
			});
		}
		else if (selectType == 1)
		{
			sideItems.forEach(function(spr:FlxSprite)
			{
				if (currentSelectedSidebar != spr.ID)
					{
						FlxG.camera.fade(FlxColor.BLACK, 0.7, false);
						FlxTween.tween(spr, {alpha: 0}, 1.3, {ease: FlxEase.quadOut,onComplete: function(twn:FlxTween)
						{
							spr.kill();
						}
					});
				}
				else
				{
					FlxTween.tween(FlxG.camera, {zoom: 20}, 1, {ease: FlxEase.expoIn});
					FlxTween.tween(FlxG.camera, {angle: 90}, 1, {ease: FlxEase.expoIn});
					FlxG.camera.fade(FlxColor.BLACK, 1, false);
					
					new FlxTimer().start(1.1, function(tmr:FlxTimer)
					{
						//asdf
						var daChoice:String = sideButtons[currentSelectedSidebar];
						switch (daChoice)
						{
							case 'skin':
							FlxG.switchState(new CharacterSelectState());
						}
					});
				}
			});
		}
	}
	
	

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{ 
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		checkeredBackground.x -= 0.45 / (100 / 60);
		checkeredBackground.y -= 0.16 / (100 / 60);

		if(FlxG.keys.justPressed.SEVEN)
		{	
			FlxG.switchState(new Credits());
		}


		if(FlxG.keys.justPressed.ENTER && !hasInnitiated)
		{
			hasInnitiated = true;
			trace("it worked lmao");
		}

		#if debug
		if (FlxG.keys.justPressed.NINE)
		{
			FlxG.state.openSubState(new DevDebugMenu());
		}
		#end

		menuItems.forEach(function(spr:FlxSprite)
		{
			if(!FlxG.mouse.overlaps(spr))
			{
				spr.animation.play('idle');
			}
			if (FlxG.mouse.overlaps(spr))
			{
				if(canClick)
				{
					curSelected = spr.ID;
					usingMouse = true;
					spr.animation.play('selected');
				}
						
				if(FlxG.mouse.pressed && canClick)
				{
					FlxG.save.flush();
					selectSomething(0);
				}
			}
			spr.updateHitbox();
		});

		sideItems.forEach(function(spr:FlxSprite)
		{
			if(!FlxG.mouse.overlaps(spr))
			{
				spr.animation.play('idle');
			}
			if (FlxG.mouse.overlaps(spr))
			{
				if(canClick)
				{
					currentSelectedSidebar = spr.ID;
					usingMouse = true;
					spr.animation.play('selected');
				}
						
				if(FlxG.mouse.pressed && canClick)
				{
					FlxG.save.flush();
					selectSomething(1);
				}
			}
			spr.updateHitbox();
		});

		if (!selectedSomethin)
		{
			var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

			if (gamepad != null)
			{
				if (FlxG.mouse.wheel == 1)
				{
					changeItem(-1);
				}
				if (FlxG.mouse.wheel == -1)
				{
					changeItem(1);
				}
			}
		}
		
		super.update(elapsed);
	}
	
	function goToState(type:Int)
	{
		var daChoice:String = optionShit[curSelected];
		var daOtherChoice:String = optionShit[currentSelectedSidebar];

		if (type == 0)	
		{
			switch (daChoice)
			{
				case 'story mode':
					FlxG.switchState(new StoryMenuState());
					trace("Story Menu Selected");			
				case 'freeplay':
					FlxG.switchState(new FreeplayState());
					trace("Freeplay Menu Selected");
				case 'options':
					FlxG.switchState(new menus.options.OptionsState());
					trace("Options Menu Selected");
				case 'donate':
					FlxG.switchState(new CharacterSelectState());
					trace("Skin Menu Selected");
			}
		}
		else if (type == 1)	
		{
			switch (daChoice)
			{
				case 'skin':
					FlxG.switchState(new CharacterSelectState());
			}
		}
		else
		{
			trace("Menu type is null or undefined, returning to menu.");
			FlxG.switchState(new MainMenuState());
		}
	}

	function changeItem(huh:Int = 0)
	{
		if (finishedFunnyMove)
		{
			curSelected += huh;

			if (curSelected >= menuItems.length)
				curSelected = 0;
			if (curSelected < 0)
				curSelected = menuItems.length - 1;
		}
		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			if (spr.ID == curSelected && finishedFunnyMove)
			{
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}

			spr.updateHitbox();
		});
	}
}
