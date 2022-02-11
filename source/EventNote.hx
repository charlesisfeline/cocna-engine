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

class EventNote extends FlxSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:EventNote;
	public var modifiedByLua:Bool = false;
	public var isCustomNote:Bool = false; // If the note is one of the user created custom notes
	public var sustainLength:Float = 0;
	public var inCharter:Bool;
	public static var swagWidth:Float = 160 * 0.7;

	public function new(strumTime:Float, noteData:Int, ?prevNote:EventNote, ?inCharter:Bool = false)
	{
		super();

		if (prevNote == null)
			prevNote = this;

		this.inCharter = inCharter;	
		this.prevNote = prevNote; 
		this.noteData = noteData;
		if (inCharter) this.strumTime = strumTime;
		else this.strumTime = Math.round(strumTime);

		x += 150;
		y -= 2000;
		
		if (this.strumTime < 0 ) this.strumTime = 0;


		frames = Paths.getSparrowAtlas('notes/default/Left', 'preload');

		animation.addByPrefix('Scroll', 'Left0');

		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();
		antialiasing = true;

		animation.play('Scroll');
		
		x += swagWidth * noteData;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (mustPress)
		{
			if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset && strumTime < Conductor.songPosition + Conductor.safeZoneOffset)
				canBeHit = true;
			else
				canBeHit = false;

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