package com.jack.hundreds
{
	import com.jack.hundreds.model.consts.Constant;
	import com.jack.hundreds.util.AssetManager;
	import com.jack.hundreds.util.ProgressBar;
	import com.jack.hundreds.view.MySprite;
	import com.jack.hundreds.view.screen.MainScreen;
	
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	
	public class Root extends MySprite
	{
		private static var _sAssets:AssetManager;
		private var m_playTime:int;
		
		private var touch:Touch;

		private var mainScreen:MainScreen;
		
		public function Root()
		{
			super();
		}
		
		public function start(background:Texture, assets:AssetManager):void
		{
			_sAssets = assets;
			
			var bg:Image = new Image(background); 
			bg.width = Constant.STAGE_INIT_WIDTH;
			bg.height = Constant.STAGE_INIT_HEIGHT;
			addChildScaled(bg);
			
			// The AssetManager contains all the raw asset data, but has not created the textures
			// yet. This takes some time (the assets might be loaded from disk or even via the
			// network), during which we display a progress indicator. 
			
			var progressBar:ProgressBar = new ProgressBar(175, 20);
			addChildScaled(progressBar);
			progressBar.x = (Constant.STAGE_ACTUAL_WIDTH  - progressBar.width)  / 2;
			progressBar.y = (Constant.STAGE_ACTUAL_HEIGHT - progressBar.height) / 2;
			progressBar.y = Constant.STAGE_ACTUAL_HEIGHT * 0.85;
			
			assets.loadQueue(function onProgress(ratio:Number):void
			{
				progressBar.ratio = ratio;
				
				// a progress bar should always show the 100% for a while,
				// so we show the main menu only after a short delay. 
				
				if(ratio == 1)
				{
					Starling.juggler.delayCall(function():void
					{
						progressBar.removeFromParent(true);
						showScene();
					}, 0.15);
				}
			});
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, handleKeyUp);
			stage.addEventListener(TouchEvent.TOUCH, handleTouch);
			// When the game becomes inactive, we pause Starling; otherwise, the enter frame event
			// would report a very long 'passedTime' when the app is reactivated.			
			NativeApplication.nativeApplication.addEventListener(flash.events.Event.ACTIVATE, onActivate);
			NativeApplication.nativeApplication.addEventListener(flash.events.Event.DEACTIVATE, onDeactivate);
			NativeApplication.nativeApplication.addEventListener(flash.events.Event.EXITING, onExit);
		}
		
		protected function onExit(event:flash.events.Event):void
		{
			// TODO Auto-generated method stub
			
		}
		
		protected function onDeactivate(event:flash.events.Event):void
		{
			// TODO Auto-generated method stub
			
		}
		
		protected function onActivate(event:flash.events.Event):void
		{
			// TODO Auto-generated method stub
			
		}
		
		private function handleTouch(e:TouchEvent):void
		{
			touch = e.getTouch(stage);
			
			if(!touch)	return;
			
			switch(touch.phase)
			{
				case TouchPhase.BEGAN:
				{
					handleMouseDown();
					break;
				}
					
				case TouchPhase.ENDED:
				{
					handleMouseUp();
					break;
				}
					
				case TouchPhase.MOVED:
				{
					handleMouseMove();
					break;
				}
					
				default:
				{
					break;
				}
			}
		}
		
		private function handleKeyUp(e:KeyboardEvent):void
		{
			// TODO Auto Generated method stub
			
		}
		
		private function handleKeyDown(e:KeyboardEvent):void
		{
			
		}
		
		private function handleMouseMove():void
		{
		}
		
		private function handleMouseDown():void
		{
			Constant.m_mouseDown = true;
			//NapeStarlingUtil.startDragBody(NapeStarlingUtil.getBodyAtMouse());
		}
		
		private function handleMouseUp():void
		{
			Constant.m_mouseDown = false;
			//NapeStarlingUtil.stopDragBody();
		}
		
		private function handleMouseClick():void
		{
			// TODO Auto Generated method stub
			
		}
		
		public static function get assets():AssetManager
		{
			return _sAssets;
		}
		
		private function showScene():void
		{
			trace("showScene");
			
			lauch();
		}
		
		private function lauch():void
		{
			mainScreen = new MainScreen();
			addChildScaled(mainScreen);
			
			addEventListener(starling.events.Event.ENTER_FRAME, loop);
		}
		
		private function loop(e:starling.events.Event):void
		{
			if(mainScreen.m_navigator.activeScreen && mainScreen.m_navigator.activeScreen.hasOwnProperty("onUpdate"))
			{
				mainScreen.m_navigator.activeScreen["onUpdate"]();
			}
		}
		
	}
}