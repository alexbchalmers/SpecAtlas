---
title: Object Types
order: 111
---

# Object Types

SpecAtlas is made up of a number of node types. This documentation provides a mapping between the presentation in the
web app and the underlying data structures in the Neo4j database.

## Specification Owner (`ControllingOrg`)

The _Specification Owner_ type defines the organizations that are responsible for the publication and maintenance of a
document. Within the SpecAtlas, there is a preference to directly link a document with the original publisher. The database
captures parent-child and successor relationships, enabling users to determine the current owner from the original.

### Record Metadata

#### `controllingOrgId`

> _automatic_; _[guid]_

The _controllingOrgId_ property is used to capture an opaque identifier for a given node. This property is a GUID added
automatically by the database engine upon data insert.

#### `createdTimestamp`

> _automatic_; _[datetime]_

The _createdTimestamp_ property is used to capture the time of initial data insert into the database. This property is
automatically added to the database.

#### `updatedTimestamp`

> _automatic_; _[datetime]_

The _updatedTimestamp_ property is used to capture the most recent modification time of node data in the database. This
property is automatically added to the database.

#### `displayGroup`

> _[boolean]_

The _displayGroup_ property is set to `true` when a Specification Owner has child organization relationships and it is
desirable to show the Owner within the web application hierarchy.

### Record Data

#### Short Name (`shortName`)

> _required_; _[string]_

The _Short Name_ property is used as basic reference to the controlling organization.

#### Full Name (`fullName`)

> _required_; _[string]_

The _Full Name_ property is the overall title of a controlling organization.

#### URL (`url`)

> _[url]_

The _URL_ property is a direct URL link to the controlling organization.

#### Organization Type (`organizationType`)

> _required_; _[string]_

The _organizationType_ property describes the format of a given organization.

##### Organization Type Taxonomy

- _`international standards organization`_
  
  International standards organizations have formal membership by national representatives.
  Examples include ISO, IEC, and ITU.

- _`regional/national standards organization`_
  
  Regional or national standards organizations are generally members of international standards organizations,
  with formal membership and limited reach within a single nation or common region (e.g., European Union).

- _`open standards organization`_
  
  Open standards organizations have no or low barriers to entry to participation. Generally, these organizations operate
  on a consensus basis.

- _`industry association`_

  Industry associations are organizations comprised of manufacturers or other producers within a common field.
  Membership is generally limited to corporate members.

- _`independent organization`_

  Independent organizations are generally large corporations that produce widely accepted standards.

- _`special purpose organization`_

  Special purpose organizations are directly related to the standardization process, but may not generate standards themselves.
  Examples include IANA and ICANN.

- _`topic focus group`_

  Topic focus groups are targeted groups to specific subjects, including most working groups within larger standards organizations.

#### Status (`status`)

> _required_; _[string]_

The _Status_ property indicates the current status of a given organization.

##### Status Taxonomy

- _`Active`_

  The organization is currently meeting and producing output.

- _`Continued`_

  The organization reached its designated end date and its topic was continued in a subsequent group in the next applicable
  time period. This status is generally used for ITU-T study groups, where groups operate within a given study period.

- _`Reorganized`_

  The organization was renamed or had other significant organization changes. Examples of this include ISO TC97, which was
  reorganized into JTC1, and ITU-T study groups that had topic reconfiguration between study periods.

- _`Closed`_

  The organization was ended under normal processes.

- _`Abandoned`_

  The organization appears to no longer be active, although no formal closure is noted.

#### Start Date (`startDate`)

> _[date]_

The _Start Date_ property is the date when a controlling organization was started.

#### End Date (`endDate`)

> _[date]_

The _End Date_ property is the date when a controlling organization was concluded.

#### Notes (`notes`)

> _[string]_; _multi-valued_, _delimiter:_ `||`

The _Notes_ property is a general field of notes for a given entry.

## Specification (`Authority`)

The _Specification_ node type defines the metadata for standards documents and other reference materials.

### Record Metadata

#### authorityId

> _automatic_; _[guid]_

The _authorityId_ property is used to capture an opaque identifier for a given node. This property is a GUID added automatically
by the database engine upon data insert.

#### createdTimestamp

> _automatic_; _[datetime]_

The _createdTimestamp_ property is used to capture the time of initial data insert into the database. This property is
automatically added to the database.

#### updatedTimestamp

> _automatic_; _[datetime]_

The _updatedTimestamp_ property is used to capture the most recent modification time of node data in the database. This
property is automatically added to the database.

#### atlasCategory

> _[string]_

The _atlasCategory_ property provides a brief categorization for a given Authority node. This property is not fully utilized
at this time.

