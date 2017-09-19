import Ember from 'ember';

export default Ember.Component.extend({
  store: Ember.inject.service(),
  routing: Ember.inject.service('-routing'),

  actions: {
    showNewEmailTemplateOverlay() {
      this.set('newEmailTemplateOverlayVisible', true);
    },

    hideNewEmailTemplateOverlay() {
      this.set('newEmailTemplateOverlayVisible', false);
    },

    editTemplate(template) {
      this.get('routing').transitionTo('admin.edit_email', [template]);
    }
  }
});
