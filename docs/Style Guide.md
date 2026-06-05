# Spec Atlas Style Guide

The Spec Atlas is a graph database consisting of multiple node types. Valid node types include:

- ControllingOrg
- Authority
- AuthorityGroup
- Format
- AuthorityDraft
- AuthorityDraftRevision

These nodes have various relationships that are further documented.

## Node Types

### ControllingOrg

The _ControllingOrg_ node type defines the organizations that are responsible for the publication of given standards.
This includes IETF working groups, OpenID Foundation working groups, ISO technical committees, among others.

#### Fields

##### controllingOrgId

> _automatic_; _[guid]_

The _controllingOrgId_ field is used to capture an opaque identifier for a given node. This field is a GUID added automatically
by the database engine upon data insert.

##### createdTimestamp

> _automatic_; _[datetime]_

The _createdTimestamp_ field is used to capture the time of initial data insert into the database. This field is automatically
added to the database.

##### updatedTimestamp

> _automatic_; _[datetime]_

The _updatedTimestamp_ field is used to capture the most recent modification time of node data in the database. This field
is automatically added to the database.

##### shortName

> _required_; _[string]_

The _shortName_ field is used as basic reference to the controlling organization.

IETF, and the related IRTF, groups are split between area groups and working groups. Working groups are assigned as child
orgs to area groups. Area groups should be formatted as `(IETF|IRTF) %AREA% Area`. The `%area%` value should be in uppercase.
Working Groups should be formatted as `%group% WG`. The `%group%` value should be in lowercase. The IETF group format is
the basis for most other working group based organizations.

ISO and IEC groups are similarly hierarchical to the IETF. Technical Committees (TCs) contain Subcommittees (SCs)
subcommittees may contain Working Groups (WGs). Generally, the Atlas will only be concerned with groups down to the
Subcommittee level. Technical Committees should be formatted as `(ISO|IEC) TC %number%`. Subcommittees should be formatted
as `TC%tc_number% SC %sc_number%`. ISO/IEC Joint Technical Committee 1 follow this same pattern, using `ISO/IEC JTC 1` at
the TC level and `JTC1 SC %sc_number%` at the SC level. All numbers should be represented with Arabic numerals.

ITU Study Groups (SGs) are unique in that they are time-bound on generally four year intervals. Often these groups are
continued with minimal changes but reorganizations and renumberings are not uncommon. ITU child organizations have been
reorganized in the past. Currently, the ITU has three sub-organizations: ITU-T for telecommunications standardization,
ITU-R for radiocommunication, and ITU-D for telecommunication development. The Spec Atlas is most concerned with documents
coming out of ITU-T. Prior to 1993, the functions of ITU-T were managed by its predecessor organization CCITT. Study Groups
should be formatted as `(ITU-T|CCITT) SG %sg_number% (%sg_year%)`, where `%sg_number%` is the study group number in Arabic
numerals and `%sg_year%` is the last year for the SG in is study period.

##### fullName

> _required_; _[string]_

The _fullName_ field is the overall title of a controlling organization. Generally, organization full names are formatted
in title case.

IETF and IRTF area groups should be formatted as `(IETF|IRTF) %group% Area`, with the `%group%` being the title of the area
group in title case. Working groups should be formatted as `%group% working group`. In the working group case, the `%group%`
title will generally be in title case but may have unique capitalization to highlight abbreviations used in the shortName
field. As with the shortName field, the IETF format is the basis for most other organizations with working groups.

ISO and IEC technical committees should be formatted as `(ISO|IEC) technical committee - %name%`, where `%name%` is the
name of the TC in title case. Subcommittees should be formatted as `TC%tc_number% subcommittee - %name% (SC %sc_number%)`,
where `%tc_number%` and `%sc_number%` are in Arabic numerals and `%name%` is the name of the SC in title case.

ITU-T study groups should be formatted as `(ITU-T|CCITT) Study Group %sg_number% (Study Period %start_year%-%end_year%) - %name%`.
CCITT study group `%sg_number%` entries are typically formatted in Roman numerals except for Study Period 1957-1960 where
they are in Arabic numerals. ITU-T `%sg_number%` values are exclusively formatted in Arabic numerals.

##### url

