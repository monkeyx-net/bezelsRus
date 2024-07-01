
import os
import xml.etree.ElementTree as ET
import csv
import argparse

def extract_paths_and_names(xml_file):
    tree = ET.parse(xml_file)
    root = tree.getroot()
    
    games = []
    
    for game in root.findall('game'):
        path = game.find('path').text
        name = game.find('name').text
        games.append((path, name))
        
    return games

def save_to_csv_and_check_files(games, csv_file, base_path):
    with open(csv_file, mode='w', newline='', encoding='utf-8') as file:
        writer = csv.writer(file)
        writer.writerow(['Path', 'Name', 'name_cfg', 'name_png', 'BezelPath'])  # Write the header
        
        #config_dir = '../retroarch/config/FinalBurn Neo/'
        config_dir = 'test/'
        overlay_path_prefix = 'retroarch/overlays/arcade/'
        
        for path, name in games:
            # Strip the left two characters and the right four characters, then add .cfg
            name_cfg = path[2:-4] + '.cfg'
            name_png = path[2:-4] + '.png'
            bezel_path = base_path + name_cfg
            writer.writerow([path, name, name_cfg, name_png, bezel_path])
            
            # Check if the file exists, if not create it
            file_path = os.path.join(config_dir, name_cfg)
            if not os.path.exists(file_path):
                with open(file_path, 'w') as cfg_file:
                    cfg_file.write(f'input_overlay = "{overlay_path_prefix}{name_cfg}"\n')
                print(f'Created file: {file_path}')
            else:
                print(f'File already exists: {file_path}')

def main():
    parser = argparse.ArgumentParser(description='Extract game paths and names from XML and save to CSV.')
    parser.add_argument('--xml_file', default='gamelist.xml', help='Path to the input XML file (default: gamelist.xml)')
    parser.add_argument('--csv_file', default='games.csv', help='Path to the output CSV file (default: games.csv)')
    parser.add_argument('--base_path', default='/base/path/', help='Base path for the BezelPath column (default: /base/path/)')
    
    args = parser.parse_args()
    
    games = extract_paths_and_names(args.xml_file)
    save_to_csv_and_check_files(games, args.csv_file, args.base_path)
    
    print(f"Data saved to {args.csv_file}")

if __name__ == "__main__":
    main()
