package com.jack.hundreds.view.screen
{
	import com.jack.hundreds.model.GameData;
	import com.jack.hundreds.model.consts.Constant;
	import com.jack.hundreds.util.Asset;
	import com.jack.hundreds.util.Log;
	
	import feathers.controls.Button;
	
	import flash.desktop.NativeApplication;
	
	import starling.display.Image;
	import starling.events.Event;
	
	[Event(name="showLevelSelect", type="starling.events.Event")]
	
	public class MenuScreen extends MyBaseScreen
	{
		public static const SHOW_LEVEL_SELECT:String = "showLevelSelect";
		
		public function MenuScreen()
		{
			setBackgroundImage("menuBg");
			
			super();
		}
		
		override protected function onInitialize(e:Event):void
		{
			Log.traced("Navigate to Menu Screen.");
			
			super.onInitialize(e);
			
			// add start button
			var startBtn:Button = new Button();
			startBtn.defaultSkin = Asset.getDisplayObject("play") as Image;
			addChild(startBtn);
			startBtn.validate();
			startBtn.x =  (bg.width-startBtn.width)/2;
			startBtn.y =  (bg.height-startBtn.height)/2 ;
			startBtn.addEventListener(Event.TRIGGERED, onStartBtn);
			
			
			// show all the levels you already passed
			
			
			// add keyboard back handler
			this.backButtonHandler = this.onBackButton;
			
			GameData.gameStatus = Constant.GAME_STATUS_MENU;
		}
		
		private function onBackButton():void
		{
			// quit the game
			NativeApplication.nativeApplication.exit();
		}
		
		override public function dispose():void
		{
			super.dispose();
		}
		
		private function onStartBtn(e:Event):void
		{
			gameData.curPlayingLevel = gameData.passedMaxLevel;
			gameData.passedMaxLevel = gameData.passedMaxLevel;	
			dispatchEventWithGameData(SHOW_LEVEL_SELECT);
		}
		
		
		
		
	}
}