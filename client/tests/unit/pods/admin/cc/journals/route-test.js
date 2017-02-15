import { moduleFor, test } from 'ember-qunit';

moduleFor('route:admin.cc.journals', 'Unit | Route | Journal', {
});

test('with one journal, redirects to specific journal route', function(assert) {
  assert.expect(1);

  const transitionTo = function() { assert.ok(true, 'transitionTo was called'); };

  let route = this.subject({ transitionTo: transitionTo });
  const model = { journals: [ { id: 3 } ], journal: null };
  route.afterModel(model);
});

test('with multiple journals, redirects to all journals route', function(assert) {
  assert.expect(1);

  const transitionTo = function() { assert.ok(false, 'transitionTo was called'); };

  let route = this.subject({ transitionTo: transitionTo });
  const model = { journals: [ { id: 3 }, { id: 5 } ], journal: { id: 3 } };
  route.afterModel(model);

  assert.ok(true);
});
