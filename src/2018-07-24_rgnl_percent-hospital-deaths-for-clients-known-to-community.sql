

/*--------------------------------------------------------
-- EOL INDICATORs: 
> Percent of Overall Hospital Deaths for Clients Known to VCH Community Program
> Avg hospital days in the last 6 months of life 
--------------------------------------------------------*/

-- cleanup 
if object_id('tempdb.dbo.#deathsInAcute') is not null drop table #deathsInAcute; 




--pull all deaths in acute: 
select [PatientID]
      ,[SourceSystemClientID]
      ,[AcuteServiceID]
      ,[CommunityServiceID]
      ,[Gender]
      ,[ClientLHA]
	  ,IIF([ClientLHA] in ('North Shore Community','North Vancouver','West Vancouver - Bowen Island','West Vancouver-Bowen Island'),'Coastal Urban',IIF([ClientLHA] in ('Richmond'),'Richmond',IIF([ClientLHA] in ('Central Coast','Howe Sound','Bella Bella','Bella Coola Valley','Powell River','Sea To Sky','Sunshine Coast'),'Coastal Rural',IIF([ClientLHA] in ('CHA1/4','City Centre','Downtown Eastside','Midtown','North East','South Vancouver','Vancouver - CHA1','Vancouver - CHA2','Vancouver - CHA3','Vancouver - CHA4','Vancouver - CHA5','Vancouver - CHA6','Vancouver Community','Westside','Mental Health & Addiction','Provincial','VCH Region'),'Vancouver','')))) 
			as 'CommunityRegion2'
      ,[ClientRegion]
      ,[AgeAtDeath]
      ,[DeathDate]
      ,[DeathFiscalPeriod]
      ,[DeathFiscalQuarter]
      ,[DeathFiscalYear]
      ,[DeathCalendarMonth]
      ,[DeathCalendarYear]
      ,[StartDateLast6Month]
      ,[StartDateLast3Month]
      ,[DeathDataSource]
      ,[IsDeathInAcute]
      ,[IsKnownToCommunity]
      ,[IsKnownToHCCMRR]
      ,[DADAdmitLast6Month]
      ,[EDVisitLast6Month]
      ,[EDAdmitLast6Month]
      ,[AcuteFacilityShortName]
      ,[DADAcuteDayLast6Month]
      ,[EDCTAS45Last6Month]
      ,[RCInterventionID]
      ,[RCStartDate]
      ,[RCEndDate]
      ,[RCProvider]
      ,[IsRCDeath]
      ,[ALInterventionID]
      ,[ALStartDate]
      ,[ALEndDate]
      ,[ALProvider]
      ,[IsALDeath]
      ,[HospiceInterventionID]
      ,[HospiceStartDate]
      ,[HospiceEndDate]
      ,[HospiceProvider]
      ,[IsHospiceDeath]
      ,[IsEPAIRS]
      ,[EPAIRSStartDate]
      ,[EPAIRSDays]
      ,[DADAdmit_EPAIRS]
      ,[DADAcuteDays_EPAIRS]
      ,[EDVisits_EPAIRS]
      ,[EDAdmit_EPAIRS]
      ,[EDVisitsCTAS45_EPAIRS]
      ,[ActiveReferralLast6Month]
      ,[CaseNoteLast6Month] 

into #deathsInAcute
from [CommunityMart].[dbo].[vwEndOfLife]


-- group by quarter 
select *
	--, ((AcuteDeaths*1.0)/Deaths) * 100 as reportedMeasure   --todo: for some reason division give inaccurate result :/
from(

	select CommunityRegion2
		 ,DeathFiscalQuarter 
		, count(patientID) as Deaths 
		, sum(cast(isdeathinacute as int)) as AcuteDeaths
		, sum(dadacutedaylast6month) as AdjLOSDays
	from #deathsInAcute
	where 1=1 
		and IsKnownToCommunity = 1
		and CommunityRegion2 <> ' '			-- params: select area
		and DeathFiscalQuarter between '14-Q1' and '18-Q1' 
	group by DeathFiscalQuarter 
		, CommunityRegion2
	) as sub
order by CommunityRegion2
	 , DeathFiscalQuarter; 

