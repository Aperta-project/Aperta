import Ember from 'ember';
import deepCamelizeKeys from 'tahi/lib/deep-camelize-keys';
import deNamespaceTaskType from 'tahi/lib/de-namespace-task-type';
import { task as concurrencyTask } from 'ember-concurrency';
import Discussions from 'tahi/mixins/discussions/route-paths';

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

export default Controller.extend(Discussions, {
  flash: Ember.inject.service(),
  restless: service('restless'),
  routing: service('-routing'),
  positionSort: ['position:asc'],
  sortedPhases: sort('model.phases', 'positionSort'),

  paper: alias('model'),
  subRouteName: 'workflow',

  activityIsLoading: false,
  showActivityOverlay: false,
  activityFeed: null,

  showCardDeleteOverlay: false,
  taskToDelete: null,

  showChooseNewCardOverlay: false,
  addToPhase: null,
  journalTaskTypes: reads('model.paperTaskTypes'),
  availableCards: reads('paper.availableCards'),
  addableTaskTypes: filterBy('journalTaskTypes', 'systemGenerated', false),

  taskToDisplay: null,
  showTaskOverlay: false,

  buildTask(emberStoreKey, title, kind, phase, card) {
    return this.store.createRecord(emberStoreKey, {
      title: title,
      type: kind,
      paper: this.get('paper'),
      phase: phase,
      card: card
    });
  },

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

  addTaskType: concurrencyTask(function * (phase, selectedCards) {
    if (selectedCards.length === 0) {
      this.get('flash').displayRouteLevelMessage('error', "No tasks were selected to add to the workflow.");
      return;
    }

    let promises = selectedCards.map((item) => {
      let newTask;

      if(item.constructor.modelName === 'card') {
        // task will be created from a Card
        newTask = this.buildTask('CustomCardTask', item.get('name'), 'CustomCardTask', phase, item);
      } else {
        // task will be created from a JournalTaskType
        let unNamespacedKind = deNamespaceTaskType(item.get('kind'));
        newTask = this.buildTask(unNamespacedKind, item.get('title'), item.get('kind'), phase);
      }

      let newTaskPromise = newTask.save().catch((response) => {
        newTask.destroyRecord();
        this.get('flash').displayRouteLevelMessage('error', response.errors[0].detail);
      });
      return newTaskPromise;
    });
    yield Ember.RSVP.all(promises);
  }).drop(),

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
      return this.get('addTaskType').perform(phase, taskTypeList);
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
