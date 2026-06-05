/*******************************************************************************
*
* LoadAuthorityDraftRevision.cypher
*
* Loads AuthorityDraftRevision node data from a CSV file.
*
* Parameters:
*   $authorityDraftRevisionDataUrl   URL to the AuthorityDraftRevision CSV file
*
* Execution order: 6 of 8 (after LoadAuthorityDraft.cypher)
*
*******************************************************************************/

LOAD CSV WITH HEADERS FROM $authorityDraftRevisionDataUrl AS row
MERGE (
  adr:AuthorityDraftRevision {
    authorityDraftRevisionId: coalesce(lower(trim(row.authorityDraftRevisionId)), randomUUID())
  }
)
  ON CREATE
    SET
    // Metadata Fields             Definition
      adr.createdTimestamp      = coalesce(
                                    datetime(trim(row.createdTimestamp)),
                                    datetime()
                                  )
      , adr.updatedTimestamp    = coalesce(
                                    datetime(trim(row.updatedTimestamp)),
                                    datetime()
                                  )
    // Informational Fields        Definition
      , adr.atlasCategory       = [x IN split(nullIf(trim(row.atlasCategory), ''), ';') | lower(trim(x))]
      , adr.atlasStatus         = coalesce(
                                    [x IN split(row.atlasStatus, ';') | lower(trim(x))],
                                    ['unknown']
                                  )
      , adr.reference           = nullIf(trim(row.reference), '')
      , adr.title               = trim(row.title)
      , adr.status              = coalesce(
                                    [x IN split(row.status, ';') | lower(trim(x))],
                                    ['unknown']
                                  )
      , adr.type                = nullIf(trim(row.type), '')
      , adr.ietfStream          = nullIf(trim(row.ietfStream), '')
      , adr.publishedDate       = date(nullIf(trim(row.publishedDate), ''))   // YYYY[-MM[-DD]]
      , adr.canonicalUrl        = nullIf(trim(row.canonicalUrl), '')
      , adr.canonicalFormat     = nullIf(trim(row.canonicalFormat), '')
      , adr.plainTextUrl        = nullIf(trim(row.plainTextUrl), '')
      , adr.htmlUrl             = nullIf(trim(row.htmlUrl), '')
      , adr.otherUrl            = nullIf(trim(row.otherUrl), '')
      , adr.otherFormat         = nullIf(trim(row.otherFormat), '')
      , adr.notes               = [x IN split(nullIf(trim(row.notes), ''), '||') | trim(x)]
RETURN
  'Loaded AuthorityDraftRevision Data' AS Action;
