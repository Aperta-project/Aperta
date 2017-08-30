import ENV from 'tahi/config/environment';
import Ember from 'ember';

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

export default Ember.Component.extend({
  classNames: ['rich-text-editor'],
  attributeBindings: ['data-editor'],
  'data-editor': Ember.computed.alias('ident'),
  editor: null,

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

  pastePostprocess() {
    let editor = this.get('editor');
    var text = editor.getContent();
    text = text.replace(/<p> *(&nbsp;)* *<\/p>/ig, '');
    editor.setContent(text);
  },

  postRender() {
    let editor = this.childViews.find(child => child.editor).editor;
    this.set('editor', editor);      
    let iframeSelector = 'iframe#' + editor.id + '_ifr';
    document.querySelector(iframeSelector).removeAttribute('title');
    let callback = this.get('focusOut');
    if (callback) editor.on('blur', callback);
  },

  configureCommon(options) {
    options['menubar'] = false;
    options['content_style'] = this.get('bodyCSS');
    options['formats'] = basicFormats;
    options['elementpath'] = false;
    options['autoresize_max_height'] = 500;
    options['autoresize_bottom_margin'] = 1;
    options['autoresize_on_init'] = true;
    this.pastePostprocess = this.pastePostprocess.bind(this);
    options['paste_postprocess'] = this.pastePostprocess;
    
    if (ENV.environment === 'development') {
      options['toolbar'] += ' code';
    }
    Ember.run.schedule('afterRender', this, this.postRender);
    return options;
  },

  editorOptions: Ember.computed('editorStyle', 'editorConfigurations', function() {
    let configs = this.get('editorConfigurations');
    let style = this.get('editorStyle') || 'expanded';
    let options = Object.assign({}, configs[style]);
    return this.configureCommon(options);
  }),
});
