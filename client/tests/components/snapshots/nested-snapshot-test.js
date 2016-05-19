import {moduleForComponent, test} from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import registerDiffAssertions from 'tahi/tests/helpers/diff-assertions';

moduleForComponent('nested-snapshot',
                   'Integration | Component | nested snapshot',
                   {integration: true,
                    beforeEach: function() {
                      registerDiffAssertions();
                    }});

var snapshot = function (){
  return {
    name: 'reviewer-recommendation',
    type: 'properties',
    children: [
      {
        name: 'reviewer_recommendations--recommend_or_oppose',
        type: 'question',
        value: {
          id: 137,
          title: 'Question Text',
          answer_type: 'text',
          answer: 'this is my answer',
          attachments: []
        },
        children: []
      },
      { name: 'id', type: 'integer', value: 11 },
      { name: 'first_name', type: 'text', value: 'Nancy' },
      { name: 'last_name', type: 'text', value: 'McReviewer' },
      { name: 'email', type: 'text', value: 'nancy@science.org' },
      { name: 'affiliation', type: 'text', value: null },
      { name: 'active', type: 'boolean', value: false }
    ]
  }
};

var template = hbs`{{nested-snapshot
                     snapshot1=newSnapshot
                     snapshot2=oldSnapshot}}`;

test('no diff, no added or removed', function(assert){
  this.set('oldSnapshot', snapshot());
  this.set('newSnapshot', snapshot());

  this.render(template);
  assert.equal(this.$('.added').length, 0, 'Has no added diff spans');
  assert.equal(this.$('.removed').length, 0, 'Has removed diff spans');
});

test('does not display the id', function(assert){
  this.set('oldSnapshot', snapshot());
  this.set('newSnapshot', snapshot());

  this.render(template);
  assert.textNotPresent('.snapshot-label', 'Id:');
});

test('diffs a text value', function(assert){
  let changededSnapshot = snapshot();
  changededSnapshot.children[3].value = 'New Last Name';

  this.set('oldSnapshot', snapshot());
  this.set('newSnapshot', changededSnapshot);

  this.render(template);
  assert.diffPresent('McReviewer', 'New Last Name');
});

test('diffs a boolean value', function(assert){
  let changededSnapshot = snapshot();
  changededSnapshot.children[6].value = true;
  changededSnapshot.children[6].value = true;

  this.set('oldSnapshot', snapshot());
  this.set('newSnapshot', changededSnapshot);

  this.render(template);
  assert.diffPresent('No', 'Yes');
});

test('diffs a question answer', function(assert){
  let changededSnapshot = snapshot();
  changededSnapshot.children[0].value.answer = 'updated answer';

  this.set('oldSnapshot', snapshot());
  this.set('newSnapshot', changededSnapshot);

  this.render(template);
  assert.diffPresent('this is my answer', 'updated answer');
});

test('diffs a question title when changed', function(assert){
  let changededSnapshot = snapshot();
  changededSnapshot.children[0].value.title = 'New Question Text';

  this.set('oldSnapshot', snapshot());
  this.set('newSnapshot', changededSnapshot);

  this.render(template);
  assert.diffPresent('Question Text', 'New Question Text');
});

test('does not diff a question title for added records', function(assert){
  let emptySnapshotChildren = snapshot();
  emptySnapshotChildren.children = [];

  this.set('oldSnapshot', emptySnapshotChildren);
  this.set('newSnapshot', snapshot());

  this.render(template);
  assert.notDiffed('Question Text');
});

test('does not diff a question title for removed records', function(assert){
  let emptySnapshotChildren = snapshot();
  emptySnapshotChildren.children = [];

  this.set('oldSnapshot', snapshot());
  this.set('newSnapshot', emptySnapshotChildren);

  this.render(template);
  assert.notDiffed('Question Text');
});

test('diffs through children - same number in each snapshot', function(assert){
  this.set('oldSnapshot', snapshot());
  this.set('newSnapshot', snapshot());

  this.render(template);
  assert.equal(this.$('.snapshot').length, 8, 'Has loaded all children');
});

test('diffs through children - one more child in snapshot1', function(assert){
  let expandedSnapshot = snapshot();
  expandedSnapshot.children.push(
    { name: 'middle_initial', type: 'text', value: 'A' }
  );

  this.set('oldSnapshot', expandedSnapshot);
  this.set('newSnapshot', snapshot());

  this.render(template);
  assert.equal(this.$('.snapshot').length, 9, 'Has loaded all children');
});

test('diffs through children - one more child in snapshot2', function(assert){
  let expandedSnapshot = snapshot();
  expandedSnapshot.children.push(
    { name: 'middle_initial', type: 'text', value: 'A' }
  );

  this.set('oldSnapshot', snapshot());
  this.set('newSnapshot', expandedSnapshot);

  this.render(template);
  assert.equal(this.$('.snapshot').length, 9, 'Has loaded all children');
});

test('diffs through snapshot1 children when snapshot2 children is empty', function(assert){
  let emptySnapshotChildren = snapshot();
  emptySnapshotChildren.children = [];

  this.set('oldSnapshot', snapshot());
  this.set('newSnapshot', emptySnapshotChildren);

  this.render(template);
  assert.equal(this.$('.snapshot').length, 8, 'Has loaded all children');
});

test('diffs through snapshot2 children when snapshot1 children is empty', function(assert){
  let emptySnapshotChildren = snapshot();
  emptySnapshotChildren.children = [];

  this.set('oldSnapshot', emptySnapshotChildren);
  this.set('newSnapshot', snapshot());

  this.render(template);
  assert.equal(this.$('.snapshot').length, 8, 'Has loaded all children');
});