#### atlasStatus

> _[string]_; _multi-valued_, _delimiter:_ `;`

The _atlasStatus_ property denotes the processing status of a given entry in the database.

##### Atlas Status Taxonomy

- _`noReview`_
  
  The authority has not been directly reviewed to confirm the metadata. Metadata may be of a lower quality and in need
  of confirmation.

- _`stub`_

  The authority is only captured by the Authority node metadata, no effort has been made to determine relationships between
  the authority and upstream authorities.
  
  Generally, the `stub` status is used for documents that are simply referenced by other authorities.

- _`relOnly`_

  The authority is captured by the Authority node metadata as well as common relationships with other authorities to identify
  development lineage or republication by other bodies.

  Generally, `relOnly` authorities are fundamental authorities used across many other standards. Should the scope of the
  Atlas increase, these authorities may be expanded with full information.

- _`relComplete`_

  Core relationships for this authority have been captured in addition to Authority node metadata. These core relationships
  include:

  - `CONTROLS` - Defines the organization that published the authority.
  - `MEMBER_OF` - Indicates the authority is part of a collection authorities in an AuthorityGroup.
  - `UPDATES` - Indicates the authority makes updates to another authority.
  - `SUPERSEDES` - Indicates the authority replaces another document within its own series.
  - `OBSOLETES` - Indicates the authority replaces another document not within a series of documents.
  - `CORRECTS` - Indicates the authority makes technical or editorial corrections to another document.
  - `HAS_RELATED_AUTHORITY` - Indicates the authority has some other relation to another document, such as republication.

- _`refComplete`_

  Authorities directly referenced within the current Authority have been captured with node metadata and appropriate
  relationships have been captured between the nodes.

- _`draftsCaptured`_

  Drafts of the current authority have been captured with at least base metadata.

### Record Data

#### Reference (`reference`)

> _required_; _[string]_

The _Reference_ property provides a single string reference to the current authority, independent of how it may be referred
to by other documents.

#### Version (`versionTag`)

> _[string]_

The _Version_ property indicates the specific version for a given standard when part of a series.

#### Title (`title`)

> _required_; _[string]_

The _Title_ property is the full title of the authority document.

#### Status (`status`)

> _required_; _[string]_; _multi-valued_, _delimiter:_ `;`

The _Status_ property represents the current state of an authority.

##### Status Taxonomy

- _`Informational`_
  
  Document is not managed as part of a standards development process. Authorities in an _informational_ state may be
  referenced in standards-controlled authorities.

- _`Active`_
  
  Document is under control of a standards development process and has not been _withdrawn_, _deprecated_, _superseded_,
  or _obsoleted_.

- _`Updated`_

  Content of a document has been substantively updated. Updates may be made by direct amendment within a document series
  or a new document/standard.

- _`Errata`_

  Content of a document has been corrected. Corrections may be editorial or technical in nature.

- _`Superseded`_

  Authority has been replaced by a new document within a common series.

- _`Obsoleted`_

  Authority has been replaced by a document outside of a series of documents.

- _`Deprecated`_

  Authority has been marked for discontinued use by its standards making organization.

- _`Withdrawn`_

  Authority has been formally removed as a valid reference by its standards making organization.

- _`Unpublished`_

  Authority was approved by its standards development process but was never published for broad dissemination.

#### Type (`type`)

> _required_; _[string]_

The _Type_ property captures the document type, as identified by the issuing organization.

Common types include, but are not limited to:

- IETF/IRTF
  - _`Internet Standard`_
  - _`Best Current Practice`_
  - _`Proposed Standard`_
  - _`Draft Standard`_
  - _`RFC - Informational`_
  - _`RFC - Experimental`_
  - _`RFC - Historic`_
  - _`RFC - Unknown`_
- ISO/IEC
  - _`International Standard`_
  - _`Technical Report`_
  - _`ISO Recommendation`_
- ITU
  - _`ITU-T Recommendation`_
  - _`ITU-R Recommendation`_
- General
  - _`%org% Standard`_
  - _`Independent Standard`_

#### IETF Stream (`ietfStream`)

> _[string]_

The _IETF String_ property captures the well-defined stream used in the IETF standards development process. Values include:

- _`IETF`_
- _`IRTF`_
- _`IAB`_
- _`Editorial`_
- _`Independent`_
- _`Legacy`_

#### Published (`publishedDate`)

> _[date]_

The _Published_ property captures the date when the authority was approved for publishing, or the actual date of publication.

#### Deprecated (`deprecatedDate`)

> _[date]_

The _Deprecated_ property captures the date when the authority was recommended to be replaced by a successor.

#### Withdrawn (`withdrawnDate`)

