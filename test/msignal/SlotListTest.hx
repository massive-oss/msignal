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

typedef Listener = Void -> Void;
typedef Slot0List = SlotList<Slot0, Listener>;

class SlotListTest
{
	var signal:Signal0;

	var listenerA:Listener;
	var listenerB:Listener;
	var listenerC:Listener;

	var slotA:Slot0;
	var slotB:Slot0;
	var slotC:Slot0;

	var listOfA:Slot0List;
	var listOfAB:Slot0List;
	var listOfABC:Slot0List;

	@Before
	public function setUp():Void
	{
		signal = new Signal0();
		listenerA = function(){};
		listenerB = function(){};
		listenerC = function(){};
		slotA = new Slot0(signal, listenerA);
		slotB = new Slot0(signal, listenerB);
		slotC = new Slot0(signal, listenerC);
		listOfA = new Slot0List(slotA);
		listOfAB = listOfA.append(slotB);
		listOfABC = listOfAB.append(slotC);
	}

	@Test
	public function NIL_has_length_zero():Void
	{
		Assert.areEqual(0, SlotList.NIL.length);
	}

	@Test
	public function tail_defaults_to_NIL_if_omitted_in_constructor():Void
	{
		var noTail = new Slot0List(slotA);
		assertSame(SlotList.NIL, noTail.tail);
	}

	@Test
	public function tail_defaults_to_NIL_if_passed_null_in_constructor():Void
	{
		var nullTail = new Slot0List(slotA, null);
		assertSame(SlotList.NIL, nullTail.tail);
	}

	@Test // expects error
	public function constructing_with_null_head_throws_error():Void
	{
		try
		{
			new Slot0List(null, listOfA);
			Assert.fail("should have throw error");
		}
		catch (e:Dynamic)
		{
			Assert.isTrue(true);
		}
	}

	@Test
	public function list_with_one_listener_contains_it():Void
	{
		Assert.isTrue(listOfA.contains(listenerA));
	}

	@Test
	public function find_the_only_listener_yields_its_slot():Void
	{
		assertSame(slotA, listOfA.find(listenerA));
	}

	@Test
	public function list_with_one_listener_has_it_in_its_head():Void
	{
		assertSame(listenerA, listOfA.head.listener);
	}

	@Test
	public function NIL_does_not_contain_anonymous_listener():Void
	{
		Assert.isFalse(SlotList.NIL.contains(function():Void {}));
	}

	@Test
	public function find_in_empty_list_yields_null():Void
	{
		Assert.isNull(SlotList.NIL.find(listenerA));
	}		

	@Test
	public function NIL_does_not_contain_null_listener():Void
	{
		Assert.isFalse(SlotList.NIL.contains(null));
	}

	@Test
	public function find_the_1st_of_2_listeners_yields_its_slot():Void
	{
		assertSame(slotA, listOfAB.find(listenerA));
	}		

	@Test
	public function find_the_2nd_of_2_listeners_yields_its_slot():Void
	{
		assertSame(slotB, listOfAB.find(listenerB));
	}	

	@Test
	public function find_the_1st_of_3_listeners_yields_its_slot():Void
	{
		assertSame(slotA, listOfABC.find(listenerA));
	}	

	@Test
	public function find_the_2nd_of_3_listeners_yields_its_slot():Void
	{
		assertSame(slotB, listOfABC.find(listenerB));
	}	

	@Test
	public function find_the_3rd_of_3_listeners_yields_its_slot():Void
	{
		assertSame(slotC, listOfABC.find(listenerC));
	}	

	@Test
	public function prepend_a_slot_makes_it_head_of_new_list():Void
	{
		var newList = listOfA.prepend(slotB);
		assertSame(slotB, newList.head);
	}

	@Test
	public function prepend_a_slot_makes_the_old_list_the_tail():Void
	{
		var newList = listOfA.prepend(slotB);
		assertSame(listOfA, newList.tail);
	}

	@Test
	public function after_prepend_slot_new_list_contains_its_listener():Void
	{
		var newList = listOfA.prepend(slotB);
		Assert.isTrue(newList.contains(slotB.listener));
	}

