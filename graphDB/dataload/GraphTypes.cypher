/*******************************************************************************
*
* GraphTypes.cypher
*
* Configures all graph type constraints for the SpecAtlas data model.
* Run this script before any data load scripts.
*
* Execution order: 1 of 8
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
*   url                   STRING
*   organizationType      STRING                                NOT NULL
*   status                LIST<STRING NOT NULL>                 NOT NULL
*   displayGroup          BOOLEAN
*   startDate             DATE
*   endDate               DATE
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

CREATE CONSTRAINT ControllingOrg__url__type IF NOT EXISTS
FOR (co:ControllingOrg)
REQUIRE co.url IS :: STRING;

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

CREATE CONSTRAINT ControllingOrg__displayGroup__type IF NOT EXISTS
FOR (co:ControllingOrg)
REQUIRE co.displayGroup IS :: BOOLEAN;

CREATE CONSTRAINT ControllingOrg__startDate__type IF NOT EXISTS
FOR (co:ControllingOrg)
REQUIRE co.startDate IS :: DATE;

CREATE CONSTRAINT ControllingOrg__endDate__type IF NOT EXISTS
FOR (co:ControllingOrg)
REQUIRE co.endDate IS :: DATE;

CREATE CONSTRAINT ControllingOrg__notes__type IF NOT EXISTS
FOR (co:ControllingOrg)
REQUIRE co.notes IS :: LIST<STRING NOT NULL>;


/* NODE: Authority *************************************************************
*
*   Property Name         Type                                  Constraints
*   --------------------  ------------------------------------  ----------------
*   authorityId           STRING                                NODE KEY
*   createdTimestamp      ZONED DATETIME                        NOT NULL
*   updatedTimestamp      ZONED DATETIME                        NOT NULL
*
*   atlasCategory         LIST<STRING NOT NULL>
*   atlasStatus           LIST<STRING NOT NULL>                 NOT NULL
*
*   reference             STRING                                UNIQUE
*   versionTag            STRING
*   title                 STRING                                NOT NULL
*   status                LIST<STRING NOT NULL>                 NOT NULL
*   type                  STRING
*   ietfStream            STRING
*   publishedDate         DATE
*   deprecatedDate        DATE
*   withdrawnDate         DATE
*   canonicalUrl          STRING
*   canonicalFormat       STRING
*   plainTextUrl          STRING
*   htmlUrl               STRING
*   otherUrl              STRING
*   otherFormat           STRING
*   doi                   STRING
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


CREATE CONSTRAINT Authority__atlasCategory__type IF NOT EXISTS
FOR (a:Authority)
REQUIRE a.atlasCategory IS :: LIST<STRING NOT NULL>;

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

CREATE CONSTRAINT Authority__ietfStream__type IF NOT EXISTS
FOR (a:Authority)
REQUIRE a.ietfStream IS :: STRING;

CREATE CONSTRAINT Authority__publishedDate__type IF NOT EXISTS
FOR (a:Authority)
REQUIRE a.publishedDate IS :: DATE;

CREATE CONSTRAINT Authority__deprecatedDate__type IF NOT EXISTS
FOR (a:Authority)
REQUIRE a.deprecatedDate IS :: DATE;

CREATE CONSTRAINT Authority__withdrawnDate__type IF NOT EXISTS
FOR (a:Authority)
REQUIRE a.withdrawnDate IS :: DATE;

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

CREATE CONSTRAINT Authority__doi__type IF NOT EXISTS
FOR (a:Authority)
REQUIRE a.doi IS :: STRING;

CREATE CONSTRAINT Authority__notes__type IF NOT EXISTS
FOR (a:Authority)
REQUIRE a.notes IS :: LIST<STRING NOT NULL>;


/* NODE: AuthorityGroup ********************************************************
*
*   Property Name         Type                                  Constraints
*   --------------------  ------------------------------------  ----------------
*   authorityGroupId      STRING                                NODE KEY
*   createdTimestamp      ZONED DATETIME                        NOT NULL
*   updatedTimestamp      ZONED DATETIME                        NOT NULL
*
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
REQUIRE ag.url IS :: STRING;

CREATE CONSTRAINT AuthorityGroup__notes__type IF NOT EXISTS
FOR (ag:AuthorityGroup)
REQUIRE ag.notes IS :: LIST<STRING NOT NULL>;


/* NODE: AuthorityDraft ********************************************************
*
*   Property Name         Type                                  Constraints
*   --------------------  ------------------------------------  ----------------
*   authorityDraftId      STRING                                NODE KEY
*   createdTimestamp      ZONED DATETIME                        NOT NULL
*   updatedTimestamp      ZONED DATETIME                        NOT NULL
*
*   atlasCategory         LIST<STRING NOT NULL>
*   atlasStatus           LIST<STRING NOT NULL>                 NOT NULL
*
*   reference             STRING                                UNIQUE
*   title                 STRING                                NOT NULL
*   status                LIST<STRING NOT NULL>                 NOT NULL
*   type                  STRING
*   notes                 LIST<STRING NOT NULL>
*
*******************************************************************************/

CREATE CONSTRAINT AuthorityDraft__authorityDraftId__type IF NOT EXISTS
FOR (ad:AuthorityDraft)
REQUIRE ad.authorityDraftId IS :: STRING;

CREATE CONSTRAINT AuthorityDraft__authorityDraftId__key IF NOT EXISTS
FOR (ad:AuthorityDraft)
REQUIRE ad.authorityDraftId IS NODE KEY;

CREATE CONSTRAINT AuthorityDraft__createdTimestamp__type IF NOT EXISTS
FOR (ad:AuthorityDraft)
REQUIRE ad.createdTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT AuthorityDraft__createdTimestamp__reqd IF NOT EXISTS
FOR (ad:AuthorityDraft)
REQUIRE ad.createdTimestamp IS NOT NULL;

