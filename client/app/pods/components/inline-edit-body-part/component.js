import Ember from 'ember';

const { computed, observer } = Ember;

export default Ember.Component.extend({
  editing: false,
  snapshot: null,
  confirmDelete: false,

  init() {
    this._super(...arguments);
    this.set('snapshot', []);
  },

  createSnapshot: observer('editing', function() {
    this.set('snapshot', Ember.copy(this.get('block'), true));
  }),

  hasContent: computed('block.@each.value', function() {
    return this.get('block').any(this._isNotEmpty);
  }),

  hasNoContent: computed.not('hasContent'),

  bodyPartType: computed('block.@each.type', function() {
    return this.get('block.firstObject.type');
  }),

  _isNotEmpty(item) {
    return item && !Ember.isEmpty(item.value);
  },

  actions: {
    toggleEdit() {
      if (this.get('editing')) {
        this.sendAction('cancel', this.get('block'), this.get('snapshot'));
      }
      this.toggleProperty('editing');
    },

    deleteBlock() {
      this.sendAction('delete', this.get('block'));
    },

    save() {
      if (this.get('hasContent')) {
        this.sendAction('save', this.get('block'));
        return this.toggleProperty('editing');
      }
    },

    confirmDeletion() {
      this.set('confirmDelete', true);
    },

    cancelDeletion() {
      this.set('confirmDelete', false);
    },

    addItem() {
      this.sendAction('addItem', this.get('block'));
    }
  }
});
