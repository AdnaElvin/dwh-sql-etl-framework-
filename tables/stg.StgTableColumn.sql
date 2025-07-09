USE [Configuration]
GO
 
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stg].[StgTableColumn](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ProdToSTG_ID] [int] NULL,
	[Description_] [nvarchar](max) NULL,
	[Dest_Column] [nvarchar](max) NULL,
	[Source_Column] [nvarchar](max) NULL,
	[Column_RN] [int] NULL,
	[IsString] [bit] NULL,
	[Column_Type_ID] [int] NULL,
	[Column_Type] [nvarchar](max) NULL,
	[CreateDate] [datetime] NULL,
	[ModifyDate] [datetime] NULL,
	[Active] [bit] NOT NULL,
	[StartTime] [datetime2](7) GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
	[EndTime] [datetime2](7) GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
 CONSTRAINT [PK_StgTableColumn] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([StartTime], [EndTime])
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [stg].[StgTableColumn_History])
)
GO

ALTER TABLE [stg].[StgTableColumn] ADD  CONSTRAINT [DF_StgTableColumn_Active]  DEFAULT ((1)) FOR [Active]
GO
