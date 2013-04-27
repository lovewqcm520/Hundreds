package com.jack.hundreds.view.component
{
	import com.jack.hundreds.Root;
	import com.jack.hundreds.model.consts.Constant;
	
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Shape;
	
	import nape.geom.Vec2;
	import nape.shape.Circle;
	
	import starling.display.Image;
	import starling.text.TextField;
	import starling.textures.Texture;

	public class TouchedBall extends NapeDynamicItem
	{
		public static var COLOR:uint = 0xcccccc;
		public static var color1:uint = 0xcccccc;
		private static var color2:uint = 0xff0000;
		private static var color3:uint = 0xffffff;
		private static var color4:uint = 0xdedede;
		private static var color5:uint = 0x222222;
		
		private static const max_scores:int = 100;
		
		private var m_radius:Number = 30;
		private var m_moveSpeed:Number = 250;
		private var m_growRate:Number = 4;
		private var m_color:uint;
		public var m_scores:int = 0;
		private var m_fontSize:Number = 35;
		
		private var shape:flash.display.Shape = new Shape();
		private var fill:Image;
		private var bmd:BitmapData;
		private var texture:Texture;
		private var activeTexture:Texture;
		private var label:TextField;
		
		private var m_mouseUp:Boolean = true;
		
		public function TouchedBall()
		{
			super();
			
			m_color = color1;
			
			addBall();
			addLabel();
			
			color1 -= color5;
		}
		
		private function addBall():void
		{
			var maxRadius:Number = Constant.STAGE_ACTUAL_HEIGHT/2;
			var g:Graphics = shape.graphics;
			g.clear();
			g.beginFill(m_color, 1);
			g.drawCircle(maxRadius, maxRadius, maxRadius);
			g.endFill();
			
			bmd = new BitmapData(maxRadius*2, maxRadius*2, true, m_color);
			bmd.draw(shape);
			
			texture = Texture.fromBitmapData(bmd)
			fill = new Image(texture);
			fill.pivotX=fill.width/2;
			fill.pivotY=fill.height/2;
			fill.width = m_radius*2;
			fill.height = m_radius*2;
			addChild(fill);
		}
		
		private function addLabel():void
		{
			label = new TextField(300, 300, String(0), "Chango", m_fontSize, 0xffffff);
			label.autoScale = true;
			label.touchable = false;
			//label.border = true;
			label.pivotX=label.width/2;
			label.pivotY=label.height/2;
			addChild(label);
		}
		
		private function draw(color:uint, radius:Number, scores:int):void
		{	
			if(color != color2)
			{
				fill.removeFromParent();
				fill = new Image(texture);
			}
			else
			{
				if(!activeTexture)
				{
					activeTexture = Root.assets.getTexture("activeCircle");
				}
				fill.removeFromParent();
				fill = new Image(activeTexture);
			}
			
			fill.pivotX=fill.width/2;
			fill.pivotY=fill.height/2;
			fill.width = radius*2;
			fill.height = radius*2;
			addChild(fill);
			
			m_fontSize += 1.5;
			label.fontSize = m_fontSize;
			label.text = String(scores);
			
			label.pivotX=label.width/2;
			label.pivotY=label.height/2;
			addChild(label);
		}
		
		public function drawInactivate():void
		{
			draw(m_color, (m_body.shapes.at(0) as Circle).radius/Constant.SCALE_FACTOR_Y, m_scores);
		}
		
		public function drawActivate():void
		{
			draw(color2, (m_body.shapes.at(0) as Circle).radius/Constant.SCALE_FACTOR_Y, m_scores);
		}
		
		override public function graphicUpdate():void
		{
			// update velocity
			var velocity:Vec2 = m_body.velocity;
			var speed:Number = velocity.length;
			var ratio:Number = m_moveSpeed / speed;
			m_body.velocity.muleq(ratio);
			
			super.graphicUpdate();
		}
		
		override public function dispose():void
		{
			bmd.dispose();
			texture.dispose();
			if(activeTexture)
				activeTexture.dispose();
			
			super.dispose();
		}

		public function get mouseOut():Boolean
		{
			return m_mouseUp;
		}

		public function set mouseOut(value:Boolean):void
		{
			if(!value)
			{
				m_mouseUp = value;
				drawActivate();
				// the ball was under mouse touch
			}
			else
			{
				if(m_mouseUp != value)
				{
					m_mouseUp = value;
					drawInactivate();
				}
			}
		}

		
	}
}