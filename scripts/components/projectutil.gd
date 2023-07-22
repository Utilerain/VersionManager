class_name ProjectUtil

##############################################################################
#
#WARNING!
#Util works only with projects that are developed on godot 3 and later. 
#(maybe i make for godot 2.x and 1.x but later)
#
##############################################################################

var configfile = ConfigFile.new()
var path


func _init(path):
	configfile.load(path)
	self.path = path


func get_name():
	return configfile.get_value("application", "config/name")


func get_icon_path():
	var icon_name = configfile.get_value("application", "config/icon").split("res://")[1]
	var temp: Array = path.split("/")
	temp.pop_at(-1)
	temp.append(icon_name)
	return "/".join(temp)
