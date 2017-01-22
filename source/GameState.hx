package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.tile.FlxTilemap;
import flixel.system.FlxSound;

class GameState extends FlxState
{
	public var tiledLevel : TiledLevel = null;
	var backgroundLayers : FlxGroup;
	var playerLayer : FlxGroup;
	var player : Player;
	var guiLayer : FlxSpriteGroup;

	public var rules : GameRules;
	public var moves : MoveQueue;

	private var timeAccumulator : Float;
	public var clock : Int = 0;
	private var queueIndicator : QueueIndicator;

	public var startPoint : IntPoint = new IntPoint();
	public var endPoint : IntPoint = new IntPoint(100, 100);
	
	public var W : Int;
	public var H : Int;

	public var waves : Array<Wave>;
	public var waveSound : Array<FlxSound>;
	public var waveLayer : flixel.tile.FlxTilemap;

	
	var levelPath : String;
	var initialScore : LongTermState;
	var callback : Bool->Void;

	var autoTick : Bool = true;

	public function new(levelPath:String, scoreInfo:LongTermState, ?callback : Bool->Void)
	{
		this.levelPath = levelPath;
		this.initialScore = scoreInfo.copy();
		this.callback = callback;
		super();
	}

	public function doSound(path:String)
	{
		var sound = FlxG.sound.play(path, 1, false, null, false);
		sound.persist = true;
	}

	public function reset()
	{
		FlxG.switchState(new GameState(levelPath, initialScore, callback));
	}

	public function onWin()
	{
		doSound(AssetPaths.victory__ogg);
		if (callback != null)
		{
			callback(true);
		}
		else
		{
			FlxG.switchState(new MenuState());
		}
	}

	public function loose()
	{
		doSound(AssetPaths.die__ogg);
		reset();
	}

	override public function create():Void
	{
		super.create();
		waves = new Array();
		backgroundLayers = new FlxGroup();
		add(backgroundLayers);
		add(playerLayer = new FlxGroup());

        tiledLevel = new TiledLevel(levelPath, this);
		backgroundLayers.add(tiledLevel.backgroundLayer);
		add(tiledLevel.objectLayerMap);
		W = tiledLevel.objectLayerMap.widthInTiles;
		H = tiledLevel.objectLayerMap.heightInTiles;

		rules = GameRules.DEFAULT_RULES;

		player = new Player(this);
		playerLayer.add(player);
		player.setPos(startPoint);
		FlxG.camera.follow(player);
		moves = new Queue1(rules);
		timeAccumulator = 0;

		initWaveLayer();

		guiLayer = new FlxSpriteGroup();
		add(guiLayer);
		guiLayer.scrollFactor.x = 0;
		guiLayer.scrollFactor.y = 0;
		queueIndicator = new QueueIndicator(moves);
		guiLayer.add(queueIndicator);
		var healthIndicator = new HealthIndicator(player);
		guiLayer.add(healthIndicator);
		healthIndicator.x = FlxG.width - 50;
	}


	function initWaveLayer()
	{
		waveLayer = new FlxTilemap();
		var tmp : Array<Int> = new Array<Int>();
		var S  = H * W;
		for (i in 0...S)
		{
			tmp.push(0);
		}
		waveLayer.loadMapFromArray(tmp, W, H, AssetPaths.tiles__png, 32, 32, OFF, 0, 1, 1);
		add(waveLayer);
		waveSound = new Array();
		for (i in 0...waves.length)
		{
			waveSound.push(FlxG.sound.load(AssetPaths.waves1__ogg, 0.5, true));
		}
	}

