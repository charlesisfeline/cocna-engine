package;

import flixel.input.gamepad.FlxGamepad;
import flixel.FlxG;
import flixel.input.FlxInput;
import flixel.input.actions.FlxAction;
import flixel.input.actions.FlxActionInput;
import flixel.input.actions.FlxActionInputDigital;
import flixel.input.actions.FlxActionManager;
import flixel.input.actions.FlxActionSet;
import flixel.input.gamepad.FlxGamepadButton;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;

#if (haxe >= "4.0.0")
enum abstract Action(String) to String from String
{
	var SixKeyLeft = "6kleft";
	var UP = "up";
	var LEFT = "left";
	var MIDDLE = "space";
	var RIGHT = "right";
	var DOWN = "down";
	var SixKeyRight = "6kRight";


	var SixKeyLeft_P = "6kLeft-press";
	var UP_P = "up-press";
	var LEFT_P = "left-press";
	var MIDDLE_P = "space-press";
	var RIGHT_P = "right-press";
	var DOWN_P = "down-press";
	var SixKeyRight_P = "6kRight-press";


	var SixKeyLeft_R = "6kLeft-release";
	var UP_R = "up-release";
	var LEFT_R = "left-release";
	var MIDDLE_R = "space-release";
	var RIGHT_R = "right-release";
	var DOWN_R = "down-release";
	var SixKeyRight_R = "6kRight-release";


	var ACCEPT = "accept";
	var BACK = "back";
	var PAUSE = "pause";
	var RESET = "reset";
	var CHEAT = "cheat";
}
#else
@:enum
abstract Action(String) to String from String
{
	var SixKeyLeft = "6kleft";
	var UP = "up";
	var LEFT = "left";
	var MIDDLE = "space";
	var RIGHT = "right";
	var DOWN = "down";
	var SixKeyRight = "6kRight";


	var SixKeyLeft_P = "6kLeft-press";
	var UP_P = "up-press";
	var LEFT_P = "left-press";
	var MIDDLE_P = "space-press";
	var RIGHT_P = "right-press";
	var DOWN_P = "down-press";
	var SixKeyRight_P = "6kRight-press";


	var SixKeyLeft_R = "6kLeft-release";
	var UP_R = "up-release";
	var LEFT_R = "left-release";
	var MIDDLE_P = "space-release";
	var RIGHT_R = "right-release";
	var DOWN_R = "down-release";
	var SixKeyRight_R = "6kRight-release";


	var ACCEPT = "accept";
	var BACK = "back";
	var PAUSE = "pause";
	var RESET = "reset";
	var CHEAT = "cheat";
}
#end

enum Device
{
	Keys;
	Gamepad(id:Int);
}

/**
 * Since, in many cases multiple actions should use similar keys, we don't want the
 * rebinding UI to list every action. ActionBinders are what the user percieves as
 * an input so, for instance, they can't set jump-press and jump-release to different keys.
 */
enum Control
{
	SixKeyLeft;
	UP;
	LEFT;
	MIDDLE;
	RIGHT;
	DOWN;
	SixKeyRight;
	RESET;
	ACCEPT;
	BACK;
	PAUSE;
	CHEAT;
}

enum KeyboardScheme
{
	Solo;
	Duo(first:Bool);
	None;
	Custom;
}

/**
 * A list of actions that a player would invoke via some input device.
 * Uses FlxActions to funnel various inputs to a single action.
 */
class Controls extends FlxActionSet
{
	var _6kleft = new FlxActionDigital(Action.SixKeyLeft);
	var _up = new FlxActionDigital(Action.UP);
	var _left = new FlxActionDigital(Action.LEFT);
	var _middle = new FlxActionDigital(Action.MIDDLE);
	var _right = new FlxActionDigital(Action.RIGHT);
	var _down = new FlxActionDigital(Action.DOWN);
	var _6kright = new FlxActionDigital(Action.SixKeyRight);


