extends StaticBody3D

func _on_area_3d_body_entered(body):
	if body.name == 'player':
		body.climbing = true


func _on_area_3d_body_exited(body):
	if body.name == 'player':
		body.climbing = false
