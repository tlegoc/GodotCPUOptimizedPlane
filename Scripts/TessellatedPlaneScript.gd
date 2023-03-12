class_name TessellatedPlane extends Node3D

@export_category("Tessellation Properties")
@export_range(.1, 50) var chunk_size: float = 16
@export_range(0, 100, 1) var chunk_count: int = 1
@export_range(1, 10, 1) var subdivisions: int = 9

@export_category("Tessellation Rendering")
@export var water_material: Material

var plane: Array[ArrayMesh]
var meshes: Array[MultiMeshInstance3D]

# Called when the node enters the scene tree for the first time.
func _ready():
	get_viewport().debug_draw = Viewport.DEBUG_DRAW_WIREFRAME
	#$Mesh.mesh = generate(10, .2)
	
	plane = []
	meshes = []
	
	for sub in range(0, subdivisions):
		plane.append(generate(pow(2, sub), chunk_size/pow(2, sub)))
		meshes.append(MultiMeshInstance3D.new())
		add_child(meshes[sub])
		meshes[sub].multimesh = MultiMesh.new()
		meshes[sub].multimesh.instance_count = 0
		meshes[sub].multimesh.mesh = plane[sub]
		meshes[sub].multimesh.transform_format = MultiMesh.TRANSFORM_3D
		meshes[sub].multimesh.instance_count = 1
		meshes[sub].multimesh.set_instance_transform(0, Transform3D.IDENTITY)
	
	for i in range(0, chunk_count):
		for j in range(0, chunk_count):
			pass
	

func generate(cell_count: int, cell_size: float) -> ArrayMesh:
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
