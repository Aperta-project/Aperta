import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['column'],

  nextPosition: Ember.computed('phaseTemplate.position', function() {
    return this.get('phaseTemplate.position') + 1;
  }),

  sortedTasks: Ember.computed('phaseTemplate.taskTemplates.[]', function() {
    return this.get('phaseTemplate.taskTemplates').sortBy('position');
  }),

  actions: {
    chooseNewCardTypeOverlay(phase) { this.sendAction('chooseNewCardTypeOverlay', phase); },
    savePhase(phase)            { this.sendAction('savePhase', phase); },
    addPhase(position)          { this.sendAction('addPhase', position); },
    removeRecord(phase)          { this.sendAction('removeRecord', phase); },
    rollbackPhase(phase)        { this.sendAction('rollbackPhase', phase); },
    showDeleteConfirm(task)     { this.sendAction('showDeleteConfirm', task); }
  }
});
