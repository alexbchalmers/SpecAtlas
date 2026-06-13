---
title: Relationships
order: 112
---

# Relationships

Nodes within SpecAtlas maintain a number of relationships.

## HAS_CHILD_ORG

Describes a subordinate relationship between organizations.

`(<SourceNode>) -[ HAS_CHILD_ORG ]-> (<TargetNode>)`

|       | Source Node Type | Target Node Type |
| :---: | :--------------: | :--------------: |
|       | **_Parent Org_** | **_Child Org_**  |
|   1   |  ControllingOrg  |  ControllingOrg  |

## HAS_AFFILIATE_ORG

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

## PREVIOUSLY_KNOWN_AS

Describes the continuity of an organization across name changes. May also be used to describe the direct succession of an
organization with minimal organizational change.

`(<SourceNode>) -[ PREVIOUSLY_KNOWN_AS ]-> (<TargetNode>)`

|       | Source Node Type  |  Target Node Type  |
| :---: | :---------------: | :----------------: |
|       | **_Instant Org_** | **_Previous Org_** |
|   1   |  ControllingOrg   |   ControllingOrg   |

## SUCCEEDED_ORG

Describes the continuity of organizations across significant change. This is often due to significant reorganization or
combining organizations.

`(<SourceNode>) -[ SUCCEEDED_ORG ]-> (<TargetNode>)`

|       | Source Node Type  |  Target Node Type  |
| :---: | :---------------: | :----------------: |
|       | **_Instant Org_** | **_Previous Org_** |
|   1   |  ControllingOrg   |   ControllingOrg   |

## CONTROLS

Describes the relationship between a standards making organization and an artifact (e.g., Authority, AuthorityGroup, etc.).
This relationship should only be used for documents under some level of standards development.

`(<SourceNode>) -[ CONTROLS ]-> (<TargetNode>)`

|       |     Source Node Type      |       Target Node Type       |
| :---: | :-----------------------: | :--------------------------: |
|       | **_Document Controller_** | **_Document or Collection_** |
|   1   |      ControllingOrg       |          Authority           |
|   2   |      ControllingOrg       |        AuthorityGroup        |
|   3   |      ControllingOrg       |        AuthorityDraft        |

## MEMBER_OF

Describes groups of artifacts.

`(<SourceNode>) -[ MEMBER_OF ]-> (<TargetNode>)`

|       |    Source Node Type     | Target Node Type |
| :---: | :---------------------: | :--------------: |
|       | **_Collection Member_** | **_Collection_** |
|   1   |        Authority        |  AuthorityGroup  |
|   2   |     AuthorityGroup      |  AuthorityGroup  |

## DEPRECATES

One artifact notifies users to discontinue use of the Authority. The target may be a group of documents to
accommodate amended Authorities. See the _Deprecated_ Authority status.

`(<SourceNode>) -[ DEPRECATES ]-> (<TargetNode>)`

|       |      Source Node Type       |    Target Node Type     |
| :---: | :-------------------------: | :---------------------: |
|       | **_Notification Document_** | **_Original Document_** |
|   1   |          Authority          |        Authority        |
|   2   |          Authority          |     AuthorityGroup      |
|   3   |          Authority          |     AuthorityDraft      |

## OBSOLETES

One artifact replaces another without being in a common series. The target may be a group of documents to
accommodate amended Authorities. One artifact may obsolete multiple other documents; an artifact may be obsoleted by
multiple other documents. See the _Obsoleted_ Authority status.

`(<SourceNode>) -[ OBSOLETES ]-> (<TargetNode>)`

|       |      Source Node Type      |    Target Node Type     |
| :---: | :------------------------: | :---------------------: |
|       | **_Replacement Document_** | **_Original Document_** |
|   1   |         Authority          |        Authority        |
|   2   |         Authority          |     AuthorityGroup      |
|   3   |   AuthorityDraftRevision   |  AuthorityDraftRevision |

## SUPERSEDES

One artifact in a series directly replaces a prior document in the series. The target may be a group of documents to
accommodate amended Authorities. The `SUPERSEDES` relationship should be a one-to-one relationship, granted the target
is an AuthorityGroup.

`(<SourceNode>) -[ SUPERSEDES ]-> (<TargetNode>)`

