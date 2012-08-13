import msignal.Signal;

class ResponderExample
{
	public static function main()
	{
		new ResponderExample();
	}

	var responderSignal:ResponderSignal<Item>;
	
	public function new()
	{
		responderSignal = new ResponderSignal(Item);

		responderSignal.add(mockRequest);
		responderSignal.completed.addOnce(completed);
		responderSignal.failed.addOnce(failed);

		var item = new Item(1);
		responderSignal.dispatch(item);
	}

	function mockRequest(item:Item)
	{
		trace("request " + item);
		responderSignal.completed.dispatch(item);
		responderSignal.failed.dispatch("something went wrong");
	}

	function completed(item:Item)
	{
		trace("completed " + item);
	}

	function failed(error:Dynamic)
	{
		trace("failed " + Std.string(error));
	}
}


class ResponderSignal<T> extends Signal1<T>
{
	public var completed:Signal1<T>;
	public var failed:Signal1<Dynamic>;

	public function new(type:Class<T>)
	{
		super(type);
		completed = new Signal1<T>(type);
		failed = new Signal1<Dynamic>(Dynamic);
	}

	override public function removeAll():Void
	{
		super.removeAll();
		completed.removeAll();
		failed.removeAll();
	}
}


class Item
{
	public var id:Int;

	public function new(id:Int)
	{
		this.id = id;
	}

	public function toString():String
	{
		return "Item " + id;
	}
}
