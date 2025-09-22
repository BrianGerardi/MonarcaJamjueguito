extends CanvasLayer

@export_range(0, 100, 1) var sanity: int = 100
var nivel_sanity: int = 1
@onready var shader_color_rect: ColorRect = %ColorRect
var material : ShaderMaterial

# valores actuales (los que realmente se aplican al shader)
var grille_opacity: float
var noise_opacity: float
var static_noise_intensity: float
var vignette_intensity: float

var target_grille_opacity: float
var target_noise_opacity: float
var target_static_noise_intensity: float
var target_vignette_intensity: float

@export var velocidad_de_transicion: float = 2.0


func _ready() -> void:
	material = shader_color_rect.material
	Global.aumentar_sanity.connect(_on_aumentar_sanity)

	grille_opacity = material.get_shader_parameter("grille_opacity")
	noise_opacity = material.get_shader_parameter("noise_opacity")
	static_noise_intensity = material.get_shader_parameter("static_noise_intensity")
	vignette_intensity = material.get_shader_parameter("vignette_intensity")

	# inicializo
	target_grille_opacity = grille_opacity
	target_noise_opacity = noise_opacity
	target_static_noise_intensity = static_noise_intensity
	target_vignette_intensity = vignette_intensity


func _physics_process(delta: float) -> void:
	grille_opacity = lerp(grille_opacity, target_grille_opacity, delta * velocidad_de_transicion)
	noise_opacity = lerp(noise_opacity, target_noise_opacity, delta * velocidad_de_transicion)
	static_noise_intensity = lerp(static_noise_intensity, target_static_noise_intensity, delta * velocidad_de_transicion)
	vignette_intensity = lerp(vignette_intensity, target_vignette_intensity, delta * velocidad_de_transicion)

	# aplicar al shader
	material.set_shader_parameter("grille_opacity", grille_opacity)
	material.set_shader_parameter("noise_opacity", noise_opacity)
	material.set_shader_parameter("static_noise_intensity", static_noise_intensity)
	material.set_shader_parameter("vignette_intensity", vignette_intensity)


func _on_aumentar_sanity(cantidad: int):
	incrementar_distorsion()


func incrementar_distorsion():
	target_grille_opacity = 1.0
	target_noise_opacity = 0.7
	target_static_noise_intensity = 0.5
	target_vignette_intensity = 0.7
