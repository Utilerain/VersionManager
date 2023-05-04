extends Node

class_name VersionDatabase

var file
var json = {"default_version_path": "%s/versions" % OS.get_user_data_dir(), "veritems":[], "is_cat":false} #template for settings.json

#checks is settings.json exists, else adds him
func _init():
	if not FileAccess.file_exists("user://settings.json"):
		FileAccess.open("user://settings.json", FileAccess.WRITE)
	
	file = FileAccess.open("user://settings.json", FileAccess.READ_WRITE)
	
	if file.get_as_text() == "":
		file.store_string(str(json))


func write_version_items(list_versions: Object):
	for i in list_versions.get_children():
		
		json["veritems"].append(i.get_json())

#writes default paths (versions path yet)
func write_default_path(verson_path: String):
	json["default_version_path"] = verson_path

#umm...
func write_is_cat(is_cat:bool):
	json["is_cat"] = is_cat


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

#loads default path (version path yet)
func load_default_path():
	return JSON.parse_string(file.get_as_text())["default_version_path"]

#uuummmm...
func load_cat():
	return JSON.parse_string(file.get_as_text())["is_cat"]

#saves changes and closes (in program - when closing)
func save_and_close():
	file = FileAccess.open("user://settings.json", FileAccess.WRITE)
	file.store_string(str(json))
	file = null

