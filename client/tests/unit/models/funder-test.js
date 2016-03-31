import { moduleForModel, test } from 'ember-qunit';
import Ember from 'ember';

moduleForModel('funder', 'Unit | Model | funder', {
  // Specify the other units that are required for this test.
  needs: [
    'model:financial-disclosure-task',
    'model:author',
    'model:nested-question',
    'model:nested-question-answer',
    'model:attachment',
    'model:card-thumbnail',
    'model:comment-look',
    'model:comment',
    'model:paper',
    'model:participation',
    'model:phase',
    'model:snapshot',
    'model:authors-task',
    'model:decision',
    'model:nested-question-answer',
    'model:nested-question-owner',
    'model:question-attachment'
  ]
});

test('it exists', function(assert) {
  let model = this.subject();
  // let store = this.store();
  assert.ok(!!model);
});

test('onlyHasAdditionalComment', function(assert) {
  let model = this.subject();

  // Nothing Set
  assert.notOk(
      model.get('onlyHasAdditionalComments'),
      'Should be false if nothing is set on the model'
  );

  // Only additionalComments Set
  Ember.run(() => {
    model.set('additionalComments', 'Klaatu barada nikto');
  });
  assert.ok(
      model.get('onlyHasAdditionalComments'),
      'Should be true if only the additional comment is set'
  );

  // AdditionalComments and name set
  Ember.run(() => {
    model.set('name', 'Dobis');
  });
  assert.notOk(
    model.get('onlyHasAdditionalComments'),
    'Should be false if additionalComments and name are set'
  );

  // AdditionalComments set and name is ''
  Ember.run(() => {
    model.set('name', '');
  });
  assert.ok(
    model.get('onlyHasAdditionalComments'),
    'Should be true if additionalComments is set and name is an empty string'
  );
});