	var _6kleftP = new FlxActionDigital(Action.SixKeyLeft_P);
	var _upP = new FlxActionDigital(Action.UP_P);
	var _leftP = new FlxActionDigital(Action.LEFT_P);
	var _middleP = new FlxActionDigital(Action.MIDDLE_P);
	var _rightP = new FlxActionDigital(Action.RIGHT_P);
	var _downP = new FlxActionDigital(Action.DOWN_P);
	var _6krightP = new FlxActionDigital(Action.SixKeyRight_P);


	var _6kleftR = new FlxActionDigital(Action.SixKeyLeft_R);
	var _upR = new FlxActionDigital(Action.UP_R);
	var _leftR = new FlxActionDigital(Action.LEFT_R);
	var _middleR = new FlxActionDigital(Action.MIDDLE_R);
	var _rightR = new FlxActionDigital(Action.RIGHT_R);
	var _downR = new FlxActionDigital(Action.DOWN_R);
	var _6krightR = new FlxActionDigital(Action.SixKeyRight_R);


	var _accept = new FlxActionDigital(Action.ACCEPT);
	var _back = new FlxActionDigital(Action.BACK);
	var _pause = new FlxActionDigital(Action.PAUSE);
	var _reset = new FlxActionDigital(Action.RESET);
	var _cheat = new FlxActionDigital(Action.CHEAT);

	#if (haxe >= "4.0.0")
	var byName:Map<String, FlxActionDigital> = [];
	#else
	var byName:Map<String, FlxActionDigital> = new Map<String, FlxActionDigital>();
	#end

	public var gamepadsAdded:Array<Int> = [];
	public var keyboardScheme = KeyboardScheme.None;

	
	public var SixKeyLeft(get, never):Bool;

	inline function get_SixKeyLeft()
		return _6kleft.check();
	
	
	public var UP(get, never):Bool;

	inline function get_UP()
		return _up.check();

	public var LEFT(get, never):Bool;

	inline function get_LEFT()
		return _left.check();

	public var MIDDLE(get, never):Bool;

	inline function get_MIDDLE()
		return _middle.check();

	public var RIGHT(get, never):Bool;

	inline function get_RIGHT()
		return _right.check();

	public var DOWN(get, never):Bool;

	inline function get_DOWN()
		return _down.check();

	public var SixKeyRight(get, never):Bool;

	inline function get_SixKeyRight()
		return _6kright.check();



	public var SixKeyLeft_P(get, never):Bool;

	inline function get_SixKeyLeft_P()
		return _6kleftP.check();

	public var UP_P(get, never):Bool;

	inline function get_UP_P()
		return _upP.check();

	public var LEFT_P(get, never):Bool;

	inline function get_LEFT_P()
		return _leftP.check();
	
	
	public var MIDDLE_P(get, never):Bool;

	inline function get_MIDDLE_P()
		return _middleP.check();

	public var RIGHT_P(get, never):Bool;

	inline function get_RIGHT_P()
		return _rightP.check();

	public var DOWN_P(get, never):Bool;

	inline function get_DOWN_P()
		return _downP.check();


	public var SixKeyRight_P(get, never):Bool;

	inline function get_SixKeyRight_P()
		return _6krightP.check();



	public var SixKeyLeft_R(get, never):Bool;

	inline function get_SixKeyLeft_R()
		return _6kleftR.check();
	

	public var UP_R(get, never):Bool;

	inline function get_UP_R()
		return _upR.check();

	public var MIDDLE_R(get, never):Bool;

	inline function get_MIDDLE_R()
		return _middleR.check();

	public var LEFT_R(get, never):Bool;

	inline function get_LEFT_R()
		return _leftR.check();

	public var RIGHT_R(get, never):Bool;

	inline function get_RIGHT_R()
		return _rightR.check();


	public var DOWN_R(get, never):Bool;

	inline function get_DOWN_R()
		return _downR.check();


	public var SixKeyRight_R(get, never):Bool;

	inline function get_SixKeyRight_R()
		return _6krightR.check();

	public var ACCEPT(get, never):Bool;

	inline function get_ACCEPT()
		return _accept.check();

	public var BACK(get, never):Bool;

	inline function get_BACK()
		return _back.check();

	public var PAUSE(get, never):Bool;

	inline function get_PAUSE()
		return _pause.check();

	public var RESET(get, never):Bool;