> _[url]_

The _url_ field is a direct URL link to the controlling organization. HTTPS links are preferred over HTTP links. Links
to the root of a site should end with a trailing `/` character.

##### organizationType

> _required_; _[string]_

The _organizationType_ field describes the format of a given organization.

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

##### status

> _required_; _[string]_

The _string_ field indicates the current status of a given organization. Potential values include:

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

##### startDate

> _[date]_

The _startDate_ field is the date when a controlling organization was started. The value should be formatted in ISO format
such as `YYYY[-MM[-DD]]`.

##### endDate

> _[date]_

The _endDate_ field is the date when a controlling organization was concluded. The value should be formatted in ISO format
such as `YYYY[-MM[-DD]]`.

##### notes

> _[string]_; _multi-valued_, _delimiter:_ `||`

The _notes_ field is a general field of notes for a given entry.

### Authority

The _Authority_ node type defines the metadata for standards documents and other reference materials.

#### Fields

##### authorityId

> _automatic_; _[guid]_

The _authorityId_ field is used to capture an opaque identifier for a given node. This field is a GUID added automatically
by the database engine upon data insert.

##### createdTimestamp

> _automatic_; _[datetime]_

The _createdTimestamp_ field is used to capture the time of initial data insert into the database. This field is automatically
added to the database.

##### updatedTimestamp

> _automatic_; _[datetime]_

The _updatedTimestamp_ field is used to capture the most recent modification time of node data in the database. This field
is automatically added to the database.

##### atlasCategory

> _[string]_

The _atlasCategory_ field provides a brief categorization for a given Authority node. This is an open text string.

##### atlasStatus

> _[string]_; _multi-valued_, _delimiter:_ `;`

**NOTE**: The _atlasStatus_ field is of limited value in the long-term maintenance of the Atlas. It is most relevant at
the current early stage data loading phase to understand what data elements have been captured to date.

The _atlasStatus_ field denotes the processing status of a given entry in the database. Field values include, but not
limited to:

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

##### reference

> _required_; _[string]_

The _reference_ field provides a single string reference to the current authority, independent of how it may be referred
to by other documents. There are some common formats in use.

IETF RFCs are represented in the format `RFC%number%`, where `%number%` is the non-padded RFC number in Arabic numerals.
It is currently expected that the `%number%` parameter would be between one (1) and five (5) digits.

ISO, IEC, and ISO/IEC joint documents are represented in the format
`(ISO|IEC|ISO/IEC)[ %doctype%] %number%[-%part%]:%year%[/%subdoctype% %subdocnumber%:%subdocyear%]`. The `%doctype%`
references specialized documents like Technical Reports, International Standards are not included. The `%number%` represents
the primary document number in Arabic numerals. The optional `%part%` element indicates the document is a subpart of a
larger standard and is formatted in Arabic numerals. The `%year%` element represents the publication year for the authority
and is formatted as four (4) Arabic numerals. The optional `%subdoctype%` element indicates an authority is a modification
of a core document such as an Amendment or Corrigendum. The `%subdocnumber%` is a serialized number for an individual
subdocument represented in non-padded Arabic numerals. The `%subdocyear%`represents the year of publication of the subdocument
formatted in four (4) Arabic numerals.

ITU-T Recommendations are represented in the format
`(ITU-T|CCITT) Rec. %series%.%number% (%month%/%year%)[/%subdoctype% %subdocnumber% (%sdmonth%/%sdyear%)]`. The `%series%`
references the letter grouping for a given authority, formatted as capital letter(s). The `%number%` value represents the
specific document number within the letter series, formatted in Arabic numerals. The `%month%` represents the document
publication month in two (2) Arabic numerals. The `%year%` represents the document publication year in four (4) Arabic
numerals. The optional `%subdoctype%` element indicates an authority is a modification of a core document such as an
Amendment or Corrigendum. The `%subdocnumber%` is a serialized number for an individual subdocument represented in non-padded
Arabic numerals. The `%sdmonth%` is the month of publication for the subdocument in two (2) Arabic numerals. The `%sdyear%`
is the month of publication for the subdocument in four (4) Arabic numerals.

##### versionTag

> _[string]_

The _versionTag_ field indicates the specific version for a given standard when part of a series.

