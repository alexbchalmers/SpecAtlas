# Neo4J Three Way Node Relationship Reference

Created from a Copilot discussion to represent an update between a Format and Protocol while noting the source of the change.

``` cypher
CREATE
  (docA:Document {name: 'A'}),
  (docB:Document {name: 'B'}),
  (protoO:Protocol {name: 'O'}),
  (formatAz:Format {name: 'Az'}),
  (formatQ:Format {name: 'Q'});

MATCH
  (docA:Document {name: 'A'}),
  (docB:Document {name: 'B'}),
  (protoO:Protocol {name: 'O'}),
  (formatAz:Format {name: 'Az'}),
  (formatQ:Format {name: 'Q'})
CREATE
  (docA)-[:DEFINES]->(protoO),
  (docA)-[:DEFINES]->(formatAz),
  (formatAz)-[:USES {defined_in: 'A'}]->(formatQ),
  (docB)-[:UPDATES]->(protoO),
  (docB)-[:UPDATES]->(formatAz),
  (formatAz)-[:PROHIBITED_FROM {defined_in: 'B'}]->(formatQ);

MATCH (n) OPTIONAL MATCH (n)-[r]->(m) RETURN n, r, m;

MATCH (doc:Document {name: 'A'})
SET doc.url = "https://sample.org/A";

MATCH (doc:Document {name: 'B'})
SET doc.url = "https://example.org/B";

MATCH (formatAz:Format {name: 'Az'})-[:PROHIBITED_FROM]->(formatQ:Format {name: 'Q'}),
      (doc:Document)-[:UPDATES]->(formatAz),
      (doc)-[:UPDATES]->(:Protocol {name: 'O'})
RETURN doc.name, doc.url;

MATCH (formatAz:Format {name: 'Az'})-[:PROHIBITED_FROM]->(formatQ:Format {name: 'Q'})
WITH formatAz, formatQ
MATCH (formatAz)-[r:PROHIBITED_FROM]->(formatQ)
MATCH (doc:Document {name: r.defined_in})
RETURN doc.name, doc.url;
```
