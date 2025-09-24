extends Node


signal modificar_sanity(cantidad : float) 
signal poner_vhs_tv
var forzar_mouse_visible: bool =false #por si hay algun bug con el mouse cuando ponemos pausa y esas cosas
signal streamer_set_input_mode(estado_bool : bool)
signal mostrar_cursor_mano_abierta #escuchada por HUD
signal mostrar_cursor_punto #escuchada por HUD
signal game_over
var posicion_player : Vector3 = Vector3.ZERO
var camara_principal : Camera3D

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func modo_forzar_mouse_visible(estado: bool):
	forzar_mouse_visible = estado

func get_forzar_mouse_visible():
	return forzar_mouse_visible


func get_posicion_player():
	return posicion_player

func set_posicion_player(posicion_nueva : Vector3):
	posicion_player = posicion_nueva


func set_camara_principal(camara : Camera3D):
	camara_principal = camara

func get_camara_principal():
	return camara_principal
