# EEG-SVM-Decoding_Spatial-Normalization
This code serves as a basic toolbox for performing spatial normalization in the SVM-based MVPA decoding on EEG datasets. The code supports within-subject and between-subject (leave-one-subject-out validation) decoding strategies. After decoding, users can visualize the results and perform statistical comparisons using the provided figure generation scripts.

![EEG-SVM Decoding Spatial Normalization Figure 0](https://github.com/Yuan-gogogo/EEG-SVM-Decoding_Spatial-Normalization/blob/d7fded925c3cc70d86c2f669bd2e9822eca85c65/Codes_EEG_Decoding_SpatialNormalization/figure_add.jpg)
![EEG-SVM Decoding Spatial Normalization Figure 0](https://github.com/Yuan-gogogo/EEG-SVM-Decoding_Spatial-Normalization/blob/af628c92d1101ca121ab9348fe18b0c61db396cf/Codes_EEG_Decoding_SpatialNormalization/figure0.jpg
)



Main Steps and Usage Notes:

First: Environment Setup
1. Add EEGLAB to your MATLAB path. If you're using a recent version (as of April 2025), ERPLAB is already integrated into EEGLAB.
2. Add the folder 'Z0_AddToPath_ToolForDecoding' to your MATLAB path. This folder contains modifications to ERPLAB that support spatial normalization.
3. Place your preprocessed EEG '.set' files into the '0_RawData' folder.

Second: BDF Configuration (Important)
1. Prepare a BDF (Bin Descriptor File) and name it using the format: 'BDF_NameComponent.txt'.
   This project uses the 'orientation' experiment as an example and includes a suitable BDF file.
   Original BDF files for ERPCORE, Face, and Orientation experiments can be downloaded from:
   - https://doi.org/10.18115/D5JW4R
   - https://osf.io/tgzew/

   For other datasets, configure the BDF using the ERPLAB tutorial:
   https://github.com/ucdavis/erplab/wiki/Studio-Tutorial:-Assigning-Events-to-Bins

2. Run the script 'A1_CreateDocList_eng.mat'.
   In the "Define" section, fill in experimental parameters as needed.
   This script serves as the master configuration and defines key variables used throughout the experiment.
   Using the 'orientation' dataset as an example, several fields are pre-filled for your reference.
   Ensure that the "Import Bin" name matches the corresponding BDF file name.

Third: Decoding, Statistics, and Plotting
1. Inside the 'B1_Processing' folder, run scripts sequentially from A1 to A6.
   The resulting figures will be saved in:
   - A1_WithinSub_Figure (within-subject decoding results)
   - A2_BetweenSub_Figure (between-subject decoding results)
   - A3_CrossBetweenWithin_Figure (cross-condition results)

2. The source code for each step is located in the 'B1_Processing' folder.
   You can modify it as needed based on your dataset or experimental design.

Folder Structure:
- 0_RawData/ — Store your preprocessed '.set' EEG files here.
- Z0_AddToPath_ToolForDecoding/ — Toolbox extensions and normalization modifications.
- B1_Processing/ — Main decoding pipeline scripts (A1–A6).
- A1_WithinSub_Figure/ — Within-subject decoding results.
- A2_BetweenSub_Figure/ — Between-subject decoding results.
- A3_CrossBetweenWithin_Figure/ — Cross-validation results.

Tips:
- Define key parameters like 'timewin', 'BinN', etc. in A1_CreateDocList_eng.mat.
- Add warnings in code comments for common misconfigurations.







Acknowledgment:

This work was supported by the National Natural Science Foundation of China (Grant No. 91748105), the National Foundation in China (No. JCKY2019110B009 and 2020-JCJQ-JJ-252), the National Social Science Fund of China (No. BGA210056), the scholarship from the China Scholarship Council (No.201906060242), the Fundamental Research Funds for the Central Universities (DUT20LAB303 and DUT20LAB308) in the Dalian University of Technology in China, and the Science and Technology Planning Project of Liaoning Province (No. 2021JH1/10400049).






MIT License:

Copyright (c) 2025 Yuan Qin, Dalian University of Technology, China and University of Jyväskylä, Finland.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
