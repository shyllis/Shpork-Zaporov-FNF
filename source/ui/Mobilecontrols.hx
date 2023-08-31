package ui;

// import options.CustomControlsState;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.util.FlxSignal;
import flixel.input.IFlxInputManager;
import flixel.util.typeLimit.OneOfTwo;
import flixel.input.actions.FlxActionInput;
import flixel.input.FlxInput.FlxInputState;
import flixel.ui.FlxButton;
import flixel.input.actions.FlxActionInputDigital.FlxActionInputDigitalIFlxInput;
import flixel.input.actions.FlxAction.FlxActionDigital;
import Controls.Control;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import ui.FlxVirtualPad;
import ui.Hitbox;

// import Config;

class Mobilecontrols extends FlxSpriteGroup
{
	public var mode:ControlsGroup = ControlsGroup.HITBOX;

	public var _hitbox:Hitbox;
	public var _virtualPad:FlxVirtualPad;

	var cHandler:ControlHandler;

	// var config:Config;

	public function new() 
	{
		super();

		mode = ControlsGroup.HITBOX;
		trace(mode);

		switch (mode)
		{
			case VIRTUALPAD_RIGHT:
				initVirtualPad(0);
				cHandler = new ControlHandler(_virtualPad);
				cHandler.bind();
			case VIRTUALPAD_LEFT:
				initVirtualPad(1);
				cHandler = new ControlHandler(_virtualPad);
				cHandler.bind();
			case VIRTUALPAD_CUSTOM:
				initVirtualPad(2);
				cHandler = new ControlHandler(_virtualPad);
				cHandler.bind();
			case HITBOX:
				_hitbox = new Hitbox(3, Std.int(FlxG.width / 4), FlxG.height, [0xFF00FF, 0x00FFFF, 0x00FF00, 0xFF0000]);
				add(_hitbox);
				cHandler = new ControlHandler(_hitbox);
				cHandler.bind();
			case KEYBOARD:
		}
	}

	function initVirtualPad(vpadMode:Int) 
	{
		switch (vpadMode)
		{
			case 1:
				_virtualPad = new FlxVirtualPad(FULL, NONE);
			case 2:
				_virtualPad = new FlxVirtualPad(FULL, NONE);
			default: // 0
				_virtualPad = new FlxVirtualPad(RIGHT_FULL, NONE);
		}
		
		_virtualPad.alpha = 0.75;
		add(_virtualPad);	
	}

	// adding pad to state (not substate)
	public static function addVirtualPad(?DPad:FlxDPadMode, ?Action:FlxActionMode) {
		var pad = createVirtualPad(DPad, Action);

		if (pad != null)
			FlxG.state.add(pad);

		return pad;
	}

	public static function addPadCamera(vpad:FlxBasic) {
		var cam = new FlxCamera();
		cam.bgColor = 0;
		FlxG.cameras.add(cam, false);
		vpad.cameras = [cam];
		return vpad;
	}

	public static function createVirtualPad(?DPad:FlxDPadMode, ?Action:FlxActionMode):Null<FlxVirtualPad> 
	{
		var virtualPad = new FlxVirtualPad(DPad, Action);
		new ControlHandler(virtualPad).bind();
		return virtualPad;
	}
}

@:access(Controls)
class ControlHandler 
{
	var isPad:Bool = true;
	var trackedinputs:Array<FlxActionInput>;

	public var virtualPad(default, null):FlxVirtualPad;
	public var hitbox(default, null):Hitbox;

	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	public function new(obj:OneOfTwo<FlxVirtualPad, Hitbox>) 
	{
		if (obj is FlxVirtualPad)
		{
			isPad = true;
			virtualPad = obj;
		}
		else if (obj is Hitbox)
		{
			isPad = false;
			hitbox = obj;
		}
		else { trace("unknown control type"); }

		FlxG.signals.preGameReset.add(forceUnBind);
		FlxG.signals.preStateSwitch.add(forceUnBind);
	}

	// bind to controls class
	public function bind() {
		trackedinputs = [];
		if (isPad)
			setVirtualPad();
		else
			setHitBox();
	}

	public function unBind() {
		removeFlxInput(trackedinputs);
		trackedinputs = null;
	}

	function forceUnBind() {
		FlxG.signals.preGameReset.remove(forceUnBind);
		FlxG.signals.preStateSwitch.remove(forceUnBind);
		
		if (trackedinputs != null)
			unBind();
	}

	public function setVirtualPad() {
		var upActions = [Control.UI_UP, Control.NOTE_UP];
		var downActions = [Control.UI_DOWN, Control.NOTE_DOWN];
		var leftActions = [Control.UI_LEFT, Control.NOTE_LEFT];
		var rightActions = [Control.UI_RIGHT, Control.NOTE_RIGHT];
		var aActions = [Control.ACCEPT];
		var bActions = [Control.BACK];

		for (button in virtualPad.members)
		{
			var name = button.frames.frames[0].name;

			switch (name)
			{
				case 'up':
					for (up in upActions)
						inline controls.forEachBound(up, (action, state) -> addbutton(action, cast button, state));
				case 'down':
					for (down in downActions)
						inline controls.forEachBound(down, (action, state) -> addbutton(action, cast button, state));
				case 'left':
					for (left in leftActions)
						inline controls.forEachBound(left, (action, state) -> addbutton(action, cast button, state));
				case 'right':
					for (right in rightActions)
						inline controls.forEachBound(right, (action, state) -> addbutton(action, cast button, state));

				case 'a':
						for (a in aActions)
						inline controls.forEachBound(a, (action, state) -> addbutton(action, cast button, state));
				case 'b':	
					for (b in bActions)
						inline controls.forEachBound(b, (action, state) -> addbutton(action, cast button, state));
			}
		}
	}

	public function setHitBox() 
	{
		var up = Control.NOTE_UP;
		var down = Control.NOTE_DOWN;
		var left = Control.NOTE_LEFT;
		var right = Control.NOTE_RIGHT;

		inline controls.forEachBound(up, (action, state) -> addbutton(action, hitbox.hints[0], state));
		inline controls.forEachBound(down, (action, state) -> addbutton(action, hitbox.hints[1], state));
		inline controls.forEachBound(left, (action, state) -> addbutton(action, hitbox.hints[2], state));
		inline controls.forEachBound(right, (action, state) -> addbutton(action, hitbox.hints[3], state));	
	}

	public function addbutton(action:FlxActionDigital, button:FlxButton, state:FlxInputState) {
		var input = new FlxActionInputDigitalIFlxInput(button, state);
		trackedinputs.push(input);
		
		action.add(input);
	}

	public function removeFlxInput(Tinputs:Array<FlxActionInput>) {
		for (action in controls.digitalActions)
		{
			var i = action.inputs.length;
			
			while (i-- > 0)
			{
				var input = action.inputs[i];

				var x = Tinputs.length;
				while (x-- > 0)
					if (Tinputs[x] == input)
					{
						action.remove(input);
						input.destroy();
					}
			}
		}
	}
}

enum abstract ControlsGroup(Int) to Int from Int {
	var HITBOX = 0;
	var VIRTUALPAD_RIGHT = 1;
	var VIRTUALPAD_LEFT = 2;
	var VIRTUALPAD_CUSTOM = 3;
	var KEYBOARD = 4;
}