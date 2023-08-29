package;

import Sys.sleep;

using StringTools;

#if discord_rpc
import discord_rpc.DiscordRpc;
#end

class DiscordClient {
	#if discord_rpc
	public function new() {
		DiscordRpc.start({
			clientID: "814588678700924999",
			onReady: onReady,
			onError: onError,
			onDisconnected: onDisconnected
		});

		while (true) {
			DiscordRpc.process();
			sleep(2);
		}

		DiscordRpc.shutdown();
	}

	public static function shutdown() {
		DiscordRpc.shutdown();
	}
	
	static function onReady() {
		DiscordRpc.presence({
			details: "In the Menus",
			state: null,
			largeImageKey: 'icon',
			largeImageText: "Friday Night Funkin'"
		});
	}

	static function onError(_code:Int, _message:String) {
		trace('Error! $_code : $_message');
	}

	static function onDisconnected(_code:Int, _message:String) {
		trace('Disconnected! $_code : $_message');
	}

	public static function initialize() {
		var DiscordDaemon = sys.thread.Thread.create(() -> {
			new DiscordClient();
		});
	}

	public static function changePresence(details:String, state:Null<String>, ?hasStartTimestamp:Bool, ?endTimestamp:Float) {
		var startTimestamp:Float = if (hasStartTimestamp) Date.now().getTime() else 0;

		if (endTimestamp > 0)
			endTimestamp = startTimestamp + endTimestamp;

		DiscordRpc.presence({
			details: details,
			state: state,
			largeImageKey: 'icon',
			largeImageText: "Friday Night Funkin'",
			smallImageKey: null,
			startTimestamp: Std.int(startTimestamp / 1000),
			endTimestamp: Std.int(endTimestamp / 1000)
		});
	}
	#end
}
