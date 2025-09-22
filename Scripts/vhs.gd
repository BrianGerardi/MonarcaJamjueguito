extends RigidBody3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.poner_vhs_tv.connect(_on_poner_vhs)


func _on_poner_vhs():
	hide()
	await get_tree().create_timer(1).timeout
	queue_free()
