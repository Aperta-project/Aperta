/*!
 * VisualEditor UserInterface MediaSizeWidget class.
 *
 * @copyright 2011-2014 VisualEditor Team and others; see AUTHORS.txt
 * @license The MIT License (MIT); see LICENSE.txt
 */

/**
 * Widget that lets the user edit dimensions (width and height),
 * optionally with a fixed aspect ratio.
 *
 * The widget is designed to work in one of two ways:
 * 1. Instantiated with size configuration already set up
 * 2. Instantiated empty, and size details added when the
 *    data is available.
 *
 * @class
 * @extends OO.ui.Widget
 * @mixins ve.Scalable
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
ve.ui.MediaSizeWidget = function VeUiMediaSizeWidget( config ) {
	var heightLabel, widthLabel;

	// Configuration
	config = config || {};

	this.showOriginalDimensionsButton = !!config.showOriginalDimensionsButton;
	// Parent constructor
	OO.ui.Widget.call( this, config );

	// Mixin constructors
	ve.Scalable.call( this, config );

	// Define dimension input widgets
	this.widthInput = new OO.ui.TextInputWidget( {
		'$': this.$
	} );
	this.heightInput = new OO.ui.TextInputWidget( {
		'$': this.$
	} );

	// Define dimension labels
	widthLabel = new OO.ui.LabelWidget( {
		'$': this.$,
		'input': this.widthInput,
		'label': ve.msg( 'visualeditor-mediasizewidget-label-width' )
	} );
	heightLabel = new OO.ui.LabelWidget( {
		'$': this.$,
		'input': this.heightInput,
		'label': ve.msg( 'visualeditor-mediasizewidget-label-height' )
	} );
	// Error label
	this.errorLabel = new OO.ui.LabelWidget( {
		'$': this.$,
		'label': ve.msg( 'visualeditor-mediasizewidget-label-defaulterror' )
	} );

	// Define buttons
	this.originalDimensionsButton = new OO.ui.ButtonWidget( {
		'$': this.$,
		'label': ve.msg( 'visualeditor-mediasizewidget-button-originaldimensions' )
	} );

	// Build the GUI
	this.$element.append( [
		this.$( '<div>' )
			.addClass( 've-ui-mediaSizeWidget-section-width' )
			.append( [
				widthLabel.$element,
				this.widthInput.$element
			] ),
		this.$( '<div>' )
			.addClass( 've-ui-mediaSizeWidget-section-height' )
			.append( [
				heightLabel.$element,
				this.heightInput.$element
			] )
	] );
	// Optionally append the original size button
	if ( this.showOriginalDimensionsButton ) {
		this.$element.append(
			this.$( '<div>' )
				.addClass( 've-ui-mediaSizeWidget-button-originalSize' )
				.append( this.originalDimensionsButton.$element )
		);
		this.originalDimensionsButton.setDisabled( true );
		// Events
		this.originalDimensionsButton.connect( this, { 'click': 'onButtonOriginalDimensionsClick' } );
	}

	// Append error message
	this.$element.append(
		this.$( '<div>' )
			.addClass( 've-ui-mediaSizeWidget-label-error' )
			.append( this.errorLabel.$element )
	);

	this.widthInput.connect( this, { 'change': 'onWidthChange' } );
	this.heightInput.connect( this, { 'change': 'onHeightChange' } );

	// Initialization
	this.$element.addClass( 've-ui-mediaSizeWidget' );
	if ( config.originalDimensions ) {
		this.setOriginalDimensions( config.originalDimensions );
	}
	if ( config.maxDimensions ) {
		this.setMaxDimensions( config.maxDimensions );
	}
};

/* Inheritance */

OO.inheritClass( ve.ui.MediaSizeWidget, OO.ui.Widget );

OO.mixinClass( ve.ui.MediaSizeWidget, ve.Scalable );

/* Events */

/**
 * @event change
 */

/* Methods */

/**
 * Set placeholder dimensions in case the widget is empty or set to 0 values
 * @param {Object} dimensions Height and width placeholders
 */
ve.ui.MediaSizeWidget.prototype.setPlaceholderDimensions = function ( dimensions ) {
	dimensions = dimensions || {};

	if ( !dimensions.height && this.getRatio() !== null && $.isNumeric( dimensions.width ) ) {
		dimensions.height = Math.round( dimensions.width / this.getRatio() );
	}
	if ( !dimensions.width && this.getRatio() !== null && $.isNumeric( dimensions.height ) ) {
		dimensions.width = Math.round( dimensions.height * this.getRatio() );
	}

	this.placeholders = dimensions;

	// Set the inputs' placeholders
	this.widthInput.$input.attr( 'placeholder', this.placeholders.width );
	this.heightInput.$input.attr( 'placeholder', this.placeholders.height );
};

