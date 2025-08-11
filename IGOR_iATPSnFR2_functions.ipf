#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Function Load0GlucStim_SyniATPsf(Fecha,CellNo)
	String Date
	Variable CellNo
	string Type = ""
		
	string Path  = "E:SynATPSnFR2-IRFP:2025:"
	variable Sensor, y, Total, NoRnd,Sol, FrameBL = 30
	string NameFolder = Fecha+"_C"+num2str(CellNo)
	
	string NameINtemp, NameOUTemp, NameOUT, NameIN
	
	String/G Stim = "600AP"
	String/G SolType = "5G;0G"
	string/G SensorType = "IRFP;iATPsf"
	string/G SensorTypeOUT="IR;A"
	
	Make/O TotalSol = {1,2}
	
	Make/T/O/N=(itemsinlist(SolType)*2) NameList	
	variable counter = 0	
	
	for(Sensor=0; Sensor<=itemsinlist(SensorType)-1;Sensor+=1)
		for (Sol=0; Sol<=itemsinlist(SolType)-1;Sol+=1)
			if (Sol == 0 || Sol ==1)
				NameIN = Date+"_"+stringfromlist(Sensor,SensorType)+"_C"+num2str(CellNo)+"_"+Type+stringfromlist(Sol,SolType)+"_"+Stim
				NameOUT = stringfromlist(Sensor,SensorTypeOUT)+"_"+stringfromlist(Sol,SolType)+"_"+Stim
			else
				NameIN = Date+"_"+stringfromlist(Sensor,SensorType)+"_C"+num2str(CellNo)+"_"+Type+stringfromlist(Sol,SolType)
				NameOUT = stringfromlist(Sensor,SensorTypeOUT)+"_"+stringfromlist(Sol,SolType)
			endif
				
			NameList[counter]=NameOUT
			counter+=1
			Total = TotalSol(Sol)
						
			for (NoRnd=0; NoRnd<=(Total-1);NoRnd+=1)
				NameINtemp = NameIN +"_"+ num2str(NoRnd)
				NameOUTemp = NameOUT+"_"+num2str(NoRnd)
				for (y=0;y<=1;y+=1)
					if(y==0)
						LoadWave/J/D/W/N/O/K=0 Path+NameFolder+":"+NameINtemp+".txt"
						rename MeanW, $NameOUTemp+"_Raw"
					elseif(y==1)
						if(NoRnd==0)
							NameINtemp = NameIN
						endif
						LoadWave/J/D/W/N/O/K=0 Path+NameFolder+":BG_"+NameINtemp+".txt"
						rename MeanW, $NameOUTemp+"_BG"
					endif
				endfor
			endfor
		endfor
	endfor	
	BackgdandF_SyniATPsfIR()
	Ratio_Trace()
	Norm2BL()
	SyniATPsf_F_BL_ConcaColor()
	WTime_Plots(FrameBL)

end
/////////////////////////////////

Function Norm2BL()
	//String/G SolType 
	string WList =wavelist("R_*_0",";","")
	
	variable item
	for (item = 0; item<=(itemsinlist(WList)-1); item+=1)
			
		wave WTrace =$stringfromlist(item, WList)
		string Wname = nameofwave(WTrace)
		Wname = Wname[1,strlen(Wname)]
		Duplicate/O WTrace, $"N"+Wname
		wave WNorm= $"N"+Wname
		
		wavestats/Q/R=[0,28] WNorm
		WNorm/=V_AVG
	endfor
end
/////////////////////////////////

function BackgdandF_SyniATPsfIR()
	wave/T Namelist
	variable/G CampExp = 0.1  //// camera exp
	variable/G CampGain = 100
	variable file, Rnd, ROI, Frame
	
	for (file = 0; File<=Dimsize(Namelist,0)-1;file+=1)
		string WaveListRaw = wavelist(Namelist[file]+"_*_Raw",";","")
		string WaveListBG = wavelist(Namelist[file]+"_*BG",";","")
		
		for(Rnd=0; Rnd <= (itemsinlist(WaveListRaw)-1); Rnd+=1)
			wave WRaw = $stringfromlist(Rnd, WaveListRaw)
			wave WBG = $stringfromlist(Rnd, WaveListBG)
		
			Duplicate/O WRaw, $Namelist[file]+"_F_"+num2str(Rnd)
		
			wave WF= $Namelist[file]+"_F_"+num2str(Rnd)
			WF -=WBG
			WF*=100/CampGain  /// GAIN TO 100
			
		endfor	 
	endfor
end
/////////////////////////////////////////

