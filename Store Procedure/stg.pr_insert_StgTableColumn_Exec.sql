USE [Configuration]
GO

/** Object:  StoredProcedure [stg].[pr_insert_StgTableColumn_Exec]    Script Date: 2025-07-09 17:50:21 **/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE proc [stg].[pr_insert_StgTableColumn_Exec] 
as
begin 
--------------- stg.StgTableColumn cədvəlini dolduru. bu cədvəl istifadə edilən cədvəllərdə, hansı sütunlar olacağını göstərir.
--------------- bu prosedur pr_insert_StgTableColumn prosedurunu stg.ProdToSTG sətirlərinin hər birində run edir

 
------------ selectin sütunları
DECLARE @ID				   int;
DECLARE @Source_Sever	   nvarchar(max) 
DECLARE @Source_Database   nvarchar(max)
DECLARE @Dest_Database	   nvarchar(max)
DECLARE @Dest_Schema	   nvarchar(max)
DECLARE @Dest_Table		   nvarchar(max)
--------------------------------


  
 
DECLARE Config_Cursor CURSOR FOR


select ID, Source_Sever, Source_Database, Dest_Database, Dest_Schema, Dest_Table
from Configuration.stg.ProdToSTG t
where t.Active=1  and t.TableIsCreated=1 and t.ID not in (select distinct c.ProdToSTG_ID from [Configuration].stg.StgTableColumn c where c.Active=1)
 

 
OPEN Config_Cursor;

 
FETCH NEXT FROM Config_Cursor INTO @ID, @Source_Sever, @Source_Database,  @Dest_Database, @Dest_Schema, @Dest_Table;

 
WHILE @@FETCH_STATUS = 0
BEGIN 
begin
 
 
exec [stg].[pr_insert_StgTableColumn] @source_server=@Source_Sever, @source_db=@Source_Database,  @dest_db=@Dest_Database,  @dest_scm =@Dest_Schema,  @dest_tbl =@Dest_Table
print(concat('ID:',@ID,' Source_Sever:',@Source_Sever,' Source_Database:',' Source_Database:',@Source_Database,' dest: ',@Dest_Database,'.',@Dest_Schema,'.',@Dest_Table))

end

 
 
FETCH NEXT FROM Config_Cursor INTO  @ID, @Source_Sever, @Source_Database,  @Dest_Database, @Dest_Schema, @Dest_Table;
END;

 
CLOSE Config_Cursor;
DEALLOCATE Config_Cursor;

end
GO
