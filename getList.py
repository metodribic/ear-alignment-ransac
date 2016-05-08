import os  
for i in range(1,101):
	j = str(i).zfill(3)
	name = './results_left/'+j
	for a in os.listdir(name):
		print(j+'/'+a)
