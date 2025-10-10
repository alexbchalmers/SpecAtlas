/*******************************************************************************
*
* DatabaseLoad.cypher
* 
* This script is used to load Atlas data in to a neo4j instance
*
*******************************************************************************/

/* Parameters ******************************************************************
*
*   Parameter Name            Notes
*   ------------------------  --------------------------------------------------
*   $authorityDataUrl         URL to the CSV containing Authority initial load
*   $authorityDraftDataUrl    URL to the CSV containing AuthorityDraft initial load
*   $revisionDataUrl          URL to the CSV containing Revision initial load
*   $controllingOrgDataUrl    URL to the CSV containing ControllingOrg initial load
*   $protocolDataUrl          URL to the CSV containing Protocol initial load
*   $protocolVersionDataUrl   URL to the CSV containing ProtocolVersion initial load
*
*   $relationshipDataUrl      URL to the CSV containing Relationship initial load
*
*******************************************************************************/

/* Atlas Status Values *********************************************************
*
*   Value Name                Notes
*   ------------------------  --------------------------------------------------
*   core                      Principal specs/technologies
*   ext                       Extension to core specifications
*   support                   Supporting specifications
*   refonly                   Specifications that are baseline technologies
*                               but not directly identity technologies
*
*   relComplete               Capture of all relationships complete
*   refComplete               Capture of all approved authority references complete
*   draftComplete             Capture of all draft versions of authority complete
*   draftRefComplete          Capture of references in all drafts complete
*   errataComplete            Capture of all errata references complete
*
*******************************************************************************/


/* NODE: ControllingOrg ********************************************************
*
*   Property Name         Type                                  Constraints
*   --------------------  ------------------------------------  ----------------
*   controllingOrgId      STRING                                NODE KEY
*   createdTimestamp      ZONED DATETIME                        NOT NULL
*   updatedTimestamp      ZONED DATETIME                        NOT NULL
*
*   shortName             STRING                                UNIQUE
*   fullName              STRING                                UNIQUE
*   organizationType      STRING                                NOT NULL
*   status                LIST<STRING NOT NULL>                 NOT NULL
*   startDate             DATE
*   endDate               DATE
*   url                   STRING
*   notes                 LIST<STRING NOT NULL>
*
*******************************************************************************/

CREATE CONSTRAINT ControllingOrg__controllingOrgId__type IF NOT EXISTS
FOR (co:ControllingOrg)
REQUIRE co.controllingOrgId IS :: STRING;

CREATE CONSTRAINT ControllingOrg__controllingOrgId__key IF NOT EXISTS
FOR (co:ControllingOrg)
REQUIRE co.controllingOrgId IS NODE KEY;

CREATE CONSTRAINT ControllingOrg__createdTimestamp__type IF NOT EXISTS
FOR (co:ControllingOrg)
REQUIRE co.createdTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT ControllingOrg__createdTimestamp__reqd IF NOT EXISTS
FOR (co:ControllingOrg)
REQUIRE co.createdTimestamp IS NOT NULL;

CREATE CONSTRAINT ControllingOrg__updatedTimestamp__type IF NOT EXISTS
FOR (co:ControllingOrg)
REQUIRE co.updatedTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT ControllingOrg__updatedTimestamp__reqd IF NOT EXISTS
FOR (co:ControllingOrg)
REQUIRE co.updatedTimestamp IS NOT NULL;

CREATE CONSTRAINT ControllingOrg__shortName__type IF NOT EXISTS
FOR (co:ControllingOrg)
REQUIRE co.shortName IS :: STRING;

CREATE CONSTRAINT ControllingOrg__shortName__unique IF NOT EXISTS
FOR (co:ControllingOrg)
REQUIRE co.shortName IS UNIQUE;

CREATE CONSTRAINT ControllingOrg__fullName__type IF NOT EXISTS
FOR (co:ControllingOrg)
REQUIRE co.fullName IS :: STRING;

CREATE CONSTRAINT ControllingOrg__fullName__unique IF NOT EXISTS
FOR (co:ControllingOrg)
REQUIRE co.fullName IS UNIQUE;

CREATE CONSTRAINT ControllingOrg__organizationType__type IF NOT EXISTS
FOR (co:ControllingOrg)
REQUIRE co.organizationType IS :: STRING;

CREATE CONSTRAINT ControllingOrg__organizationType__reqd IF NOT EXISTS
FOR (co:ControllingOrg)
REQUIRE co.organizationType IS NOT NULL;

CREATE CONSTRAINT ControllingOrg__status__type IF NOT EXISTS
FOR (co:ControllingOrg)
REQUIRE co.status IS :: LIST<STRING NOT NULL>;

CREATE CONSTRAINT ControllingOrg__status__reqd IF NOT EXISTS
FOR (co:ControllingOrg)
REQUIRE co.status IS NOT NULL;

CREATE CONSTRAINT Authority__startDate__type IF NOT EXISTS
FOR (co:ControllingOrg)
REQUIRE co.startDate IS :: DATE;

CREATE CONSTRAINT Authority__endDate__type IF NOT EXISTS
FOR (co:ControllingOrg)
REQUIRE co.endDate IS :: DATE;

CREATE CONSTRAINT ControllingOrg__url__type IF NOT EXISTS
FOR (co:ControllingOrg)
REQUIRE co.url IS :: STRING;

CREATE CONSTRAINT ControllingOrg__notes__type IF NOT EXISTS
FOR (co:ControllingOrg)
REQUIRE co.notes IS :: LIST<STRING NOT NULL>;

/* Load ControllingOrg Node Data **********************************************/

LOAD CSV WITH HEADERS FROM $controllingOrgDataUrl AS row
MERGE (
  co:ControllingOrg {
    controllingOrgId: coalesce(lower(trim(row.controllingOrgId)), randomUUID())
  }
)
  ON CREATE
    SET
    // Metadata Fields             Definition
      co.createdTimestamp       = coalesce(
                                    datetime(trim(row.createdTimestamp)),
                                    datetime()
                                  )
      , co.updatedTimestamp     = coalesce(
                                    datetime(trim(row.updatedTimestamp)),
                                    datetime()
                                  )
    // Informational Fields        Definition
      , co.shortName            = coalesce(
                                    trim(row.shortName), 
                                    trim(row.fullName)
                                  )
      , co.fullName             = trim(row.fullName)
      , co.organizationType     = coalesce(
                                    nullIf(trim(row.organizationType), ''),
                                    'unknown'
                                  )
      , co.status               = coalesce(
                                    [x IN split(row.status, ';') | lower(trim(x))], 
                                    ['unknown']
                                  )
      , co.startDate            = date(nullIf(trim(row.startDate), ''))     // startDate must be in format YYYY[-MM[-DD]]
      , co.endDate              = date(nullIf(trim(row.endDate), ''))       // endDate must be in format YYYY[-MM[-DD]]                            
      , co.url                  = nullIf(trim(row.url), '')
      , co.notes                = [x IN split(nullIf(trim(row.notes), ''), '||') | trim(x)]
RETURN
  'Loaded ControllingOrg Data';


/* NODE: Authority *************************************************************
*
*   Property Name         Type                                  Constraints
*   --------------------  ------------------------------------  ----------------
*   authorityId           STRING                                NODE KEY
*   createdTimestamp      ZONED DATETIME                        NOT NULL
*   updatedTimestamp      ZONED DATETIME                        NOT NULL
*   atlasStatus           LIST<STRING NOT NULL>                 NOT NULL
*
*   reference             STRING                                UNIQUE
*   title                 STRING                                NOT NULL
*   status                LIST<STRING NOT NULL>                 NOT NULL
*   versionTag            STRING
*   type                  STRING
*   stream                STRING
*   publishedDate         DATE
*   canonicalUrl          STRING
*   canonicalFormat       STRING
*   plainTextUrl          STRING
*   htmlUrl               STRING
*   otherUrl              STRING
*   otherFormat           STRING
*   notes                 LIST<STRING NOT NULL>
*
*******************************************************************************/

CREATE CONSTRAINT Authority__authorityId__type IF NOT EXISTS
FOR (a:Authority)
REQUIRE a.authorityId IS :: STRING;

CREATE CONSTRAINT Authority__authorityId__key IF NOT EXISTS
FOR (a:Authority)
REQUIRE a.authorityId IS NODE KEY;

