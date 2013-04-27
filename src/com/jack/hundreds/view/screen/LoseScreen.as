package com.jack.hundreds.view.screen
{
	import com.jack.hundreds.util.Log;
	
	import feathers.controls.Button;
	
	import starling.events.Event;
	import starling.text.TextField;
	
	[Event(name="showPlay", type="starling.events.Event")]
	[Event(name="complete", type="starling.events.Event")]
	
	public class LoseScreen extends MyBaseScreen
	{
		public static const SHOW_PLAY:String = "showPlay";
		public static const COMPLETE:String = "complete";
		
		public function LoseScreen()
		{
			setBackgroundImage("menuBg");
			
			super();
		}
		
		override protected function onInitialize(e:Event):void
		{
			Log.traced("LoseScreen at level", gameData.curPlayingLevel, "\n The time used is", gameData.timeUsed, "\n The scores is", gameData.totalScores);
			
			super.onInitialize(e);
			
			var txt:TextField = new TextField(200, 100, "RETRY", "Chango", 50, 0xffffff, true);
			var retryBtn:Button = new Button();
			retryBtn.defaultSkin = txt;
			retryBtn.x = 100;
			retryBtn.y = 300;
			addChild(retryBtn);
			retryBtn.addEventListener(Event.TRIGGERED, onRetryBtn);
			
			// add keyboard back handler
			this.backButtonHandler = this.onBackButton;
		}
		
		private function onBackButton():void
		{
			dispatchEventWithGameData(COMPLETE);
		}
		
		private function onRetryBtn(e:Event):void
		{
			dispatchEventWithGameData(SHOW_PLAY);
		}
	}
}