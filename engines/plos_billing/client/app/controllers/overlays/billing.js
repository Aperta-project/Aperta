import Ember from "ember";
import TaskController from "tahi/pods/task/controller";

export default TaskController.extend({
  ringgold: [
    { id: 1, text: "Memorial University of Newfoundland" },
    { id: 2, text: "Ryerson University" },
    { id: 3, text: "Simon Fraser University" },
    { id: 4, text: "University of Manitoba" },
    { id: 5, text: "Faculty of Humanities and Social Sciences Library" },
    { id: 6, text: "Odense University Hospital" },
    { id: 7, text: "University of Southern Denmark" },
    { id: 8, text: "Bielefeld University" },
    { id: 9, text: "Helmholtz Association of German Research Centres" },
    { id: 10, text: "Max Planck Institutes" },
    { id: 11, text: "Ruhr University Bochum" },
    { id: 12, text: "Technische Universität München" },
    { id: 13, text: "University of Regensburg" },
    { id: 14, text: "University of Stuttgart" },
    { id: 15, text: "Fondazione Telethon" },
    { id: 16, text: "Institute for Health & Behavior" },
    { id: 17, text: "CINVESTAV Unidad Irapuato" },
    { id: 18, text: "Delft University of Technology" },
    { id: 19, text: "Temasek Life Sciences Laboratory" },
    { id: 20, text: "Lund University" },
    { id: 21, text: "ETH Zurich" },
    { id: 22, text: "Brunel University" },
    { id: 23, text: "John Innes Centre" },
    { id: 24, text: "London School of Hygiene & Tropical Medicine" },
    { id: 25, text: "Newcastle University" },
    { id: 26, text: "Queen’s University Belfast" },
    { id: 27, text: "University College London (UCL)" },
    { id: 28, text: "University of Birmingham" },
    { id: 29, text: "University of Glasgow" },
    { id: 30, text: "University of Leeds" },
    { id: 31, text: "University of St. Andrews " },
    { id: 32, text: "University of Stirling" },
    { id: 33, text: "George Mason University" }
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
  inviteCode: "",
  endingComments: "",
  pubFee: 123.00,
  journalName: "PLOS One",
  feeMessage: (function(){
    return "The fee for publishing in " + this.get("journalName") +
      " is $" + this.get("pubFee")
  }).property("journalName"),
  journals: [
    {
      name: "PLOS Biology",
      price: 2900,
      collectionSurcharge: 1000,
      totalPrice: 3900
    },
    {
      name: "PLOS Medicine",
      price: 2900,
      collectionSurcharge: 1000,
      totalPrice: 3900
    },
    {
      name: "PLOS Computational Biology",
      price: 2250,
      collectionSurcharge: 750,
      totalPrice: 3000
    },
    {
      name: "PLOS Genetics",
      price: 2250,
      collectionSurcharge: 750,
      totalPrice: 3000
    },
    {
      name: "PLOS Neglected Tropical Diseases",
      price: 2250,
      collectionSurcharge: 750,
      totalPrice: 3000
    },
    {
      name: "PLOS Pathogens",
      price: 2250,
      collectionSurcharge: 750,
      totalPrice: 3000
    },
    {
      name: "PLOS ONE",
      price: 1350,
      collectionSurcharge: 500,
      totalPrice: 1850
    },
  ],
  responses: [
    {id: "self_payment", text: "I will pay the full fee upon article acceptance"},
    {id: "institutional", text: "Institutional Account Program"},
    {id: "gpi", text: "PLOS Global Participation Initiative (GPI)"},
    {id: "pfa", text: "PLOS Publication Fee Assistance Program (PFA)"},
    {id: "special_collection", text: "I have been invited to submit to a Special Collection"}
  ],
  selectedRinggold: null,
  selectedPaymentMethod: null,
  selfPayment: function() {
    return this.get("selectedPaymentMethod") === "self_payment";
  }.property("selectedPaymentMethod"),
  institutional: function() {
    return this.get("selectedPaymentMethod") === "institutional";
  }.property("selectedPaymentMethod"),
  gpi: function() {
    return this.get("selectedPaymentMethod") === "gpi";
  }.property("selectedPaymentMethod"),
  pfa: function() {
    return this.get("selectedPaymentMethod") === "pfa";
  }.property("selectedPaymentMethod"),
  specialCollection: function() {
    return this.get("selectedPaymentMethod") === "special_collection";
  }.property("selectedPaymentMethod"),
  agreeCollections: false,
  actions: {
    paymentMethodSelected: function (selection) {
      this.set("selectedPaymentMethod", selection.id);
    }
  }
});
