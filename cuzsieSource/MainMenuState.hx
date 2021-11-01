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

#if windows
import Discord.DiscordClient;
#end

using StringTools;

class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;
	var currentSelectedSidebar:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	#if !switch
	var optionShit:Array<String> = ['story mode', 'freeplay', 'replays', 'options'];
	#else
	var optionShit:Array<String> = ['story mode', 'freeplay'];
	#end
	
	#if !switch
	var sideButtons:Array<String> = ['skin','song'];
	#else
	var sideButtons:Array<String> = ['skin'];
	#end
	var sideItems:FlxTypedGroup<FlxSprite>;

	var newGaming:FlxText;
	var newGaming2:FlxText;
	public static var firstStart:Bool = true;
	public static var kadeEngineVer:String = "1.0";
	public static var gameVer:String = "0.2.7.1"; 
	var camFollow:FlxObject;
	public static var finishedFunnyMove:Bool = false;
	var gfDance:FlxSprite;
	var skinButton:FlxSprite;
	var canClickStuff:Bool;
	var hasInnitiated = false;
	var logoBl:FlxSprite;
	var titleText:FlxSprite;

	override function create()
	{
		FlxG.save.bind('cuzsiemod_data', 'cuzsiedev'); 

		FlxG.mouse.visible = true;
		Conductor.changeBPM(102);

		#if sys
		if (!sys.FileSystem.exists(Sys.getCwd() + "/assets/replays"))
			sys.FileSystem.createDirectory(Sys.getCwd() + "/assets/replays");
		#end

		@:privateAccess
		{
			trace("Loaded " + openfl.Assets.getLibrary("default").assetsLoaded + " assets (DEFAULT)");
		}
		
		PlayerSettings.init();
		
		#if windows
		DiscordClient.initialize();
		DiscordClient.changePresence("In the Menus - FNF VS CUZSIE", null);
		#end
		
		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('chillMenu'));
		}


		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(0).loadGraphic(Paths.image('ui/Backgrounds/skyBG', "preload"));
		bg.scrollFactor.set(0.1, 0.1);
		bg.screenCenter();
		add(bg);

		
		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		sideItems = new FlxTypedGroup<FlxSprite>();
		add(sideItems);




		var tex = Paths.getSparrowAtlas('ui/NewMenuAssets');
		var sideButtonPaths;

		for (i in 0...optionShit.length)
		{
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
			// menuItem.setGraphicSize(Std.int(menuItem.width) - 100, Std.int(menuItem.height) - 50);
			trace("line 133");
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
			button.x = 500;
			button.y = i * 100;
			sideItems.add(button);
			button.antialiasing = true;
			trace("changing the size");
			button.setGraphicSize(60,60);
		}


		

		firstStart = false;

		FlxG.camera.follow(camFollow, null, 0.60 * (60 / FlxG.save.data.fpsCap));


		var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, gameVer +  "Cuzsie Engine - Version " + kadeEngineVer);

		versionShit.scrollFactor.set();
		versionShit.setFormat(Paths.font("opensans.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);


		if (FlxG.save.data.dfjk)
			controls.setKeyboardScheme(KeyboardScheme.Solo, true);
		else
			controls.setKeyboardScheme(KeyboardScheme.Duo(true), true);

		changeItem();




		logoBl = new FlxSprite(-500, 1500);
		logoBl.frames = Paths.getSparrowAtlas('title/LogoBump');
		logoBl.antialiasing = true;
		logoBl.animation.addByPrefix('bump', 'Start Screen BG art', 24);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		add(logoBl);


		titleText = new FlxSprite(0,logoBl.y + 100);
		titleText.frames = Paths.getSparrowAtlas('title/EnterToBegin');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = true;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		titleText.screenCenter(X);
		add(titleText);

		FlxTween.tween(logoBl,{y: -500, x:-500}, 1.4, {ease: FlxEase.expoInOut});

		super.create();
	}

	var selectedSomethin:Bool = false;

	
	var canClick:Bool = true;
	var usingMouse:Bool = true;
	
	function selectSomething(selectType:Int)
	{
		selectedSomethin = true;
		FlxG.sound.play(Paths.sound('confirmMenu'));
		canClick = false;
		FlxG.save.flush();// putting flush here cuz of skins being poop
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
					FlxTween.tween(FlxG.camera, {zoom: 5}, 1, {ease: FlxEase.expoIn});
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
					FlxTween.tween(FlxG.camera, {zoom: 5}, 1, {ease: FlxEase.expoIn});
					FlxG.camera.fade(FlxColor.BLACK, 1, false);
					
					new FlxTimer().start(1.1, function(tmr:FlxTimer)
					{
						//asdf
						var daChoice:String = sideButtons[currentSelectedSidebar];
						switch (daChoice)
						{
							case 'skin':
							FlxG.switchState(new CharacterSelectState());
							case 'song':
							FlxG.switchState(new ChartingState());
						}
					});
				}
			});
		}
	}
	
	
	function buttonRise()
	{
		menuItems.forEach(function(spr:FlxSprite)
		{
			FlxTween.tween(logoBl,{y: -540, x: -250}, 1.4, {ease: FlxEase.expoInOut});
			FlxTween.tween(titleText,{y: 1500}, 1.4, {ease: FlxEase.expoInOut});
			
			FlxTween.tween(spr,{y: 60 + (spr.ID * 160)},2,{ease: FlxEase.expoInOut, onComplete: function(flxTween:FlxTween) 
			{ 
				canClickStuff = true;
				trace("it rose up");
			}});
		});
	}
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if(FlxG.keys.justPressed.ENTER && !hasInnitiated)
		{
			buttonRise();
			hasInnitiated = true;
			trace("it worked lmao");
		}


		#if debug
		if(FlxG.keys.justPressed.SIX)
		{
			PlayState.isNewTypeChart = true;
			FlxG.sound.play(Paths.sound('confirmMenu'));
		}
		if(FlxG.keys.justPressed.ONE)
		{
			FlxG.switchState(new CampaignStoryMenuState());
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
					FlxG.switchState(new OptionsMenu());
					trace("Options Menu Selected");
				case 'donate':
					FlxG.switchState(new CharacterSelectState());
					trace("Skin Menu Selected");
				case 'replays':
					FlxG.switchState(new LoadReplayState());
					trace("Skin Menu Selected");
			}
		}
		else if (type == 1)	
		{
			switch (daChoice)
			{
				case 'skin':
					FlxG.switchState(new CharacterSelectState());
				case 'song':
					FlxG.switchState(new ChartingState());
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
