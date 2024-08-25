extends Control

@onready var gobackbutton = %Button
@onready var vslider = %HSlider
@onready var lable = %Label
@onready var checkox = %CheckBox
@onready var pausemargin = get_parent().get_node("MarginContainer")
@onready var resolutionbar = %MenuButton
signal goback
func _ready():
	gobackbutton.connect("pressed",Callable(self,"ongoingback"))
	vslider.connect("value_changed",Callable(self,"volumechanged"))
	checkox.connect("toggled",Callable(self,"setscreening"))
	resolutionbar.connect("item_selected",Callable(self,"setsize"))
	if vslider.value!= 0:
		lable.text = "volume: "+str(vslider.value)
		AudioServer.set_bus_mute(0,false)
	else:
		lable.text = "volume: 0 (off)"
		AudioServer.set_bus_mute(0,true)
	AudioServer.set_bus_volume_db(0,(vslider.value/2)-40)
func volumechanged(value):
	if vslider.value!= 0:
		lable.text = "volume: "+str(vslider.value)
		AudioServer.set_bus_mute(0,false)
	else:
		lable.text = "volume: 0 (off)"
		AudioServer.set_bus_mute(0,true)
	AudioServer.set_bus_volume_db(0,(vslider.value/2)-40)
func setscreening(toggled:bool):
	if toggled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
func ongoingback():
	emit_signal('goback')
func setsize(id):
	if id == 0:
		DisplayServer.window_set_size(Vector2(576,324))
	elif id == 1:
		DisplayServer.window_set_size(Vector2(768,432))
	elif id == 2:
		DisplayServer.window_set_size(Vector2(1152,648))
	else:
		pass
		
