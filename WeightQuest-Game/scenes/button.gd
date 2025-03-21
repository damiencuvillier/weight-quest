extends Button

func _ready():
	# Optionnel, si tu veux faire quelque chose au démarrage
	pass

func _pressed():
	get_tree().change_scene_to_file("res://scenes/player_profile.tscn")
