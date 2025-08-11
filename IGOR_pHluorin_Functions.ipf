#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#include <KBColorizeTraces>

//////// Function 1 ##############
Function Load0GlucStim(Date,CellNo)
	String Date
	Variable CellNo 
	
	variable/G Amonio = 0  /// 1 = YES
	string Type = ""
	
	string/G NameBase = Date+"_C"+num2str(CellNo)
	String/G Name  = NameBase+Type+"_", NameOUT, NameIN
	string NameINtemp, NameOUTemp
	
	String Sensor = "SynphypH"
	
	string Path  = "E:"+Sensor+":2025:"
	
	string/G SolType = "NH4Cl;5G;0G;5Gto0G"
	Make/O TotalSol= {1,1,1}
	
	string/G SolTypeOUT = "Amo;G5;G0"
	
	variable x, y, Total, AP
	for(x=0; x<=(itemsinlist(SolType)-1);x+=1)
		NameIN = Name+stringfromlist(x, SolType)
		NameOUT = stringfromlist(x, SolTypeOUT)		
					
		if (x == 0 && Amonio == 1)
			for (y=0;y<=1;y+=1)
				if(y==0)
					LoadWave/J/D/W/N/O/K=0 Path+NameBase+":"+NameIN+".txt"
					rename MeanW, $NameOUT+"_Raw"
				elseif(y==1)
					LoadWave/J/D/W/N/O/K=0 Path+NameBase+":BG_"+NameIN+".txt"
					rename MeanW, $NameOUT+"_BG"
				endif
			endfor
		elseif (x!=0)
			Total = TotalSol[x-1]
			for (AP=0; AP<=(Total-1);AP+=1)
				NameINtemp = NameIN+"_50AP_"+num2str(AP)
				NameOUTemp = NameOUT+"_50AP_Raw_"+num2str(AP)
				for (y=0;y<=1;y+=1)
					if(y==0)
						LoadWave/J/D/W/N/O/K=0 Path+NameBase+":"+NameINtemp+".txt"
						rename MeanW, $NameOUTemp
					elseif(y==1)
						if(AP==0)
							NameINtemp = NameIN+"_50AP"
						endif						
						LoadWave/J/D/W/N/O/K=0 Path+NameBase+":BG_"+NameINtemp+".txt"
						rename MeanW, $NameOUTemp+"_BG"
					endif
				endfor
			endfor
		endif
	endfor
	
	Make/O/N=(Sum(TotalSol)) WIndex
	WIndex =p
	if(Amonio == 1)
		wave Amo_Raw
		Display/K=0 Amo_Raw
		ShowInfo
	endif
	
end

////////////////// Function 2 //////////////////////////////////////////////////////////////

Function TraceBGsubs()
	
	wave TotalSol
	string/G types = "G5;G0"
	
	variable x

	for (x=0; x<=(itemsinlist(types)-1); x+=1)
		variable/G  Gain = 100, nRounds = TotalSol[x]
		string Type = stringfromlist(x, types)
		print Type
		
		if (x == 1)
			display/N= NormTrace
		endif
		
		GlucTraceF(Type)
		Norm2Peak(Type)	
		
	endfor
	string name =""
	KBColorizeTraces#KBColorTablePopMenuProc(name,0,"Rainbow")
	F_BL_ConcaColor(nRounds, stringfromlist(1, types)) //itemsinlist(types)-1, types))
end


////////////////// Function 3 ////////////////////////////////

function Decar50differentTau()
	variable/G Time50per
	make/O/N=5 xTau_HalfDecay
	variable TimesTau
	for (TimesTau = 3; TimesTau<=3;TimesTau+=1)  // Tau = 3
		TwoTauDef0Gluc(TimesTau)
		TwoTauSelection(TimesTau)
		xTau_HalfDecay[TimesTau-1] =Time50per		 
	endfor
	
end

//////////////////////////////////////////////////////
//////////////////////////////////////////////////////
/// Functions embebed in in fuctions bellow ///////

