extends Node3D

@export var cant_aumento_sanity : int = 15

func _ready() -> void:
	pass # Replace with function body.




func _on_area_3d_agua_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		Global.modificar_sanity.emit(cant_aumento_sanity)
		body.tomar_agua()
		queue_free()


#func interactuar():
	#if Hud.add_item(item_data):
		#call_deferred("queue_free")
	#else:
		#print("inventario lleno")
	#
