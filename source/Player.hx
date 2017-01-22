package;

import flixel.FlxG;
import flixel.system.FlxSound;


class Player extends Character
{
    private var waterSound : FlxSound;
    private var tickSound : FlxSound;
    private var dirSounds : Array<Array<Array<FlxSound> > >;
    static inline var MAX_SOUND_BONUS = 5;
    static inline var MAX_HEALTH : Int = 5;

    var world : GameState;

	public function new(world:GameState):Void
	{
        super(AssetPaths.player__json);
        this.world = world;
        this.health = MAX_HEALTH;
        loadSound();
	}

    public function loadSound()
    {
        waterSound = FlxG.sound.load(AssetPaths.water__ogg);
        tickSound = FlxG.sound.load(AssetPaths.step__ogg, 0.4);
        dirSounds = new Array();
        for (dir in 0...4)
        {
            var dirSound = new Array<Array<FlxSound>>();
            dirSounds.push(dirSound);
            for (i in 0...MAX_SOUND_BONUS)
            {
                var bonusSounds = new Array<FlxSound>();
                dirSound.push(bonusSounds);
                for (j in 0...4)
                {
                    var name : String = "assets/sounds/m/sound_" + dir + "_" + i + "_" + j + ".ogg";
                    bonusSounds.push(FlxG.sound.load(name));
                }
            }
        }
    }

    public function step(move : Move)
    {
        var TX = PX;
        var TY = PY;
        var dir = 0;
        var hasMove = true;
        switch (move.type)
        {
            case Blank: {hasMove = false; fail();}
            case Up:    {TY -= 1; dir = 0; }
            case Right: {TX += 1; dir = 1; }
            case Down:  {TY += 1; dir = 2; }
            case Left:  {TX -= 1; dir = 3; }
        }
        if (hasMove)
        {
            angle = dir * 90;
        }

        var canMove = true;
        if (TX < 0 || TY < 0 || TX >= world.W || TY >= world.H) { return; }
        else
        {
            var obj = world.GetObject(TX, TY);
            if (obj != null)
            {
                if (obj == "raft")
                {
                    world.onWin();
                }
            }
            if (world.IsWater(TX, TY))
            {
                canMove = false;
                SetAnimation("back");
                world.moves.flush();
                waterSound.play(true);
                hurt(1);
            }
        }
        if (canMove && hasMove)
        {
            PX = TX;
            PY = TY;
            var sound_id = Std.int(move.bonus / 2);
            var sounds = dirSounds[dir][sound_id < MAX_SOUND_BONUS ? sound_id : MAX_SOUND_BONUS - 1];
            sounds[Std.random(sounds.length)].play();
            if (move.bonus >= 6 && health < MAX_HEALTH)
            {
                this.health = Math.min(health + 1, MAX_HEALTH);
            }
        }
    }

    override public function kill()
    {
        world.loose();
        super.kill();
    }

    public function fail()
    {
        tickSound.play();
    }


	override public function update(elapsed:Float):Void
	{
        super.update(elapsed);
	}
}
