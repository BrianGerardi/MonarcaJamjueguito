extends Node3D


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("jugador"):
		emit_signal("checkpoint_reached", global_transform.origin)
