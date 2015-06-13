
canvas = document.body.appendChild document.createElement "canvas"
ctx = canvas.getContext "2d"

# Create a World
@world = new p2.World gravity: [0, -10]

# Set high friction so the wheels don't slip
world.defaultContactMaterial.friction = 100

# A little shortcut
add = (body)-> world.addBody body

# Make a room with walls, a foor, and a ceiling
room_width = 8
room_height = 5
wall_thickness = 0.1
fleiling_thickness = 0.1

for x in [-room_width/2, +room_width/2]
	add wall = new p2.Body position: [x, 0]
	wall.addShape new p2.Rectangle wall_thickness, room_height + fleiling_thickness

for y in [-room_height/2, +room_height/2]
	add fleiling = new p2.Body position: [0, y]
	fleiling.addShape new p2.Rectangle room_width + wall_thickness, fleiling_thickness

class LaserBody extends p2.Body
	result = new p2.RaycastResult
	fillStyle: "#fff"
	constructor: ->
		super
		@addShape new p2.Rectangle 0.4, 0.2
	
	draw: ->
		super
		result.reset()
		[x, y] = @position
		{width, height} = @shapes[0]
		# heheh laser jump rope
		start = [x + Math.sin(@angle)*0.3, y + Math.cos(@angle)*0.3]
		end = [x + Math.sin(@angle)*500, y + Math.cos(@angle)*500]
		# r = width / 2 + 0.03
		# start = [x + Math.cos(@angle)*r, y + Math.sin(@angle)*r]
		# end = [x + Math.cos(@angle)*500, y + Math.sin(@angle)*500]
		world.raycastClosest start, end, {}, result
		if result.hasHit then end = result.hitPointWorld
		ctx.beginPath()
		ctx.moveTo(start[0], start[1])
		ctx.lineTo(end[0], end[1])
		ctx.strokeStyle = "#FF886B"
		ctx.lineWidth = 0.02
		ctx.stroke()

p2.Body::fillStyle = "#bbb"
p2.Body::draw = ->
	[x, y] = @position
	ctx.save()
	ctx.translate(x, y)
	ctx.rotate(@angle)
	for shape in @shapes
		if shape instanceof p2.Rectangle
			ctx.beginPath()
			ctx.rect(-shape.width/2, -shape.height/2, shape.width, shape.height)
			ctx.lineWidth = 0.01
			ctx.stroke()
			ctx.fillStyle = @fillStyle
			ctx.fill()
	ctx.restore()

add laser = new LaserBody position: [0, 0], mass: 1

setInterval ->
	laser.angularVelocity = if Math.random() < 0.5 then -60 else +60
, 1000

render = ->
	ctx.fillStyle = "#403c45"
	ctx.fillRect(0, 0, canvas.width, canvas.height)
	ctx.save()
	ctx.translate(canvas.width/2, canvas.height/2)
	ctx.scale(100, -100)
	
	for body in world.bodies
		ctx.save()
		body.update?()
		body.draw()
		ctx.restore()
	
	ctx.restore()

do animate = ->
	if canvas.width isnt window.innerWidth then canvas.width = window.innerWidth
	if canvas.height isnt window.innerHeight then canvas.height = window.innerHeight
	
	world.step 1/60
	
	render()
	requestAnimationFrame animate
