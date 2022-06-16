def backup_connectivity_git(request):

	from datetime import datetime
	import os
	from google.cloud import secretmanager
	from pathlib import Path


	# Create the Secret Manager client.
	client = secretmanager.SecretManagerServiceClient()


	# Access the secret version.
	version_name = "/etc/secret_is_here"  #  "projects/286910582913/secrets/PAT_token/versions/1"
	response = client.access_secret_version(request={"name": version_name})
	PAT_token = response.payload.data.decode("UTF-8")



	# clone current repo. Note command begins with a space: this prevents linux from logging the line so the PAT token isn't compromised
	os.system(f' git clone https://adam-jb:{PAT_token}@github.com/department-for-transport/connectivity.git')



	# move files to cloud storage
	date_info = datetime.now().strftime('%y-%m-%d-%H')
	pathway = f'gs://git_repo_backups/{date_info}'
	print(f'pathway: {pathway}')
	os.system(f'gsutil mv connectivity {pathway}')



	# delete connectivity folder
	def rmdir(directory):
	    directory = Path(directory)
	    for item in directory.iterdir():
	        if item.is_dir():
	            rmdir(item)
	        else:
	            item.unlink()
	    directory.rmdir()

	rmdir(Path("connectivity/"))

	return 0