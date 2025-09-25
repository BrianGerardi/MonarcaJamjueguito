extends CharacterBody3D


#@export var seguir_a_jugador_debug: bool = false
@onready var navigation_agent_enemigo: NavigationAgent3D = $NavigationAgentEnemigo
@export var velocidad_caminando : float = 3.0
@export var velocidad_corriendo : float = 5.0
var velocidad_actual : float
@export var markers_patrullar : Node3D
var posicion_jugador_global : Vector3
var posiciones_markers = []
var target_position_nuevo : Vector3
enum estados_enemigo {
patrullando,
persiguiendo,
desorientado, #todavia sin uso, pero estaria bueno que cuando lo perdes de vista se vea una animacion d desorientado
quieto
}
var estado_actual : estados_enemigo
@export var velocidad_de_rotacion : float = 1.5



func _ready() -> void:
	posicion_jugador_global = Global.get_posicion_player()
#	navigation_agent_enemigo.velocity_computed.connect(Callable(_on_velocity_computed))
	for hijo in markers_patrullar.get_children():
		posiciones_markers.append(hijo.global_position)
#	print("el array tiene los siguientes valores ", posiciones_markers) 
	estado_actual = estados_enemigo.patrullando


func _physics_process(delta):
	if NavigationServer3D.map_get_iteration_id(navigation_agent_enemigo.get_navigation_map()) == 0:
		return
	
	posicion_jugador_global = Global.get_posicion_player()
	print("POSICION DEL JUGADOR VALE: ", posicion_jugador_global)
	if navigation_agent_enemigo.is_navigation_finished(): #cuando el pj esta muuuy cerca del target se emite navigation finished
		match estado_actual:
			estados_enemigo.patrullando: #si estaba patruyando que siga patruyando
				empezar_a_patrullar()
			estados_enemigo.persiguiendo:
				#significa que alcanzo al player
				if !Global.player_esta_escondido():
					print("toco al player")
					Global.game_over.emit() #todavia no hace nada
				else:
					estado_actual = estados_enemigo.desorientado
	
	match estado_actual:
		estados_enemigo.patrullando:
			velocidad_actual = velocidad_caminando
			if %VisibleOnScreenNotifier3D.is_on_screen(): #lo estoy mirando
				if global_position.distance_to(posicion_jugador_global) < 35: #y ademas esta cerca
					vi_al_enemigo_cerca()
		estados_enemigo.persiguiendo:
			print("-------- ESTADO PERSIGUIENDOOOOOOOOOOO. .................................................")
			seguir_al_jugador() #esto actualiza siempre la posicion
			velocidad_actual = velocidad_corriendo
			#tambien animacion para cuando la tengamos
			if global_position.distance_to(posicion_jugador_global) > 100: #si lo estaba persiguiendo pero se me fue lejos
				print("DEJAR DE PERSEGUIRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR")
				estado_actual = estados_enemigo.desorientado
				#TODO ARREGLAR
		estados_enemigo.desorientado:
			velocidad_actual = 0.0
			#animacion de desorientado o idle
			%TimerDesorientado.start() #aca va a esperar 3 segunditos y se va a ir a patrullar de nuevo
			estado_actual = estados_enemigo.quieto
		estados_enemigo.quieto:
			#solo animacion de idle cuando la tengamos
			pass

	var next_path_position: Vector3 = navigation_agent_enemigo.get_next_path_position()
	var direction = (next_path_position - global_transform.origin).normalized()
	rotar_enemigo(direction, delta)
	velocity = direction * velocidad_actual
	move_and_slide()


#func _on_velocity_computed(safe_velocity: Vector3):
	#velocity = safe_velocity
	#move_and_slide()

func set_target_position_enemigo(movement_target: Vector3):
	navigation_agent_enemigo.set_target_position(movement_target)

func empezar_a_patrullar():
	seleccionar_target_aleatorio()
	set_target_position_enemigo(target_position_nuevo)

func seleccionar_target_aleatorio():
	target_position_nuevo= posiciones_markers.pick_random()
	

func _on_timer_patrulla_timeout() -> void: #lo llamo una sola vez para que empiece a patrullar a los 4 segundos
	seleccionar_target_aleatorio() #esto setea target_position_nuevo
	set_target_position_enemigo(target_position_nuevo)


func seguir_al_jugador(): #esto despues seria un estado
#	print("ESTA SIGUIENDO AL JUGADOR")
	set_target_position_enemigo(posicion_jugador_global)


func set_markers_enemigo(markers):
	markers_patrullar = markers



func _on_visible_on_screen_notifier_3d_screen_entered() -> void:
	#avisa si estoy viendo al enemigo
	if global_position.distance_to(posicion_jugador_global) < 35: #ademas de verlo, esta cerca
		print("viste al enemigo -----------------------------------------------------------")
		Global.modificar_sanity.emit(-5)
		estado_actual = estados_enemigo.persiguiendo
		if %AudioPerseguir.playing==false:
			%AudioPerseguir.play()


func _on_area_enemigo_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		print("ENTRO AL AREA DEL ENEMIGO")
		Global.modificar_sanity.emit(-25)
		if estado_actual== estados_enemigo.patrullando:
			Global.modificar_sanity.emit(-25)
			estado_actual = estados_enemigo.persiguiendo
			if %AudioPerseguir.playing==false:
				%AudioPerseguir.play()


func rotar_enemigo(direction, delta):
	if direction.length() > 0.01: #rotacion
		var target_rotation: Vector3 = Vector3(0, atan2(direction.x, direction.z), 0)
		rotation.y = lerp_angle(rotation.y, target_rotation.y, delta * velocidad_de_rotacion)


func set_estado_desorientado(): #se llama desde area segura
	estado_actual = estados_enemigo.desorientado

#simplificar
#1 - si ves al enemigo y esta cerca, ponele unos 50 metros, te persigue
#2- si pasa muuuy cerca tuyo, te persigue aunque no lo hayas visto
#3- si no te persigue esta siempre patruyando, porque asi justamente es posible que lo encuentres
#4- si te persigue y te alejas muuuuucho mucho, vuelve al estado de patrullar


func _on_timer_desorientado_timeout() -> void:
	print("sono el timer")
	estado_actual = estados_enemigo.patrullando
	empezar_a_patrullar()


func vi_al_enemigo_cerca():
	print("viste al enemigo")
	Global.modificar_sanity.emit(-5)
	estado_actual = estados_enemigo.persiguiendo
	if %AudioPerseguir.playing==false:
		%AudioPerseguir.play()


func _on_timer_audio_miedo_timeout() -> void:
	var probabilidad : int = randi_range(1,100)
	if probabilidad>40:
		%AudioMiedoAleatorio.play()
