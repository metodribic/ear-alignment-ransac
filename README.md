## DIPLOMA

# Delovni naslov: Vpliv poravnave na uspešnost razpoznavanja uhljev

**Cilj:** 
	- pridobiti bazo poravnanih slik, ki bi jo potem objavili, skupaj z razširjenim toolboxom / objava

**Opis:**
	Prilagodil nekaj obstoječih postopkov poravnavanja slik in nato preveril kako različni načini poravnave vplivajo uspešnost razpoznavanja z metodami iz našega toolboxa. 

**Metode:**
	- detekcija SIFT značilk v obeh uhljih posebej + RANSAC na ujemajočih točkah, da dosežemo poravnavo (koda za tole se lahko adaptira iz: [LINK](http://luks.fe.uni-lj.si/sl/studij/GST/vaje/vaja5b.html)) tukaj bi bilo potrebno izbrati nek referenčni uhelj, na katerega bi vse ostale poravnavali
	- funneling (oz. congealing), kjer izvajamo batch alignment preko minimizacije neke kriterijske funkcije; postopek je opisan tukaj: [LINK](http://vis-www.cs.umass.edu/code/congealingcomplex/); na voljo je tudi izvorna koda)
	- cascaded pose regression (CPR) kot ga je predlagala Anika Pflug; njen postopek je opisan v doktoratu:[LINK](http://brage.bibsys.no/xmlui/bitstream/id/338233/APflug_dissertation_digital.pdf); osnovna koda za splošni CPR, ki bi jo bilo potrebno malo popraviti je na voljo tukaj: [LINK](http://vision.ucsd.edu/~pdollar/research.html)


*Tema kot taka je nezahtevna in zahteva modifikacijo obstoječe kode in klicanje že narejenih zadev. Dodana vrednost je v dobri implementaciji in integraciji v toolbox, poravnani bazi in objavi. Dobro narejena (kar je tudi cilj) je zagotovo kandidat za najboljšo oceno.*
