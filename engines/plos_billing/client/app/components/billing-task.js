import TaskComponent from 'tahi/pods/components/task-base/component';
import EmberValidations from 'ember-validations';
import Ember from 'ember';

const DATA = {
  institutionalAccountProgramList: [
    // Canada
    { id: 'Memorial University of Newfoundland',
      text: 'Memorial University of Newfoundland' },
    { id: 'Ryerson University', text: 'Ryerson University' },
    { id: 'Simon Fraser University', text: 'Simon Fraser University' },
    // Croatia
    { id: 'Faculty of Humanities and Social Sciences Library',
      text: 'Faculty of Humanities and Social Sciences Library' },
    // Denmark
    { id: 'Odense University Hospital', text: 'Odense University Hospital' },
    { id: 'University of Southern Denmark',
      text: 'University of Southern Denmark' },
    // Germany
    { id: 'Bielefeld University',           text: 'Bielefeld University' },
    { id: 'Helmholtz Association of German Research Centres',
      text: 'Helmholtz Association of German Research Centres' },
    { id: 'Max Planck Institutes',          text: 'Max Planck Institutes' },
    { id: 'Ruhr University Bochum',         text: 'Ruhr University Bochum' },
    { id: 'Technische Universität München',
      text: 'Technische Universität München' },
    { id: 'University of Potsdam',          text: 'University of Potsdam' },
    { id: 'University of Regensburg',       text: 'University of Regensburg' },
    { id: 'University of Stuttgart',        text: 'University of Stuttgart' },
    // Italy
    { id: 'Fondazione Telethon', text: 'Fondazione Telethon' },
    // Luxembourg
    { id: 'Institute for Health & Behavior',
      text: 'Institute for Health & Behavior' },
    // Mexico
    { id: 'CINVESTAV Unidad Irapuato', text: 'CINVESTAV Unidad Irapuato' },
    // Netherlands
    { id: 'Delft University of Technology',
      text: 'Delft University of Technology' },
    // Singapore
    { id: 'Temasek Life Sciences Laboratory',
      text: 'Temasek Life Sciences Laboratory' },
    // Sweden
    { id: 'Lund University', text: 'Lund University' },
    // Switzerland
    { id: 'ETH Zurich', text: 'ETH Zurich' },
    // United Kingdom
    { id: 'Brunel University',               text: 'Brunel University' },
    { id: 'John Innes Centre',               text: 'John Innes Centre' },
    { id: 'Newcastle University',            text: 'Newcastle University' },
    { id: 'Queen Mary University of London',
      text: 'Queen Mary University of London' },
    { id: 'Queen\'s University Belfast',
      text: 'Queen\'s University Belfast' },
    { id: 'University College London (UCL)',
      text: 'University College London (UCL)' },
    { id: 'University of Birmingham',   text: 'University of Birmingham' },
    { id: 'University of Bristol',      text: 'University of Bristol' },
    { id: 'University of Edinburgh',    text: 'University of Edinburgh' },
    { id: 'University of Glasgow',      text: 'University of Glasgow' },
    { id: 'University of Leeds',        text: 'University of Leeds' },
    { id: 'University of Manchester',   text: 'University of Manchester' },
    { id: 'University of Reading',      text: 'University of Reading' },
    { id: 'University of St. Andrews ', text: 'University of St. Andrews' },
    { id: 'University of Stirling',     text: 'University of Stirling' },
    { id: 'University of Warwick',      text: 'University of Warwick' },
    // United States
    { id: 'George Mason University', text: 'George Mason University' },
  ],

  groupOneAndTwoCountries: [
    { id: 'Afghanistan', text: 'Afghanistan' },
    { id: 'Albania', text: 'Albania' },
    { id: 'Algeria', text: 'Algeria' },
    { id: 'Angola', text: 'Angola' },
    { id: 'Armenia', text: 'Armenia' },
    { id: 'Bangladesh', text: 'Bangladesh' },
    { id: 'Belize', text: 'Belize' },
    { id: 'Benin', text: 'Benin' },
    { id: 'Bhutan', text: 'Bhutan' },
    { id: 'Bolivia, Plurinational State of',
      text: 'Bolivia, Plurinational State of' },
    { id: 'Bosnia and Herzegovina', text: 'Bosnia and Herzegovina' },
    { id: 'Botswana', text: 'Botswana' },
    { id: 'Burkina Faso', text: 'Burkina Faso' },
    { id: 'Burundi', text: 'Burundi' },
    { id: 'Cambodia', text: 'Cambodia' },
    { id: 'Cameroon', text: 'Cameroon' },
    { id: 'Cape Verde', text: 'Cape Verde' },
    { id: 'Central African Republic', text: 'Central African Republic' },
    { id: 'Chad', text: 'Chad' },
    { id: 'Comoros', text: 'Comoros' },
    { id: 'Congo', text: 'Congo' },
    { id: 'Congo, The Democratic Republic of the',
      text: 'Congo, The Democratic Republic of the' },
    { id: 'Cook Islands', text: 'Cook Islands' },
    { id: 'Cote d’Ivoire', text: 'Cote d’Ivoire' },
    { id: 'Djibouti', text: 'Djibouti' },
    { id: 'Dominca', text: 'Dominca' },
    { id: 'Dominican Republic', text: 'Dominican Republic' },
    { id: 'East Timor', text: 'East Timor' },
    { id: 'Ecuador', text: 'Ecuador' },
    { id: 'Egypt', text: 'Egypt' },
    { id: 'El Salvador', text: 'El Salvador' },
    { id: 'Equatorial Guinea', text: 'Equatorial Guinea' },
    { id: 'Eritrea', text: 'Eritrea' },
    { id: 'Ethiopia', text: 'Ethiopia' },
    { id: 'Fiji', text: 'Fiji' },
    { id: 'Gabon', text: 'Gabon' },
    { id: 'Gambia', text: 'Gambia' },
    { id: 'Georgia', text: 'Georgia' },
    { id: 'Ghana', text: 'Ghana' },
    { id: 'Grenada', text: 'Grenada' },
    { id: 'Guatamala', text: 'Guatamala' },
    { id: 'Guinea', text: 'Guinea' },
    { id: 'Guinea-Bissau', text: 'Guinea-Bissau' },
    { id: 'Guyana', text: 'Guyana' },
    { id: 'Haiti', text: 'Haiti' },
    { id: 'Honduras', text: 'Honduras' },
    { id: 'India', text: 'India' },
    { id: 'Indonesia', text: 'Indonesia' },
    { id: 'Iraq', text: 'Iraq' },
    { id: 'Jamaica', text: 'Jamaica' },
    { id: 'Jordan', text: 'Jordan' },
    { id: 'Kenya', text: 'Kenya' },
    { id: 'Kiribati', text: 'Kiribati' },
    { id: 'Korea, Democratic People’s Republic of',
      text: 'Korea, Democratic People’s Republic of' },
    { id: 'Kyrgyzstan', text: 'Kyrgyzstan' },
    { id: 'Lao People’s Democratic Republic',
      text: 'Lao People’s Democratic Republic' },
    { id: 'Lesotho', text: 'Lesotho' },
    { id: 'Liberia', text: 'Liberia' },
    { id: 'Macedonia, The Former Yugoslav Republic of',
      text: 'Macedonia, The Former Yugoslav Republic of' },
    { id: 'Madagascar', text: 'Madagascar' },
    { id: 'Malawi', text: 'Malawi' },
    { id: 'Maldives', text: 'Maldives' },
    { id: 'Mali', text: 'Mali' },
    { id: 'Marshall Islands', text: 'Marshall Islands' },
    { id: 'Mauritania', text: 'Mauritania' },
    { id: 'Mauritius', text: 'Mauritius' },
    { id: 'Micronesia, Federated States of',
      text: 'Micronesia, Federated States of' },
    { id: 'Moldova, Republic of', text: 'Moldova, Republic of' },
    { id: 'Mongolia', text: 'Mongolia' },
    { id: 'Montenegro', text: 'Montenegro' },
    { id: 'Morocco', text: 'Morocco' },
    { id: 'Mozambique', text: 'Mozambique' },
    { id: 'Myanamar', text: 'Myanamar' },
    { id: 'Namibia', text: 'Namibia' },
    { id: 'Nauru', text: 'Nauru' },
    { id: 'Nepal', text: 'Nepal' },
    { id: 'Nicaragua', text: 'Nicaragua' },
    { id: 'Niger', text: 'Niger' },
    { id: 'Nigeria', text: 'Nigeria' },
    { id: 'Niue', text: 'Niue' },
    { id: 'Pakistan', text: 'Pakistan' },
    { id: 'Palau', text: 'Palau' },
    { id: 'Palestine, State of', text: 'Palestine, State of' },
    { id: 'Papua New Guinea', text: 'Papua New Guinea' },
    { id: 'Paraguay', text: 'Paraguay' },
    { id: 'Peru', text: 'Peru' },
    { id: 'Phillipines', text: 'Phillipines' },
    { id: 'Rwanda', text: 'Rwanda' },
    { id: 'Saint Kitts and Nevis', text: 'Saint Kitts and Nevis' },
    { id: 'Saint Lucia', text: 'Saint Lucia' },
    { id: 'Saint Vincent and the Grenadines',
      text: 'Saint Vincent and the Grenadines' },
    { id: 'Samoa', text: 'Samoa' },
    { id: 'Sao Tome and Principe', text: 'Sao Tome and Principe' },
    { id: 'Senegal', text: 'Senegal' },
    { id: 'Seychelles', text: 'Seychelles' },
    { id: 'Sierra Leone', text: 'Sierra Leone' },
    { id: 'Solomon Islands', text: 'Solomon Islands' },
    { id: 'Somalia', text: 'Somalia' },
    { id: 'South Sudan', text: 'South Sudan' },
    { id: 'Sri Lanka', text: 'Sri Lanka' },
    { id: 'Sudan', text: 'Sudan' },
    { id: 'Suriname', text: 'Suriname' },
    { id: 'Swaziland', text: 'Swaziland' },
    { id: 'Syrian Arab Republic', text: 'Syrian Arab Republic' },
    { id: 'Tajikistan', text: 'Tajikistan' },
    { id: 'Tanzania, United Republic of',
      text: 'Tanzania, United Republic of' },
    { id: 'Togo', text: 'Togo' },
    { id: 'Tokelau', text: 'Tokelau' },
    { id: 'Tonga', text: 'Tonga' },
    { id: 'Tunisia', text: 'Tunisia' },
    { id: 'Turkmenistan', text: 'Turkmenistan' },
    { id: 'Tuvalu', text: 'Tuvalu' },
    { id: 'Uganda', text: 'Uganda' },
    { id: 'Ukraine', text: 'Ukraine' },
    { id: 'Uzbekistan', text: 'Uzbekistan' },
    { id: 'Vanuatu', text: 'Vanuatu' },
    { id: 'Vietnam', text: 'Vietnam' },
    { id: 'Western Sahara', text: 'Western Sahara' },
    { id: 'Yemen', text: 'Yemen' },
    { id: 'Zambia', text: 'Zambia' },
    { id: 'Zimbabwe', text: 'Zimbabwe' }
  ],

  usStates: [
    { id: 'AL', text: 'AL' },
    { id: 'AK', text: 'AK' },
    { id: 'AZ', text: 'AZ' },
    { id: 'AR', text: 'AR' },
    { id: 'CA', text: 'CA' },
    { id: 'CO', text: 'CO' },
    { id: 'CT', text: 'CT' },
    { id: 'DE', text: 'DE' },
    { id: 'FL', text: 'FL' },
    { id: 'GA', text: 'GA' },
    { id: 'HI', text: 'HI' },
    { id: 'ID', text: 'ID' },
    { id: 'IL', text: 'IL' },
    { id: 'IN', text: 'IN' },
    { id: 'IA', text: 'IA' },
    { id: 'KS', text: 'KS' },
    { id: 'KY', text: 'KY' },
    { id: 'LA', text: 'LA' },
    { id: 'ME', text: 'ME' },
    { id: 'MD', text: 'MD' },
    { id: 'MA', text: 'MA' },
    { id: 'MI', text: 'MI' },
    { id: 'MN', text: 'MN' },
    { id: 'MS', text: 'MS' },
    { id: 'MO', text: 'MO' },
    { id: 'MT', text: 'MT' },
    { id: 'NE', text: 'NE' },
    { id: 'NV', text: 'NV' },
    { id: 'NH', text: 'NH' },
    { id: 'NJ', text: 'NJ' },
    { id: 'NM', text: 'NM' },
    { id: 'NY', text: 'NY' },
    { id: 'NC', text: 'NC' },
    { id: 'ND', text: 'ND' },
    { id: 'OH', text: 'OH' },
    { id: 'OK', text: 'OK' },
    { id: 'OR', text: 'OR' },
    { id: 'PA', text: 'PA' },
    { id: 'RI', text: 'RI' },
    { id: 'SC', text: 'SC' },
    { id: 'SD', text: 'SD' },
    { id: 'TN', text: 'TN' },
    { id: 'TX', text: 'TX' },
    { id: 'UT', text: 'UT' },
    { id: 'VT', text: 'VT' },
    { id: 'VA', text: 'VA' },
    { id: 'WA', text: 'WA' },
    { id: 'WV', text: 'WV' },
    { id: 'WI', text: 'WI' },
    { id: 'WY', text: 'WY' }
  ],

  pubFee: 123.00,

  journals: [
    {
      name: 'PLOS Biology',
      price: 2900,
      collectionSurcharge: 1000,
      totalPrice: 3900
    },
    {
      name: 'PLOS Medicine',
      price: 2900,
      collectionSurcharge: 1000,
      totalPrice: 3900
    },
    {
      name: 'PLOS Computational Biology',
      price: 2250,
      collectionSurcharge: 750,
      totalPrice: 3000
    },
    {
      name: 'PLOS Genetics',
      price: 2250,
      collectionSurcharge: 750,
      totalPrice: 3000
    },
    {
      name: 'PLOS Neglected Tropical Diseases',
      price: 2250,
      collectionSurcharge: 750,
      totalPrice: 3000
    },
    {
      name: 'PLOS Pathogens',
      price: 2250,
      collectionSurcharge: 750,
      totalPrice: 3000
    },
    {
      name: 'PLOS ONE',
      price: 1350,
      collectionSurcharge: 500,
      totalPrice: 1850
    },
  ],

  responses: [
    { id: 'self_payment',
      text: 'I will pay the full fee upon article acceptance' },
    { id: 'institutional',
      text: 'Institutional Account Program' },
    { id: 'gpi',
      text: 'PLOS Global Participation Initiative (GPI)' },
    { id: 'pfa',
      text: 'PLOS Publication Fee Assistance Program (PFA)' },
    { id: 'special_collection',
      text: 'I have been invited to submit to a Special Collection' }
  ]
};

