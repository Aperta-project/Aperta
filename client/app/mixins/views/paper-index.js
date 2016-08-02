import Ember from 'ember';

const { on } = Ember;

export default Ember.Mixin.create({
  classNames: ['edit-paper'],

  editable: Ember.computed.alias('controller.model.editable'),
  supportedDownloadFormats: Ember.computed.alias('controller.supportedDownloadFormats'),

  toggleEditable() {
    if (this.get('editable') !== this.get('lastEditable')) {
      this.set('lastEditable', this.get('editable'));
    }
  },

  setupEditableToggle: Ember.on('didInsertElement', function() {
    this.set('lastEditable', this.get('editable'));
    this.addObserver('editable', this, this.toggleEditable);
  }),

  teardownEditableToggle: Ember.on('willDestroyElement', function() {
    this.removeObserver('editable', this, this.toggleEditable);
  }),

  _applyManuscriptCss: on('didInsertElement', function() {
    Ember.run.scheduleOnce('afterRender', ()=> {
      this.get('controller.model.journal').then(function(journal) {
        const style = journal.get('manuscriptCss');
        Ember.$('.manuscript').attr('style', style);
      });
    });
  })
});
