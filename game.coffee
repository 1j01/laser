
tau = Math.PI * 2 # one turn in radians

# Some sort of... drawing surface!?
canvas = document.body.appendChild document.createElement "canvas"
ctx = canvas.getContext "2d"

# Some sort of... pointing device!?
mouse = x: Infinity, y: Infinity, body: new p2.Body

# Create a World
@world = new p2.World gravity: [0, -10]

# Set high friction
world.defaultContactMaterial.friction = 100

# A couple helpers for adding and removing things from the world
add = (thing)->
	switch
		when thing instanceof p2.Body
			world.addBody thing
		when thing instanceof p2.Constraint
			world.addConstraint thing
		else
			throw new Error "I don't know how to add #{thing} to the world"

remove = (thing)->
	switch
		when thing instanceof p2.Body
			world.removeBody thing
		when thing instanceof p2.Constraint
			world.removeConstraint thing
		else
			throw new Error "I don't know how to remove #{thing} from the world"
	

# A glorified box
class Room
	constructor: ->
		room_width = 8
		room_height = 5
		wall_thickness = 0.2
		fleiling_thickness = 0.2

		for x in [-room_width/2, +room_width/2]
			add wall = new p2.Body position: [x, 0]
			wall.addShape new p2.Rectangle wall_thickness, room_height + fleiling_thickness

		for y in [-room_height/2, +room_height/2]
			add fleiling = new p2.Body position: [0, y]
			fleiling.addShape new p2.Rectangle room_width + wall_thickness, fleiling_thickness


lasers = []

class Laser
	length = 0.5
	width = 0.14
	side_width = 0.03
	butt_length = 0.1
	butt_width = width - side_width
	constructor: ({position: [x, y]})->
		lasers.push @
		@beams = []
		@result = new p2.RaycastResult
		
		add @body1 = new p2.Body mass: 1, position: [
			x + Math.cos(+tau/4) * width/2
			y + Math.sin(+tau/4) * width/2
		]
		@body1.addShape new p2.Rectangle length, side_width
		
		add @body2 = new p2.Body mass: 1, position: [
			x + Math.cos(-tau/4) * width/2
			y + Math.sin(-tau/4) * width/2
		]
		@body2.addShape new p2.Rectangle length, side_width
		
		add @butt = new p2.Body mass: 1, position: [
			x + Math.cos(tau/2) * (length - butt_length)/2
			y + Math.sin(tau/2) * (length - butt_length)/2
		]
		@butt.addShape new p2.Rectangle butt_length, butt_width
		
		add new p2.LockConstraint @body1, @body2
		add new p2.LockConstraint @body1, @butt
		add new p2.LockConstraint @body2, @butt
	
	update: ->
		[x1, y1] = @body1.position
		[x2, y2] = @body2.position
		{@angle} = @body1
		@x = (x1 + x2) / 2
		@y = (y1 + y2) / 2
		@start = [@x + Math.cos(@angle)*length/2*0.9, @y + Math.sin(@angle)*length/2*0.9]
		@end = [@x + Math.cos(@angle)*500, @y + Math.sin(@angle)*500]
		@result.reset()
		world.raycastClosest @start, @end, {}, @result
		@end = @result.hitPointWorld if @result.hasHit
	
	draw: ->
		ctx.save()
		ctx.beginPath()
		ctx.moveTo(@start[0], @start[1])
		ctx.lineTo(@end[0], @end[1])
		ctx.strokeStyle = "#EB0315"
		ctx.lineWidth = 0.02
		ctx.stroke()
		ctx.strokeStyle = "rgba(255, 255, 255, 0.3)"
		ctx.lineWidth = 0.01
		ctx.stroke()
		ctx.restore()
		
		ctx.save()
		ctx.translate(@x, @y)
		ctx.rotate(@angle)
		ctx.beginPath()
		ctx.rect(-length/2, -width/2, length*0.95, width)
		ctx.fillStyle = "#222"
		ctx.fill()
		# ctx.lineWidth = 0.01
		# ctx.stroke()
		ctx.restore()


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


