extends Node2D

signal Dial(key,file)
func send_dialogue(key,file):
	emit_signal("Dial",key,file)
