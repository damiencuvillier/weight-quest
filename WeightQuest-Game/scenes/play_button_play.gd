extends Button

func _ready():
	connect("pressed", Callable(self, "_on_play_pressed"))

func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/choice.tscn")
