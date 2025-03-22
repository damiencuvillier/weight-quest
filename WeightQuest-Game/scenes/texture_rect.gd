extends TextureRect

const WIDTH_PERCENTAGE := 0.3  # 30% de la largeur de la fenêtre
const MAINTAIN_ASPECT_RATIO := true  # Garde les proportions de l'image

func _ready():
	update_texture_size()
	get_viewport().connect("size_changed", Callable(self, "update_texture_size"))

func update_texture_size():
	var screen_size = get_viewport_rect().size
	var target_width = screen_size.x * WIDTH_PERCENTAGE
	var texture_ratio = 1.0

	if texture:
		texture_ratio = float(texture.get_height()) / texture.get_width()

	var final_size = Vector2(target_width, target_width * texture_ratio)
	self.custom_minimum_size = final_size

	# Choisir comment l'image s'adapte (tu peux tester les différents modes)
	if MAINTAIN_ASPECT_RATIO:
		self.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	else:
		self.stretch_mode = TextureRect.STRETCH_SCALE