CREATE CONSTRAINT Authority__createdTimestamp__type IF NOT EXISTS
FOR (a:Authority)
REQUIRE a.createdTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT Authority__createdTimestamp__reqd IF NOT EXISTS
FOR (a:Authority)
REQUIRE a.createdTimestamp IS NOT NULL;

CREATE CONSTRAINT Authority__updatedTimestamp__type IF NOT EXISTS
FOR (a:Authority)
REQUIRE a.updatedTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT Authority__updatedTimestamp__reqd IF NOT EXISTS
FOR (a:Authority)
REQUIRE a.updatedTimestamp IS NOT NULL;

CREATE CONSTRAINT Authority__atlasStatus__type IF NOT EXISTS
FOR (a:Authority)
REQUIRE a.atlasStatus IS :: LIST<STRING NOT NULL>;

CREATE CONSTRAINT Authority__atlasStatus__reqd IF NOT EXISTS
FOR (a:Authority)
REQUIRE a.atlasStatus IS NOT NULL;

CREATE CONSTRAINT Authority__reference__type IF NOT EXISTS
FOR (a:Authority)
REQUIRE a.reference IS :: STRING;

CREATE CONSTRAINT Authority__reference__unique IF NOT EXISTS
FOR (a:Authority)
REQUIRE a.reference IS UNIQUE;

CREATE CONSTRAINT Authority__versionTag__type IF NOT EXISTS
FOR (a:Authority)
REQUIRE a.versionTag IS :: STRING;

CREATE CONSTRAINT Authority__title__type IF NOT EXISTS
FOR (a:Authority)
REQUIRE a.title IS :: STRING;

CREATE CONSTRAINT Authority__title__reqd IF NOT EXISTS
FOR (a:Authority)
REQUIRE a.title IS NOT NULL;

CREATE CONSTRAINT Authority__status__type IF NOT EXISTS
FOR (a:Authority)
REQUIRE a.status IS :: LIST<STRING NOT NULL>;

CREATE CONSTRAINT Authority__status__reqd IF NOT EXISTS
FOR (a:Authority)
REQUIRE a.status IS NOT NULL;

CREATE CONSTRAINT Authority__type__type IF NOT EXISTS
FOR (a:Authority)
REQUIRE a.type IS :: STRING;

CREATE CONSTRAINT Authority__stream__type IF NOT EXISTS
FOR (a:Authority)
REQUIRE a.stream IS :: STRING;

CREATE CONSTRAINT Authority__publishedDate__type IF NOT EXISTS
FOR (a:Authority)
REQUIRE a.publishedDate IS :: DATE;

CREATE CONSTRAINT Authority__canonicalUrl__type IF NOT EXISTS
FOR (a:Authority)
REQUIRE a.canonicalUrl IS :: STRING;

CREATE CONSTRAINT Authority__canonicalFormat__type IF NOT EXISTS
FOR (a:Authority)
REQUIRE a.canonicalFormat IS :: STRING;

CREATE CONSTRAINT Authority__plainTextUrl__type IF NOT EXISTS
FOR (a:Authority)
REQUIRE a.plainTextUrl IS :: STRING;

CREATE CONSTRAINT Authority__htmlUrl__type IF NOT EXISTS
FOR (a:Authority)
REQUIRE a.htmlUrl IS :: STRING;

CREATE CONSTRAINT Authority__otherUrl__type IF NOT EXISTS
FOR (a:Authority)
REQUIRE a.otherUrl IS :: STRING;

CREATE CONSTRAINT Authority__otherFormat__type IF NOT EXISTS
FOR (a:Authority)
REQUIRE a.otherFormat IS :: STRING;

CREATE CONSTRAINT Authority__notes__type IF NOT EXISTS
FOR (a:Authority)
REQUIRE a.notes IS :: LIST<STRING NOT NULL>;

/* Load Authority Node Data ***************************************************/

LOAD CSV WITH HEADERS FROM $authorityDataUrl AS row
MERGE (
  a:Authority {
    authorityId: coalesce(lower(trim(row.authorityId)), randomUUID())
  }
)
  ON CREATE
    SET
    // Metadata Fields             Definition
      a.createdTimestamp        = coalesce(
                                    datetime(trim(row.createdTimestamp)),
                                    datetime()
                                  )
      , a.updatedTimestamp      = coalesce(
                                    datetime(trim(row.updatedTimestamp)),
                                    datetime()
                                  )
      , a.atlasStatus           = coalesce(
                                    [x IN split(row.atlasStatus, ';') | lower(trim(x))], 
                                    ['unknown']
                                  )
    // Informational Fields        Definition
      , a.reference             = trim(row.reference)
      , a.title                 = trim(row.title)
      , a.status                = coalesce(
                                    [x IN split(row.status, ';') | lower(trim(x))], 
                                    ['unknown']
                                  )
      , a.type                  = nullIf(trim(row.type), '')
      , a.stream                = nullIf(trim(row.stream), '')
      , a.publishedDate         = date(nullIf(trim(row.publishedDate), ''))     // publishedDate must be in format YYYY[-MM[-DD]]
      , a.canonicalUrl          = nullIf(trim(row.canonicalUrl), '')
      , a.canonicalFormat       = nullIf(trim(row.canonicalFormat), '')
      , a.plainTextUrl          = nullIf(trim(row.plainTextUrl), '')
      , a.htmlUrl               = nullIf(trim(row.htmlUrl), '')
      , a.otherUrl              = nullIf(trim(row.otherUrl), '')
      , a.otherFormat           = nullIf(trim(row.otherFormat), '')
      , a.notes                 = [x IN split(nullIf(trim(row.notes), ''), '||') | trim(x)]
RETURN
  'Loaded Authority Node Data';


/* NODE: AuthorityGroup ********************************************************
*
*   Property Name         Type                                  Constraints
*   --------------------  ------------------------------------  ----------------
*   authorityGroupId      STRING                                NODE KEY
*   createdTimestamp      ZONED DATETIME                        NOT NULL
*   updatedTimestamp      ZONED DATETIME                        NOT NULL
*   atlasStatus           LIST<STRING NOT NULL>                 NOT NULL
*
*   groupType             STRING                                NOT NULL
*   reference             STRING                                UNIQUE
*   title                 STRING                                NOT NULL
*   url                   STRING
*   notes                 LIST<STRING NOT NULL>
*
*******************************************************************************/

CREATE CONSTRAINT AuthorityGroup__authorityGroupId__type IF NOT EXISTS
FOR (ag:AuthorityGroup)
REQUIRE ag.authorityGroupId IS :: STRING;

CREATE CONSTRAINT AuthorityGroup__authorityGroupId__key IF NOT EXISTS
FOR (ag:AuthorityGroup)
REQUIRE ag.authorityGroupId IS NODE KEY;

CREATE CONSTRAINT AuthorityGroup__createdTimestamp__type IF NOT EXISTS
FOR (ag:AuthorityGroup)
REQUIRE ag.createdTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT AuthorityGroup__createdTimestamp__reqd IF NOT EXISTS
FOR (ag:AuthorityGroup)
REQUIRE ag.createdTimestamp IS NOT NULL;

CREATE CONSTRAINT AuthorityGroup__updatedTimestamp__type IF NOT EXISTS
FOR (ag:AuthorityGroup)
REQUIRE ag.updatedTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT AuthorityGroup__updatedTimestamp__reqd IF NOT EXISTS
FOR (ag:AuthorityGroup)
REQUIRE ag.updatedTimestamp IS NOT NULL;

CREATE CONSTRAINT AuthorityGroup__atlasStatus__type IF NOT EXISTS
FOR (ag:AuthorityGroup)
REQUIRE ag.atlasStatus IS :: LIST<STRING NOT NULL>;

CREATE CONSTRAINT AuthorityGroup__atlasStatus__reqd IF NOT EXISTS
FOR (ag:AuthorityGroup)
REQUIRE ag.atlasStatus IS NOT NULL;

CREATE CONSTRAINT AuthorityGroup__groupType__type IF NOT EXISTS
FOR (ag:AuthorityGroup)
REQUIRE ag.groupType IS :: STRING;

CREATE CONSTRAINT AuthorityGroup__groupType__reqd IF NOT EXISTS
FOR (ag:AuthorityGroup)
REQUIRE ag.groupType IS NOT NULL;

CREATE CONSTRAINT AuthorityGroup__reference__type IF NOT EXISTS
FOR (ag:AuthorityGroup)
REQUIRE ag.reference IS :: STRING;

