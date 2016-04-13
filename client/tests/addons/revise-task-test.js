import Ember from 'ember';
import { initialize as initTruthHelpers }  from 'tahi/initializers/truth-helpers';

import {
  moduleForComponent,
  test
} from 'ember-qunit';

import hbs from 'htmlbars-inline-precompile';
import FakeCanService from '../helpers/fake-can-service';

moduleForComponent('revise-task', 'Component: revise-task', {
  integration: true,

  beforeEach() {

    initTruthHelpers();

    this.task = Ember.Object.create({
      isSubmissionTask: true,
      paper: {
        decisions: [{
          revisionNumber: 0,
          save() {
            return Ember.RSVP.resolve();
          }
        }, {
          revisionNumber: 1
        }]
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
  assert.equal(0, this.$('.error-message--hidden').length, 'Error message visible');

  this.$('#revise-task-edit-button').click();
  $('.revise-overlay-response-field').html('beep').trigger('keyup')
  this.$('#revise-task-save-button').click();

  assert.equal(1, this.$('.error-message--hidden').length, 'Error message not visible');
});