Some standards, such as Unicode, use explicit version numbers which should be used in this field.

ISO, IEC, and ITU-T specifications use Edition numbers to identify version changes. In these cases, the _versionTag_ should
be listed as `Edition %number%`, where `%number%` consists of non-padded Arabic numerals. Subdocuments shoudl be listed
as the same edition as their primary document.

##### title

> _required_; _[string]_

The _title_ field is the full title of the authority document.

Titles should be normalized to use consistent title casing throughout the Atlas. This may represent a difference from
how the Authority is listed in certain databases or lists.

Unless expressly part of a document title, document identifiers (e.g., RFC numbers, ISO/IEC numbers, or ITU recommendation
numbers) should be omitted from titles. In order to ensure clarity of referenced primary documents, amendments or other
supplemental documents should append the publication year of the original document in the title (e.g.,
`Original Document Title (2025) -- Amendment 1: Sample`).

##### status

> _required_; _[string]_; _multi-valued_, _delimiter:_ `;`

The _status_ field represents the current state of an authority. Potential values include the following. The document's
state may be comprised of multiple status values.

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

##### type

> _required_; _[string]_

The _type_ field captures the document type, as identified by the issuing organization.

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

##### ietfStream

> _[string]_

The _ietfString_ field captures the well-defined stream used in the IETF standards development process. Values include:

- _`IETF`_
- _`IRTF`_
- _`IAB`_
- _`Editorial`_
- _`Independent`_
- _`Legacy`_

##### publishedDate

> _[date]_

The _publishedDate_ field captures the date when the authority was approved for publishing, or the actual date of publication.
The value should be formatted in ISO format as `YYYY[-MM[-DD]]`.

##### withdrawnDate

> _[date]_

The _withdrawnDate_ field captures the date when the authority was withdrawn as a valid document. The value should be
formatted in ISO format as `YYYY[-MM[-DD]]`.

##### canonicalUrl

> _[url]_

The _canonicalUrl_ field captures the URL for the definitive version of an authority.

The URL used should be a permalink, if available. The link may refer directly to a specific file or to a page that facilitates
accessing or acquiring access to the authority.

##### canonicalFormat

> _[string]_

The _canonicalFormat_ field captures the format of the canonical version of the authority. Note that not all canonical
authorities are limited to a single format. Example formats include:

- _`PDF`_ - Adobe Portable Document Format (PDF)
- _`Text`_ - General text format, encoding unspecified
- _`Text (ASCII)`_ - General text format, ASCII encoded
- _`Text (Unicode)`_ - General text format, Unicode encoded (typically UTF-8)
- _`RFCXML`_ - RFC-specific XML format
- _`XML`_ - General XML format
- _`HTML`_ - HTML-based content
- _`XSD`_ - XML schema definition

##### plainTextUrl

> _[url]_

The _plainTextUrl_ field captures the URL for a plain text (e.g., ASCII or Unicode) version of an authority.

The URL used should be a permalink, if available. The link should directly targeted to the plain text file. This link
may be the same as the canonical URL.

##### htmlUrl

> _[url]_

The _htmlUrl_ field captures the URL for an HTML version of an authority.

The URL used should be a permalink, if available. The link should directly targeted to the HTML file. This link
may be the same as the canonical URL.

##### otherUrl

> _[url]_

The _otherUrl_ field captures the URL for any other version of an authority.

The URL used should be a permalink, if available.

The _otherUrl_ field may be used to capture a URL where a canonical or fixed format URL does not exist. An additional use
case is to capture the IETF Datatracker entry for a given RFC.

##### otherFormat

> _[string]_

The _otherFormat_ field performs the same function as the _canonicalFormat_ does for _canonicalUrl_. In addition to the
formats listed under _canonicalFormat_ the value `IETF Datatracker` can be used for URLs capturing the Datatracker URL
for a given RFC.

##### doi

> _[string]_

The _doi_ field captures a DOI, a persistent identifier to a digital element, for a given authority document. The DOI value
can be used as a standard URL (i.e., `https://doi.org/%doi%`) which will resolve to the actual element.

##### notes

> _[string]_; _multi-valued_, _delimiter:_ `||`