	function getWaterTile(dir : Int, end : Bool) : Int
	{
		var endTiles : Array<Array<Int> > = [
			[105, 106, 107, 108],
			[103,123,143,163],
			[165, 166, 167, 168],
			[100,120,140,160],
		];
		var middleTiles : Array<Array<Int>> = [
			[101, 102, 121, 122, 141, 142, 161, 162],
			[125, 126, 127, 128, 145, 146, 147, 148],
		];
		var tiles = end ? endTiles[dir] : middleTiles[dir & 1];
		return tiles[Std.random(tiles.length)] + 100;
	}
	function updateWaves() : Void
	{
		var S = H * W;
		for (i in 0...S) waveLayer.setTileByIndex(i, 0, false);
		var waveId : Int = -1;
		for (wave in waves)
		{
			waveId += 1;
			var dir = wave.dir;
			var h = wave.size.y;
			var w = wave.size.x;
			if (dir == 0 || dir == 2)
			{
				w = wave.size.y;
				h = wave.size.x;
			}
			var x0 : Int = 0;
			var y0 : Int = 0;
			var dxv : Int = 0;
			var dyv : Int = 0;
			var dxh : Int = 0;
			var dyh : Int = 0;
			switch (dir)
			{
				case 0:	{
					x0 = wave.p0.x; y0 = wave.p0.y + wave.size.y - 1;
					dxv = 1; dyv = 0;
					dxh = 0; dyh = -1;
				}
				case 1: {
					x0 = wave.p0.x; y0 = wave.p0.y;
					dxv = 0; dyv = 1;
					dxh = 1; dyh = 0;
				}
				case 2:	{
					x0 = wave.p0.x; y0 = wave.p0.y;
					dxv = 1; dyv = 0;
					dxh = 0; dyh = 1;
				}
				case 3:	{
					x0 = wave.p0.x + wave.size.x - 1; y0 = wave.p0.y;
					dxv = 0; dyv = 1;
					dxh = -1; dyh = 0;
				}
			}
			var moves = wave.getMoves(clock);
			if (moves < 0) continue;
			for (i in 0...h)
			{
				
				var d : Int = 
				switch (wave.type)
				{
					case 0: {
						var r : Int = moves % (2 * (w + 1));
						r = r <= w ? r : w - (r - (w + 1));
						if (h > 2 && (i == 0 || i == h-1)) r--;
						r;
					}
					case 1: { 
						moves <= w ? moves : w;
					}
					
					default: 0;
				};
				if (d < 0) d = 0;
				if (d > w) d = w;
				if (i * 2 == h&~1)
				{
					var sx = 32 * (x0 + dxv * i + dxh * d);
					var sy  = 32 * (y0 + dyv * i + dyh * d);
					var sound = waveSound[waveId];
					var range = Math.max(32 * 4, 32 * (1 + h/2));
					sound.proximity(sx, sy, player, range);
					if (!sound.playing)
					{
						sound.play(sound.length * Math.random());
					}
				}
				for (j in 0...d)
				{
					var tileId = getWaterTile(dir, j == d-1);
					waveLayer.setTile(x0 + dxv * i + dxh * j, y0 + dyv * i + dyh * j, tileId, j == d-1 && i == h-1);
				}
			}
			
			
		}
	}

	function processKeyboard() : Void
	{
		if (FlxG.keys.justPressed.ESCAPE)
		{
			if (this.subState == null)
			{
				openSubState(new EscMenu(this));
			}
		}
		if (FlxG.keys.justPressed.RIGHT)
        {
			moves.push(MoveType.Right);
        }
        if (FlxG.keys.justPressed.UP)
        {
			moves.push(MoveType.Up);
        }
        if (FlxG.keys.justPressed.DOWN)
        {
			moves.push(MoveType.Down);
        }
        if (FlxG.keys.justPressed.LEFT)
        {
			moves.push(MoveType.Left);
        }
		if (FlxG.keys.justPressed.R)
		{
			reset();
		}
#if debug 
		if (FlxG.keys.justPressed.A)
        {
			clock -= 2;
			step();
        }
		if (FlxG.keys.justPressed.D)
		{
			step();
		}
		if (FlxG.keys.justPressed.S)
		{
			autoTick = !autoTick;
		}
#end
	}

	public function IsWater(px:Int, py:Int) : Bool
	{	
		var tile = tiledLevel.groundLayer.tileArray[px + py * tiledLevel.groundLayer.width];
		if (tiledLevel.gidType[tile] == MapType.Water) return true;
		if (waveLayer.getTile(px, py) > 0) return true;
		return false;
	}

	public function GetObject(px:Int, py:Int) : String
	{
		var id = px + py * tiledLevel.objectLayer.width;
		var tile = tiledLevel.objectLayerMap.getTile(px, py);
		if (tile == 0) return null;
		if (tiledLevel.objectGidMap.exists(tile))
		{
			return tiledLevel.objectGidMap[tile];
		}
		return null;
	}

	public function SetObject(px:Int, py:Int, obj:String)
	{
		if (obj == null || obj.length == 0)
		{
			tiledLevel.objectLayerMap.setTile(px, py, 0);
		}
		else
		{
			tiledLevel.objectLayerMap.setTile(px, py, tiledLevel.objectStringMap[obj]);
		}
	}

	override public function update(elapsed:Float):Void
	{
		processKeyboard();
		timeAccumulator += elapsed;
		while (timeAccumulator >= rules.timeStep)
		{
			timeAccumulator -= rules.timeStep;
			if (autoTick) this.step();
		}
		queueIndicator.refresh((rules.timeStep - timeAccumulator)/rules.timeStep);
		super.update(elapsed);
	}

	function step() : Void
	{
		player.step(moves.pop());
		updateWaves();
		clock += 1;
	}
}
