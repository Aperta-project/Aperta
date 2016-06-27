export default function() {
  const discussionsOptions = { duration: 600, easing: [300, 25] };
  const discussionsNew = function(routeName) {
    return (/paper\.[^.]*\.discussions\.new/).test(routeName);
  };
  const discussionsShow = function(routeName) {
    return (/paper\.[^.]*\.discussions\.show/).test(routeName);
  };
  const discussionsIndex = function(routeName) {
    return (/paper\.[^.]*\.discussions\.index/).test(routeName);
  };

  this.transition(
    this.fromRoute(discussionsIndex),
    this.toRoute(discussionsShow),
    this.use('slideToLeft', discussionsOptions),
    this.reverse('slideToRight', discussionsOptions)
  );

  this.transition(
    this.toRoute(discussionsNew),
    this.use('slideToLeft', discussionsOptions),
    this.reverse('slideToRight', discussionsOptions)
  );

  this.transition(
    this.childOf('#figure-list'),
    this.use('explode', {
      matchBy: 'data-figure-id',
      use: ['fly-to', {duration: 600, easing: 'easeOutCubic'}]
    })
  );
}