const computed = Ember.computed;

export default TaskComponent.extend({
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
    const numericalityConfig = { numericality: {
      allowBlank: true,
      messages: {
        numericality: 'Must be a number and contain no symbols, or letters'
      }
    }};

    const identsToValidateNumerically = [
      'pfa_question_1b',
      'pfa_question_2b',
      'pfa_question_3a',
      'pfa_question_4a',
      'pfa_amount_to_pay'
    ];

    const pfaDataClass = Ember.Object.extend(EmberValidations.Mixin, {
      validations: {},

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
      // since answers can be create/deleted/re-created based on user interaction
      // with the form.
      answersObserver: Ember.observer('task.nestedQuestionAnswers.[]', function(){
        let answers = Ember.A();
        identsToValidateNumerically.forEach((ident) => {
          let answer = this.get('task').answerForQuestion(ident);
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
  isEditable: computed('pfa', 'pfaData.isValid', 'isUserEditable', 'currentUser.siteAdmin', function() {
    if (this.get('pfa')){
      return this.get('pfaData.isValid') && this._super();
    } else {
      return this._super();
    }
  }),

  countries: Ember.inject.service(),
  ringgold: [],
  institutionalAccountProgramList: DATA.institutionalAccountProgramList,
  usStates:  DATA.usStates,
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
  selectedPaymentMethod: computed('task.nestedQuestionAnswers.[]', function(){
    let answer = this.get('task').answerForQuestion('payment_method');
    return answer.get('value');
  }),

  selfPayment: computed.equal('selectedPaymentMethod', 'self_payment'),
  institutional: computed.equal('selectedPaymentMethod', 'institutional'),
  gpi: computed.equal('selectedPaymentMethod', 'gpi'),
  pfa: computed.equal('selectedPaymentMethod', 'pfa'),
  specialCollection: computed.equal(
    'selectedPaymentMethod', 'special_collection'
  ),

  agreeCollections: false,

  affiliation1Question: computed('task.nestedQuestions.[]', function() {
    return this.get('task').findQuestion('affiliation1');
  }),

  affiliation2Question: computed('task.nestedQuestions.[]', function() {
    return this.get('task').findQuestion('affiliation2');
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
