package editors;

import flixel.text.FlxText;
import flixel.FlxSubState;
import flixel.FlxSprite;
import flixel.FlxG;

class WeekCreatorSubstate extends FlxSubState
{
    var editing:Bool;
    var weekName:String;
    var week:Week;

    override public function create() 
    {   
        editing = WeekCreator.editing;
        weekName = WeekCreator.week;
        trace("Editing?: " + editing);
        trace("Current Week" + weekName);
        
        var bg:FlxSprite = new FlxSprite(0,0).loadGraphic(Paths.image("ui/Backgrounds/MenuPoop"));
        bg.setGraphicSize(1280,720);
        add(bg);

        var poop:FlxText = new FlxText(500,-400,0,"",50);
        poop.screenCenter(X);
        if (editing)
        {
            poop.text = "Edit Week";
        }
        else
        {
            poop.text = "Create Week";
        }
        add(poop);

        if (editing)
        {
            addEditingUI();
        }
        else
        {   
            addCreatingUI();
        }
        
        super.create();
    }

    override public function update(elapsed)
    {
        if (FlxG.keys.justPressed.ESCAPE)
        {
            close();
        }
        super.update(elapsed);
    }



    function addEditingUI()
    {

    }

    function addCreatingUI()
    {
        trace("Create a new Week");


    }
}