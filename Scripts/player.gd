extends CharacterBody3D

var velocidad := 5.0 #velocidad actual
@export var camara_zoom_normal : float = 70
@export var camara_zoom_maximo : float = 15
@export var velocidad_zoom: float = 27
@onready var collision_parado: CollisionShape3D = %CollisionParado
@onready var collision_agachado: CollisionShape3D = %CollisionAgachado
var zoom_actual : float
var haciendo_zoom : bool = false
@onready var audio_zoom: AudioStreamPlayer = %AudioZoom
@export var velocidad_corriendo :float= 7.9
@export var velocidad_caminando :float= 5.0
@export var velocidad_agachado :float= 3
@export var JUMP_VELOCITY := 5.5
@export var sensibilidad_mouse : float = 0.1 #podriamos hacer que se pueda cambiar en settings
@onready var cabeza_pivot : Node3D = %PivotCamara
@onready var camara : Camera3D = %CameraPrincipal
@onready var raycast_objetos : RayCast3D= %RayCastMano
@onready var mano_marker : Marker3D= %MarkerPosicionObjetos
@export var HUD : Control
@export var velocidad_head_bob : float = 2.0
@export var amplitud_head_bob : float = 0.04
var tiempo_head_bob: float = 0.0
var mostrar_mouse: bool = false
var objeto_señalado_actualmente = null
var posicion_pivot_camara_inicial :Vector3 #lo uso para cuando se agacha pq sino se me bugueaba
var posicion_pivot_camara_agachado : Vector3 = Vector3(0, 1.332, -0.137) #same con el de arriba, para agacharse
var objeto_interactuado : RigidBody3D = null #NOTAAAAAAA ------ Solo podemos agarrar RIGIDBODYS
var esta_agachado : bool = false
var rotacion_relativa_objeto : Quaternion #si, esto es basicamente brujeria brian
var player_escondido: bool = false
#vamo que ganamos la jam loco vamo

func _ready() -> void:
	collision_agachado.disabled = true
	zoom_actual = camara_zoom_normal
	Global.set_camara_principal(camara) #se usa para transiciones de camara
	Global.poner_vhs_tv.connect(_on_poner_vhs_tv)
	Global.streamer_set_input_mode.connect(_cambiar_set_input_mode) #por ahora sin uso pero por las dudas
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) #captura al mouse para que no salga de la pantalla
	posicion_pivot_camara_inicial = cabeza_pivot.position #para cuando se agacha


func _input(event) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
	#	print("EL MOUSE ESTA EN MODO VISIBLEEEEE")
		return
	if event is InputEventMouseMotion and mostrar_mouse == false: #si esta moviendo el mouse y esta en modo captured
	#	movimiento de camara con el mouse
		rotate_y(deg_to_rad(-event.relative.x * sensibilidad_mouse))
		cabeza_pivot.rotate_x(deg_to_rad(-event.relative.y * sensibilidad_mouse))
		cabeza_pivot.rotation.x = clamp(cabeza_pivot.rotation.x, deg_to_rad(-89), deg_to_rad(89)) #para limitar la rotacion

	if Input.is_action_pressed("control"):
		esta_agachado = true
		activar_collision_agachado()
	elif Input.is_action_just_released("control") and esta_agachado:
		esta_agachado = false
		activar_collision_parado()

func interactuar_con_objeto():
	var objeto_colisionando = raycast_objetos.get_collider()
	if objeto_colisionando != null and objeto_colisionando.is_in_group("interactuable"):
		objeto_interactuado = objeto_colisionando
		if objeto_interactuado.has_method("cambiar_esta_agarrado"): #sin uso todavia pero puede ser muuuuy util
			objeto_interactuado.cambiar_esta_agarrado(true)
		#el resto es asegurar que las rotaciones se vean bien cuando lo agarramos
		var rot_camara := Quaternion(camara.global_transform.basis) #quaternios algun dia te entendere
		var rot_objeto := Quaternion(objeto_interactuado.global_transform.basis)
		rotacion_relativa_objeto = rot_camara.inverse() * rot_objeto #para mentener siempre la rotacion con la que estaba al agarrarlo