CREATE CONSTRAINT AuthorityDraft__updatedTimestamp__type IF NOT EXISTS
FOR (ad:AuthorityDraft)
REQUIRE ad.updatedTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT AuthorityDraft__updatedTimestamp__reqd IF NOT EXISTS
FOR (ad:AuthorityDraft)
REQUIRE ad.updatedTimestamp IS NOT NULL;


CREATE CONSTRAINT AuthorityDraft__atlasCategory__type IF NOT EXISTS
FOR (ad:AuthorityDraft)
REQUIRE ad.atlasCategory IS :: LIST<STRING NOT NULL>;

CREATE CONSTRAINT AuthorityDraft__atlasStatus__type IF NOT EXISTS
FOR (ad:AuthorityDraft)
REQUIRE ad.atlasStatus IS :: LIST<STRING NOT NULL>;

CREATE CONSTRAINT AuthorityDraft__atlasStatus__reqd IF NOT EXISTS
FOR (ad:AuthorityDraft)
REQUIRE ad.atlasStatus IS NOT NULL;


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

CREATE CONSTRAINT AuthorityDraft__notes__type IF NOT EXISTS
FOR (ad:AuthorityDraft)
REQUIRE ad.notes IS :: LIST<STRING NOT NULL>;


/* NODE: AuthorityDraftRevision ************************************************
*
*   Property Name              Type                             Constraints
*   -------------------------  -------------------------------  ----------------
*   authorityDraftRevisionId  STRING                            NODE KEY
*   createdTimestamp          ZONED DATETIME                    NOT NULL
*   updatedTimestamp          ZONED DATETIME                    NOT NULL
*
*   atlasCategory             LIST<STRING NOT NULL>
*   atlasStatus               LIST<STRING NOT NULL>             NOT NULL
*
*   reference                 STRING                            UNIQUE
*   revisionSequence          INTEGER                           NOT NULL
*   title                     STRING                            NOT NULL
*   status                    LIST<STRING NOT NULL>             NOT NULL
*   type                      STRING
*   ietfStream                STRING
*   publishedDate             DATE
*   canonicalUrl              STRING
*   canonicalFormat           STRING
*   plainTextUrl              STRING
*   htmlUrl                   STRING
*   otherUrl                  STRING
*   otherFormat               STRING
*   notes                     LIST<STRING NOT NULL>
*
*******************************************************************************/

CREATE CONSTRAINT AuthorityDraftRevision__authorityDraftRevisionId__type IF NOT EXISTS
FOR (adr:AuthorityDraftRevision)
REQUIRE adr.authorityDraftRevisionId IS :: STRING;

CREATE CONSTRAINT AuthorityDraftRevision__authorityDraftRevisionId__key IF NOT EXISTS
FOR (adr:AuthorityDraftRevision)
REQUIRE adr.authorityDraftRevisionId IS NODE KEY;

CREATE CONSTRAINT AuthorityDraftRevision__createdTimestamp__type IF NOT EXISTS
FOR (adr:AuthorityDraftRevision)
REQUIRE adr.createdTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT AuthorityDraftRevision__createdTimestamp__reqd IF NOT EXISTS
FOR (adr:AuthorityDraftRevision)
REQUIRE adr.createdTimestamp IS NOT NULL;

CREATE CONSTRAINT AuthorityDraftRevision__updatedTimestamp__type IF NOT EXISTS
FOR (adr:AuthorityDraftRevision)
REQUIRE adr.updatedTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT AuthorityDraftRevision__updatedTimestamp__reqd IF NOT EXISTS
FOR (adr:AuthorityDraftRevision)
REQUIRE adr.updatedTimestamp IS NOT NULL;


CREATE CONSTRAINT AuthorityDraftRevision__atlasCategory__type IF NOT EXISTS
FOR (adr:AuthorityDraftRevision)
REQUIRE adr.atlasCategory IS :: LIST<STRING NOT NULL>;

CREATE CONSTRAINT AuthorityDraftRevision__atlasStatus__type IF NOT EXISTS
FOR (adr:AuthorityDraftRevision)
REQUIRE adr.atlasStatus IS :: LIST<STRING NOT NULL>;

CREATE CONSTRAINT AuthorityDraftRevision__atlasStatus__reqd IF NOT EXISTS
FOR (adr:AuthorityDraftRevision)
REQUIRE adr.atlasStatus IS NOT NULL;


CREATE CONSTRAINT AuthorityDraftRevision__reference__type IF NOT EXISTS
FOR (adr:AuthorityDraftRevision)
REQUIRE adr.reference IS :: STRING;

CREATE CONSTRAINT AuthorityDraftRevision__reference__unique IF NOT EXISTS
FOR (adr:AuthorityDraftRevision)
REQUIRE adr.reference IS UNIQUE;

CREATE CONSTRAINT AuthorityDraftRevision__revisionSequence__type IF NOT EXISTS
FOR (adr:AuthorityDraftRevision)
REQUIRE adr.revisionSequence IS :: INTEGER;

CREATE CONSTRAINT AuthorityDraftRevision__revisionSequence__reqd IF NOT EXISTS
FOR (adr:AuthorityDraftRevision)
REQUIRE adr.revisionSequence IS NOT NULL;

CREATE CONSTRAINT AuthorityDraftRevision__title__type IF NOT EXISTS
FOR (adr:AuthorityDraftRevision)
REQUIRE adr.title IS :: STRING;

CREATE CONSTRAINT AuthorityDraftRevision__title__reqd IF NOT EXISTS
FOR (adr:AuthorityDraftRevision)
REQUIRE adr.title IS NOT NULL;

