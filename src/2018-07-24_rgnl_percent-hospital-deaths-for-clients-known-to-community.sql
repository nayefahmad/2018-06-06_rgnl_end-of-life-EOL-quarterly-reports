

--------------------------------------------------------
-- EOL INDICATOR: Percent of Overall Hospital Deaths for Clients Known to VCH Community Program
--------------------------------------------------------

-- cleanup 
if object_id('tempdb.dbo.#deathsInAcute') is not null drop table #deathsInAcute; 


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