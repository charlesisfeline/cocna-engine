package menus; 

import flixel.FlxCamera;
import flixel.addons.ui.FlxUIText;
import haxe.zip.Writer;
import Conductor.BPMChangeEvent;
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import haxe.Json;
import lime.utils.Assets;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.IOErrorEvent;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.ByteArray;
import Stage;
import flixel.addons.display.FlxExtendedSprite;
import flixel.FlxObject;

#if windows
import Discord.DiscordClient;
#end

using StringTools;

class MenuBuilder extends MusicBeatState
{
	var UI_box:FlxCTabMenu;
	var camFollow:FlxObject;
	
	var tip:String = 
	"[E] - Zoom Out\n" +
	"[Q] - Zoom In\n" + 
	"[<][^][V][>] - Move Camera" +
	"[SHIFT] - Move 10x faster";

	var tabs = 
	[
		{name: "Menu Info", label: 'Menu Info'},
		{name: "Inspector", label: 'Inspector'},
		{name: "Objects", label: 'Objects'}
	];

	private var camEditor:FlxCamera;
	private var camHUD:FlxCamera;

	override function create()
	{
		FlxG.mouse.visible = true;

		#if windows
		DiscordClient.changePresence("Menu Builder V1 Beta", null, null, true);
		#end

		camEditor = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		
		FlxG.cameras.reset(camEditor);
		FlxG.cameras.add(camHUD);
		FlxCamera.defaultCameras = [camEditor];

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('ui/Backgrounds/FunkinBG'));
        bg.setGraphicSize(1920,1080);
        bg.screenCenter();
        bg.color = 0xFFFDE871;
		bg.scrollFactor.set(0.1,0.1);

		UI_box = new FlxCTabMenu(null, tabs, true);
		UI_box.cameras = [camHUD];
		UI_box.resize(300, 300);
		// UI_box.x = FlxG.width / 2;
		UI_box.y = 20;

		var tipText:FlxText = new FlxText(FlxG.width - 20, FlxG.height, 0, tip, 12);
		tipText.cameras = [camHUD];
		tipText.setFormat(null, 12, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		tipText.scrollFactor.set();
		tipText.borderSize = 1;
		tipText.x -= tipText.width;
		tipText.y -= tipText.height - 10;

		var versionShit:FlxText = new FlxText(9, FlxG.height - 44, 0, "MenuBuilder V1\nOriginal song by iFlicky for Psych Engine!", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		
		add(bg);
		add(UI_box);
		add(camFollow);
		add(tipText);

		FlxG.save.bind('cuzsiemod_data', 'cuzsiedev');
		FlxG.camera.follow(camFollow);
		FlxG.sound.playMusic(Paths.music("psych_offsetSong", 'preload'), 0.6);

		super.create();
	}
	
	function addUI()
	{
		
	}

	override function update(elapsed:Float)
	{
		if (FlxG.keys.pressed.E && FlxG.camera.zoom < 3) 
		{
			FlxG.camera.zoom += elapsed * FlxG.camera.zoom;

			if(FlxG.camera.zoom > 3) 
				FlxG.camera.zoom = 3;
		}
		if (FlxG.keys.pressed.Q && FlxG.camera.zoom > 0.1) 
		{
			FlxG.camera.zoom -= elapsed * FlxG.camera.zoom;
			
			if(FlxG.camera.zoom < 0.1) 
				FlxG.camera.zoom = 0.1;
		}

		if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.DOWN || FlxG.keys.pressed.UP || FlxG.keys.pressed.RIGHT)
		{
			var addToCam:Float = 500 * elapsed;
			
			if (FlxG.keys.pressed.SHIFT)
				addToCam *= 4;

			if (FlxG.keys.pressed.UP)
				camFollow.y -= addToCam;
			
			else if (FlxG.keys.pressed.DOWN)
				camFollow.y += addToCam;

			if (FlxG.keys.pressed.LEFT)
				camFollow.x -= addToCam;
			
			else if (FlxG.keys.pressed.RIGHT)
				camFollow.x += addToCam;
		}
		
		super.update(elapsed);
	}
}
