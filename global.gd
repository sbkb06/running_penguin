@tool
extends Node

signal coin_collected
signal flag_raised(flag: Flag)
signal lives_changed
signal game_ended(ending: Endings)
signal game_started
signal gravity_changed(gravity: float)
signal timer_added

enum Endings { WIN, LOSE }
enum Player { ONE, TWO, BOTH }

var timer: Timer
var coins: int = 0:
	set = _set_coins
var lives: int = 0:
	set = _set_lives
var game_started_flag: bool = false

# مجموعة لكل العناصر اللي بدك توقفها عند pause
var pausable_nodes: Array = []

func collect_coin():
	coins += 1
	coin_collected.emit()

func raise_flag(flag: Flag):
	flag_raised.emit(flag)

func setup_timer(time_limit: int):
	timer = Timer.new()
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	timer.start(time_limit)
	timer.paused = true
	timer_added.emit()

func _on_timer_timeout():
	game_ended.emit(Endings.LOSE)

func _set_lives(value):
	if value < 0:
		return
	lives = value
	lives_changed.emit()
	if lives <= 0 and game_started_flag:
		game_ended.emit(Global.Endings.LOSE)

func _set_coins(value):
	coins = value

func _ready():
	for n in pausable_nodes:
		if is_instance_valid(n):
			n.pause_mode = 1 # STOP
 # في بعض النسخ 4.x ممكن هاي الطريقة


func _on_game_ended(_ending: Endings):
	if timer and not timer.is_stopped():
		timer.paused = true

func _on_game_start():
	game_started_flag = true
	if timer != null:
		timer.paused = false

# ✅ دالة لتصفير القيم
func reset():
	coins = 0
	lives = 1 # عدد الأرواح عند البداية
	# إعادة كل العناصر ضمن المجموعة pausable لوضعها الأولي
	for n in pausable_nodes:
		if is_instance_valid(n):
			if n.has_method("reset"):
				n.reset()

# دالة لإضافة عناصر لمجموعة pausable
func add_pausable_node(node: Node):
	if not pausable_nodes.has(node):
		pausable_nodes.append(node)
		if is_inside_tree():
			# الطريقة المضمونة
			node.pause_mode = 1 # STOP
