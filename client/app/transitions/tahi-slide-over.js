import { stop, animate, Promise, isAnimating, finish } from 'liquid-fire';

export default function moveOver(dimension, direction, opts) {
  let oldParams = {},
      newParams = {},
      firstStep,
      property  = 'translateX';

  if (isAnimating(this.oldElement, 'moving-in')) {
    firstStep = finish(this.oldElement, 'moving-in');
  } else {
    stop(this.oldElement);
    firstStep = Promise.resolve();
  }

  this.newElement.css('opacity', 0);
  this.newElement.addClass('animating');
  this.oldElement.addClass('animating');

  return firstStep.then(() => {
    let bigger = biggestSize(this, 'width');
    oldParams[property]  = (bigger * direction) + 'px';
    newParams[property]  = ['0px', (-1 * bigger * direction) + 'px'];
    newParams['opacity'] = 1;

    return Promise.all([
      animate(this.oldElement, oldParams, opts),
      animate(this.newElement, newParams, opts, 'moving-in')
    ]);
  });
}

function biggestSize(context, dimension) {
  let sizes = [];
  if (context.newElement) {
    sizes.push(parseInt(context.newElement.css(dimension), 10));
    sizes.push(parseInt(context.newElement.parent().css(dimension), 10));
  }
  if (context.oldElement) {
    sizes.push(parseInt(context.oldElement.css(dimension), 10));
    sizes.push(parseInt(context.oldElement.parent().css(dimension), 10));
  }
  return Math.max.apply(null, sizes);
}
