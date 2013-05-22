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

import msignal.Slot;

/**
	A convenience type describing any kind of signal.
**/
typedef AnySignal = Signal<Dynamic, Dynamic>;

/**
	A Signal manages a list of listeners, which are executed when the signal is 
	dispatched.
**/
class Signal<TSlot:Slot<Dynamic, Dynamic>, TListener>
{
	public var valueClasses:Array<Dynamic>;

	/**
		The current number of listeners for the signal.
	**/
	public var numListeners(get_numListeners, null):Int;
	
	var slots:SlotList<TSlot, TListener>;
	var priorityBased:Bool;

	function new(?valueClasses:Array<Dynamic>)
	{
		if (valueClasses == null) valueClasses = [];
		this.valueClasses = valueClasses;
		slots = cast SlotList.NIL;
		priorityBased = false;
	}

	/**
		Subscribes a listener for the signal.
		
		@param listener A function matching the signature of TListener
		@return The added listener slot
	**/
	public function add(listener:TListener):TSlot
	{
		return registerListener(listener);
	}

	/**
		Subscribes a one-time listener for this signal.
		The signal will remove the listener automatically the first time it is called,
		after the dispatch to all listeners is complete.
		
		@param listener A function matching the signature of TListener
		@return The added listener slot
	**/
	public function addOnce(listener:TListener):TSlot
	{
		return registerListener(listener, true);
	}

	/**
		Subscribes a listener for the signal.
		After you successfully register an event listener,
		you cannot change its priority through additional calls to add().
		To change a listener's priority, you must first call remove().
		Then you can register the listener again with the new priority level.
		
		@param listener A function matching the signature of TListener
		@return The added listener slot
	**/
	public function addWithPriority(listener:TListener, ?priority:Int=0):TSlot
	{
		return registerListener(listener, false, priority);
	}

	/**
		Subscribes a one-time listener for this signal.
		The signal will remove the listener automatically the first time it is 
		called, after the dispatch to all listeners is complete.
		
		@param listener A function matching the signature of TListener
		@return The added listener slot
	**/
	public function addOnceWithPriority(listener:TListener, ?priority:Int=0):TSlot
	{
		return registerListener(listener, true, priority);
	}

	/**
		Unsubscribes a listener from the signal.
		
		@param listener The listener to remove
		@return The removed listener slot
	**/
	public function remove(listener:TListener):TSlot
	{
		var slot = slots.find(listener);
		if (slot == null) return null;
		
		slots = slots.filterNot(listener);
		return slot;
	}

	/**
		Unsubscribes all listeners from the signal.
	**/
	public function removeAll():Void
	{
		slots = cast SlotList.NIL;
	}

	function registerListener(listener:TListener, once:Bool=false, priority:Int=0):TSlot
	{
		if (registrationPossible(listener, once))
		{
			var newSlot = createSlot(listener, once, priority);
			
			if (!priorityBased && priority != 0) priorityBased = true;
			if (!priorityBased && priority == 0) slots = slots.prepend(newSlot);
			else slots = slots.insertWithPriority(newSlot);

			return newSlot;
		}
		
		return slots.find(listener);
	}

	function registrationPossible(listener, once)
	{
		if (!slots.nonEmpty) return true;
		
		var existingSlot = slots.find(listener);
		if (existingSlot == null) return true;

		if (existingSlot.once != once)
		{
			// If the listener was previously added, definitely don't add it again.
			// But throw an exception if their once values differ.
			throw "You cannot addOnce() then add() the same listener without removing the relationship first.";
		}
		
		return false; // Listener was already registered.
	}

	@:IgnoreCover
	function createSlot(listener:TListener, once:Bool=false, priority:Int=0):TSlot
	{
		return null;
	}

	function get_numListeners()
	{
		return slots.length;
	}
}

/**
	Signal that executes listeners with no arguments.
**/
class Signal0 extends Signal<Slot0, Void -> Void>
{
	public function new()
	{
		super();
	}

	/**
		Executes the signals listeners with no arguements.
	**/
	public function dispatch()
	{
		var slotsToProcess = slots;
		
		while (slotsToProcess.nonEmpty)
		{
			slotsToProcess.head.execute();
			slotsToProcess = slotsToProcess.tail;
		}
	}

	override function createSlot(listener:Void -> Void, once:Bool=false, priority:Int=0)
	{
		return new Slot0(this, listener, once, priority);
	}
}

/**
	Signal that executes listeners with one arguments.
**/
class Signal1<TValue> extends Signal<Slot1<TValue>, TValue -> Void>
{
	public function new(?type:Dynamic=null)
	{
		super([type]);
	}

	/**
		Executes the signals listeners with one arguement.
	**/
	public function dispatch(value:TValue)
	{
		var slotsToProcess = slots;
		
		while (slotsToProcess.nonEmpty)
		{
			slotsToProcess.head.execute(value);
			slotsToProcess = slotsToProcess.tail;
		}
	}

	override function createSlot(listener:TValue -> Void, once:Bool=false, priority:Int=0)
	{
		return new Slot1<TValue>(this, listener, once, priority);
	}
}

/**
	Signal that executes listeners with two arguments.
**/
class Signal2<TValue1, TValue2> extends Signal<Slot2<TValue1, TValue2>, TValue1 -> TValue2 -> Void>
{
	public function new(?type1:Dynamic=null, ?type2:Dynamic=null)
	{
		super([type1, type2]);
	}

	/**
		Executes the signals listeners with two arguements.
	**/
	public function dispatch(value1:TValue1, value2:TValue2)
	{
		var slotsToProcess = slots;
		
		while (slotsToProcess.nonEmpty)
		{
			slotsToProcess.head.execute(value1, value2);
			slotsToProcess = slotsToProcess.tail;
		}
	}

	override function createSlot(listener:TValue1 -> TValue2 -> Void, once:Bool=false, priority:Int=0)
	{
		return new Slot2<TValue1, TValue2>(this, listener, once, priority);
	}
}
