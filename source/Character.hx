package;

import flixel.FlxSprite;
import flixel.util.FlxSort;

using StringTools;

class Character extends FlxSprite {
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'shporkzaporov';

	public var holdTimer:Float = 0;

	public var animationNotes:Array<Dynamic> = [];

	public function new(x:Float, y:Float, ?character:String = "shporkzaporov", ?isPlayer:Bool = false) {
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;

		antialiasing = true;

		switch (curCharacter) {
			case 'shporkzaporov':
				frames = Paths.getSparrowAtlas('shporkzaporov');
				quickAnimAdd('idle', 'idle');
				quickAnimAdd('singUP', 'up');
				quickAnimAdd('singLEFT', 'left');
				quickAnimAdd('singRIGHT', 'right');
				quickAnimAdd('singDOWN', 'down');

				setGraphicSize(Std.int(width * 1.3));

				loadOffsetFile(curCharacter);

				playAnim('idle');

				flipX = true;
			case 'dripshpork':
				frames = Paths.getSparrowAtlas('dripshpork');
				quickAnimAdd('idle', 'Idle');
				quickAnimAdd('singUP', 'Up');
				quickAnimAdd('singLEFT', 'Right');
				quickAnimAdd('singRIGHT', 'Left');
				quickAnimAdd('singDOWN', 'Down');

				setGraphicSize(Std.int(width * 1.3));

				loadOffsetFile(curCharacter);

				playAnim('idle');
		}
		
		animation.finish();

		if (isPlayer)
			flipX = !flipX;
	}

	function sortAnims(val1:Array<Dynamic>, val2:Array<Dynamic>):Int {
		return FlxSort.byValues(FlxSort.ASCENDING, val1[0], val2[0]);
	}

	function quickAnimAdd(name:String, prefix:String) {
		animation.addByPrefix(name, prefix, 24, false);
	}

	private function loadOffsetFile(offsetCharacter:String) {
		var daFile:Array<String> = CoolUtil.coolTextFile(Paths.file("images/" + offsetCharacter + "Offsets.txt"));

		for (i in daFile) {
			var splitWords:Array<String> = i.split(" ");
			addOffset(splitWords[0], Std.parseInt(splitWords[1]), Std.parseInt(splitWords[2]));
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void {
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
			offset.set(daOffset[0], daOffset[1]);
		else
			offset.set(0, 0);
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0) {
		animOffsets[name] = [x, y];
	}
}
