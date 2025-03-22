extends CanvasLayer


@onready var time_label = $Label  # Ensure this matches the node name
@onready var level_timer = $Timer  # Ensure this matches the node name
@onready var message_label = $MessageLabel  # Reference to the MessageLabel node

var time_left = 0

func _ready():
	# Debug prints to verify nodes
	print("Label node:", time_label)
	print("Timer node:", level_timer)
	print("MessageLabel node:", message_label)
	
	if time_label == null:
		print("Error: Label node not found!")
	if level_timer == null:
		print("Error: Timer node not found!")
	if message_label == null:
		print("Error: MessageLabel node not found!")

	# Connect the timer's timeout signal (if not already connected in the editor)
	if not level_timer.is_connected("timeout", Callable(self, "_on_timer_timeout")):
		level_timer.connect("timeout", Callable(self, "_on_timer_timeout"))

func start_timer(mental_health):
	# Convert MentalHealth to time_left (e.g., higher MentalHealth = more time)
	time_left = int(mental_health)  # Use MentalHealth directly or apply a formula
	print("Time left:", time_left)  # Debug print
	print("Time labellll:", time_label)  # Debug print
	if time_label != null:
		time_label.text = "Time: " + str(time_left)  # Update the label
	
	# Debug the Timer node
	print("Timer node before wait_time:", level_timer)
	if level_timer != null:
		print("Timer node is valid!")
		level_timer.wait_time = 1.0  # Update every second
		level_timer.start()
		print("Timer started with time_left:", time_left)  # Debug print
	else:
		print("Error: Timer node is null!")
		
func _on_timer_timeout():
	time_left -= 1
	if time_label != null:
		time_label.text = "Time: " + str(time_left)  # Update the label
	print("Time left:", time_left)  # Debug print
	if time_left <= 0:
		level_timer.stop()
		emit_signal("time_up")  # Notify the level that time is up

signal time_up

func show_game_over_message():
	# Display the game over message
	if message_label != null:
		message_label.text = "Time's Up! Build Mental Strength to have more time to finish the level"
		message_label.visible = true

	# Wait for 4 seconds, then transition to the next scene
	await get_tree().create_timer(3.0).timeout
	emit_signal("transition_to_next_scene")

signal transition_to_next_scene
