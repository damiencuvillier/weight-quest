extends CharacterBody2D


var SPEED = 130.0
var JUMP_VELOCITY = -10.0
var TIME_TO_COMPLETE = 360  # Total time to complete the level in seconds
@onready var level_timer = $LevelTimer
@onready var time_label  = $TimeLabel
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite = $AnimatedSprite2D

var is_time_up = false  # Track if time has run out


func _process(delta):
	if time_label != null:  # Only update the label if it exists
		time_label.text = "Time: " + str(int(level_timer.time_left)) + "s"

func _ready():
	if level_timer == null:
		print("Error: LevelTimer node not found!")
		return

	# Start the level timer when the player is ready
	level_timer.wait_time = TIME_TO_COMPLETE
	level_timer.start()

func _on_level_timer_timeout():
	if not is_time_up:
		# Trigger the failure logic when time runs out
		print("Time's up! You failed!")
		Engine.time_scale = 0.5  # Slow down time
		$CollisionShape2D.queue_free()  # Remove the player's collision
		is_time_up = true  # Mark that time has run out
		level_timer.wait_time = 2.0  # Set a delay before transitioning (e.g., 2 seconds)
		level_timer.start()  # Restart the timer for the delay
	else:
		# Transition to the next scene after the delay
		Engine.time_scale = 1.0
		go_to_next_scene()

func go_to_next_scene():
	# Replace "res://next_scene.tscn" with the path to your next scene
	var next_scene_path = "res://next_scene.tscn"
	if ResourceLoader.exists(next_scene_path):
		get_tree().change_scene_to_file(next_scene_path)
	else:
		print("Next scene not found!")

func _playerAbility(Energy, Weight, MentalHealth):
	# Normalize the inputs to a range of 0 to 1
	var energy_factor = clamp(Energy / 100.0, 0.0, 1.0)
	var weight_factor = clamp(Weight / 100.0, 0.0, 1.0)
	var mental_health_factor = clamp(MentalHealth / 100.0, 0.0, 1.0)
	
	# Define base values for speed, jump velocity, and time to complete
	var base_speed = 75.0
	var base_jump_velocity = -170.0
	var base_time_to_complete = 360  # seconds
	
	# Modify speed based on weight
	# Higher weight increases speed
	SPEED = base_speed * (1.0 + weight_factor)
	
	# Modify jump velocity based on mental health
	# Higher mental health increases jump velocity
	JUMP_VELOCITY = base_jump_velocity * (1.0 + mental_health_factor)
	
	# Modify time to complete based on energy
	# Higher energy decreases the time to complete (more urgency)
	TIME_TO_COMPLETE = base_time_to_complete * (1.0 - energy_factor)
	
	# Ensure speed, jump velocity, and time to complete don't go below certain thresholds
	SPEED = max(SPEED, 50.0)  # Minimum speed
	JUMP_VELOCITY = max(JUMP_VELOCITY, -500.0)  # Minimum jump velocity (more negative means higher jump)
	TIME_TO_COMPLETE = max(TIME_TO_COMPLETE, 60.0)  # Minimum time to complete (60 seconds)

func _physics_process(delta):
	# Example values for Energy, Weight, and MentalHealth
	var Energy = 80.0
	var Weight = 50.0
	var MentalHealth = 70.0
	
	# Update player abilities
	_playerAbility(Energy, Weight, MentalHealth)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction: -1, 0, 1
	var direction = Input.get_axis("move_left", "move_right")
	
	# Flip the Sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	# Play animations
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")
	
	# Apply movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
