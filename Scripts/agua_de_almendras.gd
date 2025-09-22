extends Node3D


@export var cant_aumento_sanity : int = 1

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_3d_agua_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		Global.aumentar_sanity.emit(cant_aumento_sanity)
		queue_free()
