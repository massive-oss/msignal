/*
Copyright (c) 2012 Massive Interactive

Permission is hereby granted, free of charge, to any person obtaining a copy of 
this software and associated documentation files (the "Software"), to deal in 
the Software without restriction, including without limitation the rights to 
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
of the Software, and to permit persons to whom the Software is furnished to do 
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all 
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
SOFTWARE.
*/

package msignal;

import msignal.Signal;
import msignal.Slot;

import Type;

/**
	Signal that executes listeners with one arguments.
**/
class EventSignal<TTarget, TType> 
	extends Signal<EventSlot<TType>, Event<TTarget, TType> -> Void>
{
	/**
		The object for which this signal dispatches events.
	**/
	public var target(default, null):TTarget;

	/**
		Creates an `EventSignal` for the provided target.
	**/
	public function new(target:TTarget)
	{
		super([Event]);
		this.target = target;
	}

	/**
		Dispatches an event to the listeners of the `EventSignal`.
	**/
	public function dispatch(event:Event<TTarget, TType>):Void
	{
		if (event.target == null)
		{
			// set the event target
			untyped event.target = target;
			untyped event.signal = this;
		}
		
		// update current target
		event.currentTarget = target;

		// Broadcast to listeners.
		var slotsToProcess = slots;

		while (slotsToProcess.nonEmpty)
		{
			slotsToProcess.head.execute(event);
			slotsToProcess = slotsToProcess.tail;
		}
	}

	public function dispatchType(type:TType):Void
	{
		dispatch(new Event(type));
	}

	/**
		Dispatches an event to this signals listeners by calling `dispatch`, and 
		then attempts to bubble the event by checking if `target` has a field 
		`parent` of type `EventDispatcher`. Each event dispatcher in the chain 
		has an opportunity to cancel bubbling by returning `false` when 
		`dispatchEvent` is called.

		EventSignals are themselves EventDispatchers, which simplifies creating 
		bubbling chains without creating another hierarchy.
	**/
	public function bubble(event:Event<TTarget, TType>):Void
	{
		// dispatch to this signals listeners first
		dispatch(event);

		// then bubble the event as far as possible.
		var currentTarget = target;
		
		while (currentTarget != null && Reflect.hasField(currentTarget, "parent"))
		{
			currentTarget = Reflect.field(currentTarget, "parent");
			
			if (Std.is(currentTarget, EventDispatcher))
			{
				event.currentTarget = currentTarget;
				var dispatcher = cast(currentTarget, EventDispatcher<Dynamic>);

				// dispatchEvent() can stop the bubbling by returning false.
				if (!dispatcher.dispatchEvent(event)) break;
			}
		}
	}

	/**
		A convenience method for dispatching an event without having to 
		instantiate it directly. This helps prevent the ink wearing off your 
		angle bracket keys.
	**/
	public function bubbleType(type:TType):Void
	{
		bubble(new Event(type));
	}

	/**
		Internal method used to create the slot type for this signal.
	**/
	override function createSlot(listener:Event<TTarget, TType> -> Void, once:Bool=false, priority:Int=0)
	{
		return new EventSlot(this, cast listener, once, priority);
	}
}

/**
	A slot that executes a listener with one argument.
**/
class EventSlot<TValue> extends Slot<Dynamic, Event<Dynamic, TValue> -> Void>
{
	/**
		The expected type for this slot or null if one has not been set using `forType`.
	**/
	var filterType:Null<TValue>;

	public function new(signal:Dynamic, listener:Event<Dynamic, TValue> -> Void, once:Bool=false, priority:Int=0)
	{
		super(signal, listener, once, priority);
	}

	/**
		Executes a listener with one argument.
		If type <code>params</code> are not null, it will check type equality 
		on enum parameters.
	**/
	public function execute(value1:Event<Dynamic, TValue>)
	{
		if (!enabled) return;

		if (filterType != null && !typeEq(filterType, value1.type)) return;
		if (once) remove();
		listener(value1);
	}

	/**
		Restricts the slot to firing for events of a specific type.
		EnumValues with paramaters can specify explicit or fuzzy matching 
		criteria.

		To match against specific <code>param</code> values include them in the 
		type (e.g. Progress(1))
		To fuzzy match against any value use a <code>null</code> value 
		(e.g. Progress(null))
	**/
	public function forType(value:TValue)
	{
		filterType = value;
	}

	public static function typeEq(a:Dynamic, b:Dynamic):Bool
	{
		if(a == b) return true;

		switch(Type.typeof(a))
		{
			case TEnum(_):
			{
				return enumTypeEq(cast a, cast b);
			}
			default:
				return false;
		}
		return false;
	}

	/**
		Compares enum equality, ignoring any non enum parameters, so that:
			Fail(IO("One thing happened")) == Fail(IO("Another thing happened"))
		
		Also allows for wildcard matching by passing through <code>null</code> for
		any params, so that:
			Fail(IO(null)) matches Fail(IO("Another thing happened"))
		
		@param a the enum value to filter on
		@param b the enum value being checked
	**/
	static public function enumTypeEq(a:EnumValue, b:EnumValue)
	{
		if (a == b) return true;
		if (Type.getEnum(a) != Type.getEnum(b)) return false;
		if (Type.enumIndex(a) != Type.enumIndex(b)) return false;

		var aParams = Type.enumParameters(a);
		if (aParams.length == 0) return true;
		var bParams = Type.enumParameters(b);

		for (i in 0...aParams.length)
		{
			var aParam = aParams[i];
			var bParam = bParams[i];

			if (aParam == null) continue;
			if(!typeEq(aParam, bParam)) return false;
		}

		return true;
	}

	
}

/**
	Encapsulates information about a dispatched event.

	The event object defines properties that listeners might need to act on an 
	event: the target/signal of the event (where it originated), the current 
	target (the target of the most recent signal to dispatch the event) and 
	the type. To avoid developers needing to subclass Event to create custom 
	fields and data, Events use type parameters to define target and type 
	constraints, and use enums as event types to allow additional data.
**/
class Event<TTarget, TType>
{
	/**
		The original signal that dispatched this event.
	**/
	public var signal(default, null):EventSignal<TTarget, TType>;

	/**
		The target of the original signal that dispatched this event.
	**/
	public var target(default, null):TTarget;

	/**
		The type of the event.
	**/
	public var type(default, null):TType;

	/**
		The most recent target of the event. This is set each time an 
		`EventSignal` dispatches an event. When an event bubbles, `target` is 
		the original target while `currentTarget` is the most recent.
	**/
	public var currentTarget:TTarget;
	
	public function new(type:TType)
	{
		this.type = type;
	}
}

/**
	The EventDispatcher interface.
**/
interface EventDispatcher<TEvent>
{
	/**
		Dispatch an event, returning `true` if the event should continue to 
		bubble, and `false` if not.
	**/
	function dispatchEvent(event:TEvent):Bool; 
}
