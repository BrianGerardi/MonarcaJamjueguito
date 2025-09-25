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


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("1"):
		var hijo = get_child_inventario(1)
		if hijo:
			hijo.modulate
	if Input.is_action_just_pressed("2"):
		pass
	if Input.is_action_just_pressed("3"):
		pass
	if Input.is_action_just_pressed("4"):
		pass

func get_child_inventario(id : int):
	var hijo = %HboxInventario.get_child(id-1)
	if hijo:
		return hijo
	return null

#aprieto 1 2 3 4 y resalta que icono veia
#si existia un icono es pq el inventario tiene un objeto en ese lugar, lo equipo
