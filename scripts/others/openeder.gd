extends StaticBody3D
class_name door
var will_open := false
func ready():
	connect("g",Callable(self,"open"))
func open():
	will_open = !will_open
	if will_open == true:
		if $AnimationPlayer.is_playing():
			await $AnimationPlayer.animation_finished
		$AnimationPlayer.play("open")
	else:
		if $AnimationPlayer.is_playing():
			await $AnimationPlayer.animation_finished
		$AnimationPlayer.play("close")
