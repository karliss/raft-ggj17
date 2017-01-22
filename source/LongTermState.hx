class LongTermState
{
    public var score : Int;
    public function new()
    {
        this.score = 0;
    }
    
    public function copy() : LongTermState
    {
        var result = new LongTermState();
        result.score = score;

        return result;
    }
}