package;
#if html
import js.html.FileSystem;
#end
import openfl.utils.Future;
import openfl.media.Sound;
import flixel.system.FlxSound;
#if sys
import sys.FileSystem;
import sys.io.File;
#end
import Song.SwagSong;
import flixel.input.gamepad.FlxGamepad;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import openfl.Lib;
import flixel.FlxBasic;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxStringUtil;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

#if windows
import Discord.DiscordClient;
#end

using StringTools;

enum Sort{ Name; Week; ChartAuthor; SongArtist; }

class FreeplayState extends MusicBeatState{

	public static var songs:Array<SongMetadata> = [];
	public static var catagories:Array<String> = [];
	public static var catagorySongs:Array<Array<SongMetadata>> = [];
	public var group:Array<Dynamic> = [];
	var initSonglist:Array<String> = [];
	var sortOrder:Sort = Sort.Week;

	public static var currentSelected:Int = 0;
	public static var currentDifficulty:Int = 1;

	public static var rate:Float = 1.0;

	var scoreText:FlxText;
	var comboText:FlxText;
	var diffText:FlxText;
	var instruct:FlxText;
	var previewtext:FlxText;

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	var combo:String = '';
	
	var bg:FlxSprite;

	
	private var grpSongs:Array<Array<FlxObject>>;
	private var grpBackgrounds:Array<FlxSprite>;

	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	public static var openedPreview = false;

	public static var songData:Map<String,Array<SwagSong>> = [];

	var followTarget:FlxObject;
	var prevCamFollow:FlxObject;

	public static function loadDiff(diff:Int, format:String, name:String, array:Array<SwagSong>) {
		try 
		{
			var fart = Utility.difficultyArray[diff];
			
			array.push(Song.loadFromJson(name,fart.toLowerCase()));
		}

		catch(ex){trace(ex);}
	}

	override function create(){

		persistentUpdate = true;
		songData = [];
		songs = [];
		grpBackgrounds = [];

		#if windows
		DiscordClient.changePresence("Selecting a Song", null);
		Lib.application.window.title = GlobalData.globalWindowTitle + " - In the song menu";
		#end

		loadTracks();

		var ui_tex = Paths.getSparrowAtlas('ui/CampaignAssets');

		bg = new FlxSprite().loadGraphic(Paths.image('ui/Backgrounds/FunkinBG', 'preload'));
		bg.scrollFactor.set();
		bg.setGraphicSize(1920,1080);
		bg.color = 0xFFFDE871;
		bg.screenCenter();
	
		followTarget = new FlxObject(0, 0, 1, 1);
		followTarget.setPosition(FlxG.camera.x + 850, FlxG.camera.y);

		if (prevCamFollow != null){
			followTarget = prevCamFollow;
			prevCamFollow = null;
		}

		FlxG.camera.follow(followTarget, LOCKON, 0.1 * (50 / (cast (Lib.current.getChildAt(0), Main)).getFPS()));
		FlxG.camera.focusOn(followTarget.getPosition());

		grpSongs = new Array<Array<FlxObject>>();
		var loadedSongs:Int = 0;
		

		for (i in 0...songs.length) 
		{			
			createPanel(songs[i].songName, "", i, true, songs[i]);

			loadedSongs++;
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		scoreText.scrollFactor.set();

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35), 105, 0xFF000000);
		scoreBG.alpha = 0.6;
		scoreBG.scrollFactor.set();


		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		diffText.scrollFactor.set();

		instruct = new FlxText(scoreText.x, scoreText.y + 650, 0, "Left click to play\nRight click to edit", 24);
		instruct.font = scoreText.font;
		instruct.scrollFactor.set();

		comboText = new FlxText(diffText.x + 100, diffText.y, 0, "", 24);
		comboText.font = diffText.font;
		comboText.scrollFactor.set();

		add(bg);
		add(followTarget);
		add(scoreBG);
		add(diffText);
		add(instruct);
		add(comboText);
		add(scoreText);
		for(groups in grpSongs)
		{
			for (item in groups)
			{
				add(item);
			}
		}

		changeSelection();
		changeDiff();

