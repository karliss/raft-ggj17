package ;

import flixel.FlxSprite;
import flixel.FlxObject;
import haxe.Json;

class Character extends FlxSprite
{
	private var animType : String = "";
	private var dir : Int ;
	private var dying : Bool;

    public var PX : Int = 0;
    public var PY : Int = 0;

    public function updatePos()
    {
        this.x = PX * 32;
        this.y = PY * 32;
    }

    public function setPos(pos:IntPoint)
    {
        this.PX = pos.x;
        this.PY = pos.y;
        updatePos();
    }

    public function setPos2(x:Int, y:Int)
    {
        this.PX = x;
        this.PY = y;
        updatePos();
    }

	public function new(FileName:String) {
        super();
        var jsondata = Json.parse(openfl.Assets.getText(FileName));
		this.width = Std.parseInt(jsondata.width);
		this.height = Std.parseInt(jsondata.height);
		this.dying = false;
        //var spritesheet = new FlxSprite();
        this.loadGraphic(jsondata.image, true, 32, 32);
       // this.loadRotatedGraphic(spritesheet, 4);
		/*this.width = 32;
		this.height = 32;
		this.offset.set(16, 16);*/

		for (anim in Reflect.fields(jsondata.animation)) {
			var d = Reflect.field(jsondata.animation, anim);
			var speed:Int = Std.parseInt(d.speed);
			var looped = d.looped == "true";
			animation.add(anim, d.f, speed, looped);
		}
        //animation.createPrerotated();
		animation.play("idle");
		dir = 1;
	}

    static inline var ANIMATION_STEP : Float = 5;
	public override function update(elapsed:Float) : Void 
	{
        var tx = this.PX * 32.0;
        var ty = this.PY * 32.0;
        var dx = tx - this.x;
        var dy = ty - this.y;
        if (Math.abs(dx) < ANIMATION_STEP)
        {
            this.x = tx;
        }
        else
        {
            this.x += dx < 0 ? -ANIMATION_STEP : ANIMATION_STEP;
        }

        if (Math.abs(dy) < ANIMATION_STEP)
        {
            this.y = ty;
        }
        else
        {
            this.y += dy < 0 ? -ANIMATION_STEP : ANIMATION_STEP;
        }

        if (animation.finished && animType != "idle")
        {
            SetAnimation("idle");
        }
        /*
        this.ro
		if (this.velocity.x < 0) dir = -1;
		if (this.velocity.x > 0) dir = 1;
		this.flipX = dir != 1;

		if (!dying)
		{
			if (Math.abs(this.velocity.x) > 10) SetAnimation("walk");
			else if (animType == "walk") SetAnimation("idle");
		}

		checkFloor();*/

		super.update(elapsed);
	}

	public function die() : Void
	{
		this.kill();
	}

	public function SetAnimation(newAnim:String, force : Bool = false) : Void
	{
		if (animType != newAnim || force)
		{
			animation.play(newAnim);
			animType = newAnim;
		}
	}
}