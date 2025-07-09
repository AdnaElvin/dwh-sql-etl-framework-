USE [Configuration]
GO
 

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stg].[ProdToSTG](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Source_Sever] [nvarchar](max) NULL,
	[Source_Database] [nvarchar](max) NULL,
	[Source_Schema] [nvarchar](max) NULL,
	[Source_Table] [nvarchar](max) NULL,
	[Dest_Server] [nvarchar](max) NULL,
	[Dest_Database] [nvarchar](max) NULL,
	[Dest_Schema] [nvarchar](max) NULL,
	[Dest_Table] [nvarchar](max) NULL,
	[Create_Columns] [nvarchar](max) NULL,
	[Create_SQL] [nvarchar](max) NULL,
	[Note] [nvarchar](max) NULL,
	[Exec_type] [nvarchar](max) NULL,
	[TableCreatedDate] [datetime] NULL,
	[TableChekSumByte] [bigint] NULL,
	[TableCheckSumByte_CheckTime] [datetime] NULL,
	[TableCheckSumByte_UpdateTime] [datetime] NULL,
	[TableType] [nvarchar](max) NULL,
	[ColumnIsChange] [bit] NULL,
	[ColumnChangeTime] [datetime] NULL,
	[LastExecTime] [datetime] NULL,
	[FirstLoadTime] [datetime] NULL,
	[CreateDate] [datetime] NULL,
	[TableIsCreated] [bit] NULL,
	[Active] [bit] NULL,
	[StartTime] [datetime2](7) GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
	[EndTime] [datetime2](7) GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
 CONSTRAINT [PK_ProdToSTGv1] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([StartTime], [EndTime])
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [stg].[ProdToSTG_History])
)
GO
