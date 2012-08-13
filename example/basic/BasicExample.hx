import msignal.Signal;

class BasicExample
{
	public static function main()
	{
		new BasicExample();
	}

	public function new()
	{
		signalWithNoArgs();
		signalWithOneArg();
		signalWithTwoArgs();	
	}

	function signalWithNoArgs()
	{
		var changed = new Signal0();
		changed.addOnce(changeHandler);
		changed.dispatch();
	}

	function changeHandler()
	{
		trace("changed");
	}

	function signalWithOneArg()
	{
		var completed = new Signal1(String);
		completed.addOnce(completeHandler);
		completed.dispatch("hello");
	}

	function completeHandler(msg:String)
	{
		trace("completed " + msg);
	}


	function signalWithTwoArgs()
	{
		var progressed = new Signal2(Int, Int);
		progressed.addOnce(progressedHandler);
		progressed.dispatch(100, 1024);
	}

	function progressedHandler(percentLoaded:Int, bytesLoaded:Int)
	{
		trace("progress " + percentLoaded + "% (" + bytesLoaded + "kb)");
	}
}
