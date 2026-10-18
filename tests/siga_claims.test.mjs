import test from 'node:test';
import assert from 'node:assert/strict';
import { ClaimDenied, execute, transition } from '../tools/siga_claims.mjs';

const SHA_A = 'a'.repeat(40);
const SHA_B = 'b'.repeat(40);
const SHA_C = 'c'.repeat(40);
const base = { action: 'acquire', scope: 'az1nn/meme-mon/SKILLS-001/T-CLAIM',
  owner: 'siga', run: 'run-1', branch: 'spec/skill-architecture-simplification-v1',
  head: SHA_A, ttl: 120 };

class FakeAtomicStore {
  constructor() { this.sha = SHA_B; this.claims = {}; this.head = SHA_A; }
  async snapshot() {
    const current = { sha: this.sha, claims: structuredClone(this.claims) };
    // Let contenders read the exact same state before attempting compare-and-swap.
    await new Promise(resolve => setImmediate(resolve));
    return current;
  }
  async branchSha() { return this.head; }
  async cas(expected, claims, updates) {
    if (expected !== this.sha) throw new ClaimDenied('CAS_CONFLICT_WATCH');
    for (const ref of updates) {
      if (ref.beforeOid !== this.head) throw new ClaimDenied('FEATURE_HEAD_CONFLICT_WATCH');
    }
    this.claims = structuredClone(claims);
    this.sha = this.sha === SHA_B ? SHA_C : SHA_B;
    if (updates.length) this.head = updates[0].afterOid;
  }
}

test('two simultaneous acquire requests: exactly one APPLIED, one WATCH conflict', async () => {
  const store = new FakeAtomicStore();
  const responses = await Promise.allSettled([
    execute(store, { ...base, run: 'a' }, 1_000),
    execute(store, { ...base, run: 'b' }, 1_000)
  ]);
  assert.equal(responses.filter(x => x.status === 'fulfilled').length, 1);
  assert.equal(responses.filter(x => x.status === 'rejected').length, 1);
  assert.equal(responses.find(x => x.status === 'rejected').reason.code, 'CAS_CONFLICT_WATCH');
  assert.equal(store.claims[base.scope].generation, 1);
});

test('active claim cannot be stolen; expired claim requires explicit recovery', () => {
  const first = transition({}, base, 1_000);
  assert.throws(() => transition(first.claims, { ...base, run: 'run-2' }, 5_000),
    { code: 'WATCH_OWNED' });
  assert.throws(() => transition(first.claims, { ...base, run: 'run-2' }, 130_000),
    { code: 'RECOVERY_REQUIRED' });
});

test('stale owner cannot release, renew or advance a current claim', () => {
  const first = transition({}, base, 1_000);
  for (const action of ['release','renew','advance']) {
    assert.throws(() => transition(first.claims, {
      ...base, action, lease: 'stale-lease', nextHead: SHA_C
    }, 2_000), { code: 'STALE_OWNER' });
  }
});

test('renew, then release, then new acquisition increments fence generation', async () => {
  const store = new FakeAtomicStore();
  const one = await execute(store, base, 1_000);
  assert.equal(one.generation, 1);
  const renew = await execute(store, { ...base, action: 'renew', lease: one.lease }, 2_000);
  assert.equal(renew.generation, 1);
  const release = await execute(store, { ...base, action: 'release', lease: one.lease }, 3_000);
  assert.equal(release.status, 'APPLIED');
  const two = await execute(store, { ...base, run: 'run-2' }, 4_000);
  assert.equal(two.generation, 2);
  assert.notEqual(one.lease, two.lease);
  await assert.rejects(execute(store, { ...base, action: 'release', lease: one.lease }, 5_000),
    { code: 'STALE_OWNER' });
});

test('feature-head advance updates work ref and claims in one atomic batch', async () => {
  const store = new FakeAtomicStore();
  const one = await execute(store, base, 1_000);
  await execute(store, { ...base, action: 'advance', lease: one.lease, nextHead: SHA_C }, 2_000);
  assert.equal(store.head, SHA_C);
  assert.equal(store.claims[base.scope].head_sha, SHA_C);
  assert.deepEqual(await execute(store, { ...base, action: 'check', lease: one.lease }, 3_000),
    { status: 'VALID', generation: 1 });
});

test('unfenced external branch drift is rejected; stale advance cannot overwrite', async () => {
  const store = new FakeAtomicStore();
  const one = await execute(store, base, 1_000);
  store.head = SHA_C; // external writer bypassed coordinator
  await assert.rejects(execute(store, { ...base, action: 'check', lease: one.lease }, 2_000),
    { code: 'UNFENCED_BRANCH_DRIFT' });
  await assert.rejects(execute(store, {
    ...base, action: 'advance', lease: one.lease, nextHead: SHA_B
  }, 3_000), { code: 'FEATURE_HEAD_CONFLICT_WATCH' });
  assert.equal(store.claims[base.scope].head_sha, SHA_A);
});


test('reserved master/main/coordinator refs cannot be claimed', () => {
  for (const branch of ['master', 'main', 'siga-claims-v1']) {
    assert.throws(() => transition({}, { ...base, branch }, 1_000), { code: 'PROTECTED_BRANCH' });
  }
});
