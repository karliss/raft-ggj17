
class Move
{
    
    public var type : MoveType;
    public var bonus : Int;
    public function new(type : MoveType)
    {
        this.type = type;
        this.bonus = 0;
    }
}