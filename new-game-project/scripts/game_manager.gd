extends Node

enum Intensity {
	LOW,
	MEDIUM,
	HIGH
}

var is_menu = true

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

func on_lever_completed(zone_positivity: bool) -> void:
	# TODO: Implement usless scenarios
	score_total += (1 if zone_positivity else -1) * SCORE_PER_LEVER
	print("Lever completed. Score: %d" % score_total)
	lever_completed.emit()

func change_music(music: AudioStream) -> void:
	if music_player == null:
		music_player = AudioStreamPlayer.new()
		add_child(music_player)

	music_player.stream = music
	music_player.play()

func play_sound(is_left : bool) -> void:
	if sound_effect_player == null:
		sound_effect_player = AudioStreamPlayer.new()
		add_child(sound_effect_player)

	var sound = current_right_sound
	if is_left:
		sound = current_left_sound

	sound_effect_player.stream = sound
	sound_effect_player.play()

func get_current_like_amount() -> int:
	var like_multiplier = 2.0
	return int(max(score_total * like_multiplier, 0))

# placeholder
func get_current_comment_amount() -> int:
	return int(max(score_total, 0))

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
