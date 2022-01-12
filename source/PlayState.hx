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
import flixel.util.FlxSpriteUtil;

#if ALLOW_DISCORD_RPC
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
	var bgGirls:BackgroundDancer = new BackgroundDancer(0,0,"weeb/bgFreaks"); // The girls in the background
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
	#if ALLOW_DISCORD_RPC
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
	var transitioningToSubstate:Bool = false;
	public static var isNewTypeChart:Bool = true; // If its a new type chart (Songs are stored in "songs" and not "assets/songs" and "assets/data/") (FOR DEBUGGING)
	public static var noteBools:Array<Bool> = [false, false, false, false]; // The note bools (True or False)
	
	public static var storyWeek:Int = 0; // The current week
	public static var storyDifficulty:Int = 1; // The song difficulty (0 - Easy, 1 - Normal, 2 - Hard)
	public static var weekSong:Int = 0; // The current week song (If story)
	public static var weekScore:Int = 0; // The current week score
	public static var shits:Int = 0; // The amount of Shit rankings the player got while playing
	public static var bads:Int = 0; // The amount of Bad rankings the player got while playing
	public static var goods:Int = 0; // The amount of Good rankings the player got while playing
	public static var sicks:Int = 0; // The amount of Perfect rankings the player got while playing
	public static var marvelouses:Int = 0; // The amount of Marvelous rankings the player got while playing
	private var curSection:Int = 0; // The current section / beat
	public static var keyAmmount:Int; // The ammount of keys (4,6,etc)
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
	var fadeSprite:FlxSprite;
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
	var actualCamZoom:Float = 1.25;
	var defaultCamZoom:Float = 1.05; // The default camera zoom
	public static var daPixelZoom:Float = 6; // The zoom for pixel sprites
	public static var timeCurrently:Float = 0; // What time it is
	var SpinAmount:Float = 0; // The spinning ammount
	var windowX:Float = Lib.application.window.x; // The current window x
	var windowY:Float = Lib.application.window.y; // The current window y
	public static var timeCurrentlyR:Float = 0; // The time currently
	var songPercent:Float = 0;
	var ogZoom:Float;
	var ogAngle:Float;

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

	private var saveNotes:Array<Dynamic> = []; // The saved notes

	private var susTrail:FlxTrail; // The trail for dad
	private var susTrail3:FlxTrail; // The trail for bf
	
	public function addObject(object:FlxBasic) { add(object); } // api
	public function removeObject(object:FlxBasic) { remove(object); } // api

	override public function create()
	{
		instance = this;
		FlxG.mouse.visible = false;

		PlayStateChangeables.useDownscroll = FlxG.save.data.downScroll;
		PlayStateChangeables.safeFrames = FlxG.save.data.frames;
		PlayStateChangeables.scrollSpeed = FlxG.save.data.scrollSpeed;
		PlayStateChangeables.botPlay = FlxG.save.data.botplay;
		PlayStateChangeables.Optimize = FlxG.save.data.middleScroll;
		middleScroll = FlxG.save.data.middleScroll;

		if (FlxG.save.data.fpsCap > 290)
			(cast (Lib.current.getChildAt(0), Main)).setFPSCap(800);

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		
		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxCamera.defaultCameras = [camGame];
		
		persistentUpdate = true;
		persistentDraw = true;

		loadSong(true);

		FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / (cast (Lib.current.getChildAt(0), Main)).getFPS()));
		FlxG.camera.zoom = actualCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());
		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);
		FlxG.fixedTimestep = false;

		addUI(FlxG.save.data.songPosition);

		if (SONG.song == "broken")
		{
			fadeSprite = new FlxSprite(0,0).makeGraphic(FlxG.width * 5, FlxG.height * 5, FlxColor.BLACK);
			fadeSprite.screenCenter();
			add(fadeSprite);
		}
			
		
		startingSong = true;
		trace('Song Starting...');

		if (SONG.hasDialogue && isStoryMode)
			startDialogue(dialogueBox);

		else
			startCountdown();

		if (!loadRep)
			rep = new Replay("na");

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN,handleInput);

		super.create();
	}

	// Loading basically all the data abt the song
	function loadSong(traceData:Bool = true)
	{
		if (SONG == null) { SONG = Song.loadFromJson('tutorial', 'tutorial'); }
		if (FlxG.save.data.noteSkin == null) { FlxG.save.data.noteSkin = "Default"; }
		if (FlxG.sound.music != null) { FlxG.sound.music.stop(); }
		if (!isStoryMode) { sicks = 0; marvelouses = 0; bads = 0; shits = 0; goods = 0; }
		try {keyAmmount = SONG.keyAmmount;} catch(ex) {keyAmmount = 4;}
		
		misses = 0;
		repPresses = 0;
		repReleases = 0;
		
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
		songLowercase = Utility.songLowercase(songLowercase);
		
		removedVideo = false;

		#if ENABLE_LUA
		executeModchart = FileSystem.exists(Paths.lua(songLowercase + "/modchart"));
		if (executeModchart)
		{
			PlayStateChangeables.Optimize = false;
		}
		#end
		
		#if !cpp
		executeModchart = false;
		#end
		

		// Discord Presense
		#if ALLOW_DISCORD_RPC
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
		DiscordClient.changePresence(detailsText + " " + SONG.song,"\nAccuracy: " + HelperFunctions.truncateFloat(accuracy, 2) +  "% ( " + Ratings.GenerateLetterRank(accuracy) + " )", iconRPC);
		#end

		
		try
		{
			if(SONG.dadHasTrail)
			{
				susTrail = new FlxTrail(dad, null, 5, 7, 0.3, 0.001);
				add(susTrail);
				susTrail3 = new FlxTrail(player3, null, 5, 7, 0.3, 0.001);
				add(susTrail3);
			}
		}
		catch(x)
		{
			trace(x);
		}
		
		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);
	
		var path:String = Paths.txt("data/dialogue/" + SONG.song + "/dialogue");
		
		if (SONG.hasDialogue)
			dialogue = Utility.coolTextFile(path);

		if (traceData) 
		{
			trace
			(
				"\nGAME DATA: \n" 
				+ "\nGirlfriend: " + SONG.gfVersion 
				+ "\nSong Name: " + SONG.song
				+ "\nPlayer 1: " + SONG.player1 
				+ "\nPlayer 2: " + SONG.player2
				+ "\nPlayer 3: " + SONG.player3
				+ "\nStage: " + curStage
				
				+ "\n\nSettings Info:"

				+ "\nSafe Frames: "+ PlayStateChangeables.safeFrames 
				+ "\nSafe Zone Offset:" + Conductor.safeZoneOffset 
				+ "\nTime Scale:" + Conductor.timeScale 
				+ "\nBotPlay: " + PlayStateChangeables.botPlay 
				+ "\nCurrent Skin: " + characteroverride
				+ '\nModchart: ' + executeModchart + " - " + Paths.lua(songLowercase + "/modchart")
			);
		}
		
		createStage(stageCheck);
		generateCharacters(SONG.player1, SONG.gfVersion, SONG.player2, SONG.player3);

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		if (loadRep)
		{
			FlxG.watch.addQuick('rep rpesses',repPresses);
			FlxG.watch.addQuick('rep releases',repReleases);
			PlayStateChangeables.useDownscroll = rep.replay.isDownscroll;
			PlayStateChangeables.safeFrames = rep.replay.sf;
			PlayStateChangeables.botPlay = true;
		}

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		Conductor.songPosition = -5000;
		
		if (PlayStateChangeables.useDownscroll) { strumLine.y = FlxG.height - 165; }

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		playerStrums = new FlxTypedGroup<FlxSprite>();
		cpuStrums = new FlxTypedGroup<FlxSprite>();

		add(strumLineNotes);

		if (SONG.song == null) { FlxG.switchState(new MainMenuState()); }

		generateSong(SONG.song);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		actualCamZoom = defaultCamZoom + 0.2;
	}


		

	function addUI(songPositionBar:Bool = false)
	{
		dialogueBox = new DialogueBox(false, dialogue);
		dialogueBox.scrollFactor.set();
		dialogueBox.finishThing = startCountdown;
		
		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('ui/HealthBarBG'));
		
		if (PlayStateChangeables.useDownscroll)
			healthBarBG.y = 50;

		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);
	
		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(FlxColor.RED, FlxColor.LIME);
		add(healthBar);
	
		scoreTxt = new FlxText(0, healthBarBG.y + 36, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		add(scoreTxt);
	
		botPlayState = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0, "Auto", 20);
		botPlayState.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		botPlayState.scrollFactor.set();
		botPlayState.borderSize = 4;
		botPlayState.borderQuality = 2;
		
		if(PlayStateChangeables.botPlay && !loadRep) 
			add(botPlayState);
				
		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);
	
		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);
	
		if (songPositionBar) 
		{
			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('ui/SongPosBG'));
				
			if (PlayStateChangeables.useDownscroll)
				songPosBG.y = FlxG.height * 0.9 + 45; 
				
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);
	
			songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,'songPositionBar', 0, 90000);
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.BLACK, FlxColor.WHITE);
			add(songPosBar);
		
			var songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - (SONG.song.length * 5),songPosBG.y,0,SONG.song, 16);
			
			if (PlayStateChangeables.useDownscroll)
				songName.y -= 3;

			songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
			songName.scrollFactor.set();
			add(songName);

			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
			songName.cameras = [camHUD];
		}

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		dialogueBox.cameras = [camHUD];
		
		if (loadRep)
			replayTxt.cameras = [camHUD];
	}

	function generateCharacters(boyfriendCharacter:String = "bf", girlfriendCharacter:String = "gf", dadCharacter:String = "cuzsie", songPlayer3Character:String = "cuzsie", allowCustomizableCharacter:Bool = true)
	{
		var Cdad:String;
		var Cboyfriend:String;
		var Cgirlfriend:String;
		var Cplayer3:String;

		var defaultDad:String = "cuzsie";
		var defualtBoyfriend:String = "bf";
		var defaultGirlfriend:String = "gf";
		var defaultPlayer3:String = "cuzsie";
		
		
		// Changing stuff if the dad is the gf
		if (dadCharacter == "gf")
		{
			Cdad = girlfriendCharacter;
		}
		else
		{
			Cdad = dadCharacter;
		}

		Cboyfriend = boyfriendCharacter;
		Cgirlfriend = girlfriendCharacter;
		Cplayer3 = songPlayer3Character;
		
		
		// Boyfriend
		if (boyfriendCharacter != "none")
		{
			try
			{
				if (allowCustomizableCharacter )
				{
					boyfriend = new Boyfriend(770, 450, characteroverride);
				}
				else
				{
					boyfriend = new Boyfriend(770, 450, Cboyfriend);
				}
				
			}
			catch(ex)
			{
				trace(ex);
				boyfriend = new Boyfriend(770, 450, defualtBoyfriend);
			}
		}

		// Girlfriend
		if (girlfriendCharacter != "none")
		{
			try
			{
				gf = new Character(500, 130, Cgirlfriend);
				gf.scrollFactor.set(0.95, 0.95);
			}
			catch(ex)
			{
				trace(ex);
				gf = new Character(500, 130, defaultGirlfriend);
				gf.scrollFactor.set(0.95, 0.95);
			}	
		}
		else
		{
			gf = new Character(500, 130, defaultGirlfriend);
		}
		
		// Dad
		if (dadCharacter != "none")
		{
			try
			{
				dad = new Character(100, 100, Cdad);
			}
			catch(ex)
			{
				trace(ex);
				dad = new Character(100, 100, defaultDad);
			}
			
		}
		else
		{
			dad = new Character(100, 100, defaultDad);
		}


		// Player 3
		if(songPlayer3Character != "none")
		{
			try
			{
				player3 = new Character(dad.x - 200, 100, Cplayer3);
			}
			catch(ex)
			{
				trace(ex);
				player3 = new Character(dad.x - 200, 100, defaultPlayer3);
			}
			
		}
		else
		{
			player3 = new Character(dad.x - 200, 100, defaultPlayer3);
		}

		// Offsets
		#if sys
		if (sys.FileSystem.exists("assets/characters/" + SONG.player2))
		{
			var offsets:Array<String> = Utility.coolTextFile("assets/characters/" + SONG.player2 + "/characterOffsets.txt");
			var offsetX:Float = Std.parseFloat(offsets[0]);
			var offsetY:Float = Std.parseFloat(offsets[1]);

			dad.x += offsetX;
			dad.y += offsetY;
		}

		if (sys.FileSystem.exists("assets/characters/" + SONG.player1))
		{
			var offsets:Array<String> = Utility.coolTextFile("assets/characters/" + SONG.player1 + "/characterOffsets.txt");
			var offsetX:Float = Std.parseFloat(offsets[0]);
			var offsetY:Float = Std.parseFloat(offsets[1]);
	
			boyfriend.x += offsetX;
			boyfriend.y += offsetY;
		}
		#end

		
		add(gf);
		add(dad);
		add(boyfriend);
		add(player3);
			
		// Remove Characters if the Name is "none"
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
	

	// Stage create function (the actual data for stages is in Stage.hx [please move to a custom stage creator with json soon])
	function createStage(stagename:String)
	{
		if (SONG.stage == null) 
			stageCheck = 'default';
			
		else 
			stageCheck = SONG.stage;
		
		Stage = new Stage(SONG.stage);
		for (i in Stage.toAdd)
		{
			add(i);
		}
		defaultCamZoom = Stage.camZoom;

		actualCamZoom = defaultCamZoom + 0.2;
	}

	// The Dialogue
	function startDialogue(?dialogueBox:DialogueBox):Void
	{
		// If your tryna change the code for the dialogue box, refer to DialogueBox.hx
		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			if (dialogueBox != null)
			{
				inCutscene = true;
				add(dialogueBox);
			}
			else
			{
				startCountdown(); 
			}
		});
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;
	var luaWiggles:Array<WiggleEffect> = [];
	#if ENABLE_LUA
	public static var luaModchart:ModchartState = null;
	#end

	function moveWindow(x:Int,y:Int)
	{
		if (FlxG.save.data.windoweffects)
		{
			Lib.application.window.move(x,y);
		}
	}
	
	function startCountdown():Void
	{
		inCutscene = false;

		generateStrumline(0);
		generateStrumline(1);

		#if ENABLE_LUA
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
		
		if (executeModchart)
		{
			luaModchart = ModchartState.createModchartState("modchart", null);
			luaModchart.executeState('start',[songLowercase]);
		}

		trace("Modchart executed!");
		#end

		talking = false;
		startedCountdown = true;
		
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dad.dance();
			gf.dance();
			player3.dance();
			boyfriend.playAnim('idle');

			var introAssets:Array<String> = ["ui/Two", "ui/One", "ui/GetIt"];

			switch (swagCounter)
			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3' + SONG.readySetStyle), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite();
					ready.loadGraphic(Paths.image(introAssets[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();
					ready.screenCenter();
					add(ready);

					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween){ready.destroy();}});
					FlxG.sound.play(Paths.sound('intro2' + SONG.readySetStyle), 0.6);

				case 2:
					var set:FlxSprite = new FlxSprite();
					set.loadGraphic(Paths.image(introAssets[1]));
					set.scrollFactor.set();
					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween){set.destroy();}});
					FlxG.sound.play(Paths.sound('intro1' + SONG.readySetStyle), 0.6);
					
				case 3:
					var go:FlxSprite = new FlxSprite();
					go.loadGraphic(Paths.image(introAssets[2]));
					go.scrollFactor.set();
					go.updateHitbox();
					go.screenCenter();
					add(go);
					
					FlxTween.tween(go, {y: go.y += 120, alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween){go.destroy();}});
					FlxG.sound.play(Paths.sound('introGo' + SONG.readySetStyle), 0.6);
				case 4:
			}

			swagCounter += 1;
		}, 5);

		ogZoom = camGame.zoom;
		ogAngle = camGame.angle;
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	private function getKey(charCode:Int):String
	{
		for (key => value in FlxKey.fromStringMap)
		{
			if (charCode == value)
				return key;
		}
		return null;
	}

	private function handleInput(evt:KeyboardEvent):Void 
	{
		if (PlayStateChangeables.botPlay || loadRep || paused)
			return;

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
					case D:
						data = 1;
					case F:
						data = 2;
					case J:
						data = 3;
					case K:
						data = 4;
					case L:
						data =  5;
				}
			case 5:
				binds = [FlxG.save.data.sixLeftBind,FlxG.save.data.leftBind,FlxG.save.data.downBind, FlxG.save.data.upBind, FlxG.save.data.rightBind,FlxG.save.data.sixRightBind];
				switch(evt.keyCode)
				{
					case D:
						data = 0;
					case F:
						data = 1;
					case SPACE:
						data = 2;
					case J:
						data = 3;
					case K:
						data = 4;
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
		
		
		
		startingSong = false;
		songStarted = true;
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.onComplete = endSong;
		
		vocals.play();
		songLength = FlxG.sound.music.length;

		if (FlxG.save.data.songPosition)
		{
			remove(songPosBG);
			remove(songPosBar);
			remove(songName);

			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('ui/SongPosBG'));
			if (PlayStateChangeables.useDownscroll)
			{
				songPosBG.y = FlxG.height * 0.9 + 45; 
			}
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);

			songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,'songPositionBar', 0, songLength - 1000);
			songPosBar.numDivisions = 1000;
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.BLACK, FlxColor.WHITE);
			add(songPosBar);

			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
		}
		
		if (useVideo)
		{
			GlobalVideo.get().resume();
		}
		
		#if ALLOW_DISCORD_RPC
		DiscordClient.changePresence(detailsText + " " + SONG.song,"\nAccuracy: " + HelperFunctions.truncateFloat(accuracy, 2) +  "% ( " + Ratings.GenerateLetterRank(accuracy) + " )", iconRPC);
		#end
	}
	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{		
		var songData = SONG;

		Conductor.changeBPM(songData.bpm);
		curSong = songData.song;

		if (SONG.needsVoices)
		{
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		}
		else
		{
			vocals = new FlxSound();
		}
		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);
		
		var noteData:Array<SwagSection>;
		noteData = songData.notes;
		
		var playerCounter:Int = 0;

		#if windows
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
		var songPath:String;

		// Hey future cuzsie! If your ever gonna change the song path again, FOR THE LOVE OF GOD REMEMBER TO CHANGE THIS
		songPath = 'assets/songs/' + songLowercase + '/';
	
		for(file in sys.FileSystem.readDirectory(songPath))
		{
			var path = haxe.io.Path.join([songPath, file]);
			if(!sys.FileSystem.isDirectory(path))
			{
				if(path.endsWith('.offset'))
				{
					trace('Found offset file: ' + path);
					songOffset = Std.parseFloat(file.substring(0, file.indexOf('.off')));
					break;
				}
				else 
				{
					trace('Offset file not found. Creating one @: ' + songPath);
					sys.io.File.saveContent(songPath + songOffset + '.offset', '');
				}
			}
		}
		#end
		
		var daBeats:Int = 0;
		
		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / keyAmmount);

			for (songNotes in section.sectionNotes)
			{
				if (songNotes.isCustomNote)
				{
					songNotes.customNoteData.setVar('health',1);
				}
				
				var daStrumTime:Float = songNotes[0] + FlxG.save.data.offset + songOffset;

				if (daStrumTime < 0)
				{
					daStrumTime = 0;
				}
				var daNoteData:Int;
				daNoteData = Std.int(songNotes[1] % keyAmmount);

				var gottaHitNote:Bool = section.mustHitSection;
				var iFarted:Int = keyAmmount - 1;

				if (songNotes[1] > iFarted)
				{
					gottaHitNote = !section.mustHitSection;
				}
				
				var oldNote:Note;
		
				if (unspawnNotes.length > 0)
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				}
				else
				{
					oldNote = null;
				}
				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);

				if (!gottaHitNote && PlayStateChangeables.Optimize)
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
						sustainNote.x += FlxG.width / 2;
					}
				}
				
				swagNote.mustPress = gottaHitNote;
			}
			
			daBeats += 1;
		}
		
		unspawnNotes.sort(sortByShit);
		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	public function GenerateNewValue(Min:Int, Max:Int) 
	{
		randomTenInt = FlxG.random.int(Min,Max);
	}
	
	private function generateStrumline(player:Int = 0):Void
	{
		for (i in 0...keyAmmount)
		{
			var staticArrow:FlxSprite = new FlxSprite(0, strumLine.y);

			staticArrow.frames = Paths.getSparrowAtlas('notes/Notes_' + FlxG.save.data.noteSkin, 'preload');
			staticArrow.animation.addByPrefix('green', 'Up Static');
			staticArrow.animation.addByPrefix('blue', 'Down Static');
			staticArrow.animation.addByPrefix('purple', 'Left Static');
			staticArrow.animation.addByPrefix('red', 'RightStatic');
			staticArrow.animation.addByPrefix('static', NoteData.staticKeyAnimations[keyAmmount][i] + " Static");
			staticArrow.animation.addByPrefix('pressed', NoteData.staticKeyAnimations[keyAmmount][i] + ' Pressed', 24, false);
			staticArrow.animation.addByPrefix('confirm', NoteData.staticKeyAnimations[keyAmmount][i] + " Pressed", 24, false);
			staticArrow.antialiasing = true;
			staticArrow.setGraphicSize(Std.int(staticArrow.width * NoteData.sizes[keyAmmount]));
			staticArrow.scrollFactor.set();
			staticArrow.x += Note.swagWidth * NoteData.widths[keyAmmount] * i;
			staticArrow.updateHitbox();
			staticArrow.y -= 10;
			staticArrow.alpha = 0;
			staticArrow.ID = i;
				
			FlxTween.tween(staticArrow, {y: staticArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.cubeInOut, startDelay: 0.5 + (0.2 * i)});

			switch (player)
			{
				case 0:
					cpuStrums.add(staticArrow);
				case 1:
					playerStrums.add(staticArrow);
			}

			var overrideWidth:Float = switch(player) 
			{
				case 1: // Position for Player One (BF)
					(FlxG.width / 1.45) - 200; 
				case 0: // Position for Player Two (Dad);
					(FlxG.width / 1.45) - 1100; 
				default: 
					(FlxG.width / 1.45) - 1100;
			};
			
			staticArrow.animation.play('static');
			staticArrow.x += overrideWidth;

			if (PlayStateChangeables.Optimize && player == 0) {staticArrow.alpha = 0;}
			if (PlayStateChangeables.Optimize || middleScroll) {staticArrow.x -= 275;}

			strumLineNotes.add(staticArrow);
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
			transitioningToSubstate = true;
			
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			#if ALLOW_DISCORD_RPC
			DiscordClient.changePresence(detailsText + " " + SONG.song,"\nAccuracy: " + HelperFunctions.truncateFloat(accuracy, 2) +  "% ( " + Ratings.GenerateLetterRank(accuracy) + " )", iconRPC);
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
			transitioningToSubstate = false;
			
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if ALLOW_DISCORD_RPC
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText + " " + SONG.song,"\nAccuracy: " + HelperFunctions.truncateFloat(accuracy, 2) +  "% ( " + Ratings.GenerateLetterRank(accuracy) + " )", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText + " " + SONG.song,"\nAccuracy: " + HelperFunctions.truncateFloat(accuracy, 2) +  "% ( " + Ratings.GenerateLetterRank(accuracy) + " )", iconRPC);
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

		#if ALLOW_DISCORD_RPC
		DiscordClient.changePresence(detailsText + " " + SONG.song,"\nAccuracy: " + HelperFunctions.truncateFloat(accuracy, 2) +  "% ( " + Ratings.GenerateLetterRank(accuracy) + " )", iconRPC);
		#end
	}

	public static var songRate = 1.5;
	public var stopUpdate = false;
	public var removedVideo = false;
	public var centeredNoteFuck:Bool = false;
	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var nps:Int = 0;
	var maxNPS:Int = 0;
	var randomTenInt:Int = 0;

	function endLua()
	{
		#if ENABLE_LUA
		if (luaModchart != null)
		{
			luaModchart.die();
			luaModchart = null;
		}
		#end
	}

	override public function update(elapsed:Float)
	{
		/////////////
		// Hotkeys //
		/////////////
		
		// Video Test
		if (FlxG.keys.justPressed.FIVE)
		{
			startVideo("omgSimpleVideoCodeReal"); // this is a test please remove at a later time
		}

		// Animation Debug
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
			
			#if ENABLE_LUA endLua(); #end
		}
		#end

		// Chart Editor
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
				
			editors.ChartingState.fromSongMenu = false;
			GlobalData.latestDiff = storyDifficulty;
			FlxG.switchState(new editors.ChartingState());
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN,handleInput);
				
			#if ENABLE_LUA endLua(); #end
		}
		
		
		
		
		
		
		
		if (SONG.charFly)
		{
			dad.y += Math.sin(floatshit);	
			player3.y += Math.sin(floatshit);	
		}
		
		if(SONG.bfFly)
		{
			boyfriend.y += Math.sin(floatshitbf);
		}

		characteroverride = FlxG.save.data.curSkin;
		floatshit += 0.2;
		flying += 0.05;
		floatshitbf += 0.03;

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
		
		#if ENABLE_LUA
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

		super.update(elapsed);

		// Move Window stuff for broken
		SpinAmount = SpinAmount + 0.0006;
		if (SONG.song == 'broken' && isGoingCrazy)
		{
			var thisX:Float =  Math.sin(SpinAmount * (SpinAmount / 2)) * 100;
			var thisY:Float =  Math.sin(SpinAmount * (SpinAmount)) * 100;
			var yVal = Std.int(windowY + thisY);
			var xVal = Std.int(windowX + thisX);
			moveWindow(xVal,yVal);
		}

		// scoreTxt.text = Ratings.CalculateRanking(songScore,songScoreDef,nps,maxNPS,accuracy);
		scoreTxt.text = "Score: " + songScore + " | Misses: " + misses + " | Accuracy: " + HelperFunctions.truncateFloat(accuracy, 2) + " %"+ "(" + Ratings.GenerateLetterRank(accuracy) + ") | Combo (" + combo + ")";
		scoreTxt.x = healthBarBG.x;

		var lengthInPx = scoreTxt.textField.length * scoreTxt.frameHeight;
		scoreTxt.x = scoreTextOgX;

		if (controls.PAUSE && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}	


		var iconOffset:Int = 26;
		
		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP1.updateHitbox();
		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);

		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));
		iconP2.updateHitbox();
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
			Conductor.songPosition += FlxG.elapsed * 1000;
			songPositionBar = Conductor.songPosition;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
				}
			}
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (camFollow.x != dad.getMidpoint().x + 150 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				var offsetX = 0;
				var offsetY = 0;
				
				camFollow.setPosition(dad.getMidpoint().x + 150 + offsetX, dad.getMidpoint().y - 100 + offsetY);
			}

			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
			{
				var offsetX = 0;
				var offsetY = 0;

				camFollow.setPosition(boyfriend.getMidpoint().x - 100 + offsetX, boyfriend.getMidpoint().y - 100 + offsetY);
			}
		}
		
		moveNotes();

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(actualCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (health <= 0)
		{
			gameOver();
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
		cpuStrums.forEach(function(spr:FlxSprite)
		{
			if (spr.animation.finished)
			{
				spr.animation.play('static');
				// spr.centerOffsets();
			}
		});

		if (!inCutscene)
			keyShit();
	}

	function moveNotes()
	{
		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{	
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
	
							if(!PlayStateChangeables.botPlay)
							{
								if((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit) && daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= (strumLine.y + Note.swagWidth / 2))
								{
									var swagRect:FlxRect;
									swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
									swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;	
									swagRect.y = daNote.frameHeight - swagRect.height;
	
									daNote.clipRect = swagRect;
									daNote.x += 20;
								}
							}
							else 
							{
								var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
								swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;
	
								daNote.clipRect = swagRect;
								daNote.x += 20;
							}
						}
					}
					else
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
									var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
									swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
									swagRect.height -= swagRect.y;
	
									daNote.clipRect = swagRect;

									daNote.x += 20;
								}
							}
							else 
							{
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;
	
								daNote.clipRect = swagRect;
								daNote.x += 20;
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
	
					try
					{
						switch (Math.abs(daNote.noteData))
						{
							case 2:
								if (SONG.notes[Math.floor(curStep / 16)].player3Singing)
									player3.playAnim('singUP' + altAnim, true);
								
								else
									dad.playAnim('singUP' + altAnim, true);
										
							case 3:
								if (SONG.notes[Math.floor(curStep / 16)].player3Singing)
									player3.playAnim('singRIGHT' + altAnim, true);
								else
									dad.playAnim('singRIGHT' + altAnim, true);

							case 1:
								if (SONG.notes[Math.floor(curStep / 16)].player3Singing)	
									player3.playAnim('singDOWN' + altAnim, true);
								else
									dad.playAnim('singDOWN' + altAnim, true);

							case 0:
								if (SONG.notes[Math.floor(curStep / 16)].player3Singing)
									player3.playAnim('singLEFT' + altAnim, true);
										
								else
									dad.playAnim('singLEFT' + altAnim, true);
						}
					}
					catch(ex)
					{
						trace(ex);
						switch (Math.abs(daNote.noteData))
						{
							case 2:
								dad.playAnim('singUP' + altAnim, true);
							case 3:
								dad.playAnim('singRIGHT' + altAnim, true);
							case 1:
								dad.playAnim('singDOWN' + altAnim, true);
							case 0:
								dad.playAnim('singLEFT' + altAnim, true);
						}
					}
						
						
					cpuStrums.forEach(function(spr:FlxSprite)
					{
						if (Math.abs(daNote.noteData) == spr.ID)
						{
							spr.animation.play('confirm', true);
						}
					});
	
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
							if (findByTime(daNote.strumTime) != null)
								totalNotesHit += 1;
							else
							{
								vocals.volume = 0;
								
								if (theFunne)
									noteMiss(daNote.noteData, daNote);
							}
						}
						else
						{
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
	}
	function gameOver() // end his life
	{
		if (transitioningToSubstate) // fixes that bug where you can softlock your game by dying and going to the chart editor at the same time
		{
			boyfriend.stunned = true;
			persistentUpdate = false;
			persistentDraw = false;
			paused = true;
			
			vocals.stop();
			FlxG.sound.music.stop();
	
			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}
	}

	function endSong():Void
	{
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

		#if ENABLE_LUA
		endLua();
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

			campaignScore += Math.round(songScore);
				
			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;
			paused = true;
			FlxG.sound.music.stop();
			vocals.stop();
			openSubState(new ResultsScreen());

			#if ENABLE_LUA
			endLua();
			#end

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
				trace('Going back to Freeplay');

				paused = true;
				FlxG.sound.music.stop();
				vocals.stop();
				
				FlxG.switchState(new FreeplayState());
			}
	}
 
	var endingSong:Bool = false;
	var hits:Array<Float> = [];
	var offsetTest:Float = 0;
	var timeShown = 0;
	var currentTimingShown:FlxText = null;

	private function popUpScore(daNote:Note):Void
	{
		var score:Float = 350;
		var daRating = daNote.rating;
		var seperatedScore:Array<Int> = [];
		var daLoop:Int = 0;

		switch(daRating)
		{
			case 'shit':
				songScore = -300;
				combo = 0;
				misses++;
				health -= 0.2;
				ss = false;
				shits++;

			case 'bad':
				daRating = 'bad';
				health -= 0.06;
				ss = false;
				bads++;

			case 'good':
				daRating = 'good';
				songScore + 200;
				ss = false;
				goods++;
				totalNotesHit += 0.5;	
					
				if (health < 2)
					health += 0.04;

				case 'sick':
					songScore + 250;	
					
					if (health < 2)
						health += 0.1;

					totalNotesHit += 1;	
					sicks++;

				case 'marvelous':
					songScore + 300;
					
					if (health < 2)
						health += 0.2;

					totalNotesHit += 1;	
					marvelouses++;
			}

			songScore += Math.round(score);

			var rating:FlxSprite = new FlxSprite();
			rating.loadGraphic(Paths.image("ui/" + daRating));
			rating.setGraphicSize(Std.int(rating.width * 1.1));
			rating.updateHitbox();
			rating.y -= 50;
			rating.cameras = [camHUD];
			rating.screenCenter();
			add(rating);

			if (combo > highestCombo)
				highestCombo = combo;

			FlxTween.tween(rating, {alpha: 0}, 0.2);
			curSection += 1;
	}

	public function NearlyEquals(value1:Float, value2:Float, unimportantDifference:Float = 10):Bool
	{
		return Math.abs(FlxMath.roundDecimal(value1, 1) - FlxMath.roundDecimal(value2, 1)) < unimportantDifference;
	}

	var upHold:Bool = false;
	var downHold:Bool = false;
	var rightHold:Bool = false;
	var leftHold:Bool = false;	


	private function keyShit():Void
	{
		var holdArray:Array<Bool>;
		var pressArray:Array<Bool>;
		var releaseArray:Array<Bool>;

		switch (keyAmmount)
		{
			default:
				holdArray = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
				pressArray = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];		
				releaseArray = [controls.LEFT_R, controls.DOWN_R, controls.UP_R, controls.RIGHT_R];
			case 4:
				holdArray = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
				pressArray = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];		
				releaseArray = [controls.LEFT_R, controls.DOWN_R, controls.UP_R, controls.RIGHT_R];
			case 5:
				holdArray = [controls.LEFT, controls.DOWN, controls.MIDDLE, controls.UP, controls.RIGHT ];
				pressArray = [controls.LEFT_P, controls.DOWN_P, controls.MIDDLE_P, controls.UP_P, controls.RIGHT_P,];
				releaseArray = [controls.LEFT_R, controls.DOWN_R ,controls.MIDDLE_R, controls.UP_R, controls.RIGHT_R];
			case 6:
				holdArray = [controls.SixKeyLeft, controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT, controls.SixKeyLeft];
				pressArray = [controls.SixKeyLeft_P, controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P, controls.SixKeyRight_P];
				releaseArray = [controls.SixKeyLeft_R, controls.LEFT_R, controls.DOWN_R, controls.UP_R, controls.RIGHT_R, controls.SixKeyLeft_R];
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

				if (holdArray.contains(true) && generatedMusic)
				{
					notes.forEachAlive(function(daNote:Note)
					{
						try
						{
							if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData])
								goodNoteHit(daNote);
						}
						catch(e)
						{
							trace(e);
						}
					});
				}
		 
				if (KeyBinds.gamepad && !FlxG.keys.justPressed.ANY)
				{
					if (pressArray.contains(true) && generatedMusic)
					{
						boyfriend.holdTimer = 0;
			
						var possibleNotes:Array<Note> = [];
						var directionList:Array<Int> = [];
						var dumbNotes:Array<Note> = [];
						var directionsAccounted:Array<Bool> = [false,false,false,false];
						
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
										{
											dumbNotes.push(daNote);
											break;
										}
										else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
										{
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
							FlxG.log.add("Killing note at " + note.strumTime);
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
								replayAna.anaArray.push(i);
				}
				notes.forEachAlive(function(daNote:Note)
				{
					if(PlayStateChangeables.useDownscroll && daNote.y > strumLine.y ||
					!PlayStateChangeables.useDownscroll && daNote.y < strumLine.y)
					{
						if(PlayStateChangeables.botPlay && daNote.canBeHit && daNote.mustPress ||
						PlayStateChangeables.botPlay && daNote.tooLate && daNote.mustPress)
						{
							if(loadRep)
							{
								var n = findByTime(daNote.strumTime);
								trace(n);
								if(n != null)
								{
									goodNoteHit(daNote);
									boyfriend.holdTimer = daNote.sustainLength;
								}
							}
							else 
							{
								goodNoteHit(daNote);
								playerStrums.forEach(function(spr:FlxSprite)
								{
									if (PlayStateChangeables.botPlay)
										spr.animation.play('pressed');
								});
					
								
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
				});
			}

			public function findByTime(time:Float):Array<Dynamic>
				{
					for (i in rep.replay.songNotes)
					{
						if (i[0] == time)
							return i;
					}
					return null;
				}

			public function findByTimeIndex(time:Float):Int
				{
					for (i in 0...rep.replay.songNotes.length)
					{
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
			
			public function focusIn() // why does this exist help
			{ 
				trace("Game Regained Focus.");
			}


			public function backgroundVideo(source:String)
			{
				// silly little kade engine always making things complicated

				
			}
			public function startVideo(name:String):Void 
			{
				var foundFile:Bool = false;
				var fileName:String = Paths.video(name);
				
				#if sys
				if(FileSystem.exists(fileName)) 
				#else
				if(OpenFlAssets.exists(fileName)) 
				#end
				{
					foundFile = true;
				}
		
				if(foundFile) 
				{
					var bg = new FlxSprite(-FlxG.width, -FlxG.height).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					bg.scrollFactor.set();
					bg.cameras = [camHUD];
					add(bg);
		
					(new FlxVideo(fileName)).finishCallback = function() 
					{
						trace("omg this is actually gonna work");
						remove(bg);
					}
					return;
				} 
				else 
				{
					FlxG.log.warn('Couldnt find video file: ' + fileName);
				}
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

			#if ENABLE_LUA
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

				if (note.isCustomNote)
				{
					note.customNoteData.executeState('goodNoteHit',[goods]);
				}


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
		
					// Botplay Note Hit Animation
					playerStrums.forEach(function(spr:FlxSprite)
					{
						if (Math.abs(note.noteData) == spr.ID && PlayStateChangeables.botPlay)
							spr.animation.play('confirm', true);
					});


					#if ENABLE_LUA
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

	function lightningStrike():Void
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

		// Broken events
		if (SONG.song == "broken")
		{
			switch (curStep)
			{
				case 64:
					FlxSpriteUtil.fadeOut(fadeSprite,5,null);
			}
		}

		switch (SONG.song)
		{
			case "broken":
			if (curStep > 64)	
				health = health - 0.01;
		}
 
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		#if ENABLE_LUA
		if (executeModchart && luaModchart != null)
		{
			luaModchart.setVar('curStep',curStep);
			luaModchart.executeState('stepHit',[curStep]);
		}
		#end

		// yes this updates every step.
		// yes this is bad
		// but i'm doing it to update misses and accuracy
		#if ALLOW_DISCORD_RPC
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText + " " + SONG.song,"\nAccuracy: " + HelperFunctions.truncateFloat(accuracy, 2) +  "% ( " + Ratings.GenerateLetterRank(accuracy) + " )", iconRPC, true, songLength - Conductor.songPosition);
		#end

	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;
	var startCoolZooms:Bool = false;
	var zoomLeft = true;

	override function beatHit()
	{
		super.beatHit();

		if(SONG.song == "blocked-modchart")
		{
			switch(curBeat)
			{
				case 63:
					startCoolZooms = true;
				case 124:
					FlxG.camera.fade(FlxColor.BLACK, 1, false);				
				case 128:
					startCoolZooms = false;
			}
		}

		if (startCoolZooms)
		{
			switch(zoomLeft)
			{
				case true:
					FlxTween.tween(camGame, {zoom: 2}, 0.1, {ease: FlxEase.cubeInOut});
					FlxTween.tween(camGame, {angle: 25}, 0.1, {ease: FlxEase.cubeInOut});

					new FlxTimer().start(0.1 , function(tmr:FlxTimer)
					{
						FlxTween.tween(camGame, {zoom: ogZoom}, 0.05, {ease: FlxEase.expoIn});
						FlxTween.tween(camGame, {angle: ogAngle}, 0.05, {ease: FlxEase.expoIn});
					});
					
					zoomLeft = false;
				case false:
					FlxTween.tween(camGame, {zoom: 2}, 0.1, {ease: FlxEase.cubeInOut});
					FlxTween.tween(camGame, {angle: -25}, 0.1, {ease: FlxEase.cubeInOut});
				
					new FlxTimer().start(0.1 , function(tmr:FlxTimer)
					{
						FlxTween.tween(camGame, {zoom: ogZoom}, 0.05, {ease: FlxEase.expoIn});
						FlxTween.tween(camGame, {angle: ogAngle}, 0.05, {ease: FlxEase.expoIn});
					});
					zoomLeft = true;
			}
		}


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

		#if ENABLE_LUA
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
				lightningStrike();
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
			if (Sys.environment()["USERNAME"] == 'admin' || Sys.environment()["USERNAME"] == 'Administrator' || Sys.environment()["USERNAME"] == 'user' || Sys.environment()["USERNAME"] == 'Owner')
			{
				Application.current.window.alert("Yeah, im talking to you..","Cuzsie");
			}
			else
			{
				Application.current.window.alert("Yeah, im talking to you," + Sys.environment()["USERNAME"],"Cuzsie");
			}
			Application.current.window.alert("You pushed my limits...","Cuzsie");
			Application.current.window.alert("Your going to have to pay for what you did...","Cuzsie");
			Application.current.window.alert("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nhelp","Cuzsie");
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
	
	public function setHealth(set:Int)
	{
		health = set;
	}
	public function getHealth():Float
	{
		return health;
	}
}