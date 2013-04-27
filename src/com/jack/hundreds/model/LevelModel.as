package com.jack.hundreds.model
{
	public class LevelModel
	{
		public var level:int;
		public var locked:Boolean = true;
		
		// how many seconds(minimal in all tries) user use to pass this level
		public var bestScores:Number = int.MAX_VALUE;
		
		public function LevelModel()
		{
		}
	}
}