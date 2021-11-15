import flixel.FlxG;

// osu!mania / Stepmania style rankings
class Ratings
{
    public static function GenerateLetterRank(accuracy:Float) // generate a letter ranking
    {
        var ranking:String = "N/A";

        if (PlayState.misses == 0)
        {
            ranking = " FC";
        }   
        else if (PlayState.misses < 10)
        {
            ranking = " SDCB";
        } 
        else
        {
            ranking = " Clear";
        }

        var ratingCondition:Array<Bool> = [
            accuracy == 100, // SS
            accuracy >= 99.99, // S
            accuracy >= 93.17, // A
            accuracy >= 83.33, // B
            accuracy >= 75.00, // C
            accuracy >= 73.33, // D
            accuracy < 60, // F
        ];

        for(i in 0...ratingCondition.length)
        {
            var b = ratingCondition[i];
            if (b)
            {
                switch(i)
                {
                    case 0:
                        ranking += " SS -";
                    case 1:
                        ranking += " S -";
                    case 2:
                        ranking += " A -";
                    case 3:
                        ranking += " B -";
                    case 4:
                        ranking += " C -";
                    case 5:
                        ranking += " D -";
                    case 6:
                        ranking += " F -";
                }
                break;
            }
        }

        if (accuracy == 0)
        {
            ranking = "SS"; // if the ranking is 0 you probably havent pressed any notes yet , meaning you still have ss
        }
		else if(FlxG.save.data.botplay && !PlayState.loadRep)
        {
            ranking = "Auto";
        }

        return ranking;
    }
    
    public static function CalculateRating(noteDiff:Float, ?customSafeZone:Float):String // Generate a judgement through some timing shit
    {

        var customTimeScale = Conductor.timeScale;

        if (customSafeZone != null)
            customTimeScale = customSafeZone / 166;

        if (FlxG.save.data.botplay && !PlayState.loadRep)
        {
                return "sick";
        }	

        var rating = checkRating(noteDiff,customTimeScale);


        return rating;
    }

    public static function checkRating(ms:Float, ts:Float)
    {
        var rating = "sick";
        if (ms <= 166 * ts && ms >= 135 * ts)
            rating = "shit";
        if (ms < 135 * ts && ms >= 90 * ts) 
            rating = "bad";
        if (ms < 90 * ts && ms >= 45 * ts)
            rating = "good";
        if (ms < 45 * ts && ms >= -45 * ts)
            rating = "sick";
        if (ms > -90 * ts && ms <= -45 * ts)
            rating = "good";
        if (ms > -135 * ts && ms <= -90 * ts)
            rating = "bad";
        if (ms > -166 * ts && ms <= -135 * ts)
            rating = "shit";
        if (ms < 10 * ts && ms >= -10 * ts)
            rating = "marvelous";
        return rating;
    }

    public static function CalculateRanking(score:Int,scoreDef:Int,nps:Int,maxNPS:Int,accuracy:Float):String // hoping to put nps on a seprate text thingy -- FlxG.save.data.npsDisplay ? "NPS: " + nps + " (Max " + maxNPS + ")"
    {
        return
        (
            "Score: " 
            + 
            (
                Conductor.safeFrames != 10 ? score 
                + " (" 
                + scoreDef 
                + ")" : "" 
                + score 
            )
            + " | Misses: " 
            + PlayState.misses 
            +  " | Rating: " 
            + HelperFunctions.truncateFloat(accuracy, 2) 
            + " %"
            + "( " 
            + GenerateLetterRank(accuracy) 
            + " )"
        ); 																	
    }
}
