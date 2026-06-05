/*******************************************************************************
*
* LoadArtifact.cypher
*
* Loads Artifact node data from a CSV file.
*
* Parameters:
*   $artifactDataUrl   URL to the Artifact CSV file
*
* Execution order: 7 of 8 (after LoadAuthorityDraftRevision.cypher)
*
*******************************************************************************/

LOAD CSV WITH HEADERS FROM $artifactDataUrl AS row
MERGE (
  art:Artifact {
    artifactId: coalesce(lower(trim(row.artifactId)), randomUUID())
  }
)
  ON CREATE
    SET
    // Metadata Fields             Definition
      art.createdTimestamp      = coalesce(
                                    datetime(trim(row.createdTimestamp)),
                                    datetime()
                                  )
      , art.updatedTimestamp    = coalesce(
                                    datetime(trim(row.updatedTimestamp)),
                                    datetime()
                                  )
    // Informational Fields        Definition
      , art.artifactType        = coalesce(
                                    nullIf(trim(row.artifactType), ''),
                                    'unknown'
                                  )
      , art.artifactSubtype     = nullIf(trim(row.artifactSubtype), '')
      , art.artifactTypeGroup   = toBoolean(nullIf(trim(row.artifactTypeGroup), ''))
      , art.shortName           = coalesce(
                                    nullIf(trim(row.shortName), ''),
                                    nullIf(trim(row.fullName), '')
                                  )
      , art.fullName            = nullIf(trim(row.fullName), '')
      , art.status              = [x IN split(nullIf(trim(row.status), ''), ';') | lower(trim(x))]
      , art.notes               = [x IN split(nullIf(trim(row.notes), ''), '||') | trim(x)]
RETURN
  'Loaded Artifact Data';
