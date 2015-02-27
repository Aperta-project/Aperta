import Ember from 'ember';
import TaskController from 'tahi/pods/task/controller';

export default TaskController.extend({
  // billingDetail: Em.computed.alias('model.billingDetail.firstObject'),
  affiliation1: null,
  ringgold: [
    { id: 123, text: "Memorial University of Newfoundland" },
    { id: 124, text: "Ryerson University" },
    { id: 125, text: "Simon Fraser University" },
    { id: 123, text: "University of Manitoba" },
    { id: 123, text: "Faculty of Humanities and Social Sciences Library" },
    { id: 123, text: "Odense University Hospital" },
    { id: 123, text: "University of Southern Denmark" },
    { id: 123, text: "Bielefeld University" },
    { id: 123, text: "Helmholtz Association of German Research Centres" },
    { id: 123, text: "Max Planck Institutes" },
    { id: 123, text: "Ruhr University Bochum" },
    { id: 123, text: "Technische Universität München" },
    { id: 123, text: "University of Regensburg" },
    { id: 123, text: "University of Stuttgart" },
    { id: 123, text: "Fondazione Telethon" },
    { id: 123, text: "Institute for Health & Behavior" },
    { id: 123, text: "CINVESTAV Unidad Irapuato" },
    { id: 123, text: "Delft University of Technology" },
    { id: 123, text: "Temasek Life Sciences Laboratory" },
    { id: 123, text: "Lund University" },
    { id: 123, text: "ETH Zurich" },
    { id: 123, text: "Brunel University" },
    { id: 123, text: "John Innes Centre" },
    { id: 123, text: "London School of Hygiene & Tropical Medicine" },
    { id: 123, text: "Newcastle University" },
    { id: 123, text: "Queen’s University Belfast" },
    { id: 123, text: "University College London (UCL)" },
    { id: 123, text: "University of Birmingham" },
    { id: 123, text: "University of Glasgow" },
    { id: 123, text: "University of Leeds" },
    { id: 123, text: "University of St. Andrews " },
    { id: 123, text: "University of Stirling" },
    { id: 123, text: "George Mason University" }
  ],
  countries: [
    {id: 1, text: "USA"},
    {id: 2, text: "Mexico"}
  ],
  states: [
    {id: 1, text: "CA"},
    {id: 2, text: "NY"},
    {id: 3, text: "WA"}
  ],
  inviteCode: '',
  endingComments: '',
  pubFee: 123.00,
  journalName: 'PLOS One',
  feeMessage: (function(){
    return "The fee for publishing in " + this.get("journalName") + 
      " is $" + this.get("pubFee")
  }).property("journalName"),
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
    {id: 'self_payment', text: "I will pay the full fee upon article acceptance"},
    {id: 'institutional', text: "Institutional Account Program"},
    {id: 'gpi', text: "PLOS Global Participation Initiative (GPI)"},
    {id: 'pfa', text: "PLOS Publication Fee Assistance Program (PFA)"},
    {id: 'special_collection', text: "I have been invited to submit to a Special Collection"}
  ],
  selectedRinggold: null,
  selfPayment: function() {
    return this.selectedResponse == 1;
  }.property("selectedResponse"),
  institutional: function() {
    return this.selectedResponse == 2;
  }.property("selectedResponse"),
  gpi: function() {
    return this.selectedResponse == 3;
  }.property("selectedResponse"),
  pfa: function() {
    return this.selectedResponse == 4;
  }.property("selectedResponse"),
  specialCollection: function() {
    return this.selectedResponse == 5;
  }.property("selectedResponse"),
  onSelectedOption: function() {
    // alert(this.selectedResponse);
  }.observes('selectedResponse'),
  agreeCollections: false,
  actions: {
    submitToDB: function() {
      var detail = this.get("billingDetail").content;
      detail.save()
      alert("I'm submitting!")
    },
    setBillingDetails: function() {
      // var journalId = this.get("model.paper.journal.id");
      // var paperId = this.get("model.paper.id");

      // Try to find a Billing Record for this Paper, within this Journal
      // TODO: stop hardcoding the paper ID.
      // this.set("billingDetail", this.store.find("billingDetail", 1));
      // else...
      // Create a Record if it does not exist
      // var billing = this.store.createRecord('billingDetail', {
      //   journalId: journalId,
      //   paperId: paperId,
      //   pfa_question_1: 'hello'
      // });
      // billing.save()
    }
  },
  selectedPayment: function() {
    var paymentMethod = 'gpi'
    // var paymentMethod = this.get("billingDetail.paymentMethod")

    var match = this.get('responses').find(function(element, index, array) {
      if (element.id === paymentMethod) {
        return true;
      } else {
        return false;
      }
    })

    return {
      id: match.id,
      text: match.text
    }


    this.get('billingDetail.paymentMethod')
  }.property("billingDetail")

});