CREATE CONSTRAINT AuthorityGroup__reference__unique IF NOT EXISTS
FOR (ag:AuthorityGroup)
REQUIRE ag.reference IS UNIQUE;

CREATE CONSTRAINT AuthorityGroup__title__type IF NOT EXISTS
FOR (ag:AuthorityGroup)
REQUIRE ag.title IS :: STRING;

CREATE CONSTRAINT AuthorityGroup__title__reqd IF NOT EXISTS
FOR (ag:AuthorityGroup)
REQUIRE ag.title IS NOT NULL;

CREATE CONSTRAINT AuthorityGroup__url__type IF NOT EXISTS
FOR (ag:AuthorityGroup)
REQUIRE ag.otherUrl IS :: STRING;

CREATE CONSTRAINT AuthorityGroup__notes__type IF NOT EXISTS
FOR (ag:AuthorityGroup)
REQUIRE ag.notes IS :: LIST<STRING NOT NULL>;

/* Load AuthorityGroup Node Data **********************************************/

LOAD CSV WITH HEADERS FROM $authorityGroupDataUrl AS row
MERGE (
  ag:AuthorityGroup {
    authorityGroupId: coalesce(lower(trim(row.authorityGroupId)), randomUUID())
  }
)
  ON CREATE
    SET
    // Metadata Fields             Definition
      ag.createdTimestamp       = coalesce(
                                    datetime(trim(row.createdTimestamp)),
                                    datetime()
                                  )
      , ag.updatedTimestamp     = coalesce(
                                    datetime(trim(row.updatedTimestamp)),
                                    datetime()
                                  )
      , ag.atlasStatus          = coalesce(
                                    [x IN split(row.atlasStatus, ';') | lower(trim(x))], 
                                    ['unknown']
                                  )
    // Informational Fields        Definition
      , ag.groupType            = trim(row.groupType)
      , ag.reference            = trim(row.reference)
      , ag.title                = trim(row.title)
      , ag.url                  = nullIf(trim(row.url), '')
      , ag.notes                = [x IN split(nullIf(trim(row.notes), ''), '||') | trim(x)]
RETURN
  'Loaded AuthorityGroup Node Data';


/* NODE: AuthorityDraft ********************************************************
*
*   Property Name         Type                                  Constraints
*   --------------------  ------------------------------------  ----------------
*   authorityDraftId      STRING                                NODE KEY
*   reference             STRING                                UNIQUE
*   title                 STRING                                NOT NULL
*   status                LIST<STRING NOT NULL>                 NOT NULL
*   type                  STRING
*   stream                STRING
*
*******************************************************************************/

CREATE CONSTRAINT AuthorityDraft__authorityDraftId__type IF NOT EXISTS
FOR (ad:AuthorityDraft)
REQUIRE ad.authorityDraftId IS :: STRING;

CREATE CONSTRAINT AuthorityDraft__authorityDraftId__key IF NOT EXISTS
FOR (ad:AuthorityDraft)
REQUIRE ad.authorityDraftId IS NODE KEY;

CREATE CONSTRAINT AuthorityDraft__reference__type IF NOT EXISTS
FOR (ad:AuthorityDraft)
REQUIRE ad.reference IS :: STRING;

CREATE CONSTRAINT AuthorityDraft__reference__unique IF NOT EXISTS
FOR (ad:AuthorityDraft)
REQUIRE ad.reference IS UNIQUE;

CREATE CONSTRAINT AuthorityDraft__title__type IF NOT EXISTS
FOR (ad:AuthorityDraft)
REQUIRE ad.title IS :: STRING;

CREATE CONSTRAINT AuthorityDraft__title__reqd IF NOT EXISTS
FOR (ad:AuthorityDraft)
REQUIRE ad.title IS NOT NULL;

CREATE CONSTRAINT AuthorityDraft__status__type IF NOT EXISTS
FOR (ad:AuthorityDraft)
REQUIRE ad.status IS :: LIST<STRING NOT NULL>;

CREATE CONSTRAINT AuthorityDraft__status__reqd IF NOT EXISTS
FOR (ad:AuthorityDraft)
REQUIRE ad.status IS NOT NULL;

CREATE CONSTRAINT AuthorityDraft__type__type IF NOT EXISTS
FOR (ad:AuthorityDraft)
REQUIRE ad.type IS :: STRING;

CREATE CONSTRAINT AuthorityDraft__stream__type IF NOT EXISTS
FOR (ad:AuthorityDraft)
REQUIRE ad.stream IS :: STRING;

/* Load AuthorityDraft Node Data **********************************************/

LOAD CSV WITH HEADERS FROM $authorityDraftDataUrl AS row
MERGE (
  ad:AuthorityDraft {
    authorityDraftId: coalesce(lower(trim(row.authorityDraftId)), randomUUID())
  }
)
SET
  ad.reference = trim(row.reference),
  ad.title = trim(row.title),
  ad.status = coalesce(
                [x IN split(row.status, ';') | lower(trim(x))], 
                ['unknown']
              ),
  ad.type = nullIf(trim(row.type), ''),
  ad.stream = nullIf(trim(row.stream), '')
RETURN
  'Loaded AuthorityDraft Data';


/* NODE: Revision **************************************************************
*
*   Property Name         Type                                  Constraints
*   --------------------  ------------------------------------  ----------------
*   revisionId            STRING                                NODE KEY
*   reference             STRING                                UNIQUE
*   version               STRING                                NOT NULL
*   title                 STRING                                NOT NULL
*   status                LIST<STRING NOT NULL>                 NOT NULL
*   type                  STRING
*   stream                STRING
*   publishedDate         DATE
*   canonicalUrl          STRING
*   canonicalFormat       STRING
*   plainTextUrl          STRING
*   htmlUrl               STRING
*   otherUrl              STRING
*   otherFormat           STRING
*
*******************************************************************************/

CREATE CONSTRAINT Revision__revisionId__type IF NOT EXISTS
FOR (r:Revision)
REQUIRE r.revisionId IS :: STRING;

CREATE CONSTRAINT Revision__revisionId__key IF NOT EXISTS
FOR (r:Revision)
REQUIRE r.revisionId IS NODE KEY;

CREATE CONSTRAINT Revision__reference__type IF NOT EXISTS
FOR (r:Revision)
REQUIRE r.reference IS :: STRING;

CREATE CONSTRAINT Revision__reference__unique IF NOT EXISTS
FOR (r:Revision)
REQUIRE r.reference IS UNIQUE;

CREATE CONSTRAINT Revision__version__type IF NOT EXISTS
FOR (r:Revision)
REQUIRE r.version IS :: STRING;

CREATE CONSTRAINT Revision__version__reqd IF NOT EXISTS
FOR (r:Revision)
REQUIRE r.version IS NOT NULL;

CREATE CONSTRAINT Revision__title__type IF NOT EXISTS
FOR (r:Revision)
REQUIRE r.title IS :: STRING;

CREATE CONSTRAINT Revision__title__reqd IF NOT EXISTS
FOR (r:Revision)
REQUIRE r.title IS NOT NULL;

CREATE CONSTRAINT Revision__status__type IF NOT EXISTS
FOR (r:Revision)
REQUIRE r.status IS :: LIST<STRING NOT NULL>;

CREATE CONSTRAINT Revision__status__reqd IF NOT EXISTS
FOR (r:Revision)
REQUIRE r.status IS NOT NULL;

CREATE CONSTRAINT Revision__type__type IF NOT EXISTS
FOR (r:Revision)
REQUIRE r.type IS :: STRING;

CREATE CONSTRAINT Revision__stream__type IF NOT EXISTS
FOR (r:Revision)
REQUIRE r.stream IS :: STRING;

CREATE CONSTRAINT Revision__publishedDate__type IF NOT EXISTS
FOR (r:Revision)
REQUIRE r.publishedDate IS :: DATE;

CREATE CONSTRAINT Revision__canonicalUrl__type IF NOT EXISTS
FOR (r:Revision)
REQUIRE r.canonicalUrl IS :: STRING;

CREATE CONSTRAINT Revision__canonicalFormat__type IF NOT EXISTS
FOR (r:Revision)
REQUIRE r.canonicalFormat IS :: STRING;

CREATE CONSTRAINT Revision__plainTextUrl__type IF NOT EXISTS
FOR (r:Revision)
REQUIRE r.plainTextUrl IS :: STRING;

