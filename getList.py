import os  

# open list file
f = open('mapping_file.txt', 'w')

# index
index = 1;

for i in range(1,101):
	# add leading zeros and construct name of folder
	j = str(i).zfill(3)
	name = './results/'+j

	# read all images inside one directory
	for file in os.listdir(name):
		# print(j+'/'+file+' > '+index)
		print(j+'/'+file)

