package menus;

class BaseListTest extends menus.BaseListMenu
{
    override function create()
    {
        includeIcons = false;
        itemList = ["This is what", "A basic", "Menu", "That was", "Made using", "baselistmenu"];
        lastState = new MainMenuState();

        super.create();
    }
}