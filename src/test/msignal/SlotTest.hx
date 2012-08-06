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
import massive.munit.async.AsyncFactory;
import msignal.Signal;
import msignal.Slot;
import msignal.EventSignal;

class SlotTest
{
	public var signal:Signal0;
	public var signal1:Signal1<Int>;
	public var signal2:Signal2<Int, Int>;
	public var verifiableHandlerCalled:Bool;

	@Before
	public function setup():Void
	{
		signal = new Signal0();
		signal1 = new Signal1<Int>(Int);
		signal2 = new Signal2<Int, Int>(Int, Int);
		verifiableHandlerCalled = false;
	}

	@After
	public function tearDown():Void
	{
		signal.removeAll();
		signal1.removeAll();
		signal2.removeAll();
		signal = null;
		signal1 = null;
		signal2 = null;
		verifiableHandlerCalled = false;
	}
	
	function dispatchSignal()
	{
		signal.dispatch();
	}

	function checkGenericEvent(event:Event<Dynamic, Dynamic>):Void
	{
		Assert.isNull(event.signal);//'event.signal is not set by Signal'
		Assert.isNull(event.target);//'event.target is not set by Signal'
	}
	
	@Test
	public function add_listener_pause_on_slot_should_not_dispatch():Void
	{
		var slot = signal.add(failIfCalled);
		slot.enabled = false;
		
		dispatchSignal();
		emptyAssert();
	}
			
	@Test
	public function add_listener_switch_pause_and_resume_on_slot_should_not_dispatch():Void
	{
		var slot = signal.add(failIfCalled);
		slot.enabled = false;
		slot.enabled = true;
		slot.enabled = false;
		
		dispatchSignal();
		emptyAssert();	
	}
	
	@Test
	public function add_listener_then_dispatch_change_listener_on_slot_should_dispatch_second_listener():Void
	{
		var slot = signal.add(newEmptyHandler());
		
		dispatchSignal();
		
		slot.listener = verifiableHandler;
		
		dispatchSignal();
		Assert.isTrue(verifiableHandlerCalled);
	}
	
	@Test
	public function add_listener_then_dispatch_change_listener_on_slot_then_pause_should_not_dispatch_second_listener():Void
	{
		var slot = signal.add(newEmptyHandler());
		
		dispatchSignal();
		
		slot.listener = failIfCalled;
		slot.enabled = false;
		
		dispatchSignal();		
	}
	
	@Test
	public function add_listener_then_change_listener_then_switch_back_and_then_should_dispatch():Void
	{
		var slot = signal.add(verifiableHandler);
		var listener = slot.listener;
		
		slot.listener = failIfCalled;
		slot.listener = listener;
		
		dispatchSignal();
		Assert.isTrue(verifiableHandlerCalled);
	}
	
	@Test
	public function addOnce_listener_pause_on_slot_should_not_dispatch():Void
	{
		var slot = signal.addOnce(failIfCalled);
		slot.enabled = false;
		
		dispatchSignal();
		emptyAssert();
	}
	
	@Test
	public function addOnce_listener_switch_pause_and_resume_on_slot_should_not_dispatch():Void
	{
		var slot = signal.addOnce(failIfCalled);
		slot.enabled = false;
		slot.enabled = true;
		slot.enabled = false;
		
		dispatchSignal();
		emptyAssert();
	}
	
	@Test
	public function addOnce_listener_then_dispatch_change_listener_on_slot_should_not_dispatch_second_listener():Void
	{
		var slot = signal.addOnce(newEmptyHandler());
		
		dispatchSignal();
		slot.listener = failIfCalled;
		
		dispatchSignal();
		emptyAssert();
	}
	
	@Test
	public function addOnce_listener_then_dispatch_change_listener_on_slot_then_pause_should_not_dispatch_second_listener():Void
	{
		var slot = signal.addOnce(newEmptyHandler());
		
		dispatchSignal();
		
		slot.listener = failIfCalled;
		slot.enabled = false;
		
		dispatchSignal();
		emptyAssert();
	}
	
