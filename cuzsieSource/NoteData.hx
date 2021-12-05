package;

import flixel.util.FlxColor;
import lime.utils.Assets;

using StringTools;

class NoteData
{   
    public static var staticKeyAnimations:Array<Array<String>> = // Use this when grabbing animations for keys
	[
		[

		],
		[
			// X
			"Middle"
		],
		[
			// < >
			"Left", "Right"
		], 
		[
			// < X >
			"Left", "Middle", "Right"
		], 
		[
			// < v ^ >
			"Left", "Down", "Up", "Right"
		],  
		[
			// < v X ^ >
			"Left", "Down", "Middle", "Up", "Right"
		], 
		[
			// < v > < v >
			"Left", "Down", "Right", "Left", "Down", "Right"
		], 
		[
			// < v > X < v >
			"Left", "Down", "Right", "Middle", "Left", "Down", "Right"
		], 
		[
			// < v ^ > < v ^ >
			"Left", "Down", "Up", "Right", "Left", "Down", "Up", "Right"
		], 
		[
			// < v ^ > X < v ^ >
			"Left", "Down", "Up", "Right", "Middle","Left", "Down", "Up", "Right"
		] 
	];



    public static var widths:Array<Float> = // Use this when grabbing animations for keys
	[
        0,
        0,
        1,
        1,
        1,
        0.9,
        0.7
	];

    public static var sizes:Array<Float> = // Use this when grabbing animations for keys
	[
        0.7,
        0.7,
        0.7,
        0.7,
        0.7,
        0.7,
        0.65
	];
}