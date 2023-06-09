# GodotCPUOptimizedPlane

Small experiment with godot and tessellation. This project contains gdscript code to create optimized planes for use with large plane bodies such as oceans.

Ideally this would be done on the GPU with tessellation but since godot doesn't support it you have to make an alternative using the CPU. 

![image](https://user-images.githubusercontent.com/21106616/225936238-142df0d4-873c-463d-9f42-dce5cc7d773a.png)

## Todo
- Normals and UVs
- Better selection of resolutions
- Less visible seams between chunks
- ability to offset chunks position 
- Ocean shader
- Ocean wave generator (FFT work)
- C++ Fork, gdscript is not really fast enough for this kind of operations
