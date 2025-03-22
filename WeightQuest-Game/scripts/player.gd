extends CharacterBody2D

var SPEED = 0
var JUMP_VELOCITY = 0
var TIME_TO_COMPLETE = 0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite = $AnimatedSprite2D
@onready var timer_ui: CanvasLayer = $"../TimerUi"
@onready var collision_shape = $CollisionShape2D

var is_time_up = false

func _ready():
	StatsManager.connect("stats_updated", Callable(self, "update_player_abilities"))
	update_player_abilities()
	print(SPEED)
	print(JUMP_VELOCITY)
	print(TIME_TO_COMPLETE)
	if timer_ui:
		timer_ui.start_timer(TIME_TO_COMPLETE)
		timer_ui.connect("time_up", Callable(self, "_on_time_up"))
		timer_ui.connect("transition_to_next_scene", Callable(self, "_on_transition_to_next_scene"))

func update_player_abilities():
	SPEED = StatsManager.get_stat_value("Weight")
	JUMP_VELOCITY = -max(StatsManager.get_stat_value("Energy") * 5, 200)  # Higher energy = stronger jump
	TIME_TO_COMPLETE = StatsManager.get_stat_value("MentalHealth")



func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction = Input.get_axis("move_left", "move_right")
	
	if direction != 0:
		animated_sprite.flip_h = direction < 0
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")

	if not is_on_floor():
		animated_sprite.play("jump")

	velocity.x = direction * SPEED if direction else move_toward(velocity.x, 0, SPEED)
	move_and_slide()

func _on_time_up():
	print("Time's up! You failed!")
	Engine.time_scale = 0.5  
	collision_shape.set_deferred("disabled", true)  # Disable instead of queue_free
	timer_ui.show_game_over_message()

func _on_transition_to_next_scene():
	Engine.time_scale = 1.0
	go_to_next_scene()

func go_to_next_scene():
	var next_scene_path = "res://scenes/level2.tscn"
	var next_scene = ResourceLoader.load(next_scene_path)
	if next_scene:
		get_tree().change_scene_to_packed(next_scene)
	else:
		print("Next scene not found!")