	@Test
	public function append_a_slot_yields_new_list_with_same_head():Void
	{
		var oldHead = listOfA.head;
		var newList = listOfA.append(slotB);
		assertSame(oldHead, newList.head);
	}

	@Test
	public function append_to_list_of_one_yields_list_of_length_two():Void
	{
		var newList = listOfA.append(slotB);
		Assert.areEqual(2, newList.length);
	}

	@Test
	public function after_append_slot_new_list_contains_its_listener():Void
	{
		var newList = listOfA.append(slotB);
		Assert.isTrue(newList.contains(slotB.listener));
	}

	@Test
	public function append_slot_yields_a_different_list():Void
	{
		var newList = listOfA.append(slotB);
		assertNotSame(listOfA, newList);
	}

	@Test
	public function append_null_yields_same_list():Void
	{
		var newList = listOfA.append(null);
		assertSame(listOfA, newList);
	}

	@Test
	public function filterNot_on_empty_list_yields_same_list():Void
	{
		var newList = SlotList.NIL.filterNot(listenerA);
		assertSame(SlotList.NIL, newList);
	}

	@Test
	public function filterNot_null_yields_same_list():Void
	{
		var newList = listOfA.filterNot(null);
		assertSame(listOfA, newList);
	}

	@Test
	public function filterNot_head_from_list_of_1_yields_empty_list():Void
	{
		var newList = listOfA.filterNot(listOfA.head.listener);
		assertSame(SlotList.NIL, newList);
	}

	@Test
	public function filterNot_1st_listener_from_list_of_2_yields_list_of_2nd_listener():Void
	{
		var newList = listOfAB.filterNot(listenerA);
		assertSame(listenerB, newList.head.listener);
		Assert.areEqual(1, newList.length);
	}	

	@Test
	public function filterNot_2nd_listener_from_list_of_2_yields_list_of_head():Void
	{
		var newList = listOfAB.filterNot(listenerB);
		assertSame(listenerA, newList.head.listener);
		Assert.areEqual(1, newList.length);
	}

	@Test
	public function filterNot_2nd_listener_from_list_of_3_yields_list_of_1st_and_3rd():Void
	{
		var newList = listOfABC.filterNot(listenerB);
		assertSame(listenerA, newList.head.listener);
		assertSame(listenerC, newList.tail.head.listener);
		Assert.areEqual(2, newList.length);
	}

	@Test
	public function create_with_null_head_and_tail_throws_exception()
	{
		var threw = false;

		try
		{
			new SlotList(null, null);
		}
		catch (e:Dynamic)
		{
			threw = true;
		}

		Assert.isTrue(threw);
	}

	@Test
	public function create_with_null_head_throws_exception()
	{
		var threw = false;

		try
		{
			new SlotList(null, SlotList.NIL);
		}
		catch (e:Dynamic)
		{
			threw = true;
		}

		Assert.isTrue(threw);
	}

	@Test
	public function recreate_nil_list()
	{
		SlotList.NIL = null;
		SlotList.NIL = new SlotList(null, null);
		Assert.isNotNull(SlotList.NIL);
	}

	@Test
	public function append_to_nil()
	{
		var slot = new Slot0(signal, listenerB);
		var list = SlotList.NIL.append(slot);
		Assert.areEqual(slot, list.head);
		Assert.areEqual(SlotList.NIL, list.tail);
	}

	@Test
	public function contains_returns_false_when_list_does_not_contain_listener()
	{
		Assert.isFalse(listOfA.contains(listenerC));
	} 

	@Test
	public function find_returns_null_when_list_does_not_contain_listener()
	{
		Assert.isNull(listOfA.find(listenerC));
	}

	@Test
	public function filter_not_returns_original_when_list_does_not_container_listener()
	{
		Assert.areEqual(listOfA, listOfA.filterNot(listenerC));
	}

	@Test
	public function filter_not_does_nothing()
	{
		Assert.areEqual(listOfABC, listOfABC.filterNot(function(){}));
	} 

	inline function assertSame(a:Dynamic, b:Dynamic)
	{
		Assert.areEqual(a, b);
	}

	inline function assertNotSame(a:Dynamic, b:Dynamic)
	{
		Assert.areNotEqual(a, b);
	}
}