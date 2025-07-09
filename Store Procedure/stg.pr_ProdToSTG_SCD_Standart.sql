USE [Configuration]
GO
 
 CREATE proc [stg].[pr_ProdToSTG_SCD_Standart] (@src_server nvarchar(max), @Src_DB nvarchar(max))
 as
 begin
 
 declare @sql nvarchar(max)=''

-- Cursor yaradılması
DECLARE @ID				   int;
DECLARE @Source_Sever	   nvarchar(max) 
DECLARE @Source_Database   nvarchar(max)
DECLARE @Source_Schema	   nvarchar(max)
DECLARE @Source_Table	   nvarchar(max)
DECLARE @Dest_Server	   nvarchar(max)
DECLARE @Dest_Database	   nvarchar(max)
DECLARE @Dest_Schema	   nvarchar(max)
DECLARE @Dest_Table		   nvarchar(max)
DECLARE @Exec_type		   nvarchar(max)
 
 
 -----------------
declare @dim_join_id nvarchar(max)=''
declare @src_join_id nvarchar(max)=''

declare @dim_clm_StartDate nvarchar(max)=''
declare @dim_clm_EndDate nvarchar(max)=''
declare @dim_clm_Iscurrent nvarchar(max)=''
 
 ------------

DECLARE Config_Cursor CURSOR FOR

select    t.ID, t.Source_Sever, t.Source_Database, t.Source_Schema, t.Source_Table, t.Dest_Server, t.Dest_Database, t.Dest_Schema, t.Dest_Table, t.Exec_type		   
from Configuration.stg.ProdToSTG t
where t.Active=1 and t.Exec_type='STG_Standart'  and t.Source_Database=@Src_DB and t.Source_Sever=@src_server
--and t.ID=19-- between 16 and 20
--and t.ID=@ID
order by 1 desc

-- Cursorun açılması
OPEN Config_Cursor;

-- İlk məlumatın əldə edilməsi
FETCH NEXT FROM Config_Cursor INTO @ID, @Source_Sever, @Source_Database, @Source_Schema, @Source_Table, @Dest_Server, @Dest_Database, @Dest_Schema, @Dest_Table, @Exec_type;

-- Cursor ilə hər bir sətir üzərində işləmək
WHILE @@FETCH_STATUS = 0
BEGIN

select @dim_join_id=c.Dest_Column, @src_join_id=c.Source_Column
from Configuration.stg.StgTableColumn c where c.ProdToSTG_ID= @ID  and c.Column_Type_ID=1

select @dim_clm_StartDate= max(iif(c.Column_Type_ID=10, c.Dest_column, '')) 
,@dim_clm_EndDate= max(iif(c.Column_Type_ID=11, c.Dest_column, ''))
,@dim_clm_Iscurrent=max(iif(c.Column_Type_ID=12, c.Dest_column, '')) 
from Configuration.stg.StgTableColumn c where c.ProdToSTG_ID= @ID  
and c.Column_Type_ID in (10,11,12)
 
 --,IIF(t.IsString=1, concat(' collate SQL_Latin1_General_CP1_CI_AS ', '[','',']'), '')


