class_name TessellatedPlaneChunk extends Node3D 

var tp : TessellatedPlane
var current_subdiv: int
var current_index: int

func init_chunk():
	tp = get_parent()
	var r := RandomNumberGenerator.new()
	current_subdiv = 0
	current_index = tp.request_chunk(-1, -1, current_subdiv, transform)

func get_chunk_size_screen() -> float:
	return .0
