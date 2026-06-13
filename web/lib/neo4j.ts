import neo4j, { type Driver } from 'neo4j-driver';

let _driver: Driver | undefined;

function getDriver(): Driver {
  if (!_driver) {
    _driver = neo4j.driver(
      process.env.NEO4J_URI!,
      neo4j.auth.basic(process.env.NEO4J_USERNAME!, process.env.NEO4J_PASSWORD!)
    );
  }
  return _driver;
}

// Recursively converts Neo4j-specific types to plain JS values.
// Handles: Integer → number, Node → properties object, Date/DateTime → ISO string, Array/Object → recurse.
// eslint-disable-next-line @typescript-eslint/no-explicit-any
function toPlain(val: any): unknown {
  if (val === null || val === undefined) return null;
  if (typeof val !== 'object')           return val;
  if (Array.isArray(val))                return val.map(toPlain);

  // Neo4j Integer: { low, high, toNumber() }
  if ('low' in val && 'high' in val && typeof val.toNumber === 'function') {
    return val.toNumber() as number;
  }

  // Neo4j Node: { identity, labels, properties }
  if ('labels' in val && 'properties' in val) {
    return toPlain(val.properties);
  }

  // Neo4j temporal types (Date, DateTime, etc.) — class instances with meaningful toString()
  const ctorName = (val as object).constructor?.name ?? 'Object';
  if (ctorName !== 'Object') {
    return String(val);
  }

  const out: Record<string, unknown> = {};
  for (const [k, v] of Object.entries(val as Record<string, unknown>)) {
    out[k] = toPlain(v);
  }
  return out;
}

export async function runQuery<T = Record<string, unknown>>(
  cypher: string,
  params: Record<string, unknown> = {}
): Promise<T[]> {
  const session = getDriver().session();
  try {
    const result = await session.run(cypher, params);
    return result.records.map(record => toPlain(record.toObject()) as T);
  } finally {
    await session.close();
  }
}
