extends VBoxContainer

# Pourcentages de taille/marge
const LABEL_MARGIN_TOP := 0.02
const LABEL_HEIGHT := 0.1
const TEXTURE_RECT_HEIGHT := 0.6
const BUTTON_MARGIN_BOTTOM := 0.02
const BUTTON_HEIGHT := 0.05
const BUTTON_L := 0.1

func _ready():
	update_layout()
	get_viewport().connect("size_changed", Callable(self, "update_layout"))

func update_layout():
	var size = get_viewport_rect().size

	# === Label ===
	var label_margin = $MarginContainer
	var label = label_margin.get_child(0)
	label_margin.add_theme_constant_override("margin_top", int(size.y * LABEL_MARGIN_TOP))
	label.custom_minimum_size.y = int(size.y * LABEL_HEIGHT)

	# === TextureRect ===
	var texture_rect = $TextureRect
	texture_rect.custom_minimum_size.y = int(size.y * TEXTURE_RECT_HEIGHT)
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	# === Button ===
	var button_margin = $MarginContainer2
	var button = button_margin.get_child(0)
	button_margin.add_theme_constant_override("margin_bottom", int(size.y * BUTTON_MARGIN_BOTTOM))
	button.custom_minimum_size.y = int(size.y * BUTTON_HEIGHT)
	button.custom_minimum_size.x = int(size.y * BUTTON_L)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
