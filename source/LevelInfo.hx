
package ;

class LevelInfo 
{
	static public var levels : Array<String> = [	
		"t1.tmx",
		"t2.tmx",
        "tf.tmx",
        "tf2.tmx"
    ];

	static public function next(current:String)
	{
		for ( i in 0...(levels.length - 1))
		{
			if (levels[i] == current) return levels[i+1];
		}
		return null;
	}

}