The _notes_ field is a general field of notes for a given entry.

### AuthorityGroup

The _AuthorityGroup_ node type defines the metadata for collections of authorities.

#### Fields

##### authorityGroupId

> _automatic_; _[guid]_

The _authorityGroupId_ field is used to capture an opaque identifier for a given node. This field is a GUID added automatically
by the database engine upon data insert.

##### createdTimestamp

> _automatic_; _[datetime]_

The _createdTimestamp_ field is used to capture the time of initial data insert into the database. This field is automatically
added to the database.

##### updatedTimestamp

> _automatic_; _[datetime]_

The _updatedTimestamp_ field is used to capture the most recent modification time of node data in the database. This field
is automatically added to the database.

##### atlasStatus

> _[string]_; _multi-valued_, _delimiter:_ `;`

**NOTE**: The _atlasStatus_ field is of limited value in the long-term maintenance of the Atlas. It is most relevant at
the current early stage data loading phase to understand what data elements have been captured to date.

The _atlasStatus_ field denotes the processing status of a given entry in the database. Field values include, but not
limited to:

- _`relOnly`_

  The authority is captured by the Authority node metadata as well as common relationships with other authorities to identify
  development lineage or republication by other bodies.

  Generally, `relOnly` authorities are fundamental authorities used across many other standards. Should the scope of the
  Atlas increase, these authorities may be expanded with full information.

- _`relComplete`_

  Core relationships for the related authorities have been captured in addition to Authority node metadata. 

##### groupType

> _required_; _[string]_

The _groupType_ field captures the specific type of grouping of authorities this entry represents. Common types include:

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

##### reference

> _required_; _[string]_

The _reference_ field provides a single string reference to the current authority group, independent of how it may be referred
to by other documents. There are some common formats in use.

For `collectedAuthority` groups, generally the reference will be the same as the primary document reference. In the case
where the group represents a primary document with amendments or corrections append ` (as amended)` to the reference.

For `versionedAuthority` groups, generally the reference will be the same as the most recent version in the series minus
any versioning information (e.g., 'ISO/IEC 10646' for the JTC1 issuance of the Unicode standard).

IETF STDs, BCPs, and FYIs are represented in the format `(RFC|BCP|FYI)%number%`, where `%number%` is the non-padded document
number in Arabic numerals.

##### title

> _required_; _[string]_

The _title_ field is the full title of the authority group.

For `collectedAuthority` groups, use the title of the primary document with the reference appended in square brackets
(i.e., generally `%primary title% [%primary reference%]`, 'The Unicode Standard [Unicode 1.0]'). In the case where the
group represents a primary document with amendments or corrections append ` as amended` to the title after the reference.

For `versionedAuthority` groups, use the title of the most recent primary document.

##### url

> _[url]_

The _url_ field captures the URL for the authority group.

##### notes

> _[string]_; _multi-valued_, _delimiter:_ `||`

The _notes_ field is a general field of notes for a given entry.

### AuthorityDraftRevision

The _AuthorityDraftRevision_ node type defines the metadata for individual versions of draft documents.

#### Fields

##### authorityDraftRevisionId

> _automatic_; _[guid]_

The _authorityDraftRevisionId_ field is used to capture an opaque identifier for a given node. This field is a GUID added
automatically by the database engine upon data insert.

##### createdTimestamp

> _automatic_; _[datetime]_

The _createdTimestamp_ field is used to capture the time of initial data insert into the database. This field is automatically
added to the database.

##### updatedTimestamp

> _automatic_; _[datetime]_

The _updatedTimestamp_ field is used to capture the most recent modification time of node data in the database. This field
is automatically added to the database.

##### atlasCategory

> _[string]_

The _atlasCategory_ field provides a brief categorization for a given Authority node. This is an open text string.

##### atlasStatus

> _[string]_; _multi-valued_, _delimiter:_ `;`

**NOTE**: The _atlasStatus_ field is of limited value in the long-term maintenance of the Atlas. It is most relevant at
the current early stage data loading phase to understand what data elements have been captured to date.

The _atlasStatus_ field denotes the processing status of a given entry in the database. Field values include, but not
limited to:

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

  Core relationships for this authority have been captured in addition to AuthorityDraftRevision node metadata. These core
  relationships include:

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

