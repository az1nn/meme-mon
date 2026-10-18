// SKILLS-001 experimental distributed claim coordinator.
// GitHub GraphQL updateRefs(beforeOid) is the ONLY commit mechanism.
// No REST PATCH fallback; all errors fail closed.
import { randomUUID } from 'node:crypto';

export class ClaimDenied extends Error {
  constructor(code) { super(code); this.code = code; }
}
const fail = (code) => { throw new ClaimDenied(code); };
const validSha = (s) => typeof s === 'string' && /^[a-f0-9]{40}$/.test(s);
const validName = (s) => typeof s === 'string' && /^[a-zA-Z0-9._/-]{1,160}$/.test(s) && !s.includes('..');
const ZERO = '0000000000000000000000000000000000000000';
const REF = 'refs/heads/siga-claims-v1';
const FILE = '.siga/claims.json';
const MAX_TTL = 3600;

export function transition(claims, cmd, clock = Date.now()) {
  const { action, scope, owner, run, lease, branch, head, nextHead } = cmd;
  if (!validName(scope) || !validName(owner) || !validName(run)) fail('INVALID_IDENTITY');
  const copy = structuredClone(claims);
  const old = copy[scope];
  const active = old?.state === 'active';
  const expired = active && old.expires_at <= clock;
  const ttl = cmd.ttl ?? 900;
  if (!Number.isInteger(ttl) || ttl < 60 || ttl > MAX_TTL) fail('INVALID_TTL');
  if (action === 'acquire') {
    if (!validName(branch) || !validSha(head)) fail('INVALID_HEAD');
    if (active) fail(expired ? 'RECOVERY_REQUIRED' : 'WATCH_OWNED');
    const token = randomUUID();
    copy[scope] = {
      state: 'active', owner, run, lease: token, branch, head_sha: head,
      generation: (old?.generation ?? 0) + 1, expires_at: clock + ttl * 1000
    };
    return { claims: copy, token, refUpdates: [] };
  }
  if (!active || expired) fail(expired ? 'LEASE_EXPIRED' : 'NO_ACTIVE_CLAIM');
  if (old.owner !== owner || old.run !== run || old.lease !== lease) fail('STALE_OWNER');
  if (action === 'check') return { claims: copy, token: lease, refUpdates: [], readOnly: true };
  if (action === 'renew') {
    old.expires_at = clock + ttl * 1000;
    return { claims: copy, token: lease, refUpdates: [] };
  }
  if (action === 'release') {
    old.state = 'released';
    old.expires_at = clock;
    return { claims: copy, token: lease, refUpdates: [] };
  }
  if (action === 'advance') {
    if (!validSha(nextHead) || nextHead === old.head_sha) fail('INVALID_NEXT_HEAD');
    // A mutation of a work ref MUST travel in the SAME atomic GraphQL batch.
    const previous = old.head_sha;
    old.head_sha = nextHead;
    old.expires_at = clock + ttl * 1000;
    return {
      claims: copy, token: lease,
      refUpdates: [{ name: 'refs/heads/' + old.branch, beforeOid: previous, afterOid: nextHead, force: false }]
    };
  }
  fail('INVALID_ACTION');
}

export async function execute(store, cmd, clock = Date.now()) {
  const snap = await store.snapshot();
  if (!snap) fail('COORDINATOR_NOT_INITIALIZED');
  const result = transition(snap.claims, cmd, clock);
  if (result.readOnly) {
    // Fail closed if work branch has moved outside a fenced update.
    const actual = await store.branchSha(result.claims[cmd.scope].branch);
    if (actual !== result.claims[cmd.scope].head_sha) fail('UNFENCED_BRANCH_DRIFT');
    return { status: 'VALID', generation: result.claims[cmd.scope].generation };
  }
  if (cmd.action === 'acquire') {
    const actual = await store.branchSha(cmd.branch);
    if (actual !== cmd.head) fail('STALE_HEAD');
  }
  await store.cas(snap.sha, result.claims, result.refUpdates);
  return { status: 'APPLIED', lease: result.token, generation: result.claims[cmd.scope].generation };
}

