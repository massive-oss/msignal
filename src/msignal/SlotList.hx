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

class SlotList<TSlot:Slot<Dynamic, Dynamic>, TListener>
{
	@:IgnoreCover
	static function __init__() { NIL = new SlotList<Dynamic, Dynamic>(null, null); }
	
	/**
		Represents an empty list. Used as the list terminator.
	**/
	public static var NIL:SlotList<Dynamic, Dynamic>;
	
	public var head:TSlot;
	public var tail:SlotList<TSlot, TListener>;
	public var nonEmpty:Bool;
	
	/**
		Creates and returns a new SlotList object.

		<p>A user never has to create a SlotList manually. 
		Use the <code>NIL</code> element to represent an empty list. 
		<code>NIL.prepend(value)</code> would create a list containing 
		<code>value</code></p>.

		@param head The first slot in the list.
		@param tail A list containing all slots except head.
	**/
	public function new(head:TSlot, tail:SlotList<TSlot, TListener>=null)
	{
		nonEmpty = false;
		
		if (head == null && tail == null)
		{
			if (NIL != null)
			{
				throw "Parameters head and tail are null. Use the NIL element instead.";
			}
			
			// this is the NIL element as per definition
			nonEmpty = false;
		}
		else if (head == null)
		{
			throw "Parameter head cannot be null.";
		}
		else
		{
			this.head = head;
			this.tail = (tail == null ? cast NIL : tail);
			nonEmpty = true;
		}
	}
	
	/**
		The number of slots in the list.
	**/
	public var length(get_length, null):Int;
	function get_length():Int
	{
		if (!nonEmpty) return 0;
		if (tail == NIL) return 1;
		
		// We could cache the length, but it would make methods like filterNot unnecessarily complicated.
		// Instead we assume that O(n) is okay since the length property is used in rare cases.
		// We could also cache the length lazy, but that is a waste of another 8b per list node (at least).
		
		var result = 0;
		var p = this;
		
		while (p.nonEmpty)
		{
			++result;
			p = p.tail;
		}
		
		return result;
	}
	
	/**
		Prepends a slot to this list.
		@param	slot The item to be prepended.
		@return	A list consisting of slot followed by all elements of this list.
	**/
	public function prepend(slot:TSlot)
	{
		return new SlotList<TSlot, TListener>(slot, this);
	}
	
	/**
		Appends a slot to this list.
		Note: appending is O(n). Where possible, prepend which is O(1).
		In some cases, many list items must be cloned to 
		avoid changing existing lists.
		@param	slot The item to be appended.
		@return	A list consisting of all elements of this list followed by slot.
	**/
	public function append(slot:TSlot)
	{
		if (slot == null) return this;
		if (!nonEmpty) return new SlotList<TSlot, TListener>(slot);
		
		// Special case: just one slot currently in the list.
		if (tail == NIL) 
		{
			return new SlotList<TSlot, TListener>(slot).prepend(head);
		}
		
		// The list already has two or more slots.
		// We have to build a new list with cloned items because they are immutable.
		var wholeClone = new SlotList<TSlot, TListener>(head);
		var subClone = wholeClone;
		var current = tail;
		
		while (current.nonEmpty)
		{
			subClone = subClone.tail = new SlotList<TSlot, TListener>(current.head);
			current = current.tail;
		}
		
		// Append the new slot last.
		subClone.tail = new SlotList<TSlot, TListener>(slot);
		return wholeClone;
	}		
	
	/**
		Insert a slot into the list in a position according to its priority.
		The higher the priority, the closer the item will be inserted to the 
		list head.
		@param slot The item to be inserted.
	**/
	public function insertWithPriority(slot:TSlot)
	{
		if (!nonEmpty) return new SlotList<TSlot, TListener>(slot);
		
		var priority:Int = slot.priority;
		
		// Special case: new slot has the highest priority.
		if (priority >= this.head.priority) return prepend(slot);

		var wholeClone = new SlotList<TSlot, TListener>(head);
		var subClone = wholeClone;
		var current = tail;

		// Find a slot with lower priority and go in front of it.
		while (current.nonEmpty)
		{
			if (priority > current.head.priority)
			{
				subClone.tail = current.prepend(slot);
				return wholeClone;
			}
			
			subClone = subClone.tail = new SlotList<TSlot, TListener>(current.head);
			current = current.tail;
		}
		
		// Slot has lowest priority.
		subClone.tail = new SlotList<TSlot, TListener>(slot);
		return wholeClone;
	}
	
	/**
		Returns the slots in this list that do not contain the supplied 
		listener. Note: assumes the listener is not repeated within the list.
		@param	listener The function to remove.
		@return A list consisting of all elements of this list that do not 
				have listener.
	**/
	public function filterNot(listener:TListener)
	{
		if (!nonEmpty || listener == null) return this;
		
		if (Reflect.compareMethods(head.listener, listener)) return tail;
		
		// The first item wasn't a match so the filtered list will contain it.
		var wholeClone = new SlotList<TSlot, TListener>(head);
		var subClone = wholeClone;
		var current = tail;
		
		while (current.nonEmpty)
		{
			if (Reflect.compareMethods(current.head.listener, listener))
			{
				// Splice out the current head.
				subClone.tail = current.tail;
				return wholeClone;
			}
			
			subClone = subClone.tail = new SlotList<TSlot, TListener>(current.head);
			current = current.tail;
		}
		
		// The listener was not found so this list is unchanged.
		return this;
	}
	
	/**
		Determines whether the supplied listener Function is contained 
		within this list
	**/
	public function contains(listener:TListener):Bool
	{
		if (!nonEmpty) return false;

		var p = this;
		while (p.nonEmpty)
		{
			if (Reflect.compareMethods(p.head.listener, listener)) return true;
			p = p.tail;
		}

		return false;
	}
	
	/**
		Retrieves the Slot associated with a supplied listener within the SlotList.
		@param   listener The Function being searched for
		@return  The ISlot in this list associated with the listener parameter 
				 through the ISlot.listener property. Returns null if no such 
				 ISlot instance exists or the list is empty.  
	**/
	public function find(listener:TListener):TSlot
	{
		if (!nonEmpty) return null;
		
		var p = this;
		while (p.nonEmpty)
		{
			if (Reflect.compareMethods(p.head.listener, listener)) return p.head;
			p = p.tail;
		}
		
		return null;
	}
}
