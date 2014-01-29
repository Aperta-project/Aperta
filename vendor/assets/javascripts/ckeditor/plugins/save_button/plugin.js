CKEDITOR.plugins.add( 'save_button', {
  icons: null,
  init: function( editor ) {
    editor.addCommand( 'savePaper', {
      exec: function( editor ) {
        url = $('main article').data('paperPath');
        Tahi.papers.savePaper(url);
      }
    });
    editor.ui.addButton( 'TahiSave', {
      label: 'Save',
      command: 'savePaper',
      toolbar: 'tahiSave'
    });
  }
});