CREATE CONSTRAINT Revision__htmlUrl__type IF NOT EXISTS
FOR (r:Revision)
REQUIRE r.htmlUrl IS :: STRING;

CREATE CONSTRAINT Revision__otherUrl__type IF NOT EXISTS
FOR (r:Revision)
REQUIRE r.otherUrl IS :: STRING;

CREATE CONSTRAINT Revision__otherFormat__type IF NOT EXISTS
FOR (r:Revision)
REQUIRE r.otherFormat IS :: STRING;

/* Load Revision Node Data ***************************************************/

LOAD CSV WITH HEADERS FROM $revisionDataUrl AS row
MERGE (
  r:Revision {
    revisionId: coalesce(lower(trim(row.revisionId)), randomUUID())
  }
)
SET
  r.reference = trim(row.reference),
  r.version = trim(row.version),
  r.title = trim(row.title),
  r.status = coalesce(
              [x IN split(row.status, ';') | lower(trim(x))], 
              ['unknown']
            ),
  r.type = nullIf(trim(row.type), ''),
  r.stream = nullIf(trim(row.stream), ''),
  r.publishedDate = date(row.publishedDate),
  r.canonicalUrl = nullIf(trim(row.canonicalUrl), ''),
  r.canonicalFormat = nullIf(trim(row.canonicalFormat), ''),
  r.plainTextUrl = nullIf(trim(row.plainTextUrl), ''),
  r.htmlUrl = nullIf(trim(row.htmlUrl), ''),
  r.otherUrl = nullIf(trim(row.otherUrl), ''),
  r.otherFormat = nullIf(trim(row.otherFormat), '')
RETURN
  'Loaded Revision Data';


/* NODE: Protocol **************************************************************
*
*   Property Name         Type                                  Constraints
*   --------------------  ------------------------------------  ----------------
*   protocolId            STRING                                NODE KEY
*   name                  STRING                                UNIQUE
*   type                  STRING | LIST<STRING NOT NULL>        NOT NULL
*
*******************************************************************************/

CREATE CONSTRAINT Protocol__protocolId__type IF NOT EXISTS
FOR (p:Protocol)
REQUIRE p.protocolId IS :: STRING;

CREATE CONSTRAINT Protocol__protocolId__key IF NOT EXISTS
FOR (p:Protocol)
REQUIRE p.protocolId IS NODE KEY;

CREATE CONSTRAINT Protocol__name__type IF NOT EXISTS
FOR (p:Protocol)
REQUIRE p.name IS :: STRING;

CREATE CONSTRAINT Protocol__name__unique IF NOT EXISTS
FOR (p:Protocol)
REQUIRE p.name IS UNIQUE;

CREATE CONSTRAINT Protocol__type__type IF NOT EXISTS
FOR (p:Protocol)
REQUIRE p.type IS :: STRING | LIST<STRING NOT NULL>;

/* Load Protocol Node Data ****************************************************/

LOAD CSV WITH HEADERS FROM $protocolDataUrl AS row
MERGE (
  p:Protocol {
    protocolId: coalesce(lower(trim(row.protocolId)), randomUUID())
  }
)
SET
  p.name = trim(row.name),
  p.type = coalesce(
              [x IN split(row.type, ';') | lower(trim(x))], 
              ['not identified']
            )
RETURN
  'Loaded Protocol Data';


/* NODE: ProtocolVersion *******************************************************
*
*   Property Name         Type                                  Constraints
*   --------------------  ------------------------------------  ----------------
*   protocolVersionId     STRING                                NODE KEY
*   versionedName         STRING                                UNIQUE
*   versionTag            STRING                                NOT NULL
*
*******************************************************************************/

CREATE CONSTRAINT ProtocolVersion__protocolVersionId__type IF NOT EXISTS
FOR (pv:ProtocolVersion)
REQUIRE pv.protocolVersionId IS :: STRING;

CREATE CONSTRAINT ProtocolVersion__protocolVersionId__key IF NOT EXISTS
FOR (pv:ProtocolVersion)
REQUIRE pv.protocolVersionId IS NODE KEY;

CREATE CONSTRAINT ProtocolVersion__versionedName__type IF NOT EXISTS
FOR (pv:ProtocolVersion)
REQUIRE pv.versionedName IS :: STRING;

CREATE CONSTRAINT ProtocolVersion__versionedName__unique IF NOT EXISTS
FOR (pv:ProtocolVersion)
REQUIRE pv.versionedName IS UNIQUE;

CREATE CONSTRAINT ProtocolVersion__versionTag__type IF NOT EXISTS
FOR (pv:ProtocolVersion)
REQUIRE pv.versionTag IS :: STRING;

/* Load ProtocolVersion Node Data *********************************************/

LOAD CSV WITH HEADERS FROM $protocolVersionDataUrl AS row
MERGE (
  pv:ProtocolVersion {
    protocolVersionId: coalesce(lower(trim(row.protocolVersionId)), randomUUID())
  }
)
SET
  p.versionedName = trim(row.versionedName),
  p.versionTag = trim(row.versionTag)
RETURN
  'Loaded ProtocolVersion Data';


/* NODE: ProtocolFeature *******************************************************
*
*   Property Name         Type                                  Constraints
*   --------------------  ------------------------------------  ----------------
*   protocolFeatureId     STRING                                NODE KEY
*   name                  STRING                                UNIQUE
*   category              STRING                                NOT NULL
*   description           STRING
*
*******************************************************************************/

CREATE CONSTRAINT ProtocolFeature__protocolFeatureId__type IF NOT EXISTS
FOR (pf:ProtocolFeature)
REQUIRE pf.protocolFeatureId IS :: STRING;

CREATE CONSTRAINT ProtocolFeature__protocolFeatureId__key IF NOT EXISTS
FOR (pf:ProtocolFeature)
REQUIRE pf.protocolFeatureId IS NODE KEY;

CREATE CONSTRAINT ProtocolFeature__name__type IF NOT EXISTS
FOR (pf:ProtocolFeature)
REQUIRE pf.name IS :: STRING;

CREATE CONSTRAINT ProtocolFeature__name__unique IF NOT EXISTS
FOR (pf:ProtocolFeature)
REQUIRE pf.name IS UNIQUE;

CREATE CONSTRAINT ProtocolFeature__category__type IF NOT EXISTS
FOR (pf:ProtocolFeature)
REQUIRE pf.category IS :: STRING;

CREATE CONSTRAINT ProtocolFeature__category__reqd IF NOT EXISTS
FOR (pf:ProtocolFeature)
REQUIRE pf.category IS NOT NULL;

CREATE CONSTRAINT ProtocolFeature__description__type IF NOT EXISTS
FOR (pf:ProtocolFeature)
REQUIRE pf.description IS :: STRING;

/* Load ProtocolVersion Node Data *********************************************/

LOAD CSV WITH HEADERS FROM $protocolVersionDataUrl AS row
MERGE (
  pv:ProtocolVersion {
    protocolVersionId: coalsce(lower(trim(row.protocolVersionId)), randomUUID())
  }
)
SET
    versionedName: trim(row.versionedName),
    versionTag: trim(row.versionTag)
RETURN
  'Loaded ProtocolVersion Data';


