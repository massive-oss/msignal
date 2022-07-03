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
import msignal.Signal;
import msignal.EventSignal;

typedef DynamicEvent = Event<Dynamic, Dynamic>;

class SignalTest
{
	public function new() {}

	var signal0:Signal0;
	var signal1:Signal1<Dynamic>;
	var signal2:Signal2<Dynamic, Dynamic>;
	var verifiableHandlerCalled:Bool;

	@Before
	public function setup():Void 
	{
		signal0 = new Signal0();
		signal1 = new Signal1<Dynamic>(Dynamic);
		signal2 = new Signal2<Dynamic, Dynamic>(Dynamic, Dynamic);
		verifiableHandlerCalled = false;
	}
	
	@After
	public function tearDown():Void 
	{
		signal0.removeAll();
		signal1.removeAll();
		signal2.removeAll();
		signal0 = null;
		signal1 = null;
		signal2 = null;
		verifiableHandlerCalled = false;
	}
	
	@Test
	public function numListeners_is_0_after_creation():Void
	{
		Assert.areEqual(0, signal0.numListeners);
	}
	
	@Test
	public function addOnce_and_dispatch_should_remove_listener_automatically():Void
	{
		signal0.addOnce(newEmptyHandler());
		dispatchSignal();
		Assert.areEqual(0, signal0.numListeners);//'there should be no listeners'
	}

	@Test
	public function add_listener_then_remove_then_dispatch_should_not_call_listener():Void
	{
		signal0.add(failIfCalled);
		signal0.remove(failIfCalled);
		dispatchSignal();
		Assert.isTrue(true);
	}

	@Test
	public function add_listener_then_remove_function_not_in_listeners_should_do_nothing():Void
	{
		signal0.add(newEmptyHandler());
		signal0.remove(newEmptyHandler());
		Assert.areEqual(1, signal0.numListeners);
	}

	@Test
	public function add_2_listeners_remove_2nd_then_dispatch_should_call_1st_not_2nd_listener():Void
	{
		var called = false;
		signal0.add(function(){ called = true; });
		signal0.add(failIfCalled);
		signal0.remove(failIfCalled);
		dispatchSignal();
		Assert.isTrue(called);
	}
	@Test
	public function add_2_listeners_should_yield_numListeners_of_2():Void
	{
		signal0.add(newEmptyHandler());
		signal0.add(newEmptyHandler());
		Assert.areEqual(2, signal0.numListeners);
	}

	@Test
	public function add_2_listeners_then_remove_1_should_yield_numListeners_of_1():Void
	{
		var firstFunc = newEmptyHandler();
		signal0.add(firstFunc);
		signal0.add(newEmptyHandler());
		signal0.remove(firstFunc);
		
		Assert.areEqual(1, signal0.numListeners);
	}

	@Test
	public function add_2_listeners_then_removeAll_should_yield_numListeners_of_0():Void
	{
		signal0.add(newEmptyHandler());
		signal0.add(newEmptyHandler());
		signal0.removeAll();
		Assert.areEqual(0, signal0.numListeners);
	}
	
	@Test
	public function add_same_listener_twice_should_only_add_it_once():Void
	{
		var func = newEmptyHandler();
		signal0.add(func);
		signal0.add(func);
		Assert.areEqual(1, signal0.numListeners);
	}

	@Test
	public function addOnce_same_listener_twice_should_only_add_it_once():Void
	{
		var func = newEmptyHandler();
		signal0.addOnce(func);
		signal0.addOnce(func);
		Assert.areEqual(1, signal0.numListeners);
	}

	@Test
	public function add_two_listeners_and_dispatch_should_call_both():Void
	{
		var calledA = false;
		var calledB = false;
		signal0.add(function() { calledA = true; });
		signal0.add(function() { calledB = true; });
		dispatchSignal();
		Assert.isTrue(calledA);
		Assert.isTrue(calledB);
	}

	@Test
	public function add_the_same_listener_twice_should_not_throw_error():Void
	{
		var listener = newEmptyHandler();
		signal0.add(listener);
		signal0.add(listener);
		Assert.isTrue(true);
	}

	@Test
	public function dispatch_2_listeners_1st_listener_removes_itself_then_2nd_listener_is_still_called():Void
	{
		signal0.add(selfRemover);
		signal0.add(verifiableHandler);
		dispatchSignal();
		Assert.isTrue(verifiableHandlerCalled);
	}

	function selfRemover():Void
	{
		signal0.remove(selfRemover);
	}

	@Test
	public function dispatch_2_listeners_1st_listener_removes_all_then_2nd_listener_is_still_called():Void
	{
		signal0.add(allRemover);
		signal0.add(verifiableHandler);
		dispatchSignal();
		Assert.isTrue(verifiableHandlerCalled);
	}

	function allRemover():Void
	{
		signal0.removeAll();
	}

	@Test
	public function adding_a_listener_during_dispatch_should_not_call_it():Void
	{
		signal0.add(addListenerDuringDispatch);
		dispatchSignal();
		Assert.isFalse(verifiableHandlerCalled);
	}
	
	function addListenerDuringDispatch():Void
	{
		signal0.add(verifiableHandler);
	}

	@Test
	public function can_use_anonymous_listeners():Void
	{
		var slots = [];
		
		for (i in 0...10)
		{
			slots.push(signal0.add(newEmptyHandler()));
		}

		Assert.areEqual(10, signal0.numListeners);//"there should be 10 listeners"

		for (slot in slots)
		{
			signal0.remove(slot.listener);
		}

		Assert.areEqual(0, signal0.numListeners);//"all anonymous listeners removed"
	}
	
