package;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;

using StringTools;

class CustomCharacter extends FlxSpriteGroup
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';

	public var holdTimer:Float = 0;
	
	var tex:FlxAtlasFrames;


    public var hair:FlxSprite;
    public var body:FlxSprite;

    public var stunned:Bool = false;

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super(x, y);
	
		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;
		antialiasing = true;

		changeCharacter(character);

		dance();

		if (isPlayer)
		{
			flipX = !flipX;

			// Doesn't flip for BF, since his are already in the right place???
			if (!curCharacter.startsWith('bf'))
			{
				// var animArray
				var oldRight = animation.getByName('singRIGHT').frames;
				animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
				animation.getByName('singLEFT').frames = oldRight;

				// IF THEY HAVE MISS ANIMATIONS??
				if (animation.getByName('singRIGHTmiss') != null)
				{
					var oldMiss = animation.getByName('singRIGHTmiss').frames;
					animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
					animation.getByName('singLEFTmiss').frames = oldMiss;
				}
			}
		}
	}

	override function update(elapsed:Float)
	{
		if (!curCharacter.startsWith('bf'))
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}

			var dadVar:Float = 4;

			if (curCharacter == 'dad')
				dadVar = 6.1;
			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
			{
				trace('dance');
				dance();
				holdTimer = 0;
			}
		}

		switch (curCharacter)
		{
			case 'gf':
				if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
					playAnim('danceRight');
		}






        if (!debugMode)
            {
                if (body.animation.curAnim.name.startsWith('sing'))
                {
                    holdTimer += elapsed;
                }
                else
                    holdTimer = 0;
    
                if (body.animation.curAnim.name.endsWith('miss') && body.animation.curAnim.finished && !debugMode)
                {
                    playAnim('idle', true, false, 10);
                }
    
                if (body.animation.curAnim.name == 'firstDeath' && body.animation.curAnim.finished)
                {
                    playAnim('deathLoop');
                }
            }
    

		super.update(elapsed);
	}

	private var danced:Bool = false;

	public function dance()
	{
		if (!debugMode)
		{
			if (curCharacter.startsWith('gf'))
			{
				if (!body.animation.curAnim.name.startsWith('hair') || curCharacter == "spooky")
				{
					danced = !danced;

					if (danced)
						playAnim('danceRight');
					else
						playAnim('danceLeft');
				}
			}
			else
			{
				playAnim('idle');
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		var animationOffset = animOffsets.get(AnimName);
		
        
        hair.animation.play(AnimName, Force, Reversed, Frame);
        body.animation.play(AnimName, Force, Reversed, Frame);

		if (animOffsets.exists(AnimName))
		{
			hair.offset.set(animationOffset[0], animationOffset[1]);
            body.offset.set(animationOffset[0], animationOffset[1]);
		}
		else
		{
			hair.offset.set(0, 0);
            body.offset.set(0, 0);
		}
			

		if (curCharacter == 'gf')
		{
			if (AnimName == 'singLEFT')
			{
				danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				danced = false;
			}

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}

	public function changeCharacter(character:String)
	{	
		// 
        
        hair = new FlxSprite(0,0);
        hair.frames = Paths.getSparrowAtlas('characters/bfCustomize/boyfrined hair iguess', 'shared');
		
        hair.animation.addByPrefix('idle', 'BF idle dance', 24, false);
		hair.animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
		hair.animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
		hair.animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
		hair.animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
		hair.animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
		hair.animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
		hair.animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
		hair.animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
		hair.animation.addByPrefix('hey', 'BF HEY', 24, false);
		hair.animation.addByPrefix('scared', 'BF idle shaking', 24);

		/*hair.addOffset('idle', -5);
		hair.addOffset("singUP", -29, 27);
		hair.addOffset("singRIGHT", -38, -7);
		hair.addOffset("singLEFT", 12, -6);
		hair.addOffset("singDOWN", -10, -50);
		hair.addOffset("singUPmiss", -29, 27);
		hair.addOffset("singRIGHTmiss", -30, 21);
		hair.addOffset("singLEFTmiss", 12, 24);
        hair.addOffset("singDOWNmiss", -11, -19);
		hair.addOffset("hey", 7, 4);
		hair.addOffset('scared', -4);

		hair.playAnim('idle');*/

        add(hair);


        body = new FlxSprite(0,0);
        body.frames = Paths.getSparrowAtlas('characters/bfCustomize/bf body looolz', 'shared');
		
        body.animation.addByPrefix('idle', 'BF idle dance', 24, false);
		body.animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
		body.animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
		body.animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
		body.animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
		body.animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
		body.animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
		body.animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
		body.animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
		body.animation.addByPrefix('hey', 'BF HEY', 24, false);
		body.animation.addByPrefix('scared', 'BF idle shaking', 24);

		/*body.addOffset('idle', -5);
		body.addOffset("singUP", -29, 27);
		body.addOffset("singRIGHT", -38, -7);
		body.addOffset("singLEFT", 12, -6);
		body.addOffset("singDOWN", -10, -50);
		body.addOffset("singUPmiss", -29, 27);
		body.addOffset("singRIGHTmiss", -30, 21);
		body.addOffset("singLEFTmiss", 12, 24);
        body.addOffset("singDOWNmiss", -11, -19);
		body.addOffset("hey", 7, 4);
		body.addOffset('scared', -4);

		body.playAnim('idle');*/

        add(body);

		flipX = true;
	}
}