/* RELATIONSHIPS ***************************************************************
*
*   Relationship Definition Elements
*
*   Property Name         Notes
*   --------------------  ------------------------------------------------------
*   relationshipType      Relationship Type, should be in all caps
*   _sourceNodeType_      Node type, used only to match the source node
*   _sourceNodeAttr_      Node attribute, used only to match the source node
*   _sourceNodeValue_     Node attribute value, used only to match the source node
*   _targetNodeType_      Node type, used only to match the target node
*   _targetNodeAttr_      Node attribute, used only to match the target node
*   _targetNodeValue_     Node attribute value, used only to match the target node
*
*   Global Properties
*
*   Property Name         Type                                  Constraints
*   --------------------  ------------------------------------  ----------------
*   relationshipId        STRING                                REL KEY
*   createdTimestamp      ZONED DATETIME                        NOT NULL
*   updatedTimestamp      ZONED DATETIME                        NOT NULL
*
*   notes                 LIST<STRING NOT NULL>
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
*   HAS_CHILD_ORG
*       ControllingOrg       -->      ControllingOrg
*
*     Represents a direct parent-child relationship between organizations
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
*   HAS_AFFILIATE_ORG
*       ControllingOrg       -->      ControllingOrg
*
*     Represents a formal relationship between organizations that is not a
*     direct parent-child relationship, noted in _affiliation_
*
*   Property Name         Type                                  Constraints
*   --------------------  ------------------------------------  ----------------
*   affiliation           STRING                                NOT NULL
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
*   PREVIOUSLY_KNOWN_AS
*       ControllingOrg       -->      ControllingOrg
*
*     Identifies an organization's previous name, when the org is directly
*     renamed or reorganized into the new organization
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
*   SUCCEEDED_ORG
*       ControllingOrg       -->      ControllingOrg
*
*     Identifies predecessor organizations from which the current org is
*     derived, such as in spin-offs, mergers, or other non-direct options
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
*   CONTROLS
*       ControllingOrg       -->      Authority
*
*     Identifies the organization that directly controls (e.g., writes, approves)
*     a given authority, this may be a subordinate or affiliated org to the
*     organization that publishes the authority
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
*   REFERENCES
*       Authority            -->      Authority
*       Authority            -->      AuthorityGroup
*       AuthorityGroup       -->      AuthorityGroup
*       AuthorityGroup       -->      Authority
*
*     Identifies direct references from one authority to another, the level
*     of reference control (e.g., normative, informative) is noted in _referenceType_
*
*   Property Name         Type                                  Constraints
*   --------------------  ------------------------------------  ----------------
*   referenceType         STRING                                NOT NULL
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
*   UPDATES
*       Authority            -->      Authority
*
*     Identifies an authority that modifies another authority without replacing it,
*     such as an amendment or similar
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
*   EXTENDS
*       Authority            -->      Authority
*
*     Identifies an authority that builds upon another authority
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
*   OBSOLETES
*       Authority            -->      Authority
*
*     Identifies an authority that replaces another authority, whether the
*     the replaced authority is withdrawn or remains active is not implied
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
*   CONTAINS
*       Authority            -->      Authority
*
*     Identifies where a separate authority is defined within another authority
*
*   Property Name         Type                                  Constraints
*   --------------------  ------------------------------------  ----------------
*   authoritySection      LIST<STRING NOT NULL>
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
*   HAS_RELATED_AUTHORITY
*       Authority            -->      Authority
*       Authority            -->      AuthorityGroup
*       AuthorityGroup       -->      AuthorityGroup
*       AuthorityGroup       -->      Authority
*
*     Identifies an authority that is similar in some way to another authority,
*     such as through republication, adoption by multiple controlling orgs, etc;
*     the level of similarity is noted in _relationship_
*
*   Property Name         Type                                  Constraints
*   --------------------  ------------------------------------  ----------------
*   relationship          LIST<STRING NOT NULL>                 NOT NULL
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
*   MEMBER_OF
*       Authority            -->      AuthorityGroup
*       AuthorityGroup       -->      AuthorityGroup
*
*     Identifies that the authority is part of a set of collective authorities
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*******************************************************************************/

CREATE CONSTRAINT R_hasChildOrg__relationshipId__type IF NOT EXISTS
FOR ()-[r:HAS_CHILD_ORG]->()
REQUIRE r.relationshipId IS :: STRING;

CREATE CONSTRAINT R_hasChildOrg__relationshipId__key IF NOT EXISTS
FOR ()-[r:HAS_CHILD_ORG]->()
REQUIRE r.relationshipId IS REL KEY;

CREATE CONSTRAINT R_hasChildOrg__createdTimestamp__type IF NOT EXISTS
FOR ()-[r:HAS_CHILD_ORG]->()
REQUIRE r.createdTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_hasChildOrg__createdTimestamp__reqd IF NOT EXISTS
FOR ()-[r:HAS_CHILD_ORG]->()
REQUIRE r.createdTimestamp IS NOT NULL;

CREATE CONSTRAINT R_hasChildOrg__updatedTimestamp__type IF NOT EXISTS
FOR ()-[r:HAS_CHILD_ORG]->()
REQUIRE r.updatedTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_hasChildOrg__updatedTimestamp__reqd IF NOT EXISTS
FOR ()-[r:HAS_CHILD_ORG]->()
REQUIRE r.updatedTimestamp IS NOT NULL;

CREATE CONSTRAINT R_hasChildOrg__notes__type IF NOT EXISTS
FOR ()-[r:HAS_CHILD_ORG]->()
REQUIRE r.notes IS :: LIST<STRING NOT NULL>;


CREATE CONSTRAINT R_hasAffiliateOrg__relationshipId__type IF NOT EXISTS
FOR ()-[r:HAS_AFFILIATE_ORG]->()
REQUIRE r.relationshipId IS :: STRING;

CREATE CONSTRAINT R_hasAffiliateOrg__relationshipId__key IF NOT EXISTS
FOR ()-[r:HAS_AFFILIATE_ORG]->()
REQUIRE r.relationshipId IS REL KEY;

CREATE CONSTRAINT R_hasAffiliateOrg__createdTimestamp__type IF NOT EXISTS
FOR ()-[r:HAS_AFFILIATE_ORG]->()
REQUIRE r.createdTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_hasAffiliateOrg__createdTimestamp__reqd IF NOT EXISTS
FOR ()-[r:HAS_AFFILIATE_ORG]->()
REQUIRE r.createdTimestamp IS NOT NULL;

CREATE CONSTRAINT R_hasAffiliateOrg__updatedTimestamp__type IF NOT EXISTS
FOR ()-[r:HAS_AFFILIATE_ORG]->()
REQUIRE r.updatedTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_hasAffiliateOrg__updatedTimestamp__reqd IF NOT EXISTS
FOR ()-[r:HAS_AFFILIATE_ORG]->()
REQUIRE r.updatedTimestamp IS NOT NULL;

CREATE CONSTRAINT R_hasAffiliateOrg__affiliation__type IF NOT EXISTS
FOR ()-[r:HAS_AFFILIATE_ORG]->()
REQUIRE r.referenceType IS :: STRING;

CREATE CONSTRAINT R_hasAffiliateOrg__affiliation__reqd IF NOT EXISTS
FOR ()-[r:HAS_AFFILIATE_ORG]->()
REQUIRE r.referenceType IS NOT NULL;

CREATE CONSTRAINT R_hasAffiliateOrg__notes__type IF NOT EXISTS
FOR ()-[r:HAS_AFFILIATE_ORG]->()
REQUIRE r.notes IS :: LIST<STRING NOT NULL>;


CREATE CONSTRAINT R_previouslyKnownAs__relationshipId__type IF NOT EXISTS
FOR ()-[r:PREVIOUSLY_KNOWN_AS]->()
REQUIRE r.relationshipId IS :: STRING;

CREATE CONSTRAINT R_previouslyKnownAs__relationshipId__key IF NOT EXISTS
FOR ()-[r:PREVIOUSLY_KNOWN_AS]->()
REQUIRE r.relationshipId IS REL KEY;

CREATE CONSTRAINT R_previouslyKnownAs__createdTimestamp__type IF NOT EXISTS
FOR ()-[r:PREVIOUSLY_KNOWN_AS]->()
REQUIRE r.createdTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_previouslyKnownAs__createdTimestamp__reqd IF NOT EXISTS
FOR ()-[r:PREVIOUSLY_KNOWN_AS]->()
REQUIRE r.createdTimestamp IS NOT NULL;

CREATE CONSTRAINT R_previouslyKnownAs__updatedTimestamp__type IF NOT EXISTS
FOR ()-[r:PREVIOUSLY_KNOWN_AS]->()
REQUIRE r.updatedTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_previouslyKnownAs__updatedTimestamp__reqd IF NOT EXISTS
FOR ()-[r:PREVIOUSLY_KNOWN_AS]->()
REQUIRE r.updatedTimestamp IS NOT NULL;

CREATE CONSTRAINT R_previouslyKnownAs__notes__type IF NOT EXISTS
FOR ()-[r:PREVIOUSLY_KNOWN_AS]->()
REQUIRE r.notes IS :: LIST<STRING NOT NULL>;


CREATE CONSTRAINT R_succeededOrg__relationshipId__type IF NOT EXISTS
FOR ()-[r:SUCCEEDED_ORG]->()
REQUIRE r.relationshipId IS :: STRING;

CREATE CONSTRAINT R_succeededOrg__relationshipId__key IF NOT EXISTS
FOR ()-[r:SUCCEEDED_ORG]->()
REQUIRE r.relationshipId IS REL KEY;

