extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.set_player_escondido(true)
		Global.set_player_escondido(true)
		print("PLAYER ENTRO AL AREA SEGURA")


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.set_player_escondido(false)
		Global.set_player_escondido(false)
		print("PLAYER SALIO DEL AREA SEGURA")
	if body.is_in_group("enemigo"):
		if body.has_method("set_estado_desorientado"):
			body.set_estado_desorientado()
