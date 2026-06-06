/*******************************************************************************
*
* LoadControllingOrg.cypher
*
* Loads ControllingOrg node data from a CSV file.
*
* Parameters:
*   $controllingOrgDataUrl   URL to the ControllingOrg CSV file
*
* Execution order: 2 of 8 (after GraphTypes.cypher)
*
*******************************************************************************/

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
                                    nullIf(trim(row.shortName), ''),
                                    nullIf(trim(row.fullName), '')
                                  )
      , co.fullName             = nullIf(trim(row.fullName), '')
      , co.url                  = nullIf(trim(row.url), '')
      , co.organizationType     = coalesce(
                                    nullIf(trim(row.organizationType), ''),
                                    'unknown'
                                  )
      , co.status               = coalesce(
                                    [x IN split(row.status, ';') | lower(trim(x))],
                                    ['unknown']
                                  )
      , co.displayGroup         = toBoolean(nullIf(trim(row.displayGroup), ''))
      , co.startDate            = date(nullIf(trim(row.startDate), ''))   // YYYY[-MM[-DD]]
      , co.endDate              = date(nullIf(trim(row.endDate), ''))     // YYYY[-MM[-DD]]
      , co.notes                = [x IN split(nullIf(trim(row.notes), ''), '||') | trim(x)]
RETURN
  'Loaded ControllingOrg Data' AS Action;
