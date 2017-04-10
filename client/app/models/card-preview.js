import DS from 'ember-data';
import Answerable from 'tahi/mixins/answerable';


/**
 * The card-preview model only exists as an owner for ephemeral
 * answers that are used in the card-content preview.
 */
export default DS.Model.extend(Answerable);
