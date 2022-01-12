package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.Lib;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxObject;

	var stageSuffix:String = "";
	var isHall:Bool = false;

	public function new(x:Float, y:Float)
	{
		var daStage = PlayState.curStage;
		var daBf:String = '';

		Lib.application.window.title = GlobalData.globalWindowTitle + " - GAME OVER";

		FlxG.mouse.visible = true;


		if (PlayState.SONG.song == 'halucination')
		{
			isHall = true;
			Lib.application.window.title = "Wake up...";
		}
		
		switch (PlayState.SONG.song)
		{
			case 'bf-pixel':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel-dead';
			case 'bf-dark':
				daBf = 'bf-dark';
			default:
				daBf = 'bf';
		}

		super();

		Conductor.songPosition = 0;

		bf = new Boyfriend(x, y, daBf);
	
		if (!isHall)
		{
			add(bf);
		}

		camFollow = new FlxObject(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y, 1, 1);
		add(camFollow);

		if (!isHall)
		{
			FlxG.sound.play(Paths.sound('fnf_loss_sfx' + stageSuffix));
		}
		else
		{
			FlxG.sound.play(Paths.music('week1EndingGameOver' + stageSuffix, 'shared'));
		}
		Conductor.changeBPM(100);

		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');
		waitTime();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		
		if (!isHall)
		{
			if (controls.ACCEPT)
			{
				endBullshit();
				Lib.application.window.title = GlobalData.globalWindowTitle;
			}
		
			if (controls.BACK)
			{
				FlxG.sound.music.stop();
		
				Lib.application.window.title = GlobalData.globalWindowTitle;
					
				if (PlayState.isStoryMode)
					FlxG.switchState(new StoryMenuState());
				else
					FlxG.switchState(new FreeplayState());
				PlayState.loadRep = false;
			}
		}
		

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
		{
			FlxG.camera.follow(camFollow, LOCKON, 0.01);
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished && !isHall)
		{
			if (PlayState.SONG.song == "broken")
			{
				FlxG.sound.playMusic(Paths.music('gameOverCreepy'));
			}
			else
			{
				FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix));
			}
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	override function beatHit()
	{
		super.beatHit();

		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	
	
	// VS Cuzsie Function //
	function waitTime()
	{
		new FlxTimer().start(15.5, function(tmr:FlxTimer)
		{
			trace("finale time :))))))");
			LoadingState.loadAndSwitchState(new Week1FinaleCutscene());
		});
	}
	
	
	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			switch (PlayState.SONG.song)
			{
				case 'broken':
					FlxG.sound.play(Paths.music('gameOverEndCreepy'));
				default:
					FlxG.sound.play(Paths.music('gameOverEnd' + stageSuffix));
			}
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					LoadingState.loadAndSwitchState(new PlayState());
				});
			});
		}
	}
}
