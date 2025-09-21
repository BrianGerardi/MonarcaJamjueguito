extends Node3D

var vhs_puesto : bool = false
var vhs_cerca : bool = false
@onready var label_press_f: Label3D = %LabelPressF

func _ready() -> void:
	label_press_f.hide()
	%PlanoPantalla.hide()

func _physics_process(delta: float) -> void:
	if vhs_cerca and Input.is_action_just_pressed("f"):
		Global.poner_vhs_tv.emit()
		Global.modo_forzar_mouse_visible(true)
		vhs_cerca = false
		cambiar_pantalla_tv()

func _on_area_poner_vhs_body_entered(body: Node3D) -> void:
	if body.name == "VHS":
		vhs_cerca = true
		print("vhs cerca del tele")
		label_press_f.show()


func _on_area_poner_vhs_body_exited(body: Node3D) -> void:
	vhs_cerca = false
	label_press_f.hide()


func cambiar_pantalla_tv():
	print("cambiar pantalla tv")
	await get_tree().create_timer(1.5).timeout
	%PlanoPantalla.show()
