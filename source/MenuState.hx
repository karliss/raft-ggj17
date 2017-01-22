package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;

class MenuState extends FlxState
{
	private var _btnFullScreen : FlxButton;
	 
	override public function create():Void
	{
		FlxG.mouse.visible = true;

		/*super.create();
		var b1 : FlxButton = new FlxButton(FlxG.width/2, 20,  "Start", newGame);
		b1.x -= b1.width/2;
		add(b1);*/
		var t1 : FlxText = new FlxText(FlxG.width / 2, 10, 200, "Raft | Global Game Jam 2017");
		t1.x -= t1.width / 2;
		add(t1);

		
		var b1 : FlxButton = new FlxButton(FlxG.width/2, 50,  "Start", function() {newGame();});
		b1.x -= b1.width/2;
		add(b1);
		
#if desktop
		_btnFullScreen = new FlxButton(0, 70, FlxG.fullscreen ? "FULLSCREEN" : "WINDOWED", function() {
			    FlxG.fullscreen = !FlxG.fullscreen;
				_btnFullScreen.text = FlxG.fullscreen ? "FULLSCREEN" : "WINDOWED";
		});
		_btnFullScreen.x = FlxG.width / 2 - _btnFullScreen.width / 2;
		add(_btnFullScreen);

		var _btnExit = new FlxButton(FlxG.width / 2, 90, "Exit", function() { Sys.exit(0); } );
		_btnExit.x -= _btnExit.width / 2;
		add(_btnExit);
#end
		
		var t2 : FlxText = new FlxText(10, 110, FlxG.width - 20, "Controls: \n Arrows - move(with delay) \n R - restart \n Alt+Enter - fullscreen(Desktop) \n 0/+/- - Control sound\n \n\n Created by : Karlis \n");
		add(t2);
	}
	

	private function newGame():Void
	{
		FlxG.switchState(new LevelSelector());
	}
}