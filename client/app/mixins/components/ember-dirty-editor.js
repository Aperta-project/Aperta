import Ember from 'ember';

export default Ember.Mixin.create({
  showDirtyOverlay: false,
  allowStoppedTransition: 'allowStoppedTransition',
  actions: {
    cleanDirtyModel: function() {
      let model = this.get(this.get('dirtyEditorConfig.model'));
      let dirtyProps = this.get('dirtyEditorConfig.properties');
      if (dirtyProps.length) {
        dirtyProps.forEach( function(prop) { model.rollbackAttributes(prop); });
      } else {
        model.rollbackAttributes();
      }

      this.sendAction('allowStoppedTransition');
    },
  }
});