CREATE CONSTRAINT R_succeededOrg__createdTimestamp__type IF NOT EXISTS
FOR ()-[r:SUCCEEDED_ORG]->()
REQUIRE r.createdTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_succeededOrg__createdTimestamp__reqd IF NOT EXISTS
FOR ()-[r:SUCCEEDED_ORG]->()
REQUIRE r.createdTimestamp IS NOT NULL;

CREATE CONSTRAINT R_succeededOrg__updatedTimestamp__type IF NOT EXISTS
FOR ()-[r:SUCCEEDED_ORG]->()
REQUIRE r.updatedTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_succeededOrg__updatedTimestamp__reqd IF NOT EXISTS
FOR ()-[r:SUCCEEDED_ORG]->()
REQUIRE r.updatedTimestamp IS NOT NULL;

CREATE CONSTRAINT R_succeededOrg__notes__type IF NOT EXISTS
FOR ()-[r:SUCCEEDED_ORG]->()
REQUIRE r.notes IS :: LIST<STRING NOT NULL>;


CREATE CONSTRAINT R_controls__relationshipId__type IF NOT EXISTS
FOR ()-[r:CONTROLS]->()
REQUIRE r.relationshipId IS :: STRING;

CREATE CONSTRAINT R_controls__relationshipId__key IF NOT EXISTS
FOR ()-[r:CONTROLS]->()
REQUIRE r.relationshipId IS REL KEY;

CREATE CONSTRAINT R_controls__createdTimestamp__type IF NOT EXISTS
FOR ()-[r:CONTROLS]->()
REQUIRE r.createdTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_controls__createdTimestamp__reqd IF NOT EXISTS
FOR ()-[r:CONTROLS]->()
REQUIRE r.createdTimestamp IS NOT NULL;

CREATE CONSTRAINT R_controls__updatedTimestamp__type IF NOT EXISTS
FOR ()-[r:CONTROLS]->()
REQUIRE r.updatedTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_controls__updatedTimestamp__reqd IF NOT EXISTS
FOR ()-[r:CONTROLS]->()
REQUIRE r.updatedTimestamp IS NOT NULL;

CREATE CONSTRAINT R_controls__notes__type IF NOT EXISTS
FOR ()-[r:CONTROLS]->()
REQUIRE r.notes IS :: LIST<STRING NOT NULL>;


CREATE CONSTRAINT R_references__relationshipId__type IF NOT EXISTS
FOR ()-[r:REFERENCES]->()
REQUIRE r.relationshipId IS :: STRING;

CREATE CONSTRAINT R_references__relationshipId__key IF NOT EXISTS
FOR ()-[r:REFERENCES]->()
REQUIRE r.relationshipId IS REL KEY;

CREATE CONSTRAINT R_references__createdTimestamp__type IF NOT EXISTS
FOR ()-[r:REFERENCES]->()
REQUIRE r.createdTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_references__createdTimestamp__reqd IF NOT EXISTS
FOR ()-[r:REFERENCES]->()
REQUIRE r.createdTimestamp IS NOT NULL;

CREATE CONSTRAINT R_references__updatedTimestamp__type IF NOT EXISTS
FOR ()-[r:REFERENCES]->()
REQUIRE r.updatedTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_references__updatedTimestamp__reqd IF NOT EXISTS
FOR ()-[r:REFERENCES]->()
REQUIRE r.updatedTimestamp IS NOT NULL;

CREATE CONSTRAINT R_references__referenceType__type IF NOT EXISTS
FOR ()-[r:REFERENCES]->()
REQUIRE r.referenceType IS :: STRING;

CREATE CONSTRAINT R_references__referenceType__reqd IF NOT EXISTS
FOR ()-[r:REFERENCES]->()
REQUIRE r.referenceType IS NOT NULL;

CREATE CONSTRAINT R_references__notes__type IF NOT EXISTS
FOR ()-[r:REFERENCES]->()
REQUIRE r.notes IS :: LIST<STRING NOT NULL>;


CREATE CONSTRAINT R_updates__relationshipId__type IF NOT EXISTS
FOR ()-[r:UPDATES]->()
REQUIRE r.relationshipId IS :: STRING;

CREATE CONSTRAINT R_updates__relationshipId__key IF NOT EXISTS
FOR ()-[r:UPDATES]->()
REQUIRE r.relationshipId IS REL KEY;

CREATE CONSTRAINT R_updates__createdTimestamp__type IF NOT EXISTS
FOR ()-[r:UPDATES]->()
REQUIRE r.createdTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_updates__createdTimestamp__reqd IF NOT EXISTS
FOR ()-[r:UPDATES]->()
REQUIRE r.createdTimestamp IS NOT NULL;

CREATE CONSTRAINT R_updates__updatedTimestamp__type IF NOT EXISTS
FOR ()-[r:UPDATES]->()
REQUIRE r.updatedTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_updates__updatedTimestamp__reqd IF NOT EXISTS
FOR ()-[r:UPDATES]->()
REQUIRE r.updatedTimestamp IS NOT NULL;

CREATE CONSTRAINT R_updates__notes__type IF NOT EXISTS
FOR ()-[r:UPDATES]->()
REQUIRE r.notes IS :: LIST<STRING NOT NULL>;


CREATE CONSTRAINT R_extends__relationshipId__type IF NOT EXISTS
FOR ()-[r:EXTENDS]->()
REQUIRE r.relationshipId IS :: STRING;

CREATE CONSTRAINT R_extends__relationshipId__key IF NOT EXISTS
FOR ()-[r:EXTENDS]->()
REQUIRE r.relationshipId IS REL KEY;

CREATE CONSTRAINT R_extends__createdTimestamp__type IF NOT EXISTS
FOR ()-[r:EXTENDS]->()
REQUIRE r.createdTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_extends__createdTimestamp__reqd IF NOT EXISTS
FOR ()-[r:EXTENDS]->()
REQUIRE r.createdTimestamp IS NOT NULL;

CREATE CONSTRAINT R_extends__updatedTimestamp__type IF NOT EXISTS
FOR ()-[r:EXTENDS]->()
REQUIRE r.updatedTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_extends__updatedTimestamp__reqd IF NOT EXISTS
FOR ()-[r:EXTENDS]->()
REQUIRE r.updatedTimestamp IS NOT NULL;

CREATE CONSTRAINT R_extends__notes__type IF NOT EXISTS
FOR ()-[r:EXTENDS]->()
REQUIRE r.notes IS :: LIST<STRING NOT NULL>;


CREATE CONSTRAINT R_obsoletes__relationshipId__type IF NOT EXISTS
FOR ()-[r:OBSOLETES]->()
REQUIRE r.relationshipId IS :: STRING;

CREATE CONSTRAINT R_obsoletes__relationshipId__key IF NOT EXISTS
FOR ()-[r:OBSOLETES]->()
REQUIRE r.relationshipId IS REL KEY;

CREATE CONSTRAINT R_obsoletes__createdTimestamp__type IF NOT EXISTS
FOR ()-[r:OBSOLETES]->()
REQUIRE r.createdTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_obsoletes__createdTimestamp__reqd IF NOT EXISTS
FOR ()-[r:OBSOLETES]->()
REQUIRE r.createdTimestamp IS NOT NULL;

CREATE CONSTRAINT R_obsoletes__updatedTimestamp__type IF NOT EXISTS
FOR ()-[r:OBSOLETES]->()
REQUIRE r.updatedTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_obsoletes__updatedTimestamp__reqd IF NOT EXISTS
FOR ()-[r:OBSOLETES]->()
REQUIRE r.updatedTimestamp IS NOT NULL;

CREATE CONSTRAINT R_obsoletes__notes__type IF NOT EXISTS
FOR ()-[r:OBSOLETES]->()
REQUIRE r.notes IS :: LIST<STRING NOT NULL>;


CREATE CONSTRAINT R_contains__relationshipId__type IF NOT EXISTS
FOR ()-[r:CONTAINS]->()
REQUIRE r.relationshipId IS :: STRING;

CREATE CONSTRAINT R_contains__relationshipId__key IF NOT EXISTS
FOR ()-[r:CONTAINS]->()
REQUIRE r.relationshipId IS REL KEY;

CREATE CONSTRAINT R_contains__createdTimestamp__type IF NOT EXISTS
FOR ()-[r:CONTAINS]->()
REQUIRE r.createdTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_contains__createdTimestamp__reqd IF NOT EXISTS
FOR ()-[r:CONTAINS]->()
REQUIRE r.createdTimestamp IS NOT NULL;

