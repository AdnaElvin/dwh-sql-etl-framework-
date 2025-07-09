USE [Configuration]
GO
 
create procedure [stg].[pr_ProdToSTG_create_table_SERVER_A](

--bu prosedur sourec cədvəlinin, sütunlarını və cədvəli yaratmaq üçün script qaytarır/
--- cədvəldəki bütün sütunlar  qayıdır.
-- istifadə etdiyi link serverdir. link serverin İP-si [SERVER_A] 


  @source_db nvarchar(max)
, @source_scm nvarchar(max)
, @source_tbl nvarchar(max)

, @dest_db nvarchar(max)
, @dest_scm nvarchar(max)
, @dest_tbl nvarchar(max)
, @q_typ int
, @t nvarchar(max) OUTPUT



 

--declare @q_typ int=1 -- 0 cədvəl, 1 sütun

 )  as 

begin



declare @q  nvarchar(max)=''
declare @q1 nvarchar(max)=''



set @q1=isnull((
SELECT
concat(' 
 declare @q2 nvarchar(max)=(

SELECT STUFF(
(SELECT '' '' + txt
from (select 
  concat(t.db, ''.'', t.scm, ''.'', t.tbl) src
, concat(t.clm, '' '', t.typ,  t.is_nullable,  iif(t.mx_column_id=t.column_id,'''',char(10)+'','')) txt 
, t.column_id
  from 
(select concat(''['',case when c.name=''ENDDATE'' then ''ENDDATE_'' when c.name=''STARTDATE'' then ''STARTDATE_'' when c.name=''ISCURRENT''  then ''ISCURRENT_'' else c.name end,'']'') clm
, iif( st.xprec=0, concat(    case when st.name=''varchar'' then ''nvarchar'' when st.name=''char'' then ''nchar'' else st.name end  , ''('', c.max_length/(st.length/st.prec),'')'') , st.name) typ 
, ''',@source_db,''' db
, concat(''['',s.name,'']'') scm
, concat(''['',t.name,'']'') tbl
, iif(c.is_nullable=1, '' NULL'', '' NOT NULL'') is_nullable
, c.column_id
, isnull(max(c.column_id) over(),0) mx_column_id
from       [SERVER_A].',@source_db,'.sys.tables t
inner join [SERVER_A].',@source_db,'.sys.schemas s on s.schema_id=t.schema_id
inner join [SERVER_A].',@source_db,'.sys.all_columns c on c.object_id=t.object_id
inner join [SERVER_A].',@source_db,'.sys.systypes st on st.xusertype=c.user_type_id 
where t.name in (''',@source_tbl,''')
 

) t
) t
order by t.column_id
FOR XML PATH('''')), 1, 1, '''') AS B


)
 
 

select @OutputResult =     concat(''use ',@dest_db+char(10)+char(10),' CREATE TABLE [',@dest_scm,'].[',@dest_tbl,'] ('', char(10)+char(32)+char(32) 
, ''[',@dest_tbl,'_KEY]''  , ''  [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL '', char(10),'', ''
,  @q2, char(10) 
,'', [StartDate] datetime NULL
, [EndDate] datetime NULL
, [IsCurrent] bit  
) ON [PRIMARY]

 
ALTER TABLE [',@dest_scm,'].[',@dest_tbl,'] ADD  CONSTRAINT [DF_',@dest_tbl,'_StartDate]  DEFAULT (getdate()) FOR [StartDate]

 
ALTER TABLE [',@dest_scm,'].[',@dest_tbl,'] ADD  CONSTRAINT [DF_',@dest_tbl,'_IsCurrent]  DEFAULT ((1)) FOR [IsCurrent]

'')  

 
'
) B
),'')


 


 

declare  @q3 nvarchar(max)=''
set @q3=

concat(' 
 declare @q4 nvarchar(max)=(
 SELECT STUFF(
(SELECT '',''+case when clm=''[ENDDATE]'' then ''[ENDDATE_]'' when clm=''[STARTDATE]'' then ''[STARTDATE_]'' when clm=''[ISCURRENT]''  then ''[ISCURRENT_]'' else clm end from  (',
STUFF(
(SELECT ' ' + txt
 from 
(select column_id,   concat('select ',t.column_id,' clm_id, isnull(count(distinct [',t.clm,']),0) cnt, N''[', t.clm,']'' clm, N''', t.scm, '.', t.tbl,''' tbl from [172.26.2.50].', t.db, '.', t.scm, '.', t.tbl, '  ', iif(column_id=mx_column_id,'','union all')) txt 
 from 
(

select *
from (
select   c.name clm
, iif( st.xprec=0, concat(st.name, '(', c.max_length/(st.length/st.prec),')') , st.name) typ 
, 'STP_Group' db , concat('[',s.name,']') scm , concat('[',t.name,']') tbl
, iif(c.is_nullable=1, ' NULL,', ' NOT NULL,') is_nullable
, c.column_id , isnull(max(c.column_id)over(),0) mx_column_id
from      [SERVER_A].Production1.sys.tables t
left join [SERVER_A].Production1.sys.schemas s on s.schema_id=t.schema_id
left join [SERVER_A].Production1.sys.all_columns c on c.object_id=t.object_id
left join [SERVER_A].Production1.sys.systypes st on st.xusertype=c.user_type_id 
where  t.name =@source_tbl and s.name=@source_scm
) t where t.db=@source_db

union all

select *
from (
select   c.name clm
, iif( st.xprec=0, concat(st.name, '(', c.max_length/(st.length/st.prec),')') , st.name) typ 
, 'STP_GBCable' db , concat('[',s.name,']') scm , concat('[',t.name,']') tbl
, iif(c.is_nullable=1, ' NULL,', ' NOT NULL,') is_nullable
, c.column_id , isnull(max(c.column_id)over(),0) mx_column_id
from      [SERVER_A].Production2.sys.tables t
left join [SERVER_A].Production2.sys.schemas s on s.schema_id=t.schema_id
left join [SERVER_A].Production2.sys.all_columns c on c.object_id=t.object_id
left join [SERVER_A].Production2.sys.systypes st on st.xusertype=c.user_type_id 
where  t.name =@source_tbl and s.name=@source_scm
) t where t.db=@source_db

 

) t

)t
order by t.column_id   
FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '') 
,'  ) t

order by t.clm_id 
FOR XML PATH('''')), 1, 1, '''') AS B
)

 
select @OutputResult =  (replace(@q4,'','', char(13)+'' ,'')) 
'
) 


set @q=(select iif(@q_typ=0,@q1,@q3))

EXEC sp_executesql      @q,  N'@OutputResult NVARCHAR(MAX) OUTPUT', @OutputResult = @t OUTPUT;
end
GO
