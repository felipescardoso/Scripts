Select CollectionID
,CollectionName
,CollectionComment
,MemberCount
,Case when RefreshType = 1 then 'Manual'
		when RefreshType = 2 then 'Scheduled'
		when RefreshType = 4 then 'Incremental'
		when RefreshType = 6 then 'Scheduled and Incremental'
		else 'Unknown' end as RefreshType
,isnull(LimitToCollectionName,'') as LimitToCollectionName
,ServiceWindowsCount
,CloudSyncCount
,PowerConfigsCount
,IsBuiltIn
,IncludeExcludeCollectionsCount
,FullEvaluationRunTime
,ObjectPath
from v_Collections
--group by RefreshType