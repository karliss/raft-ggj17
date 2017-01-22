package;

import flixel.FlxSprite;
import flixel.text.FlxText;

class HealthIndicator extends flixel.group.FlxSpriteGroup
{
    var player : FlxSprite;
    var text : FlxText;
    var lastHealth : Float;
    var icon : AnimatedSprite;

    public function new(player : FlxSprite)
    {
        super();
        
        this.player = player;
        lastHealth = player.health;
        text = new FlxText(32, 10, 100, Std.string(lastHealth));
        add(text);
        icon = new AnimatedSprite("assets/images/health.json");
        add(icon);
    }

    override public function update(elapsed:Float):Void
    {
        if (player.health != lastHealth)
        {
            lastHealth = player.health;
            text.text = Std.string(lastHealth);
            icon.SetAnimation("beep", true);
        }
        else if (player.health == 1)
        {
            icon.SetAnimation("pulse");
        }
        else
        {
            var curAnim = icon.animation.curAnim;
            if (curAnim != null && curAnim.name == "pulse") 
            {
                icon.SetAnimation("idle");
            }
        }
        super.update(elapsed);
    }
}