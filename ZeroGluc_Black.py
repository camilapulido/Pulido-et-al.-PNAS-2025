from ij import IJ, ImagePlus
from ij import WindowManager as WM 
from ij.plugin.frame import RoiManager
from ij.gui import Roi, Plot
from ij.measure import Measurements, ResultsTable
from ij.io import FileSaver
import os
import time

###### Setup Val ####
xVal= 1600 ##2900 ##1250 ## x value to click in Get Avg
yVal = 229 
Waitfor = 1
###########
CRE = "CRE-TH\\"
Culture = "Dopaminergic\\"
sensor = "SynpH-plox-THPMP2"


Date = 231107
Cell = 1
CellType = ""

Calibration = 1   ### 1 == Single APs
##step = 0	## 0 = Glucose; 1= 0Glucose; 2 = 0GlucOligo

NoGlucose = 3
NoZeroGlucose = 26
NoZeroGlucOlig = 0

#############################################
##### NAMES ################################

####################
########################

FolderOUT = "C:\\Users\\cmp2010\\Dropbox\\LABORATORY\\ANALYSIS\\"+Culture+CRE+"ZeroGlucose\\"+sensor+"\\2023\\"+str(Date)+"_C"+str(Cell)+"\\"
FolderIN = "C:\\Users\\cmp2010\\Dropbox\\LABORATORY\\DATA\\"+Culture+CRE+"ZeroGlucose\\"+sensor+"\\2023\\"+str(Date)+"\\C"+str(Cell)+"\\"


if not os.path.exists(FolderOUT):
    os.makedirs(FolderOUT)

if Calibration == 0:
	NameIN = "C"+str(Cell)+CellType+"_NH4Cl"
	NameOUT = str(Date)+"_"+NameIN+"_Black"
					
	path = FolderIN+NameIN+".fits"
	imp = IJ.openImage(path)
	imp.show()

	time.sleep(Waitfor)
	
	IJ.run("IJ Robot", "order=Left_Click x_point="+str(xVal)+" y_point="+str(yVal)+" delay=50 keypress=[]")  ## GET AVG

	time.sleep(Waitfor)

 	IJ.renameResults("Time Trace(s)", "Results") 
	Results2 = ResultsTable.getResultsTable()
	AVG = Results2.getColumn(Results2.getColumnIndex("Average"))
	Results = ResultsTable() 

	for i in range(len(AVG)): 
       	 Results.incrementCounter() 
         Results.addValue('Mean', AVG[i])

	Results.show('Mean')
	path= FolderOUT+NameOUT+".txt"
	Results.saveAs(path)
	imp.close()
	
if Calibration == 1:
	for cycle in range(0,3):
		if cycle ==0:
			Type = "5G"
			Total = NoGlucose
		if cycle == 1:
			Type = "0G"
			Total = NoZeroGlucose
		if cycle == 2:
			Type = "GPI0G"
			Total = NoZeroGlucOlig
			
		Name = "C"+str(Cell)+CellType+"_"+Type+"_50AP"
	
 		for APs in range(0,Total):
 			if APs == 0:
 				NameIN = Name
 				NameOUT = str(Date)+"_"+Name+"_0_Black"
 			if APs!= 0:
 				NameIN = Name+"_"+str(APs)
				NameOUT = str(Date)+"_"+Name+"_"+str(APs)+"_Black"
			
 			path = FolderIN+NameIN+".fits"
			imp = IJ.openImage(path)
			imp.show()

			time.sleep(Waitfor)
			
			IJ.run("IJ Robot", "order=Left_Click x_point="+str(xVal)+" y_point="+str(yVal)+" delay=50 keypress=[]") ## GET AVG

			time.sleep(Waitfor)
		
			IJ.renameResults("Time Trace(s)", "Results") 
			Results2 = ResultsTable.getResultsTable()
			AVG = Results2.getColumn(Results2.getColumnIndex("Average"))
			Results = ResultsTable() 
		
			for i in range(len(AVG)): 
   				Results.incrementCounter() 
   	 			Results.addValue('Mean', AVG[i])

			Results.show('Mean')
			path= FolderOUT+NameOUT+".txt"
			Results.saveAs(path)
			imp.close()
			
