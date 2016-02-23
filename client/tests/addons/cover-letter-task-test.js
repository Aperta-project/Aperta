import Ember from 'ember';
import {
  moduleForComponent,
  test
} from 'ember-qunit';
import FakeCanService from '../helpers/fake-can-service';


moduleForComponent('cover-letter-task', 'CoverLetterTaskComponent', {
  integration: false,
  beforeEach() {
    this.task = Ember.Object.create({
      isSubmissionTask: true,
      paper: {},
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
    this.inject.service('can', { as: 'can' });
    this.subject().set('task', this.task);
  }
});

test('#letterBody: returns the content of the cover letter', function(assert) {
  assert.equal(this.subject().get('letterBody'), 'hi');
});

test('#saveCoverLetter: model got saved back', function(assert) {
  this.subject().set('editAbility.can', true);

  const handler = function() {};
  sinon.stub(this.task, 'save').returns(
    new Ember.RSVP.Promise(handler, handler)
  );

  this.subject().send('saveCoverLetter');
  assert.ok(this.task.save.called);
});
