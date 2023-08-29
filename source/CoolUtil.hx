package;

import flixel.FlxG;
import flixel.math.FlxMath;
import lime.utils.Assets;

using StringTools;

class CoolUtil {
	public static function coolTextFile(path:String):Array<String> {
		var daList:Array<String> = Assets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
			daList[i] = daList[i].trim();

		return daList;
	}

	public static function camLerpShit(lerp:Float):Float {
		return lerp * (FlxG.elapsed / (1 / 60));
	}

	public static function coolLerp(a:Float, b:Float, ratio:Float):Float {
		return FlxMath.lerp(a, b, camLerpShit(ratio));
	}
}