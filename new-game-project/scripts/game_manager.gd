extends Node

var SCORE_PER_LEVER = 1 # How many points are awarded for completing a scenario?

var score_total := 0

func on_lever_completed(zone_positivity: bool) -> void:
	# TODO: Implement usless scenarios
	score_total += (1 if zone_positivity else -1) * SCORE_PER_LEVER
	print("Lever completed. Score: %d" % score_total)
