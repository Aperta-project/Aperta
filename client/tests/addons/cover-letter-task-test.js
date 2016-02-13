import Ember from 'ember';
import {
  moduleForComponent,
  test
} from 'ember-qunit';
import FakeCanService from '../helpers/fake-can-service';

let c;

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

    this.fakeCanService = FakeCanService.create()
      .allowPermission('view', this.task);

    c = this.subject();
    c.set('can', this.fakeCanService);
    c.set('task', this.task);
  },

  afterEach() {
    c = null;
  }
});

test('#letterBody: returns the content of the cover letter', function(assert) {
  assert.equal(c.get('letterBody'), 'hi');
});

test('#saveCoverLetter: model got saved back', function(assert) {
  const handler = function() {};
  sinon.stub(this.task, 'save').returns(
    new Ember.RSVP.Promise(handler, handler)
  );

  c.send('saveCoverLetter');
  assert.ok(this.task.save.called);
});
