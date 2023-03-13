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
	var chunk_size = tp.get_chunk_size()
	var camera: Camera3D = get_viewport().get_camera_3d()
	var corner_top_left : Vector3 = position
	var corner_top_right : Vector3 = position + Vector3(1, 0, 0) * chunk_size
	var corner_bottom_left : Vector3 = position + Vector3(0, 0, 1) * chunk_size
	var corner_bottom_right : Vector3 = position + Vector3(0, 0, 1) * chunk_size + Vector3(1, 0, 0) * chunk_size
	var ctl_screen: Vector2 = camera.unproject_position(corner_top_left)
	var ctr_screen: Vector2 = camera.unproject_position(corner_top_right)
	var cbl_screen: Vector2 = camera.unproject_position(corner_bottom_left)
	var cbr_screen: Vector2 = camera.unproject_position(corner_bottom_right)
	
	var screen_size :Vector2 = get_viewport().get_visible_rect().size
	var minX : float = INF
	var maxX : float = -INF
	var minY : float = INF
	var maxY : float = -INF
	for corner in [ctl_screen, ctr_screen, cbl_screen, cbr_screen]:
		if corner.x > maxX:
			maxX = corner.x
		if (corner.x < minX):
			minX = corner.x
		if corner.y > maxY:
			maxY = corner.y
		if corner.y < minY:
			minY = corner.y
		minX = clamp(minX, 0, screen_size.x)
		maxX = clamp(maxX, 0, screen_size.x)
		minY = clamp(minY, 0, screen_size.y)
		maxY = clamp(maxY, 0, screen_size.y)
	
	var width = maxX - minX
	var height = maxY - minY
	var area = width * height
	return area/(screen_size.x * screen_size.y)

func _process(delta):
	var chunk_screen_area : float = get_chunk_size_screen()
	var new_subdiv: int
	if chunk_screen_area > 0.4:
		new_subdiv = 8
	elif chunk_screen_area > 0.1:
		new_subdiv = 6
	else:
		new_subdiv = 0
	
	if new_subdiv != current_subdiv:
		current_index = tp.request_chunk(current_subdiv, current_index, new_subdiv, transform)
		current_subdiv = new_subdiv
	
	
