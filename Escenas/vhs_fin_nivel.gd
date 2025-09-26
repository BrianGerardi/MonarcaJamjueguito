extends RigidBody3D


var nueva_escena  = "res://Escenas/nivel_test_cosas.tscn"

func _ready() -> void:
	pass # Replace with function body.


func cambiar_esta_agarrado(estado : bool):
	if estado == true:
		await get_tree().create_timer(2).timeout
		get_tree().change_scene_to_file(nueva_escena)