export class GitHubClaimStore {
  constructor(repo, token, http = fetch) {
    if (!/^[\w.-]+\/[\w.-]+$/.test(repo) || !token) fail('CONFIG_REQUIRED');
    this.repo = repo; this.token = token; this.http = http;
  }
  async request(method, path, body, nullable = false) {
    const endpoint = path === '/graphql' ? 'https://api.github.com/graphql' :
      'https://api.github.com/repos/' + this.repo + path;
    const response = await this.http(endpoint, {
      method,
      headers: { 'Authorization': 'Bearer ' + this.token,
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2026-03-10',
        'Content-Type': 'application/json' },
      ...(body === undefined ? {} : { body: JSON.stringify(body) })
    });
    if (nullable && response.status === 404) return null;
    if (!response.ok) fail('GITHUB_HTTP_' + response.status);
    const data = await response.json();
    if (data.errors?.length) fail('GRAPHQL_REJECTED');
    return data;
  }
  async branchSha(branch) {
    if (!validName(branch)) fail('INVALID_BRANCH');
    const ref = await this.request('GET', '/git/ref/heads/' + branch, undefined, true);
    return ref?.object?.sha ?? null;
  }
  async snapshot() {
    const sha = await this.branchSha('siga-claims-v1');
    if (!sha) return null;
    const data = await this.request('GET', '/contents/' + FILE + '?ref=siga-claims-v1', undefined, true);
    if (!data) return { sha, claims: {} };
    if (data.encoding !== 'base64') fail('INVALID_STORE_ENCODING');
    let claims;
    try { claims = JSON.parse(Buffer.from(data.content, 'base64').toString('utf8')); }
    catch { fail('INVALID_STORE_JSON'); }
    if (!claims || Array.isArray(claims) || typeof claims !== 'object') fail('INVALID_STORE_FORMAT');
    return { sha, claims };
  }
  async cas(expected, claims, extraRefs = []) {
    if (!validSha(expected)) fail('INVALID_EXPECTED_REF');
    const commit = await this.request('GET', '/git/commits/' + expected);
    const blob = await this.request('POST', '/git/blobs', { content: JSON.stringify(claims, null, 2) + '\n', encoding: 'utf-8' });
    const tree = await this.request('POST', '/git/trees', {
      base_tree: commit.tree.sha,
      tree: [{ path: FILE, mode: '100644', type: 'blob', sha: blob.sha }]
    });
    const next = await this.request('POST', '/git/commits', {
      message: 'chore(siga): fenced claim state transition',
      tree: tree.sha, parents: [expected]
    });
    const metadata = await this.request('GET', '');
    const updates = [{ name: REF, beforeOid: expected, afterOid: next.sha, force: false }, ...extraRefs];
    // beforeOid for EVERY ref: conflict changes nothing, including the branch head.
    await this.request('POST', '/graphql', {
      query: 'mutation($input:UpdateRefsInput!){updateRefs(input:$input){clientMutationId}}',
      variables: { input: { repositoryId: metadata.node_id, refUpdates: updates } }
    });
    return next.sha;
  }
  async bootstrap() {
    if (await this.snapshot()) fail('ALREADY_INITIALIZED');
    const metadata = await this.request('GET', '');
    const head = await this.branchSha(metadata.default_branch);
    if (!head) fail('DEFAULT_HEAD_MISSING');
    // Conditional creation: only one contender may create the claims ref.
    await this.request('POST', '/graphql', {
      query: 'mutation($input:UpdateRefsInput!){updateRefs(input:$input){clientMutationId}}',
      variables: { input: { repositoryId: metadata.node_id,
        refUpdates: [{ name: REF, beforeOid: ZERO, afterOid: head, force: false }] } }
    });
  }
}

async function main(argv) {
  const action = argv[0];
  const options = {};
  for (let i = 1; i < argv.length; i += 2) {
    if (!argv[i].startsWith('--') || i + 1 >= argv.length) fail('INVALID_ARGUMENTS');
    options[argv[i].slice(2).replaceAll('-', '_')] = argv[i + 1];
  }
  const token = process.env.SIGA_GITHUB_TOKEN || process.env.GITHUB_TOKEN;
  const repo = options.repo || process.env.GITHUB_REPOSITORY;
  const store = new GitHubClaimStore(repo, token);
  if (action === 'init') {
    await store.bootstrap();
    console.log(JSON.stringify({ status: 'INITIALIZED' }));
    return;
  }
  const output = await execute(store, {
    action, scope: options.scope, owner: options.owner, run: options.run,
    lease: options.lease, branch: options.branch, head: options.head,
    nextHead: options.next_head,
    ...(options.ttl ? { ttl: Number(options.ttl) } : {})
  });
  console.log(JSON.stringify(output));
}
if (process.argv[1] && import.meta.url === new URL('file://' + process.argv[1]).href) {
  main(process.argv.slice(2)).catch((err) => {
    console.error(JSON.stringify({ status: 'WATCH', reason: err.code || 'UNKNOWN_ERROR' }));
    process.exitCode = 2;
  });
}
