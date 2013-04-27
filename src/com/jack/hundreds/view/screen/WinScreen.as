package com.jack.hundreds.view.screen
{
	import com.jack.hundreds.util.Log;
	
	import feathers.controls.Button;
	
	import starling.events.Event;
	import starling.text.TextField;
	
	[Event(name="showPlay", type="starling.events.Event")]
	[Event(name="complete", type="starling.events.Event")]
	
	public class WinScreen extends MyBaseScreen
	{
		public static const SHOW_PLAY:String = "showPlay";
		public static const COMPLETE:String = "complete";
		
		public function WinScreen()
		{
			setBackgroundImage("menuBg");
			
			super();
		}
		
		override protected function onInitialize(e:Event):void
		{
			Log.traced("WinScreen at level", gameData.curPlayingLevel-1, "\n The time used is", gameData.timeUsed, "\n The scores is", gameData.totalScores);
			
			super.onInitialize(e);
			
			var txt:TextField = new TextField(200, 100, "NEXT", "Chango", 50, 0xffffff, true);
			var nextLevelBtn:Button = new Button();
			nextLevelBtn.defaultSkin = txt;
			nextLevelBtn.x = 100;
			nextLevelBtn.y = 300;
			addChild(nextLevelBtn);
			nextLevelBtn.addEventListener(Event.TRIGGERED, onNextLevelBtn);
			
			// add keyboard back handler
			this.backButtonHandler = this.onBackButton;
		}
		
		private function onBackButton():void
		{
			dispatchEventWithGameData(COMPLETE);
		}
		
		private function onNextLevelBtn(e:Event):void
		{
			dispatchEventWithGameData(SHOW_PLAY);
		}
	}
}