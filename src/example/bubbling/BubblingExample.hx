import msignal.EventSignal;

class BubblingExample
{
	public static function main()
	{
		var root = new Display("root");
		var child1 = new Display("Child 1");
		var child2 = new Display("Child 2");
		var child3 = new Display("Child 3");

		// this handler traces all events
		root.event.add(handler);

		// this handler only traces remove events
		root.event.add(removeHandler).forType(removed);

		// addOnce and priority work too
		root.event.addOnce(onceHandler).forType(added);

		// generate some events
		root.add(child1);
		child1.add(child2);
		child2.add(child3);
		root.remove(child1);
	}

	static function handler(event:DisplayEvent)
	{
		trace("handler: " + event.target.id + ":" + event.type);
	}

	static function removeHandler(event:DisplayEvent)
	{
		trace("removeHandler: " + event.target.id + ":" + event.type);
	}

	static function onceHandler(event:DisplayEvent)
	{
		trace("onceHandler: " + event.target.id + ":" + event.type);
	}
}

// a convenience typedef for display events
typedef DisplayEvent = Event<Display, DisplayEventType>;

// the types of events our display can dispatch
enum DisplayEventType
{
	added;
	removed;

	// for example
	mouseMoved(x:Int, y:Int);
}

// something that might bubble events, like a display list
class Display implements EventDispatcher<DisplayEvent>
{
	var children:List<Display>;

	public var id:String;
	public var parent:Display;
	public var event:EventSignal<Display, DisplayEventType>;

	public function new(id:String)
	{	
		this.id = id;

		children = new List<Display>();
		event = new EventSignal<Display, DisplayEventType>(this);
	}

	public function add(display:Display)
	{
		children.add(display);
		display.parent = this;
		display.event.dispatchType(added);
	}

	public function remove(display:Display)
	{
		display.event.dispatchType(removed);
		children.remove(display);
		display.parent = null;
	}

	public function dispatchEvent(event:DisplayEvent):Bool
	{
		this.event.dispatchEvent(event);
		return true;
	}
}


