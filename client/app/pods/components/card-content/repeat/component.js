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

  repetitions: Ember.computed('content.repetitions.@each.isDeleted', 'repetition', function() {
    let parent = this.get('repetition');
    return this.get('content.repetitions').rejectBy('isDeleted').filter(function(rep) {
      if(parent) {
        return rep.get('parent') === parent;
      } else {
        return !rep.get('parent');
      }
    });
  }),

  addLabelText: Ember.computed('itemName', function() {
    return `Add ${this.get('itemName')}`;
  }),

  deleteLabelText: Ember.computed('itemName', function() {
    return `Delete ${this.get('itemName')}`;
  }),

  minRepetitionsReached: Ember.computed('repetitions', function() {
    if(this.get('min')) {
      return this.get('repetitions.length') <= this.get('min');
    }
  }),

  maxRepetitionsReached: Ember.computed('repetitions', function() {
    if(this.get('max')){
      return this.get('repetitions.length') >= this.get('max');
    }
  }),

  buildRepetition() {
    let repetition = this.get('store').createRecord('repetition', {
      cardContent: this.get('content'),
      parent: this.get('repetition')
    });

    if(!this.get('preview')) {
      // a task relationship is only applicable in non-previews (card-editor/previews aren't tasks)
      repetition.set('task', this.get('owner'));
      repetition.save();
    }

    return repetition;
  },

  actions: {
    addRepetition() {
      if(!this.get('maxRepetitionsReached')) {
        this.buildRepetition();
      }
    },

    deleteRepetition(repetition) {
      if(!this.get('minRepetitionsReached')) {
        repetition.cascadingDestroy();
      }
    },
  }
});
