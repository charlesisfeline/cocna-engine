package editors; 

#if cpp
import sys.io.File;
#end
import flixel.addons.plugin.screengrab.FlxScreenGrab;
import flixel.util.FlxVerticalAlign;
import openfl.ui.KeyLocation;
import openfl.events.Event;
import haxe.EnumTools;
import openfl.ui.Keyboard;
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
import flixel.group.FlxGroup.FlxTypedGroup;

#if windows
import Discord.DiscordClient;
#end
#if windows
import Sys;
import sys.FileSystem;
#end

using StringTools;


class WeekCreator extends MusicBeatState
{
    var weekList:Array<String> = []; // All the created weeks + "Create New Week"
    var wAlphabet:FlxTypedGroup<Alphabet>; // The weeks that show on the menu
    var currentSelected:Int = 0; // The current selected week
    var createdWeekSelect:Bool = false; // If it has created the week selection menu
    public static var week:String = ""; // The current week (string)
    public static var editing:Bool = false; // If your editing a week and not creating a week

    
    
    override public function create()
	{
        addWeekSelection();

        super.create();
    }


    public function addWeekSelection()
    {
        if (createdWeekSelect)
        {
            add(wAlphabet);
        }
        else
        {
            weekList.push("Create New Week");
        
            for(files in sys.FileSystem.readDirectory("assets/weeks"))
            {
                weekList.push(files);
                for (weeks in weekList)
                {
                    if (sys.FileSystem.exists("assets/weeks/" + weeks + "/data.json"))
                    {
                        trace("it exists!");
                    }
                    else
                    {
                        trace("data.json doesnt exist for week " + weeks + ", skipping");
                        
                        if (weeks != "Create New Week")
                        {
                            weekList.remove(weeks);
                        }
                    }
                }
            }
           
            wAlphabet = new FlxTypedGroup<Alphabet>();

            for (i in 0...weekList.length)
            {
                var weekText:Alphabet = new Alphabet(0, (70 * i) + 30, weekList[i], true, false, true);
                weekText.isMenuItem = true;
                weekText.targetY = i;
                wAlphabet.add(weekText);
            }

            add(wAlphabet);
            createdWeekSelect = true;
        }
    }

    public function removeWeekSelection()
    {
        remove(wAlphabet);
    }

    override public function update(elapsed:Float)
    {
        if (FlxG.keys.justPressed.UP)
        {
            changeSelection(-1);
        }
        if (FlxG.keys.justPressed.DOWN)
        {
            changeSelection(1);
        }

        if (FlxG.keys.justPressed.ENTER)
        {
            if (weekList[currentSelected] == "Create New Week")
            {
                editing = false;
                FlxG.state.openSubState(new editors.WeekCreatorSubstate());
            }
            else
            {
                editing = true;
                week = weekList[currentSelected];
                FlxG.state.openSubState(new editors.WeekCreatorSubstate());
            }
            
        }

        super.update(elapsed);
    }

    function changeSelection(change:Int = 0)
    {
        FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
    
    
    
        currentSelected += change;
    
        if (currentSelected < 0)
            currentSelected = weekList.length - 1;
        if (currentSelected >= weekList.length)
            currentSelected = 0;
    
    
        var bullShit:Int = 0;

        for (item in wAlphabet.members)
        {
            item.targetY = bullShit - currentSelected;
            bullShit++;
    
            item.alpha = 0.6;
             // item.setGraphicSize(Std.int(item.width * 0.8));
    
            if (item.targetY == 0)
            {
                item.alpha = 1;
                 // item.setGraphicSize(Std.int(item.width));
            }
        }
    }
}