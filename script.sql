USE [IRPortal_20200107]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetConfigValue]    Script Date: 1/23/2020 10:14:45 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fnGetConfigValue]
(
 @Section nvarchar(50),
 @Key nvarchar(50)
)
returns nvarchar(1000)
as
begin
 declare @Value nvarchar(1000)
 select @Value = Value 
 from Config
 where Section = @Section and [Key] = @Key
 return @Value
end
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetEmailAdress]    Script Date: 1/23/2020 10:14:45 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================
-- Author       : Narendra Shrivastava
-- Create date  : 22-Feb-2016
-- Description  : Get Email addresses with domain name from string 
-- Parameters   : 
-- ==============================================================
CREATE FUNCTION [dbo].[fnGetEmailAdress](
   @emailString NVARCHAR(MAX)
) RETURNS @List TABLE (Email VARCHAR(100))

BEGIN
	DECLARE @EmailTable TABLE (emailString NVARCHAR(100));
		INSERT INTO @EmailTable
		SELECT item + 'insightresults.com' FROM dbo.fnSplit(@emailString, 'insightresults.com')

	INSERT INTO @List
		SELECT         
        CASE
            WHEN CHARINDEX('@',emailString) = 0 THEN NULL
            --ELSE SUBSTRING(emailString,beginningOfEmail,endOfEmail-beginningOfEmail)
			ELSE dbo.fnStripCharacters(SUBSTRING(emailString,beginningOfEmail,endOfEmail-beginningOfEmail),'^a-z0-9_.@')
        END Email
		FROM @EmailTable
		CROSS APPLY (SELECT CHARINDEX(' ',emailString + ' ',CHARINDEX('@',emailString))) AS A(endOfEmail)
		CROSS APPLY (SELECT DATALENGTH(emailString)/2 - CHARINDEX(' ',REVERSE(' ' + emailString),CHARINDEX('@',REVERSE(' ' + emailString))) + 2) AS B(beginningOfEmail)
		RETURN
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetNumericInAlphaNumeric]    Script Date: 1/23/2020 10:14:45 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fnGetNumericInAlphaNumeric]
(@strAlphaNumeric VARCHAR(256))
RETURNS VARCHAR(256)
AS
BEGIN
DECLARE @intAlpha INT
SET @intAlpha = PATINDEX('%[^0-9]%', @strAlphaNumeric)
BEGIN
WHILE @intAlpha > 0
BEGIN
SET @strAlphaNumeric = STUFF(@strAlphaNumeric, @intAlpha, 1, '' )
SET @intAlpha = PATINDEX('%[^0-9]%', @strAlphaNumeric )
END
END
RETURN ISNULL(@strAlphaNumeric,0)
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetTaskCurrentEstimate]    Script Date: 1/23/2020 10:14:45 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================
-- Author       : Ram Pujan
-- Create date  : 22-Apr-2016
-- Description  : Get Task Current Estimate time 
-- Parameters   : 
-- ==============================================================
CREATE FUNCTION [dbo].[fnGetTaskCurrentEstimate]
(
    @OriginalEstimate int,
    @TimeSpent int,
    @RemainingEstimate int
)
RETURNS INT
AS
BEGIN
    return        
        case when @RemainingEstimate is null then case when isnull(@OriginalEstimate,0) >= isnull(@TimeSpent,0) then isnull(@OriginalEstimate,0) else isnull(@TimeSpent,0) end
        else isnull(@TimeSpent,0) + @RemainingEstimate end
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnSplit]    Script Date: 1/23/2020 10:14:45 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fnSplit](
    @sInputList VARCHAR(MAX) -- List of delimited items
  , @sDelimiter VARCHAR(8000) = ',' -- delimiter that separates items
) RETURNS @List TABLE (item VARCHAR(8000))

BEGIN
DECLARE @sItem VARCHAR(8000)
WHILE CHARINDEX(@sDelimiter,@sInputList,0) <> 0
 BEGIN
 SELECT
  @sItem=RTRIM(LTRIM(SUBSTRING(@sInputList,1,CHARINDEX(@sDelimiter,@sInputList,0)-1))),
  @sInputList=RTRIM(LTRIM(SUBSTRING(@sInputList,CHARINDEX(@sDelimiter,@sInputList,0)+LEN(@sDelimiter),LEN(@sInputList))))
 
 IF LEN(@sItem) > 0
  INSERT INTO @List SELECT @sItem
 END

IF LEN(@sInputList) > 0
 INSERT INTO @List SELECT @sInputList -- Put the last item in
