extends TabBar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_master_value_changed(value: float) -> void:
	set_volume(0, value)
func _on_music_value_changed(value: float) -> void:
	set_volume(1, value)
func _on_sfx_value_changed(value: float) -> void:
	set_volume(2, value)
	
func set_volume (idx, value):
	AudioServer.set_bus_volume_db(idx,linear_to_db(value))