	inline function get_RESET()
		return _reset.check();

	public var CHEAT(get, never):Bool;

	inline function get_CHEAT()
		return _cheat.check();

	#if (haxe >= "4.0.0")
	public function new(name, scheme = None)
	{
		super(name);

		add(_6kleft);
		add(_up);
		add(_left);
		add(_middle);
		add(_right);
		add(_down);
		add(_6kright);
		
		
		add(_6kleftP);
		add(_upP);
		add(_leftP);
		add(_middleP);
		add(_rightP);
		add(_downP);
		add(_6krightP);


		add(_6kleftR);
		add(_upR);
		add(_leftR);
		add(_middleR);
		add(_rightR);
		add(_downR);
		add(_6krightR);


		add(_accept);
		add(_back);
		add(_pause);
		add(_reset);
		add(_cheat);

		for (action in digitalActions)
			byName[action.name] = action;

		setKeyboardScheme(scheme, false);
	}
	#else
	public function new(name, scheme:KeyboardScheme = null)
	{
		super(name);

		add(_6kleft);
		add(_up);
		add(_left);
		add(_middle);
		add(_right);
		add(_down);
		add(_6kright);
		
		
		add(_6kleftP);
		add(_upP);
		add(_leftP);
		add(_middleP);
		add(_rightP);
		add(_downP);
		add(_6krightP);


		add(_6kleftR);
		add(_upR);
		add(_leftR);
		add(_middleR);
		add(_rightR);
		add(_downR);
		add(_6krightR);


		add(_accept);
		add(_back);
		add(_pause);
		add(_reset);
		add(_cheat);

		for (action in digitalActions)
			byName[action.name] = action;
			
		if (scheme == null)
			scheme = None;
		setKeyboardScheme(scheme, false);
	}
	#end

	override function update()
	{
		super.update();
	}

	// inline
	public function checkByName(name:Action):Bool
	{
		#if debug
		if (!byName.exists(name))
			throw 'Invalid name: $name';
		#end
		return byName[name].check();
	}

	public function getDialogueName(action:FlxActionDigital):String
	{
		var input = action.inputs[0];
		return switch input.device
		{
			case KEYBOARD: return '[${(input.inputID : FlxKey)}]';
			case GAMEPAD: return '(${(input.inputID : FlxGamepadInputID)})';
			case device: throw 'unhandled device: $device';
		}
	}

	public function getDialogueNameFromToken(token:String):String
	{
		return getDialogueName(getActionFromControl(Control.createByName(token.toUpperCase())));
	}

	function getActionFromControl(control:Control):FlxActionDigital
	{
		return switch (control)
		{
			case SixKeyLeft: _6kleft;
			case UP: _up;
			case DOWN: _down;
			case MIDDLE: _middle;
			case LEFT: _left;
			case RIGHT: _right;
			case SixKeyRight: _6kright;


			case ACCEPT: _accept;
			case BACK: _back;
			case PAUSE: _pause;
			case RESET: _reset;
			case CHEAT: _cheat;
		}
	}

	static function init():Void
	{
		var actions = new FlxActionManager();
		FlxG.inputs.add(actions);
	}

	/**
	 * Calls a function passing each action bound by the specified control
	 * @param control
	 * @param func
	 * @return ->Void)
	 */
	function forEachBound(control:Control, func:FlxActionDigital->FlxInputState->Void)
	{
		switch (control)
		{
			case SixKeyLeft:
				func(_6kleft, PRESSED);
				func(_6kleftP, JUST_PRESSED);
				func(_6kleftR, JUST_RELEASED);

			case SixKeyRight:
				func(_6kright, PRESSED);
				func(_6krightP, JUST_PRESSED);
				func(_6krightR, JUST_RELEASED);
			
			case UP:
				func(_up, PRESSED);
				func(_upP, JUST_PRESSED);
				func(_upR, JUST_RELEASED);
			case LEFT:
				func(_left, PRESSED);
				func(_leftP, JUST_PRESSED);
				func(_leftR, JUST_RELEASED);
			case MIDDLE:
				func(_middle, PRESSED);
				func(_middleP, JUST_PRESSED);
				func(_middleR, JUST_RELEASED);
			case RIGHT:
				func(_right, PRESSED);
				func(_rightP, JUST_PRESSED);
				func(_rightR, JUST_RELEASED);
			case DOWN:
				func(_down, PRESSED);
				func(_downP, JUST_PRESSED);
				func(_downR, JUST_RELEASED);
			case ACCEPT:
				func(_accept, JUST_PRESSED);
			case BACK:
				func(_back, JUST_PRESSED);
			case PAUSE:
				func(_pause, JUST_PRESSED);
			case RESET:
				func(_reset, JUST_PRESSED);
			case CHEAT:
				func(_cheat, JUST_PRESSED);
		}
	}

