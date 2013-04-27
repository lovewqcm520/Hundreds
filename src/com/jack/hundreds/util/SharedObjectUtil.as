package com.jack.hundreds.util
{
	import flash.net.SharedObject;

	public class SharedObjectUtil
	{
		public function SharedObjectUtil()
		{
		}
		
		/**
		 * Return data object of the specified sharedObject.
		 * @param sharedObjectName
		 * @param localPath
		 * @return 
		 */
		public static function getSharedObjectData(sharedObjectName:String, localPath:String=null):Object
		{
			var so:SharedObject = SharedObject.getLocal(sharedObjectName, localPath);
			return so.data;
		}
		
		/**
		 * Retrun the property value by a key from the specified sharedObject.
		 * @param sharedObjectName
		 * @param key
		 * @param localPath
		 * @return 
		 */
		public static function getProperty(sharedObjectName:String, key:String, localPath:String=null):*
		{
			try
			{
				var data:Object = SharedObjectUtil.getSharedObjectData(sharedObjectName, localPath);
				
				if(data)
					return data[key];
				else
					return null;
			} 
			catch(error:Error) 
			{
				Log.error(error.name, error.message);
			}
		}
		
		/**
		 * Set the property value with a key to the specified sharedObject.
		 * @param sharedObjectName
		 * @param key
		 * @param value
		 * @param minDiskSpace
		 * @param localPath
		 */
		public static function setProperty(sharedObjectName:String, key:String, value:*, minDiskSpace:int=0, localPath:String=null):void
		{
			try
			{
				var so:SharedObject = SharedObject.getLocal(sharedObjectName, localPath);
				
				so.data[key] = value;
				so.flush(minDiskSpace);
				
				Log.traced("setProperty", sharedObjectName, key, value);
			} 
			catch(error:Error) 
			{
				Log.error(error.name, error.message);
			}
		}
		
		/**
		 * Remove the property value by a key from the specified sharedObject.
		 * @param sharedObjectName
		 * @param key
		 * @param localPath
		 * @return 
		 */
		public static function removeProperty(sharedObjectName:String, key:String, localPath:String=null):void
		{
			try
			{
				var data:Object = SharedObjectUtil.getSharedObjectData(sharedObjectName, localPath);
				
				if(data)
					delete data[key];
			} 
			catch(error:Error) 
			{
				Log.error(error.name, error.message);
			}
		}
		
		/**
		 * Clear all the properties from the specified sharedObject.
		 * @param sharedObjectName
		 * @param localPath
		 */
		public static function clear(sharedObjectName:String, localPath:String=null):void
		{
			try
			{
				var so:SharedObject = SharedObject.getLocal(sharedObjectName, localPath);
				
				so.clear();
			} 
			catch(error:Error) 
			{
				Log.error(error.name, error.message);
			}
		}
	}
}