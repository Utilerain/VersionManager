extends Window

var projectutil: ProjectUtil

@onready var labelerror := $MarginContainer/VBoxContainer/HBoxContainer3/Label
@onready var projectpath := $MarginContainer/VBoxContainer/HBoxContainer/ProjectPath
@onready var projectname := $MarginContainer/VBoxContainer/HBoxContainer2/VBoxContainer/Project
@onready var optengine := $MarginContainer/VBoxContainer/HBoxContainer2/VBoxContainer/HBoxContainer/OptionEngine
@onready var projecticon := $MarginContainer/VBoxContainer/HBoxContainer2/icon

func _on_close_requested():
	hide()


func _on_folder_pressed():
	$FileDialog.show()


func _on_file_dialog_file_selected(path):
	projectpath.text = path
	get_info(path)


func _on_project_path_text_changed(new_text):
	get_info(new_text)
	
	
func get_info(path):
	labelerror.visible = not FileAccess.file_exists(path)
	
	if FileAccess.file_exists(path):
		projectutil = ProjectUtil.new(path)
		projecticon.texture = ImageLoader.load(projectutil.get_icon_path())
		projectname.text = "Project: %s" % projectutil.get_name() 


func _on_add_project_pressed():
	
	var mainform = get_node("/root/MainForm")
	hide()
	
	mainform.add_project(projectutil.get_name(), projecticon.texture, optengine.selected, projectpath.text)
