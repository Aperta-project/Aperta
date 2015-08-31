import Ember from 'ember';

export default Ember.Controller.extend({
  restless: Ember.inject.service('restless'),

  positionSort: ['position:asc'],
  sortedPhases: Ember.computed.sort('model.phases', 'positionSort'),

  commentLooks: Ember.computed(function() {
    return this.store.all('comment-look');
  }),

  allTaskIds() {
    return this.store.all('phase').reduce(function(taskIds, phase) {
      return taskIds.concat(phase.get('tasks').map(function(task) {
        return task.get('id');
      }));
    }, []);
  },

  updatePositions(phase) {
    let relevantPhases = this.get('model.phases').filter(function(p) {
      return p !== phase && p.get('position') >= phase.get('position');
    });

    relevantPhases.invoke('incrementProperty', 'position');
  },

  actions: {
    changePhaseForTask(task, targetPhaseId) {
      this.beginPropertyChanges();
      this.store.getById('phase', targetPhaseId).get('tasks').addObject(task);
      this.endPropertyChanges();
    },

    addPhase(position) {
      let paper = this.get('model');
      let phase = this.store.createRecord('phase', {
        position: position,
        name: 'New Phase',
        paper: paper
      });

      this.updatePositions(phase);

      phase.save().then(function() {
        paper.reload();
      });
    },

    changeTaskPhase(task, targetPhase) {
      task.set('phase', targetPhase);
    },

    removePhase(phase) {
      let paper = phase.get('paper');

      phase.destroyRecord().then(function() {
        paper.reload();
      });
    },

    savePhase(phase) {
      phase.save();
    },

    rollbackPhase(phase) {
      phase.rollback();
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
