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
  isEditingName: false,

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
      if(!this.get('template.nameEmpty')) {
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

    parseErrors(error) {
      this.get('template').parseErrors(error);
      this.setProperties({
        message: 'Please correct errors where indicated.',
        messageType: 'danger'
      });
    },

    save: function() {
      let template = this.get('template');
      template.clearErrors();
      if (template.get('subject') && template.get('body') && template.get('name')) {
        template.save()
          .then(() => {
            this.setProperties({
              saved: true,
              isEditingName: false,
              message: 'Your changes have been saved.',
              messageType: 'success'
            });
            template.reload();
          })
          .catch(error => {
            this.send('parseErrors', error);
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