function AmoniumAnal0GlucStim(BLo)
	variable BLo
	Wave Amo_Raw, Amo_BG
	
	duplicate/O Amo_Raw, Amo_F
	Amo_F=Amo_Raw-Amo_BG
	Amo_F*=100/100 /// GAIN TO 100
	
	variable/G BL_Amo = BLo //V_AVG
	duplicate/O Amo_F, Amo_dF
	Amo_dF = Amo_F- BL_Amo
	
	wavestats/Q/R=(pcsr(A),pcsr(B)) Amo_dF
	variable/G AmoAVG = V_avg
	wavestats/Q/R=(pcsr(A),pcsr(B)) Amo_F
	print AmoAVG
	
	Display/N= NH4Cl_Plot /W=(373.5,65,552,227.75)  Amo_dF
	ModifyGraph lSize=1.2
	ModifyGraph rgb=(0,39168,0)
	ModifyGraph fSize=12
	ModifyGraph standoff(bottom)=0
	ModifyGraph axOffset(left)=-1.44444,axOffset(bottom)=0.833333
	ModifyGraph axThick=1.2
	ModifyGraph axisEnab(bottom)={0.02,1}
	Label left "\\Z12\\F'Symbol'D\\F'Terminal'\\F'Times New Roman'F"
	Label bottom "Frame"
	SetAxis left -61.209415,*
end
/////////////////////////////////
//////////////////////////////////

function GlucTraceF(Type)
	string Type
	string RawList = wavelist(Type+"_*Raw*",";","")
	variable/G  Gain
	variable item, x =0 
	
	string/G types
		
	if  (CmpStr (Type,stringfromlist(0,types)) == 0) /// Glucsoe
		Gain = 100	
	endif
	
	for (item =0; item<=(itemsinlist(RawList)-1); item+=2)
		wave WRaw =$stringfromlist(item, RawList)
		wave WBG = $stringfromlist(item+1, RawList)
		
		Duplicate/O WRaw, $Type+"_F_"+num2str(x)
		wave WF= $Type+"_F_"+num2str(x)
		WF -=WBG
		
		SetScale/P x 0,0.25,"", WF
		
		WF*=100/Gain  /// GAIN TO 1000	
		x+=1
	endfor
	
	if (CmpStr (Type,stringfromlist(0,types)) == 0)  /// Glucose
		string GlucList = wavelist (Type+"_F_*",";","") 
		fWaveAverage(GlucList, "", 0, 0, Type+"_F_AVG", "")
	endif

end

/////////////////////////////////////////////////////////////////////////

function Norm2Peak(Type)
	String Type
	string TraceList = wavelist(Type+"_F*",";","")
	
	variable/G Amonio
	variable/G AmoAVG
	
	string/G types
	string Wname = stringfromlist(itemsinlist(types)-1, types)//// just for the name
	
	variable item
	
	for (item = 0; item<=(itemsinlist(TraceList)-1); item+=1)
			
		wave WTrace =$stringfromlist(item, TraceList)
		
		if (CmpStr (nameofwave(WTrace),stringfromlist(0,types)+"_F_AVG") == 0) //&&  (item == itemsinlist(TraceList)-1))
			string lastpartname = "AVG"
		else
			lastpartname = num2str(item)
		endif
				
		Duplicate/O WTrace, $Type+"_dF_"+lastpartname
		wave WdF= $Type+"_dF_"+lastpartname
		wavestats/Q/R=[0,15] WdF
		WdF-=V_AVG
		
		if (Amonio == 1)
			if (CmpStr (stringfromlist(item, TraceList),stringfromlist(0,types)+"_F_0") == 0)
				AmoniumAnal0GlucStim(V_AVG)
			endif
		
			Duplicate/O WdF, $Type+"_Amon_"+lastpartname
			wave WAmon= $Type+"_Amon_"+lastpartname
			WAmon = (WdF/AmoAVG)*100
		endif
		
		Duplicate/O WdF, $Type+"_Norm_"+lastpartname
		wave WNorm= $Type+"_Norm_"+lastpartname
		
		wavestats/Q/R=[35,45] WNorm //35,41
		WNorm/=V_Max
		

		if (CmpStr (Type,Wname ) == 0)
			appendtograph/W = NormTrace WNorm
		endif
		
	endfor


