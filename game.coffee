
canvas = document.body.appendChild document.createElement "canvas"
ctx = canvas.getContext "2d"

# Create a World
@world = new p2.World
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

# For raycasting
result = new p2.RaycastResult

render = ->
	ctx.fillStyle = "white"
	ctx.fillRect(0, 0, canvas.width, canvas.height)
	ctx.save()
	ctx.translate(canvas.width/2, canvas.height/2)
	ctx.scale(100, 100)
	
	for body in world.bodies
		[x, y] = body.position
		ctx.save()
		ctx.translate(x, y)
		ctx.rotate(body.angle)
		for shape in body.shapes
			if shape instanceof p2.Rectangle
				ctx.beginPath()
				ctx.rect(-shape.width/2, -shape.height/2, shape.width, shape.height)
				ctx.lineWidth = 0.01
				ctx.stroke()
				ctx.fillStyle = "yellow"
				ctx.fill()
		ctx.restore()
	
	ctx.restore()

do animate = ->
	if canvas.width isnt window.innerWidth then canvas.width = window.innerWidth
	if canvas.height isnt window.innerHeight then canvas.height = window.innerHeight
	
	world.step 1/60
	render()
	requestAnimationFrame animate
