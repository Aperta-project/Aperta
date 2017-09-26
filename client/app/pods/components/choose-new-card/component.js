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

  addableCards: computed.filterBy('sortedCards', 'addable', true),
  addableWorkFlowCards: computed.filterBy('sortedCards', 'workflow_only', true),
  addableNonWorkFlowCards: computed.setDiff('sortedCards', 'addableWorkFlowCards'),

  // pre-card-config
  taskTypeSort: ['title:asc'],
  authorTasks: computed.filterBy('journalTaskTypes', 'roleHint', 'author'),
  staffTasks: computed.setDiff('journalTaskTypes', 'authorTasks'),

  unsortedAuthorColumn: computed.union('authorTasks', 'addableNonWorkFlowCards'),
  authorColumn: computed.sort('unsortedAuthorColumn', 'taskTypeSort'),
  unsortedStaffColumn: computed.union('staffTasks', 'addableWorkFlowCards'),
  staffColumn: computed.sort('unsortedStaffColumn', 'taskTypeSort'),

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
