extends Node

class_name VersionScanner

#Warning! Use this for scanning body in https://downloads.tuxfamily.org/godotengine/
static func scan_version(body):
	var regex = RegEx.new()
	regex.compile("[0-9]\\.[0-9](\\.[0-9])?") #compiles versions
	var res = regex.search_all(body.get_string_from_utf8())
	var versionlist = []
	
	for i in res:
		if i.get_string() not in versionlist:
			versionlist.append(i.get_string())
	versionlist.pop_at(0)
	versionlist.pop_at(-1)
	
	return versionlist
	
#Warning! Use this for scanning body in https://downloads.tuxfamily.org/godotengine/x.x.x/
static func scan_type(body):
	var regex = RegEx.new()
	regex.compile("stable|(alpha|beta|rc|dev)[0-9][0-9]?")
	var res = regex.search_all(body.get_string_from_utf8())
	var typelist = []
	for i in res:
		if i.get_string() not in typelist:
			typelist.append(i.get_string())
	
	return typelist
	
