extends Control
var paused:bool = false
@onready var settings = $settings
enum menu{
	none,
	pause,
	settings,
}
var menustate:menu = menu.none
func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		paused = !paused
	if paused:
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED
		if menustate != menu.settings:
			$MarginContainer.show()
		else:
			settings.show()
		$ColorRect.show()
		get_tree().paused = true
	else:
		menustate = menu.none
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		$ColorRect.hide()
		$MarginContainer.hide()
		settings.hide()
		get_tree().paused = false

func _on_button_pressed():
	menustate = menu.settings
	settings.visible  = true
	$MarginContainer.hide()
	if!settings.is_connected("goback",Callable(self,"backtooptions")):
		settings.connect("goback",Callable(self,"backtooptions"))
func backtooptions():
	menustate = menu.pause
	settings.hide()
	$MarginContainer.show()

func _on_button_2_pressed():
	get_tree().quit()
