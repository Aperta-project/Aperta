import Ember from 'ember';
import PaperBaseMixin from 'tahi/mixins/controllers/paper-base';
import PaperEditMixin from 'tahi/mixins/controllers/paper-edit';

export default Ember.Controller.extend(PaperBaseMixin, PaperEditMixin, {
  startEditing() {
    this.set('model.lockedBy', this.currentUser);
    this.get('model').save().then((paper)=> {
      this.send('startEditing');
      this.set('saveState', false);
    });
  },

  stopEditing() {
    this.set('model.lockedBy', null);
    this.send('stopEditing');
    this.get('model').save().then((paper)=> {
      this.set('saveState', true);
    });
  },

  savePaper() {
    if(!this.get('model.editable')) { return; }

    if(!this.get('model').get('isDirty')) {
      this.set('isSaving', false);
      return;
    }

    this.get('model').save().then(()=> {
      this.set('saveState', true);
      this.set('isSaving', false);
    });
  }
});
