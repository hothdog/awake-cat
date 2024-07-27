extends CanvasLayer

var boll:bool = false
@onready var cross_hair = $cross_hair
@onready var energy_bar = $energy_bar
@onready var player = get_parent()
@onready var dialoguer = $dialogue_player
var energy_bar_animator:Tween
var energy_bar_fade_timer:SceneTreeTimer
var oldenergy:float = Player.max_energy
func _ready():
	cross_hair.position = get_window().size / 2
	energy_bar.position = Vector2(15,15)
func _process(_delta):
		energy_bar_animator = get_tree().create_tween()
		energy_bar_animator.tween_property(energy_bar,"scale",Vector2(player.energyvalue/200,energy_bar.scale.y),2)
		if oldenergy != player.energyvalue:
			oldenergy = player.energyvalue
			energy_bar_animator = get_tree().create_tween()
			energy_bar_animator.tween_property(energy_bar,"color:a",1,0.2)
			energy_bar_fade_timer = get_tree().create_timer(1.2)
		if energy_bar_fade_timer and energy_bar_fade_timer.time_left == 0:
			energy_bar_animator = get_tree().create_tween()
			energy_bar_animator.tween_property(energy_bar,"color:a",0,2)
func _on_player_foundcheck():
	if boll == true:
		energy_bar_animator = get_tree().create_tween()
		energy_bar_animator.tween_property(cross_hair,"rotation",deg_to_rad(90),0.2)
		boll = false
	else:
		energy_bar_animator = get_tree().create_tween()
		energy_bar_animator.tween_property(cross_hair,"rotation",deg_to_rad(0),0.2)
		boll = true