CREATE CONSTRAINT AuthorityDraftRevision__status__type IF NOT EXISTS
FOR (adr:AuthorityDraftRevision)
REQUIRE adr.status IS :: LIST<STRING NOT NULL>;

CREATE CONSTRAINT AuthorityDraftRevision__status__reqd IF NOT EXISTS
FOR (adr:AuthorityDraftRevision)
REQUIRE adr.status IS NOT NULL;

CREATE CONSTRAINT AuthorityDraftRevision__type__type IF NOT EXISTS
FOR (adr:AuthorityDraftRevision)
REQUIRE adr.type IS :: STRING;

CREATE CONSTRAINT AuthorityDraftRevision__ietfStream__type IF NOT EXISTS
FOR (adr:AuthorityDraftRevision)
REQUIRE adr.ietfStream IS :: STRING;

CREATE CONSTRAINT AuthorityDraftRevision__publishedDate__type IF NOT EXISTS
FOR (adr:AuthorityDraftRevision)
REQUIRE adr.publishedDate IS :: DATE;

CREATE CONSTRAINT AuthorityDraftRevision__canonicalUrl__type IF NOT EXISTS
FOR (adr:AuthorityDraftRevision)
REQUIRE adr.canonicalUrl IS :: STRING;

CREATE CONSTRAINT AuthorityDraftRevision__canonicalFormat__type IF NOT EXISTS
FOR (adr:AuthorityDraftRevision)
REQUIRE adr.canonicalFormat IS :: STRING;

CREATE CONSTRAINT AuthorityDraftRevision__plainTextUrl__type IF NOT EXISTS
FOR (adr:AuthorityDraftRevision)
REQUIRE adr.plainTextUrl IS :: STRING;

CREATE CONSTRAINT AuthorityDraftRevision__htmlUrl__type IF NOT EXISTS
FOR (adr:AuthorityDraftRevision)
REQUIRE adr.htmlUrl IS :: STRING;

CREATE CONSTRAINT AuthorityDraftRevision__otherUrl__type IF NOT EXISTS
FOR (adr:AuthorityDraftRevision)
REQUIRE adr.otherUrl IS :: STRING;

CREATE CONSTRAINT AuthorityDraftRevision__otherFormat__type IF NOT EXISTS
FOR (adr:AuthorityDraftRevision)
REQUIRE adr.otherFormat IS :: STRING;

CREATE CONSTRAINT AuthorityDraftRevision__notes__type IF NOT EXISTS
FOR (adr:AuthorityDraftRevision)
REQUIRE adr.notes IS :: LIST<STRING NOT NULL>;


/* NODE: Artifact **************************************************************
*
*   Property Name         Type                                  Constraints
*   --------------------  ------------------------------------  ----------------
*   artifactId            STRING                                NODE KEY
*   createdTimestamp      ZONED DATETIME                        NOT NULL
*   updatedTimestamp      ZONED DATETIME                        NOT NULL
*
*   artifactType          STRING                                NOT NULL
*   artifactSubtype       STRING
*   artifactTypeGroup     BOOLEAN
*   shortName             STRING                                UNIQUE
*   fullName              STRING                                UNIQUE
*   status                LIST<STRING NOT NULL>
*   notes                 LIST<STRING NOT NULL>
*
*******************************************************************************/

CREATE CONSTRAINT Artifact__artifactId__type IF NOT EXISTS
FOR (art:Artifact)
REQUIRE art.artifactId IS :: STRING;

CREATE CONSTRAINT Artifact__artifactId__key IF NOT EXISTS
FOR (art:Artifact)
REQUIRE art.artifactId IS NODE KEY;

CREATE CONSTRAINT Artifact__createdTimestamp__type IF NOT EXISTS
FOR (art:Artifact)
REQUIRE art.createdTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT Artifact__createdTimestamp__reqd IF NOT EXISTS
FOR (art:Artifact)
REQUIRE art.createdTimestamp IS NOT NULL;

CREATE CONSTRAINT Artifact__updatedTimestamp__type IF NOT EXISTS
FOR (art:Artifact)
REQUIRE art.updatedTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT Artifact__updatedTimestamp__reqd IF NOT EXISTS
FOR (art:Artifact)
REQUIRE art.updatedTimestamp IS NOT NULL;


CREATE CONSTRAINT Artifact__artifactType__type IF NOT EXISTS
FOR (art:Artifact)
REQUIRE art.artifactType IS :: STRING;

CREATE CONSTRAINT Artifact__artifactType__reqd IF NOT EXISTS
FOR (art:Artifact)
REQUIRE art.artifactType IS NOT NULL;

CREATE CONSTRAINT Artifact__artifactSubtype__type IF NOT EXISTS
FOR (art:Artifact)
REQUIRE art.artifactSubtype IS :: STRING;

CREATE CONSTRAINT Artifact__artifactTypeGroup__type IF NOT EXISTS
FOR (art:Artifact)
REQUIRE art.artifactTypeGroup IS :: BOOLEAN;

CREATE CONSTRAINT Artifact__shortName__type IF NOT EXISTS
FOR (art:Artifact)
REQUIRE art.shortName IS :: STRING;

CREATE CONSTRAINT Artifact__shortName__unique IF NOT EXISTS
FOR (art:Artifact)
REQUIRE art.shortName IS UNIQUE;

CREATE CONSTRAINT Artifact__fullName__type IF NOT EXISTS
FOR (art:Artifact)
REQUIRE art.fullName IS :: STRING;

CREATE CONSTRAINT Artifact__fullName__unique IF NOT EXISTS
FOR (art:Artifact)
REQUIRE art.fullName IS UNIQUE;

