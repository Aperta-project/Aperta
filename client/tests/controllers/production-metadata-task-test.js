import Ember from 'ember';
import { test, moduleFor } from 'ember-qunit';

moduleFor('controller:overlays/production-metadata', 'ProductionMetadataController', {
  needs: ['controller:application'],

  beforeEach: function() {
    this.paper = Ember.Object.create({
      editable: true
    });

    this.currentUser = Ember.Object.create({
      siteAdmin: true
    });

    this.task = Ember.Object.create({
      isSubmissionTask: false,
      paper: this.paper,
      body: []
    });

    Ember.run(()=> {
      this.subject().set('model', this.task);
      this.subject().set('currentUser', this.currentUser);
    });
  }
});

test('#publicationDate: returns the value of the production date', function(assert) {
  Ember.run(()=> {
    this.subject().set('model.body.publicationDate', 'today');
    assert.equal(this.subject().get('publicationDate'), 'today');
  });
});

test('#volumeNumber: returns the value of the volume number', function(assert) {
  Ember.run(()=> {
    this.subject().set('model.body.volumeNumber', '22');
    assert.equal(this.subject().get('volumeNumber'), '22');
  });
});

test('#issueNumber: returns the value of the issue number', function(assert) {
  Ember.run(()=> {
    this.subject().set('model.body.issueNumber', '33');
    assert.equal(this.subject().get('issueNumber'), '33');
  });
});

test('#productionNotes: returns the value of production notes', function(assert) {
  Ember.run(()=> {
    this.subject().set('model.body.productionNotes', 'Super Cool Bod Notes');
    assert.equal(this.subject().get('productionNotes'), 'Super Cool Bod Notes');
  });
});

test('#setAndSave: model property got saved', function(assert) {
  var handler;
  handler = function() {};
  this.task.save = function() {};
  sinon.stub(this.task, 'save').returns(new Ember.RSVP.Promise(handler, handler));
  this.subject().setAndSave('publicationDate');
  return assert.ok(this.task.save.called);
});

test('#ensureBody: ensures model body is a hash', function(assert) {
  Ember.run(()=> {
    assert.ok(this.subject().get('model.body') instanceof(Array));
    this.subject().ensureBody();
    assert.ok(this.subject().get('model.body') instanceof(Object));
  });
});
