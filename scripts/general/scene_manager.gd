extends Node3D

var next_level = null
@export var next_level_id: String
@onready var current_level = $start_0

func _ready() -> void:
	current_level.connect("level_changed", Callable(self, "handle_level_changed"))
	$AnimationPlayer.play("new_animation")
	if has_node("start_1"):
		$start_1.queue_free()
func handle_level_changed(target_id:String):
	$CanvasLayer/AnimationPlayer.play_backwards("scene_fading")
	await $CanvasLayer/AnimationPlayer.animation_finished
	next_level_id = target_id
	if current_level != null:
		current_level.queue_free()
	next_level = load("res://instances/" + str(next_level_id) + ".tscn").instantiate()
	add_child(next_level)
	next_level.load_level_parameters(current_level.level_parameters)
	current_level = next_level
	current_level.level_id = next_level_id
	next_level.connect("level_changed", Callable(self, "handle_level_changed"))
	$CanvasLayer/AnimationPlayer.play("scene_fading")
func d():
	Dialogue.emit_signal("Dial","scene1_begins","res://resourses/txt.json")
