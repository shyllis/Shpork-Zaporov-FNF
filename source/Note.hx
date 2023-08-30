package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import ui.PreferencesMenu;

using StringTools;

class Note extends FlxSprite {
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;

	private var willMiss:Bool = false;

	public var altNote:Bool = false;
	public var invisNote:Bool = false;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;

	public var noteScore:Float = 1;

	public static var swagWidth:Float = 140 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	public static var arrowColors:Array<Float> = [1, 1, 1, 1];

	public function new(skin:String, strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false) {
		super();

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		x += 50;
		y -= 2000;
		this.strumTime = strumTime;

		this.noteData = noteData;

		frames = Paths.getSparrowAtlas(skin);

		animation.addByPrefix('greenScroll', 'upscroll');
		animation.addByPrefix('redScroll', 'rightscroll');
		animation.addByPrefix('blueScroll', 'downscroll');
		animation.addByPrefix('purpleScroll', 'leftscroll');

		animation.addByPrefix('end', 'endbad');
		animation.addByPrefix('hold', 'holdobed');

		setGraphicSize(Std.int(width * 1.4));
		updateHitbox();
		antialiasing = true;

		switch (noteData) {
			case 0:
				x += swagWidth * 0;
				animation.play('purpleScroll');
			case 1:
				x += swagWidth * 1;
				animation.play('blueScroll');
			case 2:
				x += swagWidth * 2;
				animation.play('greenScroll');
			case 3:
				x += swagWidth * 3;
				animation.play('redScroll');
		}

		if (isSustainNote && prevNote != null) {
			noteScore * 0.2;
			alpha = 0.6;
			setGraphicSize(Std.int(width * 1.1));

			if (PreferencesMenu.getPref('downscroll'))
				angle = 180;

			x += width / 2;

			animation.play('end');

			updateHitbox();

			x -= width / 2;

			if (prevNote.isSustainNote) {
				prevNote.animation.play('hold');
				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed;
				prevNote.updateHitbox();
			}
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (mustPress) {
			if (willMiss && !wasGoodHit) {
				tooLate = true;
				canBeHit = false;
			} else {
				if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset) {
					if (strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
						canBeHit = true;
				} else {
					canBeHit = true;
					willMiss = true;
				}
			}
		} else {
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
				wasGoodHit = true;
		}

		if (tooLate) {
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}
