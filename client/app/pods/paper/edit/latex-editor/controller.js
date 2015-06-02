import Ember from 'ember';
import PaperBaseMixin from 'tahi/mixins/controllers/paper-base';
import PaperEditMixin from 'tahi/mixins/controllers/paper-edit';
import { ClientEvents, Bindings } from 'ember-pusher';

export default Ember.Controller.extend(PaperBaseMixin, PaperEditMixin, ClientEvents, Bindings, {
  imagePreviewUrls: [],

  paperChannelName: function() {
    return `private-paper@${ this.get('model.id') }`;
  }.property('model.id'),

  startEditing() {
    this.set('model.lockedBy', this.currentUser);
    this.get('model').save().then(()=> {
      this.send('startEditing');
      this.set('saveState', false);
    });
  },

  stopEditing() {
    this.pusher.connection.send_event('client-body_updated', {
      paper_id: this.get('model.id'),
      body: this.get('model.body')
    }, 'private-latex_paper');

    this.set('model.lockedBy', null);
    this.send('stopEditing');
    this.get('model').save().then(()=> {
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
  },

  editorSetup() {
    this.pusher.wire(this, this.get('paperChannelName'), ["client-preview_images_updated"]);
  },

  editorTeardown() {
    this.pusher.unwire(this, this.get('paperChannelName'));
  },

  actions: {
    clientPreviewImagesUpdated(event_data) {
      this.set('imagePreviewUrls', event_data.image_preview_urls);
    }
  }

});
