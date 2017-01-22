
package ;

import flixel.FlxG;
import flixel.FlxState;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUIButton;
import flixel.util.FlxSave;
import flixel.text.FlxText;
import flixel.ui.FlxVirtualPad;

class LevelSelector extends FlxState
{
	private var levelSolved : Int;
	private static inline var SAVE_NAME : String = "DS_S_1";
    static inline var LEVEL_PREFIX = "assets/levels/";
    private var continueLevels : Bool;

	public function new (_solved:Int=0, continueLevels:Bool = false)
	{
		levelSolved = _solved;
        this.continueLevels = continueLevels;
		super();
	}

	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		FlxG.mouse.visible = true;
		
		var btnBack : FlxButton = new FlxButton( FlxG.width/2 , 10, "Back" , 
				function () {FlxG.switchState(new MenuState());} );
		add(btnBack);
		btnBack.x -= btnBack.width/2;

		var btnResetProgress : FlxButton = new FlxButton(FlxG.width/2, 40, "Reset progress", resetProgress); 
		add(btnResetProgress);
		btnResetProgress.x -= btnResetProgress.width/2;

		var continueText : FlxText =
		 	new FlxText( FlxG.width/2 - 100 , 60 ,200, "Pres space to continue");
	 	continueText.alignment = "center";
		add(continueText);


		updateProgress();

		var cnt : Int = LevelInfo.levels.length;
		var btnPerLine : Int = Math.floor((FlxG.width - 40)/30);

		for (i in 0...(cnt))
		{
			var line:Int = Math.floor(i / btnPerLine);
			var column : Int = i % btnPerLine;
			var locked = i > levelSolved;
			var btn = new FlxUIButton(20 + 30 * column, 80 + line*30, Std.string(i+1), 
					(!locked) ? 
				    (function() {
					FlxG.switchState(new GameState(LEVEL_PREFIX + LevelInfo.levels[i] ,
                        new LongTermState(),
						function (result : Bool) {
							var levelCnt = result ? i+1 : 0;
							FlxG.switchState(new LevelSelector(levelCnt, true));
						}
					 ));
				})  : null);
			btn.resize(20, 20);
			if (locked) {
				btn.color = flixel.util.FlxColor.RED;
			}
			add(btn);

		}
		
		super.create();
	}

	public override function update(elapsed:Float)
	{
		if (FlxG.keys.pressed.SPACE || continueLevels)
		{
			if (levelSolved < LevelInfo.levels.length)
			{
				FlxG.switchState(new GameState(LEVEL_PREFIX + LevelInfo.levels[levelSolved] ,
                            new LongTermState(),
							function (result : Bool) {
								var levelCnt = result ? levelSolved+1 : 0;
                                var selector = new LevelSelector(levelCnt);
								FlxG.switchState(new LevelSelector(levelCnt, true));
							}));
			}
		}
		super.update(elapsed);
	}

	private function getSavedProgress() : Int
	{
		var save : FlxSave = new FlxSave();
		save.bind(SAVE_NAME);
		if (save.data.progress != null)
		{
			var p1 : Int = Std.int(save.data.progress);
			return p1;
		}
		return 0;
	}

	private function updateProgress()
	{
		var oldProgress : Int = getSavedProgress();
		if (oldProgress > levelSolved) levelSolved = oldProgress;
		var save : FlxSave = new FlxSave();
		save.bind(SAVE_NAME);
		save.data.progress = levelSolved;
		save.flush();
	}

	private function resetProgress()
	{
		var save : FlxSave = new FlxSave();
		save.bind(SAVE_NAME);
		save.erase();
		FlxG.switchState(new LevelSelector());
	}
	

}