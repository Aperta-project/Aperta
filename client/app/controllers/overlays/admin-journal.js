import Ember from 'ember';

export default Ember.Controller.extend({
  journalController: Ember.inject.controller('admin/journal/index'),
  overlayClass: 'overlay--fullscreen journal-edit-overlay',
  propertyName: '',

  actions: {
    save() {
      this.get('journalController')
          .set(`${this.get('propertyName')}SaveStatus`, 'Saved')
          .get('model').save();

      this.send('closeAction');
    }
  }
});
