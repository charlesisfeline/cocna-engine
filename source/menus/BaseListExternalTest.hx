package menus;

class BaseListExternalTest extends menus.BaseListMenu
{
    override function create()
    {
        includeIcons = false;
        itemList = Utility.coolTextFile(Paths.dat("menus/BaseListExternal/list"));
        lastState = new MainMenuState();

        super.create();
    }
}