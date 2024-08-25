extends AudioStreamPlayer3D
var h:float = 0.5
var l:float = 0.5 
var g:float = 0
var p
var higher
var belower 
var fronter
func _init():
	AudioServer.add_bus()
	AudioServer.add_bus_effect(AudioServer.bus_count-1,AudioEffectLowShelfFilter.new())
	AudioServer.add_bus_effect(AudioServer.bus_count-1,AudioEffectHighShelfFilter.new())
	AudioServer.add_bus_effect(AudioServer.bus_count-1,AudioEffectPanner.new())
	bus = AudioServer.get_bus_name(AudioServer.bus_count-1)
	AudioServer.set_bus_send(AudioServer.get_bus_index(bus),"Audio")
	higher = AudioServer.get_bus_effect(AudioServer.get_bus_index(bus), 0) as AudioEffectLowShelfFilter
	belower = AudioServer.get_bus_effect(AudioServer.get_bus_index(bus), 1) as AudioEffectHighShelfFilter
	higher.gain = 0.4
	belower.gain = 0.6
	self.connect("tree_exited",Callable(self,"_on_tree_exited"))
	p = get_parent().get_parent().get_parent().get_parent().get_parent().get_node("player").get_node("cambase/Camera3D")
func _process(_delta):
	var diff = (global_position - p.global_position).normalized().rotated(Vector3.UP,p.rotation.x)
	var diffex = (global_position - p.global_position).normalized().rotated(Vector3.UP,p.rotation.y)
	unit_size = lerpf(1,10,g)
	higher.cutoff_hz =lerpf(1,400,h)
	belower.cutoff_hz =lerpf(2000,20500,l)
	h =clampf((1 + diff.z)/2,0,1)
	l =clampf((1 + diff.z)/2,0,1)
	g =clampf((1 + diffex.z)/2,0,1)

func _on_tree_exited():
	AudioServer.remove_bus(AudioServer.get_bus_index(bus))
