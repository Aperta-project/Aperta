import Ember from 'ember';
import TaskController from 'tahi/pods/task/controller';

export default TaskController.extend({
  billingApplicant: {
    firstName: "Albert",
    lastName: "Einstein",
    title: "Patent Clerk",
    department: "Patents",
    affiliation1: "",
    affiliation2: "",
    phoneNumber: "1234567890",
    emailAddress: "al@ec2.com",
    country: "USA",
    address1: "123 Main St",
    address2: "Unit 987",
    city: "San Francisco",
    state: "CA",
    postalCode: "94123"
  },
  ringgold: [,
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
    {id: 2, text: "NY"}
  ],
  inviteCode: '',
  endingComments: '',
  pubFee: 123.00,
  journalName: 'PLOS One',
  feeMessage: (function(){
    return "The fee for publishing in " + this.get("journalName") + " is $" + this.get("pubFee")
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
    {id: 1, text: "I will pay the full fee upon article acceptance"},
    {id: 2, text: "Institutional Account Program"},
    {id: 3, text: "PLOS Global Participation Initiative (GPI)"},
    {id: 4, text: "PLOS Publication Fee Assistance Program (PFA)"},
    {id: 5, text: "I have been invited to submit to a Special Collection"}
  ],
  selectedResponse: null,
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
  // agreeCollections: function() { return false; }.
  agreeCollections: false


});
