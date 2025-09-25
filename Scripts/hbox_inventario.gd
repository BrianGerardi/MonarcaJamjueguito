extends HBoxContainer

@export var HUD : Control
var slots : Array

func get_slots():
	slots = get_children()
	for slot : TextureButton in slots:
		slot.pressed.connect(HUD.seleccionar_un_slot.bind(slot.get_index()))

func update_hotbar():
	for slot: TextureButton in slots:
		var item = HUD.hotbar[slot.get_index()]
		slot.texture_normal = item.icono_2d if item else null

func _higlight_slot(slot_index):
	for i in range(4): #si fueran mas de 4 cuidado aca q lo tenemos q cambiar
		slots[i].modulate = Color(1,1,1)
	slots[slot_index].modulate = Color(1.5, 1.5, 1.5)

func _ready() -> void:
	get_slots()
	HUD.inventorio_cambio.connect(update_hotbar)
	HUD.slot_inventario_seleccionado.connect(_higlight_slot)
	update_hotbar()
