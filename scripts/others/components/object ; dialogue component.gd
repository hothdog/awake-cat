extends Node3D
@export_dir var d_file:String = ""
@export var d_key:String = ""
func _process(_delta):
	if get_parent().get("d_cond") == true:
		Dialogue.send_dialogue(d_key,d_file)
