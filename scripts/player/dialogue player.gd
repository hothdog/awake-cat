extends Node2D

signal button_pressed(title: String)

var t:String = ""
var k:float = 1
var keyn:String = ""
var index:int = 0
var buttons:Array =[]
var timer:SceneTreeTimer
#@onready var backround = $backround
@onready var label = $RichTextLabel
var listed_pause_char = ".!?,"
var typing = false
var dic:Dictionary = {}
func _ready():
	def_dio()
	Dialogue.connect("Dial",Callable(self,"dio_start"))
func dio_start(key,d_file):
	if keyn == "":
		#backround.visible = true
		var f = FileAccess.open(d_file,FileAccess.READ)
		dic = JSON.parse_string(f.get_as_text())
		f.close()
		if typeof(dic[key][index])==TYPE_DICTIONARY:
			if dic[key][index].has("voice"):
				$AudioStreamPlayer.stream = load(dic[key][index]["voice"])
			else:
				$AudioStreamPlayer.stream = load("res://resourses/basic_hi1.mp3")
			if dic[key][index].has("time"):
				k = dic[key][index].time
			else:
				k = 1
		else:
			$AudioStreamPlayer.stream = load("res://resourses/basic_hi1.mp3")
			k = 1
		$AudioStreamPlayer.play()
		label.text = "[center]"+dic[key][index].text if typeof(dic[key][index])==TYPE_DICTIONARY else dic[key][index]  +"[/center]"
		label.visible_characters = 0
		typing = true
		keyn = key
		#get_tree().paused = true
		timer = get_tree().create_timer(k)
func _process(_delta):
	if typing == true:
		if label.visible_characters > label.get_total_character_count():
			if timer.time_left == 0 and keyn in dic:
				label.visible_characters = 0
				index += 1
				if typeof(dic[keyn][index])== TYPE_STRING and index < dic[keyn].size()-1:
					$AudioStreamPlayer.stream = load("res://resourses/basic_hi1.mp3")
					$AudioStreamPlayer.play()
					label.text = "[center]"+ dic[keyn][index]+"[/center]"
					k = 3
				elif typeof(dic[keyn][index])== TYPE_DICTIONARY:
					if dic[keyn][index].has("voice"):
						$AudioStreamPlayer.stream = load(str(dic[keyn][index]["voice"]))
					else:
						$AudioStreamPlayer.stream = load("res://resourses/basic_hi1.mp3")
					$AudioStreamPlayer.play()
					label.text = "[center]"+ dic[keyn][index]["text"]+"[/center]"
					if dic[keyn][index].has("time"):
						k= dic[keyn][index]["time"]
					else:
						k = 3
					
					#Input.mouse_mode = Input.MOUSE_MODE_CONFINED
					#dic= dic[keyn][index]
					#index= -1
					#keyn = t
					#label.text = dic[keyn][index] if t in dic.keys() else ""
					#choice(dic)
				else:
					def_dio()
				timer = get_tree().create_timer(k)
		else:
			label.visible_characters += 1
func def_dio():
	#backround.visible = false
	label.text = ""
	typing = false
	keyn = ""
	#get_tree().paused = false
	index = 0

#func choice(de:Dictionary):
	#var y_position = 0
	#for i in de.keys():
		#var button = Button.new()
		#button.size = Vector2(20,5)
		#button.flat = true
		##backround.position + Vector2(...)
		#button.position = Vector2(10, y_position * 30 + 20)
		#button.connect("pressed", Callable(self, "_on_Button_pressed").bind(i))
		#button.text = "-" + i
		#add_child(button)
		#buttons.append(button)
		#y_position += 1
	#buttons[0].grab_focus()
#func clear_choice():
	#for i in buttons:
		#i.call_deferred("free")
	#buttons.clear()
	#t = ""
#func _on_Button_pressed(title):
	#timer = get_tree().create_timer(1)
	#t = title
	#emit_signal("button_pressed", title)
	#keyn = title
	#index = 0
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#if keyn in dic:
		#if label.text == dic[keyn][index]:
			#label.visible_characters = 0
		#label.text = dic[keyn][index]
		#typing = true
		#clear_choice()
	#else:
		#def_dio()
		#clear_choice()
