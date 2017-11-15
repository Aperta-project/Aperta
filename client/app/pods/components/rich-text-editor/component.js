/*global tinymce */

import ENV from 'tahi/config/environment';
import Ember from 'ember';
import TinyMceEditor from 'ember-cli-tinymce/components/tinymce-editor';

const inlineElements   = 'strong/b,em/i,u,sub,sup';

const basicElements    = 'p,br,' + inlineElements;
const basicFormats     = {underline: {inline : 'u'}};
const basicPlugins     = 'code codesample paste autoresize';
const basicToolbar     = 'bold italic underline | subscript superscript | undo redo ';

const anchorElement    = ',a[href|rel|target|title]';
const listElement      = ',ol[reversed|start|type]';

const expandedElements = ',div,span,code,ul,li,h1,h2,h3,h4,table,thead,tbody,tfoot,tr,th,td';
const expandedPlugins  = ' link table';
const expandedToolbar  = ' | bullist numlist | table link | formatselect';

const blockFormats     = 'Header 1=h1;Header 2=h2;Header 3=h3;Header 4=h4';

const rejectNewlines = function(editor) {
  editor.on('keydown', function(e) {
    if (e.keyCode === 13) return false;
  });
};

// Monkey patch TinyMceEditor to allow us to pass in an 'afterEditorInit' action. Otherwise, we aren't
// changing anything about this method.
TinyMceEditor.reopen({
  initTiny: Ember.on('didInsertElement', Ember.observer('options', function() {
    let {options, editor, afterEditorInit} = this.getProperties('options', 'editor', 'afterEditorInit');

    let initFunction = (editor) => {
      this.set('editor', editor);
      this.get('editor').setContent(this.get('value') || ''); //Set content with default text
      if (typeof afterEditorInit === 'function') {
        afterEditorInit(editor);
      }
    };

    let customOptions = {
      selector: `#${this.get('elementId')}`,
      init_instance_callback: Ember.run.bind(this, initFunction)
    };

    if (editor){
      editor.setContent('');
      editor.destroy();
    }

    tinymce.init(Ember.assign({}, options, customOptions));
  })),
});

export default Ember.Component.extend({
  classNames: ['rich-text-editor'],
  attributeBindings: ['data-editor'],
  'data-editor': Ember.computed.alias('ident'),

  bodyCSS: `
    .mce-content-body {
      color: #333;
      font-family: "Source Sans Pro", "source-sans-pro", helvetica, sans-serif;
      font-size: 14px;
      line-height: 20px;
    }

    .mce-content-body p {
      margin: 0 0 10px 0;
    }
  `,

  editorStyle: 'expanded',
  editorConfigurations: {
    /* some tinymce options are snake_case */
    /* eslint-disable camelcase */
    inline: {
      plugins: basicPlugins,
      toolbar: basicToolbar,
      valid_elements: inlineElements,
      forced_root_block: false,
      setup: rejectNewlines
    },

    basic: {
      plugins: basicPlugins,
      toolbar: basicToolbar,
      valid_elements: basicElements
    },

    expanded: {
      plugins: basicPlugins + expandedPlugins,
      block_formats: blockFormats,
      toolbar: basicToolbar + expandedToolbar,
      valid_elements: basicElements + anchorElement + listElement + expandedElements
    }
    /* eslint-enable camelcase */
  },

  hasFocus: false,

  editorIsEnabled: Ember.observer('disabled', function() {
    this.set('editorValue', this.get('value'));
  }).on('init'),

  // This prevents upstream changes from clobbering something that
  // a user is actively editing.
  updateEditorValueIfNotActive: Ember.observer('value', function() {
    if (!this.get('hasFocus')) {
      this.set('editorValue', this.get('value'));
    }
  }),

  pastePostprocess(editor, fragment) {
    function deleteEmptyParagraph(elem) {
      if (elem.nodeName === 'P' && /^\s*$/.test(elem.innerText)) {
        $(elem).remove();
      } else {
        Array.from(elem.children).forEach(deleteEmptyParagraph);
      }
    }

    deleteEmptyParagraph(fragment.node);
  },

  postRender(editor) {
    let iframeSelector = 'iframe#' + editor.id + '_ifr';
    document.querySelector(iframeSelector).removeAttribute('title');
    let callback = this.get('focusOut');
    if (callback) editor.on('blur', callback);
    editor.on('focus', () => this.set('hasFocus', true) );
    editor.on('blur', () => this.set('hasFocus', false) );
  },

  configureCommon(options) {
    options['menubar'] = false;
    options['content_style'] = this.get('bodyCSS');
    options['formats'] = basicFormats;
    options['elementpath'] = false;
    options['autoresize_max_height'] = 500;
    options['autoresize_bottom_margin'] = 1;
    options['autoresize_on_init'] = true;
    options['paste_postprocess'] = this.pastePostprocess.bind(this);

    if (ENV.environment === 'development') {
      options['toolbar'] += ' code';
    }
    return options;
  },

  editorOptions: Ember.computed('editorStyle', 'editorConfigurations', function() {
    let configs = this.get('editorConfigurations');
    let style = this.get('editorStyle') || 'expanded';
    let options = Object.assign({}, configs[style]);
    return this.configureCommon(options);
  }),

  // newValueCheck makes sure a model change has really occurred before triggering a save.
  // TinyMCE fires ValueChanged when any input event happens inside of the editor. This
  // will cut down on needlessly replaying the same data to rails.
  newValueCheck(editorValue) {
    const modelValue = this.get('value');

    // This will be true for TinyMCE editors that have focus when meta keys are pressed, and on mouse clicks.
    if (modelValue === editorValue) return;

    // This will be true for TinyMCE on the first click into a blank editor.
    if (Ember.isBlank(modelValue) && Ember.isBlank(editorValue)) return;

    this.get('onNewValue')(editorValue);
  }
});
