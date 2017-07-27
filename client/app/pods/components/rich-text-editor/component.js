import Ember from 'ember';

const basicElements    = 'p,br,strong/b,em/i,u,sub,sup,pre';
const basicFormats     = {underline: {inline : 'u'}};
const basicPlugins     = 'codesample paste';
const basicToolbar     = 'bold italic underline | subscript superscript | undo redo | codesample ';

const anchorElement    = ',a[href|rel|target|title]';
const listElement      = ',ol[reversed|start|type]';

const expandedElements = ',div,span,code,ul,li,h1,h2,h3,h4,table,thead,tbody,tfoot,tr,th,td';
const expandedPlugins  = ' link table';
const expandedToolbar  = ' | bullist numlist | table link | formatselect';

const blockFormats     = 'Header 1=h1;Header 2=h2;Header 3=h3;Header 4=h4';

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

  /* some tinymce options are snake_case */
  /* eslint-disable camelcase */

  editorStyle: 'expanded',
  editorConfigurations: {
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

  stripTitles() {
    let editors = window.tinymce.editors;
    for (let id of Object.keys(editors)) {
      let editor = editors[id];
      if (editor) {
        let ifr = window.tinymce.DOM.get(id + '_ifr');
        editor.dom.setAttrib(ifr, 'title', '');
      }
    }
  },

  configureCommon(options) {
    options['menubar'] = false;
    options['content_style'] = this.get('bodyCSS');
    options['formats'] = basicFormats;
    options['elementpath'] = false;
    Ember.run.schedule('afterRender', this.stripTitles);
    return options;
  },

  editorOptions: Ember.computed('editorStyle', 'editorConfigurations', function() {
    let configs = this.get('editorConfigurations');
    let style = this.get('editorStyle') || 'expanded';
    let options = Object.assign({}, configs[style]);
    return this.configureCommon(options);
  }),
});
