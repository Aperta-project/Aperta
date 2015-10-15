import Ember from 'ember';

const ELEMENT_NAME_MAP = {
  'b': 'bold',
  'i': 'italic',
  'sup': 'superscript',
  'sub': 'subscript'
};

/**
 *  format-input is an input like component for displaying an interface
 *  to content editable options.
 *
 *  The `content-editable` component is used in the `format-input` template
 *
 *  Basic example that displays all formatting buttons
 *  @example
 *    {{format-input value=someProperty}}
 *
 *  With a placeholder
 *  @example
 *    {{format-input value=someProperty
 *                   placeholder="Enter your email address"}}
 *
 *  Disable the bold button
 *  @example
 *    {{format-input value=someProperty
 *                   displayBold=false}}
 *
 *  @class FormatInputComponent
 *  @extends Ember.Component
 *  @since 1.3.3+
**/

export default Ember.Component.extend({
  classNameBindings: [
    ':format-input',
    'active:format-input--active'
  ],

  /**
   *  Text displayed in content-editable component
   *
   *  @property value
   *  @type any
   *  @default null
   *  @required
  **/
  value: null,

  /**
   *  Placeholder text displayed by content-editable component
   *
   *  @property placeholder
   *  @type String
   *  @default null
   *  @optional
  **/
  placeholder: null,

  /**
   *  Show/hide bold button
   *
   *  @property displayBold
   *  @type Boolean
   *  @default true
   *  @optional
  **/
  displayBold: true,
  _boldActive: false,

  /**
   *  Show/hide italic button
   *
   *  @property displayItalic
   *  @type Boolean
   *  @default true
   *  @optional
  **/
  displayItalic: true,
  _italicActive: false,

  /**
   *  Show/hide superscript button
   *
   *  @property displaySuperscript
   *  @type Boolean
   *  @default true
   *  @optional
  **/
  displaySuperscript: true,
  _superscriptActive: false,

  /**
   *  Show/hide subscript button
   *
   *  @property displaySubscript
   *  @type Boolean
   *  @default true
   *  @optional
  **/
  displaySubscript: true,
  _subscriptActive: false,

  /**
   *  This will pass the formatted content
   *  down to the content-editable component
   *
   *  @method syncMarkupAndValue
   *  @public
  **/
  syncMarkupAndValue() {
    this.set('value', this.$('.format-input-field').html());
  },

  // 
  getSelectedElements() {
    const selection = document.getSelection();

    if (
      !selection.rangeCount ||
      selection.isCollapsed ||
      !selection.getRangeAt(0).commonAncestorContainer
    ) {
      return [];
    }

    const range = selection.getRangeAt(0);

    if (range.commonAncestorContainer.nodeType === 3) {
      let toRet = [];
      let currNode = range.commonAncestorContainer;

      while (currNode.parentNode && currNode.parentNode.childNodes.length === 1) {
        toRet.push(currNode.parentNode);
        currNode = currNode.parentNode;
      }

      return toRet;
    }

    const containers = range.commonAncestorContainer.getElementsByTagName('*');
    const isFunction = typeof selection.containsNode === 'function';

    return _.filter(containers, function(element) {
      return isFunction ? selection.containsNode(element, true) : true;
    });
  },

  getActiveFormatTypes() {
    return _.map(this.getSelectedElements(), function(element) {
      const name = element.tagName.toLowerCase();

      if(ELEMENT_NAME_MAP[name]) {
        return ELEMENT_NAME_MAP[name];
      }
    });
  },

  markActiveFormatTypes() {
    this.clearActiveFormatTypes();
    _.each(this.getActiveFormatTypes(), (type)=> {
      this.set(`_${type}Active`, true);
    });
  },

  clearActiveFormatTypes() {
    $.each(ELEMENT_NAME_MAP, (type)=> {
      this.set(`_${ELEMENT_NAME_MAP[type]}Active`, false);
    });
  },

  actions: {
    format(type) {
      document.execCommand(type,false, null);
      this.syncMarkupAndValue();
    },

    'focus-in': function() {
      this.set('active', true);
    },

    'focus-out': function() {
      this.set('active', false);

      const action = this.attrs['focus-out'];
      if(action) { action(); }
    },

    'selection-in': function() {
      this.markActiveFormatTypes();
    },

    'selection-out': function() {
      this.clearActiveFormatTypes();
    }
  }
});
