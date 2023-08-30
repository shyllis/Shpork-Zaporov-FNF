package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import Init;

class Main extends Sprite {
	var gameWidth:Int = 960;
	var gameHeight:Int = 720;
	var initialState:Class<FlxState> = MainMenuState;
	var framerate:Int = 60;
	var skipSplash:Bool = true; 
	var startFullscreen:Bool = false;
	
	public static function setupSaveData() {
		if(FlxG.save.data.downscroll == null)
			FlxG.save.data.downscroll = false;
	}

	public static function main():Void {
		Lib.current.addChild(new Main());
	}

	public function new() {
		super();

		if (stage != null)
			init();
		else
			addEventListener(Event.ADDED_TO_STAGE, init);
	}

	private function init(?E:Event):Void {
		if (hasEventListener(Event.ADDED_TO_STAGE))
			removeEventListener(Event.ADDED_TO_STAGE, init);

		setupGame();
		
		Init.initialize();
	}

	public static var fpsCounter:FPS;

	private function setupGame():Void {
		addChild(new FlxGame(gameWidth, gameHeight, initialState, framerate, framerate, skipSplash, startFullscreen));

		FlxG.autoPause = true;
		FlxG.mouse.useSystemCursor = true;

		#if !mobile
		fpsCounter = new FPS(10, 3, 0xFFFFFF);
		FlxG.stage.addChild(fpsCounter);
		#end

		if (FlxG.save.data.volume != null)
			FlxG.sound.volume = FlxG.save.data.volume;
		if (FlxG.save.data.mute != null)
			FlxG.sound.muted = FlxG.save.data.mute;
	}
}
