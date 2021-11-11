package;

import Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;
import Sys;

using StringTools;


// highly based on song.hx

typedef CoolWeek = 
{
    var weekName:String; 
    var weekSongs:Array<Dynamic>; 
    var menuWeekCharacters:Array<Dynamic>;
    var weekIsLocked:Bool; 
}

class Week
{
    public var weekName:String = "my_week"; // The name of your week
    public var weekSongs:Array<Dynamic> = []; // The songs in your week
    public var menuWeekCharacters:Array<Dynamic> = []; // The characters to appear on the menu
    public var weekIsLocked:Bool = false; // Is the week locked until you complete the week before it



    public function loadFromFile(file:String)
    {
        try
        {    
            trace('Loading song file');
 
            var rawJson = Assets.getText('assets/weeks/$file/data.json');
    
                while (!rawJson.endsWith("}"))
                {
                    rawJson = rawJson.substr(0, rawJson.length - 1);
                }
        
                return parseJSONshit(rawJson);
            }
            catch(ex)
            {
                trace(ex);
                return null; // you suck and it returned null
            }
    }

    public static function parseJSONshit(rawJson:String):CoolWeek
    {
        var swagShit:CoolWeek = cast Json.parse(rawJson).week;
        return swagShit;
    } 
}