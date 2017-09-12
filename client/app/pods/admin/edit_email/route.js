import Ember from 'ember';
import EmberDirtyEditor from 'tahi/mixins/controllers/ember-dirty-editor';

export default Ember.Route.extend(EmberDirtyEditor, {
  dirtyEditorConfig: {
    model: 'template',
    properties: ['body', 'subject']
  },
  
  model(params) {
    return this.store.findRecord('letter-template', params.email_id, {reload: true});
  }
});
