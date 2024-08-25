class_name Player extends CharacterBody3D

signal foundcheck
@export_group("falling")
@export var maxisafefalldistance:float
@export_group("jump")
@export var jumpness:float
@export var minijumpness:float
@export_group("movement")
@export var minispeed:float
@export var accelry:float
@export var deaccelry:float
@export var maxispeed:float
@export_group("crouching")
@export var defheight = 3
@export var crouchheight = 1
@export_group("stepping and sliding")
@export var slidingsloprrad:float
@export var maxstephight:float
@export_group("camerasettings")
@export var sensy:float = 0.1
@export var bobfreq:float
@export var bobamp:float

var speed:float
var slidespeed:float

var currentstephight:float
var canslide:bool
var cansprint:bool
var canmove:bool = true
var canjump:bool

var sprinting:bool = false
var jumped:bool = false
var falling:bool = false
var sliding:bool= false
var climbing:bool = false

var bobbers:float

const gravity:float = 45
const max_energy:float = 250

var energyvalue:float:
	set(new):energyvalue = clamp(new,0,max_energy)

var gravec:Vector3
var falldistance:float

enum ground {
	grounded,
	midair,
	}
var groundstate:ground = ground.midair
enum crouchstate {
	crouching,
	standing,
	}
var c_mode:crouchstate = crouchstate.standing
@onready var cam = $cambase/Camera3D
@onready var cansprinttimer:SceneTreeTimer


func _ready() -> void:
	falldistance = gravec.y
	speed = minispeed
	energyvalue = max_energy
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	cansprinttimer = get_tree().create_timer(0.25)
	rotation.y = deg_to_rad(-180)
	
func _input(event):
	if event is InputEventMouseMotion:
		var event_mouse_motion = event as InputEventMouseMotion
		rotation.y += deg_to_rad(-event_mouse_motion.relative.x * sensy)
		cam.rotation.x += deg_to_rad(-event_mouse_motion.relative.y * sensy)
		cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	
func _process(delta:float)->void:
	move(delta)
	check()
	crouch()
	match groundstate:
		ground.grounded: 
			jump()
		ground.midair:
			fall(delta)
	velocity.y = gravec.y
	
func move(delta)->void:
	var inputmove:Vector3 = Vector3(Input.get_axis("left","right"),0,Input.get_axis("forward","backward")).rotated(Vector3.UP,rotation.y)*int(canmove)
	if inputmove:
		velocity.x = velocity.move_toward(inputmove * speed, accelry * delta).x
		velocity.z = velocity.move_toward(inputmove * speed, accelry * delta).z
	else:
		if sliding  and get_floor_angle() >= slidingsloprrad:
			velocity += get_floor_normal() * slidespeed * delta * 10
			velocity.y -= abs(gravec.y)
		else:
			velocity.x = velocity.move_toward(Vector3.ZERO, deaccelry * delta).x
			velocity.z = velocity.move_toward(Vector3.ZERO, deaccelry * delta).z
	
	sprint(inputmove)
	step()
	cam.position = camanimF(delta)
	velocity.normalized()
	move_and_slide()
	
func sprint(inputmove:Vector3)->void:
	if Input.is_action_just_pressed("forward"):
		if cansprint:
			sprinting = true
		else:
			cansprint = true
			cansprinttimer = get_tree().create_timer(0.25)
	elif Input.is_action_just_released("forward"):
		if sprinting:
			sprinting = false
	if!sliding:
		if sprinting and energyvalue:
			speed = maxispeed
			energyvalue -= 0.5
		else:
			speed = minispeed
			if !inputmove:
				energyvalue += 0.5
	if cansprinttimer.time_left == 0:
		cansprint = false
	
func fall(delta:float):
	if !climbing:
		canjump = true
		falling = true
		gravec.y -= gravity * delta
		falldistance = abs(gravec.y) *delta
		if is_on_ceiling():
			gravec.y = -gravity * delta
		if Input.is_action_just_released("jump")and jumped:
			if gravec.y > minijumpness:
				gravec.y = minijumpness
			jumped = false
		if is_on_floor():
			felldown()
	else:
		falling = false
		gravec.y = Input.get_axis("crouch","jump") * speed 
		falldistance = 0
		canjump = false
		

