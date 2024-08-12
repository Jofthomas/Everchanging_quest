extends CanvasLayer
class_name LoadingScreen

var size_y
var marg = 4
var cpt = 0
@onready var bar = $ColorRect/Bar

var nodes=  []

func start_loading(p_steps):
	size_y = (bar.size.x-marg)/p_steps - marg
	visible = true
	cpt = 0
	progress_loading()
	
func progress_loading():
	var rect_loading = ColorRect.new()
	rect_loading.color = "Red"
	rect_loading.size.y = bar.size.y - marg*2
	rect_loading.position.y = bar.position.y + marg
	rect_loading.size.x = size_y
	rect_loading.position.x = bar.position.x + marg + (marg + size_y)*cpt
	rect_loading.z_index=1
	cpt += 1
	nodes.push_back(rect_loading)
	add_child(rect_loading)
	
func finish_loading():
	visible = false
	for node in nodes:
		remove_child(node)
	nodes = []
