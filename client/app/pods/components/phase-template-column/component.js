import Ember from 'ember';
import DragNDrop from 'tahi/services/drag-n-drop';

export default Ember.Component.extend(DragNDrop.DroppableMixin, {
  classNames: ['column'],

  nextPosition: Ember.computed('phaseTemplate.position', function() {
    return this.get('phaseTemplate.position') + 1;
  }),

  sortedTasks: Ember.computed('phaseTemplate.taskTemplates.[]', function() {
    return this.get('phaseTemplate.taskTemplates').sortBy('position');
  }),

  removeDragStyles() {
    this.$().removeClass('current-drop-target');
  },

  dragOver() {
    this.$().addClass('current-drop-target');
  },

  dragLeave() {
    this.removeDragStyles();
  },

  dragEnd() {
    this.removeDragStyles();
  },

  drop(e) {
    this.removeDragStyles();
    this.sendAction('changeTaskPhase', DragNDrop.dragItem, this.get('phaseTemplate'));
    DragNDrop.dragItem = null;
    DragNDrop.cancel(e);
  },

  actions: {
    chooseNewCardTypeOverlay(phase) { this.sendAction('chooseNewCardTypeOverlay', phase); },
    savePhase(phase)            { this.sendAction('savePhase', phase); },
    addPhase(position)          { this.sendAction('addPhase', position); },
    removeRecord(phase)          { this.sendAction('removeRecord', phase); },
    rollbackPhase(phase)        { this.sendAction('rollbackPhase', phase); },
    showDeleteConfirm(task)     { this.sendAction('showDeleteConfirm', task); }
  }
});
