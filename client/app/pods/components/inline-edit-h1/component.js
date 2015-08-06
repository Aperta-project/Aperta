import Ember from 'ember';

export default Ember.Component.extend({
  editing: Ember.computed.reads('editOnOpen'),
  snapshot: null,

  createSnapshot() {
    this.set('snapshot', Ember.copy(this.get('title')));
  },

  hasContent: Ember.computed.notEmpty('title'),

  focusOnEdit: function() {
    if (this.get('editing')) {
      Ember.run.schedule('afterRender', this, function() {
        this.$('input[type=text]').focus().select();
      });
    }
  }.observes('editing').on('didInsertElement'),

  actions: {
    toggleEdit() {
      this.createSnapshot();

      if (this.get('editing')) {
        this.sendAction('setTitle', this.get('snapshot'));
      }

      this.toggleProperty('editing');
    },

    save() {
      if (this.get('hasContent')) {
        this.sendAction('setTitle', this.get('title'));
        this.toggleProperty('editing');
      }
    }
  }
});
