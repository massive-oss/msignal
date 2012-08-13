import msignal.Signal;

class ExtendExample
{
	public static function main()
	{
		new ExtendExample();
	}

	public function new()
	{
		var signal = new CustomSignal();
	
		signal.add(handler);
		signal.dispatch("yes");
		signal.dispatch("yes");

		signal.remove(handler);
		signal.dispatch("no");

		signal.addOnce(handler);
		signal.dispatch("yes");
		//wont get called because handler only added once
		signal.dispatch("no");


		signal.add(handler);
		signal.removeAll();
		signal.dispatch("no");

	}

	function handler(msg:String)
	{
		trace("handler " + msg);
	}
}


class CustomSignal extends Signal1<String>
{
	public function new()
	{
		super(String);
	}
}