/**
 * Return the values of the placeholder dimensions.
 * @returns {Object} The width and height of the placeholder values
 */
ve.ui.MediaSizeWidget.prototype.getPlaceholderDimensions = function () {
	return this.placeholders;
};

/**
 * Check if both inputs are empty, so to use their placeholders
 * @returns {boolean}
 */
ve.ui.MediaSizeWidget.prototype.isEmpty = function () {
	return ( this.widthInput.getValue() === '' && this.heightInput.getValue() === '' );
};

/**
 * Overridden from ve.Scalable to allow one dimension to be set
 * at a time, write values back to inputs and show any errors.
 *
 * @fires change
 */
ve.ui.MediaSizeWidget.prototype.setCurrentDimensions = function ( dimensions ) {
	// Recursion protection
	if ( this.preventChangeRecursion ) {
		return;
	}

	this.preventChangeRecursion = true;

	if ( !dimensions.height && this.getRatio() !== null && $.isNumeric( dimensions.width ) ) {
		dimensions.height = Math.round( dimensions.width / this.getRatio() );
	}
	if ( !dimensions.width && this.getRatio() !== null && $.isNumeric( dimensions.height ) ) {
		dimensions.width = Math.round( dimensions.height * this.getRatio() );
	}

	ve.Scalable.prototype.setCurrentDimensions.call( this, dimensions );

	if (
		// If placeholders are set and dimensions are 0x0, erase input values
		// so placeholders are visible
		this.getPlaceholderDimensions() &&
		( dimensions.height === 0 || dimensions.width === 0 )
	) {
		// Use placeholders
		this.widthInput.setValue( '' );
		this.heightInput.setValue( '' );
	} else {
		// This will only update if the value has changed
		this.widthInput.setValue( this.getCurrentDimensions().width );
		this.heightInput.setValue( this.getCurrentDimensions().height );
	}

	this.validateDimensions();

	// Emit change event
	this.emit( 'change' );
	this.preventChangeRecursion = false;
};

/**
 * Validate current dimensions.
 * Explicitly call for validating the current dimensions. This is especially
 * useful if we've changed conditions for the widget, like limiting image
 * dimensions for thumbnails when the image type changes. Triggers the error
 * class if needed.
 *
 * @returns {boolean} Current dimensions are valid
 */
ve.ui.MediaSizeWidget.prototype.validateDimensions = function () {
	var isValid = this.isCurrentDimensionsValid();
	this.errorLabel.$element.toggle( !isValid );
	this.$element.toggleClass( 've-ui-mediaSizeWidget-input-hasError', !isValid );

	return isValid;
};

/** */
ve.ui.MediaSizeWidget.prototype.setOriginalDimensions = function ( dimensions ) {
	// Parent method
	ve.Scalable.prototype.setOriginalDimensions.call( this, dimensions );

	// Enable the 'original dimensions' button
	if ( this.showOriginalDimensionsButton ) {
		this.originalDimensionsButton.setDisabled( false );
	}
};

/**
 * Respond to a change in the width input.
 */
ve.ui.MediaSizeWidget.prototype.onWidthChange = function () {
	var val = this.widthInput.getValue();
	this.setCurrentDimensions( { 'width': $.isNumeric( val ) ? Number( val ) : val } );
};

/**
 * Respond to a change in the height input.
 */
ve.ui.MediaSizeWidget.prototype.onHeightChange = function () {
	var val = this.heightInput.getValue();
	this.setCurrentDimensions( { 'height': $.isNumeric( val ) ? Number( val ) : val } );
};

/**
 * Set the width/height values to the original media dimensions
 *
 * @param {jQuery.Event} e Click event
 */
ve.ui.MediaSizeWidget.prototype.onButtonOriginalDimensionsClick = function () {
	this.setCurrentDimensions( this.getOriginalDimensions() );
};

/**
 * Expand on Scalable's method of checking for valid dimensions. Allow for
 * empty dimensions if the placeholders are set.
 * @returns {boolean}
 */
ve.ui.MediaSizeWidget.prototype.isCurrentDimensionsValid = function () {
	if (
		this.placeholders &&
		this.heightInput.getValue() === '' &&
		this.widthInput.getValue() === ''
	) {
		return true;
	} else {
		// Parent method
		return ve.Scalable.prototype.isCurrentDimensionsValid.call( this );
	}
};
