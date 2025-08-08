from ij.measure import ResultsTable
from ij import IJ
from ij import WindowManager as WM
from ij.plugin.frame import RoiManager
import os
import time

xVal= 1650 ## x value to click in Get Avg
yVal = 229 ## y value to click in Get Avg

Waitfor = 1
######################################################################
##### Input Variables ###############

CellLine = "WT\\"
Culture = "Dopaminergic\\"
sensor = "SynphypH_THP"

Date = 250120
Cell = 1
CellType = ""
Calibration = 1   ## 0 = NH4Cl; 1 = 5-Gluc & 0-Gluc; 2 = Save Rois

step = 0 ## 0 = 5-Gluc ; 1 = 0-Gluc

SolList = ["5G","0G"] ## All tyrode's 
SolNo = [2,14] ## No. of repetions per Solution
######################################################################

FolderOUT = "D:\\...\\ANALYSIS\\"+Culture+CellLine+"ZeroGlucose\\"+sensor+"\\2025\\"+str(Date)+"_C"+str(Cell)+"\\"
FolderIN = "D:\\...\\DATA\\"+Culture+CRE+"ZeroGlucose\\"+sensor+"\\2025\\"+str(Date)+"\\C"+str(Cell)+"\\"


if not os.path.exists(FolderOUT):
    os.makedirs(FolderOUT)

######################################################################   
##### NH4Cl data extraction #########################

if Calibration == 0:
	NameOut = str(Date)+"_C"+str(Cell)+CellType+"_NH4Cl"
	
	IJ.renameResults("Time Trace(s)", "Results")
	pathOut1 = FolderOUT+NameOut+"_Btns.xls"
	IJ.saveAs("Results", pathOut1)
	
	Results2 = ResultsTable.getResultsTable()
	AVG = Results2.getColumn(Results2.getColumnIndex("Average"))
	Results = ResultsTable() 
		
	for i in range(len(AVG)): 
       	 Results.incrementCounter() 
         Results.addValue('Mean', AVG[i])

	Results.show('Mean')
	path= FolderOUT+NameOut+".txt"
	Results.saveAs(path)


################################
####### SINGLE train of 50APs ##################

if Calibration == 1:
	Type = SolList[step]
	Total = SolNo[step]
	
	Name = "C"+str(Cell)+CellType+"_"+Type+"_50AP"
		
	Center = 3 ## which stack file to start ROIs re-centering
		
 	for APs in range(0,Total):
 		if APs == 0:
 			NameIN = Name
 			NameOUT = str(Date)+"_"+Name+"_0"
 				
 		if APs!= 0:
 			NameIN = Name+"_"+str(APs)
			NameOUT = str(Date)+"_"+Name+"_"+str(APs) 
				
 		path = FolderIN+NameIN+".fits"
 		impOriginal = IJ.openImage(path)
		impOriginal.show()
		impOriginal = IJ.getImage()
			
		time.sleep(Waitfor)

		if APs == Center:
			IJ.runMacroFile("D:\\...\\pHluorin_DeltaPeak.ijm")	## Path where to call the 'pHluorin_DeltaPeak' macro
							
			time.sleep(Waitfor)
					
			imp = IJ.selectWindow("Result of Peak.fits")	
			imp = IJ.getImage()
				
			time.sleep(Waitfor)
					
			IJ.run("IJ Robot", "order=Left_Click x_point="+str(xVal)+" y_point=190 delay=185 keypress=[]") ## RECENTER
		
			time.sleep(Waitfor)
					
			imp = IJ.selectWindow("Result of Peak.fits")
			imp = IJ.getImage()
			imp.close()
			
			impOriginal = IJ.selectWindow("Original.fits")
			impOriginal = IJ.getImage()
		
			time.sleep(Waitfor)
		
		IJ.run("IJ Robot", "order=Left_Click x_point="+str(xVal)+" y_point="+str(yVal)+" delay=100 keypress=[]") ## GET AVG

		time.sleep(Waitfor)
		
		IJ.renameResults("Time Trace(s)", "Results")
		pathOut1 = FolderOUT+NameOUT+"_Btns.xls"
		IJ.saveAs("Results", pathOut1)
				
		Results2 = ResultsTable.getResultsTable()
		AVG = Results2.getColumn(Results2.getColumnIndex("Average"))
		Results = ResultsTable() 
		
		for i in range(len(AVG)): 
   			Results.incrementCounter() 
   	 		Results.addValue('Mean', AVG[i])

		Results.show('Mean')
		pathOut= FolderOUT+NameOUT+".txt"
		Results.saveAs(pathOut)
			
		if APs == Center:
			impOriginal = IJ.selectWindow("Original.fits")
			Center+= 7 ## How many Stack files to re-centering ROIs?
		else:
			impOriginal = IJ.selectWindow(NameIN+".fits")
				
		impOriginal = IJ.getImage()			
		impOriginal.close()
IJ.run("Close All", "");


#### Save ROIs #######
rm = RoiManager.getInstance()
ROISPath = FolderIN
if Calibration == 2:
	rm.runCommand("deselect") 
	rm.runCommand("save", os.path.join(ROISPath, "ROIs.zip")) 
	rm.runCommand("Delete")