func esta_señalando_interactuable(): #para cambiar del cursor a la manito en el hud
	var objeto_colisionando = raycast_objetos.get_collider()
	if objeto_colisionando != null and objeto_colisionando.is_in_group("interactuable") and objeto_interactuado== null: 
		return true
	else:
		return false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta * 1.5 #un toque mas de gravedad pq sino se sentia fiero
	
	if Input.is_action_pressed("z"):
		print("RUEDA MOUSE ARRIBA PRESSED")
		aumentar_zoom_camara_op2(delta)
	if Input.is_action_just_released("z"):
		haciendo_zoom = false
		audio_zoom.stop()
	if Input.is_action_pressed("x"):
		quitar_zoom_camara(delta)
	if Input.is_action_just_released("x"):
		haciendo_zoom = false
		audio_zoom.stop()
	
	if !player_escondido:
		Global.set_posicion_player(global_position)
	
	if objeto_señalado_actualmente!= null and objeto_señalado_actualmente.is_in_group("presionar_f"):
		if objeto_señalado_actualmente.has_method("interactuar"):
			if Input.is_action_just_pressed("f"):
				objeto_señalado_actualmente.interactuar() #por si necesitamos usarlo mas adelante

	if Input.is_action_just_pressed("escape"): #para pausa y mostrar mouse # de ultima aca agregar que solamente intercambia el a captured de nuevo cosas externas
		if Global.get_forzar_mouse_visible() == true: #si esta en modo forzar visible
			print("Otra cosa esta mostrando el mouse, ignoro este escape")
		else:
			mostrar_mouse = !mostrar_mouse
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if mostrar_mouse else Input.MOUSE_MODE_CAPTURED)
			#el ternario es: resultado_si_verdadero if CONDICION else resultado_si_falso

	if Input.is_action_just_pressed("click_izquierdo"): #tambien podria pasarlo a dejar apretado el boton
		if objeto_interactuado==null: #si no esta interactuando con un objeto
			interactuar_con_objeto() 
		else:
			quitar_objeto()

	if Input.is_action_just_pressed("ui_accept") and is_on_floor(): #saltar
		velocity.y = JUMP_VELOCITY

	if Input.is_action_pressed("shift"): #correr
	#	print("SE PRESIONO EL SHIFT")
	#aca despues voy a agregar movimiento de camara onda balanceo
		velocidad = velocidad_corriendo
	else:
		velocidad = velocidad_caminando

	if esta_agachado: #agacharse
		cabeza_pivot.position = cabeza_pivot.position.move_toward(posicion_pivot_camara_agachado, 3 * delta)
		velocidad = velocidad_agachado
		#print("se esta agachando")
	else:
		cabeza_pivot.position = cabeza_pivot.position.move_toward(posicion_pivot_camara_inicial, 3 * delta)

	var input_dir := Input.get_vector("a", "d", "w", "s") #movimiento basico, wasd
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * velocidad
		velocity.z = direction.z * velocidad
	else:
		velocity.x = move_toward(velocity.x, 0, velocidad)
		velocity.z = move_toward(velocity.z, 0, velocidad)

	if esta_señalando_interactuable():
		Global.mostrar_cursor_mano_abierta.emit()
	else:
		Global.mostrar_cursor_punto.emit()

	if objeto_interactuado!= null: #si esta interactuando con un objeto / agarre un objeto
		var posicion_objeto_a = objeto_interactuado.global_transform.origin
		var posicion_mano_b = mano_marker.global_transform.origin
		agarrar_objeto_fisico(posicion_mano_b, posicion_objeto_a, delta)
		
		if posicion_objeto_a.distance_squared_to(posicion_mano_b) > 14: #esta bastante bien en 14 pero podemos regularlo
			print("Esta muy lejos quizas se atasco en una pared, quitar objeto")
			quitar_objeto()

	move_and_slide()
	tiempo_head_bob += delta * velocity.length() * float(is_on_floor())
	camara.transform.origin = headbob(tiempo_head_bob)



