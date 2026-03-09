extends Area2D
@export var Nivel_Nombre: String


func _process(delta: float) -> void:
	pass


func _on_body_entered(body):
	print(body.name)
	if body.name == "SpritePlus":
		change_scene()

func change_scene():
	print("CAMBIO")
	#get_tree().change_scene_to_file(Nivel_Nombre)
	get_tree().call_deferred("change_scene_to_file", Nivel_Nombre)
	#var scene = load("escena")
	#get_tree().current_scene.remove_child(body)
	#get_tree().current_scene.queue_free()
	#get_tree().current_scene.add_child(scene)
	#scene.call_deferred("add_child",body)
	#get_tree().current_scene = scene


func _on_parallax_manejador_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
