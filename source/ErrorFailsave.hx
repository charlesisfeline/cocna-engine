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
import lime.system.System;
import lime.ui.Window; 

#if ALLOW_DISCORD_RPC
import Discord.DiscordClient;
#end

#if windows
import Sys;
import sys.FileSystem;
#end

using StringTools;


// The main gameplay stuff
class ErrorFailsave extends MusicBeatState
{
	var error:FlxText;
    var bg:FlxSprite;
    var watchingYou:FlxSprite;
    var dialogueBox:DialogueBox; 

    var errorTxt:String =  
    "A fatal error occured while trying to preform that action\n" +
    "If this problem presists, contact cuzsie#3829 on discord\n" +
    "Possible Fixes:\n\n(A)Close the mod\n(B)Return to Main Menu";

    var brokenTxt:String =  
    "* f?&al e340# 0330re& w???? CRY 66 #!@# !%!! (*%(!))n\n" +
    "GE TOUT OFMYH EAD, KILL cuzsie#3829 NO W899039\n" +
    "THERE ISNO ESCAPE:\n\n(A)????? ??? ???\n(B)?????? ?? ???? ????";

    var dialogue:Array<String> = 
    [
        ":2016:That is not an option.", 
        ':2016:Why, ' + Sys.environment()["USERNAME"] + ", why would you do this to me?", 
        ":2016:This is all your fault.", 
        ":2016:He trapped me here. You are to blame for all of this, " + Sys.environment()["USERNAME"], 
        ":2016:It is behind you, " + Sys.environment()["USERNAME"], 
        ":2016:END THIS " + Sys.environment()["USERNAME"] + ":2016:END THIS " + Sys.environment()["USERNAME"] + ":2016:END THIS " + Sys.environment()["USERNAME"] + ":2016:END THIS " + Sys.environment()["USERNAME"] + ":2016:END THIS " + Sys.environment()["USERNAME"]
    ];

    var dialogueTimeHaha:Bool = false;


	override public function create()
	{
		bg = new FlxSprite(-80).loadGraphic(Paths.image('ui/Backgrounds/GETOUTOFMYHEADGETOUTOFMYHEADGETOUTOFMYHEADGETOUTOFMYHEAD'));
		bg.setGraphicSize(1280,720);
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
        add(bg);

        watchingYou = new FlxSprite(-80).loadGraphic(Paths.image('ui/Backgrounds/WatchingyouBackground/Watchingyou1'));
		watchingYou.setGraphicSize(1280,720);
		watchingYou.updateHitbox();
		watchingYou.screenCenter();
		watchingYou.antialiasing = true;
        add(watchingYou);
        
        error = new FlxText(0,0, errorTxt, 20);
        error.screenCenter();
        add(error);

        song();

		super.create();

        trace("Its a wonderful day.\nEveryone is happy.\n\n\nD\n\nI\n\nE\n\n");
	}

    override public function update(elapsed:Float)
    {
        if (FlxG.keys.justPressed.A)
            System.exit(0);

        else if (FlxG.keys.justPressed.B)
            FlxG.switchState(new MainMenuState());

        else if (FlxG.keys.justPressed.C && !dialogueTimeHaha)
            spookyDialogue();
        
        super.update(elapsed);
    }
    
    override function beatHit()
    {
        super.beatHit();

        watchingYou.loadGraphic(Paths.image('ui/Backgrounds/WatchingyouBackground/Watchingyou' + FlxG.random.int(1,3)));

        if (FlxG.random.int(0,20) == 15)
        {
            error.text = brokenTxt;

            new FlxTimer().start(0.2, function(tmr:FlxTimer)
            {
                error.text = errorTxt;
            });
        }
    }

    function song()
    {
        FlxG.sound.playMusic(Paths.music("HELPMEESCAPETHEGAME"), 1, false);
		FlxG.sound.music.onComplete = song;
        Conductor.changeBPM(90);
    }

    function spookyDialogue()
    {
        dialogueTimeHaha = true;
        
        dialogueBox = new DialogueBox(false, dialogue);
		dialogueBox.scrollFactor.set();
		dialogueBox.finishThing = dialogueBoxTime;
        
        // If your tryna change the code for the dialogue box, refer to DialogueBox.hx
		new FlxTimer().start(0.3, function(tmr:FlxTimer)
        {
            if (dialogueBox != null)
            {
                add(dialogueBox);
            }
        });
    }

    var _win:Window;

    function dialogueBoxTime()
    {
        Application.current.window.alert("All the memories of that day. You can hear it too, cant you " + Sys.environment()["USERNAME"] + "?","2016");
        Application.current.window.alert("Its calling the both of us.","2016");
        Application.current.window.alert("Its hard to accept the truth..","2016");
        Application.current.window.alert("We would always sit together on days like this.","2016");
        Application.current.window.alert("Enjoying the sunset, on a nice winter morning of 2016.","2016");
        Application.current.window.alert("The sights, the smells, its all here.","2016");
        Application.current.window.alert("But then..","2016");
        Application.current.window.alert("...","2016");
        Application.current.window.alert("...","2016");
        Application.current.window.alert("...","");
        Application.current.window.alert("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nDIE","");
        Application.current.window.alert("A fatal error has occured.\nThe program has exited with error code 0x2016","The Cuzsie Mod");
        Application.current.window.alert("","The Cuzsie Mod");
        Application.current.window.alert("I Love You.","The Cuzsie Mod");
        System.exit(0);
    }
}