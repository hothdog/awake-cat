extends Area3D
signal g
func _ready():
	get_tree().quit()
	connect("g",Callable(get_parent(),"open"))
func _on_body_entered(body):
	if body is Player:
		emit_signal("g")
	Dialogue.emit_signal("Dial","area","res://resourses/txt.json")

func _on_body_exited(body):
	if body is Player:
		emit_signal("g")
