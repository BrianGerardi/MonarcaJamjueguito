extends CharacterBody3D


#@export var seguir_a_jugador_debug: bool = false
@onready var navigation_agent_enemigo: NavigationAgent3D = $NavigationAgentEnemigo
@export var velocidad_caminando : float = 5.0
@export var velocidad_corriendo : float = 7.2
@export var markers_patrullar : Node3D
@export var vision_distancia_maxima: float = 20.0
@export var vision_angulo_grados: float = 60.0 # campo de visión
var posicion_jugador_global : Vector3
var posiciones_markers = []
var target_position_nuevo : Vector3
var persiguiendo: bool = false
@export var velocidad_de_rotacion : float = 1.3
@onready var ray_cast_busca_player: RayCast3D = %RayCastBuscaPlayer



func _ready() -> void:
	posicion_jugador_global = Global.get_posicion_player()
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
	
	posicion_jugador_global = Global.get_posicion_player()
	if esta_mirando_player():
		persiguiendo = true
	else:#si no mira player, solo patrulla
		
		if persiguiendo and global_position.distance_to(posicion_jugador_global) < vision_distancia_maxima * 1.5:
			pass
		else:
			persiguiendo = false
		
		if persiguiendo:
			seguir_al_jugador()
			var next_path_position: Vector3 = navigation_agent_enemigo.get_next_path_position()
		else:
			if navigation_agent_enemigo.is_navigation_finished(): #cuando el pj esta muuuy cerca del target se emite navigation finished
				seleccionar_target_aleatorio()
				set_movement_target(target_position_nuevo)
		#	seguir_al_jugador() #probando
	
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
	print("DEBERIA ESTAR SIGUIENDO AL JUGADORRRRRRRR")
	set_movement_target(posicion_jugador_global)


func set_markers_enemigo(markers):
	markers_patrullar = markers



func _on_visible_on_screen_notifier_3d_screen_entered() -> void:
	if global_position.distance_to(posicion_jugador_global) < 30:
		print("viste al enemigo")
		Global.modificar_sanity.emit(-5)
		persiguiendo = true
		seguir_al_jugador()


func _on_area_enemigo_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		Global.modificar_sanity.emit(-25)


func esta_mirando_player():
	var posicion_enemigo : Vector3 = global_position
	
	var vec_to_player: Vector3 = posicion_jugador_global - posicion_enemigo
	var dist = vec_to_player.length()
	if dist > vision_distancia_maxima:
		return false #no lo persigo pq esta lejos
	
	# 2. Ángulo / Frente
	# frente del enemigo: ahora mismo es el eje z
	var frente_enemigo: Vector3 = -transform.basis.z.normalized()
	var dir_norm: Vector3 = vec_to_player.normalized()
	var producto_punto_vector = frente_enemigo.dot(dir_norm)
	
	# para convertir el ángulo permitido a producto punto mínimo: si ángulo_grados = 60, el dot mínimo = cos(60°)
	var cos_threshold = cos(deg_to_rad(vision_angulo_grados))
	if producto_punto_vector < cos_threshold:
		return false
	
	# 3. Raycast para ver si hay obstáculos
	ray_cast_busca_player.target_position = dir_norm * vision_distancia_maxima
	ray_cast_busca_player.force_raycast_update()
	
	if ray_cast_busca_player.is_colliding():
		var collider = ray_cast_busca_player.get_collider()
		if collider.is_in_group("player"):
			return true
	return false
