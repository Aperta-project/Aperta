import Ember from 'ember';
import PaperBaseMixin from 'tahi/mixins/controllers/paper-base';
import PaperIndexMixin from 'tahi/mixins/controllers/paper-index';
import DiscussionsRoutePathsMixin from 'tahi/mixins/discussions/route-paths';

export default Ember.Controller.extend(
  PaperBaseMixin, PaperIndexMixin, DiscussionsRoutePathsMixin, {
  subRouteName: 'index',

  startEditing() {
    this.set('model.lockedBy', this.currentUser);
    this.get('model').save().then(()=> {
      this.send('startEditing');
      this.set('saveState', false);
    });
  },

  stopEditing() {
    this.set('model.lockedBy', null);
    this.send('stopEditing');
    this.get('model').save().then(()=> {
      this.set('saveState', true);
    });
  },

  savePaper() {
    if(!this.get('model.editable')) { return; }

    if(!this.get('model').get('hasDirtyAttributes')) {
      this.set('isSaving', false);
      return;
    }

    this.get('model').save().then(()=> {
      this.set('saveState', true);
      this.set('isSaving', false);
    });
  }
});
