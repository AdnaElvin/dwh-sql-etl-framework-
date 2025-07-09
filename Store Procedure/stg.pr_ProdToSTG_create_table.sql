USE [Configuration]
GO
 
CREATE proc [stg].[pr_ProdToSTG_create_table](@pr_type nvarchar(max))
as
begin

--Declare @pr_type nvarchar(max)=''
--    'update_script': create script və  columları ProdToSTG cədvəlində update et
--    'create_table': ilk dəfə, əgər cədvəl yaradılmayıbsa. cədvəlləri yarat.    
 
--exec  [stg].[pr_ProdToSTG_create_table] @pr_type='update_script'
--exec  [stg].[pr_ProdToSTG_create_table] @pr_type='create_table'


 
-----------------

------------ digər dəyişənlər
 declare @out_txt_create nvarchar(max) 
 declare @out_txt_column nvarchar(max) 

------------------
 
------------  ProdToSTG cədvəlinin sütunları
 declare @ID							 int
 declare @Source_Sever					 nvarchar(max)
 declare @Source_Database				 nvarchar(max)
 declare @Source_Schema					 nvarchar(max)
 declare @Source_Table					 nvarchar(max)
 declare @Dest_Server					 nvarchar(max)
 declare @Dest_Database					 nvarchar(max)
 declare @Dest_Schema					 nvarchar(max)
 declare @Dest_Table					 nvarchar(max)
 declare @Create_Columns				 nvarchar(max)
 declare @Create_SQL					 nvarchar(max)
 declare @Note							 nvarchar(max)
 declare @Exec_type						 nvarchar(max)
 declare @TableCreatedDate				 datetime
 declare @TableChekSumByte				 bigint
 declare @TableCheckSumByte_CheckTime	 datetime
 declare @TableCheckSumByte_UpdateTime	 datetime 
 declare @TableType						 nvarchar(max)
 declare @ColumnIsChange				 bit
 declare @ColumnChangeTime				 datetime
 declare @LastExecTime					 datetime
 declare @FirstLoadTime					 datetime
 declare @CreateDate					 datetime
 declare @TableIsCreated				 bit
 declare @Active						 bit
 ---------------------------------------------------end

 

DECLARE Config_Cursor CURSOR FOR

select ID, Source_Sever, Source_Database, Source_Schema, Source_Table, Dest_Server, Dest_Database, Dest_Schema, Dest_Table, Create_Columns, Create_SQL, Note, Exec_type, TableCreatedDate, TableChekSumByte, TableCheckSumByte_CheckTime, TableCheckSumByte_UpdateTime, TableType, ColumnIsChange, ColumnChangeTime, LastExecTime, FirstLoadTime, CreateDate, TableIsCreated, Active					 
from Configuration.stg.ProdToSTG t
where t.Active=1  and t.TableIsCreated=0  
 
OPEN Config_Cursor;

FETCH NEXT FROM Config_Cursor INTO @ID, @Source_Sever, @Source_Database, @Source_Schema, @Source_Table, @Dest_Server, @Dest_Database, @Dest_Schema, @Dest_Table, @Create_Columns, @Create_SQL, @Note, @Exec_type, @TableCreatedDate, @TableChekSumByte, @TableCheckSumByte_CheckTime, @TableCheckSumByte_UpdateTime, @TableType, @ColumnIsChange, @ColumnChangeTime, @LastExecTime, @FirstLoadTime, @CreateDate, @TableIsCreated, @Active
WHILE @@FETCH_STATUS = 0
BEGIN
 
 

 -- 0 cədvəl, 1 sütun
 if(@pr_type='update_script')
 begin
 
if(@Source_Sever='server_a')
begin 
 
 exec  stg.pr_ProdToSTG_create_table_query_SERVER_A @source_db=@Source_Database, @source_scm=@Source_Schema, @source_tbl=@Source_Table, @dest_db=@Dest_Database, @dest_scm=@Dest_Schema, @dest_tbl=@Dest_Table, @q_typ=0, @t = @out_txt_create OUTPUT;
 exec  stg.pr_ProdToSTG_create_table_query_SERVER_A @source_db=@Source_Database, @source_scm=@Source_Schema, @source_tbl=@Source_Table, @dest_db=@Dest_Database, @dest_scm=@Dest_Schema, @dest_tbl=@Dest_Table, @q_typ=1, @t = @out_txt_column OUTPUT;

