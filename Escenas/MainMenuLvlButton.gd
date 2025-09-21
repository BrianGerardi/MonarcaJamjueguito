extends Button

@export var nivel_path: String

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	get_tree().change_scene_to_file(nivel_path)
