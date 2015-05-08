import Ember from 'ember';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default Ember.Component.extend(ValidationErrorsMixin, {
  classNameBindings: [':admin-role', 'isEditing:is-editing:not-editing'],
  isEditing: false,
  notEditing: Ember.computed.not('isEditing'),

  setIsEditing: function() {
    if(this.get('model.isNew')) {
      this.set('isEditing', true);
    }
  }.on('init'),

  _animateInIfNewRole: function() {
    if (this.get('model.isNew')) {
      this.$().hide().fadeIn(250);
    }
  }.on('didInsertElement'),

  focusObserver: function() {
    if (!this.get('isEditing')) { return; }
    Ember.run.schedule('afterRender', this, function() {
      this.$('input:first').focus();
    });
  }.observes('isEditing'),

  click(e) {
    if (!this.get('isEditing')) {
      this.set('isEditing', true);
      e.stopPropagation();
    }
  },

  actions: {
    edit() {
      this.set('isEditing', true);
    },

    save() {
      this.get('model').save().then(()=> {
        this.set('isEditing', false);
      }, (response)=> {
        this.displayValidationErrorsFromResponse(response);
      });
    },

    cancel() {
      this.get('model')[this.get('model.isNew') ? 'deleteRecord' : 'rollback']();
      this.set('isEditing', false);
    },

    deleteRole() {
      this.get('model').destroyRecord();
    }
  }
});
