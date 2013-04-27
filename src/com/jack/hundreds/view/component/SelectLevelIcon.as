package com.jack.hundreds.view.component
{
	import com.jack.hundreds.model.LevelModel;
	import com.jack.hundreds.util.Asset;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.text.TextField;
	
	public class SelectLevelIcon extends Sprite
	{
		private var m_levelModel:LevelModel;
		
		public function SelectLevelIcon(levelModel:LevelModel)
		{
			super();
			
			m_levelModel = levelModel;
			initialize();
		}
		
		private function initialize():void
		{
			// add background image
			var bg:Image = Asset.getDisplayObject("selectLevel_bg") as Image;
			//bg.pivotX = bg.width >> 1;
			//bg.pivotY = bg.height >> 1;
			addChild(bg);
			
			// add level label center
			var level:TextField = new TextField(100, 100, String(m_levelModel.level), "Chango", 53, 0xffffff);
			level.autoScale = true;
			level.border = false;
			level.x = (bg.width-level.width) >> 1;
			level.y = (bg.height-level.height) >> 1;
			//addChild(level);
			
			if(m_levelModel.locked)
			{	// add lock icon center
				var lock:Image = Asset.getDisplayObject("selectLevel_lock") as Image;
				lock.x = (bg.width-lock.width) >> 1;
				lock.y = (bg.height-lock.height) >> 1;
				addChild(lock);
			}
			else	// show best scores under background image
			{
				var bestScores:TextField = new TextField(100, 100, String(m_levelModel.bestScores), "Chango", 50, 0xffffff);
				bestScores.autoScale = true;
				bestScores.border = true;
				bestScores.y = bg.height;
				//addChild(bestScores);
			}
		}
	}
}