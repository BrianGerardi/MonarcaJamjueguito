extends Control

signal inventorio_cambio
signal slot_inventario_seleccionado(slot_id : int)
signal item_drop(item)

var size_inventario : int = 4
var hotbar : Array[itemdata]
var slot_seleccionado : int = 0


func _init() -> void:
	for i in size_inventario:
		hotbar.append(null)

func add_item(item_nuevo : itemdata):
	for i in size_inventario:
		if hotbar[i]==null:
			hotbar[i] = item_nuevo
			inventorio_cambio.emit()
			slot_inventario_seleccionado.emit(i)
			return true
	return false


@export var cursor_mano_abierta : TextureRect
@export var cursor_punto : TextureRect
@onready var hbox_inventario: HBoxContainer = %HboxInventario


func _ready() -> void:
	Global.mostrar_cursor_mano_abierta.connect(mostrar_cursor_mano_ab)
	Global.mostrar_cursor_punto.connect(mostrar_cursor_punto)


func seleccionar_un_slot(index: int):
	print("index vale ", index)
	slot_seleccionado = clamp(index, 0 , size_inventario- 1)
	slot_inventario_seleccionado.emit(slot_seleccionado)


func mostrar_cursor_mano_ab():
	cursor_punto.hide()
	cursor_mano_abierta.show()

func mostrar_cursor_punto():
	cursor_punto.show()
	cursor_mano_abierta.hide()
