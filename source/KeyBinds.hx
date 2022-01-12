import flixel.FlxG;
import flixel.input.FlxInput;
import flixel.input.actions.FlxAction;
import flixel.input.actions.FlxActionInput;
import flixel.input.actions.FlxActionInputDigital;
import flixel.input.actions.FlxActionManager;
import flixel.input.actions.FlxActionSet;
import flixel.input.gamepad.FlxGamepadButton;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;

class KeyBinds
{

    public static var gamepad:Bool = false;

    public static function resetBinds():Void{

        FlxG.save.data.sixLeftBind = "S";
       
        FlxG.save.data.sixRightBind = "L";
        
        FlxG.save.data.upBind = "W";
        
        FlxG.save.data.downBind = "S";

        FlxG.save.data.middleBind = "SPACE";
        
        FlxG.save.data.leftBind = "A";
       
        FlxG.save.data.rightBind = "D";
       
        FlxG.save.data.killBind = "R";
        
        FlxG.save.data.gpupBind = "DPAD_UP";
        
        FlxG.save.data.gpdownBind = "DPAD_DOWN";
       
        FlxG.save.data.gpleftBind = "DPAD_LEFT";
        
        FlxG.save.data.gprightBind = "DPAD_RIGHT";
       
        PlayerSettings.player1.controls.loadKeyBinds();
	}

    public static function keyCheck():Void
    {
        if(FlxG.save.data.sixLeftBind == null){
            FlxG.save.data.sixLeftBind = "S";
            trace("No SLeft");
        }
        if(FlxG.save.data.sixRightBind == null){
            FlxG.save.data.sixRightBind = "L";
            trace("No SRight");
        }
        if(FlxG.save.data.upBind == null){
            FlxG.save.data.upBind = "W";
            trace("No UP");
        }
        if(FlxG.save.data.middleBind == null){
            FlxG.save.data.middleBind = "SPACE";
            trace("No MIDDLE");
        }
        if (StringTools.contains(FlxG.save.data.upBind,"NUMPAD"))
            FlxG.save.data.upBind = "W";
        if(FlxG.save.data.downBind == null){
            FlxG.save.data.downBind = "S";
            trace("No DOWN");
        }
        if (StringTools.contains(FlxG.save.data.downBind,"NUMPAD"))
            FlxG.save.data.downBind = "S";
        if(FlxG.save.data.leftBind == null){
            FlxG.save.data.leftBind = "A";
            trace("No LEFT");
        }
        if (StringTools.contains(FlxG.save.data.leftBind,"NUMPAD"))
            FlxG.save.data.leftBind = "A";
        if(FlxG.save.data.rightBind == null){
            FlxG.save.data.rightBind = "D";
            trace("No RIGHT");
        }
        if (StringTools.contains(FlxG.save.data.rightBind,"NUMPAD"))
            FlxG.save.data.rightBind = "D";
        
        if(FlxG.save.data.gpupBind == null){
            FlxG.save.data.gpupBind = "DPAD_UP";
            trace("No GUP");
        }
        if(FlxG.save.data.gpdownBind == null){
            FlxG.save.data.gpdownBind = "DPAD_DOWN";
            trace("No GDOWN");
        }
        if(FlxG.save.data.gpleftBind == null){
            FlxG.save.data.gpleftBind = "DPAD_LEFT";
            trace("No GLEFT");
        }
        if(FlxG.save.data.gprightBind == null){
            FlxG.save.data.gprightBind = "DPAD_RIGHT";
            trace("No GRIGHT");
        }

        trace
        (
            'Keybinds: \n\n\n
           
            4 Key:\n
            ${FlxG.save.data.leftBind}-
            ${FlxG.save.data.downBind}-
            ${FlxG.save.data.upBind}-
            ${FlxG.save.data.rightBind}\n\n
            
            5 Key: \n
            ${FlxG.save.data.leftBind}-
            ${FlxG.save.data.downBind}-
            ${FlxG.save.data.middleBind}-
            ${FlxG.save.data.upBind}-
            ${FlxG.save.data.rightBind}\n\n
            
            6 Key:\n
            ${FlxG.save.data.sixLeftBind}-
            ${FlxG.save.data.leftBind}-
            ${FlxG.save.data.downBind}-
            ${FlxG.save.data.upBind}-
            ${FlxG.save.data.rightBind}
            ${FlxG.save.data.sixRightBind}\n\n
            
            7 Key:\n
            ${FlxG.save.data.sixLeftBind}-
            ${FlxG.save.data.leftBind}-
            ${FlxG.save.data.downBind}-
            ${FlxG.save.data.middleBind}-
            ${FlxG.save.data.upBind}-
            ${FlxG.save.data.rightBind}
            ${FlxG.save.data.sixRightBind}\n\n'
        );
    }

}