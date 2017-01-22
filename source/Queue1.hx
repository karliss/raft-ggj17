
class Queue1 implements MoveQueue
{
    var rules : GameRules;
   
    private var queue : Array<Move>;
    public function new(rules : GameRules)
    {
        this.rules = rules;
        this.queue = new Array<Move>();
    }

    public function flush()
    {
        this.queue = new Array<Move>();
    }

    public function pop() : Move 
    {
        var result = queue.shift();
        if (result == null)
        {
            return new Move(MoveType.Blank);
        }
        return result;
    }

    public var moveCount(get,null) : Int;
    public function get_moveCount() : Int
    {
       return queue.length; 
    }

    public function getMove(i : Int) : Move
    {
        if (i < queue.length)
        {
            return queue[i];
        }
        return new Move(MoveType.Blank);
    }

    public function push(type : MoveType)
    {
        var fill = false;
        while (queue.length < rules.delay)
        {
            fill = true;
            queue.push(new Move(MoveType.Blank));
        }
        var move = new Move(type);
        if (!fill)
        {
            var i : Int = queue.length - 1;
            while (i >= 0 && queue[i].type != MoveType.Blank)
            {
                i--;
                move.bonus++;
            }
        }
        queue.push(move);
    }
}