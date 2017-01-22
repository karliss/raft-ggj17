class Wave 
{
    public var p0 : IntPoint = new IntPoint();
    public var size : IntPoint = new IntPoint();
    public var speedA : Int = 1;
    public var speedB : Int = 2;
    public var dir : Int = 1;
    public var type : Int = 0;
    public var startOffset : Int = 0;
    public function new(x : Int, y : Int, w : Int, h : Int)
    {
        p0.set(x, y);
        size.set(w, h);
    }

    public function getMoves(time:Int) : Int
    {
        if (time < startOffset) return -1;
        time -= startOffset;
        var blocks : Int = Std.int(time / speedB);
		var reminder = time % speedB;
        var res : Int = blocks * speedA;
        res += reminder < speedA ? reminder : speedA;
        return res;
    }
}