extends Control


var escena_nivel_principal = "res://Escenas/elegir_arma.tscn"
var icono_cursor = load("res://Assets/cursores mouse/pointer_a.svg")
var mute : bool = false

func _ready() -> void:
#	Input.set_custom_mouse_cursor(icono_cursor)
	%MusicaDeFondo.play()

func _on_opciones_pressed() -> void:
	$OpcionesPanel.visible = true
	$MenuPrincipal/VBoxContainer.visible = false


func _on_volver_pressed() -> void:
	$OpcionesPanel.visible = false


func _on_volumen_pressed() -> void:
	$Volumen.visible = true
	$Volumen/VBoxContainer/VolverVolumenes.visible = true

func _on_volver_volumenes_pressed() -> void:
	$Volumen/VBoxContainer/VolverVolumenes.visible = false
	$Volumen.visible = false
	$MenuPrincipal/VBoxContainer.visible = true


func _on_mute_on_pressed() -> void:
	$MenuPrincipal/MuteOn.visible = false
	$MenuPrincipal/MuteOff.visible = true
	mute = !mute
	%MusicaDeFondo.stream_paused= mute


func _on_mute_off_pressed() -> void:
	$MenuPrincipal/MuteOff.visible = false
	$MenuPrincipal/MuteOn.visible = true
	mute = !mute
	%MusicaDeFondo.stream_paused= mute


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_play_pressed() -> void:
	print("aprete play")
	get_tree().change_scene_to_file(escena_nivel_principal)