> _[date]_

The _Withdrawn_ property captures the date when the authority was withdrawn as a valid document.

#### Canonical URL (`canonicalUrl`)

> _[url]_

The _Canonical URL_ property captures the URL for the definitive version of an authority.

#### Canonical Format (`canonicalFormat`)

> _[string]_

The _Canonical Format_ property captures the format of the canonical version of the authority. Note that not all canonical
authorities are limited to a single format. Example formats include:

- _`PDF`_ - Adobe Portable Document Format (PDF)
- _`Text`_ - General text format, encoding unspecified
- _`Text (ASCII)`_ - General text format, ASCII encoded
- _`Text (Unicode)`_ - General text format, Unicode encoded (typically UTF-8)
- _`RFCXML`_ - RFC-specific XML format
- _`XML`_ - General XML format
- _`HTML`_ - HTML-based content
- _`XSD`_ - XML schema definition

#### Plain Text (`plainTextUrl`)

> _[url]_

The _Plain Text_ property captures the URL for a plain text (e.g., ASCII or Unicode) version of an authority.

#### HTML (`htmlUrl`)

> _[url]_

The _HTML_ property captures the URL for an HTML version of an authority.

#### Other URL (`otherUrl`)

> _[url]_

The _Other URL_ property captures the URL for any other version of an authority.

The _otherUrl_ property may be used to capture a URL where a canonical or fixed format URL does not exist. An additional use
case is to capture the IETF Datatracker entry for a given RFC.

#### Other Format (`otherFormat`)

> _[string]_

The _otherFormat_ property performs the same function as the _canonicalFormat_ does for _canonicalUrl_. In addition to the
formats listed under _canonicalFormat_ the value `IETF Datatracker` can be used for URLs capturing the Datatracker URL
for a given RFC.

#### doi (`doi`)

> _[string]_

The _doi_ property captures a DOI, a persistent identifier to a digital element, for a given authority document. The DOI is
rendered as a link using the <https://doi.org/> resolver.

#### Notes (`notes`)

> _[string]_; _multi-valued_, _delimiter:_ `||`

The _notes_ property is a general property of notes for a given entry.

## Authority Group (`AuthorityGroup`)

The _Authority Group_ node type defines the metadata for collections of authorities.

### Record Metadata

#### authorityGroupId

> _automatic_; _[guid]_

The _authorityGroupId_ property is used to capture an opaque identifier for a given node. This field is a GUID added automatically
by the database engine upon data insert.

#### createdTimestamp

> _automatic_; _[datetime]_

The _createdTimestamp_ property is used to capture the time of initial data insert into the database. This property is
automatically added to the database.

#### updatedTimestamp

> _automatic_; _[datetime]_

The _updatedTimestamp_ property is used to capture the most recent modification time of node data in the database. This
property is automatically added to the database.

#### atlasStatus

> _[string]_; _multi-valued_, _delimiter:_ `;`

The _atlasStatus_ property denotes the processing status of a given entry in the database.

### Record Data

#### Group Type (`groupType`)

> _required_; _[string]_

The _Group Type_ property captures the specific type of grouping of authorities this entry represents. Common types include:

- General

  - _`collectedAuthority`_
  
    This group type represents a scenario where the full context of the authority is spread across multiple documents.
    A common use case for this type is when capturing a primary authority with its amendments, errata, and other
    supplemental documents.

  - _`versionedAuthority`_

    This group type represents a scenario where a given authority has been revised over time. This entry represents the
    overall standard, rather than particulars of a given version.

    This group type often represents a root anchor for a document series, with membership consisting of `collectedAuthority`
    groups representing each version within the series.

- IETF
  
  IETF STD, BCP, and FYI groupings may consist of multiple RFC documents but often are single member groups.

  - _`ietfInternetStandard`_

    This group type represents a collection of RFCs that make up an Internet Standard.

  - _`ietfBestCurrentPractice`_

    This group type represents a collection of RFCs that make up a Best Current Practice.

#### Reference (`reference`)

> _required_; _[string]_

The _Reference_ property provides a single string reference to the current authority group, independent of how it may be
referred to by other documents.

#### Title (`title`)

> _required_; _[string]_

The _title_ property is the full title of the authority group.

#### URL (`url`)

> _[url]_

The _URL_ property captures the URL for the authority group.

#### Notes (`notes`)

> _[string]_; _multi-valued_, _delimiter:_ `||`

The _Notes_ property is a general property of notes for a given entry.

## Draft Revision (`AuthorityDraftRevision`)

The _Draft Revision_ node type defines the metadata for individual versions of draft documents.

### Record Metadata

#### authorityDraftRevisionId

