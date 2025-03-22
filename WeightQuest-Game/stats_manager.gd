extends Node

var stats := {
	"Weight": 10.0,
	"Energy": 99.0,
	"MentalHealth": 99.0
}

func get_stat_value(stat_name: String) -> int:
	return stats.get(stat_name, 0)  # Default to 0 if the stat doesn't exist

func set_stat_value(stat_name: String, value: int) -> void:
	if stats.has(stat_name):
		stats[stat_name] = clamp(value, 0, 100)
		emit_signal("stats_updated")

signal stats_updated  # Signal to notify changes
