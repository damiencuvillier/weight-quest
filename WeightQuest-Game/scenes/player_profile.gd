extends Control

# Constantes de pourcentage
const LABEL_MARGIN_TOP_PERCENT := 0.05
const LABEL_HEIGHT_PERCENT := 0.1
const TEXTURE_RECT_HEIGHT_PERCENT := 0.6
const BUTTON_MARGIN_BOTTOM_PERCENT := 0.05
const BUTTON_HEIGHT_PERCENT := 0.1
const FONT_SIZE_PERCENT := 0.03

func _ready():
	update_layout()
	get_viewport().connect("size_changed", Callable(self, "update_layout"))

func update_layout():
	var screen_size = get_viewport_rect().size
	
	# Récupération des éléments
	var label_margin = $HBoxContainer/VBoxContainer/MarginContainer
	var label = label_margin.get_child(0)
	var texture_rect = $HBoxContainer/VBoxContainer/TextureRect
	var button = $HBoxContainer/VBoxContainer/PlayButton

	# LABEL
	var label_margin_top = int(screen_size.y * LABEL_MARGIN_TOP_PERCENT)
	label_margin.add_theme_constant_override("margin_top", label_margin_top)
	label.custom_minimum_size.y = int(screen_size.y * LABEL_HEIGHT_PERCENT)

	# Taille de police dynamique
	var font_size = int(screen_size.y * FONT_SIZE_PERCENT)
	var font = label.get_theme_font("font")
	if font:
		label.add_theme_font_size_override("font_size", font_size)

	# TEXTURE RECT
	texture_rect.custom_minimum_size.y = int(screen_size.y * TEXTURE_RECT_HEIGHT_PERCENT)
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	# BUTTON
	var button_height = int(screen_size.y * BUTTON_HEIGHT_PERCENT)
	var button_margin_bottom = int(screen_size.y * BUTTON_MARGIN_BOTTOM_PERCENT)
	button.custom_minimum_size.y = button_height
	button.add_theme_constant_override("margin_bottom", button_margin_bottom)

	var button_font = button.get_theme_font("font")
	if button_font:
		button.add_theme_font_size_override("font_size", font_size)
