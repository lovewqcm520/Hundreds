package com.jack.hundreds.view.panel
{
	import com.jack.hundreds.model.consts.Constant;
	import com.jack.hundreds.view.screen.MyBaseScreen;
	
	import starling.display.Sprite;
	
	public class MyBasePanel extends Sprite
	{
		protected static const ICON_SIZE:Number = 128;
		
		public function MyBasePanel()
		{
			super();
			
			initialize();
		}
		
		protected function initialize():void
		{
			
		}
		
		public function show():void
		{
			
		}
		
		public function hide():void
		{
			
		}

		protected function destroy():void
		{
			
		}
		
		protected function dispatchEventWithGameData(screenName:String):void
		{
			dispatchEventWith(screenName, false, (Constant.navigator.activeScreen as MyBaseScreen).gameData);
		}
	}
}