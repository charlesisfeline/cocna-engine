// kakyoin
package editors; 

import flixel.FlxCamera;
import flixel.addons.ui.FlxUIText;
import haxe.zip.Writer;
import Conductor.BPMChangeEvent;
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import haxe.Json;
import lime.utils.Assets;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.IOErrorEvent;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.ByteArray;
import Stage;
import flixel.addons.display.FlxExtendedSprite;

#if windows
import Discord.DiscordClient;
#end

using StringTools;

class ChartingState extends MusicBeatState
{
	var _song:SwagSong;
	var player1:Boyfriend = new Boyfriend(0,0, "bf");
	var player2:Character = new Character(0,0, "dad");
	var p3Icon:HealthIcon;
	var leftIcon:HealthIcon;
	var rightIcon:HealthIcon;
	private var lastNote:Note;
	var claps:Array<Note> = [];
	var curRenderedNotes:FlxTypedGroup<Note>;

	var _file:FileReference;
	
	public var playClaps:Bool = false;
	public var isNewChart:Bool;
	
	public var snap:Int = 1;
	var curSection:Int = 0;
	public static var lastSection:Int = 0;
	var amountSteps:Int = 0;
	var noteType:Int = 0;
	var currType:Int = 0;
	var GRID_SIZE:Int = 40;
	var gridWidth:Int = 8;

	var tempBpm:Float = 0;

	var UI_box:FlxCTabMenu;
	var UI_box_objectData:FlxUITabMenu;
	
	var bpmTxt:FlxText;
	var writingNotesText:FlxText;
	public var snapText:FlxText;

	var strumLine:FlxSprite;
	var highlight:FlxSprite;
	var dummyArrow:FlxSprite;
	var gridBG:FlxSprite;
	var gridBlackLine:FlxSprite;
	var curRenderedSustains:FlxTypedGroup<FlxSprite>;

	var curSong:String = 'Dad Battle';
	var styles:Array<String> = ["normal","alpha"];
	var typeNames:Array<String> = ['Normal', 'Alpha'];
	var possibleChars:Array<String>;
	
	var bullshitUI:FlxGroup;

	var typingShit:FlxInputText;

	var curSelectedNote:Array<Dynamic>;
	
	var vocals:FlxSound;

	var stepperType:FlxUINumericStepper;

	public static var fromSongMenu:Bool = false;
	var bg:FlxSprite;


	override function create()
	{
		FlxG.mouse.visible = true;
		FlxG.camera.zoom + 0.1; // zoooom

		#if windows
		DiscordClient.changePresence("Chart Editor", null, null, true);
		#end
		
		curSection = lastSection;

		if (PlayState.SONG != null || !isNewChart)
		{
			try
			{
				_song = PlayState.SONG; // Change the song to the song in PlayState
			}
			catch(ex)
			{
				defaultChart();
			}
			
		}	
		else
		{
			defaultChart();
		}
		
		var tabs = 
		[
			{name: "Song", label: 'Song'},
			{name: "Character", label: 'Character'},
			{name: "Section", label: 'Section'},
			{name: "Assets", label: 'Assets'}
		];

		var object_tabs = 
		[
			{name: "Note", label: 'Note'},
			{name: "Events", label: 'Events'}
		];

		// for debugging that weird ass bug, removing later
		if 
		(
				_song.keyAmmount == 0 || 
				_song.keyAmmount != 1 || 
				_song.keyAmmount != 2 || 
				_song.keyAmmount != 3 || 
				_song.keyAmmount != 4 || 
				_song.keyAmmount != 5 || 
				_song.keyAmmount != 6 || 
				_song.keyAmmount != 7 || 
				_song.keyAmmount != 8 || 
				_song.keyAmmount != 9
		)
		{
			_song.keyAmmount = 4;
		}

		bg = new FlxSprite().loadGraphic(Paths.image('ui/Backgrounds/FunkinBG'));
		bg.scrollFactor.set();
		bg.setGraphicSize(1920,1080);
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		bg.color = FlxColor.GRAY;
		add(bg);

		gridWidth = _song.keyAmmount * 2;
		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * gridWidth, GRID_SIZE * 16, true, FlxColor.GRAY, FlxColor.BLACK);

		var blackBorder:FlxSprite = new FlxSprite(60,10).makeGraphic(120,100,FlxColor.BLACK);
		blackBorder.scrollFactor.set();
		blackBorder.alpha = 0.3;

		snapText = new FlxText(60,10,0,"Snap: 1/" + snap , 14);
		snapText.scrollFactor.set();

		gridBlackLine = new FlxSprite(gridBG.x + gridBG.width / 2).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		
		leftIcon = new HealthIcon(_song.player1);
		leftIcon.scrollFactor.set(1, 1);
		leftIcon.setGraphicSize(0, 45);
		leftIcon.setPosition(0, -100);

		rightIcon = new HealthIcon(_song.player2);
		rightIcon.scrollFactor.set(1, 1);
		rightIcon.setGraphicSize(0, 45);
		rightIcon.setPosition(gridBG.width / 2, -100);

		p3Icon = new HealthIcon(_song.player3);
		p3Icon.scrollFactor.set(1, 1);
		p3Icon.setGraphicSize(0, 45);
		p3Icon.setPosition(rightIcon.x + 10, rightIcon.y + 10);

		curRenderedNotes = new FlxTypedGroup<Note>();
		curRenderedSustains = new FlxTypedGroup<FlxSprite>();

		for (rendered in curRenderedNotes)
		{
			rendered.customNoteName = '';
			rendered.isCustomNote = false;
		}

		FlxG.save.bind('cuzsiemod_data', 'cuzsiedev');

		tempBpm = _song.bpm;

		bpmTxt = new FlxText(1000, 50, 0, "", 16);
		bpmTxt.scrollFactor.set();

		strumLine = new FlxSprite(0, 50).makeGraphic(Std.int(FlxG.width / 2), 4);

		dummyArrow = new FlxSprite().makeGraphic(GRID_SIZE, GRID_SIZE);
		
		UI_box = new FlxCTabMenu(null, null, tabs, null, null, null, null, "Transparent Blackout");
		UI_box.resize(500, 500);
		UI_box.x = FlxG.width / 2;
		UI_box.y = 20;

		UI_box_objectData = new FlxUITabMenu(null, object_tabs, true);
		UI_box_objectData.resize(500, 100);
		UI_box_objectData.x = UI_box.x;
		UI_box_objectData.y = UI_box.y + 500;

