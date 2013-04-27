package com.jack.hundreds.util
{
	import flash.display.Sprite;
	import flash.display.Stage;
	
	import nape.callbacks.CbType;
	import nape.constraint.PivotJoint;
	import nape.dynamics.InteractionFilter;
	import nape.geom.GeomPoly;
	import nape.geom.GeomPolyList;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyList;
	import nape.phys.BodyType;
	import nape.phys.Material;
	import nape.shape.Circle;
	import nape.shape.Polygon;
	import nape.space.Broadphase;
	import nape.space.Space;
	import nape.util.BitmapDebug;
	
	import starling.core.Starling;

	public class NapeStarlingUtil
	{
		public static var m_world:Space;
		public static var m_isDebug:Boolean = true;
		private static var m_isPause:Boolean = false;
		public static var m_gravity:Vec2 = new Vec2(0, 600);
		public static var m_broadphase:Broadphase = Broadphase.DYNAMIC_AABB_TREE;
		
		private static var m_deltaTime:Number = 0.0166667;  // 1/60
		private static var m_velocityIterations:int = 10;
		private static var m_positionIterations:int = 10;
		
		private static var m_pivotJoint:PivotJoint;
		private static var m_debug:BitmapDebug;
		private static var m_mouseVec:Vec2 = new Vec2();
		private static var m_overlay:flash.display.Sprite;
		private static var m_stage:flash.display.Stage;
		
		public function NapeStarlingUtil()
		{
			
		}
		
		public static function initialize(s:Starling, frameRate:int=60):void
		{
			m_overlay = s.nativeOverlay;
			m_stage = s.nativeStage;
			m_deltaTime = 1/frameRate;
		}
		
		public static function createWorld(gravity:Vec2=null, broadphase:Broadphase=null):Space
		{
			gravity = gravity ? gravity : m_gravity.copy();
			broadphase = broadphase ? broadphase : m_broadphase;
			
			m_world = new Space(gravity, broadphase);
			
			return m_world;
		}
		
		public static function pauseWorld():void
		{
			m_isPause = true;
		}
		
		public static function resumeWorld():void
		{
			m_isPause = false;
		}
		
		public static function destroyWorld():void
		{
			m_world.clear();
			//m_world = null;
			
			if(m_isDebug && m_debug)
			{
				m_debug.clear();
				m_debug.draw(m_world);
				m_debug.flush();
			}
		}
		
		public static function clearWorld():void
		{
			m_world.clear();
			
			if(m_isDebug && m_debug)
			{
				m_debug.clear();
				m_debug.draw(m_world);
				m_debug.flush();
			}
		}
		
		public static function updateWorld():void
		{
			if(!m_world)	
				return;
			
			if(m_isPause)	
				return;
			
			// update pivotJoint position
			if(m_pivotJoint && m_pivotJoint.active)
			{
				m_pivotJoint.anchor1.setxy(m_stage.mouseX, m_stage.mouseY);
			}
			
			// step the engine
			m_world.step(m_deltaTime, m_velocityIterations, m_positionIterations);
			
			// update all the live bodies graphics
			var len:int = m_world.liveBodies.length;
			var body:Body;
			for (var i:int = 0; i < len; i++) 
			{
				body = m_world.liveBodies.at(i);
				if(body.userData && body.userData.graphicUpdate)
				{
					body.userData.graphicUpdate();
				}
			}
			
			// draw debug
			if(m_isDebug && m_debug)
			{
				m_debug.clear();
				m_debug.draw(m_world);
				m_debug.flush();
			}
		}
		
		public static function createDebug():void
		{
			m_debug = new BitmapDebug(m_stage.stageWidth, m_stage.stageHeight, 
				m_stage.color, true);
			
			m_overlay.addChild(m_debug.display);
			
			m_debug.drawConstraints = true;
		}
		
		public static function createBox(x:Number, y:Number, width:Number, height:Number, isStatic:Boolean=false, userData:*=null,
			material:Material=null, interactionFilter:InteractionFilter=null):Body
		{
			var body:Body = new Body((isStatic ? BodyType.STATIC : BodyType.DYNAMIC), new Vec2(x, y));
			body.shapes.add(new Polygon(Polygon.box(width, height), material, interactionFilter));
			body.space = m_world;
			
			if(userData)
			{
				userData.width = width;
				userData.height = height;
				body.userData.graphic = userData;
				body.userData.graphicUpdate = userData.graphicUpdate;
			}
			
			return body;
		}
		
		public static function createCircle(x:Number, y:Number, radius:Number, isStatic:Boolean=false, userData:*=null,
										 material:Material=null, interactionFilter:InteractionFilter=null):Body
		{
			var body:Body = new Body((isStatic ? BodyType.STATIC : BodyType.DYNAMIC), new Vec2(x, y));
			body.shapes.add(new Circle(radius, null, material, interactionFilter));
			body.space = m_world;
			
			if(userData)
			{
				userData.width = radius*2;
				userData.height = radius*2;
				body.userData.graphic = userData;
				body.userData.graphicUpdate = userData.graphicUpdate;
			}
			
			return body;
		}
		
		public static function createRegular(x:Number, y:Number, radius:Number, edgeCount:int, rotation:Number, isStatic:Boolean=false, userData:*=null,
										 material:Material=null, interactionFilter:InteractionFilter=null):Body
		{
			var body:Body = new Body((isStatic ? BodyType.STATIC : BodyType.DYNAMIC), new Vec2(x, y));
			var shape:Polygon = new Polygon(Polygon.regular(radius, radius, edgeCount), material, interactionFilter);
			shape.rotate(rotation);
			body.shapes.add(shape);
			body.space = m_world;
			
			if(userData)
			{
				body.userData.graphic = userData;
				body.userData.graphicUpdate = userData.graphicUpdate;
			}
			
			return body;
		}
		
		public static function createPolygon(localVerts:*, x:Number, y:Number, isStatic:Boolean=false, userData:*=null,
										 material:Material=null, interactionFilter:InteractionFilter=null):Body
		{
			var body:Body = new Body();
			body.type = isStatic ? BodyType.STATIC : BodyType.DYNAMIC;
			
			var geomPoly:GeomPoly = new GeomPoly(localVerts);
			var polyShapeList:GeomPolyList = geomPoly.convexDecomposition();
			polyShapeList.foreach(
				function(shape:*):void
				{
					body.shapes.add(new Polygon(shape, material, interactionFilter));
				}
			);
			
			body.position.setxy(x, y);
			body.space = m_world;
			
			if(userData)
			{
				body.userData.graphic = userData;
				body.userData.graphicUpdate = userData.graphicUpdate;
			}
			
			return body;
		}
		
		public static function createWrapWall(wallThick:Number=0.1, material:Material=null):void
		{
			var w:Number = m_stage.stageWidth;
			var h:Number = m_stage.stageHeight;
			
			createBox(w/2, 0, w, wallThick, true, null, material);
			createBox(w, h/2, wallThick, h, true, null, material);
			createBox(w/2, h, w, wallThick, true, null, material);
			createBox(0, h/2, wallThick, h, true, null, material);
		}
		
		public static function createWrapWallEx(wallThick:Number=0.1, material:Material=null, cbType:CbType=null):void
		{
			var w:Number = m_stage.stageWidth;
			var h:Number = m_stage.stageHeight;
			
			createBox(w/2, 0, w, wallThick, true, null, material).cbTypes.add(cbType);
			createBox(w, h/2, wallThick, h, true, null, material).cbTypes.add(cbType);
			createBox(w/2, h, w, wallThick, true, null, material).cbTypes.add(cbType);
			createBox(0, h/2, wallThick, h, true, null, material).cbTypes.add(cbType);
		}
		
		public static function getBodyAtMouse():Body
		{
			m_mouseVec.x = m_stage.mouseX;
			m_mouseVec.y = m_stage.mouseY;
			var bodies:BodyList = m_world.bodiesUnderPoint(m_mouseVec);
			
			var body:Body;
			for (var i:int = 0; i < bodies.length; i++) 
			{
				body = bodies.at(i);
				
				if(body.isDynamic())
					return body;
			}
			
			return null;
		}
		
		public static function getBodiesAtMouse():BodyList
		{
			m_mouseVec.x = m_stage.mouseX;
			m_mouseVec.y = m_stage.mouseY;
			var bodies:BodyList = m_world.bodiesUnderPoint(m_mouseVec);
			
			return bodies;
		}
		
		public static function startDragBody(body:Body):void
		{
			if(!body)	return;
			
			if(!m_pivotJoint)
			{
				m_pivotJoint = new PivotJoint(m_world.world, null, Vec2.weak(), Vec2.weak());
				m_pivotJoint.space = m_world;
				m_pivotJoint.active = false;
				m_pivotJoint.stiff = false;
				m_pivotJoint.maxForce = 60000;
				m_pivotJoint.frequency = 4;
			}
			
			m_mouseVec.x = m_stage.mouseX;
			m_mouseVec.y = m_stage.mouseY;
			m_pivotJoint.body2 = body;
			m_pivotJoint.anchor2.set(body.worldPointToLocal(m_mouseVec, true));
			m_pivotJoint.active = true;
		}
		
		public static function stopDragBody():void
		{
			if(m_pivotJoint && m_pivotJoint.active)
			{
				m_pivotJoint.active = false;
			}
		}
	}
}