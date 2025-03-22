extends VBoxContainer

const WIDTH_PERCENTAGE := 0.4  # Largeur = 40% de la fenêtre
const HEIGHT_PERCENTAGE := 0.05 # Hauteur = 5% de la fenêtre
const FONT_SIZE_PERCENTAGE := 0.03 # Taille du texte = 3% de la hauteur de la fenêtre
const SPACING_PERCENTAGE := 0.1  # Espacement entre chaque StatX = 20% de la hauteur de la fenêtre

func _ready():
	update_sizes()
	get_viewport().connect("size_changed", Callable(self, "update_sizes"))

	# Connexion au signal du StatsManager pour mettre à jour les barres
	StatsManager.connect("stats_updated", Callable(self, "update_bars"))
	update_bars()  # Mise à jour initiale

func update_sizes():
	var screen_size = get_viewport_rect().size  # Taille totale de la fenêtre
	var bar_width = screen_size.x * WIDTH_PERCENTAGE  # Largeur proportionnelle
	var bar_height = screen_size.y * HEIGHT_PERCENTAGE  # Hauteur proportionnelle
	var font_size = int(screen_size.y * FONT_SIZE_PERCENTAGE)  # Taille de police proportionnelle
	var spacing = int(screen_size.y * SPACING_PERCENTAGE)  # Espacement dynamique

	# Appliquer la séparation aux enfants du VBoxContainer
	self.add_theme_constant_override("separation", spacing)

	for stat in get_children():  # Parcours tous les éléments (Stat1, Stat2, etc.)
		var progress_bar = stat.get_node("TextureProgressBar") if stat.has_node("TextureProgressBar") else null
		var label = stat.get_node("Label") if stat.has_node("Label") else null
		var icon = stat.get_node("TextureRect") if stat.has_node("TextureRect") else null  # Vérifie s'il y a une icône

		if progress_bar:
			progress_bar.custom_minimum_size = Vector2(bar_width, bar_height)  # Applique largeur & hauteur

		if label:
			var font = label.get_theme_font("font")  # Récupère la police du label
			if font:
				label.add_theme_font_size_override("font_size", font_size)  # Ajuste la taille du texte

		# Gestion dynamique de l'icône si elle existe
		if icon:
			var icon_size = Vector2(font_size * 3.5, font_size * 3.5)  # Taille proportionnelle à la police
			icon.custom_minimum_size = icon_size
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED  # Garde le ratio

	update_bars()  # Mise à jour après le redimensionnement

func update_bars():
	# Met à jour toutes les barres en fonction du StatsManager
	for stat in get_children():
		if not stat.has_node("TextureProgressBar"):
			continue
		
		var progress_bar = stat.get_node("TextureProgressBar")
		var stat_value = StatsManager.get_stat_value(stat.name)
		progress_bar.value = stat_value

		var texture = get_texture_for_stat(stat.name, stat_value)
		if texture:
			progress_bar.texture_progress = texture  # Applique la bonne texture

# Mapping spécifique pour chaque stat
const STAT_TEXTURES := {
	"Energy": [
		{ "threshold": 33, "texture": preload("res://assets/Nazim/hbp_red.png") },
		{ "threshold": 66, "texture": preload("res://assets/Nazim/hbp_orange.png") },
		{ "threshold": 100, "texture": preload("res://assets/Nazim/hbp_green.png") },
	],
	"Weight": [
		{ "threshold": 33, "texture": preload("res://assets/Nazim/hbp_red.png") },
		{ "threshold": 66, "texture": preload("res://assets/Nazim/hbp_orange.png") },
		{ "threshold": 100, "texture": preload("res://assets/Nazim/hbp_green.png") },
	],
	"MentalHealth": [
		{ "threshold": 33, "texture": preload("res://assets/Nazim/hbp_red.png") },
		{ "threshold": 66, "texture": preload("res://assets/Nazim/hbp_orange.png") },
		{ "threshold": 100, "texture": preload("res://assets/Nazim/hbp_green.png") },
	]
}

func get_texture_for_stat(stat_name: String, value: float) -> Texture:
	if not STAT_TEXTURES.has(stat_name):
		return null

	var texture_list = STAT_TEXTURES[stat_name]

	for mapping in texture_list:
		if value <= mapping["threshold"]:
			return mapping["texture"]

	# Si aucune condition ne match, retourne la dernière texture par défaut
	return texture_list[-1]["texture"]
