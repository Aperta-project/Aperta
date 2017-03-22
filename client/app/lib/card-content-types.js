// Every kind of card-content has a type and a view component. Mos tof
// the time, they share a name. In case they don't, add the exceptions
// here.

const CONTENT_TYPES = [
//  {
//    contentType: 'conditional-children',
//    component: 'card-content/display-children'
//  }
];

export default {
  forType(type) {
    const substitution = _.find(CONTENT_TYPES, t => t.contentType === type);
    if (substitution) return substitution;
    return {component: `card-content/${type}`};
  }
};
