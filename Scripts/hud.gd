extends Control


@export var cursor_mano_abierta : TextureRect
@export var cursor_punto : TextureRect
@onready var hbox_inventario: HBoxContainer = %HboxInventario


func _ready() -> void:
	Global.mostrar_cursor_mano_abierta.connect(mostrar_cursor_mano_ab)
	Global.mostrar_cursor_punto.connect(mostrar_cursor_punto)



func mostrar_cursor_mano_ab():
	cursor_punto.hide()
	cursor_mano_abierta.show()

func mostrar_cursor_punto():
	cursor_punto.show()
	cursor_mano_abierta.hide()
