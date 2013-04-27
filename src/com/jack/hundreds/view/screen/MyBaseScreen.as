package com.jack.hundreds.view.screen
{
	import com.jack.hundreds.model.GameData;
	import com.jack.hundreds.model.consts.Constant;
	import com.jack.hundreds.util.Asset;
	
	import feathers.controls.Screen;
	import feathers.events.FeathersEventType;
	
	import starling.display.Image;
	import starling.events.Event;
	
	public class MyBaseScreen extends Screen
	{
		public var gameData:GameData;
		private var m_bgImageName:String;

		protected var bg:Image;
		
		public function MyBaseScreen()
		{
			super();
			
			this.addEventListener(FeathersEventType.INITIALIZE, onInitialize);
		}
		
		protected function setBackgroundImage(backgroundImageName:String):void
		{
			m_bgImageName = backgroundImageName;
		}
		
		protected function onInitialize(e:Event):void
		{
			// add background
			bg = Asset.getDisplayObject(m_bgImageName) as Image;
			bg.width = Constant.STAGE_INIT_WIDTH;
			bg.height = Constant.STAGE_INIT_HEIGHT;
			addChild(bg);
		}
		
		override public function dispose():void
		{
			gameData = null;
			
			super.dispose();
		}
		
		public function onUpdate():void	
		{
			
		}
		
		protected function dispatchEventWithGameData(screenName:String):void
		{
			dispatchEventWith(screenName, false, gameData);
		}
	}
}