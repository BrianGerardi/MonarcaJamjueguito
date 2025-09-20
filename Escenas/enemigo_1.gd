extends CharacterBody3D


#@export var seguir_a_jugador_debug: bool = false
@onready var navigation_agent_enemigo: NavigationAgent3D = $NavigationAgentEnemigo
@export var velocidad_caminando : float = 5.0
@export var velocidad_corriendo : float = 7.2
@onready var posiciones_test = [%MarkerEnemigo1.global_position, %MarkerEnemigo2.global_position,%MarkerEnemigo3.global_position]
var target_position_nuevo : Vector3
@export var velocidad_de_rotacion : float = 1.3

func _ready() -> void:
	navigation_agent_enemigo.velocity_computed.connect(Callable(_on_velocity_computed))

func set_movement_target(movement_target: Vector3):
	navigation_agent_enemigo.set_target_position(movement_target)

func _physics_process(delta):
	if NavigationServer3D.map_get_iteration_id(navigation_agent_enemigo.get_navigation_map()) == 0:
		return
	if navigation_agent_enemigo.is_navigation_finished(): #cuando el pj esta muuuy cerca del target se emite navigation finished
		return
	
	#if seguir_al_jugador():
		#seguir_al_jugador()
		#$TimerPatrulla.paused = true
	
	var next_path_position: Vector3 = navigation_agent_enemigo.get_next_path_position()
	var direction = (next_path_position - global_transform.origin).normalized()
	
	if direction.length() > 0.01:
		var target_rotation: Vector3 = Vector3(0, atan2(direction.x, direction.z), 0)
		rotation.y = lerp_angle(rotation.y, target_rotation.y, delta * velocidad_de_rotacion) 
	
	
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * velocidad_caminando
	if navigation_agent_enemigo.avoidance_enabled: #avoidance es util para cuando hay otros npc, sino no, pero por las dudas lo dejo
		navigation_agent_enemigo.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

func _on_velocity_computed(safe_velocity: Vector3):
	velocity = safe_velocity
	move_and_slide()


func seleccionar_target_aleatorio():
	target_position_nuevo= posiciones_test.pick_random()

func _on_timer_patrulla_timeout() -> void:
	seleccionar_target_aleatorio()
	set_movement_target(target_position_nuevo)


func seguir_al_jugador(): #esto despues seria un estado
	var posicion_jugador = Global.get_posicion_player()
	set_movement_target(posicion_jugador)
