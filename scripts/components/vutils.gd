extends Node

class_name V_utils

const base_url = "https://downloads.tuxfamily.org/godotengine/" #url for searching godot versions

#Warning! Use this for scanning body in https://downloads.tuxfamily.org/godotengine/
static func scan_version(body):
	Logger.info("call scan_version")
	var regex = RegEx.new()
	regex.compile("[0-9]\\.[0-9](\\.[0-9])?") #compiles versions
	var res = regex.search_all(body.get_string_from_utf8())
	var versionlist = []
	
	for i in res:
		if i.get_string() not in versionlist:
			versionlist.append(i.get_string())
	versionlist.pop_at(0)
	versionlist.pop_at(-1)
	
	Logger.info("found: %s" % ", v".join(versionlist))
	return versionlist
	
#Warning! Use this for scanning body in https://downloads.tuxfamily.org/godotengine/x.x.x/
static func scan_type(body):
	Logger.info("call scan_type")
	var regex = RegEx.new()
	regex.compile("stable|(alpha|beta|rc|dev)[0-9][0-9]?") #compiles types
	var res = regex.search_all(body.get_string_from_utf8())
	var typelist = []
	for i in res:
		if i.get_string() not in typelist:
			typelist.append(i.get_string())
	
	Logger.info("found: %s" % ", ".join(typelist))
	return typelist

#checks .NET support of current engine
static func check_mono(body):
	Logger.info("call check_mono")
	var regex = RegEx.new()
	regex.compile("(\\bmono\\b)")
	return regex.search(body.get_string_from_utf8()) == null

#checks is current version selected returns an error
static func check_version(version) -> Error:
	if version == null:
		Logger.error("user not selected version")
		OS.alert("You're not selected version", "Warning!")
		return ERR_INVALID_DATA
	return OK
	
