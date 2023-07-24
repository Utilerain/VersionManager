extends Node

class_name MainForm

const base_url = "https://downloads.tuxfamily.org/godotengine/"

@onready var addenginepopup := $AddEngineDialog
@onready var addcustomenginepopup := $AddCustomEngineDialog
@onready var addprojectpopup := $AddProjectDialog
@onready var settingspopup := $SettingsDialog
@onready var aboutpopup := $AboutDialog
@onready var settingsenginepopup := $SettingsForEngineDialog
@onready var regex := RegEx.new()
@onready var verdb := VersionDatabase.new()
@onready var listVersion := $MainBox/TabContainer/Versions/ListVersions
@onready var listProject := $MainBox/TabContainer/Projects/ScrollContainer/ListProjects
@onready var engineMenu := $MenuBox/EngineMenu
@onready var engineIcon := $MenuBox/EngineMenu/VBoxContainer/EngineIcon
@onready var engineName := $MenuBox/EngineMenu/VBoxContainer/EngineName
@onready var addEngine := $HeadBar/BarBg/Bar/AddEngine
@onready var opteng := $AddProjectDialog/MarginContainer/VBoxContainer/HBoxContainer2/VBoxContainer/HBoxContainer/OptionEngine

var default_version_path: String = ProjectSettings.globalize_path("user://versions")
var sender_item: VersionItem
var url
var filename

#initialize base functions
func _ready():
	if not verdb.load_default_path() == "":
		default_version_path = verdb.load_default_path()
		
	verdb.load_version_items(get_node("./MainBox/TabContainer/Versions/ListVersions"))
	verdb.load_project_items(get_node("./MainBox/TabContainer/Projects/ScrollContainer/ListProjects"))
	
	$"cat???".visible = verdb.load_cat()
	
	engineMenu.visible = false
	
	#if version list isn't clear
	if listVersion.get_children() != null:
		for item in listVersion.get_children():
			opteng.add_item("%s (%s)" % [item.Name, item.Version])
			item.button_pressed.connect(self._on_item_selected)
			item.double_click.connect(self._on_veritem_start)
	
	if listProject.get_children() != null:
		for item in listProject.get_children():
			item.double_click.connect(self._on_projitem_start)
			item.on_open_button.connect(self._on_projitem_open_button)
			item.on_settings_button.connect(self._on_projitem_settings_button)
			item.on_remove_button.connect(self._on_projitem_remove_button)

#starts download progress of version
func start_download_progress(version, type, platform, custom_name="Godot engine", custom_icon=ImageTexture.create_from_image(load("res://resources/logo_engines/default.png").get_image()), monosupport=false):
	addEngine.disabled = true
	
	var ver_item = load("res://scenes/versionitem.tscn").instantiate() #versionitem for version list
	
	var regex_compiled_string = "Godot_v{version}(-|_){type}(_mono)?({platform})".format(
		{
			"version": version,
			"platform": platform,
			"type": type
		}
	)
	
	regex.compile(regex_compiled_string) # compiles different godot version (Example: Godot_v3.5-stable_win64.exe.zip)
	
	if custom_name == "":
		custom_name = "Godot engine"

	if url == null:
		url = base_url + version 
		
		if type != "stable":
			url += "/{type}".format({"type":type})
		
		if monosupport:
			url += "/mono"
	
	DirAccess.make_dir_absolute(default_version_path)
	var dir = DirAccess.open(default_version_path)
	var count = 0
	
	for item in listVersion.get_children():
		if custom_name in item.Name: #if name of engine has same name of other engine
			count += 1
			continue
	
	if count > 0:
		custom_name += "(%s)" % count
	
	var is_mono = ""
	
	if monosupport:
		is_mono = "_mono"
	
	dir.make_dir_recursive("{name}({version}{type}{mono})".format({
		"name": custom_name,
		"version": version,
		"type":type,
		"mono":is_mono
	}))

	var req = HTTPRequest.new()
	req.request_completed.connect(self._on_req_request_completed)
	add_child(req)
	
	if filename:
		ver_item.Version = version + type 
		if monosupport:
			ver_item.Version += "_mono"
		ver_item.Icon = custom_icon
		ver_item.button_pressed.connect(self._on_item_selected)
		ver_item.double_click.connect(self._on_veritem_start)
		listVersion.add_child(ver_item)
		
		filename = filename.format({
			"name": custom_name,
			"version": ver_item.Version
		})
		
		req.download_file = filename
		req.request_completed.disconnect(self._on_req_request_completed)
	
	else:
		req.request(url, ["User-Agent: *"])
		await req.request_completed
		await start_download_progress(version, type, platform, custom_name, custom_icon, monosupport) #restarts function (recursive, bruh)
		return

	req.request(url, ["User-Agent: *"])
	var divisor : float = 1024 * 1024
	
	while req.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED: #downloads file
		ver_item.disabled = true
		ver_item.Name = "Downloading... [%.2f/%.2fMB]." % [req.get_downloaded_bytes() / divisor, req.get_body_size() / divisor]
		await get_tree().create_timer(0.5).timeout
	
	ver_item.Name = "Extracting..."
	await get_tree().create_timer(0.2).timeout
	
	var unzipper = load("res://scripts/CSharp/unzipper.cs")
	var zipfile = unzipper.new()
	

	zipfile.load(filename)
	
	await zipfile.extract()
	ver_item.Name = custom_name
	
	
	#configuration for extracting (not MacOs)
	if not OS.has_feature("macos"):
		var folder = filename.split("/")
		folder.remove_at(len(folder)-1)
		folder = "/".join(folder)
		
		var file = filename.split("/")[-1]
		var exec_filename = file.split(".")
		exec_filename.remove_at(len(exec_filename)-1)
		exec_filename = ".".join(exec_filename)
		
		if monosupport:
			var monofolder = file.split(".")
			monofolder.remove_at(len(monofolder)-1)
			var mono_filename = monofolder.duplicate()
			monofolder = ".".join(monofolder)
			
			if OS.has_feature("windows"):
				mono_filename.append("exe")
				mono_filename = ".".join(mono_filename)
		
			elif OS.has_feature("linux"):
				mono_filename = ".".join(mono_filename)
				if "x11_" in mono_filename:
					mono_filename = mono_filename.replace("x11_", "x11.")
				elif "_x86" in mono_filename:
					mono_filename = mono_filename.replace("_x86", ".x86")
					
			ver_item.Path = "%s/%s/%s" % [folder, monofolder, mono_filename]
		
		else:
			ver_item.Path = "%s/%s" % [folder, exec_filename]
	
	else:
		#configuration for extracting (MacOs) (will be later)
		var temp = filename.split("/")
		temp.remove_at(len(temp)-1)
		if not monosupport:
			ver_item.Path = "{path}/Godot.app/MacOS/Godot".format({"path":"/".join(temp)})
		else:
			ver_item.Path = "{path}/Godot_mono.app/MacOS/Godot".format({"path":"/".join(temp)})
	
	DirAccess.remove_absolute(filename)
	url = null
	filename = ""
	ver_item.disabled = false
	addEngine.disabled = false
	opteng.add_item("%s (%s)" % [ver_item.Name, ver_item.Version])