end

if(@Source_Sever='server_b')
begin 
 exec  stg.pr_ProdToSTG_create_table_query_SERVER_B @source_db=@Source_Database, @source_scm=@Source_Schema, @source_tbl=@Source_Table, @dest_db=@Dest_Database, @dest_scm=@Dest_Schema, @dest_tbl=@Dest_Table, @q_typ=0, @t = @out_txt_create OUTPUT;
 exec  stg.pr_ProdToSTG_create_table_query_SERVER_B @source_db=@Source_Database, @source_scm=@Source_Schema, @source_tbl=@Source_Table, @dest_db=@Dest_Database, @dest_scm=@Dest_Schema, @dest_tbl=@Dest_Table, @q_typ=1, @t = @out_txt_column OUTPUT;

end


if(@Source_Sever='server_test')
begin 
 exec  stg.pr_ProdToSTG_create_table_query_SERVER_TEST @source_db=@Source_Database, @source_scm=@Source_Schema, @source_tbl=@Source_Table, @dest_db=@Dest_Database, @dest_scm=@Dest_Schema, @dest_tbl=@Dest_Table, @q_typ=0, @t = @out_txt_create OUTPUT;
 exec  stg.pr_ProdToSTG_create_table_query_SERVER_TEST @source_db=@Source_Database, @source_scm=@Source_Schema, @source_tbl=@Source_Table, @dest_db=@Dest_Database, @dest_scm=@Dest_Schema, @dest_tbl=@Dest_Table, @q_typ=1, @t = @out_txt_column OUTPUT;

end




if(@out_txt_create<>isnull(@Create_SQL, '') or @out_txt_column<>isnull(@Create_Columns,''))
begin
 

update t
set t.Create_Columns=@out_txt_column , t.Create_SQL=@out_txt_create
from [Configuration].stg.ProdToSTG t
where t.ID=@ID

print(concat(N'Cədvəl update edildi [',@Dest_Database,'].[',@Dest_Schema,'].[',@Dest_Table,']'))
end
else
begin

print(concat(N'Cədvəldə sütunlarda heç nə dəyişməyib: [',@Dest_Database,'].[',@Dest_Schema,'].[',@Dest_Table,']'))

end

 
 end

 if(@pr_type='create_table' and @TableIsCreated=0)
 begin
---- declare @q2 nvarchar(max)=concat('drop table if exists  [',@Dest_Database,'].[',@Dest_Schema,'].[',@Dest_Table,']')
 

 declare @cedvel_say int=(
 select count(*) say
 from (
 select 'STG' db, s.name sc, t.name tb
 from STG.sys.tables t
 inner join STG.sys.schemas s on s.schema_id=t.schema_id
 
 ) t
 where t.db=@Dest_Database and t.sc=@Dest_Schema and t.tb=@Dest_Table
 )
 if(@cedvel_say=0)
	 begin


	  exec(@Create_SQL)
	  
	  update z
	  set z.TableCreatedDate=getdate(), z.TableIsCreated=1
	  from stg.ProdToSTG z
	  where  z.ID=@ID


	 print(concat(N'Cədvəl yaradıldı: [',@Dest_Database,'].[',@Dest_Schema,'].[',@Dest_Table,']'))

	 end
 else 


	 begin
	 print(N'Cədvəl bazada var')
	 end

 end




FETCH NEXT FROM Config_Cursor INTO  @ID, @Source_Sever, @Source_Database, @Source_Schema, @Source_Table, @Dest_Server, @Dest_Database, @Dest_Schema, @Dest_Table, @Create_Columns, @Create_SQL, @Note, @Exec_type, @TableCreatedDate, @TableChekSumByte, @TableCheckSumByte_CheckTime, @TableCheckSumByte_UpdateTime, @TableType, @ColumnIsChange, @ColumnChangeTime, @LastExecTime, @FirstLoadTime, @CreateDate, @TableIsCreated, @Active
END;
 
CLOSE Config_Cursor;
DEALLOCATE Config_Cursor;


end

GO
