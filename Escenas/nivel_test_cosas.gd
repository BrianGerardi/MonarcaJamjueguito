extends Node3D

@onready var camara_ver_tele : Camera3D= %CameraTele
var animacion_ver_tele : bool = false
var target_camara_position : Vector3

func _ready() -> void:
	Global.poner_vhs_tv.connect(_on_poner_vhs)

func _physics_process(delta: float) -> void:
	if animacion_ver_tele:
		camara_ver_tele.global_position = camara_ver_tele.global_position.lerp(target_camara_position, 0.05 * delta * 60)

func _on_poner_vhs():
	%AnimationTele.play("poner_vhs")
	%CameraTransition.transition_camera3D(Global.get_camara_principal(),camara_ver_tele)
