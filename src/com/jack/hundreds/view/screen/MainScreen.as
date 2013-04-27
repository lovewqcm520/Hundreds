package com.jack.hundreds.view.screen
{
	import com.jack.hundreds.model.GameData;
	import com.jack.hundreds.model.LevelModel;
	import com.jack.hundreds.model.consts.Constant;
	import com.jack.hundreds.util.Log;
	import com.jack.hundreds.util.SharedObjectUtil;
	import com.jack.hundreds.view.component.SoundButton;
	
	import feathers.controls.ScreenNavigator;
	import feathers.controls.ScreenNavigatorItem;
	import feathers.motion.transitions.ScreenFadeTransitionManager;
	
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class MainScreen extends Sprite
	{
		public static const MENU_SCREEN:String = "mainMenu";
		public static const SELECT_LEVEL_SCREEN:String = "selectLevel";
		public static const PLAY_SCREEN:String = "play";
		public static const WIN_SCREEN:String = "win";
		public static const LOSE_SCREEN:String = "lose";
		
		public var m_navigator:ScreenNavigator;
		private var m_mainMenu:MenuScreen;
		private var m_transitionManager:ScreenFadeTransitionManager;
		
		private var m_gameData:GameData;
		
		public function MainScreen()
		{
			super();
			
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(e:Event):void
		{
			m_gameData = new GameData();
			
			// load local shared object
			loadDataFromLocalSharedObject();
			// show the sound icon always on the top of the screen
			addSoundButton();
			
			m_navigator = new ScreenNavigator();
			Constant.navigator = m_navigator;
			
			m_navigator.addScreen(MENU_SCREEN, new ScreenNavigatorItem(MenuScreen,
				{
					showLevelSelect:menuScreen_showLevelSelectScreenHandler
				},
				{
					gameData:m_gameData
				}
			));
			
			m_navigator.addScreen(SELECT_LEVEL_SCREEN, new ScreenNavigatorItem(SelectLevelScreen,
				{
					showPlay:menuScreen_showPlayScreenHandler,
					complete:MENU_SCREEN
				},
				{
					gameData:m_gameData
				}
			));
			
			m_navigator.addScreen(PLAY_SCREEN, new ScreenNavigatorItem(PlayScreen,
				{
					showWin:WIN_SCREEN,
					showLose:LOSE_SCREEN,
					complete:MENU_SCREEN
				},
				{
					gameData:m_gameData
				}
			));
			
			m_navigator.addScreen(WIN_SCREEN, new ScreenNavigatorItem(WinScreen,
				{
					showPlay:menuScreen_showPlayScreenHandler,
					complete:MENU_SCREEN
				},
				{
					gameData:m_gameData
				}
			));
			
			m_navigator.addScreen(LOSE_SCREEN, new ScreenNavigatorItem(LoseScreen,
				{
					showPlay:menuScreen_showPlayScreenHandler,
					complete:MENU_SCREEN
				},
				{
					gameData:m_gameData
				}
			));
			
			m_transitionManager = new ScreenFadeTransitionManager(m_navigator);
			m_transitionManager.duration = 0.4;
			
			addChild(m_navigator);
			m_navigator.showScreen(MENU_SCREEN);
			
			addChild(Constant.soundButton);
		}
		
		private function menuScreen_showLevelSelectScreenHandler(e:Event, gameData:GameData):void
		{
			m_gameData = gameData;
			m_navigator.showScreen(SELECT_LEVEL_SCREEN);
		}
		
		private function menuScreen_showPlayScreenHandler(e:Event, gameData:GameData):void
		{
			m_gameData = gameData;
			m_navigator.showScreen(PLAY_SCREEN);
		}
		
		private function loadDataFromLocalSharedObject():void
		{
			var i:int;
			var allLevelsData:Vector.<LevelModel> = new Vector.<LevelModel>();
			var levelModel:LevelModel;
			var m_passedLevel:int = 1;
			var isSoundEnabled:Boolean = true;
			
			var pl:* = SharedObjectUtil.getProperty(Constant.HUNDREDS_SHARED_OBJECT, Constant.HUNDREDS_SHARED_OBJECT_PASSED_LEVEL);
			if(pl != undefined && pl != null)
			{
				m_passedLevel = int(pl);
				
				var objList:Vector.<Object> = SharedObjectUtil.getProperty(Constant.HUNDREDS_SHARED_OBJECT, Constant.HUNDREDS_SHARED_OBJECT_DATA);
				var obj:Object;
				for (i = 0; i < objList.length; i++) 
				{
					obj = objList[i];
					levelModel = new LevelModel();
					levelModel.level = obj.level;
					levelModel.locked = obj.locked;
					levelModel.bestScores = obj.bestScores;
					allLevelsData.push(levelModel);
				}
				
				var sound:String = SharedObjectUtil.getProperty(Constant.HUNDREDS_SHARED_OBJECT, Constant.HUNDREDS_SHARED_OBJECT_SOUND);
				if(sound == Constant.SOUND_ON)
					isSoundEnabled = true;
				else if(sound == Constant.SOUND_OFF)
					isSoundEnabled = false;
			}
			else
			{
				// init all the levels data and write to the shared object
				for (i = 1; i <= Constant.HUNDREDS_MAX_LEVEL; i++) 
				{
					levelModel = new LevelModel();
					levelModel.level = i;
					levelModel.locked = ((i == 1) ? false : true);
					allLevelsData.push(levelModel);
				}
				
				SharedObjectUtil.setProperty(Constant.HUNDREDS_SHARED_OBJECT, 
					Constant.HUNDREDS_SHARED_OBJECT_PASSED_LEVEL, m_passedLevel);
				
				SharedObjectUtil.setProperty(Constant.HUNDREDS_SHARED_OBJECT, 
					Constant.HUNDREDS_SHARED_OBJECT_DATA, allLevelsData);
				
				SharedObjectUtil.setProperty(Constant.HUNDREDS_SHARED_OBJECT, 
					Constant.HUNDREDS_SHARED_OBJECT_SOUND, Constant.SOUND_ON);
			}
			
			m_gameData.passedMaxLevel = m_passedLevel;
			m_gameData.allLevelsData = allLevelsData;
			GameData.isSoundEnabled = isSoundEnabled;
			
			// testonly
			for (i = 0; i < allLevelsData.length; i++) 
			{
				levelModel = allLevelsData[i];
				Log.traced("Level", levelModel.level, levelModel.locked, levelModel.bestScores);
			}
		}
		
		private function addSoundButton():void
		{
			var soundButton:SoundButton = new SoundButton();
			soundButton.width = soundButton.height = 64;
			soundButton.x = Constant.STAGE_INIT_WIDTH - soundButton.width - 20;
			soundButton.y = 20;
			
			soundButton.setSoundEnable(GameData.isSoundEnabled);
			Constant.soundButton = soundButton;
		}
	}
}