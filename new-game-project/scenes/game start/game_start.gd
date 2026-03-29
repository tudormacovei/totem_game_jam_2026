extends Node2D

@export var transition_delay: float = 3.0
@export var fade_duration: float = 1.0

@onready var fade_rect: ColorRect = $CanvasLayer/ColorRect

func _ready() -> void:
	fade_rect.modulate.a = 1.0

	var fade_in_tween = create_tween()
	fade_in_tween.tween_property(fade_rect, "modulate:a", 0.0, fade_duration)

	await get_tree().create_timer(transition_delay).timeout

	var fade_out_tween = create_tween()
	fade_out_tween.tween_property(fade_rect, "modulate:a", 1.0, fade_duration)
	await fade_out_tween.finished

	get_tree().change_scene_to_file("res://scenes/main_scene.tscn")
