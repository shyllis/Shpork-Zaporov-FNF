package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.system.FlxSound;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.transition.FlxTransitionableState;

using StringTools;
class PauseSubState extends MusicBeatSubstate {
	var pauseMusic:FlxSound;

	var resume:FlxSprite;
	var restart:FlxSprite;
	var exit:FlxSprite;

	public function new(x:Float, y:Float) {
		super();

		FlxG.mouse.visible = true;

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('drisnya'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false);

		FlxG.sound.list.add(pauseMusic);

		var kakashki = 0xFFDCE010;
		if (PlayState.SONG.song.toLowerCase().contains('drip'))
			kakashki = 0xFFFF0033;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, kakashki);
		bg.alpha = 0.001;
		bg.scrollFactor.set();
		add(bg);

		var kakashki:FlxBackdrop = new FlxBackdrop(Paths.image('menu/kaka_byaka'));
		kakashki.velocity.set(40, 40);
		kakashki.alpha = 0.001;
		add(kakashki);

		var pausetxt:FlxSprite = new FlxSprite(0, -100).loadGraphic(Paths.image('pause/pause', 'shared'));
		pausetxt.antialiasing = true;
		pausetxt.setGraphicSize(Std.int(pausetxt.width * 0.5));
		pausetxt.updateHitbox();
		pausetxt.screenCenter(X);
		add(pausetxt);

		resume = new FlxSprite(40).loadGraphic(Paths.image('pause/resume', 'shared'));
		resume.antialiasing = true;
		resume.setGraphicSize(Std.int(resume.width * 0.35));
		resume.updateHitbox();
		resume.screenCenter(Y);
		resume.scrollFactor.set();
		resume.updateHitbox();
		add(resume);

		restart = new FlxSprite(620).loadGraphic(Paths.image('pause/r-start', 'shared'));
		restart.antialiasing = true;
		restart.setGraphicSize(Std.int(restart.width * 0.35));
		restart.updateHitbox();
		restart.screenCenter(Y);
		restart.scrollFactor.set();
		restart.updateHitbox();
		add(restart);

		exit = new FlxSprite(0, 450).loadGraphic(Paths.image('pause/exit', 'shared'));
		exit.antialiasing = true;
		exit.setGraphicSize(Std.int(exit.width * 0.4));
		exit.updateHitbox();
		exit.screenCenter(X);
		exit.scrollFactor.set();
		exit.updateHitbox();
		add(exit);

		var levelInfo:FlxText = new FlxText(0, 720, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.screenCenter(X);
		levelInfo.updateHitbox();
		add(levelInfo);

		levelInfo.alpha = 0;
		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(kakashki, {alpha: 0.3}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(pausetxt, {y: 20}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 680}, 0.5, {ease: FlxEase.quartInOut, startDelay: 0.3});
	}

	override function update(elapsed:Float) {
		if (pauseMusic.volume < 1)
			pauseMusic.volume += 0.1 * elapsed;

		var overlapResume:Bool = FlxG.mouse.overlaps(resume);
		var overlapRestart:Bool = FlxG.mouse.overlaps(restart);
		var overlapExit:Bool = FlxG.mouse.overlaps(exit);

		if (overlapResume) {
			if (FlxG.mouse.justPressed) {
				FlxG.mouse.visible = false;
				close();
			}
		}

		if (controls.BACK) {
			FlxG.mouse.visible = false;
			close();
		}

		if (overlapRestart) {
			if (FlxG.mouse.justPressed) {
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				close();
				FlxG.resetState();
			}
		}

		if (overlapExit) {
			if (FlxG.mouse.justPressed) 
				FlxG.switchState(new MainMenuState());
		}

		super.update(elapsed);

	}

	override function destroy() {
		pauseMusic.destroy();

		super.destroy();
	}
}
