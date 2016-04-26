import {
  moduleForComponent,
  test
} from 'ember-qunit';

import Ember from 'ember';
import { initialize as initTruthHelpers }  from 'tahi/initializers/truth-helpers';
import hbs from 'htmlbars-inline-precompile';
import FakeCanService from '../helpers/fake-can-service';
import customAssertions from '../helpers/custom-assertions';

moduleForComponent('paper-sidebar', 'Integration | Component | paper sidebar', {
  integration: true,

  beforeEach() {
    initTruthHelpers();
    customAssertions();
  }
});

test('Shows the submit button when the paper is ready to submit and the user is authorized to submit', function(assert) {

  let template = hbs`{{paper-sidebar paper=paper}}`;

  this.container.register('service:can', FakeCanService);
  let fake = this.container.lookup('service:can');

  this.set('stubAction', function() {});
  let paper = Ember.Object.create({isReadyForSubmission: true});
  this.set('paper', paper);

  fake.allowPermission('submit', paper);
  this.render(template);
  assert.elementFound(
    '#sidebar-submit-paper',
    'the submit button should be visible when the user is authorized'
  );

  fake.rejectPermission('submit');
  this.$().empty();
  this.render(template);
  assert.elementNotFound(
    '#sidebar-submit-paper',
    'the submit button should NOT be visible when the user is unauthorized'
  );

});
