import Ember from 'ember';
import { test, moduleFor } from 'ember-qunit';
import startApp from '../helpers/start-app';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';
import setupMockServer from '../helpers/mock-server';

let app = null;
let server = null;

moduleFor('controller:paper/workflow', 'PaperWorkflowController', {
  needs: ['controller:application'],

  beforeEach() {
    app = startApp();
    server = setupMockServer();

    this.phase1 = Ember.Object.create({ position: 1 });
    this.phase2 = Ember.Object.create({ position: 2 });
    this.phase3 = Ember.Object.create({ position: 3 });
    this.phase4 = Ember.Object.create({ position: 4 });

    this.paper = Ember.Object.create({
      title: 'test paper',
      phases: []
    });

    server.respondWith('GET', '/api/journals', [
      200, { 'Content-Type': 'application/json' },
      JSON.stringify({journals:[]})
    ]);
  },

  afterEach() {
    Ember.run(app, 'destroy');
    server.restore();
  }

});

test('#sortedPhases: phases are sorted by position', function(assert) {
  const paperWorkflowController = this.subject();
  paperWorkflowController.set('model', this.paper);
  paperWorkflowController.set(
    'model.phases', [this.phase3, this.phase2, this.phase4]
  );

  let sortedPositionArray = paperWorkflowController.get('sortedPhases')
                                                   .mapBy('position').toArray();

  assert.deepEqual(sortedPositionArray, [2, 3, 4]);

  paperWorkflowController.get('model.phases').pushObject(this.phase1);
  sortedPositionArray = paperWorkflowController.get('sortedPhases')
                                               .mapBy('position').toArray();

  assert.deepEqual(sortedPositionArray, [1, 2, 3, 4]);
});

test('#updatePositions: phase positions are updated accordingly', function(assert) {
  assert.equal(this.phase3.get('position'), 3);
  assert.equal(this.phase4.get('position'), 4);

  const paperWorkflowController = this.subject();

  paperWorkflowController.set('model', this.paper);
  paperWorkflowController.set(
    'model.phases', [this.phase1, this.phase2, this.phase3, this.phase4]
  );
  this.phase1.setProperties({ position: 3 });
  paperWorkflowController.updatePositions(this.phase1);

  assert.equal(this.phase3.get('position'), 4);
  assert.equal(this.phase4.get('position'), 5);
});
