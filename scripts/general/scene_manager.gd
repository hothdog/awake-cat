extends Node3D

var next_level = null
var next_level_id: String
@onready var current_level = $scene_1

func _ready() -> void:
	current_level.connect("level_changed", Callable(self, "handle_level_changed"))
	$cutsceneplayer.play("new_animation")
func handle_level_changed(target_id:String):
	%AnimationPlayer.play_backwards("scene_fading")
	await %AnimationPlayer.animation_finished
	next_level_id = target_id
	if current_level != null:
		current_level.queue_free()
		
	next_level = load("res://instances/sections/" + str(next_level_id) + ".tscn").instantiate()
	add_child(next_level)
	next_level.load_level_parameters(current_level.level_parameters)
	current_level = next_level
	current_level.level_id = next_level_id
	next_level.connect("level_changed", Callable(self, "handle_level_changed"))
	%AnimationPlayer.play("scene_fading")
func d():
	Dialogue.send_dialogue("scene1_begins","res://resourses/other resourses/txt.json")
