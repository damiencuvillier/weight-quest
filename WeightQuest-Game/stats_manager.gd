extends Node

# Dictionnaire contenant les valeurs des stats
var stats := {
	"Energy": 50.0,
	"Weight": 30.0,
	"MentalHealth": 75.0
}

# Récupérer la valeur d'une stat
func get_stat_value(stat_name: String) -> int:
	return stats.get(stat_name, 0)  # Retourne 0 si la stat n’existe pas

# Changer la valeur d'une stat
func set_stat_value(stat_name: String, value: int) -> void:
	if stats.has(stat_name):
		stats[stat_name] = clamp(value, 0, 100)  # Par exemple entre 0 et 100
