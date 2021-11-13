#================= Node Utils ==================

static func find_child_by_class(node:Node, cls:String):
	for child in node.get_children():
		if child.get_class() == cls:
			return child


static func find_node_by_class_path(node:Node, class_path:Array)->Node:
	var res:Node

	var stack = []
	var depths = []

	var first = class_path[0]
	for c in node.get_children():
		if c.get_class() == first:
			stack.push_back(c)
			depths.push_back(0)

	if not stack: return res
	
	var max_ = class_path.size()-1

	while stack:
		var d = depths.pop_back()
		var n = stack.pop_back()

		if d>max_:
			continue
		if n.get_class() == class_path[d]:
			if d == max_:
				res = n
				return res

			for c in n.get_children():
				stack.push_back(c)
				depths.push_back(d+1)

	return res


#========== Tree Utils ============
#get all selected items
static func tree_get_selected_items(tree:Tree)->Array:
	var res = []
	var item = tree.get_next_selected(tree.get_root())
	while true:
		if not item: break
		res.push_back(item)
		item = tree.get_next_selected(item)
	return res


#========= FS Dock Utils ==========

static func get_fylesystem_tree(plugin:EditorPlugin)->Tree:
	var dock = plugin.get_editor_interface().get_file_system_dock()
	return find_node_by_class_path(dock, ['VSplitContainer','Tree']) as Tree


static func get_selected_paths(fs_tree:Tree)->Array:
	var sel_items: = tree_get_selected_items(fs_tree)
	var result: = []
	for i in sel_items:
		i = i as TreeItem
		result.push_back(i.get_metadata(0))
	return result


#========== Scene Tree uils =======

static func get_scene_tree_node(plugin:EditorPlugin)->Tree:
	var scene_tree_dock:Container= plugin.get_editor_interface().get_base_control().find_node("Scene", 1,0)
	return find_node_by_class_path(scene_tree_dock, ['SceneTreeEditor', 'Tree']) as Tree


#CanvasItemEditor, SpatialEditor
#========== ===================
static func get_main_editors_parent(base:Panel):
	return find_node_by_class_path(
		base, 
		[
			'VBoxContainer',
			'HSplitContainer',
			'HSplitContainer',
			'HSplitContainer',
			'VBoxContainer',
			'VSplitContainer',
			'VSplitContainer',
			'VBoxContainer',
			'PanelContainer',
			'VBoxContainer'
		]
		
	)

static func get_canvas_item_editor(base:Panel)->Control:
	return find_child_by_class(get_main_editors_parent(base), "CanvasItemEditor")

static func get_spatial_editor(base:Panel)->Control:
	return find_child_by_class(get_main_editors_parent(base), "SpatialEditor")

