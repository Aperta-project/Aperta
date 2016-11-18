import Ember from 'ember';

const { observer } = Ember;

export default Ember.Component.extend({
  editing: false,
  confirmDelete: false,

  createSnapshot: observer('editing', function() {
    this.get('block').createSnapshot();
  }),

  actions: {
    toggleEdit() {
      if (this.get('editing')) {
        this.get('cancel')();
      }
      this.toggleProperty('editing');
    },

    save() {
      if (this.get('block.hasContent')) {
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
