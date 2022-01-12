package;

import haxe.Json;
import haxe.format.JsonParser;
import openfl.utils.Assets as OpenFlAssets;

import Section.SwagSection;
import Song.SwagSong;

import CpSong.KadeSwagSong;

enum SongTypes{Kade;Psych;Forever;Funkin;}

class SongConvert
{
    public static function convertKade(chart:KadeSwagSong):SwagSong
    {
        trace("Converting...");

        var convertedSong:SwagSong;
      
        convertedSong = 
		{
			song: chart.song,
			artist: '',
			notes: chart.notes,
			bpm: chart.bpm,
			needsVoices: chart.needsVoices,
			player1: chart.player1,
			player2: chart.player2,
			player3: 'none',
			gfVersion: chart.gfVersion,
			noteStyle: chart.noteStyle,
			readySetStyle: 'default',
			readySetAnimation: 'Bounce',
			stage: chart.stage,
			speed: chart.speed,
			dadFlyX: 0.1,
			validScore: chart.validScore,
			bfFly: false,
			charFly: false,
			dadHasTrail: false,
			hasDialogue: false,
			keyAmmount: 4
		};

        trace("Conversion Complete!");

        return convertedSong;
    }

    
}