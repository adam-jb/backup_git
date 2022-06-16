def backup_connectivity_git(request):

	from datetime import datetime
	import os
	from google.cloud import secretmanager
	from pathlib import Path
	import shutil
	from google.cloud import storage


	# Create the Secret Manager client.
	client = secretmanager.SecretManagerServiceClient()
	print('secret manager initialised')


	# Access the secret version.
	version_name = "projects/286910582913/secrets/PAT_token/versions/1" #  "/etc/secret_is_here"  #  "projects/286910582913/secrets/PAT_token/versions/1"
	response = client.access_secret_version(request={"name": version_name})
	PAT_token = response.payload.data.decode("UTF-8")
	print('PAT token accessed')



	# clone current repo into whatever current director is. Note command begins with a space: this prevents linux from logging the line so the PAT token isn't compromised
	print(f'os path: {os.getcwd()}')
	print(f'os files: {os.listdir()}')
	os.chdir('/tmp')
	print(f'os path: {os.getcwd()}')
	print(f'os files: {os.listdir()}')
	os.system(f' git clone https://adam-jb:{PAT_token}@github.com/department-for-transport/connectivity.git')
	print('git clone run')
	print(f'os files: {os.listdir()}')


	def getListOfFiles(dirName):
		# create a list of file and sub directories 
		# names in the given directory 
		listOfFile = os.listdir(dirName)
		allFiles = list()
		# Iterate over all the entries
		for entry in listOfFile:
			# Create full path
			fullPath = os.path.join(dirName, entry)
			# If entry is a directory then get the list of files in this directory 
			if os.path.isdir(fullPath):
				allFiles = allFiles + getListOfFiles(fullPath)
			else:
				allFiles.append(fullPath)
					
		return allFiles

	all_files = getListOfFiles('connectivity')
	print(f'all files found: {all_files}')
		

	client = storage.Client()
	bucket = client.get_bucket('git_repo_backups')
	date_info = datetime.now().strftime('%y-%m-%d-%H')
	for blobname in all_files:
		print(f'blobname: {blobname}')
		file_gcs_pathway = date_info + '/' + blobname
		blob = bucket.blob(file_gcs_pathway)
		blob.upload_from_filename(blobname)

	return ""



	