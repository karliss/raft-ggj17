
package ;

import flixel.FlxG;
import flixel.FlxSubState;
import flixel.ui.FlxButton;

class EscMenu extends FlxSubState
{
	private var game:GameState;
	private var btnRestart : flixel.ui.FlxButton;
	private var btnExit : FlxButton;
	private var btnContinue : FlxButton;

	public function new (_game:GameState)
	{
		game = _game;
		super();
	}

	public override function create()
	{
		FlxG.mouse.visible = true;

		btnRestart = new FlxButton ( 0 , 10 , "Restart" , function () {game.reset();} );
		add(btnRestart);
		btnRestart.x = FlxG.width/2 - btnRestart.width/2;
		
        btnExit = new FlxButton(0, 40, "Exit", function() { FlxG.switchState(new MenuState()); });
		add(btnExit);
		btnExit.x = FlxG.width/2 - btnExit.width/2;

		btnContinue = new FlxButton(0, 70, "Continue", function() { game.closeSubState(); });
		add(btnContinue);
		btnContinue.x = FlxG.width/2 - btnContinue.width/2;
	}
	
	public override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ESCAPE)
		{
			game.closeSubState();
		}
		super.update(elapsed);
	}


}