#selects version from the list of versions
func _on_item_selected(sender):
	$MenuBox/Label.visible = false
	engineName.text = "%s (%s)" % [sender.Name, sender.Version]
	engineIcon.icon = sender.Icon
	sender_item = sender
	engineMenu.visible = true
	
	settingsenginepopup.title = engineName.text
	$SettingsForEngineDialog/MarginContainer/VBoxContainer/PathContainer/Path.text = sender.Path
	$SettingsForEngineDialog/MarginContainer/VBoxContainer/ArgsContainer/Args.text = sender.Args


# if filename == null
func _on_req_request_completed(_result, _response_code, _headers, body):
	var list = []
	var res = regex.search_all(body.get_string_from_utf8())
	
	for i in res:
		
		if i.get_string() not in list:
			list.append(i.get_string())

	var current_arch = list[0]
	
	if len(list) > 1:
		for i in list:
			
			if "64" in i and OS.get_environment("PROCESSOR_ARCHITECTURE").ends_with("64"):
				current_arch = i
				break
				
			current_arch = i
	
	url = url + "/%s" % current_arch
	filename = "{ver_path}/{name}({version})/{file}".format({
						"ver_path": default_version_path,
						"file": current_arch
	})


func _on_settings_pressed():
	settingspopup.show()


func _on_add_engine_pressed():
	addenginepopup.show()

#saves changes and closes program
func _exit_tree():
	verdb.write_is_cat($"cat???".visible)
	verdb.write_default_path(default_version_path)
	verdb.write_version_items(get_node("./MainBox/TabContainer/Versions/ListVersions"))
	verdb.write_project_items(get_node("./MainBox/TabContainer/Projects/ScrollContainer/ListProjects"))
	
	if FileAccess.open("user://settings.json", FileAccess.READ).get_as_text() == str(verdb.settings_json) and FileAccess.open("user://projects.json", FileAccess.READ).get_as_text() == str(verdb.projects_json):
		return
	
	verdb.save_and_close()

#removes engine with directories (not custom_build version)
func _on_delete_engine_pressed():
	if not "custom_build" in sender_item.Version:
		var temp = sender_item.Path.split("/")
		temp.remove_at(len(temp)-1)
		
		if "mono" in sender_item.Version:
			temp.remove_at(len(temp)-1)
		
		V_utils.delete_directory("/".join(temp))
	
	for idx in range(opteng.item_count):
		if "%s (%s)" % [sender_item.Name, sender_item.Version] in opteng.get_item_text(idx):
			opteng.remove_item(idx)
			break
	listVersion.remove_child(sender_item)
	engineMenu.visible = false
	$MenuBox/Label.visible = true