		super.create();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter));
	}

	var overSomething:Bool = false;
	
	function createPanel(title:String, info:String, targetX:Float, isSong:Bool, song:SongMetadata)
	{
		var elements:Array<FlxObject> = []; // All of the elements to show on your custom song panel		
		var songInfo:String = info; // The text to show on the info panel

		if (isSong)
		{
			var funkySong:FlxSound = new FlxSound().loadEmbedded(Paths.inst(title)); // The song for this panel (this isnt used for playing the actual song, dont edit this)
			songInfo += "" + FlxStringUtil.formatTime(funkySong.length / 1000, false); 
		}

		var songBG:FlxSprite = new FlxSprite(-290,targetX * 250).loadGraphic(Paths.image("ui/songBG", "preload")); // The background for the song panel
		songBG.setGraphicSize(900,200);
		songBG.updateHitbox();
		songBG.color = FlxColor.GRAY;

		var songText:FlxText = new FlxText(-30, songBG.y + 40, 0, title, 20); // The text to show the current song for this panel (EG: Bopeebo)
		songText.setFormat(Paths.font("vcr.ttf"), 35);
		songText.color = FlxColor.BLACK;

		var songInfo:FlxText = new FlxText(350, songBG.y + 70, 0, songInfo, 13); // The info text to show stuff like song duration
		songInfo.setFormat(Paths.font("vcr.ttf"),15);
		songInfo.color = FlxColor.BLACK;

		var icon:FlxSprite = new FlxSprite(songText.x + 600, songText.y + -10).loadGraphic("assets/songs/" + title + "/icon.png"); // The icon next to the song name
		icon.setGraphicSize(150,150);
		icon.updateHitbox();
			
		elements.push(songBG);
		grpBackgrounds.push(songBG);
		elements.push(songText);
		elements.push(songInfo);
		elements.push(icon);
		grpSongs.push(elements);
	}
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		for (item in 0...grpSongs.length)
		{
			if (FlxG.mouse.overlaps(grpSongs[item][0]) && FlxG.mouse.justPressed && item != currentSelected)
			{
				currentSelected = item;
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
				FlxG.sound.playMusic(Paths.inst(songs[currentSelected].songName));
				followTarget.y = grpSongs[currentSelected][0].y + 100;
			}
		}

		// check for the thishdishihdhsdiiadhsihlasdjfhaskldjfhlasdjkhflasjkfhasdjklf
		for (item in 0...grpSongs.length)
		{
			if (FlxG.mouse.overlaps(grpSongs[item][0]) && FlxG.mouse.justPressed && item != currentSelected)
			{
				overSomething = true;
			}
			else
			{
				overSomething = false;
			}
		}

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "PERSONAL BEST:" + lerpScore;
		comboText.text = combo + '\n';

		if (FlxG.sound.music.volume > 0.8)
		{
			FlxG.sound.music.volume -= 0.5 * FlxG.elapsed;
		}

		var accepted = FlxG.mouse.pressed;
		var right = FlxG.mouse.pressedRight;

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{

			if (gamepad.justPressed.DPAD_UP)
			{
				changeSelection(-1);
			}
			if (gamepad.justPressed.DPAD_DOWN)
			{
				changeSelection(1);
			}
			if (gamepad.justPressed.DPAD_LEFT)
			{
				changeDiff(-1);
			}
			if (gamepad.justPressed.DPAD_RIGHT)
			{
				changeDiff(1);
			}
		}

		if (FlxG.mouse.wheel == 1)
		{
			changeSelection(-1, "up");
		}
		if (FlxG.mouse.wheel == -1)
		{
			changeSelection(1, "down");
		}



		if (FlxG.keys.justPressed.LEFT)
			changeDiff(-1);
		if (FlxG.keys.justPressed.RIGHT)
			changeDiff(1);

		if (controls.BACK)
		{
			Lib.application.window.title = GlobalData.globalWindowTitle;
			FlxG.switchState(new MainMenuState());
		}

		if (accepted && !overSomething) // This prevents the ability to click something without it selecting it
		{
			if (songs[currentSelected].songName == "create new song")
			{
				trace("Song Creation Selected");
				FlxG.switchState(new NewSongState());
			}
			else
			{
				var songFormat = StringTools.replace(songs[currentSelected].songName, " ", "-");
				songFormat = Utility.songLowercase(songFormat);
				
				var songRef;
				try
				{
					var fart = Utility.difficultyArray[currentDifficulty];
					songRef = Song.loadFromJson(songs[currentSelected].songName,fart.toLowerCase()); // 
					if (Song == null)
					{
						FlxG.sound.play(Paths.sound('cancelMenu'), 0.4);
						trace("ERROR: Song returned null");
						return;
					}
						
				}
				catch(ex)
				{
					FlxG.sound.play(Paths.sound('cancelMenu'), 0.4);
					trace("ERROR: Song returned null");
					return;
				}


				PlayState.SONG = songRef;
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = currentDifficulty;
				PlayState.storyWeek = songs[currentSelected].week;
				trace('Current Week: ' + PlayState.storyWeek);
				LoadingState.loadAndSwitchState(new PlayState());
			}
		}

		if (right)
		{
			// adjusting the song name to be compatible
			var songFormat = StringTools.replace(songs[currentSelected].songName, " ", "-");
			songFormat = Utility.songLowercase(songFormat);

			try
			{
				var hmm = songData.get(songs[currentSelected].songName)[currentDifficulty];
				GlobalData.latestDiff = currentDifficulty;
				PlayState.SONG = hmm;
				editors.ChartingState.fromSongMenu = true;
				FlxG.switchState(new editors.ChartingState());
			}
			catch(ex)
			{
				Disclamer(currentDifficulty);
				trace("You screwed up gg bro: " + ex);
			}
		}
	}

	function changeDiff(change:Int = 0)
	{
		currentDifficulty += change;

		if (currentDifficulty < 0)
			currentDifficulty = 4;
		if (currentDifficulty > 4)
			currentDifficulty = 0;
		
		GlobalData.latestDiff = currentDifficulty;

		// adjusting the highscore song name to be compatible (changeDiff)
		var songHighscore = StringTools.replace(songs[currentSelected].songName, " ", "-");
		songHighscore = Utility.songLowercase(songHighscore);
		
		#if !switch
		intendedScore = Highscore.getScore(songHighscore, currentDifficulty);
		combo = Highscore.getCombo(songHighscore, currentDifficulty);
		#end
		diffText.text = Utility.difficultyFromInt(currentDifficulty).toUpperCase();
	}

	function changeSelection(change:Int = 0, direction:String = "down")
	{
		currentSelected += change;

		if (currentSelected <= 0) // if the current selected is less than 0
			currentSelected = songs.length; // set it to the max it can go

		if (currentSelected >= songs.length) // if current selecteds i bigger or equal to the max it can go
			currentSelected = 0; // set it to 0
		
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		FlxG.sound.playMusic(Paths.inst(songs[currentSelected].songName));

		followTarget.y = grpSongs[currentSelected][0].y + 100; // ig just like put the pos of camera on the first element in the objs (prob the bg)
		
		for (i in 0...grpSongs.length)
		{
			if (i == currentSelected)
				grpBackgrounds[i].color = FlxColor.WHITE;

			else
				grpBackgrounds[i].color = FlxColor.GRAY;
		}
	}


	function loadTracks(overrideP:String = "none", stupidOtherArray:Bool = false, stupidInt:Int = 0)
	{
		switch(overrideP)
		{
			case "none":
				#if sys
				initSonglist = sys.FileSystem.readDirectory("assets/songs");//Utility.coolTextFile(Paths.txt('data/freeplaySonglist'));
				#else
				initSonglist = Utility.coolTextFile(Paths.txt('data/freeplaySonglist'));
				#end
			default:
				#if sys
				initSonglist = sys.FileSystem.readDirectory(overrideP);//Utility.coolTextFile(Paths.txt('data/freeplaySonglist'));
				#else
				initSonglist = Utility.coolTextFile(Paths.txt(overrideP));
				#end	
		}

		for (i in 0...initSonglist.length)
		{
			var data:Array<String> = initSonglist[i].split(':');
			var meta = new SongMetadata(data[0], Std.parseInt(data[2]), data[1]);

			if (stupidOtherArray)
			{
				catagorySongs[stupidInt].push(meta);
			}
			else
			{
				songs.push(meta);
			}
		
			trace(meta);
			
			var format = StringTools.replace(meta.songName, " ", "-");
			format = Utility.songLowercase(format);

			var diffs = [];
			FreeplayState.loadDiff(0,format,meta.songName,diffs); // Easy
			FreeplayState.loadDiff(1,format,meta.songName,diffs); // Normal
			FreeplayState.loadDiff(2,format,meta.songName,diffs); // Hard
			FreeplayState.loadDiff(3,format,meta.songName,diffs); // Insane
			FreeplayState.loadDiff(4,format,meta.songName,diffs); // Expert
			FreeplayState.songData.set(meta.songName,diffs);
			
			trace('Difficulties Loaded for ' + meta.songName);
		}
	}

	var disclamerText:FlxText;

	public function Disclamer(difficulty:Int) 
	{
		var uhhDiff:String = Utility.difficultyFromInt(difficulty);
		
		disclamerText = new FlxText(0,0,0,'Difficulty $uhhDiff for song doesnt seem to have a valid chart\nWould you like to create a new one?\n\nENTER: Continue\nESCAPE: Back',15);
		disclamerText.screenCenter();
		add(disclamerText);
	}

	public function RemoveDisclamer() 
	{
		remove(disclamerText);
	}
}
