# Stratified sampling for dataset splitting

**MIDRC TDP 3d**, https://www.midrc.org/technology-development-projects/tdp3

**Development Team**: Natalie Baughan; Heather Whitney, PhD; Kyle Myers, PhD; Maryellen Giger, PhD

Problem Definition:
This algorithm uses multi-dimensional stratified sampling where several variables of interest (such as demographics - race, gender, imaging acquisition system) can be sequentially used to divide the data into numerous strata, each representing a unique combination of variables. Within each resulting stratum, patients are assigned to a specific dataset. This algorithm was developed and is used by MIDRC for separation of data into either the open data commons or the sequestered data commons. However, as shared here by MIDRC, it can be generalized by users for other needs for stratified sampling, e.g., dividing your own dataset into a two separate sets: one for training and one for testing.

Acknowledgment to Alec Steep, PhD, for his work in translation of the original Matlab code to Python.


**Requirements**: Matlab/ Python3


References
---
1)  N. Baughan, H. M. Whitney, K. Drukker, B. Sahiner, T. Hu, G. H. Kim, M. McNitt-Gray, K. J. Myers, M. L. Giger, “Sequestration of imaging studies in MIDRC: Stratified sampling to balance demographic characteristics of patients in a multi-institutional data commons.” Journal of Medical Imaging, Vol. 10, Issue 6, 064501 (November 2023). https://doi.org/10.1117/1.JMI.10.6.064501.

2) H. M. Whitney, N. Baughan, K. J. Myers, K. Drukker, J. Gichoya, B. Bower, R. Sa, W. Chen, N. Gruszauskas, J. Kalpathy-Cramer, S. Koyejo, B. Sahiner, J. Zhang, and M. L. Giger, “Longitudinal assessment of demographic representativeness in the Medical Imaging and Data Resource Center Open Data Commons.” Journal of Medical Imaging, Vol. 10, Issue 6, 061105 (July 2023). https://doi.org/10.1117/1.JMI.10.6.061105.

3) N. Baughan, H. M. Whitney, K. Drukker, B. Sahiner, T. Hu, G. H. Kim, M. McNitt-Gray, K. J. Myers, M. L. Giger, “Sequestration methodology in practice through evaluation of joint demographic distributions of 54,185 patients in the Medical Imaging and Data Resource Center (MIDRC) data commons,” Proceedings Volume 12469, Medical Imaging 2023: Imaging Informatics for Healthcare, Research, and Applications; 1246909 (2023) https://doi.org/10.1117/12.2654247.

