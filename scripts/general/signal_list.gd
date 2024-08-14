extends Node2D

signal Dial(key,file)
signal Cut(animname,animator)
func send_dialogue(key,file):
	emit_signal("Dial",key,file)
func start_cutscene(animname,animator:AnimationPlayer):
	emit_signal("cut",animname,animator)
