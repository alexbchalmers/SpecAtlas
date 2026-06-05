/*******************************************************************************
*
* LoadAuthorityGroup.cypher
*
* Loads AuthorityGroup node data from a CSV file.
*
* Parameters:
*   $authorityGroupDataUrl   URL to the AuthorityGroup CSV file
*
* Execution order: 4 of 8 (after LoadAuthority.cypher)
*
*******************************************************************************/

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
    // Informational Fields        Definition
      , ag.atlasStatus          = coalesce(
                                    [x IN split(row.atlasStatus, ';') | lower(trim(x))],
                                    ['unknown']
                                  )
      , ag.groupType            = coalesce(
                                    nullIf(trim(row.groupType), ''),
                                    'unknown'
                                  )
      , ag.reference            = nullIf(trim(row.reference), '')
      , ag.title                = trim(row.title)
      , ag.url                  = nullIf(trim(row.url), '')
      , ag.notes                = [x IN split(nullIf(trim(row.notes), ''), '||') | trim(x)]
RETURN
  'Loaded AuthorityGroup Data' AS Action;