> _automatic_; _[guid]_

The _authorityDraftRevisionId_ property is used to capture an opaque identifier for a given node. This property is a GUID
added automatically by the database engine upon data insert.

#### createdTimestamp

> _automatic_; _[datetime]_

The _createdTimestamp_ property is used to capture the time of initial data insert into the database. This property is
automatically added to the database.

#### updatedTimestamp

> _automatic_; _[datetime]_

The _updatedTimestamp_ property is used to capture the most recent modification time of node data in the database. This
property is automatically added to the database.

#### atlasCategory

> _[string]_

The _atlasCategory_ property provides a brief categorization for a given Authority node. This is an open text string.

#### atlasStatus

> _[string]_; _multi-valued_, _delimiter:_ `;`

The _atlasStatus_ property denotes the processing status of a given entry in the database.

### Record Data

#### Reference (`reference`)

> _required_; _[string]_

The _Reference_ property provides a single string reference to the current authority, independent of how it may be referred
to by other documents.

#### Revision Sequence (`revisionSequence`)

> _required_; _[integer]_

The _Revision Sequence_ property provides a direct ordering of when a revision was released.

#### Title (`title`)

> _required_; _[string]_

The _Title_ property is the full title of the authority document.

#### Status (`status`)

> _required_; _[string]_; _multi-valued_, _delimiter:_ `;`

The _Status_ property represents the current state of an authority. Potential values include the following. The document's
state may be comprised of multiple status values.

- _`Adopted`_
  
  Document has been adopted as a published specification and managed as part of a standards development process.

- _`Revised`_
  
  Document has a new version and the current version has been superseded.

- _`Replaced`_
  
  Set of document revisions has been replaced by an alternative set of revisions.

- _`Expired`_
  
  Document was neither revised or adopted and has reached the end of its lifecycle as part of a standards development process.

#### Type (`type`)

> _required_; _[string]_

The _Type_ property captures the document type, as identified by the issuing organization.

Common types include, but are not limited to:

- IETF/IRTF
  - _`Internet-Draft`_
- ISO/IEC
  - _`Final Draft International Standard`_
  - _`Draft International Standard`_
  - _`Committee Draft`_
  - _`Working Draft`_
  - _`New Work Item Proposal`_
  - _`Preliminary Work Item`_
- General
  - _`Work[ing] Group Draft`_
  - _`Implementers Draft`_

#### IETF Stream (`ietfStream`)

> _[string]_

The _IETF Stream_ property captures the well-defined stream used in the IETF standards development process. Values include:

- _`IETF`_
- _`IRTF`_
- _`IAB`_
- _`Editorial`_
- _`Independent`_
- _`Legacy`_

#### Published (`publishedDate`)

> _[date]_

The _Published_ property captures the date when the authority was approved for publishing, or the actual date of publication.

#### Canonical URL (`canonicalUrl`)

> _[url]_

The _Canonical URL_ property captures the URL for the definitive version of an authority.

#### Canonical Format (`canonicalFormat`)

> _[string]_

The _Canonical Format_ property captures the format of the canonical version of the authority. Note that not all canonical
authorities are limited to a single format. Example formats include:

- _`PDF`_ - Adobe Portable Document Format (PDF)
- _`Text`_ - General text format, encoding unspecified
- _`Text (ASCII)`_ - General text format, ASCII encoded
- _`Text (Unicode)`_ - General text format, Unicode encoded (typically UTF-8)
- _`RFCXML`_ - RFC-specific XML format
- _`XML`_ - General XML format
- _`HTML`_ - HTML-based content
- _`XSD`_ - XML schema definition

#### Plain Text (`plainTextUrl`)

> _[url]_

The _Plain Text_ property captures the URL for a plain text (e.g., ASCII or Unicode) version of an authority.

#### HTML (`htmlUrl`)

> _[url]_

The _HTML_ property captures the URL for an HTML version of an authority.

#### Other URL (`otherUrl`)

> _[url]_

The _Other URL_ property captures the URL for any other version of an authority.

The _otherUrl_ property may be used to capture a URL where a canonical or fixed format URL does not exist. An additional use
case is to capture the IETF Datatracker entry for a given RFC.

#### Other Format (`otherFormat`)

> _[string]_

The _otherFormat_ property performs the same function as the _canonicalFormat_ does for _canonicalUrl_. In addition to the
formats listed under _canonicalFormat_ the value `IETF Datatracker` can be used for URLs capturing the Datatracker URL
for a given RFC.

#### Notes (`notes`)

> _[string]_; _multi-valued_, _delimiter:_ `||`

The _Notes_ property is a general property of notes for a given entry.

