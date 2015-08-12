import Ember from 'ember';
import RESTless from 'tahi/services/rest-less';

export default Ember.Controller.extend({
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
    changePhaseForTask(taskId, targetPhaseId, taskPositions) {
      let newPhase = this.store.getById('phase', targetPhaseId);
      newPhase.set('taskPositions', taskPositions);

      RESTless.putModel(newPhase, '/move_task_to_phase', {
        task_id: taskId,
        task_positions: taskPositions,
      });

      this.store.findTask(taskId).set('phase', newPhase);
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
      RESTless.putUpdate(this.get('model'), '/toggle_editable').catch((arg) => {
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
