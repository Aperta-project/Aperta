import Ember from 'ember';

export default Ember.Controller.extend({
  restless: Ember.inject.service('restless'),
  positionSort: ['position:asc'],
  sortedPhases: Ember.computed.sort('model.phases', 'positionSort'),

  updatePositions(phase) {
    let relevantPhases = this.get('model.phases').filter(function(p) {
      return p !== phase && p.get('position') >= phase.get('position');
    });

    relevantPhases.invoke('incrementProperty', 'position');
  },

  updateTaskPositions(itemList) {
    this.beginPropertyChanges();
    itemList.forEach((item, index) => {
      item.set('position', index + 1);
    });
    this.endPropertyChanges();
  },

  actions: {
    addPhase(position) {
      let paper = this.get('model');
      let phase = this.store.createRecord('phase', {
        position: position,
        name: 'New Phase',
        paper: paper
      });

      this.updatePositions(phase);

      phase.save();
    },

    removePhase(phase) {
      phase.destroyRecord();
    },

    savePhase(phase) {
      phase.save();
    },

    rollbackPhase(phase) {
      phase.rollback();
    },

    taskMovedWithinList(item, oldIndex, newIndex, itemList) {
      itemList.removeAt(oldIndex);
      itemList.insertAt(newIndex, item);
      this.updateTaskPositions(itemList);
      item.save();
    },

    taskMovedBetweenList(item, oldIndex, newIndex, newList, sourceItems, newItems) {
      sourceItems.removeAt(oldIndex);
      newItems.insertAt(newIndex, item);
      item.set('phase', newList);

      this.updateTaskPositions(sourceItems);
      this.updateTaskPositions(newItems);

      item.save();
    },

    toggleEditable() {
      const model = this.get('model');
      const url   = '/toggle_editable';

      this.get('restless').putUpdate(model, url).catch((arg) => {
        let model   = arg.model;
        let message = (function() {
          switch (arg.status) {
            case 422:
              return model.get('errors.messages') + ' You should probably reload.';
            case 403:
              return "You weren't authorized to do that";
            default:
              return 'There was a problem saving.  Please reload.';
          }
        })();

        this.flash.displayMessage('error', message);
      });
    }
  }
});
