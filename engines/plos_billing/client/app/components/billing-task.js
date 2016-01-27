import TaskComponent from 'tahi/pods/components/task-base/component';
import Ember from 'ember';
import DATA from 'tahi/plos-billing-form-data';

const { computed, observer } = Ember;

export default TaskComponent.extend({
  validations: {
    'plos_billing--first_name': ['presence'],
    'plos_billing--last_name': ['presence'],
    'plos_billing--department': ['presence'],
    'plos_billing--affiliation1': ['presence'],
    'plos_billing--phone_number': ['presence'],
    'plos_billing--email': ['presence'],
    'plos_billing--address1': ['presence'],
    'plos_billing--city': ['presence'],
    'plos_billing--postal_code': ['presence']
  },

  _paymentMethod: Ember.on('didInsertElement', function() {
    Ember.run.scheduleOnce('afterRender', ()=> {
      const choice = Ember.$('.payment-method .select2-container')
                          .select2('val');
      this.get('controller').set('selectedPaymentMethod', choice);
    });
  }),

  /*
    will hold pfa data validator
  */
  pfaData: null,

  /*
    Makes a self-contained Pfa Data validator, temporarily to avoid conflict
    with ValidationErrorsMixin 'tahi/mixins/validation-errors'
    This is called in billing-pfa component via onDidInsertElement
    Call is async because these question don't exist until
    pfa partial is inserted
  */
  buildPfaValidator: function(){
    const numericMessage = `Must be a number and contain no symbols, or letters,
                            e.g. $1,000.00 should be written 1000`;
    const numericalityConfig = { numericality: {
      allowBlank: true,
      onlyInteger: true,
      messages: {
        onlyInteger: numericMessage,
        numericality: numericMessage
      }
    }};

    const identsToValidateNumerically = [
      'plos_billing--pfa_question_1b',
      'plos_billing--pfa_question_2b',
      'plos_billing--pfa_question_3a',
      'plos_billing--pfa_question_4a',
      'plos_billing--pfa_amount_to_pay'
    ];

    const pfaDataClass = Ember.Object.extend(EmberValidations.Mixin, {
      validations: {},
      plos_billing: {},

      init: function(){
        let validations = this.get('validations');
        identsToValidateNumerically.forEach((ident) => {
          validations[ident + '.value'] = numericalityConfig;
        });

        // this must be called after we set up the validations since
        // ember-validations builds up its validators in its constructor
        this._super.apply(this, arguments);
      },

      // answersObserver makes sure validations occur on the most recent answers
      // since answers can be create/deleted/re-created based on user
      // interaction with the form.
      answersObserver: observer('model.nestedQuestionAnswers.[]', function(){
        identsToValidateNumerically.forEach((ident) => {
          let answer = this.get('model').answerForQuestion(ident);
          this.set(ident, answer);
        });
      }),

      // container required because we are creating an Ember.Object.
      // EmberValidations must need access.
      // Ember.Object is not assigned this property unless
      // generated through the container
      container: this.get('container'),

      model: this.get('task')
    });

    this.set('pfaData', pfaDataClass.create());
  },

  /*
    Sets error message bound to validationErrors.completed
    in -overlay-completed-checkbox when data invalid
  */
  _showErrorsInFormMsg: Ember.observer('pfa', 'pfaData.isValid', function(){
    let msg = null;

    if (this.get('pfa')) { //only if payment method is pfa
      if (!this.get('pfaData.isValid')) { msg = 'Errors in form'; }
    }

    this.set('validationErrors.completed', msg);
  }),

  /*
    Overloads inherited isEditable in TaskController
    When false, makes complete box uncheckable
  */
  isEditable: computed(
    'pfa', 'pfaData.isValid', 'isUserEditable', 'currentUser.siteAdmin',
    function() {
      if (this.get('pfa')){
        return this.get('pfaData.isValid') && this._super();
      } else {
        return this._super();
      }
    }
  ),

  countries: Ember.inject.service(),
  ringgold: [],
  institutionalAccountProgramList: DATA.institutionalAccountProgramList,
  states:    DATA.states,
  pubFee:    DATA.pubFee,
  journals:  DATA.journals,
  responses: DATA.responses,
  groupOneAndTwoCountries: DATA.groupOneAndTwoCountries,

  _fetchCountries: Ember.on('init', function() {
    this.get('countries').fetch();
  }),
  formattedCountries: computed('countries.data', function() {
    return this.get('countries.data').map(function(c) {
      return { id: c, text: c };
    });
  }),

  journalName: 'PLOS One',
  inviteCode: '',
  endingComments: '',

  feeMessage: computed('journalName', function() {
    return 'The fee for publishing in ' + this.get('journalName') +
      ' is $' + this.get('pubFee');
  }),

  selectedRinggold: null,
  selectedPaymentMethod: computed('model.nestedQuestionAnswers.[]', function(){
    return this.get('task')
               .answerForQuestion('plos_billing--payment_method')
               .get('value');
  }),

  selfPayment: computed.equal('selectedPaymentMethod', 'self_payment'),
  institutional: computed.equal('selectedPaymentMethod', 'institutional'),
  gpi: computed.equal('selectedPaymentMethod', 'gpi'),
  pfa: computed.equal('selectedPaymentMethod', 'pfa'),
  specialCollection: computed.equal(
    'selectedPaymentMethod', 'special_collection'
  ),

  agreeCollections: false,

  affiliation1Question: computed('model.nestedQuestions.[]', function() {
    return this.get('task').findQuestion('plos_billing--affiliation1');
  }),

  affiliation2Question: computed('model.nestedQuestions.[]', function() {
    return this.get('task').findQuestion('plos_billing--affiliation2');
  }),

  // institution-search component expects data to be hash
  // with name property
  affiliation1Proxy: computed('affiliation1Question', function(){
    let question = this.get('affiliation1Question');
    let answer = question.answerForOwner(this.get('task'));
    if(answer.get('wasAnswered')) {
      return { name: answer.get('value') };
    }
  }),

  // institution-search component expects data to be hash
  // with name property
  affiliation2Proxy: computed('affiliation2Question', function(){
    let question = this.get('affiliation2Question');
    let answer = question.answerForOwner(this.get('task'));
    if(answer.get('wasAnswered')) {
      return { name: answer.get('value') };
    }
  }),

  setAffiliationAnswer(index, answerValue) {
    let question = this.get('affiliation' + index + 'Question');
    let answer = question.answerForOwner(this.get('task'));

    if(typeof answerValue === 'string') {
      answer.set('value', answerValue);
    } else if(typeof answerValue === 'object') {
      answer.set('value', answerValue.name);
      answer.set('additionalData', {
        answer: answerValue.name,
        additionalData: answerValue
      });
    }

    answer.save();
  },

  actions: {
    paymentMethodSelected(selection) {
      this.set('selectedPaymentMethod', selection.id);
    },

    affiliation1Selected(answer) { this.setAffiliationAnswer('1', answer); },
    affiliation2Selected(answer) { this.setAffiliationAnswer('2', answer); }
  }
});
