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
  let paper = Ember.Object.create({isReadyForSubmission: true});
  this.set('paper', paper);

  this.registry.register('service:can', FakeCanService);
  let fake = this.container.lookup('service:can');
  fake.allowPermission('submit', paper);

  let template = hbs`{{paper-sidebar paper=paper}}`;
  this.render(template);
  assert.elementFound(
    '#sidebar-submit-paper',
    'the submit button should be visible when the user is authorized'
  );

  fake.rejectPermission('submit');
  this.$().empty(); // this.render() only appends to the test container
  this.render(template);
  assert.elementNotFound(
    '#sidebar-submit-paper',
    'the submit button should NOT be visible when the user is unauthorized'
  );

});