RETURN
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnStripCharacters]    Script Date: 1/23/2020 10:14:45 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================
-- Author       : Narendra Shrivastava
-- Create date  : 26-Feb-2016
-- Description  : Get string with desired characters set only 
-- Parameters   : 
-- ==============================================================
CREATE FUNCTION [dbo].[fnStripCharacters]
(
    @String NVARCHAR(MAX), 
    @MatchExpression VARCHAR(255)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    SET @MatchExpression =  '%['+@MatchExpression+']%'

    WHILE PatIndex(@MatchExpression, @String) > 0
        SET @String = Stuff(@String, PatIndex(@MatchExpression, @String), 1, '')

    RETURN @String

END
GO
/****** Object:  UserDefinedFunction [dbo].[getNextBuildNumber]    Script Date: 1/23/2020 10:14:45 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create FUNCTION [dbo].[getNextBuildNumber]
(
	@ComponentId UNIQUEIDENTIFIER
)
RETURNS VARCHAR(50)
AS
BEGIN
    DECLARE @MaxVal INT 
    DECLARE @BuildNumber VARCHAR(50)
    
    SET @MaxVal = (
            SELECT MAX( CAST( SUBSTRING(NAME,2,LEN(NAME))AS INT)) + 1 
            FROM   DBbuild WHERE ComponentId=@ComponentId
        )
    
       
    IF @MaxVal IS NULL
        SET @MaxVal = 1
        
    IF (LEN(@MaxVal)<3)
		BEGIN
    		SET @BuildNumber='B'+RIGHT('00'+CONVERT(VARCHAR(10) ,@MaxVal) ,3)
		END	
    ELSE
    	BEGIN
    		SET @BuildNumber='B'+CAST(@MaxVal AS VARCHAR)
    	END
  
    RETURN @BuildNumber
END
GO
/****** Object:  Table [dbo].[Attachment]    Script Date: 1/23/2020 10:14:45 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Attachment](
	[AttachmentId] [uniqueidentifier] NULL,
	[EntityType] [int] NULL,
	[EntityId] [uniqueidentifier] NULL,
	[FileName] [nvarchar](250) NULL,
	[ContentType] [nvarchar](250) NULL,
	[ContentLength] [int] NULL,
	[FileContent] [varbinary](max) NULL,
	[UploadedBy] [uniqueidentifier] NULL,
	[UploadedOn] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[vwAttachmentCount]    Script Date: 1/23/2020 10:14:45 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Sanjay Singh Pawar
-- Create date: 07 Aug 2015
-- Description:	vwAttachmentCount with the help to count Attachment per task
-- =============================================
CREATE VIEW [dbo].[vwAttachmentCount]
AS
SELECT        EntityId, EntityType, COUNT(EntityId) AS AttchmentCount
FROM            dbo.Attachment AS a
GROUP BY EntityId, EntityType
GO
/****** Object:  Table [dbo].[Comment]    Script Date: 1/23/2020 10:14:45 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Comment](
	[CommentId] [uniqueidentifier] NOT NULL,
	[EntityType] [int] NOT NULL,
	[EntityId] [uniqueidentifier] NOT NULL,
	[Comment] [varchar](max) NOT NULL,
	[CreatedBy] [uniqueidentifier] NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[ModifiedBy] [uniqueidentifier] NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [pk_Comment] PRIMARY KEY CLUSTERED 
(
	[CommentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[vwCountComment]    Script Date: 1/23/2020 10:14:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Sanjay Singh Pawar
-- Create date: 07 Aug 2015
-- Description:	vwCountComment with the help to count Attachment per task
-- =============================================
CREATE VIEW [dbo].[vwCountComment]
AS
SELECT EntityId, EntityType, COUNT(EntityId) AS CountComment
FROM   dbo.Comment AS c
GROUP BY EntityId, EntityType
GO
/****** Object:  Table [dbo].[VersionChange]    Script Date: 1/23/2020 10:14:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VersionChange](
	[VersionChangeId] [uniqueidentifier] NOT NULL,
	[VersionId] [uniqueidentifier] NULL,
	[Reference] [nvarchar](50) NULL,
	[FileChanges] [nvarchar](2000) NULL,
	[DBChanges] [nvarchar](2000) NULL,
	[Description] [nvarchar](4000) NULL,
	[ChangedBy] [nvarchar](50) NULL,
	[ChangedOn] [datetime] NULL,
	[QAStatus] [int] NULL,
	[CreatedOn] [datetime] NULL,
	[CreatedBy] [uniqueidentifier] NULL,
PRIMARY KEY CLUSTERED 
(
	[VersionChangeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vwTaskQAStatus]    Script Date: 1/23/2020 10:14:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =====================================================
-- Author       : Ram Pujan
-- Create date  : 28-Apr-2016
-- Description  : Get Version's task QA status
-- =====================================================
CREATE VIEW [dbo].[vwTaskQAStatus]
AS
    WITH cteQAStatus AS 
    ( 
     SELECT VersionId,Reference,CreatedOn,QAStatus, 
         ROW_NUMBER() OVER 
         ( 
             PARTITION BY Reference
             ORDER BY ChangedOn DESC 
         ) AS RN 
     FROM VersionChange 
    ) 
    SELECT VersionId,Reference,CreatedOn,QAStatus 
    FROM cteQAStatus 
    WHERE RN = 1 and (Reference is not null or NULLIF(Reference, '') is not null)
GO
/****** Object:  Table [dbo].[Activity]    Script Date: 1/23/2020 10:14:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Activity](
	[ActivityId] [uniqueidentifier] NOT NULL,
	[EntityType] [int] NOT NULL,
	[EntityId] [uniqueidentifier] NOT NULL,
	[Description] [varchar](100) NOT NULL,
	[CommentId] [uniqueidentifier] NULL,
	[IsInternal] [bit] NOT NULL,
	[CreatedBy] [uniqueidentifier] NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[ActivityType] [int] NULL,
 CONSTRAINT [pk_Activity] PRIMARY KEY CLUSTERED 
(
	[ActivityId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AspNetRoles]    Script Date: 1/23/2020 10:14:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetRoles](
	[Id] [nvarchar](128) NOT NULL,
	[Name] [nvarchar](256) NOT NULL,
 CONSTRAINT [PK_dbo.AspNetRoles] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AspNetUserClaims]    Script Date: 1/23/2020 10:14:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUserClaims](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [nvarchar](128) NOT NULL,
	[ClaimType] [nvarchar](max) NULL,
	[ClaimValue] [nvarchar](max) NULL,
 CONSTRAINT [PK_dbo.AspNetUserClaims] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AspNetUserLogins]    Script Date: 1/23/2020 10:14:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUserLogins](
	[LoginProvider] [nvarchar](128) NOT NULL,
	[ProviderKey] [nvarchar](128) NOT NULL,
	[UserId] [nvarchar](128) NOT NULL,
 CONSTRAINT [PK_dbo.AspNetUserLogins] PRIMARY KEY CLUSTERED 
(
	[LoginProvider] ASC,
	[ProviderKey] ASC,
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AspNetUserRoles]    Script Date: 1/23/2020 10:14:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUserRoles](
	[UserId] [nvarchar](128) NOT NULL,
	[RoleId] [nvarchar](128) NOT NULL,
 CONSTRAINT [PK_dbo.AspNetUserRoles] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AspNetUsers]    Script Date: 1/23/2020 10:14:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUsers](
	[Id] [nvarchar](128) NOT NULL,
	[Email] [nvarchar](256) NULL,
	[EmailConfirmed] [bit] NOT NULL,
	[PasswordHash] [nvarchar](max) NULL,
	[SecurityStamp] [nvarchar](max) NULL,
	[PhoneNumber] [nvarchar](max) NULL,
	[PhoneNumberConfirmed] [bit] NOT NULL,
	[TwoFactorEnabled] [bit] NOT NULL,
	[LockoutEndDateUtc] [datetime] NULL,
	[LockoutEnabled] [bit] NOT NULL,
	[AccessFailedCount] [int] NOT NULL,
	[UserName] [nvarchar](256) NOT NULL,
	[FirstName] [nvarchar](max) NULL,
	[LastName] [nvarchar](max) NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_dbo.AspNetUsers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Attendance]    Script Date: 1/23/2020 10:14:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Attendance](
	[AttendanceId] [uniqueidentifier] NOT NULL,
	[EmployeeId] [uniqueidentifier] NOT NULL,
	[AttendanceDate] [datetime] NOT NULL,
	[Attendance] [decimal](2, 1) NOT NULL,
	[InTime] [datetime] NULL,
	[OutTime] [datetime] NULL,
	[IsWorkFromHome] [bit] NOT NULL,
	[TimeInMinutes] [int] NULL,
	[Remarks] [nvarchar](255) NULL,
	[CreatedBy] [nvarchar](50) NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedBy] [nvarchar](50) NULL,
	[ModifiedOn] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Client]    Script Date: 1/23/2020 10:14:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Client](
	[ClientId] [uniqueidentifier] NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[Code] [varchar](20) NOT NULL,
	[Status] [int] NOT NULL,
	[CreatedBy] [uniqueidentifier] NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[ModifiedBy] [uniqueidentifier] NULL,
	[ModifiedOn] [datetime] NULL,
	[S3BucketName] [varchar](50) NULL,
 CONSTRAINT [pk_Client] PRIMARY KEY CLUSTERED 
(
	[ClientId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Component]    Script Date: 1/23/2020 10:14:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Component](
	[ComponentId] [uniqueidentifier] NOT NULL,
	[ProjectId] [uniqueidentifier] NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[CreatedBy] [uniqueidentifier] NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[ModifiedBy] [uniqueidentifier] NULL,
	[ModifiedOn] [datetime] NULL,
	[JiraComponentId] [int] NULL,
	[IsDBComponent] [bit] NULL,
	[IsVersionComponent] [bit] NULL,
	[GitUrl] [nvarchar](100) NULL,
	[BuildPrefixForConfig] [nvarchar](50) NULL,
 CONSTRAINT [PK_Component] PRIMARY KEY CLUSTERED 
(
	[ComponentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Config]    Script Date: 1/23/2020 10:14:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Config](
	[ConfigID] [uniqueidentifier] NOT NULL,
	[Section] [nvarchar](50) NOT NULL,
	[Key] [nvarchar](50) NOT NULL,
	[Value] [nvarchar](1000) NOT NULL,
 CONSTRAINT [PK_Config] PRIMARY KEY CLUSTERED 
(
	[ConfigID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Container]    Script Date: 1/23/2020 10:14:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Container](
	[ContainerId] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](250) NULL,
	[IsDeleted] [bit] NOT NULL,
	[Folders] [nvarchar](max) NULL,
 CONSTRAINT [PK_Container] PRIMARY KEY CLUSTERED 
(
	[ContainerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DataColumn]    Script Date: 1/23/2020 10:14:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DataColumn](
	[DataColumnId] [uniqueidentifier] NOT NULL,
	[DataTableId] [uniqueidentifier] NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Description] [varchar](max) NULL,
	[Mandatory] [bit] NULL,
	[DataType] [varchar](20) NULL,
	[DataLength] [int] NULL,
	[Precision] [int] NULL,
	[IsForeignKey] [bit] NULL,
	[MinValue] [varchar](100) NULL,
	[MaxValue] [varchar](100) NULL,
	[DistinctValues] [varchar](max) NULL,
	[DistinctValueCount] [int] NULL,
	[CreatedBy] [uniqueidentifier] NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[ModifiedBy] [uniqueidentifier] NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [pk_DataColumn] PRIMARY KEY CLUSTERED 
(
	[DataColumnId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DataFile]    Script Date: 1/23/2020 10:14:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DataFile](
	[DataFileId] [uniqueidentifier] NOT NULL,
	[DataRequestId] [uniqueidentifier] NULL,
	[FileType] [int] NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[FileNumber] [int] NOT NULL,
	[Description] [varchar](max) NULL,
	[Path] [varchar](250) NULL,
	[Source] [varchar](250) NULL,
	[SQLQuery] [varchar](max) NULL,
	[Status] [int] NOT NULL,
	[CreatorContactInfo] [varchar](250) NULL,
	[FileUploaded] [bit] NULL,
	[UploadedBy] [uniqueidentifier] NULL,
	[UploadedOn] [datetime] NULL,
	[OwnerId] [uniqueidentifier] NULL,
	[CreatedBy] [uniqueidentifier] NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[ModifiedBy] [uniqueidentifier] NULL,
	[ModifiedOn] [datetime] NULL,
	[ClientId] [uniqueidentifier] NOT NULL,
	[CleaningProcess] [varchar](max) NULL,
 CONSTRAINT [pk_DataFile] PRIMARY KEY CLUSTERED 
(
	[DataFileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DataRequest]    Script Date: 1/23/2020 10:14:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DataRequest](
	[DataRequestId] [uniqueidentifier] NOT NULL,
	[ClientId] [uniqueidentifier] NOT NULL,
	[RequestNumber] [int] NOT NULL,
	[RequestDate] [datetime] NOT NULL,
	[RequestedByUserId] [uniqueidentifier] NULL,
	[AssignedToUserId] [uniqueidentifier] NULL,
	[Status] [int] NOT NULL,
	[Description] [varchar](max) NULL,
	[EstimatedDate] [datetime] NULL,
	[CreatedBy] [uniqueidentifier] NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[ModifiedBy] [uniqueidentifier] NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [pk_DataRequest] PRIMARY KEY CLUSTERED 
(
	[DataRequestId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DataTable]    Script Date: 1/23/2020 10:14:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DataTable](
	[DataTableId] [uniqueidentifier] NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[DBInfo] [varchar](100) NOT NULL,
	[DataFileId] [uniqueidentifier] NOT NULL,
	[OwnerId] [uniqueidentifier] NULL,
	[Description] [varchar](max) NULL,
	[RowCount] [int] NULL,
	[CreatedBy] [uniqueidentifier] NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[ModifiedBy] [uniqueidentifier] NULL,
	[ModifiedOn] [datetime] NULL,
	[ClientId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_DataTable] PRIMARY KEY CLUSTERED 
(
	[DataTableId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DBBuild]    Script Date: 1/23/2020 10:14:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DBBuild](
	[DBBuildId] [uniqueidentifier] NOT NULL,
	[ComponentId] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[IsLocked] [bit] NULL,
	[CreatedBy] [uniqueidentifier] NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[ModifiedBy] [uniqueidentifier] NULL,
	[ModifiedOn] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[DBBuildId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DBScript]    Script Date: 1/23/2020 10:14:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DBScript](
	[DBScriptId] [uniqueidentifier] NOT NULL,
	[DBBuildId] [uniqueidentifier] NOT NULL,
	[DBScriptType] [int] NOT NULL,
	[DBChangeType] [int] NULL,
	[Reference] [varchar](50) NULL,
	[Name] [varchar](50) NOT NULL,
	[Description] [varchar](max) NULL,
	[Script] [nvarchar](max) NULL,
	[Sequence] [int] NOT NULL,
	[CreatedBy] [uniqueidentifier] NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[ModifiedBy] [uniqueidentifier] NULL,
	[ModifiedOn] [datetime] NULL,
	[ChangedBy] [uniqueidentifier] NOT NULL,
	[ChangedOn] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[DBScriptId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DeploymentSite]    Script Date: 1/23/2020 10:14:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DeploymentSite](
	[DeploymentSiteId] [uniqueidentifier] NOT NULL,
	[ComponentId] [uniqueidentifier] NOT NULL,
	[SiteName] [nvarchar](100) NULL,
	[Status] [bit] NULL,
	[IsObsolete] [bit] NULL,
	[SiteLink] [nvarchar](100) NULL,
	[Server] [varchar](20) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DownloadFile]    Script Date: 1/23/2020 10:14:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DownloadFile](
	[DownloadFileId] [uniqueidentifier] NOT NULL,
	[Folder] [nvarchar](500) NULL,
	[File] [nvarchar](250) NULL,
PRIMARY KEY CLUSTERED 
(
	[DownloadFileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EmailTemplate]    Script Date: 1/23/2020 10:14:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmailTemplate](
	[EmailTemplateId] [uniqueidentifier] NOT NULL,
	[TemplateName] [nvarchar](50) NOT NULL,
	[FromEmailId] [nvarchar](100) NOT NULL,
	[ToEmailId] [nvarchar](100) NOT NULL,
	[CCEmailId] [nvarchar](100) NULL,
	[Subject] [nvarchar](200) NOT NULL,
	[Body] [nvarchar](max) NULL,
	[Status] [int] NOT NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedOn] [datetime] NOT NULL,
	[ModifiedBy] [uniqueidentifier] NULL,
	[ModifiedOn] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Employee]    Script Date: 1/23/2020 10:14:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Employee](
	[EmployeeId] [uniqueidentifier] NOT NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[MiddleName] [nvarchar](50) NULL,
	[LastName] [nvarchar](50) NULL,
	[Designation] [nvarchar](50) NULL,
	[Gender] [nvarchar](1) NULL,
	[DateOfBirth] [datetime] NULL,
	[Anniversary] [datetime] NULL,
	[Remarks] [nvarchar](255) NULL,
	[CreatedBy] [nvarchar](50) NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedBy] [nvarchar](50) NULL,
	[ModifiedOn] [datetime] NULL,
	[DateOfJoining] [datetime] NULL,
	[DateOfRelieving] [datetime] NULL,
	[PanNo] [nvarchar](20) NULL,
	[FatherName] [nvarchar](100) NULL,
	[EmployeeType] [nvarchar](10) NULL,
	[BankDetail] [nvarchar](255) NULL,
	[OrignalDateOfBirth] [datetime] NULL,
	[MapStatus] [bit] NULL,
 CONSTRAINT [pk_Employee] PRIMARY KEY CLUSTERED 
(
	[EmployeeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Holiday]    Script Date: 1/23/2020 10:14:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Holiday](
	[HolidayDate] [datetime] NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Remarks] [nvarchar](255) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[JiraImport]    Script Date: 1/23/2020 10:14:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[JiraImport](
	[Project] [varchar](27) NULL,
	[Key] [varchar](9) NULL,
	[Summary] [varchar](199) NULL,
	[Issue Type] [varchar](11) NULL,
	[Status] [varchar](17) NULL,
	[Priority] [varchar](8) NULL,
	[Resolution] [varchar](16) NULL,
	[Assignee] [varchar](20) NULL,
	[Reporter] [varchar](20) NULL,
	[Creator] [varchar](20) NULL,
	[Created] [datetime] NULL,
	[Last Viewed] [datetime] NULL,
	[Updated] [datetime] NULL,
	[Resolved] [datetime] NULL,
	[Affects Version s] [varchar](max) NULL,
	[Fix Version s] [varchar](9) NULL,
	[Component] [varchar](22) NULL,
	[Due Date] [datetime] NULL,
	[Votes] [smallint] NULL,
	[Watchers] [smallint] NULL,
	[Images] [varchar](85) NULL,
	[Original Estimate] [int] NULL,
	[Remaining Estimate] [int] NULL,
	[Time Spent] [int] NULL,
	[Work Ratio] [varchar](20) NULL,
	[Sub-Tasks] [varchar](23) NULL,
	[Linked Issues] [varchar](max) NULL,
	[Environment] [varchar](182) NULL,
	[Description] [varchar](5171) NULL,
	[Security Level] [varchar](max) NULL,
	[Progress] [varchar](4) NULL,
	[? Progress] [varchar](4) NULL,
	[? Time Spent] [int] NULL,
	[? Remaining Estimate] [int] NULL,
	[? Original Estimate] [int] NULL,
	[Labels] [varchar](18) NULL,
	[Account] [varchar](4) NULL,
	[Business Value] [varchar](max) NULL,
	[Iteration] [varchar](4) NULL,
	[Rank (Obsolete)] [real] NULL,
	[Sprint] [varchar](149) NULL,
	[Test Sessions] [varchar](20) NULL,
	[Raised During] [varchar](20) NULL,
	[Epic Link] [varchar](19) NULL,
	[ CHART  Date of First Response] [datetime] NULL,
	[Epic Name] [varchar](19) NULL,
	[Flagged] [varchar](max) NULL,
	[Epic Status] [varchar](5) NULL,
	[Epic Theme] [varchar](max) NULL,
	[Rank] [varchar](20) NULL,
	[Epic Colour] [varchar](11) NULL,
	[Story Points] [varchar](max) NULL,
	[Team] [varchar](4) NULL,
	[Testing Status] [varchar](11) NULL,
	[Column 54] [smallint] NULL,
	[Column 55] [smallint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[JiraIssue]    Script Date: 1/23/2020 10:14:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[JiraIssue](
	[JiraIssueId] [int] NOT NULL,
	[IssueKey] [nvarchar](15) NULL,
	[IssueSummary] [nvarchar](250) NULL,
	[IssueType] [int] NULL,
	[ProjectId] [int] NULL,
	[Component] [int] NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[UpdatedDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[JiraIssueId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Leave]    Script Date: 1/23/2020 10:14:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Leave](
	[LeaveId] [uniqueidentifier] NOT NULL,
	[EmployeeId] [uniqueidentifier] NOT NULL,
	[LeaveDate] [datetime] NOT NULL,
	[LeaveType] [nvarchar](5) NULL,
	[LeaveCount] [decimal](2, 1) NOT NULL,
	[Remarks] [nvarchar](255) NULL,
	[CreatedBy] [nvarchar](50) NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedBy] [nvarchar](50) NULL,
	[ModifiedOn] [datetime] NULL,
	[IsApproved] [bit] NULL,
	[IsSecondHalf] [bit] NULL,
 CONSTRAINT [pk_Leave] PRIMARY KEY CLUSTERED 
(
	[LeaveId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[License]    Script Date: 1/23/2020 10:14:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[License](
	[LicenseId] [uniqueidentifier] NOT NULL,
	[ActivationKey] [varchar](512) NULL,
	[CrmOrganizationName] [varchar](128) NULL,
	[Product] [varchar](20) NOT NULL,
	[Edition] [varchar](10) NOT NULL,
	[Version] [varchar](10) NOT NULL,
	[Users] [int] NOT NULL,
	[Mode] [varchar](5) NOT NULL,
	[ExpiryDate] [date] NULL,
	[FirstName] [varchar](50) NOT NULL,
	[LastName] [varchar](50) NULL,
	[CompanyName] [varchar](128) NULL,
	[Email] [varchar](256) NULL,
 CONSTRAINT [PK_License] PRIMARY KEY CLUSTERED 
(
	[LicenseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Module]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Module](
	[ModuleId] [uniqueidentifier] NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[ParentModuleId] [uniqueidentifier] NULL,
	[PageURL] [varchar](max) NULL,
	[ClientId] [uniqueidentifier] NULL,
	[Description] [varchar](50) NULL,
	[Status] [int] NOT NULL,
	[CreatedBy] [uniqueidentifier] NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[ModifiedBy] [uniqueidentifier] NULL,
	[ModifiedOn] [datetime] NULL,
	[Sequence] [int] NULL,
 CONSTRAINT [pk_Module] PRIMARY KEY CLUSTERED 
(
	[ModuleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OffDay]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OffDay](
	[OffDayDate] [datetime] NOT NULL,
	[Remarks] [nvarchar](255) NULL,
 CONSTRAINT [pk_OffDay] PRIMARY KEY CLUSTERED 
(
	[OffDayDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Option]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Option](
	[OptionSetId] [uniqueidentifier] NOT NULL,
	[OptionValue] [int] NOT NULL,
	[OptionName] [varchar](50) NOT NULL,
	[Sequence] [int] NOT NULL,
	[CreatedBy] [uniqueidentifier] NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[ModifiedBy] [uniqueidentifier] NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_Option] PRIMARY KEY CLUSTERED 
(
	[OptionSetId] ASC,
	[OptionValue] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OptionSet]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OptionSet](
	[OptionSetId] [uniqueidentifier] NOT NULL,
	[EntityType] [int] NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[CreatedBy] [uniqueidentifier] NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[ModifiedBy] [uniqueidentifier] NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_OptionSet] PRIMARY KEY CLUSTERED 
(
	[OptionSetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Project]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Project](
	[ProjectId] [uniqueidentifier] NOT NULL,
	[ClientId] [uniqueidentifier] NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Code] [varchar](20) NOT NULL,
	[Status] [int] NULL,
	[Description] [varchar](max) NULL,
	[CreatedBy] [uniqueidentifier] NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[ModifiedBy] [uniqueidentifier] NULL,
	[ModifiedOn] [datetime] NULL,
	[JiraProjectId] [int] NULL,
 CONSTRAINT [pk_Project] PRIMARY KEY CLUSTERED 
(
	[ProjectId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProjectPermission]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProjectPermission](
	[ProjectPermissionId] [uniqueidentifier] NOT NULL,
	[ProjectId] [uniqueidentifier] NOT NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[Permission] [int] NOT NULL,
 CONSTRAINT [pk_ProjectPermissionId] PRIMARY KEY CLUSTERED 
(
	[ProjectPermissionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ReleaseNote]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReleaseNote](
	[ReleaseNoteId] [uniqueidentifier] NULL,
	[VersionId] [uniqueidentifier] NULL,
	[Reference] [nvarchar](10) NULL,
	[Type] [int] NULL,
	[Title] [nvarchar](500) NULL,
	[Remarks] [nvarchar](1000) NULL,
	[IsPublic] [bit] NULL,
	[Sequence] [int] NULL,
	[ReleaseNoteSummaryId] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ReleaseNoteSummary]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReleaseNoteSummary](
	[ReleaseNoteSummaryId] [uniqueidentifier] NOT NULL,
	[ComponentId] [uniqueidentifier] NOT NULL,
	[ReleaseDate] [datetime] NOT NULL,
	[ReleaseTitle] [nvarchar](250) NULL,
	[IsLocked] [bit] NULL,
	[CreatedBy] [uniqueidentifier] NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[ModifiedBy] [uniqueidentifier] NULL,
	[ModifiedOn] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Role]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Role](
	[RoleId] [uniqueidentifier] NOT NULL,
	[Name] [varchar](50) NOT NULL,
 CONSTRAINT [PK_Role] PRIMARY KEY CLUSTERED 
(
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SoftwareDownload]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SoftwareDownload](
	[SoftwareDownloadId] [uniqueidentifier] NOT NULL,
	[DownloadFileId] [uniqueidentifier] NULL,
PRIMARY KEY CLUSTERED 
(
	[SoftwareDownloadId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Status]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Status](
	[EntityType] [int] NOT NULL,
	[Status] [int] NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[CreatedBy] [uniqueidentifier] NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[ModifiedBy] [uniqueidentifier] NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [pk_Status] PRIMARY KEY CLUSTERED 
(
	[EntityType] ASC,
	[Status] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Task]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Task](
	[TaskId] [uniqueidentifier] NOT NULL,
	[ProjectId] [uniqueidentifier] NOT NULL,
	[Key] [nvarchar](30) NOT NULL,
	[Summary] [nvarchar](500) NOT NULL,
	[TaskType] [int] NOT NULL,
	[Status] [int] NOT NULL,
	[PriorityType] [int] NOT NULL,
	[ResolutionType] [int] NULL,
	[Assignee] [nvarchar](100) NULL,
	[Reporter] [nvarchar](100) NOT NULL,
	[ComponentId] [uniqueidentifier] NULL,
	[DueDate] [datetime] NULL,
	[OriginalEstimate] [int] NULL,
	[TimeSpent] [int] NULL,
	[RemainingEstimate] [int] NULL,
	[Description] [nvarchar](4000) NULL,
	[Area] [nvarchar](100) NULL,
	[Rank] [int] NULL,
	[CreatedBy] [uniqueidentifier] NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[ModifiedBy] [uniqueidentifier] NULL,
	[ModifiedOn] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[TaskId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UK_TaskKey] UNIQUE NONCLUSTERED 
(
	[Key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TaxSaving]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TaxSaving](
	[TaxSavingId] [uniqueidentifier] NOT NULL,
	[EmployeeId] [uniqueidentifier] NOT NULL,
	[FinancialYear] [int] NOT NULL,
	[TaxSavingType] [int] NOT NULL,
	[RecurringFrequency] [int] NOT NULL,
	[SavingDate] [date] NULL,
	[AccountNumber] [nvarchar](100) NOT NULL,
	[Amount] [decimal](8, 2) NULL,
	[ReceiptSubmitted] [bit] NULL,
	[Remarks] [nvarchar](100) NULL,
	[EligibleCount] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TaxSavingType]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TaxSavingType](
	[TaxSavingType] [int] NOT NULL,
	[TaxSavingTypeName] [nvarchar](100) NOT NULL,
	[TaxCategoryCode] [nvarchar](20) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Temp]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Temp](
	[IssueKey] [nvarchar](250) NULL,
	[Hours] [decimal](6, 2) NULL,
	[WorkDate] [datetime] NULL,
	[UserName] [nvarchar](250) NULL,
	[WorkDescription] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Types]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Types](
	[CategoryId] [int] NOT NULL,
	[TypeId] [int] NOT NULL,
	[TypeName] [nvarchar](100) NOT NULL,
	[Sequence] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[CategoryId] ASC,
	[TypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[User]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[User](
	[UserId] [uniqueidentifier] NOT NULL,
	[ClientId] [uniqueidentifier] NULL,
	[UserName] [varchar](100) NOT NULL,
	[Email] [varchar](100) NULL,
	[LoginName] [varchar](20) NOT NULL,
	[Password] [nvarchar](max) NULL,
	[Status] [int] NOT NULL,
	[CreatedBy] [uniqueidentifier] NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[ModifiedBy] [uniqueidentifier] NULL,
	[ModifiedOn] [datetime] NULL,
	[EmployeeId] [uniqueidentifier] NULL,
 CONSTRAINT [pk_User] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserContainer]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserContainer](
	[UserId] [uniqueidentifier] NOT NULL,
	[ContainerId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_UserContainer] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[ContainerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserRole]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserRole](
	[UserRoleId] [uniqueidentifier] NOT NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[RoleId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_UserRole] PRIMARY KEY CLUSTERED 
(
	[UserRoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Version]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Version](
	[VersionId] [uniqueidentifier] NOT NULL,
	[ComponentId] [uniqueidentifier] NOT NULL,
	[Version] [nvarchar](15) NULL,
	[BuildBy] [nvarchar](20) NULL,
	[BuildOn] [datetime] NULL,
	[DBBuilds] [nvarchar](50) NULL,
	[IsLocked] [bit] NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedBy] [uniqueidentifier] NOT NULL,
	[ModifiedOn] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[VersionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[VersionChangeCommit]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VersionChangeCommit](
	[VersionChangeCommitId] [uniqueidentifier] NOT NULL,
	[VersionChangeId] [uniqueidentifier] NOT NULL,
	[GitCommitId] [nvarchar](50) NOT NULL,
	[CommittedBy] [uniqueidentifier] NOT NULL,
	[CommittedOn] [datetime] NOT NULL,
	[CommittedFiles] [nvarchar](2000) NULL,
	[Description] [nvarchar](2000) NULL,
 CONSTRAINT [PK_VersionChangeCommit] PRIMARY KEY CLUSTERED 
(
	[VersionChangeCommitId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[VersionDeployment]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VersionDeployment](
	[VersionId] [uniqueidentifier] NULL,
	[DeploymentSiteId] [uniqueidentifier] NULL,
	[DeployedBy] [varchar](50) NULL,
	[DeployedOn] [datetime] NULL,
	[Remarks] [nvarchar](1000) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WorkLog]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WorkLog](
	[WorkLogId] [uniqueidentifier] NULL,
	[UserId] [uniqueidentifier] NULL,
	[JiraIssueId] [int] NULL,
	[WorkDate] [datetime] NULL,
	[Hours] [decimal](6, 2) NULL,
	[Remarks] [nvarchar](max) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[UpdatedDate] [datetime] NULL,
	[TaskId] [uniqueidentifier] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[YearDay]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[YearDay](
	[YearDayDate] [date] NOT NULL,
 CONSTRAINT [pk_YearDay] PRIMARY KEY CLUSTERED 
(
	[YearDayDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AspNetUserClaims]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AspNetUserClaims_dbo.AspNetUsers_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserClaims] CHECK CONSTRAINT [FK_dbo.AspNetUserClaims_dbo.AspNetUsers_UserId]
GO
ALTER TABLE [dbo].[AspNetUserLogins]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AspNetUserLogins_dbo.AspNetUsers_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserLogins] CHECK CONSTRAINT [FK_dbo.AspNetUserLogins_dbo.AspNetUsers_UserId]
GO
ALTER TABLE [dbo].[AspNetUserRoles]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AspNetUserRoles_dbo.AspNetRoles_RoleId] FOREIGN KEY([RoleId])
REFERENCES [dbo].[AspNetRoles] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserRoles] CHECK CONSTRAINT [FK_dbo.AspNetUserRoles_dbo.AspNetRoles_RoleId]
GO
ALTER TABLE [dbo].[AspNetUserRoles]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AspNetUserRoles_dbo.AspNetUsers_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserRoles] CHECK CONSTRAINT [FK_dbo.AspNetUserRoles_dbo.AspNetUsers_UserId]
GO
ALTER TABLE [dbo].[Component]  WITH NOCHECK ADD FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[User] ([UserId])
GO
ALTER TABLE [dbo].[Component]  WITH NOCHECK ADD FOREIGN KEY([ModifiedBy])
REFERENCES [dbo].[User] ([UserId])
GO
ALTER TABLE [dbo].[Component]  WITH NOCHECK ADD  CONSTRAINT [FK_Component] FOREIGN KEY([ProjectId])
REFERENCES [dbo].[Project] ([ProjectId])
GO
ALTER TABLE [dbo].[Component] CHECK CONSTRAINT [FK_Component]
GO
ALTER TABLE [dbo].[DataColumn]  WITH CHECK ADD  CONSTRAINT [fk_DataColumn_DataTable] FOREIGN KEY([DataTableId])
REFERENCES [dbo].[DataTable] ([DataTableId])
GO
ALTER TABLE [dbo].[DataColumn] CHECK CONSTRAINT [fk_DataColumn_DataTable]
GO
ALTER TABLE [dbo].[DataFile]  WITH NOCHECK ADD  CONSTRAINT [fk_DataFile_DataRequest] FOREIGN KEY([DataRequestId])
REFERENCES [dbo].[DataRequest] ([DataRequestId])
GO
ALTER TABLE [dbo].[DataFile] CHECK CONSTRAINT [fk_DataFile_DataRequest]
GO
ALTER TABLE [dbo].[DataRequest]  WITH NOCHECK ADD  CONSTRAINT [fk_DataRequest_Client] FOREIGN KEY([ClientId])
REFERENCES [dbo].[Client] ([ClientId])
GO
ALTER TABLE [dbo].[DataRequest] CHECK CONSTRAINT [fk_DataRequest_Client]
GO
ALTER TABLE [dbo].[DBBuild]  WITH NOCHECK ADD FOREIGN KEY([ComponentId])
REFERENCES [dbo].[Component] ([ComponentId])
GO
ALTER TABLE [dbo].[DBBuild]  WITH NOCHECK ADD FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[User] ([UserId])
GO
ALTER TABLE [dbo].[DBBuild]  WITH NOCHECK ADD FOREIGN KEY([ModifiedBy])
REFERENCES [dbo].[User] ([UserId])
GO
ALTER TABLE [dbo].[DBScript]  WITH NOCHECK ADD FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[User] ([UserId])
GO
ALTER TABLE [dbo].[DBScript]  WITH NOCHECK ADD FOREIGN KEY([DBBuildId])
REFERENCES [dbo].[DBBuild] ([DBBuildId])
GO
ALTER TABLE [dbo].[DBScript]  WITH NOCHECK ADD FOREIGN KEY([ModifiedBy])
REFERENCES [dbo].[User] ([UserId])
GO
ALTER TABLE [dbo].[Module]  WITH NOCHECK ADD  CONSTRAINT [fk_Module_Client] FOREIGN KEY([ClientId])
REFERENCES [dbo].[Client] ([ClientId])
GO
ALTER TABLE [dbo].[Module] CHECK CONSTRAINT [fk_Module_Client]
GO
ALTER TABLE [dbo].[Module]  WITH NOCHECK ADD  CONSTRAINT [fk_Module_Module] FOREIGN KEY([ParentModuleId])
REFERENCES [dbo].[Module] ([ModuleId])
GO
ALTER TABLE [dbo].[Module] CHECK CONSTRAINT [fk_Module_Module]
GO
ALTER TABLE [dbo].[Option]  WITH NOCHECK ADD  CONSTRAINT [FK_Option] FOREIGN KEY([OptionSetId])
REFERENCES [dbo].[OptionSet] ([OptionSetId])
GO
ALTER TABLE [dbo].[Option] CHECK CONSTRAINT [FK_Option]
GO
ALTER TABLE [dbo].[Option]  WITH NOCHECK ADD  CONSTRAINT [FK_Option_User_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[User] ([UserId])
GO
ALTER TABLE [dbo].[Option] CHECK CONSTRAINT [FK_Option_User_CreatedBy]
GO
ALTER TABLE [dbo].[Option]  WITH NOCHECK ADD  CONSTRAINT [FK_Option_User_ModifiedBy] FOREIGN KEY([ModifiedBy])
REFERENCES [dbo].[User] ([UserId])
GO
ALTER TABLE [dbo].[Option] CHECK CONSTRAINT [FK_Option_User_ModifiedBy]
GO
ALTER TABLE [dbo].[OptionSet]  WITH NOCHECK ADD  CONSTRAINT [FK_OptionSet_User_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[User] ([UserId])
GO
ALTER TABLE [dbo].[OptionSet] CHECK CONSTRAINT [FK_OptionSet_User_CreatedBy]
GO
ALTER TABLE [dbo].[OptionSet]  WITH NOCHECK ADD  CONSTRAINT [FK_OptionSet_User_ModifiedBy] FOREIGN KEY([ModifiedBy])
REFERENCES [dbo].[User] ([UserId])
GO
ALTER TABLE [dbo].[OptionSet] CHECK CONSTRAINT [FK_OptionSet_User_ModifiedBy]
GO
ALTER TABLE [dbo].[Project]  WITH NOCHECK ADD  CONSTRAINT [fk_Project_Client] FOREIGN KEY([ClientId])
REFERENCES [dbo].[Client] ([ClientId])
GO
ALTER TABLE [dbo].[Project] CHECK CONSTRAINT [fk_Project_Client]
GO
ALTER TABLE [dbo].[ProjectPermission]  WITH NOCHECK ADD  CONSTRAINT [fk_ProjectPermission_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([UserId])
GO
ALTER TABLE [dbo].[ProjectPermission] CHECK CONSTRAINT [fk_ProjectPermission_User]
GO
ALTER TABLE [dbo].[SoftwareDownload]  WITH NOCHECK ADD FOREIGN KEY([DownloadFileId])
REFERENCES [dbo].[DownloadFile] ([DownloadFileId])
GO
ALTER TABLE [dbo].[Task]  WITH NOCHECK ADD FOREIGN KEY([ComponentId])
REFERENCES [dbo].[Component] ([ComponentId])
GO
ALTER TABLE [dbo].[Task]  WITH NOCHECK ADD FOREIGN KEY([ProjectId])
REFERENCES [dbo].[Project] ([ProjectId])
GO
ALTER TABLE [dbo].[User]  WITH NOCHECK ADD  CONSTRAINT [fk_User_Client] FOREIGN KEY([ClientId])
REFERENCES [dbo].[Client] ([ClientId])
GO
ALTER TABLE [dbo].[User] CHECK CONSTRAINT [fk_User_Client]
GO
ALTER TABLE [dbo].[UserContainer]  WITH CHECK ADD  CONSTRAINT [FK_UserContainer_Container] FOREIGN KEY([ContainerId])
REFERENCES [dbo].[Container] ([ContainerId])
GO
ALTER TABLE [dbo].[UserContainer] CHECK CONSTRAINT [FK_UserContainer_Container]
GO
ALTER TABLE [dbo].[UserContainer]  WITH CHECK ADD  CONSTRAINT [FK_UserContainer_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([UserId])
GO
ALTER TABLE [dbo].[UserContainer] CHECK CONSTRAINT [FK_UserContainer_User]
GO
ALTER TABLE [dbo].[UserRole]  WITH NOCHECK ADD  CONSTRAINT [FK_UserRole_RoleId] FOREIGN KEY([RoleId])
REFERENCES [dbo].[Role] ([RoleId])
GO
ALTER TABLE [dbo].[UserRole] CHECK CONSTRAINT [FK_UserRole_RoleId]
GO
ALTER TABLE [dbo].[UserRole]  WITH NOCHECK ADD  CONSTRAINT [FK_UserRole_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([UserId])
GO
ALTER TABLE [dbo].[UserRole] CHECK CONSTRAINT [FK_UserRole_UserId]
GO
ALTER TABLE [dbo].[VersionChange]  WITH NOCHECK ADD FOREIGN KEY([VersionId])
REFERENCES [dbo].[Version] ([VersionId])
GO
/****** Object:  StoredProcedure [dbo].[DeleteAttachment]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeleteAttachment]
	@AttachmentId UNIQUEIDENTIFIER,
	@FileName VARCHAR(100) = NULL --Not required, it will be removed later
AS
BEGIN
	DELETE FROM Attachment WHERE AttachmentId = @AttachmentId
END
GO
/****** Object:  StoredProcedure [dbo].[getAssignedUserList]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[getAssignedUserList]
	@ClientId UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;
	
	IF (@ClientId <> '00000000-0000-0000-0000-000000000000')
	BEGIN
	    SELECT U.UserName,
	           U.UserId
	    FROM   Client c
	           JOIN [User] U
	                ON  c.ClientId = U.ClientId
	                AND c.ClientId = @ClientId
	    WHERE  U.Status = 0
	END
	ELSE
	BEGIN
	    SELECT UserName,
	           UserId
	    FROM   [User]
	    WHERE  STATUS = 0
	END
END
GO
/****** Object:  StoredProcedure [dbo].[GetComponents]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetComponents] 
@ProjectId UNIQUEIDENTIFIER=null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT ComponentId, Name 
	FROM Component 
	WHERE @ProjectId IS NULL OR ProjectId=@ProjectId 
	AND ISNULL(Name,'') <> ''
	ORDER BY Name
END
GO
/****** Object:  StoredProcedure [dbo].[GetEmailTemplates]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author       : Ankit Sharma
-- Create date  : 15-March-2016
-- Description  : Get All Email Templates
-- Parameters   : 
-- =============================================
CREATE PROCEDURE [dbo].[GetEmailTemplates]
AS
BEGIN
	SET NOCOUNT ON;
	SELECT EmailTemplateId,TemplateName,FromEmailId,
	ToEmailId,CCEmailId,[Subject],Body,(u.UserName) AS CreatedBy,e.CreatedOn,(u2.UserName) AS ModifiedBy,e.ModifiedOn 
	FROM EmailTemplate e
	LEFT JOIN [User] u ON e.CreatedBy=u.Userid
	LEFT JOIN [User] u2 ON e.ModifiedBy=u2.Userid
END
GO
/****** Object:  StoredProcedure [dbo].[GetTypes]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetTypes]
@CategoryId INT
AS
BEGIN
	SELECT CategoryId,TypeId,TypeName,Sequence FROM Types WHERE CategoryId = @CategoryId ORDER BY Sequence
END
GO
/****** Object:  StoredProcedure [dbo].[InsertAttachment]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InsertAttachment]	
	@EntityType      INT=NULL,
	@EntityId        UNIQUEIDENTIFIER=NULL,
	@FileName        NVARCHAR(250)=NULL,
	@ContentType     NVARCHAR(250)=NULL,
	@ContentLength   INT=NULL,
	@FileContent     VARBINARY(MAX)=NULL,
	@UploadedBy      UNIQUEIDENTIFIER
	
AS
BEGIN
  IF NOT EXISTS(SELECT 1 FROM Attachment WHERE EntityId = @EntityId AND [FileName] = @FileName)
  BEGIN
	INSERT INTO Attachment(AttachmentId,EntityType,EntityId,FileName,ContentType,ContentLength,FileContent,UploadedBy,UploadedOn)
				VALUES(NEWID(),@EntityType,@EntityId,@FileName,@ContentType,@ContentLength,@FileContent,@UploadedBy,GETDATE())
  END
	
END
GO
/****** Object:  StoredProcedure [dbo].[InsertTaskAttachment]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================
-- Author       : Narendra Shrivastava
-- Create date  : 22-Feb-2016
-- Description  : Create Task from Email and save attachments also
-- Parameters   : 
-- ==============================================================
CREATE PROCEDURE [dbo].[InsertTaskAttachment]
	@TaskId        UNIQUEIDENTIFIER=NULL,
	@FileName        NVARCHAR(250)=NULL,
	@ContentType     NVARCHAR(250)=NULL,
	@ContentLength   INT=NULL,
	@FileContent     VARBINARY(MAX)=NULL
	
AS
BEGIN
	DECLARE @UploadedBy UNIQUEIDENTIFIER = NULL

	SELECT @UploadedBy = ISNULL(CreatedBy,'743E21CE-4388-487A-805F-486CD86DD7B3') from Task where TaskId = @TaskId

	INSERT INTO Attachment(AttachmentId,EntityType,EntityId,FileName,ContentType,ContentLength,FileContent,UploadedBy,UploadedOn)
		VALUES(NEWID(),11,@TaskId,@FileName,@ContentType,@ContentLength,@FileContent,@UploadedBy,GETDATE())
END
GO
/****** Object:  StoredProcedure [dbo].[spActivateLicenseKey]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spActivateLicenseKey] 
	-- Add the parameters for the stored procedure here
	@licensekey VARCHAR(512),
	@activationkey VARCHAR(512)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE License SET ActivationKey =  @activationkey WHERE LicenseId = @licensekey
END
GO
/****** Object:  StoredProcedure [dbo].[spApproveTaxSavingReceipts]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================
-- Author       : Ankit Sharma
-- Create date  : 07-April-2016
-- Description  : Approve Tax Saving Receipts
-- Parameters   : 
-- ==============================================================
CREATE PROCEDURE [dbo].[spApproveTaxSavingReceipts]
	@TaxSavingIds		NVARCHAR(MAX)
AS	 
BEGIN	
	Update TaxSaving set ReceiptSubmitted = 1
    where TaxSavingId in (select * from fnSplit(isnull(@TaxSavingIds,''),','))

END
GO
/****** Object:  StoredProcedure [dbo].[spAuthenticateUser]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spAuthenticateUser] @LoginName nvarchar(100),
@password nvarchar(100)
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @pass1 varchar(max)
  SELECT @pass1=[password]
  FROM [User]
  WHERE LoginName = @LoginName AND [Status] = 0
  IF (@pass1 IS NOT NULL)
  BEGIN
  IF (@pass1 = @password)
        BEGIN
              select top 1 UserId,ClientId,UserName,Email,LoginName,IsAdmin,EmployeeId From
              (SELECT
              [User].[UserId],
              [ClientId],
              UserName,
              Email,
              LoginName,
              CASE
              WHEN [UserRole].RoleId = '576FD083-1FE9-4433-B7A7-8F1655A55C9E' THEN 1 ELSE 0   END AS IsAdmin,
              EmployeeId
              FROM dbo.[User]
              left join [UserRole] on [User].UserId=[UserRole].UserId
              WHERE LoginName = @LoginName AND [Status] = 0)Autentication order by IsAdmin desc
        END
  END
END
GO
/****** Object:  StoredProcedure [dbo].[spChangeClientStatus]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spChangeClientStatus]
	@ClientId UNIQUEIDENTIFIER,
	@status INT,
	@ModifiedBy UNIQUEIDENTIFIER = NULL
AS
BEGIN
	SET NOCOUNT ON;
		
	UPDATE Client
	SET    STATUS         = @status,
	       ModifiedBy     = @ModifiedBy,
	       ModifiedOn     = GETDATE()
	WHERE  ClientId       = @ClientId
END
GO
/****** Object:  StoredProcedure [dbo].[spChangeEmailTemplateStatus]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spChangeEmailTemplateStatus] 
	@EmailTemplateId uniqueidentifier
	,@status int
	,@ModifiedBy uniqueidentifier=null
AS
BEGIN
	SET NOCOUNT ON;
	
	update EmailTemplate set Status=@status,ModifiedBy=@ModifiedBy,ModifiedOn=GETDATE() where EmailTemplateId=@EmailTemplateId
END
GO
/****** Object:  StoredProcedure [dbo].[spChangeModuleStatus]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spChangeModuleStatus] 
	@ModuleId uniqueidentifier
	,@status int
	,@ModifiedBy uniqueidentifier=null

AS
BEGIN

	SET NOCOUNT ON;
	update Module set Status=@status,ModifiedBy=@ModifiedBy,ModifiedOn=GETDATE() where ModuleId=@ModuleId
END
GO
/****** Object:  StoredProcedure [dbo].[spChangePassword]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spChangePassword] 
 @UserId uniqueidentifier,	
	@Password nvarchar(100)=null,
	@ModifiedBy uniqueidentifier= NULL

   
AS
BEGIN
    SET NOCOUNT ON;
	
	if(@Password<>'')
	begin

    UPDATE  dbo.[User]
    SET		
						
			ModifiedBy			= @ModifiedBy,
			ModifiedOn			= Getdate()	,	
			Password		  = @Password
			

     WHERE UserId = @UserId
	

	 end
END
GO
/****** Object:  StoredProcedure [dbo].[spChangeStatus]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spChangeStatus]
	@EntityType INT,
	@EntityId UNIQUEIDENTIFIER,
	@NewStatus INT
AS
BEGIN
	SET NOCOUNT ON;
	
	IF (@EntityType = 3)
	BEGIN
	    UPDATE DataRequest
	    SET    [Status]          = @NewStatus
	    WHERE  DataRequestId     = @EntityId
	END
END
GO
/****** Object:  StoredProcedure [dbo].[spChangeUserStatus]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spChangeUserStatus] 
	@UserId uniqueidentifier
	,@status int
	,@ModifiedBy uniqueidentifier=null

AS
BEGIN


	SET NOCOUNT ON;


   update [User] set Status=@status,ModifiedBy=@ModifiedBy,ModifiedOn=GETDATE() where UserId=@UserId

END
GO
/****** Object:  StoredProcedure [dbo].[spCheckAttendanceTime]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spCheckAttendanceTime]
    @EmployeeId     UNIQUEIDENTIFIER,
	@Date			datetime
	
AS
BEGIN
    SET NOCOUNT ON;
     SELECT InTime,OutTime,AttendanceDate FROM attendance WHERE employeeid= @EmployeeId AND  AttendanceDate = @Date   
END
GO
/****** Object:  StoredProcedure [dbo].[spCheckDuplicateName]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spCheckDuplicateName]
	@Name NVARCHAR(100),
	@retval INT OUTPUT
AS
BEGIN
SET @retval=0
IF EXISTS(SELECT 'TRUE' FROM Holiday WHERE Name=@Name)
	BEGIN
		SET @retval=1
	END
RETURN @retval
END
GO
/****** Object:  StoredProcedure [dbo].[spCheckDuplicateRefrenceNumber]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spCheckDuplicateRefrenceNumber]
	@VersionId UNIQUEIDENTIFIER,
	@Reference NVARCHAR(20)	
	
AS
BEGIN

	DECLARE @recordCount INT;
	SELECT @recordCount = Count(*) FROM VersionChange  WHERE VersionId=@VersionId AND Reference=@Reference
	IF(@recordCount > 0)
	BEGIN
		select 1
	END
	ELSE
	BEGIN
		select 0
	END	
	
END
GO
/****** Object:  StoredProcedure [dbo].[spCheckRole]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================
-- Author:		Avadhesh kumar
-- Create date: 4 July 2019
-- Description: Check User Role
-- ========================================================  
CREATE PROCEDURE [dbo].[spCheckRole] 
	@EmployeeId AS UNIQUEIDENTIFIER
AS
BEGIN
    SELECT R.UserId, R.RoleId, A.Name, U.UserName, U.EmployeeId
    FROM [dbo].[AspNetRoles] AS A
        INNER JOIN [dbo].[AspNetUserRoles] AS R ON A.Id = R.RoleId
        INNER JOIN [dbo].[User] AS U ON R.UserId = U.UserId
    WHERE U.EmployeeId = @EmployeeId;
END;
GO
/****** Object:  StoredProcedure [dbo].[spCopyTaxSavingData]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================
-- Author:		Avadhesh kumar
-- Create date: 9 July 2019
-- Description: Copy Tax Saving
-- ========================================================  
CREATE PROCEDURE [dbo].[spCopyTaxSavingData]
	@EmployeeId AS UNIQUEIDENTIFIER=null,
	@FinancialPriviousYear INT=null
AS
BEGIN

 INSERT INTO
     [dbo].[TaxSaving](TaxSavingId, EmployeeId,FinancialYear,TaxSavingType,RecurringFrequency,SavingDate,AccountNumber,Amount,ReceiptSubmitted,Remarks,EligibleCount)  
 SELECT
      NEWID() as TaxSavingId,  EmployeeId,(FinancialYear+1) AS FinancialYear,TaxSavingType,RecurringFrequency,SavingDate,AccountNumber,Amount,ReceiptSubmitted,Remarks,EligibleCount
	    FROM [dbo].[TaxSaving]  WHERE EmployeeId=@EmployeeId and FinancialYear=@FinancialPriviousYear  
END
GO
/****** Object:  StoredProcedure [dbo].[spDeleteAttendance]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spDeleteAttendance]
    @AttendanceId     uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM Attendance
    WHERE AttendanceId = @AttendanceId
END
GO
/****** Object:  StoredProcedure [dbo].[spDeleteClient]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spDeleteClient]
    @ClientId    uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM Client
    WHERE ClientId = @ClientId
END
GO
/****** Object:  StoredProcedure [dbo].[spDeleteComment]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spDeleteComment]
    @CommentId    uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM Comment
    WHERE CommentId = @CommentId
END
GO
/****** Object:  StoredProcedure [dbo].[spDeleteComponents]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spDeleteComponents]
    @ComponentId     uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON; 
    DELETE FROM Component WHERE ComponentId = @ComponentId
END
GO
/****** Object:  StoredProcedure [dbo].[spDeleteContainer]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ========================================================
-- Author:		Ankit Sharma 
-- Create date: 03 May 2016
-- Description: Delete Container
-- ========================================================
CREATE PROCEDURE [dbo].[spDeleteContainer]
 @ContainerId   UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
		DELETE Container WHERE ContainerId = @ContainerId
		DELETE UserContainer WHERE ContainerId = @ContainerId
END
GO
/****** Object:  StoredProcedure [dbo].[spDeleteDataColumn]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spDeleteDataColumn]
    @DataColumnId    uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM DataColumn
    WHERE DataColumnId = @DataColumnId
END
GO
/****** Object:  StoredProcedure [dbo].[spDeleteDataFile]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spDeleteDataFile]
    @DataFileId   uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM DataFile
    WHERE DataFileId = @DataFileId
END
GO
/****** Object:  StoredProcedure [dbo].[spDeleteDataRequest]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spDeleteDataRequest]
    @DataRequestId    uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM DataRequest
    WHERE DataRequestId = @DataRequestId
END
GO
/****** Object:  StoredProcedure [dbo].[spDeleteDataTable]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spDeleteDataTable]
    @DataTableId   uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM DataTable
    WHERE DataTableId = @DataTableId
END
GO
/****** Object:  StoredProcedure [dbo].[spDeleteDBScript]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spDeleteDBScript]
    @DBScriptId    uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM DBScript
    WHERE DBScriptId = @DBScriptId
END
GO
/****** Object:  StoredProcedure [dbo].[spDeleteDeploymentDetail]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spDeleteDeploymentDetail]
	@VersionId      UNIQUEIDENTIFIER,
	@DeploymentSiteId  UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	DELETE FROM VersionDeployment
	Where VersionId=@VersionId and  DeploymentSiteId=@DeploymentSiteId
END
GO
/****** Object:  StoredProcedure [dbo].[spDeleteDetailVersionData]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spDeleteDetailVersionData]
	@VersionChangeId     UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	DELETE FROM VersionChange
	Where VersionChangeId=@VersionChangeId  
END
GO
/****** Object:  StoredProcedure [dbo].[spDeleteEmployee]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spDeleteEmployee]
    @EmployeeId     uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM Employee
    WHERE EmployeeId = @EmployeeId
END
GO
/****** Object:  StoredProcedure [dbo].[spDeleteHoliday]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spDeleteHoliday]
@HolidayDate datetime
AS
BEGIN
SET NOCOUNT ON;
	DELETE FROM Holiday
	WHERE HolidayDate=@HolidayDate
END
GO
/****** Object:  StoredProcedure [dbo].[spDeleteLeave]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spDeleteLeave]
    @LeaveId     uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS(SELECT * FROM Leave WHERE LeaveId = @LeaveId)
    BEGIN
        DELETE FROM Leave WHERE LeaveId = @LeaveId
    END
END
GO
/****** Object:  StoredProcedure [dbo].[spDeleteModule]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spDeleteModule]
    @ModuleId   uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM [Module]
    WHERE ModuleId = @ModuleId
END
GO
/****** Object:  StoredProcedure [dbo].[spDeleteProject]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spDeleteProject]
    @ProjectId    uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM Project
    WHERE ProjectId = @ProjectId
END
GO
/****** Object:  StoredProcedure [dbo].[spDeleteReleaseNote]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spDeleteReleaseNote]

	@ReleaseNoteId uniqueidentifier

AS

BEGIN

	delete from ReleaseNote where ReleaseNoteId = @ReleaseNoteId

END
GO
/****** Object:  StoredProcedure [dbo].[spDeleteReleaseNoteSummary]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author       : Ankit Sharma
-- Create date  : 08-March-2016
-- Description  : Delete Release Notes Summary
-- Parameters   : 
-- =============================================
Create PROCEDURE [dbo].[spDeleteReleaseNoteSummary]
@ReleaseNoteSummaryId uniqueidentifier
AS
BEGIN
delete from ReleaseNoteSummary where ReleaseNoteSummaryId = @ReleaseNoteSummaryId
delete from ReleaseNote where ReleaseNoteSummaryId = @ReleaseNoteSummaryId
END
GO
/****** Object:  StoredProcedure [dbo].[spDeleteTask]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spDeleteTask]
	@TaskId				UNIQUEIDENTIFIER
AS
BEGIN
		SET NOCOUNT ON;
		DELETE FROM Task WHERE TaskId=@TaskId
END
GO
/****** Object:  StoredProcedure [dbo].[spDeleteTaxSavingReceipt]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================
-- Author       : Ankit Sharma
-- Create date  : 07-April-2016
-- Description  : Delete Tax Saving Receipt
-- Parameters   : 
-- ==============================================================
CREATE PROCEDURE [dbo].[spDeleteTaxSavingReceipt]
	@TaxSavingId		uniqueidentifier
AS	 
BEGIN	
	DELETE FROM TaxSaving
	WHERE TaxSavingId=@TaxSavingId
END
GO
/****** Object:  StoredProcedure [dbo].[spDeleteTaxSavingType]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spDeleteTaxSavingType]
(
@TaxSavingType INT
)
AS
BEGIN
 SET NOCOUNT ON;
  DELETE FROM TaxSavingType WHERE TaxSavingType=@TaxSavingType
END
GO
/****** Object:  StoredProcedure [dbo].[spDeleteUser]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spDeleteUser]
    @UserId    uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM [User]
    WHERE UserId = @UserId
END
GO
/****** Object:  StoredProcedure [dbo].[spDeleteVersionChangeCommit]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ankit Sharma
-- Create date: 12 May 2016
-- Description: Update version change commit details
-- =============================================
CREATE PROCEDURE [dbo].[spDeleteVersionChangeCommit]
	@VersionChangeCommitId    UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;
	    Delete from VersionChangeCommit  
		where VersionChangeCommitId=@VersionChangeCommitId    
END
GO
/****** Object:  StoredProcedure [dbo].[spDeleteVersionData]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[spDeleteVersionData]
	@VersionId       UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	delete from VersionChange where VersionId=@VersionId
	delete from Version where VersionId=@VersionId
	delete from ReleaseNote where VersionId=@VersionId  
END
GO
/****** Object:  StoredProcedure [dbo].[spDeleteWorkLog]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spDeleteWorkLog]
@UserId UNIQUEIDENTIFIER,
@TaskId UNIQUEIDENTIFIER,
@WorkDate DATETIME
AS 
BEGIN   
	Delete WorkLog WHERE UserId=@UserId AND TaskId = @TaskId AND WorkDate = @WorkDate
END
GO
/****** Object:  StoredProcedure [dbo].[spDownloadAttachment]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spDownloadAttachment]
	@EntityId UNIQUEIDENTIFIER,
	@FileName VARCHAR(200)
AS
BEGIN
	SELECT FileName,ContentType,ContentLength,FileContent FROM Attachment WHERE EntityId=@EntityId AND FileName=@FileName
END
GO
/****** Object:  StoredProcedure [dbo].[spDownloadAttachment2]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================
-- Author       : Narendra Shrivastava
-- Create date  : 25-Feb-2016
-- Description  : Get download file detail 
-- Parameters   : EntityId and AttachmentId
-- ==============================================================
CREATE PROCEDURE [dbo].[spDownloadAttachment2]
	@AttachmentId UNIQUEIDENTIFIER,
	@EntityId UNIQUEIDENTIFIER
AS
BEGIN
	SELECT FileName,ContentType,ContentLength,FileContent FROM Attachment WHERE AttachmentId = @AttachmentId AND EntityId=@EntityId  
END
GO
/****** Object:  StoredProcedure [dbo].[spEmployeeAttendanceSummary]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================
-- Author:		Avadhesh kumar
-- Create date: 4 July 2019
-- Description: Get employee attendance summary
-- ========================================================
CREATE PROCEDURE [dbo].[spEmployeeAttendanceSummary]	 
AS
BEGIN

	SELECT t.EmployeeName, 
	CASE t.Attendance WHEN 'P' THEN 'Present' WHEN 'L' THEN 'Leave' WHEN 'A' THEN 'Absent' ELSE NULL END AS Attendance, 
	t.AttendanceDate, 
	t.EmployeeName, 
	t.InTime, 
	t.OutTime, 
	t.TotalTime,
	CASE 
		WHEN (t.Attendance = 'P' AND t.OutTime IS NULL) THEN '#B2EC5D' 
		WHEN (t.Attendance='P' AND t.OutTime IS NOT NULL) THEN '#D5F2AA' 
		WHEN t.Attendance = 'L' THEN '#FC8EAC' 
		WHEN t.Attendance = 'A' THEN '#BD33A4'  
		ELSE '#9B9C9A' 
	END AS ColorCode
	FROM (
		SELECT  
			ISNULL(e.FirstName,'') + ' ' + ISNULL(e.MiddleName,'') + ' '  + ISNULL(e.LastName,'') AS EmployeeName,
			CASE WHEN a.Attendance = 0.0 AND l.LeaveDate IS NULL THEN 'A'
				 WHEN a.Attendance = 0.5 OR a.Attendance = 1.0 THEN 'P'
				 WHEN l.LeaveDate IS NOT NULL AND l.IsApproved=1 THEN 'L'             
			ELSE NULL END AS [Attendance],
			CONVERT(NVARCHAR(11), A.AttendanceDate,103) as AttendanceDate ,
			FORMAT(a.InTime,'t','en-US') InTime,
			FORMAT(a.OutTime,'t','en-US') OutTime,
			CASE WHEN a.OutTime IS NOT NULL THEN LEFT(CONVERT(VARCHAR(12), DATEADD(mi, DATEDIFF(mi, a.InTime, a.OutTime), 0), 114),5) 
				 WHEN a.TimeInMinutes IS NOT NULL THEN RIGHT('0' + CAST(a.TimeInMinutes/60 AS VARCHAR(5)),2) + ':' + RIGHT('0' + cast(a.TimeInMinutes%60 AS VARCHAR(2)), 2)
				 ELSE NULL END AS TotalTime			 
		FROM [dbo].[Employee] e
			LEFT JOIN [dbo].[User] u ON e.EmployeeId=u.EmployeeId
			LEFT JOIN [dbo].[Attendance] a ON e.EmployeeId = a.EmployeeId AND CONVERT(DATE, a.AttendanceDate) = CONVERT(DATE, GETDATE())
			LEFT JOIN [dbo].[Leave] l ON e.EmployeeId = l.EmployeeId AND CONVERT(DATE, l.LeaveDate) = CONVERT(DATE, GETDATE())
		WHERE u.[Status]=0 AND u.LoginName <> 'spujan'
	)t 
	ORDER BY t.EmployeeName

END
GO
/****** Object:  StoredProcedure [dbo].[spEmployeeTotalPresentHour]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spEmployeeTotalPresentHour]
    @EmployeeId     uniqueidentifier,
    @Day            int=null,
    @Month          int,
    @Year           int
AS
BEGIN
    SET NOCOUNT ON;

 select cast(sum(DATEDIFF(mi, a.InTime, a.OutTime) + IsNull(a.TimeInMinutes,0))/60 as varchar(5)) + ':' + right('0' + cast(sum(DATEDIFF(mi, a.InTime, a.OutTime) + 
 IsNull(a.TimeInMinutes,0))%60 as varchar(2)),2) 
 from Attendance a where EmployeeId=@EmployeeId and Month(AttendanceDate) = @Month and Year(AttendanceDate) = @Year
END
GO
/****** Object:  StoredProcedure [dbo].[spFillOffDays]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spFillOffDays]
    @datStart DATETIME,
    @datEnd DATETIME,
    @lngWeekDay INTEGER,
    @lngWeekOption INTEGER,
    @lngReturn INTEGER=0 OUTPUT
AS

DECLARE @lngStartYear INTEGER
DECLARE @lngEndYear INTEGER
DECLARE @lngCountYear INTEGER
DECLARE @lngStartMonth INTEGER
DECLARE @lngEndMonth INTEGER
DECLARE @lngCountMonth INTEGER
DECLARE @datCalculated DATETIME
DECLARE @datFirstDayOfMonth DATETIME
DECLARE @lngWeekDayOfFirstDay INTEGER
DECLARE @datFirstOccurrenceOfDay DATETIME
DECLARE @datDesiredDate DATETIME
DECLARE @strMonth VARCHAR(2)
DECLARE @lngMaxID INTEGER
DECLARE @lngForAllDays INTEGER
DECLARE @lngCountForAllDays INTEGER
DECLARE @strRemark VARCHAR(255)
DECLARE @lngCount INTEGER
BEGIN
    BEGIN TRANSACTION
    
    --VALIDATE THE WEEKDAY 
    IF @lngWeekDay<1 OR @lngWeekDay >7
    BEGIN
        RAISERROR ('Error: WeekDay must lie between 1 to 7.',16,1)
        ROLLBACK TRANSACTION
        RETURN 0
    END

    --VALIDATE THE WEEKOPTION
    IF @lngWeekOption<0 OR @lngWeekOption >5
    BEGIN
        RAISERROR ('Error: WeekOption must lie between 0 to 5.',16,1)
        ROLLBACK TRANSACTION
        RETURN 0
    END

    --GET THE STARTING AND ENDING YEAR 
    SET @lngStartYear=DATEPART(YYYY,@datStart)
    SET @lngEndYear=DATEPART(YYYY,@datEnd)
    SET @lngCountYear=@lngStartYear

    WHILE @lngCountYear<=@lngEndYear
    BEGIN
        --CALCULATE START MONTH OF THE COUNTER YEAR
        IF @lngCountYear=@lngStartYear            
        BEGIN
            SET @lngStartMonth=MONTH(@datStart)                        
        END
        ELSE
        BEGIN
            SET @lngStartMonth=1
        END

        --CALCULATE END MONTH OF THE COUNTER YEAR
        IF @lngCountYear=@lngEndYear            
        BEGIN
            SET @lngEndMonth=MONTH(@datEnd)                        
        END
        ELSE
        BEGIN
            SET @lngEndMonth=12
        END
        IF @lngweekoption=0 OR @lngWeekOption=1 OR @lngWeekOption=2 OR @lngWeekOption=3 OR @lngWeekOption=4 OR @lngWeekOption=5
        BEGIN
            SET @lngReturn=0
            SET @lngCountMonth=@lngStartMonth
            WHILE @lngCountMonth<=@lngEndMonth
            BEGIN
                SET @lngCountForAllDays=0
                --Get the first day of the month
                IF LEN(@lngCountMonth)<2
                    SET @strMonth='0' + CAST(@lngCountMonth AS VARCHAR(1))
                ELSE
                    SET @strMonth=CAST(@lngCountMonth AS VARCHAR(2))

                SET @datFirstDayOfMonth=CAST(CAST(@lngCountYear AS VARCHAR(4)) +'-' + @strMonth + '-01' AS VARCHAR(10))

        		SET @lngWeekDayOfFirstDay=DATEPART(DW,@datFirstDayOfMonth)
									
        		--Get the date of the first occurrence of the given day.
          		IF @lngWeekDayOfFirstDay - @lngWeekDay > 0  
        			SET @datFirstOccurrenceOfDay=DATEADD(d, 7 - (@lngWeekDayOfFirstDay - @lngWeekDay), @datFirstDayOfMonth)
		        ELSE
        			SET @datFirstOccurrenceOfDay=DATEADD(d, (@lngWeekDay - @lngWeekDayOfFirstDay), @datFirstDayOfMonth)			
		        
                --Now calculate the desired date.
        		IF @lngWeekOption = 0
                    SET @lngForAllDays = 5             
                ELSE
                    SET @lngForAllDays = 1
                WHILE @lngCountForAllDays < @lngForAllDays     
                BEGIN
                    SET @lngCountForAllDays = @lngCountForAllDays+1     

                    IF @lngForAllDays = 5             
                        SET @lngWeekOption =@lngCountForAllDays              
                                       
                    SET @datCalculated = DATEADD(ww,@lngWeekOption-1 ,@datFirstOccurrenceOfDay)
		        
                    --Check that date is in the same month or not.
        		    IF MONTH(@datCalculated)=  @lngCountMonth AND 
                       DATEDIFF(d, @datStart, @datCalculated ) >= 0 AND
				       DATEDIFF(d, @datEnd, @datCalculated )<= 0 
       		        BEGIN                        
                        IF @lngForAllDays=5
				            SET @strRemark = DATENAME(dw,@datCalculated)                        
		                ELSE IF @lngWeekOption=1
				            SET @strRemark = DATENAME(dw,@datCalculated)
		                ELSE IF @lngWeekOption=2
				            SET @strRemark = DATENAME(dw,@datCalculated)
		                ELSE IF @lngWeekOption=3
				            SET @strRemark = DATENAME(dw,@datCalculated)
		                ELSE IF @lngWeekOption=4
				            SET @strRemark = DATENAME(dw,@datCalculated)
		                ELSE IF @lngWeekOption=5
				            SET @strRemark = DATENAME(dw,@datCalculated)

                        --IGNORE THE EXITING CALCULATED DATE 
    		            SELECT @lngCount= COUNT(*) FROM OffDay where OffDayDate=@datCalculated
                        IF @lngCount=0
                        BEGIN
                            SET @lngMaxID=@lngMaxID+1
                            INSERT INTO OffDay(OffDayDate, Remarks)
                                 VALUES (@datCalculated,@strRemark)            
                            IF @@ERROR<>0
                            BEGIN
                                ROLLBACK TRANSACTION
                                RETURN @lngReturn
                            END
                        END
           		    END
                END
                --REINITIALIZE THE WEEKOPTION
                IF @lngForAllDays = 5
                    SET @lngWeekOption=0
                SET @lngCountMonth=@lngCountMonth+1            
            END        
        END
        SET @lngCountYear=@lngCountYear+1
    END
    SET @lngReturn=1
    COMMIT TRANSACTION
    RETURN @lngReturn
END
GO
/****** Object:  StoredProcedure [dbo].[spFillOffDaysV2]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ================================================================
-- Author		: Abhishek Ranjan
-- Create date	: 31-Dec-2019
-- Description	: For weekends entry in table OffDay
-- Usage		: EXEC [spFillOffDaysV2] @year='2020'
-- ================================================================
CREATE PROCEDURE [dbo].[spFillOffDaysV2]
	@year INTEGER
AS
BEGIN
    DECLARE @StartDate DATETIME, @EndDate DATETIME
	SELECT @StartDate = DATEFROMPARTS(@year, 1, 1), @EndDate = DATEFROMPARTS(@year, 12, 31)

	--Prepare weekends table
	;WITH CTE AS
	(
		SELECT CONVERT(DATE, @StartDate) AS [DATE], DATENAME (DW, CONVERT(DATE, @StartDate)) AS [DAY]
		UNION ALL
		SELECT DATEADD(DAY, 1, [DATE]) AS [DATE], DATENAME (DW , DATEADD(DAY, 1, [DATE])) AS [DAY] FROM CTE WHERE [DATE] < @EndDate
	)
	SELECT [DATE], [DAY] 
		INTO #Weekends  FROM CTE 
	WHERE [DAY] IN ('Saturday','Sunday') 
		ORDER BY [DATE] 
	OPTION (MAXRECURSION 367)

	--Insert entry if not exists
	MERGE dbo.OffDay od
		USING #Weekends wknds ON od.OffDayDate = wknds.[DATE]
		WHEN NOT MATCHED BY TARGET
		THEN INSERT (OffDayDate, Remarks) VALUES ([DATE], [DAY]);

	--Finally drop the temp table
	DROP TABLE #Weekends
END
GO
/****** Object:  StoredProcedure [dbo].[spFillYearDates]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spFillYearDates]
    @datStartDate DATETIME,
    @datEndDate DATETIME
AS

BEGIN
    BEGIN TRANSACTION
    
    DECLARE @lngStartDate INT
    DECLARE @lngEndDate INT
         
    SET @lngStartDate=CAST(@datStartDate AS INT)
    SET @lngEndDate=CAST(@datEndDate AS INT)
    
    WHILE @lngStartDate<=@lngEndDate
    BEGIN
        INSERT INTO YearDay (YearDayDate) VALUES (CAST(@lngStartDate AS DATETIME))
            
        SET @lngStartDate=@lngStartDate+1
    END
    COMMIT TRANSACTION
end
GO
/****** Object:  StoredProcedure [dbo].[spGetActivationKey]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetActivationKey]
	-- Add the parameters for the stored procedure here
	@licensekey uniqueidentifier,
	@activationkey VARCHAR(512)  OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Retirve license key here
	SELECT @activationkey = ActivationKey FROM License WHERE LicenseId = @licensekey
END
GO
/****** Object:  StoredProcedure [dbo].[spGetActivities]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetActivities]
	@EntityType INT,
	@EntityId UNIQUEIDENTIFIER,
	@IsInternal BIT=0
AS
BEGIN
	SET NOCOUNT ON;
	SELECT A.ActivityId,
	       A.EntityType,
	       A.EntityId,
	       A.[Description],
	       A.CommentId,
	       C.Comment,
	       A.IsInternal,
	       A.CreatedBy,
	       u.UserName as CreatedByUserName,
	       A.CreatedOn
	FROM   Activity A
	       LEFT OUTER JOIN Comment C
	            ON  A.CommentId = C.CommentId
	       LEFT OUTER JOIN [user] U
	            ON  A.CreatedBy = U.UserId
	WHERE  A.EntityType = @EntityType
	       AND A.EntityId = @EntityId
	       AND A.IsInternal = @IsInternal 
	ORDER BY A.CreatedOn DESC
END
GO
/****** Object:  StoredProcedure [dbo].[spGetAllDBScriptsByBuild]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetAllDBScriptsByBuild] 
@DBBuildId NVARCHAR(MAX)=null,
@DBScriptIDs NVARCHAR(MAX)=null,
@ComponentId UNIQUEIDENTIFIER=null
AS
BEGIN
 SET NOCOUNT ON;
 SELECT *
 FROM DBScript A
 WHERE ((A.DBBuildId IN (SELECT item FROM dbo.fnSplit(@DBBuildId,',')) OR  @DBBuildId IS NULL) AND (A.DBScriptType <> 11))--altered to not include Client Data scripts
		AND
		(A.DBScriptId IN (SELECT item FROM dbo.fnSplit(@DBScriptIDs,',')) OR  @DBScriptIDs IS NULL)
 ORDER BY A.DBScriptType ASC, A.Sequence ASC
 SELECT BuildPrefixForConfig from Component where ComponentId=@ComponentId
END
GO
/****** Object:  StoredProcedure [dbo].[spGetAllDBScriptsByComponent]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================
-- Author       : Ankit Sharma
-- Create date  : 19-April-2016
-- Description  : Get All Scripts for a Component.
-- Parameters   : 
-- ==============================================================
CREATE PROCEDURE [dbo].[spGetAllDBScriptsByComponent]
@DBBuildId NVARCHAR(MAX)
AS
BEGIN
SET NOCOUNT ON;
;WITH cte AS (
SELECT ROW_NUMBER () OVER ( PARTITION BY  res1.ScriptName ORDER BY res.BuildName Desc)AS RowNumber,res1.ScriptName ScriptName,res1.Script,res1.BuildName,res1.DBScriptType from
(
select distinct a.Name ScriptName, max(b.Name) BuildName from DBScript a
LEFT JOIN DBBuild b on a.DBBuildId=b.DBBuildId
where a.DBBuildId in(select DBBuildId from DBBuild where (DBBuildId IN (SELECT item FROM dbo.fnSplit(@DBBuildId,',')) OR  @DBBuildId IS NULL)) And a.DBScriptType in(6,7,8)
group by a.Name)as res
left join 
(SELECT Distinct A.Name ScriptName,A.Script,DB.Name BuildName,A.DBScriptType FROM DBScript A
LEFT JOIN DBBuild DB on A.DBBuildId=DB.DBBuildId
where A.DBBuildId in(select DBBuildId from DBBuild where (DBBuildId IN (SELECT item FROM dbo.fnSplit(@DBBuildId,',')) OR  @DBBuildId IS NULL)) And a.DBScriptType in(6,7,8))
as res1 on res.BuildName=res1.BuildName and res.ScriptName=res1.ScriptName)
SELECT ScriptName,Script,BuildName,DBScriptType FROM cte WHERE RowNumber=1 ORDER BY BuildName,DBScriptType	
END
GO
/****** Object:  StoredProcedure [dbo].[spGetAllUserRoles]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetAllUserRoles] 
 @usrId AS UNIQUEIDENTIFIER
AS
BEGIN
 SET NOCOUNT ON;
 DECLARE @cols AS NVARCHAR(MAX), @query  AS NVARCHAR(MAX);

 SET @cols = STUFF((SELECT distinct ',' + QUOTENAME(roleTable.name)
            FROM [Role] roleTable
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)') 
        ,1,1,'')

 
 set @query = 'SELECT *
 FROM (
  SELECT usr.UserId, usr.username as UserName
   ,rl.NAME,
   cast(case usr.userid when NULL then 0 else 1 end as int) as usrid
  FROM [Role] AS rl
  LEFT OUTER JOIN [UserRole] AS usrl ON (usrl.[RoleId] = rl.[RoleId])
  RIGHT OUTER JOIN [User] AS usr ON (usr.[UserId] = usrl.[UserId])' 
  + case when @usrId is not null then 
  	' where cast(usr.userid as varchar(50))=''' + cast(@usrId as varchar(50)) + ''''
  	else 'where usr.LoginName <> ''admin'''  end
 + 
 ') AS sr
 pivot(MAX(usrid) FOR Name IN (' + @cols + ' )) AS pitable'

 
execute(@query)
END
GO
/****** Object:  StoredProcedure [dbo].[spGetAllUsers]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================  
-- Author:  Avadhesh kumar  
-- Create date: 4 July 2019  
-- Description: Get All Active Users  
-- ========================================================  
CREATE PROCEDURE [dbo].[spGetAllUsers]  
  @UserId UNIQUEIDENTIFIER = NULL  
AS  
BEGIN  
 SELECT DISTINCT UserId,UserName,LoginName FROM [dbo].[User] WHERE status=0 and EmployeeId is null  AND (@UserId IS NULL OR UserId=@UserId) ORDER BY UserName  
END
GO
/****** Object:  StoredProcedure [dbo].[spGetAssignedProject]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetAssignedProject]
	@Userid UNIQUEIDENTIFIER
AS
BEGIN
	 SELECT CAST(UPPER(P.ProjectId) as UNIQUEIDENTIFIER)ProjectId ,Name FROM  Project P 
	INNER JOIN ProjectPermission PP ON P.ProjectId=PP.ProjectId WHERE UserId= @Userid
	ORDER BY Name
END
GO
/****** Object:  StoredProcedure [dbo].[spGetAttachments]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  PROCEDURE [dbo].[spGetAttachments]
	@TaskId UNIQUEIDENTIFIER
AS
BEGIN
	 SELECT AttachmentId,EntityId,FileName,UploadedOn FROM Attachment WHERE EntityId=@TaskId
END
GO
/****** Object:  StoredProcedure [dbo].[spGetAttendance]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetAttendance]
    @EmployeeId     uniqueidentifier,
    @Day            int=null,
    @Month          int,
    @Year           int
AS
BEGIN
    SET NOCOUNT ON;
    declare @date date
 
 --set @date = CONVERT(datetime,CONVERT(varchar(10),@Year) + '-' +CONVERT(varchar(10),@Month) + '-' +CONVERT(varchar(10),@Day),103)
 set @date = cast(CONVERT(varchar(10),@Year) + '-' +CONVERT(varchar(10),@Month) + '-' +CONVERT(varchar(10),@Day) as datetime)
    SELECT 
        @EmployeeId AS EmployeeId,
        a.AttendanceId,
        a.InTime,
        a.OutTime,
        CASE WHEN a.OutTime IS NOT NULL THEN LEFT(CONVERT(VARCHAR(12), DATEADD(mi, DATEDIFF(mi, a.InTime, a.OutTime), 0), 114),5)
             WHEN a.TimeInMinutes IS NOT NULL THEN RIGHT('0' + CAST(a.TimeInMinutes/60 AS VARCHAR(5)),2) + ':' + RIGHT('0' + cast(a.TimeInMinutes%60 AS VARCHAR(2)), 2)
             ELSE NULL END AS TotalTime,
        ISNULL(a.Attendance,2) AS Attendance,
        ISNULL(a.IsWorkFromHome,0) AS IsWorkFromHome,
        --a.TimeInMinutes,
        yd.YearDayDate AS [Date],
        CASE WHEN hd.Name IS NOT NULL THEN hd.Name
             WHEN od.Remarks IS NOT NULL THEN od.Remarks
        ELSE NULL END AS [DayDescription],
        CASE WHEN a.AttendanceDate IS NOT NULL AND a.IsWorkFromHome=0 AND a.AttendanceDate <> CONVERT(DATE,@date) AND (a.InTime IS NOT NULL AND a.OutTime IS NULL) THEN ' Incomplete '
    WHEN a.AttendanceDate IS NOT NULL AND Attendance=1.0 THEN 'Present'              
             WHEN a.AttendanceDate IS NOT NULL AND Attendance=0.5 THEN 'Present (Half Day)'             
             WHEN l.LeaveDate IS NOT NULL AND l.LeaveCount=1.0 AND l.IsApproved=1 THEN 'Leave - ' + l.LeaveType  
             WHEN l.LeaveDate IS NOT NULL AND l.LeaveCount=0.5 AND l.IsApproved=1 THEN 'Leave (Half Day) - ' + l.LeaveType
             WHEN a.AttendanceDate IS NOT NULL AND Attendance=0.0 THEN 'Absent'
        ELSE NULL END AS [Description],        
        CASE WHEN hd.Name IS NOT NULL THEN case when a.Attendance = 1.0 THEN 'P' else'H' end
             WHEN od.Remarks IS NOT NULL then case when a.Attendance = 1.0 THEN 'P' else 'O' end              
             WHEN a.Attendance = 0.0 AND l.LeaveDate IS NULL THEN 'A'
             WHEN a.AttendanceDate IS NOT NULL AND a.IsWorkFromHome=0 AND a.AttendanceDate <> CONVERT(DATE,@date) AND (a.InTime IS NOT NULL AND a.OutTime IS NULL) THEN 'I'
             WHEN a.Attendance = 0.5 OR a.Attendance = 1.0 THEN 'P'
             --WHEN hd.Name IS NOT NULL or od.Remarks IS NOT NULL or l.LeaveDate IS NULL and ((a.InTime IS NULL OR a.OutTime IS NULL) and a.Attendance<>2.0) THEN 'I'             
             WHEN l.LeaveDate IS NOT NULL AND l.IsApproved=1 THEN 'L'             
        ELSE NULL END AS [Type],
        CASE WHEN hd.Remarks IS NOT NULL THEN hd.Remarks
             WHEN l.Remarks IS NOT NULL AND l.IsApproved=1 THEN l.Remarks
             WHEN a.Remarks IS NOT NULL THEN a.Remarks
        ELSE NULL END AS [Remarks]
    FROM YearDay yd
        LEFT JOIN OffDay od ON yd.YearDayDate = od.OffDayDate
        LEFT JOIN Holiday hd ON yd.YearDayDate = hd.HolidayDate
        LEFT JOIN Leave l ON yd.YearDayDate = DATEADD(dd, 0, DATEDIFF(dd, 0, l.LeaveDate)) AND l.EmployeeId = @EmployeeId
        LEFT JOIN Attendance a ON CONVERT(VARCHAR(10),yd.YearDayDate,111) = CONVERT(VARCHAR(10),a.AttendanceDate,111) AND a.EmployeeId = @EmployeeId
    WHERE 
    DatePart(mm,yd.YearDayDate) = @Month AND DatePart(yyyy,yd.YearDayDate) = @Year 
    --AND (DatePart(dd,yd.YearDayDate) = @Day OR @Day IS NULL)
    ORDER BY yd.YearDayDate
END
GO
/****** Object:  StoredProcedure [dbo].[spGetBuildDetail]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetBuildDetail] 
	@VersionId UNIQUEIDENTIFIER = null
AS
BEGIN
	SELECT  V.VersionId, V.ComponentId, V.[Version], V.DBBuilds,VD.DeployedBy, REPLACE(CONVERT(VARCHAR(50),DATEADD(MINUTE,330,VD.DeployedOn),106),' ','-') + ' '+ CONVERT(VARCHAR(50),DATEADD(MINUTE,330,VD.DeployedOn),108) AS DeployedOn, VD.Remarks,DS.SiteName,DS.DeploymentSiteId          
	FROM [Version] V 
	INNER JOIN  VersionDeployment VD ON V.VersionId = VD.VersionId 
    LEFT  JOIN  DeploymentSite DS ON VD.DeploymentSiteId = DS.DeploymentSiteId
	WHERE  VD.VersionID=@VersionId
	ORDER BY VD.DeployedOn DESC 
END
GO
/****** Object:  StoredProcedure [dbo].[spGetCalendar]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =======================================================
-- Author:		Akhilesh Gupta
-- Create date: 11 March 2019
-- Description:	
-- =======================================================
CREATE PROCEDURE [dbo].[spGetCalendar]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM
    (
        SELECT 'Holiday' AS EventType,
               h.HolidayDate AS EventDate,
               Name AS [Name],
               h.Name AS EmpId,
               h.HolidayDate AS OrderByDate,
			   '' AS IsApproved,
			  CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AS EmployeeId,
			  CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AS LeaveId 
        FROM dbo.Holiday h
        UNION ALL
        SELECT 'Birthday' AS EventType,
               DATEFROMPARTS(YEAR(GETDATE()), MONTH(ISNULL(e.OrignalDateOfBirth, e.DateOfBirth)), DAY(ISNULL(e.OrignalDateOfBirth, e.DateOfBirth))) AS EventDate,
               e.FirstName AS [Name],
               u.LoginName AS EmpId,
               DATEFROMPARTS(YEAR(GETDATE()), MONTH(ISNULL(e.OrignalDateOfBirth, e.DateOfBirth)), DAY(ISNULL(e.OrignalDateOfBirth, e.DateOfBirth))) AS OrderByDate,
				'' as IsApproved ,
				 e.EmployeeId,
				CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AS LeaveId
        FROM dbo.Employee e
            INNER JOIN dbo.[User] u
                ON u.EmployeeId = e.EmployeeId
        WHERE e.DateOfBirth IS NOT NULL
              AND e.DateOfRelieving IS NULL AND u.Status=0
        UNION ALL
        SELECT 'Anniversary' AS EventType,
               e.Anniversary AS EventDate,
               e.FirstName + ' ' + ISNULL(e.MiddleName, '') + ' ' + e.LastName AS [Name],
               u.LoginName AS EmpId,
               DATEFROMPARTS(YEAR(GETDATE()), MONTH(e.Anniversary), DAY(e.Anniversary)) AS OrderByDate,
				'' as IsApproved,
				e.EmployeeId,
				CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AS LeaveId
        FROM dbo.Employee e
            INNER JOIN dbo.[User] u
                ON u.EmployeeId = e.EmployeeId
        WHERE e.Anniversary IS NOT NULL
              AND e.DateOfRelieving IS NULL
        UNION ALL
        SELECT CASE WHEN l.LeaveCount=1.0 THEN 'FullDay' 
					ELSE CASE WHEN l.IsSecondHalf IS NOT NULL AND l.IsSecondHalf=1 THEN '2ndHalf' ELSE '1stHalf' END
				END AS EventType,
               l.LeaveDate AS EventDate,
               e.FirstName AS [Name],
               u.LoginName AS EmpId,
               l.LeaveDate AS OrderByDate,
			   l.IsApproved AS IsApproved,
			   e.EmployeeId,
			   l.LeaveId
        FROM dbo.Leave l
            LEFT OUTER JOIN dbo.Employee e
                ON e.EmployeeId = l.EmployeeId
               INNER JOIN dbo.[User] u
                ON u.EmployeeId = e.EmployeeId
    ) tmp 
	WHERE YEAR(tmp.OrderByDate)>=year(GETDATE())-4 /*Last 4 years calender data*/

    ORDER BY OrderByDate, EmpId;
END;
GO
/****** Object:  StoredProcedure [dbo].[spGetCalendarV2]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ================================================
-- Author       : Abhishek Ranjan
-- Create date  : 16-Jan-2020
-- Description	: 
-- Parameters	: 
-- ================================================
CREATE PROCEDURE [dbo].[spGetCalendarV2]
AS
BEGIN
    SET NOCOUNT ON;

	--DECLARE @StartDate DATETIME=DATEADD(MONTH,-1,GETDATE()), @EndDate DATETIME=DATEADD(MONTH,1,GETDATE())

    SELECT tmp.EventType, tmp.EventDate, tmp.Name, tmp.EmpId, tmp.OrderByDate, tmp.IsApproved, tmp.EmployeeId, tmp.LeaveId
    FROM
    (
        SELECT 'holiday' AS EventType,
               h.HolidayDate AS EventDate,
               Name AS [Name],
               h.Name AS EmpId,
               h.HolidayDate AS OrderByDate,
			   '' AS IsApproved,
			  CAST(CAST(0 AS BINARY(1)) AS UNIQUEIDENTIFIER) AS EmployeeId,
			  CAST(CAST(0 AS BINARY(1)) AS UNIQUEIDENTIFIER) AS LeaveId 
        FROM dbo.Holiday h
        UNION ALL
        SELECT 'birthday' AS EventType,
               DATEFROMPARTS(YEAR(GETDATE()), MONTH(ISNULL(e.OrignalDateOfBirth, e.DateOfBirth)), DAY(ISNULL(e.OrignalDateOfBirth, e.DateOfBirth))) AS EventDate,
               e.FirstName AS [Name],
               u.LoginName AS EmpId,
               DATEFROMPARTS(YEAR(GETDATE()), MONTH(ISNULL(e.OrignalDateOfBirth, e.DateOfBirth)), DAY(ISNULL(e.OrignalDateOfBirth, e.DateOfBirth))) AS OrderByDate,
				'' as IsApproved ,
				 e.EmployeeId,
				CAST(CAST(0 AS BINARY(1)) AS UNIQUEIDENTIFIER) AS LeaveId
        FROM dbo.Employee e
            INNER JOIN dbo.[User] u
                ON u.EmployeeId = e.EmployeeId
        WHERE e.DateOfBirth IS NOT NULL
              AND e.DateOfRelieving IS NULL AND u.Status=0
        UNION ALL
        SELECT CASE WHEN l.LeaveCount=1.0 THEN 'full-day' 
					ELSE CASE WHEN l.IsSecondHalf IS NOT NULL AND l.IsSecondHalf=1 THEN 'second-half' ELSE 'first-half' END
				END AS EventType,
               l.LeaveDate AS EventDate,
               e.FirstName AS [Name],
               u.LoginName AS EmpId,
               l.LeaveDate AS OrderByDate,
			   l.IsApproved AS IsApproved,
			   e.EmployeeId,
			   l.LeaveId
        FROM dbo.Leave l
            LEFT OUTER JOIN dbo.Employee e
                ON e.EmployeeId = l.EmployeeId
               INNER JOIN dbo.[User] u
                ON u.EmployeeId = e.EmployeeId
    ) tmp 
	WHERE 1=1 
		AND YEAR(tmp.OrderByDate)>=YEAR(GETDATE())-2 /*Last 2 years calender data*/
		--AND tmp.OrderByDate BETWEEN @StartDate AND @EndDate

    ORDER BY OrderByDate, EmpId;
END;
GO
/****** Object:  StoredProcedure [dbo].[spGetComment]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetComment] 
 @EntityType int,
 @EntityId uniqueidentifier

AS
BEGIN


 SET NOCOUNT ON;

    SELECT CommentId,EntityType,EntityId,Comment,CreatedBy,CreatedOn,ModifiedBy,ModifiedOn
    FROM  Comment
    WHERE  EntityType = @EntityType AND EntityId = @EntityId
    
END
GO
/****** Object:  StoredProcedure [dbo].[spGetComments]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetComments] 
 @EntityType int,
 @EntityId uniqueidentifier

AS
BEGIN

 SET NOCOUNT ON;

    SELECT ROW_NUMBER() OVER(ORDER BY c.CreatedOn DESC) AS RowNo,
	CommentId,EntityType,EntityId,replace(Comment,'<br />','</n>') as Comment ,c.CreatedBy,c.CreatedOn,c.ModifiedBy,c.ModifiedOn,u.UserName,u.LoginName,
    Comment AS OriginalComment
    FROM  Comment c
	left outer join [user] u on c.CreatedBy = u.UserId 
    WHERE  EntityType = @EntityType AND EntityId = @EntityId
    ORDER BY c.CreatedOn DESC,c.EntityType DESC
END
GO
/****** Object:  StoredProcedure [dbo].[spGetComponents]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetComponents]
    @ProjectId UNIQUEIDENTIFIER = NULL,
	@ComponentId UNIQUEIDENTIFIER = NULL 
AS
BEGIN
    SET NOCOUNT ON;
    SELECT C.ComponentId,C.ProjectId,C.Name,C.CreatedBy,C.CreatedOn,isnull(T.TaskCount,0)AssociatedTaskCount,isnull(IsDBComponent,0)IsDBComponent,
    isnull(IsVersionComponent,0)IsVersionComponent,GitUrl,BuildPrefixForConfig
    FROM   Component  c
	left outer join 
	(select count(*) TaskCount,ComponentId from Task group by ComponentId) T
	 on T.ComponentId =  C.ComponentId
    WHERE  ProjectId = @ProjectId
	AND	ISNULL(c.Name,'') <> ''
	AND (@ComponentId IS NULL OR C.ComponentId = @ComponentId)
    ORDER BY Name
END
GO
/****** Object:  StoredProcedure [dbo].[spGetComponentsByType]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================
-- Author       : Ankit Sharma
-- Create date  : 25-April-2016
-- Description  : Get All Components/Projects.
-- Parameters   : 
-- ==============================================================
CREATE PROCEDURE [dbo].[spGetComponentsByType] 
@ProjectId UNIQUEIDENTIFIER=NULL,
@IsDBComponent  BIT=NULL	,
@IsVersionComponent BIT=NULL
AS
BEGIN
	SET NOCOUNT ON;
	SELECT ComponentId, Name FROM Component 
	WHERE (ProjectId = @ProjectId OR @ProjectId IS NULL) 
	AND (IsDBComponent = @IsDBComponent OR @IsDBComponent IS NULL)
	AND (IsVersionComponent = @IsVersionComponent OR @IsVersionComponent IS NULL)
	ORDER BY Name
END
GO
/****** Object:  StoredProcedure [dbo].[spGetConfigValue]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [dbo].[spGetConfigValue]
AS
BEGIN
	select dbo.fnGetConfigValue('DBInfo','Build') as ConfigValue
END
GO
/****** Object:  StoredProcedure [dbo].[spGetContainers]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--=============================================
-- Author:		Ankit Sharma 
-- Create date: 02 May 2016
-- Description  : Get non deleted containers
-- EXEC [spGetContainers] 
-- =============================================
CREATE PROCEDURE [dbo].[spGetContainers]
@IsAdminRole BIT,
@UserId UNIQUEIDENTIFIER = NULL,
@ContainerId UNIQUEIDENTIFIER = NULL,
@ContainerName NVARCHAR(250) = NULL
AS
BEGIN
	SELECT ContainerId,[Name],[Folders]  FROM [Container]
	WHERE ISNULL(IsDeleted,0)=0
	AND @IsAdminRole = 1 OR (@UserId IS NULL OR ContainerId IN (Select ContainerId from UserContainer where UserId = @UserId))
	AND (@ContainerId IS NULL OR ContainerId = @ContainerId)
	AND (@ContainerName IS NULL OR Name = @ContainerName)
	ORDER BY [NAME]

END
GO
/****** Object:  StoredProcedure [dbo].[spGetDataFiles]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetDataFiles]
		@DataFileId uniqueidentifier = NULL,
		@ClientId uniqueidentifier
AS
BEGIN
	
	SET NOCOUNT ON;
	
    SELECT	DataFileId,DataRequestId,Name,Description,Source,SQLQuery,d.CleaningProcess,d.Status,CreatorContactInfo,FileUploaded,UploadedBy,UploadedOn,OwnerId,d.CreatedBy,d.CreatedOn
			,d.ModifiedBy,d.ModifiedOn, u.UserName AS 'UploadedByUserName',d.FileNumber,uu.UserName AS 'CreatedByUserName'
    FROM	DataFile d
    LEFT JOIN [User] u ON u.UserId = d.UploadedBy
    LEFT JOIN [User] uu ON uu.UserId = d.CreatedBy
    WHERE	(DataFileId = @DataFileId OR @DataFileId IS null) AND d.ClientId=@ClientId
    ORDER BY d.Name
END
GO
/****** Object:  StoredProcedure [dbo].[spGetDataFilesByDataRequestId]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetDataFilesByDataRequestId]
		@DataRequestId uniqueidentifier = null
AS
BEGIN
	
	SET NOCOUNT ON;
	
    SELECT	DataFileId,DataRequestId,FileType,Name,FileNumber,Description,Path,Source,SQLQuery,d.CleaningProcess,d.Status,CreatorContactInfo,FileUploaded,UploadedBy,UploadedOn,OwnerId,d.CreatedBy,d.CreatedOn
			,d.ModifiedBy,d.ModifiedOn, u.UserName AS 'UploadedByUserName'
    FROM	DataFile d
    LEFT JOIN [User] u ON u.UserId = d.UploadedBy
    WHERE	(DataRequestId = @DataRequestId OR @DataRequestId IS null)
    ORDER BY d.Name
END
GO
/****** Object:  StoredProcedure [dbo].[spGetDataRequestUsers]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetDataRequestUsers]
	@ClientId UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;
	
	IF (@ClientId is null OR @ClientId = '00000000-0000-0000-0000-000000000000')
	BEGIN
	    SELECT UserName,
	           UserId
	    FROM   [User]
	    WHERE  STATUS = 0 and ClientId is null
	END
	ELSE
	BEGIN
	    SELECT U.UserName,
	           U.UserId
	    FROM   Client c
	           JOIN [User] U ON  c.ClientId = U.ClientId
	    WHERE  U.Status = 0 AND u.ClientId = @ClientId
	END
END
GO
/****** Object:  StoredProcedure [dbo].[spGetDBBuilds]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Pabitra Dash
-- Create date: 13/03/2014
-- Description:	Get DBBuilds for a given Component Ids
-- =============================================
CREATE PROCEDURE [dbo].[spGetDBBuilds] 
	@ComponentId UNIQUEIDENTIFIER
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Select Name, DBBuildId, IsLocked from DBBuild where ComponentId = @ComponentId  ORDER BY Name
END
GO
/****** Object:  StoredProcedure [dbo].[spGetDbScriptsByDBBuild]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Pabitra Dash
-- Create date: 13/03/2014
-- Description:	Returns all DB scripts for a given DB Build
-- =============================================
CREATE PROCEDURE [dbo].[spGetDbScriptsByDBBuild]
	@DBBuildId UNIQUEIDENTIFIER
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT Name, [Description], Reference, DBScriptType, DBChangeType, Script, Sequence, ChangedBy, ChangedOn 
	From DBScript 
	WHERE DBBuildId = @DBBuildId
END
GO
/****** Object:  StoredProcedure [dbo].[spGetDBSnapshots]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =========================================
-- Author       : Akhilesh Gupta
-- Create date  : 13-March-2019
-- Description	: Get DB Snapshots
-- Parameters	: @Tables - comma separated table names
-- =========================================
CREATE PROCEDURE [dbo].[spGetDBSnapshots]
	@Tables varchar(500) = NULL,
	@TimeTaken INT = NULL OUT
AS
BEGIN
   	SET NOCOUNT ON;
	DECLARE @InitTime DATETIME = GETDATE()

	DECLARE @MaxModifiedOn datetime2
	DECLARE @MetaTable TABLE(TableName varchar(50), MaxModifiedOn datetime2)

	IF(@Tables IS NULL OR CHARINDEX(',Employee,', @Tables) > 0)
	BEGIN
		SELECT EmployeeId,
		 RTRIM(LTRIM(ISNULL(e.FirstName,'') + ' ' + LTRIM(ISNULL(e.MiddleName,'') + ' ' + ISNULL(e.LastName,'')))) AS FullName,
		 Designation, Gender, DateOfBirth
		FROM Employee e
		--Metatable
		INSERT INTO @MetaTable(TableName) VALUES('Employee')
	END

	IF(@Tables IS NULL OR CHARINDEX(',Holiday,', @Tables) > 0)
	BEGIN
		SELECT HolidayDate, [Name], Remarks FROM Holiday
		--Metatable
		INSERT INTO @MetaTable(TableName) VALUES('Holiday')
	END

	IF(@Tables IS NULL OR CHARINDEX(',Leave,', @Tables) > 0)
	BEGIN
		SELECT LeaveId, EmployeeId, LeaveDate, LeaveType, LeaveCount, Remarks, IsApproved FROM Leave
		--Metatable
		INSERT INTO @MetaTable(TableName) VALUES('Leave')
	END

	IF(@Tables IS NULL OR CHARINDEX(',Attendance,', @Tables) > 0)
	BEGIN
		SELECT AttendanceId, EmployeeId, AttendanceDate, Attendance, InTime, OutTime, IsWorkFromHome, TimeInMinutes FROM Attendance
		--Metatable
		INSERT INTO @MetaTable(TableName) VALUES('Attendance')
	END

	
	--Select Metatable at last
	SELECT mt.* FROM @MetaTable mt	

	SET @TimeTaken=DATEDIFF(millisecond, @InitTime, GETDATE())

END
GO
/****** Object:  StoredProcedure [dbo].[spGetDetailVersionData]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetDetailVersionData]
	@VersionId UNIQUEIDENTIFIER = NULL ,
	@TaskId UNIQUEIDENTIFIER = NULL
AS
BEGIN
	DECLARE @TaskKey NVARCHAR(50)=''
	IF(@TaskId IS NOT NULL)
	BEGIN
		SELECT @TaskKey = [Key] FROM Task WHERE TaskId = @TaskId
	END
	select vc.VersionChangeId,vc.VersionId,vc.Reference,vc.FileChanges,vc.DBChanges,vc.[Description],vc.ChangedBy,vc.ChangedOn,vc.QAStatus,tblOption.OptionName as IssueName 
	,v.Version, v.DBBuilds,t.TaskType,t2.TypeName [Type],t.PriorityType,t3.TypeName [Priority],t.Summary,usr.LoginName,CAST(dbo.fnGetNumericInAlphaNumeric(vc.Reference) AS INT) NumReference
	into #tmpVersionDetail
	from VersionChange vc
	left join Task t on t.[Key]=vc.Reference
	LEFT JOIN [Types] t2 ON t2.TypeId=t.TaskType AND t2.CategoryId=102
	LEFT JOIN [Types] t3 ON t3.TypeId=t.PriorityType AND t3.CategoryId=103
	INNER JOIN Version v ON v.VersionId = vc.VersionId
	 left join 
	 (
			SELECT OptionName, OptionValue FROM [Option] 
			INNER JOIN OptionSet ON [Option].OptionSetId = OptionSet.OptionSetId
			WHERE OptionSet.EntityType = 9
	 )TBLOPTION ON tblOption.OptionValue=vc.QAStatus
	 LEFT JOIN [User] usr ON usr.UserName=vc.ChangedBy
	WHERE (@VersionId IS NULL OR vc.VersionId = @VersionId )
	  AND (@TaskId IS NULL OR isnull(vc.Reference,'') = isnull(@TaskKey,'') )
	ORDER BY NumReference DESC
	select * from #tmpVersionDetail ORDER BY NumReference DESC
	select VersionChangeCommitId,VersionChangeId,GitCommitId,CommittedBy,CommittedOn,CommittedFiles,[Description] as CommittedDescription,u.LoginName,u.UserName
	from VersionChangeCommit as vcc
	left join [User] u on u.UserId=vcc.CommittedBy
	where VersionChangeId in (select VersionChangeId from #tmpVersionDetail)
	order by vcc.CommittedOn DESC
END
GO
/****** Object:  StoredProcedure [dbo].[spGetDistinctTaskAreaByProject]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetDistinctTaskAreaByProject]	
@ProjectId UNIQUEIDENTIFIER = NULL
AS
BEGIN
		SET NOCOUNT ON;
		SELECT DISTINCT ISNULL(Area,'') as 'Area' FROM Task  where (@ProjectId IS NULL OR ProjectId=@ProjectId) order by Area
END
GO
/****** Object:  StoredProcedure [dbo].[spGetDistinctUserName]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetDistinctUserName]	
AS
BEGIN
		SET NOCOUNT ON;
		SELECT DISTINCT Reporter as 'UserName' FROM Task
		UNION
		SELECT DISTINCT Assignee as 'UserName' FROM Task
		EXCEPT
		SELECT [UserName] FROM [User] WHERE STATUS=1
END
GO
/****** Object:  StoredProcedure [dbo].[spGetDownloadFile]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetDownloadFile]	
	@DownloadFileId uniqueidentifier,
	@Folder nvarchar(250) OUT,
	@File	VARCHAR(500) OUT
	
AS
BEGIN	
	-- interfering with SELECT statements.
	SET NOCOUNT ON;    
	SELECT	@Folder = Folder,
			@File = [File]
	FROM DownloadFile WHERE DownloadFileId = @DownloadFileId
	print @Folder
	print @File
END
GO
/****** Object:  StoredProcedure [dbo].[spGetEmailTepmlate]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetEmailTepmlate] 
@TemplateName VARCHAR(50)=null
AS
BEGIN
	SET NOCOUNT ON;

  SELECT EmailTemplateId,TemplateName, FromEmailId, ToEmailId, CCEmailId,
         [Subject], Body, [Status]
    FROM EmailTemplate WHERE (TemplateName = @TemplateName OR @TemplateName IS NULL)
  
END
GO
/****** Object:  StoredProcedure [dbo].[spGetEmployee]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetEmployee] 
	@EmployeeId VARCHAR(50) = NULL
AS
BEGIN

    SET NOCOUNT ON;

    SELECT U.UserId, E.EmployeeId, FirstName, MiddleName, LastName,
           REPLACE(FirstName + ' ' + ISNULL(MiddleName, '') + ' ' + ISNULL(LastName, ''), '  ', ' ') AS FullName, Designation, Gender, DateOfBirth,
           ISNULL(DateOfBirth, OrignalDateOfBirth) AS DateOfBirthDocumentorOriginal, Anniversary, Remarks, DateOfJoining, DateOfRelieving, PanNo, FatherName,
           EmployeeType, BankDetail, OrignalDateOfBirth, U.LoginName
    FROM dbo.Employee E
        LEFT JOIN [User] U ON E.EmployeeId = U.EmployeeId
    WHERE (E.EmployeeId = @EmployeeId OR @EmployeeId IS NULL) AND E.EmployeeId NOT IN ( SELECT EmployeeId FROM Employee WHERE EmployeeType = 'WH' )
          AND U.[Status] = 0
    ORDER BY FirstName;
END;
GO
/****** Object:  StoredProcedure [dbo].[spGetEmployeeAttendance]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ================================================
-- Author       : Avadhesh kumar
-- Create date  : 07-Jan-2020
-- Description	: 
-- Parameters	: 
-- ================================================
CREATE PROCEDURE [dbo].[spGetEmployeeAttendance] 
	@Period DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @DateList VARCHAR(MAX),
            @DateList2 VARCHAR(MAX),
            @DynamicColumnList VARCHAR(MAX),
            @StartDate DATETIME,
            @EndDate DATETIME;

    SELECT @StartDate = DATEADD(dd, - (DAY(@Period) - 1), @Period);
    SELECT @EndDate = DATEADD(dd, - (DAY(DATEADD(mm, 1, @Period))), DATEADD(mm, 1, @Period))
    
	;WITH CTE AS 
	(
		SELECT CONVERT(DATE, @StartDate) AS YearDayDate
        UNION ALL
        SELECT DATEADD(DAY, 1, YearDayDate) AS YearDayDate FROM CTE WHERE YearDayDate < @EndDate
	)
    SELECT YearDayDate INTO #TempYearDay FROM CTE ORDER BY YearDayDate OPTION (MAXRECURSION 367);

    SET @DateList = STUFF(
                    (
                        SELECT ', [' + CONVERT(VARCHAR(10), YearDayDate, 120) + ']' FROM #TempYearDay
                        WHERE YearDayDate BETWEEN @StartDate AND @EndDate FOR XML PATH('')
                    ),1,1,'');

    SET @DateList2 = STUFF(
          (
              SELECT ', [' + CONVERT(VARCHAR(10), YearDayDate, 120) + '] AS [' + LEFT(CONVERT(VARCHAR(10), DATENAME(DW, YearDayDate)), 3) + 'X' + RIGHT(CONVERT(VARCHAR(10), YearDayDate, 120), 2) + ']'
              FROM #TempYearDay WHERE YearDayDate BETWEEN @StartDate AND @EndDate FOR XML PATH('')
          ),1,1,'');


    CREATE TABLE #tmpTbl
    (
        EmployeeId UNIQUEIDENTIFIER,
        AttendanceId UNIQUEIDENTIFIER,
        InTime DATETIME,
        OutTime DATETIME,
        TotalTime VARCHAR(10),
        Attendance DECIMAL,
        IsWorkFromHome BIT,
        date DATETIME,
        DayDescription NVARCHAR(50),
        DESCRIPTION NVARCHAR(MAX),
        TYPE NVARCHAR(1),
        Remarks NVARCHAR(255)
    );


    DECLARE @EmployeeId UNIQUEIDENTIFIER;
    DECLARE @month INT;
    SELECT @month = DATEPART(mm, @Period);
    DECLARE @year INT;
    SELECT @year = DATEPART(YYYY, @Period);

    DECLARE curAttendance CURSOR FOR
    SELECT DISTINCT
           e.EmployeeId
    FROM Employee e
    WHERE e.EmployeeId NOT IN
          (
              SELECT e.EmployeeId FROM Employee e WHERE e.EmployeeType = 'WH'
          );
    OPEN curAttendance;

    FETCH NEXT FROM curAttendance
    INTO @EmployeeId;

    WHILE @@Fetch_Status = 0
    BEGIN
        --... do whatever you want ...
        INSERT INTO #tmpTbl
        EXEC spGetAttendance @EmployeeId, NULL, @month, @year;

        FETCH NEXT FROM curAttendance
        INTO @EmployeeId;
    END;

    CLOSE curAttendance;
    DEALLOCATE curAttendance;

    --select * from [#tmpTbl]
    SET @DynamicColumnList
        = 'SELECT [EmployeeName],' + @DateList2
          + 'FROM
    (
        SELECT a.[EmployeeId]
                ,Replace(e.[FirstName] + '' '' + ISNULL(e.[MiddleName],'''') + '' '' + isnull(e.[LastName],''''),''  '','' '') AS EmployeeName
                ,[date],
                Case Type When ''L'' then a.Type + ''-'' + l.LeaveType else a.Type + '' '' + concat(cast(isnull(+'',TotalTime:''+a.TotalTime,'''') as varchar),+'',InTime:''+right(a.InTime,7), +'',OutTime:''+right(a.OutTime,6)) end as Attendance
               
        FROM     [dbo].[#tmpTbl] a
        LEFT JOIN Employee e ON a.EmployeeId = e.EmployeeId
        LEFT JOIN Leave l ON e.EmployeeId = l.EmployeeId and CONVERT(DATE, a.date) = CONVERT(DATE, l.leavedate)
        LEFT JOIN [User]  u ON e.EmployeeId = u.EmployeeId
        WHERE Status=0    
    ) as A
    Pivot
    (
    MAX([Attendance])
    FOR date IN (' + @DateList + ')
    ) as P';


    PRINT @DynamicColumnList;
    EXEC (@DynamicColumnList);
    DROP TABLE #TempYearDay;
    DROP TABLE #tmpTbl;

END;
GO
/****** Object:  StoredProcedure [dbo].[spGetEmployeeForMap]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================
-- Author:		Avadhesh kumar
-- Create date: 17 June 2019
-- Description: Get employees
-- ========================================================
CREATE PROCEDURE [dbo].[spGetEmployeeForMap]
AS   
BEGIN   
	SET NOCOUNT ON;    
	SELECT EmployeeId  ,isnull(FirstName,' ')+' '+isnull(MiddleName,' ')+' '+isnull(LastName,' ') AS [Name], FirstName, MiddleName, LastName, Designation, Gender, DateOfBirth,  
	MapStatus FROM [dbo].[Employee]  
END
GO
/****** Object:  StoredProcedure [dbo].[spGetEmployeeLeaveCount]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spGetEmployeeLeaveCount]
	@EmployeeId uniqueidentifier=null
as
begin
	set nocount on;
	declare @CurrentDate datetime=getdate()
	declare @CurrentYear int = year(getdate())
	declare @StartDate datetime='2014-01-01'
	declare @CurrentYearDate datetime = cast(cast(year(getdate()) as varchar) + '-01-01' as datetime)
	;with cte1 as
	(
		select e.EmployeeId,e.FirstName,e.MiddleName,e.LastName, 
		--datediff(m,@CurrentYearDate,@CurrentDate)+1 as MaxCL,
		case when DateOfJoining > @CurrentYearDate then datediff(m,e.DateOfJoining,@CurrentDate)+1 else datediff(m,@CurrentYearDate,@CurrentDate)+1 end as MaxCL,
		case when DateOfJoining > @StartDate and day(DateOfJoining) > 15 then -1 else 0 end DoJ,
		case when DateOfJoining > @StartDate then (datediff(m,e.DateOfJoining,@CurrentDate)+1) * 1.25 else (datediff(m,@StartDate,@CurrentDate)+1) * 1.25 end as MaxEL,
		case when DateOfJoining > @StartDate then (datediff(m,e.DateOfJoining,@CurrentDate)+1) * .5 else (datediff(m,@StartDate,@CurrentDate)+1) * .5 end as MaxSL
		from employee e
		WHERE DateOfJoining <= ''+ convert(nvarchar, @CurrentDate,112)+'' or (DateOfRelieving is null and DateOfRelieving > ''+ convert(nvarchar, @CurrentDate,112)+'') and e.EmployeeType <> 'WH'	
	),
	cte2 as
	(
		select 
			l.EmployeeId,
			rtrim(Replace(e.FirstName + ' ' + isnull(e.MiddleName,'') + ' ' + isnull(e.LastName,''), '  ',' ')) as EmployeeName,
			(select sum(LeaveCount) from leave l2 where l2.EmployeeId = l.EmployeeId and LeaveType='CL' and year(LeaveDate)=@CurrentYear and IsApproved=1) CL,
			(select sum(LeaveCount) from leave l2 where l2.EmployeeId = l.EmployeeId and LeaveType='EL' and year(LeaveDate) in (2014, 2015, 2016, 2017, 2018, 2019, 2020) and IsApproved=1) EL,
			(select sum(LeaveCount) from leave l2 where l2.EmployeeId = l.EmployeeId and LeaveType='SL' and year(LeaveDate) in (2014, 2015, 2016, 2017, 2018, 2019, 2020) and IsApproved=1) SL
		from leave l
		inner join employee e on l.EmployeeId = e.EmployeeId
		WHERE DateOfJoining <= ''+ convert(nvarchar, @CurrentDate,112)+'' or (DateOfRelieving is null or DateOfRelieving > ''+ convert(nvarchar, @CurrentDate,112)+'') and e.EmployeeType <> 'WH'
		group by l.EmployeeId,rtrim(Replace(e.FirstName + ' ' + isnull(e.MiddleName,'') + ' ' + isnull(e.LastName,''), '  ',' '))
	)

	select 
		cte2.EmployeeId, 
		cte2.EmployeeName,
		--cte1.DoJ,
		--cte1.MaxCL [TotalCL],
		case when cte1.DoJ = -1 then cte1.MaxCL - 1 else cte1.MaxCL end [TotalCL],
		isnull(cte2.[CL],0) CL,
		case when cte1.DoJ = -1 then cte1.MaxEL - 1.25 else cte1.MaxEL end [TotalEL],
		isnull(cte2.[EL],0) EL,
		case when cte1.DoJ = -1 then cte1.MaxSL - 0.5  else cte1.MaxSL end [TotalSL],
		isnull(cte2.[SL],0) SL
	from
	cte1 inner join cte2 on cte1.EmployeeId = cte2.EmployeeId
	where cte2.EmployeeId = @EmployeeId or @EmployeeId is null
	order by cte2.EmployeeName
end
GO
/****** Object:  StoredProcedure [dbo].[spGetEmployeeLeaveCountV2]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ================================================
-- Author       : Abhishek Ranjan
-- Create date  : 22-Jan-2020
-- Description	: 
-- Parameters	: 
-- ================================================
CREATE PROCEDURE [dbo].[spGetEmployeeLeaveCountV2] 
	@EmployeeId UNIQUEIDENTIFIER=null
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @year INT=2014, 
			@StartDate DATETIME = '2014-01-01',
			@CurrentDate DATETIME = GETDATE(),
			@CurrentYearDate DATETIME = CAST(CAST(YEAR(GETDATE()) AS VARCHAR) + '-01-01' AS DATETIME)

	;WITH cte_name AS
	(
		SELECT @year yyyy
		UNION ALL
		SELECT yyyy+1 FROM cte_name WHERE yyyy < DATEPART(YEAR, GETDATE())
	)
	SELECT yyyy INTO #years FROM cte_name  ORDER BY yyyy OPTION (MAXRECURSION 100) 

	;WITH cte1 
	AS (
			SELECT e.EmployeeId, e.FirstName, e.MiddleName, e.LastName, 
			CASE
				WHEN DATEDIFF(DAY, e.DateOfJoining, @CurrentDate) < 15 THEN 0
				WHEN YEAR(e.DateOfJoining) < YEAR(@CurrentDate) THEN DATEDIFF(m, @CurrentYearDate, @CurrentDate) + 1
				WHEN DAY(e.DateOfJoining) < 16 THEN DATEDIFF(m, e.DateOfJoining, @CurrentDate) + 1
				ELSE DATEDIFF(m, e.DateOfJoining, @CurrentDate)	
			END AS MaxCL, 
			CASE WHEN e.DateOfJoining > @StartDate AND DAY(e.DateOfJoining) > 15 THEN -1 ELSE 0 END DoJ, 
			CASE WHEN e.DateOfJoining > @StartDate THEN (DATEDIFF(m, e.DateOfJoining, @CurrentDate) + 1) * 1.25 ELSE (DATEDIFF(m, @StartDate, @CurrentDate) + 1) * 1.25 END AS MaxEL, 
			CASE WHEN e.DateOfJoining > @StartDate THEN (DATEDIFF(m, e.DateOfJoining, @CurrentDate) + 1) * .5 ELSE (DATEDIFF(m, @StartDate, @CurrentDate) + 1) * .5 END AS MaxSL
			FROM dbo.Employee e				
			WHERE E.EmployeeId NOT IN (SELECT EmployeeId FROM Employee WHERE EmployeeType = 'WH')
		),
	cte2
	AS (
		SELECT l.EmployeeId, RTRIM(REPLACE(e.FirstName + ' ' + ISNULL(e.MiddleName, '') + ' ' + ISNULL(e.LastName, ''), '  ', ' ')) AS EmployeeName,
					(
						SELECT SUM(LeaveCount) FROM dbo.Leave l2
						WHERE l2.EmployeeId = l.EmployeeId AND LeaveType = 'CL' AND IsApproved = 1 AND YEAR(LeaveDate) = YEAR(GETDATE())
					) CL,
					(
						SELECT SUM(LeaveCount) FROM dbo.Leave l2
						WHERE l2.EmployeeId = l.EmployeeId AND LeaveType = 'EL' AND IsApproved = 1 AND YEAR(LeaveDate) in (SELECT yyyy FROM #years)
					) EL,
					(
						SELECT SUM(LeaveCount) FROM dbo.Leave l2
						WHERE l2.EmployeeId = l.EmployeeId AND LeaveType = 'SL' AND IsApproved = 1 AND YEAR(LeaveDate) in (SELECT yyyy FROM #years)
					) SL
			FROM dbo.Leave l
				INNER JOIN dbo.Employee e ON l.EmployeeId = e.EmployeeId
			WHERE e.EmployeeId NOT IN (SELECT EmployeeId FROM Employee WHERE EmployeeType = 'WH')
			GROUP BY l.EmployeeId, RTRIM(REPLACE(e.FirstName + ' ' + ISNULL(e.MiddleName, '') + ' ' + ISNULL(e.LastName, ''), '  ', ' '))
		)
	SELECT cte2.EmployeeId, cte2.EmployeeName, cte1.MaxCL AS [TotalCL], 
		ISNULL(cte2.[CL], 0) AS [CL], 
		CASE WHEN cte1.DoJ = -1 THEN cte1.MaxEL - 1.25 ELSE cte1.MaxEL END AS [TotalEL],
		ISNULL(cte2.[EL], 0) [EL], 
		CASE WHEN cte1.DoJ = -1 THEN cte1.MaxSL - 0.5 ELSE cte1.MaxSL END AS [TotalSL],
		ISNULL(cte2.[SL], 0) AS [SL]	
	FROM cte1
		INNER JOIN cte2 ON cte1.EmployeeId = cte2.EmployeeId
		LEFT JOIN dbo.[User] u ON u.EmployeeId = cte1.EmployeeId
	WHERE u.[Status]=0  AND (@EmployeeId IS NULL OR cte1.EmployeeId=@EmployeeId)
	ORDER BY cte2.EmployeeName;
	

	DROP TABLE #years
		
END
GO
/****** Object:  StoredProcedure [dbo].[spGetEmployeeLeaveRecord]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetEmployeeLeaveRecord] 
	@EmployeeStatus nvarchar(100)=null
AS
BEGIN
	SET NOCOUNT ON;

	declare @parameter nvarchar(1000),
	        @query nvarchar(max)
	        
	set @parameter = case @EmployeeStatus
						  when 'Active' then ' DateOfJoining <= getdate() and (DateOfRelieving is null or DateOfRelieving > getdate()) and isnull(EmployeeType,'''') <> ''WH'''
						  else '1=1' end
	set @query =
	'select rtrim(Replace(e.FirstName + '' '' + isnull(e.MiddleName,'''') + '' '' + isnull(e.LastName,''''), ''  '','' '')) as EmployeeName,
		[CL2014],[EL2014],[SL2014],[EW2014],[LWP2014],
		[CL2015],[EL2015],[SL2015],[EW2015],[LWP2015],
        [CL2016],[EL2016],[SL2016],[EW2016],[LWP2016]
	from
	(
		select
			employeeid, 
		[CL2014],[EL2014],[SL2014],[EW2014],[LWP2014],
		[CL2015],[EL2015],[SL2015],[EW2015],[LWP2015],
        [CL2016],[EL2016],[SL2016],[EW2016],[LWP2016]		
		from
			(select employeeid, LeaveType+Cast(Year(LeaveDate) as nvarchar) as LeaveType,LeaveCount 
			 from Leave
			) l
		pivot
		(
			sum(LeaveCount) for LeaveType in ([CL2014],[EL2014],[SL2014],[EW2014],[LWP2014],[CL2015],[EL2015],[SL2015],[EW2015],[LWP2015],[CL2016],[EL2016],[SL2016],[EW2016],[LWP2016])
		)as pvt
	)t
	inner join employee e on t.employeeid = e.employeeid
	 where ' + @parameter + ' 
	order by rtrim(Replace(e.FirstName + '' '' + isnull(e.MiddleName,'''') + '' '' + isnull(e.LastName,''''), ''  '','' ''))'
PRINT @query
	execute(@query)	
END
GO
/****** Object:  StoredProcedure [dbo].[spGetEmployeeLeaveRecordV2]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ================================================
-- Author       : Abhishek Ranjan
-- Create date  : 07-Jan-2020
-- Description	: 
-- Parameters	: 
-- ================================================
CREATE PROCEDURE [dbo].[spGetEmployeeLeaveRecordV2] 
	@EmployeeStatus nvarchar(100)=NULL,
	@EmployeeId UNIQUEIDENTIFIER=null
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @parameter nvarchar(1000), 
			@query nvarchar(max), 
			@year INT=2014, 
			@Cols VARCHAR(MAX), 
			@StartDate DATETIME = '2014-01-01',
			@CurrentDate DATETIME = GETDATE(),
			@CurrentYearDate DATETIME = CAST(CAST(YEAR(GETDATE()) AS VARCHAR) + '-01-01' AS DATETIME)

	;WITH cte_name AS
	(
		SELECT @year yyyy
		UNION ALL
		SELECT yyyy+1 FROM cte_name WHERE yyyy < YEAR(GETDATE())
	)
	SELECT yyyy INTO #years FROM cte_name  ORDER BY yyyy OPTION (MAXRECURSION 100) 
	SELECT DISTINCT LeaveType INTO #leavetype FROM dbo.Leave

	/*******************************************************************************************************************/
	/*******************************************Leave Balance***********************************************************/
	;WITH cte1 
	AS (
			SELECT e.EmployeeId, e.FirstName, e.MiddleName, e.LastName, 
			CASE
				WHEN DATEDIFF(DAY, e.DateOfJoining, @CurrentDate) < 15 THEN 0
				WHEN YEAR(e.DateOfJoining) < YEAR(@CurrentDate) THEN DATEDIFF(m, @CurrentYearDate, @CurrentDate) + 1
				WHEN DAY(e.DateOfJoining) < 16 THEN DATEDIFF(m, e.DateOfJoining, @CurrentDate) + 1
				ELSE DATEDIFF(m, e.DateOfJoining, @CurrentDate)	
			END AS MaxCL, 
			CASE WHEN e.DateOfJoining > @StartDate AND DAY(e.DateOfJoining) > 15 THEN -1 ELSE 0 END DoJ, 
			CASE WHEN e.DateOfJoining > @StartDate THEN (DATEDIFF(m, e.DateOfJoining, @CurrentDate) + 1) * 1.25 ELSE (DATEDIFF(m, @StartDate, @CurrentDate) + 1) * 1.25 END AS MaxEL, 
			CASE WHEN e.DateOfJoining > @StartDate THEN (DATEDIFF(m, e.DateOfJoining, @CurrentDate) + 1) * .5 ELSE (DATEDIFF(m, @StartDate, @CurrentDate) + 1) * .5 END AS MaxSL
			FROM dbo.Employee e				
			WHERE E.EmployeeId NOT IN (SELECT EmployeeId FROM Employee WHERE EmployeeType = 'WH')
		),
		cte2
	AS (
		SELECT l.EmployeeId, RTRIM(REPLACE(e.FirstName + ' ' + ISNULL(e.MiddleName, '') + ' ' + ISNULL(e.LastName, ''), '  ', ' ')) AS EmployeeName,
				   (
					   SELECT SUM(LeaveCount) FROM dbo.Leave l2
					   WHERE l2.EmployeeId = l.EmployeeId AND LeaveType = 'CL' AND IsApproved = 1 AND YEAR(LeaveDate) = YEAR(GETDATE())
				   ) CL,
				   (
					   SELECT SUM(LeaveCount) FROM dbo.Leave l2
					   WHERE l2.EmployeeId = l.EmployeeId AND LeaveType = 'EL' AND IsApproved = 1 AND YEAR(LeaveDate) in (SELECT yyyy FROM #years)
				   ) EL,
				   (
					   SELECT SUM(LeaveCount) FROM dbo.Leave l2
					   WHERE l2.EmployeeId = l.EmployeeId AND LeaveType = 'SL' AND IsApproved = 1 AND YEAR(LeaveDate) in (SELECT yyyy FROM #years)
				   ) SL
			FROM dbo.Leave l
				INNER JOIN dbo.Employee e ON l.EmployeeId = e.EmployeeId				
			WHERE e.EmployeeId NOT IN (SELECT EmployeeId FROM Employee WHERE EmployeeType = 'WH')
			GROUP BY l.EmployeeId, RTRIM(REPLACE(e.FirstName + ' ' + ISNULL(e.MiddleName, '') + ' ' + ISNULL(e.LastName, ''), '  ', ' '))
		)
	SELECT cte2.EmployeeId, (cte1.MaxCL - ISNULL(cte2.[CL], 0)) AS [CL], 
		CASE WHEN cte1.DoJ = -1 THEN ((cte1.MaxEL - 1.25) - ISNULL(cte2.[EL], 0)) ELSE (cte1.MaxEL - ISNULL(cte2.[EL], 0)) END [EL], 
		CASE WHEN cte1.DoJ = -1 THEN ((cte1.MaxSL - 0.5) - ISNULL(cte2.[SL], 0)) ELSE (cte1.MaxSL - ISNULL(cte2.[SL], 0)) END [SL] 
	INTO #LeaveBalance
	FROM cte1
		INNER JOIN cte2 ON cte1.EmployeeId = cte2.EmployeeId
	ORDER BY cte2.EmployeeName;
	/*******************************************Leave Balance***********************************************************/
	/*******************************************************************************************************************/

	SET @Cols = (SELECT '['+CAST(yyyy AS VARCHAR)+LeaveType+'],'  FROM #years,#leavetype
		ORDER BY yyyy
		FOR XML PATH(''))

	SELECT @Cols = LEFT(@Cols, LEN(@Cols)-1);

	
	        
	SET @parameter = CASE @EmployeeStatus WHEN 'all' THEN ' 1=1' ELSE ' u.[Status]=0' END;
	
	IF(@EmployeeId IS NOT NULL)
		SET @parameter = @parameter + ' AND e.EmployeeId='''+CAST(@EmployeeId AS NVARCHAR(36))+'''';

	SET @query =
	'SELECT RTRIM(REPLACE(e.FirstName + '' '' + ISNULL(e.MiddleName,'''') + '' '' + ISNULL(e.LastName,''''), ''  '','' '')) AS EmployeeName, CL, EL, SL, '
		+@Cols+
	'FROM
	(
		SELECT employeeid, ' +@Cols+		
		'FROM
			(
				SELECT employeeid, CAST(YEAR(LeaveDate) as NVARCHAR)+LeaveType AS LeaveType, LeaveCount FROM Leave
			) l
		PIVOT
		(
			SUM(LeaveCount) FOR LeaveType IN ('+@Cols+')
		)AS pvt
	)t
	INNER JOIN dbo.Employee e ON t.EmployeeId = e.EmployeeId
	LEFT JOIN dbo.[User] u ON u.EmployeeId = e.EmployeeId
	INNER JOIN #LeaveBalance lb on t.EmployeeId=lb.EmployeeId
	WHERE ' + @parameter + ' 
	ORDER BY RTRIM(REPLACE(e.FirstName + '' '' + ISNULL(e.MiddleName,'''') + '' '' + ISNULL(e.LastName,''''), ''  '','' ''))'
	
	PRINT @query
	EXECUTE(@query)
	
	DROP TABLE #years
	DROP TABLE #leavetype
	DROP TABLE #LeaveBalance
		
END
GO
/****** Object:  StoredProcedure [dbo].[spGetEmployeeTotalLeave]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[spGetEmployeeTotalLeave]
	 @EmployeeId     UNIQUEIDENTIFIER=NULL,
     @LeaveDate      DATETIME = NULL, 
	 @Year           INT=NULL
AS
BEGIN
   SELECT SUM(LeaveCount) AS TotalLeave 
   FROM   Leave
   WHERE  EmployeeId = @EmployeeId AND (LeaveDate = @LeaveDate OR @LeaveDate IS NULL) AND Year(LeaveDate)=@Year
END
GO
/****** Object:  StoredProcedure [dbo].[spGetHoliday]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ================================================
-- Author       : Abhishek Ranjan
-- Create date  : 21-Jan-2020
-- Description	: 
-- Parameters	: 
-- ================================================
CREATE PROCEDURE [dbo].[spGetHoliday]
@HolidayYear int
AS
BEGIN
SET NOCOUNT ON;
  SELECT HolidayDate,Name,Remarks FROM Holiday
  where DATEPART(yyyy,HolidayDate)= @HolidayYear order by HolidayDate
END

GO
/****** Object:  StoredProcedure [dbo].[spGetLeave]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ================================================
-- Author       : Avadhesh Kumar
-- Create date  : 07-Jan-2020
-- Description	: 
-- Parameters	: 
-- ================================================
CREATE PROCEDURE [dbo].[spGetLeave]
    @EmployeeId UNIQUEIDENTIFIER = NULL, 
	@LeaveDate DATETIME = NULL, 
	@IsAdmin BIT = 0, 
	@Year INT = NULL
AS
BEGIN
    IF @IsAdmin = 0
    BEGIN
        SELECT LeaveId, EmployeeId, LeaveDate, LeaveType, ABS(LeaveCount) LeaveCount, Remarks, IsApproved,IsSecondHalf
        FROM dbo.Leave
        WHERE EmployeeId = @EmployeeId AND (LeaveDate = @LeaveDate OR @LeaveDate IS NULL) AND YEAR(LeaveDate) = @Year
        ORDER BY EmployeeId, LeaveDate;

    END
    ELSE
    BEGIN
        SELECT LeaveId, EmployeeId, LeaveDate, LeaveType, LeaveCount, Remarks, IsApproved,IsSecondHalf
        FROM dbo.Leave
        WHERE (LeaveDate = @LeaveDate OR @LeaveDate IS NULL) AND YEAR(LeaveDate) = @Year
        ORDER BY EmployeeId, LeaveDate;
    END
END
GO
/****** Object:  StoredProcedure [dbo].[spGetLicenseInfo]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetLicenseInfo]
	@LicenseKey		uniqueidentifier,
	@ProductName	VARCHAR(20) OUT,
	@Edition		VARCHAR(10) OUT,
	@Version		VARCHAR(10) OUT,
	@UserCount		int OUT,
	@Mode			VARCHAR(5) OUT,
	@ExpiryDate		Date OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT	@ProductName = Product, 
			@Edition = Edition,
			@Version = Version,
			@UserCount = Users,
			@Mode = Mode,
			@ExpiryDate = ExpiryDate
	FROM License WHERE LicenseId = @LicenseKey
END
GO
/****** Object:  StoredProcedure [dbo].[spGetModuleMenus]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetModuleMenus]
	@ParentModuleName VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
	--declare @ParentModuleName VARCHAR(50)='Administration'
	SELECT m.ModuleId,
	       m.Name,
	       m.PageURL
	FROM   Module m
	       LEFT JOIN module mp
	            ON  (m.ParentModuleId = mp.ModuleId AND m.[Status]=0)
	WHERE  mp.Name = @ParentModuleName AND mp.[Status]=0
	ORDER BY m.Sequence
END
GO
/****** Object:  StoredProcedure [dbo].[spGetModulesByPortal]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetModulesByPortal] 
	@PortalModuleId UNIQUEIDENTIFIER
	,@ForParentDropDown BIT
AS
BEGIN
	SET NOCOUNT ON;

	IF (@ForParentDropDown = 0)
	BEGIN
		
		SELECT m.ModuleId
			,m.Name
			,m.ParentModuleId
			,CASE 
				WHEN m2.ModuleId = @PortalModuleId
					THEN ''
				ELSE isnull(m3.NAME, '') + '/'
				END + m2.NAME AS ParentName
			,m.[PageURL]
			,m.ClientId
			,m.[Description]
			,m.[Status]
			,m.CreatedBy
			,m.CreatedOn
			,m.ModifiedBy
			,m.ModifiedOn
			,m.Sequence
		FROM [Module] m
		LEFT JOIN module m2 ON m.ParentModuleId = m2.ModuleId
		LEFT JOIN module m3 ON m2.ParentModuleId = m3.ModuleId
		WHERE m.ParentModuleId = @PortalModuleId
			OR m2.ParentModuleId = @PortalModuleId
		ORDER BY m.Sequence
	END

	IF (@ForParentDropDown = 1)
	BEGIN
		SELECT CAST ('00000000-0000-0000-0000-000000000000' AS UNIQUEIDENTIFIER) as ModuleId
			,NULL as Name
			,m.ModuleId AS ParentModuleId
			,m.Name AS ParentName
			,NULL AS [PageURL]
			,NULL AS ClientId
			,NULL AS [Description]
			,0 AS [Status]
			,CAST ('00000000-0000-0000-0000-000000000000' AS UNIQUEIDENTIFIER) AS CreatedBy
			,CAST ('1900-01-01 01:01:01.001' AS DATETIME) AS CreatedOn
			,NULL AS ModifiedBy
			,NULL AS ModifiedOn
			,0 as Sequence
		FROM [Module] m
		LEFT JOIN module m2 ON m.ParentModuleId = m2.ModuleId
		LEFT JOIN module m3 ON m2.ParentModuleId = m3.ModuleId
		WHERE (m.ModuleId = @PortalModuleId	OR m.ParentModuleId = @PortalModuleId)
	END
END
GO
/****** Object:  StoredProcedure [dbo].[spGetMonthlyWorkLog]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spGetMonthlyWorkLog]
    @UserId UNIQUEIDENTIFIER = NULL,
    @Period DATE
    AS
    BEGIN
    	SET NOCOUNT ON;  
    DECLARE
    @cols nvarchar(max),
    @stmt nvarchar(max),
    @StartDate DATETIME,
    @EndDate DATETIME
        
    SELECT @StartDate = DATEADD(dd,-(DAY(@Period)-1),@Period)
    SELECT @EndDate   = DATEADD(dd,-(DAY(DATEADD(mm,1,@Period))),DATEADD(mm,1,@Period))    
    
SELECT @cols = isnull(@cols + ', ', '') + '[' + CAST(day(YearDayDate) AS VARCHAR) + ']' FROM YearDay where YearDayDate between @StartDate and @EndDate order by YearDayDate
select @cols = 'Total, ' + @cols
SELECT @stmt = '
  SELECT (case when p.Name is null then cast(ts.projectid as varchar) else p.name end) as Project, 
         C.Name, ts.[Key] as IssueKey, ts.Summary,cast(ts.OriginalEstimate/60.0 as decimal(9,2)) Estimate,cast(ts.TimeSpent/60.0 as decimal(9,2)) TimeSpent,cast(ts.RemainingEstimate/60.0 as decimal(9,2))RemainingEstimate,
  wl.* FROM 
  (
    SELECT *
    FROM 
  (
  select    UserId, TaskId, cast(day(workdate) as varchar) as WorkDate, sum(hours) as Hours
  from Worklog wl
  where (wl.userId = '''+ cast(@UserId AS VARCHAR(40)) +''' or wl.userId is null) and wl.workdate between '''+ cast(@StartDate AS VARCHAR) +''' and ''' + cast(@EndDate AS varchar) + '''
  group by wl.UserId, wl.TaskId, cast(day(workdate) as varchar)
   
  union 
  select    UserId, TaskId, ''Total'' as workdate, sum(hours) as Hours
  from Worklog wl
  where (wl.userId = '''+ cast(@UserId AS VARCHAR(40)) +''' or wl.userId is null)  and wl.workdate between '''+ cast(@StartDate AS VARCHAR) +''' and ''' + cast(@EndDate AS varchar) + '''
  group by wl.UserId, wl.TaskId

  ) T
        PIVOT 
        (
            max(Hours)
            for workdate in (' + @cols + ')
        ) as P
  ) as wl
  left join Task ts on wl.TaskId = ts.TaskId
  left join [User] u on wl.userid = u.UserId
  left join Project p on ts.projectid = p.projectid
  left join Component c on ts.TaskId = c.projectid
  order by Project,IssueKey
  '
        
exec sp_executesql  @stmt = @stmt
end
GO
/****** Object:  StoredProcedure [dbo].[spGetMonthlyWorkLogProject]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spGetMonthlyWorkLogProject]
    @Period DATE
AS
BEGIN
    SET NOCOUNT ON;  
    DECLARE
    @cols nvarchar(max),
    @stmt nvarchar(max),
    @StartDate DATETIME,
    @EndDate DATETIME
        
    SELECT @StartDate = DATEADD(dd,-(DAY(@Period)-1),@Period)
    SELECT @EndDate   = DATEADD(dd,-(DAY(DATEADD(mm,1,@Period))),DATEADD(mm,1,@Period))    
	SELECT @cols = isnull(@cols + ', ', '') + '[' + Code + ']' FROM (SELECT distinct Code FROM Project where isnull(status,0)=0) as T
	select @cols = 'Total, ' + @cols

	SELECT @stmt = '
	select * from
	(
		select p.Code as Project,u.UserName,sum(wl.Hours) as Hours
		from WorkLog wl
		left join [User] u on wl.UserId=u.UserId
		left join JiraIssue ji on wl.JiraIssueId=ji.JiraIssueId
		left join Project p on ji.ProjectId=p.JiraProjectId
		where wl.WorkDate between '''+ cast(@StartDate AS VARCHAR) +''' and ''' + cast(@EndDate AS varchar) + '''
		group by p.Code,u.UserName
		
		union all
		
		select  ''Total'' as Project,  u.UserName, sum(hours) as Hours
		from Worklog wl
		left join [User] u on wl.UserId=u.UserId
		where wl.WorkDate between '''+ cast(@StartDate AS VARCHAR) +''' and ''' + cast(@EndDate AS varchar) + '''
		group by u.UserName		
		
	)proj
	pivot (sum(Hours) for Project in (' + @cols + ')) as piv'
        
	exec sp_executesql  @stmt = @stmt
END
GO
/****** Object:  StoredProcedure [dbo].[spGetMonthlyWorkLogTeam]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spGetMonthlyWorkLogTeam]
    @Period DATE
AS
BEGIN
    SET NOCOUNT ON;  
    DECLARE
    @cols nvarchar(max),
    @stmt nvarchar(max),
    @StartDate DATETIME,
    @EndDate DATETIME
        
    SELECT @StartDate = DATEADD(dd,-(DAY(@Period)-1),@Period)
    SELECT @EndDate   = DATEADD(dd,-(DAY(DATEADD(mm,1,@Period))),DATEADD(mm,1,@Period))    
    
    --SELECT @StartDate
    --SELECT @EndDate
    
--SELECT @cols = isnull(@cols + ', ', '') + '[' + CAST(YearDayDate AS VARCHAR) + ']' FROM YearDay where YearDayDate between @StartDate and @EndDate 
SELECT @cols = isnull(@cols + ', ', '') + '[' + CAST(day(YearDayDate) AS VARCHAR) + ']' FROM YearDay where YearDayDate between @StartDate and @EndDate order by YearDayDate
select @cols = 'Total, ' + @cols
--select 
SELECT @stmt = '
  SELECT u.UserName,
  wl.* FROM 
  (
    SELECT *
    FROM 
  (
  select    UserId, cast(day(workdate) as varchar) as WorkDate, sum(hours) as Hours
  from Worklog wl
  where wl.workdate between '''+ cast(@StartDate AS VARCHAR) +''' and ''' + cast(@EndDate AS varchar) + '''
  group by wl.UserId, cast(day(workdate) as varchar)
   
  union 
  select    UserId, ''Total'' as workdate, sum(hours) as Hours
  from Worklog wl
  where wl.workdate between '''+ cast(@StartDate AS VARCHAR) +''' and ''' + cast(@EndDate AS varchar) + '''
  group by wl.UserId

  ) T
        PIVOT 
        (
            max(Hours)
            for workdate in (' + @cols + ')
        ) as P
  ) as wl
  left join [User] u on wl.userid = u.UserId
  order by 1
  '
        
--select @stmt        
exec sp_executesql  @stmt = @stmt

END
GO
/****** Object:  StoredProcedure [dbo].[spGetMyTasks]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [dbo].[spGetMyTasks]
	@Assignee UNIQUEIDENTIFIER
AS
BEGIN	
	SELECT P.Name,TaskId, [Key], CAST(SUBSTRING([Key],LEN(p.Code) + 2, 10) AS INT) AS KeyNo , Summary, TaskType,t.TypeName AS [Type], ts.[Status] AS [StatusId],isnull(s.Name,'') AS [Status],ts.PriorityType,t2.TypeName AS	[Priority],ISNULL(ts.ResolutionType, 0)  AS ResolutionType,t3.TypeName as Resolution,
		   ISNULL(Assignee, '') AS Assignee, ISNULL(Reporter, '') AS Reporter, ts.ComponentId,c.Name AS Component, DueDate, 
		   CAST(CAST(ROUND(OriginalEstimate/60.0,2) AS DECIMAL(18,2)) AS FLOAT) AS OriginalEstimate,
		   CAST(CAST(ROUND(TimeSpent/60.0,2) AS DECIMAL(18,2))  AS FLOAT) AS TimeSpent,
		   CAST(CAST(ROUND(RemainingEstimate/60.0,2) AS DECIMAL(18,2))  AS FLOAT) AS RemainingEstimate,
		   CAST(ROUND(dbo.[fnGetTaskCurrentEstimate] (originalestimate,timespent,remainingestimate)/60.0,2) AS DECIMAL(18,0)) as CurrentEstimate,
           case when dbo.[fnGetTaskCurrentEstimate] (originalestimate,timespent,remainingestimate) > 0 then 
           cast(Round(cast(isnull(TimeSpent,0) as decimal) / dbo.[fnGetTaskCurrentEstimate] (originalestimate,timespent,remainingestimate) * 100,0) as decimal(8,0)) else 0 end as PctComplete,
		   ts.Description,		   
	       Area,RANK,ts.CreatedBy,ts.CreatedOn,U3.UserName CreatedByUser,ts.ModifiedBy,ts.ModifiedOn,U4.UserName ModifiedByUser,ISNULL(U.LoginName,'empty') LoginName,
	       ISNULL(U2.LoginName,'empty') AS ReporterLoginName,ISNULL(vwAT.AttchmentCount,0) as CountAttachment,ISNULL(vwComment.CountComment,0) as CommentCount,P.ProjectId
	FROM   Task ts
	       INNER JOIN Project p ON  p.ProjectId = ts.ProjectId
		   left outer join [User] U on U.UserName = Assignee
		   left outer join [User] U2 on U2.UserName = Reporter
		   left outer join [User] U3 on U3.UserId = ts.CreatedBy
		   left outer join [User] U4 on U4.UserId = ts.ModifiedBy
		   LEFT JOIN Component c ON c.ComponentId=ts.ComponentId
		   LEFT JOIN Types t ON t.TypeId=ts.TaskType AND t.CategoryId=102
		   LEFT JOIN Types t2 ON t2.TypeId=ts.PriorityType AND t2.CategoryId=103
		   LEFT JOIN Types t3 ON t3.TypeId=ts.ResolutionType AND t3.CategoryId=104
		   LEFT JOIN [Status] s ON s.[Status]=ts.[Status] AND EntityType=11
		   LEFT JOIN vwAttachmentCount vwAT on vwAT.EntityId= ts.TaskId and vwAT.EntityType=11
		   LEFT JOIN vwCountComment vwComment on vwComment.EntityId=ts.TaskId 	  
	WHERE  U.UserId = @Assignee
    and isnull(P.Status,0)=0
    and  s.Status < 31 AND s.Status > 11
    and ts.TaskType <> 5
	ORDER BY  p.Name,CAST(SUBSTRING([Key],LEN(p.Code) + 2, 10) AS INT) DESC	
END
GO
/****** Object:  StoredProcedure [dbo].[spGetNextBuildNumber]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 create PROCEDURE [dbo].[spGetNextBuildNumber]
 @ComponentId UNIQUEIDENTIFIER
 AS
 BEGIN
 	SET NOCOUNT ON;
 --select 'B' + cast(cast(replace(MAX(Name),'B','0')as int)+ 1 as nvarchar) from DBBuild WHERE ComponentId=@ComponentId
 SELECT dbo.[getNextBuildNumber](@ComponentId) as NextNumber
 
 END
GO
/****** Object:  StoredProcedure [dbo].[spGetOptions]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Pabitra Dash
-- Create date: 13/03/2014
-- Description:	Get options on a given entity type.
-- =============================================
CREATE PROCEDURE [dbo].[spGetOptions] 
	@EntityType int,
	@OptionSetName VARCHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT OptionName, OptionValue FROM [Option] 
		INNER JOIN OptionSet ON [Option].OptionSetId = OptionSet.OptionSetId
		WHERE OptionSet.EntityType = @EntityType AND OptionSet.Name = @OptionSetName
END
GO
/****** Object:  StoredProcedure [dbo].[spGetPortalLevelModules]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetPortalLevelModules]
   
AS

BEGIN
    SET NOCOUNT ON;
    
    SELECT m.ModuleId, m.Name
	FROM   [Module] m
	left join module m2 on m.ParentModuleId = m2.ModuleId
	left join module m3 on m2.ParentModuleId = m3.ModuleId
	
    where m2.ModuleId is not null and m3.ModuleId is NULL
    
END
GO
/****** Object:  StoredProcedure [dbo].[spGetProjectDeploymentSummary]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spGetProjectDeploymentSummary]
(
	@ProjectId UNIQUEIDENTIFIER
)
AS 
BEGIN
	SELECT v.version      AS Version,
	       v.DBBuilds     AS DBBuilds,
	       ds.SiteName    AS [Site],
	       ds.SiteLink    AS [Link],
	       vd.DeployedBy  AS DeployedBy,
	       vd.DeployedOn  AS ReleaseDate,
	       vd.Remarks     AS Remarks,
	       ds.Server      AS [Server]
	FROM   VersionDeployment vd
	       INNER JOIN Version v
	            ON  v.VersionId = vd.VersionId
	       INNER JOIN DeploymentSite ds
	            ON  vd.DeploymentSiteId = ds.DeploymentSiteId
	       INNER JOIN (
	                SELECT MAX(vd.DeploymentSiteId) AS DeploymentSiteId, MAX(vd.DeployedOn) AS DeployedOn
	                FROM   VersionDeployment vd
	                GROUP BY  vd.DeploymentSiteId
	            ) t
	            ON  vd.DeployedOn = t.DeployedOn
	            AND vd.DeploymentSiteId = t.DeploymentSiteId
	WHERE  ds.ComponentId IN (SELECT ComponentId FROM   Component c WHERE  c.ProjectId = @ProjectId)
	       AND ISNULL(ds.IsObsolete, 0) = 0
	ORDER BY vd.DeployedOn DESC
END
GO
/****** Object:  StoredProcedure [dbo].[spGetProjectForTask]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetProjectForTask]

AS
BEGIN

	SET NOCOUNT ON;

    SELECT ProjectId,Name FROM  Project
    
END
GO
/****** Object:  StoredProcedure [dbo].[spGetProjects]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ========================================================
-- Author:		Narendra Shrivastava
-- Create date: 16 March 2016
-- Description: Get Projects
-- ========================================================
CREATE PROCEDURE [dbo].[spGetProjects]
 
	@ProjectId uniqueidentifier = null,
	@UserId uniqueidentifier = null,
	@StatusId INT  = 1
AS
BEGIN
SET NOCOUNT ON;
	SELECT DISTINCT P.ProjectId,P.ClientId,C.Name AS ClientName,P.Name,P.Code,ISNULL(P.Status,1) AS [Status],p.[Description],P.CreatedBy,P.CreatedOn,P.ModifiedBy,P.ModifiedOn 
	FROM Project P
	LEFT JOIN ProjectPermission PP ON PP.ProjectId=P.ProjectId
	LEFT JOIN Client C ON C.clientId = P.ClientId
	WHERE  (P.ProjectId = @ProjectId OR @ProjectId IS NULL)
	AND (@UserId IS NULL OR PP.UserId = @UserId)
	AND ISNULL(P.Status,1) = ISNULL(@StatusId,1)
	ORDER BY P.Name
END
GO
/****** Object:  StoredProcedure [dbo].[spGetProjectSummary]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetProjectSummary]
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT p.Name AS Project, sum(CASE WHEN t.[Status] IN (11) THEN isnull(t.RemainingEstimate,t.OriginalEstimate-t.TimeSpent)/60 ELSE 0 END) AS Backlog,
	sum(CASE WHEN t.[Status] IN (12,22,23) THEN isnull(t.RemainingEstimate,isnull(t.OriginalEstimate,0)-isnull(t.TimeSpent,0))/60 ELSE 0 END) AS [NotStarted],
	sum(CASE WHEN t.[Status] IN (13,21,31,41) THEN isnull(t.RemainingEstimate,isnull(t.OriginalEstimate,0)-isnull(t.TimeSpent,0))/60 ELSE 0 END) AS [InProgress]
	FROM dbo.Task t
	LEFT JOIN dbo.Project p ON p.ProjectId = t.ProjectId
	WHERE isnull(t.RemainingEstimate,isnull(t.OriginalEstimate,0)-isnull(t.TimeSpent,0))>0
    and isnull(p.Status,0)=0
    and t.TaskType <> 5
	GROUP BY p.Name
	ORDER BY 1
END
GO
/****** Object:  StoredProcedure [dbo].[spGetProjectUserPermission]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetProjectUserPermission] 
	@ProjectId [uniqueidentifier] = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
	select u.UserId, u.UserName, cast (case when pp.ProjectId is not null then 1 else 0 end as bit) as Permission
	from [User] u
	left join
		(select userid, Projectid from ProjectPermission where Projectid = @ProjectId) pp on u.UserId=pp.userid
	where u.[status]=0 or pp.UserId is not null
	order by u.username
end
GO
/****** Object:  StoredProcedure [dbo].[spGetRecentReleases]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author       : Ankit Sharma
-- Create date  : 01-Jan-2016
-- Description  : Get Client's Settings
-- Parameters   : 
-- =============================================
CREATE PROCEDURE [dbo].[spGetRecentReleases]
(
	@ProjectId UNIQUEIDENTIFIER
)
AS 
BEGIN
	SELECT TOP 20 
	MAX(v.Version) AS Version,	MAX(v.DBBuilds) AS DBBuilds,MAX(ds.SiteName) AS [Site],MAX(ds.SiteLink) AS [Link],MAX(vd.DeployedBy) AS DeployedBy,
	MAX(vd.DeployedOn) as ReleaseDate,	MAX(vd.Remarks) as Remarks,MAX(ds.Server) AS [Server]		
	FROM VersionDeployment vd
	INNER JOIN Version v ON v.VersionId = vd.VersionId
	INNER JOIN DeploymentSite ds ON vd.DeploymentSiteId=ds.DeploymentSiteId 	
	WHERE ds.ComponentId IN (SELECT ComponentId FROM Component c WHERE c.ProjectId=@ProjectId)
	 AND isnull(ds.IsObsolete,0)=0
	GROUP BY vd.DeploymentSiteId 
	ORDER BY Max(vd.DeployedOn)DESC ,MAX(ds.Server) DESC
END
GO
/****** Object:  StoredProcedure [dbo].[spGetReference]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetReference]
  @SelectedVersions nvarchar(max),
  @ReleaseNoteSummaryId UNIQUEIDENTIFIER
AS  

BEGIN  
 DECLARE @Reference NVARCHAR(10)
 DECLARE @IssueSummary NVARCHAR(500)
 DECLARE @IssueType INT
 DECLARE @VersionId UNIQUEIDENTIFIER 
 
 --Insert Sequence number when insert data into Release NOte
 --DECLARE @recordCount INT;
 DECLARE @Sequence int = 10; 
 --SELECT @recordCount = Count(*) FROM ReleaseNote  WHERE VersionId = @VersionId
 --IF (@recordCount > 0)
 --BEGIN
 -- SELECT @Sequence=MAX(IsNull(Sequence, 0)) + 10 from ReleaseNote  WHERE VersionId = @VersionId
 --END

 DECLARE curRecord CURSOR LOCAL 

 --FOR SELECT vc.VersionId,vc.Reference,ts.Summary,ts.TaskType 
 --FROM VersionChange vc LEFT JOIN Task ts on vc.Reference=ts.[Key] WHERE VC.VersionId IN (SELECT item FROM dbo.fnSplit(@SelectedVersions ,',' ))  

 FOR SELECT vc.VersionId,vc.Reference,ts.Summary,ts.TaskType
 FROM VersionChange vc LEFT JOIN Task ts on vc.Reference=ts.[Key] LEFT JOIN Version v on vc.VersionId=v.VersionId 
     WHERE VC.VersionId IN (SELECT item FROM dbo.fnSplit(@SelectedVersions ,',' )) 
     ORDER BY (CAST('/' + REPLACE(v.version , '.', '/') + '/' AS HIERARCHYID)) DESC 
 
 OPEN curRecord 
 FETCH NEXT FROM curRecord INTO @VersionId,@Reference,@IssueSummary,@IssueType
 WHILE (@@FETCH_STATUS = 0)
 BEGIN
 IF NOT EXISTS(SELECT 1 FROM ReleaseNote WHERE Reference=@Reference and ReleaseNoteSummaryId=@ReleaseNoteSummaryId)
 BEGIN
  INSERT INTO ReleaseNote(ReleaseNoteId,VersionId,Reference,Title,[Type],Sequence,ReleaseNoteSummaryId) 
  SELECT NEWID(),@VersionId as VersionId,@Reference Reference, @IssueSummary IssueSummary, @IssueType IssueType, @Sequence, @ReleaseNoteSummaryId
 END     
 FETCH NEXT FROM curRecord INTO @VersionId,@Reference,@IssueSummary,@IssueType
 END 
 CLOSE curRecord 
 DEALLOCATE curRecord 
END
GO
/****** Object:  StoredProcedure [dbo].[spGetReleaseNoteBySummaryId]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetReleaseNoteBySummaryId]
	@ReleaseNoteSummaryIds NVARCHAR(MAX)
AS
BEGIN	
DECLARE @ReleaseNoteSummary Table
 (
   ReleaseNoteId Uniqueidentifier,
   VersionId Uniqueidentifier,
   Version nvarchar(50),
   Reference nvarchar(50),
   Title nvarchar(250),
   Remarks nvarchar(250),
   IsPublic BIT NULL,
   [Type] INT,
   Sequence INT,
   IssueName nvarchar(50),
   UpdateTaskFields BIT
 )

 DECLARE @ReleaseNoteId UNIQUEIDENTIFIER
 DECLARE @VersionId UNIQUEIDENTIFIER 
 DECLARE @Version nvarchar(50)
 DECLARE @Reference NVARCHAR(50)
 DECLARE @Title NVARCHAR(250)
 DECLARE @Remarks nvarchar(250)
 DECLARE @IsPublic BIT
 DECLARE @Type INT
 DECLARE @Sequence INT
 DECLARE @IssueName nvarchar(50)
 DECLARE @UpdateTaskFields BIT

 DECLARE curRecord CURSOR LOCAL 

	FOR SELECT rn.ReleaseNoteId,rn.VersionId,V.Version,rn.Reference,rn.Title, rn.Remarks, rn.IsPublic,rn.[Type], rn.Sequence, tblOption.OptionName as IssueName,
	CAST(0 AS BIT) AS UpdateTaskFields	
		from ReleaseNote rn
		left join Version V on V.VersionId = rn.VersionId
		LEFT JOIN
		(
			SELECT TypeName OptionName, TypeId OptionValue FROM [Types] 
			WHERE CategoryId = 102
		) TBLOPTION ON tblOption.OptionValue=rn.[Type]
		WHERE ReleaseNoteSummaryId in (select item from dbo.fnSplit(@ReleaseNoteSummaryIds,','))
	ORDER BY  (CAST('/' +  REPLACE(v.version , '.', '/') +  '/' AS HIERARCHYID)) DESC,rn.Sequence 
	OPEN curRecord 
	FETCH NEXT FROM curRecord INTO @ReleaseNoteId,@VersionId,@Version,@Reference,@Title,@Remarks,@IsPublic,@Type,@Sequence,@IssueName,@UpdateTaskFields
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
	IF NOT EXISTS(SELECT 1 FROM @ReleaseNoteSummary WHERE Reference=@Reference)
	BEGIN
	 INSERT INTO @ReleaseNoteSummary
	 SELECT @ReleaseNoteId,@VersionId,@Version,@Reference,@Title,@Remarks,@IsPublic,@Type,@Sequence,@IssueName,@UpdateTaskFields
	END     
	FETCH NEXT FROM curRecord INTO @ReleaseNoteId,@VersionId,@Version,@Reference,@Title,@Remarks,@IsPublic,@Type,@Sequence,@IssueName,@UpdateTaskFields
	END 
	CLOSE curRecord 
	DEALLOCATE curRecord 

	SELECT ReleaseNoteId,VersionId,Version,Reference,Title,Remarks,IsPublic,Type,Sequence,IssueName,UpdateTaskFields
	FROM @ReleaseNoteSummary
	ORDER BY (CAST('/' +  REPLACE(version , '.', '/') +  '/' AS HIERARCHYID)) DESC, Sequence 

END
GO
/****** Object:  StoredProcedure [dbo].[spGetReleaseNotes]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author       : Ankit Sharma
-- Create date  : 01-Jan-2016
-- Description  : Get Release Notes
-- Parameters   : 
-- =============================================
CREATE PROCEDURE [dbo].[spGetReleaseNotes]
	@ComponentId UNIQUEIDENTIFIER,
	@ReleaseNoteSummaryId UNIQUEIDENTIFIER='00000000-0000-0000-0000-000000000000'	
AS
BEGIN
	
	IF(ISNULL(@ReleaseNoteSummaryId,'00000000-0000-0000-0000-000000000000') = '00000000-0000-0000-0000-000000000000')
	BEGIN
		SELECT TOP(1) @ReleaseNoteSummaryId = ReleaseNoteSummaryId FROM ReleaseNoteSummary
			WHERE ComponentId=@ComponentId						
			ORDER BY (CAST('/' + REPLACE(ReleaseTitle , '.', '/') + '/' AS HIERARCHYID)) DESC
	END
	
	SELECT rns.ReleaseTitle,rn.ReleaseNoteId,rn.VersionId,V.Version,rn.Reference,rn.Title, 
		rn.Remarks, rn.IsPublic,rn.[Type],t.TypeName as IssueName, rn.Sequence,
		CAST(0 AS BIT) AS UpdateTaskFields
	FROM ReleaseNote rn
		LEFT JOIN ReleaseNoteSummary rns ON rns.ReleaseNoteSummaryId=rn.ReleaseNoteSummaryId
		LEFT JOIN [Version] V on V.VersionId = rn.VersionId		
		LEFT JOIN [Types] t
		ON (t.CategoryId=102 AND rn.[Type]=t.TypeId)
		
		WHERE rns.ReleaseNoteSummaryId=@ReleaseNoteSummaryId
		ORDER BY rn.Sequence DESC, (CAST('/' + REPLACE(v.version , '.', '/') + '/' AS HIERARCHYID))
	
END
GO
/****** Object:  StoredProcedure [dbo].[spGetReleaseNotesSummaries]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author       : Abhishek Ranjan
-- Create date  : 19-Feb-2016
-- Description  : Get Release Notes List of componentId
-- Parameters   : 
-- =============================================
CREATE PROCEDURE [dbo].[spGetReleaseNotesSummaries]
@ComponentId UNIQUEIDENTIFIER
AS 
BEGIN
   	SELECT ReleaseNoteSummaryId, ReleaseTitle, 
   		ReleaseDate, IsLocked
   	FROM ReleaseNoteSummary
		WHERE ComponentId=@ComponentId						
		ORDER BY (CAST('/' + REPLACE(ReleaseTitle , '.', '/') + '/' AS HIERARCHYID)) DESC
END
GO
/****** Object:  StoredProcedure [dbo].[spGetReleaseNoteSummary]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetReleaseNoteSummary]
	@ComponentId UNIQUEIDENTIFIER	
AS
BEGIN				
		select ReleaseNoteSummaryId,ComponentId,P.Name,ReleaseDate,ReleaseTitle,IsLocked,U.UserName CreatedBy,RNS.CreatedOn,U2.UserName ModifiedBy,RNS.ModifiedOn from ReleaseNoteSummary RNS
		left join Project P on RNS.ComponentId=P.ProjectId
		left join [User] U on RNS.CreatedBy=U.UserId
		left join [User] U2 on RNS.ModifiedBy=U2.UserId
		WHERE ComponentId = @ComponentId
		order by ReleaseDate desc
END
GO
/****** Object:  StoredProcedure [dbo].[spGetResourceWorkload]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetResourceWorkload]
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT isnull(u.UserName,'Unassigned') AS [Resource], sum(isnull(t.RemainingEstimate,t.OriginalEstimate-t.TimeSpent)/60) AS [Workload]
FROM dbo.Task t
LEFT JOIN dbo.[User] u ON u.UserName=t.Assignee
WHERE isnull(t.RemainingEstimate,t.OriginalEstimate-t.TimeSpent)>0
AND t.[Status] IN (12,13,21,22,23)
AND t.TaskType <> 5
GROUP BY u.UserName
ORDER BY 1
END
GO
/****** Object:  StoredProcedure [dbo].[spGetSavingTypes]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author       : Ankit Sharma
-- Create date  : 06-aPRIL-2016
-- Description  : Get All Saving Types
-- Parameters   : 
-- =============================================
CREATE PROCEDURE [dbo].[spGetSavingTypes]
AS
BEGIN
	SELECT Distinct TaxSavingType,TaxSavingTypeName FROM TaxSavingType order by TaxSavingTypeName
END
GO
/****** Object:  StoredProcedure [dbo].[spGetScriptsByComponentAndName]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ankit Sharma
-- Create date: 27/05/2016
-- Description:	Fetch all DB Scripts for a given Component and Script Name
-- =============================================
CREATE PROCEDURE [dbo].[spGetScriptsByComponentAndName]
	@ComponentId UNIQUEIDENTIFIER,
	@SearchText NVARCHAR(250)=NULL
AS
BEGIN
	SET NOCOUNT ON;
SELECT DBScriptId,
		   DBS.Name,
		   [Description],
		   DBScriptType,
		   DBChangeType,
		   Reference,
		   Script,
		   Sequence,
		   ChangedBy,
		   ChangedOn,
		   Src.OptionName DBScriptTypeName,
		   Chng.OptionName DBChangeTypeName,
		   usr.UserName UserName,
		   usr.LoginName LoginName,
		   DBB.Name BuildName,
		   DBB.DBBuildId BuildId
	FROM DBSCript DBS
	LEFT JOIN 
		(SELECT OptionName, OptionValue FROM [Option] 
		INNER JOIN OptionSet ON [Option].OptionSetId = OptionSet.OptionSetId
		WHERE OptionSet.EntityType = 8 AND OptionSet.Name = 'DB Script Type') Src 
		ON Src.OptionValue=DBS.DBScriptType
	LEFT JOIN 
		(SELECT OptionName, OptionValue FROM [Option] 
		INNER JOIN OptionSet ON [Option].OptionSetId = OptionSet.OptionSetId
		WHERE OptionSet.EntityType = 8 AND OptionSet.Name = 'DB Change Type') Chng 
		ON Chng.OptionValue=DBS.DBChangeType
		INNER JOIN
		(SELECT [USER].UserId,UserName,LoginName FROM [USER]  
		INNER JOIN UserRole  ON  UserRole.UserId = [USER].UserId
	        INNER JOIN [Role]  ON  [Role].RoleId = UserRole.RoleId AND ([Role].Name = 'IR User')
		) usr
	    ON usr.UserId=DBS.ChangedBy
	LEFT JOIN DBBuild DBB on DBS.DBBuildId=DBB.DBBuildId
	WHERE DBB.ComponentId=@ComponentId and (@SearchText IS NULL OR DBS.Name Like '%'+@SearchText+'%')
	ORDER BY CAST(dbo.fnGetNumericInAlphaNumeric(DBB.Name) AS INT) DESC,DBScriptType, Sequence
END
GO
/****** Object:  StoredProcedure [dbo].[spGetSiteName]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetSiteName]
	@ComponentId UNIQUEIDENTIFIER = NULL
AS

BEGIN
		SELECT  DeploymentSiteId, SiteName FROM DeploymentSite  WHERE ComponentId=@ComponentId
		AND ISNULL(IsObsolete,0)=0
END
GO
/****** Object:  StoredProcedure [dbo].[spGetSoftwareDownload]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetSoftwareDownload]	
	@SoftwareDownloadId uniqueidentifier,
	@DownloadFileId uniqueidentifier OUT	
	
AS
BEGIN	
	-- interfering with SELECT statements.
	SET NOCOUNT ON;    
	SELECT	@DownloadFileId = DownloadFileId			
	FROM SoftwareDownload WHERE SoftwareDownloadId = @SoftwareDownloadId
END
GO
/****** Object:  StoredProcedure [dbo].[spGetStatus]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetStatus]
	@EntityType INT
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT EntityType,  [Status],Name  	FROM   [Status]	WHERE  EntityType = @EntityType
END
GO
/****** Object:  StoredProcedure [dbo].[spGetSummaryDetail]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetSummaryDetail]
	@ComponentId UNIQUEIDENTIFIER = null
AS
BEGIN
SELECT v.Version, v.DBBuilds, ds.SiteName, vd.DeployedBy,
		(REPLACE(CONVERT(VARCHAR(50),DATEADD(MINUTE,330,vd.DeployedOn),106),' ','-') + ' '+ CONVERT(VARCHAR(50),DATEADD(MINUTE,330,vd.DeployedOn),108)) as DeployedOn,
		vd.Remarks	       
	FROM   VersionDeployment vd
	       INNER JOIN Version v
	            ON  v.VersionId = vd.VersionId
	       INNER JOIN DeploymentSite ds
	            ON  vd.DeploymentSiteId = ds.DeploymentSiteId
	       INNER JOIN (
	                SELECT MAX(vd.DeploymentSiteId) AS DeploymentSiteId, MAX(vd.DeployedOn) AS DeployedOn
	                FROM   VersionDeployment vd
	                GROUP BY  vd.DeploymentSiteId
	            ) t
	            ON  vd.DeployedOn = t.DeployedOn AND vd.DeploymentSiteId = t.DeploymentSiteId
	WHERE ds.ComponentId=@ComponentId AND ISNULL(ds.IsObsolete, 0) = 0
	ORDER BY vd.DeployedOn DESC
END
GO
/****** Object:  StoredProcedure [dbo].[spGetTasks]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetTasks]
	@ProjectId UNIQUEIDENTIFIER,
	@Status VARCHAR(MAX)=NULL,
	@TaskType VARCHAR(MAX)=NULL,
	@Component VARCHAR(MAX)=NULL,
	@Assignees VARCHAR(MAX)=NULL,
	@TaskId UNIQUEIDENTIFIER = NULL,
    @IsBoard INT = NULL
AS
BEGIN	
	DECLARE @StartIndex INT=0;
	SELECT @StartIndex=LEN(Code) + 2 FROM Project WHERE ProjectId=@ProjectId
	SELECT TaskId, [Key], CAST(SUBSTRING([Key],@StartIndex, 10) AS INT) AS KeyNo , Summary, TaskType,t.TypeName AS [Type], ts.[Status] AS [StatusId],isnull(s.Name,'') AS [Status],ts.PriorityType,t2.TypeName AS [Priority],
		 ISNULL(ts.ResolutionType, 0)  AS ResolutionType,t3.TypeName as Resolution,
		   ISNULL(Assignee, '') AS Assignee,
		   ISNULL(Reporter, '') AS Reporter,
		    ts.ComponentId,c.Name AS Component, DueDate, 
		   CAST(ROUND(OriginalEstimate/60.0,2) AS DECIMAL(18,2)) AS OriginalEstimate,
		   CAST(ROUND(TimeSpent/60.0,2) AS DECIMAL(18,2)) AS TimeSpent,
		   CAST(ROUND(RemainingEstimate/60.0,2) AS DECIMAL(18,2)) AS RemainingEstimate,
           CAST(ROUND(dbo.[fnGetTaskCurrentEstimate] (originalestimate,timespent,remainingestimate)/60.0,2) AS DECIMAL(18,0)) as CurrentEstimate,
           case when dbo.[fnGetTaskCurrentEstimate] (originalestimate,timespent,remainingestimate) > 0 then 
                cast(Round(cast(isnull(TimeSpent,0) as decimal) / dbo.[fnGetTaskCurrentEstimate] (originalestimate,timespent,remainingestimate) * 100,0) as decimal(8,0)) else 0 end as PctComplete,
		   CONVERT(VARCHAR,CAST(CAST(ROUND(OriginalEstimate/60.0,2) AS DECIMAL(18,2)) AS FLOAT)) + '/' +
		   CONVERT(VARCHAR,CAST(CAST(ROUND(TimeSpent/60.0,2) AS DECIMAL(18,2)) AS FLOAT)) + '/' +
		   CONVERT(VARCHAR,CAST(CAST(ROUND(RemainingEstimate/60.0,2) AS DECIMAL(18,2))AS FLOAT)) AS [Time],
		   ts.Description,		   
	       Area,RANK,ts.CreatedBy,ts.CreatedOn,U3.UserName CreatedByUser,ts.ModifiedBy,ts.ModifiedOn,U4.UserName ModifiedByUser,ISNULL(U.LoginName,'empty') AssigneeLoginName,
		   ISNULL(U2.LoginName,'empty') AS ReporterLoginName,
		   ISNULL(vwAT.AttchmentCount,0) as CountAttachment,ISNULL(vwComment.CountComment,0) as CommentCount,
		   [Key]+' '+ Summary AS IssueKeyAndSummary,
           vwTaskQAStatus.Reference AS QAReference,
		   vwTaskQAStatus.QAStatus,opt.OptionName QAStatusName,com.GitUrl
	FROM   Task ts
	       INNER JOIN Project p ON  p.ProjectId = ts.ProjectId
		   left outer join [User] U on U.UserName = Assignee
		   left outer join [User] U2 on U2.UserName = Reporter
		   left outer join [User] U3 on U3.UserId = ts.CreatedBy
		   left outer join [User] U4 on U4.UserId = ts.ModifiedBy
		   LEFT JOIN Component c ON c.ComponentId=ts.ComponentId
		   LEFT JOIN Types t ON t.TypeId=ts.TaskType AND t.CategoryId=102
		   LEFT JOIN Types t2 ON t2.TypeId=ts.PriorityType AND t2.CategoryId=103
		   LEFT JOIN Types t3 ON t3.TypeId=ts.ResolutionType AND t3.CategoryId=104
		   LEFT JOIN [Status] s ON s.[Status]=ts.[Status] AND EntityType=11
		   LEFT JOIN vwAttachmentCount vwAT on vwAT.EntityId= ts.TaskId and vwAT.EntityType=11
		   LEFT JOIN vwCountComment vwComment on vwComment.EntityId=ts.TaskId 	  
           LEFT JOIN vwTaskQAStatus on vwTaskQAStatus.Reference = ts.[Key]
		   --QA Status Name for QA Status
		   LEFT JOIN [Option] opt ON opt.OptionValue=vwTaskQAStatus.QAStatus AND opt.OptionSetId='639F1F0D-B0B0-44F2-950B-E13F16B16CA4'
		   --Component Join for Component git url
		   LEFT JOIN Component com ON ts.ComponentId=com.ComponentId
		   
	WHERE 
	ts.ProjectId = @ProjectId
	AND (ISNULL(@Status,'') = '' OR ts.[Status] In (SELECT item FROM dbo.fnSplit(@Status,',')))
	AND (ISNULL(@TaskType,'') = '' OR ts.TaskType In (SELECT item FROM dbo.fnSplit(@TaskType,',')))
	AND (ISNULL(@Component,'') = '' OR ts.ComponentId In (SELECT item FROM dbo.fnSplit(@Component,',')))
	AND (ISNULL(@Assignees,'') = '' OR U.UserId In (SELECT item FROM dbo.fnSplit(@Assignees,',')))
	AND (@TaskId IS NULL OR ts.TaskId = @TaskId)
	
	--AND 1=(
	--		CASE WHEN ISNULL(@Status,'')='' THEN 1
	--			--CASE WHEN ts.Status<50 THEN 1 ELSE 0 END
	--		ELSE
	--			CASE WHEN ts.[Status] IN (SELECT item FROM dbo.fnSplit(@Status,',')) THEN 1 ELSE 0 END
	--        END
	--       )  
	ORDER BY 
        CASE WHEN ISNULL(@IsBoard,0) = 0 THEN CAST(SUBSTRING([Key], @StartIndex, 10) AS INT) END DESC,
        CASE WHEN ISNULL(@IsBoard,0) = 1 THEN [Rank] END
END
GO
/****** Object:  StoredProcedure [dbo].[spGetTaxSavingReceipt]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================
-- Author       : Ankit Sharma
-- Create date  : 07-April-2016
-- Description  : Get Tax Saving Receipt
-- Parameters   : 
-- ==============================================================
CREATE PROCEDURE [dbo].[spGetTaxSavingReceipt]
	@EmployeeId			uniqueidentifier=NULL,
	@FinancialYear		int=NULL
AS	 
BEGIN	
	Select TaxSavingId,T.EmployeeId,Replace(FirstName + ' ' + ISNULL(MiddleName,'') + ' ' + ISNULL(LastName,''),'  ',' ') AS FullName,
	FinancialYear,T.TaxSavingType,TT.TaxSavingTypeName,RecurringFrequency,SavingDate,AccountNumber,Amount,
	Isnull(Amount,0)*Isnull(EligibleCount,1) as TotalAmount,T.Remarks,Isnull(ReceiptSubmitted,0) as ReceiptSubmitted,Isnull(EligibleCount,1)EligibleCount
	from TaxSaving T
	LEFT JOIN Employee E ON T.EmployeeId=E.EmployeeId
	LEFT JOIN TaxSavingType TT ON T.TaxSavingType=TT.TaxSavingType   
	where 	(@EmployeeId IS NULL OR T.EmployeeId=@EmployeeId) 
	and (@FinancialYear IS NULL OR FinancialYear=@FinancialYear) 
	order by E.FirstName,T.TaxSavingType,T.RecurringFrequency
END
GO
/****** Object:  StoredProcedure [dbo].[spGetTaxSavingReceiptExcel]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================
-- Author       : Ankit Sharma
-- Create date  : 07-April-2016
-- Description  : Get Tax Saving Receipt For Excel Export
-- Parameters   : 
-- ==============================================================
CREATE PROCEDURE [dbo].[spGetTaxSavingReceiptExcel]
	@EmployeeId			uniqueidentifier=NULL,
	@FinancialYear		int=NULL
AS	 
BEGIN	
	Select TT.TaxSavingTypeName as [Saving Type],
	CASE RecurringFrequency
    WHEN 12 THEN 'Monthly'
	WHEN 4 THEN 'Quarterly'
	WHEN 2 THEN 'Half-Yearly'
	WHEN 1 THEN 'Yearly'
    END as [Frequency],SavingDate as [Date],AccountNumber [Policy/Account No./Description],Amount,
	Isnull(Amount,0)*Isnull(EligibleCount,1) as [Total Amount],T.Remarks,Isnull(ReceiptSubmitted,0) as Receipt
	from TaxSaving T
	LEFT JOIN Employee E ON T.EmployeeId=E.EmployeeId
	LEFT JOIN TaxSavingType TT ON T.TaxSavingType=TT.TaxSavingType   
	where 	(@EmployeeId IS NULL OR T.EmployeeId=@EmployeeId) 
	and (@FinancialYear IS NULL OR FinancialYear=@FinancialYear) 
	order by E.FirstName,T.TaxSavingType,T.RecurringFrequency
END
GO
/****** Object:  StoredProcedure [dbo].[spGetTaxSavingTypes]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetTaxSavingTypes]
AS 
 BEGIN
  
  SET NOCOUNT ON;
  SELECT TaxSavingType,TaxSavingTypeName,TaxCategoryCode FROM TaxSavingType
  ORDER BY TaxSavingTypeName
END
GO
/****** Object:  StoredProcedure [dbo].[spGetTodayWorklog]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =====================================================
-- Author       : Narendra Shrivastava
-- Create date  : 08-April-2016
-- Description  : Used to Get today's work log
-- =====================================================
CREATE PROCEDURE [dbo].[spGetTodayWorklog]
 @TaskId UNIQUEIDENTIFIER,
 @UserId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    
	SELECT ShowOrder,TaskId,[Key],Summary,SUM([Hours]) AS [Hours] FROM
	(
	SELECT 0 As ShowOrder ,t.TaskId,[Key],t.Summary,0 AS [Hours] FROM Task t
	LEFT OUTER JOIN worklog wl on t.TaskId = wl.TaskId
	WHERE t.taskid = @TaskId
	
	UNION
	
	SELECT CASE WHEN t.TaskId = @TaskId THEN 0 ELSE 1 END AS ShowOrder, t.TaskId,[Key],t.Summary,wl.Hours FROM worklog wl
	LEFT OUTER JOIN Task t on t.TaskId = wl.TaskId
	WHERE CAST(WorkDate AS DATE) = CAST(GetDate() AS DATE)	
	and wl.UserId = @UserId
	) TodayWorkLog
	GROUP BY ShowOrder,TaskId,[Key],Summary
	ORDER BY ShowOrder,[Key]
END
GO
/****** Object:  StoredProcedure [dbo].[spGetTotalBuild]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author       : Ankit Sharma
-- Create date  : 11-March-2016
-- Description  : Get Total DB Builds Between From And To on Bulk Export
-- Parameters   : 
-- =============================================
CREATE PROCEDURE [dbo].[spGetTotalBuild]
    @ComponentId UNIQUEIDENTIFIER,
	@DBBuildFrom VARCHAR(5),
	@DBBuildTo   VARCHAR(5)
AS
BEGIN
SELECT DBBuildId,Name FROM(
SELECT db.DBBuildId,db.Name,COUNT(*) 'Count'
FROM DBBuild db
JOIN  DBScript dbs ON dbs.DBBuildId=db.DBBuildId
WHERE ComponentId=@ComponentId AND 
cast(SUBSTRING(db.Name,2,LEN(db.Name)-1) AS INT) BETWEEN cast(SUBSTRING(@DBBuildFrom,2,LEN(@DBBuildFrom)-1) AS INT) 
AND cast(SUBSTRING(@DBBuildTo,2,LEN(@DBBuildTo)-1) AS INT) 
Group by db.DBBuildId,db.Name) DBSCount
ORDER BY Name ASC
END
GO
/****** Object:  StoredProcedure [dbo].[spGetUpcomingEvents]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spGetUpcomingEvents]
AS
BEGIN
   SET NOCOUNT ON;
   declare @today date
    select @today = getdate()
   SELECT * FROM  
    (
    SELECT 
        'Holiday' AS 'EventType', 
        SUBSTRING(DATENAME(dw,h.HolidayDate),0,4)+', '+convert(NVARCHAR(2),datepart(DAY,h.HolidayDate))+' '+SUBSTRING(DATENAME(mm,h.HolidayDate),0,4) AS 'EventDate',
        NAME AS 'Name', 
        h.Name AS 'EmpId', 
        h.HolidayDate AS 'OrderByDate'
    FROM Holiday h 
    WHERE h.HolidayDate BETWEEN @today AND (DATEADD(day, 30, GETDATE()))

    UNION ALL

    SELECT 
        'Birthday' AS 'EventType',
        SUBSTRING(DATENAME(dw,DATEFROMPARTS(Year(GetDate()), Month(e.DateOfBirth), Day(e.DateOfBirth))),0,4)+', '+convert(NVARCHAR(2),datepart(DAY,DATEFROMPARTS(Year(GetDate()), Month(e.DateOfBirth), Day(e.DateOfBirth))))+' '+SUBSTRING(DATENAME(mm,DATEFROMPARTS(Year(GetDate()), Month(e.DateOfBirth), Day(e.DateOfBirth))),0,4) AS 'EventDate', 
        e.FirstName+ ' ' +isnull(e.MiddleName,'')+ ' '+ e.LastName AS 'Name', 
        u.LoginName AS 'EmpId',
        --e.DateOfBirth AS 'OrderByDate'
        DATEFROMPARTS(Year(GetDate()), Month(e.DateOfBirth), Day(e.DateOfBirth)) as 'OrderByDate'
    FROM Employee e 
        INNER JOIN [User] u ON u.EmployeeId = e.EmployeeId 
    WHERE DATEADD(YEAR, DATEDIFF(YEAR,e.DateOfBirth,GETDATE()), e.DateOfBirth)  BETWEEN @today AND (DATEADD(day, 30, GETDATE())) AND u.[Status] = 0

    --UNION ALL

    --SELECT 
    --    'Anniversary' AS 'EventType', 
    --    SUBSTRING(DATENAME(dw,DATEFROMPARTS(Year(GetDate()), Month(e.Anniversary), Day(e.Anniversary))),0,4)+', '+convert(NVARCHAR(2),datepart(DAY,DATEFROMPARTS(Year(GetDate()), Month(e.Anniversary), Day(e.Anniversary))))+' ' +SUBSTRING(DATENAME(mm,DATEFROMPARTS(Year(GetDate()), Month(e.Anniversary), Day(e.Anniversary))),0,4) AS 'EventDate', 
    --    e.FirstName+ ' '+isnull(e.MiddleName,'')+ ' ' + e.LastName AS 'Name', 
    --    u.LoginName AS 'EmpId',
    --    DATEFROMPARTS(Year(GetDate()), Month(e.Anniversary), Day(e.Anniversary)) as 'OrderByDate'
    --    --e.Anniversary AS 'OrderByDate'
    --FROM Employee e 
    --    INNER JOIN [User] u ON u.EmployeeId = e.EmployeeId 
    --    WHERE Month(Anniversary) = month(Getdate())  AND u.[Status] = 0

    UNION ALL

    SELECT 
        'On Leave' AS 'EventType', 
        SUBSTRING(DATENAME(dw,l.LeaveDate),0,4)+', '+convert(NVARCHAR(2),datepart(DAY,l.LeaveDate))+' '+SUBSTRING(DATENAME(mm,l.LeaveDate),0,4) AS 'EventDate', 
        e.FirstName+ ' ' +isnull(e.MiddleName,'')+ ' '+ e.LastName AS 'Name', 
        u.LoginName AS 'EmpId',
        l.LeaveDate AS 'OrderByDate'
    FROM Leave l 
        LEFT OUTER JOIN Employee e ON e.EmployeeId = l.EmployeeId INNER JOIN [User] u ON u.EmployeeId = e.EmployeeId 
    WHERE l.LeaveDate BETWEEN @today AND (DATEADD(day, 30, GETDATE()))
    ) tmp ORDER BY OrderByDate,EmpId
END
GO
/****** Object:  StoredProcedure [dbo].[spGetUpcomingLeaves]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetUpcomingLeaves]
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @TodaysDate Date
	Set @TodaysDate=GetDate()
    BEGIN
    select LoginName,LeaveId,EmployeeName,LeaveDateFormat,LeaveDate,LeaveType,LeaveCount from 
	(select u.LoginName LoginName,LeaveId,LTRIM(Rtrim(ISNULL(FirstName,'')+' '+ISNULL(MiddleName,'')+' '+ISNULL(LastName,''))) EmployeeName,DATENAME(dw, LeaveDate)+','+CONVERT(varchar(2), DATEPART(dd,LeaveDate))+' '+DATENAME(mm, LeaveDate) LeaveDateFormat,LeaveDate,
	CASE WHEN LeaveType='CL' THEN 'Casual Leave'  
    WHEN LeaveType='SL' THEN 'Sick Leave'  
    WHEN LeaveType='EL' THEN 'Earned Leave'  
    WHEN LeaveType='EW' THEN 'Extra Work'  
	WHEN LeaveType='LWP' THEN 'Leave Without Pay'   
    END LeaveType,
   	CASE WHEN LeaveCount=1.0 THEN 'Full Day'  
    WHEN LeaveCount=0.5 THEN 'Half Day' END LeaveCount 
	from  Leave l left join Employee on l.EmployeeId=[Employee].EmployeeId left join [User] u on l.EmployeeId=u.EmployeeId  where LeaveDate>=@TodaysDate and IsApproved=1) TempLeave
	order by LeaveDate,EmployeeName
	END;
END
GO
/****** Object:  StoredProcedure [dbo].[spGetUserContainerPermission]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ========================================================
-- Author:		Ankit Sharma 
-- Create date: 02 May 2016
-- Description: Get user Container permissions
-- ========================================================
CREATE PROCEDURE [dbo].[spGetUserContainerPermission]
 @ContainerId [uniqueidentifier] = NULL 
AS BEGIN

SET NOCOUNT ON;
SELECT u.UserId,
       u.UserName AS Name,
       CAST (CASE
                 WHEN cc.ContainerId IS NOT NULL THEN 1
                 ELSE 0
             END AS bit) AS Permission
FROM [User] u
LEFT JOIN
  (SELECT UserId,
          ContainerId
   FROM UserContainer
   WHERE ContainerId = @ContainerId) cc ON u.UserId = cc.UserId
WHERE (ISNULL(u.[Status],0) = 0 OR cc.UserId IS NOT NULL)
AND ISNULL(u.[Status],0) = 0
ORDER BY u.UserName END
GO
/****** Object:  StoredProcedure [dbo].[spGetUserEmployeeId]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author       : Ankit Sharma
-- Create date  : 10-Feb-2016
-- Description  : Get EmployeeId Based On UserId
-- Parameters   : 
-- =============================================
CREATE PROCEDURE [dbo].[spGetUserEmployeeId]
    @UserId UniqueIdentifier = null
AS
BEGIN
    SET NOCOUNT ON;
    SELECT EmployeeId FROM   [User] 
    WHERE  (UserId = @UserId OR @UserId IS NULL)

END
GO
/****** Object:  StoredProcedure [dbo].[spGetUserId]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author       : Ankit Sharma
-- Create date  : 25-April-2016
-- Description  : Get USERID Based On EmployeeId
-- Parameters   : 
-- =============================================
CREATE PROCEDURE [dbo].[spGetUserId]
    @EmployeeId UniqueIdentifier = null
AS
BEGIN
    SET NOCOUNT ON;
    SELECT UserId FROM   [User] 
    WHERE  ( EmployeeId = @EmployeeId OR @EmployeeId IS NULL)

END
GO
/****** Object:  StoredProcedure [dbo].[spGetUsers]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetUsers]
@UserId UNIQUEIDENTIFIER = NULL
AS
BEGIN
	SELECT DISTINCT UserId,UserName,LoginName FROM [User] WHERE Status=0 AND (@UserId IS NULL OR UserId=@UserId) ORDER BY UserName
END
GO
/****** Object:  StoredProcedure [dbo].[spGetUsersByRoleName]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetUsersByRoleName]
	@RoleName VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT u.UserId,
	       u.UserName,
	       u.LoginName
	FROM   [USER] u
	       INNER JOIN UserRole ur
	            ON  ur.UserId = u.UserId
	       INNER JOIN [Role] r
	            ON  r.RoleId = ur.RoleId
	            AND (r.Name = @RoleName OR @RoleName IS NULL)
END
GO
/****** Object:  StoredProcedure [dbo].[spGetVersion]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetVersion]
	@ComponentId UNIQUEIDENTIFIER
AS
BEGIN
	SELECT Version,VersionId,DBBuilds FROM Version v WHERE ComponentId=@ComponentId ORDER BY (CAST('/' + REPLACE(v.version , '.', '/') + '/' AS HIERARCHYID)) DESC
END
GO
/****** Object:  StoredProcedure [dbo].[spGetVersionBuildId]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetVersionBuildId] 
	@ComponentId UNIQUEIDENTIFIER
AS
BEGIN	
	SET NOCOUNT ON;

	SELECT DBBuilds, VersionId FROM Version  
	WHERE ComponentId = @ComponentId  ORDER BY DBBuilds DESC

END
GO
/****** Object:  StoredProcedure [dbo].[spGetVersionData]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetVersionData]
	@ComponentId UNIQUEIDENTIFIER	
AS
BEGIN		
		
		SELECT  VersionId,Version,BuildBy,BuildOn,DBBuilds,IsLocked,v.CreatedBy,v.CreatedOn,v.ModifiedBy,v.ModifiedOn,U.LoginName BuildByLogin from 
		version v 
		LEFT JOIN [User] u ON u.UserName=v.BuildBy
		WHERE ComponentId = @ComponentId
		order by cast('/' + replace(Version , '.', '/') + '/' as hierarchyid) desc
		
		SELECT  GitUrl from 
		Component  WHERE ComponentId = @ComponentId
	
END
GO
/****** Object:  StoredProcedure [dbo].[spGetVersionsForTask]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ankit Sharma
-- Create date: 24 May 2016
-- Description: Get All Versions For a Component By TaskId
-- =============================================
CREATE PROCEDURE [dbo].[spGetVersionsForTask]
	@TaskId UNIQUEIDENTIFIER,
	@Project NVARCHAR(50)
AS
BEGIN
	DECLARE @ComponentId uniqueidentifier
	DECLARE @TaskKey NVARCHAR(50)
		SELECT @ComponentId =  ComponentId FROM Task WHERE TaskId = @TaskId
		SELECT @TaskKey =  [key] FROM Task WHERE TaskId = @TaskId
		IF(@ComponentId IS NOT NULL)
		BEGIN
		SELECT VersionId,[Version] FROM [Version] where ComponentId=@ComponentId and IsLocked=0
		order by cast('/' + replace([Version] , '.', '/') + '/' as hierarchyid) desc
		SELECT @TaskKey as TaskKey
		END
END
GO
/****** Object:  StoredProcedure [dbo].[spGetWorklog]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetWorklog]
@UserId UNIQUEIDENTIFIER
AS BEGIN
   	SELECT wl.WorkDate,wl.WorkLogId,ji.IssueKey +' '+ ji.IssueSummary AS IssueSummary,wl.Hours,wl.Remarks 
   	  FROM WorkLog wl INNER JOIN JiraIssue ji ON ji.JiraIssueId = wl.JiraIssueId WHERE (wl.UserId = @UserId OR @UserId IS NULL)
END
GO
/****** Object:  StoredProcedure [dbo].[spGetWorklogByTask]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =====================================================
-- Author       : Narendra Shrivastava
-- Create date  : 26-Apr-2016
-- Description  : Used to Get worklog by task
-- =====================================================
CREATE PROCEDURE [dbo].[spGetWorklogByTask]
@TaskId UNIQUEIDENTIFIER
AS
BEGIN
	 SET NOCOUNT ON;

	 SELECT U.UserName,SUM(wl.Hours) AS Hours FROM WorkLog wl
	 LEFT OUTER JOIN [USER] U ON u.UserId = wl.UserId  
	 WHERE  TaskId=@TaskId
	 GROUP BY U.UserName
	 ORDER BY UserName
END
GO
/****** Object:  StoredProcedure [dbo].[spGetWorklogByTaskId]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetWorklogByTaskId]
    @TaskId Uniqueidentifier
AS
BEGIN
 SET NOCOUNT ON;
 SELECT TaskId,WorkDate,wl.Remarks,U.UserName,wl.Hours FROM WorkLog wl
 LEFT OUTER JOIN [USER] U ON u.UserId = wl.UserId  
 WHERE  TaskId=@TaskId
 ORDER BY WorkDate
END
GO
/****** Object:  StoredProcedure [dbo].[spInsertActivity]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spInsertActivity]
	@EntityType INT,
	@EntityId UNIQUEIDENTIFIER,
	@Description VARCHAR(100)= NULL,
	@CommentId UNIQUEIDENTIFIER = NULL,
	@IsInternal BIT = 0,
	@CreatedBy UNIQUEIDENTIFIER,
	@ActivityType INT = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	IF(isnull(@Description,'')='')
	BEGIN
		SELECT @Description = TypeName	FROM Types WHERE TypeId = @ActivityType
	END
	
	INSERT INTO Activity
	  (
	    ActivityId,
	    EntityType,
	    EntityId,
	    [Description],
	    CommentId,
	    IsInternal,
	    CreatedBy,
	    CreatedOn,
	    ActivityType
	  )
	VALUES
	  (
	    NEWID(),
	    @EntityType,
	    @EntityId,
	    @Description,
	    @CommentId,
	    @IsInternal,
	    @CreatedBy,
	    GETDATE(),
	    @ActivityType
	  )
END
GO
/****** Object:  StoredProcedure [dbo].[spInsertAttendance]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spInsertAttendance]
    @EmployeeId     uniqueidentifier,
    @AttendanceDate datetime,
    @InTime         datetime=null,
    @OutTime        datetime=null,
    @Attendance     decimal(2,1)=null,
    @IsWorkFromHome bit=0,
    @TotalMinute    int=null,
    @Remarks        nvarchar(255)=null
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @AttendanceId uniqueidentifier
    DECLARE @ExistingAttendanceId uniqueidentifier
 DECLARE @EmpName nvarchar(100)

    SELECT @AttendanceId = NEWID()
    SELECT @ExistingAttendanceId = AttendanceId FROM Attendance WHERE EmployeeId = @EmployeeId AND AttendanceDate = @AttendanceDate
 SELECT @EmpName = rtrim(Replace(FirstName + ' ' + isnull(MiddleName,'') + ' ' + isnull(LastName,''), '  ',' ')) from employee where EmployeeId = @EmployeeId

    IF (@ExistingAttendanceId IS NOT NULL)
    BEGIN
        EXEC spUpdateAttendance @ExistingAttendanceId,@AttendanceDate,@InTime,@OutTime,null,
    @IsWorkFromHome,@TotalMinute,@Remarks
    END
    ELSE
    BEGIN
        Insert Into Attendance (AttendanceId,EmployeeId,AttendanceDate,InTime,OutTime,Attendance,IsWorkFromHome,TimeInMinutes,Remarks,CreatedBy,CreatedOn)
                    Values     (@AttendanceId,@EmployeeId,@AttendanceDate,@InTime,@OutTime,ISNULL(@Attendance,0),@IsWorkFromHome,@TotalMinute,@Remarks,@EmpName,@InTime)    
    END
END
GO
/****** Object:  StoredProcedure [dbo].[spInsertClient]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spInsertClient]
    @Name    varchar(100),
    @Code    varchar(20),
    @Status    int,
    @CreatedBy          uniqueidentifier,
 @S3BucketName  varchar(50)=null
AS
BEGIN
    SET NOCOUNT ON;
    
    Insert Into Client (ClientId,Name,Code,[Status],CreatedBy,CreatedOn,ModifiedBy,ModifiedOn,S3BucketName)
                Values  (NEWID(),@Name,@Code,@Status,@CreatedBy,GETDATE(),null,null,@S3BucketName)
END
GO
/****** Object:  StoredProcedure [dbo].[spInsertComment]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spInsertComment]
 @EntityType   INT,
 @EntityId   uniqueidentifier,
 @Comment   varchar(max),
 @CreatedBy   uniqueidentifier
 
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @newCommentId UNIQUEIDENTIFIER;
	SET @newCommentId = NEWID();
    Insert Into Comment (CommentId,EntityType,EntityId,Comment,CreatedBy,CreatedOn)
                Values  (@newCommentId,@EntityType,@EntityId,@Comment,@CreatedBy,GETDATE())
    EXEC spInsertActivity @EntityType, @EntityId, 'added a comment', @newCommentId, 0, @CreatedBy
END
GO
/****** Object:  StoredProcedure [dbo].[spInsertComponents]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spInsertComponents]
    @ProjectId       uniqueidentifier,
    @ComponentName   nvarchar(50),
    @CreatedBy       uniqueidentifier,
	@IsDBComponent   bit,
	@IsVersionComponent   bit,
	@GitUrl			 nvarchar(100),
	@BuildPrefixForConfig nvarchar(100)
AS
BEGIN
    SET NOCOUNT ON;    
    DECLARE @ComponentId uniqueidentifier
    SELECT @ComponentId = NEWID()
    Insert Into Component(ComponentId,ProjectId,Name,CreatedBy,CreatedOn,IsDBComponent,IsVersionComponent,GitUrl,BuildPrefixForConfig)
    Values   (@ComponentId,@ProjectId,@ComponentName,@CreatedBy,GETDATE(),@IsDBComponent,@IsVersionComponent,@GitUrl,@BuildPrefixForConfig)
END
GO
/****** Object:  StoredProcedure [dbo].[spInsertContainer]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ========================================================
-- Author:		Ankit Sharma 
-- Create date: 03 May 2016
-- Description: Insert New Container
-- ========================================================
CREATE PROCEDURE [dbo].[spInsertContainer]
 @ContainerName   NVARCHAR(250),
 @Directories	  NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    
	DECLARE @NewContainerId UNIQUEIDENTIFIER = NEWID()
	IF NOT EXISTS(SELECT 1 FROM Container WHERE Name = @ContainerName)
	BEGIN
		INSERT INTO Container(ContainerId,IsDeleted, NAME,Folders) Values(@NewContainerId,0,@ContainerName,@Directories)
	END
END
GO
/****** Object:  StoredProcedure [dbo].[spInsertDataColumn]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spInsertDataColumn]
	@DataTableId		uniqueidentifier,
    @Name				varchar(50),
    @Description		varchar(max)=null,
    @Mandatory			bit=0,
	@DataType			varchar(20)=null,
	@DataLength			int=null,
	@Precision			int=null,
	@IsForeignKey		bit=0,
	@MinValue			varchar(100)=null,
	@MaxValue			varchar(100)=null,
	@DistinctValues		varchar(max)= null,
	@DistinctValueCount	int=null,
    @CreatedBy          uniqueidentifier
    
	
AS
BEGIN
    SET NOCOUNT ON;
    
    Insert Into DataColumn (DataColumnId,DataTableId,Name,[Description],Mandatory,DataType,[DataLength],[Precision],IsForeignKey,MinValue,MaxValue,DistinctValues,DistinctValueCount,CreatedBy,CreatedOn,ModifiedBy,ModifiedOn)
                Values		(NEWID(),@DataTableId,@Name,@Description,@Mandatory,@DataType,@DataLength,@Precision,@IsForeignKey,@MinValue,@MaxValue,@DistinctValues,@DistinctValueCount,@CreatedBy,GETDATE(),null,null)
END
GO
/****** Object:  StoredProcedure [dbo].[spInsertDataFile]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spInsertDataFile]
		@DataRequestId			UNIQUEIDENTIFIER=null,
		@FileType				int,
		@Name					varchar(50),
		@Description			varchar(max)=null,
		@Path					varchar(250)=null,
		@Source					varchar(250)=null,
		@SQLQuery				varchar(max)=null,
		@Status					int,
		@CreatorContactInfo		varchar(250)=null,
		@FileUploaded			bit=0,
		@UploadedBy				uniqueidentifier=null,
		@UploadedOn				datetime=null,
		@OwnerId				uniqueidentifier=null,
		@CreatedBy				uniqueidentifier,
		@ClientId				UNIQUEIDENTIFIER,
		@CleaningProcess		varchar(max)=null
		
		
	    
AS
BEGIN
    SET NOCOUNT ON;
    
    SET NOCOUNT ON;
    declare @FileNumber INT
    DECLARE @FileId UNIQUEIDENTIFIER
        set @FileNumber=(select isnull(max(FileNumber),100)+1 from DataFile)
        SET @FileId = NEWID();
    Insert Into DataFile (DataFileId,DataRequestId,FileType,Name,FileNumber,[Description],[Path],[Source],SQLQuery,CleaningProcess,
    [Status],CreatorContactInfo,FileUploaded,UploadedBy,UploadedOn,OwnerId,CreatedBy,ClientId,CreatedOn,ModifiedBy,ModifiedOn)
                Values  (@FileId,@DataRequestId,@FileType,@Name,@FileNumber,@Description,@Path,@Source,@SQLQuery,@CleaningProcess,@Status,@CreatorContactInfo,@FileUploaded,@UploadedBy,@UploadedOn,@OwnerId,@CreatedBy,@ClientId,GETDATE(),null,null)
	
	DECLARE @RequestStatus INT
	Select @RequestStatus = [STATUS] FROM DataRequest WHERE DataRequestId = @DataRequestId
	
	IF @RequestStatus = 0
	BEGIN
		UPDATE DataRequest SET [Status] = 1 WHERE DataRequestId = @DataRequestId
	END
	
	EXEC spInsertActivity 104, @FileId, 'added a new file', null, 0, @CreatedBy
END
GO
/****** Object:  StoredProcedure [dbo].[spInsertDataRequest]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [dbo].[spInsertDataRequest]
		@ClientId				uniqueidentifier,
		@RequestDate			datetime,
		@RequestedByUserId		uniqueidentifier=null,
		@AssignedToUserId		uniqueidentifier=null,
		@Status					int,
		@Description			varchar(max)=null,
		@EstimatedDate			datetime=null,
		@CreatedBy				uniqueidentifier
		
	    
AS
BEGIN
    SET NOCOUNT ON;
    declare @RequestNumber int

	set @RequestNumber=(select isnull(max(RequestNumber),1000)+1 from DataRequest)
    Insert Into DataRequest (DataRequestId,ClientId,RequestNumber,RequestDate,RequestedByUserId,AssignedToUserId,[Status],[Description],EstimatedDate,CreatedBy,CreatedOn,ModifiedBy,ModifiedOn)
                Values  (NEWID(),@ClientId,@RequestNumber,@RequestDate,@RequestedByUserId,@AssignedToUserId,@Status,@Description,@EstimatedDate,@CreatedBy,GETDATE(),null,null)
END
GO
/****** Object:  StoredProcedure [dbo].[spInsertDataTable]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spInsertDataTable]
    @Name				varchar(50),
    @DBInfo				varchar(100),
    @DataFileId			uniqueidentifier,
    @OwnerId			uniqueidentifier=null,
    @Description		varchar(max)=null,
    @RowCount			int=null,
	@CreatedBy			uniqueidentifier,
	@ClientId			uniqueidentifier
	
AS
BEGIN
    SET NOCOUNT ON;
    
    Insert Into DataTable(DataTableId,Name,DBInfo,DataFileId,OwnerId,[Description],[RowCount],CreatedBy,ClientId,CreatedOn,ModifiedBy,ModifiedOn)
                Values	(NEWID(),@Name,@DBInfo,@DataFileId,@OwnerId,@Description,@RowCount,@CreatedBy,@ClientId,GETDATE(),null,null)
END
GO
/****** Object:  StoredProcedure [dbo].[spInsertDBBuild]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Pabitra Dash
-- Create date: 20/03/2014
-- Description:	Stored procedure to insert a new DB build entry
-- =============================================
CREATE PROCEDURE [dbo].[spInsertDBBuild] 
	@ComponentId	uniqueidentifier,
	@Name			VARCHAR(50),
	@CreatedBy		uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO DBBuild (DBBuildId, ComponentId, Name, IsLocked, CreatedBy, CreatedOn)
		   VALUES (NEWID(), @ComponentId, @Name, 0, @CreatedBy, GETDATE())
END
GO
/****** Object:  StoredProcedure [dbo].[spInsertDBScript]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Pabitra Dash
-- Create date: 12/03/2014
-- Description:	Procedure to insert DB Script
-- =============================================
CREATE PROCEDURE [dbo].[spInsertDBScript]
	-- Add the parameters for the stored procedure here
	@DBBuildId		uniqueidentifier,
	@Name			VARCHAR(50),
	@Description	VARCHAR(MAX),
	@DBScriptType   int,
	@DBChangeType   int,
	@Reference		VARCHAR(50),
	@Script			NVARCHAR(MAX),
	@ChangedOn      DateTime,
	@ChangedBy      uniqueidentifier,
	@CreatedBy		uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @recordCount INT;
	Declare @SequenceNumber int = 10;
  
	SELECT @recordCount = Count(*) FROM DBScript  WHERE DBBuildId = @DBBuildId
	IF (@recordCount > 0)
	BEGIN
		SELECT @SequenceNumber=MAX(IsNull(Sequence, 0)) + 10 from DBScript  WHERE DBBuildId = @DBBuildId
	END
    -- Insert statements for procedure here
	Insert into DBScript (DBScriptId, DBBuildId, Name, [Description], DBScriptType, DBChangeType, Reference, Script, ChangedBy, ChangedOn, Sequence, CreatedBy, CreatedOn)
				  VALUES (NEWID(), @DBBuildId, @Name, @Description, @DBScriptType, @DBChangeType, @Reference, @Script, @ChangedBy, @ChangedOn, @SequenceNumber, @CreatedBy, GETDATE())
END
GO
/****** Object:  StoredProcedure [dbo].[spInsertDetailVersionData]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spInsertDetailVersionData]
	-- Add the parameters for the stored procedure here
	--@VersionChangeId     UNIQUEIDENTIFIER,
	@VersionId           UNIQUEIDENTIFIER,
	@Reference           nvarchar(50)=NULL,
	@FileChanges	     nvarchar(2000)=NULL,
	@DBChanges			 nvarchar(2000)=NULL, 
	@Description		 nvarchar(4000) = NULL,
	@ChangedBy			 nvarchar(50)=NULL,
	@ChangedOn			 datetime,
	@QAStatus			 int,
	@CreatedBy           UNIQUEIDENTIFIER

AS
BEGIN
	SET NOCOUNT ON;
	IF NOT EXISTS(SELECT 1 FROM VersionChange  WHERE VersionId=@VersionId AND Reference=@Reference)
	BEGIN
		INSERT INTO VersionChange(VersionChangeId,VersionId,Reference,FileChanges,DBChanges,[Description],ChangedBy,ChangedOn,QAStatus,CreatedBy,CreatedOn)
		VALUES(NEWID(),@VersionId,@Reference,@FileChanges,@DBChanges,@Description,@ChangedBy,@ChangedOn,@QAStatus,@CreatedBy,GETDATE())		
	END
END
GO
/****** Object:  StoredProcedure [dbo].[spInsertDownloadFile]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spInsertDownloadFile]
	@Folder nvarchar(250),
	@File nvarchar(500)=null	
AS
BEGIN
    SET NOCOUNT ON;

	Insert Into DownloadFile (DownloadFileId, Folder, [File])
                Values   (NEWID(), @Folder, @File)
	
END
GO
/****** Object:  StoredProcedure [dbo].[spInsertEmailTepmlate]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spInsertEmailTepmlate] 
@TemplateName NVARCHAR(50),
@FromEmailId NVARCHAR(100),
@ToEmailId NVARCHAR(100), 
@CCEmailId NVARCHAR(100),
@Subject NVARCHAR(200), 
@Body NVARCHAR(MAX),
@Status INT,
@CreatedBy uniqueidentifier=null
AS
BEGIN
	SET NOCOUNT ON;
	INSERT INTO EmailTemplate(EmailTemplateId, TemplateName, FromEmailId,ToEmailId, CCEmailId, [Subject], Body, [Status], CreatedBy,CreatedOn)
	            VALUES(NEWID(),@TemplateName,@FromEmailId,@ToEmailId,@CCEmailId,@Subject,@Body,@Status,@CreatedBy,GETDATE())
END
GO
/****** Object:  StoredProcedure [dbo].[spInsertEmployee]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spInsertEmployee]    
    @FirstName       nvarchar(50),    
    @MiddleName      nvarchar(50)=null,    
    @LastName        nvarchar(50)=null,    
    @Designation     nvarchar(50)=null,    
    @Gender          nvarchar(1)=null,        
    @DateOfBirth     datetime=null,    
    @Anniversary     datetime=null,    
    @Remarks         nvarchar(255)=null,    
    @DateOfJoining   datetime=null,    
    @DateOfRelieving datetime=null,    
    @PanNo           nvarchar(20)=null,    
    @FatherName      nvarchar(100)=null,    
    @EmployeeType    nvarchar(10)=null,    
    @BankDetail      nvarchar(255)=null,  
	@OrignalDateOfBirth datetime=null    
AS    
BEGIN    
    SET NOCOUNT ON;    
        
    DECLARE @EmployeeId uniqueidentifier    
    
    SELECT @EmployeeId = NEWID()    
    Insert Into Employee (EmployeeId,FirstName,MiddleName,LastName,Designation,Gender,DateOfBirth,Anniversary,Remarks,DateOfJoining,    
                          DateOfRelieving,PanNo,FatherName,EmployeeType,BankDetail,OrignalDateOfBirth,CreatedBy,CreatedOn)    
                Values   (@EmployeeId,@FirstName,@MiddleName,@LastName,@Designation,@Gender,@DateOfBirth,@Anniversary,@Remarks,@DateOfJoining,    
                          @DateOfRelieving,@PanNo,@FatherName,@EmployeeType,@BankDetail,@OrignalDateOfBirth,substring(SYSTEM_USER,5,LEN(SYSTEM_USER)),GetDate()) 
						  
END
GO
/****** Object:  StoredProcedure [dbo].[spInsertHoliday]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spInsertHoliday]
@HolidayDate datetime,
@Name nvarchar(100),
@Remarks nvarchar(255)
AS
BEGIN
 SET NOCOUNT ON;
 Insert Into Holiday (HolidayDate,Name,Remarks) Values(@HolidayDate,@Name,@Remarks)
END
GO
/****** Object:  StoredProcedure [dbo].[spInsertIssue]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spInsertIssue]
@JiraIssueId INT,
@IssueKey NVARCHAR(15),
@IssueSummary NVARCHAR(100),
@IssueType INT,
@ProjectId Int,
@ComponentId INT,
@Component VARCHAR(50),
@UserId UNIQUEIDENTIFIER
AS BEGIN
	DECLARE @ProjectUid UNIQUEIDENTIFIER
	SELECT @ProjectUid = ProjectId FROM Project p WHERE p.JiraProjectId = @ProjectId
	
	IF EXISTS(SELECT 1 FROM Component WHERE JiraComponentId = @ComponentId)
 BEGIN
  UPDATE Component SET NAME=@Component,ModifiedBy = @UserId,ModifiedOn =GETDATE() WHERE JiraComponentId = @ComponentId
 END
 ELSE
  BEGIN
  IF(LEN(@ComponentId) > 0)
      INSERT INTO Component VALUES (NEWID(),@ProjectUid,@Component,@UserId,GETDATE(),NULL,NULL,@ComponentId)
  END
  
 IF EXISTS(SELECT 1 FROM JiraIssue WHERE JiraIssueId=@JiraIssueId)
 BEGIN
  UPDATE JiraIssue SET IssueKey=@IssueKey,IssueSummary=@IssueSummary,IssueType=@IssueType,ProjectId = @ProjectId,
  Component=@ComponentId,UpdatedBy=@UserId,UpdatedDate=GETDATE()
  WHERE JiraIssueId=@JiraIssueId
 END
 ELSE
  BEGIN
      INSERT INTO JiraIssue VALUES (@JiraIssueId,@IssueKey,@IssueSummary,@IssueType,@ProjectId,@ComponentId,@UserId,GETDATE(),NULL,NULL)
  END
END
GO
/****** Object:  StoredProcedure [dbo].[spInsertLeave]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spInsertLeave]
    @EmployeeId UNIQUEIDENTIFIER, 
	@LeaveFromDate DATETIME, 
	@LeaveToDate DATETIME, 
	@LeaveType NVARCHAR(5), 
	@LeaveCount DECIMAL(5, 1), 
	@Remarks NVARCHAR(255),
    @IsApproved BIT = 0, 
	@IsSecondHalf BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @LeaveId UNIQUEIDENTIFIER;
    DECLARE @CountLeaves DECIMAL(5, 1);
    DECLARE @Count DECIMAL(5, 1);
    DECLARE @ExistingLeaveFlag DATETIME;

    SET @Count = 0;
    IF @LeaveToDate IS NULL
    BEGIN
        SET @LeaveToDate = DATEADD(DAY, 1, @LeaveFromDate);
    END;
    SET @CountLeaves = DATEDIFF(DAY, @LeaveFromDate, @LeaveToDate);
    WHILE @Count <= @CountLeaves
    BEGIN
        -- check if there is existing leave for this date
        SELECT @ExistingLeaveFlag = LeaveDate FROM dbo.[Leave] WHERE EmployeeId = @EmployeeId AND LeaveDate = @LeaveFromDate;
        IF (@ExistingLeaveFlag IS NULL)
        BEGIN
            IF (FORMAT(@LeaveFromDate, 'dddd') <> 'Saturday' AND FORMAT(@LeaveFromDate, 'dddd') <> 'Sunday')
            BEGIN
                SELECT @LeaveId = NEWID();
                INSERT INTO dbo.[Leave] (LeaveId, EmployeeId, LeaveDate, LeaveType, LeaveCount, Remarks, CreatedBy, CreatedOn, IsApproved, IsSecondHalf)
                VALUES
                (@LeaveId, @EmployeeId, @LeaveFromDate, @LeaveType, CASE WHEN @LeaveType = 'EW' THEN -1 * @LeaveCount ELSE @LeaveCount END, @Remarks,
                 SUBSTRING(SYSTEM_USER, 5, LEN(SYSTEM_USER)), GETDATE(), @IsApproved, @IsSecondHalf);
            END;
        END;
        SET @LeaveFromDate = DATEADD(DAY, 1, @LeaveFromDate);
        SET @Count = @Count + 1;
    END;
END;
GO
/****** Object:  StoredProcedure [dbo].[spInsertLicense]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spInsertLicense]
    @LicenseId    uniqueidentifier Output,
	@Product varchar(20)=cp,
	@Edition varchar(10)=5,
	@Version varchar(10)=1,
	@Users int=5,
	@Mode varchar(5)=T,
	@ExpiryDate date=null,
	@FirstName varchar(50),
	@LastName varchar(50)=null,
	@CompanyName varchar(128),
	@Email varchar(256)=null
AS
BEGIN
    SET NOCOUNT ON;
	
    SELECT @LicenseId = NEWID()
	Insert Into License (LicenseId,Product,Edition,[Version],Users,Mode,ExpiryDate,FirstName,CompanyName,Email)
                Values   (@LicenseId,@Product,@Edition,@Version,@Users,@Mode,@ExpiryDate,@FirstName,@CompanyName,@Email)
	
END
GO
/****** Object:  StoredProcedure [dbo].[spInsertModule]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spInsertModule]
	@Name				varchar(50),
	@ParentModuleId		uniqueidentifier=null,
	@PageURL			varchar(max)=null,
	@ClientId			uniqueidentifier=null,
	@Description		varchar(50)=null,
	@Status				int,
	@CreatedBy			uniqueidentifier,
	@Sequence			int
	
AS
BEGIN
    SET NOCOUNT ON;   
    Insert Into [Module] (ModuleId,Name,ParentModuleId,PageURL,ClientId,[Description],[Status],CreatedBy,CreatedOn,ModifiedBy,ModifiedOn,Sequence)
    Values  (NEWID(),@Name,@ParentModuleId,@PageURL,@ClientId,@Description,@Status,@CreatedBy,GETDATE(),null,null,@Sequence)
END
GO
/****** Object:  StoredProcedure [dbo].[spInsertProject]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spInsertProject]
	@ClientId			uniqueidentifier,
    @Name				varchar(50),
    @Code				varchar(20),
    @Status				int,
    @Description		varchar(Max)=null,
    @CreatedBy          uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;
    
    Insert Into Project (ProjectId,ClientId,Name,Code,[Status],[Description],CreatedBy,CreatedOn,ModifiedBy,ModifiedOn)
                Values  (NEWID(),@ClientId,@Name,@Code,@Status,@Description,@CreatedBy,GETDATE(),null,null)
END
GO
/****** Object:  StoredProcedure [dbo].[spInsertReleaseNote]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spInsertReleaseNote]
	
	@VersionId			 UNIQUEIDENTIFIER,
	@Reference			 NVARCHAR(10) = NULL, 
	@Type			     INT = NULL,
	@Title			     NVARCHAR(500) = NULL,	
	@Remarks			 NVARCHAR(1000) = NULL,	
	@IsPublic            BIT,
	@ReleaseNoteSummaryId UNIQUEIDENTIFIER=NULL
	

AS
BEGIN
	SET NOCOUNT ON;
		INSERT INTO ReleaseNote(ReleaseNoteId,VersionId,Reference,[Type],Title,Remarks,IsPublic,Sequence,ReleaseNoteSummaryId)
				        VALUES(NEWID(),@VersionId,@Reference,@Type,@Title,@Remarks,1,10,@ReleaseNoteSummaryId)

END
GO
/****** Object:  StoredProcedure [dbo].[spInsertReleaseNoteSummary]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spInsertReleaseNoteSummary]
@ComponentId    UNIQUEIDENTIFIER,
@ReleaseTitle   NVARCHAR(250),
@IsLocked       BIT,
@CreatedBy      UNIQUEIDENTIFIER,
@ReleaseDate    DATETIME
AS
BEGIN
	SET NOCOUNT ON;
	Insert into ReleaseNoteSummary(ReleaseNoteSummaryId,ComponentId,ReleaseDate,ReleaseTitle,IsLocked,CreatedBy,CreatedOn)
				values(NEWID(),@ComponentId,@ReleaseDate,@ReleaseTitle,@IsLocked,@CreatedBy,GETDATE())
END
GO
/****** Object:  StoredProcedure [dbo].[spInsertSiteName]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spInsertSiteName]
	@ComponentId UNIQUEIDENTIFIER,
	@SiteName    VARCHAR(50),
	@SiteLink    VARCHAR(50)
AS
BEGIN
	INSERT INTO DeploymentSite(DeploymentSiteId,ComponentId,SiteName,SiteLink,Status)
		VALUES(NEWID(),@ComponentId,@SiteName,@SiteLink,1)
END
GO
/****** Object:  StoredProcedure [dbo].[spInsertSoftwareDownload]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spInsertSoftwareDownload]
    @DownloadFileId    uniqueidentifier
	
AS
BEGIN
    SET NOCOUNT ON;
    Insert Into SoftwareDownload (SoftwareDownloadId, DownloadFileId)
                Values   (NEWID(), @DownloadFileId)
END
GO
/****** Object:  StoredProcedure [dbo].[spInsertTask]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spInsertTask]
	@ProjectId			UNIQUEIDENTIFIER,
	@Summary			NVARCHAR(500),
	@TaskType			INT,
	@Status				INT,
	@PriorityType		INT,
	@ResolutionType		INT=NULL,
	@Assignee			NVARCHAR(100)=NULL,
	@Reporter			NVARCHAR(100),
	@ComponentId		UNIQUEIDENTIFIER=NULL,
	@DueDate		    DATETIME=NULL,
	@OriginalEstimate   INT=NULL,
	@TimeSpent			INT=NULL,
	@RemainingEstimate  INT=NULL,
	@Description		NVARCHAR(4000)=NULL,
	@Area				NVARCHAR(100)=NULL,	
	@CreatedBy		    UNIQUEIDENTIFIER
AS
BEGIN
		DECLARE @NewKey VARCHAR(30),@Rank INT = 10;
		IF(@ComponentId='00000000-0000-0000-0000-000000000000') 
		BEGIN
		    SET @ComponentId=NULL
		END
		--Create Rank
		SELECT @Rank=MAX(IsNull([Rank], 0)) + 10 from Task  WHERE ProjectId = @ProjectId		
		
		-- Create Key 
		SELECT @NewKey = max(p.Code)+ '-' +CAST( MAX(ISNULL(CAST(SUBSTRING([Key], LEN(p.Code) + 2, 10) AS INT),0)) + 1 AS VARCHAR) from Project p
		left join task ts ON  p.ProjectId = ts.ProjectId  
		WHERE P.ProjectId =@ProjectId

    DECLARE @NewTaskId UNIQUEIDENTIFIER = NEWID()		

	INSERT INTO Task(TaskId,ProjectId,[Key],Summary,TaskType,[Status],PriorityType,ResolutionType,Assignee,Reporter,ComponentId,DueDate,OriginalEstimate,TimeSpent,RemainingEstimate,
		[Description],Area,[Rank],CreatedBy,CreatedOn)
	VALUES				
		(@NewTaskId,@ProjectId,@NewKey,@Summary,@TaskType,@Status,@PriorityType,@ResolutionType,@Assignee,@Reporter,@ComponentId,@DueDate,@OriginalEstimate,@TimeSpent,@RemainingEstimate,@Description,
		@Area,@Rank,@CreatedBy,getdate())
		
		--Add activity for task created
		 EXEC spInsertActivity @EntityType=101,@EntityId= @NewTaskId,@Description=NULL,@CommentId= NULL,@IsInternal= 0,@CreatedBy= @CreatedBy,@ActivityType=11001
		
		IF(ISNULL(@Assignee,'') <> '')
		BEGIN
			--Add activity for task assigned when created
			WAITFOR DELAY '00:00:00:005' ---- 5 MiliSecond Delay to Prevent Duplicate Activity Changedon Time
			DECLARE @assigneeDesc NVARCHAR(50)= NULL
			SELECT @assigneeDesc = TypeName +' to ' + @Assignee FROM Types WHERE CategoryId = 105 AND TypeId = 11004
			EXEC spInsertActivity @EntityType=101,@EntityId= @NewTaskId,@Description=@assigneeDesc,@CommentId= NULL,@IsInternal= 0,@CreatedBy= @CreatedBy,@ActivityType=11004
		END
		
		IF(ISNULL(@Status,0) NOT IN (0,12))
		BEGIN
			--Add activity for task status when created
			WAITFOR DELAY '00:00:00:005' ---- 5 MiliSecond Delay to Prevent Duplicate Activity Changedon Time
			
			DECLARE @statusDesc NVARCHAR(50)= NULL
			SELECT @statusDesc = NAME FROM [status] ts WHERE ts.EntityType=11 AND ts.[Status] = 21
			SELECT @statusDesc = TypeName +' changed to ' + @statusDesc FROM Types WHERE CategoryId = 105 AND TypeId = 11002
			EXEC spInsertActivity @EntityType=101,@EntityId= @NewTaskId,@Description=@statusDesc,@CommentId= NULL,@IsInternal= 0,@CreatedBy= @CreatedBy,@ActivityType=11002
		END
END
GO
/****** Object:  StoredProcedure [dbo].[spInsertTaskFromEmail]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================
-- Author       : Narendra Shrivastava
-- Create date  : 22-Feb-2016
-- Description  : Create Task from Email and save attachments also
-- Parameters   : 
-- ==============================================================
CREATE PROCEDURE [dbo].[spInsertTaskFromEmail]
@From NVARCHAR(100),
@To NVARCHAR(MAX),
@Cc NVARCHAR(MAX) = NULL,
@Subject NVARCHAR(500),
@Body NVARCHAR(4000) = NULL
AS
BEGIN
 DECLARE @AssigneeEmail nvarchar(100)  = NULL

 DECLARE @ProjectId UNIQUEIDENTIFIER = NULL
 DECLARE @CreatedBy UNIQUEIDENTIFIER = '743E21CE-4388-487A-805F-486CD86DD7B3'

 DECLARE @Assignee NVARCHAR(100)  = NULL
 DECLARE @Reporter NVARCHAR(100)  =  'Shiv Pujan Singh'

 Select @Body = ISNULL(@Body,'') + CHAR(13) + CHAR(10) + '[Created via e-mail received from: ' + @From + ']'

 SELECT TOP 1 @Cc = item from dbo.fnSplit(@cc,',')

 SELECT TOP 1 @ProjectId = ProjectId from Project where REPLACE(Name,' ','') = 
	(
		SELECT SUBSTRING(Email,0,CHARINDEX('@',Email)) FROM dbo.fnGetEmailAdress(ISNULL(@To,'') + ' ' + ISNULL(@Cc,''))
		--WHERE Email IN ('irportal@portal.insightresults.com','eimpact@portal.insightresults.com','irportal@portalqa.insightresults.com','eimpact@portalqa.insightresults.com') 
		WHERE Email like ('%@portal.insightresults.com') OR Email like ('%@portalqa.insightresults.com')
	)

 --Get Reporter
 SELECT TOP 1 @From = ISNULL(email, @From) from dbo.fnGetEmailAdress(@From)
 SELECT @Reporter = ISNULL(UserName,'Shiv Pujan Singh'),@CreatedBy = ISNULL(UserId,'743E21CE-4388-487A-805F-486CD86DD7B3') from [User] where Email =  @From

 --Get Assignee email
 SELECT TOP 1 @AssigneeEmail =  Email FROM dbo.fnGetEmailAdress(ISNULL(@To,'') + ' ' + ISNULL(@Cc,'')) 
 --WHERE Email NOT IN ('irportal@portal.insightresults.com','eimpact@portal.insightresults.com','irportal@portalqa.insightresults.com','eimpact@portalqa.insightresults.com')
 WHERE Email NOT LIKE ('%@portal.insightresults.com') AND Email NOT LIKE ('%@portalqa.insightresults.com')

 --Get Assignee 
 SELECT @Assignee = UserName from [User] where Email =  @AssigneeEmail

 IF (@ProjectId IS NOT NULL AND @Reporter IS NOT NULL)
 BEGIN

	DECLARE @NewKey VARCHAR(30),@Rank INT = 10;
	
		--Create Rank
		SELECT @Rank=MAX(IsNull([Rank], 0)) + 10 from Task  WHERE ProjectId = @ProjectId		
		
		-- Create Key 
		SELECT @NewKey = max(p.Code)+ '-' +CAST( MAX(ISNULL(CAST(SUBSTRING([Key], LEN(p.Code) + 2, 10) AS INT),0)) + 1 AS VARCHAR) from Project p
		left join task ts ON  p.ProjectId = ts.ProjectId  
		WHERE P.ProjectId =@ProjectId

		DECLARE @NewTaskId UNIQUEIDENTIFIER = NEWID()		

		INSERT INTO Task(TaskId,ProjectId,[Key],Summary,TaskType,[Status],PriorityType,ResolutionType,Assignee,Reporter,ComponentId,DueDate,OriginalEstimate,TimeSpent,RemainingEstimate,
			[Description],Area,[Rank],CreatedBy,CreatedOn)
		VALUES				
			(@NewTaskId,@ProjectId,@NewKey,@Subject,4,12,3,NULL,@Assignee,@Reporter,NULL,NULL,NULL,NULL,NULL,@Body,
			NULL,@Rank,@CreatedBy,GETDATE())
		
		--Add activity for task created
		 EXEC spInsertActivity @EntityType=101,@EntityId= @NewTaskId,@Description=NULL,@CommentId= NULL,@IsInternal= 0,@CreatedBy= @CreatedBy,@ActivityType=11001
		
		IF(ISNULL(@Assignee,'') <> '')
		BEGIN
			--Add activity for task assigned when created
			WAITFOR DELAY '00:00:00:005' ---- 5 MiliSecond Delay to Prevent Duplicate Activity Changedon Time
			DECLARE @assigneeDesc NVARCHAR(50)= NULL
			SELECT @assigneeDesc = TypeName +' to ' + @Assignee FROM Types WHERE CategoryId = 105 AND TypeId = 11004
			EXEC spInsertActivity @EntityType=101,@EntityId= @NewTaskId,@Description=@assigneeDesc,@CommentId= NULL,@IsInternal= 0,@CreatedBy= @CreatedBy,@ActivityType=11004
		END

		SELECT @NewTaskId
 END
 ELSE 
	 BEGIN
			SELECT ''
	 END
 

END
GO
/****** Object:  StoredProcedure [dbo].[spInsertTaxSavingReceipt]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================
-- Author       : Ankit Sharma
-- Create date  : 07-April-2016
-- Description  : Create Tax Saving Receipt
-- Parameters   : 
-- ==============================================================
CREATE PROCEDURE [dbo].[spInsertTaxSavingReceipt]
	@EmployeeId			uniqueidentifier,
	@FinancialYear		int,
	@TaxSavingType      int,
	@RecurringFrequency int,
	@SavingDate        	date=null,
	@AccountNumber     	nvarchar(100),
	@Amount            	decimal(8,2),
	@Remarks           	nvarchar(100),
	@EligibleCount		int
AS	 
BEGIN	

	INSERT INTO TaxSaving(TaxSavingId,EmployeeId,FinancialYear,TaxSavingType,RecurringFrequency,SavingDate,AccountNumber,Amount,Remarks,EligibleCount)
	VALUES(NEWID(),@EmployeeId,@FinancialYear,@TaxSavingType,@RecurringFrequency,@SavingDate,@AccountNumber,@Amount,@Remarks,@EligibleCount)
END
GO
/****** Object:  StoredProcedure [dbo].[spInsertTaxSavingType]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spInsertTaxSavingType]
(
@TaxSavingTypeName NVARCHAR(100),
@TaxCategoryCode NVARCHAR(20)
)
AS 
 BEGIN
  
  SET NOCOUNT ON;
  DECLARE @TaxSavingType INT
  SELECT @TaxSavingType = MAX(TaxSavingType)+1  FROM TaxSavingType 
    
  INSERT INTO TaxSavingType(TaxSavingType,TaxSavingTypeName,TaxCategoryCode)VALUES(@TaxSavingType,@TaxSavingTypeName,@TaxCategoryCode)
END
GO
/****** Object:  StoredProcedure [dbo].[spInsertUser]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spInsertUser]
	@ClientId		uniqueidentifier=null,
	@UserName		varchar(100),
	@Email			varchar(100)=null,
	@LoginName		varchar(20),
	@Password nvarchar(max)=null,
	@Status			int,
	@CreatedBy		uniqueidentifier
	
AS
BEGIN
    SET NOCOUNT ON;
	declare @CID as uniqueidentifier
	if(@ClientId= '00000000-0000-0000-0000-000000000000')
	begin
	set @CID=null;
	end
	else
	begin
	set @CID=@ClientId
	end
    declare @pass varbinary(max)
	 set @pass=( select EncryptByPassPhrase('key',@Password ))
    Insert Into [User] (UserId,ClientId,UserName,Email,LoginName,[Password],[Status],CreatedBy,CreatedOn,ModifiedBy,ModifiedOn)
                Values  (NEWID(),@CID,@UserName,@Email,@LoginName,@pass,@Status,@CreatedBy,GETDATE(),@CreatedBy,GETDATE())
END
GO
/****** Object:  StoredProcedure [dbo].[spInsertVersionChangeCommit]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Ranjan
-- Create date: 11 May 2016
-- Description: Insert version change commit details
-- =============================================
CREATE PROCEDURE [dbo].[spInsertVersionChangeCommit]
	@VersionChangeId    UNIQUEIDENTIFIER,
	@GitCommitId        NVARCHAR(50),
	@CommittedFiles     NVARCHAR(2000) = NULL,
	@CommitDescription  NVARCHAR(2000),
	@CommittedBy          UNIQUEIDENTIFIER,
	@CommittedOn          DATETIME
AS
BEGIN
	SET NOCOUNT ON;
	IF NOT EXISTS(SELECT 1 FROM VersionChangeCommit WHERE VersionChangeId = @VersionChangeId AND GitCommitId = @GitCommitId)
	BEGIN
	    INSERT INTO VersionChangeCommit(VersionChangeCommitId,VersionChangeId,GitCommitId,CommittedBy,CommittedOn,CommittedFiles,[Description])
	    VALUES(NEWID(),@VersionChangeId,@GitCommitId,@CommittedBy,@CommittedOn,@CommittedFiles,@CommitDescription)
	END
END
GO
/****** Object:  StoredProcedure [dbo].[spInsertVersionData]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[spInsertVersionData]
	-- Add the parameters for the stored procedure here
	--@VersionId           UNIQUEIDENTIFIER = null,
	@ComponentId         UNIQUEIDENTIFIER,
	@Version			 nvarchar(10),
	@BuildBy			 nvarchar(20), 
	@BuildOn			 datetime,
	@DBBuilds			 nvarchar(50),	
	@IsLocked            bit,
	@CreatedBy			 UNIQUEIDENTIFIER,	
	@ModifiedBy			 UNIQUEIDENTIFIER	

AS
BEGIN
	SET NOCOUNT ON;

	Insert into Version(VersionId,ComponentId,Version,BuildBy,BuildOn,DBBuilds,IsLocked,CreatedBy,CreatedOn,ModifiedBy,ModifiedOn)
				values(NEWID(),@ComponentId,@Version,@BuildBy,@BuildOn,@DBBuilds,@IsLocked,@CreatedBy,GETDATE(),@ModifiedBy,GETDATE())

END
GO
/****** Object:  StoredProcedure [dbo].[spInsertVersionDeployment]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spInsertVersionDeployment]
	 @VersionId        UNIQUEIDENTIFIER,	 
	 @DeploymentSiteId UNIQUEIDENTIFIER,
	 @DeployedBy       varchar(50),
	 @DeployedOn       datetime,
	 @Remarks          nvarchar(1000)

AS
BEGIN
	SET NOCOUNT ON;

	IF  EXISTS(SELECT 1 FROM VersionDeployment WHERE VersionId=@VersionId AND DeploymentSiteId=@DeploymentSiteId)
	BEGIN
		UPDATE VersionDeployment SET  DeployedBy=@DeployedBy,DeployedOn=DATEADD(MINUTE,-330,@DeployedOn),Remarks=@Remarks WHERE VersionId=@VersionId and DeploymentSiteId=@DeploymentSiteId
	END
	ELSE
	BEGIN
		INSERT INTO VersionDeployment(VersionId,DeploymentSiteId,DeployedBy,DeployedOn,Remarks)
						VALUES(@VersionId,@DeploymentSiteId,@DeployedBy,DATEADD(MINUTE,-330,@DeployedOn),@Remarks)
	END	

END
GO
/****** Object:  StoredProcedure [dbo].[spInsertWorkLog]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spInsertWorkLog]
@WorkLogId UNIQUEIDENTIFIER, 
@UserId UNIQUEIDENTIFIER,
@JiraIssueId INT=NULL,
@WorkDate DATETIME,
@Hours decimal(6,2),
@Remarks NVARCHAR(100),
@TaskId UNIQUEIDENTIFIER,
@RemainingEstimate INT=NULL
AS 
BEGIN
 IF EXISTS(SELECT 1 FROM WorkLog wl WHERE wl.UserId=@UserId AND wl.JiraIssueId = @JiraIssueId AND wl.WorkDate = @WorkDate )
   	BEGIN
   	DELETE FROM WorkLog WHERE UserId=@UserId AND JiraIssueId = @JiraIssueId AND WorkDate = @WorkDate
   	END
   		INSERT INTO WorkLog	( WorkLogId,UserId,	JiraIssueId,WorkDate,Hours,	Remarks,CreatedBy,CreatedDate,UpdatedBy,UpdatedDate,TaskId)
   			VALUES	( @WorkLogId,@userId, @JiraIssueId,@workDate,@Hours,@Remarks,@UserId,GETDATE(),null,null,@TaskId)

		UPDATE Task SET RemainingEstimate=@RemainingEstimate WHERE TaskId=@TaskId
		
		IF  exists(select 1 from task where taskid = @TaskId and [status] in (12,22,23))
		BEGIN 
			update task set [status] = 21 where taskid = @TaskId
   		END 
   	
END
GO
/****** Object:  StoredProcedure [dbo].[spLockReleaseNoteSummary]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spLockReleaseNoteSummary]
@ReleaseNoteSummaryId UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;
	Update ReleaseNoteSummary set IsLocked=1 where ReleaseNoteSummaryId=@ReleaseNoteSummaryId
END
GO
/****** Object:  StoredProcedure [dbo].[spMapEmployee]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--========================================================
-- Author:		Avadhesh kumar
-- Create date: 17 June 2019
-- Description: map employees
-- ========================================================
CREATE PROCEDURE [dbo].[spMapEmployee]  
 @UserId NVARCHAR(500),
 @EmployeeId NVARCHAR(500)
AS  
BEGIN   
	SET NOCOUNT ON;   
	update [dbo].[User] SET  EmployeeId=@EmployeeId WHERE UserId=@UserId
	update [dbo].[Employee] SET MapStatus=1 WHERE EmployeeId=@EmployeeId
END
GO
/****** Object:  StoredProcedure [dbo].[spMoveChanges]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spMoveChanges]	
	@VersionId		 UNIQUEIDENTIFIER = NULL,
	@VersionChangeId UNIQUEIDENTIFIER = NULL,
	@Status INT
AS
BEGIN
	SET NOCOUNT ON;	
	IF(ISNULL(@Status,0) = 0)	
	BEGIN
		IF EXISTS(SELECT * FROM VersionChange WHERE VersionChangeId=@VersionChangeId)
		BEGIN	
			UPDATE VersionChange SET QAStatus=NULL,VersionId=@VersionId where VersionChangeId=@VersionChangeId
		END
	END
	
	IF(@Status=1)
	BEGIN
		INSERT INTO VersionChange(VersionChangeId,VersionId,Reference,FileChanges,DBChanges,Description,ChangedBy,ChangedOn,QAStatus)
		SELECT NEWID(),@VersionId,Reference,FileChanges,DBChanges,DESCRIPTION,ChangedBy,ChangedOn,NULL FROM VersionChange WHERE VersionChangeId=@VersionChangeId
	END
		
END
GO
/****** Object:  StoredProcedure [dbo].[spMoveDBScript]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spMoveDBScript]
	@DBScriptId UNIQUEIDENTIFIER,
	@DBBuildId  UNIQUEIDENTIFIER,
	@ModifiedBy	UNIQUEIDENTIFIER,
	@Status     INT	
AS
BEGIN

	SET NOCOUNT ON;
	-- MOVE DATA
	IF(Isnull(@Status,0) = 0)
	BEGIN 
		UPDATE DBScript
		SET DBBuildId=@DBBuildId,ModifiedBy = @ModifiedBy,ModifiedOn = GETDATE(),ChangedOn=GETDATE()
		WHERE DBScriptId=@DBScriptId
	END
	
	-- COPY DATA AND MOVE DATA
	IF(@Status = 1)
	BEGIN
		INSERT INTO DBScript(DBScriptId,DBBuildId,DBScriptType,DBChangeType,Reference,NAME,DESCRIPTION,Script,Sequence,CreatedBy,CreatedOn,ModifiedBy,ModifiedOn,ChangedBy,ChangedOn)
		SELECT NEWID(),@DBBuildId,DBScriptType,DBChangeType,Reference,NAME,DESCRIPTION,Script,Sequence,@ModifiedBy,CreatedOn,NULL,NULL,@ModifiedBy, GETDATE() 
		FROM DBScript WHERE DBScriptId=@DBScriptId		
	END	
END
GO
/****** Object:  StoredProcedure [dbo].[spOutTimeAttendance]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spOutTimeAttendance]
    @EmployeeId		uniqueidentifier,
	@AttendanceDate		DateTime,
    @OutTime        datetime=null
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE  Attendance
    SET OutTime = @OutTime  WHERE EmployeeId = @EmployeeId and AttendanceDate = @AttendanceDate
    SELECT @@rowcount
END
GO
/****** Object:  StoredProcedure [dbo].[spSelectActiveClient]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spSelectActiveClient]
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT ClientId,
	       NAME,
	       Code,
	       S3BucketName
	FROM   Client
	WHERE  STATUS = 0
	ORDER BY
	       NAME
END
GO
/****** Object:  StoredProcedure [dbo].[spSelectClient]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spSelectClient]
	@ClientId UNIQUEIDENTIFIER = NULL,
	@Name NVARCHAR(100) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT ClientId,
	       NAME,
	       Code,
	       [Status],
	       CreatedBy,
	       CreatedOn,
	       ModifiedBy,
	       ModifiedOn,
	       S3BucketName
	FROM   Client
	WHERE  ClientId = @ClientId
	       OR  @ClientId IS NULL
	       AND (NAME = @Name OR @Name IS NULL)
END
GO
/****** Object:  StoredProcedure [dbo].[spSelectDataColumn]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spSelectDataColumn] 
	@DataColumnId uniqueidentifier =null

AS
BEGIN
	
	SET NOCOUNT ON;

    SELECT DataColumnId,DataTableId,Name,[Description],Mandatory,DataType,[DataLength],[Precision],IsForeignKey,MinValue,MaxValue,DistinctValues,DistinctValueCount,CreatedBy,CreatedOn,ModifiedBy,ModifiedBy
    FROM   DataColumn
    WHERE  DataColumnId  = @DataColumnId OR @DataColumnId IS NULL
    
END
GO
/****** Object:  StoredProcedure [dbo].[spSelectDataFile]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spSelectDataFile]
		@DataFileId uniqueidentifier =NULL,
		@DataRequestId uniqueidentifier = null
AS
BEGIN
	
	SET NOCOUNT ON;
	
    SELECT	DataFileId,DataRequestId,FileType,Name,FileNumber,Description,Path,Source,SQLQuery,d.Status,CreatorContactInfo,FileUploaded,UploadedBy,UploadedOn,OwnerId,d.CreatedBy,d.CreatedOn
			,d.ModifiedBy,d.ModifiedOn, u.UserName AS 'UploadedByUserName'
    FROM	DataFile d
    LEFT JOIN [User] u ON u.UserId = d.UploadedBy
    WHERE	(DataFileId = @DataFileId OR @DataFileId  IS NULL)
    	    and (DataRequestId = @DataRequestId OR @DataRequestId IS null)
    ORDER BY d.Name
END
GO
/****** Object:  StoredProcedure [dbo].[spSelectDataRequest]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spSelectDataRequest]
	@DataRequestId uniqueidentifier = NULL,
	@ClientId uniqueidentifier = null
AS
BEGIN
	SET NOCOUNT ON;

    SELECT d.DataRequestId,d.ClientId,d.RequestNumber,d.RequestDate,RequestedByUserId,AssignedToUserId,d.[Status],s.Name AS StatusName,
		[Description],EstimatedDate,d.CreatedBy,d.CreatedOn,d.ModifiedBy,d.ModifiedOn,u.UserName AS RequestedByUserName,
		(SELECT COUNT(*) FROM DataFile df WHERE df.DataRequestId = d.DataRequestId) AS FileCount
    FROM   DataRequest d INNER JOIN [Status] s ON s.entitytype = 3 and d.[Status] = s.[Status]
    INNER JOIN [USER] u ON d.RequestedByUserId = u.UserId
    WHERE  (DataRequestId = @DataRequestId OR @DataRequestId IS NULL)
			AND (d.ClientId = @ClientId OR @ClientId IS null)    
    ORDER BY d.RequestNumber
END
GO
/****** Object:  StoredProcedure [dbo].[spSelectDataTable]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spSelectDataTable] 
	@DataTableId uniqueidentifier =null

AS
BEGIN
	
	SET NOCOUNT ON;

    SELECT DataTableId,Name,DBInfo,DataFileId,OwnerId,[Description],[RowCount],CreatedBy,CreatedOn,ModifiedBy,ModifiedOn
    FROM   DataTable
    WHERE  DataTableId = @DataTableId OR @DataTableId IS NULL
    
END
GO
/****** Object:  StoredProcedure [dbo].[spSelectDBScript]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ankit Sharma
-- Create date: 08/03/2016
-- Description:	Fetch all DB Scripts for a given DBBuildId
-- =============================================
CREATE PROCEDURE [dbo].[spSelectDBScript] 
	@DBBuildId UNIQUEIDENTIFIER
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT DBScriptId,
		   Name,
		   [Description],
		   DBScriptType,
		   DBChangeType,
		   Reference,
		   Script,
		   Sequence,
		   ChangedBy,
		   ChangedOn,
		   Src.OptionName DBScriptTypeName,
		   Chng.OptionName DBChangeTypeName,
		   usr.UserName UserName,
		   usr.LoginName LoginName
	FROM DBSCript DBS
	LEFT JOIN 
		(SELECT OptionName, OptionValue FROM [Option] 
		INNER JOIN OptionSet ON [Option].OptionSetId = OptionSet.OptionSetId
		WHERE OptionSet.EntityType = 8 AND OptionSet.Name = 'DB Script Type') Src 
		ON Src.OptionValue=DBS.DBScriptType
	LEFT JOIN 
		(SELECT OptionName, OptionValue FROM [Option] 
		INNER JOIN OptionSet ON [Option].OptionSetId = OptionSet.OptionSetId
		WHERE OptionSet.EntityType = 8 AND OptionSet.Name = 'DB Change Type') Chng 
		ON Chng.OptionValue=DBS.DBChangeType
		INNER JOIN
		(SELECT [USER].UserId,UserName,LoginName FROM [USER]  
		INNER JOIN UserRole  ON  UserRole.UserId = [USER].UserId
	        INNER JOIN [Role]  ON  [Role].RoleId = UserRole.RoleId AND ([Role].Name = 'IR User')
		) usr
	    ON usr.UserId=DBS.ChangedBy
	WHERE DBBuildId=@DBBuildId
	ORDER BY DBScriptType, Sequence
END
GO
/****** Object:  StoredProcedure [dbo].[spSelectModule]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [dbo].[spSelectModule]
	@ModuleId UNIQUEIDENTIFIER,
	@ClientId UNIQUEIDENTIFIER,
	@ParentModuleId UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT ModuleId,
	       Name,
	       ParentModuleId,
	       [PageURL],
	       ClientId,
	       [Description],
	       [Status],
	       CreatedBy,
	       CreatedOn,
	       ModifiedBy,
	       ModifiedOn
	FROM   [Module]
	WHERE  (ModuleId = @ModuleId OR @ModuleId IS NULL)
	       AND (ParentModuleId = @ParentModuleId OR @ParentModuleId IS NULL)
	       AND (ClientId = @ClientId OR @ClientId IS NULL)
	ORDER BY
	       Name
END
GO
/****** Object:  StoredProcedure [dbo].[spSelectProject]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spSelectProject] 
	@ProjectId uniqueidentifier = null,
	@UserId uniqueidentifier = null
AS
BEGIN
SET NOCOUNT ON;
if (@UserId !='00000000-0000-0000-0000-000000000000')
BEGIN
select Distinct P.ProjectId,ClientId,Name,Code,[Status],[Description],CreatedBy,CreatedOn,ModifiedBy,ModifiedOn from Project P
left join ProjectPermission PP on PP.ProjectId=P.ProjectId
WHERE  (P.ProjectId = @ProjectId OR @ProjectId IS NULL) and PP.UserId= CASE WHEN PP.UserId IS NOT NULL THEN @UserId END   
END
ELSE
select Distinct P.ProjectId,ClientId,Name,Code,[Status],[Description],CreatedBy,CreatedOn,ModifiedBy,ModifiedOn from Project P
left join ProjectPermission PP on PP.ProjectId=P.ProjectId
WHERE  (P.ProjectId = @ProjectId OR @ProjectId IS NULL)
END
GO
/****** Object:  StoredProcedure [dbo].[spSelectUser]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spSelectUser] 
	@UserId uniqueidentifier = null
	,@LoginName nvarchar(100)=null
	,@Email nvarchar(300)=null

AS
BEGIN


	SET NOCOUNT ON;


    SELECT UserId,ClientId,UserName,Email,LoginName,[Password],[Status],CreatedBy,CreatedOn,ModifiedBy,ModifiedOn
    FROM   [User]
    WHERE  (UserId = @UserId OR @UserId IS NULL)
	       and (LoginName=@LoginName or @LoginName is null)
		   and (Email=@Email or @Email is null)
END
GO
/****** Object:  StoredProcedure [dbo].[spUpdateAttendance]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spUpdateAttendance]
    @AttendanceId   uniqueidentifier,
    @AttendanceDate datetime,
    @InTime         datetime=null,
    @OutTime        datetime=null,
    @Attendance     decimal(2,1)=null,
    @IsWorkFromHome bit=0,
    @TotalMinute    int=null,
    @Remarks        nvarchar(255)=null
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE  Attendance
    SET     AttendanceDate  = @AttendanceDate,
            InTime          = @InTime,
            OutTime         = @OutTime,
            Attendance      = ISNULL(@Attendance,0),
            IsWorkFromHome  = @IsWorkFromHome,
            TimeInMinutes   = @TotalMinute,
            Remarks         = @Remarks,
            ModifiedBy      = substring(SYSTEM_USER,5,LEN(SYSTEM_USER)),
            ModifiedOn      = GETDATE()
    WHERE   AttendanceId    = @AttendanceId
    SELECT @@rowcount
END
GO
/****** Object:  StoredProcedure [dbo].[spUpdateClient]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spUpdateClient]
	@ClientId UNIQUEIDENTIFIER,
	@Name VARCHAR(100),
	@Code VARCHAR(20),
	@S3BucketName VARCHAR(50) = NULL,
	@ModifiedBy UNIQUEIDENTIFIER = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	UPDATE Client
	SET    NAME = @Name,
	       Code = @Code,
	       S3BucketName = @S3BucketName,
	       ModifiedBy = @ModifiedBy,
	       ModifiedOn = GETDATE()
	WHERE  ClientId = @ClientId
	
	RETURN @@rowcount
END
GO
/****** Object:  StoredProcedure [dbo].[spUpdateComment]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spUpdateComment]
 @CommentId   uniqueidentifier,
 @Comment   varchar(max),
 @ModifiedBy   uniqueidentifier=null
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE  Comment
    SET     Comment      = @Comment,
            ModifiedBy   = @ModifiedBy,
			ModifiedOn   = GETDATE()    
    WHERE   CommentId  = @CommentId 
    
END
GO
/****** Object:  StoredProcedure [dbo].[spUpdateComponents]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spUpdateComponents]
    @ComponentId     uniqueidentifier,
    @ModifiedBy		 uniqueidentifier,
    @ComponentName   nvarchar(50),
	@IsDBComponent   bit,
	@IsVersionComponent   bit,
	@GitUrl			 nvarchar(100),
	@BuildPrefixForConfig nvarchar(100)
AS
BEGIN
    SET NOCOUNT ON;   
    UPDATE  Component
    SET     Name            = @ComponentName,
            ModifiedBy      = @ModifiedBy,
            ModifiedOn      = GETDATE(), 
			IsDBComponent	= @IsDBComponent,
			IsVersionComponent=@IsVersionComponent ,
			GitUrl			= @GitUrl,
			BuildPrefixForConfig=@BuildPrefixForConfig        
    WHERE   ComponentId     = @ComponentId
    RETURN @@rowcount
END
GO
/****** Object:  StoredProcedure [dbo].[spUpdateContainer]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ========================================================
-- Author:		Ankit Sharma 
-- Create date: 03 May 2016
-- Description: Update Container Name
-- ========================================================
CREATE PROCEDURE [dbo].[spUpdateContainer]
 @ContainerId   UNIQUEIDENTIFIER,
 @ContainerName   NVARCHAR(250),
 @Directories   NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE  Container
    SET     Name = @ContainerName,
			Folders=@Directories	  
    WHERE   ContainerId = @ContainerId
    
END
GO
/****** Object:  StoredProcedure [dbo].[spUpdateDataColumn]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spUpdateDataColumn]
	@DataColumnId		uniqueidentifier,
    @DataTableId		uniqueidentifier,
    @Name				varchar(50),
    @Description		varchar(max)=null,
    @Mandatory			bit=0,
	@DataType			varchar(20)=null,
	@DataLength			int=null,
	@Precision			int=null,
	@IsForeignKey		bit=0,
	@MinValue			varchar(100)=null,
	@MaxValue			varchar(100)=null,
	@DistinctValues		varchar(max)= null,
	@DistinctValueCount	int=null,
	@ModifiedBy			uniqueidentifier=null
	
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE  DataColumn
    SET     DataTableId			=	@DataTableId,
			Name				=	@Name,
            [Description]		=	@Description,
            Mandatory			=	@Mandatory,
            DataType			=	@DataType,
			[DataLength]		=	@DataLength,
			[Precision]			=	@Precision,
			IsForeignKey		=	@IsForeignKey,
			MinValue			=	@MinValue,
			MaxValue			=	@MaxValue,
			DistinctValues		=	@DistinctValues,
			DistinctValueCount	=	@DistinctValueCount,
            ModifiedBy			=	@ModifiedBy,
			ModifiedOn			=	GETDATE()    
    WHERE   @DataColumnId	= @DataColumnId
    RETURN @@rowcount
END
GO
/****** Object:  StoredProcedure [dbo].[spUpdateDataFile]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spUpdateDataFile]
		@DataFileId				uniqueidentifier,
		@DataRequestId			UNIQUEIDENTIFIER=null,
		@FileType				int,
		@Name					varchar(50),
		@Description			varchar(max)=null,
		@Path					varchar(250)=null,
		@Source					varchar(250)=null,
		@SQLQuery				varchar(max)=null,
		@Status					int,
		@CreatorContactInfo		varchar(250)=null,
		@FileUploaded			bit=0,
		@UploadedBy				uniqueidentifier=null,
		@UploadedOn				datetime=null,
		@OwnerId				uniqueidentifier=null,
		@ModifiedBy				uniqueidentifier=NULL,
		@ClientId				UNIQUEIDENTIFIER,
		@CleaningProcess		varchar(max)=null
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE  DataFile
    SET     DataRequestId		=	@DataRequestId,
			FileType			=   @FileType,
			Name				=	@Name,
            [Description]		=	@Description,
            [Path]				=	@Path,
			[Source]			=	@Source,
			SQLQuery			=	@SQLQuery,
			[Status]			=	@Status,
			CreatorContactInfo	=	@CreatorContactInfo,
            FileUploaded		=	@FileUploaded,
			UploadedBy			=	@UploadedBy,
			UploadedOn			=   @UploadedOn,
			OwnerId				=	@OwnerId,
			ModifiedBy			=	@ModifiedBy,
			ClientId			=	@ClientId,
			CleaningProcess		=	@CleaningProcess,
			ModifiedOn			=	GETDATE()
             
    WHERE   DataFileId      =	@DataFileId
    RETURN @@rowcount
END
GO
/****** Object:  StoredProcedure [dbo].[spUpdateDataFileName]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spUpdateDataFileName]
	@DataFileId UNIQUEIDENTIFIER,
	@Name VARCHAR(50),
	@Path VARCHAR(250) = NULL,
	@UploadedBy UNIQUEIDENTIFIER = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	UPDATE DataFile
	SET    NAME             = @Name,
	       [Path]           = @Path,
	       FileUploaded     = 1,
	       UploadedBy       = @UploadedBy,
	       UploadedOn       = GETDATE()
	WHERE  DataFileId       = @DataFileId
	EXEC spInsertActivity 104, @DataFileId, 'Uploaded a file', NULL, 0, @UploadedBy
END
GO
/****** Object:  StoredProcedure [dbo].[spUpdateDataRequest]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spUpdateDataRequest]
		@DataRequestId			uniqueidentifier,
		@ClientId				uniqueidentifier,
		@RequestNumber			int,
		@RequestDate			datetime,
		@RequestedByUserId		uniqueidentifier=null,
		@AssignedToUserId		uniqueidentifier=null,
		@Status					int,
		@Description			varchar(max)=null,
		@EstimatedDate			datetime=null,
		@ModifiedBy				uniqueidentifier=null
		
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE  DataRequest
    SET     ClientId			=   @ClientId,
			RequestNumber		=	@RequestNumber,
            RequestDate			=	@RequestDate,
            RequestedByUserId	=	@RequestedByUserId,
            AssignedToUserId	=	@AssignedToUserId,
            [Status]				=	@Status,
            [Description]			=	@Description,
            EstimatedDate		=	@EstimatedDate,
			ModifiedBy			=	@ModifiedBy,
			ModifiedOn			=	GETDATE()   
    WHERE   DataRequestId		=	@DataRequestId
END
GO
/****** Object:  StoredProcedure [dbo].[spUpdateDataTable]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spUpdateDataTable]
	@DataTableId		uniqueidentifier,
    @Name				varchar(50),
    @DBInfo				varchar(100),
    @DataFileId			uniqueidentifier,
    @OwnerId			uniqueidentifier=null,
    @Description		varchar(max)=null,
    @RowCount			int=null,
	@ModifiedBy			uniqueidentifier,
	@ClientId			uniqueidentifier
	
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE  DataTable
    SET     Name			=	@Name,
            DBInfo			=	@DBInfo,
            DataFileId		=	@DataFileId,
            OwnerId			=	@OwnerId,
            [Description]   =	@Description,
            [RowCount]		=	@RowCount,
            ModifiedBy		=	@ModifiedBy,
			ClientId		=	@ClientId,
			ModifiedOn		=	GETDATE()
    WHERE   DataTableId     =   @DataTableId
    RETURN @@rowcount
END
GO
/****** Object:  StoredProcedure [dbo].[spUpdateDBBuild]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spUpdateDBBuild]
	-- Add the parameters for the stored procedure here
	@DBBuildId		uniqueidentifier,
	@IsLocked		bit,
	@ModifiedBy     uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE DBBuild
	SET IsLocked = @IsLocked,
		ModifiedBy = @ModifiedBy,
		ModifiedOn = GETDATE()
	WHERE DBBuildId = @DBBuildId
END
GO
/****** Object:  StoredProcedure [dbo].[spUpdateDBScript]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Pabitra Dash
-- Create date: 18/03/2013
-- Description:	Update DBScript
-- =============================================
CREATE PROCEDURE [dbo].[spUpdateDBScript]
	-- Add the parameters for the stored procedure here
	@DBScriptId		uniqueidentifier,
	@Name			VARCHAR(50),
	@Description	VARCHAR(MAX),
	@DBScriptType   int,
	@DBChangeType   int,
	@Reference		VARCHAR(50),
	@Script			NVARCHAR(MAX),
	@Sequence		int,
	@ChangedOn      DateTime,
	@ChangedBy      uniqueidentifier,
    @ModifiedBy	    uniqueidentifier=null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE DBScript
		SET Name = @Name,
			[Description] = @Description,
			DBScriptType = @DBScriptType,
			DBChangeType = @DBChangeType,
			Reference = @Reference,
			Script = @Script,
			Sequence = @Sequence,
			ChangedOn = @ChangedOn,
			ChangedBy = @ChangedBy,
			ModifiedBy = @ModifiedBy,
			ModifiedOn		=	GETDATE()
	WHERE DBScriptId = @DBScriptId
END
GO
/****** Object:  StoredProcedure [dbo].[spUpdateDBScriptsSequence]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author       : Ankit Sharma
-- Create date  : 11-March-2016
-- Description  : Update DB Scripts Sequence on Drag and Drop
-- Parameters   : 
-- =============================================
CREATE PROCEDURE [dbo].[spUpdateDBScriptsSequence]
  @SelectedDbScriptsId nvarchar(max)
AS  
BEGIN  
DECLARE @DBScriptId UNIQUEIDENTIFIER
DECLARE @Squence INT = 0 
 DECLARE CurUpdateSquence CURSOR LOCAL 
 FOR  SELECT item  FROM   dbo.fnSplit(@SelectedDbScriptsId,',')
 OPEN CurUpdateSquence 
 FETCH NEXT FROM CurUpdateSquence INTO @DBScriptId 
 WHILE (@@FETCH_STATUS = 0)
 BEGIN
 	set @Squence = @Squence + 10
     Update DBScript SET Sequence=@Squence WHERE DBScriptId=@DBScriptId
     FETCH NEXT FROM CurUpdateSquence INTO @DBScriptId
 END
 CLOSE CurUpdateSquence 
 DEALLOCATE CurUpdateSquence
END
GO
/****** Object:  StoredProcedure [dbo].[spUpdateDetailVersionData]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spUpdateDetailVersionData]	
	@VersionChangeId     UNIQUEIDENTIFIER,	
	@Reference			 nvarchar(50)=NULL,
	@FileChanges		 nvarchar(2000)=NULL,
	@DBChanges			 nvarchar(2000)=NULL,
	@Description		 nvarchar(4000),
	@ChangedBy			 nvarchar(50)=NULL,
	@ChangedOn			 datetime,			
	@QAStatus			 int
	
AS

BEGIN
	SET NOCOUNT ON;
	Update VersionChange
		SET Reference=@Reference,
			FileChanges=@FileChanges,
			DBChanges=@DBChanges,
			[Description]=@Description,
			ChangedBy=@ChangedBy,
			ChangedOn=@ChangedOn,
			QAStatus=@QAStatus
			
	WHERE VersionChangeId=@VersionChangeId

END
GO
/****** Object:  StoredProcedure [dbo].[spUpdateEmailTepmlate]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spUpdateEmailTepmlate] 
@EmailTemplateId UNIQUEIDENTIFIER,
@TemplateName NVARCHAR(50),
@FromEmailId NVARCHAR(100),
@ToEmailId NVARCHAR(100), 
@CCEmailId NVARCHAR(100),
@Subject NVARCHAR(200), 
@Body NVARCHAR(MAX),
@ModifiedBy uniqueidentifier=null
AS
BEGIN
	SET NOCOUNT ON;
	UPDATE EmailTemplate
	SET
		TemplateName = @TemplateName,
		FromEmailId = @FromEmailId,
		ToEmailId = @ToEmailId,
		CCEmailId = @CCEmailId,
		[Subject] = @Subject,
		Body = @Body,
		ModifiedBy = @ModifiedBy,
		ModifiedOn = GETDATE()
	WHERE EmailTemplateId = @EmailTemplateId
RETURN @@ROWCOUNT  
END
GO
/****** Object:  StoredProcedure [dbo].[spUpdateEmployee]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spUpdateEmployee]  
    @EmployeeId     uniqueidentifier,  
    @FirstName       nvarchar(50),  
    @MiddleName      nvarchar(50)=null,  
    @LastName        nvarchar(50)=null,  
    @Designation     nvarchar(50)=null,  
    @Gender          nvarchar(1)=null,      
    @DateOfBirth     datetime=null,  
    @Anniversary     datetime=null,  
    @Remarks         nvarchar(255)=null,  
    @DateOfJoining   datetime=null,  
    @DateOfRelieving datetime=null,  
    @PanNo           nvarchar(20)=null,  
    @FatherName      nvarchar(100)=null,  
    @EmployeeType    nvarchar(10)=null,  
    @BankDetail      nvarchar(255)=null,     
    @OrignalDateOfBirth  datetime=null  
AS  
BEGIN  
    SET NOCOUNT ON;  
      
    UPDATE  Employee  
    SET    
	        FirstName       = @FirstName,  
            MiddleName      = @MiddleName,  
            LastName        = @LastName,  
            Designation     = @Designation,  
            Gender          = @Gender,  
            DateOfBirth     = @DateOfBirth,  
            Anniversary     = @Anniversary,  
            Remarks         = @Remarks,  
            DateOfJoining   = @DateOfJoining,  
            DateOfRelieving = @DateOfRelieving,  
            PanNo           = @PanNo,  
            FatherName      = @FatherName,  
            EmployeeType    = @EmployeeType,  
            BankDetail      = @BankDetail,  
            OrignalDateOfBirth=@OrignalDateOfBirth, 	 
            ModifiedBy      = substring(SYSTEM_USER,5,LEN(SYSTEM_USER)),  
            ModifiedOn      = GETDATE()              
    WHERE   EmployeeId      = @EmployeeId  
    RETURN @@rowcount  
END
GO
/****** Object:  StoredProcedure [dbo].[spUpdateHoliday]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spUpdateHoliday]
@HolidayDate  DATETIME,
@Name         NVARCHAR(100),
@Remarks      NVARCHAR(255)=NULL
AS
BEGIN
SET NOCOUNT ON;
    UPDATE Holiday
    SET
	Name=@Name,
	Remarks=@Remarks
	WHERE HolidayDate=@HolidayDate
END
GO
/****** Object:  StoredProcedure [dbo].[spUpdateLeave]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spUpdateLeave]
    @LeaveId UNIQUEIDENTIFIER, 
	@LeaveDate DATETIME, 
	@LeaveType NVARCHAR(5), 
	@LeaveCount DECIMAL(2, 1), 
	@Remarks NVARCHAR(255), 
	@IsApproved BIT,
    @IsSecondHalf BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Leave
    SET LeaveDate = @LeaveDate, 
		LeaveType = @LeaveType, 
		LeaveCount = CASE WHEN @LeaveType = 'EW' THEN -1 * @LeaveCount ELSE @LeaveCount END,
        Remarks = @Remarks, 
		ModifiedBy = SUBSTRING(SYSTEM_USER, 5, LEN(SYSTEM_USER)), 
		ModifiedOn = GETDATE(), 
		IsApproved = @IsApproved,
        IsSecondHalf = @IsSecondHalf
    WHERE LeaveId = @LeaveId;
    SELECT @@rowcount;
END;
GO
/****** Object:  StoredProcedure [dbo].[spUpdateModule]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spUpdateModule]
    @ModuleId				uniqueidentifier,
	@Name					varchar(50),
    @ParentModuleId			uniqueidentifier=null,
	@PageURL				varchar(max)=null,
    @ClientId				uniqueidentifier=null,
	@Description			varchar(50)=null,
    @Status					int,
    @ModifiedBy				uniqueidentifier=null,
	@Sequence				int
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE  Module
    SET     Name				=   @Name,
			ParentModuleId		=	@ParentModuleId,
			PageURL			    =	@PageURL,
            ClientId			=	@ClientId,
            [Status]			=	@Status,
            [Description]		=	@Description,
            ModifiedBy			=	@ModifiedBy,
			ModifiedOn			=	GETDATE(),
			Sequence            =   @Sequence
    WHERE   ModuleId	= @ModuleId
    RETURN @@rowcount
END
GO
/****** Object:  StoredProcedure [dbo].[spUpdateProject]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spUpdateProject]
    @ProjectId			uniqueidentifier,
    @ClientId			uniqueidentifier,
    @Name				varchar(50),
    @Code				varchar(50),
    @Status				int,
    @Description		varchar(Max)=null,
    @ModifiedBy			uniqueidentifier=null
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE  Project
    SET     ClientId		=   @ClientId,
			Name			=	@Name,
            Code			=	@Code,
            [Status]		=	@Status,
            [Description]   =	@Description,
            ModifiedBy		=	@ModifiedBy,
			ModifiedOn		=	GETDATE()    
    WHERE   ProjectId       = @ProjectId
    RETURN @@rowcount
END
GO
/****** Object:  StoredProcedure [dbo].[spUpdateProjectPermission]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spUpdateProjectPermission]
	@ProjectId [uniqueidentifier],
    @UserIds nvarchar(max)
AS
BEGIN
    SET NOCOUNT ON;
    
    declare @pos int
	declare @len int
	declare @UserId uniqueidentifier

    -- delete existing user permission    
    delete from ProjectPermission where ProjectId = @ProjectId

	-- insert user permission
	insert into ProjectPermission (ProjectPermissionId,ProjectId,Permission,UserId) 
		select newid(),@ProjectId, 1, item from dbo.fnSplit(@UserIds,',')
END
GO
/****** Object:  StoredProcedure [dbo].[spUpdateReleaseNote]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spUpdateReleaseNote]	
	
	@ReleaseNoteId       UNIQUEIDENTIFIER,
	@VersionId			 UNIQUEIDENTIFIER,
	@Reference			 NVARCHAR(10) = NULL, 
	@Type			     INT = NULL,
	@Title			     NVARCHAR(500) = NULL,	
	@Remarks			 NVARCHAR(1000) = NULL,	
	@IsPublic            BIT,
	@Sequence			 INT=0,
	@UpdateTaskFields	 BIT=0
	

AS
BEGIN
	SET NOCOUNT ON;	 
	    
		
		--IF (@Sequence > 0)
		--BEGIN
		--	SELECT @Sequence=MAX(IsNull(Sequence, 0)) + 10 from ReleaseNote  WHERE VersionId = @VersionId
		--END	

		 IF EXISTS(SELECT * FROM ReleaseNote where ReleaseNoteId=@ReleaseNoteId)
		 BEGIN
			UPDATE ReleaseNote SET	 VersionId=@VersionId, Reference=@Reference, [Type]=@Type, Title=@Title, Remarks=@Remarks,Sequence=@Sequence,IsPublic=@IsPublic WHERE ReleaseNoteId = @ReleaseNoteId
		 END
		 
		 IF(@UpdateTaskFields = 1)
		 BEGIN
		 	UPDATE Task SET Summary = @Title,TaskType = @Type WHERE [Key]=@Reference		 		
		 END	 

END
GO
/****** Object:  StoredProcedure [dbo].[spUpdateReleaseNotesSequence]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author       : Ankit Sharma
-- Create date  : 04-March-2016
-- Description  : Update Release Notes Sequence on Drag and Drop
-- Parameters   : 
-- =============================================
CREATE PROCEDURE [dbo].[spUpdateReleaseNotesSequence]
  @SelectedReleaseNotesId nvarchar(max)
AS  
BEGIN  
DECLARE @ReleaseNoteId UNIQUEIDENTIFIER
DECLARE @Squence INT = 0 
 DECLARE CurUpdateSquence CURSOR LOCAL 
 FOR  SELECT item  FROM   dbo.fnSplit(@SelectedReleaseNotesId,',')
 OPEN CurUpdateSquence 
 FETCH NEXT FROM CurUpdateSquence INTO @ReleaseNoteId 
 WHILE (@@FETCH_STATUS = 0)
 BEGIN
 	set @Squence = @Squence + 10
     Update ReleaseNote SET Sequence=@Squence WHERE ReleaseNoteId=@ReleaseNoteId
     FETCH NEXT FROM CurUpdateSquence INTO @ReleaseNoteId
 END
 CLOSE CurUpdateSquence 
 DEALLOCATE CurUpdateSquence
END
GO
/****** Object:  StoredProcedure [dbo].[spUpdateReleaseNoteSummary]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spUpdateReleaseNoteSummary]
@ReleaseTitle   NVARCHAR(250),
@IsLocked       BIT,
@ModifiedBy      UNIQUEIDENTIFIER,
@ReleaseNoteSummaryId UNIQUEIDENTIFIER,
@ReleaseDate    DATETIME
AS
BEGIN
	SET NOCOUNT ON;
	Update ReleaseNoteSummary set ReleaseDate=@ReleaseDate,ReleaseTitle=@ReleaseTitle,IsLocked=@IsLocked,ModifiedBy=@ModifiedBy,ModifiedOn=GETDATE() where ReleaseNoteSummaryId=@ReleaseNoteSummaryId
END
GO
/****** Object:  StoredProcedure [dbo].[spUpdateTask]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spUpdateTask]
	@TaskId				UNIQUEIDENTIFIER,
	@Summary			NVARCHAR(500),
	@TaskType			INT,
	@Status				INT,
	@PriorityType		INT,
	@ResolutionType		INT=NULL,
	@Assignee			NVARCHAR(100)=NULL,
	@Reporter			NVARCHAR(100),
	@ComponentId		UNIQUEIDentifier,
	@DueDate		    DATETIME=NULL,
	@OriginalEstimate   INT=NULL,
	@TimeSpent			INT=NULL,
	@RemainingEstimate  INT=NULL,
	@Description		NVARCHAR(4000)=NULL,
	@Area				NVARCHAR(100)=NULL,	
	@ModifiedBy		    UNIQUEIDENTIFIER
AS
BEGIN
		SET NOCOUNT ON;
	IF(@ComponentId='00000000-0000-0000-0000-000000000000') 
	BEGIN
		SET @ComponentId=NULL
	END	
		
	UPDATE Task SET Summary = @Summary,
	             TaskType = @TaskType,
	             --[Status] = @Status,
	             PriorityType = @PriorityType,
	             ResolutionType = @ResolutionType,
	             --Assignee = @Assignee,
	             Reporter = @Reporter,
	             ComponentId = @ComponentId,
	             DueDate = @DueDate,
	             OriginalEstimate = @OriginalEstimate,
	             TimeSpent = @TimeSpent,
	             RemainingEstimate = @RemainingEstimate,
	             [Description] = @Description,
	             Area = @Area,
	             ModifiedBy = @ModifiedBy,
	             ModifiedOn = GETDATE()
	WHERE TaskId=@TaskId
	
	
	DECLARE @ChangeAssigneeCount INT = 0
	UPDATE Task SET Assignee = @Assignee WHERE TaskId = @TaskId AND ISNULL(Assignee,'') <> ISNULL(@Assignee,'')
	SELECT @ChangeAssigneeCount = @@ROWCOUNT
	
	IF(@ChangeAssigneeCount > 0)
	BEGIN
		--Add activity for task assigned when Updated
			WAITFOR DELAY '00:00:00:005' ---- 5 MiliSecond Delay to Prevent Duplicate Activity Changedon Time
			DECLARE @assigneeDesc NVARCHAR(50)= NULL
			SELECT @assigneeDesc = TypeName +' to ' + @Assignee FROM Types WHERE CategoryId = 105 AND TypeId = 11004
			EXEC spInsertActivity @EntityType=101,@EntityId= @TaskId,@Description=@assigneeDesc,@CommentId= NULL,@IsInternal= 0,@CreatedBy= @ModifiedBy,@ActivityType=11004
	END
	
	DECLARE @ChangeStatusCount INT = 0
	UPDATE Task SET [Status] = @Status WHERE TaskId = @TaskId AND [Status] <> @Status
	SELECT @ChangeStatusCount = @@ROWCOUNT
	
	IF(@ChangeStatusCount > 0)
	BEGIN
		IF(ISNULL(@Status,0) NOT IN (0,12))
		BEGIN
			--Add activity for task status when created
			WAITFOR DELAY '00:00:00:005' ---- 5 MiliSecond Delay to Prevent Duplicate Activity Changedon Time
			DECLARE @statusDesc NVARCHAR(50)= NULL
			SELECT @statusDesc = NAME FROM [status] ts WHERE ts.EntityType=11 AND ts.[Status] = @Status
			SELECT @statusDesc = TypeName +' changed to ' + @statusDesc FROM Types WHERE CategoryId = 105 AND TypeId = 11002
			EXEC spInsertActivity @EntityType=101,@EntityId= @TaskId,@Description=@statusDesc,@CommentId= NULL,@IsInternal= 0,@CreatedBy= @ModifiedBy,@ActivityType=11002
		END
	END
END
GO
/****** Object:  StoredProcedure [dbo].[spUpdateTaskBulk]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Narendra Shrivastava
-- Create date: 09 May 2016
-- Description: Bulk Update Task Operations
-- Parameters: @OperationType 
--			   1 = TaskType,
--			   2 = Priority,
--			   3 = Reporter,
--			   4 = Component,
--			   5 = Assignee,
--			   6 = Area,
--			   7 = Status,
-- =============================================
CREATE PROCEDURE [dbo].[spUpdateTaskBulk]
@TaskIds VARCHAR(MAX),
@OperationType INT, 
@Param1 NVARCHAR(500)=NULL,
@Param2 NVARCHAR(500)=NULL,
@ModifiedBy UNIQUEIDENTIFIER
AS
BEGIN
	--SET NOCOUNT ON;
	
	IF(@OperationType IN (1,2,3,4,6))
	BEGIN
			DECLARE @ComponentId UNIQUEIDENTIFIER = NULL
			IF(@OperationType = 4)
			BEGIN
				SELECT @ComponentId = CAST(@Param1 AS UNIQUEIDENTIFIER)
			END
		UPDATE Task 
		   SET TaskType = CASE WHEN @OperationType = 1 then @Param1 else TaskType END,
	           PriorityType = CASE WHEN @OperationType = 2 then @Param1 else PriorityType END,
	           Reporter = CASE WHEN @OperationType = 3 then @Param1 else Reporter END,
	           ComponentId = CASE WHEN @OperationType = 4 then @ComponentId else ComponentId END,
	           Area = CASE WHEN @OperationType = 6 then @Param1 else Area END,
			   ResolutionType = CASE WHEN [Status] IN (51,52) THEN [Status] ELSE NULL END,
	           ModifiedBy = @ModifiedBy,
	           ModifiedOn = GETDATE()
		WHERE TaskId  IN(SELECT item FROM dbo.fnSplit(@TaskIds,','))
	END
	ELSE IF(@Operationtype = 5)
	BEGIN
			DECLARE @TaskId UNIQUEIDENTIFIER
			DECLARE curTaskId CURSOR FOR SELECT item FROM dbo.fnSplit(@TaskIds,',')
			OPEN curTaskId
			FETCH curTaskId INTO @TaskId
			WHILE (@@FETCH_STATUS = 0)
			BEGIN
				DECLARE @ChangeAssigneeCount INT = 0
				UPDATE Task SET Assignee = @Param1 WHERE TaskId = @TaskId AND ISNULL(Assignee,'') <> ISNULL(@Param1,'')
				SELECT @ChangeAssigneeCount = @@ROWCOUNT
				
				IF(@ChangeAssigneeCount > 0 AND ISNULL(@Param1,'') <> '')
				BEGIN
					--Add activity for task assigned when Updated
						WAITFOR DELAY '00:00:00:005' ---- 5 MiliSecond Delay to Prevent Duplicate Activity Changedon Time
						DECLARE @assigneeDesc NVARCHAR(50)= NULL
						SELECT @assigneeDesc = TypeName +' to ' + @Param1 FROM Types WHERE CategoryId = 105 AND TypeId = 11004
						EXEC spInsertActivity @EntityType=101,@EntityId= @TaskId,@Description=@assigneeDesc,@CommentId= NULL,@IsInternal= 0,@CreatedBy= @ModifiedBy,@ActivityType=11004
				END
			
				FETCH NEXT FROM curTaskId INTO @TaskId
			END
			CLOSE curTaskId
			DEALLOCATE curTaskId
	END
	ELSE IF(@Operationtype = 7)
	BEGIN
			DECLARE @TaskId2 UNIQUEIDENTIFIER, @Status INT = CONVERT(INT,@param1)
			DECLARE curTaskId CURSOR FOR SELECT item FROM dbo.fnSplit(@TaskIds,',')
			OPEN curTaskId
			FETCH curTaskId INTO @TaskId
			WHILE (@@FETCH_STATUS = 0)
			BEGIN
				--Update Status
				DECLARE @ChangeStatusCount INT = 0
				UPDATE Task SET [Status] = @Status WHERE TaskId = @TaskId AND [Status] <> @Status
				SELECT @ChangeStatusCount = @@ROWCOUNT
				
				--Update Resolution Type
				UPDATE Task SET ResolutionType = CASE WHEN ISNULL(@Status,0) IN (51,52) THEN @Param2 ELSE NULL END WHERE TaskId = @TaskId

				IF(@ChangeStatusCount > 0)				
				BEGIN
					IF(ISNULL(@Status,0) NOT IN (0,12))
					BEGIN
						--Add activity for task status when created
						WAITFOR DELAY '00:00:00:005' ---- 5 MiliSecond Delay to Prevent Duplicate Activity Changedon Time
						DECLARE @statusDesc NVARCHAR(50)= NULL
						SELECT @statusDesc = NAME FROM [status] ts WHERE ts.EntityType=11 AND ts.[Status] = @Status
						SELECT @statusDesc = TypeName +' changed to ' + @statusDesc FROM Types WHERE CategoryId = 105 AND TypeId = 11002
						EXEC spInsertActivity @EntityType=101,@EntityId= @TaskId,@Description=@statusDesc,@CommentId= NULL,@IsInternal= 0,@CreatedBy= @ModifiedBy,@ActivityType=11002
					END
				END
			
				FETCH NEXT FROM curTaskId INTO @TaskId
			END
			CLOSE curTaskId
			DEALLOCATE curTaskId
	END
	
END
GO
/****** Object:  StoredProcedure [dbo].[spUpdateTaskRank]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =====================================================
-- Author       : Ram Pujan
-- Create date  : 03-May-2016
-- Description  : Update taks' Rank
-- =====================================================
CREATE PROCEDURE [dbo].[spUpdateTaskRank]
    @data   nvarchar(max),
    @status int = null
AS
BEGIN
	 SET NOCOUNT ON;

    declare @temp table ([key] NVARCHAR(100), RN int)
    INSERT INTO @temp
    SELECT *, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM fnSplit(@data,',')

    UPDATE
        Task
    SET
        Task.[Rank] = temp.RN,
        Task.[Status] = (case when @status is not null then @status else Task.[Status] end)
    FROM
        Task
        INNER JOIN @temp temp
            ON Task.[Key] = temp.[Key]

END
GO
/****** Object:  StoredProcedure [dbo].[spUpdateTaxSavingReceipt]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================
-- Author       : Ankit Sharma
-- Create date  : 07-April-2016
-- Description  : Update Tax Saving Receipt
-- Parameters   : 
-- ==============================================================
CREATE PROCEDURE [dbo].[spUpdateTaxSavingReceipt]
	@TaxSavingId		uniqueidentifier,
	@EmployeeId			uniqueidentifier,
	@FinancialYear		int,
	@TaxSavingType      int,
	@RecurringFrequency int,
	@SavingDate        	date=null,
	@AccountNumber     	nvarchar(100),
	@Amount            	decimal(8,2),
	@Remarks           	nvarchar(100),
	@EligibleCount		int
AS	 
BEGIN	

	UPDATE TaxSaving SET 
	EmployeeId=@EmployeeId, 
	FinancialYear=@FinancialYear,
	TaxSavingType=@TaxSavingType,
	RecurringFrequency=@RecurringFrequency,
	SavingDate=@SavingDate,
	AccountNumber=@AccountNumber,
	Amount=@Amount,
	Remarks=@Remarks,
	EligibleCount=@EligibleCount
	WHERE TaxSavingId=@TaxSavingId
END
GO
/****** Object:  StoredProcedure [dbo].[spUpdateTaxSavingType]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spUpdateTaxSavingType]
(
@TaxSavingType INT,
@TaxSavingTypeName NVARCHAR(100),
@TaxCategoryCode NVARCHAR(20)
)
AS
BEGIN
 SET NOCOUNT ON;
 UPDATE TaxSavingType SET TaxSavingTypeName=@TaxSavingTypeName,TaxCategoryCode=@TaxCategoryCode WHERE TaxSavingType=@TaxSavingType
END
GO
/****** Object:  StoredProcedure [dbo].[spUpdateTodayWorkLog]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spUpdateTodayWorkLog]
@UserId UNIQUEIDENTIFIER,
@Hours decimal(6,2),
@TaskId UNIQUEIDENTIFIER
AS 
BEGIN
 IF EXISTS(SELECT 1 FROM WorkLog wl WHERE wl.UserId=@UserId AND TaskId = @TaskId AND CAST(wl.WorkDate AS DATE) = CAST(GETDATE() AS DATE))
   	BEGIN
   	DELETE FROM WorkLog WHERE UserId = @UserId AND TaskId = @TaskId AND CAST(WorkDate AS DATE) = CAST(GETDATE() AS DATE)
   	END

	IF(ISNULL(@Hours,0) > 0)
	BEGIN
		INSERT INTO WorkLog	
					(
						WorkLogId, UserId, JiraIssueId, WorkDate,
						Hours, Remarks, CreatedBy, CreatedDate,
						UpdatedBy, UpdatedDate, TaskId
					)
   			VALUES	(
						NEWID(), @userId, NULL, DATEADD(d,DATEDIFF(d,0,GETDATE()),0),
						@Hours, NULL, @UserId, GETDATE(),
						NULL, NULL, @TaskId
					)

		IF  EXISTS(SELECT 1 FROM Task WHERE Taskid = @TaskId and [status] in (12,22,23))
		BEGIN 
			UPDATE Task SET [status] = 21 WHERE Taskid = @TaskId
   		END
	END
   		
END
GO
/****** Object:  StoredProcedure [dbo].[spUpdateUser]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spUpdateUser]
    @UserId UNIQUEIDENTIFIER, 
	@ClientId UNIQUEIDENTIFIER = NULL, 
	@UserName VARCHAR(100), 
	@Email VARCHAR(100) = NULL, 
	@LoginName VARCHAR(20), 
	@Status INT,
    @ModifiedBy UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @CID AS UNIQUEIDENTIFIER;
    IF (@ClientId = '00000000-0000-0000-0000-000000000000')
    BEGIN
        SET @CID = NULL;
    END;
    ELSE
    BEGIN
        SET @CID = @ClientId;
    END;
    UPDATE dbo.[User]
    SET ClientId = @CID, UserName = @UserName, Email = @Email, LoginName = @LoginName, Status = @Status, ModifiedBy = @ModifiedBy, ModifiedOn = GETDATE()
    WHERE UserId = @UserId;

    RETURN @@rowcount;
END;
GO
/****** Object:  StoredProcedure [dbo].[spUpdateUserContainer]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ========================================================
-- Author:		Ankit Sharma 
-- Create date: 03 May 2016
-- Description: Save User Container permissions
-- ========================================================
CREATE PROCEDURE [dbo].[spUpdateUserContainer]
	@ContainerId UNIQUEIDENTIFIER,
    @UserIds VARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
   
    -- delete existing user container permission    
    DELETE FROM UserContainer WHERE ContainerId = @ContainerId

	-- insert user container permission
	Insert into UserContainer (ContainerId, UserId)
		SELECT @ContainerId, item AS UserId from dbo.fnSplit(@UserIds,',')
END
GO
/****** Object:  StoredProcedure [dbo].[spUpdateUserRole]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spUpdateUserRole]
	@UserId UNIQUEIDENTIFIER,
	@IsChecked BIT,
	@RoleName VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @RoleId UNIQUEIDENTIFIER
	SELECT @RoleId = RoleId
	FROM   ROLE
	WHERE  NAME = @RoleName
	
	IF @IsChecked = 1
	BEGIN
	    IF NOT EXISTS(
	           SELECT *
	           FROM   UserRole ur
	           WHERE  ur.UserId = @UserId
	                  AND ur.RoleId = @RoleId
	       )
	    BEGIN
	        INSERT INTO UserRole
	          (
	            UserRoleId,
	            UserId,
	            RoleId
	          )
	        VALUES
	          (
	            NEWID(),
	            @UserId,
	            @RoleId
	          )
	    END
	END
	ELSE
	BEGIN
	    DELETE 
	    FROM   UserRole
	    WHERE  userId = @UserId AND RoleId = @RoleId
	END
END
GO
/****** Object:  StoredProcedure [dbo].[spUpdateVersionChangeCommit]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ankit Sharma
-- Create date: 12 May 2016
-- Description: Update version change commit details
-- =============================================
CREATE PROCEDURE [dbo].[spUpdateVersionChangeCommit]
	@VersionChangeCommitId    UNIQUEIDENTIFIER,
	@GitCommitId        NVARCHAR(50),
	@CommittedFiles     NVARCHAR(2000) = NULL,
	@CommitDescription  NVARCHAR(2000),
	@CommittedBy        UNIQUEIDENTIFIER,
	@CommittedOn        DATETIME
AS
BEGIN
	SET NOCOUNT ON;
	    UPDATE VersionChangeCommit SET 
		GitCommitId=@GitCommitId,
		CommittedBy=@CommittedBy,
		CommittedOn=@CommittedOn,
		CommittedFiles=@CommittedFiles,
		[Description]=@CommitDescription
		where VersionChangeCommitId=@VersionChangeCommitId
	    
END
GO
/****** Object:  StoredProcedure [dbo].[spUpdateVersionData]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[spUpdateVersionData]	
	@versionId           UNIQUEIDENTIFIER,
	@ComponentId         UNIQUEIDENTIFIER,
	@Version			 nvarchar(10),
	@BuildBy			 nvarchar(20), 
	@BuildOn			 datetime,
	@DBBuilds			 nvarchar(50),
	@IsLocked			 bit,	
	@ModifiedBy			 UNIQUEIDENTIFIER
	
AS

BEGIN
	SET NOCOUNT ON;
	Update Version
		SET Version=@Version,
			BuildBy=@BuildBy,
			BuildOn=@BuildOn,
			DBBuilds=@DBBuilds,
			IsLocked=@IsLocked,
			ModifiedBy=@ModifiedBy,
			ModifiedOn=GETDATE()
	WHERE versionId=@versionId

END
GO
/****** Object:  StoredProcedure [dbo].[spUpdateVersionLock]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spUpdateVersionLock]
	-- Add the parameters for the stored procedure here
	@VersionId		uniqueidentifier,
	@IsLocked		bit,
	@ModifiedBy     uniqueidentifier

AS

BEGIN
	SET NOCOUNT ON;

    -- Update statements for procedure here
	UPDATE Version
	SET IsLocked = @IsLocked,
		ModifiedBy = @ModifiedBy,
		ModifiedOn = GETDATE()
	WHERE VersionId = @VersionId
END
GO
/****** Object:  StoredProcedure [dbo].[spUpdateWorkLog]    Script Date: 1/23/2020 10:14:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[spUpdateWorkLog]
@UserId UNIQUEIDENTIFIER,
@TaskId UNIQUEIDENTIFIER,
@WorkDate DATETIME,
@Hours DECIMAL(18,2),
@Remarks NVARCHAR(100),
@RemainingEstimate INT=NULL
AS 
BEGIN
	IF EXISTS(SELECT 1 FROM WorkLog wl WHERE wl.UserId=@UserId AND wl.TaskId = @TaskId AND wl.WorkDate = @WorkDate )
   	BEGIN
   	DELETE FROM WorkLog WHERE UserId=@UserId AND TaskId = @TaskId AND WorkDate = @WorkDate
   	END
   	
   			INSERT INTO WorkLog
   			(
   				WorkLogId,
   				UserId,
   				TaskId,
   				WorkDate,
   				Hours,
   				Remarks,
   				CreatedBy,
   				CreatedDate,
   				UpdatedBy,
   				UpdatedDate
   			)
   			VALUES
   			(
   				NEWID(),
   				@userId,
   				@TaskId,
   				@workDate,
   				@Hours,
   				@Remarks,
   				@UserId,
   				GETDATE(),
   				null,
   				null
   			)

			UPDATE Task SET RemainingEstimate=@RemainingEstimate Where TaskId=@TaskId
   		
END
GO
