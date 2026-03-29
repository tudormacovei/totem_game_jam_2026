extends Node

enum Intensity {
	LOW,
	MEDIUM,
	HIGH
}

var SCORE_PER_LEVER = 1 # How many points are awarded for completing a scenario?
var score_total := 0
var current_intensity := Intensity.LOW

signal lever_completed

func update_intensity(intensity: Intensity) -> void:
	current_intensity = intensity

func on_lever_completed(zone_positivity: bool) -> void:
	# TODO: Implement usless scenarios
	score_total += (1 if zone_positivity else -1) * SCORE_PER_LEVER
	print("Lever completed. Score: %d" % score_total)
	lever_completed.emit()

func get_current_like_amount() -> int:
	var like_multiplier = 2.0
	return int(max(score_total * like_multiplier, 0))

# placeholder
func get_current_comment_amount() -> int:
	return int(max(score_total, 0))

func get_current_score() -> int:
	return score_total

func get_current_intensity() -> GameManager.Intensity:
	return current_intensity
