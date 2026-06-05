/*******************************************************************************
*
* LoadAuthorityDraft.cypher
*
* Loads AuthorityDraft node data from a CSV file.
*
* Parameters:
*   $authorityDraftDataUrl   URL to the AuthorityDraft CSV file
*
* Execution order: 5 of 8 (after LoadAuthority.cypher)
*
*******************************************************************************/

LOAD CSV WITH HEADERS FROM $authorityDraftDataUrl AS row
MERGE (
  ad:AuthorityDraft {
    authorityDraftId: coalesce(lower(trim(row.authorityDraftId)), randomUUID())
  }
)
  ON CREATE
    SET
    // Metadata Fields             Definition
      ad.createdTimestamp       = coalesce(
                                    datetime(trim(row.createdTimestamp)),
                                    datetime()
                                  )
      , ad.updatedTimestamp     = coalesce(
                                    datetime(trim(row.updatedTimestamp)),
                                    datetime()
                                  )
    // Informational Fields        Definition
      , ad.atlasCategory        = [x IN split(nullIf(trim(row.atlasCategory), ''), ';') | lower(trim(x))]
      , ad.atlasStatus          = coalesce(
                                    [x IN split(row.atlasStatus, ';') | lower(trim(x))],
                                    ['unknown']
                                  )
      , ad.reference            = nullIf(trim(row.reference), '')
      , ad.title                = trim(row.title)
      , ad.status               = coalesce(
                                    [x IN split(row.status, ';') | lower(trim(x))],
                                    ['unknown']
                                  )
      , ad.type                 = nullIf(trim(row.type), '')
RETURN
  'Loaded AuthorityDraft Data';
