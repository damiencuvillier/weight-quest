# GoalArea.gd
extends Area2D

@onready var next_level: Area2D = $"."

func _on_body_entered(body):
	print("Collided with: ", body.name)  # Debugging: Check the name of the colliding body
	if body.is_in_group("Player"):  # Check if the colliding body is in the "player" group
		print("Player reached the goal!")
		get_tree().change_scene_to_file("res://scenes/Level2.tscn")  # Manually change scene
