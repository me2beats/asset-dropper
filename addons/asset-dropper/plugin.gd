tool
extends EditorPlugin

const Utils = preload("utils.gd")



var Dir: = Directory.new()

var ed_interface: = get_editor_interface()
var base: = ed_interface.get_base_control()

var scene_tree_control:Tree
var fs_tree:Tree

var canvas_item_editor:Container
var spatial_editor:Container

var dragging_files: = false

var can_drop: = false


func _notification(what):
	match what:
		NOTIFICATION_DRAG_BEGIN:
			if fs_tree.has_focus():
				dragging_files = true

		NOTIFICATION_DRAG_END:
			if not dragging_files: return false
			dragging_files = false
			
			if !can_drop: return
			
			add_audio_players()


# from godot fs to any control node of where array
func are_files_dragged_to(where:Array)->Control:
	var empty:Control
	if Input.get_current_cursor_shape() == Input.CURSOR_CAN_DROP:
		return empty


	var mouse = base.get_global_mouse_position()
	
	for node in [scene_tree_control, canvas_item_editor, spatial_editor]:
		node = node as Control
		if node.visible and node.get_global_rect().has_point(mouse):
			return node
	return empty


func add_audio_players():
	var sel_items: = Utils.get_selected_paths(fs_tree)
	
	var target_parent:Node
	
	var sel_nodes:Array = ed_interface.get_selection().get_selected_nodes()
	var current_scene_root:Node = ed_interface.get_edited_scene_root()
	
	if sel_nodes:
		target_parent = sel_nodes[0]
	else:
		target_parent = current_scene_root


	if !sel_items: return
	
	var Undo = get_undo_redo()

	Undo.create_action("AssetDropper - Add audio", Undo.MERGE_ALL)

	for i in sel_items:
		i = i as String


		if not i.get_extension(): continue # skip folders

		var resource = load(i)
		if not resource is AudioStream: continue
		
		var player:=AudioStreamPlayer.new()
		player.stream = resource
		player.name = resource.resource_path.get_file().get_basename()

		Undo.add_do_method(target_parent, "add_child", player)
		Undo.add_do_property(player, "owner", current_scene_root)
		Undo.add_do_reference(player)
		Undo.add_undo_method(target_parent, "remove_child", player)

	Undo.commit_action()


var idle_input_timer: = Timer.new()	

func on_idle_input_timer_timeout():

	var target: = are_files_dragged_to([scene_tree_control, canvas_item_editor, spatial_editor])
	if not target: return

	if Input.get_current_cursor_shape() == base.CURSOR_FORBIDDEN:
		Input.set_default_cursor_shape(base.CURSOR_CAN_DROP)
		Input.set_default_cursor_shape(base.CURSOR_ARROW)
		can_drop = true
	

func _input(event):
	if not dragging_files: return
	if ! event is InputEventMouseMotion: return
	event = event as  InputEventMouseMotion
	if not event.button_mask: return

	can_drop = false
	idle_input_timer.start()


func _enter_tree():
	
	yield(get_tree(), "idle_frame")

	
	idle_input_timer.name = 'IdleInput'
	idle_input_timer.wait_time = 0.2
	idle_input_timer.connect("timeout", self, "on_idle_input_timer_timeout")
	idle_input_timer.one_shot = true
	add_child(idle_input_timer)

	canvas_item_editor = Utils.get_canvas_item_editor(self)
	spatial_editor = Utils.get_spatial_editor(self)


	scene_tree_control = Utils.get_scene_tree_node(self)
	if not scene_tree_control:
		push_warning('scene tree not found')
		return


	fs_tree = Utils.get_fylesystem_tree(self)