	@Test
	public function addOnce_listener_then_change_listener_then_switch_back_and_then_should_dispatch():Void
	{
		var slot = signal.addOnce(verifiableHandler);
		
		slot.listener = failIfCalled;
		slot.listener = verifiableHandler;
		
		dispatchSignal();
		Assert.isTrue(verifiableHandlerCalled);
	}
	
	@Test
	public function add_listener_and_verify_once_is_false():Void
	{
		var listener = newEmptyHandler();
		var slot = signal.add(listener);
		
		Assert.isFalse(slot.once);//'Slot once is false'
	}
	
	@Test
	public function add_listener_and_verify_priority_is_zero():Void
	{
		var listener = newEmptyHandler();
		var slot = signal.add(listener);
		
		Assert.isTrue(slot.priority == 0);//'Slot priority is zero'
	}
	
	@Test
	public function add_listener_and_verify_slot_listener_is_same():Void
	{
		var listener = newEmptyHandler();
		var slot = signal.add(listener);
		
		Assert.isTrue(Reflect.compareMethods(slot.listener, listener));//'Slot listener is the same as the listener'
	}
		
	@Test
	public function add_same_listener_twice_and_verify_slots_are_the_same():Void
	{
		var listener = newEmptyHandler();
		var slot0 = signal.add(listener);
		var slot1 = signal.add(listener);
		
		Assert.isTrue(slot0 == slot1);//'Slots are equal if they have the same listener'
	}
	
	@Test
	public function add_same_listener_twice_and_verify_slot_listeners_are_the_same():Void
	{
		var listener = newEmptyHandler();
		var slot0 = signal.add(listener);
		var slot1 = signal.add(listener);
		
		Assert.isTrue(Reflect.compareMethods(slot0.listener, slot1.listener));//'Slot listener is the same as the listener'
	}
	
	@Test
	public function add_listener_and_remove_using_slot():Void
	{
		var slot = signal.add(newEmptyHandler());
		slot.remove();
		
		Assert.isTrue(signal.numListeners == 0);//'Number of listeners should be 0'
	}
	
	@Test
	public function add_same_listener_twice_and_remove_using_slot_should_have_no_listeners():Void
	{
		var listener = newEmptyHandler();
		var slot0 = signal.add(listener);
		signal.add(listener);
		
		slot0.remove();
		
		Assert.isTrue(signal.numListeners == 0);//'Number of listeners should be 0'
	}
	
	@Test
	public function add_lots_of_same_listener_and_remove_using_slot_should_have_no_listeners():Void
	{
		var listener = newEmptyHandler();
		var slot = null;

		for (i in 0...10)
		{
			slot = signal.add(listener);
		}
		
		slot.remove();
		
		Assert.isTrue(signal.numListeners == 0);//'Number of listeners should be 0'
	}
	
	@Test
	public function add_listener_then_set_listener_to_null_should_throw_ArgumentError():Void
	{
		try
		{
			var slot = signal.add(newEmptyHandler());
			slot.listener = null;
			Assert.fail("should have thrown error");
		}
		catch (e:Dynamic)
		{
			emptyAssert();
		}
		
	}
		
	@Test
	public function add_listener_and_call_execute_on_slot_should_call_listener():Void
	{
		var slot = signal.add(verifiableHandler);
		slot.execute();
		Assert.isTrue(verifiableHandlerCalled);
	}
	
	@Test
	public function add_listener_twice_and_call_execute_on_slot_should_call_listener_and_not_on_signal_listeners():Void
	{
		signal.add(failIfCalled);
		
		var slot = signal.add(newEmptyHandler());
		slot.execute();
	}
	
	@Test
	public function addOnce_listener_and_verify_once_is_true():Void
	{
		var listener = newEmptyHandler();
		var slot = signal.addOnce(listener);
		
		Assert.isTrue(slot.once == true);//'Slot once is true'
	}
	
	@Test
	public function addOnce_listener_and_verify_priority_is_zero():Void
	{
		var listener = newEmptyHandler();
		var slot = signal.addOnce(listener);
		
		Assert.isTrue(slot.priority == 0);//'Slot priority is zero'
	}
	
