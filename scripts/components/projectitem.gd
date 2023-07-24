extends Control

class_name ProjectItem

signal double_click(sender: ProjectItem)
signal on_open_button(sender: ProjectItem)
signal on_settings_button(sender: ProjectItem)
signal on_remove_button(sender: ProjectItem)

@export var Name: String = "Project"
@export var EngineName: String = "Engine Name"
@export var Icon: ImageTexture
@export var Path: String = "PATH"

@onready var icon := $MarginContainer/HBoxContainer/icon
@onready var project_name := $MarginContainer/HBoxContainer/VBoxContainer/ProjectName
@onready var engine := $MarginContainer/HBoxContainer/VBoxContainer/Engine
@onready var path := $MarginContainer/HBoxContainer/VBoxContainer/Path

var default_icon: ImageTexture


func _ready():
	default_icon = ImageTexture.create_from_image(load("res://resources/logo_engines/default.png").get_image())
	
#sets parameters for project item
func _process(_delta):
	project_name.text = Name
	engine.text = "Engine: %s" % EngineName
	path.text = Path
	
	if Icon:
		icon.texture = Icon
	else:
		icon.texture = default_icon
		Icon = default_icon

#gets JSON (dictionary) for projects.json
func get_json():
	var projectutil = ProjectUtil.new(Path)
	return {
		"name":Name,
		"icon":projectutil.get_icon_path(),
		"path":Path,
		"engine_name":EngineName,
	}


func _on_gui_input(event):
	if event is InputEventMouseButton and event.double_click:
		double_click.emit(self)


func _on_focus_entered():
	$MarginContainer/HBoxContainer/HBoxContainer.visible = true


func _on_focus_exited():
	$MarginContainer/HBoxContainer/HBoxContainer.visible = false


func _on_open_pressed():
	on_open_button.emit(self)


func _on_settings_pressed():
	on_settings_button.emit(self)


func _on_remove_pressed():
	on_remove_button.emit(self)
