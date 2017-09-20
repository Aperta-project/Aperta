import Ember from 'ember';
import EmberDirtyEditor from 'tahi/mixins/routes/dirty-editor-ember';

export default Ember.Route.extend(EmberDirtyEditor, {
  dirtyEditorConfig: {
    model: 'card',
    properties: ['xml']
  }
});
