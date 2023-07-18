extends Node

class_name VersionDatabase


const settings = "user://settings.json"
const projects = "user://projects.json"

var file
var projfile
var settings_json = {
	"default_version_path": "%s/versions" % OS.get_user_data_dir(), 
	"veritems":[], 
	"is_cat":false
	} #template for settings.json

var projects_json = {"projects":[]} #template for projects.json

#checks is settings.json and projects.json exists, else adds him
func _init():
	if not FileAccess.file_exists(settings):
		FileAccess.open(settings, FileAccess.WRITE)
	
	file = FileAccess.open(settings, FileAccess.READ_WRITE)
	
	if not FileAccess.file_exists(projects):
		FileAccess.open(projects, FileAccess.WRITE)
	
	projfile = FileAccess.open(projects, FileAccess.READ_WRITE)
	
	if file.get_as_text() == "":
		file.store_string(str(settings_json))


func write_version_items(list_versions: Object):
	for i in list_versions.get_children():
		
		settings_json["veritems"].append(i.get_json())


func write_project_items(list_projects: Object):
	for i in list_projects.get_children():
		
		projects_json["projects"].append(i.get_json())

#writes default path
func write_default_path(verson_path: String):
	settings_json["default_version_path"] = verson_path

#umm...
func write_is_cat(is_cat:bool):
	settings_json["is_cat"] = is_cat


func load_version_items(list_versions: Object):
	for json_item in JSON.parse_string(file.get_as_text())["veritems"]:
		
		var ver_item = load("res://scenes/versionitem.tscn").instantiate()
		
		if json_item["icon"] not in ["<null>", ""] and FileAccess.file_exists(json_item["icon"]):
			ver_item.Icon = ImageLoader.load(json_item["icon"])
		else:
			ver_item.Icon = ImageLoader.load("res://resources/logo_engines/default.png") #if image isn't exist in database
		
		ver_item.Name = json_item["name"]
		ver_item.Path = json_item["path"]
		ver_item.Version = json_item["version"]
		ver_item.Args = json_item["args"]
		
		list_versions.add_child(ver_item)


func load_project_items(list_projects: Object):
	for json_item in JSON.parse_string(file.get_as_text())["projects"]:
		
		var project_item = load("res://scenes/projectitem.tscn").instantiate()
		
		if json_item["icon"] not in ["<null>", ""] and FileAccess.file_exists(json_item["icon"]):
			project_item.Icon = ImageLoader.load(json_item["icon"])
		else:
			project_item.Icon = ImageLoader.load("res://resources/logo_engines/default.png") #if image isn't exist in database
		
		project_item.Name = json_item["name"]
		project_item.Path = json_item["path"]
		project_item.EngineName = json_item["engine_name"]
		
		list_projects.add_child(project_item)

#loads default path (version path yet)
func load_default_path():
	return JSON.parse_string(file.get_as_text())["default_version_path"]

#uuummmm...
func load_cat():
	return JSON.parse_string(file.get_as_text())["is_cat"]

#saves changes and closes (in program - when closing)
func save_and_close():
	file = FileAccess.open(settings, FileAccess.WRITE)
	file.store_string(str(settings_json))
	
	projfile = FileAccess.open(projects, FileAccess.WRITE)
	projfile.store_string(str(projects_json))
	
	file = null
	projfile = null
