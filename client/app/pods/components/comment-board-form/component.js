import Ember from 'ember';

export default Ember.Component.extend({
  classNameBindings: ['editing', ':comment-board-form', 'form-group'],
  editing: false,
  comment: '',

  _setupFocus: Ember.on('didInsertElement', function() {
    this.$('.new-comment-field').on('focus', ()=> {
      this.set('editing', true);
    });
  }),

  _teardownFocus: Ember.on('willDestroyElement', function() {
    this.$('.new-comment-field').off();
  }),

  clear() {
    this.set('comment', '');
    this.set('editing', false);
  },

  actions: {
    cancel() { this.clear(); },

    save() {
      this.sendAction('save', this.get('comment'));
      this.clear();
    }
  }
});
