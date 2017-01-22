package ;

import flixel.FlxSprite;
import flixel.FlxObject;
import haxe.Json;

class AnimatedSprite extends FlxSprite
{
	public function new(FileName:String) {
        super();
        var jsondata = Json.parse(openfl.Assets.getText(FileName));
        var width = Std.parseInt(jsondata.width);
        var height = Std.parseInt(jsondata.height);
        this.loadGraphic(jsondata.image, true, width, height);
		for (anim in Reflect.fields(jsondata.animation)) {
			var d = Reflect.field(jsondata.animation, anim);
			var speed:Int = Std.parseInt(d.speed);
			var looped = d.looped == "true";
			animation.add(anim, d.f, speed, looped);
		}
	}

	public override function update(elapsed:Float) : Void 
	{
		super.update(elapsed);
	}

	public function SetAnimation(newAnim:String, force : Bool = false) : Void
	{
    	animation.play(newAnim, force);
	}
}