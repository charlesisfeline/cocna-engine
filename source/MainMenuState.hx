package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var engineVer:String = '0.1 Beta';
	public static var curSelected:Int = 0;

	// Ui Elements //
	var bg:FlxSprite;
	var magenta:FlxSprite;
	var versionShit:FlxText;
	var menuItems:FlxTypedGroup<FlxSprite>;

	private var camGame:FlxCamera;

	var optionShit:Array<String> = [
		'story mode', 
		'freeplay', 
		'credits', 
		'donate', 
		'options'
	];

	var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	var selectedSomethin:Bool = false;

	override function create()
	{
		FlxG.save.bind('cuzsiemod_data', 'cuzsiedev'); 

		KadeEngineData.initSave();
		PlayerSettings.init();
		Conductor.changeBPM(102);
		FlxG.mouse.visible = true;	
		#if ALLOW_DISCORD_RPC
		DiscordClient.initialize();
		DiscordClient.changePresence("In the Menus", null); 
		#end

		camGame = new FlxCamera();

		FlxG.cameras.reset(camGame);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bgPath:String = "FunkinBG";
		switch(UserPrefs.seasonalBackgrounds){case true: bgPath="osu/"+Utility.osu_sBackgroundSeason+"/"+Utility.getNewOsuBg();default:}

		bg = new FlxSprite(-80).loadGraphic(Paths.image('ui/Backgrounds/' + bgPath));
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(1920,1080);
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		if (!UserPrefs.seasonalBackgrounds){bg.color = 0xFFFDE871;}

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('ui/Backgrounds/' + bgPath));
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(1920,1080);
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing;
		magenta.color = 0xFFfd719b;

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);

		versionShit = new FlxText(9, FlxG.height - 44, 0, "Cuzsie Engine v" + engineVer, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		FlxG.camera.follow(camFollowPos, null, 1);

		add(bg);
		add(magenta);
		add(camFollow);
		add(camFollowPos);
		add(versionShit);

		createMenuButtons(optionShit);
		changeItem();

		super.create();
	}

	function createMenuButtons(options:Array<String>)
	{
		var scale:Float = 1;
		
		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);
		
		for (i in 0...options.length)
		{
			var offset:Float = 108 - (Math.max(options.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, (i * 140)  + offset);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('main_menu/Button_' + options[i]);
			menuItem.animation.addByPrefix('idle', options[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', options[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.screenCenter(X);
			menuItem.ID = i;
	
			menuItems.add(menuItem);
	
			var scr:Float = (options.length - 4) * 0.135;
	
			if(options.length < 6) 
				scr = 0;
				
			menuItem.scrollFactor.set(0, scr);
			menuItem.updateHitbox();
		}
	}
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var lerpVal:Float = Utility.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				Select();
			}
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});


		// debug keys

		if (FlxG.keys.justPressed.FIVE)
		{
			FlxG.switchState(new menus.BaseListTest());
		}
		if (FlxG.keys.justPressed.SIX)
		{
			FlxG.switchState(new ErrorFailsave());
		}
	}

	public function Select()
	{
		selectedSomethin = true;
		FlxG.sound.play(Paths.sound('confirmMenu'));
		FlxFlicker.flicker(magenta, 1.1, 0.15, false);

		menuItems.forEach(function(spr:FlxSprite)
		{
			if (curSelected != spr.ID)
			{
				FlxTween.tween(spr, {alpha: 0}, 0.4,
				{
					ease: FlxEase.quadOut,
					onComplete: function(twn:FlxTween)
					{
						spr.kill();
					}
				});
			}
			else
			{
				FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
				{
					var daChoice:String = optionShit[curSelected];

					switch (daChoice)
					{
						case 'story mode':
							FlxG.switchState(new StoryMenuState());

						case 'freeplay':
							FlxG.switchState(new FreeplayState());

						case 'donate':
							FlxG.switchState(new Credits());

						case 'credits':
							FlxG.switchState(new Credits());
									
						case 'options':
							FlxG.switchState(new menus.options.OptionsState());

						default:
							FlxG.switchState(new MainMenuState());
					}
				});
			}
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				var add:Float = 0;
				if(menuItems.length > 4) {
					add = menuItems.length * 8;
				}
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
				spr.centerOffsets();
			}
		});
	}
}