package com.jack.hundreds.model.consts
{
	import com.jack.hundreds.view.component.SoundButton;
	import feathers.controls.ScreenNavigator;

	public class Constant
	{
		public static const STAGE_INIT_WIDTH:int = 960;
		public static const STAGE_INIT_HEIGHT:int = 640;
		public static var SCALE_FACTOR_X:Number;
		public static var SCALE_FACTOR_Y:Number;
		public static var STAGE_ACTUAL_WIDTH:Number;
		public static var STAGE_ACTUAL_HEIGHT:Number;
		public static var PHYS_FACTOR_X:Number;
		public static var PHYS_FACTOR_Y:Number;
		public static const IS_LANDSCAPE:Boolean = true;
		public static const m_debugMode:Boolean = true;
		
		public static var m_mouseDown:Boolean = false;
		
		public static const SOUND_ON:String = "on";
		public static const SOUND_OFF:String = "off";
		public static const HUNDREDS_MAX_LEVEL:int = 30;
		public static const HUNDREDS_SHARED_OBJECT:String = "hunderds_shared_object";
		public static const HUNDREDS_SHARED_OBJECT_PASSED_LEVEL:String = "passedLevel";
		public static const HUNDREDS_SHARED_OBJECT_DATA:String = "allLevelsData";
		public static const HUNDREDS_SHARED_OBJECT_SOUND:String = "isSoundEnable";
		
		public static var soundButton:SoundButton;
		public static var navigator:ScreenNavigator;
		
		public static const GAME_STATUS_MENU:int = 1;
		public static const GAME_STATUS_PLAYING:int = 2;
		public static const GAME_STATUS_PAUSE:int = 3;
		public static const GAME_STATUS_WIN:int = 4;
		public static const GAME_STATUS_LOSE:int = 5;
		public static const GAME_STATUS_ACTIVATE:int = 6;
		public static const GAME_STATUS_DEACTIVATE:int = 7;
	}
}