package msignal;
import msignal.Slot;

typedef AnyOnceSignal = OnceSignal<Dynamic, Dynamic>

interface OnceSignal <TSlot:Slot<Dynamic, Dynamic>, TListener> {
    function addOnce(listener:TListener):TSlot;
    function remove(listener:TListener):TSlot;
    function removeAll():Void;
}

interface OnceSignal0 implements OnceSignal <Slot0, Void -> Void> {
    function dispatch():Void;
}

interface OnceSignal1<TValue> implements OnceSignal <Slot1<TValue>, TValue -> Void> {
    function dispatch(value:TValue):Void;
}

interface OnceSignal2<TValue1, TValue2> implements OnceSignal <Slot2<TValue1, TValue2>, TValue1 -> TValue2 -> Void> {
    function dispatch(value1:TValue1, value2:TValue2):Void;
}