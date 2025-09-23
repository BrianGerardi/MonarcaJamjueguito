extends CharacterBody3D


#@export var seguir_a_jugador_debug: bool = false
@onready var navigation_agent_enemigo: NavigationAgent3D = $NavigationAgentEnemigo
@export var velocidad_caminando : float = 5.0
@export var velocidad_corriendo : float = 7.2
@export var markers_patrullar : Node3D
var posiciones_markers = []
var target_position_nuevo : Vector3
@export var velocidad_de_rotacion : float = 1.3
@onready var ray_cast_busca_player: RayCast3D = %RayCastBuscaPlayer



func _ready() -> void:
	navigation_agent_enemigo.velocity_computed.connect(Callable(_on_velocity_computed))
	for hijo in markers_patrullar.get_children():
		posiciones_markers.append(hijo.global_position)
	seleccionar_target_aleatorio()
	set_movement_target(target_position_nuevo)

func set_movement_target(movement_target: Vector3):
	navigation_agent_enemigo.set_target_position(movement_target)

func _physics_process(delta):
	if NavigationServer3D.map_get_iteration_id(navigation_agent_enemigo.get_navigation_map()) == 0:
		return
	if navigation_agent_enemigo.is_navigation_finished(): #cuando el pj esta muuuy cerca del target se emite navigation finished
		seleccionar_target_aleatorio()
		set_movement_target(target_position_nuevo)
		return
	if esta_mirando_player():
		seguir_al_jugador()
	#si no mira player, solo patrulla
	var next_path_position: Vector3 = navigation_agent_enemigo.get_next_path_position()
	var direction = (next_path_position - global_transform.origin).normalized()
	
	if direction.length() > 0.01: #rotacion
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
	target_position_nuevo= posiciones_markers.pick_random()

func _on_timer_patrulla_timeout() -> void: #lo llamo una sola vez para que empiece a patrullar a los 4 segundos
	seleccionar_target_aleatorio() #esto setea target_position_nuevo
	set_movement_target(target_position_nuevo)


func seguir_al_jugador(): #esto despues seria un estado
	var posicion_jugador = Global.get_posicion_player()
	set_movement_target(posicion_jugador)


#llega a la pos del jugador. navigation termino
#pasarlo a patrullaje

func set_markers_enemigo(markers):
	markers_patrullar = markers

#TODO TERMINAR IA


func _on_visible_on_screen_notifier_3d_screen_entered() -> void:
	var player_position = Global.get_posicion_player()
#	Global.modificar_sanity.emit(-5)
	if global_position.distance_to(player_position) < 10:
		seguir_al_jugador()


func _on_area_enemigo_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		Global.modificar_sanity.emit(-25)


func esta_mirando_player():
	ray_cast_busca_player.target_position= Global.get_posicion_player() - ray_cast_busca_player.global_position
	ray_cast_busca_player.force_raycast_update()
	
	if ray_cast_busca_player.is_colliding():
		var collider = ray_cast_busca_player.get_collider()
		if collider.is_in_group("player"):
			return true
	return false
