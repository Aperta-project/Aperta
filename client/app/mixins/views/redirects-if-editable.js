import Ember from 'ember';

export default Ember.Mixin.create({
  editable: Ember.computed.alias('controller.model.editable'),
  supportedDownloadFormats: Ember.computed.alias('controller.supportedDownloadFormats'),

  toggleEditable() {
    if (this.get('editable') !== this.get('lastEditable')) {
      this.set('lastEditable', this.get('editable'));
      this.get('controller').send('editableDidChange');
    }
  },

  setupEditableToggle: function() {
    this.set('lastEditable', this.get('editable'));
    this.addObserver('editable', this, this.toggleEditable);
  }.on('didInsertElement'),

  teardownEditableToggle: function() {
    this.removeObserver('editable', this, this.toggleEditable);
  }.on('willDestroyElement')
});
