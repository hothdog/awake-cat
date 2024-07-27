extends StaticBody3D

signal sent
@export var targets:PackedStringArray
@export var dio:String = ""
@export var d_file:String = ""
func _ready():
	for i in targets.size():
		connect("sent",Callable(get_parent().get_node(targets[i]),"open"))
func interact():
	if dio!= "":
		Dialogue.emit_signal("Dial",dio,d_file)
	emit_signal("sent")
	$AudioStreamPlayer.play()
