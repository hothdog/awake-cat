extends Node3D

@onready var secure = get_parent()
@export var chacks_array:PackedVector3Array = [Vector3(0,0,0),Vector3(0,180,0)]
var index:int = -1
@export var speed = 0.5

func _process(delta):
	if secure.state == secure.states.wanderstate:
		var s = chacks_array[index]*PI/180-secure.rotation
		if abs(s.length())>=0.02 :
			secure.rotation += s.normalized() * delta * speed
		else:
			index = (index + 1) % chacks_array.size()
		secure.rotation_degrees.y = fmod(secure.rotation_degrees.y,360)