room = new Room

laser = new Laser position: [0, 0]

# setInterval ->
# 	laser.body1.angularVelocity = (Math.random()*2-1) * 200
# , 1000


view = {}

render = ->
	ctx.fillStyle = "#403c45"
	ctx.fillRect(0, 0, canvas.width, canvas.height)
	
	ctx.save()
	ctx.translate(view.centerX, view.centerY)
	ctx.scale(view.scaleX, view.scaleY)
	
	for body in world.bodies
		body.update?()
		body.draw()
	
	laser.update()
	laser.draw()
	
	ctx.beginPath()
	ctx.arc(mouse.x, mouse.y, 0.04, 0, tau)
	ctx.fillStyle = "rgba(255, 255, 255, 0.5)"
	ctx.fill()
	
	ctx.restore()

do animate = ->
	view =
		scaleX: +100
		scaleY: -100 # (y goes up in the world, down on the canvas)
		centerX: canvas.width/2
		centerY: canvas.height/2
	
	if canvas.width isnt window.innerWidth then canvas.width = window.innerWidth
	if canvas.height isnt window.innerHeight then canvas.height = window.innerHeight
	
	world.step 1/60
	
	render()
	requestAnimationFrame animate

update_mouse_position = (e)->
	mouse.x = (e.pageX - view.centerX) / view.scaleX
	mouse.y = (e.pageY - view.centerY) / view.scaleY
	mouse.body.position[0] = mouse.x
	mouse.body.position[1] = mouse.y

window.addEventListener "mousemove", (e)->
	update_mouse_position e

# isNearLine = (startX, startY, endX, endY, px, py)->
# 	tolerance = 1
# 	f = (x)-> (endY - startY) / (endX - startX) * (x - startX) + startY
# 	(startX <= px <= endX or startX >= px >= endX) and
# 	Math.abs(f(px) - py) < tolerance

dist2 = (v, w)-> (v[0] - w[0]) ** 2 + (v[1] - w[1]) ** 2
distToSegmentSquared = (p, v, w)->
	l2 = dist2(v, w)
	return dist2(p, v) if l2 is 0
	t = ((p[0] - v[0]) * (w[0] - v[0]) + (p[1] - v[1]) * (w[1] - v[1])) / l2
	return dist2(p, v) if t < 0
	return dist2(p, w) if t > 1
	dist2(p, [
		v[0] + t * (w[0] - v[0])
		v[1] + t * (w[1] - v[1])
	])
distToSegment = (p, v, w)-> Math.sqrt(distToSegmentSquared(p, v, w))


canvas.addEventListener "mousedown", (e)->
	update_mouse_position e
	for laser in lasers
		# [startX, startY] = laser.start
		# [endX, endY] = laser.end
		# if isNearLine startX, startY, endX, endY, mouse.x, mouse.y
		if distToSegment([mouse.x, mouse.y], laser.start, laser.end) < 0.1
			# console.log "near laser"
			
			# add mouse.constraint = new p2.RevoluteConstraint mouse.body, laser.butt, localPivotA: [0, 0], localPivotB: [0, 0]
			
			add mouse.constraint = new p2.DistanceConstraint mouse.body, laser.butt, localPivotA: [0, 0], localPivotB: [0, 0]
			# add mouse.constraint = new p2.DistanceConstraint mouse.body, laser.body1, localPivotA: [0, 0], localPivotB: [0, 0]
			# add mouse.constraint = new p2.DistanceConstraint mouse.body, laser.body2, localPivotA: [0, 0], localPivotB: [0, 0]
			
			# laserMousePivot = [0, 0]
			# p2.vec2.toLocalFrame laserMousePivot, [mouse.x, mouse.y], laser.butt.position, laser.butt.angle
			# add mouse.constraint = new p2.RevoluteConstraint mouse.body, laser.butt, localPivotA: [0, 0], localPivotB: laserMousePivot

window.addEventListener "mouseup", (e)->
	update_mouse_position e
	if mouse.constraint
		remove mouse.constraint
		delete mouse.constraint

