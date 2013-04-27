package com.jack.hundreds.util
{
	public class Log
	{
		public static function traced(...arg):void
		{
			var str:String = "Traced Log:	";
			for (var i:int = 0; i < arg.length; i++) 
			{
				str += (String(arg[i]) + " ");
			}
			
			trace(str);
		}
		
		public static function error(...arg):void
		{
			var str:String = "Error Log:	";
			for (var i:int = 0; i < arg.length; i++) 
			{
				str += (String(arg[i]) + " ");
			}
			
			trace(str);
		}
	}
}