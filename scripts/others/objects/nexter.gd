extends Area3D
signal n
@export var nextro:String = ""
var t:bool = false
func _process(_delta):
	if monitoring:
		for i in get_overlapping_bodies():
			if i.name == "player":
				if t == false:
					get_parent()._change(nextro)
				t = true
