extends StaticBody3D

signal sent
@export var targets:PackedStringArray
@export var dio:String = ""
@export var d_file:String = ""
@export_enum("once","onoff") var switch_mode:String
var on:bool = false
func _ready():
	for i in targets.size():
		connect("sent",Callable(get_parent().get_node(targets[i]),"open"))
func interact():
	if dio!= "":
		Dialogue.send_dialogue(dio,d_file)
	if (on == false and switch_mode == "once")or switch_mode == "onoff":
		emit_signal("sent")
		$AudioStreamPlayer.play()
	on = !on
	
