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

  bodyPartType: computed.reads('block.firstObject.type'),

  _isNotEmpty(item) {
    return item && !Ember.isEmpty(item.value);
  },

  actions: {
    toggleEdit() {
      if (this.get('editing')) {
        this.get('cancel')(this.get('snapshot'));
      }
      this.toggleProperty('editing');
    },

    save() {
      if (this.get('hasContent')) {
        this.get('save')();
        return this.toggleProperty('editing');
      }
    },

    confirmDeletion() {
      this.set('confirmDelete', true);
    },

    cancelDeletion() {
      this.set('confirmDelete', false);
    }
  }
});
