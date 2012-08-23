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

import massive.munit.Assert;
import msignal.EventSignal;

class EventSignalStringTest
{
	public static inline var STARTED:String = "started";
	public static inline var COMPLETED:String = "completed";
	
	public function new() {}

	var target:MyTarget;
	var signal:EventSignal<MyTarget, String>;

	@Before
	public function before()
	{
		target = new MyTarget();
		signal = new EventSignal(target);
	}

	@After
	public function after()
	{
		signal = null;
	}

	@Test
	public function bubble_sets_event_target()
	{
		var event = new Event(STARTED);
		signal.bubble(event);
		Assert.isTrue(event.target == target);
	}

	@Test
	public function add_for_type_filters_events_on_type()
	{
		var startedDispatched = false;
		var completedDispatched = false;

		signal.add(function(e){
			startedDispatched = true;
		}).forType(STARTED);

		signal.add(function(e){
			completedDispatched = true;
		}).forType(COMPLETED);

		signal.dispatchType(STARTED);
		Assert.isTrue(startedDispatched);
		Assert.isFalse(completedDispatched);
	}

	@Test function remove_for_type_removes_listener()
	{
		var startedDispatched = false;
		var listener = function(e){
			startedDispatched = true;
		}
		signal.add(listener).forType(STARTED);
		signal.remove(listener);
		signal.dispatchType(COMPLETED);
		Assert.isFalse(startedDispatched);
	}

	@Test function add_once_for_type_removes_after_dispatch()
	{
		var startedDispatched = 0;
		var listener = function(e){
			startedDispatched += 1;
		}
		signal.addOnce(listener).forType(STARTED);
		signal.bubbleType(STARTED);
		signal.bubbleType(STARTED);
		Assert.areEqual(1, startedDispatched);
	}

	@Test function add_once_for_type_does_not_remove_for_other_types()
	{
		var startedDispatched = 0;
		var listener = function(e){
			startedDispatched += 1;
		}
		signal.addOnce(listener).forType(STARTED);
		signal.bubbleType(COMPLETED);
		signal.bubbleType(STARTED);
		Assert.areEqual(1, startedDispatched);
	}
}

private class MyTarget
{
	public function new(){}
}