	public function replaceBinding(control:Control, device:Device, ?toAdd:Int, ?toRemove:Int)
	{
		if (toAdd == toRemove)
			return;

		switch (device)
		{
			case Keys:
				if (toRemove != null)
					unbindKeys(control, [toRemove]);
				if (toAdd != null)
					bindKeys(control, [toAdd]);

			case Gamepad(id):
				if (toRemove != null)
					unbindButtons(control, id, [toRemove]);
				if (toAdd != null)
					bindButtons(control, id, [toAdd]);
		}
	}

	public function copyFrom(controls:Controls, ?device:Device)
	{
		#if (haxe >= "4.0.0")
		for (name => action in controls.byName)
		{
			for (input in action.inputs)
			{
				if (device == null || isDevice(input, device))
					byName[name].add(cast input);
			}
		}
		#else
		for (name in controls.byName.keys())
		{
			var action = controls.byName[name];
			for (input in action.inputs)
			{
				if (device == null || isDevice(input, device))
				byName[name].add(cast input);
			}
		}
		#end

		switch (device)
		{
			case null:
				// add all
				#if (haxe >= "4.0.0")
				for (gamepad in controls.gamepadsAdded)
					if (!gamepadsAdded.contains(gamepad))
						gamepadsAdded.push(gamepad);
				#else
				for (gamepad in controls.gamepadsAdded)
					if (gamepadsAdded.indexOf(gamepad) == -1)
					  gamepadsAdded.push(gamepad);
				#end

				mergeKeyboardScheme(controls.keyboardScheme);

			case Gamepad(id):
				gamepadsAdded.push(id);
			case Keys:
				mergeKeyboardScheme(controls.keyboardScheme);
		}
	}

	inline public function copyTo(controls:Controls, ?device:Device)
	{
		controls.copyFrom(this, device);
	}

	function mergeKeyboardScheme(scheme:KeyboardScheme):Void
	{
		if (scheme != None)
		{
			switch (keyboardScheme)
			{
				case None:
					keyboardScheme = scheme;
				default:
					keyboardScheme = Custom;
			}
		}
	}

	/**
	 * Sets all actions that pertain to the binder to trigger when the supplied keys are used.
	 * If binder is a literal you can inline this
	 */
	public function bindKeys(control:Control, keys:Array<FlxKey>)
	{
		#if (haxe >= "4.0.0")
		inline forEachBound(control, (action, state) -> addKeys(action, keys, state));
		#else
		forEachBound(control, function(action, state) addKeys(action, keys, state));
		#end
	}

	/**
	 * Sets all actions that pertain to the binder to trigger when the supplied keys are used.
	 * If binder is a literal you can inline this
	 */
	public function unbindKeys(control:Control, keys:Array<FlxKey>)
	{
		#if (haxe >= "4.0.0")
		inline forEachBound(control, (action, _) -> removeKeys(action, keys));
		#else
		forEachBound(control, function(action, _) removeKeys(action, keys));
		#end
	}

	inline static function addKeys(action:FlxActionDigital, keys:Array<FlxKey>, state:FlxInputState)
	{
		for (key in keys)
			action.addKey(key, state);
	}

	static function removeKeys(action:FlxActionDigital, keys:Array<FlxKey>)
	{
		var i = action.inputs.length;
		while (i-- > 0)
		{
			var input = action.inputs[i];
			if (input.device == KEYBOARD && keys.indexOf(cast input.inputID) != -1)
				action.remove(input);
		}
	}

