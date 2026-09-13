class_name TogglePicker
extends ActivableControl

@onready var value_label :=  $ValueLabel


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_active and has_input_togle():
		set_value(1 if current_value == 0 else 0)

func has_input_togle() -> bool:
	var actions := ["move_left","move_right","move_saltar","ataque_golpear"]
	for action in actions:
		if Input.is_action_just_pressed(action):
			return true
	return false

func refresh() -> void:
	value_label.text = "ON" if current_value == 1 else "OFF"
