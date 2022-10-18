USE CM_MEM   -- <--- INSERIR O NOME DO BD


SELECT vrs.ResourceID
,vrs.Netbios_Name0
,[Online] = (
	select distinct CNIsOnline
	FROM v_CollectionMemberClientBaselineStatus
	WHERE MachineID = vrs.ResourceID
	)
,[LastOnlineTime] = (
	select distinct CONVERT(varchar,CNLastOnlineTime,103) as [DD/MM/YYYY HH:mm]
	FROM v_CollectionMemberClientBaselineStatus
	WHERE MachineID = vrs.ResourceID
	)
,[Patches Totais] = (
		SELECT count(DISTINCT ui.articleid)
		FROM v_UpdateComplianceStatus ucs
		INNER JOIN v_UpdateInfo ui ON ui.CI_ID = ucs.CI_ID
		INNER JOIN (
			v_CICategories_All catall1 INNER JOIN v_CategoryInfo catinfo1 ON catall1.CategoryInstance_UniqueID = catinfo1.CategoryInstance_UniqueID
				AND catinfo1.CategoryTypeName = 'UpdateClassification'
			) ON catall1.CI_ID = ui.CI_ID
		WHERE ui.IsDeployed = 1
		and vrs.ResourceID = ucs.ResourceID
		GROUP BY ResourceID
		)

,isnull((
		SELECT count(DISTINCT ui.articleid)
		FROM v_UpdateComplianceStatus ucs
		INNER JOIN v_UpdateInfo ui ON ui.CI_ID = ucs.CI_ID
		INNER JOIN (
			v_CICategories_All catall1 INNER JOIN v_CategoryInfo catinfo1 ON catall1.CategoryInstance_UniqueID = catinfo1.CategoryInstance_UniqueID
				AND catinfo1.CategoryTypeName = 'UpdateClassification'
			) ON catall1.CI_ID = ui.CI_ID
		WHERE ui.IsDeployed = 1
			AND ui.isExpired = 0
			AND ucs.STATUS = 2
			AND ucs.ResourceID = vrs.ResourceID
		GROUP BY ResourceID
		),0) as 'Patches Faltantes'

,LastScanSUP = (
	SELECT convert(VARCHAR(10), lastscantime, 103)
	FROM v_updatescanstatus
	WHERE ResourceID = vrs.ResourceID
	)
,Inventário_HW = (
	SELECT convert(VARCHAR(10), LastHWScan, 103)
	FROM v_GS_Workstation_Status
	WHERE ResourceID = vrs.ResourceID
	)
,[SO] = so.Caption0
,[Cliente_Instalado] = vrs.Client0
,[Cliente_Ativo] = vrs.Active0
,[Version] = vrs.Client_Version0
,LastErrorCode = (
	SELECT LastErrorCode
	FROM v_updatescanstatus
	WHERE ResourceID = vrs.ResourceID
	)
,LastScanPackageVersion = (
	SELECT LastScanPackageVersion
	FROM v_updatescanstatus
	WHERE ResourceID = vrs.ResourceID
	)
,SUPSync = (
	select SyncCatalogVersion
	FROM vSMS_SUPSyncStatus
	WHERE WSUSServerName = 'servidor.contoso.biz' --SERVIDOR com a ROLE SUP
	)
,cs.Model0
,cs.Roles0

FROM v_R_System vrs
left join v_GS_OPERATING_SYSTEM so on so.ResourceID = vrs.ResourceID
left join v_GS_COMPUTER_SYSTEM cs on cs.ResourceID = vrs.ResourceID

--WHERE vrs.Netbios_Name0 in ('SERVIDOR1','SERVIDOR2','SERVIDOR3') --Inserir a lista dos servidores
--WHERE so.Caption0 like '%Server%' --Todos os objetios com SO Server