CREATE CONSTRAINT Artifact__status__type IF NOT EXISTS
FOR (art:Artifact)
REQUIRE art.status IS :: LIST<STRING NOT NULL>;

CREATE CONSTRAINT Artifact__notes__type IF NOT EXISTS
FOR (art:Artifact)
REQUIRE art.notes IS :: LIST<STRING NOT NULL>;


/* RELATIONSHIP: HAS_CHILD_ORG *************************************************
*
*   Property Name         Type                                  Constraints
*   --------------------  ------------------------------------  ----------------
*   relationshipId        STRING                                REL KEY
*   createdTimestamp      ZONED DATETIME                        NOT NULL
*   updatedTimestamp      ZONED DATETIME                        NOT NULL
*
*   notes                 LIST<STRING NOT NULL>
*
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


/* RELATIONSHIP: PREVIOUSLY_KNOWN_AS *******************************************
*
*   Property Name         Type                                  Constraints
*   --------------------  ------------------------------------  ----------------
*   relationshipId        STRING                                REL KEY
*   createdTimestamp      ZONED DATETIME                        NOT NULL
*   updatedTimestamp      ZONED DATETIME                        NOT NULL
*
*   notes                 LIST<STRING NOT NULL>
*
*******************************************************************************/

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


/* RELATIONSHIP: SUCCEEDED_ORG *************************************************
*
*   Property Name         Type                                  Constraints
*   --------------------  ------------------------------------  ----------------
*   relationshipId        STRING                                REL KEY
*   createdTimestamp      ZONED DATETIME                        NOT NULL
*   updatedTimestamp      ZONED DATETIME                        NOT NULL
*
*   notes                 LIST<STRING NOT NULL>
*
*******************************************************************************/

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


/* RELATIONSHIP: HAS_AFFILIATE_ORG *********************************************
*
*   Property Name         Type                                  Constraints
*   --------------------  ------------------------------------  ----------------
*   relationshipId        STRING                                REL KEY
*   createdTimestamp      ZONED DATETIME                        NOT NULL
*   updatedTimestamp      ZONED DATETIME                        NOT NULL
*
*   affiliation           STRING                                NOT NULL
*   notes                 LIST<STRING NOT NULL>
*
*******************************************************************************/

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
REQUIRE r.affiliation IS :: STRING;

CREATE CONSTRAINT R_hasAffiliateOrg__affiliation__reqd IF NOT EXISTS
FOR ()-[r:HAS_AFFILIATE_ORG]->()
REQUIRE r.affiliation IS NOT NULL;

CREATE CONSTRAINT R_hasAffiliateOrg__notes__type IF NOT EXISTS
FOR ()-[r:HAS_AFFILIATE_ORG]->()
REQUIRE r.notes IS :: LIST<STRING NOT NULL>;


/* RELATIONSHIP: CONTROLS ******************************************************
*
*   Property Name         Type                                  Constraints
*   --------------------  ------------------------------------  ----------------
*   relationshipId        STRING                                REL KEY
*   createdTimestamp      ZONED DATETIME                        NOT NULL
*   updatedTimestamp      ZONED DATETIME                        NOT NULL
*
*   notes                 LIST<STRING NOT NULL>
*
*******************************************************************************/

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


/* RELATIONSHIP: MEMBER_OF *****************************************************
*
*   Property Name         Type                                  Constraints
*   --------------------  ------------------------------------  ----------------
*   relationshipId        STRING                                REL KEY
*   createdTimestamp      ZONED DATETIME                        NOT NULL
*   updatedTimestamp      ZONED DATETIME                        NOT NULL
*
*   notes                 LIST<STRING NOT NULL>
*
*******************************************************************************/

CREATE CONSTRAINT R_memberOf__relationshipId__type IF NOT EXISTS
FOR ()-[r:MEMBER_OF]->()
REQUIRE r.relationshipId IS :: STRING;

CREATE CONSTRAINT R_memberOf__relationshipId__key IF NOT EXISTS
FOR ()-[r:MEMBER_OF]->()
REQUIRE r.relationshipId IS REL KEY;

CREATE CONSTRAINT R_memberOf__createdTimestamp__type IF NOT EXISTS
FOR ()-[r:MEMBER_OF]->()
REQUIRE r.createdTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_memberOf__createdTimestamp__reqd IF NOT EXISTS
FOR ()-[r:MEMBER_OF]->()
REQUIRE r.createdTimestamp IS NOT NULL;

CREATE CONSTRAINT R_memberOf__updatedTimestamp__type IF NOT EXISTS
FOR ()-[r:MEMBER_OF]->()
REQUIRE r.updatedTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_memberOf__updatedTimestamp__reqd IF NOT EXISTS
FOR ()-[r:MEMBER_OF]->()
REQUIRE r.updatedTimestamp IS NOT NULL;


CREATE CONSTRAINT R_memberOf__notes__type IF NOT EXISTS
FOR ()-[r:MEMBER_OF]->()
REQUIRE r.notes IS :: LIST<STRING NOT NULL>;


/* RELATIONSHIP: UPDATES *******************************************************
*
*   Property Name         Type                                  Constraints
*   --------------------  ------------------------------------  ----------------
*   relationshipId        STRING                                REL KEY
*   createdTimestamp      ZONED DATETIME                        NOT NULL
*   updatedTimestamp      ZONED DATETIME                        NOT NULL
*
*   notes                 LIST<STRING NOT NULL>
*
*******************************************************************************/

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


/* RELATIONSHIP: CORRECTS ******************************************************
*
*   Property Name         Type                                  Constraints
*   --------------------  ------------------------------------  ----------------
*   relationshipId        STRING                                REL KEY
*   createdTimestamp      ZONED DATETIME                        NOT NULL
*   updatedTimestamp      ZONED DATETIME                        NOT NULL
*
*   notes                 LIST<STRING NOT NULL>
*
*******************************************************************************/

