package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

class DeathState extends MusicBeatState {
	var animfinished:Bool = false;
	var doNotSpam:Bool = false;

	var govno:FlxSprite;

	var govnotxt:FlxSprite;
	var konch:FlxSprite;

	var smile:FlxSprite;

	override function create() {
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		govno = new FlxSprite();
		govno.frames = Paths.getSparrowAtlas('death/govno', 'shared');
		govno.animation.addByPrefix('sex', '1231123', 24, false);
		govno.animation.play('sex', true);
		govno.screenCenter();
		add(govno);

		govnotxt = new FlxSprite(300, 230).loadGraphic(Paths.image('death/govnotxt', 'shared'));
		govnotxt.setGraphicSize(Std.int(govnotxt.width * 0.4));
		govnotxt.updateHitbox();
		govnotxt.alpha = 0;
		add(govnotxt);

		konch = new FlxSprite(250, 370).loadGraphic(Paths.image('death/konchilos', 'shared'));
		konch.setGraphicSize(Std.int(konch.width * 0.4));
		konch.updateHitbox();
		konch.alpha = 0;
		add(konch);

		smile = new FlxSprite(570, 250);
		smile.frames = Paths.getSparrowAtlas('death/smile', 'shared');
		smile.animation.addByPrefix('smile', 'smile', 24, false);
		smile.setGraphicSize(Std.int(smile.width * 0.6));
		smile.updateHitbox();
		smile.alpha = 0;
		add(smile);

		new FlxTimer().start(4, function(tmr:FlxTimer) {
			FlxG.sound.play(Paths.sound('vineBoom', 'shared'));

			FlxTween.tween(govno, {alpha: 0}, 1, {onComplete: function(twn:FlxTween) {
				new FlxTimer().start(1, function(tmr:FlxTimer) {
					FlxG.sound.play(Paths.sound('vineBoom', 'shared'));
					govno.alpha = 0;
					govnotxt.alpha = 1;
		
					new FlxTimer().start(1, function(tmr:FlxTimer) {
						FlxG.sound.playMusic(Paths.music('net_govna'));
						konch.alpha = 1;
						smile.alpha = 1;

						animfinished = true;
					});
				});
			}});
		});
		super.create();
	}

	override function update(elapsed:Float) {
        var justTouched:Bool = false;
        for (touch in FlxG.touches.list)
	        if (touch.justPressed)
                        justTouched = true;
		
		if (animfinished && !doNotSpam) {
			if (justTouched)
				smileAnim();
			if (controls.BACK #if android || FlxG.android.justReleased.BACK #end) {
				FlxG.mouse.visible = true;
				
				FlxG.sound.music.stop();
				
				FlxG.switchState(new MainMenuState());
			}
		}

		govno.updateHitbox();
		govno.screenCenter();

		super.update(elapsed);
	}

	function smileAnim() {
		doNotSpam = true;
		FlxG.sound.playMusic(Paths.music('net_govna_end'));
		smile.animation.play('smile');
		FlxTween.tween(smile, {y: smile.y + 50}, 2);
		FlxTween.tween(govnotxt, {y: govnotxt.y + 50}, 2);
		FlxTween.tween(konch, {alpha: 0}, 2, {onComplete: function(twn:FlxTween) {
			FlxG.switchState(new PlayState());
		}});
	}
}
