package menus;

import flixel.input.gamepad.FlxGamepad;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxState;


#if windows
import Discord.DiscordClient;
#end

using StringTools;


class BaseListMenu extends MusicBeatState
{
	var curSelected:Int = 0;
	private var listMenu:FlxTypedGroup<Alphabet>;

    public var lastState:FlxState = null; 
    var includeIcons:Bool = false;
    var allignment:String = "Left";
    var itemList = [];
    private var iconArray:Array<HealthIcon> = [];
	public var currentSelected:String = '';

	override function create()
	{
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('ui/Backgrounds/FunkinBG'));
        bg.setGraphicSize(1280,720);
        bg.screenCenter();
        bg.color = 0xFFFDE871;
		add(bg);

		listMenu = new FlxTypedGroup<Alphabet>();
		add(listMenu);

		for (i in 0...itemList.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, itemList[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			listMenu.add(songText);

			if (allignment == "Middle")
				songText.screenCenter(X);

            if (includeIcons)
            {
                var icon:HealthIcon = new HealthIcon("bf");
			    icon.sprTracker = songText;

			    iconArray.push(icon);
			    add(icon);
            }
			
		}

		changeSelection();

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var upP = FlxG.keys.justPressed.UP;
		var downP = FlxG.keys.justPressed.DOWN;
		var accepted = controls.ACCEPT;

		if (upP)
			changeSelection(-1);
		
        if (downP)
	    	changeSelection(1);

		if (controls.BACK)
			FlxG.switchState(lastState);

		if (accepted){
			onPress();
        }
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = itemList.length - 1;
		if (curSelected >= itemList.length)
			curSelected = 0;

		var bullShit:Int = 0;


        if (includeIcons){
            for (i in 0...iconArray.length){
                iconArray[i].alpha = 0.6;
            }

            iconArray[curSelected].alpha = 1;
        }

		for (item in listMenu.members){
			item.targetY = bullShit - curSelected;
			bullShit++;
			item.alpha = 0.6;

			if (item.targetY == 0)
				item.alpha = 1;
		}

		currentSelected = itemList[curSelected];
	}

	public function onPress():Void
	{

	}
}