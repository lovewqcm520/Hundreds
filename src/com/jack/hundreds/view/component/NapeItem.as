package com.jack.hundreds.view.component
{
	import com.jack.hundreds.model.consts.Constant;
	import com.jack.hundreds.view.impl.IPhysicsEngineGraphicUpdate;
	
	import nape.phys.Body;
	
	import starling.display.Sprite;
	
	public class NapeItem extends Sprite implements IPhysicsEngineGraphicUpdate
	{
		protected var m_body:Body;
		
		public function NapeItem()
		{
		}
		
		public function setBody(body:Body):void
		{
			m_body = body;
			m_body.userData.graphic = this;
			m_body.userData.graphicUpdate = this.graphicUpdate;
		}
		
		public function graphicUpdate():void
		{
			if(m_body)
			{
				this.x = m_body.position.x/Constant.SCALE_FACTOR_X;
				this.y = m_body.position.y/Constant.SCALE_FACTOR_Y;
				this.rotation = m_body.rotation;
			}
		}
		
		public function destroyBody():void
		{
			if(m_body && m_body.space)
			{
				m_body.space.liveBodies.remove(m_body);
				m_body = null;
			}
		}
		
		public function centerSelf():void
		{
			this.pivotX = this.width/2;
			this.pivotY = this.height/2;
		}
		
		override public function dispose():void
		{
			destroyBody();
			removeFromParent(true);
		}
		
	}
}