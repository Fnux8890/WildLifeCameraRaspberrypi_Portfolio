import os
import base64
from github import Github
from github import InputGitTreeElement

user = "team23team23"
password = "team23team23team23"
token = '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'

g = Github(token)
repo = g.get_repo('Fnux8890/WildLifeCameraRaspberrypi_Portfolio')

folder_path = '/home/jeppe/Desktop/WildLifeCameraRaspberrypi_Portfolio/annotations/'
commit_message = 'python commit'

# Get all files in the annotations folder
file_list = [os.path.join(folder_path, f) for f in os.listdir(folder_path) if os.path.isfile(os.path.join(folder_path, f))]

element_list = list()
for entry in file_list:
    with open(entry, 'rb') as input_file:  # Use 'rb' to read binary files
        data = input_file.read().decode('utf-8')  # Decode bytes to string
    if entry.endswith('.png'):  # images must be encoded
        data = base64.b64encode(data.encode('utf-8')).decode('utf-8')  # Encode string to bytes and then to base64
    file_name = os.path.basename(entry)
    # Specify the full path to the annotations folder in the repository
    # Change '289c03cbbd26e5dc29cf713132587df8c71aa6a9' to the actual commit SHA
    element = InputGitTreeElement("annotations/" + file_name, '100644', 'blob', data)
    element_list.append(element)

# Assuming the default branch is main
master_ref = repo.get_git_ref('heads/main')
master_sha = master_ref.object.sha
base_tree = repo.get_git_tree(master_sha)

tree = repo.create_git_tree(element_list, base_tree)
parent = repo.get_git_commit(master_sha)
commit = repo.create_git_commit(commit_message, tree, [parent])
master_ref.edit(commit.sha)
