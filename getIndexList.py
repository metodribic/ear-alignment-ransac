# rename original images into index images
# 001/03.png - 001.png
# 001/04.png - 002.png
# ...

import os  


# index
index = 1;
f = open('mapping_file.txt', 'w')

for i in range(1,101):
	# add leading zeros and construct name of folder
	j = str(i).zfill(3)
	name = './results_left/'+j

	# read all images inside one directory
	for file in os.listdir(name):
		#  skip .DS_Store file
		if file == '.DS_Store':
			continue;
		# construct file path
		path = j+'/'+file+' - '+str(index).zfill(3)+'.png'
		#  write it to file
		f.write(path+'\n')
		# constrct path and name of new image
		newName = 'index_right/'+str(index).zfill(3)+'.png'
		filePath = name + '/'+file
		# rename file
		os.rename(filePath, newName)
		index += 1;

f.close()