CREATE CONSTRAINT R_corrects__relationshipId__type IF NOT EXISTS
FOR ()-[r:CORRECTS]->()
REQUIRE r.relationshipId IS :: STRING;

CREATE CONSTRAINT R_corrects__relationshipId__key IF NOT EXISTS
FOR ()-[r:CORRECTS]->()
REQUIRE r.relationshipId IS REL KEY;

CREATE CONSTRAINT R_corrects__createdTimestamp__type IF NOT EXISTS
FOR ()-[r:CORRECTS]->()
REQUIRE r.createdTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_corrects__createdTimestamp__reqd IF NOT EXISTS
FOR ()-[r:CORRECTS]->()
REQUIRE r.createdTimestamp IS NOT NULL;

CREATE CONSTRAINT R_corrects__updatedTimestamp__type IF NOT EXISTS
FOR ()-[r:CORRECTS]->()
REQUIRE r.updatedTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_corrects__updatedTimestamp__reqd IF NOT EXISTS
FOR ()-[r:CORRECTS]->()
REQUIRE r.updatedTimestamp IS NOT NULL;


CREATE CONSTRAINT R_corrects__notes__type IF NOT EXISTS
FOR ()-[r:CORRECTS]->()
REQUIRE r.notes IS :: LIST<STRING NOT NULL>;


/* RELATIONSHIP: SUPERSEDES ****************************************************
*
*   Property Name           Type                                Constraints
*   --------------------    ----------------------------------  --------------
*   relationshipId          STRING                              REL KEY
*   createdTimestamp        ZONED DATETIME                      NOT NULL
*   updatedTimestamp        ZONED DATETIME                      NOT NULL
*
*   sourceAuthoritySection  LIST<STRING NOT NULL>
*   targetAuthoritySection  LIST<STRING NOT NULL>
*   notes                   LIST<STRING NOT NULL>
*
*******************************************************************************/

CREATE CONSTRAINT R_supersedes__relationshipId__type IF NOT EXISTS
FOR ()-[r:SUPERSEDES]->()
REQUIRE r.relationshipId IS :: STRING;

CREATE CONSTRAINT R_supersedes__relationshipId__key IF NOT EXISTS
FOR ()-[r:SUPERSEDES]->()
REQUIRE r.relationshipId IS REL KEY;

CREATE CONSTRAINT R_supersedes__createdTimestamp__type IF NOT EXISTS
FOR ()-[r:SUPERSEDES]->()
REQUIRE r.createdTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_supersedes__createdTimestamp__reqd IF NOT EXISTS
FOR ()-[r:SUPERSEDES]->()
REQUIRE r.createdTimestamp IS NOT NULL;

CREATE CONSTRAINT R_supersedes__updatedTimestamp__type IF NOT EXISTS
FOR ()-[r:SUPERSEDES]->()
REQUIRE r.updatedTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_supersedes__updatedTimestamp__reqd IF NOT EXISTS
FOR ()-[r:SUPERSEDES]->()
REQUIRE r.updatedTimestamp IS NOT NULL;


CREATE CONSTRAINT R_supersedes__sourceAuthoritySection__type IF NOT EXISTS
FOR ()-[r:SUPERSEDES]->()
REQUIRE r.sourceAuthoritySection IS :: LIST<STRING NOT NULL>;

CREATE CONSTRAINT R_supersedes__targetAuthoritySection__type IF NOT EXISTS
FOR ()-[r:SUPERSEDES]->()
REQUIRE r.targetAuthoritySection IS :: LIST<STRING NOT NULL>;

CREATE CONSTRAINT R_supersedes__notes__type IF NOT EXISTS
FOR ()-[r:SUPERSEDES]->()
REQUIRE r.notes IS :: LIST<STRING NOT NULL>;


/* RELATIONSHIP: OBSOLETES *****************************************************
*
*   Property Name           Type                                Constraints
*   --------------------    ----------------------------------  --------------
*   relationshipId          STRING                              REL KEY
*   createdTimestamp        ZONED DATETIME                      NOT NULL
*   updatedTimestamp        ZONED DATETIME                      NOT NULL
*
*   sourceAuthoritySection  LIST<STRING NOT NULL>
*   targetAuthoritySection  LIST<STRING NOT NULL>
*   notes                   LIST<STRING NOT NULL>
*
*******************************************************************************/

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


CREATE CONSTRAINT R_obsoletes__sourceAuthoritySection__type IF NOT EXISTS
FOR ()-[r:OBSOLETES]->()
REQUIRE r.sourceAuthoritySection IS :: LIST<STRING NOT NULL>;

CREATE CONSTRAINT R_obsoletes__targetAuthoritySection__type IF NOT EXISTS
FOR ()-[r:OBSOLETES]->()
REQUIRE r.targetAuthoritySection IS :: LIST<STRING NOT NULL>;

CREATE CONSTRAINT R_obsoletes__notes__type IF NOT EXISTS
FOR ()-[r:OBSOLETES]->()
REQUIRE r.notes IS :: LIST<STRING NOT NULL>;


/* RELATIONSHIP: DEPRECATES ****************************************************
*
*   Property Name           Type                                Constraints
*   --------------------    ----------------------------------  --------------
*   relationshipId          STRING                              REL KEY
*   createdTimestamp        ZONED DATETIME                      NOT NULL
*   updatedTimestamp        ZONED DATETIME                      NOT NULL
*
*   sourceAuthoritySection  LIST<STRING NOT NULL>
*   targetAuthoritySection  LIST<STRING NOT NULL>
*   notes                   LIST<STRING NOT NULL>
*
*******************************************************************************/

