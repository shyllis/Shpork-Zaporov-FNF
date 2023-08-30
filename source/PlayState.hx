package;

import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import ui.PreferencesMenu;

using StringTools;

#if discord_rpc
import Discord.DiscordClient;
#end

class PlayState extends MusicBeatState {
	public static var SONG:SwagSong;

	private var vocals:FlxSound;
	private var vocalsFinished:Bool = false;

	private var boyfriend:Boyfriend;

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	private var strumLine:FlxSprite;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;
	private var cpuStrums:FlxTypedGroup<FlxSprite>;

	private var curSong:String = "";

	private var health:Float = 2;

	private var healthBar:FlxBar;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	var songScore:Int = 0;
	var scoreTxt:FlxText;

	var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public static var campaignScore:Int = 0;

	var daCamZoom:Float = 0.85;

	var boombox:FlxSprite;
	var gitara:FlxSprite;

	#if discord_rpc
	var songLength:Float = 0;
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	var camPos:FlxPoint;
	
	override public function create() {
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		FlxG.sound.cache(Paths.inst(PlayState.SONG.song));
		FlxG.sound.cache(Paths.voices(PlayState.SONG.song));

		bgColor = 0xFF000000;

		camGame = new SwagCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);

		persistentUpdate = true;
		persistentDraw = true;

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		#if discord_rpc
		detailsText = "SHPORK ZAPOROV";
		detailsPausedText = "Paused - " + detailsText;

		DiscordClient.changePresence(detailsText, SONG.song);
		#end


		if (SONG.song.toLowerCase().endsWith('drip')) {
			var bg:BGSprite = new BGSprite('bgdrip', 200, 400, 1, 1);
			bg.setGraphicSize(Std.int(bg.width * 2));
			add(bg);

			if (SONG.song.toLowerCase().startsWith('shpork')) {
				boombox = new FlxSprite(390, 710);
				boombox.frames = Paths.getSparrowAtlas('boombox');
				boombox.animation.addByPrefix('sex', 'boombox', 24);
				add(boombox);
			} else if (SONG.song.toLowerCase().startsWith('govnoed')) {
				gitara = new FlxSprite(330, 580);
				gitara.frames = Paths.getSparrowAtlas('gitara');
				gitara.animation.addByPrefix('sex', 'gitara', 24);
				add(gitara);

				boombox = new FlxSprite(1100, 710);
				boombox.frames = Paths.getSparrowAtlas('boombox');
				boombox.animation.addByPrefix('sex', 'boombox', 24);
				boombox.flipX = true;
				add(boombox);
			}
		} else {
			var bg:BGSprite = new BGSprite('bg', 0, -50, 1, 1);
			bg.setGraphicSize(Std.int(bg.width * 2.4));
			add(bg);

			if (SONG.song.toLowerCase().startsWith('shpork')) {
				boombox = new FlxSprite(390, 710);
				boombox.frames = Paths.getSparrowAtlas('boombox');
				boombox.animation.addByPrefix('sex', 'boombox', 24);
				add(boombox);
			} else if (SONG.song.toLowerCase().startsWith('govnoed')) {
				gitara = new FlxSprite(330, 580);
				gitara.frames = Paths.getSparrowAtlas('gitara');
				gitara.animation.addByPrefix('sex', 'gitara', 24);
				add(gitara);
			}
		}

		boyfriend = new Boyfriend(770, 450, SONG.player1);
		add(boyfriend);

		healthBar = new FlxBar(boyfriend.getGraphicMidpoint().x, boyfriend.y - 80, LEFT_TO_RIGHT, 133, 24, this, 'health', 0, 2);
		healthBar.createImageBar(Paths.image('hpploho', 'shared'), Paths.image('hpklassno', 'shared'));
		healthBar.x -= Std.int(healthBar.width / 2);
		add(healthBar);

		camPos = new FlxPoint(boyfriend.getGraphicMidpoint().x, boyfriend.getGraphicMidpoint().y - 90);

