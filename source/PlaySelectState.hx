package;

#if discord_rpc
import Discord.DiscordClient;
#end

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.addons.display.FlxBackdrop;

using StringTools;

class PlaySelectState extends MusicBeatState {
	var dripMode:Bool = false;
	var stopspamming:Bool = false;

	var bg:FlxSprite;
	var kakashki:FlxBackdrop;

	var bg2:FlxSprite;
	var dripdrip:FlxBackdrop;

	var shpork:FlxSprite;
	var govnoed:FlxSprite;
	var y:FlxSprite;

	var switcher:FlxSprite;

	var drip:FlxSprite;
	var drip2:FlxSprite;

	var tweenbg:FlxTween;
	var tweenbg2:FlxTween;

	var tweendrip:FlxTween;
	var tweendrip2:FlxTween;

	override function create() {
		#if discord_rpc
		DiscordClient.changePresence("Songs", null);
		#end

		if (FlxG.sound.music != null) {
			if (!FlxG.sound.music.playing)
				FlxG.sound.playMusic(Paths.music('kakahi'));
		}
		
		// default bg
		bg = new FlxSprite().makeGraphic(960, 720, 0xFFDCE010);
		bg.screenCenter();
		add(bg);

		kakashki = new FlxBackdrop(Paths.image('menu/kaka_byaka'));
		kakashki.velocity.set(40, 40);
		add(kakashki);

		// drip bg
		bg2 = new FlxSprite().makeGraphic(960, 720, 0xFFFF0033);
		bg2.screenCenter();
		bg2.alpha = 0.01;
		add(bg2);

		dripdrip = new FlxBackdrop(Paths.image('playselect/kakaha'));
		dripdrip.velocity.set(40, 40);
		dripdrip.alpha = 0.01;
		add(dripdrip);

		// buttons
		shpork = new FlxSprite(30).loadGraphic(Paths.image('playselect/shpork'));
		shpork.antialiasing = true;
		shpork.setGraphicSize(Std.int(shpork.width * 0.3));
		shpork.updateHitbox();
		shpork.screenCenter(Y);
		add(shpork);

		govnoed = new FlxSprite(480).loadGraphic(Paths.image('playselect/govnoed'));
		govnoed.antialiasing = true;
		govnoed.setGraphicSize(Std.int(govnoed.width * 0.3));
		govnoed.updateHitbox();
		govnoed.screenCenter(Y);
		add(govnoed);

		y = new FlxSprite(380).loadGraphic(Paths.image('playselect/Y'));
		y.antialiasing = true;
		y.setGraphicSize(Std.int(y.width * 0.3));
		y.updateHitbox();
		y.screenCenter(Y);
		add(y);

		// drip switch
		switcher = new FlxSprite(0, 560).loadGraphic(Paths.image('playselect/drip'));
		switcher.antialiasing = true;
		switcher.setGraphicSize(Std.int(switcher.width * 0.3));
		switcher.updateHitbox();
		switcher.screenCenter(X);
		add(switcher);

		// drip below buttons
		drip = new FlxSprite(-200, 430).loadGraphic(Paths.image('playselect/driptxt')); 
		drip.antialiasing = true;
		drip.setGraphicSize(Std.int(drip.width * 0.3));
		drip.updateHitbox();
		add(drip);

		drip2 = new FlxSprite(960, 430).loadGraphic(Paths.image('playselect/driptxt'));
		drip2.antialiasing = true;
		drip2.setGraphicSize(Std.int(drip2.width * 0.3));
		drip2.updateHitbox();
		add(drip2);

		super.create();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (FlxG.sound.music != null) {
			if (FlxG.sound.music.volume < 0.7)
				FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (controls.BACK || FlxG.android.justReleased.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(new MainMenuState());
		}
		
		var shporkOverlap:Bool = FlxG.mouse.overlaps(shpork);
		var govnoedOverlap:Bool = FlxG.mouse.overlaps(govnoed);
		var switchOverlap:Bool = FlxG.mouse.overlaps(switcher);

		if (shporkOverlap && !stopspamming) {
			if (FlxG.mouse.justPressed) {
				stopspamming = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));
				FlxG.mouse.visible = false;

				if (!dripMode) {
					PlayState.SONG = Song.loadFromJson('shpork-zaporov', 'shpork-zaporov');
					LoadingState.loadAndSwitchState(new PlayState());
				} else {
					PlayState.SONG = Song.loadFromJson('shpork-zaporov-drip', 'shpork-zaporov-drip');
					LoadingState.loadAndSwitchState(new PlayState());
				}
			}
		}
		