	@Test
	public function can_use_anonymous_listeners_in_addOnce():Void
	{
		var slots = [];
		
		for (i in 0...10)
		{
			slots.push(signal0.addOnce(newEmptyHandler()));
		}

		Assert.areEqual(10, signal0.numListeners);//"there should be 10 listeners"

		for (slot in slots)
		{
			signal0.remove(slot.listener);
		}

		Assert.areEqual(0, signal0.numListeners);//"all anonymous listeners removed"
	}

	@Test
	public function add_listener_returns_slot_with_same_listener():Void
	{
		var listener = newEmptyHandler();
		var slot = signal0.add(listener);
		Assert.areEqual(listener, slot.listener);
	}
	
	@Test
	public function remove_listener_returns_same_slot_as_when_it_was_added():Void
	{
		var listener = newEmptyHandler();
		var slot = signal0.add(listener);
		Assert.areEqual(slot, signal0.remove(listener));
	}

	@Test
	public function dispatch_should_pass_event_to_listener_but_not_set_signal_or_target_properties():Void
	{
		signal1.add(checkGenericEvent);
		signal1.dispatch(new DynamicEvent(null));
		Assert.isTrue(verifiableHandlerCalled);
	}
	
	function checkGenericEvent(event:DynamicEvent):Void
	{
		Assert.isNull(event.signal); // event.signal is not set by Signal
		Assert.isNull(event.target); // event.target is not set by Signal
		verifiableHandlerCalled = true;
	}
	
	@Test
	public function dispatch_non_Event_without_error():Void
	{
		signal1.addOnce(checkDate);

		// Date doesn't have a target property,
		// so if the signal tried to set .target,
		// an error would be thrown and this test would fail.
		signal1.dispatch(Date.now());
	}
	
	function checkDate(date:Date):Void
	{
		Assert.isTrue(Std.isOfType(date, Date));
	}
	
	@Test
	public function adding_dispatch_method_as_listener_does_not_throw_error():Void
	{
		Assert.isTrue(true);
		var redispatchSignal = new Signal1<DynamicEvent>(DynamicEvent);
		signal1 = new Signal1<DynamicEvent>(DynamicEvent);
		signal1.add(redispatchSignal.dispatch);
	}

	static var PARAM1 = 12345;
	static var PARAM2 = "text";

	@Test
	public function slot_params_should_be_sent_through_to_listener():Void
	{
		var slot = signal2.add(checkParams);
		slot.param1 = PARAM1;
		slot.param2 = PARAM2;
		signal2.dispatch(null, null);
		Assert.isTrue(verifiableHandlerCalled);
	}

	function checkParams(number:Int, string:String):Void
	{
		Assert.areEqual(number, PARAM1);
		Assert.areEqual(string, PARAM2);
		verifiableHandlerCalled = true;
	}

	var order:Array<Int>;

	@Test
	public function add_with_priority_dispatches_listeners_in_right_order_when_added_in_wrong_order()
	{
		order = [];

		signal0.addWithPriority(item0, 0);
		signal0.addWithPriority(item1, 1);
		signal0.addWithPriority(item2, 2);
		signal0.dispatch();

		Assert.areEqual(2, order[0]);
		Assert.areEqual(1, order[1]);
		Assert.areEqual(0, order[2]);
	}

    @Test
    public function add_with_same_no_priority_dispatches_order()
    {
        order = [];

        signal0.add(item0);
        signal0.add(item1);
        signal0.add(item2);
        signal0.dispatch();

        assertLastAddedFirstDispatched();
    }

    @Test
    public function add_with_same_priority_dispatches_in_same_order_as_no_priority()
    {
        order = [];

        signal0.addWithPriority(item0, 1);
        signal0.addWithPriority(item1, 1);
        signal0.addWithPriority(item2, 1);
        signal0.dispatch();

        assertLastAddedFirstDispatched();
    }

	@Test
	public function add_with_priority_dispatches_listeners_in_right_order_when_added_in_right_order()
	{
		order = [];
		
		signal0.addWithPriority(item2, 2);
		signal0.addWithPriority(item1, 1);
		signal0.addWithPriority(item0, 0);
		signal0.dispatch();
		
		Assert.areEqual(2, order[0]);
		Assert.areEqual(1, order[1]);
		Assert.areEqual(0, order[2]);
	}

	@Test
	public function add_once_with_priority_dispatches_listeners_in_right_order_when_added_in_wrong_order()
	{
		order = [];

		signal0.addOnceWithPriority(item0, 0);
		signal0.addOnceWithPriority(item1, 1);
		signal0.addOnceWithPriority(item2, 2);
		signal0.dispatch();
		
		Assert.areEqual(2, order[0]);
		Assert.areEqual(1, order[1]);
		Assert.areEqual(0, order[2]);
	}

	function item0(){order.push(0);}
	function item1(){order.push(1);}
	function item2(){order.push(2);}

	@Test
	public function add_then_add_once_throws_exception()
	{
		var threw = false;
		signal0.add(verifiableHandler);
		
		try
		{
			signal0.addOnce(verifiableHandler);
		}
		catch (e:Dynamic)
		{
			threw = true;
		}

		Assert.isTrue(threw);
	}

	// helper

    function assertLastAddedFirstDispatched():Void {
        Assert.areEqual(2, order[0]);
        Assert.areEqual(1, order[1]);
        Assert.areEqual(0, order[2]);
    }
	
	function dispatchSignal():Void 
	{
		signal0.dispatch();
	}

	static function newEmptyHandler():Dynamic
	{
		// neko work around, see: http://code.google.com/p/nekovm/issues/detail?id=4
		var n = 0;
		return function(){n;};
	}

	function verifiableHandler()
	{
		verifiableHandlerCalled = true;
	}

	static function failIfCalled():Void
	{
		Assert.fail("This function should not have been called.");
	}
}