	@Test
	public function addOnce_listener_and_verify_slot_listener_is_same():Void
	{
		var listener = newEmptyHandler();
		var slot = signal.addOnce(listener);
		
		Assert.isTrue(Reflect.compareMethods(slot.listener, listener));//'Slot listener is the same as the listener'
	}
			
	@Test
	public function addOnce_same_listener_twice_and_verify_slots_are_the_same():Void
	{
		var listener = newEmptyHandler();
		var slot0 = signal.addOnce(listener);
		var slot1 = signal.addOnce(listener);
		
		Assert.isTrue(slot0 == slot1);//'Slots are equal if they\'re they have the same listener'
	}
	
	@Test
	public function addOnce_same_listener_twice_and_verify_slot_listeners_are_the_same():Void
	{
		var listener = newEmptyHandler();
		var slot0 = signal.addOnce(listener);
		var slot1 = signal.addOnce(listener);
		
		Assert.isTrue(Reflect.compareMethods(slot0.listener, slot1.listener));//'Slot listener is the same as the listener'
	}
	
	@Test
	public function addOnce_listener_and_remove_using_slot():Void
	{
		var slot = signal.addOnce(newEmptyHandler());
		slot.remove();
		
		Assert.isTrue(signal.numListeners == 0);//'Number of listeners should be 0'
	}
	
	@Test
	public function addOnce_same_listener_twice_and_remove_using_slot_should_have_no_listeners():Void
	{
		var listener = newEmptyHandler();
		var slot0 = signal.addOnce(listener);
		signal.addOnce(listener);
		
		slot0.remove();
		
		Assert.isTrue(signal.numListeners == 0);//'Number of listeners should be 0'
	}
	
	@Test
	public function addOnce_lots_of_same_listener_and_remove_using_slot_should_have_no_listeners():Void
	{
		var listener = newEmptyHandler();
		var slot = null;

		for (i in 0...10)
		{
			slot = signal.addOnce(listener);
		}
		
		slot.remove();
		
		Assert.isTrue(signal.numListeners == 0);//'Number of listeners should be 0'
	}
	
	@Test
	public function addOnce_listener_then_set_listener_to_null_should_throw_ArgumentError():Void
	{
		try
		{
			var slot = signal.addOnce(newEmptyHandler());
			slot.listener = null;
			Assert.fail("should have thrown error");
		}
		catch (e:Dynamic)
		{
			Assert.isTrue(true);
		}
		
	}
			
	@Test
	public function addOnce_listener_and_call_execute_on_slot_should_call_listener():Void
	{
		var slot = signal.addOnce(verifiableHandler);
		slot.execute();
		Assert.isTrue(verifiableHandlerCalled);
	}
	
	@Test
	public function addOnce_listener_twice_and_call_execute_on_slot_should_call_listener_and_not_on_signal_listeners():Void
	{
		signal.addOnce(failIfCalled);
		
		var slot = signal.addOnce(verifiableHandler);
		slot.execute();

		Assert.isTrue(verifiableHandlerCalled);
	}
	
	@Test
	public function slot_params_are_null_when_created():Void
	{
		var slot1 = signal1.add(function(a){});
		var slot2 = signal2.add(function(a, b){});

		Assert.isNull(slot1.param);
		Assert.isNull(slot2.param1);
		Assert.isNull(slot2.param2);
	}
	
	@Test
	public function slot_params_should_not_be_null_after_adding_array():Void
	{
		var slot1 = signal1.add(function(a){});
		var slot2 = signal2.add(function(a, b){});

		slot1.param = 1;
		slot2.param1 = 1;
		slot2.param2 = 1;

		Assert.isNotNull(slot1.param);
		Assert.isNotNull(slot2.param1);
		Assert.isNotNull(slot2.param2);

		slot1.execute(0);
		slot2.execute(0, 0);
	}

	@Test
	public function slot2_removed_when_once_is_true():Void
	{
		var slot2 = signal2.addOnce(function(a, b){});
		Assert.areEqual(1, signal2.numListeners);
		slot2.execute(1, 2);
		Assert.areEqual(0, signal2.numListeners);
	}
	
