# NOTE: This research is strongly based on [AWE dataset](http://awe.fri.uni-lj.si/)
## Description
This is case study for bachelor degree on Faculty of Computer and Information Science

The goal of this research/case study was to prove that RANSAC as a state of art method could align images which represents different object (different shape, same class - outer ear). For feature extraction was used algorithm [SIFT](http://www.vlfeat.org/overview/sift.html). As a reference ear (ear to which all ears was aligned) we summarize all perfectly aligned ears in [AWE dataset](http://awe.fri.uni-lj.si/) (every ear in AWE dataset is annotated - therefore we knew which ear is perfectly aligned). 

![Reference/Average ear image](https://github.com/metodribic/ear-alignment-ransac/blob/master/Average_ear/reference-ear.png "Reference/Average ear image")
This image shows reference/average ear, cropped image to remove black areas on sides (result of padding images with black so all were the same sizes), and applied binary mask which were annotated by hand.

We rejected images which could not be aligned (RANSAC failed to connect more than 40% of all extracted points). Evaluation was made with [AWE toolbox](http://awe.fri.uni-lj.si/). Partial results was published [here](https://www.researchgate.net/publication/308618674_Influence_of_Alignment_on_Ear_Recognition_Case_Study_on_AWE_Dataset), for full results head to [bachelor thesis](http://eprints.fri.uni-lj.si/3674/1/63110173-METOD_RIBI%C4%8C-Vpliv_poravnave_na_uspe%C5%A1nost_razpoznavanja_uhljev-1.pdf) (Slovene)

## Requirements
- Matlab (tested on R2015b)
- Matlab Image Processing Toolbox
- [vlfeat](http://www.vlfeat.org/) (tested on 0.9.20)


## How to run
RANSAC:
- start the process of alignment with RANSAC/STARTHERE.m
- it then calls createDatabase.m with side input:
```matlab
% left or right ears
side == 'l' || 'r'
```
- inside createDatabase.m is called earAlignement.m where feature are extracted and RANSAC tries to connect them

NOTE: All ears were aligned using perfect ear which was result of summarizing all pixels of perfectly aligned images from AWE dataset. Image and matrix of average ear is in [Average_ear](https://github.com/metodribic/ear-alignment-ransac/tree/master/Average_ear) dir, but you should use your own reference image.

## References

1. K. Chang, K. W. Bowyer, S. Sarkar, and B. Vic-tor, “Comparison and combination of ear and face images in appearance-based biometrics,” Pattern Analysis and Machine Intelligence, IEEE Transactions on, vol. 25, no. 9, pp. 1160–1165, 2003.

2. M. A. Fischler and R. C. Bolles, “Random sample consensus: a paradigm for model ﬁtting with applications to image analysis and automated cartography,” Communications of the ACM , vol. 24, no. 6,pp. 381–395, 1981.

3. A. Pﬂug and C. Busch, “Ear biometrics: a survey of detection, feature extraction and recognition methods,” Biometrics, IET, vol. 1, no. 2, pp. 114–129,June 2012

4. A. P. Yazdanpanah and K. Faez, Emerging Intelligent Computing Technology and Applications: 5th International Conference on Intelligent Computing, ICIC 2009, Ulsan, South Korea,September 16-19, 2009. Proceedings. Berlin, Heidelberg: Springer Berlin Heidelberg, 2009,ch. Normalizing Human Ear in Proportion to Size and Rotation, pp. 37–45. [Online](http://dx.doi.org/10.1007/978-3-642-04070-2_5)

5. E. Gonzalez, L. Alvarez, and L. Mazorra, “Normalization and feature extraction on ear images,” in Security Technology (ICCST), 2012 IEEE International Carnahan Conference on, Oct 2012, pp. 97–104.

6. W.Shu-zhong, “An improved normalization method for ear feature extraction,” Shandong College of In- formation Technology, Weifang, China, 2013.

7. Ž. Emeršič and P. Peer, “Toolbox for ear biometric recognition evaluation,” in EUROCON 2015- International Conference on Computer as a Tool(EUROCON), IEEE. IEEE, 2015, pp. 1–6

8. D. G. Lowe, “Distinctive image features from scale-invariant keypoints,” International journal of computer vision, vol. 60, no. 2, pp. 91–110, 2004. [Online](http://www.cs.ubc.ca/~lowe/papers/ijcv04.pdf)
