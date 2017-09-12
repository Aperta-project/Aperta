import Ember from 'ember';
import EmberDirtyEditor from 'tahi/mixins/controllers/ember-dirty-editor';

export default Ember.Route.extend(EmberDirtyEditor, {
  dirtyEditorConfig: {
    model: 'card',
    properties: ['xml']
  },
});