CREATE CONSTRAINT R_deprecates__relationshipId__type IF NOT EXISTS
FOR ()-[r:DEPRECATES]->()
REQUIRE r.relationshipId IS :: STRING;

CREATE CONSTRAINT R_deprecates__relationshipId__key IF NOT EXISTS
FOR ()-[r:DEPRECATES]->()
REQUIRE r.relationshipId IS REL KEY;

CREATE CONSTRAINT R_deprecates__createdTimestamp__type IF NOT EXISTS
FOR ()-[r:DEPRECATES]->()
REQUIRE r.createdTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_deprecates__createdTimestamp__reqd IF NOT EXISTS
FOR ()-[r:DEPRECATES]->()
REQUIRE r.createdTimestamp IS NOT NULL;

CREATE CONSTRAINT R_deprecates__updatedTimestamp__type IF NOT EXISTS
FOR ()-[r:DEPRECATES]->()
REQUIRE r.updatedTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_deprecates__updatedTimestamp__reqd IF NOT EXISTS
FOR ()-[r:DEPRECATES]->()
REQUIRE r.updatedTimestamp IS NOT NULL;


CREATE CONSTRAINT R_deprecates__sourceAuthoritySection__type IF NOT EXISTS
FOR ()-[r:DEPRECATES]->()
REQUIRE r.sourceAuthoritySection IS :: LIST<STRING NOT NULL>;

CREATE CONSTRAINT R_deprecates__targetAuthoritySection__type IF NOT EXISTS
FOR ()-[r:DEPRECATES]->()
REQUIRE r.targetAuthoritySection IS :: LIST<STRING NOT NULL>;

CREATE CONSTRAINT R_deprecates__notes__type IF NOT EXISTS
FOR ()-[r:DEPRECATES]->()
REQUIRE r.notes IS :: LIST<STRING NOT NULL>;


/* RELATIONSHIP: HAS_RELATED_AUTHORITY *****************************************
*
*   Property Name           Type                                Constraints
*   --------------------    ----------------------------------  --------------
*   relationshipId          STRING                              REL KEY
*   createdTimestamp        ZONED DATETIME                      NOT NULL
*   updatedTimestamp        ZONED DATETIME                      NOT NULL
*
*   relationship            STRING                              NOT NULL
*   sourceAuthoritySection  LIST<STRING NOT NULL>
*   targetAuthoritySection  LIST<STRING NOT NULL>
*   notes                   LIST<STRING NOT NULL>
*
*******************************************************************************/

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


CREATE CONSTRAINT R_hasRelatedAuthority__relationship__type IF NOT EXISTS
FOR ()-[r:HAS_RELATED_AUTHORITY]->()
REQUIRE r.relationship IS :: STRING;

CREATE CONSTRAINT R_hasRelatedAuthority__relationship__reqd IF NOT EXISTS
FOR ()-[r:HAS_RELATED_AUTHORITY]->()
REQUIRE r.relationship IS NOT NULL;

CREATE CONSTRAINT R_hasRelatedAuthority__sourceAuthoritySection__type IF NOT EXISTS
FOR ()-[r:HAS_RELATED_AUTHORITY]->()
REQUIRE r.sourceAuthoritySection IS :: LIST<STRING NOT NULL>;

CREATE CONSTRAINT R_hasRelatedAuthority__targetAuthoritySection__type IF NOT EXISTS
FOR ()-[r:HAS_RELATED_AUTHORITY]->()
REQUIRE r.targetAuthoritySection IS :: LIST<STRING NOT NULL>;

CREATE CONSTRAINT R_hasRelatedAuthority__notes__type IF NOT EXISTS
FOR ()-[r:HAS_RELATED_AUTHORITY]->()
REQUIRE r.notes IS :: LIST<STRING NOT NULL>;


/* RELATIONSHIP: REFERENCES ****************************************************
*
*   Property Name           Type                                Constraints
*   --------------------    ----------------------------------  --------------
*   relationshipId          STRING                              REL KEY
*   createdTimestamp        ZONED DATETIME                      NOT NULL
*   updatedTimestamp        ZONED DATETIME                      NOT NULL
*
*   referenceType           STRING
*   targetAuthoritySection  LIST<STRING NOT NULL>
*   notes                   LIST<STRING NOT NULL>
*
*******************************************************************************/

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

CREATE CONSTRAINT R_references__targetAuthoritySection__type IF NOT EXISTS
FOR ()-[r:REFERENCES]->()
REQUIRE r.targetAuthoritySection IS :: LIST<STRING NOT NULL>;

CREATE CONSTRAINT R_references__notes__type IF NOT EXISTS
FOR ()-[r:REFERENCES]->()
REQUIRE r.notes IS :: LIST<STRING NOT NULL>;


/* RELATIONSHIP: DRAFTED_BY ****************************************************
*
*   Property Name         Type                                  Constraints
*   --------------------  ------------------------------------  ----------------
*   relationshipId        STRING                                REL KEY
*   createdTimestamp      ZONED DATETIME                        NOT NULL
*   updatedTimestamp      ZONED DATETIME                        NOT NULL
*
*   notes                 LIST<STRING NOT NULL>
*
*******************************************************************************/

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


CREATE CONSTRAINT R_draftedBy__notes__type IF NOT EXISTS
FOR ()-[r:DRAFTED_BY]->()
REQUIRE r.notes IS :: LIST<STRING NOT NULL>;


