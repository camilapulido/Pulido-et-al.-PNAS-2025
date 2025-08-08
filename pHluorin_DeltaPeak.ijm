BLStart = 1
BLfin = 19									
PeakStart = 35								
PeakEnd= PeakStart+10

	rename("Original.fits");
	run("Z Project...", "start="+toString(BLStart)+" stop="+toString(BLfin)+" projection=[Average Intensity]");
	rename("BL.fits");
	selectWindow("Original.fits");

	run("Z Project...", "start="+toString(PeakStart)+" stop="+toString(PeakEnd)+" projection=[Average Intensity]");
	rename("Peak.fits");

	imageCalculator("Subtract create", "Peak.fits","BL.fits");
	selectWindow("Result of Peak.fits");
	

	selectWindow("BL.fits");
	close();
	selectWindow("Peak.fits");
	close();
