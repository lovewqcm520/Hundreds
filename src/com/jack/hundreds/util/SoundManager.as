package com.jack.hundreds.util
{
    import com.jack.hundreds.Root;
    import com.jack.hundreds.model.consts.Constant;
    
    import flash.media.SoundChannel;
    import flash.media.SoundTransform;


    public class SoundManager extends Object
    {
		private static const vtFadeOut:int = 0;
		private static const vtFadeIn:int = 1;
        private static const vtNormal:int = 2;
        private static var m_volumeType:int = 2;
		
        private static var m_musicVolume:Number = 1;
		private static var m_soundVolume:Number = 1;
		
        private static var m_isSoundEnable:Boolean = true;
		
        private static var m_currentLoop:SoundChannel;
        private static var m_musicVolumeBackup:Number;
        private static var m_liveTime:Number;
        private static var m_currentLoopName:String;
        private static var m_soundAfterFade:String;

        public function SoundManager()
        {
            return;
        }

        /**
         * When play this soundName sound, fade out the background music, when soundName finish, fade in back the 
		 * background music.
         * @param soundName
         */
        public static function playFadeOut(soundName:String) : void
        {
            m_musicVolumeBackup = m_musicVolume;
            m_volumeType = vtFadeOut;
            m_soundAfterFade = soundName;
            return;
        }

        public static function setSoundVolume(volume:Number) : void
        {
            m_soundVolume = volume;
        }

        public static function update(elapsedSecond:Number) : void
        {
            m_liveTime = m_liveTime + elapsedSecond;
            if (m_isSoundEnable)
            {
                switch(m_volumeType)
                {
                    case vtFadeOut:
                    {
                        setMusicVolume(m_musicVolume - 0.8 * elapsedSecond);
                        if (m_musicVolume <= 0.15)
                        {
                            play(m_soundAfterFade);
                            m_volumeType = vtNormal;
                            m_liveTime = 0;
                        }
                        break;
                    }
                    case vtNormal:
                    {
                        if (m_liveTime > 2.3 && m_soundAfterFade)
                        {
                            m_soundAfterFade = null;
                            m_volumeType = vtFadeIn;
                        }
                        break;
                    }
                    case vtFadeIn:
                    {
                        setMusicVolume(m_musicVolume + 1.5 * elapsedSecond);
                        if (m_musicVolume >= m_musicVolumeBackup)
                        {
                            setMusicVolume(m_musicVolumeBackup);
                            m_volumeType = vtNormal;
                        }
                        break;
                    }
                    default:
                    {
                        break;
                    }
                }
            }
        }

        public static function getSoundVolume() : Number
        {
            return m_soundVolume;
        }

        public static function setMusicVolume(volume:Number) : void
        {
            if (volume < 0.01)
            {
                volume = 0;
            }
            if (volume > 1)
            {
                volume = 1;
            }
            m_musicVolume = volume;
            if (m_currentLoop)
            {
				var transform:SoundTransform = m_currentLoop.soundTransform;
                transform.volume = volume;
                m_currentLoop.soundTransform = transform;
            }
        }

        public static function getMusicVolume() : Number
        {
            return m_musicVolume;
        }

        public static function setSoundEnable(enable:Boolean) : void
        {
            m_volumeType = vtNormal;
            m_isSoundEnable = enable;
            if (m_isSoundEnable)
            {
                var soundName:String = m_currentLoopName;
                m_currentLoopName = "";
                playLoop(soundName);
            }
            else if (m_currentLoop)
            {
                m_currentLoop.stop();
            }
        }

        /**
         * Play a sound once.
         * @param soundName
         */
        public static function play(soundName:String) : void
        {
            if (m_isSoundEnable)
            {
                try
                {
					var channel:SoundChannel = Root.assets.playSound(soundName);
					var transform:SoundTransform = channel.soundTransform;
                    transform.volume = m_soundVolume;
                    channel.soundTransform = transform;
                }
                catch (e:Error)
                {
                    if (Constant.m_debugMode)
                    {
                        trace(e);
                    }
                }
            }
        }

        /**
         * Play loop sound, normally are background music.
         * @param soundName
         */
        public static function playLoop(soundName:String) : void
        {
            try
            {
                if (m_isSoundEnable)
                {
                    if (m_currentLoopName != soundName)
                    {
                        if (m_currentLoop != null)
                        {
                            m_currentLoop.stop();
                        }
                        m_currentLoop = Root.assets.playSound(soundName, 0, int.MAX_VALUE);
						var transform:SoundTransform = m_currentLoop.soundTransform;
                        transform.volume = m_musicVolume;
                        m_currentLoop.soundTransform = transform;
                    }
                }
                m_currentLoopName = soundName;
            }
            catch (e:Error)
            {
                if (Constant.m_debugMode)
                {
                    trace("SoundManager::playLoop", e);
                }
            }
        }

    }
}
