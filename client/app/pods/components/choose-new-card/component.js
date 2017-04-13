import Ember from 'ember';
import EscapeListenerMixin from 'tahi/mixins/escape-listener';
import {PropTypes} from 'ember-prop-types';

const { computed, on } = Ember;

export default Ember.Component.extend(EscapeListenerMixin, {
  propTypes: {
    phase: PropTypes.EmberObject,
    journalTaskTypes: PropTypes.array,
    cards: PropTypes.EmberObject,
    onSave: PropTypes.func,
    isLoading: PropTypes.bool,
    close: PropTypes.func
  },

  setuptaskTypeList: on('init', function() {
    if (!this.get('selectedCards')) {
      this.set('selectedCards', []);
    }
  }),

  // card-config
  cardSort: ['name:asc'],
  sortedCards: computed.sort('cards', 'cardSort'),

  // pre-card-config
  taskTypeSort: ['title:asc'],
  sortedTaskTypes: computed.sort('journalTaskTypes', 'taskTypeSort'),
  authorTasks: computed.filterBy('sortedTaskTypes', 'roleHint', 'author'),
  staffTasksUnsorted: computed.setDiff('sortedTaskTypes', 'authorTasks'),
  staffTasks: computed.sort('staffTasksUnsorted', 'taskTypeSort'),

  save() {
    this.get('onSave')(
      this.get('phase'),
      this.get('selectedCards')
    );
    this.get('close')();
  },

  actions: {
    updateList(checkbox) {
      if (checkbox.get('checked')) {
        this.get('selectedCards').pushObject(checkbox.get('task'));
      } else {
        this.get('selectedCards').removeObject(checkbox.get('task'));
      }
    },

    throttledSave() {
      Ember.run.throttle(this, this.get('save'), 500);
    },

    close() {
      this.get('close')();
    }
  }
});
