extends Control
@onready var dialogue_label: Panel = $"Textbox/DialogueBox Panel"
@onready var dialoguetext_rich_text_label: RichTextLabel = $"Textbox/DialogueBox Panel/Dialoguetext RichTextLabel"
@onready var choix_container: VBoxContainer = $"Textbox/DialogueBox Panel/ChoiceContainer VBoxContainer"
@onready var choice_1_button: Button = $"Textbox/DialogueBox Panel/ChoiceContainer VBoxContainer/Choice1 Button"
@onready var choice_2_button: Button = $"Textbox/DialogueBox Panel/ChoiceContainer VBoxContainer/Choice2 Button"
@onready var choice_3_button: Button = $"Textbox/DialogueBox Panel/ChoiceContainer VBoxContainer/Choice3 Button"

var texte_complet = "Nous sommes un lundi matin. Vous vous réveillez doucement après avoir éteint votre réveil..."
var texte_affiche = ""
var index = 0
var affichage_termine = false
var dialogue_affiche = false  # ✅ Empêche la répétition du texte initial
var interrompre_affichage = false  
var choix_joueur: int = 0
var textes_choix = ["Vous prenez un bon petit déjeuner et vous vous sentez prêt pour la journée.","Vous faites un petit exercice physique et vous vous sentez réveillé.", "Vous sortez pour un gros exercice physique et sentez l'air frais sur votre visage."]  # Liste globale pour stocker les textes associés aux choix

func _ready():
	choix_container.hide()
	if not dialogue_affiche:
		dialogue_affiche = true
		afficher_texte_progressivement(texte_complet)

func afficher_texte_progressivement(texte):
	texte_affiche = ""
	index = 0
	affichage_termine = false
	interrompre_affichage = false  # ✅ Réinitialisation
	dialoguetext_rich_text_label.text = ""  

	while index < texte.length():
		if interrompre_affichage:  # ✅ Si on doit interrompre, on affiche tout de suite le texte complet
			print("affichage interrompu")
			dialoguetext_rich_text_label.text = texte
			break  # ✅ On sort de la boucle
		
		texte_affiche += texte[index]
		dialoguetext_rich_text_label.text = texte_affiche
		index += 1
		await get_tree().create_timer(0.05).timeout

	affichage_termine = true

func _input(event):
	if event.is_action_pressed("ui_accept"):
		if affichage_termine:
			passer_au_texte_suivant()
			afficher_choix("Prendre son petit déjeuner", "Faire un petit exercice")
		else:
			interrompre_affichage = true
			dialoguetext_rich_text_label.text = texte_complet
			affichage_termine = true

func passer_au_texte_suivant():
	print("Passage au dialogue suivant")

func afficher_choix(choix_1: String, choix_2: String, choix_3: String = ""):
	# ✅ Assigner les textes aux boutons
	choice_1_button.text = choix_1
	choice_2_button.text = choix_2
	choice_3_button.text = choix_3

	# ✅ Toujours afficher les deux premiers boutons
	choice_1_button.show()
	choice_2_button.show()

	# ✅ Afficher le 3e bouton uniquement s'il existe
	if choix_3 != "":
		choice_3_button.show()
	else:
		choice_3_button.hide()

	# ✅ Afficher le conteneur des choix
	choix_container.show()

	# ✅ Déconnecter les anciens signaux
	if choice_1_button.is_connected("pressed", Callable(self, "_set_choix_joueur").bind(1)):
		choice_1_button.disconnect("pressed", Callable(self, "_set_choix_joueur").bind(1))
	if choice_2_button.is_connected("pressed", Callable(self, "_set_choix_joueur").bind(2)):
		choice_2_button.disconnect("pressed", Callable(self, "_set_choix_joueur").bind(2))
	if choice_3_button.is_connected("pressed", Callable(self, "_set_choix_joueur").bind(3)):
		choice_3_button.disconnect("pressed", Callable(self, "_set_choix_joueur").bind(3))

	# ✅ Connecter les boutons directement à la fonction qui stocke le choix
	choice_1_button.pressed.connect(func(): _set_choix_joueur(1))
	choice_2_button.pressed.connect(func(): _set_choix_joueur(2))
	if choix_3 != "":
		choice_3_button.pressed.connect(func(): _set_choix_joueur(3))

# ✅ Fonction pour stocker le choix du joueur et masquer les boutons
func _set_choix_joueur(choix_index: int):
	choix_joueur = choix_index
	choix_container.hide()
	print("Le joueur a choisi :", choix_joueur)  # Débogage

func definir_textes_choix(nouveaux_textes: Array):
	# ✅ Stocke les textes pour les futurs choix
	textes_choix = nouveaux_textes

func afficher_resultat_choix():
	if choix_joueur > 0 and choix_joueur <= textes_choix.size():
		dialoguetext_rich_text_label.text = textes_choix[choix_joueur - 1]

	await get_tree().create_timer(2).timeout
	# load next scene