|       |      Source Node Type      |    Target Node Type     |
| :---: | :------------------------: | :---------------------: |
|       | **_Replacement Document_** | **_Original Document_** |
|   1   |         Authority          |        Authority        |
|   2   |         Authority          |     AuthorityGroup      |

## UPDATES

One artifact substantively updates another. See the _Updated_ Authority status.

`(<SourceNode>) -[ UPDATES ]-> (<TargetNode>)`

|       |      Source Node Type       |   Target Node Type    |
| :---: | :-------------------------: | :-------------------: |
|       | **_Document with Updates_** | **_Source Document_** |
|   1   |          Authority          |       Authority       |

## CORRECTS

One artifact corrects another, either technically or editorially. See the _Errata_ Authority status.

`(<SourceNode>) -[ CORRECTS ]-> (<TargetNode>)`

|       |        Source Node Type         |   Target Node Type    |
| :---: | :-----------------------------: | :-------------------: |
|       | **_Document with Corrections_** | **_Source Document_** |
|   1   |            Authority            |       Authority       |

## HAS_RELATED_AUTHORITY

Describes a relationship between two Authorities, given a `relationship`.

`(<SourceNode>) -[ HAS_RELATED_AUTHORITY {relationship} ]-> (<TargetNode>)`

|       |   Source Node Type    |   Target Node Type    |
| :---: | :-------------------: | :-------------------: |
|       | **_Source Document_** | **_Target Document_** |
|   1   |       Authority       |       Authority       |
|   2   |       Authority       |    AuthorityGroup     |
|   3   |       Authority       | AuthorityDraftRevision|
|   4   |    AuthorityGroup     |       Authority       |
|   5   |    AuthorityGroup     |    AuthorityGroup     |

`relationship` values include, but are not limited to:

- _`influenced`_ - One Authority provided a basis for the development of another.

- _`partially equivalent`_ - Elements of an Authority, but not the entirety, are technically equivalent to another.
  Equivalent elements should be noted in the `notes` field.

- _`technically equivalent`_ - Two Authorities have the same technical meaning, although the text is not identical.

- _`textually equivalent`_ - Two Authorities maintain the exact text. The Authorities are published from two different
  controlling organizations.

- _`republication`_ - One Authority is a direct republication of a prior Authority, such as due to a renumbering
  or reauthorization.

## REFERENCES

Describes one Authority's reference of another, given an optional `referenceType`.

`(<SourceNode>) -[ REFERENCES {referenceType} ]-> (<TargetNode>)`

|       |      Source Node Type      |     Target Node Type      |
| :---: | :------------------------: | :-----------------------: |
|       | **_Referencing Document_** | **_Referenced Document_** |
|   1   |         Authority          |         Authority         |
|   2   |         Authority          |      AuthorityGroup       |
|   3   |         Authority          |   AuthorityDraftRevision  |

`referenceType` values include, but are not limited to:

- _`normative`_ - Understanding the referenced document is critical to understand or implement the technology presented
  in the referencing document.

- _`informative`_ - The referenced document provides contextual or additional information not critical to understand or
  implement the technology in the referencing document.

## DRAFTED_BY

An authority has been drafted by a group of draft revisions.

`(<SourceNode>) -[ DRAFTED_BY ]-> (<TargetNode>)`

|       |    Source Node Type     | Target Node Type |
| :---: | :---------------------: | :--------------: |
|       | **_Defining Document_** |   **_Object_**   |
|   1   |        Authority        |  AuthorityDraft  |

## ADOPTED_AS

An authority draft revision has been adopted as a published authority.

`(<SourceNode>) -[ ADOPTED_AS ]-> (<TargetNode>)`

|       |    Source Node Type     | Target Node Type |
| :---: | :---------------------: | :--------------: |
|       | **_Defining Document_** |   **_Object_**   |
|   1   | AuthorityDraftRevision  |    Authority     |

## DEFINES

An authority provides the definition of a format.

`(<SourceNode>) -[ DEFINES ]-> (<TargetNode>)`

|       |    Source Node Type     | Target Node Type |
| :---: | :---------------------: | :--------------: |
|       | **_Defining Document_** |   **_Object_**   |
|   1   |        Authority        |     Artifact     |
|   2   |     AuthorityGroup      |     Artifact     |
