
new p2.WebGLRenderer ->
	
	# Create a World
	@setWorld world = new p2.World
		gravity: [0, -10] # Set gravity to -10 in y direction
	
	# Set high friction so the wheels don't slip
	world.defaultContactMaterial.friction = 100
	
	# Make a room with walls, a foor, and a ceiling
	room_width = 8
	room_height = 5
	wall_thickness = 0.1
	fleiling_thickness = 0.1
	
	for x in [-room_width/2, +room_width/2]
		wall = new p2.Body position: [x, 0]
		wall.addShape new p2.Rectangle wall_thickness, room_height + fleiling_thickness
		world.addBody wall
	
	for y in [-room_height/2, +room_height/2]
		fleiling = new p2.Body position: [0, y]
		fleiling.addShape new p2.Rectangle room_width + wall_thickness, fleiling_thickness
		world.addBody fleiling
	
	@frame 0, 0, 8, 6
