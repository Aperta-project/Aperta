import Ember from 'ember';
import { test, moduleForModel } from 'ember-qunit';
import startApp from 'tahi/tests/helpers/start-app';
import FactoryGuy from 'ember-data-factory-guy';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';

var App;

moduleForModel('paper', 'Unit | Model | paper', {
  needs: ['model:author', 'model:user', 'model:figure', 'model:journal', 'model:decision', 'model:invitation', 'model:affiliation', 'model:attachment', 'model:question-attachment', 'model:comment-look', 'model:discussion-topic', 'model:versioned-text', 'model:discussion-participant', 'model:discussion-reply', 'model:phase', 'model:task', 'model:comment', 'model:participation', 'model:card-thumbnail', 'model:nested-question-owner', 'model:nested-question', 'model:nested-question-answer', 'model:collaboration', 'model:supporting-information-file'],
  afterEach: function() {
    Ember.run(function() {
      return TestHelper.teardown();
    });
    return Ember.run(App, "destroy");
  },
  beforeEach: function() {
    App = startApp();
    return TestHelper.setup(App);
  }
});

test('displayTitle displays [NO TITLE] if title is missing', function(assert) {
  var shortTitle;
  shortTitle = 'test short title';
  var paper = FactoryGuy.make("paper", {
    title: "",
    shortTitle: shortTitle
  });
  assert.equal(paper.get('displayTitle'), "[No Title]");
});

test('displayTitle displays title if present', function(assert) {
  var title;
  title = 'Test Title';
  var paper = FactoryGuy.make("paper", {
    title: title,
    shortTitle: ""
  });
  assert.equal(paper.get('displayTitle'), title);
});

test('previousDecisions returns decisions that are not drafts', function(assert){
  var noVerdictDecision = FactoryGuy.make('decision', 'draft');
  var acceptedDecision = FactoryGuy.make('decision');
  var rejectedDecision = FactoryGuy.make('decision');

  var paper = FactoryGuy.make('paper', {
    decisions: [noVerdictDecision, acceptedDecision, rejectedDecision]
  });

  assert.arrayContainsExactly(
    paper.get('previousDecisions'),
    [acceptedDecision, rejectedDecision]
  );
});

test('simplifiedRelatedUsers contains no collaborators', function(assert) {
  var title;
  title = 'Test Title';
  var paper = FactoryGuy.make('paper', {
    title: title,
    shortTitle: '',
    relatedUsers: [
      {name: 'Creator', users: []},
      {name: 'Collaborator', users: []}
    ]
  });
  assert.equal(paper.get('simplifiedRelatedUsers.length'), 1);
  let remaining = paper.get('simplifiedRelatedUsers').objectAt(0).name;
  assert.equal(remaining, 'Creator');
});

test('decisionsAscending with many decisions, including a draft decision', function(assert) {
  const paper = FactoryGuy.make('paper', {
    decisions: [
      FactoryGuy.make('decision', { majorVersion: 1, minorVersion: 0, draft: false}),
      FactoryGuy.make('decision', { majorVersion: 0, minorVersion: 0, draft: false}),
      FactoryGuy.make('decision', { majorVersion: 0, minorVersion: 1, draft: false}),
      FactoryGuy.make('decision', { majorVersion: null, minorVersion: null, draft: true}),
      FactoryGuy.make('decision', { majorVersion: 1, minorVersion: 1, draft: false})
    ]
  });
  const versions = paper.get('decisionsAscending').map(function(decision) {
    return decision.getProperties('minorVersion', 'majorVersion', 'draft');
  });
  const expectedVersions = [
    { majorVersion: 0, minorVersion: 0, draft: false},
    { majorVersion: 0, minorVersion: 1, draft: false},
    { majorVersion: 1, minorVersion: 0, draft: false},
    { majorVersion: 1, minorVersion: 1, draft: false},
    { majorVersion: null, minorVersion: null, draft: true}
  ];
  assert.deepEqual(versions, expectedVersions);
});

test('latestDecision when there are two decisions', function(assert) {
  const paper = FactoryGuy.make('paper', {
    decisions: [
      FactoryGuy.make('decision', { majorVersion: 1, minorVersion: 0, draft: false}),
      FactoryGuy.make('decision', { majorVersion: 0, minorVersion: 0, draft: false})
    ]
  });
  const version = paper.get('latestDecision').getProperties('majorVersion', 'minorVersion', 'draft');
  const expectedVersion = { majorVersion: 1, minorVersion: 0, draft: false };
  assert.deepEqual(version, expectedVersion);
});

test('latestDecision when there are zero decisions', function(assert) {
  const paper = FactoryGuy.make('paper', {
    decisions: []
  });
  assert.equal(paper.get('latestDecision'), null);
});

test('latestDecision when version numbers change', function(assert) {
  const decisions = [
    FactoryGuy.make('decision', { majorVersion: 1, minorVersion: 0, draft: false }),
    FactoryGuy.make('decision', { majorVersion: 0, minorVersion: 0, draft: false })
  ];
  const paper = FactoryGuy.make('paper', { decisions });
  const version = paper.get('latestDecision').getProperties('majorVersion', 'minorVersion', 'draft');
  const expectedVersion = { majorVersion: 1, minorVersion: 0, draft: false };
  assert.deepEqual(version, expectedVersion);

  // now change the majorVersion of the 0.0 decision so it becomes the latest
  decisions[1].set('majorVersion', 2);
  const mutatedVersion = paper.get('latestDecision').getProperties('majorVersion', 'minorVersion', 'draft');
  const expectedMutatedVersion = { majorVersion: 2, minorVersion: 0, draft: false };
  assert.deepEqual(mutatedVersion, expectedMutatedVersion);
});

['accepted',
  'in_revision',
  'invited_for_full_submission',
  'published',
  'rejected',
  'unsubmitted',
  'withdrawn'].forEach((state)=>{
    test(`isReadyForDecision is false when publishingState is ${state}`, (assert)=>{
      let paper = FactoryGuy.make('paper', { publishingState: state });
      assert.notOk(paper.get('isReadyForDecision'));
    });
  });


['submitted', 'initially_submitted', 'checking'].forEach((state)=>{
  test(`isReadyForDecision is true when publishingState is ${state}`, (assert)=>{
    let paper = FactoryGuy.make('paper', { publishingState: state });
    assert.ok(paper.get('isReadyForDecision'));
  });
});
