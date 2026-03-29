extends Node

# NOTE: Comment Manager expects at least 2 tiers
var SCORE_TO_TIER_DICT := {
	6: 1, # Tier 1 is from 0 to 6
	12: 2, # Tier 2
	15: 3, # Tier 3 - Value should be tied to MAX_TIER
}
var MAX_TIER = 3

enum Intensity {
	LOW,
	MEDIUM,
	HIGH
}

var in_tutorial = true

var SCORE_PER_LEVER = 1 # How many points are awarded for completing a scenario?
var score_total := 0
var current_intensity := Intensity.LOW

var current_left_sound = null
var current_right_sound = null

var music_player: AudioStreamPlayer
var sound_effect_player: AudioStreamPlayer

signal lever_completed


func update_intensity(intensity: Intensity) -> void:
	current_intensity = intensity


func on_lever_completed(zone_positivity: bool, lever: Lever) -> void:
	var score_multiplier: float = 0.0
	if lever.intensity == Intensity.LOW:
		score_multiplier = 0.0
	elif lever.intensity == Intensity.MEDIUM:
		score_multiplier = 1.0
	else:
		score_multiplier = 3.0

	score_total += (-1 if zone_positivity else +1) * SCORE_PER_LEVER * score_multiplier
	score_total = max(score_total, 0)
	print("Lever completed. Score: %d" % score_total)
	lever_completed.emit()

func change_music(music: AudioStream) -> void:
	if music_player == null:
		music_player = AudioStreamPlayer.new()
		music_player.finished.connect(music_player.play)
		add_child(music_player)

	music_player.stream = music
	music_player.play()

func play_sound(is_left: bool) -> void:
	if sound_effect_player == null:
		sound_effect_player = AudioStreamPlayer.new()
		add_child(sound_effect_player)

	var sound = current_right_sound
	if is_left:
		sound = current_left_sound

	sound_effect_player.stream = sound
	sound_effect_player.play()

func get_tier_from_score(score: int) -> int:
	for i in GameManager.SCORE_TO_TIER_DICT:
		if score <= i:
			return GameManager.SCORE_TO_TIER_DICT[i]
	return MAX_TIER

func get_current_like_amount() -> int:
	var like_multiplier = 10.0
	return int(max(score_total * score_total * score_total * score_total * like_multiplier, 0))

func get_current_comment_amount() -> int:
	var comments_multiplier = 10 * get_tier_from_score(score_total)
	return int(max(score_total * score_total * score_total * comments_multiplier, 0))

# 0 -> 6: indifferent, 6->12 medium, 13+ extreme
func get_current_score() -> int:
	return score_total

func get_current_intensity() -> GameManager.Intensity:
	return current_intensity

var current_lever_score: LeverScore = null

func set_focus(leverScore: LeverScore) -> void:
	if current_lever_score != null:
		current_lever_score.lever_area._on_focus_loss()
	current_lever_score = leverScore

func get_comment_rate_from_tier(tier: int) -> float:
	var comment_rate_seconds = 0.5
	if tier == 1:
		comment_rate_seconds = 1
	elif tier == 2:
		comment_rate_seconds = 0.7
	elif tier == 3:
		comment_rate_seconds = 0.2
	else:
		comment_rate_seconds = 0.2
	return comment_rate_seconds