import Ember from 'ember';
import PositionNearMixin from 'tahi/mixins/components/position-near';

/*
Block Style:

{{#if peeps}}
  {{#auto-suggest-list positionNearSelector="#search-user-input"
                        class="animation-fade-in"
                        items=peeps
                        selectItem="selectUser"
                        itemClass="user-search-list-item" as |item|}}
    <img class="user-search-list-avatar" src={{item.avatar}}>
    {{item.fullName}}
    <span class="user-search-list-email">[{{item.email}}]</span>
  {{/auto-suggest-list}}
{{/if}}

Non Block Style with partial:

{{#if peeps}}
  {{auto-suggest-list positionNearSelector="#search-user-input"
                      class="animation-fade-in"
                      selectItem="selectUser"
                      items=peeps
                      itemPartial="user-search-list-item"
                      itemClass="user-search-list-item"}}
{{/if}}
*/

export default Ember.Component.extend(PositionNearMixin, {
  classNames: ['auto-suggest'],
  positionNearSelector: Ember.computed.alias('selector'),

  items: [],

  highlightedItem: null,
  highlightedItemIndex: Ember.computed('highlightedItem', function() {
    return this.get('items').indexOf( this.get('highlightedItem') );
  }),

  highlightFirstItem: Ember.on('didInsertElement', function() {
    this.set('highlightedItem', this.get('items.firstObject'));
  }),

  highlightlastItem() {
    this.set('highlightedItem', this.get('items.lastObject'));
  },

  highlightPrevious() {
    let index        = this.get('highlightedItemIndex');
    let previousItem = this.get('items').objectAt(--index);

    if(previousItem) {
      this.set('highlightedItem', previousItem);
    } else {
      this.highlightlastItem();
    }
  },

  highlightNext() {
    let index    = this.get('highlightedItemIndex');
    let nextItem = this.get('items').objectAt(++index);

    if(nextItem) {
      this.set('highlightedItem', nextItem);
    } else {
      this.highlightFirstItem();
    }
  },

  click() {
    this.sendAction('selectItem', this.get('highlightedItem'));
  },

  _setupKeybindings: Ember.on('didInsertElement', function() {
    $(document).on('keyup.autocomplete', (event)=> {
      switch(event.which) {
        case 13:
          // enter
          this.sendAction('selectItem', this.get('highlightedItem'));
          break;
        case 38:
          // arrow up
          this.highlightPrevious();
          break;
        case 40:
          // arrow down
          this.highlightNext();
          break;
      }
    });
  }),

  _teardownKeybindings: Ember.on('willDestroyElement', function() {
    $(document).off('keyup.autocomplete');
  })
});