##### reference

> _required_; _[string]_

The _reference_ field provides a single string reference to the current authority, independent of how it may be referred
to by other documents.

##### title

> _required_; _[string]_

The _title_ field is the full title of the authority document.

Titles should be normalized to use consistent title casing throughout the Atlas. This may represent a difference from
how the Authority is listed in certain databases or lists.

Unless expressly part of a document title, document identifiers (e.g., RFC numbers, ISO/IEC numbers, or ITU recommendation
numbers) should be omitted from titles. In order to ensure clarity of referenced primary documents, amendments or other
supplemental documents should append the publication year of the original document in the title (e.g.,
`Original Document Title (2025) -- Amendment 1: Sample`).

##### status

> _required_; _[string]_; _multi-valued_, _delimiter:_ `;`

The _status_ field represents the current state of an authority. Potential values include the following. The document's
state may be comprised of multiple status values.

- _`Informational`_
  
  Document is not managed as part of a standards development process. Authorities in an _informational_ state may be
  referenced in standards-controlled authorities.

- _`Active`_
  
  Document is under control of a standards development process and has not been _withdrawn_, _deprecated_, _superseded_,
  or _obsoleted_.

##### type

> _required_; _[string]_

The _type_ field captures the document type, as identified by the issuing organization.

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

##### ietfStream

> _[string]_

The _ietfString_ field captures the well-defined stream used in the IETF standards development process. Values include:

- _`IETF`_
- _`IRTF`_
- _`IAB`_
- _`Editorial`_
- _`Independent`_
- _`Legacy`_

##### publishedDate

> _[date]_

The _publishedDate_ field captures the date when the authority was approved for publishing, or the actual date of publication.
The value should be formatted in ISO format as `YYYY[-MM[-DD]]`.

##### withdrawnDate

> _[date]_

The _withdrawnDate_ field captures the date when the authority was withdrawn as a valid document. The value should be
formatted in ISO format as `YYYY[-MM[-DD]]`.

##### canonicalUrl

> _[url]_

The _canonicalUrl_ field captures the URL for the definitive version of an authority.

The URL used should be a permalink, if available. The link may refer directly to a specific file or to a page that facilitates
accessing or acquiring access to the authority.

##### canonicalFormat

> _[string]_

The _canonicalFormat_ field captures the format of the canonical version of the authority. Note that not all canonical
authorities are limited to a single format. Example formats include:

- _`PDF`_ - Adobe Portable Document Format (PDF)
- _`Text`_ - General text format, encoding unspecified
- _`Text (ASCII)`_ - General text format, ASCII encoded
- _`Text (Unicode)`_ - General text format, Unicode encoded (typically UTF-8)
- _`RFCXML`_ - RFC-specific XML format
- _`XML`_ - General XML format
- _`HTML`_ - HTML-based content
- _`XSD`_ - XML schema definition

##### plainTextUrl

> _[url]_

The _plainTextUrl_ field captures the URL for a plain text (e.g., ASCII or Unicode) version of an authority.

The URL used should be a permalink, if available. The link should directly targeted to the plain text file. This link
may be the same as the canonical URL.

##### htmlUrl

> _[url]_

The _htmlUrl_ field captures the URL for an HTML version of an authority.

The URL used should be a permalink, if available. The link should directly targeted to the HTML file. This link
may be the same as the canonical URL.

##### otherUrl

> _[url]_

The _otherUrl_ field captures the URL for any other version of an authority.

The URL used should be a permalink, if available.

The _otherUrl_ field may be used to capture a URL where a canonical or fixed format URL does not exist. An additional use
case is to capture the IETF Datatracker entry for a given RFC.

##### otherFormat

> _[string]_

The _otherFormat_ field performs the same function as the _canonicalFormat_ does for _canonicalUrl_. In addition to the
formats listed under _canonicalFormat_ the value `IETF Datatracker` can be used for URLs capturing the Datatracker URL
for a given RFC.

##### doi

> _[string]_

The _doi_ field captures a DOI, a persistent identifier to a digital element, for a given authority document. The DOI value
can be used as a standard URL (i.e., `https://doi.org/%doi%`) which will resolve to the actual element.

##### notes

