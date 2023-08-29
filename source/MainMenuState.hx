package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import flixel.addons.display.FlxBackdrop;
import lime.app.Application;
import ui.OptionsState;
import ui.PreferencesMenu;

using StringTools;

#if discord_rpc
import Discord.DiscordClient;
#end

class MainMenuState extends MusicBeatState {
	var play:FlxSprite;
	var playanim:FlxSprite;
	var options:FlxSprite;
	var optionsanim:FlxSprite;

	override function create() {
		#if android
		FlxG.android.preventDefaultKeys = [BACK];
		#end

		#if discord_rpc
		DiscordClient.initialize();

		Application.current.onExit.add(function(exitCode) {
			DiscordClient.shutdown();
		});

		DiscordClient.changePresence("Menu", null);
		#end
		
		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = [ZERO];
		FlxG.save.bind('shporkzaporov', 'kawaisexo');
		Main.setupSaveData();
		PreferencesMenu.initPrefs();
		PlayerSettings.init();
		Highscore.load();

		var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
		diamond.persist = true;
		diamond.destroyOnNoUse = false;

		FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 0.32, new FlxPoint(0, -1),
			{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
		FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.32, new FlxPoint(0, 1),
			{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;
		
		if (FlxG.sound.music == null)
			FlxG.sound.playMusic(Paths.music('freakyMenu'));

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite().makeGraphic(960, 720, 0xFFDCE010);
		bg.screenCenter();
		add(bg);

		var kakashki:FlxBackdrop = new FlxBackdrop(Paths.image('menu/kaka_byaka'));
		kakashki.velocity.set(40, 40);
		add(kakashki);

		play = new FlxSprite(0, 180).loadGraphic(Paths.image('menu/play'));
		play.antialiasing = true;
		play.screenCenter(X);
		add(play);
		
		playanim = new FlxSprite(0, play.getGraphicMidpoint().y - 120);
		playanim.frames = Paths.getSparrowAtlas('menu/playanim');
		playanim.animation.addByPrefix('anim', 'play', 24, true);
		playanim.animation.play('anim');
		playanim.antialiasing = true;
		playanim.setGraphicSize(Std.int(play.width));
		playanim.updateHitbox();
		playanim.screenCenter(X);
		playanim.visible = false;
		add(playanim);

		options = new FlxSprite(0, 420).loadGraphic(Paths.image('menu/options'));
		options.antialiasing = true;
		options.screenCenter(X);
		add(options);
		
		optionsanim = new FlxSprite(0, options.getGraphicMidpoint().y - 65);
		optionsanim.frames = Paths.getSparrowAtlas('menu/optionsanim');
		optionsanim.animation.addByPrefix('anim', 'options', 24, true);
		optionsanim.animation.play('anim');
		optionsanim.antialiasing = true;
		optionsanim.setGraphicSize(Std.int(options.width));
		optionsanim.updateHitbox();
		optionsanim.screenCenter(X);
		optionsanim.visible = false;
		add(optionsanim);

		super.create();
	}

	var didathing:Bool = false;
	var stopspamming:Bool = false;
	override function update(elapsed:Float) {
		if (FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		if (!FlxG.sound.music.playing)
			FlxG.sound.playMusic(Paths.music('freakyMenu'));

		var playOverlap:Bool = FlxG.mouse.overlaps(play);
		var optionsOverlap:Bool = FlxG.mouse.overlaps(options);

		if (playOverlap) {
			// i had to do it i have only few days
			if (!didathing) {
				didathing = true;
				play.alpha = 0.01;
				playanim.visible = true;
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if (FlxG.mouse.justPressed && !stopspamming) {
				stopspamming = true;
				doTheThing(0);
				FlxG.sound.play(Paths.sound('confirmMenu'));
			}
		}
		
		if (optionsOverlap) {
			// i had to do it i have only few days
			if (!didathing) {
				didathing = true;
				options.alpha = 0.01;
				optionsanim.visible = true;
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if (FlxG.mouse.justPressed && !stopspamming) {
				stopspamming = true;
				doTheThing(1);
				FlxG.sound.play(Paths.sound('confirmMenu'));
			}
		}
		
		// i had to do it i have only few days
		if (!playOverlap) {
			if (!optionsOverlap)
				didathing = false;
			play.alpha = 1;
			playanim.visible = false;
		} 

		if (!optionsOverlap) {
			if (!playOverlap)
				didathing = false;
			options.alpha = 1;
			optionsanim.visible = false;
		} 

		super.update(elapsed);
	}

	function doTheThing(num:Int) {
		switch (num) {
			case 0:
				FlxG.switchState(new PlaySelectState());
			case 1:
				FlxG.switchState(new ui.OptionsState());
		}
	}
}