end
///////////////////////////////////////////////
function TwoTauDef()
	
	string/G types

	string Glucwaves = wavelist(stringfromlist(0,types)+"_Norm_*",";","")
	variable item
	wave WTrace = $stringfromlist(0, Glucwaves)
	duplicate/O WTrace, Gluc_Trace_AVG 

	for (item = 1; item<=(itemsinlist(Glucwaves)-1); item+=1)
		wave WTrace =$stringfromlist(item, Glucwaves)
		Gluc_Trace_AVG+=WTrace
	endfor
	
	Gluc_Trace_AVG/=itemsinlist(Glucwaves)

	wavestats/Q/R=[35,65] Gluc_Trace_AVG

	CurveFit/Q/M=2/W=0 exp_XOffset, Gluc_Trace_AVG(V_MaxLoc,62)/D
	wave W_coef

	variable Time2Tau =  V_MaxLoc+(W_coef[2]*2)
	string/G XTime
	sprintf XTime ,"%.3g\r", Time2Tau
	print XTime
end

////////////////////////////////////////////////

function TwoTauDef0Gluc(TimesTau)
	variable TimesTau
	
	string/G types
	string Wname = stringfromlist(0, types)+"_Norm_AVG"  //// Tau time from Glucose AVG trace
	
	wave WTrace = $Wname

	wavestats/Q/R=[35,65] WTrace

	CurveFit/Q/M=2/W=0 exp_XOffset, WTrace(V_MaxLoc,62)/D
	wave W_coef

	variable Time2Tau =  V_MaxLoc+(W_coef[2]*TimesTau)
	string/G XTime
	sprintf XTime ,"%.3g\r", Time2Tau
	print "Tau Value = ", W_coef[2]
	print "TauX"+num2str(TimesTau)+"= ", XTime
end
///////////////////////////////////////////////


Function  TwoTauSelection(TimesTau)
	variable TimesTau
	string/G XTime
	string/G types
	
	string ZeroGlucwaves = wavelist(stringfromlist(1, types)+"_Norm_*",";","")
	string ZeroGlucOligowaves = wavelist(stringfromlist(2, types)+"_Norm_*",";","")
	
	string ALlZeroGLuc =ZeroGlucwaves+ ZeroGlucOligowaves
	
	variable item
 
	Make/O/N=(itemsinlist(ALlZeroGLuc)) $"Yval"+num2str(TimesTau)+"xTau"
	
	wave Yval2Tau = $"Yval"+num2str(TimesTau)+"xTau"
	SetScale/P x 1,1,"", Yval2Tau
	
	if (TimesTau<=3)
		for (item = 0; item<=(itemsinlist(ALlZeroGLuc)-1); item+=1)
			wave WTrace =$stringfromlist(item, ALlZeroGLuc)
			wavestats/Q/R=[35,65] WTrace
			CurveFit/Q/M=2/W=0 exp_XOffset, WTrace(V_MaxLoc,62)/D
			wave Wfit = $"fit_"+nameofwave(WTrace)
			Yval2Tau[item]=Wfit(str2num(XTime))
		endfor
		
	else 
		for (item = 0; item<=(itemsinlist(ALlZeroGLuc)-1); item+=1)
			wave WTrace =$stringfromlist(item, ALlZeroGLuc)
			Yval2Tau[item]=mean(WTrace, str2num(XTime)-0.25, str2num(XTime)+0.25)
		endfor
		
	endif
	
	variable V50 = 0.5

	variable/G Time50per 
	findlevel/Q Yval2Tau, V50
	Time50per=V_LevelX
	print "Time to 50% = ",Time50per

	wave WIndex
	Display/K=0 Yval2Tau
	SetAxis left -0.2,1
	ModifyGraph manTick(left)={0,0.5,0,1},manMinor(left)={1,0}
	ModifyGraph mode=4,marker=19
	ModifyGraph zColor($"Yval"+num2str(TimesTau)+"xTau")={WIndex,*,*,Rainbow,0}
	ModifyGraph lstyle=3
	ModifyGraph grid(left)=2,ZisZ(left)=1,zapTZ(left)=1,gridStyle(left)=2;DelayUpdate
	ModifyGraph gridHair(left)=0,gridRGB(left)=(34816,34816,34816)
	Label left "% Endocytic Block"
	ModifyGraph manTick(bottom)={1,2,0,0},manMinor(bottom)={0,0};DelayUpdate
	Label bottom "Stim Round";DelayUpdate
	SetAxis bottom 1,30
end
		
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////