> _[string]_; _multi-valued_, _delimiter:_ `||`

The _notes_ field is a general field of notes for a given entry.

## Relationship Types

### HAS_CHILD_ORG

Describes a subordinate relationship between organizations.

`(<SourceNode>) -[ HAS_CHILD_ORG ]-> (<TargetNode>)`

|       | Source Node Type | Target Node Type |
| :---: | :--------------: | :--------------: |
|       | **_Parent Org_** | **_Child Org_**  |
|   1   |  ControllingOrg  |  ControllingOrg  |

### HAS_AFFILIATE_ORG

Describes a relationship between organizations with a specified `affiliation`.

`(<SourceNode>) -[ HAS_AFFILIATE_ORG {affiliation} ]-> (<TargetNode>)`

|       |   Source Node Type   |  Target Node Type   |
| :---: | :------------------: | :-----------------: |
|       | **_Originator Org_** | **_Affiliate Org_** |
|   1   |    ControllingOrg    |   ControllingOrg    |

`affiliation` values include, but are not limited to:

- _`accredits`_ - In the case of formal national standards bodies, a national standards body (source) may accredit an 
  affiliate (target) to support specific subjects.

- _`sponsors`_ - An example would be a commercial organization (source) providing financial, technical, or administrative
  assistance to a standards making body (target).

- _`national representative`_ - A national standards body (source) provides national representation to a broader international
  standards body (target).

- _`national technical advisor`_ - A nationally-accredited standards group (source) provides technical participation in
  the international standards making process (target).

- _`operates`_ - A technical organization (source) provides technical services on behalf of another organization (target).

### PREVIOUSLY_KNOWN_AS

Describes the continuity of an organization across name changes. May also be used to describe the direct succession of an
organization with minimal organizational change.

`(<SourceNode>) -[ PREVIOUSLY_KNOWN_AS ]-> (<TargetNode>)`

|       | Source Node Type  |  Target Node Type  |
| :---: | :---------------: | :----------------: |
|       | **_Instant Org_** | **_Previous Org_** |
|   1   |  ControllingOrg   |   ControllingOrg   |

### SUCCEEDED_ORG

Describes the continuity of organizations across significant change. This is often due to significant reorganization or
combining organizations.

`(<SourceNode>) -[ SUCCEEDED_ORG ]-> (<TargetNode>)`

|       | Source Node Type  |  Target Node Type  |
| :---: | :---------------: | :----------------: |
|       | **_Instant Org_** | **_Previous Org_** |
|   1   |  ControllingOrg   |   ControllingOrg   |

### CONTROLS

Describes the relationship between a standards making organization and an artifact (e.g., Authority, AuthorityGroup, etc.).
This relationship should only be used for documents under some level of standards development.

`(<SourceNode>) -[ CONTROLS ]-> (<TargetNode>)`

|       |     Source Node Type      |       Target Node Type       |
| :---: | :-----------------------: | :--------------------------: |
|       | **_Document Controller_** | **_Document or Collection_** |
|   1   |      ControllingOrg       |          Authority           |
|   2   |      ControllingOrg       |        AuthorityGroup        |

### MEMBER_OF

Describes groups of artifacts.

`(<SourceNode>) -[ MEMBER_OF ]-> (<TargetNode>)`

|       |    Source Node Type     | Target Node Type |
| :---: | :---------------------: | :--------------: |
|       | **_Collection Member_** | **_Collection_** |
|   1   |        Authority        |  AuthorityGroup  |
|   2   |     AuthorityGroup      |  AuthorityGroup  |

### UPDATES

One artifact substantively updates another. See the _Updated_ Authority status.

`(<SourceNode>) -[ UPDATES ]-> (<TargetNode>)`

|       |      Source Node Type       |   Target Node Type    |
| :---: | :-------------------------: | :-------------------: |
|       | **_Document with Updates_** | **_Source Document_** |
|   1   |          Authority          |       Authority       |

### CORRECTS

One artifact corrects another, either technically or editorially. See the _Errata_ Authority status.

`(<SourceNode>) -[ CORRECTS ]-> (<TargetNode>)`