declare @all_clm_CS_1 nvarchar(max)=(select  STUFF( (
SELECT ',' + t.Dest_Column from  ( 
select concat(iif(t.IsString=1,'[Configuration].[dbo].[azh](','')+' CS.[',t.Source_Column,'] ',iif(t.IsString=1,') ','') ) Dest_Column, t.ID from Configuration.stg.StgTableColumn t where t.ProdToSTG_ID=@ID and t.Column_Type_ID in (1,13,14,15)
)t
order by t.ID    FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '') )

declare @all_clm_CS_2 nvarchar(max)=(select  STUFF( (
SELECT ',' + t.Dest_Column from  ( 
select concat(iif(t.IsString=1,'[Configuration].[dbo].[azh](','')+' CS.[',t.Dest_Column,'] ',iif(t.IsString=1,') ['+t.Dest_Column+']','') ) Dest_Column, t.ID from Configuration.stg.StgTableColumn t where t.ProdToSTG_ID=@ID and t.Column_Type_ID in (1,13,14,15)
)t
order by t.ID    FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '') )



declare @all_clm_1 nvarchar(max)=(select  STUFF( (
SELECT ',' + t.Dest_Column from  ( 
select concat(' [',t.Dest_Column,'] ') Dest_Column, t.ID from Configuration.stg.StgTableColumn t where t.ProdToSTG_ID=@ID and t.Column_Type_ID in (1,13,14,15)
)t
order by t.ID    FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '') )
 



declare @typ1_cand nvarchar(max)= 'WHEN MATCHED and ('+(

select  concat(' BINARY_CHECKSUM( ',STUFF( (
SELECT ',' + t.Dest_Column from  ( 
select concat(' cm.[',t.Dest_Column,']' ) Dest_Column, t.ID 
from Configuration.stg.StgTableColumn t 
where t.ProdToSTG_ID=@ID and t.Column_Type_ID in (1, 14) )t
order by t.ID    FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, ''),') ',

 '<> BINARY_CHECKSUM( ', STUFF( (
SELECT ',' + t.Dest_Column from  ( 
select concat(' ',iif(t.IsString=1, '[Configuration].[dbo].[azh](', ''),'cs.[',t.Source_Column,'] ',IIF(t.IsString=1, ') collate SQL_Latin1_General_CP1_CI_AS ', '')) Dest_Column, t.ID from Configuration.stg.StgTableColumn t 
where t.ProdToSTG_ID=@ID and t.Column_Type_ID in (1,14) )t
order by t.ID    FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '') ,') ' )

)+
') THEN    UPDATE SET '+(select  STUFF( (
SELECT ' , ' + t.Dest_Column from  ( 
select concat(' cm.[',t.Dest_Column,'] = ',iif(t.IsString=1, '[Configuration].[dbo].[azh](', ''),'cs.[',t.Source_Column,'] ',IIF(t.IsString=1, ') collate SQL_Latin1_General_CP1_CI_AS ', '')) Dest_Column, t.ID from Configuration.stg.StgTableColumn t 
where t.ProdToSTG_ID=@ID and t.Column_Type_ID=14 )t
order by t.ID    FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 3, '') )
 
-- select * from   Configuration.stg.StgTableColumn t 

-- declare @typ2_cand nvarchar(max)=' CM.[FirstName] <> CS.[FirstName] or CM.[LastName]<> CS.[LastName]  or CM.[Phone]<> CS.[Phone]  '

 

 declare @typ2_cand nvarchar(max)= 'WHEN MATCHED  AND CM.['+@dim_clm_Iscurrent+'] =1  AND (  '
 +(
 
--select  STUFF( (
--SELECT ' or ' + t.Dest_Column from  ( 
--select concat(' cm.[',t.Dest_Column,'] <> ',iif(t.IsString=1, '[Configuration].[dbo].[azh](', ''),'cs.[',t.Source_Column,'] ',IIF(t.IsString=1, ') collate SQL_Latin1_General_CP1_CI_AS ', '')) Dest_Column, t.ID 
--from Configuration.stg.StgTableColumn t 
--where t.ProdToSTG_ID=@ID and t.Column_Type_ID=15 )t
--order by t.ID    FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 4, '') 

 select concat(' BINARY_CHECKSUM (',  STUFF( (
SELECT ',' + t.Dest_Column from  ( 
select concat(' cm.[',t.Dest_Column,'] ') Dest_Column, t.ID 
from Configuration.stg.StgTableColumn t 
where t.ProdToSTG_ID=@ID and t.Column_Type_ID in (1,15) )t
order by t.ID    FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, ''), ') '
,

' <> BINARY_CHECKSUM (', STUFF( (
SELECT ',' + t.Dest_Column from  ( 
select concat(' ',iif(t.IsString=1, '[Configuration].[dbo].[azh](', ''),'cs.[',t.Source_Column,'] ',IIF(t.IsString=1, ') collate SQL_Latin1_General_CP1_CI_AS ', '')) Dest_Column, t.ID 
from Configuration.stg.StgTableColumn t 
where t.ProdToSTG_ID=@ID and t.Column_Type_ID in (1,15) )t
order by t.ID    FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, ''),')'
)

 


)
+' ) 
THEN UPDATE  SET   CM.['+@dim_clm_Iscurrent+'] = 0,  CM.['+@dim_clm_EndDate+']  = getdate() '
 


set @sql=concat(N' 

INSERT INTO [',@Dest_Database,'].[',@Dest_Schema,'].[', @Dest_Table,']',N'

SELECT ',@all_clm_1,N', [',@dim_clm_StartDate,'], [',@dim_clm_EndDate,'], [',@dim_clm_Iscurrent,']
FROM( 

    MERGE    ','[',@Dest_Database,'].[',@Dest_Schema,'].[', @Dest_Table,']',N' CM
    USING    ','[',@Source_Sever,'].[',@Source_Database,'].[', @Source_Schema,'].[',@Source_Table,']',N' CS
    ON     CM.',@dim_join_id,'=',' CS.',@src_join_id,N'

	--------Yeni sətirlərin əlavə edilməsi
    WHEN NOT MATCHED     THEN
        INSERT VALUES  (  ',@all_clm_CS_1,N'
            , convert(date,''2000-01-01''),   eomonth(''9999-12-31''),     1       )
    
	---SCD TYPE 2-yə uygun dəyişikliklər olanlari update etmək.
	--- SCD type2 begin
	',@typ2_cand,N'
	----SCD type2 end


    OUTPUT  $Action Action_Out,
            ',@all_clm_CS_2,N'
         , convert(date,''2000-01-01'')  StartDate,
         eomonth(''9999-12-31'') EndDate,
        1 IsCurrent
    ) AS MERGE_OUT
WHERE  MERGE_OUT.Action_Out = ''UPDATE'';


MERGE    ','[',@Dest_Database,'].[',@Dest_Schema,'].[', @Dest_Table,']',N' CM
USING    ','[',@Source_Sever,'].[',@Source_Database,'].[', @Source_Schema,'].[',@Source_Table,']',N' CS
ON     CM.',@dim_join_id,N'=','CS.',@src_join_id,N'

------SCD_type1_begin
',@typ1_cand,N'

------SCD_type1_end

 
WHEN NOT MATCHED BY SOURCE AND CM.[',@dim_clm_Iscurrent,'] = 1 THEN
UPDATE SET   CM.',@dim_clm_EndDate,' = GETDATE(),  CM.[',@dim_clm_Iscurrent,'] = 0	;

 '
 )



---------------------------------------------

print(concat('ID: ',@ID,' Dest_Table:',@Dest_Table))
print(concat('start:', convert(nvarchar(max),getdate(), 21)))

exec(@sql)
-------------------------------------------------------



-------------------------------------------- print begin
--DECLARE @FullText NVARCHAR(MAX) = @sql
--DECLARE @StartIndex INT = 1;DECLARE @ChunkSize INT = 1000;  DECLARE @EndIndex INT; DECLARE @CurrentText NVARCHAR(1000);
--WHILE @StartIndex <= LEN(@FullText) BEGIN  SET @EndIndex = @StartIndex + @ChunkSize - 1;
--    IF SUBSTRING(@FullText, @EndIndex, 1) <> ' '     BEGIN        WHILE @EndIndex > @StartIndex AND SUBSTRING(@FullText, @EndIndex, 1) <> ' '
--     BEGIN       SET @EndIndex = @EndIndex - 1;     END    END
--    SET @CurrentText = SUBSTRING(@FullText, @StartIndex, @EndIndex - @StartIndex + 1);
--    PRINT @CurrentText;    SET @StartIndex = @EndIndex + 1;END

-------------------------------------------- print end


FETCH NEXT FROM Config_Cursor INTO  @ID, @Source_Sever, @Source_Database, @Source_Schema, @Source_Table, @Dest_Server, @Dest_Database, @Dest_Schema, @Dest_Table, @Exec_type;


END;

 
CLOSE Config_Cursor;
DEALLOCATE Config_Cursor;


end


GO
