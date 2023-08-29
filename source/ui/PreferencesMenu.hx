package ui;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import ui.AtlasText.AtlasFont;
import ui.TextMenuList.TextMenuItem;

class PreferencesMenu extends ui.OptionsState.Page
{
	public static var preferences:Map<String, Dynamic> = new Map();

	var items:TextMenuList;

	var checkboxes:Array<CheckboxThingie> = [];
	var menuCamera:FlxCamera;
	var ghostCamera:FlxCamera;
	var camFollow:FlxObject;
	var ghostText:FlxText;
	var ghostBox:FlxSprite;
	var isText2:Bool = false;
	var inGhost:Bool = false;

	public function new()
	{
		super();

		menuCamera = new SwagCamera();
		ghostCamera = new SwagCamera();
		FlxG.cameras.add(menuCamera, false);
		FlxG.cameras.add(ghostCamera, false);
		ghostCamera.alpha = 0;
		ghostCamera.bgColor.alpha = 0;
		menuCamera.bgColor = 0x0;
		camera = menuCamera;

		add(items = new TextMenuList());

		createPrefItem('Ghost Tapping', 'ghost-tapping', false);
		createPrefItem('downscroll', 'downscroll', FlxG.save.data.downscroll);

		camFollow = new FlxObject(FlxG.width / 2, 0, 140, 70);
		if (items != null)
			camFollow.y = items.selectedItem.y;

		menuCamera.follow(camFollow, null, 0.06);
		var margin = 160;
		menuCamera.deadzone.set(0, margin, menuCamera.width, 40);
		menuCamera.minScrollY = 0;

		items.onChange.add(function(selected)
		{
			camFollow.y = selected.y;
		});
		
		ghostBox = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		ghostBox.alpha = 0.5;
		ghostBox.cameras = [ghostCamera];
		add(ghostBox);

		ghostText = new FlxText(0, 0, 0, '', 30);
		ghostText.setFormat(Paths.font("vcr.ttf"), 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		ghostText.borderSize = 0.5;
		ghostText.screenCenter();
		ghostText.cameras = [ghostCamera];
		add(ghostText);
	}

	public static function getPref(pref:String):Dynamic
	{
		return preferences.get(pref);
	}

	// easy shorthand?
	public static function setPref(pref:String, value:Dynamic):Void
	{
		preferences.set(pref, value);
	}

	public static function initPrefs():Void
	{
		preferenceCheck('ghost-tapping', false);
		preferenceCheck('downscroll', FlxG.save.data.downscroll);
		FlxG.autoPause = true;
	}

	private function createPrefItem(prefName:String, prefString:String, prefValue:Dynamic):Void
	{
		items.createItem(120, (120 * items.length) + 30, prefName, AtlasFont.Bold, function()
		{
			preferenceCheck(prefString, prefValue);

			switch (Type.typeof(prefValue).getName())
			{
				case 'TBool':
					prefToggle(prefString);

				default:
					trace('swag');
			}
		});

		switch (Type.typeof(prefValue).getName())
		{
			case 'TBool':
				createCheckbox(prefString);

			default:
				trace('swag');
		}

		trace(Type.typeof(prefValue).getName());
	}

	function createCheckbox(prefString:String)
	{
		var checkbox:CheckboxThingie = new CheckboxThingie(0, 120 * (items.length - 1), preferences.get(prefString));
		checkboxes.push(checkbox);
		add(checkbox);
	}

	/**
	 * Assumes that the preference has already been checked/set?
	 */
	private function prefToggle(prefName:String)
	{
		if (prefName == 'ghost-tapping')
		{
			inGhost = true;
			isText2 = false;
			ghostText.text = 'Lets play without Ghost Tapping,\notherwise ur mom will turn into ghost.';
			ghostText.screenCenter();
			FlxTween.tween(ghostCamera, {alpha: 1}, 0.5);
			items.enabled = false;
		}
		else
		{
			var daSwap:Bool = preferences.get(prefName);
			daSwap = !daSwap;
			preferences.set(prefName, daSwap);
			checkboxes[items.selectedIndex].daValue = daSwap;
			trace('toggled? ' + preferences.get(prefName));
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.BACK)
			FlxG.save.data.downscroll = getPref('downscroll');

		items.forEach(function(daItem:TextMenuItem)
		{
			if (items.selectedItem == daItem)
				daItem.x = 150;
			else
				daItem.x = 120;
		});
		
		if (controls.ACCEPT && inGhost)
		{
			if(!isText2)
			{
				ghostText.text = '(Joke, your mom will live forever).';
				ghostText.screenCenter();
				isText2 = true;
			}
			else
				FlxTween.tween(ghostCamera, {alpha: 0}, 0.5, {onComplete: function(twn:FlxTween) items.enabled = true});
		}
	}

	private static function preferenceCheck(prefString:String, prefValue:Dynamic):Void
	{
		if (preferences.get(prefString) == null)
		{
			preferences.set(prefString, prefValue);
			trace('set preference!');
		}
		else
		{
			trace('found preference: ' + preferences.get(prefString));
		}
	}
}

class CheckboxThingie extends FlxSprite
{
	public var daValue(default, set):Bool;

	public function new(x:Float, y:Float, daValue:Bool = false)
	{
		super(x, y);

		frames = Paths.getSparrowAtlas('checkboxThingie');
		animation.addByPrefix('static', 'Check Box unselected', 24, false);
		animation.addByPrefix('checked', 'Check Box selecting animation', 24, false);

		antialiasing = true;

		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();

		this.daValue = daValue;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		switch (animation.curAnim.name)
		{
			case 'static':
				offset.set();
			case 'checked':
				offset.set(17, 70);
		}
	}

	function set_daValue(value:Bool):Bool
	{
		if (value)
			animation.play('checked', true);
		else
			animation.play('static');

		return value;
	}
}