/* RELATIONSHIP: HAS_REVISION **************************************************
*
*   Property Name         Type                                  Constraints
*   --------------------  ------------------------------------  ----------------
*   relationshipId        STRING                                REL KEY
*   createdTimestamp      ZONED DATETIME                        NOT NULL
*   updatedTimestamp      ZONED DATETIME                        NOT NULL
*
*   notes                 LIST<STRING NOT NULL>
*
*******************************************************************************/

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


CREATE CONSTRAINT R_hasRevision__notes__type IF NOT EXISTS
FOR ()-[r:HAS_REVISION]->()
REQUIRE r.notes IS :: LIST<STRING NOT NULL>;


/* RELATIONSHIP: DEFINES *******************************************************
*
*   Property Name           Type                                Constraints
*   --------------------    ----------------------------------  --------------
*   relationshipId          STRING                              REL KEY
*   createdTimestamp        ZONED DATETIME                      NOT NULL
*   updatedTimestamp        ZONED DATETIME                      NOT NULL
*
*   sourceAuthoritySection  LIST<STRING NOT NULL>
*   notes                   LIST<STRING NOT NULL>
*
*******************************************************************************/

CREATE CONSTRAINT R_defines__relationshipId__type IF NOT EXISTS
FOR ()-[r:DEFINES]->()
REQUIRE r.relationshipId IS :: STRING;

CREATE CONSTRAINT R_defines__relationshipId__key IF NOT EXISTS
FOR ()-[r:DEFINES]->()
REQUIRE r.relationshipId IS REL KEY;

CREATE CONSTRAINT R_defines__createdTimestamp__type IF NOT EXISTS
FOR ()-[r:DEFINES]->()
REQUIRE r.createdTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_defines__createdTimestamp__reqd IF NOT EXISTS
FOR ()-[r:DEFINES]->()
REQUIRE r.createdTimestamp IS NOT NULL;

CREATE CONSTRAINT R_defines__updatedTimestamp__type IF NOT EXISTS
FOR ()-[r:DEFINES]->()
REQUIRE r.updatedTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_defines__updatedTimestamp__reqd IF NOT EXISTS
FOR ()-[r:DEFINES]->()
REQUIRE r.updatedTimestamp IS NOT NULL;


CREATE CONSTRAINT R_defines__sourceAuthoritySection__type IF NOT EXISTS
FOR ()-[r:DEFINES]->()
REQUIRE r.sourceAuthoritySection IS :: LIST<STRING NOT NULL>;

CREATE CONSTRAINT R_defines__notes__type IF NOT EXISTS
FOR ()-[r:DEFINES]->()
REQUIRE r.notes IS :: LIST<STRING NOT NULL>;


/* RELATIONSHIP: PROFILES ******************************************************
*
*   Property Name         Type                                  Constraints
*   --------------------  ------------------------------------  ----------------
*   relationshipId        STRING                                REL KEY
*   createdTimestamp      ZONED DATETIME                        NOT NULL
*   updatedTimestamp      ZONED DATETIME                        NOT NULL
*
*   notes                 LIST<STRING NOT NULL>
*
*******************************************************************************/

CREATE CONSTRAINT R_profiles__relationshipId__type IF NOT EXISTS
FOR ()-[r:PROFILES]->()
REQUIRE r.relationshipId IS :: STRING;

CREATE CONSTRAINT R_profiles__relationshipId__key IF NOT EXISTS
FOR ()-[r:PROFILES]->()
REQUIRE r.relationshipId IS REL KEY;

CREATE CONSTRAINT R_profiles__createdTimestamp__type IF NOT EXISTS
FOR ()-[r:PROFILES]->()
REQUIRE r.createdTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_profiles__createdTimestamp__reqd IF NOT EXISTS
FOR ()-[r:PROFILES]->()
REQUIRE r.createdTimestamp IS NOT NULL;

CREATE CONSTRAINT R_profiles__updatedTimestamp__type IF NOT EXISTS
FOR ()-[r:PROFILES]->()
REQUIRE r.updatedTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_profiles__updatedTimestamp__reqd IF NOT EXISTS
FOR ()-[r:PROFILES]->()
REQUIRE r.updatedTimestamp IS NOT NULL;


CREATE CONSTRAINT R_profiles__notes__type IF NOT EXISTS
FOR ()-[r:PROFILES]->()
REQUIRE r.notes IS :: LIST<STRING NOT NULL>;


/* RELATIONSHIP: VERSION_OF ****************************************************
*
*   Property Name         Type                                  Constraints
*   --------------------  ------------------------------------  ----------------
*   relationshipId        STRING                                REL KEY
*   createdTimestamp      ZONED DATETIME                        NOT NULL
*   updatedTimestamp      ZONED DATETIME                        NOT NULL
*
*   notes                 LIST<STRING NOT NULL>
*
*******************************************************************************/

CREATE CONSTRAINT R_versionOf__relationshipId__type IF NOT EXISTS
FOR ()-[r:VERSION_OF]->()
REQUIRE r.relationshipId IS :: STRING;

CREATE CONSTRAINT R_versionOf__relationshipId__key IF NOT EXISTS
FOR ()-[r:VERSION_OF]->()
REQUIRE r.relationshipId IS REL KEY;

CREATE CONSTRAINT R_versionOf__createdTimestamp__type IF NOT EXISTS
FOR ()-[r:VERSION_OF]->()
REQUIRE r.createdTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_versionOf__createdTimestamp__reqd IF NOT EXISTS
FOR ()-[r:VERSION_OF]->()
REQUIRE r.createdTimestamp IS NOT NULL;

CREATE CONSTRAINT R_versionOf__updatedTimestamp__type IF NOT EXISTS
FOR ()-[r:VERSION_OF]->()
REQUIRE r.updatedTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_versionOf__updatedTimestamp__reqd IF NOT EXISTS
FOR ()-[r:VERSION_OF]->()
REQUIRE r.updatedTimestamp IS NOT NULL;


