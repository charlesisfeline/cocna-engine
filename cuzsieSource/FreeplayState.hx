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

#if windows
import Discord.DiscordClient;
#end

using StringTools;

class FreeplayState extends MusicBeatState
{
	public static var songs:Array<SongMetadata> = [];
	public static var catagories:Array<String> = [];
	public static var catagorySongs:Array<Array<SongMetadata>> = [];
	public var group:Array<Dynamic> = [];
	var initSonglist:Array<String> = [];

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
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	public static var openedPreview = false;

	public static var songData:Map<String,Array<SwagSong>> = [];

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var followTarget:FlxObject;
	var prevCamFollow:FlxObject;

	var checkeredBackground:FlxBackdrop;

	public static function loadDiff(diff:Int, format:String, name:String, array:Array<SwagSong>)
	{
		try 
		{
			var fart = Utility.difficultyArray[diff];
			
			array.push(Song.loadFromJson(name,fart.toLowerCase()));
		}
		catch(ex)
		{
			trace("Error: " + ex);
		}
	}

	override function create()
	{		
		persistentUpdate = true;
		songData = [];
		songs = [];

		#if windows
		DiscordClient.changePresence("Selecting a Song", null);
		Lib.application.window.title = GlobalData.globalWindowTitle + " - In the song menu";
		#end

		loadTracks();

		for (i in 0...songs.length)
		{
			var isSongAndNotCatagory:Bool = false;
			
			for(diff in Utility.difficultyArray)
			{
				if (!sys.FileSystem.exists("assets/songs/" + songs[i] + '/$diff.funkin'))
				{
					isSongAndNotCatagory = true;
				}
			}


			if (!isSongAndNotCatagory)
			{
				trace("catagory found: " + songs[i].songName);
				catagories.push(songs[i].songName);
				songs.remove(songs[i]);
			}
		}

		var ui_tex = Paths.getSparrowAtlas('ui/CampaignAssets');

		bg = new FlxSprite().loadGraphic(Paths.image('ui/Backgrounds/BackgroundFreeplay', 'preload'));
		bg.scrollFactor.set();

		checkeredBackground = new FlxBackdrop(Paths.image('ui/checkeredBG', "preload"), 0.2, 0.2, true, true);
		checkeredBackground.scrollFactor.set();

		followTarget = new FlxObject(0, 0, 1, 1);
		followTarget.setPosition(FlxG.camera.x + 850, FlxG.camera.y);
		if (prevCamFollow != null)
		{
			followTarget = prevCamFollow;
			prevCamFollow = null;
		}
		FlxG.camera.follow(followTarget, LOCKON, 5000);
		FlxG.camera.focusOn(followTarget.getPosition());


		grpSongs = new Array<Array<FlxObject>>();

		var loadedSongs:Int = 0;
		var loadedCatagories:Int = 0;
	
		for (i in 0...catagories.length)
		{			
			loadTracks("assets/songs/" + catagories[i] + "/", true, loadedCatagories);

			var elements:Array<FlxObject> = [];
				
			var songBG:FlxSprite = new FlxSprite(0,i * 250).loadGraphic(Paths.image("ui/songBG", "preload"));
			songBG.screenCenter(X);
			songBG.x + 140;
			songBG.setGraphicSize(1000,200);
			songBG.updateHitbox();
			songBG.color = FlxColor.GRAY;

			var songSelector:FlxSprite = new FlxSprite(0,i * 250).loadGraphic(Paths.image("ui/songBG", "preload"));
			songSelector.screenCenter(X);
			songSelector.x + 140;
			songSelector.setGraphicSize(920,220);
			songSelector.updateHitbox();
			songSelector.color = FlxColor.GRAY;
	
			var songText:FlxText = new FlxText(230, songBG.y + 40, 0, catagories[i], 40);
			songText.setFormat(null,40,FlxColor.BLACK);
			songBG.screenCenter(X);
				
			elements.push(songSelector);
			elements.push(songBG);
			elements.push(songText);
	
			grpSongs.push(elements);
	
			loadedSongs++;
			loadedCatagories++;
		}


		for (i in 0...catagorySongs.length)
		{			
			for (songs in 0...catagorySongs[i].length)
			{
				var elements:Array<FlxObject> = [];
				
				var songBG:FlxSprite = new FlxSprite(0,i * 250).loadGraphic(Paths.image("ui/songBG", "preload"));
				songBG.screenCenter(X);
				songBG.x + 140;
				songBG.setGraphicSize(900,200);
				songBG.updateHitbox();
				songBG.color = FlxColor.GRAY;
		
				var songSelector:FlxSprite = new FlxSprite(0,i * 250).loadGraphic(Paths.image("ui/songBG", "preload"));
				songSelector.screenCenter(X);
				songSelector.x + 140;
				songSelector.setGraphicSize(920,220);
				songSelector.updateHitbox();
				songSelector.color = FlxColor.GRAY;
		
				var songText:FlxText = new FlxText(230, songBG.y + 40, 0, catagorySongs[i][songs].songName, 40);
				songText.setFormat(null,40,FlxColor.BLACK);
				songBG.screenCenter(X);
		
		
				var icon:FlxSprite = new FlxSprite(songText.x + 600, songText.y + 5).loadGraphic("assets/songs/" + catagorySongs[i][songs].songName.toLowerCase() + "/icon.png");
				icon.setGraphicSize(150,150);
				icon.updateHitbox();
					
				elements.push(songSelector);
				elements.push(songBG);
				elements.push(songText);
				elements.push(icon);
		
				grpSongs.push(elements);
		
				loadedSongs++;
			}
		}
		
		
		
		for (i in 0...songs.length)
		{			
			var elements:Array<FlxObject> = [];
			
			var songBG:FlxSprite = new FlxSprite(0,i * 250).loadGraphic(Paths.image("ui/songBG", "preload"));
			songBG.screenCenter(X);
			songBG.x + 140;
			songBG.setGraphicSize(900,200);
			songBG.updateHitbox();
			songBG.color = FlxColor.GRAY;

			var songSelector:FlxSprite = new FlxSprite(0,i * 250).loadGraphic(Paths.image("ui/songBG", "preload"));
			songSelector.screenCenter(X);
			songSelector.x + 140;
			songSelector.setGraphicSize(920,220);
			songSelector.updateHitbox();
			songSelector.color = FlxColor.GRAY;

			var songText:FlxText = new FlxText(230, songBG.y + 40, 0, songs[i].songName, 40);
			songText.setFormat(null,40,FlxColor.BLACK);
			songBG.screenCenter(X);


			var icon:FlxSprite = new FlxSprite(songText.x + 600, songText.y + 5).loadGraphic("assets/songs/" + songs[i].songName.toLowerCase() + "/icon.png");
			icon.setGraphicSize(150,150);
			icon.updateHitbox();
			
			elements.push(songSelector);
			elements.push(songBG);
			elements.push(songText);
			elements.push(icon);

			grpSongs.push(elements);

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

		difficultySelectors = new FlxGroup();

		leftArrow = new FlxSprite(-500,500);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');

		sprDifficulty = new FlxSprite(leftArrow.x + 130, leftArrow.y);
		sprDifficulty.frames = ui_tex;
		sprDifficulty.animation.addByPrefix('easy', 'EASY');
		sprDifficulty.animation.addByPrefix('normal', 'NORMAL');
		sprDifficulty.animation.addByPrefix('hard', 'HARD');
		sprDifficulty.animation.play('easy');

		rightArrow = new FlxSprite(sprDifficulty.x + sprDifficulty.width + 50, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');

		add(bg);
		add(checkeredBackground);
		add(followTarget);
		add(scoreBG);
		add(diffText);
		add(instruct);
		add(comboText);
		add(scoreText);
		add(difficultySelectors);
		difficultySelectors.add(leftArrow);
		difficultySelectors.add(sprDifficulty);
		difficultySelectors.add(rightArrow);
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

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['dad'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		checkeredBackground.x -= 0.45 / (100 / 60);
		checkeredBackground.y -= 0.16 / (100 / 60);

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "PERSONAL BEST:" + lerpScore;
		comboText.text = combo + '\n';

		if (FlxG.sound.music.volume > 0.8)
		{
			FlxG.sound.music.volume -= 0.5 * FlxG.elapsed;
		}

		var upP = FlxG.keys.justPressed.UP;
		var downP = FlxG.keys.justPressed.DOWN;
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

		if (upP)
		{
			changeSelection(-1, "up");
		}
		if (downP)
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

		if (accepted)
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

		switch (currentDifficulty)
		{
			case 0:
				sprDifficulty.animation.play('easy');
				sprDifficulty.offset.x = 20;
			case 1:
				sprDifficulty.animation.play('normal');
				sprDifficulty.offset.x = 70;
			case 2:
				sprDifficulty.animation.play('hard');
				sprDifficulty.offset.x = 70;
			case 3:
				sprDifficulty.animation.play('insane');
				sprDifficulty.offset.x = 70;
			case 4:
				sprDifficulty.animation.play('expert');
				sprDifficulty.offset.x = 70;
		}

		sprDifficulty.alpha = 0;
		sprDifficulty.y = leftArrow.y - 15;

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
		var songHighscore = StringTools.replace(songs[currentSelected].songName, " ", "-");
		songHighscore = Utility.songLowercase(songHighscore);
		var bullShit:Int = 0;
		var selectorToRemove:Int;
		
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		currentSelected += change;

		FlxG.sound.playMusic(Paths.inst(songs[currentSelected].songName));
		

		if (currentSelected < 0)
			currentSelected = songs.length - 1;
		if (currentSelected >= songs.length)
			currentSelected = 0;

		followTarget.y = grpSongs[currentSelected][0].y + 100; // ig just like put the pos of camera on the first element in the objs (prob the bg)
		

		try 
		{
			bg.color = Stage.getStageColors(songData.get(songs[currentSelected].songName)[currentDifficulty].stage);
		}
		catch(ex)
		{
			// no
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
