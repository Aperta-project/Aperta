import Ember from 'ember';
import startApp from '../helpers/start-app';
import { test, moduleFor } from 'ember-qunit';

moduleFor(
  'controller:admin/journal/manuscript-manager-template/edit',
  'ManuscriptManagerTemplateEditController', {

  beforeEach() {
    startApp();
    Ember.run(() => {
      this.ctrl = this.subject();
      this.store = getStore();
      this.phase = this.store.createRecord('phaseTemplate', {
        name: 'First Phase'
      });

      this.task1 = this.store.createRecord('taskTemplate', {
        title: 'ATask',
        phaseTemplate: this.phase
      });

      this.task2 = this.store.createRecord('taskTemplate', {
        title: 'BTask',
        phaseTemplate: this.phase
      });

      this.template = this.store.createRecord('manuscriptManagerTemplate', {
        name: 'A name',
        paper_type: 'A type',
        phases: [this.phase]
      });

      this.ctrl.setProperties({
        model: this.template,
        store: this.store
      });
    });
  }
});

test('#rollbackPhase sets the given old name on the given phase', function(assert) {
  const phase = Ember.Object.create({
    name: 'Captain Picard'
  });
  this.ctrl.send('rollbackPhase', phase, 'Captain Kirk');
  return assert.equal(phase.get('name'), 'Captain Kirk');
});

test('#addPhase adds a phase at a specified index', function(assert) {
  return Ember.run(() => {
    this.ctrl.send('addPhase', 0);
    assert.equal(
      this.ctrl.get('sortedPhaseTemplates.firstObject.name'),
      'New Phase'
    );
  });
});
