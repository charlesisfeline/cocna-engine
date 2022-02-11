package;

import flixel.FlxState;

class FlxMenuButton
{
    public var name:String = "";
    public var destination:FlxState = new MainMenuState();
    
    public function new(name:String, destination:FlxState)
    {
        this.name = name;
        this.destination = destination;
    }
}