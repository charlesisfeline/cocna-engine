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
	public var noteType:String = "normal";
	public var customNoteName:String = '';

	#if windows
	public var customNoteData:ModchartState;
	#end

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inCharter:Bool = false, noteType:String = "normal")
	{
		super();

		this.noteType = noteType;	
		this.inCharter = inCharter;	
		this.customNoteName = noteType;
		#if windows
		isCustomNote = FileSystem.exists("mods/note_types/" + customNoteName + '/data.lua'); // if the file exists
		customNoteData = ModchartState.createModchartState("note", customNoteName);
		customNoteData.executeState('onNoteSpawn',[customNoteName]);
		customNoteData.type = "note";
		#else
		isCustomNote = false; // no custom notes for you BITCH
		#end

		if (prevNote == null)
		{
			prevNote = this; // If there is no previous note, set this to the previous note
		}

		this.prevNote = prevNote; 
		isSustainNote = sustainNote;

		x += 150; // Put the note off-screen
		y -= 2000; // Put the note off-screen
		
		if (inCharter)
		{
			this.strumTime = strumTime;
		}
		else 
		{
			this.strumTime = Math.round(strumTime);
		}
			

		if (this.strumTime < 0 ) // If the strum time is less than 0
		{
			this.strumTime = 0; // Set the strum time to 0
		}
		
		this.noteData = noteData;

		var daStage:String = PlayState.curStage; // The current stage

		var noteTypeCheck:String = 'normal'; // The note style

		frames = Paths.getSparrowAtlas("notes/Notes_Default", "preload"); // help why doesnt this work

		animation.addByPrefix('greenScroll', 'Up0');
		animation.addByPrefix('redScroll', 'Right0');
		animation.addByPrefix('blueScroll', 'Down0');
		animation.addByPrefix('purpleScroll', 'Left0');

		animation.addByPrefix('purpleholdend', 'Purple Hold End');
		animation.addByPrefix('greenholdend', 'Green Hold End');
		animation.addByPrefix('redholdend', 'Red Hold End');
		animation.addByPrefix('blueholdend', 'Blue Hold End');

		animation.addByPrefix('purplehold', 'Purple Hold');
		animation.addByPrefix('greenhold', 'Green Hold');
		animation.addByPrefix('redhold', 'Red Hold');
		animation.addByPrefix('bluehold', 'Blue Hold');

		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();
		antialiasing = true;

		switch (noteData)
		{
			case 0:
				x += swagWidth * 0;
				animation.play('purpleScroll');
			case 1:
				x += swagWidth * 1;
				animation.play('blueScroll');
			case 2:
				x += swagWidth * 2;
				animation.play('greenScroll');
			case 3:
				x += swagWidth * 3;
				animation.play('redScroll');
			case 4:
				x += swagWidth * 4;
				animation.play('redScroll');
			case 5:
				x += swagWidth * 5;
				animation.play('redScroll');
		}

		
		if (FlxG.save.data.downscroll && sustainNote) 
		{
			flipY = true;
		}
			

		if (isSustainNote && prevNote != null) // If its a sustain note and if the previous note isnt null
		{
			noteScore * 0.2;
			alpha = 0.6;

			x += width / 2;

			switch (noteData)
			{
				case 2:
					animation.play('greenholdend');
				case 3:
					animation.play('redholdend');
				case 1:
					animation.play('blueholdend');
				case 0:
					animation.play('purpleholdend');
				case 4:
					animation.play('redholdend');
				case 5:
					animation.play('redholdend');
			}

			updateHitbox();

			x -= width / 2;

			if (prevNote.isSustainNote)
			{
				switch (prevNote.noteData)
				{
					case 0:
						prevNote.animation.play('purplehold');
					case 1:
						prevNote.animation.play('bluehold');
					case 2:
						prevNote.animation.play('greenhold');
					case 3:
						prevNote.animation.play('redhold');
					case 4:
						prevNote.animation.play('redhold');
					case 5:
						prevNote.animation.play('redhold');
				}


				if(FlxG.save.data.scrollSpeed != 1)
					prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * FlxG.save.data.scrollSpeed;
				else
					prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed;
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);


		if (isCustomNote && !inCharter)
		{
			PlayState.instance.setHealth(customNoteData.getVar('health','float'));
		}
		if (mustPress)
		{
			// ass
			if (isSustainNote)
			{
				if (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * 1.5)
					&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
					canBeHit = true;
				else
					canBeHit = false;
			}
			else
			{
				if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
					&& strumTime < Conductor.songPosition + Conductor.safeZoneOffset)
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