## Overview

Signals are highly scalable and lightweight alternative to Events.

`msignal.Signal` is a type safe port of Robert Penner’s AS3 Signals leveraging Haxe generics.

Benefits:

* Avoids costly native event bubbling on different platforms (e.g. HTML DOM events) that impact performance
* Type safe signature for dispatching and observer handlers
* Typing excluded from output (lighter, cleaner code without compromising integrity)

You can download some examples of msignal usage [here](https://github.com/downloads/massiveinteractive/msignal/examples.zip).

### Importing

All required classes can be imported through msignal.Signal

```haxe
import msignal.Signal;
```

### Basic usage

```haxe
var signal = new Signal0();
signal.add(function(){ trace("signal dispatched!"); })
signal.dispatch();
```

### Extending

```haxe
class MySignal extends Signal2<String, Int>
{
	public function new()
	{
		super();
	}
}
```

### Typed parameters

```haxe
var signal = new Signal1<String>();
signal.add(function(i:Int){}); // error: Int -> Void should be String -> Void
signal.dispatch(true) // error Bool should be String
```

### Numbers of parameters:

```haxe
var signal0 = new Signal0();
var signal1 = new Signal1<String>();
var signal2 = new Signal2<String, String>();
```

### Slots:

```haxe
var signal = new Signal0();
var slot = signal.add(function(){});
slot.enabled = false;
signal.dispatch(); // slot will not dispatch
```

### Slot parameters:

```haxe
var signal2 = new Signal2<String, String>();
var slot = signal.add(function(s1, s2){ trace(s1 + " " + s2); });
slot.param1 = "Goodbye";
signal.dispatch("Hello", "Mr Bond"); // traces: Goodbye Mr Bond
```
