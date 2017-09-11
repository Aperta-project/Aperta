import Ember from 'ember';

// This validation works for our pre-populated letter templates
// but we might want to change this up when users are allowed to create
// new templates.

export default Ember.Component.extend({
  showDirtyOverlay: false,
  store: Ember.inject.service(),
  routing: Ember.inject.service('-routing'),
  disabled: Ember.computed('template.subject', 'template.body', function() {
    return !this.get('template.subject') || !this.get('template.body');
  }),
  unsaved: true,
  allowStoppedTransition: 'allowStoppedTransition',

  emailTemplateDirty: Ember.computed('template.body', 'template.subject', 'template.hasDirtyAttributes', function() {
    let emailTemplate = this.get('template');
    let dirtyAndRelevant = emailTemplate.changedAttributes()['subject'] || emailTemplate.changedAttributes()['body'];
    return !!(emailTemplate.get('hasDirtyAttributes') && dirtyAndRelevant);
  }),

  didInsertElement() {
    $(window).on('beforeunload.dirtyApertaEmailTemplateEditor', () => { if (this.get('emailTemplateDirty')) { return true; } });
  },

  willDestroyElement() {
    $(window).off('beforeunload.dirtyApertaEmailTemplateEditor');
  },

  actions: {
    save: function() {
      if (this.get('disabled') || this.get('template.isSaving')) {
        this.set('unsaved', false);
      } else {
        this.get('template').save().then(() => {
          this.get('routing').transitionTo('admin.journals.emailtemplates', this.get('template.journal.id'));
        });
      }
    },
    cleanEmailTemplate: function() {
      let emailTemplate = this.get('template');
      if (emailTemplate.get('hasDirtyAttributes')) {
        emailTemplate.rollbackAttributes();
      }
      this.sendAction('allowStoppedTransition');
    }
  }
});
