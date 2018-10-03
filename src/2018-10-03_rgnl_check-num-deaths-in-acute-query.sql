

-----------------------------------------------------------------------
-- QUARTERLY DEATHS AND DEATHS IN ACUTE FROM EOL VIEW 
-----------------------------------------------------------------------

if object_id('tempdb.dbo.#deathsinacute') is not null drop table #deathsinacute; 

--select all deaths in acute ---------------------------------
select PatientID
	  ,IIF([ClientLHA] in ('North Shore Community','North Vancouver','West Vancouver - Bowen Island','West Vancouver-Bowen Island'),'Coastal Urban',IIF([ClientLHA] in ('Richmond'),'Richmond',IIF([ClientLHA] in ('Central Coast','Howe Sound','Bella Bella','Bella Coola Valley','Powell River','Sea To Sky','Sunshine Coast'),'Coastal Rural',IIF([ClientLHA] in ('CHA1/4','City Centre','Downtown Eastside','Midtown','North East','South Vancouver','Vancouver - CHA1','Vancouver - CHA2','Vancouver - CHA3','Vancouver - CHA4','Vancouver - CHA5','Vancouver - CHA6','Vancouver Community','Westside','Mental Health & Addiction','Provincial','VCH Region'),'Vancouver','')))) 
			as 'CommunityRegion2'
      ,[DeathFiscalQuarter]
      ,[DADAcuteDayLast6Month]
	  ,[IsKnownToCommunity]
	  ,[isDeathInAcute]

into #deathsInAcute
from [CommunityMart].[dbo].[vwEndOfLife]
where DeathFiscalQuarter >= '17-Q1' 


-- pull vancouver only: ---------------------------------
select CommunityRegion2
	, DeathFiscalQuarter
	, count(patientid) as num_deaths 
	, sum(cast(isdeathinacute as int)) as acute_deaths 
	
from #deathsInAcute
where CommunityRegion2 = 'Vancouver' 
group by CommunityRegion2
	, DeathFiscalQuarter
order by DeathFiscalQuarter


