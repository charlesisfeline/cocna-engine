package;

import flixel.util.FlxColor;
import lime.utils.Assets;

using StringTools;

class Utility
{
	public static var difficultyArray:Array<String> = ['Easy', "Normal", "Hard", "Insane", "Expert", "Extra"];

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
