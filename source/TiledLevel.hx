package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.editors.tiled.TiledImageLayer;
import flixel.addons.editors.tiled.TiledImageTile;
import flixel.addons.editors.tiled.TiledLayer.TiledLayerType;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.addons.editors.tiled.TiledTilePropertySet;
import flixel.addons.editors.tiled.TiledPropertySet;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;
import flixel.addons.tile.FlxTilemapExt;
import flixel.addons.tile.FlxTileSpecial;
import haxe.io.Path;


class TiledLevel extends TiledMap
{
	private inline static var c_PATH_LEVEL_TILESHEETS = "assets/images/";
	
	// Array of tilemaps used for collision
	//public var foregroundTiles:FlxGroup;
	//public var objectsLayer:FlxGroup;
	public var backgroundLayer:FlxGroup;
	//private var collidableTileLayers:Array<FlxTilemap>;
	
	// Sprites of images layers
	public var imagesLayer:FlxGroup;
	public var gidType(default,null):Array<MapType> = new Array<MapType>();
	public var groundLayer : TiledTileLayer;

	public var objectLayer : TiledTileLayer;
	public var objectLayerMap : FlxTilemapExt;
	public var objectGidMap : Map<Int, String> = new Map<Int, String>();
	public var objectStringMap : Map<String, Int> = new Map<String, Int>();
	
    public function getLayerTileset(ly:TiledTileLayer) : TiledTileSet
    {
        
        for (tile in ly.tileArray)
        {
            if (tile > 0)
            {
                return getGidOwner(tile);
            }
        }
        return null;
    }

	public function new(tiledLevel:Dynamic, state:GameState)
	{
		super(tiledLevel, "assets/levels/");
		
		imagesLayer = new FlxGroup();
		//foregroundTiles = new FlxGroup();
		//objectsLayer = new FlxGroup();
		backgroundLayer = new FlxGroup();
		
		FlxG.camera.setScrollBoundsRect(0, 0, fullWidth, fullHeight, true);
		
		//loadImages();
		loadObjects(state);
		
		var maxGid = 1;
		// Load Tile Maps
			
		for (tileset in tilesets)
		{
			for (i in tileset.firstGID...(tileset.firstGID + tileset.numTiles))
			{
				gidType[i] = MapType.Empty;
				var props : TiledPropertySet = tileset.getPropertiesByGid(i);
				if (props == null) continue;
				var type = props.get("type");
				if (type != null)
				{
					if (type == "water")
					{
						gidType[i] = MapType.Water;
					}
					else if (type == "block")
					{
						gidType[i] = MapType.Block;
					}
					else if (type == "object")
					{
						gidType[i] = MapType.Object;
						var tileId2 = tileset.fromGid(i);
						var objectType = props.get("objectType");
						objectGidMap.set(tileId2, objectType);
						objectStringMap.set(objectType, tileId2);
					}
				}
			}
		}
			
		for (layer in layers)
		{
			if (layer.type != TiledLayerType.TILE) continue;
			var tileLayer:TiledTileLayer = cast layer;
			
		
			/*var tileSheetName:String = tileLayer.properties.get("tileset");
			
			if (tileSheetName == null)
				throw "'tileset' property not defined for the '" + tileLayer.name + "' layer. Please add the property to the layer.";
                */
				
			var tileSet:TiledTileSet =  getLayerTileset(tileLayer);
			//if (tileSet == null)
			//	throw "Tileset '" + tileSheetName + " not found. Did you misspell the 'tilesheet' property in " + tileLayer.name + "' layer?";
				
			var imagePath 		= new Path(tileSet.imageSource);
			var processedPath 	= c_PATH_LEVEL_TILESHEETS + imagePath.file + "." + imagePath.ext;
			
			// could be a regular FlxTilemap if there are no animated tiles
			var tilemap = new FlxTilemapExt();
			tilemap.loadMapFromArray(tileLayer.tileArray, width, height, processedPath,
				tileSet.tileWidth, tileSet.tileHeight, OFF, tileSet.firstGID, 1, 1);
			
		
				
            backgroundLayer.add(tilemap);
			if (tileLayer.name == "ground")
			{
				groundLayer = tileLayer;
				backgroundLayer.add(tilemap);
			}
			else if (tileLayer.name == "objects")
			{
				objectLayer = tileLayer;
				objectLayerMap = tilemap;
			}
			/*if (tileLayer.properties.contains("animated"))
			{
				var tileset = tilesets["level"];
				var specialTiles:Map<Int, TiledTilePropertySet> = new Map();
				for (tileProp in tileset.tileProps)
				{
					if (tileProp != null && tileProp.animationFrames.length > 0)
					{
						specialTiles[tileProp.tileID + tileset.firstGID] = tileProp;
					}
				}
				var tileLayer:TiledTileLayer = cast layer;
				tilemap.setSpecialTiles([
					for (tile in tileLayer.tiles)
						if (tile != null && specialTiles.exists(tile.tileID))
							getAnimatedTile(specialTiles[tile.tileID], tileset)
						else null
				]);
			}*/
			
			/*
			if (tileLayer.properties.contains("nocollide"))
			{
				backgroundLayer.add(tilemap);
			}
			else
			{
				if (collidableTileLayers == null)
					collidableTileLayers = new Array<FlxTilemap>();
				
				foregroundTiles.add(tilemap);
				collidableTileLayers.push(tilemap);
			}
            */
		}
	}

