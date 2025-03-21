extends VBoxContainer

const BUTTON_WIDTH_PERCENTAGE := 0.20  # 20% de la largeur de la fenêtre
const BUTTON_HEIGHT_PERCENTAGE := 0.1  # 10% de la hauteur de la fenêtre
const FONT_SIZE_PERCENTAGE := 0.07  # Taille de la police = 7% de la hauteur de la fenêtre
const SPACING_PERCENTAGE := 0.03  # Espacement entre les boutons = 3% de la hauteur de la fenêtre
const OFFSET_Y_PERCENTAGE := 0.33  # Décalage vers le bas = 33% de la hauteur de la fenêtre

func _ready():
	update_sizes()
	get_viewport().connect("size_changed", Callable(self, "update_sizes"))  # Détecte le redimensionnement

	# Connecte les boutons aux fonctions correspondantes
	var play_button = $PlayButton if has_node("PlayButton") else null
	var quit_button = $QuitButton if has_node("QuitButton") else null

	if play_button:
		play_button.connect("pressed", Callable(self, "_on_play_pressed"))
	
	if quit_button:
		quit_button.connect("pressed", Callable(self, "_on_quit_pressed"))

func update_sizes():
	var screen_size = get_viewport_rect().size  # Taille de la fenêtre
	var button_width = screen_size.x * BUTTON_WIDTH_PERCENTAGE  # Largeur dynamique
	var button_height = screen_size.y * BUTTON_HEIGHT_PERCENTAGE  # Hauteur dynamique
	var font_size = int(screen_size.y * FONT_SIZE_PERCENTAGE)  # Taille du texte
	var spacing = int(screen_size.y * SPACING_PERCENTAGE)  # Espacement dynamique
	var offset_y = int(screen_size.y * OFFSET_Y_PERCENTAGE)  # Décalage vertical

	# Appliquer l'espacement dynamique
	self.add_theme_constant_override("separation", spacing)

	# Ajuster la position du VBoxContainer
	self.anchor_top = 0.5
	self.anchor_bottom = 0.5
	self.pivot_offset.y = offset_y  # Décale verticalement

	for button in get_children():  # Parcours tous les boutons
		if button is Button:
			button.custom_minimum_size = Vector2(button_width, button_height)  # Applique largeur & hauteur

			# Ajuste la taille de la police
			var font = button.get_theme_font("font")  # Récupère la police actuelle
			if font:
				button.add_theme_font_size_override("font_size", font_size)

# 📌 Fonction pour changer de scène
func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/player_profile.tscn")  # Remplace par le chemin de ta scène de jeu

# 📌 Fonction pour quitter le jeu
func _on_quit_pressed():
	get_tree().quit()  # Ferme l'application
