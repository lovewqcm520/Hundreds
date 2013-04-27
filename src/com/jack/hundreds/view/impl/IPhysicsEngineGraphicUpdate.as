package com.jack.hundreds.view.impl
{
	public interface IPhysicsEngineGraphicUpdate
	{
		
		/**
		 * Implement this function for call every frame to update the graphic
		 * attached to the physics engine body("b2Body" in Box2D or "body" in Nape).
		 */
		function graphicUpdate():void;
		
		/**
		 * Implement this function for call it when you want destory the body and graphic together.
		 */
		function destroyBody():void;
		
		/**
		 * Change self both pivot x and y to center.
		 */
		function centerSelf():void;
	}
}