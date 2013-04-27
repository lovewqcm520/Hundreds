package
{
	import com.jack.hundreds.Root;
	import com.jack.hundreds.model.consts.Constant;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	
	import starling.core.Starling;
	import starling.events.Event;
	import starling.textures.Texture;
	import starling.utils.RectangleUtil;
	import starling.utils.ScaleMode;
	import starling.utils.formatString;
	import com.jack.hundreds.util.AssetManager;
	
	[SWF(frameRate="60", backgroundColor="#000000", width="960", height="640")]
	public class Hundreds extends Sprite
	{
		[Embed(source="assets/splash/startup.png")]
		private static var Background:Class;
		
		[Embed(source="assets/splash/startup@2x.png")]
		private static var BackgroundHD:Class;
		
		public static var napeDebugSprite:Sprite;
		
		public function Hundreds()
		{
			super();
			
			if(stage)
				init()
			else
				addEventListener(flash.events.Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:flash.events.Event = null):void
		{
			// get the scale factor both x and y direction
			Constant.STAGE_ACTUAL_WIDTH = stage.fullScreenWidth;
			Constant.STAGE_ACTUAL_HEIGHT = stage.fullScreenHeight;
			Constant.SCALE_FACTOR_X = stage.fullScreenWidth / Constant.STAGE_INIT_WIDTH;
			Constant.SCALE_FACTOR_Y = stage.fullScreenHeight / Constant.STAGE_INIT_HEIGHT;
			
			var stageWidth:int = Constant.STAGE_INIT_WIDTH;
			var stageHeight:int = Constant.STAGE_INIT_HEIGHT;
			var iOS:Boolean = Capabilities.manufacturer.indexOf("iOS") != -1;
			
			Starling.multitouchEnabled = true;	// useful on mobile devices
			Starling.handleLostContext = !iOS;	// not necessary on iOS. Saves a lot of memory!
			
			// create a suitable viewport for the screen size
			// 
			// we develop the game in a *fixed* coordinate system of 320x480; the game might 
			// then run on a device with a different resolution; for that case, we zoom the 
			// viewPort to the optimal size for any display and load the optimal textures.
			var viewPort:Rectangle = RectangleUtil.fit(
				new Rectangle(0, 0, stageWidth, stageHeight),
				new Rectangle(0, 0, stage.fullScreenWidth, stage.fullScreenHeight),
				ScaleMode.SHOW_ALL, true);
			
			viewPort = new Rectangle(0, 0, stage.fullScreenWidth, stage.fullScreenHeight);
			
			// create the AssetManager, which handles all required assets for this resolution
			var scaleFactor:int = viewPort.width <= Constant.STAGE_INIT_WIDTH ? 1: 2;
			var appDir:File = File.applicationDirectory;
			// just test
			var assets:AssetManager = new AssetManager(1);
			
			assets.verbose = Capabilities.isDebugger;
			assets.enqueue(
				appDir.resolvePath("assets/audio"),
				appDir.resolvePath(formatString("assets/fonts/{0}x", 1)),
				appDir.resolvePath(formatString("assets/textures/{0}x", 1))
			);
			
			// While Stage3D is initializing, the screen will be blank. To avoid any flickering, 
			// we display a startup image now and remove it below, when Starling is ready to go.
			// This is especially useful on iOS, where "Default.png" (or a variant) is displayed
			// during Startup. You can create an absolute seamless startup that way.
			// 
			// These are the only embedded graphics in this app. We can't load them from disk,
			// because that can only be done asynchronously (resulting in a short flicker).
			// 
			// Note that we cannot embed "Default.png" (or its siblings), because any embedded
			// files will vanish from the application package, and those are picked up by the OS!
			
			var background:Bitmap = scaleFactor == 1 ? new Background() : new BackgroundHD();
			Background = BackgroundHD = null;
			
			background.x = viewPort.x;
			background.y = viewPort.y;
			background.width = viewPort.width;
			background.height = viewPort.height;
			background.smoothing = true;
			addChild(background);
			
			// launch Starling
			
			var m_starling:Starling = new Starling(Root, stage, viewPort);
			m_starling.stage.stageWidth = stage.fullScreenWidth;
			m_starling.stage.stageHeight = stage.fullScreenHeight;
			m_starling.simulateMultitouch = false;
			m_starling.enableErrorChecking = false;
			m_starling.showStats = true;
			m_starling.enableErrorChecking = true;
			
			m_starling.addEventListener(starling.events.Event.ROOT_CREATED, 
				function onRootCreated(event:Object, app:Root):void
				{
					m_starling.removeEventListener(starling.events.Event.ROOT_CREATED, onRootCreated);
					removeChild(background);
					
					var bgTexture:Texture = Texture.fromBitmap(background, false, false);
					
					app.start(bgTexture, assets);
					m_starling.start();
				}
			);
			
			m_starling.addEventListener(starling.events.Event.RESIZE, onResize);
			m_starling.addEventListener(starling.events.Event.CONTEXT3D_CREATE, onContextCreated);
		}
		
		private function onContextCreated(e:starling.events.Event):void
		{
			// just test
			// remove this when release the application
			napeDebugSprite = new Sprite();
			addChild(napeDebugSprite);
		}
		
		private function onResize(e:starling.events.Event, size:Point):void
		{
			Starling.current.viewPort = RectangleUtil.fit(
				new Rectangle(0, 0, stage.stageWidth, stage.stageHeight),
				new Rectangle(0, 0, size.x, size.y),
				ScaleMode.SHOW_ALL
			);
		}
	}
}