extends Node3D

@onready var player:CharacterBody3D
@export var lookcone_width:float = 2.5
@export var lookcone_height:float = 2.5
@export var viewrange:float = 8
var my_script = preload("res://resourses/sfx/voices(acting)/AudioStreamPlayer2D.gd")
var rayspace = 2.5
var ray:RayCast3D
var hisrays:Array= []
var poly:ArrayMesh
enum states{lookstate,wanderstate}
var state = states.wanderstate
var arrays = []
var verts = PackedVector3Array()
var indices = PackedInt32Array()
var rays_width = deg_to_rad(lookcone_width) / deg_to_rad(rayspace)
var rays_height = deg_to_rad(lookcone_height) / deg_to_rad(rayspace)
var x:float = 0
var au:AudioStreamPlayer3D

func _ready() -> void:
	$RayCast3D.queue_free()
	generay()
	genefield()
	if get_parent().is_class("PathFollow3D"):
		player = get_parent().get_parent().get_parent().get_parent().get_node("player")
	else:
		player = get_parent().get_parent().get_node("player")

func generay() -> void:
	var a = []
	poly = ArrayMesh.new()
	arrays.resize(Mesh.ARRAY_MAX)
	
	for j in range(rays_height):
		var newangle_height = deg_to_rad(rayspace) * (j - rays_width / 2)
		for i in range(rays_width):
			ray = RayCast3D.new()
			var newangle_width = deg_to_rad(rayspace) * (i - rays_width / 2)
			ray.target_position = Vector3(newangle_width, newangle_height, 1) * viewrange
			add_child(ray)
			hisrays.append(ray)
			a.append(ray.target_position)
			if i * j == ceil(((rays_height-1)*(rays_width-1))/2):
				au = AudioStreamPlayer3D.new()
				au.position = ray.target_position
				au.stream = load("res://resourses/sfx/voices(acting)/basic_hi4.mp3")
				add_child(au)
				au.set_script(my_script)
				au.set_process(true)
				au.play()
	genevert(a)

func genevert(target):
	for i in range(hisrays.size()):
		verts.append(target[i])
	verts.append(to_local(global_position))
	
func genefield():
	for j in range(rays_height - 1):
		for i in range(rays_width - 1):
			var base_index = i+j * rays_width 
			indices.append(base_index)
			indices.append(base_index + rays_width)
			indices.append(base_index + 1)
				
			indices.append(base_index + 1)
			indices.append(base_index + rays_width)
			indices.append(base_index + rays_width+ 1)
	indices.append_array(genseq(rays_width,rays_height)) 
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_INDEX] = indices
	poly.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var m = MeshInstance3D.new()
	m.mesh = poly
	m.material_override = preload("res://resourses/textures and models/mat.tres")
	add_child(m)
func genseq(W,H)-> Array:
	var seq=[]
	for i in range(W):
		seq.append(i)
	for i in range(W + (W-1) , W*H, W):
		seq.append(i)
	for i in range(W * H - 2, W * H - W - 1, -1):
		seq.append(i)
	for i in range(W * (H - 2), W - 1, -W):
		seq.append(i)
	seq.append(0)
	var seq2 = []
	for i in seq.size():
		if i == 0:
			seq2.append(0)
		elif i == seq.size()-1:
			seq2.append_array([W * H, seq[i]])
		else:
			seq2.append_array([W * H, seq[i], seq[i]])
	return seq2

func statefunc():
	#var direction = player.global_position+Vector3(0,2,0)- global_position
	match state:
		states.wanderstate:
			if get_parent().name == "p":
				get_parent().progress += 0
			pass
		states.lookstate:
			if get_parent().name == "p":
				player.get_parent().get_node("CanvasLayer/AnimationPlayer").play("returning")
				await player.get_parent().get_node("CanvasLayer/AnimationPlayer").animation_finished
				player.position = get_parent().get_parent().get_parent().pp
				player.get_parent().get_node("CanvasLayer/AnimationPlayer").play("scene_fading")
			else:
				player.get_parent().get_node("CanvasLayer/AnimationPlayer").play("returning")
				await player.get_parent().get_node("CanvasLayer/AnimationPlayer").animation_finished
				player.position = get_parent().get_parent().get_parent().pp
				player.get_parent().get_node("CanvasLayer/AnimationPlayer").play("scene_fading")

func _process(_delta: float) -> void:
	var foundPlayer = false
	var b:PackedVector3Array = []
	for i in range(hisrays.size()):
		var r = hisrays[i]
		if r.is_colliding():
			var collision_point = r.get_collision_point()
			b.append(to_local(collision_point))
			if r.get_collider() == player:
				foundPlayer = true
		else:
			b.append(r.target_position)
	var p = b.to_byte_array()
	poly.surface_update_vertex_region(0,0,p)
	if foundPlayer:
		state = states.lookstate
		pass
	else:
		state = states.wanderstate
	statefunc()
