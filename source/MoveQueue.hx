package;


interface MoveQueue
{
    public function pop() : Move;
    public function push(type:MoveType) : Void;
    public function flush() : Void;
    public var moveCount(get, null) : Int;
    public function getMove(i : Int) : Move;
}