function Ratio_Trace()
	string/G SensorTypeOUT
	String/G SolType
	String/G Stim 
	wave TotalSol
	
	variable sol, rnd
	for(sol=0;sol<=(itemsinlist(SolType)-1);sol+=1)
		for(rnd=0;rnd<=(TotalSol[sol]-1);rnd+=1)
			if (sol == 2)
				Wave WIR = $stringfromlist(0,SensorTypeOUT)+"_"+stringfromlist(sol,SolType)+"_F_"+num2str(rnd)
				Wave WiATP = $stringfromlist(1,SensorTypeOUT)+"_"+stringfromlist(sol,SolType)+"_F_"+num2str(rnd)		
			
				duplicate/O WiATP, $"R_"+stringfromlist(sol,SolType)+"_"+num2str(rnd)
				wave Wratio = $"R_"+stringfromlist(sol,SolType)+"_"+num2str(rnd)
		
			else
				Wave WIR = $stringfromlist(0,SensorTypeOUT)+"_"+stringfromlist(sol,SolType)+"_"+Stim+"_F_"+num2str(rnd)
				Wave WiATP = $stringfromlist(1,SensorTypeOUT)+"_"+stringfromlist(sol,SolType)+"_"+Stim+"_F_"+num2str(rnd)
				
				duplicate/O WiATP, $"R_"+stringfromlist(sol,SolType)+"_"+Stim+"_"+num2str(rnd)
				wave Wratio = $"R_"+stringfromlist(sol,SolType)+"_"+Stim+"_"+num2str(rnd)
			endif
			Wratio/=WIR
		endfor
	endfor
	SensorTypeOUT+=";R"
end
	

///////////////////////////////////////////////////////////////////////////////////////////////////
Function SyniATPsf_F_BL_ConcaColor()
	string/G SensorTypeOUT
	String/G SolType
	String/G Stim 
	
	variable x,item,sol
	for(x=0;x<=(itemsinlist(SensorTypeOUT)-1);x+=1)
		for(sol=0;sol<=(itemsinlist(SolType)-1);sol+=1)
			string type =stringfromlist(x,SensorTypeOUT)+"_"+stringfromlist(sol,SolType)+"_"+Stim
			if(x == itemsinlist(SensorTypeOUT)-1)
				CP_WConcatenate(type+"_*", type+"_Con")
			else
				CP_WConcatenate(type+"_F_*", type+"_F_Con")
			endif
		endfor 
		
		CP_WConcatenate(stringfromlist(x,SensorTypeOUT)+"_*_Con", stringfromlist(x,SensorTypeOUT)+"_ALL_Con")
		
	endfor
end

///////////////////////////////////////////////////////////////////////////////////////////////////
function WTime_Plots(FrameBL)
	variable FrameBL
	String/G SolType
	string TestSolution = stringfromlist(1,SolType)+"_600AP"
	print TestSolution
	wave WRatio = $"R_"+TestSolution+"_0"

	duplicate/O WRatio, WTime
	WTime=(p*2)/60
	variable TimeZero = WTime[FrameBL] 
	WTime-=TimeZero
	
	///////////////////////////////////////////////////////////////////////////////////
	Display WRatio vs WTime
	ModifyGraph fSize=12,axThick=1.2,axisEnab(left)={0.02,1};DelayUpdate
	ModifyGraph axisEnab(bottom)={0.02,1};DelayUpdate
	Label left "Syn-iATPsf / IR";DelayUpdate
	Label bottom "Time, min";DelayUpdate
	SetAxis left 0,*;DelayUpdate
	SetAxis bottom -7.5,*
	ModifyGraph lsize=1.2,rgb=(34816,34816,34816)
		
	///////////////////////////////////////////////////////////////////////////////////////
	wave A_ALL_Con, IR_ALL_Con
	Display/R A_ALL_Con; AppendToGraph IR_ALL_Con
	ModifyGraph fSize=12,axThick=1.2,axisEnab(right)={0.02,1};DelayUpdate
	ModifyGraph axisEnab(bottom)={0.02,0.98},axisEnab(left)={0.02,1};DelayUpdate
	ModifyGraph axRGB(right)=(26112,52224,0),axRGB(left)=(65280,0,0);DelayUpdate
	ModifyGraph tlblRGB(right)=(26112,52224,0),tlblRGB(left)=(65280,0,0);DelayUpdate
	ModifyGraph alblRGB(right)=(26112,52224,0),alblRGB(left)=(65280,0,0);DelayUpdate
	Label right "Syn-iATPsf";DelayUpdate
	Label bottom "Frames";DelayUpdate
	Label left "IR";DelayUpdate
	SetAxis bottom 0,*;DelayUpdate
	SetAxis left 0,*
	ModifyGraph lsize=1.2,rgb(A_ALL_Con)=(26112,52224,0)
	SetAxis right 0,*
	
end
