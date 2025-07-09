USE [Configuration]
GO


----- bu prosedur, StgTableColumn cədvəlinə,  ProdToSTG cədvəlində olan cədvəllərin sütunlarını əlavə edir.
--------------- stg.StgTableColumn cədvəlini dolduru. bu cədvəl istifadə edilən cədvəllərdə, hansı sütunlar olacağını göstərir.
--------------- pr_insert_StgTableColumn_Exec prosedur pr_insert_StgTableColumn prosedurunu stg.StgTableColumn sətirlərinin hər birində run edir


CREATE proc [stg].[pr_insert_StgTableColumn] ( 
   @source_server nvarchar(max)
,  @source_db nvarchar(max)
,  @dest_db nvarchar(max)
,  @dest_scm nvarchar(max)
,  @dest_tbl nvarchar(max) 
)
as
begin


if @source_server='Server_a' or @source_server='server_b'  or @source_server='server_test'
begin


 

delete c
from Configuration.stg.StgTableColumn c

where c.ProdToSTG_ID in (
 select
   z.ID
from  Configuration.stg.ProdToSTG z
where z.Active=1 and z.Dest_Database=@dest_db and z.Dest_Schema=@dest_scm  and z.Dest_Table=@dest_tbl 
)


; with   dest as(
select *
from (
select   
  c.name clm
, 'STG' db 
,  s.name scm 
,  t.name  tbl
, c.column_id 
from      [STG].sys.tables t
left join [STG].sys.schemas s on s.schema_id=t.schema_id
left join [STG].sys.all_columns c on c.object_id=t.object_id

 
 ) t
 where t.db=@dest_db
 )
 
 ,    src as(
select *
from(

select  
  c.name clm
, 'Prodaction1' db 
,  s.name scm 
,  t.name  tbl
, c.column_id 
, iif(c.collation_name is null , 0, 1) isString
from      [server_a].[Prodaction1].sys.tables t
left join [server_a].[Prodaction1].sys.schemas s on s.schema_id=t.schema_id
left join [server_a].[Prodaction1].sys.all_columns c on c.object_id=t.object_id
where  @source_server='Server_a' and  @source_db= 'Prodaction1' 


union all

select  
  c.name clm
, 'Prodaction2' db 
,  s.name scm 
,  t.name  tbl
, c.column_id 
, iif(c.collation_name is null , 0, 1) isString
from      [server_a].[Prodaction2].sys.tables t
left join [server_a].[Prodaction2].sys.schemas s on s.schema_id=t.schema_id
left join [server_a].[Prodaction2].sys.all_columns c on c.object_id=t.object_id
where  @source_server='Server_a' and  @source_db= 'Prodaction1' 

union all

select  
  c.name clm
, 'Prodaction3' db 
,  s.name scm 
,  t.name  tbl
, c.column_id 
, iif(c.collation_name is null , 0, 1) isString
from      [server_b].[Prodaction3].sys.tables t
left join [server_b].[Prodaction3].sys.schemas s on s.schema_id=t.schema_id
left join [server_b].[Prodaction3].sys.all_columns c on c.object_id=t.object_id
where  @source_server='Server_b' and  @source_db= 'Prodaction3' 


union all

select  
  c.name clm
, 'Prodaction3' db 
,  s.name scm 
,  t.name  tbl
, c.column_id 
, iif(c.collation_name is null , 0, 1) isString
from      [server_test].[Prodaction_test].sys.tables t
left join [server_test].[Prodaction_test].sys.schemas s on s.schema_id=t.schema_id
left join [server_test].[Prodaction_test].sys.all_columns c on c.object_id=t.object_id
where  @source_server='Server_test' and  @source_db= 'Prodaction_test'  

 ) t
 


 )
 , dest_clm as(

 select
   z.ID
, 'dest' typ
, concat('[',z.Dest_Database, '].[', z.Dest_Schema, '].[' , z.Dest_Table,']') dest
, concat('[',z.Source_Database, '].[', z.Source_Schema, '].[' , z.Source_Table,']') src
, dest.column_id
, dest.clm
, dest.tbl
from  Configuration.stg.ProdToSTG z
inner join dest on dest.tbl=z.Dest_Table collate SQL_Latin1_General_CP1_CI_AS and z.Dest_Database=dest.db  collate SQL_Latin1_General_CP1_CI_AS and z.Dest_Schema=dest.scm  collate SQL_Latin1_General_CP1_CI_AS
where z.Active=1 and z.Dest_Database=@dest_db and z.Dest_Schema=@dest_scm  and z.Dest_Table=@dest_tbl 

)


, src_clm as(
 select
  z.ID
, src.column_id
, src.clm 
, src.isString
from  Configuration.stg.ProdToSTG z
inner join src on src.tbl=z.Source_Table collate SQL_Latin1_General_CP1_CI_AS and z.Source_Database=src.db  collate SQL_Latin1_General_CP1_CI_AS
where z.Active=1 and z.Dest_Database=@dest_db and z.Dest_Schema=@dest_scm  and z.Dest_Table=@dest_tbl 
)

insert into [Configuration].[stg].[StgTableColumn] ([ProdToSTG_ID],[Description_],[Dest_Column],[Source_Column],[Column_RN],[IsString],[Column_Type_ID],[Column_Type],[Active], CreateDate, ModifyDate)

select
 d.ID  ProdToSTG_ID
, concat('dest:', d.dest, '  src:', d.src) Description_
, d.clm  Dest_Column
, src_clm.clm Source_Column
, d.column_id Column_RN
, isnull(src_clm.IsString,0) IsString

, case when d.clm=concat(d.tbl,'_KEY') then 9
       when d.clm='LOGICALREF' then  1
	   when d.clm='StartDate' then  10
       when d.clm='EndDate' then 11
       when d.clm='IsCurrent' then  12
	   else 15 end Column_Type_ID


, case when d.clm=concat(d.tbl,'_KEY') then  'STG:Primary_Key'
       when d.clm='LOGICALREF' then  'Source:Primary_Key'
	   when d.clm='StartDate' then  'STG:Start'
       when d.clm='EndDate' then  'STG:End'
       when d.clm='IsCurrent' then  'STG:IsCurrent'
       else 'STG:SCD_Type2' end Column_Type


--, case when left(d.clm,3)='Dim' and RIGHT(d.clm, 4)='_KEY' then  'DWH_Primary_Key'
--       when d.clm='LOGICALREF' then  'Source_Primary_Key'
--	   when d.clm='StartDate' then  'Dim_Begin'
--       when d.clm='EndDate' then  'Dim_End'
--       when d.clm='IsCurrent' then  'IsCurrent'
--       else 'SCD_Type2' end Column_Type

, 1 Active
, getdate() CreateDate 
, getdate() ModifyDate

from dest_clm d
left join src_clm on src_clm.ID=d.ID and  src_clm.clm=d.clm collate SQL_Latin1_General_CP1_CI_AS
order by d.column_id

end
else
begin

print(concat(N'Source serverə aid olmayan məlumatlar var. source_server:', @source_server, '  @source_db:' , @source_db, '  dest_db:', @dest_db,'  dest_scm:', @dest_scm, ' dest_tbl:', @dest_tbl ))
 
end


end

 
GO