		Conductor.songPosition = -2000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);

		if (PreferencesMenu.getPref('downscroll'))
			strumLine.y = FlxG.height - 150;

		strumLine.scrollFactor.set();

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();
		add(grpNoteSplashes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		cpuStrums = new FlxTypedGroup<FlxSprite>();

		generateSong();

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null) {
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		FlxG.camera.zoom = daCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		scoreTxt = new FlxText(20, (FlxG.height * 0.9) + 30, 0, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		add(scoreTxt);

		grpNoteSplashes.cameras = [camHUD];
		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];

		startingSong = true;

		#if mobile
		addHitbox(false);
		addHitboxCamera(false);
		#end

		startCountdown();

		super.create();
	}

	var startTimer:FlxTimer = new FlxTimer();

	function startCountdown():Void {
		camHUD.visible = true;
		#if mobile
		hitbox.visible = true;
		#end

		generateStaticArrows(0);
		generateStaticArrows(1);

		startedCountdown = true;

		var swagCounter:Int = 0;

		startTimer.start(Conductor.crochet / 1000, function(tmr:FlxTimer) {
			if (swagCounter % 2 == 0) {
				if (!boyfriend.animation.curAnim.name.startsWith("sing"))
					boyfriend.playAnim('idle');
			}

			if (generatedMusic)
				notes.sort(sortNotes, FlxSort.DESCENDING);
			
			if (swagCounter != 0) {
				var spr:FlxSprite = new FlxSprite().loadGraphic(Paths.image('kakahi', 'shared'));
				spr.scrollFactor.set();
				spr.setGraphicSize(Std.int(spr.width * 1.4));
				spr.updateHitbox();
				spr.screenCenter();
				add(spr);
	
				FlxTween.tween(spr, {alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.cubeInOut,
					onComplete: function(twn:FlxTween) {
						spr.destroy();
					}
				});
	
				FlxG.sound.play(Paths.sound('kakahi'), 0.6);
			}

			swagCounter++;
		}, 2);
	}

	var previousFrameTime:Int = 0;
	var songTime:Float = 0;

	function startSong():Void {
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;

		if (!paused)
			FlxG.sound.playMusic(Paths.inst(SONG.song), 1, false);

		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		#if discord_rpc
		songLength = FlxG.sound.music.length;

		DiscordClient.changePresence(detailsText, SONG.song, true, songLength);
		#end
	}

	private function generateSong():Void {
		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(SONG.song));
		else
			vocals = new FlxSound();

		vocals.onComplete = function(){
			vocalsFinished = true;
		};

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;
		noteData = songData.notes;

		for (section in noteData) {
			for (songNotes in section.sectionNotes) {
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
					gottaHitNote = !section.mustHitSection;

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.sustainLength = songNotes[2];
				swagNote.altNote = songNotes[3];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength)) {
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
						sustainNote.x += FlxG.width / 2;
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
					swagNote.x += FlxG.width / 2;
			}
		}

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int {
		return sortNotes(FlxSort.ASCENDING, Obj1, Obj2);
	}

	function sortNotes(order:Int = FlxSort.ASCENDING, Obj1:Note, Obj2:Note) {
		return FlxSort.byValues(order, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void {
		for (i in 0...4) {
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);
			babyArrow.frames = Paths.getSparrowAtlas('arrow_call');
			babyArrow.antialiasing = true;
			babyArrow.setGraphicSize(Std.int(babyArrow.width * 1.4));

			switch (Math.abs(i)) {
				case 0:
					babyArrow.x += Note.swagWidth * 0;
					babyArrow.animation.addByPrefix('static', 'left1');
					babyArrow.animation.addByPrefix('confirm', 'leftconf', 24, false);
				case 1:
					babyArrow.x += Note.swagWidth * 1;
					babyArrow.animation.addByPrefix('static', 'down1');
					babyArrow.animation.addByPrefix('confirm', 'downconf', 24, false);
				case 2:
					babyArrow.x += Note.swagWidth * 2;
					babyArrow.animation.addByPrefix('static', 'up1');
					babyArrow.animation.addByPrefix('confirm', 'upconf', 24, false);
				case 3:
					babyArrow.x += Note.swagWidth * 3;
					babyArrow.animation.addByPrefix('static', 'right1');
					babyArrow.animation.addByPrefix('confirm', 'rightconf', 24, false);
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();
			babyArrow.y -= 10;
			babyArrow.alpha = 0;
			FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});

			babyArrow.ID = i;

			switch (player) {
				case 0:
					cpuStrums.add(babyArrow);
					babyArrow.visible = false;
				case 1:
					playerStrums.add(babyArrow);
					babyArrow.x -= (FlxG.width / 4);
			}

			babyArrow.animation.play('static');
			babyArrow.x += ((FlxG.width / 2) * player) + 50;

			strumLineNotes.add(babyArrow);
		}
	}

	override function openSubState(SubState:FlxSubState) {
		if (paused) {
			if (FlxG.sound.music != null) {
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState() {
		if (paused) {
			if (FlxG.sound.music != null && !startingSong)
				resyncVocals();

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if discord_rpc
			if (startTimer.finished)
				DiscordClient.changePresence(detailsText, SONG.song, true, songLength - Conductor.songPosition);
			else
				DiscordClient.changePresence(detailsText, SONG.song);
			#end
		}

		super.closeSubState();
	}

	#if discord_rpc
	override public function onFocus():Void {
		if (health > 0 && !paused && FlxG.autoPause) {
			if (Conductor.songPosition > 0.0)
				DiscordClient.changePresence(detailsText, SONG.song, true, songLength - Conductor.songPosition);
			else
				DiscordClient.changePresence(detailsText, SONG.song);
		}

		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		if (health > 0 && !paused && FlxG.autoPause)
			DiscordClient.changePresence(detailsPausedText, SONG.song);

		super.onFocusLost();
	}
	#end

	function resyncVocals():Void {
		if (_exiting)
			return;

		vocals.pause();
		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time + Conductor.offset;

		if (vocalsFinished)
			return;

		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	override public function update(elapsed:Float) {
		if (startingSong) {
			if (startedCountdown) {
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		} else {
			Conductor.songPosition = FlxG.sound.music.time + Conductor.offset;

			if (!paused) {
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				if (Conductor.lastSongPos != Conductor.songPosition) {
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
				}
			}
		}

		super.update(elapsed);

		scoreTxt.text = "Score:" + songScore;

		if (controls.PAUSE #if android || FlxG.android.justReleased.BACK #end && startedCountdown && canPause) {
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			var boyfriendPos = boyfriend.getScreenPosition();
			var pauseSubState = new PauseSubState(boyfriendPos.x, boyfriendPos.y);
			openSubState(pauseSubState);
			pauseSubState.camera = camHUD;
			boyfriendPos.put();

			#if discord_rpc
			DiscordClient.changePresence(detailsPausedText, SONG.song);
			#end
		}

		if (FlxG.keys.justPressed.SEVEN) {
			FlxG.switchState(new ChartingState());

			#if discord_rpc
			DiscordClient.changePresence("Chart Editor", null, true);
			#end
		}

		if (health > 2)
			health = 2;

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		if (FlxG.keys.justPressed.PAGEUP)
			changeSection(1);
		if (FlxG.keys.justPressed.PAGEDOWN)
			changeSection(-1);
		#end

		if (generatedMusic && SONG.notes[Std.int(curStep / 16)] != null) {
			cameraRightSide = SONG.notes[Std.int(curStep / 16)].mustHitSection;

			cameraMovement();
		}

		FlxG.camera.zoom = FlxMath.lerp(daCamZoom, FlxG.camera.zoom, 0.95);
		camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);

		if (!_exiting) {
			if (controls.RESET)
				FlxG.resetState();

			if (health <= 0) {
				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				FlxG.switchState(new DeathState());
			}
		}

		while (unspawnNotes[0] != null && unspawnNotes[0].strumTime - Conductor.songPosition < 1800 / SONG.speed) {
			var dunceNote:Note = unspawnNotes[0];
			notes.add(dunceNote);
			unspawnNotes.shift();
		}

		if (generatedMusic) {
			notes.forEachAlive(function(daNote:Note) {
				if ((PreferencesMenu.getPref('downscroll') && daNote.y < -daNote.height)
					|| (!PreferencesMenu.getPref('downscroll') && daNote.y > FlxG.height)) {
					daNote.active = false;
					daNote.visible = false;
				} else {
					daNote.visible = true;
					daNote.active = true;
				}

				var strumLineMid = strumLine.y + Note.swagWidth / 2;

				if (PreferencesMenu.getPref('downscroll')) {
					daNote.y = (strumLine.y + (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2)));

					if (daNote.isSustainNote) {
						if (daNote.animation.curAnim.name.endsWith("end") && daNote.prevNote != null)
							daNote.y += daNote.prevNote.height;
						else
							daNote.y += daNote.height / 2;

						if ((!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit)))
							&& daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= strumLineMid) {
							// clipRect is applied to graphic itself so use frame Heights
							var swagRect:FlxRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);

							swagRect.height = (strumLineMid - daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;
							daNote.clipRect = swagRect;
						}
					}
				} else {
					daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2)));

					if (daNote.isSustainNote
						&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit)))
						&& daNote.y + daNote.offset.y * daNote.scale.y <= strumLineMid) {
						var swagRect:FlxRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);

						swagRect.y = (strumLineMid - daNote.y) / daNote.scale.y;
						swagRect.height -= swagRect.y;
						daNote.clipRect = swagRect;
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit) {
					if (SONG.needsVoices)
						vocals.volume = 1;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
				
				if (daNote.mustPress) {
					daNote.visible = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].visible;
					daNote.x = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x;
					if (!daNote.isSustainNote)
						daNote.angle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
					daNote.alpha = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha;
				} else if (!daNote.wasGoodHit) {
					daNote.visible = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].visible;
					daNote.x = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].x;
					if (!daNote.isSustainNote)
						daNote.angle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].angle;
					daNote.alpha = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].alpha;
				}
				
				if (daNote.isSustainNote)
					daNote.x += daNote.width / 2 + 20;

				if (daNote.isSustainNote && daNote.wasGoodHit) {
					if ((!PreferencesMenu.getPref('downscroll') && daNote.y < -daNote.height)
						|| (PreferencesMenu.getPref('downscroll') && daNote.y > FlxG.height)) {
						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				} else if (daNote.tooLate || daNote.wasGoodHit) {
					if (daNote.tooLate) {
						health -= 0.09;
						vocals.volume = 0;
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}

		keyShit();
	}

	#if debug
	function changeSection(sec:Int):Void {
		FlxG.sound.music.pause();

		var daBPM:Float = SONG.bpm;
		var daPos:Float = 0;
		for (i in 0...(Std.int(curStep / 16 + sec))) {
			if (SONG.notes[i].changeBPM)
				daBPM = SONG.notes[i].bpm;
			
			daPos += 4 * (1000 * 60 / daBPM);
		}

		Conductor.songPosition = FlxG.sound.music.time = daPos;
		updateCurStep();
		resyncVocals();
	}
	#end

	function endSong():Void {
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		if (SONG.validScore)
			Highscore.saveScore(SONG.song, songScore);

		#if mobile
		removeHitbox();
		#end

		FlxG.switchState(new MainMenuState());
	}

	private function calculateScore(strumtime:Float, daNote:Note):Void {
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
		vocals.volume = 1;

		var score:Int = 350;

		var daRating:String = "sick";

		var isSick:Bool = true;

		if (noteDiff > Conductor.safeZoneOffset * 0.9) {
			daRating = 'shit';
			score = 50;
			isSick = false;
		} else if (noteDiff > Conductor.safeZoneOffset * 0.75) {
			daRating = 'bad';
			score = 100;
			isSick = false;
		} else if (noteDiff > Conductor.safeZoneOffset * 0.2) {
			daRating = 'good';
			score = 200;
			isSick = false;
		}

		if (isSick) {
			var noteSplash:NoteSplash = new NoteSplash(daNote.getMidpoint().x + 10, strumLine.y + 40);
			grpNoteSplashes.add(noteSplash);
		}

		songScore += score;
	}

	var cameraRightSide:Bool = false;

	function cameraMovement() {
		if (cameraRightSide && camFollow.x != boyfriend.getMidpoint().x)
			camFollow.setPosition(boyfriend.getMidpoint().x, boyfriend.getMidpoint().y - 60);
	}

	private function keyShit():Void {
		var holdArray:Array<Bool> = [controls.NOTE_LEFT, controls.NOTE_DOWN, controls.NOTE_UP, controls.NOTE_RIGHT];
		var pressArray:Array<Bool> = [controls.NOTE_LEFT_P, controls.NOTE_DOWN_P, controls.NOTE_UP_P, controls.NOTE_RIGHT_P];

		if (holdArray.contains(true) && generatedMusic) {
			notes.forEachAlive(function(daNote:Note) {
				if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData])
					goodNoteHit(daNote);
			});
		}

		if (pressArray.contains(true) && generatedMusic) {
			boyfriend.holdTimer = 0;

			var possibleNotes:Array<Note> = [];
			var directionList:Array<Int> = [];
			var dumbNotes:Array<Note> = [];

			notes.forEachAlive(function(daNote:Note) {
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit) {
					if (directionList.contains(daNote.noteData)) {
						for (coolNote in possibleNotes) {
							if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
								dumbNotes.push(daNote);
							else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime) {
								possibleNotes.remove(coolNote);
								possibleNotes.push(daNote);
								break;
							}
						}
					} else {
						possibleNotes.push(daNote);
						directionList.push(daNote.noteData);
					}
				}
			});

			for (note in dumbNotes) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}

			possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

			if (possibleNotes.length > 0) {
				for (shit in 0...pressArray.length) {
					if (pressArray[shit] && !directionList.contains(shit))
						noteMiss(shit);
				} 
				
				for (coolNote in possibleNotes) {
					if (pressArray[coolNote.noteData])
						goodNoteHit(coolNote);
				}
			} else {
				for (shit in 0...pressArray.length)
					if (pressArray[shit])
						noteMiss(shit);
			}
		}

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !holdArray.contains(true)) {
			if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
				boyfriend.playAnim('idle');
		}

		playerStrums.forEach(function(spr:FlxSprite) {
			if (!holdArray[spr.ID])
				spr.animation.play('static');

			spr.centerOffsets();
		});
	}

	function noteMiss(direction:Int = 1):Void {
		health -= 0.1;
		songScore -= 10;

		vocals.volume = 0;
		FlxG.sound.play(Paths.sound('puk'), FlxG.random.float(0.1, 0.2));
	}

	function goodNoteHit(note:Note):Void {
		if (!note.wasGoodHit) {
			if (!note.isSustainNote) {
				calculateScore(note.strumTime, note);
			}

			if (note.noteData >= 0)
				health += 0.1;
			else
				health += 0.15;

			switch (note.noteData) {
				case 0:
					boyfriend.playAnim('singLEFT', true);
				case 1:
					boyfriend.playAnim('singDOWN', true);
				case 2:
					boyfriend.playAnim('singUP', true);
				case 3:
					boyfriend.playAnim('singRIGHT', true);
			}

			playerStrums.forEach(function(spr:FlxSprite) {
				if (Math.abs(note.noteData) == spr.ID)
					spr.animation.play('confirm', true);
			});

			note.wasGoodHit = true;
			vocals.volume = 1;

			if (!note.isSustainNote) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	override function stepHit() {
		super.stepHit();

		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > 20 || (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > 20))
			resyncVocals();
	}

	override function beatHit() {
		super.beatHit();

		if (generatedMusic)
			notes.sort(sortNotes, FlxSort.DESCENDING);

		if (SONG.notes[Math.floor(curStep / 16)] != null) {
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
		}

		if (FlxG.camera.zoom < 1.35 && curBeat % 4 == 0) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}
		
		if (curBeat % 2 == 0) {
			if (!boyfriend.animation.curAnim.name.startsWith("sing"))
				boyfriend.playAnim('idle');
		}
		
		if (SONG.song.toLowerCase().startsWith('shpork')) {
			if (curBeat % 2 == 0)
				boombox.animation.play('sex');
		} else if (SONG.song.toLowerCase().startsWith('govnoed')) {
			if (curBeat % 2 == 0)
				gitara.animation.play('sex');
			if (SONG.song.toLowerCase().endsWith('drip')) {
				if (curBeat % 2 == 0)
					boombox.animation.play('sex');
			}
		}
	}
}