func felldown():
	falling = false
	if falldistance >= maxisafefalldistance:energyvalue -= falldistance - maxisafefalldistance
	groundstate= ground.grounded
	falldistance = 0
	if get_floor_angle()<=slidingsloprrad:
		gravec.y = 0

func jump():
	if Input.is_action_pressed("jump") and canjump:
		gravec.y = jumpness
		jumped = true
		c_mode = crouchstate.standing
	if !is_on_floor():
		groundstate = ground.midair
		
func slide():
	if sliding == true:
		slidespeed += (get_floor_normal().y + velocity.length())
		slidespeed = clamp(slidespeed,0,12)
	if get_floor_angle() <= slidingsloprrad:
		slidespeed -= 0.04
		sliding = false
		canslide = false
		canmove = true
	if canslide and is_on_floor() and get_floor_angle() > slidingsloprrad:
		sliding = true
	
func crouch():
	var tw:Tween
	if (Input.is_action_pressed("crouch") or $crouch_ray.is_colliding())and !climbing:
		c_mode = crouchstate.crouching
		tw = create_tween()
		tw.tween_property($cambase,"position:y",$CollisionShape3D.position.y*1.5,0.2)
	elif !Input.is_action_pressed("crouch") and !slide():
		c_mode = crouchstate.standing
		tw = create_tween()
		tw.tween_property($cambase,"position:y",$CollisionShape3D.position.y*1.5,0.2)
	$CollisionShape3D.position.y = $CollisionShape3D.shape.size.y /2
	$ShapeCast3D.shape.radius = 0.5
	$ShapeCast3D.position = $cambase.position + Vector3(Input.get_axis("left","right"),0,Input.get_axis("forward","backward")).normalized()
	$ShapeCast3D.target_position.y =-$CollisionShape3D.position.y +0.3
	match c_mode:
		crouchstate.standing:
			$CollisionShape3D.shape.size.y = defheight
			$crouch_ray.shape.size.y = 0
			$crouch_ray.position.y = defheight+ $crouch_ray.shape.size.y / 2
			$check_ray.position.y = $cambase.position.y
			maxstephight = 2
			canslide = false
			sliding = false
			canmove = true
			canjump = true
		crouchstate.crouching:
			maxstephight = 0.7
			$check_ray.position.y = $cambase.position.y
			$CollisionShape3D.shape.size.y = crouchheight
			$crouch_ray.shape.size.y = defheight - crouchheight
			$crouch_ray.position.y = crouchheight + $crouch_ray.shape.size.y / 2
			canslide = true
			slide()
	
func check():
	var headray =$check_ray
	headray.transform.basis= cam.transform.basis
	headray.transform.origin = cam.transform.origin
	if headray.is_colliding() and headray.get_collider().has_method("interact") : 
		emit_signal("foundcheck")
		if Input.is_action_just_pressed("check"):
			headray.get_collider().call("interact")
			
func camanimF(delta)->Vector3:
	var camanimV:Vector3 = Vector3(0,bobamp*sin(bobbers*bobfreq),0)
	var robob:float
	bobbers = fmod(bobbers,2*PI/bobfreq)
	bobbers += (Vector2(velocity.x,velocity.z).length()*delta+0.01)*int(is_on_floor())
	if !is_on_floor():
		robob = bobamp *delta*gravec.y/7.5
		if abs(robob) > 0.05:robob = 0
		if cam.rotation.x <= deg_to_rad(90) and cam.rotation.x >= deg_to_rad(-90):
			cam.rotation.x += robob 
	else:robob = 0
	return camanimV
func step():
	if $ShapeCast3D.is_colliding():
		var np =to_local($ShapeCast3D.get_collision_point(0))
		if is_on_floor():
			if np.y < maxstephight:
				position.y += (np.y)+0.1
