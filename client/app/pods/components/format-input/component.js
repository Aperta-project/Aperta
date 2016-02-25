import Ember from 'ember';
import findSelectedElements from 'tahi/lib/find-selected-elements';

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
    'disabled:read-only',
    ':format-input',
    'errorPresent:error',
    'active:format-input--active'
  ],
  errorPresent: Ember.computed.notEmpty('errors'),

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
   *  Apply focus to field on render
   *
   *  @property autofocus
   *  @type Boolean
   *  @default true
   *  @optional
  **/
  autofocus: false,

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
   *  Disable the input
   *
   *  @property disabled
   *  @type Boolean
   *  @default false
   *  @optional
  **/
  disabled: false,

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

  /**
   *  Find current formatting types within user selected text
   *
   *  @method getActiveFormatTypes
   *  @public
   */
  getActiveFormatTypes() {
    return _.map(findSelectedElements(), function(element) {
      const name = element.tagName.toLowerCase();

      if(ELEMENT_NAME_MAP[name]) {
        return ELEMENT_NAME_MAP[name];
      }
    });
  },

  /**
   *  Highlight format buttons as active within user selected text
   *
   *  @method _markActiveFormatTypes
   *  @private
   */
  _markActiveFormatTypes() {
    this._clearActiveFormatTypes();
    _.each(this.getActiveFormatTypes(), (type)=> {
      this.set(`_${type}Active`, true);
    });
  },

  /**
   *  Remove highlighing from formatting buttons
   *
   *  @method _clearActiveFormatTypes
   *  @private
   */
  _clearActiveFormatTypes() {
    _.each(ELEMENT_NAME_MAP, (type)=> {
      this.set(`_${type}Active`, false);
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
      this._markActiveFormatTypes();
    },

    'selection-out': function() {
      this._clearActiveFormatTypes();
    }
  }
});
