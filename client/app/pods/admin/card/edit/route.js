import Ember from 'ember';
import EmberDirtyEditor from 'tahi/mixins/controllers/dirty-editor-ember';

export default Ember.Route.extend(EmberDirtyEditor, {
  dirtyEditorConfig: {
    model: 'card',
    properties: ['xml']
  }
});
