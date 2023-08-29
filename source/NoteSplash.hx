package;

import flixel.FlxG;
import flixel.FlxSprite;

class NoteSplash extends FlxSprite {
	var random:Array<String> = ['mocha', 'sperma', 'sopli', 'govno'];
	public function new(x:Float, y:Float):Void {
		super(x, y);

		var thing:Int = FlxG.random.int(0, 3);
		var splash:String = random[thing];
		frames = Paths.getSparrowAtlas('splashTypes/$splash', 'shared');
		animation.addByPrefix('splash', 'splash', 24, false);
		animation.play('splash', true);
		animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
		setGraphicSize(Std.int(width * 2));
		updateHitbox();
		antialiasing = true;

		setPosition(x, y);
		alpha = 0.6;
		offset.set(width * 0.3, height * 0.3);
	}

	override function update(elapsed:Float) {
		if (animation.curAnim.finished)
			kill();

		super.update(elapsed);
	}
}
