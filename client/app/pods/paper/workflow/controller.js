import Ember from 'ember';
import deepCamelizeKeys from 'tahi/lib/deep-camelize-keys';

export default Ember.Controller.extend({
  restless: Ember.inject.service('restless'),
  routing: Ember.inject.service('-routing'),
  positionSort: ['position:asc'],
  sortedPhases: Ember.computed.sort('model.phases', 'positionSort'),

  activityIsLoading: false,
  showActivityOverlay: false,
  activityFeed: null,

  showCardDeleteOverlay: false,
  taskToDelete: null,

  showChooseNewCardOverlay: false,
  addToPhase: null,
  journalTaskTypes: [],
  journalTaskTypesIsLoading: false,

  taskToDisplay: null,
  showTaskOverlay: false,

  updatePositions(phase) {
    const relevantPhases = this.get('model.phases').filter(function(p) {
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
    viewCard(task) {
      const r = this.get('routing.router.router');
      r.updateURL(r.generate('paper.task', task.get('id')));

      this.set('taskToDisplay', task);
      this.set('showTaskOverlay', true);
    },

    hideTaskOverlay() {
      const r = this.get('routing.router.router');
      const lastRoute = r.currentHandlerInfos[r.currentHandlerInfos.length - 1];
      r.updateURL(r.generate(lastRoute.name, lastRoute.context.get('id')));
      this.set('showTaskOverlay', false);
    },

    showChooseNewCardOverlay(phase) {
      this.setProperties({
        addToPhase: phase,
        journalTaskTypesIsLoading: true
      });

      this.setProperties({
        journalTaskTypes: this.get('model.paperTaskTypes'),
        journalTaskTypesIsLoading: false
      });

      this.set('showChooseNewCardOverlay', true);
    },

    hideChooseNewCardOverlay() {
      this.set('showChooseNewCardOverlay', false);
    },

    addTaskType(phase, taskTypeList) {
      this.send('addTaskTypeToPhase', phase, taskTypeList);
    },

    showCardDeleteOverlay(task) {
      this.set('taskToDelete', task);
      this.set('showCardDeleteOverlay', true);
    },

    hideCardDeleteOverlay() {
      this.set('showCardDeleteOverlay', false);
    },

    hideActivityOverlay() {
      this.set('showActivityOverlay', false);
    },

    showActivityOverlay(type) {
      this.set('activityIsLoading', true);
      this.set('showActivityOverlay', true);
      const url = `/api/papers/${this.get('model.id')}/activity/${type}`;

      this.get('restless').get(url).then((data)=> {
        this.setProperties({
          activityIsLoading: false,
          activityFeed: deepCamelizeKeys(data.feeds)
        });
      });
    },

    addPhase(position) {
      const paper = this.get('model');
      const phase = this.store.createRecord('phase', {
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
      phase.rollbackAttributes();
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

    startDragging(item, container) {
      item.addClass('card--dragging');
      container.parent().addClass('column-content--dragging');
    },

    stopDragging(item, container) {
      item.removeClass('card--dragging');
      container.parent().removeClass('column-content--dragging');
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
