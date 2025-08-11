#pragma rtGlobals=3		// Use modern global access method and strict wave access.
Function ChatGPT_BinningGsvsGlyc()
	Variable binning = 6

	Wave Wdata = SortbyGs_ALL_GlycVsGS
	Duplicate/O/R=[][0] Wdata, WGlyc
	Duplicate/O/R=[][1] Wdata, WGS

	WaveStats/Q WGS  	
	variable Binsize = (V_max)/binning 
	print Binsize
	variable Top = V_Max
    
	String Wname = "Wtest_B" + num2str(binning)
	Make/O/N=(binning,2)/D $Wname + "_AVG"
	Make/O/N=(binning,2)/D $Wname + "_SE"
	Make/O/N=(binning)/D $Wname + "_Counts"

	Wave Wtest_AVG = $Wname + "_AVG"
	Wave Wtest_SE = $Wname + "_SE"
	Wave Wtest_Counts = $Wname + "_Counts"

	Variable i, j, step, fill
	Variable NoBin = 0
	Variable nPts = DimSize(WGS, 0)

	Make/O/N=(nPts)/D TempGS, TempGlyc

	for (step = binSize; step <= top; step += binSize)
		Redimension/N=(nPts) TempGS, TempGlyc  // <- Reset size before reuse
		fill = 0
		for (i = 0; i < nPts; i += 1)
			if ((step < top && WGS[i] <= step && WGS[i] > step - binSize) || (step >= top && WGS[i] <= top && WGS[i] > step - binSize))
            
				TempGS[fill] = WGS[i]
				TempGlyc[fill] = WGlyc[i]
				fill += 1
			endif
		endfor

		// Trim the waves to the number of filled entries
		if (fill > 0)
			Redimension/N=(fill) TempGS, TempGlyc

			WaveStats/Q TempGS
			Wtest_AVG[NoBin][1] = V_avg
			Wtest_SE[NoBin][1] = V_SEM

			WaveStats/Q TempGlyc
			Wtest_AVG[NoBin][0] = V_avg
			Wtest_SE[NoBin][0] = V_SEM
            
		else
			Wtest_AVG[NoBin][] = NaN
			Wtest_SE[NoBin][] = NaN
		endif
		Wtest_Counts[NoBin] = fill
		NoBin += 1
	endfor

	KillWaves/Z TempGS, TempGlyc
End
