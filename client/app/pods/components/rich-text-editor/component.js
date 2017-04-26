import Ember from 'ember';

export default Ember.Component.extend({
  editorStyle: 'expanded',
  editorConfigurations: {
    basic: {
      menubar: false,
      toolbar: 'bold italic underline | subscript superscript | undo redo',
    },

    expanded: {
      menubar: false,
      toolbar: 'bold italic underline | subscript superscript | bullist numlist table | undo redo | code',
      plugins: 'table code'
    }
  },

  editorOptions: Ember.computed('editorStyle', 'editorConfigurations', function() {
    let options = this.get('editorConfigurations');
    let style = this.get('editorStyle');
    return options[style];
  }),

});
