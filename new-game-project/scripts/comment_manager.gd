extends Node3D

@export var general_pool: CommentPool
@export var cooldown_seconds := 3 # How long to wait before using a comment again
@export var comment_rate_seconds := 1 # How often comments show up
@export var comment_scene: PackedScene

@onready var ui_layer: CanvasLayer = %UILayer

#TODO: Needs balancing
var SCORE_TO_TIER_DICT := {
	5: 1, # Tier 1: 0-5 points
	10: 2, # Tier 2: 6-10 points
	15: 3, # Tier 3: 11-15 points
}

var last_used := {} # Key: comment string, Value: timestamp

func _process(_delta: float) -> void:
	return # Disable for now
	randomize()

	var now := Time.get_unix_time_from_system()
	var last_time = - comment_rate_seconds if last_used.size() == 0 else last_used.values().max()
	if now - last_time >= comment_rate_seconds + randf() * comment_rate_seconds:
		var intensity = GameManager.get_current_intensity()
		var score = GameManager.get_current_score()
		var tier = _get_tier(score)
		var comment = get_general_comment(intensity, tier)
		_spawn_comment(comment)

# Returns a random comment. Cooldown is applied.
func get_general_comment(intensity: GameManager.Intensity, tier: int) -> String:
	var bucket = null
	match intensity:
		GameManager.Intensity.LOW:
			bucket = general_pool.low_intensity
		GameManager.Intensity.MEDIUM:
			bucket = general_pool.medium_intensity
		GameManager.Intensity.HIGH:
			bucket = general_pool.high_intensity
		_:
			return ""

	if not bucket.has(tier):
		return ""

	var list = bucket[tier]
	if list.is_empty():
		return ""

	var now := Time.get_unix_time_from_system()
	var available := []
	for c in list:
		if not last_used.has(c) or now - last_used[c] >= cooldown_seconds:
			available.append(c)

	if available.is_empty():
		available = list.duplicate()

	var chosen: String = available[randi() % available.size()]
	last_used[chosen] = now
	return chosen

func _get_tier(score: int) -> int:
	for i in SCORE_TO_TIER_DICT:
		if score <= i:
			return SCORE_TO_TIER_DICT[i]
	return 3

func _spawn_comment(text: String) -> void:
	print("Spawning comment: %s" % text)
	var comment_node = comment_scene.instantiate()
	ui_layer.add_child(comment_node)

	var comment_script = comment_node.get_node_or_null("NinePatchRect")
	if comment_script and comment_script is Comment:
		comment_script.init_comment_text(text)
		return
