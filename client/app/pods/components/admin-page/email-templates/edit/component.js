import Ember from 'ember';

// This validation works for our pre-populated letter templates
// but we might want to change this up when users are allowed to create
// new templates.

export default Ember.Component.extend({
  store: Ember.inject.service(),
  routing: Ember.inject.service('-routing'),
  disabled: Ember.computed('template.subject', 'template.letter', function() {
    return !this.get('template.subject') || !this.get('template.letter');
  }),
  unsaved: true,
  buttonClasses: Ember.computed('disabled', function(){
    var colorClass = this.get('disabled') ? 'button-disabled' : 'button--blue';
    return `button-primary ${colorClass}`;
  }),
  actions: {
    save: function() {
      if (this.get('disabled')) {
        this.set('unsaved', false);
      } else {
        this.get('template').save().then(() => {
          this.get('routing').transitionTo('admin.cc.journals.emailtemplates');
        });
      }
    }
  }
});
