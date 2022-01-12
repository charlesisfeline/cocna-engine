package;

import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxG;

using StringTools;

class Utility
{
	public static var difficultyArray:Array<String> = ['Easy', "Normal", "Hard", "Insane", "Expert", "Extra"];

	// these are the actual id's that you can find in osu/Data/bg
	public static var osu_sBackgroundID:Array<String> = [
		"0f09a552b15c5130b402b7b5f59322a1",
		"1a507a8a23d1043eaad37ea7d75be6e8",
		"3eea32244d908f4e6ec1b2d579a60035",
		"6b0389c6917fc4ef79f660c3c36cb5af",
		'6c6c849eecce57d74913c5e787202fc8',
		"9b8fd5a4045700c5d02d51eaab570b14",
		"26b55d589f4564be2b3cd63b42e537b4",
		"39f72ceed3318f49069c680a9d84288a",
		"85aaaebe77a13354a28ed23cdf9dfc26",
		"346b9f8273f18d2ed45a957f0c39c404",
		"00486a5868bd018e2e27dc4ff6ceb71e",
		"856e76322399a1a72f0db57fb2af6b39",
		"4768f3363ec951644b3207751e7ca5be",
		"41464fcdc1b19179637cc0ae934b26ec",
		"41518f2027643460325f2be8fab476ff",
		"41518f2027643460325f2be8fab476ff",
		"af99c37e58e6819a29e7f004663d301b",
		"c67412d1d08e95aa6f88bd6eb49fe7af",
		"cf4f1ca666d86fdd46a5a9081d65be29"
	];

	public static var osu_sBackgroundSeason:String = "dec_2021";
	

	public static function getNewOsuBg():String
	{
		trace("Getting osu seasonal bg...");
		return osu_sBackgroundID[FlxG.random.int(0, osu_sBackgroundID.length)];
	}

	inline public static function boundTo(value:Float, min:Float, max:Float):Float 
	{
		return Math.max(min, Math.min(max, value));
	}
	
	public static function difficultyFromInt(difficulty:Int):String
	{
		return difficultyArray[difficulty];
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = Assets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}



	public static function coolDynamicTextFile(path:String):Array<Dynamic>
	{
		var daList:Array<Dynamic> = Assets.getText(path).trim().split('\n');
	
		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}
	
		return daList;
	}
	
	public static function coolStringFile(path:String):Array<String>
	{
		var daList:Array<String> = path.trim().split('\n');
	
		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}
	
		return daList;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

	public static function songLowercase(value:String)
	{
		switch (value) 
		{
			case 'Dad-Battle': 
				return "Dadbattle";
			case 'Philly-Nice': 
				return "Philly";
			default:
				return value;
		}
	}

	// dont get mad at me for this >:((
	public static function getColorString(data:String)
	{
		switch(data)
		{
			case 'black':
				return FlxColor.BLACK;
			case 'red':
				return FlxColor.RED;
			case 'yellow':
				return FlxColor.YELLOW;
			case 'orange':
				return FlxColor.ORANGE;
			case 'green':
				return FlxColor.GREEN;
			case 'blue':
				return FlxColor.BLUE;
			case 'purple':
				return FlxColor.PURPLE;
			case 'white':
				return FlxColor.WHITE;
			// for the love of god why are there 2 spellings of grey
			case 'grey':
				return FlxColor.GRAY;
			case 'gray':
				return FlxColor.GRAY;
			case 'brown':
				return FlxColor.BROWN;
			case 'cyan':
				return FlxColor.CYAN;
			case 'lime':
				return FlxColor.LIME;
			case 'magenta':
				return FlxColor.MAGENTA;
			case 'pink':
				return FlxColor.PINK;
			default:
				return FlxColor.WHITE;
		}
	}



	public function getKeyTex(keyAmmount:Int, currentKey:Int)
	{
		// shut up, i hate this code aswell. dont question it

		switch(keyAmmount)
		{
			case 1:
				// lmaoo one key fun
		}
	}
}
