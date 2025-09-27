extends Node2D




func _ready() -> void:
	%UI.hide()
	Global.pausa.connect(_on_pausa)

func esconder_menu():
	%UI.hide()


func _on_pausa():
	%UI.visible = !%UI.visible