func headbob(tiempo_headbob):
	var headbob_position = Vector3.ZERO
	headbob_position.y = sin(tiempo_headbob * velocidad_head_bob) * amplitud_head_bob
	headbob_position.x = cos(tiempo_headbob * velocidad_head_bob / 2) * amplitud_head_bob
	return headbob_position


func quitar_objeto():
	print("SE EJECUTO QUITAR OBJETO")
	if objeto_interactuado!=null:
		if objeto_interactuado.has_method("cambiar_esta_agarrado"):
			objeto_interactuado.cambiar_esta_agarrado(false)
		var impulse := objeto_interactuado.linear_velocity * objeto_interactuado.mass
		impulse = impulse.limit_length(7.0) # Variar este valor según qué tan fuerte quiero que salga
		objeto_interactuado.apply_central_impulse(impulse)
		objeto_interactuado.angular_velocity = Vector3() #limpiamos la rotacion para q no salga volando
		objeto_interactuado = null
	#	$"../Example".mostrar_cursor_punto()
		%AudioSoltarObj.play() #debug nomas, podemos sacarlo despues



func agarrar_objeto_fisico(posicion_mano_b, posicion_objeto_a, delta): #se llama en el physics process
	# RESET de velocidades previas para evitar acumulación
	objeto_interactuado.linear_velocity = Vector3()
	objeto_interactuado.angular_velocity = Vector3()
	#------------ ROTACION ----------------
	var rot_camara := Quaternion(camara.global_transform.basis)
	var rot_deseada := rot_camara * rotacion_relativa_objeto
	var rot_actual := Quaternion(objeto_interactuado.global_transform.basis)
	var rot_diff := rot_deseada * rot_actual.inverse()
	# Aplico rotación como velocidad angular (más suave y controlada)
	objeto_interactuado.angular_velocity = rot_diff.get_euler() * 5.0
	#-----------------
	#---- nuevo en set linear velocity y lo viejo era esto: objeto_interactuado.set_linear_velocity((posicion_mano_b-posicion_objeto_a)* 2)
	#calculamos fuerzas fisicas en direccion de la mano
	var to_mano = posicion_mano_b - posicion_objeto_a
	var fuerza = to_mano / delta * 0.5 / objeto_interactuado.mass
	objeto_interactuado.linear_velocity = fuerza
	#si este codigo lo lee alguien le mandamos mil gracias al pibe que hizo una physics gun en godot jdasja


func _cambiar_set_input_mode(booleano : bool):
	$".".set_process_input(booleano)

func _on_poner_vhs_tv():
	quitar_objeto()

func aumentar_zoom_camara(delta : float):
	if zoom_actual<= camara_zoom_maximo:
		return
	zoom_actual -= delta * velocidad_zoom
	camara.fov = zoom_actual
	audio_zoom.play()

func quitar_zoom_camara(delta: float):
	if zoom_actual>= camara_zoom_normal:
		return
	zoom_actual += delta * velocidad_zoom
	camara.fov = zoom_actual
	if haciendo_zoom == false:
		audio_zoom.play()
	haciendo_zoom = true


func aumentar_zoom_camara_op2(delta : float):
	if zoom_actual<= camara_zoom_maximo:
		return
	camara.set_fov(lerp(camara.fov, camara_zoom_maximo, delta * 1.2))
	zoom_actual = camara.fov
	if haciendo_zoom == false:
		audio_zoom.play()
	haciendo_zoom = true

#mecanica de sanity - la camara indica sanity - se cura son botellas
#sanity aplicable en todos los niveles

func set_player_escondido(estado : bool): #agregas area3d 
	player_escondido = estado


func _on_timer_curar_sanity_timeout() -> void:
	var probabilidad : int = randi_range(1,100)
	if probabilidad>20:
		Global.modificar_sanity.emit(2) #curo de a 2 

func activar_collision_parado():
	collision_agachado.disabled= true
	collision_parado.disabled = false

func activar_collision_agachado():
	collision_parado.disabled = true
	collision_agachado.disabled= false
