extends Node3D

@onready var camara_ver_tele : Camera3D= %CameraTele

func _ready() -> void:
	Global.poner_vhs_tv.connect(_on_poner_vhs)


func _on_poner_vhs():
	%AnimationTele.play("poner_vhs")
	%CameraTransition.transition_camera3D(Global.get_camara_principal(),camara_ver_tele)
