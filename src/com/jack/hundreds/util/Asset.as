package com.jack.hundreds.util
{
	import com.jack.hundreds.Root;
	
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.textures.Texture;

	public class Asset
	{
		public static function getDisplayObject(name:String, fps:Number=24):DisplayObject
		{
			if(Root.assets.getTexture(name))
			{
				var texture:Texture = Root.assets.getTexture(name);
				return new Image(texture);
			}
			else if(Root.assets.getTextures(name))
			{
				var textures:Vector.<Texture> = Root.assets.getTextures(name);
				if(textures && textures.length >= 1)
					return new MovieClip(textures, fps);
			}
			
			Log.error("getDisplayObject", name);
			return null;
		}
		

	}
}