extends Node2D


func _ready() -> void:
	%UI.hide()
	Global.pausa.connect(_on_pausa)

func esconder_menu():
	%UI.hide()


func _on_pausa():
	pass
	%UI.visible = !%UI.visible


func _on_salir_pressed() -> void:
	get_tree().quit()
