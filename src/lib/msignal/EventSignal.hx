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

class EventSignal<TTarget, TEvent:Event<TTarget>> extends Signal1<TEvent>
{
	public var target(default, set_target):TTarget;

	public function new(target:TTarget=null)
	{
		super(Event);
		this.target = target;
	}

	function set_target(value:TTarget):TTarget
	{
		if (value == target) return target;
		removeAll();
		target = value;
		return target;
	}

	override public function dispatch(event:TEvent):Void
	{
		if (event.target != null)
		{
			event = cast event.clone();
		}

		event.target = target;
		event.currentTarget = target;
		event.signal = this;
		
		// Broadcast to listeners.
		var slotsToProcess = slots;

		while (slotsToProcess.nonEmpty)
		{
			slotsToProcess.head.execute(event);
			slotsToProcess = slotsToProcess.tail;
		}

		// Bubble the event as far as possible.
		if (!event.bubbles) return;

		var currentTarget = target;

		while (currentTarget != null && Reflect.hasField(currentTarget, "parent"))
		{
			currentTarget = Reflect.field(currentTarget, "parent");

			if (Std.is(currentTarget, IBubbleEventHandler))
			{
				event.currentTarget = currentTarget;
				var handler = cast(currentTarget, IBubbleEventHandler<Dynamic>);

				// onEventBubbled() can stop the bubbling by returning false.
				if (!handler.onEventBubbled(event)) break;
			}
		}
	}
}

interface IBubbleEventHandler<TEvent>
{
	function onEventBubbled(event:TEvent):Bool; 
}
