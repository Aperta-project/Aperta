import DS from 'ember-data';
import Ember from 'ember';

export default DS.Model.extend({
  unsortedChildren: DS.hasMany('card-content', {
    inverse: 'parent',
    async: false
  }),
  parent: DS.belongsTo('card-content', {
    async: false,
    inverse: 'unsortedChildren'
  }),
  answers: DS.hasMany('answer', { async: false }),
  repetitions: DS.hasMany('repetitions', { async: false }),

  allowMultipleUploads: DS.attr('boolean'),
  allowFileCaptions: DS.attr('boolean'),
  requiredField: DS.attr('boolean'),
  contentType: DS.attr('string'),
  ident: DS.attr('string'),
  possibleValues: DS.attr(),
  defaultAnswerValue: DS.attr(),
  order: DS.attr('number'),
  text: DS.attr('string'),
  instructionText: DS.attr('string'),
  label: DS.attr('string'),
  customChildClass: DS.attr('string'),
  customClass: DS.attr('string'),
  childTag: DS.attr('string'),
  wrapperTag: DS.attr('string'),
  valueType: DS.attr('string'),
  editorStyle: DS.attr('string'),
  condition: DS.attr('string'),
  visibleWithParentAnswer: DS.attr('string'),
  allowAnnotations: DS.attr('boolean'),
  answerable: Ember.computed.notEmpty('valueType'),
  errorMessage: DS.attr('string'),
  key: DS.attr('string'),
  min: DS.attr('number'),
  max: DS.attr('number'),
  itemName: DS.attr('string'),


  // The unusual nature of the sendback component (being reliant on other card-content within the context
  // of its rendering and behavior, as well as their order) had the side effect of adding answerContainer
  // element (which is used to flex-grid up the annotations component)
  // being wrapped around card-content that we actually wanted to be in-line. After deciding between
  // either having this be track on the card-content record in the DB or have it be a hard-coded override on the
  // model, it made sense to add it there to reduce complexity and because it's purely a display concern.
  overrideAnswerContainerOverrideables: ['sendback-reason'],

  overrideAnswerContainer: Ember.computed('contentType', function(){
    return this.get('overrideAnswerContainerOverrideables').includes(this.get('contentType'));
  }),

  hasInstructionText: Ember.computed.notEmpty('instructionText'),
  hasAdditionalText: Ember.computed.or('allowAnnotations', 'hasInstructionText'),
  anyChildRendersAsDualColumn: Ember.computed('unsortedChildren.@each.renderAsDualColumn', function() {
    return this.get('unsortedChildren').isAny('renderAsDualColumn');
  }),
  renderAsDualColumn: Ember.computed.or('hasAdditionalText', 'anyChildRendersAsDualColumn'),

  childrenSort: ['order:asc'],
  children: Ember.computed.sort('unsortedChildren', 'childrenSort'),

  visitDescendants(task, parentRepetition, f) {
    let repetitions = this.get('repetitions').filterBy('parent', parentRepetition).filterBy('task.id', task.get('id'));
    if(repetitions.length) {
      // we're a repeater, so now start using our repetitions.
    } else {
      // we're not a repeater, so we inherit a repetition from somewhere higher in the card content heirarchy.
      repetitions = [parentRepetition];
    }

    if(repetitions.length) {
      // traverse the card content for each repetition
      repetitions.forEach((repetition) => {
        this.get('children').forEach((child) => child.visitDescendants(task, repetition, f));
        f(this, repetition);
      });
    } else {
      // we're not inside a repetition, so just traverse the tree like normal
      this.get('children').forEach((child) => child.visitDescendants(task, null, f));
      f(this, null);
    }
  },

  destroyDescendants(owner, parentRepetition) {
    this.visitDescendants(owner, parentRepetition, (childCC, repetition) => {
      if(repetition) {
        childCC.get('answers').filterBy('owner', owner).filterBy('repetition', repetition).invoke('destroyRecord');

        if(childCC.get('repetitions').includes(repetition)) {
          repetition.destroyRecord();
        }
      } else {
        childCC.get('answers').filterBy('owner', owner).invoke('destroyRecord');
      }
    });
  },

  isRequired: Ember.computed.equal('requiredField', true),

  isRequiredString: Ember.computed('isRequired', function() {
    return this.get('isRequired') === true ? 'true' : 'false';
  }),

  createAnswerForOwner(owner, repetition){
    let store = this.get('store');
    let answer = store.createRecord('answer', {
      owner: owner,
      cardContent: this,
      repetition: repetition,
      value: this.parsedDefaultAnswerValue(),
    });

    return answer;
  },

  parsedDefaultAnswerValue() {
    let defaultAnswerValue = this.get('defaultAnswerValue');
    if(!defaultAnswerValue) { return; }

    if(this.get('valueType') === 'text')  {
      return defaultAnswerValue;
    } else {
      return JSON.parse(defaultAnswerValue);
    }
  },

  answerForOwner(owner, repetition) {
    if(!this.get('answerable')) {
      // only return answers for things that are actually
      // answerable (i.e., textboxes, radio buttons) and
      // not things like static text or paragraphs
      return;
    }

    if(repetition) {
      let answer = this.get('answers').filterBy('owner', owner).findBy('repetition', repetition);
      if(!answer) {
        answer = this.createAnswerForOwner(owner, repetition);
      }
      return answer;
    } else {
      return this.get('answers').findBy('owner', owner) ||
             this.createAnswerForOwner(owner);
    }
  }
});
