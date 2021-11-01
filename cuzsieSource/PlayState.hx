package;

#if cpp
import sys.io.File;
#end
import flixel.addons.plugin.screengrab.FlxScreenGrab;
import flixel.util.FlxVerticalAlign;
import openfl.ui.KeyLocation;
import openfl.events.Event;
import haxe.EnumTools;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import Replay.Ana;
import Replay.Analysis;
#if cpp
import webm.WebmPlayer;
#end
import flixel.input.keyboard.FlxKey;
import haxe.Exception;
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import openfl.utils.AssetType;
import lime.graphics.Image;
import flixel.graphics.FlxGraphic;
import openfl.utils.AssetManifest;
import openfl.utils.AssetLibrary;
import flixel.system.FlxAssets;

import lime.app.Application;
import lime.media.AudioContext;
import lime.media.AudioManager;
import openfl.Lib;
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;

#if windows
import Discord.DiscordClient;
#end
#if windows
import Sys;
import sys.FileSystem;
#end

using StringTools;


// The main gameplay stuff
class PlayState extends MusicBeatState
{
	var Stage:Stage; // The Stage
	public static var instance:PlayState = null; // The current instance of PlayState
	public static var SONG:SwagSong; // The current song
	public static var rep:Replay; // The replay if the player is replaying
	public var iconP1:HealthIcon; //making these public again because i may be stupid
	public var iconP2:HealthIcon; //what could go wrong?
	var bgGirls:BackgroundGirls; // The girls in the background
	var dialogueBox:DialogueBox; // The dialogue box
	var wiggleShit:WiggleEffect = new WiggleEffect(); // Wiggle Effect
	public var notes:FlxTypedGroup<Note>; // The Notes
	private var unspawnNotes:Array<Note> = []; // Notes to unspawn after they go off screen
	var notesHitArray:Array<Date> = []; // The Notes to Hit Array
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>; // The Limo Dancers
	private var replayAna:Analysis = new Analysis(); // Replay Analisis
	
	public static var curStage:String = ''; // The current stage
	public static var characteroverride:String; // The players skin
	private var curSong:String = ""; // The current song
	var poopooStringModifier:String; // The modifiers
	var stageCheck:String = 'stage'; // The current stage again? (idk honestly)
	#if windows
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end
	public static var storyPlaylist:Array<String> = []; // The full story playlist
	public var dialogue:Array<String> = ['dad:This is dialogue!', 'bf:Beep!']; // The dialogue to say
	private var saveJudge:Array<String> = []; // The saved judgements
	
	public static var isStoryMode:Bool = false; // If its story mode and not freeplay
	public static var loadRep:Bool = false; // If its loading a replay
	var halloweenLevel:Bool = false; //If its a halloween stage (Lightning Strikes)
	private var camZooming:Bool = false; // If the camera is zooming
	private var ss:Bool = false;
	private var generatedMusic:Bool = false; // If the song has been generated
	private var startingSong:Bool = false; // If the song started.
	public static var offsetTesting:Bool = false; // If you are testing your offset
	var isHalloween:Bool = false; // If its halloween (BF and GF get scared)
	var talking:Bool = true; // If dialogue is active
	public static var theFunne:Bool = true;
	var fc:Bool = true; // If you have full comboed the song
	public static var songOffset:Float = 0; // The per song offset
	private var triggeredAlready:Bool = false; // If gf cheer has been triggered already
	private var allowedToHeadbang:Bool = false; // If gf can do the cheer pose
	var hasModifiersOn:Bool; // If the player has any active modifiers
	var inCutscene:Bool = false; // If its in a cutscene (Dialogue, animations, other stuff before the song)
	var isGoingCrazy:Bool = false; // if the window is going crazy
	var windowShakeyShake:Bool = false; // If the window is shaking
	private var executeModchart = false; // If its exicuting a modchart
	public var middleScroll:Bool;
	public static var isNewTypeChart:Bool = true; // If its a new type chart (Songs are stored in "songs" and not "assets/songs" and "assets/data/") (FOR DEBUGGING)
	public static var noteBools:Array<Bool> = [false, false, false, false]; // The note bools (True or False)
	
	public static var storyWeek:Int = 0; // The current week
	public static var storyDifficulty:Int = 1; // The song difficulty (0 - Easy, 1 - Normal, 2 - Hard)
	public static var weekSong:Int = 0; // The current week song (If story)
	public static var weekScore:Int = 0; // The current week score
	public static var shits:Int = 0; // The amount of Shit rankings the player got while playing
	public static var bads:Int = 0; // The amount of Bad rankings the player got while playing
	public static var goods:Int = 0; // The amount of Good rankings the player got while playing
	public static var sicks:Int = 0; // The amount of Sick (Marvelous) rankings the player got while playing
	private var curSection:Int = 0; // The current section / beat
	private var keyAmmount:Int; // The ammount of keys (4,6,etc)
	private var gfSpeed:Int = 1; // The speed of the gf bobbing
	private var combo:Int = 0; // Players Combo
	public static var campaignScore:Int = 0;
	public static var misses:Int = 0; // How many misses the player has
	public static var campaignMisses:Int = 0; // The ammount of misses for story mode
	private var totalPlayed:Int = 0; // The ammount of times accuracy has been updated
	var currentFrames:Int = 0; // The current ammount of frames
	public var songScore:Int = 0; // The current score of the song your playing
	public static var highestCombo:Int = 0; // The highest combo you got before missing
	var songScoreDef:Int = 0; // The song score before cauculation (i think)
	public static var repPresses:Int = 0; // The ammount of presses in replay mode
	public static var repReleases:Int = 0; // The ammount of releases in replay mode
	
	public static var songPosBG:FlxSprite; // The song position bar background
	public var strumLine:FlxSprite; // The strumline
	private var healthBarBG:FlxSprite; // The background for the health bar
	var halloweenBG:FlxSprite; // The halloween background
	var phillyTrain:FlxSprite; // The train for the pico week
	var limo:FlxSprite; // The limo for week 4
	var fastCar:FlxSprite; // The fast car in week 4
	var upperBoppers:FlxSprite; // The top characters for week 5
	var bottomBoppers:FlxSprite; // The bottom characters for week 5
	var santa:FlxSprite; // Santa for week 5
	var funneEffect:FlxSprite; // The funny effect
	public static var strumLineNotes:FlxTypedGroup<FlxSprite> = null; // The notes on the strum line
	public static var playerStrums:FlxTypedGroup<FlxSprite> = null; // The player strums
	public static var cpuStrums:FlxTypedGroup<FlxSprite> = null; // The other character strums
	var phillyCityLights:FlxTypedGroup<FlxSprite>; // The lights in week 3
	
	public static var songPosBar:FlxBar; // The song position bar itself
	private var healthBar:FlxBar; // The health bar

	private var camFollow:FlxObject; // Where the camera should follow
	private static var prevCamFollow:FlxObject; // Where the camera was following
	
	var songLength:Float = 0; // The length of the song
	public var scoreTextOgX:Float; // The original position of the score text
	public var health:Float = 1; // The health of the player
	private var floatshit:Float = 0; // The Speed of the character floating
	private var flying:Float = 0; 
	private var floatshitbf:Float = 0; // The speed of boyfriend flying
	public var accuracy:Float = 0.00; // The accuracy of the player
	private var accuracyDefault:Float = 0.00; // The default accuracy
	private var totalNotesHit:Float = 0; // The ammount of notes hit
	private var totalNotesHitDefault:Float = 0; // The default ammount of notes hit
	private var songPositionBar:Float = 0; // The position of the song bar
	var defaultCamZoom:Float = 1.05; // The default camera zoom
	public static var daPixelZoom:Float = 6; // The zoom for pixel sprites
	public static var timeCurrently:Float = 0; // What time it is
	var SpinAmount:Float = 0; // The spinning ammount
	var windowX:Float = Lib.application.window.x; // The current window x
	var windowY:Float = Lib.application.window.y; // The current window y
	public static var timeCurrentlyR:Float = 0; // The time currently

	private var vocals:FlxSound; // The vocals
	var trainSound:FlxSound; // Week 3 train sound
	
	// Characters
	public static var dad:Character; // Dad (Left Side Character)
	public static var player3:Character; // Player 3 (Dads Side)
	public static var gf:Character; // Girlfriend
	public static var boyfriend:Boyfriend; // Boyfriend

	public var camHUD:FlxCamera; // The hud camera
	private var camGame:FlxCamera; // The game camera

	var songName:FlxText; // The name of the song
	var scoreTxt:FlxText; // The score text 
	var replayTxt:FlxText; // The replay text
	private var botPlayState:FlxText; // The boyplay text
	private var activeModifiers:FlxText; // The active modifiers text

	private var saveNotes:Array<Dynamic> = []; // The saved notes

	private var susTrail:FlxTrail; // The trail for dad
	private var susTrail3:FlxTrail; // The trail for bf
	
	public function addObject(object:FlxBasic) { add(object); } // api
	public function removeObject(object:FlxBasic) { remove(object); } // api

	override public function create()
	{
		instance = this;

		FlxG.mouse.visible = false;

		// Fps Cap Stuff
		if (FlxG.save.data.fpsCap > 290)
		{
			(cast (Lib.current.getChildAt(0), Main)).setFPSCap(800);
		}
		
		// Disable music if music is disabled
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
		}

		// Sets the sicks, bads, and goods if its not story mode
		if (!isStoryMode)
		{
			sicks = 0;
			bads = 0;
			shits = 0;
			goods = 0;
		}
		
		misses = 0;
		repPresses = 0;
		repReleases = 0;


		// Load Settings
		PlayStateChangeables.useDownscroll = FlxG.save.data.downscroll;
		PlayStateChangeables.safeFrames = FlxG.save.data.frames;
		PlayStateChangeables.scrollSpeed = FlxG.save.data.scrollSpeed;
		PlayStateChangeables.botPlay = FlxG.save.data.botplay;
		PlayStateChangeables.Optimize = FlxG.save.data.optimize;
		middleScroll = FlxG.save.data.middleScroll;
		try
		{
			keyAmmount = SONG.keyAmmount;
		}
		catch(ex)
		{
			// death
		}
		if (!FlxG.save.data.ampmiss && !FlxG.save.data.suddendeath && !FlxG.save.data.nomiss)
		{
			hasModifiersOn = false;
		} 
		else
		{
			hasModifiersOn = true;
		}
		// if all modifiers are off, shut off the display thingy
		
		if (FlxG.save.data.ampmiss)
		{
			poopooStringModifier = poopooStringModifier + "\nAmplified Misses";
		}
		if (FlxG.save.data.suddendeath)
		{
			poopooStringModifier = poopooStringModifier + "\nSudden Death";
		}
		if (FlxG.save.data.suddendeath)
		{
			poopooStringModifier = poopooStringModifier + "\nSudden Death";
		}
		if (FlxG.save.data.nomiss)
		{
			poopooStringModifier = poopooStringModifier + "\nNo Misses";
		}


		// Changes the lowercasing of the song name
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
		songLowercase = Utility.songLowercase(songLowercase);
		
		
		removedVideo = false;

		// Execute modchart if its windows	
		#if windows
		executeModchart = FileSystem.exists(Paths.lua(songLowercase + "/modchart"));
		if (executeModchart)
		{
			PlayStateChangeables.Optimize = false;
		}
		#end
		
		// Force disable for non ccp targets
		#if !cpp
		executeModchart = false;
		#end
		

		// Discord Presense
		#if windows
		storyDifficultyText = Utility.difficultyFromInt(storyDifficulty);

		if (isStoryMode)
		{
			detailsText = "Story Mode: Week " + storyWeek;
		}
		else
		{
			detailsText = "Freeplay";
		}

