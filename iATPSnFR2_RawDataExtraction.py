from ij.measure import ResultsTable
from ij import IJ, ImageStack
from ij import WindowManager as WM
import os
import time
from ij.io import FileSaver
from ij.plugin.frame import RoiManager
###################################################################
###################################################################
xVal= 1600 ## x value to click in Get Avg
yVal = 229 ## y value to click in Get Avg

Waitfor = 1  # in seconds
###################################################################
sensor = "SynATPSnFR2-IRFP"
########## VARIABLES #################

Date = 250527
Cell = 2

Drug = ""

Calibration =  2  ## 0 = glucose & 0Gluc; 2 = Save Rois
step = 1  ## 0 = Glucose; 1= Test Solution

SolList = ["5G","G0"]
SolNo =[1,1] 
##########################

SensorType = ["RFP","iATPsf"]
######################################################################
window = 100   ## how many frames to AVG in the center

FolderOUT = "D:\\...\\ANALYSIS\\"+sensor+"\\2025\\"+str(Date)+"_C"+str(Cell)+"\\"
FolderIN = "D:\\...\\DATA\\"+sensor+"\\2025\\"+str(Date)+"\\C"+str(Cell)+"\\FormatedFiles\\"

if not os.path.exists(FolderOUT):
    os.makedirs(FolderOUT)
######################################################################

if Calibration == 0:
	Type = SolList[step]
	Total = SolNo [step]
	
	for Rounds in range(0,Total):	
		for CellType in SensorType:
			
			if step == 0 or step == 1:
				Name = CellType+"_C"+str(Cell)+"_"+Drug+Type+"_600AP"
			else:
				Name = CellType+"_C"+str(Cell)+"_"+Drug+Type
			
			if Rounds == 0:
				NameIN = Name
				NameOUT = str(Date)+"_"+Name+"_0"

			if Rounds!= 0:
				NameIN = Name+"_"+str(Rounds)
				NameOUT = str(Date)+"_"+Name+"_"+str(Rounds)

			path = FolderIN+NameIN+".fits"
			impOriginal = IJ.openImage(path)
			impOriginal.show()
			impOriginal = IJ.getImage()
			
			if CellType == SensorType[0]:
				HALOName = impOriginal.title
				HALOpathOUT = FolderOUT+NameOUT 
			if CellType == SensorType[1]:
				iATPName = impOriginal.title
				iATPpathOUT = FolderOUT+NameOUT 
		
		ResultsATP = ResultsTable()
		ResultsATPBtns =ResultsTable()
		ResultsHALO = ResultsTable()
		ResultsHALOBtns =ResultsTable()
		
		stop = 0
		TotalFrames = impOriginal.getDimensions()
		TotalFrames = TotalFrames[3]
		
		division = int(round(TotalFrames/window,0))+1
		
		for interation in range (0,division):
			start = stop
			if interation == division-1:
				stop = TotalFrames
			else:
				stop = start+window	
			
			####### RFP ##############
			imp = IJ.selectWindow(HALOName)  #### JUSt recenter in RFP channel
			imp = IJ.getImage()
			IJ.run(imp, "Z Project...", "start="+str(start)+" stop="+str(stop)+" projection=[Average Intensity]") ### z project to get average of the stack
			AVG= IJ.getImage()
	
			time.sleep(Waitfor)
			
			IJ.run("IJ Robot", "order=Left_Click x_point="+str(xVal)+" y_point=190 delay=185 keypress=[]") ## RECENTER
			
			time.sleep(Waitfor)
			
			AVG.close()
								
			imp = IJ.selectWindow(HALOName)
			imp = IJ.getImage()
			
			time.sleep(Waitfor)
	
			IJ.run("IJ Robot", "order=Left_Click x_point="+str(xVal)+" y_point="+str(yVal)+" delay=150 keypress=[]") ## GET AVG

			time.sleep(Waitfor)
					
			Results2 = ResultsTable.getActiveTable()
			AVG = Results2.getColumn(Results2.getColumnIndex("Average"))
			Headings = Results2.getHeadings()
			
			for frame in range(start,stop):
				ResultsHALO.incrementCounter()
				ResultsHALOBtns.incrementCounter()
				ResultsHALO.addValue('Mean', AVG[frame])
				for head in Headings:
					Column = Results2.getColumn(Results2.getColumnIndex(str(head)))
					ResultsHALOBtns.addValue(str(head), Column[frame])
					
			####### iATPsf ##############

			time.sleep(Waitfor)
					
			imp = IJ.selectWindow(iATPName)
			imp = IJ.getImage()
	
			IJ.run("IJ Robot", "order=Left_Click x_point="+str(xVal)+" y_point="+str(yVal)+" delay=150 keypress=[]") ## GET AVG

			time.sleep(Waitfor)
				
			Results2 = ResultsTable.getActiveTable()
			AVG = Results2.getColumn(Results2.getColumnIndex("Average"))
			Headings = Results2.getHeadings()
			
			for frame in range(start,stop):
				ResultsATP.incrementCounter()
				ResultsATPBtns.incrementCounter()
				ResultsATP.addValue('Mean', AVG[frame])
				for head in Headings:
					Column = Results2.getColumn(Results2.getColumnIndex(str(head)))
					ResultsATPBtns.addValue(str(head), Column[frame])
		
		ResultsATP.saveAs(iATPpathOUT+".txt")
		ResultsATPBtns.saveAs(iATPpathOUT+"_Btns.txt")
		
		ResultsHALO.saveAs(HALOpathOUT+".txt")
		ResultsHALOBtns.saveAs(HALOpathOUT+"_Btns.txt")
		
				
		IJ.run("Close All", "");

		
###############################################################				
###############################################################						
###############################################################
rm = RoiManager.getInstance()
ROISPath = FolderIN
if Calibration == 2:
	rm.runCommand("deselect")
	rm.runCommand("save", os.path.join(ROISPath, "ROIs.zip"))
	rm.runCommand("Delete")
