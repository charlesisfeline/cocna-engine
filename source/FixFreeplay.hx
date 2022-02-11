/*package;

import flixel.FlxG;
import flixel.text.FlxText;
#if sys
import sys.FileSystem;
import sys.io.File;
#end

class FixFreeplay extends menus.BaseListMenu
{
    var scoreText:FlxText;
    var diffText:FlxText;
    var instructionText:FlxText;
    var comboText:FlxText;
    var currentDifficulty:Int = 0;
    
    override function create()
    {
        includeIcons = false;
        itemList = sys.FileSystem.readDirectory("songs");
        lastState = new MainMenuState();

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

		add(scoreBG);
		add(diffText);
		add(instruct);
		add(comboText);
		add(scoreText);

        changeDiff();

        super.create();
    }

    override function update(elapsed:Float)
    {
        if (FlxG.keys.justPressed.LEFT)
			changeDiff(-1);
		if (FlxG.keys.justPressed.RIGHT)
			changeDiff(1);

        super.update(elapsed);
    }


    override function onPress()
    {
        select();
        
        super.onPress();
    }



    function select()
    {
        var songFormat = StringTools.replace(itemList[curSelected], " ", "-");		
        //var difficulty = /*Utility.difficultyArray[currentDifficulty]"normal";
        var songRef;
    
        songFormat = Utility.songLowercase(songFormat);	
        songRef = Song.loadFromJson(itemList[curSelected],difficulty.toLowerCase());
    
        if (Song == null)
        {
            FlxG.sound.play(Paths.sound('cancelMenu'), 0.4);
            trace("ERROR: Song returned null");
            return;
        }
        else if (Song != null)
        {
            PlayState.SONG = songRef;
            PlayState.isStoryMode = false;
            PlayState.storyDifficulty = 1;
            PlayState.storyWeek = 1;
            trace('Current Week: ' + PlayState.storyWeek);
            LoadingState.loadAndSwitchState(new PlayState());
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
}*/