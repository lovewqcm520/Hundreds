package com.jack.hundreds.view.component
{
	import com.jack.hundreds.model.GameData;
	import com.jack.hundreds.model.consts.Constant;
	import com.jack.hundreds.util.Asset;
	import com.jack.hundreds.util.SharedObjectUtil;
	import com.jack.hundreds.util.SoundManager;
	
	import feathers.controls.Check;
	
	import starling.events.Event;
	
	public class SoundButton extends Check
	{
		public function SoundButton()
		{
			super();
			
			this.isSelected = true;
			this.defaultSelectedSkin = Asset.getDisplayObject("sound_on1");
			this.defaultSkin = Asset.getDisplayObject("sound_off1");
			this.addEventListener(Event.TRIGGERED, onTriggered);
		}
		
		private function onTriggered(e:Event):void
		{
			setSoundAndSave(!this.isSelected);
		}		
		
		public function setSoundEnable(enable:Boolean):void
		{
			this.isSelected = enable;
			
			setSoundAndSave(enable);
		}
		
		private function setSoundAndSave(enable:Boolean):void
		{
			GameData.isSoundEnabled = enable;
			SharedObjectUtil.setProperty(Constant.HUNDREDS_SHARED_OBJECT, 
				Constant.HUNDREDS_SHARED_OBJECT_SOUND, (enable ? Constant.SOUND_ON : Constant.SOUND_OFF));
			
			SoundManager.setSoundEnable(enable);
		}
	}
}