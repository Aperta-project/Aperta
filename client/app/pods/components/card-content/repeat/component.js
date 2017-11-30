import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  classNames: ['card-content-repeat'],
  store: Ember.inject.service(),
  min: Ember.computed.readOnly('content.min'),
  max: Ember.computed.readOnly('content.max'),
  itemName: Ember.computed.readOnly('content.itemName'),

  propTypes: {
    content: PropTypes.EmberObject.isRequired,
    disabled: PropTypes.bool,
    owner: PropTypes.EmberObject.isRequired,
    repetition: PropTypes.oneOfType([PropTypes.null, PropTypes.EmberObject]).isRequired,
    preview: PropTypes.bool
  },

  init() {
    this._super(...arguments);

    Ember.run.once(this, 'addMinimumRepetitions');
  },

  addMinimumRepetitions() {
    let toAdd =  this.get('min') - this.get('repetitions.length');
    for(let i = 0; i < toAdd; i++) {
      this.buildRepetition();
    }
  },

  unsortedRepetitions: Ember.computed('content.repetitions.@each.isDeleted', 'repetition', 'owner', function() {
    let parent = this.get('repetition');
    return this.ownedRepetitions().rejectBy('isDeleted').filter(function(rep) {
      if(parent) {
        return rep.get('parent') === parent;
      } else {
        return !rep.get('parent');
      }
    });
  }),
  ownedRepetitions() {
    let contentRepetitions = this.get('content.repetitions');
    return contentRepetitions.filterBy('task.id', this.get('owner.id'));
  },
  repetitionSort: ['position:asc'],
  repetitions: Ember.computed.sort('unsortedRepetitions', 'repetitionSort'),

  addLabelText: Ember.computed('itemName', function() {
    return `Add ${this.get('itemName')}`;
  }),

  deleteLabelText: Ember.computed('itemName', function() {
    return `Delete ${this.get('itemName')}`;
  }),

  canDeleteRepetition: Ember.computed('disabled', 'repetitions.[]', function() {
    if(this.get('disabled')) {
      return false;
    }
    if(this.get('min')) {
      return this.get('repetitions.length') > this.get('min');
    } else {
      return true;
    }
  }),

  canAddRepetition: Ember.computed('disabled', 'repetitions.[]', function() {
    if(this.get('disabled')) {
      return false;
    }
    if(this.get('max')){
      return this.get('repetitions.length') < this.get('max');
    } else {
      return true;
    }
  }),

  buildRepetition(previousRepetition) {
    let position = previousRepetition ? previousRepetition.get('position') + 1 : this.get('repetitions.length');
    let repetition = this.get('store').createRecord('repetition', {
      cardContent: this.get('content'),
      parent: this.get('repetition'),
      task: this.get('owner'),
      position: position,
    });

    if(!this.get('preview')) {
      // a task relationship is only applicable in non-previews (card-editor/previews aren't tasks)
      repetition.save();
    }

    return repetition;
  },

  actions: {
    addRepetition(repetition) {
      if(this.get('canAddRepetition')) {
        this.buildRepetition(repetition);
      }
    },

    deleteRepetition(repetition) {
      if(this.get('canDeleteRepetition')) {
        repetition.cascadingDestroy();
      }
    },
  }
});
