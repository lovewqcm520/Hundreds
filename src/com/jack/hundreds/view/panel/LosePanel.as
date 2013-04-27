package com.jack.hundreds.view.panel
{
	import com.jack.hundreds.model.consts.Constant;
	import com.jack.hundreds.util.Asset;
	import com.jack.hundreds.view.screen.MainScreen;
	import com.jack.hundreds.view.screen.PlayScreen;
	
	import feathers.controls.Button;
	
	import starling.display.Image;
	import starling.events.Event;

	public class LosePanel extends MyBasePanel
	{
		public function LosePanel()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			// add bg
			var bg:Image = Asset.getDisplayObject("panel_background") as Image;
			addChild(bg);
			
			// add buttons
			var refreshBtn:Button = new Button();
			refreshBtn.defaultSkin = Asset.getDisplayObject("refresh");
			addChild(refreshBtn);
			refreshBtn.addEventListener(Event.TRIGGERED, onRefreshBtn);
			refreshBtn.x = 355;
			refreshBtn.y = 223;
			
			var menuBtn:Button = new Button();
			menuBtn.defaultSkin = Asset.getDisplayObject("menu");
			addChild(menuBtn);
			menuBtn.addEventListener(Event.TRIGGERED, onMenuBtn);
			menuBtn.x = 150;
			menuBtn.y = 223;
			
			// add keyboard back handler
		}
		
		private function onMenuBtn(e:Event):void
		{
			Constant.navigator.showScreen(MainScreen.SELECT_LEVEL_SCREEN);
		}
		
		private function onRefreshBtn(e:Event):void
		{
			(Constant.navigator.activeScreen as PlayScreen).restart();
			this.removeFromParent(true);
		}
		
		override public function dispose():void
		{
			// TODO Auto Generated method stub
			super.dispose();
		}
	}
}