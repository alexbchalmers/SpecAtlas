/*******************************************************************************
*
* LoadRelationships.cypher
*
* Loads all relationship data from a CSV file.
*
* Parameters:
*   $relationshipDataUrl   URL to the Relationships CSV file
*
* Execution order: 8 of 8 (after all node load scripts)
*
* CSV columns:
*   relationshipId, createdTimestamp, updatedTimestamp,
*   relationshipType,
*   sourceNodeType, sourceNodeAttr, sourceNodeValue,
*   targetNodeType, targetNodeAttr, targetNodeValue,
*   affiliation, referenceType,
*   sourceAuthoritySection, targetAuthoritySection,
*   relationship, notes
*
* Node matching strategy:
*   ControllingOrg and Artifact are matched by shortName.
*   All Authority node types are matched by reference.
*   The sourceNodeAttr and targetNodeAttr columns are not used.
*
*******************************************************************************/

LOAD CSV WITH HEADERS FROM $relationshipDataUrl AS row

// Match source node by type
OPTIONAL MATCH (src_co:ControllingOrg)
  WHERE row.sourceNodeType = 'ControllingOrg'
    AND src_co.shortName = row.sourceNodeValue
OPTIONAL MATCH (src_a:Authority)
  WHERE row.sourceNodeType = 'Authority'
    AND src_a.reference = row.sourceNodeValue
OPTIONAL MATCH (src_ag:AuthorityGroup)
  WHERE row.sourceNodeType = 'AuthorityGroup'
    AND src_ag.reference = row.sourceNodeValue
OPTIONAL MATCH (src_ad:AuthorityDraft)
  WHERE row.sourceNodeType = 'AuthorityDraft'
    AND src_ad.reference = row.sourceNodeValue
OPTIONAL MATCH (src_adr:AuthorityDraftRevision)
  WHERE row.sourceNodeType = 'AuthorityDraftRevision'
    AND src_adr.reference = row.sourceNodeValue
OPTIONAL MATCH (src_art:Artifact)
  WHERE row.sourceNodeType = 'Artifact'
    AND src_art.shortName = row.sourceNodeValue

// Match target node by type
OPTIONAL MATCH (tgt_co:ControllingOrg)
  WHERE row.targetNodeType = 'ControllingOrg'
    AND tgt_co.shortName = row.targetNodeValue
OPTIONAL MATCH (tgt_a:Authority)
  WHERE row.targetNodeType = 'Authority'
    AND tgt_a.reference = row.targetNodeValue
OPTIONAL MATCH (tgt_ag:AuthorityGroup)
  WHERE row.targetNodeType = 'AuthorityGroup'
    AND tgt_ag.reference = row.targetNodeValue
OPTIONAL MATCH (tgt_ad:AuthorityDraft)
  WHERE row.targetNodeType = 'AuthorityDraft'
    AND tgt_ad.reference = row.targetNodeValue
OPTIONAL MATCH (tgt_adr:AuthorityDraftRevision)
  WHERE row.targetNodeType = 'AuthorityDraftRevision'
    AND tgt_adr.reference = row.targetNodeValue
OPTIONAL MATCH (tgt_art:Artifact)
  WHERE row.targetNodeType = 'Artifact'
    AND tgt_art.shortName = row.targetNodeValue

WITH row,
     coalesce(src_co, src_a, src_ag, src_ad, src_adr, src_art) AS source,
     coalesce(tgt_co, tgt_a, tgt_ag, tgt_ad, tgt_adr, tgt_art) AS target
WHERE source IS NOT NULL AND target IS NOT NULL

