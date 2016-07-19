import Ember from 'ember';
import { initialize as initTruthHelpers }  from 'tahi/initializers/truth-helpers';

import {
  moduleForComponent,
  test
} from 'ember-qunit';

import hbs from 'htmlbars-inline-precompile';
import FakeCanService from '../helpers/fake-can-service';

moduleForComponent('revise-task', 'Integration | Component | revise task', {
  integration: true,

  beforeEach() {

    initTruthHelpers();

    this.task = Ember.Object.create({
      isSubmissionTask: true,
      paper: {
        latestRegisteredDecision: {
          majorVersion: 0,
          minorVersion: 0,
          registeredAt: 2,
          save() {
            return Ember.RSVP.resolve();
          }
        }
      },
      body: ['hi'],
      save: function() {
        return {
          then: function(fn) {
            return fn.call();
          }
        };
      }
    });

    this.register('service:can', FakeCanService);
    this.set('task', this.task);
  }
});

test('validations work', function(assert) {
  this.render(hbs`
    {{revise-task task=task isEditable=true}}
  `);

  this.$('#revise-task-save-button').click();
  assert.equal(this.$('.error-message:not(.error-message--hidden)').length, 1,
    'There should be an error message when there is no author response');

  // set the author response
  this.$('#revise-task-edit-button').click();
  $('.revise-overlay-response-field').html('beep').trigger('keyup');
  this.$('#revise-task-save-button').click();

  assert.equal(this.$('.error-message:not(.error-message--hidden)').length, 0,
    'There should not be an error message when there is an author response');
});
