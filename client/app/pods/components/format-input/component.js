import Ember from 'ember';

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
  classNameBindings: [':format-input', 'active:format-input--active'],

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

  /**
   *  Show/hide italic button
   *
   *  @property displayItalic
   *  @type Boolean
   *  @default true
   *  @optional
  **/
  displayItalic: true,

  /**
   *  Show/hide superscript button
   *
   *  @property displaySuperscript
   *  @type Boolean
   *  @default true
   *  @optional
  **/
  displaySuperscript: true,

  /**
   *  Show/hide subscript button
   *
   *  @property displaySubscript
   *  @type Boolean
   *  @default true
   *  @optional
  **/
  displaySubscript: true,

  /**
   *  Show/hide remove formatting button
   *
   *  @property displayRemove
   *  @type Boolean
   *  @default true
   *  @optional
  **/
  displayRemove: true,

  bold() {
    document.execCommand('bold',false, null);
    this.syncMarkupAndValue();
  },

  italic() {
    document.execCommand('italic', false, null);
    this.syncMarkupAndValue();
  },

  superscript() {
    document.execCommand('superscript', false, null);
    this.syncMarkupAndValue();
  },

  subscript() {
    document.execCommand('subscript', false, null);
    this.syncMarkupAndValue();
  },

  remove() {
    document.execCommand('removeFormat', false, null);
    this.syncMarkupAndValue();
  },

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

  actions: {
    format(type) {
      this[type]();
    },

    'focus-in': function() {
      this.set('active', true);
    },

    'focus-out': function() {
      this.set('active', false);
    }
  }
});
