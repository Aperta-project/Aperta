import Ember from 'ember';
import BrowserDirtyEditor from 'tahi/mixins/components/dirty-editor-browser';
import EmberDirtyEditor from 'tahi/mixins/components/dirty-editor-ember';

// This validation works for our pre-populated letter templates
// but we might want to change this up when users are allowed to create
// new templates.

export default Ember.Component.extend(BrowserDirtyEditor, EmberDirtyEditor, {
  store: Ember.inject.service(),
  routing: Ember.inject.service('-routing'),
  saved: true,
  subjectEmpty: false,
  bodyEmpty: false,
  nameEmpty: Ember.computed.empty('template.name'),
  isEditingName: false,
  subjectErrors: [],
  bodyErrors: [],
  ccErrors: [],
  bccErrors: [],
  nameError: '',
  subjectErrorPresent: Ember.computed.notEmpty('subjectErrors'),
  bodyErrorPresent: Ember.computed.notEmpty('bodyErrors'),
  nameErrorPresent: Ember.computed.notEmpty('nameError'),
  ccErrorPresent: Ember.computed.notEmpty('ccErrors'),
  bccErrorPresent: Ember.computed.notEmpty('bccErrors'),

  actions: {
    editTitle() {
      this.set('isEditingName', true);
      if (this.get('template.hasDirtyAttributes')) {
        this.set('saved', false);
      } else {
        this.set('saved', true);
      }
    },

    handleInputChange() {
      this.set('saved', false);
      if(!this.get('nameEmpty')) {
        this.set('message', '');
      } else {
        this.setProperties({
          message: 'Please correct errors where indicated.',
          messageType: 'danger'
        });
      }
    },

    checkSubject() {
      if (!this.get('template.subject')) {
        this.set('subjectEmpty', true);
      } else {
        this.set('subjectEmpty', false);
      }
    },

    checkBody() {
      if(!this.get('template.body')) {
        this.set('bodyEmpty', true);
      } else {
        this.set('bodyEmpty', false);
      }
    },

    save: function() {
      this.setProperties({
        subjectErrors: [],
        bodyErrors: [],
        ccErrors: [],
        bccErrors: []
      });
      if (this.get('template.subject') && this.get('template.body') && this.get('template.name')) {
        this.get('template').save()
          .then(() => {
            this.setProperties({
              saved: true,
              isEditingName: false,
              message: 'Your changes have been saved.',
              messageType: 'success'
            });
          })
          .catch(error => {
            const subjectErrors = error.errors.filter((e) => e.source.pointer.includes('subject'));
            const bodyErrors = error.errors.filter((e) => e.source.pointer.includes('body'));
            const nameError = error.errors.filter(e => e.source.pointer.includes('name'));
            const ccErrors = error.errors.filter(e => e.source.pointer.endsWith('/cc'));
            const bccErrors = error.errors.filter(e => e.source.pointer.endsWith('/bcc'));
            if (subjectErrors.length) {
              this.set('subjectErrors', subjectErrors.map(s => s.detail));
            }
            if (bodyErrors.length) {
              this.set('bodyErrors', bodyErrors.map(b => b.detail));
            }
            if (nameError.length) {
              this.set('nameError', nameError.map(n => n.detail));
            }
            if (ccErrors.length) {
              this.set('ccErrors', ccErrors.map(err => err.detail));
            }
            if (bccErrors.length) {
              this.set('bccErrors', bccErrors.map(err => err.detail));
            }
            this.setProperties({
              message: 'Please correct errors where indicated.',
              messageType: 'danger'
            });
          });
      } else {
        this.setProperties({
          message: 'Please correct errors where indicated.',
          messageType: 'danger'
        });
      }
    }
  }
});

