import Ember from 'ember';

// Facilitates display of a warning overlay when navigating away from a dirty editor.
// Used in conjuction with client/app/mixins/routes/dirty-editor-ember.js
export default Ember.Mixin.create({
  retryStoppedTransition: 'retryStoppedTransition',
  actions: {
    cleanDirtyModel: function() {
      let model = this.get(this.get('dirtyEditorConfig.model'));
      let props = this.get('dirtyEditorConfig.properties');
      if (props.length) {
        props.forEach(function(prop) { model.rollbackAttributes(prop); });
      } else {
        model.rollbackAttributes();
      }

      this.sendAction('retryStoppedTransition');
    },
  }
});