CREATE CONSTRAINT R_versionOf__notes__type IF NOT EXISTS
FOR ()-[r:VERSION_OF]->()
REQUIRE r.notes IS :: LIST<STRING NOT NULL>;


/* RELATIONSHIP: VARIANT_OF ****************************************************
*
*   Property Name         Type                                  Constraints
*   --------------------  ------------------------------------  ----------------
*   relationshipId        STRING                                REL KEY
*   createdTimestamp      ZONED DATETIME                        NOT NULL
*   updatedTimestamp      ZONED DATETIME                        NOT NULL
*
*   notes                 LIST<STRING NOT NULL>
*
*******************************************************************************/

CREATE CONSTRAINT R_variantOf__relationshipId__type IF NOT EXISTS
FOR ()-[r:VARIANT_OF]->()
REQUIRE r.relationshipId IS :: STRING;

CREATE CONSTRAINT R_variantOf__relationshipId__key IF NOT EXISTS
FOR ()-[r:VARIANT_OF]->()
REQUIRE r.relationshipId IS REL KEY;

CREATE CONSTRAINT R_variantOf__createdTimestamp__type IF NOT EXISTS
FOR ()-[r:VARIANT_OF]->()
REQUIRE r.createdTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_variantOf__createdTimestamp__reqd IF NOT EXISTS
FOR ()-[r:VARIANT_OF]->()
REQUIRE r.createdTimestamp IS NOT NULL;

CREATE CONSTRAINT R_variantOf__updatedTimestamp__type IF NOT EXISTS
FOR ()-[r:VARIANT_OF]->()
REQUIRE r.updatedTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_variantOf__updatedTimestamp__reqd IF NOT EXISTS
FOR ()-[r:VARIANT_OF]->()
REQUIRE r.updatedTimestamp IS NOT NULL;


CREATE CONSTRAINT R_variantOf__notes__type IF NOT EXISTS
FOR ()-[r:VARIANT_OF]->()
REQUIRE r.notes IS :: LIST<STRING NOT NULL>;


/* RELATIONSHIP: ADOPTED_BY ****************************************************
*
*   Property Name         Type                                  Constraints
*   --------------------  ------------------------------------  ----------------
*   relationshipId        STRING                                REL KEY
*   createdTimestamp      ZONED DATETIME                        NOT NULL
*   updatedTimestamp      ZONED DATETIME                        NOT NULL
*
*   notes                 LIST<STRING NOT NULL>
*
*******************************************************************************/

CREATE CONSTRAINT R_adoptedBy__relationshipId__type IF NOT EXISTS
FOR ()-[r:ADOPTED_BY]->()
REQUIRE r.relationshipId IS :: STRING;

CREATE CONSTRAINT R_adoptedBy__relationshipId__key IF NOT EXISTS
FOR ()-[r:ADOPTED_BY]->()
REQUIRE r.relationshipId IS REL KEY;

CREATE CONSTRAINT R_adoptedBy__createdTimestamp__type IF NOT EXISTS
FOR ()-[r:ADOPTED_BY]->()
REQUIRE r.createdTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_adoptedBy__createdTimestamp__reqd IF NOT EXISTS
FOR ()-[r:ADOPTED_BY]->()
REQUIRE r.createdTimestamp IS NOT NULL;

CREATE CONSTRAINT R_adoptedBy__updatedTimestamp__type IF NOT EXISTS
FOR ()-[r:ADOPTED_BY]->()
REQUIRE r.updatedTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_adoptedBy__updatedTimestamp__reqd IF NOT EXISTS
FOR ()-[r:ADOPTED_BY]->()
REQUIRE r.updatedTimestamp IS NOT NULL;


CREATE CONSTRAINT R_adoptedBy__notes__type IF NOT EXISTS
FOR ()-[r:ADOPTED_BY]->()
REQUIRE r.notes IS :: LIST<STRING NOT NULL>;


/* RELATIONSHIP: REVISES *******************************************************
*
*   Property Name         Type                                  Constraints
*   --------------------  ------------------------------------  ----------------
*   relationshipId        STRING                                REL KEY
*   createdTimestamp      ZONED DATETIME                        NOT NULL
*   updatedTimestamp      ZONED DATETIME                        NOT NULL
*
*   notes                 LIST<STRING NOT NULL>
*
*******************************************************************************/

CREATE CONSTRAINT R_revises__relationshipId__type IF NOT EXISTS
FOR ()-[r:REVISES]->()
REQUIRE r.relationshipId IS :: STRING;

CREATE CONSTRAINT R_revises__relationshipId__key IF NOT EXISTS
FOR ()-[r:REVISES]->()
REQUIRE r.relationshipId IS REL KEY;

CREATE CONSTRAINT R_revises__createdTimestamp__type IF NOT EXISTS
FOR ()-[r:REVISES]->()
REQUIRE r.createdTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_revises__createdTimestamp__reqd IF NOT EXISTS
FOR ()-[r:REVISES]->()
REQUIRE r.createdTimestamp IS NOT NULL;

CREATE CONSTRAINT R_revises__updatedTimestamp__type IF NOT EXISTS
FOR ()-[r:REVISES]->()
REQUIRE r.updatedTimestamp IS :: ZONED DATETIME;

CREATE CONSTRAINT R_revises__updatedTimestamp__reqd IF NOT EXISTS
FOR ()-[r:REVISES]->()
REQUIRE r.updatedTimestamp IS NOT NULL;


CREATE CONSTRAINT R_revises__notes__type IF NOT EXISTS
FOR ()-[r:REVISES]->()
REQUIRE r.notes IS :: LIST<STRING NOT NULL>;
