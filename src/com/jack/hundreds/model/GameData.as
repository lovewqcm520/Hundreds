package com.jack.hundreds.model
{
	import com.jack.hundreds.model.consts.Constant;

	public class GameData
	{
		public var maxScoresForPass:int = 100;
		public var passedMaxLevel:int;
		public var curPlayingLevel:int = 1;
		public var scaleable_ball_init_radius:Number = 30*Constant.SCALE_FACTOR_Y;
		public var scaleable_ball_speed:Number = 250*Constant.SCALE_FACTOR_Y;
		
		public var timeUsed:Number;
		public var totalScores:int;
		public static var isSoundEnabled:Boolean;
		private static var m_gameStatus:int = -1;
		
		public var allLevelsData:Vector.<LevelModel>;
		
		public function GameData()
		{
		}

		public static function get gameStatus():int
		{
			return m_gameStatus;
		}

		public static function set gameStatus(value:int):void
		{
			if(m_gameStatus != value)
			{
				m_gameStatus = value;
				
				switch(m_gameStatus)
				{
					case Constant.GAME_STATUS_MENU:
					{
						Constant.soundButton.visible = true;
						break;
					}
						
					case Constant.GAME_STATUS_PLAYING:
					{
						Constant.soundButton.visible = false;
						break;
					}
						
					case Constant.GAME_STATUS_PAUSE:
					{
						Constant.soundButton.visible = true;
						break;
					}
						
					case Constant.GAME_STATUS_WIN:
					{
						Constant.soundButton.visible = true;
						break;
					}
						
					case Constant.GAME_STATUS_LOSE:
					{
						Constant.soundButton.visible = true;
						break;
					}
						
					case Constant.GAME_STATUS_ACTIVATE:
					{
						
						break;
					}
						
					case Constant.GAME_STATUS_DEACTIVATE:
					{
						
						break;
					}
						
					default:
					{
						break;
					}
				}
			}
		}

	}
}