	public function setKeyboardScheme(scheme:KeyboardScheme, reset = true)
	{

		loadKeyBinds();
		/*if (reset)
			removeKeyboard();

		keyboardScheme = scheme;
		
		#if (haxe >= "4.0.0")
		switch (scheme)
		{
			case Solo:
				inline bindKeys(Control.UP, [FlxKey.fromString("W"), FlxKey.UP]);
				inline bindKeys(Control.DOWN, [FlxKey.fromString("S"), FlxKey.DOWN]);
				inline bindKeys(Control.LEFT, [FlxKey.fromString("A"), FlxKey.LEFT]);
				inline bindKeys(Control.RIGHT, [FlxKey.fromString("D"), FlxKey.RIGHT]);
				inline bindKeys(Control.ACCEPT, [Z, SPACE, ENTER]);
				inline bindKeys(Control.BACK, [BACKSPACE, ESCAPE]);
				inline bindKeys(Control.PAUSE, [P, ENTER, ESCAPE]);
				inline bindKeys(Control.RESET, [FlxKey.fromString("R")]);
			case Duo(true):
				inline bindKeys(Control.UP, [W, K]);
				inline bindKeys(Control.DOWN, [S, J]);
				inline bindKeys(Control.LEFT, [A, H]);
				inline bindKeys(Control.RIGHT, [D, L]);
				inline bindKeys(Control.ACCEPT, [Z]);
				inline bindKeys(Control.BACK, [X]);
				inline bindKeys(Control.PAUSE, [ONE]);
				inline bindKeys(Control.RESET, [R]);
			case Duo(false):
				inline bindKeys(Control.UP, [FlxKey.UP]);
				inline bindKeys(Control.DOWN, [FlxKey.DOWN]);
				inline bindKeys(Control.LEFT, [FlxKey.LEFT]);
				inline bindKeys(Control.RIGHT, [FlxKey.RIGHT]);
				inline bindKeys(Control.ACCEPT, [O]);
				inline bindKeys(Control.BACK, [P]);
				inline bindKeys(Control.PAUSE, [ENTER]);
				inline bindKeys(Control.RESET, [BACKSPACE]);
			case None: // nothing
			case Custom: // nothing
		}
		#else
		switch (scheme)
		{
			case Solo:
				bindKeys(Control.UP, [W, K, FlxKey.UP]);
				bindKeys(Control.DOWN, [S, J, FlxKey.DOWN]);
				bindKeys(Control.LEFT, [A, H, FlxKey.LEFT]);
				bindKeys(Control.RIGHT, [D, L, FlxKey.RIGHT]);
				bindKeys(Control.ACCEPT, [Z, SPACE, ENTER]);
				bindKeys(Control.BACK, [BACKSPACE, ESCAPE]);
				bindKeys(Control.PAUSE, [P, ENTER, ESCAPE]);
				bindKeys(Control.RESET, [R]);
			case Duo(true):
				bindKeys(Control.UP, [W, K]);
				bindKeys(Control.DOWN, [S, J]);
				bindKeys(Control.LEFT, [A, H]);
				bindKeys(Control.RIGHT, [D, L]);
				bindKeys(Control.ACCEPT, [Z]);
				bindKeys(Control.BACK, [X]);
				bindKeys(Control.PAUSE, [ONE]);
				bindKeys(Control.RESET, [R]);
			case Duo(false):
				bindKeys(Control.UP, [FlxKey.UP]);
				bindKeys(Control.DOWN, [FlxKey.DOWN]);
				bindKeys(Control.LEFT, [FlxKey.LEFT]);
				bindKeys(Control.RIGHT, [FlxKey.RIGHT]);
				bindKeys(Control.ACCEPT, [O]);
				bindKeys(Control.BACK, [P]);
				bindKeys(Control.PAUSE, [ENTER]);
				bindKeys(Control.RESET, [BACKSPACE]);
			case None: // nothing
			case Custom: // nothing
		}
		#end*/
	}

