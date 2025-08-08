from ij import IJ, ImagePlus
from ij.plugin.filter import PlugInFilterRunner
import os
import glob

#import sys
#sys.path.append("C:\\Users\\cmp2010\\Dropbox\\LABORATORY\\ImageJ\\")  # the folder containing Hello_.py
#from Slice_Keeper import Hello
#################
###################################################################
Sensor = "SynATPSnFR2-IRFP"

########## VARIABLES ###############"
Culture = "Dopaminergic\\WT\\ZeroGlucose\\"

Date = 250527
Cell = 2

FolderIN = "D:\\Dropbox\\LABORATORY\\DATA\\"+Culture+Sensor+"\\2025\\"+str(Date)+"\\C"+str(Cell)+"\\"
FolderOUT = FolderIN+"FormatedFiles\\"

if not os.path.exists(FolderOUT):
	os.makedirs(FolderOUT)

###################################################
fitsfiles = []
for file in glob.glob(FolderIN+"*.fits"):
	fitsfiles.append(file)
	IJ.open(file)
	stackOriginal = IJ.getImage()
	slices_nb=stackOriginal.getNSlices();
	OriginalName = stackOriginal.title

	for switch in range(0,2):
		if switch == 0:
			Type = "IRFP_"
		else:
			Type = "iATPsf_"

		stackOriginal = IJ.selectWindow(OriginalName)
		IJ.run("Duplicate...", "title="+Type+OriginalName+" duplicate")
		
		imp = IJ.getImage()
		
		FinalName = Type+OriginalName
		Arguments = str(switch+1)
		
		#IJ.runMacroFile("C:\\Users\\cmp2010\\Dropbox\\LABORATORY\\ImageJ\\Slice_Keeper.ijm", "1")
		imp = IJ.run("Slice Keeper", "first="+Arguments+" last="+str(slices_nb)+" increment=2");
		stack = IJ.selectWindow(FinalName+" kept stack")
		stack = IJ.getImage()
		IJ.run("Save", "save="+FolderOUT+Type+OriginalName);


IJ.run("Close All", "");


