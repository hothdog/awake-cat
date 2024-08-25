extends Area3D
signal g
var d_cond:bool = false
func _ready():
	connect("g",Callable(get_parent(),"open"))
func _on_body_entered(body):
	if body is Player:
		emit_signal("g")
		d_cond = true
func _on_body_exited(body):
	if body is Player:
		emit_signal("g")