CALL (*) {
  WHEN row.relationshipType = 'HAS_CHILD_ORG' THEN {
    MERGE (source)-[r:HAS_CHILD_ORG {
      relationshipId: coalesce(lower(trim(row.relationshipId)), randomUUID())
    }]->(target)
      ON CREATE
        SET
          r.createdTimestamp  = coalesce(datetime(trim(row.createdTimestamp)), datetime())
          , r.updatedTimestamp = coalesce(datetime(trim(row.updatedTimestamp)), datetime())
          , r.notes           = [x IN split(nullIf(trim(row.notes), ''), '||') | trim(x)]
  }
  WHEN row.relationshipType = 'PREVIOUSLY_KNOWN_AS' THEN {
    MERGE (source)-[r:PREVIOUSLY_KNOWN_AS {
      relationshipId: coalesce(lower(trim(row.relationshipId)), randomUUID())
    }]->(target)
      ON CREATE
        SET
          r.createdTimestamp  = coalesce(datetime(trim(row.createdTimestamp)), datetime())
          , r.updatedTimestamp = coalesce(datetime(trim(row.updatedTimestamp)), datetime())
          , r.notes           = [x IN split(nullIf(trim(row.notes), ''), '||') | trim(x)]
  }
  WHEN row.relationshipType = 'SUCCEEDED_ORG' THEN {
    MERGE (source)-[r:SUCCEEDED_ORG {
      relationshipId: coalesce(lower(trim(row.relationshipId)), randomUUID())
    }]->(target)
      ON CREATE
        SET
          r.createdTimestamp  = coalesce(datetime(trim(row.createdTimestamp)), datetime())
          , r.updatedTimestamp = coalesce(datetime(trim(row.updatedTimestamp)), datetime())
          , r.notes           = [x IN split(nullIf(trim(row.notes), ''), '||') | trim(x)]
  }
  WHEN row.relationshipType = 'HAS_AFFILIATE_ORG' THEN {
    MERGE (source)-[r:HAS_AFFILIATE_ORG {
      relationshipId: coalesce(lower(trim(row.relationshipId)), randomUUID())
    }]->(target)
      ON CREATE
        SET
          r.createdTimestamp  = coalesce(datetime(trim(row.createdTimestamp)), datetime())
          , r.updatedTimestamp = coalesce(datetime(trim(row.updatedTimestamp)), datetime())
          , r.affiliation     = coalesce(lower(trim(row.affiliation)), 'unknown')
          , r.notes           = [x IN split(nullIf(trim(row.notes), ''), '||') | trim(x)]
  }
  WHEN row.relationshipType = 'CONTROLS' THEN {
    MERGE (source)-[r:CONTROLS {
      relationshipId: coalesce(lower(trim(row.relationshipId)), randomUUID())
    }]->(target)
      ON CREATE
        SET
          r.createdTimestamp  = coalesce(datetime(trim(row.createdTimestamp)), datetime())
          , r.updatedTimestamp = coalesce(datetime(trim(row.updatedTimestamp)), datetime())
          , r.notes           = [x IN split(nullIf(trim(row.notes), ''), '||') | trim(x)]
  }
  WHEN row.relationshipType = 'MEMBER_OF' THEN {
    MERGE (source)-[r:MEMBER_OF {
      relationshipId: coalesce(lower(trim(row.relationshipId)), randomUUID())
    }]->(target)
      ON CREATE
        SET
          r.createdTimestamp  = coalesce(datetime(trim(row.createdTimestamp)), datetime())
          , r.updatedTimestamp = coalesce(datetime(trim(row.updatedTimestamp)), datetime())
          , r.notes           = [x IN split(nullIf(trim(row.notes), ''), '||') | trim(x)]
  }
  WHEN row.relationshipType = 'REPLACES' THEN {
    MERGE (source)-[r:REPLACES {
      relationshipId: coalesce(lower(trim(row.relationshipId)), randomUUID())
    }]->(target)
      ON CREATE
        SET
          r.createdTimestamp  = coalesce(datetime(trim(row.createdTimestamp)), datetime())
          , r.updatedTimestamp = coalesce(datetime(trim(row.updatedTimestamp)), datetime())
          , r.notes           = [x IN split(nullIf(trim(row.notes), ''), '||') | trim(x)]
  }
  WHEN row.relationshipType = 'UPDATES' THEN {
    MERGE (source)-[r:UPDATES {
      relationshipId: coalesce(lower(trim(row.relationshipId)), randomUUID())
    }]->(target)
      ON CREATE
        SET
          r.createdTimestamp  = coalesce(datetime(trim(row.createdTimestamp)), datetime())
          , r.updatedTimestamp = coalesce(datetime(trim(row.updatedTimestamp)), datetime())
          , r.notes           = [x IN split(nullIf(trim(row.notes), ''), '||') | trim(x)]
  }
  WHEN row.relationshipType = 'CORRECTS' THEN {
    MERGE (source)-[r:CORRECTS {
      relationshipId: coalesce(lower(trim(row.relationshipId)), randomUUID())
    }]->(target)
      ON CREATE
        SET
          r.createdTimestamp  = coalesce(datetime(trim(row.createdTimestamp)), datetime())
          , r.updatedTimestamp = coalesce(datetime(trim(row.updatedTimestamp)), datetime())
          , r.notes           = [x IN split(nullIf(trim(row.notes), ''), '||') | trim(x)]
  }
  WHEN row.relationshipType = 'SUPERSEDES' THEN {
    MERGE (source)-[r:SUPERSEDES {
      relationshipId: coalesce(lower(trim(row.relationshipId)), randomUUID())
    }]->(target)
      ON CREATE
        SET
          r.createdTimestamp        = coalesce(datetime(trim(row.createdTimestamp)), datetime())
          , r.updatedTimestamp      = coalesce(datetime(trim(row.updatedTimestamp)), datetime())
          , r.sourceAuthoritySection =
              [x IN split(nullIf(trim(row.sourceAuthoritySection), ''), ';') | trim(x)]
          , r.targetAuthoritySection =
              [x IN split(nullIf(trim(row.targetAuthoritySection), ''), ';') | trim(x)]
          , r.notes                 = [x IN split(nullIf(trim(row.notes), ''), '||') | trim(x)]
  }
  WHEN row.relationshipType = 'OBSOLETES' THEN {
    MERGE (source)-[r:OBSOLETES {
      relationshipId: coalesce(lower(trim(row.relationshipId)), randomUUID())
    }]->(target)
      ON CREATE
        SET
          r.createdTimestamp        = coalesce(datetime(trim(row.createdTimestamp)), datetime())
          , r.updatedTimestamp      = coalesce(datetime(trim(row.updatedTimestamp)), datetime())
          , r.sourceAuthoritySection =
              [x IN split(nullIf(trim(row.sourceAuthoritySection), ''), ';') | trim(x)]
          , r.targetAuthoritySection =
              [x IN split(nullIf(trim(row.targetAuthoritySection), ''), ';') | trim(x)]
          , r.notes                 = [x IN split(nullIf(trim(row.notes), ''), '||') | trim(x)]
  }
  WHEN row.relationshipType = 'DEPRECATES' THEN {
    MERGE (source)-[r:DEPRECATES {
      relationshipId: coalesce(lower(trim(row.relationshipId)), randomUUID())
    }]->(target)
      ON CREATE
        SET
          r.createdTimestamp        = coalesce(datetime(trim(row.createdTimestamp)), datetime())
          , r.updatedTimestamp      = coalesce(datetime(trim(row.updatedTimestamp)), datetime())
          , r.sourceAuthoritySection =
              [x IN split(nullIf(trim(row.sourceAuthoritySection), ''), ';') | trim(x)]
          , r.targetAuthoritySection =
              [x IN split(nullIf(trim(row.targetAuthoritySection), ''), ';') | trim(x)]
          , r.notes                 = [x IN split(nullIf(trim(row.notes), ''), '||') | trim(x)]
  }
  WHEN row.relationshipType = 'HAS_RELATED_AUTHORITY' THEN {
    MERGE (source)-[r:HAS_RELATED_AUTHORITY {
      relationshipId: coalesce(lower(trim(row.relationshipId)), randomUUID())
    }]->(target)
      ON CREATE
        SET
          r.createdTimestamp        = coalesce(datetime(trim(row.createdTimestamp)), datetime())
          , r.updatedTimestamp      = coalesce(datetime(trim(row.updatedTimestamp)), datetime())
          , r.relationship          = lower(trim(row.relationship))
          , r.sourceAuthoritySection =
              [x IN split(nullIf(trim(row.sourceAuthoritySection), ''), ';') | trim(x)]
          , r.targetAuthoritySection =
              [x IN split(nullIf(trim(row.targetAuthoritySection), ''), ';') | trim(x)]
          , r.notes                 = [x IN split(nullIf(trim(row.notes), ''), '||') | trim(x)]
  }
  WHEN row.relationshipType = 'REFERENCES' THEN {
    MERGE (source)-[r:REFERENCES {
      relationshipId: coalesce(lower(trim(row.relationshipId)), randomUUID())
    }]->(target)
      ON CREATE
        SET
          r.createdTimestamp        = coalesce(datetime(trim(row.createdTimestamp)), datetime())
          , r.updatedTimestamp      = coalesce(datetime(trim(row.updatedTimestamp)), datetime())
          , r.referenceType         = nullIf(lower(trim(row.referenceType)), '')
          , r.targetAuthoritySection =
              [x IN split(nullIf(trim(row.targetAuthoritySection), ''), ';') | trim(x)]
          , r.notes                 = [x IN split(nullIf(trim(row.notes), ''), '||') | trim(x)]
  }
  WHEN row.relationshipType = 'DRAFTED_BY' THEN {
    MERGE (source)-[r:DRAFTED_BY {
      relationshipId: coalesce(lower(trim(row.relationshipId)), randomUUID())
    }]->(target)
      ON CREATE
        SET
          r.createdTimestamp  = coalesce(datetime(trim(row.createdTimestamp)), datetime())
          , r.updatedTimestamp = coalesce(datetime(trim(row.updatedTimestamp)), datetime())
          , r.notes           = [x IN split(nullIf(trim(row.notes), ''), '||') | trim(x)]
  }
  WHEN row.relationshipType = 'HAS_REVISION' THEN {
    MERGE (source)-[r:HAS_REVISION {
      relationshipId: coalesce(lower(trim(row.relationshipId)), randomUUID())
    }]->(target)
      ON CREATE
        SET
          r.createdTimestamp  = coalesce(datetime(trim(row.createdTimestamp)), datetime())
          , r.updatedTimestamp = coalesce(datetime(trim(row.updatedTimestamp)), datetime())
          , r.notes           = [x IN split(nullIf(trim(row.notes), ''), '||') | trim(x)]
  }
  WHEN row.relationshipType = 'DEFINES' THEN {
    MERGE (source)-[r:DEFINES {
      relationshipId: coalesce(lower(trim(row.relationshipId)), randomUUID())
    }]->(target)
      ON CREATE
        SET
          r.createdTimestamp        = coalesce(datetime(trim(row.createdTimestamp)), datetime())
          , r.updatedTimestamp      = coalesce(datetime(trim(row.updatedTimestamp)), datetime())
          , r.sourceAuthoritySection =
              [x IN split(nullIf(trim(row.sourceAuthoritySection), ''), ';') | trim(x)]
          , r.notes                 = [x IN split(nullIf(trim(row.notes), ''), '||') | trim(x)]
  }
  WHEN row.relationshipType = 'PROFILES' THEN {
    MERGE (source)-[r:PROFILES {
      relationshipId: coalesce(lower(trim(row.relationshipId)), randomUUID())
    }]->(target)
      ON CREATE
        SET
          r.createdTimestamp  = coalesce(datetime(trim(row.createdTimestamp)), datetime())
          , r.updatedTimestamp = coalesce(datetime(trim(row.updatedTimestamp)), datetime())
          , r.notes           = [x IN split(nullIf(trim(row.notes), ''), '||') | trim(x)]
  }
  WHEN row.relationshipType = 'VERSION_OF' THEN {
    MERGE (source)-[r:VERSION_OF {
      relationshipId: coalesce(lower(trim(row.relationshipId)), randomUUID())
    }]->(target)
      ON CREATE
        SET
          r.createdTimestamp  = coalesce(datetime(trim(row.createdTimestamp)), datetime())
          , r.updatedTimestamp = coalesce(datetime(trim(row.updatedTimestamp)), datetime())
          , r.notes           = [x IN split(nullIf(trim(row.notes), ''), '||') | trim(x)]
  }
  WHEN row.relationshipType = 'VARIANT_OF' THEN {
    MERGE (source)-[r:VARIANT_OF {
      relationshipId: coalesce(lower(trim(row.relationshipId)), randomUUID())
    }]->(target)
      ON CREATE
        SET
          r.createdTimestamp  = coalesce(datetime(trim(row.createdTimestamp)), datetime())
          , r.updatedTimestamp = coalesce(datetime(trim(row.updatedTimestamp)), datetime())
          , r.notes           = [x IN split(nullIf(trim(row.notes), ''), '||') | trim(x)]
  }
  WHEN row.relationshipType = 'ADOPTED_BY' THEN {
    MERGE (source)-[r:ADOPTED_BY {
      relationshipId: coalesce(lower(trim(row.relationshipId)), randomUUID())
    }]->(target)
      ON CREATE
        SET
          r.createdTimestamp  = coalesce(datetime(trim(row.createdTimestamp)), datetime())
          , r.updatedTimestamp = coalesce(datetime(trim(row.updatedTimestamp)), datetime())
          , r.notes           = [x IN split(nullIf(trim(row.notes), ''), '||') | trim(x)]
  }
  WHEN row.relationshipType = 'REVISES' THEN {
    MERGE (source)-[r:REVISES {
      relationshipId: coalesce(lower(trim(row.relationshipId)), randomUUID())
    }]->(target)
      ON CREATE
        SET
          r.createdTimestamp  = coalesce(datetime(trim(row.createdTimestamp)), datetime())
          , r.updatedTimestamp = coalesce(datetime(trim(row.updatedTimestamp)), datetime())
          , r.notes           = [x IN split(nullIf(trim(row.notes), ''), '||') | trim(x)]
  }
}
RETURN
  'Loaded Relationship Data' AS Action;
