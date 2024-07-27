extends Node3D

@onready var player:CharacterBody3D = get_parent().get_parent().get_node("player")
@export var lookcone_width = deg_to_rad(25)
@export var lookcone_height = deg_to_rad(25)
@export var viewrange = 8
var rayspace = deg_to_rad(2.5)
var ray:RayCast3D
var hisrays:Array= []
var poly:ArrayMesh
enum states{lookstate,wanderstate}
var state = states.wanderstate
var arrays = []
var verts = PackedVector3Array()
var indices = PackedInt32Array()
var rays_width = lookcone_width / rayspace
var rays_height = lookcone_height / rayspace
var x:float = 0
@export var chacks_array:PackedVector3Array = [Vector3(0,0,0),Vector3(0,180,0)]
var index:int = -1
@export var speed = 0.5


func _ready() -> void:
	$RayCast3D.queue_free()
	generay()
	genefield()

func generay() -> void:
	var a = []
	poly = ArrayMesh.new()
	arrays.resize(Mesh.ARRAY_MAX)
	
	for j in range(rays_height):
		var newangle_height = rayspace * (j - rays_width / 2)
		for i in range(rays_width):
			ray = RayCast3D.new()
			var newangle_width = rayspace * (i - rays_width / 2)
			ray.target_position = Vector3(newangle_width, newangle_height, 1) * viewrange
			add_child(ray)
			hisrays.append(ray)
			a.append(ray.target_position)
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
	m.material_override = preload("res://resourses/mat.tres")
	add_child(m)
	
func genseq(W,H)-> Array:
	var seq=[]
	for i in range(W):
		seq.append(i)
	for i in range(W + (W-1), W*H, W):
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

func statefunc(delta:float):
	#var direction = player.global_position+Vector3(0,2,0)- global_position
	match state:
		states.wanderstate:
			var s = chacks_array[index]*PI/180-rotation
			if abs(s.length())>=0.02 :
				rotation += s.normalized() * delta * speed
			else:
				index = (index + 1) % chacks_array.size()
			rotation_degrees.y = fmod(rotation_degrees.y,360)
		states.lookstate:
			player.get_parent().get_node("CanvasLayer/AnimationPlayer").play("returning")
			await player.get_parent().get_node("CanvasLayer/AnimationPlayer").animation_finished
			player.position = get_parent().pp
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
	statefunc(_delta)
