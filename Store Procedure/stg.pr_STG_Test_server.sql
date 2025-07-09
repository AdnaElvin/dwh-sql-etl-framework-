USE [Configuration]
GO
 
CREATE proc [stg].[pr_STG_Test_server] as
begin

exec  [stg].[pr_ProdToSTG_create_table] @pr_type='update_script'         
exec  [stg].[pr_ProdToSTG_create_table] @pr_type='create_table'

exec [stg].[pr_insert_StgTableColumn_Exec]


exec [Configuration].[stg].[pr_ProdToSTG_SCD_Standart] @src_server='test_server' @src_DB='production1'
exec [Configuration].[stg].[pr_ProdToSTG_SCD_Standart] @src_server='test_server' @src_DB='production2'


end
GO
