package com.jack.hundreds.view
{
	import com.jack.hundreds.model.consts.Constant;
	
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	
	public class MySprite extends Sprite
	{
		public function MySprite()
		{
			super();
		}
		
		public function addChildScaled(child:DisplayObject):DisplayObject
		{
			// auto scale the child object width and height to match the 
			// different aspect ratio and mobile screen resolution
			child.scaleX *= Constant.SCALE_FACTOR_X;
			child.scaleY *= Constant.SCALE_FACTOR_Y;
			
			child.x *= Constant.SCALE_FACTOR_X;
			child.y *= Constant.SCALE_FACTOR_Y;
			
			return this.addChild(child);
		}
		
	}
}