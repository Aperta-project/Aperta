// Every kind of card-content has a type and a view component. Mos tof
// the time, they share a name. In case they don't, add the exceptions
// here.

const CONTENT_TYPES = {
  'conditional-children': 'card-content/display-children'
};

export default {
  forType(type) {
    const substitution = CONTENT_TYPES[type];
    if (substitution) return substitution;
    return `card-content/${type}`;
  }
};
