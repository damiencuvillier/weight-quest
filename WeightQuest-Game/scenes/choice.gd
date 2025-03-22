extends Control

# ✅ VARIABLES & RÉFÉRENCES UI
@onready var dialogue_label: Panel = $"Textbox/DialogueBox Panel"
@onready var dialoguetext_rich_text_label: RichTextLabel = $"Textbox/DialogueBox Panel/Dialoguetext RichTextLabel"
@onready var choix_container: VBoxContainer = $"Textbox/DialogueBox Panel/ChoiceContainer VBoxContainer"
@onready var choice_1_button: Button = $"Textbox/DialogueBox Panel/ChoiceContainer VBoxContainer/Choice1 Button"
@onready var choice_2_button: Button = $"Textbox/DialogueBox Panel/ChoiceContainer VBoxContainer/Choice2 Button"
@onready var choice_3_button: Button = $"Textbox/DialogueBox Panel/ChoiceContainer VBoxContainer/Choice3 Button"
@onready var black_bg: Sprite2D = %BlackBg

# ✅ VARIABLES DE JEU
var choix_joueur: int = 0
var affichage_termine = false
var interrompre_affichage = false  
var index_texte = 0  # Suivi du texte actuellement affiché
var texte_scene = []
var current_scene = "reveil"
var scene = {}  # Contiendra les données de la scène

# ✅ INITIALISATION
func _ready():
	afficher_scene(current_scene)

# ✅ AFFICHAGE DES SCÈNES
func afficher_scene(scene_name: String):
	if not scenes_data.has(scene_name):
		print("Erreur : scène non trouvée :", scene_name)
		return
	
	current_scene = scene_name
	scene = scenes_data[scene_name]

	# Charger l'image de fond
	var background_path = "res://assets/illustrations/blackBG.jpeg"
	if scene_name == "petit_dejeuner":
		background_path = "res://assets/illustrations/ptit_dej_oui_non.png"
	elif scene_name == "reveil":
		background_path = "res://assets/illustrations/shot_or_no_shot.png"
	
		
	
	black_bg.texture = load(background_path) as Texture2D
	ajuster_taille_background()

	# Récupérer les textes et afficher le premier
	texte_scene = scene.get("texte", [])
	index_texte = 0
	if texte_scene.size() > 0:
		afficher_texte_progressivement(texte_scene[index_texte])

# ✅ AFFICHAGE PROGRESSIF DU TEXTE
func afficher_texte_progressivement(texte: String):
	affichage_termine = false
	interrompre_affichage = false  
	dialoguetext_rich_text_label.text = ""
	var texte_affiche = ""

	for i in range(texte.length()):
		if interrompre_affichage:
			dialoguetext_rich_text_label.text = texte
			break  

		texte_affiche += texte[i]
		dialoguetext_rich_text_label.text = texte_affiche
		await get_tree().create_timer(0.05).timeout

	affichage_termine = true

# ✅ AFFICHAGE DES CHOIX
func afficher_choix(choix_textes: Array):
	deconnecter_choix()

	# Cacher tous les boutons au départ
	for bouton in [choice_1_button, choice_2_button, choice_3_button]:
		bouton.hide()

	# Afficher les choix disponibles
	for i in range(min(choix_textes.size(), 3)):
		var bouton = [choice_1_button, choice_2_button, choice_3_button][i]
		bouton.text = choix_textes[i]["texte"]
		print(choix_textes[i]["texte"])
		bouton.show()
		bouton.pressed.connect(_on_choice_pressed.bind(i + 1, choix_textes[i]["next"]))

	choix_container.show()

# ✅ DÉCONNECTER LES ANCIENS CHOIX
func deconnecter_choix():
	for bouton in [choice_1_button, choice_2_button, choice_3_button]:
		for conn in bouton.get_signal_connection_list("pressed"):
			bouton.disconnect("pressed", conn.callable)

# ✅ GESTION DU CHOIX DU JOUEUR
func _on_choice_pressed(choix_index: int, next_scene: String):
	choix_joueur = choix_index
	choix_container.hide()
	afficher_scene(next_scene)

# ✅ AJUSTER L'IMAGE DE FOND
func ajuster_taille_background():
	if black_bg.texture:
		var texture_size = black_bg.texture.get_size()
		var screen_size = get_viewport_rect().size
		var final_scale = max(screen_size.x / texture_size.x, screen_size.y / texture_size.y)

		black_bg.scale = Vector2(final_scale, final_scale)
		black_bg.position = screen_size / 2

# ✅ GESTION DE L'ENTRÉE UTILISATEUR
func _input(event):
	if event.is_action_pressed("ui_accept"):
		if not affichage_termine:
			interrompre_affichage = true
		else:
			if index_texte < texte_scene.size() - 1:
				index_texte += 1
				afficher_texte_progressivement(texte_scene[index_texte])
			else:
				# Tous les textes sont affichés, proposer les choix
				if scene.has("choix") and scene["choix"].size() > 0:
					afficher_choix(scene["choix"])
				else:
					print("Fin du scénario")

# ✅ SCÉNARIO & TEXTES
var scenes_data = {
	"reveil": {
		"texte": [
			"Nous sommes un lundi matin.",
			"Vous vous réveillez doucement après avoir éteint votre réveil...",
			"Que veux-tu faire ?"
		],
		"choix": [
			{"texte": "Je veux prendre le traitement GLP-1 (Wegovy, Ozempic...).", "next": "petit_dejeuner"},
			{"texte": "Je ne veux pas prendre le traitement.", "next": "exercice"},
		]
	},
	
	"petit_dejeuner": {
		"texte": [
			"Tu descends dans la cuisine...",
			"Quel choix fais-tu ?"
		],
		"choix": [
			{"texte": "Prendre un bon petit déjeuner", "next": "choix_ptit_dej"},
			{"texte": "Non, je ne déjeune pas.", "next": "exercice"},
		]
	},
	
	"choix_ptit_dej": {
		"texte": [
			"L'heure de déjeuner !",
			"Que choisis-tu?"
		],
		"choix": [
			{"texte": "Combo Café-croissant", "next": "petit_dejeuner"},
			{"texte": "Muesli aux fruits ", "next": "exercice"},
			{"texte": "Œufs bacon", "next": "course"},
			{"texte": "Café Tartine confiture ", "next": "course"}

		]
	},
	
	
	
	
	"course": {
		"texte": [
			"Vous sortez pour un gros exercice physique.",
			"L'air frais sur votre visage vous revigore."
		],
		"choix": [
			{"texte": "Prendre un bon petit déjeuner", "next": "petit_dejeuner"},
			{"texte": "Faire un petit exercice physique", "next": "exercice"},
			{"texte": "Sortir pour un gros exercice physique", "next": "course"}
		]
	}
}
