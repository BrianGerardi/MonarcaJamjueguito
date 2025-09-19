extends Node


var forzar_mouse_visible: bool =false #por si hay algun bug con el mouse cuando ponemos pausa y esas cosas
signal streamer_set_input_mode(estado_bool : bool)
signal mostrar_cursor_mano_abierta #escuchada por HUD
signal mostrar_cursor_punto #escuchada por HUD
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func modo_forzar_mouse_visible(estado: bool):
	forzar_mouse_visible = estado

func get_forzar_mouse_visible():
	return forzar_mouse_visible
