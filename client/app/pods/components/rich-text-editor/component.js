import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

const basicElements    = 'p,br,strong/b,em/i,u,sub,sup,pre';
const basicPlugins     = '';
const basicToolbar     = 'bold italic underline | subscript superscript | undo redo';

const anchorElement    = ',a[href|rel|target|title]';
const expandedElements = ',div,span,code,ol,ul,li,h1,h2,h3,h4,table,thead,tbody,tfoot,tr,th,td';
const expandedPlugins  = ' code codesample link table';
const expandedToolbar  = ' | bullist numlist | table link | codesample code | formatselect';

const blockFormats     = 'Header 1=h1;Header 2=h2;Header 3=h3;Header 4=h4;Code=pre';

export default Ember.Component.extend({

  classNames: ['rich-text-editor'],

  /* some tinymce options are snake_case */
  /* eslint-disable camelcase */

  attributeBindings: ['data-editor'],
  'data-editor': Ember.computed.alias('name'),

  propTypes: {
    class: PropTypes.string,
    disabled: PropTypes.bool,
    editorStyle: PropTypes.string, // 'basic', 'expanded'
    ident: PropTypes.string,
    onContentsChanged: PropTypes.EmberObject.isRequired,
    placeholder: PropTypes.string,
    value: PropTypes.string
  },

  getDefaultProps () {
    return {
      disabled: false,
      editorStyle: 'expanded'
    };
  },

  bodyCSS: `
    .mce-content-body {
      color: #333;
      font-family: "Source Sans Pro", "source-sans-pro", helvetica, sans-serif;
      font-size: 14px;
      line-height: 20px;
    }`,

  name: Ember.computed('ident', function() {
    let ident = this.get('ident') || Ember.guidFor(this);
    return ident;
  }),

  editorConfigurations: {
    basic: {
      plugins: basicPlugins,
      statusbar: false,
      height: '4em',
      toolbar: basicToolbar,
      valid_elements: basicElements
    },

    expanded: {
      plugins: basicPlugins + expandedPlugins,
      block_formats: blockFormats,
      toolbar: basicToolbar + expandedToolbar,
      valid_elements: basicElements + anchorElement + expandedElements
    }
  },

  /* eslint-enable camelcase */

  configureCommon(hash) {
    hash['menubar'] = false;
    hash['content_style'] = this.get('bodyCSS');
    return hash;
  },

  editorOptions: Ember.computed('editorStyle', 'editorConfigurations', function() {
    let configs = this.get('editorConfigurations');
    let style = this.get('editorStyle');
    let options = configs[style];
    return this.configureCommon(options);
  })
});
