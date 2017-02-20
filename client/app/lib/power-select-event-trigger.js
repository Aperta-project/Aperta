const createEvent = function(name) {
  return new window.Event(name, { bubbles: true, cancelable: true, view: window });
};

export function mousedown(selector) {
  const element = $(selector);
  if(!element.length) { return; }

  element[0].dispatchEvent(createEvent('mousedown'));
}

export function mouseup(selector) {
  const element = $(selector);
  if(!element.length) { return; }

  element[0].dispatchEvent(createEvent('mouseup'));
}
