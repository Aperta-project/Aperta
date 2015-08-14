import Ember from 'ember';

const { computed, on } = Ember;

/**
 *  select-box is a replacement for the html select element.
 *  - It is block style only (see example below)
 *  - It will iterate over the items attr and yield each item,
 *    this allows for each select-box-item to have custom content/style/layout
 *  - The makeSelection and clearSelection actions must use the
 *    action helper (see example below)
 *
 *  Example with just required attributes:
 *  @example
 *    {{#select-box items=journalsDataSource
 *                  selectedItem=model.journal
 *                  makeSelection=(action "selectJournal")
 *                  clearSelection=(action "clearJournal")
 *                  as |journal|}}
 *      {{journal.title}}
 *    {{/select-box}}
 *
 *  Example with all attributes:
 *  @example
 *    {{#select-box items=journalsDataSource
 *                  selectedItem=model.journal
 *                  placeholder="Please select a journal"
 *                  allowDeselect=true
 *                  makeSelection=(action "selectJournal")
 *                  clearSelection=(action "clearJournal")
 *                  as |journal|}}
 *      {{journal.title}}
 *    {{/select-box}}
 *
 *  @class SelectBoxComponent
 *  @extends Ember.Component
 *  @since 1.3.0
**/

export default Ember.Component.extend({
  classNames: ['select-box'],

  // -- attrs:

  /**
   *  Data source to display select-box-list
   *
   *  @property items
   *  @type Array
   *  @default null
   *  @required
  **/
  items: null,

  /**
   *  Used for highlighting select-box-item.
   *  When a selection is made, the outside context should modify this attr.
   *
   *  @property selectedItem
   *  @type any
   *  @default null
   *  @required
  **/
  selectedItem: null,

  /**
   *  Put placeholder as first option.
   *  requires clearSelection attr to be set or nothing will happen
   *  requires placeholder or no text will be displayed in first option
   *
   *  @property items
   *  @type Array
   *  @default null
   *  @requires placeholder, clearSelection
   *  @optional
  **/
  allowDeselect: false,

  /**
   *  Displayed in select-box-element when no items are selected.
   *  When the allowDeselect property is true, the first select-box-item will
   *  display with this placeholder text as well.
   *
   *  @property placeholder
   *  @type String
   *  @default null
   *  @optional
  **/
  placeholder: null,

  // -- props:

  /**
   *  Used in template to toggle visibility of select-box-list
   *
   *  @property _showOptions
   *  @type Boolean
   *  @default false
   *  @private
  **/
  _showOptions: false,

  /**
   *  Used in template for aria and positioning select-box-list
   *
   *  @property _generatedId
   *  @type String
   *  @default null
   *  @private
  **/
  _generatedId: null,

  /**
   *  Used in template for positioning select-box-list
   *
   *  @property _generatedIdSelector
   *  @type String
   *  @private
  **/
  _generatedIdSelector: computed('_generatedId', function() {
    return '#' + this.get('_generatedId');
  }),

  /**
   *  Used to give unique id to element placed in body to capture clicks
   *  outside of select-box
   *
   *  @property _generatedIdBackgroundCoverId
   *  @type String
   *  @private
  **/
  _generatedIdBackgroundCoverId: computed('_generatedId', function() {
    return this.get('_generatedId') + '-background-cover';
  }),

  /**
   *  Used to give unique id to element placed in body to capture clicks
   *  outside of select-box
   *
   *  @method _setGeneratedId
   *  @private
  **/
  _setGeneratedId: on('didInsertElement', function() {
    this.set('_generatedId', this.$().attr('id') + '-select');
  }),

  /**
   *  Make sure background cover doesn't hang around
   *
   *  @method _setGeneratedId
   *  @private
  **/
  _teardownBackgroundCover: on('willDestroyElement', function() {
    this.removeBackgroundCover();
  }),

  /**
   *  Listen for escape key to hide select-box-list
   *
   *  @method _setupKeybindings
   *  @private
  **/
  _setupKeybindings: on('didInsertElement', function() {
    Ember.$(document).on('keyup.selectbox', (event) => {
      // escape pressed
      if (event.which === 27 && this.get('_showOptions')) {
        this.toggleShowOptions();
      }
    });
  }),

  /**
   *  Cleanup keybindings
   *
   *  @method _teardownKeybindings
   *  @private
  **/
  _teardownKeybindings: on('willDestroyElement', function() {
    Ember.$(document).off('keyup.selectbox');
  }),

  /**
   *  Show select-box-list
   *
   *  @method toggleShowOptions
   *  @public
  **/
  toggleShowOptions() {
    this.toggleProperty('_showOptions');

    if(this.get('_showOptions')) {
      this._appendBackgroundCover();
    } else {
      this.removeBackgroundCover();
    }
  },

  /**
   *  Div placed in body to capture clicks outside of select-box
   *
   *  @method _appendBackgroundCover
   *  @private
  **/
  _appendBackgroundCover() {
    let id = this.get('_generatedIdBackgroundCoverId');
    Ember.$('body').append(
      `<div class="select-box-background-cover" id="${id}"></div>`
    );

    Ember.$('#' + id).on('click.selectBoxBackgroundCover', ()=> {
      this.toggleShowOptions();
    });
  },

  removeBackgroundCover() {
    let id = this.get('_generatedIdBackgroundCoverId');
    Ember.$('#' + id).off().remove();
  },

  actions: {
    toggleShowOptions() {
      this.toggleShowOptions();
    },

    makeSelection(selection) {
      this.toggleShowOptions();
      Ember.assert(
        'select-box requires the makeSelection action to be set',
        !Ember.isEmpty(this.attrs.makeSelection)
      );
      this.attrs.makeSelection(selection);
    },

    clearSelection() {
      this.toggleShowOptions();
      Ember.assert(
        'select-box allowDeselect was enabled but the clearSelection action was not set',
        !Ember.isEmpty(this.attrs.clearSelection)
      );
      this.attrs.clearSelection();
    }
  }
});