Function F_BL_ConcaColor(nRounds, type)
	variable nRounds
	string type
	variable/G AmoAVG, BL_Amo, Amonio
	
	CP_WConcatenate(type+"_F_*", type+"_F_Conca")
	
	wave WTrace = $type+"_F_"
	wave Wconca = $type+"_F_Conca"
	
	if (Amonio == 1)
		duplicate/O Wconca, $type+"_Amon_Conca"
		wave WConcaAmon = $type+"_Amon_Conca"
	endif
	
	WConcaAmon-=BL_Amo
	WConcaAmon = (WConcaAmon/AmoAVG)*100
		
	duplicate/o Wconca, $type+"_F_ColorIndex"
	wave WColorIndex = $type+"_F_ColorIndex"
	
	variable x = 0, y
	
	for(y=1;y<=nRounds;y+=1)
		WColorIndex[x,x+249] = y
		x+=250
	endfor
	
	if (Amonio == 1)
		Display/K=0 $type+"_Amon_Conca"
		ModifyGraph zColor($type+"_Amon_Conca")={$type+"_F_ColorIndex",*,*,Rainbow,0}
		Label left "% NH4Cl"
	else
		Display/K=0 $type+"_F_Conca"
		ModifyGraph zColor($type+"_F_Conca")={$type+"_F_ColorIndex",*,*,Rainbow,0}
		Label left "F (A.U)"
	endif
end

///////////////////////////////////////////

function AmplitudandBLRoundStim(nRounds)
	variable nRounds
	string/G types
	variable/G BL_Amo, AmoAVG
	variable check = itemsinlist(types)-1
	
	Make/O/N=(nRounds) StimBL_Amon
	Make/O/N=(nRounds) StimdFPeak_Amon
	
	variable NoRound
	
	for (NoRound=0;NoRound<=(nRounds-1); NoRound+=1)
		
		wave Wpeak = $stringfromlist(check, types)+"_Amon_"+num2str(NoRound)
		wavestats/Q/R=[35,65] WPeak
		StimdFPeak_Amon[NoRound]= V_max
		
		wave WBL = $stringfromlist(check, types)+"_F_"+num2str(NoRound)
		wavestats/Q/R=[0,15] WBL
		StimBL_Amon[NoRound] = ((V_AVG-BL_Amo)/AmoAVG)*100
		
	endfor
	
	SetScale/P x 1,1,"", StimBL_Amon
	SetScale/P x 1,1,"", StimdFPeak_Amon
	
	wave WIndex
	Display /W=(351,130.25,722.25,338.75) StimBL_Amon
	ModifyGraph mode=4
	ModifyGraph marker=19
	ModifyGraph lStyle=3
	ModifyGraph zColor(StimBL_Amon)={WIndex,*,*,Rainbow}
	ModifyGraph grid(left)=2
	ModifyGraph gridRGB(left)=(34816,34816,34816)
	ModifyGraph gridStyle(left)=2
	ModifyGraph gridHair(left)=0
	ModifyGraph ZisZ(left)=1
	ModifyGraph zapTZ(left)=1
	ModifyGraph manTick(bottom)={1,2,0,0},manMinor(bottom)={0,0}
	Label left "% F\\BBL\\M/NH4Cl\\BMax"
	Label bottom "Stim Round"
	SetAxis left -5,15
	
	Display /W=(503.25,173.75,874.5,382.25) StimdFPeak_Amon
	ModifyGraph mode=4
	ModifyGraph marker=19
	ModifyGraph lStyle=3
	ModifyGraph zColor(StimdFPeak_Amon)={WIndex,*,*,Rainbow}
	ModifyGraph grid(left)=2
	ModifyGraph lblMargin(left)=3
	ModifyGraph gridRGB(left)=(34816,34816,34816)
	ModifyGraph gridStyle(left)=2
	ModifyGraph gridHair(left)=0
	ModifyGraph ZisZ(left)=1
	ModifyGraph zapTZ(left)=1
	ModifyGraph manTick(bottom)={1,2,0,0},manMinor(bottom)={0,0}
	Label left "% \\F'Symbol'D\\F'Arial'F\\B\\M/NH4Cl\\BMax"
	Label bottom "Stim Round"
	SetAxis left 0,25
	
end
