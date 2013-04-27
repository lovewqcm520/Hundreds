package com.jack.hundreds.view.screen
{
	import com.jack.hundreds.model.consts.Constant;
	import com.jack.hundreds.util.Asset;
	import com.jack.hundreds.util.Log;
	import com.jack.hundreds.view.component.SelectLevelIcon;
	
	import feathers.controls.Button;
	import feathers.controls.List;
	import feathers.controls.PageIndicator;
	import feathers.data.ListCollection;
	import feathers.layout.TiledRowsLayout;
	
	import starling.display.Image;
	import starling.events.Event;

	[Event(name="showPlay", type="starling.events.Event")]
	[Event(name="complete", type="starling.events.Event")]
	
	public class SelectLevelScreen extends MyBaseScreen
	{
		public static const SHOW_PLAY:String = "showPlay";
		public static const COMPLETE:String = "complete";

		private var m_list:List;
		private var m_pageIndicator:PageIndicator;
		
		public function SelectLevelScreen()
		{
			setBackgroundImage("menuBg");
			
			super();
		}
		
		override protected function onInitialize(e:Event):void
		{
			Log.traced("LevelSelectScreen");
			
			super.onInitialize(e);
			
			// init the level list
			initLevelList();
			// init the page indicator
			initPageIndicator();
			// setup layout
			initLayout();
			
			// add keyboard back handler
			this.backButtonHandler = this.onBackButton;
		}
		
		private function initLevelList():void
		{
			m_list = new List();
			
			// list layout
			var listLayout:TiledRowsLayout = new TiledRowsLayout();
			listLayout.paging = TiledRowsLayout.PAGING_HORIZONTAL;
			listLayout.useSquareTiles = false;
			listLayout.tileHorizontalAlign = TiledRowsLayout.TILE_HORIZONTAL_ALIGN_CENTER;
			listLayout.horizontalAlign = TiledRowsLayout.HORIZONTAL_ALIGN_CENTER;

			// collection
			var data:Array = [];
			var len:int = gameData.allLevelsData.length;
			var levelIcon:SelectLevelIcon;
			for (var i:int = 0; i < len; i++) 
			{
				levelIcon = new SelectLevelIcon(gameData.allLevelsData[i]);
				data.push({icon:levelIcon});
			}
			var collection:ListCollection = new ListCollection(data);
			
			// init list
			m_list.dataProvider = collection;
			m_list.layout = listLayout;
			m_list.snapToPages = true;
			m_list.isSelectable = true;
			m_list.hasElasticEdges = true;
			m_list.scrollBarDisplayMode = List.SCROLL_BAR_DISPLAY_MODE_NONE;
			m_list.horizontalScrollPolicy = List.SCROLL_POLICY_ON;
			m_list.itemRendererProperties.iconField = "icon";
			m_list.itemRendererProperties.iconPosition = Button.ICON_POSITION_TOP;
			
			m_list.addEventListener(Event.SCROLL, onListScroll);
			m_list.addEventListener(Event.CHANGE, onListItemChange);
			addChild(m_list);
		}
		
		private function initPageIndicator():void
		{
			m_pageIndicator = new PageIndicator();
			m_pageIndicator.normalSymbolFactory = function():Image
			{
				return Asset.getDisplayObject("normal-page-symbol") as Image;
			};
			m_pageIndicator.selectedSymbolFactory = function():Image
			{
				return Asset.getDisplayObject("selected-page-symbol") as Image;
			};
			m_pageIndicator.direction = PageIndicator.DIRECTION_HORIZONTAL;
			m_pageIndicator.pageCount = 1;
			m_pageIndicator.gap = 3;
			m_pageIndicator.paddingTop = m_pageIndicator.paddingBottom = m_pageIndicator.paddingLeft = m_pageIndicator.paddingRight = 6;
			m_pageIndicator.addEventListener(Event.CHANGE, onPageIndicatorChange);
			
			addChild(m_pageIndicator);
		}
		
		private function initLayout():void
		{
			this.m_pageIndicator.width = Constant.STAGE_INIT_WIDTH;
			this.m_pageIndicator.validate();
			this.m_pageIndicator.y = Constant.STAGE_INIT_HEIGHT - this.m_pageIndicator.height;
			
			const shorterSide:Number = Math.min(Constant.STAGE_INIT_WIDTH, Constant.STAGE_INIT_HEIGHT) - m_pageIndicator.height;
			const layout:TiledRowsLayout = TiledRowsLayout(this.m_list.layout);
			layout.paddingTop = layout.paddingBottom = (Constant.STAGE_INIT_HEIGHT - m_pageIndicator.height) * 0.165;
			layout.paddingRight = layout.paddingLeft = Constant.STAGE_INIT_WIDTH * 0.15;
			
			this.m_list.width = Constant.STAGE_INIT_WIDTH;
			this.m_list.height = this.m_pageIndicator.y;
			this.m_list.x = 0;
			this.m_list.y = 0;
			this.m_list.validate();
			
			this.m_pageIndicator.pageCount = Math.ceil(this.m_list.maxHorizontalScrollPosition / this.m_list.width) + 1;
		}
		
		private function onPageIndicatorChange(e:Event):void
		{
			m_list.scrollToPageIndex(m_pageIndicator.selectedIndex, 0, 0.25);
		}
		
		private function onListScroll(e:Event):void
		{
			m_pageIndicator.selectedIndex = m_list.horizontalPageIndex;
		}
		
		private function onListItemChange(e:Event):void
		{
			var itemIndex:int = List(e.currentTarget).selectedIndex;
			
			// if unlocked 
			if(!gameData.allLevelsData[itemIndex].locked)
			{
				// play game
				gameData.curPlayingLevel = itemIndex + 1;
				onPlayGame();
			}
		}
		
		private function onPlayGame():void
		{
			dispatchEventWithGameData(SHOW_PLAY);
		}
		
		private function onBackButton():void
		{
			dispatchEventWithGameData(COMPLETE);
		}
	}
}