	private function getAnimatedTile(props:TiledTilePropertySet, tileset:TiledTileSet):FlxTileSpecial
	{
		var special = new FlxTileSpecial(1, false, false, 0);
		var n:Int = props.animationFrames.length;
		var offset = Std.random(n);
		special.addAnimation(
			[for (i in 0 ... n) props.animationFrames[(i + offset) % n].tileID + tileset.firstGID],
			(1000 / props.animationFrames[0].duration)
		);
		return special;
	}

	private function getPropertyOrDefault(prop:TiledPropertySet, name:String, defaultValue:String) : String
	{
		var propV = prop.get(name);
		if (propV != null) return propV;
		return defaultValue;
	}

	public function readGameInfo(layer:TiledObjectLayer, state:GameState)
	{
		for (object in layer.objects)
		{
			var props : TiledPropertySet = object.properties;
			if (props == null) continue;
			var typeProp = props.get("type");
			if (typeProp == null) continue;
			var pos = new IntPoint(Std.int((object.x + 1)/32), Std.int((object.y + 1) / 32));
			if (typeProp == "start")
			{
				state.startPoint = pos;
			}
			else if (typeProp == "wave")
			{
				var waveWidth = Std.int((object.width + 31) / 32);
				var waveHeight = Std.int((object.height + 31) / 32);
				var wave = new Wave(pos.x, pos.y, waveWidth, waveHeight);
				var dirP = props.get("dir");
				if (dirP != null) wave.dir = Std.parseInt(dirP);
				var typeP = props.get("wtype");
				if (typeP != null) wave.type = Std.parseInt(typeP);
				wave.startOffset = Std.parseInt(getPropertyOrDefault(props, "offset", "0"));
				wave.speedA = Std.parseInt(getPropertyOrDefault(props, "speedA", "1"));
				wave.speedB = Std.parseInt(getPropertyOrDefault(props, "speedB", "2"));
				state.waves.push(wave);
			}
			
		}
	}
	
	public function loadObjects(state:GameState)
	{
		var layer:TiledObjectLayer;
		for (layer in layers)
		{
			if (layer.type != TiledLayerType.OBJECT)
				continue;
			var objectLayer:TiledObjectLayer = cast layer;

			if (layer.name == "info")
			{
				readGameInfo(objectLayer, state);
			}
			/*
			//collection of images layer
			if (layer.name == "images")
			{
				for (o in objectLayer.objects)
				{
					loadImageObject(o);
				}
			}
			
			//objects layer
			if (layer.name == "objects")
			{
				for (o in objectLayer.objects)
				{
					loadObject(state, o, objectLayer, objectsLayer);
				}
			}*/
		}
	}
	
