package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;
	var curCharacter:String = '';
	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];
	var swagDialogue:FlxTypeText;
	public var finishThing:Void->Void;
	var portraitLeft:FlxSprite;
	var portraitRight:FlxSprite;
	var portraitMiddle:FlxSprite;
	var handSelect:FlxSprite;
	var bgFade:FlxSprite;
	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>, musicOverride:Bool = false, music:String = null)
	{
		super();


		
		this.dialogueList = dialogueList;

		// Music Changeable stuff
		if (!musicOverride)
		{
			switch (PlayState.SONG.song.toLowerCase())
			{
				case 'broken':
					FlxG.sound.playMusic(Paths.sound('creep_bg'), 0);
					FlxG.sound.music.fadeIn(1, 0, 0.5);
				default:
					FlxG.sound.playMusic(Paths.music('dialogueMain'), 0);
					FlxG.sound.music.fadeIn(1, 0, 0.8);
			}
		}
		else
		{
			FlxG.sound.playMusic(Paths.sound(music), 0);
		}

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		add(bgFade);

		new FlxTimer().start(0.2, function(tmr:FlxTimer)
		{
					bgFade.alpha = .5;
					bgFade.alpha += (.05);
					if (bgFade.alpha > 0.7)
					bgFade.alpha = 0.7;
		}, 5);
		
		var hasDialog = true;
		if (!hasDialog)
		{
			return;
		}

		box = new FlxSprite(0, 0);
		box.frames = Paths.getSparrowAtlas('ui/DialogueBox');
		box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
		box.animation.addByIndices('normal', 'Text Box Appear', [4], "", 24);
		box.animation.play('normalOpen');
		box.setGraphicSize(Std.int(box.width * 1));
		box.updateHitbox();
		
		portraitLeft = new FlxSprite(0, 160);
		portraitLeft.frames = Paths.getSparrowAtlas('portraits/Cuzsie');
		portraitLeft.animation.addByPrefix('enter', 'Senpai Portrait Enter', 24, false);
		portraitLeft.setGraphicSize(Std.int(portraitLeft.width * 1));
		portraitLeft.updateHitbox();
		portraitLeft.scrollFactor.set();

		portraitRight = new FlxSprite(700, 145);
		portraitRight.frames = Paths.getSparrowAtlas('portraits/Boyfriend');
		portraitRight.animation.addByPrefix('enter', 'Boyfriend portrait enter', 24, false);
		portraitRight.setGraphicSize(Std.int(portraitRight.width * 1));
		portraitRight.updateHitbox();
		portraitRight.scrollFactor.set();
		
		portraitMiddle = new FlxSprite(350, 90);
		portraitMiddle.frames = Paths.getSparrowAtlas('portraits/Girlfriend');
		portraitMiddle.animation.addByPrefix('enter', 'Girlfriend portrait enter', 24, false);
		portraitMiddle.setGraphicSize(Std.int(portraitRight.width * 1));
		portraitMiddle.updateHitbox();
		portraitMiddle.scrollFactor.set();


		swagDialogue = new FlxTypeText(182, 497, Std.int(FlxG.width * 1), "", 30);
		swagDialogue.font = Paths.font("opensans.ttf");
		swagDialogue.color = FlxColor.BLACK;
		swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];

		add(portraitLeft);
		add(portraitRight);
		add(portraitMiddle);
		add(box);
		add(swagDialogue);

		portraitLeft.visible = false;
		portraitRight.visible = false;
		portraitMiddle.visible = false;

		box.screenCenter(X);
		
		dialogue = new Alphabet(0, 20, "", false, true);
	}

	override function update(elapsed:Float)
	{
		if (box.animation.curAnim != null)
		{
			if (box.animation.curAnim.name == 'normalOpen' && box.animation.curAnim.finished)
			{
				box.animation.play('normal');
				dialogueOpened = true;
			}
		}

		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}

		if (FlxG.keys.justPressed.ANY  && dialogueStarted == true)
		{
			remove(dialogue);
				
			FlxG.sound.play(Paths.sound('clickText'), 0.8);

			if (dialogueList[1] == null && dialogueList[0] != null)
			{
				if (!isEnding)
				{
					isEnding = true;
					FlxG.sound.music.stop();

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						box.alpha -= 1 / 10;
						bgFade.alpha -= 1 / 10 * 0.7;
						portraitLeft.visible = false;
						portraitRight.visible = false;
						portraitMiddle.visible = false;
						swagDialogue.alpha -= 1 / 10;
					}, 5);

					new FlxTimer().start(.5, function(tmr:FlxTimer)
					{
						finishThing();
						kill();
					});
				}
			}
			else
			{
				dialogueList.remove(dialogueList[0]);
				startDialogue();
			}
		}
		
		super.update(elapsed);
	}

	var isEnding:Bool = false;

	function startDialogue():Void
	{
		cleanDialog();

		swagDialogue.resetText(dialogueList[0]);
		swagDialogue.start(0.04, true);

		switch (curCharacter)
		{
			case 'cuzsie':
				portraitRight.visible = false;
				portraitMiddle.visible = false;
				portraitLeft.frames = Paths.getSparrowAtlas('portraits/Cuzsie', "preload");
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('DialogueSounds/cuzsie'), 0.6)];
				if (!portraitLeft.visible)
				{
					portraitLeft.visible = true;
					portraitLeft.animation.play('enter');
				}


			case 'bf':
				portraitLeft.visible = false;
				portraitMiddle.visible = false;
				portraitRight.frames = Paths.getSparrowAtlas('portraits/Boyfriend', "preload");
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('DialogueSounds/bf'), 0.6)];
				if (!portraitRight.visible)
				{
					portraitRight.visible = true;
					portraitRight.animation.play('enter');
				}
			
			
			case 'bf-bep':
				portraitLeft.visible = false;
				portraitMiddle.visible = false;
				portraitRight.frames = Paths.getSparrowAtlas('portraits/BoyfriendBep', "preload");
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('DialogueSounds/bf'), 0.6)];
				if (!portraitRight.visible)
				{
					portraitRight.visible = true;
					portraitRight.animation.play('enter');
				}
			

			case 'bf-smug':
				portraitLeft.visible = false;
				portraitMiddle.visible = false;
				portraitRight.frames = Paths.getSparrowAtlas('portraits/BoyfriendSmug', "preload");
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('DialogueSounds/bf'), 0.6)];
				if (!portraitRight.visible)
				{
					portraitRight.visible = true;
					portraitRight.animation.play('enter');
				}

			case 'bf-bruh':
				portraitLeft.visible = false;
				portraitMiddle.visible = false;
				portraitRight.frames = Paths.getSparrowAtlas('portraits/BoyfriendBruh', "preload");
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('DialogueSounds/bf'), 0.6)];
				if (!portraitRight.visible)
				{
					portraitRight.visible = true;
					portraitRight.animation.play('enter');
				}
			
			case 'bf-shocked':
				portraitLeft.visible = false;
				portraitMiddle.visible = false;
				portraitRight.frames = Paths.getSparrowAtlas('portraits/BoyfriendShock', "preload");
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('DialogueSounds/bf'), 0.6)];
				if (!portraitRight.visible)
				{
					portraitRight.visible = true;
					portraitRight.animation.play('enter');
				}
			
			case 'gf':
				portraitLeft.visible = false;
				portraitRight.visible = false;
				portraitMiddle.frames = Paths.getSparrowAtlas('portraits/Girlfriend', "preload");
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('DialogueSounds/gf'), 0.6)];
				if (!portraitMiddle.visible)
				{
					portraitMiddle.visible = true;
					portraitMiddle.animation.play('enter');
				}


			case 'gf-bruh':
				portraitLeft.visible = false;
				portraitRight.visible = false;
				portraitMiddle.frames = Paths.getSparrowAtlas('portraits/GirlfriendBruh', "preload");
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('DialogueSounds/gf'), 0.6)];
				if (!portraitMiddle.visible)
				{
					portraitMiddle.visible = true;
					portraitMiddle.animation.play('enter');
				}
			
			
			case 'gf-laugh':
				portraitLeft.visible = false;
				portraitRight.visible = false;
				portraitMiddle.frames = Paths.getSparrowAtlas('portraits/GirlfriendLaugh', "preload");
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('DialogueSounds/gf'), 0.6)];
				if (!portraitMiddle.visible)
				{
					portraitMiddle.visible = true;
					portraitMiddle.animation.play('enter');
				}
			case 'alpha':
				portraitLeft.visible = false;
				portraitRight.visible = false;
				portraitMiddle.frames = Paths.getSparrowAtlas('portraits/Alpha', "preload");
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('DialogueSounds/alpha'), 0.6)];
				if (!portraitMiddle.visible)
				{
					portraitMiddle.visible = true;
					portraitMiddle.animation.play('enter');
				}
		}
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		curCharacter = splitName[1];
		dialogueList[0] = dialogueList[0].substr(splitName[1].length + 2).trim();
	}
}
