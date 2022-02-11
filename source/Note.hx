package;

import flixel.addons.effects.FlxSkewedSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
#if polymod
import polymod.format.ParseRules.TargetSignatureElement;
#end

#if windows
import Sys;
import sys.FileSystem;
#end

import PlayState;

using StringTools;

class Note extends FlxSprite
{
	public static var staticKeyAnimations:Array<Array<String>> = // Use this when grabbing animations for keys
	[
		[],
		["Middle"],
		["Left", "Right"], 
		["Left", "Middle", "Right"], 
		["Left", "Down", "Up", "Right"],  
		["Left", "Down", "Middle", "Up", "Right"], 
		["Left", "Down", "Right", "Left 2", "Down 2", "Right 2"], 
		["Left", "Down", "Right", "Middle", "Left 2", "Down 2", "Right 2"], 
		["Left", "Down", "Up", "Right", "Left 2", "Down 2", "Up 2", "Right 2"], 
		[ "Left", "Down", "Up", "Right", "Middle","Left 2", "Down 2", "Up 2", "Right 2"] 
	];

    public static var widths:Array<Float> = 
	[
        0.000,
        0,
        1,
        1,
        1,
        0.9,
        0.7
	];

    public static var sizes:Array<Float> =
	[
        0.000,
        0.7,
        0.7,
        0.7,
        0.7,
        0.7,
        0.65
	];
	
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;
	public var modifiedByLua:Bool = false;
	public var isCustomNote:Bool = false; // If the note is one of the user created custom notes
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var inCharter:Bool;

	public var noteScore:Float = 1;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;
	public static var secNote:Int = 4;
	public static var secNote2:Int = 5;

	public var rating:String = "shit";
	public var customNoteName:String = '';

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inCharter:Bool = false)
	{
		super();

		if (prevNote == null)
			prevNote = this;

		this.inCharter = inCharter;	
		this.prevNote = prevNote; 
		this.noteData = noteData;
		if (inCharter) {this.strumTime = strumTime;}
		else {this.strumTime = Math.round(strumTime);}

		isSustainNote = sustainNote;

		x += 150;
		y -= 2000;
		
		if (this.strumTime < 0 ) {this.strumTime = 0;}


		if (PlayState.keyAmmount == 0) {PlayState.keyAmmount = 4;}

		frames = Paths.getSparrowAtlas('notes/default/${Note.staticKeyAnimations[PlayState.keyAmmount][noteData]}', 'preload');

		animation.addByPrefix('Scroll', '${Note.staticKeyAnimations[PlayState.keyAmmount][noteData]}0');
		animation.addByPrefix('holdend', '${Note.staticKeyAnimations[PlayState.keyAmmount][noteData]} Tail');
		animation.addByPrefix('hold', '${Note.staticKeyAnimations[PlayState.keyAmmount][noteData]} Hold');

		setGraphicSize(Std.int(width * sizes[PlayState.keyAmmount]));
		updateHitbox();
		antialiasing = true;

		animation.play('Scroll');
		
		x += swagWidth * noteData;

		
		if (FlxG.save.data.downscroll && sustainNote) 
			flipY = true;
			
		if (isSustainNote && prevNote != null)
		{
			noteScore * 0.2;
			alpha = 0.6;
			x += width / 2;


			animation.play('holdend');

			updateHitbox();

			x -= width / 2;

			if (prevNote.isSustainNote)
			{
				prevNote.animation.play('hold');	

				if(FlxG.save.data.scrollSpeed != 1)
					prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * FlxG.save.data.scrollSpeed;
				else
					prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed;
				prevNote.updateHitbox();
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (mustPress)
		{
			if (isSustainNote)
			{
				if (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * 1.5) && strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
					canBeHit = true;
				else
					canBeHit = false;
			}

			else
			{
				if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset && strumTime < Conductor.songPosition + Conductor.safeZoneOffset)
					canBeHit = true;
				else
					canBeHit = false;
			}

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset * Conductor.timeScale && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
				wasGoodHit = true;
		}

		if (tooLate)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}