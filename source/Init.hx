package;

import flixel.FlxG;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import lime.app.Application;
import ui.PreferencesMenu;

#if discord_rpc
import Discord.DiscordClient;
#end

using StringTools;

class Init {
    static public function initialize() {
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
    }
}