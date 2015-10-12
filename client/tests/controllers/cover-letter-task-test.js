import Ember from 'ember';
import startApp from '../helpers/start-app';
import { test, moduleFor } from 'ember-qunit';

moduleFor('controller:overlays/cover-letter', 'CoverLetterController', {
  needs: ['controller:application'],
  beforeEach: function() {
    startApp();

    this.task = Ember.Object.create({
      isSubmissionTask: true,
      paper: this.paper,
      body: [''],
      save: function() {
        return {
          then: function(fn) {
            return fn.call();
          }
        };
      }
    });

    return Ember.run(()=> {
      this.ctrl = this.subject();
      this.ctrl.set('model', this.task);
    });
  }
});

test('#letterBody: returns the content of the cover letter', function(assert) {
  assert.equal(this.ctrl.get('letterBody'), '');
});

test('#saveCoverLetter: model got saved back', function(assert) {
  const handler = function() {};
  sinon.stub(this.task, 'save').returns(new Ember.RSVP.Promise(handler, handler));

  this.ctrl.send('saveCoverLetter');
  assert.ok(this.task.save.called);
});
