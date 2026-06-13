export interface AuthorityListItem {
  authorityId: string;
  title:       string;
  reference:   string | null;
  status:      string[];
  atlasStatus: string[];
}

export interface Authority {
  authorityId:     string;
  title:           string;
  reference:       string | null;
  versionTag:      string | null;
  status:          string[];
  atlasStatus:     string[];
  atlasCategory:   string[] | null;
  type:            string | null;
  ietfStream:      string | null;
  publishedDate:   string | null;
  deprecatedDate:  string | null;
  withdrawnDate:   string | null;
  canonicalUrl:    string | null;
  canonicalFormat: string | null;
  plainTextUrl:    string | null;
  htmlUrl:         string | null;
  otherUrl:        string | null;
  otherFormat:     string | null;
  doi:             string | null;
  notes:           string[] | null;
}

export interface ControllingOrg {
  controllingOrgId: string;
  shortName:        string;
  fullName:         string;
  url:              string | null;
  organizationType: string;
  status:           string[];
  startDate:        string | null;
  endDate:          string | null;
}

export interface AuthorityRelationship {
  relType:                string;
  targetId:               string;
  targetNodeType:         string;
  targetTitle:            string;
  targetRef:              string | null;
  targetAuthoritySection: string[] | null;
  relationship:           string | null;
}

export interface AuthorityBackLink {
  relType:        string;
  sourceId:       string;
  sourceNodeType: string;
  sourceTitle:    string;
  sourceRef:      string | null;
  relationship:   string | null;
}

export interface AuthorityReference {
  targetId:               string;
  targetNodeType:         string;
  targetTitle:            string;
  targetRef:              string | null;
  referenceType:          string | null;
  targetAuthoritySection: string[] | null;
}

export interface ArtifactItem {
  artifactId:      string;
  artifactType:    string;
  artifactSubtype: string | null;
  fullName:        string | null;
  shortName:       string | null;
}

export interface GroupRef {
  groupId:   string;
  reference: string | null;
  title:     string;
}

export interface AuthorityDetail {
  authority:       Authority;
  org:             ControllingOrg | null;
  relationships:   AuthorityRelationship[];
  backLinks:       AuthorityBackLink[];
  references:      AuthorityReference[];
  artifacts:       ArtifactItem[];
  memberOf:        GroupRef[];
  hasDraftHistory: boolean;
}

// ControllingOrg node with hierarchy data (used for grouped list page)
export interface OrgRow {
  orgId:        string;
  shortName:    string;
  fullName:     string | null;
  displayGroup: boolean | null;
  parentIds:    string[];
  successorIds: string[];
}

// A node in the visual display tree built from OrgRow hierarchy
export interface DisplayGroup {
  orgId:    string;
  name:     string;   // fullName ?? shortName
  depth:    number;
  specs:    AuthorityListItem[];
  children: DisplayGroup[];
}
