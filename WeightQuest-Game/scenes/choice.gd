extends Control

# ✅ VARIABLES & RÉFÉRENCES UI
@onready var dialogue_label: Panel = $"Textbox/DialogueBox Panel"
@onready var dialoguetext_rich_text_label: RichTextLabel = $"Textbox/DialogueBox Panel/Dialoguetext RichTextLabel"
@onready var choix_container: VBoxContainer = $"Textbox/DialogueBox Panel/ChoiceContainer VBoxContainer"
@onready var choice_1_button: Button = $"Textbox/DialogueBox Panel/ChoiceContainer VBoxContainer/Choice1 Button"
@onready var choice_2_button: Button = $"Textbox/DialogueBox Panel/ChoiceContainer VBoxContainer/Choice2 Button"
@onready var choice_3_button: Button = $"Textbox/DialogueBox Panel/ChoiceContainer VBoxContainer/Choice3 Button"
@onready var choice_4_button: Button = $"Textbox/DialogueBox Panel/ChoiceContainer VBoxContainer/Choice4 Button"
@onready var black_bg: Sprite2D = %BlackBg

const StatsManager = preload("res://stats_manager.gd")
@onready var stats = get_node("/root/StatsManager")

	
# ✅ VARIABLES DE JEU
var choix_joueur: int = 0
var affichage_termine = false
var interrompre_affichage = false  
var index_texte = 0  # Suivi du texte actuellement affiché
var texte_scene = []
var current_scene = "shot"
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

	if scene_name == "shot":
		background_path = "res://assets/illustrations/ozempic_ornot.webp"
	elif scene_name == "reveil":
		background_path = "res://assets/illustrations/reveilMieux.webp"
	elif scene_name == "choix_activité" : 
		background_path = "res://assets/illustrations/quelleactivité.webp"
	elif scene_name == "petit_dejeuner" : 
		background_path = "res://assets/illustrations/petitdej.webp"	
	elif scene_name == "activité_physique" : 
		background_path = "res://assets/illustrations/activitéphysique.webp"
		
		
	
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
	for bouton in [choice_1_button, choice_2_button, choice_3_button, choice_4_button]:
		bouton.hide()

	# Afficher les choix disponibles
	for i in range(min(choix_textes.size(), 4)):  # ✅ Gérer jusqu'à 4 choix
		var bouton = [choice_1_button, choice_2_button, choice_3_button, choice_4_button][i]
		bouton.text = choix_textes[i]["texte"]
		print(choix_textes[i]["texte"])
		bouton.show()
		bouton.pressed.connect(_on_choice_pressed.bind(i + 1, choix_textes[i]["next"]))

	choix_container.show()
	choix_container.show()

# ✅ DÉCONNECTER LES ANCIENS CHOIX
func deconnecter_choix():
	for bouton in [choice_1_button, choice_2_button, choice_3_button, choice_4_button]:  # ✅ Ajout du 4e bouton
		for conn in bouton.get_signal_connection_list("pressed"):
			bouton.disconnect("pressed", conn.callable)

# ✅ GESTION DU CHOIX DU JOUEUR
func _on_choice_pressed(choix_index: int, next_scene: String):
	choix_joueur = choix_index
	choix_container.hide()

	var choix = scene["choix"][choix_index - 1]
	if "effets" in choix:
		appliquer_effets(choix["effets"])

	# Vérifie si la scène suivante existe
	if scenes_data.has(next_scene):
		afficher_scene(next_scene)
	else:
		afficher_scene("game")



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
			if current_scene == "game":
				print("OK")
				get_tree().change_scene_to_file("C:/Users/qjkin/documents/WeightQuestFirstGame/weight-quest/WeightQuest-Game/scenes/game.tscn")	

