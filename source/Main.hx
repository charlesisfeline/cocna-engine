package;

import openfl.display.BlendMode;
import openfl.text.TextFormat;
import openfl.display.Application;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import lime.app.Application;
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import openfl.errors.Error;
import openfl.events.ErrorEvent;

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the ga me in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 120; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	public static var instance:Main;

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		instance = this;

		super();

		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, function(e:UncaughtErrorEvent) 
		{
			var m:String = e.error;
			
			if (Std.isOfType(e.error, Error)) 
			{
				var err = cast(e.error, Error);
				m = '${err.message}';
			} 
			else if (Std.isOfType(e.error, ErrorEvent)) 
			{
				var err = cast(e.error, ErrorEvent);
				m = '${err.text}';
			}

			m += '\r\n ${CallStack.toString(CallStack.exceptionStack())}';

			trace('An uncaught error occured!\r\r\r\n\r\n${m}\r\n\r\nIf the problem presists, report the bug to the github!!');
 			Application.current.window.alert('An uncaught error occured!\r\n\r\n${m}\r\n\r\nIf the problem presists, report the bug to the github!!', e.error);
			e.stopPropagation();
			e.stopImmediatePropagation();
		});

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	public static var webmHandler:WebmHandler;

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}


		stage.window.onDropFile.add(function(path:String) 
		{
			FlxG.switchState(new FreeplayState());
		});


		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.application.window.width;
		var stageHeight:Int = Lib.application.window.height;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		#if cpp
		game = new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen);
		#else
		game = new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen);
		#end
		addChild(game);

		#if !mobile
		fpsCounter = new FpsCount(10, 3, 0xFFFFFF);
		addChild(fpsCounter);
		toggleFPS(FlxG.save.data.fps);
		#end
	}

	var game:FlxGame;
	public static var fpsCounter:FpsCount;

	public function toggleFPS(fpsEnabled:Bool):Void 
	{
		//fpsCounter.visible = fpsEnabled;
		fpsCounter.visible = true;
	}

	public function changeFPSColor(color:FlxColor)
	{
		fpsCounter.textColor = color;
	}

	public function setFPSCap(cap:Float)
	{
		openfl.Lib.current.stage.frameRate = cap;
	}

	public function getFPSCap():Float
	{
		return openfl.Lib.current.stage.frameRate;
	}

	public function getFPS():Float
	{
		return fpsCounter.currentFPS;
	}
}
