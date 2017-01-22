
class IntPoint
{
    public var x : Int;
    public var y : Int;
    inline public function new(x : Int = 0, y: Int = 0)
    {
        this.x = x;
        this.y = y;
    }
    inline public function add(b : IntPoint)
    {
        x += b.x;
        y += b.y;   
    }
    inline public function set(x : Int, y : Int)
    {
        this.x = x;
        this.y = y;
    }
}