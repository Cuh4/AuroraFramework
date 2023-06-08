##############
# Half-Assed Combine Files [Setup]
##############

#-------------------------
# Imports
#-------------------------
import json
import time

#-------------------------
# Variables
#-------------------------
file = "workspace_config.json"

#-------------------------
# Functions
#-------------------------
def timed_exit(duration):
    print("[!] Exiting in " + str(duration) + " seconds.")
    time.sleep(duration)
    exit(100)
    
def edit(key, new_value):
    content = None

    with open(file, "r") as f:
        content = json.loads(f.read())
        
    content[key] = new_value
    with open(file, "w") as f:
        f.write(json.dumps(content, indent=5))
        
def get(key):
    content = None

    with open(file, "r") as f:
        content = json.loads(f.read())
        
    return content[key]

#-------------------------
# Choices
#-------------------------
def set_folders():
    folders = input("[?] Input a list of folders that contain your library files.\n   Separate between commas.\n   Example: one,two,three\n")
    folders = folders.split(",")
    
    edit("folders", folders)

    print("[:)] Done.")
    timed_exit(5)
    
def set_files():
    files = input("[?] Input a list of library files that are in the same folder as this script.\n   Separate between commas.\n   Example: one.lua,two.lua,three.lua\n")
    files = files.split(",")
    
    edit("files", files)

    print("[:)] Done.")
    timed_exit(5)

def set_main():
    main = input("[?] Input the main file:\n")
    edit("main", main)

    print("[:)] Done.")
    timed_exit(5)
    
def set_dump_file():
    dump = input("[?] Input the dump file:\n")
    edit("dump", dump)

    print("[:)] Done.")
    timed_exit(5)

choices = {
    "set_folders" : set,
    "set_main" : set_main,
    "set_dump_file" : set_dump_file,
    "set_files" : set_files
}

#-------------------------
# Main
#-------------------------
# Get choice
desired = input("[?] Choose a choice.\nAvailable Choices:\n" + "\n".join(choices) + "\n")

try:
    choices[desired.lower()]()
except:
    print("[!] This choice doesn't exist.")
    timed_exit(5)