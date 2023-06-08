##############
# Half-Assed Combine Files [Combine]
##############

#-------------------------
# Imports
#-------------------------
import json
import time
import os

#-------------------------
# Variables
#-------------------------
before = "../"
file =  "workspace_config.json"

#-------------------------
# Functions
#-------------------------
def get(key):
    content = None

    with open(file, "r") as f:
        content = json.loads(f.read())
        
    return content[key]

def combine_files(folders, main, dump, files):
    content_from_files = []
    
    for i in files:
        with open(f"{before}{i}", "r") as f:
            content_from_files.append(f"-----------------\n-- [Library] {i}\n-----------------\n{f.read()}")
    
    for i in folders:
        for file in os.listdir(before + i):
            with open(f"{before}{i}/{file}", "r") as f:
                content_from_files.append(f"-----------------\n-- [Library | Folder: {i}] {file}\n-----------------\n{f.read()}")
            
    with open(before + main, "r") as f:
        content_from_files.append (f"-----------------\n-- [Main File] {main}\n-----------------\n" + f.read())
        
    with open(before + dump, "w") as f:
        f.write("\n\n".join(content_from_files))

#-------------------------
# Main
#-------------------------
while True:
    time.sleep(0.2)
    
    print("----- Combining files...")
    
    try:
        folders = get("folders")
        main = get("main")
        dump = get("dump")
        files = get("files")

        combine_files(folders, main, dump, files)
    
        concatenatedFolders = " and ".join(folders)
        concatenatedFiles = " and ".join(files)
        print(f"     \_____Successfully combined {concatenatedFiles} and all files in {concatenatedFolders} with {main}.")
    except Exception as e:
        print(f"     \_____Failed to combine files.\n          \_____Error: {str(e)}")