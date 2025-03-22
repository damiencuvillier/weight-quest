# GoalArea.gd
extends Area2D

@onready var next_level: Area2D = $"."

func _on_body_entered(body):
	print("Collided with: ", body.name)  # Debugging: Check the name of the colliding body
	if body.name == "Player":  # Check if the colliding body is the player
		print("Player reached the goal!")
		
		# Get the current scene's file path
		var current_scene_path = get_tree().current_scene.scene_file_path
		print("Current scene path:", current_scene_path)  # Debugging: Print the current scene path
		
		# Determine the next scene based on the current scene
		if current_scene_path == "res://scenes/level1.tscn":
			get_tree().change_scene_to_file("res://scenes/choice2.tscn")
		elif current_scene_path == "res://scenes/level2.tscn":
			get_tree().change_scene_to_file("res://scenes/choice3.tscn")
		else:
			print("Unknown scene! Cannot determine the next scene.")
