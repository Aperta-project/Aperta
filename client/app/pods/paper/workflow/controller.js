import Ember from 'ember';
import deepCamelizeKeys from 'tahi/lib/deep-camelize-keys';

const {
  Controller,
  inject: { service },
  computed: {
    sort,
    alias,
    reads,
    filterBy
  }
} = Ember;

export default Controller.extend({
  restless: service('restless'),
  routing: service('-routing'),
  positionSort: ['position:asc'],
  sortedPhases: sort('model.phases', 'positionSort'),

  paper: alias('model'),

  activityIsLoading: false,
  showActivityOverlay: false,
  activityFeed: null,

  showCardDeleteOverlay: false,
  taskToDelete: null,

  showChooseNewCardOverlay: false,
  addToPhase: null,
  journalTaskTypes: reads('model.paperTaskTypes'),
  addableTaskTypes: filterBy('journalTaskTypes', 'systemGenerated', false),

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
      r.updateURL(r.generate(lastRoute.name, lastRoute.context.get('shortDoi')));
      this.set('showTaskOverlay', false);
    },

    showChooseNewCardOverlay(phase) {
      this.set('addToPhase', phase);
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

   /**
    *  @method taskMovedWithinList
    *  @param {Object} item DS.Model Task
    *  @param {Number} oldIndex
    *  @param {Number} newIndex
    *  @param {Array}  itemList Array of DS.Model Task
    **/
    taskMovedWithinList(item, oldIndex, newIndex, itemList) {
      itemList.removeAt(oldIndex);
      itemList.insertAt(newIndex, item);
      this.updateTaskPositions(itemList);
      item.save();
    },

   /**
    *  @method taskMovedBetweenList
    *  @param {Object} item DS.Model Task
    *  @param {Number} oldIndex
    *  @param {Number} newIndex
    *  @param {Object} newPhase DS.Model Phase
    *  @param {Array}  sourceItems Array of DS.Model Task
    *  @param {Array}  newItems Array of DS.Model Task
    **/
    taskMovedBetweenList(item, oldIndex, newIndex, newPhase, sourceItems, newItems) {
      sourceItems.removeAt(oldIndex);
      newItems.insertAt(newIndex, item);
      item.set('phase', newPhase);

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
      const url = '/toggle_editable';

      this.get('restless').putUpdate(this.get('model'), url).catch((arg) => {
        const model = arg.model;
        const message = (function() {
          switch (arg.status) {
          case 422:
            return model.get('errors.messages') + ' You should probably reload.';
          case 403:
            return "You weren't authorized to do that";
          default:
            return 'There was a problem saving. Please reload.';
          }
        })();

        this.flash.displayRouteLevelMessage('error', message);
      });
    }
  }
});