|       |        Source Node Type         |   Target Node Type    |
| :---: | :-----------------------------: | :-------------------: |
|       | **_Document with Corrections_** | **_Source Document_** |
|   1   |            Authority            |       Authority       |

### SUPERSEDES

One artifact in a series directly replaces a prior document in the series. The target may be a group of documents to
accommodate amended Authorities. The `SUPERSEDES` relationship should be a one-to-one relationship, granted the target
is an AuthorityGroup. See the _Errata_ Authority status.

`(<SourceNode>) -[ SUPERSEDES ]-> (<TargetNode>)`

|       |      Source Node Type      |    Target Node Type     |
| :---: | :------------------------: | :---------------------: |
|       | **_Replacement Document_** | **_Original Document_** |
|   1   |         Authority          |        Authority        |
|   2   |         Authority          |     AuthorityGroup      |

### OBSOLETES

One artifact replaces another without being in a common series. The target may be a group of documents to
accommodate amended Authorities. One artifact may obsolete multiple other documents; an artifact may be obsoleted by
multiple other documents. See the _Obsoleted_ Authority status.

`(<SourceNode>) -[ OBSOLETES ]-> (<TargetNode>)`

|       |      Source Node Type      |    Target Node Type     |
| :---: | :------------------------: | :---------------------: |
|       | **_Replacement Document_** | **_Original Document_** |
|   1   |         Authority          |        Authority        |
|   2   |         Authority          |     AuthorityGroup      |

### DEPRECATES

One artifact notifies users to discontinue use of the Authority. The target may be a group of documents to
accommodate amended Authorities. See the _Deprecated_ Authority status.

`(<SourceNode>) -[ DEPRECATES ]-> (<TargetNode>)`

|       |      Source Node Type       |    Target Node Type     |
| :---: | :-------------------------: | :---------------------: |
|       | **_Notification Document_** | **_Original Document_** |
|   1   |          Authority          |        Authority        |
|   2   |          Authority          |     AuthorityGroup      |

### HAS_RELATED_AUTHORITY

Describes a relationship between two Authorities, given a `relationship`.

`(<SourceNode>) -[ HAS_RELATED_AUTHORITY {relationship} ]-> (<TargetNode>)`

|       |   Source Node Type    |   Target Node Type    |
| :---: | :-------------------: | :-------------------: |
|       | **_Source Document_** | **_Target Document_** |
|   1   |       Authority       |       Authority       |
|   2   |       Authority       |    AuthorityGroup     |
|   3   |    AuthorityGroup     |       Authority       |
|   4   |    AuthorityGroup     |    AuthorityGroup     |

`relationship` values include, but are not limited to:

- _`influenced`_ - One Authority provided a basis for the development of another.

- _`partially equivalent`_ - Elements of an Authority, but not the entirety, are technically equivalent to another.
  Equivalent elements should be noted in the `notes` field.

- _`technically equivalent`_ - Two Authorities have the same technical meaning, although the text is not identical.

- _`textually equivalent`_ - Two Authorities maintain the exact text. The Authorities are published from two different
  controlling organizations.

- _`republication`_ - One Authority is a direct republication of a prior Authority, such as due to a renumbering
  or reauthorization.

### REFERENCES

Describes one Authority's reference of another, given an optional `referenceType`.

`(<SourceNode>) -[ REFERENCES {referenceType} ]-> (<TargetNode>)`

|       |      Source Node Type      |     Target Node Type      |
| :---: | :------------------------: | :-----------------------: |
|       | **_Referencing Document_** | **_Referenced Document_** |
|   1   |         Authority          |         Authority         |
|   2   |         Authority          |      AuthorityGroup       |

`referenceType` values include, but are not limited to:

- _`normative`_ - Understanding the referenced document is critical to understand or implement the technology presented
  in the referencing document.

- _`informative`_ - The referenced document provides contextual or additional information not critical to understand or
  implement the technology in the referencing document.

### DEFINES

An authority provides the definition of a format.

`(<SourceNode>) -[ DEFINES ]-> (<TargetNode>)`

|       |    Source Node Type     | Target Node Type |
| :---: | :---------------------: | :--------------: |
|       | **_Defining Document_** |   **_Object_**   |
|   1   |        Authority        |      Format      |
|   2   |     AuthorityGroup      |      Format      |
