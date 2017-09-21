import Ember from 'ember';

export default Ember.Component.extend({
  store: Ember.inject.service(),
  routing: Ember.inject.service('-routing'),
  sortedTemplates: Ember.computed.sort('templates', function(a, b) {
    try {
      let aName = a.get('name').toLowerCase(),
        bName = b.get('name').toLowerCase();
      if (aName === bName) return 0;
      return aName < bName ? -1 : 1;
    } catch(e) {
      return 0;
    }
  }),

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
