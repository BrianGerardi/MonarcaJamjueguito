extends Node

@onready var camera3D: Camera3D = %Camera3DGlobal
var tween
#esto viene de un addon que adapte para godot 4
#cualquier cosa aca ta el link: https://www.youtube.com/watch?v=8Lj3pUYuVe8&t=13s
var transitioning: bool = false

func _ready() -> void:
	camera3D.current = false

func switch_camera(from, to) -> void:
	from.current = false
	to.current = true


func transition_camera3D(from: Camera3D, to: Camera3D, duration: float = 1.0) -> void:
	if transitioning: return
	# Copy the parameters of the first camera
	camera3D.fov = from.fov
	camera3D.cull_mask = from.cull_mask
	
	# Move our transition camera to the first camera position
	camera3D.global_transform = from.global_transform
	
	# Make our transition camera current
	camera3D.current = true
	transitioning = true
	
	# Move to the second camera, while also adjusting the parameters to
	# match the second camera
	tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(camera3D, "global_transform", to.global_transform, duration).from(camera3D.global_transform)
	tween.tween_property(camera3D, "fov", to.fov, duration).from(camera3D.fov)

# Wait for the tween to complete	
	await tween.finished
	# Make the second camera current
	to.current = true
	transitioning = false