		addSection();
		updateGrid();
		loadSong(_song.song);
		Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);
		addUI(); // Add UI last because some elements require the song to be loaded

		add(gridBG);
		add(gridBlackLine);
		add(leftIcon);
		add(rightIcon);
		add(p3Icon);
		add(bpmTxt);
		add(strumLine);
		add(dummyArrow);
		add(curRenderedNotes);
		add(curRenderedSustains);
		add(blackBorder);
		add(snapText);
		add(UI_box);
		add(UI_box_objectData);

		super.create();
	}

	var stepperLength:FlxUINumericStepper;
	var check_mustHitSection:FlxUICheckBox;
	var check_changeBPM:FlxUICheckBox;
	var stepperSectionBPM:FlxUINumericStepper;
	var check_altAnim:FlxUICheckBox;
	var check_p3sing:FlxUICheckBox;
	var stepperSusLength:FlxUINumericStepper;
	var tab_group_note:FlxUI;
	var notetypes:FlxUIDropDownMenu;
	
	function addUI()
	{
		// Song Tab //

		// Save (Real)
		var realsaveButton:FlxButton = new FlxButton(10, 0, "Save", function()
		{
			saveRealLevel();
		});

		// Save
		var saveButton:FlxButton = new FlxButton(10, 30, "Save As", function()
		{
			saveLevel();
		});
		
		// Load
		var reloadSong:FlxButton = new FlxButton(10, 60, "Reload Audio", function()
		{
			loadSong(_song.song);
		});
		
		// Reload
		var reloadSongJson:FlxButton = new FlxButton(10, 90, "Reload Chart", function()
		{
			loadJson(_song.song.toLowerCase());
		});
	
		// Reset Chart
		var restart = new FlxButton(10,90,"Reset Chart", function()
		{
			for (ii in 0..._song.notes.length)
			{
				for (i in 0..._song.notes[ii].sectionNotes.length)
				{
					_song.notes[ii].sectionNotes = [];
				}
			}
			resetSection(true); 
		});
	
		// Load Autosave
		var loadAutosaveBtn:FlxButton = new FlxButton(10, 120, 'Load AutoSave', loadAutosave);
	
		// Shift Note Forward by Section
		var shiftNoteDialLabel = new FlxText(10, 245, 'Shift Note Forward by (Section)');
		var stepperShiftNoteDial:FlxUINumericStepper = new FlxUINumericStepper(10, 260, 1, 0, -1000, 1000, 0);
		stepperShiftNoteDial.name = 'song_shiftnote';
			
		// Shift Note Forward by Step
		var shiftNoteDialLabel2 = new FlxText(10, 275, 'Shift Note FWD by (Step)');
		var stepperShiftNoteDialstep:FlxUINumericStepper = new FlxUINumericStepper(10, 290, 1, 0, -1000, 1000, 0);
		stepperShiftNoteDialstep.name = 'song_shiftnotems';
	
		// Shift Note Forward by Milliseconds
		var shiftNoteDialLabel3 = new FlxText(10, 305, 'Shift Note FWD by (ms)');
		var stepperShiftNoteDialms:FlxUINumericStepper = new FlxUINumericStepper(10, 320, 1, 0, -1000, 1000, 2);
		stepperShiftNoteDialms.name = 'song_shiftnotems';		
			
		
		
		// Song Name
		var UI_songTitle = new FlxUIInputText(400, 5, 70, _song.song, 8); // lol funny x value
		typingShit = UI_songTitle;

		// Has Vocal Track
		var check_voices = new FlxUICheckBox(400, 25, null, null, "Has voice track", 100);
		check_voices.checked = _song.needsVoices;
		check_voices.callback = function()
		{
			_song.needsVoices = check_voices.checked;
			trace('CHECKED!');
		};
	
		// Has Dialogue
		var check_dialogue = new FlxUICheckBox(400, 45, null, null, "Has dialogue", 100);
		check_dialogue.checked = _song.hasDialogue;
		check_dialogue.callback = function()
		{
			_song.hasDialogue = check_dialogue.checked;
			trace('CHECKED!');
		};
	
		// Dialogue Path Text
		var thing:String;
		#if sys
		if (sys.FileSystem.exists("assets/data/data/dialogue/" +  _song.song + "/dialogue.txt"))
		{
			thing = "Exists";
		}
		else
		{
			thing = "Doesn't Exist";
		}
		#else
		thing = "Can't be checked when accessing non-ccp targets!";
		#end
			
		var dText = new FlxText(50,0,0,"Dialogue Path " + thing, 7);
			
			
		// BPM
		var stepperBPM:FlxUINumericStepper = new FlxUINumericStepper(100, 5, 0.1, 1, 1.0, 5000.0, 1);
		stepperBPM.value = Conductor.bpm;
		stepperBPM.name = 'song_bpm';
		var stepperBPMLabel = new FlxText(160,5,'BPM');
	
		// Keys
		var stepperKEY:FlxUINumericStepper = new FlxUINumericStepper(100, 25, 1, 1, 1.0, 5000.0, 1);
		stepperKEY.value = _song.keyAmmount;
		stepperKEY.name = 'song_keys';
		var stepperKEYLabel = new FlxText(160,25,'Key Ammount');
			
		// Scroll Speed
		var stepperSpeed:FlxUINumericStepper = new FlxUINumericStepper(100, 45, 0.1, 1, 0.1, 10, 1);
		stepperSpeed.value = _song.speed;
		stepperSpeed.name = 'song_speed';
		var stepperSpeedLabel = new FlxText(160,45,'Scroll Speed');

		var stepperVocalVol:FlxUINumericStepper = new FlxUINumericStepper(100, 65, 0.1, 1, 0.1, 10, 1);
		stepperVocalVol.value = vocals.volume;
		stepperVocalVol.name = 'song_vocalvol';
		var stepperVocalVolLabel = new FlxText(160, 65, 'Vocal Volume');
				
		var stepperSongVol:FlxUINumericStepper = new FlxUINumericStepper(100, 85, 0.1, 1, 0.1, 10, 1);
		stepperSongVol.value = FlxG.sound.music.volume;
		stepperSongVol.name = 'song_instvol';
		var stepperSongVolLabel = new FlxText(160, 85, 'Insturmental Volume');
	
		var shiftNoteButton:FlxButton = new FlxButton(10, 335, "Shift", function()
		{
			shiftNotes(Std.int(stepperShiftNoteDial.value),Std.int(stepperShiftNoteDialstep.value),Std.int(stepperShiftNoteDialms.value));
		});
	
		// Assets //
		#if sys
		var characters:Array<String> = Utility.coolTextFile(Paths.txt('characterList'));
		#end
		var gfVersions:Array<String> = Utility.coolTextFile(Paths.txt('data/gfVersionList'));
		var noteStyles:Array<String> = Utility.coolTextFile(Paths.txt('data/noteStyleList'));
		var readySetStyles:Array<String> = Utility.coolTextFile(Paths.txt('data/readySetStyles'));
		var readySetAnims:Array<String> = Utility.coolTextFile(Paths.txt('data/readySetAnims'));
		#if sys
		var stages:Array<String> = sys.FileSystem.readDirectory("assets/stages");
		#else
		var stages:Array<String> = Utility.coolTextFile(Paths.txt('data/stageList'));
		#end

		// Player 1
		var player1DropDown = new FlxUIDropDownMenu(10, 100, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player1 = characters[Std.parseInt(character)];
		});
		player1DropDown.selectedLabel = _song.player1;
		var player1Label = new FlxText(10,80,64,'Player 1');
	
		// Player 2
		var player2DropDown = new FlxUIDropDownMenu(140, 100, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player2 = characters[Std.parseInt(character)];
		});
		player2DropDown.selectedLabel = _song.player2;
		var player2Label = new FlxText(140,80,64,'Player 2');
	
		// Player 3
		var player3DropDown = new FlxUIDropDownMenu(270, 100, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player3 = characters[Std.parseInt(character)];
		});
		player3DropDown.selectedLabel = _song.player3;
		var player3Label = new FlxText(270,80,64,'Player 3 (OPTIONAL)');
	
		// GF
		var gfVersionDropDown = new FlxUIDropDownMenu(10, 200, FlxUIDropDownMenu.makeStrIdLabelArray(gfVersions, true), function(gfVersion:String)
		{
			_song.gfVersion = gfVersions[Std.parseInt(gfVersion)];
		});
		gfVersionDropDown.selectedLabel = _song.gfVersion;
		var gfVersionLabel = new FlxText(10,180,64,'Girlfriend');
	
		// Stage
		var stageDropDown = new FlxUIDropDownMenu(140, 200, FlxUIDropDownMenu.makeStrIdLabelArray(stages, true), function(stage:String)
		{
			_song.stage = stages[Std.parseInt(stage)];
		});
		stageDropDown.selectedLabel = _song.stage;
		var stageLabel = new FlxText(140,180,64,'Stage');
	
		// Note Style
		var noteStyleDropDown = new FlxUIDropDownMenu(270, 200, FlxUIDropDownMenu.makeStrIdLabelArray(noteStyles, true), function(noteStyle:String)
		{
			_song.noteStyle = noteStyles[Std.parseInt(noteStyle)];
		});
		noteStyleDropDown.selectedLabel = _song.noteStyle;
		var noteStyleLabel = new FlxText(10,280,64,'Note Skin');
	
		// Ready Set Style
		var readySetDropDown = new FlxUIDropDownMenu(10, 300, FlxUIDropDownMenu.makeStrIdLabelArray(readySetStyles, true), function(readySetStyle:String)
		{
			_song.readySetStyle = readySetStyles[Std.parseInt(readySetStyle)];
		});
		readySetDropDown.selectedLabel = _song.readySetStyle;
		var readySetLabel = new FlxText(140,380,64,'Countdown Style');
	
	
		var readySetAnim = new FlxUIDropDownMenu(140, 300, FlxUIDropDownMenu.makeStrIdLabelArray(readySetAnims, true), function(readySetAnim:String)
		{
			_song.readySetAnimation = readySetAnims[Std.parseInt(readySetAnim)];
		});
		readySetAnim.selectedLabel = _song.readySetStyle;
		var readySetAnimLabel = new FlxText(140,380,64,'Countdown Animation');

			
		
		var editorLabel = new FlxText(250, 120, 'Editor');
		var hitsounds = new FlxUICheckBox(400, 145, null, null, "Play\nhitsounds\n(In Editor)", 100);
		hitsounds.checked = false;
		hitsounds.callback = function()
		{
			playClaps = hitsounds.checked;
		};
		var stepperSongVolLabel = new FlxText(74, 110, 'Instrumental Volume');

		// Mute Inst
		var check_mute_inst = new FlxUICheckBox(400, 165, null, null, "Mute\nInstrumental\n(in editor)", 100);
		check_mute_inst.checked = false;
		check_mute_inst.callback = function()
		{
			var vol:Float = 1;
	
			if (check_mute_inst.checked)
			{
				vol = 0;
			}
			
			FlxG.sound.music.volume = vol;
		};

		// Character Data //
		
		var check_fly = new FlxUICheckBox(10, 60, null, null, "Dad floats?", 100);
		check_fly.checked = _song.charFly;
		check_fly.callback = function()
		{
			_song.charFly = check_fly.checked;
			trace('CHECKED!');
		};
		
		var check_flybf = new FlxUICheckBox(10, 25, null, null, "Boyfriend floats?", 100);
		check_flybf.checked = _song.bfFly;
		check_flybf.callback = function()
		{
			_song.bfFly = check_flybf.checked;
			trace('CHECKED!');
		};

		var check_dadtrail = new FlxUICheckBox(50, 25, null, null, "Dad has trail?", 100);
		check_dadtrail.checked = _song.dadHasTrail;
		check_dadtrail.callback = function()
		{
			_song.dadHasTrail = check_dadtrail.checked;
			trace('CHECKED!');
		};
		
		var stepperDadFlySpeedX:FlxUINumericStepper = new FlxUINumericStepper(10, 110, 0.1, 0.1, 0.001, 0.9);
		stepperDadFlySpeedX.value = _song.dadFlyX;
		stepperDadFlySpeedX.name = 'song_dfsx';
		var stepperDadFlySpeedXLabel = new FlxText(10,90,'Dad Float Speed X');

		// Section //
		
		var tab_group_section = new FlxUI(null, UI_box);
		tab_group_section.name = 'Section';

		stepperLength = new FlxUINumericStepper(10, 10, 4, 0, 0, 999, 0);
		stepperLength.value = _song.notes[curSection].lengthInSteps;
		stepperLength.name = "section_length";

		var stepperLengthLabel = new FlxText(74,10,'Section Length (in steps)');

		stepperSectionBPM = new FlxUINumericStepper(10, 80, 1, Conductor.bpm, 0, 999, 0);
		stepperSectionBPM.value = Conductor.bpm;
		stepperSectionBPM.name = 'section_bpm';


		var stepperCopy:FlxUINumericStepper = new FlxUINumericStepper(110, 132, 1, 1, -999, 999, 0);
		var stepperCopyLabel = new FlxText(174,132,'sections back');

		var copyButton:FlxButton = new FlxButton(10, 130, "Copy last section", function()
		{
			copySection(Std.int(stepperCopy.value));
		});


		check_p3sing = new FlxUICheckBox(140, 400, null, null, "Player 3 Singing", 100);
		check_p3sing.name = 'check_p3sing';


			
		var clearSectionButton:FlxButton = new FlxButton(10, 150, "Clear Section", clearSection);

		var swapSection:FlxButton = new FlxButton(10, 170, "Swap Section", function()
		{
			for (i in 0..._song.notes[curSection].sectionNotes.length)
			{
				var note = _song.notes[curSection].sectionNotes[i];
				note[1] = (note[1] + 4) % 8;
				_song.notes[curSection].sectionNotes[i] = note;
				updateGrid();
			}
		});
		check_mustHitSection = new FlxUICheckBox(10, 30, null, null, "Camera Points to P1?", 100);
		check_mustHitSection.name = 'check_mustHit';
		check_mustHitSection.checked = true;
		// _song.needsVoices = check_mustHit.checked;

		check_altAnim = new FlxUICheckBox(10, 400, null, null, "Alternate Animation", 100);
		check_altAnim.name = 'check_altAnim';

		check_changeBPM = new FlxUICheckBox(10, 60, null, null, 'Change BPM', 100);
		check_changeBPM.name = 'check_changeBPM';

		// Notes //

		writingNotesText = new FlxUIText(20,100, 0, "");
		writingNotesText.setFormat("Arial",20,FlxColor.WHITE,FlxTextAlign.LEFT,FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);

		stepperSusLength = new FlxUINumericStepper(10, 10, Conductor.stepCrochet / 2, 0, 0, Conductor.stepCrochet * _song.notes[curSection].lengthInSteps * 4);
		stepperSusLength.value = 0;
		stepperSusLength.name = 'note_susLength';

		var stepperSusLengthLabel = new FlxText(74,10,'Note Sustain Length');

		var applyLength:FlxButton = new FlxButton(10, 100, 'Apply Data');

		var types:Array<String> = [];
		
		types.push("default");
		for (string in sys.FileSystem.readDirectory("mods/note_types"))
		{
			types.push(string);
		}
		
		trace(types);
		
		notetypes = new FlxUIDropDownMenu(10, 100, FlxUIDropDownMenu.makeStrIdLabelArray(types, true), null);
		var notetypesLabel = new FlxText(10,80,64,'Note Type');


		// Triggers 

		var triggerBetaLabel = new FlxText(10,80,64,'Events Coming Soon!');
	

		var tab_group_song = new FlxUI(null, UI_box);
		tab_group_song.name = "Song";
		tab_group_song.add(UI_songTitle);
		tab_group_song.add(restart);
		tab_group_song.add(check_voices);
		tab_group_song.add(check_mute_inst);
		tab_group_song.add(realsaveButton); 
		tab_group_song.add(saveButton);
		tab_group_song.add(reloadSong);
		tab_group_song.add(reloadSongJson);
		tab_group_song.add(loadAutosaveBtn);
		tab_group_song.add(stepperBPM);
		tab_group_song.add(stepperBPMLabel);
		tab_group_song.add(stepperSpeed);
		tab_group_song.add(stepperSpeedLabel);
		tab_group_song.add(shiftNoteDialLabel);
		tab_group_song.add(stepperShiftNoteDial);
		tab_group_song.add(shiftNoteDialLabel2);
		tab_group_song.add(stepperShiftNoteDialstep);
		tab_group_song.add(shiftNoteDialLabel3);
		tab_group_song.add(stepperShiftNoteDialms);
		tab_group_song.add(shiftNoteButton);
		tab_group_song.add(check_dialogue);
		tab_group_song.add(dText);
		tab_group_song.add(stepperKEY);
		tab_group_song.add(stepperKEYLabel);
		UI_box.addGroup(tab_group_song);
	
		var tab_group_assets = new FlxUI(null, UI_box);
		tab_group_assets.name = "Assets";
		tab_group_assets.add(noteStyleDropDown);
		tab_group_assets.add(noteStyleLabel); 
		tab_group_assets.add(gfVersionDropDown);
		tab_group_assets.add(gfVersionLabel);
		tab_group_assets.add(readySetDropDown);
		tab_group_assets.add(readySetLabel);
		tab_group_assets.add(readySetAnim);
		tab_group_assets.add(readySetAnimLabel);
		tab_group_assets.add(stageDropDown);
		tab_group_assets.add(stageLabel);
		tab_group_assets.add(player1DropDown);
		tab_group_assets.add(player2DropDown);
		tab_group_assets.add(player3DropDown);
		tab_group_assets.add(player1Label);
		tab_group_assets.add(player2Label);
		tab_group_assets.add(player3Label);
		tab_group_song.add(stepperVocalVol);
		tab_group_song.add(stepperVocalVolLabel);
		tab_group_song.add(stepperSongVol);
		tab_group_song.add(stepperSongVolLabel);
		tab_group_song.add(hitsounds);
		UI_box.addGroup(tab_group_assets);

		var tab_group_cdata = new FlxUI(null, UI_box);
		tab_group_cdata.name = "Character";
		tab_group_cdata.add(check_fly);
		tab_group_cdata.add(check_flybf);
		tab_group_cdata.add(stepperDadFlySpeedX);
		tab_group_cdata.add(stepperDadFlySpeedXLabel);
		UI_box.addGroup(tab_group_cdata);

		var tab_group_section = new FlxUI(null, UI_box);
		tab_group_section.name = "Section";
		tab_group_section.add(stepperLength);
		tab_group_section.add(stepperLengthLabel);
		tab_group_section.add(stepperSectionBPM);
		tab_group_section.add(stepperCopy);
		tab_group_section.add(stepperCopyLabel);
		tab_group_section.add(check_mustHitSection);
		tab_group_section.add(check_altAnim);
		tab_group_section.add(check_changeBPM);
		tab_group_section.add(copyButton);
		tab_group_section.add(clearSectionButton);
		tab_group_section.add(swapSection);
		tab_group_section.add(check_p3sing);
		UI_box.addGroup(tab_group_section);

		var tab_group_note = new FlxUI(null, UI_box_objectData);
		tab_group_note.name = 'Note';
		tab_group_note.add(stepperSusLength);
		tab_group_note.add(stepperSusLengthLabel);
		tab_group_note.add(applyLength);
		tab_group_note.add(notetypes);
		tab_group_note.add(notetypesLabel);
		UI_box_objectData.addGroup(tab_group_note);


		var tab_group_events = new FlxUI(null, UI_box_objectData);
		tab_group_events .name = 'Events';
		tab_group_events.add(triggerBetaLabel);
		UI_box_objectData.addGroup(tab_group_events);
			
		UI_box.scrollFactor.set();
		UI_box_objectData.scrollFactor.set();
		FlxG.camera.follow(strumLine);
	}

	
	function loadSong(daSong:String):Void
	{
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
		}

		FlxG.sound.playMusic(Paths.inst(daSong), 0.6);

		vocals = new FlxSound().loadEmbedded(Paths.voices(daSong));
		FlxG.sound.list.add(vocals);
		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.onComplete = function()
		{
			vocals.pause();
			vocals.time = 0;
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
			changeSection();
		};
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUICheckBox.CLICK_EVENT)
		{
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch (label)
			{
				case 'Camera Points to P1?': _song.notes[curSection].mustHitSection = check.checked; FlxG.log.add('Cam points to p1 ' + check.checked);
				case 'Change BPM': _song.notes[curSection].changeBPM = check.checked; FlxG.log.add('Change Bpm ' + check.checked);
				case "Alternate Animation": _song.notes[curSection].altAnim = check.checked; FlxG.log.add('Alt Anim ' + check.checked);
				case "Player 3 Singing": _song.notes[curSection].player3Singing = check.checked; FlxG.log.add('P3 Sing ' + check.checked);
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			FlxG.log.add(wname);
			
			if (wname == 'section_length'){
				if (nums.value <= 4)
					nums.value = 4;
				_song.notes[curSection].lengthInSteps = Std.int(nums.value);
				updateGrid();
			}
			
			else if (wname == 'song_speed'){
				if (nums.value <= 0)
					nums.value = 0;
				_song.speed = nums.value;
			}
			
			else if (wname == 'song_bpm'){
				if (nums.value <= 0)
					nums.value = 1;
				tempBpm = Std.int(nums.value);
				Conductor.mapBPMChanges(_song);
				Conductor.changeBPM(Std.int(nums.value));
			}
			
			else if (wname == 'song_keys'){
				if (nums.value <= 0)
					nums.value = 1;
				_song.keyAmmount = Std.int(nums.value);
				updateGrid();
			}
			
			else if (wname == 'note_susLength'){
				if (curSelectedNote == null)
					return;

				if (nums.value <= 0)
					nums.value = 0;
				curSelectedNote[2] = nums.value;
				updateGrid();
			}
			
			else if (wname == 'section_bpm'){
				if (nums.value <= 0.1)
					nums.value = 0.1;
				_song.notes[curSection].bpm = Std.int(nums.value);
				updateGrid();
			}
			
			else if (wname == 'song_vocalvol'){
				if (nums.value <= 0.1)
					nums.value = 0.1;
				vocals.volume = nums.value;
			}
			
			else if (wname == 'song_instvol'){
				if (nums.value <= 0.1)
					nums.value = 0.1;
				FlxG.sound.music.volume = nums.value;
			}
		}
	}

	var updatedSection:Bool = false;

	function stepStartTime(step):Float
	{
		return _song.bpm / (step / 4) / 60;
	}

	function sectionStartTime():Float
	{
		var daBPM:Float = _song.bpm;
		var daPos:Float = 0;
		for (i in 0...curSection)
		{
			if (_song.notes[i].changeBPM)
			{
				daBPM = _song.notes[i].bpm;
			}
			daPos += 4 * (1000 * 60 / daBPM);
		}
		return daPos;
	}

	var writingNotes:Bool = false;
	var doSnapShit:Bool = true;

	override function update(elapsed:Float)
	{
		updateHeads();

		if (FlxG.keys.pressed.CONTROL)
		{
			if (FlxG.keys.pressed.S)
			{
				saveRealLevel();
				trace("Saved Level using Control + S");
			}
		}
		snapText.text = "Snap: 1/" + snap + " (" + (doSnapShit ? "Control to disable" : "Snap Disabled, Control to renable") + ")\nAdd Notes: 1-8 (or click)\n\n\n" + (fromSongMenu ? "ESCAPE to return to Songs" : "");

		if (fromSongMenu && FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.switchState(new FreeplayState());
		}

		curStep = recalculateSteps();

		if (FlxG.keys.justPressed.CONTROL)
			doSnapShit = !doSnapShit;

		Conductor.songPosition = FlxG.sound.music.time;
		_song.song = typingShit.text;

		var left = FlxG.keys.justPressed.E;
		var down = FlxG.keys.justPressed.R;
		var up = FlxG.keys.justPressed.T;
		var right = FlxG.keys.justPressed.Y;
		var leftO = FlxG.keys.justPressed.U;
		var downO = FlxG.keys.justPressed.I;
		var upO = FlxG.keys.justPressed.O;
		var rightO = FlxG.keys.justPressed.P;

		var pressArray = [left, down, up, right, leftO, downO, upO, rightO];
		var delete = false;
		curRenderedNotes.forEach(function(note:Note)
			{
				if (strumLine.overlaps(note) && pressArray[Math.floor(Math.abs(note.noteData))])
				{
					deleteNote(note);
					delete = true;
					trace('deelte note');
				}
			});
		for (p in 0...pressArray.length)
		{
			var i = pressArray[p];
			if (i && !delete)
			{
				addNote(new Note(Conductor.songPosition,p));
			}
		}

		strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps));
		


		if (playClaps)
		{
			curRenderedNotes.forEach(function(note:Note)
			{
				if (FlxG.sound.music.playing)
				{
					FlxG.overlap(strumLine, note, function(_, _)
					{
						if(!claps.contains(note))
						{
							claps.push(note);
							FlxG.sound.play(Paths.sound('SNAP'));
						}
					});
				}
			});
		}
		
		if (curBeat % 4 == 0 && curStep >= 16 * (curSection + 1))
		{
			trace(curStep);
			trace((_song.notes[curSection].lengthInSteps) * (curSection + 1));
			trace('DUMBSHIT');

			if (_song.notes[curSection + 1] == null)
			{
				addSection();
			}

			changeSection(curSection + 1, false);
		}

		FlxG.watch.addQuick('daBeat', curBeat);
		FlxG.watch.addQuick('daStep', curStep);

		if (FlxG.mouse.justPressed)
		{
			if (FlxG.mouse.overlaps(curRenderedNotes))
			{
				curRenderedNotes.forEach(function(note:Note)
				{
					if (FlxG.mouse.overlaps(note))
					{
						if (FlxG.keys.pressed.CONTROL)
						{
							selectNote(note);
						}
					}
				});
			}
			else
			{
				if (!FlxG.mouse.overlaps(curRenderedNotes))
				{
					if 
					(
						FlxG.mouse.x > gridBG.x
						&& FlxG.mouse.x < gridBG.x + gridBG.width
						&& FlxG.mouse.y > gridBG.y
						&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps)
					)
					{
						FlxG.log.add('added note');
						addNote();
					}
				}
			}
		}

		if (FlxG.mouse.pressedRight)
		{
			if (FlxG.mouse.overlaps(curRenderedNotes))
			{
				curRenderedNotes.forEach(function(note:Note)
				{
					if (FlxG.mouse.overlaps(note))
					{
						deleteNote(note);
					}
				});
			}
		}

		if (FlxG.mouse.x > gridBG.x
			&& FlxG.mouse.x < gridBG.x + gridBG.width
			&& FlxG.mouse.y > gridBG.y
			&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
		{
			dummyArrow.x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;
			if (FlxG.keys.pressed.SHIFT)
				dummyArrow.y = FlxG.mouse.y;
			else
				dummyArrow.y = Math.floor(FlxG.mouse.y / GRID_SIZE) * GRID_SIZE;
		}


		if (FlxG.keys.justPressed.ENTER)
		{
			lastSection = curSection;

			PlayState.SONG = _song;
			FlxG.sound.music.stop();
			vocals.stop();
			LoadingState.loadAndSwitchState(new PlayState());
		}

		if (FlxG.keys.justPressed.E)
		{
			changeNoteSustain(Conductor.stepCrochet);
		}
		if (FlxG.keys.justPressed.Q)
		{
			changeNoteSustain(-Conductor.stepCrochet);
		}


		if(FlxG.keys.justPressed.Z)
		{
			this.noteType - 1;
			if (noteType < 0)
			{
				noteType = styles.length - 1;
			}
		}
		if(FlxG.keys.justPressed.X)
		{
			this.noteType - 1;
			if (noteType > 0)
			{
				noteType = 0;
			}
		}

		if (FlxG.keys.justPressed.TAB)
		{
			if (FlxG.keys.pressed.SHIFT)
			{
				UI_box.selected_tab -= 1;
				if (UI_box.selected_tab < 0)
					UI_box.selected_tab = 2;
			}
			else
			{
				UI_box.selected_tab += 1;
				if (UI_box.selected_tab >= 3)
					UI_box.selected_tab = 0;
			}
		}

		if (!typingShit.hasFocus)
		{

			if (FlxG.keys.pressed.CONTROL)
			{
				if (FlxG.keys.justPressed.Z && lastNote != null)
				{
					trace(curRenderedNotes.members.contains(lastNote) ? "delete note" : "add note");
					if (curRenderedNotes.members.contains(lastNote))
						deleteNote(lastNote);
					else 
						addNote(lastNote);
				}
			}

			var shiftThing:Int = 1;
			if (FlxG.keys.pressed.SHIFT)
				shiftThing = 4;
			if (!FlxG.keys.pressed.CONTROL)
			{
				if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D)
					changeSection(curSection + shiftThing);
				if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A)
					changeSection(curSection - shiftThing);
			}	
			if (FlxG.keys.justPressed.SPACE)
			{
				if (FlxG.sound.music.playing)
				{
					FlxG.sound.music.pause();
					vocals.pause();
					claps.splice(0, claps.length);
				}
				else
				{
					vocals.play();
					FlxG.sound.music.play();
				}
			}

			if (FlxG.keys.justPressed.R)
			{
				if (FlxG.keys.pressed.SHIFT)
					resetSection(true);
				else
					resetSection();
			}

			
			if (FlxG.sound.music.time < 0 || curStep < 0)
				FlxG.sound.music.time = 0;

			if (FlxG.mouse.wheel != 0)
			{
				FlxG.sound.music.pause();
				vocals.pause();
				claps.splice(0, claps.length);

				var stepMs = curStep * Conductor.stepCrochet;


				trace(Conductor.stepCrochet / snap);

				if (doSnapShit)
					FlxG.sound.music.time = stepMs - (FlxG.mouse.wheel * Conductor.stepCrochet / snap);
				else
					FlxG.sound.music.time -= (FlxG.mouse.wheel * Conductor.stepCrochet * 0.4);
				trace(stepMs + " + " + Conductor.stepCrochet / snap + " -> " + FlxG.sound.music.time);

				vocals.time = FlxG.sound.music.time;
			}

			if (!FlxG.keys.pressed.SHIFT)
			{
				if (FlxG.keys.pressed.W || FlxG.keys.pressed.S)
				{
					FlxG.sound.music.pause();
					vocals.pause();
					claps.splice(0, claps.length);

					var daTime:Float = 700 * FlxG.elapsed;

					if (FlxG.keys.pressed.W)
					{
						FlxG.sound.music.time -= daTime;
					}
					else
						FlxG.sound.music.time += daTime;

					vocals.time = FlxG.sound.music.time;
				}
			}
			else
			{
				if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.S)
				{
					FlxG.sound.music.pause();
					vocals.pause();

					var daTime:Float = Conductor.stepCrochet * 2;

					if (FlxG.keys.justPressed.W)
					{
						FlxG.sound.music.time -= daTime;
					}
					else
						FlxG.sound.music.time += daTime;

					vocals.time = FlxG.sound.music.time;
				}
			}
		}

		_song.bpm = tempBpm;

		/* if (FlxG.keys.justPressed.UP)
				Conductor.changeBPM(Conductor.bpm + 1);
			if (FlxG.keys.justPressed.DOWN)
				Conductor.changeBPM(Conductor.bpm - 1); */

		bpmTxt.text = bpmTxt.text = 
			Std.string(FlxMath.roundDecimal(Conductor.songPosition / 1000, 2))
			+ " / "
			+ Std.string(FlxMath.roundDecimal(FlxG.sound.music.length / 1000, 2))
			+ "\nSection: "
			+ curSection 
			+ "\nStep: " 
			+ curStep
			+ "\nBeat: "
			+ curBeat
			+ "\nTempo: "
			+ _song.bpm;
		super.update(elapsed);
	}

	function changeNoteSustain(value:Float):Void
	{
		if (curSelectedNote != null)
		{
			if (curSelectedNote[2] != null)
			{
				curSelectedNote[2] += value;
				curSelectedNote[2] = Math.max(curSelectedNote[2], 0);
			}
		}

		updateNoteUI();
		updateGrid();
	}

	override function beatHit() 
	{
		trace('beat');

		super.beatHit();
		if (!player2.animation.curAnim.name.startsWith("sing"))
		{
			player2.playAnim('idle');
		}
		player1.dance();
	}

	function recalculateSteps():Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (FlxG.sound.music.time > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((FlxG.sound.music.time - lastChange.songTime) / Conductor.stepCrochet);
		updateBeat();

		return curStep;
	}

	function resetSection(songBeginning:Bool = false):Void
	{
		updateGrid();

		FlxG.sound.music.pause();
		vocals.pause();

		// Basically old shit from changeSection???
		FlxG.sound.music.time = sectionStartTime();

		if (songBeginning)
		{
			FlxG.sound.music.time = 0;
			curSection = 0;
		}

		vocals.time = FlxG.sound.music.time;
		updateCurStep();

		updateGrid();
		updateSectionUI();
	}

	function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void
	{
		trace('changing section' + sec);

		if (_song.notes[sec] != null)
		{
			trace('naw im not null');
			curSection = sec;

			updateGrid();

			if (updateMusic)
			{
				FlxG.sound.music.pause();
				vocals.pause();

				/*var daNum:Int = 0;
					var daLength:Float = 0;
					while (daNum <= sec)
					{
						daLength += lengthBpmBullshit();
						daNum++;
				}*/

				FlxG.sound.music.time = sectionStartTime();
				vocals.time = FlxG.sound.music.time;
				updateCurStep();
			}

			updateGrid();
			updateSectionUI();
		}
		else
			trace('bro wtf I AM NULL');
	}

	function copySection(?sectionNum:Int = 1)
	{
		var daSec = FlxMath.maxInt(curSection, sectionNum);

		for (note in _song.notes[daSec - sectionNum].sectionNotes)
		{
			var strum = note[0] + Conductor.stepCrochet * (_song.notes[daSec].lengthInSteps * sectionNum);

			var copiedNote:Array<Dynamic> = [strum, note[1], note[2]];
			_song.notes[daSec].sectionNotes.push(copiedNote);
		}

		updateGrid();
	}

	function updateSectionUI():Void
	{
		var sec = _song.notes[curSection];

		stepperLength.value = sec.lengthInSteps;
		check_mustHitSection.checked = sec.mustHitSection; // kinda broken with the new grid pos
		check_altAnim.checked = sec.altAnim;
		check_p3sing.checked = sec.player3Singing;
		check_changeBPM.checked = sec.changeBPM;
		stepperSectionBPM.value = sec.bpm;
	}

	function updateHeads():Void
	{
		if (check_mustHitSection.checked)
		{
			if (_song.player1 == "none")
			{
				remove(leftIcon);
			}
			else
			{
				leftIcon.animation.play(_song.player1);
			}

			
			if (_song.player2 == "none")
			{
				remove(rightIcon);
			}
			else
			{
				rightIcon.animation.play(_song.player2);
			}
			
			if (_song.player3 == "none")
			{
				remove(p3Icon);
			}
			else
			{
				p3Icon.animation.play(_song.player3);
			}
		}
		else
		{
			leftIcon.animation.play(_song.player2);
			rightIcon.animation.play(_song.player1);
			p3Icon.animation.play(_song.player3);
		}
	}

	function updateNoteUI():Void
	{
		if (curSelectedNote != null)
			stepperSusLength.value = curSelectedNote[2];
	}

	function updateGrid():Void
	{
		remove(gridBG);
		gridWidth = _song.keyAmmount * 2;
		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * gridWidth, GRID_SIZE * _song.notes[curSection].lengthInSteps, true, FlxColor.GRAY, FlxColor.BLACK);
        add(gridBG);

		remove(gridBlackLine);
		gridBlackLine = new FlxSprite(gridBG.x + gridBG.width / 2).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		add(gridBlackLine);
		
		while (curRenderedNotes.members.length > 0)
		{
			curRenderedNotes.remove(curRenderedNotes.members[0], true);
		}

		while (curRenderedSustains.members.length > 0)
		{
			curRenderedSustains.remove(curRenderedSustains.members[0], true);
		}

		var sectionInfo:Array<Dynamic> = _song.notes[curSection].sectionNotes;

		if (_song.notes[curSection].changeBPM && _song.notes[curSection].bpm > 0)
		{
			Conductor.changeBPM(_song.notes[curSection].bpm);
			FlxG.log.add('CHANGED BPM!');
		}
		else
		{
			// get last bpm
			var daBPM:Float = _song.bpm;
			for (i in 0...curSection)
				if (_song.notes[i].changeBPM)
					daBPM = _song.notes[i].bpm;
			Conductor.changeBPM(daBPM);
		}


		for (i in sectionInfo)
		{
			var daNoteInfo = i[1];
			var daStrumTime = i[0];
			var daSus = i[2];
			var daType = i[3];
			
			var note:Note;

			try
			{
				note = new Note(daStrumTime, daNoteInfo % 4,null,false,true);
			}
			catch(ex)
			{
				trace(ex);
				note = new Note(0, 0 % 4,null,false,true);
			}
			
			note.sustainLength = daSus;
			note.setGraphicSize(GRID_SIZE, GRID_SIZE);
			note.updateHitbox();
			note.x = Math.floor(daNoteInfo * GRID_SIZE);
			note.y = Math.floor(getYfromStrum((daStrumTime - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps)));

			if (curSelectedNote != null)
				if (curSelectedNote[0] == note.strumTime)
					lastNote = note;

			curRenderedNotes.add(note);

			if (daSus > 0)
			{
				var sustainVis:FlxSprite = new FlxSprite(note.x + (GRID_SIZE / 2),
					note.y + GRID_SIZE).makeGraphic(8, Math.floor(FlxMath.remapToRange(daSus, 0, Conductor.stepCrochet * _song.notes[curSection].lengthInSteps, 0, gridBG.height)));
				curRenderedSustains.add(sustainVis);
			}
		}
	}

	private function addSection(lengthInSteps:Int = 16):Void
	{
		var sec:SwagSection = {
			lengthInSteps: lengthInSteps,
			bpm: _song.bpm,
			changeBPM: false,
			mustHitSection: true,
			sectionNotes: [],
			typeOfSection: 0,
			altAnim: false,
			player3Singing: false
		};

		_song.notes.push(sec);
	}

	function selectNote(note:Note):Void
	{
		var swagNum:Int = 0;

		for (i in _song.notes[curSection].sectionNotes)
		{
			if (i.strumTime == note.strumTime && i.noteData % 4 == note.noteData)
			{
				curSelectedNote = _song.notes[curSection].sectionNotes[swagNum];
			}

			swagNum += 1;
		}

		updateGrid();
		updateNoteUI();
	}


	function deleteNote(note:Note):Void
		{
			lastNote = note;
			for (i in _song.notes[curSection].sectionNotes)
			{
				if (i[0] == note.strumTime && i[1] % 4 == note.noteData)
				{
					_song.notes[curSection].sectionNotes.remove(i);
				}
			}
	
			updateGrid();
		}

	function clearSection():Void
	{
		_song.notes[curSection].sectionNotes = [];

		updateGrid();
	}

	function clearSong():Void
	{
		for (daSection in 0..._song.notes.length)
		{
			_song.notes[daSection].sectionNotes = [];
		}

		updateGrid();
	}

	private function newSection(lengthInSteps:Int = 16,mustHitSection:Bool = false,altAnim:Bool = true, player3Singing:Bool = false):SwagSection
		{
			var sec:SwagSection = {
				lengthInSteps: lengthInSteps,
				bpm: _song.bpm,
				changeBPM: false,
				mustHitSection: mustHitSection,
				sectionNotes: [],
				typeOfSection: 0,
				altAnim: altAnim,
				player3Singing: player3Singing
			};

			return sec;
		}

	function shiftNotes(measure:Int=0,step:Int=0,ms:Int = 0):Void
		{
			var newSong = [];
			
			var millisecadd = (((measure*4)+step/4)*(60000/_song.bpm))+ms;
			var totaladdsection = Std.int((millisecadd/(60000/_song.bpm)/4));
			trace(millisecadd,totaladdsection);
			if(millisecadd > 0)
				{
					for(i in 0...totaladdsection)
						{
							newSong.unshift(newSection());
						}
				}
			for (daSection1 in 0..._song.notes.length)
				{
					newSong.push(newSection(16,_song.notes[daSection1].mustHitSection,_song.notes[daSection1].altAnim));
				}
	
			for (daSection in 0...(_song.notes.length))
			{
				var aimtosetsection = daSection+Std.int((totaladdsection));
				if(aimtosetsection<0) aimtosetsection = 0;
				newSong[aimtosetsection].mustHitSection = _song.notes[daSection].mustHitSection;
				newSong[aimtosetsection].altAnim = _song.notes[daSection].altAnim;
				//trace("section "+daSection);
				for(daNote in 0...(_song.notes[daSection].sectionNotes.length))
					{	
						var newtiming = _song.notes[daSection].sectionNotes[daNote][0]+millisecadd;
						if(newtiming<0)
						{
							newtiming = 0;
						}
						var futureSection = Math.floor(newtiming/4/(60000/_song.bpm));
						_song.notes[daSection].sectionNotes[daNote][0] = newtiming;
						newSong[futureSection].sectionNotes.push(_song.notes[daSection].sectionNotes[daNote]);
	
						//newSong.notes[daSection].sectionNotes.remove(_song.notes[daSection].sectionNotes[daNote]);
					}
	
			}
			//trace("DONE BITCH");
			_song.notes = newSong;
			updateGrid();
			updateSectionUI();
			updateNoteUI();
		}
	private function addNote(?n:Note):Void
	{
		var noteStrum = getStrumTime(dummyArrow.y) + sectionStartTime();
		var noteData = Math.floor(FlxG.mouse.x / GRID_SIZE);
		var noteSus = 0;
		var noteType = styles[this.noteType];

		
		if (n != null)
			_song.notes[curSection].sectionNotes.push([n.strumTime, n.noteData, n.sustainLength]);
		else
			_song.notes[curSection].sectionNotes.push([noteStrum, noteData, noteSus, noteType]);

		var thingy = _song.notes[curSection].sectionNotes[_song.notes[curSection].sectionNotes.length - 1];

		curSelectedNote = thingy;


		updateGrid();
		updateNoteUI();

		autosaveSong();
	}
	

	function getStrumTime(yPos:Float):Float
	{
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height, 0, 16 * Conductor.stepCrochet);
	}

	function getYfromStrum(strumTime:Float):Float
	{
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height);
	}

	/*
		function calculateSectionLengths(?sec:SwagSection):Int
		{
			var daLength:Int = 0;

			for (i in _song.notes)
			{
				var swagLength = i.lengthInSteps;

				if (i.typeOfSection == Section.COPYCAT)
					swagLength * 2;

				daLength += swagLength;

				if (sec != null && sec == i)
				{
					trace('swag loop??');
					break;
				}
			}

			return daLength;
	}*/
	private var daSpacing:Float = 0.3;

	function loadLevel():Void
	{
		trace(_song.notes);
	}

	function getNotes():Array<Dynamic>
	{
		var noteData:Array<Dynamic> = [];

		for (i in _song.notes)
		{
			noteData.push(i.sectionNotes);
		}

		return noteData;
	}

	function loadJson(song:String):Void
	{
		PlayState.SONG = Song.loadFromJson(song.toLowerCase(), song.toLowerCase());
		LoadingState.loadAndSwitchState(new ChartingState());
	}

	function loadAutosave():Void
	{
		PlayState.SONG = Song.parseJSONshit(FlxG.save.data.autosave);
		LoadingState.loadAndSwitchState(new ChartingState());
	}

	function autosaveSong():Void
	{
		FlxG.save.data.autosave = Json.stringify({
			"song": _song
		});
		FlxG.save.flush();
	}

	private function saveLevel()
	{
		var json = {
			"song": _song
		};

		var data:String = Json.stringify(json);

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), Utility.difficultyFromInt(GlobalData.latestDiff).toLowerCase() + ".funkin");
		}
	}

	private function saveRealLevel()
	{
		var json = 
		{
			"song": _song
		};
	
		var data:String = Json.stringify(json);
	
		sys.io.File.saveContent("songs/" + _song.song.toLowerCase().replace(" ", "-") + "/" +  Utility.difficultyFromInt(GlobalData.latestDiff).toLowerCase() + ".funkin", data);
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}

	function defaultChart()
	{
		_song = 
		{
			song: 'New Song',
			artist: '',
			notes: [],
			bpm: 150,
			needsVoices: true,
			player1: 'bf',
			player2: 'dad',
			player3: 'none',
			gfVersion: 'gf',
			noteStyle: 'normal',
			readySetStyle: 'default',
			readySetAnimation: 'Bounce',
			stage: 'stage',
			speed: 1,
			dadFlyX: 0.1,
			validScore: false,
			bfFly: false,
			charFly: false,
			dadHasTrail: false,
			hasDialogue: false,
			keyAmmount: 4
		};
	}
}
