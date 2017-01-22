
import flixel.FlxSprite;

class QueueIndicator extends flixel.group.FlxSpriteGroup
{
    var queue : MoveQueue;
    var arrowTiles : Array<FlxSprite>;
    var arrowOffset : Float = 0;

    private static inline var MAX_ARROWS = 20;

    public function new(queue : MoveQueue)
    {
        super();
        this.queue = queue;
        arrowTiles = new Array();
        var tmpSprite : FlxSprite = new FlxSprite();
        tmpSprite.loadGraphic(AssetPaths.arrows__png, true, 32, 32);
        for (i in 0...MAX_ARROWS)
        {
            var sprite : FlxSprite = new FlxSprite();
            sprite.loadGraphicFromSprite(tmpSprite);
            arrowTiles.push(sprite);
            add(sprite);
        }
    }

    public function refresh(offset:Float)
    {
        arrowOffset = offset * 32;
    }

    override public function update(elapsed:Float):Void
    {
        for (i in 0...MAX_ARROWS)
        {
            var sprite = arrowTiles[i];
            if (i < queue.moveCount)
            {
                var move = queue.getMove(i);
                var moveId = 
                switch(move.type)
                {
                    case MoveType.Blank: 0;
                    case MoveType.Up: 1;
                    case MoveType.Right: 2;
                    case MoveType.Down: 3;
                    case MoveType.Left: 4;
                    default: 0;
                };
                var bonus = move.bonus;
                sprite.x = i * 32 + arrowOffset;
                sprite.y = 0;
                sprite.frame = sprite.frames.frames[moveId + 10 * (bonus < 5 ? bonus : 4)];
                
                if (bonus >= 5)
                {
                    var k = Math.min(bonus - 5.0, 6);
                    sprite.x += (Math.random() - 0.5) * k;
                    sprite.y += (Math.random() - 0.5) * k;
                }
                sprite.visible = true;
            }
            else
            {
                sprite.x = i * 32 + arrowOffset;
                sprite.y = 0;
                sprite.frame = sprite.frames.frames[0];
                sprite.visible = false;
            }  
        }

        super.update(elapsed);
    }
}