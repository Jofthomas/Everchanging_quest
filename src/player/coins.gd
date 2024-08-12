extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Enable BBCode for the RichTextLabel
	var rich_text_label = $ColorRect/RichTextLabel
	rich_text_label.bbcode_enabled = true
	var gold_anim = $GoldAnim
	gold_anim.play("default")
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Get the parent node, which is Player
	var player = get_parent()

	# Access the InGameMenu node which is a sibling to CanvasLayer
	var in_game_menu = player.get_node("InGameMenu")
	var xp_value = in_game_menu.get_xp()

	# You can also update the RichTextLabel with the XP value
	var rich_text_label = $ColorRect/RichTextLabel
	rich_text_label.bbcode_text = "[color=#cc1b45]" + str(xp_value) + "[/color]"

