import Ember from 'ember';

// This validation works for our pre-populated letter templates
// but we might want to change this up when users are allowed to create
// new templates.

export default Ember.Component.extend({
  store: Ember.inject.service(),
  routing: Ember.inject.service('-routing'),
  saved: true,
  subjectErrors: [],
  bodyErrors: [],
  subjectErrorPresent: Ember.computed.notEmpty('subjectErrors'),
  bodyErrorPresent: Ember.computed.notEmpty('bodyErrors'),
  actions: {
    handleInputChange() {
      this.set('saved', false);
      this.set('message', '');
    },

    save: function() {
      this.set('subjectErrors', []);
      this.set('bodyErrors', []);
      if (this.get('template.subject') && this.get('template.body')) {
        this.get('template').save()
          .then(() => {
            this.set('saved', true);
            this.set('message', 'Your changes have been saved.');
            this.set('messageType', 'success');
          })
          .catch(error => {
            let subjectErrors = error.errors.filter((e) => e.source.pointer.includes('subject'));
            let bodyErrors = error.errors.filter((e) => e.source.pointer.includes('body'));
            if (subjectErrors.length) {
              this.set('subjectErrors', subjectErrors.map(s => s.detail));
            }
            if (bodyErrors.length) {
              this.set('bodyErrors', bodyErrors.map(b => b.detail));
            }
            this.set('message', 'Please correct errors where indicated.');
            this.set('messageType', 'danger');
          });
      }
    }
  }
});

