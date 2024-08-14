extends Node3D
signal level_changed(level_name)

@export var level_id:String
var level_parameters := {
}
var pp
func _ready():
	get_parent().set_editable_instance(self, true)
	pp = get_parent().get_node("player").position
func load_level_parameters(new_level_parameters: Dictionary):
	level_parameters = new_level_parameters

func _change(target):
	emit_signal("level_changed",target)