func _on_start_engine_pressed():
	var output = []
	
	#using threading can avoid freezing while godot project manager is working
	var thread = Thread.new()
	thread.start(OS.execute.bind(sender_item.Path, sender_item.Args.split(" "), output))
	
	while thread.is_alive():
		await get_tree().process_frame
		
	thread.wait_to_finish()
	thread = null


func _on_open_folder_engine_pressed():
	var temp = sender_item.Path.split("/")
	temp.remove_at(len(temp)-1)
	OS.shell_open("/".join(temp))


func _on_engine_icon_pressed():
	$FileDialog.show()


func _on_file_dialog_file_selected(path):
	if FileAccess.file_exists(path):
		var tex = ImageLoader.load(path)
		engineIcon.icon = tex
		sender_item.Icon = tex
		for i in listVersion.get_children():
			
			if i == sender_item:
				i.Icon = sender_item.Icon
				return
	

#			／＞　 フ
#		   | 　_　_| 
#		  ／` ミ＿xノ 
#		 /　　　　 |
#		/　 ヽ　　 ﾉ
#		│　　|　|　|
#	／￣|　　 |　|　|
#	( (￣ヽ＿_ヽ_)__)
#	 ＼二)
func _on_cat_toggled(_button_pressed):
	$"cat???".visible = not $"cat???".visible


func _on_about_pressed():
	aboutpopup.show()


func _on_settingsengine_pressed():
	settingsenginepopup.show()

#SettingsForEngineDialog
func _on_save_pressed():
	sender_item.Path = settingsenginepopup.get_node("MarginContainer/VBoxContainer/PathContainer/Path").text
	sender_item.Args = settingsenginepopup.get_node("MarginContainer/VBoxContainer/ArgsContainer/Args").text
	settingsenginepopup.hide()


func _on_link_customengine_pressed():
	addenginepopup.hide()
	addcustomenginepopup.show()


func load_custom_build(version, type, path, custom_name="Godot engine custom", custom_icon=ImageLoader.load("res://resources/logo_engines/default.png"), monosupport=false):

	var ver_item = load("res://scenes/versionitem.tscn").instantiate() #versionitem for version list
	var mono = ""
	var count = 0
	
	if custom_name == "":
		custom_name = "Godot engine custom"
		
	for item in listVersion.get_children():
		
		if custom_name in item.Name: #if name of engine has same name of other engine
			count += 1
			continue
	
	if count > 0:
		custom_name += "(%s)" % count
	
	if monosupport:
		mono = "_mono"
	
	ver_item.Name = custom_name
	ver_item.Icon = custom_icon
	ver_item.Path = path
	ver_item.Version = version + type + mono + ".custom_build"
	
	ver_item.button_pressed.connect(self._on_item_selected)
	ver_item.double_click.connect(self._on_veritem_start)
	opteng.add_item("%s (%s)" % [ver_item.Name, ver_item.Version])
	listVersion.add_child(ver_item)


func _on_veritem_start():
	_on_start_engine_pressed()


func _on_add_project_pressed():
	addprojectpopup.show()


func add_project(name, icon, selected_engine, path):
	var proj_item = load("res://scenes/projectitem.tscn").instantiate()
	
	proj_item.Name = name
	proj_item.Icon = icon
	proj_item.Path = path
	proj_item.EngineName = opteng.get_item_text(selected_engine)
	proj_item.double_click.connect(self._on_projitem_start)
	proj_item.on_open_button.connect(self._on_projitem_open_button)
	proj_item.on_settings_button.connect(self._on_projitem_settings_button)
	proj_item.on_remove_button.connect(self._on_projitem_remove_button)
	listProject.add_child(proj_item)


func _on_projitem_start(sender):
	var output = []
	var args = []
	
	#using threading can avoid freezing while godot project manager is working
	var thread = Thread.new()
	var engitem = get_engine(sender.EngineName) 
	
	args.append(sender.Path)
	args.append_array(engitem.Args.split(" "))
	
	thread.start(OS.execute.bind(engitem.Path, args, output))
	
	while thread.is_alive():
		await get_tree().process_frame
		
	thread.wait_to_finish()
	thread = null


func get_engine(text):
	var idx = -90
	var engpath = ""
	
	for i in opteng.item_count:
		if text in opteng.get_item_text(i):
			idx = i
	
	if idx == -90:
		return ERR_DOES_NOT_EXIST
		
	for item in listVersion.get_children():
		if "%s (%s)" % [item.Name, item.Version] in opteng.get_item_text(idx):
			return item


func _on_projitem_open_button(sender):
	_on_projitem_start(sender)


func _on_projitem_settings_button(sender):
	pass


func _on_projitem_remove_button(sender):
	listProject.remove_child(sender)


func _on_search_project_text_changed(new_text: String):
	for item in listProject.get_children():
		item.visible = item.Name.to_lower().begins_with(new_text) and not new_text.length() == -1
		