	public function loadKeyBinds()
	{

		//trace(FlxKey.fromString(FlxG.save.data.upBind));

		removeKeyboard();
		if (gamepadsAdded.length != 0)
			removeGamepad();
		KeyBinds.keyCheck();

		var buttons = new Map<Control,Array<FlxGamepadInputID>>();

		buttons.set(Control.SixKeyLeft,[FlxGamepadInputID.fromString(FlxG.save.data.gpsixleftbind)]);
		buttons.set(Control.SixKeyRight,[FlxGamepadInputID.fromString(FlxG.save.data.gpsixrightbind)]);
		
		buttons.set(Control.UP,[FlxGamepadInputID.fromString(FlxG.save.data.gpupBind)]);
		
		buttons.set(Control.LEFT,[FlxGamepadInputID.fromString(FlxG.save.data.gpleftBind)]);
		
		buttons.set(Control.MIDDLE,[FlxGamepadInputID.fromString(FlxG.save.data.gpMiddleBind)]);
		
		buttons.set(Control.DOWN,[FlxGamepadInputID.fromString(FlxG.save.data.gpdownBind)]);
		buttons.set(Control.RIGHT,[FlxGamepadInputID.fromString(FlxG.save.data.gprightBind)]);
	
		buttons.set(Control.ACCEPT,[FlxGamepadInputID.A]);
		buttons.set(Control.BACK,[FlxGamepadInputID.B]);
		buttons.set(Control.PAUSE,[FlxGamepadInputID.START]);

		addGamepad(0,buttons);

		inline bindKeys(Control.SixKeyLeft, [FlxKey.fromString(FlxG.save.data.sixLeftBind), FlxKey.S]);
		inline bindKeys(Control.SixKeyRight, [FlxKey.fromString(FlxG.save.data.sixRightBind), FlxKey.L]);
		inline bindKeys(Control.UP, [FlxKey.fromString(FlxG.save.data.upBind), FlxKey.UP]);
		inline bindKeys(Control.DOWN, [FlxKey.fromString(FlxG.save.data.downBind), FlxKey.DOWN]);
		inline bindKeys(Control.MIDDLE, [FlxKey.fromString(FlxG.save.data.middleBind), FlxKey.DOWN]);
		inline bindKeys(Control.LEFT, [FlxKey.fromString(FlxG.save.data.leftBind), FlxKey.LEFT]);
		inline bindKeys(Control.RIGHT, [FlxKey.fromString(FlxG.save.data.rightBind), FlxKey.RIGHT]);
		inline bindKeys(Control.ACCEPT, [Z, SPACE, ENTER]);
		inline bindKeys(Control.BACK, [BACKSPACE, ESCAPE]);
		inline bindKeys(Control.PAUSE, [ENTER, ESCAPE]);
		inline bindKeys(Control.RESET, [FlxKey.fromString(FlxG.save.data.killBind)]);
	}

	function removeKeyboard()
	{
		for (action in this.digitalActions)
		{
			var i = action.inputs.length;
			while (i-- > 0)
			{
				var input = action.inputs[i];
				if (input.device == KEYBOARD)
					action.remove(input);
			}
		}
	}

	public function addGamepad(id:Int, ?buttonMap:Map<Control, Array<FlxGamepadInputID>>):Void
	{
		if (gamepadsAdded.contains(id))
			gamepadsAdded.remove(id);

		gamepadsAdded.push(id);
		
		#if (haxe >= "4.0.0")
		for (control => buttons in buttonMap)
			inline bindButtons(control, id, buttons);
		#else
		for (control in buttonMap.keys())
			bindButtons(control, id, buttonMap[control]);
		#end
	}

	inline function addGamepadLiteral(id:Int, ?buttonMap:Map<Control, Array<FlxGamepadInputID>>):Void
	{
		gamepadsAdded.push(id);

		#if (haxe >= "4.0.0")
		for (control => buttons in buttonMap)
			inline bindButtons(control, id, buttons);
		#else
		for (control in buttonMap.keys())
			bindButtons(control, id, buttonMap[control]);
		#end
	}

	public function removeGamepad(deviceID:Int = FlxInputDeviceID.ALL):Void
	{
		for (action in this.digitalActions)
		{
			var i = action.inputs.length;
			while (i-- > 0)
			{
				var input = action.inputs[i];
				if (input.device == GAMEPAD && (deviceID == FlxInputDeviceID.ALL || input.deviceID == deviceID))
					action.remove(input);
			}
		}

		gamepadsAdded.remove(deviceID);
	}

