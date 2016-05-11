# rename original images into index images
# 001/03.png - 001.png

import os  

# open list file

count = 0;
index_all = 0;

for i in range(1,101):
	index = 0
	# add leading zeros and construct name of folder
	j = str(i).zfill(3)
	name = './results_left/'+j

	# read all images inside one directory
	for file in os.listdir(name):
		index += 1;
	if index >= 4:
		count += 1;
		print(name)
		index_all += index

print(index_all)
print(count)

