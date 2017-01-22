package ;

class GameRules
{
    public static inline var QUEUE_SIZE = 128; 
    public static inline var DEFAULT_TIME_STEP = 0.5;
    public var delay : Int;
    public var timeStep : Float;

    public function new(delay:Int, timeStep:Float)
    {
        this.delay = delay;
        this.timeStep = timeStep;
    }
    public static var DEFAULT_RULES : GameRules = new GameRules(2, DEFAULT_TIME_STEP);
}