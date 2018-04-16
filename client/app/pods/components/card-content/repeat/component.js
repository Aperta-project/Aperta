/**
 * Copyright (c) 2018 Public Library of Science
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
*/

import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';
import QAIdent from 'tahi/mixins/components/qa-ident';

export default Ember.Component.extend(QAIdent, {
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