	public function addDefaultGamepad(id):Void
	{
		#if !switch
		addGamepadLiteral(id, [
			Control.ACCEPT => [A],
			Control.BACK => [B],
			Control.SixKeyLeft => [X, LEFT_STICK_DIGITAL_UP],
			Control.SixKeyRight => [B, LEFT_STICK_DIGITAL_UP],
			Control.UP => [DPAD_UP, LEFT_STICK_DIGITAL_UP],
			Control.DOWN => [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN],
			Control.LEFT => [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT],
			Control.RIGHT => [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT],
			Control.PAUSE => [START],
			Control.RESET => [Y]
		]);
		#else
		addGamepadLiteral(id, [
			//Swap A and B for switch
			Control.ACCEPT => [A],
			Control.BACK => [B],
			Control.SixKeyLeft => [DPAD_X, LEFT_STICK_DIGITAL_UP],
			Control.SixKeyRight => [DPAD_B, LEFT_STICK_DIGITAL_UP],
			Control.UP => [DPAD_X, LEFT_STICK_DIGITAL_UP],
			Control.UP => [DPAD_UP, LEFT_STICK_DIGITAL_UP],
			Control.DOWN => [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN],
			Control.LEFT => [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT],
			Control.RIGHT => [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT],
			Control.PAUSE => [START],
			Control.RESET => [Y]
		]);
		#end
	}

	/**
	 * Sets all actions that pertain to the binder to trigger when the supplied keys are used.
	 * If binder is a literal you can inline this
	 */
	public function bindButtons(control:Control, id, buttons)
	{
		#if (haxe >= "4.0.0")
		inline forEachBound(control, (action, state) -> addButtons(action, buttons, state, id));
		#else
		forEachBound(control, function(action, state) addButtons(action, buttons, state, id));
		#end
	}

	/**
	 * Sets all actions that pertain to the binder to trigger when the supplied keys are used.
	 * If binder is a literal you can inline this
	 */
	public function unbindButtons(control:Control, gamepadID:Int, buttons)
	{
		#if (haxe >= "4.0.0")
		inline forEachBound(control, (action, _) -> removeButtons(action, gamepadID, buttons));
		#else
		forEachBound(control, function(action, _) removeButtons(action, gamepadID, buttons));
		#end
	}

	inline static function addButtons(action:FlxActionDigital, buttons:Array<FlxGamepadInputID>, state, id)
	{
		for (button in buttons)
			action.addGamepad(button, state, id);
	}

	static function removeButtons(action:FlxActionDigital, gamepadID:Int, buttons:Array<FlxGamepadInputID>)
	{
		var i = action.inputs.length;
		while (i-- > 0)
		{
			var input = action.inputs[i];
			if (isGamepad(input, gamepadID) && buttons.indexOf(cast input.inputID) != -1)
				action.remove(input);
		}
	}

	public function getInputsFor(control:Control, device:Device, ?list:Array<Int>):Array<Int>
	{
		if (list == null)
			list = [];

		switch (device)
		{
			case Keys:
				for (input in getActionFromControl(control).inputs)
				{
					if (input.device == KEYBOARD)
						list.push(input.inputID);
				}
			case Gamepad(id):
				for (input in getActionFromControl(control).inputs)
				{
					if (input.deviceID == id)
						list.push(input.inputID);
				}
		}
		return list;
	}

	public function removeDevice(device:Device)
	{
		switch (device)
		{
			case Keys:
				setKeyboardScheme(None);
			case Gamepad(id):
				removeGamepad(id);
		}
	}

	static function isDevice(input:FlxActionInput, device:Device)
	{
		return switch device
		{
			case Keys: input.device == KEYBOARD;
			case Gamepad(id): isGamepad(input, id);
		}
	}

	inline static function isGamepad(input:FlxActionInput, deviceID:Int)
	{
		return input.device == GAMEPAD && (deviceID == FlxInputDeviceID.ALL || input.deviceID == deviceID);
	}
}
