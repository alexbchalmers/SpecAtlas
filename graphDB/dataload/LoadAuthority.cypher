/*******************************************************************************
*
* LoadAuthority.cypher
*
* Loads Authority node data from a CSV file.
*
* Parameters:
*   $authorityDataUrl   URL to the Authority CSV file
*
* Execution order: 4 of 8 (after LoadAuthorityGroup.cypher)
*
*******************************************************************************/

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
    // Informational Fields        Definition
      , a.atlasCategory         = [x IN split(nullIf(trim(row.atlasCategory), ''), ';') | lower(trim(x))]
      , a.atlasStatus           = coalesce(
                                    [x IN split(row.atlasStatus, ';') | lower(trim(x))],
                                    ['unknown']
                                  )
      , a.reference             = nullIf(trim(row.reference), '')
      , a.versionTag            = nullIf(trim(row.versionTag), '')
      , a.title                 = trim(row.title)
      , a.status                = coalesce(
                                    [x IN split(row.status, ';') | lower(trim(x))],
                                    ['unknown']
                                  )
      , a.type                  = nullIf(trim(row.type), '')
      , a.ietfStream            = nullIf(trim(row.ietfStream), '')
      , a.publishedDate         = date(nullIf(trim(row.publishedDate), ''))    // YYYY[-MM[-DD]]
      , a.deprecatedDate        = date(nullIf(trim(row.deprecatedDate), ''))   // YYYY[-MM[-DD]]
      , a.withdrawnDate         = date(nullIf(trim(row.withdrawnDate), ''))    // YYYY[-MM[-DD]]
      , a.canonicalUrl          = nullIf(trim(row.canonicalUrl), '')
      , a.canonicalFormat       = nullIf(trim(row.canonicalFormat), '')
      , a.plainTextUrl          = nullIf(trim(row.plainTextUrl), '')
      , a.htmlUrl               = nullIf(trim(row.htmlUrl), '')
      , a.otherUrl              = nullIf(trim(row.otherUrl), '')
      , a.otherFormat           = nullIf(trim(row.otherFormat), '')
      , a.doi                   = nullIf(trim(row.doi), '')
      , a.notes                 = [x IN split(nullIf(trim(row.notes), ''), '||') | trim(x)]
RETURN
  'Loaded Authority Data';