    /*
	private function loadImageObject(object:TiledObject)
	{
		var tilesImageCollection:TiledTileSet = this.getTileSet("imageCollection");
		var tileImagesSource:TiledImageTile = tilesImageCollection.getImageSourceByGid(object.gid);
		
		//decorative sprites
		var levelsDir:String = "assets/tiled/";
		
		var decoSprite:FlxSprite = new FlxSprite(0, 0, levelsDir + tileImagesSource.source);
		if (decoSprite.width != object.width ||
			decoSprite.height != object.height)
		{
			decoSprite.antialiasing = true;
			decoSprite.setGraphicSize(object.width, object.height);
		}
		decoSprite.setPosition(object.x, object.y - decoSprite.height);
		decoSprite.origin.set(0, decoSprite.height);
		if (object.angle != 0)
		{
			decoSprite.angle = object.angle;
			decoSprite.antialiasing = true;
		}
		
		//Custom Properties
		if (object.properties.contains("depth"))
		{
			var depth = Std.parseFloat( object.properties.get("depth"));
			decoSprite.scrollFactor.set(depth,depth);
		}

		backgroundLayer.add(decoSprite);
	}
	*/
    
	/*
	private function loadObject(state:PlayState, o:TiledObject, g:TiledObjectLayer, group:FlxGroup)
	{
        
		var x:Int = o.x;
		var y:Int = o.y;
		
		// objects in tiled are aligned bottom-left (top-left in flixel)
		if (o.gid != -1)
			y -= g.map.getGidOwner(o.gid).tileHeight;
		
		switch (o.type.toLowerCase())
		{
			case "player_start":
				var player = new FlxSprite(x, y);
				player.makeGraphic(32, 32, 0xffaa1111);
				player.maxVelocity.x = 160;
				player.maxVelocity.y = 400;
				player.acceleration.y = 400;
				player.drag.x = player.maxVelocity.x * 4;
				FlxG.camera.follow(player);
				state.player = player;
				group.add(player);
				
			case "floor":
				var floor = new FlxObject(x, y, o.width, o.height);
				state.floor = floor;
				
			case "coin":
				var tileset = g.map.getGidOwner(o.gid);
				var coin = new FlxSprite(x, y, c_PATH_LEVEL_TILESHEETS + tileset.imageSource);
				state.coins.add(coin);
				
			case "exit":
				// Create the level exit
				var exit = new FlxSprite(x, y);
				exit.makeGraphic(32, 32, 0xff3f3f3f);
				exit.exists = false;
				state.exit = exit;
				group.add(exit);
		}
        
	}*/

	public function loadImages()
	{
		for (layer in layers)
		{
			if (layer.type != TiledLayerType.IMAGE)
				continue;

			var image:TiledImageLayer = cast layer;
			var sprite = new FlxSprite(image.x, image.y, c_PATH_LEVEL_TILESHEETS + image.imagePath);
			imagesLayer.add(sprite);
		}
	}
	/*
	public function collideWithLevel(obj:FlxObject, ?notifyCallback:FlxObject->FlxObject->Void, ?processCallback:FlxObject->FlxObject->Bool):Bool
	{
		if (collidableTileLayers == null)
			return false;

		for (map in collidableTileLayers)
		{
			// IMPORTANT: Always collide the map with objects, not the other way around. 
			//			  This prevents odd collision errors (collision separation code off by 1 px).
			if (FlxG.overlap(map, obj, notifyCallback, processCallback != null ? processCallback : FlxObject.separate))
			{
				return true;
			}
		}
		return false;
	}
    */
}