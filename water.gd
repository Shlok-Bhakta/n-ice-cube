@tool
extends Node2D
class_name Water

@onready var area: Area2D = $Area2D
@onready var shape: CollisionShape2D = $Area2D/CollisionShape2D


@export var water_size: Vector2 = Vector2(8.0, 16.0)
@export var surface_pos_y: float = 0.5
@export_range(2,512) var segment_count: int = 64

@export_range(0.0, 1000.0) var water_physics_speed: float = 80.0
@export var water_restoring_force: float = 0.03
@export var wave_energy_loss: float = 0.10
@export var wave_strength: float = 0.20
@export var max_wave_height: float = 30.0  
@export var max_wave_velocity: float = 100.0
@export_range(1,64) var wave_spread_updates: int = 2

@export var surface_line_thickness: float = 1.0
@export var surface_color: Color = Color("86ecfdff")
@export var water_fill_color: Color = Color("45f9fbff")

var segment_data: Array = []
var recently_splashed: bool = false

var surface_line: Line2D
var fill_polygon: Polygon2D

@export_tool_button("Update_Water") var update_water_button: Callable = func():
	_ready()
	_update_visuals()

var player: Node2D

func _ready() -> void:
	_initiate_water()
	player = get_tree().get_first_node_in_group("player")
	
	if player:
		global_position.x = player.global_position.x



func _initiate_water() -> void:
	segment_data.clear()

	for i in range(segment_count):
		segment_data.append({
			"height": surface_pos_y,
			"velocity": 0.0,
			"wave_to_left": 0.0,
			"wave_to_right": 0.0,
		})

	# Surface line
	surface_line = Line2D.new()
	surface_line.width = surface_line_thickness
	surface_line.default_color = surface_color
	add_child(surface_line)

	# Fill polygon
	fill_polygon = Polygon2D.new()
	fill_polygon.color = water_fill_color
	fill_polygon.show_behind_parent = true
	surface_line.add_child(fill_polygon)

	# --- COLLISION SHAPE SETUP (correct indentation) ---
	var rect := RectangleShape2D.new()
	rect.size = water_size
	shape.shape = rect

	# Center the rectangle under the surface
	shape.position = Vector2(
		water_size.x / 2.0,
		water_size.y / 2.0
	)

	
func _process(delta: float) -> void:
	update_physics(delta)
	_update_visuals()


func update_physics(delta: float) -> void:
	for i in range(segment_count):
		var displacement = segment_data[i]["height"] - surface_pos_y
		var acc = -water_restoring_force * displacement

		segment_data[i]["velocity"] += acc * delta * water_physics_speed
		segment_data[i]["velocity"] *= (1.0 - wave_energy_loss)

		segment_data[i]["velocity"] = clampf(
			segment_data[i]["velocity"],
			-max_wave_velocity,
			max_wave_velocity
		)

		segment_data[i]["height"] += segment_data[i]["velocity"] * delta * water_physics_speed

		segment_data[i]["height"] = clampf(
			segment_data[i]["height"],
			surface_pos_y - max_wave_height,
			surface_pos_y + max_wave_height
		)

	# ---- stable wave spread ----
	var spread := wave_strength * 0.25
	for i in range(1, segment_count - 1):
		var left_delta  = segment_data[i]["height"] - segment_data[i - 1]["height"]
		var right_delta = segment_data[i]["height"] - segment_data[i + 1]["height"]

		segment_data[i - 1]["velocity"] += left_delta  * spread
		segment_data[i + 1]["velocity"] += right_delta * spread

	# ---- lock the edges ----
	segment_data[0]["height"] = surface_pos_y
	segment_data[0]["velocity"] = 0.0
	segment_data[1]["height"] = surface_pos_y
	segment_data[1]["velocity"] = 0.0

	segment_data[segment_count - 1]["height"] = surface_pos_y
	segment_data[segment_count - 1]["velocity"] = 0.0
	segment_data[segment_count - 2]["height"] = surface_pos_y
	segment_data[segment_count - 2]["velocity"] = 0.0

	# sleep logic unchanged
	if !recently_splashed:
		var still := true
		for p in surface_line.points:
			if abs(abs(p.y) - abs(surface_pos_y)) > 0.001:
				still = false
				break
		set_process(!still)
	else:
		recently_splashed = false

func _update_visuals() -> void:
	var points: Array[Vector2] = []
	var segment_width := water_size.x / (segment_count - 1)

	for i in range(segment_count):
		points.append(Vector2(i * segment_width, segment_data[i]["height"]))

	var left_static := Vector2(points[0].x, surface_pos_y)
	var right_static := Vector2(points[-1].x, surface_pos_y)

	var final_points: Array[Vector2] = []
	final_points.append(left_static)
	final_points += points
	final_points.append(right_static)

	surface_line.points = final_points

	var bottom_y := surface_pos_y + water_size.y
	final_points.append(Vector2(water_size.x, bottom_y))
	final_points.append(Vector2(0, bottom_y))
	fill_polygon.polygon = final_points


func splash(splash_pos: Vector2, splash_velocity: float) -> void:
	splash_velocity = clampf(splash_velocity, -120.0, 120.0)

	# Find where the water actually is in world-space
	# NOTE: because the CollisionShape is centered (pos = water_size/2)
	# the true LEFT EDGE is:
	var left := area.global_position.x - (water_size.x / 2.0)
	var right := area.global_position.x + (water_size.x / 2.0)

	# How far across the water is the player (0..1)
	var t := clampf((splash_pos.x - left) / (right - left), 0.0, 1.0)

	var center_index := int(round(t * float(segment_count - 1)))

	print("--- DEBUG ---")
	print("player =", splash_pos.x)
	print("water left =", left)
	print("water right =", right)
	print("% across (t) =", t)
	print("index =", center_index)

	var radius := 2
	for o in range(-radius, radius + 1):
		var idx : int = clampi(center_index + o, 0, segment_count - 1)
		var falloff : float = 1.0 - (abs(o) / float(radius + 1))
		segment_data[idx]["velocity"] = splash_velocity * falloff

	recently_splashed = true
	set_process(true)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("can_interact_with_water"):
		splash(body.global_position, -100.0)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("can_interact_with_water"):
		splash(body.global_position, 70.0)
