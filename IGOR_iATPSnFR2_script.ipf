#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Function iATPSnFR2_LoadRaw(Date,CellNo)  
	String Date
	Variable CellNo
	string Type = ""
	
	string Path  = "E:SynATPSnFR2-IRFP:2025:"
	
	variable Sensor, y, Total, NoRnd,Sol
	string NameFolder = Fecha+"_C"+num2str(CellNo)
	
	string NameINtemp, NameOUTemp, NameOUT, NameIN
	String/G SolType = "5G_600AP;0G_600AP"
	string/G SensorType = "RFP;iATPsf"
	string/G SensorTypeOUT="IR;A"
	
	Make/O TotalSol = {1,1}
	
	Make/T/O/N=(itemsinlist(SolType)*2) NameList	
	variable counter = 0	
	
	for(Sensor=0; Sensor<=itemsinlist(SensorType)-1;Sensor+=1)
		for (Sol=0; Sol<=itemsinlist(SolType)-1;Sol+=1)
			NameIN = Fecha+"_"+stringfromlist(Sensor,SensorType)+"_C"+num2str(CellNo)+"_"+stringfromlist(Sol,SolType)
			NameOUT = stringfromlist(Sensor,SensorTypeOUT)+"_"+stringfromlist(Sol,SolType)
				
			NameList[counter]=NameOUT
			counter+=1
			Total = TotalSol(Sol)
						
			for (NoRnd=0; NoRnd<=(Total-1);NoRnd+=1)
				NameINtemp = NameIN +"_"+ num2str(NoRnd)
				NameOUTemp = NameOUT+"_"+num2str(NoRnd)
				
				for (y=0;y<=1;y+=1)
					print NameINtemp
					if(y==0)
						LoadWave/J/D/W/N/O/K=0 Path+NameFolder+":"+NameINtemp+".txt"
						rename MeanW, $NameOUTemp+"_Raw"
					elseif(y==1)
						if(NoRnd ==0)
							NameINtemp = NameIN 
						endif
						LoadWave/J/D/W/N/O/K=0 Path+NameFolder+":BG_"+NameINtemp+".txt"
						rename MeanW, $NameOUTemp+"_BG"
					endif
				endfor
			endfor
		endfor
	endfor
	BackgdandF_SyniATPsfHALO()	
	Ratio_Trace()
end

/////////////////////////////////

function BackgdandF_SyniATPsfHALO()
	wave/T Namelist
	variable/G CampExp = 0.1  //// camera exp
	variable/G CampGain = 100
	variable file, Rnd, ROI, Frame
	
	for (file = 0; File<=Dimsize(Namelist,0)-1;file+=1)
		string WaveListRaw = wavelist(Namelist[file]+"_*_Raw",";","")
		string WaveListBlack = wavelist(Namelist[file]+"_*_Black",";","")
		
		for(Rnd=0; Rnd <= (itemsinlist(WaveListRaw)-1); Rnd+=1)
			wave WRaw = $stringfromlist(Rnd, WaveListRaw)
			wave WBlack = $stringfromlist(Rnd, WaveListBlack)
		
			Duplicate/O WRaw, $Namelist[file]+"_F_"+num2str(Rnd)
		
			wave WF= $Namelist[file]+"_F_"+num2str(Rnd)
			WF -=WBlack
			WF*=100/CampGain  /// GAIN TO 100
			
		endfor	 
	endfor
end
/////////////////////////////////////////

function Ratio_Trace()
	string/G SensorTypeOUT
	String/G SolType
	wave TotalSol
	
	variable sol, rnd
	for(sol=0;sol<=(itemsinlist(SolType)-1);sol+=1)
		for(rnd=0;rnd<=(TotalSol[sol]-1);rnd+=1)
			Wave WHalo = $stringfromlist(0,SensorTypeOUT)+"_"+stringfromlist(sol,SolType)+"_F_"+num2str(rnd)
			Wave WiATP = $stringfromlist(1,SensorTypeOUT)+"_"+stringfromlist(sol,SolType)+"_F_"+num2str(rnd)
		
			duplicate/O WiATP, $"RATIO_"+stringfromlist(sol,SolType)+"_"+num2str(rnd)
			wave Wratio = $"RATIO_"+stringfromlist(sol,SolType)+"_"+num2str(rnd)
		
			Wratio/=WHalo
		endfor
	endfor
	SensorTypeOUT+=";RATIO"
end
	


///////////////////////////////////////////////////////////////////////////////////////////////////
Function SyniATPsf_F_BL_ConcaColor()
	string/G SensorTypeOUT
	String/G SolType
	
	//variable/G NH4ClFPeak, BL_Amo
	variable x,item,sol
	for(x=0;x<=(itemsinlist(SensorTypeOUT)-1);x+=1)
		for(sol=0;sol<=(itemsinlist(SolType)-1);sol+=1)
			string type =stringfromlist(x,SensorTypeOUT)+"_"+stringfromlist(sol,SolType)
			if(x == itemsinlist(SensorTypeOUT)-1)
				CP_WConcatenate(type+"_*", type+"_Con")
			else
				CP_WConcatenate(type+"_F_*", type+"_F_Con")
			endif
		endfor 
		
		CP_WConcatenate(stringfromlist(x,SensorTypeOUT)+"_*_Con", stringfromlist(x,SensorTypeOUT)+"_ALL_Con")
		
	endfor
end
