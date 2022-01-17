package;

import flixel.tweens.FlxEase;
#if desktop
import Discord.DiscordClient;
#end
import editors.ChartingState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText; 
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import flixel.system.FlxSound;
import openfl.utils.Assets as OpenFlAssets;
import WeekData;
import Character;
import ModList.modNum as modNum;
import ModList.modCats as modCats;
#if MODS_ALLOWED
import sys.FileSystem;
#end

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	
	var selector:FlxText;
	private static var curSelected:Int = 0;
	var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = '';

	var scoreBG:FlxSprite;
	var textBG:FlxSprite;
	var text:FlxText;

	var charName:Alphabet;
	private var boyfriendo:Boyfriend;
	var chara:Array<String>;


	var scoreText:FlxText;
	var modName:FlxText;
	var chooseT:Alphabet;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var icon:HealthIcon;
	private var keyIcons:FlxTypedGroup<FlxSprite>;
	private var freeArrow:FlxSprite; 
	private var curPlaying:Bool = false;
	private var keyArray:Array<Dynamic>;

	private var iconArray:Array<HealthIcon> = [];
	private var icons:FlxTypedGroup<HealthIcon>;

	var bg:FlxSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;
	//private static var BFs:Array<String> = ["bf", "bf-holding-gf", "bf-pixel"];
	//private static var BFSprs:Array<String> = ["BOYFRIEND", "bfAndGF", "bfPixel"];
	//private static var BFName:Array<String> = ["BF", "BF and GF", "Pixel BF"];
	var bfList:BfSelect;
	var charTime:Bool = false;
	var moveScore:Bool = false;
	var logo:FlxSprite;
	var ofs:Int;

	var canControl:Bool = true;
	
	override function create()
	{
		#if MODS_ALLOWED
		Paths.destroyLoadedImages();
		#end
		
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		modCats = CoolUtil.coolTextFile(Paths.getPreloadPath('moddies/mods.txt'));

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		
		/*		//KIND OF BROKEN NOW AND ALSO PRETTY USELESS//

		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));
		for (i in 0...initSonglist.length)
		{
			if(initSonglist[i] != null && initSonglist[i].length > 0) {
				var songArray:Array<String> = initSonglist[i].split(":");
				addSong(songArray[0], 0, songArray[1], Std.parseInt(songArray[2]));
			}
		}*/

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		scoreText = new FlxText(FlxG.width * 0.5, FlxG.height * 0.6, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
		

		scoreBG = new FlxSprite(scoreText.x+(scoreText.width/2), FlxG.height * 0.6).makeGraphic(1, 66, 0xFF000000);
		scoreBG.alpha = 0.6;

		charName = new Alphabet(0, FlxG.height * 0.4, "<  >", true);
		charName.x = (FlxG.width/2) - (charName.width / 2);
		charName.y = 0 - charName.height;
		//charName = new FlxText(FlxG.width * 0.9, FlxG.height * 0.4, 0, "test", 24);
		//charName.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER);

		diffText = new FlxText(scoreText.x - 6, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;


		
		boyfriendo = new Boyfriend(0, 0, 'characters/BOYFRIEND');
		boyfriendo.setGraphicSize(Std.int(boyfriendo.width * 0.5), Std.int(boyfriendo.height * 0.5));
		boyfriendo.updateHitbox();
		
		chooseT = new Alphabet (0, FlxG.height * 0.5, "select your bf", true);
		chooseT.x = (FlxG.width/2) - (chooseT.width / 2);
		chooseT.y = 0 - chooseT.height;
		chooseT.changeText("select your bf");
		chooseT.alpha = 0;

		logo = new FlxSprite(845, 115);
		if (modNum == 0) {
			ofs = 40;
			logo.x -= ofs;
		} else {
			ofs = 0;
		}
		freeArrow = new FlxSprite(0, 0).loadGraphic(Paths.image('free_arrow'));
		//add(freeArrow);
		
		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);
		icons = new FlxTypedGroup<HealthIcon>();
		add(icons);
		keyIcons = new FlxTypedGroup<FlxSprite>();

		add(scoreBG);
		charName.alpha = 0;
		boyfriendo.alpha = 0;
		add(charName);
		add(diffText);
		add(scoreText);
		add(chooseT);
		add(logo);
		

		
		//changeChar(0);

		textBG = new FlxSprite(0, FlxG.height - 52).makeGraphic(FlxG.width, 52, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);


		#if PRELOAD_ALL
		var size:Int = 16;
		#else
		var leText:String = "Back:   | Switch Mod:      | Modifiers:    | Switch Song:       | Change Difficulty:      | Select:    ";
		var size:Int = 18;
		#end
		text = new FlxText(textBG.x, textBG.y + 4 + 13, FlxG.width, leText, size);
		text.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, LEFT);
		text.scrollFactor.set();
		modName = new FlxText(FlxG.width * 0.9, textBG.y + 4 + 13, 0, "", 24);
		modName.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, CENTER);
		add(modName);
		add(text);
		add(keyIcons);


		reloadWeeks();
		keyBinds([['esckey', 60, 20], ['brackets', 225, 3], ['ctrlkey', 415, 15], ['updown', 605, 3], ['leftright', 890, 3], ['enter', 1050, 15]]);

		super.create();
	}

	override function closeSubState() {
		changeSelection(0, false);
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
	}

	/*public function addWeek(songs:Array<String>, weekNum:Int, weekColor:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);
			this.songs[this.songs.length-1].color = weekColor;

			if (songCharacters.length != 1)
				num++;
		}
	}*/

	var instPlaying:Int = -1;
	private static var vocals:FlxSound = null;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, CoolUtil.boundTo(elapsed * 12, 0, 1));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(Highscore.floorDecimal(lerpRating * 100, 2)).split('.');
		if(ratingSplit.length < 2) { //No decimals, add an empty space
			ratingSplit.push('');
		}
		
		while(ratingSplit[1].length < 2) { //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}
		if (charTime) {
			modName.text = '[' + (Character.curBF+1) + '/' + bfList.chars.length + ']';
		} else {
			modName.text = '[' + (modNum+1) + '/' + modCats.length + ']';
		}
		
		scoreText.text = 'HIGHSCORE: ' + lerpScore + ' (' + ratingSplit.join('.') + '%)';
		positionHighscore();

		

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;
		var space = FlxG.keys.justPressed.SPACE;
		var ctrl = FlxG.keys.justPressed.CONTROL;
		

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;
		if (charTime && boyfriendo.animation.curAnim.finished && boyfriendo.animation.getByName('idle-l') != null)
			{
				boyfriendo.playAnim('idle-l');
			}
		if (canControl)
		{
			if (upP)
			{
				if (!charTime) {
					changeSelection(-shiftMult);
				}
			}
			if (downP)
			{
				if (!charTime) {
					changeSelection(shiftMult);
				}
			}

			if (controls.UI_LEFT_P)
				if (charTime) {
					changeChar(-1);
				} else {
					changeDiff(-1);
				}
			else if (controls.UI_RIGHT_P)
				if (charTime) {
					changeChar(1);
				} else {
					changeDiff(1);
				}
			else if (upP || downP) changeDiff();
			if (!charTime) {
				if (FlxG.keys.justPressed.LBRACKET)
					changeMod(-1);
				else if (FlxG.keys.justPressed.RBRACKET)
					changeMod(1);
			}



			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				if (charTime) {
					
					tweenBinds(false);
					FlxTween.tween(chooseT, {y: 0 - chooseT.height }, 0.2, { ease: FlxEase.quadOut } );
					FlxTween.tween(charName, {y: 0 - charName.height }, 0.2, { ease: FlxEase.quadOut } );
					FlxTween.tween(boyfriendo, { y: -FlxG.height }, 0.3, { ease: FlxEase.quadOut, onComplete: songSelectSwitch } );
				} else {
					if(colorTween != null) {
						colorTween.cancel();
					}
					MusicBeatState.switchState(new MainMenuState());
				}
				
			}

				if(ctrl)
					{
						openSubState(new GameplayChangersSubstate());
					}
			

			else if(space)
			{
				if(instPlaying != curSelected)
				{
					#if PRELOAD_ALL
					destroyFreeplayVocals();
					FlxG.sound.music.volume = 0;
					Paths.currentModDirectory = songs[curSelected].folder;
					var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
					PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
					if (PlayState.SONG.needsVoices)
						vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
					else
						vocals = new FlxSound();

					FlxG.sound.list.add(vocals);
					FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.7);
					vocals.play();
					vocals.persist = true;
					vocals.looped = true;
					vocals.volume = 0.7;
					instPlaying = curSelected;
					#end
				}
			}

			else if (accepted)
			{
				var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
				var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
				/*#if MODS_ALLOWED
				if(!sys.FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop)) && !sys.FileSystem.exists(Paths.json(songLowercase + '/' + poop))) {
				#else
				if(!OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop))) {
				#end
					poop = songLowercase;
					curDifficulty = 1;
					trace('Couldnt find file');
				}*/
				trace(poop);

				PlayState.SONG = Song.loadFromJson(poop, songLowercase);
				PlayState.isStoryMode = false;
				bfList = Character.getBFs('images/characters/bflist.json');
				PlayState.storyDifficulty = curDifficulty;
				chara = bfList.chars[Character.curBF];
				PlayState.daPlayer = chara[0];

				trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
				if(colorTween != null) {
					colorTween.cancel();
				}
				if (FlxG.keys.pressed.SHIFT){
					LoadingState.loadAndSwitchState(new ChartingState());
					FlxG.sound.music.volume = 0;
						
					destroyFreeplayVocals();
				} else if (charTime) {
					toggleControl(false);
					
					FlxG.sound.play(Paths.sound('gameOverEnd'), 0.7);
					FlxTween.tween(FlxG.sound.music, { volume: 0 }, 0.8, { onComplete: loadSong });
					boyfriendo.playAnim('hey', true);
					if (boyfriendo.animation.curAnim != boyfriendo.animation.getByName('hey')) {
						boyfriendo.playAnim('singUP', true);
					}
					destroyFreeplayVocals();
				} else {
					toggleControl(false);
					moveScore = true;
					FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
					FlxTween.tween(logo, { x: FlxG.width }, 0.2, { ease: FlxEase.quadIn });
					FlxTween.tween(scoreText, { x: FlxG.width }, 0.2, { ease: FlxEase.quadIn });
					for (i in grpSongs.members) {
						FlxTween.tween(i, { x: -1200 }, 0.2, { ease: FlxEase.quadIn, onComplete: charSwitchingTime });
					}
					
				}
				tweenBinds(false);


			}
			else if(controls.RESET)
			{
				openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
		}
		super.update(elapsed);
	}

	public static function destroyFreeplayVocals() {
		if(vocals != null) {
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length-1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		lastDifficultyName = CoolUtil.difficulties[curDifficulty];

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		PlayState.storyDifficulty = curDifficulty;
		diffText.text = '< ' + CoolUtil.difficultyString() + ' >';
		positionHighscore();
	}

	function changeColor() {
		var newColor:Int = songs[curSelected].color;
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;
		changeColor();
/* 		var newColor:Int = songs[curSelected].color;
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		} */

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;
		//freeArrow.screenCenter(Y);
		//FlxTween.tween(freeArrow, {x: (grpSongs.members[curSelected].width + iconArray[curSelected].width + 10) }, 0.3, { ease: FlxEase.quadInOut } );
		for (item in grpSongs.members)
		{
			
			item.targetY = bullShit - curSelected;
			
			bullShit++;


			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
		
		Paths.currentModDirectory = songs[curSelected].folder;
		PlayState.storyWeek = songs[curSelected].week;

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if(diffStr != null) diffStr = diffStr.trim(); //Fuck you HTML5

		if(diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if(diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if(diffs[i].length < 1) diffs.remove(diffs[i]);
				}
				--i;
			}

			if(diffs.length > 0 && diffs[0].length > 0)
			{
				CoolUtil.difficulties = diffs;
			}
		}
		
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(CoolUtil.defaultDifficulty)));
		var newPos:Int = CoolUtil.difficulties.indexOf(lastDifficultyName);
		//trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		if(newPos > -1)
		{
			curDifficulty = newPos;
		}
	}

	private function positionHighscore() {
		//scoreText.x = FlxG.width - scoreText.width - 6;
		if (charTime && moveScore) {

		} else if (!moveScore) {
			scoreText.x = 1018-(scoreText.width/2);
		}
		
		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		//scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
		
		scoreBG.x = scoreText.x+(scoreText.width/2);
		trace(logo.width);
		diffText.x = (scoreText.x + (scoreText.width/2))-(diffText.width/2);
		modName.x = FlxG.width - modName.width - 5;
		
		
	}
	private function keyBinds(array:Array<Dynamic>) {
		keyArray = array;
		keyIcons.clear();
		for (i in 0...array.length) {
			var key:FlxSprite = new FlxSprite(0, FlxG.height);
			key.frames = Paths.getSparrowAtlas('keys');
			key.animation.addByPrefix('butt', array[i][0], 1, false);
			key.setGraphicSize(Std.int(key.width * 0.12));
			key.updateHitbox();
			keyIcons.add(key);
			key.animation.play('butt');
			key.x = array[i][1];
			tweenBinds(true);
		}
	}

	function changeMod(change:Int = 0) {
		modNum += change;
		if (modNum > modCats.length-1)
			modNum = 0;
		if (modNum < 0)
			modNum = modCats.length-1;

		if (modNum == 0) {
			ofs = 40;
		} else {
			ofs = 0;
		}
		//WeekData.modNum = modNum;
		WeekData.reloadWeekFiles(false);
		for (songl in grpSongs.members) {
			FlxTween.tween(songl, { x: -1000 }, 0.2, { ease: FlxEase.quadIn });
		}
		FlxTween.tween(logo, { x: FlxG.width }, 0.2, { ease: FlxEase.quadIn });
		FlxTween.tween(grpSongs.members[curSelected], { x: -1200 }, 0.2, { ease: FlxEase.quadIn, onComplete: doneTween });	
	}

	function doneTween(tween:FlxTween):Void {
		FlxTween.tween(logo, { x: 845 - ofs }, 0.3, { ease: FlxEase.quadOut });
		FlxTween.tween(scoreText, { x: 1018-(scoreText.width/2) }, 0.3, { ease: FlxEase.quadOut, onComplete: scoreMove });
		reloadWeeks();
	}

	function loadSong(tween:FlxTween):Void {
		LoadingState.loadAndSwitchState(new PlayState());
	}
	function reloadWeeks() {
		
		songs = [];
		
		if (logo.graphic != Paths.image('storylogos/' + modCats[modNum])) {
			logo.loadGraphic(Paths.image('storylogos/' + modCats[modNum]));
			logo.setGraphicSize(Std.int(logo.width * 0.5));
			logo.updateHitbox();
		}


		
		bfList = Character.getBFs('images/characters/bflist.json');
		for (i in 0...WeekData.weeksList.length) {
			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];
			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				var colors:Array<Int> = song[2];
				if(colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
			}
		}
		WeekData.setDirectoryFromWeek();
		
		grpSongs.clear();
		iconArray = [];
		icons.clear();

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.x = -1000;
			songText.targetY = i;
			FlxTween.tween(songText, { x: 20 }, 0.3, { ease: FlxEase.quadOut });
			
			grpSongs.add(songText);
			
			Paths.currentModDirectory = songs[i].folder;
			icon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;
			// Centering X
			//songText.x = (FlxG.width / 2) - ((songText.width + icon.width) / 2);
			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			icons.add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}
		
		WeekData.setDirectoryFromWeek();

		if(curSelected >= songs.length) curSelected = 0;
		changeColor();
		//bg.color = songs[curSelected].color;
		//intendedColor = bg.color;

		if(lastDifficultyName == '')
		{
			lastDifficultyName = CoolUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));
		
		changeSelection();
		changeDiff();

		
	}

	function changeChar(change:Int=0) {
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		bfList = Character.getBFs('images/characters/bflist.json');
		Character.curBF += change;
		var bY:Float = (FlxG.height / 2) - (boyfriendo.height / 2);

		if (Character.curBF < 0)
			Character.curBF = bfList.chars.length-1;
		else if (Character.curBF > bfList.chars.length-1)
			Character.curBF = 0;

		remove(boyfriendo);
		if (Character.curBF == 0)
			boyfriendo = new Boyfriend(0, bY - 260, 'bf');
		else
			boyfriendo = new Boyfriend(0, bY - 260, bfList.chars[Character.curBF][0]);
		boyfriendo.updateHitbox();
		boyfriendo.setGraphicSize(Std.int(boyfriendo.width * 0.8), Std.int(boyfriendo.height * 0.8));
		boyfriendo.updateHitbox();
		boyfriendo.animation.addByPrefix('idle-l', 'idle-l', 24, true);
		boyfriendo.playAnim('idle-l');
		

		boyfriendo.updateHitbox();
		boyfriendo.x = (FlxG.width / 2) - (boyfriendo.width / 2) - 50;
		boyfriendo.x += boyfriendo.positionArray[0];
		boyfriendo.y += boyfriendo.positionArray[1];
		add(boyfriendo);
		boyfriendo.dance();
		charName.changeText('< ' + bfList.chars[Character.curBF][1] + ' >');
		
		charName.x = (FlxG.width/2) - (charName.width / 2);


	}

	// Character Selection Shit
	function charSwitchingTime(tween:FlxTween) {
		charTime = true;
		toggleControl(true);
		text.text = "Back:    | Switch Character:      | Funk:    ";
		keyBinds([['esckey', 60, 20], ['leftright', 300, 3], ['enter', 435, 15]]);
		charName.alpha = 1;
		FlxTween.tween(chooseT, {y: 10 }, 0.2, { ease: FlxEase.quadOut } );
		FlxTween.tween(charName, {y: 100 }, 0.2, { ease: FlxEase.quadOut } );
		chooseT.alpha = 1;
		
		boyfriendo.alpha = 1;

		changeChar(0);

		boyfriendo.y = -FlxG.height;
		var bfY:Float = (FlxG.height / 2) - (boyfriendo.height / 2);
		FlxTween.tween(boyfriendo, { y: bfY + 90 }, 0.3, { ease: FlxEase.quadOut } );
	}
	function tweenBinds(show:Bool) {
		if (show) {
			FlxTween.tween(textBG, { y: FlxG.height - 52 }, 0.2, { ease: FlxEase.quadOut } );
			FlxTween.tween(text, { y: (FlxG.height-52) + 4 + 13 }, 0.2, { ease: FlxEase.quadOut } );
			FlxTween.tween(modName, { y: (FlxG.height-52) + 4 + 13 }, 0.2, { ease: FlxEase.quadOut } );
			for (i in 0...keyIcons.members.length) {
				FlxTween.tween(keyIcons.members[i], { y: (FlxG.height - 52) + keyArray[i][2] }, 0.2, { ease: FlxEase.quadOut } );
			}
		} else {
			FlxTween.tween(textBG, { y: FlxG.height }, 0.2, { ease: FlxEase.quadIn } );
			FlxTween.tween(text, { y: FlxG.height }, 0.2, { ease: FlxEase.quadIn } );
			FlxTween.tween(modName, { y: FlxG.height }, 0.2, { ease: FlxEase.quadIn } );
			for (i in 0...keyIcons.members.length) {
				FlxTween.tween(keyIcons.members[i], { y: FlxG.height }, 0.2, { ease: FlxEase.quadIn } );
			}
		}
	}
	function songSelectSwitch(tween:FlxTween) {
		charTime = false;
		reloadWeeks();
		changeMod(0);
		toggleControl(true);
		text.text = "Back:   | Switch Mod:      | Modifiers:    | Switch Song:       | Change Difficulty:      | Select:    ";
		keyBinds([['esckey', 60, 20], ['brackets', 225, 3], ['ctrlkey', 415, 15], ['updown', 605, 3], ['leftright', 890, 3], ['enter', 1050, 15]]);
	}

	function toggleControl(control:Bool) {
		canControl = control;
	}
	function scoreMove(tween:FlxTween) {
		moveScore = false;
	}

}


class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";

	public function new(song:String, week:Int, songCharacter:String, color:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Paths.currentModDirectory;
		if(this.folder == null) this.folder = '';
	}
}