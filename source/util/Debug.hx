package util;


class Debug
{
    public static function trace(text:String)
    {
        trace(text);
    }

    public static function traceError(text:String)
    {
        trace("ERROR: " + text);
    }

    public static function traceWarning(text:String)
    {
        trace("Warning: " + text);
    }
}