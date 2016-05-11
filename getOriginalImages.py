# get original images from aligend ones
# if i have aligned image 001/03.png and 002/09.png
# I need original images of these images so i can test on original images
#  and then compare results

import os  
import shutil



# index
index = 1;
# new dir destination
destination_path = 'original_database_right'
source_path = 'databases/awe'

for i in range(1,101):
	# add leading zeros and construct name of folder
	j = str(i).zfill(3)
	name = './results_right/'+j

	# read all images inside one directory
	for file in os.listdir(name):
		#skip .DS_Store file
		if file == '.DS_Store':
			continue;
		# construct new path for copying orignial image
		src = source_path + '/' + str(i).zfill(3) + '/' + file
		dst = destination_path + '/' + str(i).zfill(3) + '/' + file
		shutil.copy2(src, dst)

		# path = j+'/'+file+' - '+str(index).zfill(3)+'.png'
		