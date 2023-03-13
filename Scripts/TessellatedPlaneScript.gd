class_name TessellatedPlane extends Node3D


@export_category("Tessellation Properties")
@export_range(.1, 50) var chunk_size: float = 16
@export_range(1, 100, 1) var chunk_count: int = 10
@export_range(1, 10, 1) var subdivisions: int = 9

@export_category("Tessellation Rendering")
@export var water_material: Material

var plane: Array[ArrayMesh]
var meshes: Array[MultiMeshInstance3D]
var mutex_request_chunk: Mutex
var chunks: Array[TessellatedPlaneChunk]

# Called when the node enters the scene tree for the first time.
func _ready():
	init_tessellated_plane()

func clear_plane():
	for child in get_children():
		child.queue_free()
	
	plane = []
	meshes = []

func init_tessellated_plane():
	clear_plane()
	mutex_request_chunk = Mutex.new()
	plane = []
	meshes = []
	
	for sub in range(0, subdivisions):
		plane.append(gen_plane(pow(2, sub), chunk_size/pow(2, sub)))
		meshes.append(MultiMeshInstance3D.new())
		add_child(meshes[sub])
		meshes[sub].multimesh = MultiMesh.new()
		meshes[sub].multimesh.instance_count = 0
		meshes[sub].multimesh.mesh = plane[sub]
		meshes[sub].multimesh.transform_format = MultiMesh.TRANSFORM_3D
	
	for i in range(0, chunk_count):
		for j in range(0, chunk_count):
			var chunk := TessellatedPlaneChunk.new()
			chunks.append(chunk)
			add_child(chunk)
			chunk.position = Vector3(i * chunk_size, 0, j * chunk_size)
			chunk.init_chunk()
	
	

func gen_plane(cell_count: int, cell_size: float) -> ArrayMesh:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for x in range(0, cell_count + 1):
		for y in range (0, cell_count + 1):
			st.add_vertex(Vector3(x * cell_size, 0,  y * cell_size))
	
	st.deindex()
	var vi: int = 0
	for x in range(0, cell_count + 1):
		for y in range (0, cell_count + 1):
			st.add_index(vi)
			st.add_index(vi + cell_count + 1)
			st.add_index(vi + 1)
			st.add_index(vi + 1)
			st.add_index(vi + cell_count + 1)
			st.add_index(vi + cell_count + 2)
			vi+=1
			
	st.set_material(water_material)
	return st.commit()

func request_chunk(old_subdiv: int, old_index: int, new_subdiv: int, t: Transform3D) -> int:
	mutex_request_chunk.lock()
	
	# First we remove the old plane
	if old_subdiv != -1 && old_index != -1:
		var old_multimesh: MultiMesh = meshes[old_subdiv].multimesh
		if old_multimesh.instance_count > 1:
			# We delete the old transform by overwriting it with the old one
			var temp_tarray := old_multimesh.transform_array
			old_multimesh.set_instance_transform(old_index, old_multimesh.get_instance_transform(old_multimesh.instance_count-1))
			temp_tarray.resize(temp_tarray.size() - 4)
			old_multimesh.instance_count -= 1
			old_multimesh.transform_array = temp_tarray
			
			# This also means we need to warn the chunk that was moved to change
			# it's old index.
			for c in chunks:
				if c.current_subdiv == old_subdiv && c.current_index == old_multimesh.instance_count:
					c.current_index = old_index
					break
		else:
			old_multimesh.instance_count = 0
	
	# Then we create a new plane for the chunk
	# Save transforms as they get reset when instance_count changes
	var transform_array := meshes[new_subdiv].multimesh.transform_array
	
	# Add another instance
	meshes[new_subdiv].multimesh.instance_count += 1
	
	# Add 4 blank vectors to avoid errors
	transform_array.resize(transform_array.size() + 4)
	
	# Put old transforms back into the multimesh
	meshes[new_subdiv].multimesh.transform_array = transform_array
	
	# Add our transform
	meshes[new_subdiv].multimesh.set_instance_transform(meshes[new_subdiv].multimesh.instance_count-1, t)
	
	# /!\ Unlock before return
	mutex_request_chunk.unlock()
	
	return meshes[new_subdiv].multimesh.instance_count - 1

func get_subdiv_count() -> int:
	return subdivisions
	
func get_chunk_size() -> float:
	return chunk_size
