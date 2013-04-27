package com.jack.hundreds.view.screen
{
	import com.jack.hundreds.model.GameData;
	import com.jack.hundreds.model.consts.Constant;
	import com.jack.hundreds.model.consts.SoundConst;
	import com.jack.hundreds.util.Delay;
	import com.jack.hundreds.util.Log;
	import com.jack.hundreds.util.NapeStarlingUtil;
	import com.jack.hundreds.util.SharedObjectUtil;
	import com.jack.hundreds.util.SoundManager;
	import com.jack.hundreds.view.component.TouchedBall;
	import com.jack.hundreds.view.panel.LosePanel;
	import com.jack.hundreds.view.panel.WinPanel;
	
	import feathers.controls.Label;
	import feathers.text.BitmapFontTextFormat;
	
	import flash.utils.getTimer;
	
	import nape.callbacks.CbEvent;
	import nape.callbacks.CbType;
	import nape.callbacks.InteractionCallback;
	import nape.callbacks.InteractionListener;
	import nape.callbacks.InteractionType;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyList;
	import nape.phys.BodyType;
	import nape.phys.Material;
	import nape.shape.Circle;
	
	import starling.core.Starling;
	import starling.events.Event;
	import starling.textures.TextureSmoothing;
	
	[Event(name="showWin", type="starling.events.Event")]
	[Event(name="showLose", type="starling.events.Event")]
	[Event(name="complete", type="starling.events.Event")]
	
	public class PlayScreen extends MyBaseScreen
	{
		public static const SHOW_WIN:String = "showWin";
		public static const SHOW_LOSE:String = "showLose";
		public static const COMPLETE:String = "complete";
		
		private var m_levelAdjust:int = 3;
		private var m_radiusAdjust:Number = 4*Constant.SCALE_FACTOR_Y;
		public var m_isOver:Boolean = false;
		public var m_isWin:Boolean = false;
		private var m_playTime:Number = 0;
		private var m_startTime:int;
		private var m_endTime:int;
		private var m_totalScores:int = 0;
		
		private var m_circleType:CbType = new CbType();
		private var m_wallType:CbType = new CbType();
		private var ballVsBallListener:InteractionListener;
		private var ballVsWallListener:InteractionListener;
		
		private var m_scaleableBallList:Vector.<TouchedBall>;
		private var scoreTxt:Label;

		private var bodies:BodyList;
		private var body:Body;
		private var circle:Circle;

		private var levelTxt:Label;
		
		public function PlayScreen()
		{
			setBackgroundImage("playBg");
			
			super();
		}
		
		override protected function onInitialize(e:Event):void
		{
			Log.traced("PlayScreen at level", gameData.curPlayingLevel, "\n The passed max level is", gameData.passedMaxLevel);
		
			super.onInitialize(e);
			
			// add current level label in the center
			levelTxt = new Label();
			levelTxt.text = String(gameData.curPlayingLevel);
			levelTxt.touchable = false;
			levelTxt.textRendererProperties.textFormat = new BitmapFontTextFormat("Chango", 50, 0xcccccc);
			levelTxt.textRendererProperties.smoothing = TextureSmoothing.BILINEAR;
			addChild(levelTxt);
			levelTxt.validate();
			levelTxt.x = (Constant.STAGE_INIT_WIDTH - levelTxt.width)/2;
			levelTxt.y = (Constant.STAGE_INIT_HEIGHT - levelTxt.height)/2;
			
			// add current total scores at top right
			scoreTxt = new Label();
			scoreTxt.text = String(m_totalScores) + " / 100";
			scoreTxt.touchable = false;
			scoreTxt.textRendererProperties.textFormat = new BitmapFontTextFormat("Chango", 50, 0xcccccc);
			scoreTxt.textRendererProperties.smoothing = TextureSmoothing.BILINEAR;
			
			// add keyboard back handler
			this.backButtonHandler = this.onBackButton;
			
			// start game
			start();
			
			addChild(scoreTxt);
			scoreTxt.validate();
			scoreTxt.x = Constant.STAGE_INIT_WIDTH - scoreTxt.width - 20;
			scoreTxt.y = 20;
			
			GameData.gameStatus = Constant.GAME_STATUS_PLAYING;
		}
		
		private function onBackButton():void
		{
			dispatchEventWithGameData(COMPLETE);
		}
		
		override public function dispose():void
		{
			// dispose all the balls
			var ball:TouchedBall;
			for (var i:int = 0; i < m_scaleableBallList.length; i++) 
			{
				ball = m_scaleableBallList[i];
				ball.dispose();
			}
			m_scaleableBallList.length = 0;
			
			// destory physics engine
			destroyPhysicsEngine();
			
			super.dispose();
		}
		
		public function start():void
		{
			m_isOver = false;
			m_isWin = false;
			m_totalScores = 0;
			m_scaleableBallList = new Vector.<TouchedBall>();
			
			// setup the nape physics engine 
			setupPhysicsEngine();
			
			// init scaleable balls
			initTouchedBalls();
			
			m_startTime = getTimer();
			
			scoreTxt.text = String(m_totalScores) + " / 100";
			levelTxt.text = String(gameData.curPlayingLevel);
		}
		
		public function restart():void
		{
			var ball:TouchedBall;
			for (var i:int = 0; i < m_scaleableBallList.length; i++) 
			{
				ball = m_scaleableBallList[i];
				ball.dispose();
			}
			m_scaleableBallList.length = 0;
			
			m_totalScores = 0;
			
			start();
		}
		
		public function gotoNextLevel():void
		{
			restart();
		}
		
		public function pause():void
		{
			NapeStarlingUtil.pauseWorld();
		}
		
		public function resume():void
		{
			NapeStarlingUtil.resumeWorld();
		}
		
		public function win():void
		{
			m_endTime = getTimer();
			m_playTime = (m_endTime - m_startTime)/1000;
			
			// destory physics engine
			destroyPhysicsEngine();
			
			// play game win sound
			SoundManager.play(SoundConst.sfx_win);
			
			// update new minimal pass level time
			if(m_playTime < gameData.allLevelsData[gameData.curPlayingLevel].bestScores)
			{
				gameData.allLevelsData[gameData.curPlayingLevel-1].bestScores = m_playTime;
				// wirte new passed level minimal use time record to shared object
				SharedObjectUtil.setProperty(Constant.HUNDREDS_SHARED_OBJECT, Constant.HUNDREDS_SHARED_OBJECT_DATA, gameData.allLevelsData);
			}
			
			// update level number
			gameData.curPlayingLevel++;
			if(gameData.passedMaxLevel < gameData.curPlayingLevel)
			{
				gameData.passedMaxLevel = gameData.curPlayingLevel;
				// wirte new passed level record to shared object
				SharedObjectUtil.setProperty(Constant.HUNDREDS_SHARED_OBJECT, Constant.HUNDREDS_SHARED_OBJECT_PASSED_LEVEL, gameData.passedMaxLevel);
			}
			
			// delay 1 second to show game win screen
			Delay.doIt(1000, showGameWinScreen);
		}
		
		public function lose():void
		{
			m_endTime = getTimer();
			m_playTime = (m_endTime - m_startTime)/1000;
			
			// destory physics engine
			destroyPhysicsEngine();
			
			// change all the scaleable balls to red active status
			var ball:TouchedBall;
			for (var i:int = 0; i < m_scaleableBallList.length; i++) 
			{
				ball = m_scaleableBallList[i];
				ball.drawActivate();
			}
			
			// play game over sound
			SoundManager.play(SoundConst.sfx_circleKill);
			
			// delay 1 second to show game lose screen
			Delay.doIt(1000, showGameLoseScreen);
		}
		
		private function showGameLoseScreen():void
		{
			gameData.timeUsed = m_playTime;
			//dispatchEventWithGameData(SHOW_LOSE);
			
			// show the game lose panel
			var losePanel:LosePanel = new LosePanel();
			addChild(losePanel);
			losePanel.x = (Constant.STAGE_INIT_WIDTH - losePanel.width)/2;
			losePanel.y = (Constant.STAGE_INIT_HEIGHT - losePanel.height)/2;
		}
		
		private function showGameWinScreen():void
		{
			gameData.timeUsed = m_playTime;
			gameData.totalScores = m_totalScores;	
			//dispatchEventWithGameData(SHOW_WIN);
			
			// show the game win panel
			var winPanel:WinPanel = new WinPanel();
			addChild(winPanel);
			winPanel.x = (Constant.STAGE_INIT_WIDTH - winPanel.width)/2;
			winPanel.y = (Constant.STAGE_INIT_HEIGHT - winPanel.height)/2;
		}
		
		override public function onUpdate():void	
		{
			if(m_isOver)	
			{
				return;
			}
			
			// update nape physics world
			NapeStarlingUtil.updateWorld();
			
			var len:int;
			// update the size of body that under mouse 
			bodies = NapeStarlingUtil.getBodiesAtMouse();
			if(bodies.length > 0)
			{
				len = bodies.length;
				
				
				for (var i:int = 0; i < len; i++) 
				{
					body = bodies.at(i);
					
					if(body.userData.name == "scaleableBall")
					{
						if(Constant.m_mouseDown)
						{
							circle = body.shapes.at(0) as Circle;
							if(circle.radius < (Constant.STAGE_ACTUAL_HEIGHT/2))
							{
								circle.radius += m_radiusAdjust;
								(body.userData.graphic as TouchedBall).m_scores++;
								(body.userData.graphic as TouchedBall).mouseOut = false;
								
								// update total scores 
								m_totalScores++;
								
								// update total scores textField
								scoreTxt.text = String(m_totalScores) + " / 100";
								
								// check if win
								if(m_totalScores >= gameData.maxScoresForPass)
								{
									m_isWin = true;
									win();
								}
							}
						}
						else
						{
							(body.userData.graphic as TouchedBall).mouseOut = true;
						}
					}
				}
			}
		}
		
		private function setupPhysicsEngine():void
		{
			NapeStarlingUtil.m_isDebug = true;
			NapeStarlingUtil.initialize(Starling.current, 60);
			NapeStarlingUtil.createWorld(new Vec2(0, 0));
			NapeStarlingUtil.createDebug();
			
			// create wall that has elasticity
			var material:Material = new Material();
			material.elasticity = 0.6;
			material.density = 1;
			material.staticFriction = 0;
			NapeStarlingUtil.createWrapWallEx(0.1, material, m_wallType);
			
			// setup interaction listener
			ballVsBallListener = new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, m_circleType, m_circleType, onBallVsBallCallback);
			ballVsWallListener = new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, m_circleType, m_wallType, onBallVsWallCallback);
			NapeStarlingUtil.m_world.listeners.add(ballVsBallListener);
			NapeStarlingUtil.m_world.listeners.add(ballVsWallListener);
		}
		
		private function destroyPhysicsEngine():void
		{
			NapeStarlingUtil.destroyWorld();
		}
		
		private function onBallVsBallCallback(cb:InteractionCallback):void
		{
			if(!(cb.int1.castBody.userData.graphic as TouchedBall).mouseOut || !(cb.int2.castBody.userData.graphic as TouchedBall).mouseOut)
			{
				// game over
				m_isOver = true;
				lose();
			}
			else
			{
				SoundManager.play(SoundConst.sfx_circleHit);
			}
		}
		
		private function onBallVsWallCallback(cb:InteractionCallback):void
		{
			
		}
		
		private function initTouchedBalls():void
		{
			// reset the ball color every round
			TouchedBall.color1 = TouchedBall.COLOR;
			
			// init balls
			var ballNum:int = gameData.curPlayingLevel + m_levelAdjust;
			for (var i:int = 0; i < ballNum; i++) 
			{
				m_scaleableBallList.push(addScaleableBall());
			}
		}
		
		private function addScaleableBall():TouchedBall
		{
			var radius:Number = gameData.scaleable_ball_init_radius;
			var speed:Number = gameData.scaleable_ball_speed;
			
			var posX:Number = Math.round(radius + Math.random()*(Constant.STAGE_ACTUAL_WIDTH-radius));
			var posY:Number = Math.round(radius + Math.random()*(Constant.STAGE_ACTUAL_HEIGHT-radius));
			var body:Body = new Body(BodyType.DYNAMIC, new Vec2(posX, posY));
			
			var circle:Circle = new Circle(radius);
			circle.material.elasticity = 0.6;
			circle.material.density = 1;
			circle.material.staticFriction = 0;
			
			body.shapes.add(circle);
			body.space = NapeStarlingUtil.m_world;
			
			var ball:TouchedBall = new TouchedBall();
			ball.setBody(body);
			addChild(ball);
			
			body.userData.name = "scaleableBall";
			
			var randonAngle:Number = Math.random()*2*Math.PI;
			body.velocity = new Vec2(speed*Math.cos(randonAngle), speed*Math.sin(randonAngle));
			
			body.cbTypes.add(m_circleType);
			
			return ball;
		}
		
		
		
	}
}