		if (govnoedOverlap && !stopspamming) {
			if (FlxG.mouse.justPressed) {
				stopspamming = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));
				FlxG.mouse.visible = false;

				if (!dripMode) {
					PlayState.SONG = Song.loadFromJson('govnoed', 'govnoed');
					LoadingState.loadAndSwitchState(new PlayState());
				} else {
					PlayState.SONG = Song.loadFromJson('govnoed-drip', 'govnoed-drip');
					LoadingState.loadAndSwitchState(new PlayState());
				}
			}
		}
		
		
		if (switchOverlap && !stopspamming) {
			if (FlxG.mouse.justPressed) {
				FlxG.sound.play(Paths.sound('scrollMenu'));

				dripSwitch(!dripMode);
			}
		}
	}

	function dripSwitch(toDrip:Bool) {
		if (toDrip) {
			FlxG.sound.play(Paths.sound('vineBoom', 'shared'));
			dripMode = true;
	
			shpork.loadGraphic(Paths.image('playselect/shporkblack'));
			shpork.updateHitbox();
			govnoed.loadGraphic(Paths.image('playselect/govnoedblack'));
			govnoed.updateHitbox();
			y.loadGraphic(Paths.image('playselect/Yblack'));
			
			switcher.loadGraphic(Paths.image('playselect/default'));
			switcher.setGraphicSize(Std.int(switcher.width * 0.3));
			switcher.updateHitbox();
			switcher.screenCenter(X);

			if(tweenbg != null)
				tweenbg.cancel();
			if(tweenbg2 != null)
				tweenbg2.cancel();
			if(tweendrip != null)
				tweendrip.cancel();
			if(tweendrip2 != null)
				tweendrip2.cancel();

			tweenbg = FlxTween.tween(bg2, {alpha: 1}, 0.5, {ease: FlxEase.cubeInOut});
			tweenbg2 = FlxTween.tween(dripdrip, {alpha: 1}, 0.5, {ease: FlxEase.cubeInOut});
			tweendrip = FlxTween.tween(drip, {x: 90}, 0.5, {ease: FlxEase.cubeInOut});
			tweendrip2 = FlxTween.tween(drip2, {x: 610}, 0.5, {ease: FlxEase.cubeInOut});
		} else {
			FlxG.sound.play(Paths.sound('vineBoom', 'shared'));
			dripMode = false;
	
			shpork.loadGraphic(Paths.image('playselect/shpork'));
			shpork.updateHitbox();
			govnoed.loadGraphic(Paths.image('playselect/govnoed'));
			govnoed.updateHitbox();
			y.loadGraphic(Paths.image('playselect/Y'));

			switcher.loadGraphic(Paths.image('playselect/drip'));
			switcher.setGraphicSize(Std.int(switcher.width * 0.3));
			switcher.updateHitbox();
			switcher.screenCenter(X);

			if(tweenbg != null)
				tweenbg.cancel();
			if(tweenbg2 != null)
				tweenbg2.cancel();
			if(tweendrip != null)
				tweendrip.cancel();
			if(tweendrip2 != null)
				tweendrip2.cancel();

			tweenbg = FlxTween.tween(bg2, {alpha: 0}, 0.5, {ease: FlxEase.cubeInOut});
			tweenbg2 = FlxTween.tween(dripdrip, {alpha: 0}, 0.5, {ease: FlxEase.cubeInOut});
			tweendrip = FlxTween.tween(drip, {x: -200}, 0.5, {ease: FlxEase.cubeInOut});
			tweendrip2 = FlxTween.tween(drip2, {x: 960}, 0.5, {ease: FlxEase.cubeInOut});
		}
	}
}