func appliquer_effets(effets: Dictionary):
	for stat in effets.keys():
		if stat == "Ozempic":
			stats.set_stat_value(stat, effets[stat])
		else:
			print("!!! ", stat)
			print("new value :", stats.get_stat_value(stat), " + ", effets[stat] )
			var new_value = stats.get_stat_value(stat) + effets[stat]
			stats.set_stat_value(stat, new_value)

	# Afficher correctement les stats après modification
	print("Updated stats:")
	for stat in stats.get_all_stats_keys():
		print(stat, ":", stats.get_stat_value(stat))



# ✅ SCÉNARIO & TEXTES
var scenes_data = {
	"shot": {
		"texte": [
			"Que souhaites-tu faire ?"
		],
		"choix": [
			{"texte": "Je veux prendre le traitement GLP-1 (Wegovy, Ozempic...).", "next": "reveil", "effets": {"Weight": -1, "Energy": 1, "MentalHealth": -2, "Ozempic": true}},
			{"texte": "Je ne veux pas prendre le traitement.", "next": "reveil", "effets": {"Weight": 0, "Energy": 0, "MentalHealth": 1, "Ozempic": false}},
		]	
	},
	"reveil": {
		"texte": [
			"Nous sommes un lundi matin.",
			"Vous vous réveillez doucement après avoir éteint votre réveil...",
			"Que veux-tu faire ?"
		],
		"choix": [
			{"texte": "Prendre un déjeuner", "next": "petit_dejeuner", "effets": {}},
			{"texte": "Je ne déjeune pas", "next": "choix_activité", "effets": {"Weight": 1, "Energy": -2, "MentalHealth": -1, "Ozempic": false}},
		]
	},
	
	"petit_dejeuner": {
		"texte": [
			"Tu descends dans la cuisine...",
			"Quel choix fais-tu ?"
		],
		"choix": [
			{"texte": "Café/Thé croissant", "next": "choix_activité", "effets": {"Weight": -1, "Energy": 1, "MentalHealth": 0, "Ozempic": false}},
			{"texte": "Muesli aux fruits", "next": "choix_activité", "effets": {"Weight": 0, "Energy": 1, "MentalHealth": 2, "Ozempic": false}},
			{"texte": "Œufs bacon", "next": "choix_activité", "effets": {"Weight": -2, "Energy": 2, "MentalHealth": -1, "Ozempic": false}},
			{"texte": "Café/Thé Tartine confiture", "next": "choix_activité", "effets": {"Weight": 0, "Energy": 1, "MentalHealth": 0, "Ozempic": false}},
		]
	},		
	"choix_activité": {
		"texte": [
			"Pas encore tout à fait reveillé, vous vous demandez ce que vous voudriez faire aujourd'hui.",
			"Qu'allez-vous faire ?"
		],
		"choix": [
			{"texte": "Regarder la tété et grignoter.", "next": "", "effets": {"Weight": -2, "Energy": 1, "MentalHealth": -2, "Ozempic": false}},
			{"texte": "Pratiquer une activité physique de mon choix", "next": "activité_physique"}
		]
	},
	"activité_physique": {
		"texte": [
			"Vous vous préparez à faire une activité physique.",
			"Quelle activité allez vous pratiquer ?"
		],
		"choix": [
			{"texte": "Une activité de la vie quotidienne (marche, ménage, jardinage, vélo électrique, …)", "next": "", "effets": {"Weight": 1, "Energy": 0, "MentalHealth": 0, "Ozempic": false}},
			{"texte": "Une activité physique d’intensité modérée (vélo, natation, marche nordique, danse, Pilate, …)", "next": "activité", "effets": {"Weight": 2, "Energy": 1, "MentalHealth": 1, "Ozempic": false}},
			{"texte": "Une activité physique intense (jogging, fitness cardio, sport de combat, sport de raquette, …) ", "next": "activité", "effets": {"Weight": 2, "Energy": -1, "MentalHealth": -1, "Ozempic": false}}
		]
	},
	"game": {
		"texte": [
			"Un épreuve sauvage apparait !"
		]
	}
}
