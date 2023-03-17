class_name TessellatedPlane extends Node3D


@export_category("Tessellation Properties")
@export_range(.1, 50) var chunk_size: float = 16
@export_range(1, 100, 1) var chunk_count: int = 50
@export_range(1, 10, 1) var subdivisions: int = 8

@export_category("Tessellation Rendering")
@export var water_material: Material

var plane: Array[ArrayMesh]
var meshes: Array[MultiMeshInstance3D]
var request_chunk_mutex: Mutex
var chunks: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	init_tessellated_plane()
	request_chunk_mutex = Mutex.new()

func clear_plane():
	for child in get_children():
		child.queue_free()
	
	chunks = {}
	plane = []
	meshes = []

func init_tessellated_plane():
	clear_plane()
	
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
			add_child(chunk)
			chunk.name = str(i * j)
			chunk.position = Vector3(i * chunk_size, 0, j * chunk_size)
			chunk.init_chunk()
			chunks[chunk.name] = [-1, -1]

func gen_plane(cell_count: int, cell_size: float) -> ArrayMesh:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for x in range(0, cell_count + 1):
		for y in range (0, cell_count + 1):
			st.add_vertex(Vector3(x * cell_size, 0,  y * cell_size))
	
	st.deindex()
	var vi: int = 0
	for x in range(0, cell_count):
		for y in range (0, cell_count):
			st.add_index(vi)
			st.add_index(vi + cell_count + 1)
			st.add_index(vi + 1)
			st.add_index(vi + 1)
			st.add_index(vi + cell_count + 1)
			st.add_index(vi + cell_count + 2)
			vi+=1
		vi+=1
	st.set_material(water_material)
	return st.commit()

func request_chunk(c: TessellatedPlaneChunk, new_subdiv: int, t: Transform3D):
	var current = chunks[c.name]
	if current[0] == new_subdiv:
		return
	
	request_chunk_mutex.lock()
	# Removing the old div
	if current[0] != -1 && current[1] != -1:
		var mm = meshes[current[0]].multimesh
		
		mm.set_instance_transform(current[1], mm.get_instance_transform(mm.instance_count-1))
		
		chunks[chunks.find_key([current[0], mm.instance_count-1])][1] = current[1]
		
		var array = mm.transform_array
		array.resize(array.size() - 4)
		
		mm.instance_count -= 1
		mm.transform_array = array
	
	var mm = meshes[new_subdiv].multimesh
	
	var array = mm.transform_array
	
	array.resize(array.size() + 4)
	
	mm.instance_count += 1
	
	mm.transform_array = array
	
	mm.set_instance_transform(mm.instance_count - 1, t)
	
	chunks[c.name] = [new_subdiv, mm.instance_count - 1]
	
	request_chunk_mutex.unlock()
