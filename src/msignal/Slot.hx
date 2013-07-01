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

/**
	A convenience type describing any kind of slot.
**/
typedef AnySlot = Slot<Dynamic, Dynamic>;

/**
	Defines the basic properties of a listener associated with a Signal.
**/
#if haxe3
class Slot<TSignal:msignal.Signal.AnySignal, TListener>
#else
class Slot<TSignal:Signal<Dynamic, TListener>, TListener>
#end
{
	/**
		The listener associated with this slot.
		Note: for hxcpp 2.10 this requires a getter method to compile
	**/
	#if cpp
	#if haxe3 @:isVar #end
	public var listener(get_listener, set_listener):TListener;
	#else
	#if haxe3 @:isVar #end
	public var listener(default, set_listener):TListener;
	#end
	

	/**
		Whether this slot is automatically removed after it has been used once.
	**/
	public var once(default, null):Bool;

	/**
		The priority of this slot should be given in the execution order.
		An Signal will call higher numbers before lower ones.
		Defaults to 0.
	**/
	public var priority(default, null):Int;

	/**
		Whether the listener is called on execution. Defaults to true.
	**/
	public var enabled:Bool;

	var signal:TSignal;
	
	function new(signal:TSignal, listener:TListener, once:Bool=false, priority:Int=0)
	{
		this.signal = signal;
		this.listener = listener;
		this.once = once;
		this.priority = priority;
		this.enabled = true;
	}

	/**
		Removes the slot from its signal.
	**/
	public function remove()
	{
		signal.remove(listener);
	}

	#if cpp
	/**
		Hxcpp 2.10 requires a getter method for a typed function property in 
		order to compile
	**/
	function get_listener():TListener
	{
		return listener;
	}
	#end

	function set_listener(value:TListener):TListener
	{
		if (value == null) throw "listener cannot be null";
		return listener = value;
	}
}

/**
	A slot that executes a listener with no arguments.
**/
class Slot0 extends Slot<Signal0, Void -> Void>
{
	public function new(signal:Signal0, listener:Void -> Void, once:Bool=false, priority:Int=0)
	{
		super(signal, listener, once, priority);
	}

	/**
		Executes a listener with no arguments.
	**/
	public function execute()
	{
		if (!enabled) return;
		if (once) remove();
		listener();
	}
}

/**
	A slot that executes a listener with one argument.
**/
class Slot1<TValue> extends Slot<Signal1<TValue>, TValue -> Void>
{
	/**
		Allows the slot to inject the argument to dispatch.
	**/
	public var param:TValue;

	public function new(signal:Signal1<TValue>, listener:TValue -> Void, once:Bool=false, priority:Int=0)
	{
		super(signal, listener, once, priority);
	}

	/**
		Executes a listener with one argument.
		If <code>param</code> is not null, it overrides the value provided.
	**/
	public function execute(value1:TValue)
	{
		if (!enabled) return;
		if (once) remove();
		if (param != null) value1 = param;
		listener(value1);
	}
}

/**
	A slot that executes a listener with two arguments.
**/
class Slot2<TValue1, TValue2> extends Slot<Signal2<TValue1, TValue2>, TValue1 -> TValue2 -> Void>
{
	/**
		Allows the slot to inject the first argument to dispatch.
	**/
	public var param1:TValue1;

	/**
		Allows the slot to inject the second argument to dispatch.
	**/
	public var param2:TValue2;

	public function new(signal:Signal2<TValue1, TValue2>, listener:TValue1 -> TValue2 -> Void, once:Bool=false, priority:Int=0)
	{
		super(signal, listener, once, priority);
	}

	/**
		Executes a listener with two arguments.
		If <code>param1</code> or <code>param2</code> is set, 
		they override the values provided.
	**/
	public function execute(value1:TValue1, value2:TValue2)
	{
		if (!enabled) return;
		if (once) remove();
		
		if (param1 != null) value1 = param1;
		if (param2 != null) value2 = param2;
		
		listener(value1, value2);
	}
}
