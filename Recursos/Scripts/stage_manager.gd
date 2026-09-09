extends Node

signal checkpoint_start
signal checkpoint_complete(checkpoint: Checkpoint) #controla en actores para borrar/desblqouear camara y en UI para modificar
signal stage_complete
signal stage_intermedio
