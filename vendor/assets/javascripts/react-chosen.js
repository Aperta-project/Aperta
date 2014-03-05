var Chosen = React.createClass({
  displayName: 'Chosen',
  componentDidUpdate: function() {
    // chosen doesn't refresh the options by itself, babysit it
    $(this.getDOMNode()).trigger('chosen:updated');
  },
  componentDidMount: function() {
    // this.getDOMNode() now returns the root node in 0.9
    $(this.getDOMNode())
      .chosen({
        disable_search_threshold: this.props.disableSearchThreshold,
        no_results_text: this.props.noResultsText,
        max_selected_options: this.props.maxSelectedOptions,
        allow_single_deselect: this.props.allowSingleDeselect,
        width: this.props.width
      })
      .on('chosen:maxselected', this.props.onMaxSelected)
      .change(this.props.onChange);
  },
  componentWillUnmount: function() {
    $(this.getDOMNode()).off('chosen:maxselected change');
  },
  render: function() {
    return this.transferPropsTo(React.DOM.select(null, this.props.children));
  }
});