CREATE CONSTRAINT R_contains__updatedTimestamp__type IF NOT EXISTS
FOR ()-[r:CONTAINS]->()
REQUIRE r.updatedTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_contains__updatedTimestamp__reqd IF NOT EXISTS
FOR ()-[r:CONTAINS]->()
REQUIRE r.updatedTimestamp IS NOT NULL;

CREATE CONSTRAINT R_contains__authoritySection__type IF NOT EXISTS
FOR ()-[r:CONTAINS]->()
REQUIRE r.authoritySection IS :: LIST<STRING NOT NULL>;

CREATE CONSTRAINT R_contains__notes__type IF NOT EXISTS
FOR ()-[r:CONTAINS]->()
REQUIRE r.notes IS :: LIST<STRING NOT NULL>;


CREATE CONSTRAINT R_hasRelatedAuthority__relationshipId__type IF NOT EXISTS
FOR ()-[r:HAS_RELATED_AUTHORITY]->()
REQUIRE r.relationshipId IS :: STRING;

CREATE CONSTRAINT R_hasRelatedAuthority__relationshipId__key IF NOT EXISTS
FOR ()-[r:HAS_RELATED_AUTHORITY]->()
REQUIRE r.relationshipId IS REL KEY;

CREATE CONSTRAINT R_hasRelatedAuthority__createdTimestamp__type IF NOT EXISTS
FOR ()-[r:HAS_RELATED_AUTHORITY]->()
REQUIRE r.createdTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_hasRelatedAuthority__createdTimestamp__reqd IF NOT EXISTS
FOR ()-[r:HAS_RELATED_AUTHORITY]->()
REQUIRE r.createdTimestamp IS NOT NULL;

CREATE CONSTRAINT R_hasRelatedAuthority__updatedTimestamp__type IF NOT EXISTS
FOR ()-[r:HAS_RELATED_AUTHORITY]->()
REQUIRE r.updatedTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_hasRelatedAuthority__updatedTimestamp__reqd IF NOT EXISTS
FOR ()-[r:HAS_RELATED_AUTHORITY]->()
REQUIRE r.updatedTimestamp IS NOT NULL;

CREATE CONSTRAINT R_hasRelatedAuthority__authoritySection__type IF NOT EXISTS
FOR ()-[r:HAS_RELATED_AUTHORITY]->()
REQUIRE r.authoritySection IS :: LIST<STRING NOT NULL>;

CREATE CONSTRAINT R_hasRelatedAuthority__notes__type IF NOT EXISTS
FOR ()-[r:HAS_RELATED_AUTHORITY]->()
REQUIRE r.notes IS :: LIST<STRING NOT NULL>;


/***/


CREATE CONSTRAINT R_draftedBy__relationshipId__type IF NOT EXISTS
FOR ()-[r:DRAFTED_BY]->()
REQUIRE r.relationshipId IS :: STRING;

CREATE CONSTRAINT R_draftedBy__relationshipId__key IF NOT EXISTS
FOR ()-[r:DRAFTED_BY]->()
REQUIRE r.relationshipId IS REL KEY;

CREATE CONSTRAINT R_draftedBy__createdTimestamp__type IF NOT EXISTS
FOR ()-[r:DRAFTED_BY]->()
REQUIRE r.createdTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_draftedBy__createdTimestamp__reqd IF NOT EXISTS
FOR ()-[r:DRAFTED_BY]->()
REQUIRE r.createdTimestamp IS NOT NULL;

CREATE CONSTRAINT R_draftedBy__updatedTimestamp__type IF NOT EXISTS
FOR ()-[r:DRAFTED_BY]->()
REQUIRE r.updatedTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_draftedBy__updatedTimestamp__reqd IF NOT EXISTS
FOR ()-[r:DRAFTED_BY]->()
REQUIRE r.updatedTimestamp IS NOT NULL;


CREATE CONSTRAINT R_hasRevision__relationshipId__type IF NOT EXISTS
FOR ()-[r:HAS_REVISION]->()
REQUIRE r.relationshipId IS :: STRING;

CREATE CONSTRAINT R_hasRevision__relationshipId__key IF NOT EXISTS
FOR ()-[r:HAS_REVISION]->()
REQUIRE r.relationshipId IS REL KEY;

CREATE CONSTRAINT R_hasRevision__createdTimestamp__type IF NOT EXISTS
FOR ()-[r:HAS_REVISION]->()
REQUIRE r.createdTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_hasRevision__createdTimestamp__reqd IF NOT EXISTS
FOR ()-[r:HAS_REVISION]->()
REQUIRE r.createdTimestamp IS NOT NULL;

CREATE CONSTRAINT R_hasRevision__updatedTimestamp__type IF NOT EXISTS
FOR ()-[r:HAS_REVISION]->()
REQUIRE r.updatedTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_hasRevision__updatedTimestamp__reqd IF NOT EXISTS
FOR ()-[r:HAS_REVISION]->()
REQUIRE r.updatedTimestamp IS NOT NULL;


CREATE CONSTRAINT R_alsoPublishedAs__relationshipId__type IF NOT EXISTS
FOR ()-[r:ALSO_PUBLISHED_AS]->()
REQUIRE r.relationshipId IS :: STRING;

CREATE CONSTRAINT R_alsoPublishedAs__relationshipId__key IF NOT EXISTS
FOR ()-[r:ALSO_PUBLISHED_AS]->()
REQUIRE r.relationshipId IS REL KEY;

CREATE CONSTRAINT R_alsoPublishedAs__createdTimestamp__type IF NOT EXISTS
FOR ()-[r:ALSO_PUBLISHED_AS]->()
REQUIRE r.createdTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_alsoPublishedAs__createdTimestamp__reqd IF NOT EXISTS
FOR ()-[r:ALSO_PUBLISHED_AS]->()
REQUIRE r.createdTimestamp IS NOT NULL;

CREATE CONSTRAINT R_alsoPublishedAs__updatedTimestamp__type IF NOT EXISTS
FOR ()-[r:ALSO_PUBLISHED_AS]->()
REQUIRE r.updatedTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_alsoPublishedAs__updatedTimestamp__reqd IF NOT EXISTS
FOR ()-[r:ALSO_PUBLISHED_AS]->()
REQUIRE r.updatedTimestamp IS NOT NULL;

/* Load Relationship Data *****************************************************/

