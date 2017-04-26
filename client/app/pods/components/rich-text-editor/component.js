import Ember from 'ember';

/* tinymce requires snake_case option names */
/* eslint-disable camelcase */

export default Ember.Component.extend({
  editorStyle: 'expanded',
  editorConfigurations: {
    basic: {
      menubar: false,
      plugins: 'preview',
      statusbar: false,
      toolbar: 'italic | subscript superscript | undo redo | preview',
      valid_elements: 'p,br,em/i,sub,sup'
    },

    expanded: {
      menubar: false,
      plugins: 'code preview table',
      block_formats: 'Header 1=h1;Header 2=h2;Header 3=h3;Header 4=h4',
      toolbar: 'bold italic underline | subscript superscript | \
                bullist numlist table | undo redo | code preview | formatselect',
      valid_elements: 'p,br,strong/b,em/i,u,sub,sup,ol,ul,li,h1,h2,h3,h4,table,thead,tbody,tr,th,td'
    }
  },

/* eslint-enable camelcase */

  editorOptions: Ember.computed('editorStyle', 'editorConfigurations', function() {
    let options = this.get('editorConfigurations');
    let style = this.get('editorStyle') || 'expanded';
    return options[style];
  }),
});
