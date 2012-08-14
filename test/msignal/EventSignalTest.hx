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

class EventSignalTest
{
	public function new() {}

	var target:MyTarget;
	var signal:EventSignal<MyTarget, MyEventType>;

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
		var event = new Event(started);
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
		}).forType(started);

		signal.add(function(e){
			completedDispatched = true;
		}).forType(completed);

		signal.dispatchType(started);
		Assert.isTrue(startedDispatched);
		Assert.isFalse(completedDispatched);
	}

	@Test function remove_for_type_removes_listener()
	{
		var startedDispatched = false;
		var listener = function(e){
			startedDispatched = true;
		}
		signal.add(listener).forType(started);
		signal.remove(listener);
		signal.dispatchType(completed);
		Assert.isFalse(startedDispatched);
	}

	@Test function add_once_for_type_removes_after_dispatch()
	{
		var startedDispatched = 0;
		var listener = function(e){
			startedDispatched += 1;
		}
		signal.addOnce(listener).forType(started);
		signal.bubbleType(started);
		signal.bubbleType(started);
		Assert.areEqual(1, startedDispatched);
	}

	@Test function add_once_for_type_does_not_remove_for_other_types()
	{
		var startedDispatched = 0;
		var listener = function(e){
			startedDispatched += 1;
		}
		signal.addOnce(listener).forType(started);
		signal.bubbleType(completed);
		signal.bubbleType(started);
		Assert.areEqual(1, startedDispatched);
	}

	@Test
	public function add_for_type_with_params_filters_events_on_type_and_params()
	{
		var progressDispatchedCount = 0;

		signal.add(function(e){
			progressDispatchedCount ++;
		}).forType(progressed(0));

		signal.progressDispatchedCount(function(e){
			changedCount ++;
		}).forType(progressed(1);

		signal.dispatchType(progressed(1));
		Assert.areEqual(1, progressDispatchedCount);
	}

	@Test
	public function add_for_type_with_null_params_filters_events_on_type_only()
	{
		var progressDispatchedCount = 0;

		signal.add(function(e){
			progressDispatchedCount ++;
		}).forType(progressed(null));

		signal.add(function(e){
			progressDispatchedCount ++;
		}).forType(progressed(null);

		signal.dispatchType(progressed(1));
		Assert.areEqual(2, progressDispatchedCount);
	}

}

class MyTarget
{
	public function new(){}
}

enum MyEventType
{
	started;
	progressed(value:Float);
	completed;
}