LOAD CSV WITH HEADERS FROM $relationshipDataUrl AS row
MATCH (
  source:${row.sourceNodeType} {
    ${row.sourceNodeAttr}: lower(trim(row.sourceNodeValue))
  }
)
MATCH (
  target:${row.targetNodeType} {
    ${row.targetNodeAttr}: lower(trim(row.targetNodeValue))
  }
)
CALL (*) {
  WHEN row.relationshipType = 'HAS_CHILD_ORG' THEN {
    MERGE (source)-[r:HAS_CHILD_ORG {relationshipId: coalesce(lower(trim(row.relationshipId)), randomUUID())}]->(target)
      ON CREATE
        SET
        // Metadata Fields             Definition
          r.createdTimestamp        = coalesce(
                                        datetime(trim(row.createdTimestamp)),
                                        datetime()
                                      )
          , r.updatedTimestamp      = coalesce(
                                        datetime(trim(row.updatedTimestamp)),
                                        datetime()
                                      )
        // Informational Fields        Definition
          , r.notes                 = [x IN split(nullIf(trim(row.notes), ''), '||') | trim(x)]
  }
  WHEN row.relationshipType = 'HAS_AFFILIATE_ORG' THEN {
    MERGE (source)-[r:HAS_AFFILIATE_ORG {relationshipId: coalesce(lower(trim(row.relationshipId)), randomUUID())}]->(target)
      ON CREATE
        SET
        // Metadata Fields             Definition
          r.createdTimestamp        = coalesce(
                                        datetime(trim(row.createdTimestamp)),
                                        datetime()
                                      )
          , r.updatedTimestamp      = coalesce(
                                        datetime(trim(row.updatedTimestamp)),
                                        datetime()
                                      )
        // Informational Fields        Definition
          , r.affiliation           = coalesce(
                                        lower(trim(row.affiliation)),
                                        'unknown'
                                      )
          , r.notes                 = [x IN split(nullIf(trim(row.notes), ''), '||') | trim(x)]
  }
  WHEN row.relationshipType = 'PREVIOUSLY_KNOWN_AS' THEN {
    MERGE (source)-[r:PREVIOUSLY_KNOWN_AS {relationshipId: coalesce(lower(trim(row.relationshipId)), randomUUID())}]->(target)
      ON CREATE
        SET
        // Metadata Fields             Definition
          r.createdTimestamp        = coalesce(
                                        datetime(trim(row.createdTimestamp)),
                                        datetime()
                                      )
          , r.updatedTimestamp      = coalesce(
                                        datetime(trim(row.updatedTimestamp)),
                                        datetime()
                                      )
        // Informational Fields        Definition
          , r.notes                 = [x IN split(nullIf(trim(row.notes), ''), '||') | trim(x)]
  }
  WHEN row.relationshipType = 'SUCCEEDED_ORG' THEN {
    MERGE (source)-[r:SUCCEEDED_ORG {relationshipId: coalesce(lower(trim(row.relationshipId)), randomUUID())}]->(target)
      ON CREATE
        SET
        // Metadata Fields             Definition
          r.createdTimestamp        = coalesce(
                                        datetime(trim(row.createdTimestamp)),
                                        datetime()
                                      )
          , r.updatedTimestamp      = coalesce(
                                        datetime(trim(row.updatedTimestamp)),
                                        datetime()
                                      )
        // Informational Fields        Definition
          , r.notes                 = [x IN split(nullIf(trim(row.notes), ''), '||') | trim(x)]
  }
  WHEN row.relationshipType = 'CONTROLS' THEN {
    MERGE (source)-[r:CONTROLS {relationshipId: coalesce(lower(trim(row.relationshipId)), randomUUID())}]->(target)
      ON CREATE
        SET
        // Metadata Fields             Definition
          r.createdTimestamp        = coalesce(
                                        datetime(trim(row.createdTimestamp)),
                                        datetime()
                                      )
          , r.updatedTimestamp      = coalesce(
                                        datetime(trim(row.updatedTimestamp)),
                                        datetime()
                                      )
        // Informational Fields        Definition
          , r.notes                 = [x IN split(nullIf(trim(row.notes), ''), '||') | trim(x)]
  }
  WHEN row.relationshipType = 'REFERENCES' THEN {
    MERGE (source)-[r:REFERENCES {relationshipId: coalesce(lower(trim(row.relationshipId)), randomUUID())}]->(target)
      ON CREATE
        SET
        // Metadata Fields             Definition
          r.createdTimestamp        = coalesce(
                                        datetime(trim(row.createdTimestamp)),
                                        datetime()
                                      )
          , r.updatedTimestamp      = coalesce(
                                        datetime(trim(row.updatedTimestamp)),
                                        datetime()
                                      )
        // Informational Fields        Definition
          , r.referenceType         = coalesce(
                                        lower(trim(row.referenceType)),
                                        'unknown'
                                      )
          , r.notes                 = [x IN split(nullIf(trim(row.notes), ''), '||') | trim(x)]
  }
  WHEN row.relationshipType = 'UPDATES' THEN {
    MERGE (source)-[r:UPDATES {relationshipId: coalesce(lower(trim(row.relationshipId)), randomUUID())}]->(target)
      ON CREATE
        SET
        // Metadata Fields             Definition
          r.createdTimestamp        = coalesce(
                                        datetime(trim(row.createdTimestamp)),
                                        datetime()
                                      )
          , r.updatedTimestamp      = coalesce(
                                        datetime(trim(row.updatedTimestamp)),
                                        datetime()
                                      )
        // Informational Fields        Definition
          , r.notes                 = [x IN split(nullIf(trim(row.notes), ''), '||') | trim(x)]
  }
  WHEN row.relationshipType = 'EXTENDS' THEN {
    MERGE (source)-[r:EXTENDS {relationshipId: coalesce(lower(trim(row.relationshipId)), randomUUID())}]->(target)
      ON CREATE
        SET
        // Metadata Fields             Definition
          r.createdTimestamp        = coalesce(
                                        datetime(trim(row.createdTimestamp)),
                                        datetime()
                                      )
          , r.updatedTimestamp      = coalesce(
                                        datetime(trim(row.updatedTimestamp)),
                                        datetime()
                                      )
        // Informational Fields        Definition
          , r.notes                 = [x IN split(nullIf(trim(row.notes), ''), '||') | trim(x)]
  }
  WHEN row.relationshipType = 'OBSOLETES' THEN {
    MERGE (source)-[r:OBSOLETES {relationshipId: coalesce(lower(trim(row.relationshipId)), randomUUID())}]->(target)
      ON CREATE
        SET
        // Metadata Fields             Definition
          r.createdTimestamp        = coalesce(
                                        datetime(trim(row.createdTimestamp)),
                                        datetime()
                                      )
          , r.updatedTimestamp      = coalesce(
                                        datetime(trim(row.updatedTimestamp)),
                                        datetime()
                                      )
        // Informational Fields        Definition
          , r.notes                 = [x IN split(nullIf(trim(row.notes), ''), '||') | trim(x)]
  }
  WHEN row.relationshipType = 'CONTAINS' THEN {
    MERGE (source)-[r:CONTAINS {relationshipId: coalesce(lower(trim(row.relationshipId)), randomUUID())}]->(target)
      ON CREATE
        SET
        // Metadata Fields             Definition
          r.createdTimestamp        = coalesce(
                                        datetime(trim(row.createdTimestamp)),
                                        datetime()
                                      )
          , r.updatedTimestamp      = coalesce(
                                        datetime(trim(row.updatedTimestamp)),
                                        datetime()
                                      )
        // Informational Fields        Definition
          , r.authoritySection      = [x IN split(nullIf(trim(row.authoritySection), ''), ';') | trim(x)]
          , r.notes                 = [x IN split(nullIf(trim(row.notes), ''), '||') | trim(x)]
  }
  WHEN row.relationshipType = 'HAS_RELATED_AUTHORITY' THEN {
    MERGE (source)-[r:HAS_RELATED_AUTHORITY {relationshipId: coalesce(lower(trim(row.relationshipId)), randomUUID())}]->(target)
      ON CREATE
        SET
        // Metadata Fields             Definition
          r.createdTimestamp        = coalesce(
                                        datetime(trim(row.createdTimestamp)),
                                        datetime()
                                      )
          , r.updatedTimestamp      = coalesce(
                                        datetime(trim(row.updatedTimestamp)),
                                        datetime()
                                      )
        // Informational Fields        Definition
          , r.relationship          = coalesce(
                                        [x IN split(row.relationship, ';') | lower(trim(x))], 
                                        ['unknown']
                                      )
          , r.notes                 = [x IN split(nullIf(trim(row.notes), ''), '||') | trim(x)]
  }


/**/
  WHEN row.relationshipType = 'DRAFTED_BY' THEN {
    MERGE (source)-[r:DRAFTED_BY {relationshipId: coalesce(lower(trim(row.relationshipId)), randomUUID())}]->(target)
      ON CREATE
        SET
          r.createdTimestamp        = coalesce(
                                        datetime(trim(row.createdTimestamp)),
                                        datetime()
                                      ),
          r.updatedTimestamp        = coalesce(
                                        datetime(trim(row.updatedTimestamp)),
                                        datetime()
                                      )
  }
  WHEN row.relationshipType = 'HAS_REVISION' THEN {
    MERGE (source)-[r:HAS_REVISION {relationshipId: coalesce(lower(trim(row.relationshipId)), randomUUID())}]->(target)
      ON CREATE
        SET
          r.createdTimestamp        = coalesce(
                                        datetime(trim(row.createdTimestamp)),
                                        datetime()
                                      ),
          r.updatedTimestamp        = coalesce(
                                        datetime(trim(row.updatedTimestamp)),
                                        datetime()
                                      )
  }
  WHEN row.relationshipType = 'ALSO_PUBLISHED_AS' THEN {
    MERGE (source)-[r:ALSO_PUBLISHED_AS {relationshipId: coalesce(lower(trim(row.relationshipId)), randomUUID())}]->(target)
      ON CREATE
        SET
          r.createdTimestamp        = coalesce(
                                        datetime(trim(row.createdTimestamp)),
                                        datetime()
                                      ),
          r.updatedTimestamp        = coalesce(
                                        datetime(trim(row.updatedTimestamp)),
                                        datetime()
                                      )
  }
}
RETURN
  'Loaded Relationship Data';
