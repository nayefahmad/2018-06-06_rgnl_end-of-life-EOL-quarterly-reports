

/*--------------------------------------------------------
-- EOL INDICATORs: 
> Percent of Overall Hospital Deaths for Clients Known to VCH Community Program
> Avg hospital days in the last 6 months of life 
--------------------------------------------------------*/

-- cleanup 
if object_id('tempdb.dbo.#deathsInAcute') is not null drop table #deathsInAcute; 




--pull all deaths in acute: 
select PatientID
	  ,IIF([ClientLHA] in ('North Shore Community','North Vancouver','West Vancouver - Bowen Island','West Vancouver-Bowen Island'),'Coastal Urban',IIF([ClientLHA] in ('Richmond'),'Richmond',IIF([ClientLHA] in ('Central Coast','Howe Sound','Bella Bella','Bella Coola Valley','Powell River','Sea To Sky','Sunshine Coast'),'Coastal Rural',IIF([ClientLHA] in ('CHA1/4','City Centre','Downtown Eastside','Midtown','North East','South Vancouver','Vancouver - CHA1','Vancouver - CHA2','Vancouver - CHA3','Vancouver - CHA4','Vancouver - CHA5','Vancouver - CHA6','Vancouver Community','Westside','Mental Health & Addiction','Provincial','VCH Region'),'Vancouver','')))) 
			as 'CommunityRegion2'
      ,[DeathFiscalPeriod]
      ,[DeathFiscalQuarter]
      ,[DeathFiscalYear]
      ,[DeathCalendarMonth]
      ,[DeathCalendarYear]
      ,[DADAcuteDayLast6Month]
	  ,[IsKnownToCommunity]
	  ,[isDeathInAcute]

into #deathsInAcute
from [CommunityMart].[dbo].[vwEndOfLife]


-- group by quarter 
select CommunityRegion2
	 ,DeathFiscalQuarter 
	, count(patientID) as Deaths 
	, sum(cast(isdeathinacute as int)) as AcuteDeaths
	, sum(dadacutedaylast6month) as AdjLOSDays
from #deathsInAcute
where 1=1 
	and IsKnownToCommunity = 1
	--and CommunityRegion2 <> ' '			-- params: select area
	and DeathFiscalQuarter between '14-Q1' and '18-Q4' 
group by DeathFiscalQuarter 
	, CommunityRegion2
order by CommunityRegion2
	 , DeathFiscalQuarter; 