	@Test
	public function slot_params_with_one_param_should_be_sent_through_to_listener():Void
	{
		var listener = function(a)
		{ 
			Assert.areEqual(10, a);
		};

		var slot = signal1.add(listener);
		slot.param = 10;

		signal1.dispatch(0);
	}

	@Test
	public function slot1_does_not_dispatch_when_not_enabled()
	{
		var slot = signal1.add(function(a){ Assert.fail("Slot should not have dispatched!"); });
		slot.enabled = false;
		slot.execute(1);
		Assert.isTrue(true);
	}

	@Test
	public function slot2_does_not_dispatch_when_not_enabled()
	{
		var slot = signal2.add(function(a, b){ Assert.fail("Slot should not have dispatched!"); });
		slot.enabled = false;
		slot.execute(1,2);
		Assert.isTrue(true);
	}
	
	/*
	@Test
	public function slot_params_with_multiple_params_should_be_sent_through_to_listener():Void
	{
		var listener = function(e:Event, ...args):Void
								{ 
									assertNotNull(e);
										
									Assert.isTrue(args[0] is int);
									assertEquals(args[0], 12345);
									
									Assert.isTrue(args[1] is String);
									assertEquals(args[1], 'text');
									
									Assert.isTrue(args[2] is Sprite);
									assertEquals(args[2], slot.params[2]);
								};

		var slot = signal.add(listener);
		slot.params = [12345, 'text', new Sprite()];

		signal.dispatch(new MouseEvent('click'));
	}
	
	@Test
	public function slot_params_should_not_effect_other_slots():Void
	{
		var listener0 = function(e:Event):Void
								{ 
									assertNotNull(e);
									
									assertEquals(arguments.length, 1);
								};
		
		signal.add(listener0);
		
		var listener1 = function(e:Event):Void
								{ 
									assertNotNull(e);
									
									assertEquals(arguments.length, 2);
									assertEquals(arguments[1], 123456);
								};
		
		var slot = signal.add(listener1);
		slot.params = [123456];
		
		signal.dispatch(new MouseEvent('click'));
	}
	
	@Test
	public function verify_chaining_of_slot_params():Void
	{
		var listener = function(e:Event, ...args):Void
								{ 
									assertNotNull(e);
									
									assertEquals(args.length, 1);
									assertEquals(args[0], 1234567);
								};
		
		signal.add(listener).params = [1234567];
					
		signal.dispatch(new MouseEvent('click'));
	}
	
	@Test
	public function verify_chaining_and_concat_of_slot_params():Void
	{
		var listener = function(e:Event, ...args):Void
								{ 
									assertNotNull(e);
									
									assertEquals(args.length, 2);
									assertEquals(args[0], 12345678);
									assertEquals(args[1], 'text');
								};
		
		signal.add(listener).params = [12345678].concat(['text']);
					
		signal.dispatch(new MouseEvent('click'));
	}
	
	
	@Test
	public function verify_chaining_and_pushing_on_to_slot_params():Void
	{
		var listener = function(e:Event, ...args):Void
								{ 
									assertNotNull(e);
									
									assertEquals(args.length, 2);
									assertEquals(args[0], 123456789);
									assertEquals(args[1], 'text');
								};
		
		// This is ugly, but I put money on somebody will attempt to do this!
		var slots;
		(slots = signal.add(listener)).params = [123456789];
		slots.params.push('text');
		
		signal.dispatch(new MouseEvent('click'));
	}
	*/				
	
	function verifiableHandler()
	{
		verifiableHandlerCalled = true;
	}

	static function newEmptyHandler():Dynamic
	{
		// neko work around, see: http://code.google.com/p/nekovm/issues/detail?id=4
		var n = 0;
		return function(){n;};
	}

	static function failIfCalled():Void
	{
		Assert.fail("This function should not have been called.");
	}

	static function emptyAssert():Void
	{
		Assert.isTrue(true);
	}
}
