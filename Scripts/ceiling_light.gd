extends Node3D

@export var flicker_enabled: bool = true     # Para activar/desactivar desde el inspector
@export var flicker_speed: float = 0.5       # Velocidad del parpadeo (segundos)
@export var audio_luz : AudioStreamPlayer3D
@onready var omni_light: OmniLight3D = $OmniLight3D
@onready var mesh: MeshInstance3D = $MeshInstance3D

var emissive_material: StandardMaterial3D
var is_on: bool = true
var timer: Timer

func _ready():
	# Duplicar material para no afectar al recurso original
	emissive_material = mesh.get_active_material(0).duplicate()
	mesh.set_surface_override_material(0, emissive_material)

	# Crear timer
	timer = Timer.new()
	timer.wait_time = flicker_speed
	timer.autostart = flicker_enabled
	timer.one_shot = false
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)

	# Si está desactivado en inspector, forzar todo prendido
	if not flicker_enabled:
		_set_light_state(true)

func _on_timer_timeout():
	if flicker_enabled:
		is_on = !is_on
		_set_light_state(is_on)

func _set_light_state(state: bool):
	omni_light.visible = state
	emissive_material.emission_enabled = state
	if state:
		emissive_material.emission = Color(1, 1, 0.6) # amarillento
		emissive_material.emission_energy = 2.0


func _on_audio_luz_finished() -> void:
	if audio_luz != null:
		audio_luz.play()