		detailsPausedText = "Paused - " + detailsText;
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), "\nAcc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC);
		#end

		
		if(SONG.dadHasTrail)
		{
			susTrail = new FlxTrail(dad, null, 5, 7, 0.3, 0.001);
			add(susTrail);
			susTrail3 = new FlxTrail(player3, null, 5, 7, 0.3, 0.001);
			add(susTrail3);
		}

		// Creates Cameras
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxCamera.defaultCameras = [camGame];
		persistentUpdate = true;
		persistentDraw = true;

		// If the song is null, load tutorial
		if (SONG == null)
		{
			SONG = Song.loadFromJson('tutorial', 'tutorial');
		}

		// Conductor stuff
		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);
	
		// Loads dialogue
		var path:String = Paths.txt("data/dialogue/" + SONG.song + "/dialogue");
		

		if (SONG.hasDialogue)
		{
			dialogue = Utility.coolTextFile(Paths.txt(path)); // LETS JUST GO FOR IT AND HOPE IT WORKS LMAOOOOOOOO
		}
		
		
		if (SONG.stage == null) 
		{
			stageCheck = 'default';
		} 
		else 
		{
			stageCheck = SONG.stage;
		}

		
		// Stage Data
		if (!PlayStateChangeables.Optimize)
		{
			createStage(stageCheck);
		}
		
		
		// Sets the default GF if no GF was found in the chart
		var gfCheck:String = 'gf';
		
		if (SONG.gfVersion == null) 
		{
			var gfCheck:String = 'gf';
		} 
		else 
		{
			gfCheck = SONG.gfVersion;
		}

		var curGf:String = '';
		
		switch (gfCheck)
		{
			case 'gf-car':
				curGf = 'gf-car';
			case 'gf-christmas':
				curGf = 'gf-christmas';
			case 'gf-pixel':
				curGf = 'gf-pixel';
			default:
				curGf = 'gf';
		}
		
		// GF Data
		gf = new Character(500, 130, curGf);
		gf.scrollFactor.set(0.95, 0.95);

		// Dad data
		if(SONG.player2 != "none")
		{
			dad = new Character(100, 100, SONG.player2);
		}
		else
		{
			dad = new Character(100, 100, "cuzsie"); // this is just here cuz the character "none" doesnt exist and it could cause a crash
		}


		// P3
		if(SONG.player2 != "none")
		{
			player3 = new Character(dad.x - 200, 100, SONG.player2);
		}
		else
		{
			player3 = new Character(dad.x - 200, 100, "cuzsie"); // this is just here cuz the character "none" doesnt exist and it could cause a crash
		}

		// Position Data
		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		// screw with the offsets
		#if sys
		if (sys.FileSystem.exists("assets/characters/" + SONG.player2))
		{
			var offsets:Array<String> = Utility.coolTextFile("assets/characters/" + SONG.player2 + "/characterOffsets.txt");
			var offsetX:Float = Std.parseFloat(offsets[0]);
			var offsetY:Float = Std.parseFloat(offsets[1]);
		

			dad.x += offsetX;
			dad.y += offsetY;
		}
		#end


		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}
		}

		// If a skin was found, use it. Else, use the default skin.
		if (characteroverride == "none" || SONG.song == "broken")
		{
			boyfriend = new Boyfriend(770, 450, SONG.player1);
		}
		else if (characteroverride == "bf" || SONG.song == "broken")
		{
			boyfriend = new Boyfriend(770, 450, SONG.player1);
		}
		else
		{
			boyfriend = new Boyfriend(770, 450, characteroverride);
		}

		// Per Stage Position Data
		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;
				if(FlxG.save.data.distractions){
					resetFastCar();
					add(fastCar);
				}

			case 'mall':
				boyfriend.x += 200;

			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'schoolEvil':
				if(FlxG.save.data.distractions){
				// trailArea.scrollFactor.set();
				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
				// evilTrail.changeValuesEnabled(false, false, false, false);
				// evilTrail.changeGraphic()
				add(evilTrail);
				// evilTrail.scrollFactor.set(1.1, 1.1);
				}


				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
		}


		trace
		(
		"\nGAME DATA: " 
		+ "\nGirlfriend: " + SONG.gfVersion 
		+ "\nSong Name: " + SONG.song
		+ "\nPlayer 1: " + SONG.player1 
		+ "\nPlayer 2: " + SONG.player2
		+ "\nStage: " + curStage
		
		+ "\n\nSettings Info:"

		+ "\nSafe Frames: "+ PlayStateChangeables.safeFrames 
		+ "\nSafe Zone Offset:" + Conductor.safeZoneOffset 
		+ "\nTime Scale:" + Conductor.timeScale 
		+ "\nBotPlay: " + PlayStateChangeables.botPlay 
		+ "\nCurrent Skin: " + characteroverride
		+ '\nModchart: ' + executeModchart + " - " + Paths.lua(songLowercase + "/modchart")
		);


		// Creates Characters (and the limo idfk why its here)
		if (!PlayStateChangeables.Optimize)
		{
			add(gf);
			if (curStage == 'limo')
			{
				add(limo);
			}

			add(dad);
			add(boyfriend);
			add(player3);
			
			
			// stuff for removing characters
			if (SONG.gfVersion == 'none')
			{
				remove(gf);
			}
			if (SONG.player1 == 'none')
			{
				remove(boyfriend);
			}
			if (SONG.player2 == 'none')
			{
				remove(dad);
			}
			if (SONG.player3 == 'none')
			{
				remove(player3);
			}
			
		}

		// honestly dont know what this stuff is lol pls explain kade
		if (loadRep)
		{
			FlxG.watch.addQuick('rep rpesses',repPresses);
			FlxG.watch.addQuick('rep releases',repReleases);
			PlayStateChangeables.useDownscroll = rep.replay.isDownscroll;
			PlayStateChangeables.safeFrames = rep.replay.sf;
			PlayStateChangeables.botPlay = true;
		}

		trace('uh ' + PlayStateChangeables.safeFrames);
		trace("SF CALC: " + Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));
		
		// Dialogue box data
		var dialogueBox = new DialogueBox(false, dialogue);
		dialogueBox.scrollFactor.set();
		dialogueBox.finishThing = startCountdown;

		// Sets the song pos
		Conductor.songPosition = -5000;
		
		// Creates the strumline
		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();
		
		if (PlayStateChangeables.useDownscroll)
		{
			strumLine.y = FlxG.height - 165;
		}

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);
		playerStrums = new FlxTypedGroup<FlxSprite>(); // The player strums
		cpuStrums = new FlxTypedGroup<FlxSprite>(); // The dad's strums

		if (SONG.song == null)
		{
			trace('Song returned null');
		}
		else
		{
			trace('Song looks good, generating');
		}

		// Generates the song
		generateSong(SONG.song);
		trace('Song Generated');

		// Sets the camera follow position
		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / (cast (Lib.current.getChildAt(0), Main)).getFPS()));
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		// Sets world bounds
		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);
		FlxG.fixedTimestep = false;

		// Sets the stuff with the song position bar
		if (FlxG.save.data.songPosition) 
		{
			// Sets the data for the background
			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('ui/HealthBarBG'));
			if (PlayStateChangeables.useDownscroll)
			{
				songPosBG.y = FlxG.height * 0.9 + 45; 
			}
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);
				
			// Sets the data for the bar itself
			songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,'songPositionBar', 0, 90000);
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.BLACK, FlxColor.WHITE);
			add(songPosBar);
	
			// Sets the data for the song name
			var songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - (SONG.song.length * 5),songPosBG.y,0,SONG.song, 16);
			if (PlayStateChangeables.useDownscroll)
			{
				songName.y -= 3;
			}
			songName.setFormat(Paths.font("opensans.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
			songName.scrollFactor.set();
			add(songName);
			songName.cameras = [camHUD];
		}

		
		// Sets the data for the health bar bg
		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('ui/HealthBarBG'));
		if (PlayStateChangeables.useDownscroll)
		{
			healthBarBG.y = 50;
		}
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		// Sets the data for the health bar
		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,'health', 0, 2);
		healthBar.scrollFactor.set();
		
		
		var player2ColorPath:String = "assets/characters/" + SONG.player2 + "/healthbar_color.txt"; // fart doo doo doo doo



		if (SONG.player2 == 'cuzsie')
		{
			healthBar.createFilledBar(FlxColor.ORANGE, FlxColor.BLUE);
		}
		if (SONG.player2 == 'alpha')
		{
			healthBar.createFilledBar(FlxColor.BLACK, FlxColor.BLUE);
		}
		else
		{
			healthBar.createFilledBar(FlxColor.RED, FlxColor.BLUE);
		}
		add(healthBar);

		// Sets the data for the score text
		scoreTxt = new FlxText(FlxG.width / 2 - 235, healthBarBG.y + 50, 0, "", 30);
		scoreTxt.screenCenter(X);
		scoreTextOgX = scoreTxt.x;
		scoreTxt.scrollFactor.set();
		scoreTxt.setFormat(Paths.font("pixel.otf"), 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		add(scoreTxt);
		scoreTxt.screenCenter(X);

		// Sets the data for the replay text when in replay mode
		replayTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0, "Replay: " + SONG.song, 20);
		replayTxt.setFormat(Paths.font("opensans.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		replayTxt.borderSize = 4;
		replayTxt.borderQuality = 2;
		replayTxt.scrollFactor.set();
		if (loadRep)
		{
			add(replayTxt);
		}
		
		// Sets the data for the auto text when in auto mode
		botPlayState = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0, "Auto", 20);
		botPlayState.setFormat(Paths.font("opensans.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		botPlayState.scrollFactor.set();
		botPlayState.borderSize = 4;
		botPlayState.borderQuality = 2;
		

		activeModifiers = new FlxText(healthBarBG.x + healthBarBG.width / 5 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0, poopooStringModifier, 20);
		activeModifiers.setFormat(Paths.font("opensans.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		activeModifiers.scrollFactor.set();
		activeModifiers.borderSize = 4;
		activeModifiers.borderQuality = 2;
		add(activeModifiers);

		// Display HUD Elements on the HUD Camera


		// If botplay and not loading a replay
		if(PlayStateChangeables.botPlay && !loadRep) add(botPlayState);
		{
			// Add P1 Icon
			iconP1 = new HealthIcon(SONG.player1, true);
			iconP1.y = healthBar.y - (iconP1.height / 2);
			add(iconP1);

			// Add P2 Icon
			iconP2 = new HealthIcon(SONG.player2, false);
			iconP2.y = healthBar.y - (iconP2.height / 2);
			add(iconP2);

			// Sets the UI elements to the hud camera
			strumLineNotes.cameras = [camHUD];
			notes.cameras = [camHUD];
			healthBar.cameras = [camHUD];
			healthBarBG.cameras = [camHUD];
			iconP1.cameras = [camHUD];
			iconP2.cameras = [camHUD];
			scoreTxt.cameras = [camHUD];
			dialogueBox.cameras = [camHUD];
		}

		// If song bar is on, show song bar
		if (FlxG.save.data.songPosition)
		{
			// Set song bar to the hud camera
			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
		}
		
		
		// If loading replay, put replay text on hud camera
		if (loadRep)
		{
			replayTxt.cameras = [camHUD];
		}

		// Start the song
		startingSong = true;
		trace('Song Starting...');

		// Start the dialogue
		if (SONG.song == "broken")
		{
			brokenCutscene();
		}
		else if (SONG.hasDialogue)
		{
			startDialogue(dialogueBox);
		}
		else
		{
			startCountdown();
		}

		// If you arent loading a replay, create a new replay in the replay folder	
		if (!loadRep)
		{
			rep = new Replay("na");
		}

		// Add the event listener
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN,handleInput);

		super.create();
	}


	// Stage create function
	function createStage(stagename:String)
	{

		Stage = new Stage(SONG.stage);
		for (i in Stage.toAdd)
		{
			add(i);
		}
		defaultCamZoom = Stage.camZoom;

		/*switch(stagename)
		{
			case 'park':
			{
				defaultCamZoom = 0.9;
				curStage = 'park';
						
				var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('stages/parkmain/Sky', "preload"));
				bg.scrollFactor.set(0.1, 0.1);

				var ground:FlxSprite = new FlxSprite(-200, 0).loadGraphic(Paths.image('stages/parkmain/Ground', "preload"));
				
				add(bg);
				add(ground);
			}

			case 'park-alpha':
			{
				defaultCamZoom = 0.7;
				curStage = 'park-alpha';
				
				var bg:FlxSprite = new FlxSprite(0,0).loadGraphic(Paths.image('stages/alphapark/BrokenBG', "preload"));
				bg.setGraphicSize(2560,1440);
				bg.screenCenter();
				bg.updateHitbox();
				bg.scrollFactor.set(0.1, 0.1);

				add(bg);
			}

			case 'dreamland':
			{
				defaultCamZoom = 0.6;
				curStage = 'dreamland';
						
				var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('stages/dreamstage/dreamBG', "preload"));
				bg.scrollFactor.set(0.1, 0.1);
				bg.setGraphicSize(2560,1440);

				add(bg);
			}
					
			// dis just the failsave stage
			default:
			{
				defaultCamZoom = 0.9;
				curStage = 'stage';

				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stages/stage/stageback', "preload"));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;

				var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stages/stage/stagefront', "preload"));
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				stageFront.antialiasing = true;
				stageFront.scrollFactor.set(0.9, 0.9);
				stageFront.active = false;

				var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stages/stage/stagecurtains', "preload"));
				stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
				stageCurtains.updateHitbox();
				stageCurtains.antialiasing = true;
				stageCurtains.scrollFactor.set(1.3, 1.3);
				stageCurtains.active = false;

				add(bg);
				add(stageFront);
				add(stageCurtains);
			}
		}

		var daStageLmao:Stage = new Stage("park");*/
	}

	function brokenCutscene()
	{
		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('cutscene/cuzsieTransformation','preload');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		// Creates the red bg for the thorns cutscene
		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		add(red);

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
				// Add senpai
				add(senpaiEvil);
				senpaiEvil.alpha = 0;
	
				new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
				{
					// SLowly fade in senpai
					senpaiEvil.alpha += 0.15;
					if (senpaiEvil.alpha < 1)
					{
						swagTimer.reset();
					}
					else
					{
						// Play senpais idle animation
						senpaiEvil.animation.play('idle');
	
						// Changes window title
						windowChangeData();
									
						// Play the senpai dies sound
						FlxG.sound.play(Paths.sound('cuzsie-transform','shared'), 1, false, null, true, function()
						{
							// Remove senpai and the red bg
							remove(senpaiEvil);
							remove(red);
							windowShakeyShake = false;
							FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
							{
								startCountdown();
							}, true);
						});
									
						// Fade White
						new FlxTimer().start(3.2, function(deadTime:FlxTimer)
						{
							FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
						});
					}
				});
		});
	}

	// The Dialogue and Cutscene Stuff (NOT VIDEO)
	function startDialogue(?dialogueBox:DialogueBox):Void
	{
		// Creates the black bg
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);
		
		// If the song uses the thorns cutscene, disable da thing
		if (StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase() == 'broken' || StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase() == 'broken')
		{
			remove(black);
		}

		// Here comes the dialogue stuff!
		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			// Changes the alpha of the black bg
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				// If there is a dialogue box
				if (dialogueBox != null)
				{
					// Tells the game that your in a cutscene
					inCutscene = true;
					
					// Add the dialogue box
					add(dialogueBox);
				}
				else
				{
					startCountdown(); 
				}
				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;
	var luaWiggles:Array<WiggleEffect> = [];
	#if windows
	public static var luaModchart:ModchartState = null;
	#end

	
	// EASIER FUNCTIONS //


	function moveWindow(x:Int,y:Int) // simpler way to move window
	{
		if (FlxG.save.data.windoweffects)
		{
			Lib.application.window.move(x,y);
		}
		else
		{
			trace(" moveWindow() - Window effects are disabled");
		}
	}
	





	// Starts the "Three, Two, One, Go!"
	function startCountdown():Void
	{
		// Tells the game that you aint in a cutscene
		inCutscene = false;
		
		keyAmmount = 4;
			
		
		generateStaticArrows(0,keyAmmount);
		generateStaticArrows(1,keyAmmount);


		// If its windows, prepare the modchart
		#if windows
		// Pre-Lowercasing the song name
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
		
		//If If there is a modchart, execute it
		if (executeModchart)
		{
			luaModchart = ModchartState.createModchartState();
			luaModchart.executeState('start',[songLowercase]);
		}

		trace("Modchart executed!");
		#end

		// Set started countdown to true
		talking = false;
		startedCountdown = true;
		trace("Starting the Countdown...");
		
		// Sets the song position to 0
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			// Starts the dad, gf, and bf idle animations
			dad.dance();
			gf.dance();
			player3.dance();
			boyfriend.playAnim('idle');

			// Gets the intro assets
			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ui/Two', "ui/One", "ui/GetIt"]);
			introAssets.set('school', ['ui/TwoPixel','ui/OnePixel','ui/GetItPixel']);
			introAssets.set('schoolEvil', ['ui/TwoPixel','ui/OnePixel','ui/GetItPixel']);
			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			// Play sounds and show the icons on screen
			switch (swagCounter)
			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3' + SONG.readySetStyle), 0.6);
				case 1:
					// Sets the data for the ready image
					var ready:FlxSprite = new FlxSprite();

					switch (SONG.readySetStyle)
					{
						case 'default':
							ready.loadGraphic(Paths.image('ui/Two'));
						case 'null':
							ready.loadGraphic(Paths.image('ui/Two'));
						case 'pixel':
							ready.loadGraphic(Paths.image('ui/TwoPixel'));
							ready.setGraphicSize(Std.int(ready.width * daPixelZoom));
						default:
							ready.loadGraphic(Paths.image('ui/Two'));
					}
					
					ready.scrollFactor.set();
					ready.updateHitbox();


					// Center the ready image
					ready.screenCenter();
					// Add the ready image
					add(ready);
					// Animate the ready image
					
					if (SONG.readySetAnimation == "cube")
					{
						FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween){ready.destroy();}});
					}
					else if (SONG.readySetAnimation == "bounce")
					{
						FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.bounceInOut, onComplete: function(twn:FlxTween){ready.destroy();}});
					}
					else if (SONG.readySetAnimation == "elastic")
					{
						FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.elasticInOut, onComplete: function(twn:FlxTween){ready.destroy();}});
					}
					else
					{
						FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween){ready.destroy();}});
					}



					if (SONG.readySetStyle != null || SONG.readySetStyle != null)
					{
						FlxG.sound.play(Paths.sound('intro2default'), 0.6);
					}
					else
					{
						FlxG.sound.play(Paths.sound('intro2' + SONG.readySetStyle), 0.6);
					}
				// If the counter is at 1
				case 2:
					// Sets the data for the set image
					var set:FlxSprite = new FlxSprite();
					switch (SONG.readySetStyle)
					{
						case 'default':
							set.loadGraphic(Paths.image('ui/One'));
						case 'null':
							set.loadGraphic(Paths.image('ui/One'));
						case 'pixel':
							set.loadGraphic(Paths.image('ui/OnePixel'));
							set.setGraphicSize(Std.int(set.width * daPixelZoom));
						default:
							set.loadGraphic(Paths.image('ui/One'));
					}
					set.scrollFactor.set();

					// Center the set image
					set.screenCenter();
					// Add the set image
					add(set);
					// Animate the set image
					if (SONG.readySetAnimation == "cube")
						{
							FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween){set.destroy();}});
						}
						else if (SONG.readySetAnimation == "bounce")
						{
							FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.bounceInOut, onComplete: function(twn:FlxTween){set.destroy();}});
						}
						else if (SONG.readySetAnimation == "elastic")
						{
							FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.elasticInOut, onComplete: function(twn:FlxTween){set.destroy();}});
						}
						else
						{
							FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween){set.destroy();}});
						}
					// Play the one sound
						if (SONG.readySetStyle != null || SONG.readySetStyle != null)
						{
							FlxG.sound.play(Paths.sound('intro1default'), 0.6);
						}
						else
						{
							FlxG.sound.play(Paths.sound('intro1' + SONG.readySetStyle), 0.6);
						}
					
				// If the counter is on GO
				case 3:
					// Sets the data for the go image
					var go:FlxSprite = new FlxSprite();
					switch (SONG.readySetStyle)
					{
						case 'default':
							go.loadGraphic(Paths.image('ui/GetIt'));
						case 'null':
							go.loadGraphic(Paths.image('ui/GetIt'));
						case 'pixel':
							go.loadGraphic(Paths.image('ui/GetItPixel'));
							go.setGraphicSize(Std.int(go.width * daPixelZoom));
						default:
							go.loadGraphic(Paths.image('ui/GetIt'));

					}

					go.scrollFactor.set();
					
					// Update the hitbox for the go image
					go.updateHitbox();
					// Center the set image
					go.screenCenter();
					// Add the set image
					add(go);
					// Animate the set image
					if (SONG.readySetAnimation == "cube")
					{
						FlxTween.tween(go, {y: go.y += 120, alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween){go.destroy();}});
					}
					else if (SONG.readySetAnimation == "bounce")
					{
						FlxTween.tween(go, {y: go.y += 120, alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.bounceInOut, onComplete: function(twn:FlxTween){go.destroy();}});
					}
					else if (SONG.readySetAnimation == "elastic")
					{
						FlxTween.tween(go, {y: go.y += 120, alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.elasticInOut, onComplete: function(twn:FlxTween){go.destroy();}});
					}
					else
					{
						FlxTween.tween(go, {y: go.y += 120, alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween){go.destroy();}});
					}



					// Play the go sound
					if (SONG.readySetStyle != null || SONG.readySetStyle != null)
						{
							FlxG.sound.play(Paths.sound('introGodefault'), 0.6);
						}
						else
						{
							FlxG.sound.play(Paths.sound('introGo' + SONG.readySetStyle), 0.6);
						}
				// Its the end of the cycle, so this will do nothing
				case 4:
			}

			// Changes the counter by 1 every time it completes the cycle
			swagCounter += 1;
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;


	// Gets the.. key? (yea idk what this is can someone tell me)
	private function getKey(charCode:Int):String
	{
		for (key => value in FlxKey.fromStringMap)
		{
			if (charCode == value)
				return key;
		}
		return null;
	}

	// The input handler (Dont reccomend modifying this)
	private function handleInput(evt:KeyboardEvent):Void 
	{

		if (PlayStateChangeables.botPlay || loadRep || paused)
			return;

		// first convert it from openfl to a flixel key code
		// then use FlxKey to get the key's name based off of the FlxKey dictionary
		// this makes it work for special characters
		@:privateAccess
		var key = FlxKey.toStringMap.get(evt.keyCode);
		var binds:Array<String>;
		var data = -1;
		
		switch(keyAmmount)
		{
			case 4:
				binds = [FlxG.save.data.leftBind,FlxG.save.data.downBind, FlxG.save.data.upBind, FlxG.save.data.rightBind];
				switch(evt.keyCode)
				{
					case 37:
						data = 0;
					case 40:
						data = 1;
					case 38:
						data = 2;
					case 39:
						data = 3;
				}
			case 6:
				binds = [FlxG.save.data.sixLeftBind,FlxG.save.data.leftBind,FlxG.save.data.downBind, FlxG.save.data.upBind, FlxG.save.data.rightBind,FlxG.save.data.sixRightBind];
				switch(evt.keyCode)
				{
					case S:
						data = 0;
					case 37:
						data = 1;
					case 40:
						data = 2;
					case 39:
						data = 3;
					case L:
						data = 3;
				}
			default:
				binds = [FlxG.save.data.leftBind,FlxG.save.data.downBind, FlxG.save.data.upBind, FlxG.save.data.rightBind];
				switch(evt.keyCode)
				{
					case 37:
						data = 0;
					case 40:
						data = 1;
					case 38:
						data = 2;
					case 39:
						data = 3;
				}
		}
		// https://api.haxeflixel.com/flixel/input/keyboard/FlxKey.html
		trace(key);


		for (i in 0...binds.length) // binds
		{
			if (binds[i].toLowerCase() == key.toLowerCase())
			data = i;
		}

		if (data == -1)
			{
				trace("couldn't find a keybind with the code " + key);
				return;
			}



		if (evt.keyLocation == KeyLocation.NUM_PAD)
		{
			trace(String.fromCharCode(evt.charCode) + " " + key);
		}

		if (data == -1)
			return;

		var ana = new Ana(Conductor.songPosition, null, false, "miss", data);

		var dataNotes = [];
		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && daNote.noteData == data)
				dataNotes.push(daNote);
		}); // Collect notes that can be hit


		dataNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime)); // sort by the earliest note
		
		if (dataNotes.length != 0)
		{
			var coolNote = dataNotes[0];

			goodNoteHit(coolNote);
			var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
			ana.hit = true;
			ana.hitJudge = Ratings.CalculateRating(noteDiff, Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));
			ana.nearestNote = [coolNote.strumTime,coolNote.noteData,coolNote.sustainLength];
		}
		
	}
	var songStarted = false;

	// Starts the song
	function startSong():Void
	{
		// Sets starting song to false and song started to true
		startingSong = false;
		songStarted = true;
		
		// weird crap
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		// If it isnt paused, play the song
		if (!paused)
		{
			if (isNewTypeChart)
			{
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
			}
			else
			{
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
			}
		}

		// Ends the song on the track ending time
		FlxG.sound.music.onComplete = endSong;
		
		// Plays the vocals
		vocals.play();

		// The song duration stored in a float
		songLength = FlxG.sound.music.length;

		// Add song position stuff to the hud
		if (FlxG.save.data.songPosition)
		{
			remove(songPosBG);
			remove(songPosBar);
			remove(songName);

			// Sets the data for the background
			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('healthBar'));
			if (PlayStateChangeables.useDownscroll)
			{
				songPosBG.y = FlxG.height * 0.9 + 45; 
			}
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);

			// Sets the data for the bar itself
			songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,'songPositionBar', 0, songLength - 1000);
			songPosBar.numDivisions = 1000;
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.BLACK, FlxColor.WHITE);
			add(songPosBar);

			// Sets the data for the song name text
			var songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - (SONG.song.length * 5),songPosBG.y,0,SONG.song, 16);
			if (PlayStateChangeables.useDownscroll)
				songName.y -= 3;
			songName.setFormat(Paths.font("opensans.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
			songName.scrollFactor.set();
			add(songName);

			
			// Puts all this on the HUD
			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
			songName.cameras = [camHUD];
		}
		
		// Allows gf to do the yay pose
		switch(curSong)
		{
			// All the songs that allow it
			case 'Bopeebo' | 'Philly Nice' | 'Blammed' | 'Cocoa' | 'Eggnog': allowedToHeadbang = true;
			
			// For default, dont allow gf to do the yay pose
			default: allowedToHeadbang = false;
		}

		// Get the video if the song uses it
		if (useVideo)
		{
			GlobalVideo.get().resume();
		}
		
		// Updates discord RPC with time left
		#if windows
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), "\nAcc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC);
		#end
	}
	var debugNum:Int = 0;

	// Generates the song
	private function generateSong(dataPath:String):Void
	{
		// Sets the song data as the saved chart
		var songData = SONG;

		// Sets the conducter bpm to the chart bpm
		Conductor.changeBPM(songData.bpm);

		// Load the song data
		trace('Loading Song Data...');
		curSong = songData.song;
		trace('Loaded Song Data!');

		// Load the song voices
		trace('Loading Voices...');
		if (SONG.needsVoices)
		{
			if (isNewTypeChart)
			{
				vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
			}
			else
			{
				vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
			}
			
		}
		else
		{
			vocals = new FlxSound();
		}
		trace('Vocal Track Loaded!');

		// Adds the vocals to the song list
		FlxG.sound.list.add(vocals);

		// Adds the notes
		notes = new FlxTypedGroup<Note>();
		add(notes);
		var noteData:Array<SwagSection>;

		// Sets the note data as the cart note data
		noteData = songData.notes;
		var playerCounter:Int = 0;

		// Per song offset check
		#if windows
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
		
		// Change song lowercase
		switch (songLowercase) 
		{
			case 'dad-battle': songLowercase = 'dadbattle';
			case 'philly-nice': songLowercase = 'philly';
		}

		// Data for the song path
		var songPath:String;

		if (isNewTypeChart)
		{
			songPath = 'assets/songs/' + songLowercase + '/';
		}
		else
		{
			songPath = 'assets/data/' + songLowercase + '/';
		}
			
		// Loads the song offset
		for(file in sys.FileSystem.readDirectory(songPath))
		{
			var path = haxe.io.Path.join([songPath, file]);
			if(!sys.FileSystem.isDirectory(path))
			{
				// If the path ends with .offset
				if(path.endsWith('.offset'))
				{
					trace('Found offset file: ' + path);
					// Sets the offset
					songOffset = Std.parseFloat(file.substring(0, file.indexOf('.off')));
					break;
				}
				// If the path doesnt exist
				else 
				{
					trace('Offset file not found. Creating one @: ' + songPath);
					// Create an offset file
					sys.io.File.saveContent(songPath + songOffset + '.offset', '');
				}
			}
		}
		#end
		
		// Beats is how many times the song has looped
		var daBeats:Int = 0;
		
		// Note generation stuff (i think)
		for (section in noteData)
		{

			var coolSection:Int = Std.int(section.lengthInSteps / 4);


			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0] + FlxG.save.data.offset + songOffset;
				if (daStrumTime < 0)
				{
					daStrumTime = 0;
				}
				var daNoteData:Int;
				daNoteData = Std.int(songNotes[1] % 4);
				var gottaHitNote:Bool = section.mustHitSection;
				
				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}
				var oldNote:Note;
				
				// Despawn note when offscreen
				if (unspawnNotes.length > 0)
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				}
				else
				{
					oldNote = null;
				}
				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);

				if (!gottaHitNote && PlayStateChangeables.Optimize || middleScroll)
					continue;

				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);
				var susLength:Float = swagNote.sustainLength;
				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);
					sustainNote.mustPress = gottaHitNote;
					
					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}
				}
				
				swagNote.mustPress = gottaHitNote;
				
				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else
				{
				}
			}
			daBeats += 1;
		}
		
		unspawnNotes.sort(sortByShit);
		generatedMusic = true;
	}

	// Sort stuff (dont know what it does)
	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	public function GenerateNewValue(Min:Int, Max:Int) 
	{
		randomTenInt = FlxG.random.int(Min,Max);	
	}
	
	
	// Generate arrows
	private function generateStaticArrows(player:Int,keys:Int = 4):Void
	{
		for (i in 0...keys)
		{
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);
			var noteTypeCheck:String = 'normal';
		
			if (PlayStateChangeables.Optimize && player == 0 || middleScroll)
			{
				continue;
			}
			if (SONG.noteStyle == null) 
			{
				noteTypeCheck = 'normal';
			}
			else 
			{
				noteTypeCheck = SONG.noteStyle;
			}


			switch (noteTypeCheck)
			{
				case 'pixel':
					babyArrow.loadGraphic(Paths.image('notes/NotesPixel','preload'), true, 17, 17);
				case 'normal':
					babyArrow.frames = Paths.getSparrowAtlas('notes/Notes', 'preload');
				case 'glitch':
					babyArrow.frames = Paths.getSparrowAtlas('notes/NotesWeird', 'preload');
			}
					
				babyArrow.animation.addByPrefix('green', 'arrowUP');
				babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
				babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
				babyArrow.animation.addByPrefix('red', 'arrowRIGHT');
				babyArrow.antialiasing = true;


				if (noteTypeCheck == "pixel")
				{
					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;
				}
				else
				{
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
				}

				
				
				switch (Math.abs(i))
				{
					// Note 1
					case 0:
						if (keyAmmount > 4)
						{
							babyArrow.x += Note.swagWidth * 0;
						}
						else
						{
							babyArrow.x += Note.swagWidth * 0;
						}
						

						babyArrow.animation.addByPrefix('static', 'arrowLEFT');
						babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
						babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);

					
					
					// Note 2
					case 1:
						if (keyAmmount > 4)
						{
							babyArrow.x += Note.swagWidth * 0.7;
						}
						else
						{
							babyArrow.x += Note.swagWidth * 1;
						}
						babyArrow.animation.addByPrefix('static', 'arrowDOWN');
						babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
						babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						
					// Note 3
					case 2:
						if (keyAmmount > 4)
						{
							babyArrow.x += Note.swagWidth * 1.4;
						}
						else
						{
							babyArrow.x += Note.swagWidth * 2;
						}
						if (keyAmmount == 6)
						{
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
						}
						else
						{
							babyArrow.animation.addByPrefix('static', 'arrowUP');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						}
					
					// Note 4
					case 3:
						if (keyAmmount > 4)
						{
							babyArrow.x += Note.swagWidth * 2.1;
						}
						else
						{
							babyArrow.x += Note.swagWidth * 3;
						}
						if (keyAmmount == 6)
							{
								babyArrow.animation.addByPrefix('static', 'arrowLEFT');
								babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
								babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
							}
							else
							{
								babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
								babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
								babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
							}
					
						case 4:
							if (keyAmmount > 4)
							{
									babyArrow.x += Note.swagWidth * 2.8;
							}
							else
							{
								babyArrow.x += Note.swagWidth * 4;
							}
							babyArrow.animation.addByPrefix('static', 'arrowDOWN');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
							
							
						case 5:
							if (keyAmmount > 4)
							{
								babyArrow.x += Note.swagWidth * 3.5;
							}
							else
							{
								babyArrow.x += Note.swagWidth * 5;
							}
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
						}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			switch (player)
			{
				case 0:
					cpuStrums.add(babyArrow);
				case 1:
					playerStrums.add(babyArrow);
			}

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);
			
			if (PlayStateChangeables.Optimize || middleScroll)
				babyArrow.x -= 275;
			
			cpuStrums.forEach(function(spr:FlxSprite)
			{					
				spr.centerOffsets(); //CPU arrows start out slightly off-center
			});

			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			#if windows
			DiscordClient.changePresence("PAUSED on " + SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), "Acc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC);
			#end
			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if windows
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), "\nAcc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses, iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), iconRPC);
			}
			#end
		}

		super.closeSubState();
	}
	

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();

		#if windows
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), "\nAcc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC);
		#end
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var nps:Int = 0;
	var maxNPS:Int = 0;
	var randomTenInt:Int = 0;

	public static var songRate = 1.5;

	public var stopUpdate = false;
	public var removedVideo = false;

	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end
		


		

		if (SONG.charFly)
		{
			dad.y += Math.sin(floatshit);	
			dad.x += Math.sin(flying);
			player3.y += Math.sin(floatshit);	
			player3.x += Math.sin(flying);
		}
		
		if(SONG.bfFly) // you see me floatin
		{
			boyfriend.y += Math.sin(floatshitbf);
		}

		#if debug
		if (FlxG.keys.justPressed.FOUR)
		{
			errorStuff();
		}
		#end

		if (SONG.song != "broken")
		{
			characteroverride = FlxG.save.data.curSkin;
		}
		
		floatshit += 0.2;
		flying += 0.05;
		floatshitbf += 0.03;
		

		if (windowShakeyShake)
		{
			moveWindow(Lib.application.window.x + FlxG.random.int( -4, 4),Lib.application.window.y + FlxG.random.int( -1, 1));
		}
		if (PlayStateChangeables.botPlay && FlxG.keys.justPressed.ONE)
			camHUD.visible = !camHUD.visible;


		if (useVideo && GlobalVideo.get() != null && !stopUpdate)
			{		
				if (GlobalVideo.get().ended && !removedVideo)
				{
					remove(videoSprite);
					FlxG.stage.window.onFocusOut.remove(focusOut);
					FlxG.stage.window.onFocusIn.remove(focusIn);
					removedVideo = true;
				}
			}
		
		#if windows
		if (executeModchart && luaModchart != null && songStarted)
		{
			luaModchart.setVar('songPos',Conductor.songPosition);
			luaModchart.setVar('hudZoom', camHUD.zoom);
			luaModchart.setVar('cameraZoom',FlxG.camera.zoom);
			luaModchart.executeState('update', [elapsed]);

			for (i in luaWiggles)
			{
				trace('wiggle le gaming');
				i.update(elapsed);
			}

			/*for (i in 0...strumLineNotes.length) {
				var member = strumLineNotes.members[i];
				member.x = luaModchart.getVar("strum" + i + "X", "float");
				member.y = luaModchart.getVar("strum" + i + "Y", "float");
				member.angle = luaModchart.getVar("strum" + i + "Angle", "float");
			}*/

			FlxG.camera.angle = luaModchart.getVar('cameraAngle', 'float');
			camHUD.angle = luaModchart.getVar('camHudAngle','float');

			if (luaModchart.getVar("showOnlyStrums",'bool'))
			{
				healthBarBG.visible = false;
				healthBar.visible = false;
				iconP1.visible = false;
				iconP2.visible = false;
				scoreTxt.visible = false;
			}
			else
			{
				healthBarBG.visible = true;
				healthBar.visible = true;
				iconP1.visible = true;
				iconP2.visible = true;
				scoreTxt.visible = true;
			}

			var p1 = luaModchart.getVar("strumLine1Visible",'bool');
			var p2 = luaModchart.getVar("strumLine2Visible",'bool');

			for (i in 0...4)
			{
				strumLineNotes.members[i].visible = p1;
				if (i <= playerStrums.length)
					playerStrums.members[i].visible = p2;
			}
		}

		#end

		// reverse iterate to remove oldest notes first and not invalidate the iteration
		// stop iteration as soon as a note is not removed
		// all notes should be kept in the correct order and this is optimal, safe to do every frame/update
		{
			var balls = notesHitArray.length-1;
			while (balls >= 0)
			{
				var cock:Date = notesHitArray[balls];
				if (cock != null && cock.getTime() + 1000 < Date.now().getTime())
					notesHitArray.remove(cock);
				else
					balls = 0;
				balls--;
			}
			nps = notesHitArray.length;
			if (nps > maxNPS)
				maxNPS = nps;
		}

		if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');
		}

		switch (curStage)
		{
			case 'philly':
				if (trainMoving && !PlayStateChangeables.Optimize)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;
		}

		super.update(elapsed);

		SpinAmount = SpinAmount + 0.0006;
		if (SONG.song == 'broken' && isGoingCrazy)
		{
			var thisX:Float =  Math.sin(SpinAmount * (SpinAmount / 2)) * 100;
			var thisY:Float =  Math.sin(SpinAmount * (SpinAmount)) * 100;
			var yVal = Std.int(windowY + thisY);
			var xVal = Std.int(windowX + thisX);
			moveWindow(xVal,yVal);
		}
	

		scoreTxt.text = Ratings.CalculateRanking(songScore,songScoreDef,nps,maxNPS,accuracy);
		scoreTxt.screenCenter(X);


		var lengthInPx = scoreTxt.textField.length * scoreTxt.frameHeight; // bad way but does more or less a better job

		scoreTxt.x = scoreTextOgX;

		if (controls.PAUSE && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}	


		if (FlxG.keys.justPressed.SEVEN)
		{
			if (useVideo)
				{
					GlobalVideo.get().stop();
					remove(videoSprite);
					FlxG.stage.window.onFocusOut.remove(focusOut);
					FlxG.stage.window.onFocusIn.remove(focusIn);
					removedVideo = true;
				}
			#if windows
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
			ChartingState.fromSongMenu = false;
			FlxG.switchState(new ChartingState());
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN,handleInput);
			#if windows
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;
		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		#if debug
		if (FlxG.keys.justPressed.SIX)
		{
			if (useVideo)
				{
					GlobalVideo.get().stop();
					remove(videoSprite);
					FlxG.stage.window.onFocusOut.remove(focusOut);
					FlxG.stage.window.onFocusIn.remove(focusIn);
					removedVideo = true;
				}

			FlxG.switchState(new AnimationDebug(SONG.player2));
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN,handleInput);
			#if windows
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}
		#end

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;
			/*@:privateAccess
			{
				FlxG.sound.music._channel.
			}*/
			songPositionBar = Conductor.songPosition;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			// Make sure Girlfriend cheers only for certain songs
			if(allowedToHeadbang)
			{
				// Don't animate GF if something else is already animating her (eg. train passing)
				if(gf.animation.curAnim.name == 'danceLeft' || gf.animation.curAnim.name == 'danceRight' || gf.animation.curAnim.name == 'idle')
				{
					// Per song treatment since some songs will only have the 'Hey' at certain times
					switch(curSong)
					{
						case 'Philly Nice':
						{
							// General duration of the song
							if(curBeat < 250)
							{
								// Beats to skip or to stop GF from cheering
								if(curBeat != 184 && curBeat != 216)
								{
									if(curBeat % 16 == 8)
									{
										// Just a garantee that it'll trigger just once
										if(!triggeredAlready)
										{
											gf.playAnim('cheer');
											triggeredAlready = true;
										}
									}else triggeredAlready = false;
								}
							}
						}
						case 'Bopeebo':
						{
							// Where it starts || where it ends
							if(curBeat > 5 && curBeat < 130)
							{
								if(curBeat % 8 == 7)
								{
									if(!triggeredAlready)
									{
										gf.playAnim('cheer');
										triggeredAlready = true;
									}
								}else triggeredAlready = false;
							}
						}
						case 'Blammed':
						{
							if(curBeat > 30 && curBeat < 190)
							{
								if(curBeat < 90 || curBeat > 128)
								{
									if(curBeat % 4 == 2)
									{
										if(!triggeredAlready)
										{
											gf.playAnim('cheer');
											triggeredAlready = true;
										}
									}else triggeredAlready = false;
								}
							}
						}
						case 'Cocoa':
						{
							if(curBeat < 170)
							{
								if(curBeat < 65 || curBeat > 130 && curBeat < 145)
								{
									if(curBeat % 16 == 15)
									{
										if(!triggeredAlready)
										{
											gf.playAnim('cheer');
											triggeredAlready = true;
										}
									}else triggeredAlready = false;
								}
							}
						}
						case 'Eggnog':
						{
							if(curBeat > 10 && curBeat != 111 && curBeat < 220)
							{
								if(curBeat % 8 == 7)
								{
									if(!triggeredAlready)
									{
										gf.playAnim('cheer');
										triggeredAlready = true;
									}
								}else triggeredAlready = false;
							}
						}
					}
				}
			}
			
			#if windows
			if (luaModchart != null)
				luaModchart.setVar("mustHit",PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			#end

			if (camFollow.x != dad.getMidpoint().x + 150 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				var offsetX = 0;
				var offsetY = 0;
				#if windows
				if (luaModchart != null)
				{
					offsetX = luaModchart.getVar("followXOffset", "float");
					offsetY = luaModchart.getVar("followYOffset", "float");
				}
				#end
				camFollow.setPosition(dad.getMidpoint().x + 150 + offsetX, dad.getMidpoint().y - 100 + offsetY);
				#if windows
				if (luaModchart != null)
					luaModchart.executeState('playerTwoTurn', []);
				#end
				// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

				switch (dad.curCharacter)
				{
					case 'mom':
						camFollow.y = dad.getMidpoint().y;
					case 'senpai':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
					case 'senpai-angry':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
				}

				if (dad.curCharacter == 'mom')
					vocals.volume = 1;
			}

			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
			{
				var offsetX = 0;
				var offsetY = 0;
				#if windows
				if (luaModchart != null)
				{
					offsetX = luaModchart.getVar("followXOffset", "float");
					offsetY = luaModchart.getVar("followYOffset", "float");
				}
				#end
				camFollow.setPosition(boyfriend.getMidpoint().x - 100 + offsetX, boyfriend.getMidpoint().y - 100 + offsetY);

				#if windows
				if (luaModchart != null)
					luaModchart.executeState('playerOneTurn', []);
				#end

				switch (curStage)
				{
					case 'limo':
						camFollow.x = boyfriend.getMidpoint().x - 300;
					case 'mall':
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'school':
						camFollow.x = boyfriend.getMidpoint().x - 200;
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'schoolEvil':
						camFollow.x = boyfriend.getMidpoint().x - 200;
						camFollow.y = boyfriend.getMidpoint().y - 200;
				}
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
				case 163:
					// FlxG.sound.music.stop();
					// FlxG.switchState(new TitleState());
			}
		}

		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
					// FlxG.sound.music.stop();
					// FlxG.switchState(new PlayState());
			}
		}

		if (health <= 0)
		{
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			#if windows
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("GAME OVER -- " + SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy),"\nAcc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC);
			#end

			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}
 		if (FlxG.save.data.resetButton)
		{
			if(controls.RESET) // thing i added
				{
					boyfriend.stunned = true;

					persistentUpdate = false;
					persistentDraw = false;
					paused = true;
		
					vocals.stop();
					FlxG.sound.music.stop();
		
					openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		
					#if windows
					// Game Over doesn't get his own variable because it's only used here
					DiscordClient.changePresence("GAME OVER -f- " + SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy),"\nAcc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC);
					#end
		
					// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				}
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 3500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
			{
				notes.forEachAlive(function(daNote:Note)
				{	

					// instead of doing stupid y > FlxG.height
					// we be men and actually calculate the time :)
					if (daNote.tooLate)
					{
						daNote.active = false;
						daNote.visible = false;
					}
					else
					{
						daNote.visible = true;
						daNote.active = true;
					}
					
					if (!daNote.modifiedByLua)
						{
							if (PlayStateChangeables.useDownscroll)
							{
								if (daNote.mustPress)
									daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y + 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed, 2));
								else
									daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed, 2));
								if(daNote.isSustainNote)
								{
									// Remember = minus makes notes go up, plus makes them go down
									if(daNote.animation.curAnim.name.endsWith('end') && daNote.prevNote != null)
										daNote.y += daNote.prevNote.height;
									else
										daNote.y += daNote.height / 2;
	
									// If not in botplay, only clip sustain notes when properly hit, botplay gets to clip it everytime
									if(!PlayStateChangeables.botPlay)
									{
										if((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit) && daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= (strumLine.y + Note.swagWidth / 2))
										{
											// Clip to strumline
											var swagRect:FlxRect;
											swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
											swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;	
											swagRect.y = daNote.frameHeight - swagRect.height;
	
											daNote.clipRect = swagRect;
										}
									}else {
										var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
										swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
										swagRect.y = daNote.frameHeight - swagRect.height;
	
										daNote.clipRect = swagRect;
									}
								}
							}else
							{
								if (daNote.mustPress)
									daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y - 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed, 2));
								else
									daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y - 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed, 2));
								if(daNote.isSustainNote)
								{
									daNote.y -= daNote.height / 2;
	
									if(!PlayStateChangeables.botPlay)
									{
										if((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit) && daNote.y + daNote.offset.y * daNote.scale.y <= (strumLine.y + Note.swagWidth / 2))
										{
											// Clip to strumline
											var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
											swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
											swagRect.height -= swagRect.y;
	
											daNote.clipRect = swagRect;
										}
									}else {
										var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
										swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
										swagRect.height -= swagRect.y;
	
										daNote.clipRect = swagRect;
									}
								}
							}
						}
		
	
					if (!daNote.mustPress && daNote.wasGoodHit)
					{
						if (SONG.song != 'Tutorial')
							camZooming = true;

						var altAnim:String = "";
	
						if (SONG.notes[Math.floor(curStep / 16)] != null)
						{
							if (SONG.notes[Math.floor(curStep / 16)].altAnim)
								altAnim = '-alt';
						}
	
						switch (Math.abs(daNote.noteData))
						{
							case 2:
								if (SONG.notes[Math.floor(curStep / 16)].player3Singing)
								{
									player3.playAnim('singUP' + altAnim, true);
								}
								else
								{
									dad.playAnim('singUP' + altAnim, true);
								}
								
							case 3:
								if (SONG.notes[Math.floor(curStep / 16)].player3Singing)
								{
									player3.playAnim('singRIGHT' + altAnim, true);
								}
								else
								{
									dad.playAnim('singRIGHT' + altAnim, true);
								}
							case 1:
								if (SONG.notes[Math.floor(curStep / 16)].player3Singing)
								{
									player3.playAnim('singDOWN' + altAnim, true);
								}
								else
								{
									dad.playAnim('singDOWN' + altAnim, true);
								}
							case 0:
								if (SONG.notes[Math.floor(curStep / 16)].player3Singing)
								{
									player3.playAnim('singLEFT' + altAnim, true);
								}
								else
								{
									dad.playAnim('singLEFT' + altAnim, true);
								}
						}
						
							cpuStrums.forEach(function(spr:FlxSprite)
							{
								if (Math.abs(daNote.noteData) == spr.ID)
								{
									spr.animation.play('confirm', true);
								}
								if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
								{
									spr.centerOffsets();
									spr.offset.x -= 13;
									spr.offset.y -= 13;
								}
								else
									spr.centerOffsets();
							});
	
						#if windows
						if (luaModchart != null)
							luaModchart.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition]);
						#end

						dad.holdTimer = 0;
						player3.holdTimer = 0;
	
						if (SONG.needsVoices)
							vocals.volume = 1;
	
						daNote.active = false;


						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}

					if (daNote.mustPress && !daNote.modifiedByLua)
					{
						daNote.visible = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].visible;
						daNote.x = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x;
						if (!daNote.isSustainNote)
							daNote.angle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
						daNote.alpha = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					}
					else if (!daNote.wasGoodHit && !daNote.modifiedByLua)
					{
						daNote.visible = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].visible;
						daNote.x = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].x;
						if (!daNote.isSustainNote)
							daNote.angle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].angle;
						daNote.alpha = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					}
					
					

					if (daNote.isSustainNote)
						daNote.x += daNote.width / 2 + 17;
					

					//trace(daNote.y);
					// WIP interpolation shit? Need to fix the pause issue
					// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));
	
					if ((daNote.mustPress && daNote.tooLate && !PlayStateChangeables.useDownscroll || daNote.mustPress && daNote.tooLate && PlayStateChangeables.useDownscroll) && daNote.mustPress)
					{	
						if (daNote.isSustainNote && daNote.wasGoodHit)
						{
							daNote.kill();
							notes.remove(daNote, true);
						}
						else
						{
							if (loadRep && daNote.isSustainNote)
							{
								// im tired and lazy this sucks I know i'm dumb
								if (findByTime(daNote.strumTime) != null)
									totalNotesHit += 1;
								else
								{
									// health -= 0.075;
									vocals.volume = 0;
									if (theFunne)
										noteMiss(daNote.noteData, daNote);
								}
							}
							else
							{
								// health -= 0.075;
								vocals.volume = 0;
								if (theFunne)
									noteMiss(daNote.noteData, daNote);
							}
						}
				
						daNote.visible = false;
						daNote.kill();
						notes.remove(daNote, true);
					}	
				});
			}


		cpuStrums.forEach(function(spr:FlxSprite)
		{
			if (spr.animation.finished)
			{
				spr.animation.play('static');
				spr.centerOffsets();
			}
		});

		if (!inCutscene)
			keyShit();


		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
	}

	function endSong():Void
	{
		if (curSong == 'holding-back')
		{
			errorStuff();
		}
		
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN,handleInput);
		if (useVideo)
			{
				GlobalVideo.get().stop();
				FlxG.stage.window.onFocusOut.remove(focusOut);
				FlxG.stage.window.onFocusIn.remove(focusIn);
				PlayState.instance.remove(PlayState.instance.videoSprite);
			}

		if (isStoryMode)
			campaignMisses = misses;

		if (!loadRep)
			rep.SaveReplay(saveNotes, saveJudge, replayAna);
		else
		{
			PlayStateChangeables.botPlay = false;
			PlayStateChangeables.scrollSpeed = 1;
			PlayStateChangeables.useDownscroll = false;
		}

		if (FlxG.save.data.fpsCap > 290)
			(cast (Lib.current.getChildAt(0), Main)).setFPSCap(290);

		#if windows
		if (luaModchart != null)
		{
			luaModchart.die();
			luaModchart = null;
		}
		#end

		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		FlxG.sound.music.pause();
		vocals.pause();
		if (SONG.validScore)
		{
			var songHighscore = StringTools.replace(PlayState.SONG.song, " ", "-");
			
			#if !switch
			Highscore.saveScore(songHighscore, Math.round(songScore), storyDifficulty);
			Highscore.saveCombo(songHighscore, Ratings.GenerateLetterRank(accuracy), storyDifficulty);
			#end
		}

		if (offsetTesting)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			offsetTesting = false;
			LoadingState.loadAndSwitchState(new OptionsMenu());
			FlxG.save.data.offset = offsetTest;
		}
		else
		{
			campaignScore += Math.round(songScore);
				
			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;
			paused = true;
			FlxG.sound.music.stop();
			vocals.stop();
			openSubState(new ResultsScreen());

			#if windows
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end

			// story LMAOOOOOOOOOOO
			if (isStoryMode)
			{
				if (storyPlaylist.length <= 0)
				{
					StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;
					FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				}
				Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
				FlxG.save.flush();
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');

				paused = true;


				FlxG.sound.music.stop();
				vocals.stop();

				if (FlxG.save.data.scoreScreen)
					openSubState(new ResultsScreen());
				else
					FlxG.switchState(new FreeplayState());
			}
		}
	}


	var endingSong:Bool = false;

	var hits:Array<Float> = [];
	var offsetTest:Float = 0;

	var timeShown = 0;
	var currentTimingShown:FlxText = null;

	private function popUpScore(daNote:Note):Void
	{
			var noteDiff:Float = -(daNote.strumTime - Conductor.songPosition);
			var wife:Float = EtternaFunctions.wife3(-noteDiff, Conductor.timeScale);
			// boyfriend.playAnim('hey');
			vocals.volume = 1;
			var placement:String = Std.string(combo);
	
			var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
			coolText.screenCenter();
			coolText.x = FlxG.width * 0.55;
			coolText.y -= 350;
			coolText.cameras = [camHUD];
			//
	
			var rating:FlxSprite = new FlxSprite();
			var score:Float = 350;

			if (FlxG.save.data.accuracyMod == 1)
				totalNotesHit += wife;

			var daRating = daNote.rating;

			switch(daRating)
			{
				case 'shit':
					score = -300;
					combo = 0;
					misses++;
					health -= 0.2;
					ss = false;
					shits++;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit -= 1;
				case 'bad':
					daRating = 'bad';
					score = 0;
					health -= 0.06;
					ss = false;
					bads++;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 0.50;
				case 'good':
					daRating = 'good';
					score = 200;
					ss = false;
					goods++;
					if (health < 2)
						health += 0.04;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 0.75;
				case 'sick':
					if (health < 2)
						health += 0.1;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 1;
					sicks++;
			}

			// trace('Wife accuracy loss: ' + wife + ' | Rating: ' + daRating + ' | Score: ' + score + ' | Weight: ' + (1 - wife));

			if (daRating != 'shit' || daRating != 'bad')
				{
	
	
			songScore += Math.round(score);
			songScoreDef += Math.round(ConvertScore.convertScore(noteDiff));
	
			/* if (combo > 60)
					daRating = 'sick';
				else if (combo > 12)
					daRating = 'good'
				else if (combo > 4)
					daRating = 'bad';
			 */
	
			var pixelShitPart1:String = "";
			var pixelShitPart2:String = '';
	
			if (curStage.startsWith('school'))
			{
				pixelShitPart1 = 'weeb/pixelUI/';
				pixelShitPart2 = '-pixel';
			}
	
			rating.loadGraphic(Paths.image("ui/" + daRating));
			rating.screenCenter();
			rating.y -= 50;
			rating.x = coolText.x - 125;
			
			if (FlxG.save.data.changedHit)
			{
				rating.x = FlxG.save.data.changedHitX;
				rating.y = FlxG.save.data.changedHitY;
			}
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);
			
			var msTiming = HelperFunctions.truncateFloat(noteDiff, 3);
			if(PlayStateChangeables.botPlay && !loadRep) msTiming = 0;		
			
			if (loadRep)
				msTiming = HelperFunctions.truncateFloat(findByTime(daNote.strumTime)[3], 3);

			if (currentTimingShown != null)
				remove(currentTimingShown);

			currentTimingShown = new FlxText(0,0,0,"0ms");
			timeShown = 0;
			switch(daRating)
			{
				case 'shit' | 'bad':
					currentTimingShown.color = FlxColor.RED;
				case 'good':
					currentTimingShown.color = FlxColor.ORANGE;
				case 'sick':
					currentTimingShown.color = FlxColor.GREEN;
			}
			currentTimingShown.borderStyle = OUTLINE;
			currentTimingShown.borderSize = 1;
			currentTimingShown.borderColor = FlxColor.BLACK;
			currentTimingShown.text = msTiming + "ms";
			currentTimingShown.size = 20;

			if (msTiming >= 0.03 && offsetTesting)
			{
				//Remove Outliers
				hits.shift();
				hits.shift();
				hits.shift();
				hits.pop();
				hits.pop();
				hits.pop();
				hits.push(msTiming);

				var total = 0.0;

				for(i in hits)
					total += i;
				

				
				offsetTest = HelperFunctions.truncateFloat(total / hits.length,2);
			}

			if (currentTimingShown.alpha != 1)
				currentTimingShown.alpha = 1;

			if(!PlayStateChangeables.botPlay || loadRep) add(currentTimingShown);
			
			var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image("ui/combo"));
			comboSpr.screenCenter();
			comboSpr.x = rating.x;
			comboSpr.y = rating.y + 100;
			comboSpr.acceleration.y = 600;
			comboSpr.velocity.y -= 150;

			currentTimingShown.screenCenter();
			currentTimingShown.x = comboSpr.x + 100;
			currentTimingShown.y = rating.y + 100;
			currentTimingShown.acceleration.y = 600;
			currentTimingShown.velocity.y -= 150;
	
			comboSpr.velocity.x += FlxG.random.int(1, 10);
			currentTimingShown.velocity.x += comboSpr.velocity.x;
			if(!PlayStateChangeables.botPlay || loadRep) add(rating);
	
			if (!curStage.startsWith('school'))
			{
				rating.setGraphicSize(Std.int(rating.width * 0.7));
				rating.antialiasing = true;
				comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
				comboSpr.antialiasing = true;
			}
			else
			{
				rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
				comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
			}
	
			currentTimingShown.updateHitbox();
			comboSpr.updateHitbox();
			rating.updateHitbox();
	
			currentTimingShown.cameras = [camHUD];
			comboSpr.cameras = [camHUD];
			rating.cameras = [camHUD];

			var seperatedScore:Array<Int> = [];
	
			var comboSplit:Array<String> = (combo + "").split('');

			if (combo > highestCombo)
				highestCombo = combo;

			// make sure we have 3 digits to display (looks weird otherwise lol)
			if (comboSplit.length == 1)
			{
				seperatedScore.push(0);
				seperatedScore.push(0);
			}
			else if (comboSplit.length == 2)
				seperatedScore.push(0);

			for(i in 0...comboSplit.length)
			{
				var str:String = comboSplit[i];
				seperatedScore.push(Std.parseInt(str));
			}
	
			var daLoop:Int = 0;
			for (i in seperatedScore)
			{
				var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image("ui/" + 'num' + Std.int(i)));
				numScore.screenCenter();
				numScore.x = rating.x + (43 * daLoop) - 50;
				numScore.y = rating.y + 100;
				numScore.cameras = [camHUD];

				if (!curStage.startsWith('school'))
				{
					numScore.antialiasing = true;
					numScore.setGraphicSize(Std.int(numScore.width * 0.5));
				}
				else
				{
					numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
				}
				numScore.updateHitbox();
	
				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);
	
				add(numScore);
	
				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						numScore.destroy();
					},
					startDelay: Conductor.crochet * 0.002
				});
	
				daLoop++;
			}
			/* 
				trace(combo);
				trace(seperatedScore);
			 */
	
			coolText.text = Std.string(seperatedScore);
			// add(coolText);
	
			FlxTween.tween(rating, {alpha: 0}, 0.2, {
				startDelay: Conductor.crochet * 0.001,
				onUpdate: function(tween:FlxTween)
				{
					if (currentTimingShown != null)
						currentTimingShown.alpha -= 0.02;
					timeShown++;
				}
			});

			FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					coolText.destroy();
					comboSpr.destroy();
					if (currentTimingShown != null && timeShown >= 20)
					{
						remove(currentTimingShown);
						currentTimingShown = null;
					}
					rating.destroy();
				},
				startDelay: Conductor.crochet * 0.001
			});
	
			curSection += 1;
			}
	}

	public function NearlyEquals(value1:Float, value2:Float, unimportantDifference:Float = 10):Bool
	{
		return Math.abs(FlxMath.roundDecimal(value1, 1) - FlxMath.roundDecimal(value2, 1)) < unimportantDifference;
	}

		var upHold:Bool = false;
		var downHold:Bool = false;
		var rightHold:Bool = false;
		var leftHold:Bool = false;	

		// THIS FUNCTION JUST FUCKS WIT HELD NOTES AND BOTPLAY/REPLAY (also gamepad shit)

		private function keyShit():Void // I've invested in emma stocks
			{
				// control arrays, order L D R U
				var holdArray:Array<Bool>;
				var pressArray:Array<Bool>;
				var releaseArray:Array<Bool>;
				
				if (keyAmmount == 4)
				{
					holdArray = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
					pressArray = [
						controls.LEFT_P,
						controls.DOWN_P,
						controls.UP_P,
						controls.RIGHT_P
					];
					releaseArray = [
						controls.LEFT_R,
						controls.DOWN_R,
						controls.UP_R,
						controls.RIGHT_R
					];
					#if windows
					if (luaModchart != null){
					if (controls.LEFT_P){luaModchart.executeState('keyPressed',["left"]);};
					if (controls.DOWN_P){luaModchart.executeState('keyPressed',["down"]);};
					if (controls.UP_P){luaModchart.executeState('keyPressed',["up"]);};
					if (controls.RIGHT_P){luaModchart.executeState('keyPressed',["right"]);};
					};
					#end
				}
				else if (keyAmmount == 6)
				{
					holdArray = 
					[
						controls.SixKeyLeft,
						controls.LEFT, 
						controls.DOWN, 
						controls.UP, 
						controls.RIGHT, 
						controls.SixKeyLeft
					];

					pressArray = 
					[
						controls.SixKeyLeft_P,
						controls.LEFT_P,
						controls.DOWN_P,
						controls.UP_P,
						controls.RIGHT_P,
						controls.SixKeyRight_P
					];

					releaseArray = 
					[
						controls.SixKeyLeft_R,
						controls.LEFT_R,
						controls.DOWN_R,
						controls.UP_R,
						controls.RIGHT_R,
						controls.SixKeyLeft_R
					];


					#if windows
					if (luaModchart != null){
					if (controls.LEFT_P){luaModchart.executeState('keyPressed',["left"]);};
					if (controls.DOWN_P){luaModchart.executeState('keyPressed',["down"]);};
					if (controls.UP_P){luaModchart.executeState('keyPressed',["up"]);};
					if (controls.RIGHT_P){luaModchart.executeState('keyPressed',["right"]);};
					if (controls.SixKeyLeft_P){luaModchart.executeState('keyPressed',["6kright"]);};
					if (controls.SixKeyRight_P){luaModchart.executeState('keyPressed',["6kright"]);};
					};
					#end
				}
				else
					{
						holdArray = 
						[
							controls.SixKeyLeft,
							controls.LEFT, 
							controls.DOWN, 
							controls.UP, 
							controls.RIGHT, 
							controls.SixKeyLeft
						];
	
						pressArray = 
						[
							controls.SixKeyLeft_P,
							controls.LEFT_P,
							controls.DOWN_P,
							controls.UP_P,
							controls.RIGHT_P,
							controls.SixKeyRight_P
						];
	
						releaseArray = 
						[
							controls.SixKeyLeft_R,
							controls.LEFT_R,
							controls.DOWN_R,
							controls.UP_R,
							controls.RIGHT_R,
							controls.SixKeyLeft_R
						];
	
	
						#if windows
						if (luaModchart != null){
						if (controls.LEFT_P){luaModchart.executeState('keyPressed',["left"]);};
						if (controls.DOWN_P){luaModchart.executeState('keyPressed',["down"]);};
						if (controls.UP_P){luaModchart.executeState('keyPressed',["up"]);};
						if (controls.RIGHT_P){luaModchart.executeState('keyPressed',["right"]);};
						if (controls.SixKeyLeft_P){luaModchart.executeState('keyPressed',["6kright"]);};
						if (controls.SixKeyRight_P){luaModchart.executeState('keyPressed',["6kright"]);};
						};
						#end
					}
				
				// Prevent player input if botplay is on
				if(PlayStateChangeables.botPlay)
				{
					holdArray = [false, false, false, false];
					pressArray = [false, false, false, false];
					releaseArray = [false, false, false, false];
				} 

				var anas:Array<Ana> = [null,null,null,null];

				for (i in 0...pressArray.length)
					if (pressArray[i])
						anas[i] = new Ana(Conductor.songPosition, null, false, "miss", i);

				// HOLDS, check for sustain notes
				if (holdArray.contains(true) && /*!boyfriend.stunned && */ generatedMusic)
				{
					notes.forEachAlive(function(daNote:Note)
					{
						if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData])
							goodNoteHit(daNote);
					});
				}
		 
				if (KeyBinds.gamepad && !FlxG.keys.justPressed.ANY)
				{
					// PRESSES, check for note hits
					if (pressArray.contains(true) && generatedMusic)
					{
						boyfriend.holdTimer = 0;
			
						var possibleNotes:Array<Note> = []; // notes that can be hit
						var directionList:Array<Int> = []; // directions that can be hit
						var dumbNotes:Array<Note> = []; // notes to kill later
						var directionsAccounted:Array<Bool> = [false,false,false,false]; // we don't want to do judgments for more than one presses
						
						notes.forEachAlive(function(daNote:Note)
							{
								if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !directionsAccounted[daNote.noteData])
								{
									if (directionList.contains(daNote.noteData))
										{
											directionsAccounted[daNote.noteData] = true;
											for (coolNote in possibleNotes)
											{
												if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
												{ // if it's the same note twice at < 10ms distance, just delete it
													// EXCEPT u cant delete it in this loop cuz it fucks with the collection lol
													dumbNotes.push(daNote);
													break;
												}
												else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
												{ // if daNote is earlier than existing note (coolNote), replace
													possibleNotes.remove(coolNote);
													possibleNotes.push(daNote);
													break;
												}
											}
										}
										else
										{
											possibleNotes.push(daNote);
											directionList.push(daNote.noteData);
										}
								}
						});

						for (note in dumbNotes)
						{
							FlxG.log.add("killing dumb ass note at " + note.strumTime);
							note.kill();
							notes.remove(note, true);
							note.destroy();
						}
			
						possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
						if (perfectMode)
							goodNoteHit(possibleNotes[0]);
						else if (possibleNotes.length > 0)
						{
							for (coolNote in possibleNotes)
							{
								if (pressArray[coolNote.noteData])
								{
									scoreTxt.color = FlxColor.WHITE;
									var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
									anas[coolNote.noteData].hit = true;
									anas[coolNote.noteData].hitJudge = Ratings.CalculateRating(noteDiff, Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));
									anas[coolNote.noteData].nearestNote = [coolNote.strumTime,coolNote.noteData,coolNote.sustainLength];
									goodNoteHit(coolNote);
								}
							}
						}
					}

					if (!loadRep)
						for (i in anas)
							if (i != null)
								replayAna.anaArray.push(i); // put em all there
				}
				notes.forEachAlive(function(daNote:Note)
				{
					if(PlayStateChangeables.useDownscroll && daNote.y > strumLine.y ||
					!PlayStateChangeables.useDownscroll && daNote.y < strumLine.y)
					{
						// Force good note hit regardless if it's too late to hit it or not as a fail safe
						if(PlayStateChangeables.botPlay && daNote.canBeHit && daNote.mustPress ||
						PlayStateChangeables.botPlay && daNote.tooLate && daNote.mustPress)
						{
							if(loadRep)
							{
								//trace('ReplayNote ' + tmpRepNote.strumtime + ' | ' + tmpRepNote.direction);
								var n = findByTime(daNote.strumTime);
								trace(n);
								if(n != null)
								{
									goodNoteHit(daNote);
									boyfriend.holdTimer = daNote.sustainLength;
								}
							}else {
								goodNoteHit(daNote);
								boyfriend.holdTimer = daNote.sustainLength;
							}
						}
					}
				});
				
				if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || PlayStateChangeables.botPlay))
				{
					if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
						boyfriend.playAnim('idle');
				}
		 
				playerStrums.forEach(function(spr:FlxSprite)
				{
					if (pressArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (!holdArray[spr.ID])
						spr.animation.play('static');
		 
					if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
					{
						spr.centerOffsets();
						spr.offset.x -= 13;
						spr.offset.y -= 13;
					}
					else
						spr.centerOffsets();
				});
			}

			public function findByTime(time:Float):Array<Dynamic>
				{
					for (i in rep.replay.songNotes)
					{
						//trace('checking ' + Math.round(i[0]) + ' against ' + Math.round(time));
						if (i[0] == time)
							return i;
					}
					return null;
				}

			public function findByTimeIndex(time:Float):Int
				{
					for (i in 0...rep.replay.songNotes.length)
					{
						//trace('checking ' + Math.round(i[0]) + ' against ' + Math.round(time));
						if (rep.replay.songNotes[i][0] == time)
							return i;
					}
					return -1;
				}

			public var fuckingVolume:Float = 1;
			public var useVideo = false;

			public static var webmHandler:WebmHandler;

			public var playingDathing = false;

			public var videoSprite:FlxSprite;

			public function focusOut() {
				if (paused)
					return;
				persistentUpdate = false;
				persistentDraw = true;
				paused = true;
		
					if (FlxG.sound.music != null)
					{
						FlxG.sound.music.pause();
						vocals.pause();
					}
		
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			}
			public function focusIn() 
			{ 
				// nada 
			}


			public function backgroundVideo(source:String) // for background videos
				{
					#if cpp
					useVideo = true;
			
					FlxG.stage.window.onFocusOut.add(focusOut);
					FlxG.stage.window.onFocusIn.add(focusIn);

					var ourSource:String = "assets/videos/daWeirdVid/dontDelete.webm";
					WebmPlayer.SKIP_STEP_LIMIT = 90;
					var str1:String = "WEBM SHIT"; 
					webmHandler = new WebmHandler();
					webmHandler.source(ourSource);
					webmHandler.makePlayer();
					webmHandler.webm.name = str1;
			
					GlobalVideo.setWebm(webmHandler);

					GlobalVideo.get().source(source);
					GlobalVideo.get().clearPause();
					if (GlobalVideo.isWebm)
					{
						GlobalVideo.get().updatePlayer();
					}
					GlobalVideo.get().show();
			
					if (GlobalVideo.isWebm)
					{
						GlobalVideo.get().restart();
					} else {
						GlobalVideo.get().play();
					}
					
					var data = webmHandler.webm.bitmapData;
			
					videoSprite = new FlxSprite(-470,-30).loadGraphic(data);
			
					videoSprite.setGraphicSize(Std.int(videoSprite.width * 1.2));
			
					remove(gf);
					remove(boyfriend);
					remove(dad);
					add(videoSprite);
					
					
					if (SONG.gfVersion != 'none')
					{
						add(gf);
					}

					add(boyfriend);
					add(dad);
			
					trace('poggers');
			
					if (!songStarted)
						webmHandler.pause();
					else
						webmHandler.resume();
					#end
				}

	function noteMiss(direction:Int = 1, daNote:Note):Void
	{
		if (!boyfriend.stunned && !FlxG.save.data.nomiss)
		{
			if (FlxG.save.data.suddendeath)// sudden death
			{
				health = 0;
			}
			else if (FlxG.save.data.ampmiss)// amplified misses
			{
				health -= 0.10;
			}
			else//default
			{
				health -= 0.04;
			}
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;
			misses++;

			if (daNote != null)
			{
				if (!loadRep)
				{
					saveNotes.push([daNote.strumTime,0,direction,166 * Math.floor((PlayState.rep.replay.sf / 60) * 1000) / 166]);
					saveJudge.push("miss");
				}
			}
			else
				if (!loadRep)
				{
					saveNotes.push([Conductor.songPosition,0,direction,166 * Math.floor((PlayState.rep.replay.sf / 60) * 1000) / 166]);
					saveJudge.push("miss");
				}

			//var noteDiff:Float = Math.abs(daNote.strumTime - Conductor.songPosition);
			//var wife:Float = EtternaFunctions.wife3(noteDiff, FlxG.save.data.etternaMode ? 1 : 1.7);

			if (FlxG.save.data.accuracyMod == 1)
				totalNotesHit -= 1;

			songScore -= 10;

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));

			switch (direction)
			{
				case 0:
					boyfriend.playAnim('singLEFTmiss', true);
				case 1:
					boyfriend.playAnim('singDOWNmiss', true);
				case 2:
					boyfriend.playAnim('singUPmiss', true);
				case 3:
					boyfriend.playAnim('singRIGHTmiss', true);
			}

			#if windows
			if (luaModchart != null)
				luaModchart.executeState('playerOneMiss', [direction, Conductor.songPosition]);
			#end


			updateAccuracy();
		}
	}

	function updateAccuracy() 
		{
			totalPlayed += 1;
			accuracy = Math.max(0,totalNotesHit / totalPlayed * 100);
			accuracyDefault = Math.max(0, totalNotesHitDefault / totalPlayed * 100);
		}


	function getKeyPresses(note:Note):Int
	{
		var possibleNotes:Array<Note> = []; // copypasted but you already know that

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
			{
				possibleNotes.push(daNote);
				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
			}
		});
		if (possibleNotes.length == 1)
			return possibleNotes.length + 1;
		return possibleNotes.length;
	}
	
	var mashing:Int = 0;
	var mashViolations:Int = 0;

	var etternaModeScore:Int = 0;

	function noteCheck(controlArray:Array<Bool>, note:Note):Void // sorry lol
		{
			var noteDiff:Float = -(note.strumTime - Conductor.songPosition);
			note.rating = Ratings.CalculateRating(noteDiff, Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));
			if (controlArray[note.noteData])
			{
				goodNoteHit(note);
			}
		}

		function goodNoteHit(note:Note):Void
			{
				var noteDiff:Float = -(note.strumTime - Conductor.songPosition);

				if(loadRep)
				{
					noteDiff = findByTime(note.strumTime)[3];
					note.rating = rep.replay.songJudgements[findByTimeIndex(note.strumTime)];
				}
				else
					note.rating = Ratings.CalculateRating(noteDiff);

				if (note.rating == "miss")
					return;	

				// add newest note to front of notesHitArray
				// the oldest notes are at the end and are removed first
				if (!note.isSustainNote)
					notesHitArray.unshift(Date.now());

				if (!note.wasGoodHit)
				{
					if (!note.isSustainNote)
					{
						popUpScore(note);
						combo += 1;
					}
					else
						totalNotesHit += 1;
	

					switch (note.noteData)
					{
						case 2:
							boyfriend.playAnim('singUP', true);
						case 3:
							boyfriend.playAnim('singRIGHT', true);
						case 1:
							boyfriend.playAnim('singDOWN', true);
						case 0:
							boyfriend.playAnim('singLEFT', true);
					}
		
					#if windows
					if (luaModchart != null)
						luaModchart.executeState('playerOneSing', [note.noteData, Conductor.songPosition]);
					#end


					if(!loadRep && note.mustPress)
					{
						var array = [note.strumTime,note.sustainLength,note.noteData,noteDiff];
						if (note.isSustainNote)
							array[1] = -1;
						saveNotes.push(array);
						saveJudge.push(note.rating);
					}
					
					playerStrums.forEach(function(spr:FlxSprite)
					{
						if (Math.abs(note.noteData) == spr.ID)
						{
							spr.animation.play('confirm', true);
						}
					});
					
					note.wasGoodHit = true;
					vocals.volume = 1;
		
					note.kill();
					notes.remove(note, true);
					note.destroy();
					
					updateAccuracy();
				}
			}
		

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		if(FlxG.save.data.distractions){
			fastCar.x = -12600;
			fastCar.y = FlxG.random.int(140, 250);
			fastCar.velocity.x = 0;
			fastCarCanDrive = true;
		}
	}

	function fastCarDrive()
	{
		if(FlxG.save.data.distractions){
			FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

			fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
			fastCarCanDrive = false;
			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				resetFastCar();
			});
		}
	}

	function windowChangeData()
	{
		new FlxTimer().start(2.3, function(tmr:FlxTimer)
		{
			Lib.application.window.title = "???";
			windowShakeyShake = true;
		});
	}
	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	var appearscreen:Bool = true;

	function trainStart():Void
	{
		if(FlxG.save.data.distractions){
			trainMoving = true;
			if (!trainSound.playing)
				trainSound.play(true);
		}
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if(FlxG.save.data.distractions){
			if (trainSound.time >= 4700)
				{
					startedMoving = true;
					gf.playAnim('hairBlow');
				}
		
				if (startedMoving)
				{
					phillyTrain.x -= 400;
		
					if (phillyTrain.x < -2000 && !trainFinishing)
					{
						phillyTrain.x = -1150;
						trainCars -= 1;
		
						if (trainCars <= 0)
							trainFinishing = true;
					}
		
					if (phillyTrain.x < -4000 && trainFinishing)
						trainReset();
				}
		}

	}

	function trainReset():Void
	{
		if(FlxG.save.data.distractions){
			gf.playAnim('hairFall');
			phillyTrain.x = FlxG.width + 200;
			trainMoving = false;
			// trainSound.stop();
			// trainSound.time = 0;
			trainCars = 8;
			trainFinishing = false;
			startedMoving = false;
		}
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	var danced:Bool = false;

	override function stepHit()
	{
		super.stepHit();

		switch (SONG.song)
		{
			case "broken":
				health - 1;
		}
 
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		#if windows
		if (executeModchart && luaModchart != null)
		{
			luaModchart.setVar('curStep',curStep);
			luaModchart.executeState('stepHit',[curStep]);
		}
		#end

		// yes this updates every step.
		// yes this is bad
		// but i'm doing it to update misses and accuracy
		#if windows
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), "Acc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC,true,  songLength - Conductor.songPosition);
		#end

	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		super.beatHit();

		

		if (curBeat == 416 && SONG.song == 'broken')
		{
			
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, (PlayStateChangeables.useDownscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));
		}
		if (curBeat == 32 && FlxG.save.data.windoweffects)
		{
			isGoingCrazy = true;
			windowX = Lib.application.window.x;
			windowY = Lib.application.window.y;
		}

		#if windows
		if (executeModchart && luaModchart != null)
		{
			luaModchart.setVar('curBeat',curBeat);
			luaModchart.executeState('beatHit',[curBeat]);
		}
		#end

		if (curSong == 'Tutorial' && dad.curCharacter == 'gf') {
			if (curBeat % 2 == 1 && dad.animOffsets.exists('danceLeft'))
				dad.playAnim('danceLeft');
			if (curBeat % 2 == 0 && dad.animOffsets.exists('danceRight'))
				dad.playAnim('danceRight');
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			if (SONG.notes[Math.floor(curStep / 16)].mustHitSection && dad.curCharacter != 'gf')
				dad.dance();
				player3.dance();
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		if (FlxG.save.data.camzoom)
		{
			// HARDCODING FOR MILF ZOOMS!
			if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}
	
			if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
				Lib.application.window.scale == Lib.application.window.scale + 10;
			}
	
		}
		
		if (curSong.toLowerCase() == 'broken')
			{
				var amount = curBeat/30;
				if (FlxG.random.bool(amount) && appearscreen)
				{
					var randomthing:FlxSprite = new FlxSprite(FlxG.random.int(300, 1077), FlxG.random.int(0, 622));
					GenerateNewValue(0,10);
					FlxG.sound.play(Paths.sound("error"), 1);
					randomthing.loadGraphic(Paths.image('ui/Errors/error' + randomTenInt));
					randomthing.updateHitbox();
					randomthing.alpha = 0;
					randomthing.antialiasing = true;
					add(randomthing);
					randomthing.cameras = [camHUD];
					appearscreen = false;
					if (storyDifficulty == 0)
					{
						FlxTween.tween(randomthing, {width: 1, alpha: 0.5}, 0.2, {ease: FlxEase.sineOut});
					}
					else
					{
						FlxTween.tween(randomthing, {width: 1, alpha: 1}, 0.2, {ease: FlxEase.sineOut});
					}
					new FlxTimer().start(1.5 , function(tmr:FlxTimer)
					{
						appearscreen = true;
					});
					new FlxTimer().start(1 , function(tmr:FlxTimer)
					{
						remove(randomthing);
					});
				}
			}
			
		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));
			
		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0)
		{
			gf.dance();
		}

		if (!boyfriend.animation.curAnim.name.startsWith("sing"))
		{
			boyfriend.playAnim('idle');
		}
		

		if (curBeat % 8 == 7 && curSong == 'Bopeebo')
		{
			boyfriend.playAnim('hey', true);
		}

		if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
			{
				boyfriend.playAnim('hey', true);
				dad.playAnim('cheer', true);
			}

		switch (curStage)
		{
			case 'school':
				if(FlxG.save.data.distractions){
					bgGirls.dance();
				}

			case 'mall':
				if(FlxG.save.data.distractions){
					upperBoppers.animation.play('bop', true);
					bottomBoppers.animation.play('bop', true);
					santa.animation.play('idle', true);
				}

			case 'limo':
				if(FlxG.save.data.distractions){
					grpLimoDancers.forEach(function(dancer:BackgroundDancer)
						{
							dancer.dance();
						});
		
						if (FlxG.random.bool(10) && fastCarCanDrive)
							fastCarDrive();
				}
			case "philly":
				if(FlxG.save.data.distractions){
					if (!trainMoving)
						trainCooldown += 1;
	
					if (curBeat % 4 == 0)
					{
						phillyCityLights.forEach(function(light:FlxSprite)
						{
							light.visible = false;
						});
	
						curLight = FlxG.random.int(0, phillyCityLights.length - 1);
	
						phillyCityLights.members[curLight].visible = true;
						// phillyCityLights.members[curLight].alpha = 1;
				}

				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					if(FlxG.save.data.distractions){
						trainCooldown = FlxG.random.int(-4, 0);
						trainStart();
					}
				}

				Lib.application.window.scale == Lib.application.window.scale - 10;
		}

		if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			if(FlxG.save.data.distractions){
				lightningStrikeShit();
			}
		}
	}

	var curLight:Int = 0;

	
	////////////////////////////////////
	// Vs Cuzsie Exclusive Functions //
	///////////////////////////////////	
	
	public function errorStuff()
	{
		if (FlxG.save.data.fourthwallbreaksoff)
		{	
			if (FlxG.fullscreen == true)
			{
				FlxG.fullscreen = !FlxG.fullscreen;
			}
			#if windows
			Application.current.window.alert("You made a mistake..","Cuzsie");
			Application.current.window.alert("I warned you from the start...","Cuzsie");
			Application.current.window.alert("Im not talking to you, boyfriend.","Cuzsie");
			
			// Excluding default windows names
			if (Sys.environment()["USERNAME"] == 'admin' || Sys.environment()["USERNAME"] == 'Administrator' || Sys.environment()["USERNAME"] == 'user')
			{
				Application.current.window.alert("Yeah, im talking to you..","Cuzsie");
			}
			else
			{
				Application.current.window.alert("Yeah, im talking to you," + Sys.environment()["USERNAME"],"Cuzsie");
			}
			Application.current.window.alert("You pushed my limits...","Cuzsie");
			Application.current.window.alert("Your going to have to pay for what you did...","Cuzsie");
			#end
			fancyOpenURL("https://drive.google.com/file/d/1e6T-lk0JL-zlh4St3N5cha8o9_gYfltX/view?usp=sharing");
		}
	}


	public function glitchSound()
	{

	}

	public function resetGlitch()
	{
	
	}
}
