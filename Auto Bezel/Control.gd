extends Control

@export var config_dir = "test/"

func _ready():
	$Button_Processed.text = config_dir

# Function to extract paths and names from XML
func extract_paths_and_names(xml_file: String) -> Array:
	var games = []
	var xml = XMLParser.new()
	var error = xml.open(xml_file)
	
	if error != OK:
		print("Failed to open XML file: %s" % xml_file)
		return games

	while xml.read() == OK:
		if xml.get_node_type() == XMLParser.NODE_ELEMENT and xml.get_node_name() == "game":
			var path = ""
			#var name = ""
			while xml.read() == OK:
				if xml.get_node_type() == XMLParser.NODE_ELEMENT and xml.get_node_name() == "path":
					xml.read()
					path = xml.get_node_data().strip_edges()
				elif xml.get_node_type() == XMLParser.NODE_ELEMENT and xml.get_node_name() == "name":
					xml.read()
					name = xml.get_node_data().strip_edges()
				elif xml.get_node_type() == XMLParser.NODE_ELEMENT and xml.get_node_name() == "game":
					break

			if path != "" and name != "":
				games.append([path, name])
	return games

# Function to save extracted data to CSV and check/create files
func save_to_csv_and_check_files(games: Array, csv_file: String, base_path: String):
	var file = FileAccess.open(csv_file, FileAccess.WRITE)
	if file == null:
		print("Failed to open CSV file: %s" % csv_file)
		return
	file.store_line("Path,Name,name_cfg,name_png,BezelPath")  # Write the header

	var overlay_path_prefix = "../retroarch/overlays/arcade/"
	var sline = ""
	
	for game in games:
		var path = game[0]
		#var name = game[1]
		
		# Strip the left two characters and the right four characters, then add .cfg
		var name_cfg = path.substr(2, path.length() - 6) + ".cfg"
		var name_png = path.substr(2, path.length() - 6) + ".png"
		var bezel_path = base_path + name_cfg
		sline =("%s,%s,%s,%s,%s" % [path, name, name_cfg, name_png, bezel_path])
		file.store_line(sline)
	
		# Check if the file exists, if not create it
		var file_path = config_dir + name_cfg
		if not FileAccess.file_exists(file_path):
			var cfg_file = FileAccess.open(file_path, FileAccess.WRITE)
			if cfg_file != null:
				cfg_file.store_line('input_overlay = "%s%s"' % [overlay_path_prefix, name_cfg])
				cfg_file.close()
	#			print("Created file: %s" % file_path)
	#		else:
	#			print("Failed to create file: %s" % file_path)
	#	else:
	#		print("File already exists: %s" % file_path)
	
	file.close()
	$Button_Csv.text = csv_file
	$Label_Current.text += str(games.size()) + " files processed"
#	print("Data saved to %s" % csv_file)
#	print ("%i files processed" % games.size())

func _on_button_process_pressed():
	var args = OS.get_cmdline_args()
	var xml_file = "gamelist.xml"
	var csv_file = "csv/games.csv"
	var base_path = "/base/path/"

	for i in range(args.size()):
		if args[i] == "--xml_file" and i + 1 < args.size():
			xml_file = args[i + 1]
		elif args[i] == "--csv_file" and i + 1 < args.size():
			csv_file = args[i + 1]
		elif args[i] == "--base_path" and i + 1 < args.size():
			base_path = args[i + 1]

	var games = extract_paths_and_names(xml_file)
	save_to_csv_and_check_files(games, csv_file, base_path)	

func _on_button_load_pressed():
	$FileDialog_Load.visible = true

func _on_file_dialog_load_file_selected(path):
		$LineEdit_Path.text = path

func _on_button_csv_pressed():
	OS.shell_open($Button_Csv.text)


func _on_button_processed_pressed():
	OS.shell_open(config_dir)
