/*!
 * VisualEditor ContentEditable namespace.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Namespace for all VisualEditor ContentEditable classes, static methods and static properties.
 * @class
 * @singleton
 */
ve.ce = {
	// nodeFactory: Initialized in ve.ce.NodeFactory.js
};

/* Static Properties */

/**
 * RegExp pattern for matching all whitespaces in HTML text.
 *
 * \u0020 (32) space
 * \u00A0 (160) non-breaking space
 *
 * @property
 */
ve.ce.whitespacePattern = /[\u0020\u00A0]/g;

/**
 * Data URI for minimal GIF image.
 */
ve.ce.minImgDataUri = 'data:image/gif;base64,R0lGODdhAQABAADcACwAAAAAAQABAAA';
ve.ce.unicornImgDataUri = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAA8AAAATCAQAAADly58hAAAAAmJLR0QAAKqNIzIAAAAJcEhZcwAACxMAAAsTAQCanBgAAAAHdElNRQfeChIMMi319aEqAAAAzUlEQVQoz4XSMUoDURAG4K8NIljaeQZrCwsRb5FWL5Daa1iIjQewTycphAQloBEUAoogFmqMsiBmHSzcdfOWlcyU3/+YGXgsqJZMbvv/wLqZDCw1B9rCBSaOmgOHQsfQvVYT7wszIbPSxO9CCF8ebNXx1J2TIvDoxlrKU3mBIYz1U87mMISB3QqXk7e/A4bp1WV/CiE3sFHymZ4X4cO57yLWdVDyjoknr47/MPRcput1k+ljt/O4V1vu2bXViq9qPNW3WfGoxrk37UVfxQ999n1bP+Vh5gAAAABJRU5ErkJggg==';
ve.ce.chimeraImgDataUri = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABMAAAATCAYAAAByUDbMAAAABGdBTUEAALGPC/xhBQAAAThJREFUOMvF088rRFEYxvGpKdnwJ8iStVnMytZ2ipJmI6xmZKEUe5aUULMzCxtlSkzNjCh2lClFSUpDmYj8KBZq6vreetLbrXs5Rjn1aWbuuee575z7nljsH8YkepoNaccsHrGFgWbCWpHCLZb+oroFzKOEbpeFHVp8gitsYltzSRyiqrkKhsKCevGMfWQwor/2ghns4BQTGMMcnlBA3Aa14U5VLeMDnqrq1/cDpHGv35eqrI5pG+Y/qYYp3WiN6zOHs8DcA7IK/BqLWMOuY5inQjwbNqheGnYMO9d+XtiwFu1BQU/y96ooKRO2Yq6vqog3jAbfZgKvuDELfGWFXQeu76GB9bD26MQRNnSMotTVJvGoxs2rx2oR/B47Rtd3pyBv3lCYnEtYWo0Yps8l7F3HKErjJ2G/Hp/F9YtlR3MQiAAAAABJRU5ErkJggg==';

/* Static Methods */

/**
 * Gets the plain text of a DOM element (that is a node canContainContent === true)
 *
 * In the returned string only the contents of text nodes are included, and the contents of
 * non-editable elements are excluded (but replaced with the appropriate number of snowman
 * characters so the offsets match up with the linear model).
 *
 * @method
 * @param {HTMLElement} element DOM element to get text of
 * @returns {string} Plain text of DOM element
 */
ve.ce.getDomText = function ( element ) {
	// Inspired by jQuery.text / Sizzle.getText
	var func = function ( element ) {
		var viewNode,
			nodeType = element.nodeType,
			$element = $( element ),
			text = '';

		if (
			nodeType === Node.ELEMENT_NODE ||
			nodeType === Node.DOCUMENT_NODE ||
			nodeType === Node.DOCUMENT_FRAGMENT_NODE
		) {
			if ( $element.hasClass( 've-ce-branchNode-blockSlug' ) ) {
				// Block slugs are not represented in the model at all, but they do
				// contain a single nbsp/FEFF character in the DOM, so make sure
				// that character isn't counted
				return '';
			} else if ( $element.hasClass( 've-ce-leafNode' ) ) {
				// For leaf nodes, don't return the content, but return
				// the right number of placeholder characters so the offsets match up.
				viewNode = $element.data( 'view' );
				// Only return snowmen for the first element in a sibling group: otherwise
				// we'll double-count this node
				if ( viewNode && element === viewNode.$element[0] ) {
					// \u2603 is the snowman character: ☃
					return new Array( viewNode.getOuterLength() + 1 ).join( '\u2603' );
				}
				// Second or subsequent sibling, don't double-count
				return '';
			} else {
				// Traverse its children
				for ( element = element.firstChild; element; element = element.nextSibling ) {
					text += func( element );
				}
			}
		} else if ( nodeType === Node.TEXT_NODE ) {
			return element.data;
		}
		return text;
	};
	// Return the text, replacing spaces and non-breaking spaces with spaces?
	// TODO: Why are we replacing spaces (\u0020) with spaces (' ')
	return func( element ).replace( ve.ce.whitespacePattern, ' ' );
};

/**
 * Gets a hash of a DOM element's structure.
 *
 * In the returned string text nodes are represented as "#" and elements are represented as "<type>"
 * and "</type>" where "type" is their element name. This effectively generates an HTML
 * serialization without any attributes or text contents. This can be used to observe structural
 * changes.
 *
 * @method
 * @param {HTMLElement} element DOM element to get hash of
 * @returns {string} Hash of DOM element
 */
ve.ce.getDomHash = function ( element ) {
	var nodeType = element.nodeType,
		nodeName = element.nodeName,
		hash = '';

	if ( nodeType === Node.TEXT_NODE || nodeType === Node.CDATA_SECTION_NODE ) {
		return '#';
	} else if ( nodeType === Node.ELEMENT_NODE || nodeType === Node.DOCUMENT_NODE ) {
		hash += '<' + nodeName + '>';
		if ( !$( element ).hasClass( 've-ce-branchNode-blockSlug' ) ) {
			// Traverse its children
			for ( element = element.firstChild; element; element = element.nextSibling ) {
				hash += ve.ce.getDomHash( element );
			}
		}
		hash += '</' + nodeName + '>';
		// Merge adjacent text node representations
		hash = hash.replace( /##+/g, '#' );
	}
	return hash;
};

/**
 * Get the first cursor offset immediately after a node.
 *
 * @param {Node} node DOM node
 * @returns {Object}
 * @returns {Node} return.node
 * @returns {number} return.offset
 */
ve.ce.nextCursorOffset = function ( node ) {
	var nextNode, offset;
	if ( node.nextSibling !== null && node.nextSibling.nodeType === Node.TEXT_NODE ) {
		nextNode = node.nextSibling;
		offset = 0;
	} else {
		nextNode = node.parentNode;
		offset = 1 + Array.prototype.indexOf.call( node.parentNode.childNodes, node );
	}
	return { node: nextNode, offset: offset };
};

/**
 * Get the first cursor offset immediately before a node.
 *
 * @param {Node} node DOM node
 * @returns {Object}
 * @returns {Node} return.node
 * @returns {number} return.offset
 */
ve.ce.previousCursorOffset = function ( node ) {
	var previousNode, offset;
	if ( node.previousSibling !== null && node.previousSibling.nodeType === Node.TEXT_NODE ) {
		previousNode = node.previousSibling;
		offset = previousNode.data.length;
	} else {
		previousNode = node.parentNode;
		offset = Array.prototype.indexOf.call( node.parentNode.childNodes, node );
	}
	return { node: previousNode, offset: offset };
};

/**
 * Gets the linear offset from a given DOM node and offset within it.
 *
 * @method
 * @param {HTMLElement} domNode DOM node
 * @param {number} domOffset DOM offset within the DOM node
 * @returns {number} Linear model offset
 * @throws {Error} domOffset is out of bounds
 * @throws {Error} domNode has no ancestor with a .data( 'view' )
 * @throws {Error} domNode is not in document
 */
ve.ce.getOffset = function ( domNode, domOffset ) {
	var node, view, offset, startNode, maxOffset, lengthSum = 0,
		$domNode = $( domNode );

	if ( $domNode.hasClass( 've-ce-unicorn' ) ) {
		if ( domOffset !== 0 ) {
			throw new Error( 'Non-zero offset in unicorn' );
		}
		return $domNode.data( 'dmOffset' );
	}

	/**
	 * Move to the previous "traversal node" in "traversal sequence".
	 *
	 * - A node is a "traversal node" if it is either a leaf node or a "view node"
	 * - A "view node" is one that has $( n ).data( 'view' ) instanceof ve.ce.Node
	 * - "Traversal sequence" is defined on every node (not just traversal nodes).
	 *   It is like document order, except that each parent node appears
	 *   in the sequence both immediately before and immediately after its child nodes.
	 *
	 * Important properties:
	 * - Non-traversal nodes don't have any width in DM (e.g. bold).
	 * - Certain traversal nodes also have no width (namely, those within an alienated node).
	 * - Both the start and end of a (non-alienated) parent traversal node has width
	 *   (which is one reason why traversal sequence is important).
	 * - In VE-normalized HTML, a text node cannot be a sibling of a non-leaf view node
	 *   (because all non-alienated text nodes are inside a ContentBranchNode).
	 * - Traversal-consecutive non-view nodes are either all alienated or all not alienated.
	 *
	 * @param {Node} n Node to traverse from
	 * @returns {Node} Previous traversal node from n
	 * @throws {Error} domNode has no ancestor with a .data( 'view' )
	 */
	function traverse( n ) {
		while ( !n.previousSibling ) {
			n = n.parentNode;
			if ( !n ) {
				throw new Error( 'domNode has no ancestor with a .data( \'view\' )' );
			}
			if ( $( n ).data( 'view' ) instanceof ve.ce.Node ) {
				return n;
			}
		}
		n = n.previousSibling;
		if ( $( n ).data( 'view' ) instanceof ve.ce.Node ) {
			return n;
		}
		while ( n.lastChild ) {
			n = n.lastChild;
			if ( $( n ).data( 'view' ) instanceof ve.ce.Node ) {
				return n;
			}
		}
		return n;
	}

	// Validate domOffset
	if ( domNode.nodeType === Node.ELEMENT_NODE ) {
		maxOffset = domNode.childNodes.length;
	} else {
		maxOffset = domNode.data.length;
	}
	if ( domOffset < 0 || domOffset > maxOffset) {
		throw new Error( 'domOffset is out of bounds' );
	}

	// Figure out what node to start traversing at (startNode)
	if ( domNode.nodeType === Node.ELEMENT_NODE ) {
		if ( domNode.childNodes.length === 0 ) {
			// domNode has no children, and the offset is inside of it
			// If domNode is a view node, return the offset inside of it
			// Otherwise, start traversing at domNode
			startNode = domNode;
			view = $( startNode ).data( 'view' );
			if ( view instanceof ve.ce.Node ) {
				return view.getOffset() + ( view.isWrapped() ? 1 : 0 );
			}
			node = startNode;
		} else if ( domOffset === domNode.childNodes.length ) {
			// Offset is at the end of domNode, after the last child. Set startNode to the
			// very rightmost descendant node of domNode (i.e. the last child of the last child
			// of the last child, etc.)
			// However, if the last child or any of the last children we encounter on the way
			// is a view node, return the offset after it. This will be the correct return value
			// because non-traversal nodes don't have a DM width.
			startNode = domNode.lastChild;

			view = $( startNode ).data( 'view' );
			if ( view instanceof ve.ce.Node ) {
				return view.getOffset() + view.getOuterLength();
			}
			while ( startNode.lastChild ) {
				startNode = startNode.lastChild;
				view = $( startNode ).data( 'view' );
				if ( view instanceof ve.ce.Node ) {
					return view.getOffset() + view.getOuterLength();
				}
			}
			node = startNode;
		} else {
			// Offset is right before childNodes[domOffset]. Set startNode to this node
			// (i.e. the node right after the offset), then traverse back once.
			startNode = domNode.childNodes[domOffset];
			node = traverse( startNode );
		}
	} else {
		// Text inside of a block slug doesn't count
		if ( !$( domNode.parentNode ).hasClass( 've-ce-branchNode-blockSlug' ) ) {
			lengthSum += domOffset;
		}
		startNode = domNode;
		node = traverse( startNode );
	}

	// Walk the traversal nodes in reverse traversal sequence, until we find a view node.
	// Add the width of each text node we meet. (Non-text node non-view nodes can only be widthless).
	// Later, if it transpires that we're inside an alienated node, then we will throw away all the
	// text node lengths, because the alien's content has no DM width.
	while ( true ) {
		// First node that has a ve.ce.Node, stop
		// Note that annotations have a .data( 'view' ) too, but that's a ve.ce.Annotation,
		// not a ve.ce.Node
		view = $( node ).data( 'view' );
		if ( view instanceof ve.ce.Node ) {
			break;
		}

		// Text inside of a block slug doesn't count
		if ( node.nodeType === Node.TEXT_NODE && !$( node.parentNode ).hasClass( 've-ce-branchNode-blockSlug' ) ) {
			lengthSum += node.data.length;
		}
		// else: non-text nodes that don't have a .data( 'view' ) don't exist in the DM
		node = traverse( node );
	}

	offset = view.getOffset();

	if ( $.contains( node, startNode ) ) {
		// node is an ancestor of startNode
		if ( !view.getModel().isContent() ) {
			// Add 1 to take the opening into account
			offset += view.getModel().isWrapped() ? 1 : 0;
		}
		if ( view.getModel().canContainContent() ) {
			offset += lengthSum;
		}
		// else: we're inside an alienated node: throw away all the text node lengths,
		// because the alien's content has no DM width
	} else if ( view.parent ) {
		// node is not an ancestor of startNode
		// startNode comes after node, so add node's length
		offset += view.getOuterLength();
		if ( view.isContent() ) {
			// view is a leaf node inside of a CBN, so we started inside of a CBN
			// (otherwise we would have hit the CBN when entering it), so the text we summed up
			// needs to be counted.
			offset += lengthSum;
		}
	} else {
		throw new Error( 'Node is not in document' );
	}

	return offset;
};

/**
 * Gets the linear offset of a given slug
 *
 * @method
 * @param {HTMLElement} element Slug DOM element
 * @returns {number} Linear model offset
 * @throws {Error}
 */
ve.ce.getOffsetOfSlug = function ( element ) {
	var model, $element = $( element );
	if ( $element.index() === 0 ) {
		model = $element.parent().data( 'view' ).getModel();
		return model.getOffset() + ( model.isWrapped() ? 1 : 0 );
	} else if ( $element.prev().length ) {
		model = $element.prev().data( 'view' ).getModel();
		return model.getOffset() + model.getOuterLength();
	} else {
		throw new Error( 'Incorrect slug location' );
	}
};

/**
 * Check if keyboard shortcut modifier key is pressed.
 *
 * @method
 * @param {jQuery.Event} e Key press event
 * @returns {boolean} Modifier key is pressed
 */
ve.ce.isShortcutKey = function ( e ) {
	return !!( e.ctrlKey || e.metaKey );
};

/**
 * Find the DM range of a DOM selection
 *
 * @param {Object} selection DOM-selection-like object
 * @param {Node} selection.anchorNode
 * @param {number} selection.anchorOffset
 * @param {Node} selection.focusNode
 * @param {number} selection.focusOffset
 * @returns {ve.Range|null} DM range, or null if nothing in the CE document is selected
 */
ve.ce.veRangeFromSelection = function ( selection ) {
	try {
		return new ve.Range(
			ve.ce.getOffset( selection.anchorNode, selection.anchorOffset ),
			ve.ce.getOffset( selection.focusNode, selection.focusOffset )
		);
	} catch ( e ) {
		return null;
	}
};

/*!
 * VisualEditor Content Editable Range State class
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable range state (a snapshot of CE selection/content state)
 *
 * @class
 *
 * @constructor
 * @param {ve.ce.RangeState|null} old Previous range state
 * @param {ve.ce.DocumentNode} documentNode Document node
 * @param {boolean} selectionOnly The caller promises the content has not changed from old
 */
ve.ce.RangeState = function VeCeRangeState( old, documentNode, selectionOnly ) {
	/**
	 * @property {boolean} branchNodeChanged Whether the CE branch node changed
	 */
	this.branchNodeChanged = false;

	/**
	 * @property {boolean} selectionChanged Whether the DOM range changed
	 */
	this.selectionChanged = false;

	/**
	 * @property {boolean} contentChanged Whether the content changed
	 */
	this.contentChanged = false;

	/**
	 * @property {ve.Range|null} veRange The current selection range
	 */
	this.veRange = null;

	/**
	 * @property {ve.ce.BranchNode|null} node The current branch node
	 */
	this.node = null;

	/**
	 * @property {string|null} text Plain text of current branch node
	 */
	this.text = null;

	/**
	 * @property {string|null} DOM Hash of current branch node
	 */
	this.hash = null;

	this.saveState( old, documentNode, selectionOnly );
};

/* Inheritance */

OO.initClass( ve.ce.RangeState );

/* Static methods */

/**
 * Create a plain selection object equivalent to no selection
 *
 * @return {Object} Plain selection object
 */
ve.ce.RangeState.static.createNullSelection = function () {
	return {
		focusNode: null,
		focusOffset: 0,
		anchorNode: null,
		anchorOffset: 0
	};
};

/**
 * Compare two plain selection objects, checking that all values are equal
 * and all nodes are reference-equal.
 *
 * @param {Object} a First plain selection object
 * @param {Object} b First plain selection object
 * @return {boolean} Selections are identical
 */
ve.ce.RangeState.static.compareSelections = function ( a, b ) {
	return a.focusNode === b.focusNode &&
		a.focusOffset === b.focusOffset &&
		a.anchorNode === b.anchorNode &&
		a.anchorOffset === b.anchorOffset;
};

/* Methods */

/**
 * Saves a snapshot of the current range state
 * @method
 * @param {ve.ce.RangeState|null} old Previous range state
 * @param {ve.ce.DocumentNode} documentNode Document node
 * @param {boolean} selectionOnly The caller promises the content has not changed from old
 */
ve.ce.RangeState.prototype.saveState = function ( old, documentNode, selectionOnly ) {
	var $node, selection, anchorNodeChanged,
		oldSelection = old ? old.misleadingSelection : this.constructor.static.createNullSelection(),
		nativeSelection = documentNode.getElementDocument().getSelection();

	if (
		nativeSelection.rangeCount &&
		OO.ui.contains( documentNode.$element[0], nativeSelection.anchorNode, true )
	) {
		// Freeze selection out of live object.
		selection = {
			focusNode: nativeSelection.focusNode,
			focusOffset: nativeSelection.focusOffset,
			anchorNode: nativeSelection.anchorNode,
			anchorOffset: nativeSelection.anchorOffset
		};
	} else {
		// Use a blank selection if the selection is outside the document
		selection = this.constructor.static.createNullSelection();
	}

	// Get new range information
	if ( this.constructor.static.compareSelections( oldSelection, selection ) ) {
		// No change; use old values for speed
		this.selectionChanged = false;
		this.veRange = old && old.veRange;
	} else {
		this.selectionChanged = true;
		this.veRange = ve.ce.veRangeFromSelection( selection );
	}

	anchorNodeChanged = oldSelection.anchorNode !== selection.anchorNode;

	if ( !anchorNodeChanged ) {
		this.node = old && old.node;
	} else {
		$node = $( selection.anchorNode ).closest( '.ve-ce-branchNode' );
		if ( $node.length === 0 ) {
			this.node = null;
		} else {
			this.node = $node.data( 'view' );
			// Check this node belongs to our document
			if ( this.node && this.node.root !== documentNode ) {
				this.node = null;
				this.veRange = null;
			}
		}
	}

	this.branchNodeChanged = ( old && old.node ) !== this.node;

	// Compute text/hash, for change comparison
	if ( selectionOnly && !anchorNodeChanged ) {
		this.text = old.text;
		this.hash = old.hash;
	} else if ( !this.node ) {
		this.text = null;
		this.hash = null;
	} else {
		this.text = ve.ce.getDomText( this.node.$element[0] );
		this.hash = ve.ce.getDomHash( this.node.$element[0] );
	}

	// Only set contentChanged if we're still in the same branch node
	this.contentChanged =
		!selectionOnly &&
		!this.branchNodeChanged && (
			( old && old.hash ) !== this.hash ||
			( old && old.text ) !== this.text
		);

	// Save selection for future comparisons. (But it is not properly frozen, because the nodes
	// are live and mutable, and therefore the offsets may come to point to places that are
	// misleadingly different from when the selection was saved).
	this.misleadingSelection = selection;
};

/*!
 * VisualEditor ContentEditable AnnotationFactory class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable annotation factory.
 *
 * @class
 * @extends OO.Factory
 * @constructor
 */
ve.ce.AnnotationFactory = function VeCeAnnotationFactory() {
	// Parent constructor
	OO.Factory.call( this );
};

/* Inheritance */

OO.inheritClass( ve.ce.AnnotationFactory, OO.Factory );

/* Methods */

/**
 * Get a plain text description of an annotation model.
 *
 * @param {ve.dm.Annotation} annotation Annotation to describe
 * @returns {string} Description of the annotation
 * @throws {Error} Unknown annotation type
 */
ve.ce.AnnotationFactory.prototype.getDescription = function ( annotation ) {
	var type = annotation.constructor.static.name;
	if ( Object.prototype.hasOwnProperty.call( this.registry, type ) ) {
		return this.registry[type].static.getDescription( annotation );
	}
	throw new Error( 'Unknown annotation type: ' + type );
};

/**
 * Check if an annotation needs to force continuation
 * @param {string} type Annotation type
 * @returns {boolean} Whether the annotation needs to force continuation
 */
ve.ce.AnnotationFactory.prototype.isAnnotationContinuationForced = function ( type ) {
	if ( Object.prototype.hasOwnProperty.call( this.registry, type ) ) {
		return this.registry[type].static.forceContinuation;
	}
	return false;
};

/* Initialization */

// TODO: Move instantiation to a different file
ve.ce.annotationFactory = new ve.ce.AnnotationFactory();

/*!
 * VisualEditor ContentEditable NodeFactory class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable node factory.
 *
 * @class
 * @extends OO.Factory
 * @constructor
 */
ve.ce.NodeFactory = function VeCeNodeFactory() {
	// Parent constructor
	OO.Factory.call( this );
};

/* Inheritance */

OO.inheritClass( ve.ce.NodeFactory, OO.Factory );

/* Methods */

/**
 * Get a plain text description of a node model.
 *
 * @param {ve.dm.Node} node Node to describe
 * @returns {string} Description of the node
 * @throws {Error} Unknown node type
 */
ve.ce.NodeFactory.prototype.getDescription = function ( node ) {
	var type = node.constructor.static.name;
	if ( Object.prototype.hasOwnProperty.call( this.registry, type ) ) {
		return this.registry[type].static.getDescription( node );
	}
	throw new Error( 'Unknown node type: ' + type );
};

/**
 * Check if a node type splits on Enter
 *
 * @param {string} type Node type
 * @returns {boolean} The node can have grandchildren
 * @throws {Error} Unknown node type
 */
ve.ce.NodeFactory.prototype.splitNodeOnEnter = function ( type ) {
	if ( Object.prototype.hasOwnProperty.call( this.registry, type ) ) {
		return this.registry[type].static.splitOnEnter;
	}
	throw new Error( 'Unknown node type: ' + type );
};

/**
 * Get primary command for node type.
 *
 * @method
 * @param {string} type Node type
 * @returns {string|null} Primary command name
 * @throws {Error} Unknown node type
 */
ve.ce.NodeFactory.prototype.getNodePrimaryCommandName = function ( type ) {
	if ( Object.prototype.hasOwnProperty.call( this.registry, type ) ) {
		return this.registry[type].static.primaryCommandName;
	}
	throw new Error( 'Unknown node type: ' + type );
};

/* Initialization */

// TODO: Move instantiation to a different file
ve.ce.nodeFactory = new ve.ce.NodeFactory();

/*!
 * VisualEditor ContentEditable Document class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable document.
 *
 * @class
 * @extends ve.Document
 *
 * @constructor
 * @param {ve.dm.Document} model Model to observe
 * @param {ve.ce.Surface} surface Surface document is part of
 */
ve.ce.Document = function VeCeDocument( model, surface ) {
	// Parent constructor
	ve.Document.call( this, new ve.ce.DocumentNode(
		model.getDocumentNode(), surface, { $: surface.$ }
	) );

	this.getDocumentNode().$element.prop( {
		lang: model.getLang(),
		dir: model.getDir()
	} );

	// Properties
	this.model = model;
};

/* Inheritance */

OO.inheritClass( ve.ce.Document, ve.Document );

/* Methods */

/**
 * Get a slug at an offset.
 *
 * @method
 * @param {number} offset Offset to get slug at
 * @returns {HTMLElement} Slug at offset
 */
ve.ce.Document.prototype.getSlugAtOffset = function ( offset ) {
	var node = this.getBranchNodeFromOffset( offset );
	return node ? node.getSlugAtOffset( offset ) : null;
};

/**
 * Get a DOM node and DOM element offset for a document offset.
 *
 * @method
 * @param {number} offset Linear model offset
 * @returns {Object} Object containing a node and offset property where node is an HTML element and
 * offset is the byte position within the element
 * @throws {Error} Offset could not be translated to a DOM element and offset
 */
ve.ce.Document.prototype.getNodeAndOffset = function ( offset ) {
	var nao, currentNode, nextNode, previousNode;
	function getNext( node ) {
		while ( node.nextSibling === null ) {
			node = node.parentNode;
			if ( node === null ) {
				return null;
			}
		}
		node = node.nextSibling;
		while ( node.firstChild ) {
			node = node.firstChild;
		}
		return node;
	}
	function getPrevious( node ) {
		while ( node.previousSibling === null ) {
			node = node.parentNode;
			if ( node === null ) {
				return null;
			}
		}
		node = node.previousSibling;
		while ( node.lastChild ) {
			node = node.lastChild;
		}
		return node;
	}

	nao = this.getNodeAndOffsetUnadjustedForUnicorn( offset );
	currentNode = nao.node;
	nextNode = getNext( currentNode );
	previousNode = getPrevious( currentNode );

	// Adjust for unicorn if necessary, then return
	if (
		( (
			currentNode.nodeType === Node.TEXT_NODE &&
			nao.offset === currentNode.data.length
		) || (
			currentNode.nodeType === Node.ELEMENT_NODE &&
			currentNode.classList.contains( 've-ce-branchNode-inlineSlug' )
		) ) &&
		nextNode &&
		nextNode.nodeType === Node.ELEMENT_NODE &&
		nextNode.classList.contains( 've-ce-pre-unicorn' )
	) {
		// At text offset or slug just before the pre unicorn; return the point just after it
		return ve.ce.nextCursorOffset( nextNode );
	} else if ( currentNode.nodeType === Node.ELEMENT_NODE &&
		currentNode.childNodes.length > nao.offset &&
		currentNode.childNodes[nao.offset].nodeType === Node.ELEMENT_NODE &&
		currentNode.childNodes[nao.offset].classList.contains( 've-ce-pre-unicorn' )
	) {
		// At element offset just before the pre unicorn; return the point just after it
		return { node: nao.node, offset: nao.offset + 1 };
	} else if (
		( (
			currentNode.nodeType === Node.TEXT_NODE &&
			nao.offset === 0
		) || (
			currentNode.nodeType === Node.ELEMENT_NODE &&
			currentNode.classList.contains( 've-ce-branchNode-inlineSlug' )
		) ) &&
		previousNode &&
		previousNode.nodeType === Node.ELEMENT_NODE &&
		previousNode.classList.contains( 've-ce-post-unicorn' )
	) {
		// At text offset or slug just after the post unicorn; return the point just before it
		return ve.ce.previousCursorOffset( previousNode );
	} else if ( currentNode.nodeType === Node.ELEMENT_NODE &&
		nao.offset > 0 &&
		currentNode.childNodes[nao.offset - 1].nodeType === Node.ELEMENT_NODE &&
		currentNode.childNodes[nao.offset - 1].classList.contains( 've-ce-post-unicorn' )
	) {
		// At element offset just after the post unicorn; return the point just before it
		return { node: nao.node, offset: nao.offset - 1 };
	} else {
		return nao;
	}
};

/**
 * @private
 */
ve.ce.Document.prototype.getNodeAndOffsetUnadjustedForUnicorn = function ( offset ) {
	var node, startOffset, current, stack, item, $item, length, model,
		countedNodes = [],
		slug = this.getSlugAtOffset( offset );
	// Check for a slug that is empty (apart from a chimera)
	if ( slug && ( !slug.firstChild || $( slug.firstChild ).hasClass( 've-ce-chimera' ) ) ) {
		return { node: slug, offset: 0 };
	}
	node = this.getBranchNodeFromOffset( offset );
	startOffset = node.getOffset() + ( ( node.isWrapped() ) ? 1 : 0 );
	current = [node.$element.contents(), 0];
	stack = [current];
	while ( stack.length > 0 ) {
		if ( current[1] >= current[0].length ) {
			stack.pop();
			current = stack[ stack.length - 1 ];
			continue;
		}
		item = current[0][current[1]];
		if ( item.nodeType === Node.TEXT_NODE ) {
			length = item.textContent.length;
			if ( offset >= startOffset && offset <= startOffset + length ) {
				return {
					node: item,
					offset: offset - startOffset
				};
			} else {
				startOffset += length;
			}
		} else if ( item.nodeType === Node.ELEMENT_NODE ) {
			$item = current[0].eq( current[1] );
			if ( $item.hasClass( 've-ce-unicorn' ) ) {
				if ( offset === startOffset ) {
					// Return if empty unicorn pair at the correct offset
					if ( $( $item[0].previousSibling ).hasClass( 've-ce-unicorn' ) ) {
						return {
							node: $item[0].parentNode,
							offset: current[1] - 1
						};
					} else if ( $( $item[0].nextSibling ).hasClass( 've-ce-unicorn' ) ) {
						return {
							node: $item[0].parentNode,
							offset: current[1] + 1
						};
					}
					// Else algorithm will/did descend into unicorned range
				}
				// Else algorithm will skip this unicorn
			} else if ( $item.is( '.ve-ce-branchNode, .ve-ce-leafNode' ) ) {
				model = $item.data( 'view' ).model;
				// DM nodes can render as multiple elements in the view, so check
				// we haven't already counted it.
				if ( countedNodes.indexOf( model ) === -1 ) {
					length = model.getOuterLength();
					countedNodes.push( model );
					if ( offset >= startOffset && offset < startOffset + length ) {
						stack.push( [$item.contents(), 0] );
						current[1]++;
						current = stack[stack.length - 1];
						continue;
					} else {
						startOffset += length;
					}
				}
			} else {
				// Maybe ve-ce-branchNode-slug
				stack.push( [$item.contents(), 0] );
				current[1]++;
				current = stack[stack.length - 1];
				continue;
			}
		}
		current[1]++;
	}
	throw new Error( 'Offset could not be translated to a DOM element and offset: ' + offset );
};

/**
 * Get the directionality of some selection.
 *
 * @method
 * @param {ve.dm.Selection} selection Selection
 * @returns {string|null} 'rtl', 'ltr' or null if unknown
 */
ve.ce.Document.prototype.getDirectionFromSelection = function ( selection ) {
	var effectiveNode, range, selectedNodes;

	if ( selection instanceof ve.dm.LinearSelection ) {
		range = selection.getRange();
	} else if ( selection instanceof ve.dm.TableSelection ) {
		range = selection.tableRange;
	} else {
		return null;
	}

	selectedNodes = this.selectNodes( range, 'covered' );

	if ( selectedNodes.length > 1 ) {
		// Selection of multiple nodes
		// Get the common parent node
		effectiveNode = this.selectNodes( range, 'siblings' )[0].node.getParent();
	} else {
		// selection of a single node
		effectiveNode = selectedNodes[0].node;

		while ( effectiveNode.isContent() ) {
			// This means that we're in a leaf node, like TextNode
			// those don't read the directionality properly, we will
			// have to climb up the parentage chain until we find a
			// wrapping node like paragraph or list item, etc.
			effectiveNode = effectiveNode.parent;
		}
	}

	return effectiveNode.$element.css( 'direction' );
};

/*!
 * VisualEditor ContentEditable View class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Generic base class for CE views.
 *
 * @abstract
 * @extends OO.ui.Element
 * @mixins OO.EventEmitter
 *
 * @constructor
 * @param {ve.dm.Model} model Model to observe
 * @param {Object} [config] Configuration options
 */
ve.ce.View = function VeCeView( model, config ) {
	// Setting this property before calling the parent constructor allows overridden #getTagName
	// methods in view classes to have access to the model when they are called for the first time
	// inside of OO.ui.Element
	this.model = model;

	// Parent constructor
	OO.ui.Element.call( this, config );

	// Mixin constructors
	OO.EventEmitter.call( this );

	// Properties
	this.live = false;

	// Events
	this.connect( this, {
		setup: 'onSetup',
		teardown: 'onTeardown'
	} );

	// Render attributes from original DOM elements
	ve.dm.Converter.renderHtmlAttributeList(
		this.model.getOriginalDomElements(),
		this.$element,
		this.constructor.static.renderHtmlAttributes,
		// computed attributes
		true,
		// deep
		( !(this.model instanceof ve.dm.Node) || ( !this.model.canHaveChildren() || this.model.handlesOwnChildren() ) )
	);
};

/* Inheritance */

OO.inheritClass( ve.ce.View, OO.ui.Element );

OO.mixinClass( ve.ce.View, OO.EventEmitter );

/* Events */

/**
 * @event setup
 */

/**
 * @event teardown
 */

/* Static members */

/**
 * Allowed attributes for DOM elements, in the same format as ve.dm.Model#preserveHtmlAttributes
 *
 * This list includes attributes that are generally safe to include in HTML loaded from a
 * foreign source and displaying it inside the browser. It doesn't include any event attributes,
 * for instance, which would allow arbitrary JavaScript execution. This alone is not enough to
 * make HTML safe to display, but it helps.
 *
 * TODO: Rather than use a single global list, set these on a per-view basis to something that makes
 * sense for that view in particular.
 *
 * @static
 * @property {boolean|string|RegExp|Array|Object}
 * @inheritable
 */
ve.ce.View.static.renderHtmlAttributes = function ( attribute ) {
	var attributes = [
		'abbr', 'about', 'align', 'alt', 'axis', 'bgcolor', 'border', 'cellpadding', 'cellspacing',
		'char', 'charoff', 'cite', 'class', 'clear', 'color', 'colspan', 'datatype', 'datetime',
		'dir', 'face', 'frame', 'headers', 'height', 'href', 'id', 'itemid', 'itemprop', 'itemref',
		'itemscope', 'itemtype', 'lang', 'noshade', 'nowrap', 'property', 'rbspan', 'rel',
		'resource', 'rev', 'rowspan', 'rules', 'scope', 'size', 'span', 'src', 'start', 'style',
		'summary', 'title', 'type', 'typeof', 'valign', 'value', 'width'
	];
	return attributes.indexOf( attribute ) !== -1;
};

/* Methods */

/**
 * Get an HTML document from the model, to use for URL resolution.
 *
 * The default implementation returns null; subclasses should override this if they can provide
 * a resolution document.
 *
 * @see #getResolvedAttribute
 * @returns {HTMLDocument|null} HTML document to use for resolution, or null if not available
 */
ve.ce.View.prototype.getModelHtmlDocument = function () {
	return null;
};

/**
 * Handle setup event.
 *
 * @method
 */
ve.ce.View.prototype.onSetup = function () {
	this.$element.data( 'view', this );
};

/**
 * Handle teardown event.
 *
 * @method
 */
ve.ce.View.prototype.onTeardown = function () {
	this.$element.removeData( 'view' );
};

/**
 * Get the model the view observes.
 *
 * @method
 * @returns {ve.dm.Model} Model the view observes
 */
ve.ce.View.prototype.getModel = function () {
	return this.model;
};

/**
 * Check if the view is attached to the live DOM.
 *
 * @method
 * @returns {boolean} View is attached to the live DOM
 */
ve.ce.View.prototype.isLive = function () {
	return this.live;
};

/**
 * Set live state.
 *
 * @method
 * @param {boolean} live The view has been attached to the live DOM (use false on detach)
 * @fires setup
 * @fires teardown
 */
ve.ce.View.prototype.setLive = function ( live ) {
	this.live = live;
	if ( this.live ) {
		this.emit( 'setup' );
	} else {
		this.emit( 'teardown' );
	}
};

/**
 * Check if the node is inside a contentEditable node
 *
 * @return {boolean} Node is inside a contentEditable node
 */
ve.ce.View.prototype.isInContentEditable = function () {
	var node = this.$element[0].parentNode;
	while ( node && node.contentEditable === 'inherit' ) {
		node = node.parentNode;
	}
	return !!( node && node.contentEditable === 'true' );
};

/**
 * Get a resolved URL from a model attribute.
 *
 * @abstract
 * @method
 * @param {string} key Attribute name whose value is a URL
 * @returns {string} URL resolved according to the document's base
 */
ve.ce.View.prototype.getResolvedAttribute = function ( key ) {
	var plainValue = this.model.getAttribute( key ),
		doc = this.getModelHtmlDocument();
	return doc && typeof plainValue === 'string' ? ve.resolveUrl( plainValue, doc ) : plainValue;
};

/**
 * Release all memory.
 */
ve.ce.View.prototype.destroy = function () {
	this.disconnect( this );
	this.model.disconnect( this );
	this.model = null;
};

/*!
 * VisualEditor ContentEditable Annotation class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Generic ContentEditable annotation.
 *
 * This is an abstract class, annotations should extend this and call this constructor from their
 * constructor. You should not instantiate this class directly.
 *
 * Subclasses of ve.dm.Annotation should have a corresponding subclass here that controls rendering.
 *
 * @abstract
 * @extends ve.ce.View
 *
 * @constructor
 * @param {ve.dm.Annotation} model Model to observe
 * @param {ve.ce.ContentBranchNode} [parentNode] Node rendering this annotation
 * @param {Object} [config] Configuration options
 */
ve.ce.Annotation = function VeCeAnnotation( model, parentNode, config ) {
	// Parent constructor
	ve.ce.View.call( this, model, config );

	// Properties
	this.parentNode = parentNode || null;
};

/* Inheritance */

OO.inheritClass( ve.ce.Annotation, ve.ce.View );

/* Static Properties */

ve.ce.Annotation.static.tagName = 'span';

/**
 * Whether this annotation's continuation (or lack thereof) needs to be forced.
 *
 * This should be set to true only for annotations that aren't continued by browsers but are in DM,
 * or the other way around, or those where behavior is inconsistent between browsers.
 *
 * @static
 * @property
 * @inheritable
 */
ve.ce.Annotation.static.forceContinuation = false;

/* Static Methods */

/**
 * Get a plain text description.
 *
 * @static
 * @inheritable
 * @param {ve.dm.Annotation} annotation Annotation model
 * @returns {string} Description of annotation
 */
ve.ce.Annotation.static.getDescription = function () {
	return '';
};

/* Methods */

/**
 * Get the content branch node this annotation is rendered in, if any.
 * @returns {ve.ce.ContentBranchNode|null} Content branch node or null if none
 */
ve.ce.Annotation.prototype.getParentNode = function () {
	return this.parentNode;
};

/** */
ve.ce.Annotation.prototype.getModelHtmlDocument = function () {
	return this.parentNode && this.parentNode.getModelHtmlDocument();
};

/**
 * Release all memory.
 */
ve.ce.Annotation.prototype.destroy = function () {
	this.parentNode = null;

	// Parent method
	ve.ce.View.prototype.destroy.call( this );
};

/*!
 * VisualEditor ContentEditable Node class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Generic ContentEditable node.
 *
 * @abstract
 * @extends ve.ce.View
 * @mixins ve.Node
 *
 * @constructor
 * @param {ve.dm.Node} model Model to observe
 * @param {Object} [config] Configuration options
 */
ve.ce.Node = function VeCeNode( model, config ) {
	// Parent constructor
	ve.ce.View.call( this, model, config );

	// Mixin constructor
	ve.Node.call( this );

	// Properties
	this.parent = null;
};

/* Inheritance */

OO.inheritClass( ve.ce.Node, ve.ce.View );

OO.mixinClass( ve.ce.Node, ve.Node );

/* Static Members */

/**
 * Whether Enter splits this node type.
 *
 * When the user presses Enter, we split the node they're in (if splittable), then split its parent
 * if splittable, and continue traversing up the tree and stop at the first non-splittable node.
 *
 * @static
 * @property
 * @inheritable
 */
ve.ce.Node.static.splitOnEnter = false;

/**
 * Command to execute when Enter is pressed while this node is selected, or when the node is double-clicked.
 *
 * @static
 * @property {string|null}
 * @inheritable
 */
ve.ce.Node.static.primaryCommandName = null;

/* Static Methods */

/**
 * Get a plain text description.
 *
 * @static
 * @inheritable
 * @param {ve.dm.Node} node Node model
 * @returns {string} Description of node
 */
ve.ce.Node.static.getDescription = function () {
	return '';
};

/* Methods */

/**
 * @inheritdoc ve.Node
 */
ve.ce.Node.prototype.getChildNodeTypes = function () {
	return this.model.getChildNodeTypes();
};

/**
 * @inheritdoc ve.Node
 */
ve.ce.Node.prototype.getParentNodeTypes = function () {
	return this.model.getParentNodeTypes();
};

/**
 * @inheritdoc ve.Node
 */
ve.ce.Node.prototype.getSuggestedParentNodeTypes = function () {
	return this.model.getSuggestedParentNodeTypes();
};

/**
 * @inheritdoc ve.Node
 */
ve.ce.Node.prototype.canHaveChildren = function () {
	return this.model.canHaveChildren();
};

/**
 * @inheritdoc ve.Node
 */
ve.ce.Node.prototype.canHaveChildrenNotContent = function () {
	return this.model.canHaveChildrenNotContent();
};

/**
 * @inheritdoc ve.Node
 */
ve.ce.Node.prototype.isWrapped = function () {
	return this.model.isWrapped();
};

/**
 * @inheritdoc ve.Node
 */
ve.ce.Node.prototype.canContainContent = function () {
	return this.model.canContainContent();
};

/**
 * @inheritdoc ve.Node
 */
ve.ce.Node.prototype.isContent = function () {
	return this.model.isContent();
};

/**
 * @inheritdoc ve.Node
 *
 * If this is set to true it should implement:
 *
 *     setFocused( boolean val )
 *     boolean isFocused()
 */
ve.ce.Node.prototype.isFocusable = function () {
	return this.model.isFocusable();
};

/**
 * @inheritdoc ve.Node
 */
ve.ce.Node.prototype.isAlignable = function () {
	return this.model.isAlignable();
};

/**
 * @inheritdoc ve.Node
 */
ve.ce.Node.prototype.hasSignificantWhitespace = function () {
	return this.model.hasSignificantWhitespace();
};

/**
 * @inheritdoc ve.Node
 */
ve.ce.Node.prototype.handlesOwnChildren = function () {
	return this.model.handlesOwnChildren();
};

/**
 * @inheritdoc ve.Node
 */
ve.ce.Node.prototype.shouldIgnoreChildren = function () {
	return this.model.shouldIgnoreChildren();
};

/**
 * @inheritdoc ve.Node
 */
ve.ce.Node.prototype.getLength = function () {
	return this.model.getLength();
};

/**
 * @inheritdoc ve.Node
 */
ve.ce.Node.prototype.getOuterLength = function () {
	return this.model.getOuterLength();
};

/**
 * @inheritdoc ve.Node
 */
ve.ce.Node.prototype.getOffset = function () {
	return this.model.getOffset();
};

/**
 * Check if the node can be split.
 *
 * @returns {boolean} Node can be split
 */
ve.ce.Node.prototype.splitOnEnter = function () {
	return this.constructor.static.splitOnEnter;
};

/**
 * Release all memory.
 */
ve.ce.Node.prototype.destroy = function () {
	this.parent = null;
	this.root = null;
	this.doc = null;

	// Parent method
	ve.ce.View.prototype.destroy.call( this );
};

/** */
ve.ce.Node.prototype.getModelHtmlDocument = function () {
	return this.model.getDocument() && this.model.getDocument().getHtmlDocument();
};

/*!
 * VisualEditor ContentEditable BranchNode class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable branch node.
 *
 * Branch nodes can have branch or leaf nodes as children.
 *
 * @class
 * @abstract
 * @extends ve.ce.Node
 * @mixins ve.BranchNode
 * @constructor
 * @param {ve.dm.BranchNode} model Model to observe
 * @param {Object} [config] Configuration options
 */
ve.ce.BranchNode = function VeCeBranchNode( model, config ) {
	// Mixin constructor
	ve.BranchNode.call( this );

	// Parent constructor
	ve.ce.Node.call( this, model, config );

	// DOM changes (keep in sync with #onSetup)
	this.$element.addClass( 've-ce-branchNode' );

	// Properties
	this.tagName = this.$element.get( 0 ).nodeName.toLowerCase();
	this.slugNodes = [];

	// Events
	this.model.connect( this, { splice: 'onSplice' } );

	// Initialization
	this.onSplice.apply( this, [0, 0].concat( model.getChildren() ) );
};

/* Inheritance */

OO.inheritClass( ve.ce.BranchNode, ve.ce.Node );

OO.mixinClass( ve.ce.BranchNode, ve.BranchNode );

/* Static Properties */

/**
 * Inline slug template.
 *
 * @static
 * @property {HTMLElement}
 */
ve.ce.BranchNode.inlineSlugTemplate = ( function () {
	var $img = $( '<img>' )
			.addClass( 've-ce-chimera' )
			.css( { width: '0', height: '0' } ),
		$span = $( '<span>' )
			.addClass( 've-ce-branchNode-slug ve-ce-branchNode-inlineSlug' )
			.append( $img );

	// Firefox misbehaves if we don't set an src: https://bugzilla.mozilla.org/show_bug.cgi?id=989012
	// But setting an src in Chrome is very slow, so only set it in Firefox
	if ( $.client.profile().layout === 'gecko' ) {
		$img.prop( 'src', ve.ce.minImgDataUri );
	}
	return $span.get( 0 );
}() );

/**
 * Inline slug template for input debugging.
 *
 * @static
 * @property {HTMLElement}
 */
ve.ce.BranchNode.inputDebugInlineSlugTemplate = $( '<span>' )
	.addClass( 've-ce-branchNode-slug ve-ce-branchNode-inlineSlug' )
	.append(
		$( '<img>' )
			.prop( 'src', ve.ce.chimeraImgDataUri )
			.addClass( 've-ce-chimera' )
	)
	.get( 0 );

/**
 * Block slug template.
 *
 * @static
 * @property {HTMLElement}
 */
ve.ce.BranchNode.blockSlugTemplate = $( '<div>' )
	.addClass( 've-ce-branchNode-slug ve-ce-branchNode-blockSlug' )
	.get( 0 );

/* Methods */

/**
 * @inheritdoc
 */
ve.ce.BranchNode.prototype.onSetup = function () {
	// Parent method
	ve.ce.Node.prototype.onSetup.call( this );

	// DOM changes (duplicated from constructor in case this.$element is replaced)
	this.$element.addClass( 've-ce-branchNode' );
};

/**
 * Update the DOM wrapper.
 *
 * WARNING: The contents, .data( 'view' ), the contentEditable property and any classes the wrapper
 * already has will be moved to  the new wrapper, but other attributes and any other information
 * added using $.data() will be lost upon updating the wrapper. To retain information added to the
 * wrapper, subscribe to the 'teardown' and 'setup' events.
 *
 * @method
 * @fires teardown
 * @fires setup
 */
ve.ce.BranchNode.prototype.updateTagName = function () {
	var wrapper,
		tagName = this.getTagName();

	if ( tagName !== this.tagName ) {
		this.emit( 'teardown' );
		wrapper = document.createElement( tagName );
		// Copy classes
		wrapper.className = this.$element[0].className;
		// Copy contentEditable
		wrapper.contentEditable = this.$element[0].contentEditable;
		// Move contents
		while ( this.$element[0].firstChild ) {
			wrapper.appendChild( this.$element[0].firstChild );
		}
		// Swap elements
		if ( this.$element[0].parentNode ) {
			this.$element[0].parentNode.replaceChild( wrapper, this.$element[0] );
		}
		// Use new element from now on
		this.$element = $( wrapper );
		this.emit( 'setup' );
		// Remember which tag name we are using now
		this.tagName = tagName;
	}
};

/**
 * Handles model update events.
 *
 * @param {ve.dm.Transaction} transaction
 */
ve.ce.BranchNode.prototype.onModelUpdate = function ( transaction ) {
	this.emit( 'childUpdate', transaction );
};

/**
 * Handle splice events.
 *
 * ve.ce.Node objects are generated from the inserted ve.dm.Node objects, producing a view that's a
 * mirror of its model.
 *
 * @method
 * @param {number} index Index to remove and or insert nodes at
 * @param {number} howmany Number of nodes to remove
 * @param {ve.dm.BranchNode...} [nodes] Variadic list of nodes to insert
 */
ve.ce.BranchNode.prototype.onSplice = function ( index ) {
	var i, j,
		length,
		args = [],
		$anchor,
		afterAnchor,
		node,
		parentNode,
		removals;

	for ( i = 0, length = arguments.length; i < length; i++ ) {
		args.push( arguments[i] );
	}
	// Convert models to views and attach them to this node
	if ( args.length >= 3 ) {
		for ( i = 2, length = args.length; i < length; i++ ) {
			args[i] = ve.ce.nodeFactory.create( args[i].getType(), args[i], { $: this.$ } );
			args[i].model.connect( this, { update: 'onModelUpdate' } );
		}
	}
	removals = this.children.splice.apply( this.children, args );
	for ( i = 0, length = removals.length; i < length; i++ ) {
		removals[i].model.disconnect( this, { update: 'onModelUpdate' } );
		removals[i].setLive( false );
		removals[i].detach();
		removals[i].$element.detach();
	}
	if ( args.length >= 3 ) {
		if ( index ) {
			// Get the element before the insertion point
			$anchor = this.children[ index - 1 ].$element.last();
		}
		for ( i = args.length - 1; i >= 2; i-- ) {
			args[i].attach( this );
			if ( index ) {
				// DOM equivalent of $anchor.after( args[i].$element );
				afterAnchor = $anchor[0].nextSibling;
				parentNode = $anchor[0].parentNode;
				for ( j = 0, length = args[i].$element.length; j < length; j++ ) {
					parentNode.insertBefore( args[i].$element[j], afterAnchor );
				}
			} else {
				// DOM equivalent of this.$element.prepend( args[j].$element );
				node = this.$element[0];
				for ( j = args[i].$element.length - 1; j >= 0; j-- ) {
					node.insertBefore( args[i].$element[j], node.firstChild );
				}
			}
			if ( this.live !== args[i].isLive() ) {
				args[i].setLive( this.live );
			}
		}
	}

	this.setupBlockSlugs();
};

/**
 * Setup block slugs
 */
ve.ce.BranchNode.prototype.setupBlockSlugs = function () {
	// Only proceed if we are in a non-content node
	if ( this.canHaveChildrenNotContent() ) {
		this.setupSlugs( true );
	}
};

/**
 * Setup inline slugs
 */
ve.ce.BranchNode.prototype.setupInlineSlugs = function () {
	// Only proceed if we are in a content node
	if ( !this.canHaveChildrenNotContent() ) {
		this.setupSlugs( false );
	}
};

/**
 * Setup slugs where needed.
 *
 * Existing slugs will be removed before new ones are added.
 *
 * @param {boolean} isBlock Set up block slugs, otherwise setup inline slugs
 */
ve.ce.BranchNode.prototype.setupSlugs = function ( isBlock ) {
	var i, slugTemplate, slugNode, child, slugButton,
		doc = this.getElementDocument();

	// Remove all slugs in this branch
	for ( i in this.slugNodes ) {
		if ( this.slugNodes[i] !== undefined && this.slugNodes[i].parentNode ) {
			this.slugNodes[i].parentNode.removeChild( this.slugNodes[i] );
		}
		delete this.slugNodes[i];
	}

	if ( isBlock ) {
		slugTemplate = ve.ce.BranchNode.blockSlugTemplate;
	} else if ( ve.inputDebug ) {
		slugTemplate = ve.ce.BranchNode.inputDebugInlineSlugTemplate;
	} else {
		slugTemplate = ve.ce.BranchNode.inlineSlugTemplate;
	}

	for ( i in this.getModel().slugPositions ) {
		slugNode = doc.importNode( slugTemplate, true );
		// FIXME: InternalListNode has an empty $element, so we assume that the slug goes at the
		// end instead. This is a hack and the internal list needs to die in a fire.
		if ( this.children[i] && this.children[i].$element[0] ) {
			child = this.children[i].$element[0];
			// child.parentNode might not be equal to this.$element[0]: e.g. annotated inline nodes
			child.parentNode.insertBefore( slugNode, child );
		} else {
			this.$element[0].appendChild( slugNode );
		}
		this.slugNodes[i] = slugNode;
		if ( isBlock ) {
			slugButton = new OO.ui.ButtonWidget( {
				label: ve.msg( 'visualeditor-slug-insert' ),
				icon: 'add',
				framed: false
			} ).on( 'click', this.onSlugClick.bind( this, slugNode ) );
			$( slugNode ).append( slugButton.$element );
		}
	}
};

/**
 * Handle slug click events
 *
 * @param {HTMLElement} slugNode Slug node clicked
 */
ve.ce.BranchNode.prototype.onSlugClick = function ( slugNode ) {
	this.getRoot().getSurface().createSlug( slugNode );
};

/**
 * Get a slug at an offset.
 *
 * @method
 * @param {number} offset Offset to get slug at
 * @returns {HTMLElement|null}
 */
ve.ce.BranchNode.prototype.getSlugAtOffset = function ( offset ) {
	var i,
		startOffset = this.model.getOffset() + ( this.isWrapped() ? 1 : 0 );

	if ( offset === startOffset ) {
		return this.slugNodes[0] || null;
	}
	for ( i = 0; i < this.children.length; i++ ) {
		startOffset += this.children[i].model.getOuterLength();
		if ( offset === startOffset ) {
			return this.slugNodes[i + 1] || null;
		}
	}
};

/**
 * Set live state on child nodes.
 *
 * @method
 * @param {boolean} live New live state
 */
ve.ce.BranchNode.prototype.setLive = function ( live ) {
	ve.ce.Node.prototype.setLive.call( this, live );
	for ( var i = 0; i < this.children.length; i++ ) {
		this.children[i].setLive( live );
	}
};

/**
 * Release all memory.
 */
ve.ce.BranchNode.prototype.destroy = function () {
	var i, len;
	for ( i = 0, len = this.children.length; i < len; i++ ) {
		this.children[i].destroy();
	}

	ve.ce.Node.prototype.destroy.call( this );
};

/*!
 * VisualEditor ContentEditable ContentBranchNode class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable content branch node.
 *
 * Content branch nodes can only have content nodes as children.
 *
 * @abstract
 * @extends ve.ce.BranchNode
 * @constructor
 * @param {ve.dm.BranchNode} model Model to observe
 * @param {Object} [config] Configuration options
 */
ve.ce.ContentBranchNode = function VeCeContentBranchNode( model, config ) {
	// Parent constructor
	ve.ce.BranchNode.call( this, model, config );

	// Properties
	this.lastTransaction = null;
	this.rendered = false;
	this.unicornAnnotations = null;
	this.unicorns = null;
	this.onClickHandler = this.onClick.bind( this );

	// Events
	this.connect( this, { childUpdate: 'onChildUpdate' } );
	// Some browsers allow clicking links inside contenteditable, such as in iOS Safari when the
	// keyboard is closed
	this.$element.on( 'click', this.onClickHandler );
};

/* Inheritance */

OO.inheritClass( ve.ce.ContentBranchNode, ve.ce.BranchNode );

/* Static Members */

/**
 * Whether Enter splits this node type. Must be true for ContentBranchNodes.
 *
 * Warning: overriding this to false in a subclass will cause crashes on Enter key handling.
 *
 * @static
 * @property
 * @inheritable
 */
ve.ce.ContentBranchNode.static.splitOnEnter = true;

/* Static Methods */

/**
 * Append the return value of #getRenderedContents to a DOM element.
 *
 * @param {HTMLElement} container DOM element
 * @param {HTMLElement} wrapper Wrapper returned by #getRenderedContents
 */
ve.ce.ContentBranchNode.static.appendRenderedContents = function ( container, wrapper ) {
	function resolveOriginals( domElement ) {
		var i, len, child;
		for ( i = 0, len = domElement.childNodes.length; i < len; i++ ) {
			child = domElement.childNodes[i];
			if ( child.veOrigNode ) {
				domElement.replaceChild( child.veOrigNode, child );
			} else if ( child.childNodes && child.childNodes.length ) {
				resolveOriginals( child );
			}
		}
	}

	/* Resolve references to the original nodes. */
	resolveOriginals( wrapper );
	while ( wrapper.firstChild ) {
		container.appendChild( wrapper.firstChild );
	}
};

/* Methods */

/**
 * Handle click events.
 *
 * @param {jQuery.Event} e Click event
 */
ve.ce.ContentBranchNode.prototype.onClick = function ( e ) {
	if (
		// Only block clicks on links
		( e.target !== this.$element[0] && e.target.nodeName.toUpperCase() === 'A' ) &&
		// Don't prevent a modified click, which in some browsers deliberately opens the link
		( !e.altKey && !e.ctrlKey && !e.metaKey && !e.shiftKey )
	) {
		e.preventDefault();
	}
};

/**
 * Handle splice events.
 *
 * Rendering is only done once per transaction. If a paragraph has multiple nodes in it then it's
 * possible to receive multiple `childUpdate` events for a single transaction such as annotating
 * across them. State is tracked by storing and comparing the length of the surface model's complete
 * history.
 *
 * This is used to automatically render contents.
 * @see ve.ce.BranchNode#onSplice
 *
 * @method
 */
ve.ce.ContentBranchNode.prototype.onChildUpdate = function ( transaction ) {
	if ( transaction === null || transaction === this.lastTransaction ) {
		this.lastTransaction = transaction;
		return;
	}
	this.renderContents();
};

/**
 * Handle splice events.
 *
 * This is used to automatically render contents.
 * @see ve.ce.BranchNode#onSplice
 *
 * @method
 */
ve.ce.ContentBranchNode.prototype.onSplice = function ( index, howmany ) {
	// Parent method
	ve.ce.BranchNode.prototype.onSplice.apply( this, arguments );

	// HACK: adjust slugNodes indexes if isRenderingLocked. This should be sufficient to
	// keep this.slugNodes valid - only text changes can occur, which cannot create a
	// requirement for a new slug (it can make an existing slug redundant, but it is
	// harmless to leave it there).
	if (
		this.root instanceof ve.ce.DocumentNode &&
		this.root.getSurface().isRenderingLocked
	) {
		this.slugNodes.splice.apply( this.slugNodes, [ index, howmany ].concat( new Array( arguments.length - 2 ) ) );
	}

	// Rerender to make sure annotations are applied correctly
	this.renderContents();
};

/** @inheritdoc */
ve.ce.ContentBranchNode.prototype.setupBlockSlugs = function () {
	// Respect render lock
	if (
		this.root instanceof ve.ce.DocumentNode &&
		this.root.getSurface().isRenderingLocked()
	) {
		return;
	}
	ve.ce.BranchNode.prototype.setupBlockSlugs.apply( this, arguments );
};

/**
 * Get an HTML rendering of the contents.
 *
 * If you are actually going to append the result to a DOM, you need to
 * do this with #appendRenderedContents, which resolves the cloned
 * nodes returned by this function back to their originals.
 *
 * @method
 * @returns {HTMLElement} Wrapper containing rendered contents
 * @returns {Object} return.unicornInfo Unicorn information
 */
ve.ce.ContentBranchNode.prototype.getRenderedContents = function () {
	var i, ilen, j, jlen, item, itemAnnotations, ann, clone, dmSurface, dmSelection, relCursor,
		unicorn, img1, img2, annotationsChanged, childLength, offset, htmlItem, ceSurface,
		nextItemAnnotations, linkAnnotations,
		store = this.model.doc.getStore(),
		annotationStack = new ve.dm.AnnotationSet( store ),
		annotatedHtml = [],
		doc = this.getElementDocument(),
		wrapper = doc.createElement( 'div' ),
		current = wrapper,
		unicornInfo = {},
		buffer = '',
		node = this;

	function openAnnotation( annotation ) {
		annotationsChanged = true;
		if ( buffer !== '' ) {
			current.appendChild( doc.createTextNode( buffer ) );
			buffer = '';
		}
		// Create a new DOM node and descend into it
		ann = ve.ce.annotationFactory.create(
			annotation.getType(), annotation, node, { $: node.$ }
		).$element[0];
		current.appendChild( ann );
		current = ann;
	}

	function closeAnnotation() {
		annotationsChanged = true;
		if ( buffer !== '' ) {
			current.appendChild( doc.createTextNode( buffer ) );
			buffer = '';
		}
		// Traverse up
		current = current.parentNode;
	}

	// Gather annotated HTML from the child nodes
	for ( i = 0, ilen = this.children.length; i < ilen; i++ ) {
		annotatedHtml = annotatedHtml.concat( this.children[i].getAnnotatedHtml() );
	}

	// Set relCursor to collapsed selection offset, or -1 if none
	// (in which case we don't need to worry about preannotation)
	relCursor = -1;
	if ( this.getRoot() ) {
		ceSurface = this.getRoot().getSurface();
		dmSurface = ceSurface.getModel();
		dmSelection = dmSurface.getTranslatedSelection();
		if ( dmSelection instanceof ve.dm.LinearSelection && dmSelection.isCollapsed() ) {
			// subtract 1 for CBN opening tag
			relCursor = dmSelection.getRange().start - this.getOffset() - 1;
		}
	}

	// Set cursor status for renderContents. If hasCursor, splice unicorn marker at the
	// collapsed selection offset. It will be rendered later if it is needed, else ignored
	if ( relCursor < 0 || relCursor > this.getLength() ) {
		unicornInfo.hasCursor = false;
	} else {
		unicornInfo.hasCursor = true;
		offset = 0;
		for ( i = 0, ilen = annotatedHtml.length; i < ilen; i++ ) {
			htmlItem = annotatedHtml[i][0];
			childLength = ( typeof htmlItem === 'string' ) ? 1 : 2;
			if ( offset <= relCursor && relCursor < offset + childLength ) {
				unicorn = [
					{}, // unique object, for testing object equality later
					dmSurface.getInsertionAnnotations().storeIndexes
				];
				annotatedHtml.splice( i, 0, unicorn );
				break;
			}
			offset += childLength;
		}
		// Special case for final position
		if ( i === ilen && offset === relCursor ) {
			unicorn = [
				{}, // unique object, for testing object equality later
				dmSurface.getInsertionAnnotations().storeIndexes
			];
			annotatedHtml.push( unicorn );
		}
	}

	// Render HTML with annotations
	for ( i = 0, ilen = annotatedHtml.length; i < ilen; i++ ) {
		if ( Array.isArray( annotatedHtml[i] ) ) {
			item = annotatedHtml[i][0];
			itemAnnotations = new ve.dm.AnnotationSet( store, annotatedHtml[i][1] );
		} else {
			item = annotatedHtml[i];
			itemAnnotations = new ve.dm.AnnotationSet( store );
		}

		// Remove 'a' from the unicorn, if the following item has no 'a'
		if ( unicorn && item === unicorn[0] && i < ilen - 1 ) {
			linkAnnotations = itemAnnotations.getAnnotationsByName( 'link' );
			nextItemAnnotations = new ve.dm.AnnotationSet(
				store,
				Array.isArray( annotatedHtml[i + 1] ) ? annotatedHtml[i + 1][1] : undefined
			);
			if ( !nextItemAnnotations.containsAllOf( linkAnnotations ) ) {
				itemAnnotations.removeSet( linkAnnotations );
			}
		}

		// annotationsChanged gets set to true by openAnnotation and closeAnnotation
		annotationsChanged = false;
		ve.dm.Converter.openAndCloseAnnotations( annotationStack, itemAnnotations,
			openAnnotation, closeAnnotation
		);

		// Handle the actual item
		if ( typeof item === 'string' ) {
			buffer += item;
		} else if ( unicorn && item === unicorn[0] ) {
			if ( annotationsChanged ) {
				if ( buffer !== '' ) {
					current.appendChild( doc.createTextNode( buffer ) );
					buffer = '';
				}
				img1 = doc.createElement( 'img' );
				img2 = doc.createElement( 'img' );
				img1.className = 've-ce-unicorn ve-ce-pre-unicorn';
				img2.className = 've-ce-unicorn ve-ce-post-unicorn';
				$( img1 ).data( 'dmOffset', ( this.getOffset() + 1 + i ) );
				$( img2 ).data( 'dmOffset', ( this.getOffset() + 1 + i ) );
				if ( ve.inputDebug ) {
					img1.setAttribute( 'src', ve.ce.unicornImgDataUri );
					img2.setAttribute( 'src', ve.ce.unicornImgDataUri );
				} else {
					img1.setAttribute( 'src', ve.ce.minImgDataUri );
					img2.setAttribute( 'src', ve.ce.minImgDataUri );
					img1.style.width = '0px';
					img2.style.width = '0px';
					img1.style.height = '0px';
					img2.style.height = '0px';
				}
				current.appendChild( img1 );
				current.appendChild( img2 );
				unicornInfo.annotations = dmSurface.getInsertionAnnotations();
				unicornInfo.unicorns = [ img1, img2 ];
			} else {
				unicornInfo.unicornAnnotations = null;
				unicornInfo.unicorns = null;
			}
		} else {
			if ( buffer !== '' ) {
				current.appendChild( doc.createTextNode( buffer ) );
				buffer = '';
			}
			// DOM equivalent of $( current ).append( item.clone() );
			for ( j = 0, jlen = item.length; j < jlen; j++ ) {
				// Append a clone so as to not relocate the original node
				clone = item[j].cloneNode( true );
				// Store a reference to the original node in a property
				clone.veOrigNode = item[j];
				current.appendChild( clone );
			}
		}
	}
	if ( buffer !== '' ) {
		current.appendChild( doc.createTextNode( buffer ) );
		buffer = '';
	}
	wrapper.unicornInfo = unicornInfo;
	return wrapper;
};

/**
 * Render contents.
 *
 * @method
 * @return {boolean} Whether the contents have changed
 */
ve.ce.ContentBranchNode.prototype.renderContents = function () {
	var i, len, element, rendered, unicornInfo, oldWrapper, newWrapper,
		node = this;
	if (
		this.root instanceof ve.ce.DocumentNode &&
		this.root.getSurface().isRenderingLocked()
	) {
		return false;
	}

	if ( this.root instanceof ve.ce.DocumentNode ) {
		this.root.getSurface().setContentBranchNodeChanged();
	}

	rendered = this.getRenderedContents();
	unicornInfo = rendered.unicornInfo;
	delete rendered.unicornInfo;

	// Return if unchanged. Test by building the new version and checking DOM-equality.
	// However we have to normalize to cope with consecutive text nodes. We can't normalize
	// the attached version, because that would close IMEs. As an optimization, don't perform
	// this checking if this node has never rendered before.
	if ( this.rendered ) {
		oldWrapper = this.$element[0].cloneNode( true );
		newWrapper = this.$element[0].cloneNode( false );
		while ( rendered.firstChild ) {
			newWrapper.appendChild( rendered.firstChild );
		}
		ve.normalizeNode( oldWrapper );
		ve.normalizeNode( newWrapper );
		if ( newWrapper.isEqualNode( oldWrapper ) ) {
			return false;
		}
		rendered = newWrapper;
	}
	this.rendered = true;

	this.unicornAnnotations = unicornInfo.annotations || null;
	this.unicorns = unicornInfo.unicorns || null;

	// Detach all child nodes from this.$element
	for ( i = 0, len = this.$element.length; i < len; i++ ) {
		element = this.$element[i];
		while ( element.firstChild ) {
			element.removeChild( element.firstChild );
		}
	}

	// Reattach nodes
	this.constructor.static.appendRenderedContents( this.$element[0], rendered );

	// Set unicorning status
	if ( this.getRoot() ) {
		if ( !unicornInfo.hasCursor ) {
			this.getRoot().getSurface().setNotUnicorning( this );
		} else if ( this.unicorns ) {
			this.getRoot().getSurface().setUnicorning( this );
		} else {
			this.getRoot().getSurface().setNotUnicorningAll( this );
		}
	}
	this.hasCursor = null;

	// Add slugs
	this.setupInlineSlugs();

	// Highlight the node in debug mode
	if ( ve.debug ) {
		this.$element.css( 'backgroundColor', '#eee' );
		setTimeout( function () {
			node.$element.css( 'backgroundColor', '' );
		}, 500 );
	}

	return true;
};

/**
 * Handle teardown event.
 *
 * @method
 */
ve.ce.ContentBranchNode.prototype.onTeardown = function () {
	var ceSurface = this.getRoot().getSurface();

	// Parent method
	ve.ce.BranchNode.prototype.onTeardown.call( this );

	ceSurface.setNotUnicorning( this );
};

/**
 * @inheritdoc
 */
ve.ce.ContentBranchNode.prototype.destroy = function () {
	this.$element.off( 'click', this.onClickHandler );
};

/*!
 * VisualEditor ContentEditable LeafNode class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable leaf node.
 *
 * Leaf nodes can not have any children.
 *
 * @abstract
 * @extends ve.ce.Node
 * @mixins ve.LeafNode
 *
 * @constructor
 * @param {ve.dm.LeafNode} model
 * @param {Object} [config]
 */
ve.ce.LeafNode = function VeCeLeafNode( model ) {
	// Mixin constructor
	ve.LeafNode.call( this );

	// Parent constructor
	ve.ce.Node.apply( this, arguments );

	// DOM changes (keep in sync with #onSetup)
	if ( model.isWrapped() ) {
		this.$element.addClass( 've-ce-leafNode' );
	}
};

/* Inheritance */

OO.inheritClass( ve.ce.LeafNode, ve.ce.Node );

OO.mixinClass( ve.ce.LeafNode, ve.LeafNode );

/* Static Properties */

ve.ce.LeafNode.static.tagName = 'span';

/* Methods */

/**
 * @inheritdoc
 */
ve.ce.LeafNode.prototype.onSetup = function () {
	// Parent method
	ve.ce.Node.prototype.onSetup.call( this );

	// DOM changes (duplicated from constructor in case this.$element is replaced)
	if ( this.model.isWrapped() ) {
		this.$element.addClass( 've-ce-leafNode' );
	}
};

/**
 * Get annotated HTML fragments.
 *
 * @see ve.ce.ContentBranchNode
 *
 * An HTML fragment can be:
 * - a plain text string
 * - a jQuery object
 * - an array with a plain text string or jQuery object at index 0 and a ve.dm.AnnotationSet at index 1,
 *   i.e. ['textstring', ve.dm.AnnotationSet] or [$jQueryObj, ve.dm.AnnotationSet]
 *
 * The default implementation should be fine in most cases. A subclass only needs to override this
 * if the annotations aren't necessarily the same across the entire node (like in ve.ce.TextNode).
 *
 * @method
 * @returns {Array} Array of HTML fragments, i.e.
 *  [ string | jQuery | [string|jQuery, ve.dm.AnnotationSet] ]
 */
ve.ce.LeafNode.prototype.getAnnotatedHtml = function () {
	return [ [ this.$element, this.getModel().getAnnotations() ] ];
};

/*!
 * VisualEditor ContentEditable ClassAttributeNode class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable class-attribute node.
 *
 * @class
 * @abstract
 *
 * @constructor
 * @param {jQuery} [$classedElement=this.$element] Element to which attribute-based classes are attached
 */
ve.ce.ClassAttributeNode = function VeCeClassAttributeNode( $classedElement, config ) {
	config = config || {};

	// Properties
	this.$classedElement = $classedElement || this.$element;
	this.currentAttributeClasses = '';

	// Events
	this.connect( this, { setup: 'updateAttributeClasses' } );
	this.model.connect( this, { attributeChange: 'updateAttributeClasses' } );
};

/* Inheritance */

OO.initClass( ve.ce.ClassAttributeNode );

/**
 * Update classes from attributes
 */
ve.ce.ClassAttributeNode.prototype.updateAttributeClasses = function () {
	this.$classedElement.removeClass( this.currentAttributeClasses );
	this.currentAttributeClasses = this.model.constructor.static.getClassAttrFromAttributes( this.model.element.attributes );
	this.$classedElement.addClass( this.currentAttributeClasses );
};

/*!
 * VisualEditor ContentEditable AlignableNode class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable Alignable node.
 *
 * @class
 * @abstract
 * @extends ve.ce.ClassAttributeNode
 *
 * @constructor
 */
ve.ce.AlignableNode = function VeCeAlignableNode() {
	// Parent constructor
	ve.ce.AlignableNode.super.apply( this, arguments );

	this.align = null;
};

/* Inheritance */

OO.inheritClass( ve.ce.AlignableNode, ve.ce.ClassAttributeNode );

/* Events */

/**
 * @event align
 * @param {string} align New alignment
 */

/**
 * @inheritdoc
 */
ve.ce.AlignableNode.prototype.updateAttributeClasses = function () {
	ve.ce.AlignableNode.super.prototype.updateAttributeClasses.apply( this, arguments );
	var align = this.model.getAttribute( 'align' );
	if ( align && align !== this.align ) {
		this.emit( 'align', align );
		this.align = align;
	}
};

/*!
 * VisualEditor ContentEditable FocusableNode class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable focusable node.
 *
 * Focusable elements have a special treatment by ve.ce.Surface. When the user selects only a single
 * node, if it is focusable, the surface will set the focusable node's focused state. Other systems,
 * such as the context, may also use a focusable node's $focusable property as a hint of where the
 * primary element in the node is. Typically, and by default, the primary element is the root
 * element, but in some cases it may need to be configured to be a specific child element within the
 * node's DOM rendering.
 *
 * If your focusable node changes size and the highlight must be redrawn, call redrawHighlights().
 * 'resizeEnd' and 'rerender' are already bound to call this.
 *
 * @class
 * @abstract
 *
 * @constructor
 * @param {jQuery} [$focusable=this.$element] Primary element user is focusing on
 * @param {Object} [config] Configuration options
 * @cfg {string[]} [classes] CSS classes to be added to the highlight container
 */
ve.ce.FocusableNode = function VeCeFocusableNode( $focusable, config ) {
	config = config || {};

	// Properties
	this.focused = false;
	this.highlighted = false;
	this.isFocusableSetup = false;
	this.$highlights = this.$( '<div>' ).addClass( 've-ce-focusableNode-highlights' );
	this.$focusable = $focusable || this.$element;
	this.focusableSurface = null;
	this.rects = null;
	this.boundingRect = null;
	this.startAndEndRects = null;

	if ( Array.isArray( config.classes ) ) {
		this.$highlights.addClass( config.classes.join( ' ' ) );
	}

	// DOM changes
	this.$element
		.addClass( 've-ce-focusableNode' )
		.prop( 'contentEditable', 'false' );

	// Events
	this.connect( this, {
		setup: 'onFocusableSetup',
		teardown: 'onFocusableTeardown',
		resizeStart: 'onFocusableResizeStart',
		resizeEnd: 'onFocusableResizeEnd',
		rerender: 'onFocusableRerender'
	} );
};

/* Inheritance */

OO.initClass( ve.ce.FocusableNode );

/* Events */

/**
 * @event focus
 */

/**
 * @event blur
 */

/* Methods */

/**
 * Create a highlight element.
 *
 * @returns {jQuery} A highlight element
 */
ve.ce.FocusableNode.prototype.createHighlight = function () {
	return this.$( '<div>' )
		.addClass( 've-ce-focusableNode-highlight' )
		.prop( {
			title: this.constructor.static.getDescription( this.model ),
			draggable: false
		} )
		.append( this.$( '<img>' )
			.addClass( 've-ce-focusableNode-highlight-relocatable-marker' )
			.attr( 'src', 'data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==' )
			.on( {
				dragstart: this.onFocusableDragStart.bind( this ),
				dragend: this.onFocusableDragEnd.bind( this )
			} )
		);
};

/**
 * Handle node setup.
 *
 * @method
 */
ve.ce.FocusableNode.prototype.onFocusableSetup = function () {
	// Exit if already setup or not attached
	if ( this.isFocusableSetup || !this.root ) {
		return;
	}

	this.focusableSurface = this.root.getSurface();

	// DOM changes (duplicated from constructor in case this.$element is replaced)
	this.$element
		.addClass( 've-ce-focusableNode' )
		.prop( 'contentEditable', 'false' );

	// Events
	this.$focusable.on( {
		'mouseenter.ve-ce-focusableNode': this.onFocusableMouseEnter.bind( this ),
		'mousedown.ve-ce-focusableNode touchend.ve-ce-focusableNode': this.onFocusableMouseDown.bind( this )
	} );
	// $element is ce=false so make sure nothing happens when you click
	// on it, just in case the browser decides to do something.
	// If $element == $focusable then this can be skipped as $focusable already
	// handles mousedown events.
	if ( !this.$element.is( this.$focusable ) ) {
		this.$element.on( {
			'mousedown.ve-ce-focusableNode': function ( e ) { e.preventDefault(); }
		} );
	}

	this.isFocusableSetup = true;
};

/**
 * Handle node teardown.
 *
 * @method
 */
ve.ce.FocusableNode.prototype.onFocusableTeardown = function () {
	// Exit if not setup or not attached
	if ( !this.isFocusableSetup || !this.root ) {
		return;
	}

	// Events
	this.$focusable.off( '.ve-ce-focusableNode' );
	this.$element.off( '.ve-ce-focusableNode' );

	// Highlights
	this.clearHighlights();

	// DOM changes
	this.$element
		.removeClass( 've-ce-focusableNode' )
		.removeProp( 'contentEditable' );

	this.focusableSurface = null;
	this.isFocusableSetup = false;
};

/**
 * Handle highlight mouse down events.
 *
 * @method
 * @param {jQuery.Event} e Mouse down event
 */
ve.ce.FocusableNode.prototype.onFocusableMouseDown = function ( e ) {
	var range,
		surfaceModel = this.focusableSurface.getModel(),
		selection = surfaceModel.getSelection(),
		nodeRange = this.model.getOuterRange();

	if ( !this.isInContentEditable() ) {
		return;
	}
	// Wait for native selection to change before correcting
	setTimeout( function () {
		range = selection instanceof ve.dm.LinearSelection && selection.getRange();
		surfaceModel.getLinearFragment(
			e.shiftKey && range ?
				ve.Range.static.newCoveringRange(
					[ range, nodeRange ], range.from > nodeRange.from
				) :
				nodeRange
		).select();
	} );
};

/**
 * Handle highlight double click events.
 *
 * @method
 * @param {jQuery.Event} e Double click event
 */
ve.ce.FocusableNode.prototype.onFocusableDblClick = function () {
	if ( !this.isInContentEditable() ) {
		return;
	}
	this.executeCommand();
};

/**
 * Execute the command associated with this node.
 *
 * @method
 */
ve.ce.FocusableNode.prototype.executeCommand = function () {
	if ( !this.model.isInspectable() ) {
		return false;
	}
	var command = ve.ui.commandRegistry.getCommandForNode( this );
	if ( command ) {
		command.execute( this.focusableSurface.getSurface() );
	}
};

/**
 * Handle element drag start.
 *
 * @method
 * @param {jQuery.Event} e Drag start event
 */
ve.ce.FocusableNode.prototype.onFocusableDragStart = function () {
	if ( this.focusableSurface ) {
		// Allow dragging this node in the surface
		this.focusableSurface.startRelocation( this );
	}
	this.$highlights.addClass( 've-ce-focusableNode-highlights-relocating' );
};

/**
 * Handle element drag end.
 *
 * If a relocation actually takes place the node is destroyed before this events fires.
 *
 * @method
 * @param {jQuery.Event} e Drag end event
 */
ve.ce.FocusableNode.prototype.onFocusableDragEnd = function () {
	// endRelocation is usually triggered by onDocumentDrop in the surface, but if it isn't
	// trigger it here instead
	if ( this.focusableSurface ) {
		this.focusableSurface.endRelocation();
	}
	this.$highlights.removeClass( 've-ce-focusableNode-highlights-relocating' );
};

/**
 * Handle mouse enter events.
 *
 * @method
 * @param {jQuery.Event} e Mouse enter event
 */
ve.ce.FocusableNode.prototype.onFocusableMouseEnter = function () {
	if ( !this.root.getSurface().dragging && !this.root.getSurface().resizing && this.isInContentEditable() ) {
		this.createHighlights();
	}
};

/**
 * Handle surface mouse move events.
 *
 * @method
 * @param {jQuery.Event} e Mouse move event
 */
ve.ce.FocusableNode.prototype.onSurfaceMouseMove = function ( e ) {
	var $target = this.$( e.target );
	if (
		!$target.hasClass( 've-ce-focusableNode-highlight' ) &&
		$target.closest( '.ve-ce-focusableNode' ).length === 0
	) {
		this.clearHighlights();
	}
};

/**
 * Handle surface mouse out events.
 *
 * @method
 * @param {jQuery.Event} e Mouse out event
 */
ve.ce.FocusableNode.prototype.onSurfaceMouseOut = function ( e ) {
	if ( e.relatedTarget === null ) {
		this.clearHighlights();
	}
};

/**
 * Handle resize start events.
 *
 * @method
 */
ve.ce.FocusableNode.prototype.onFocusableResizeStart = function () {
	this.clearHighlights();
};

/**
 * Handle resize end event.
 *
 * @method
 */
ve.ce.FocusableNode.prototype.onFocusableResizeEnd = function () {
	this.redrawHighlights();
};

/**
 * Handle rerender event.
 *
 * @method
 */
ve.ce.FocusableNode.prototype.onFocusableRerender = function () {
	if ( this.focused && this.focusableSurface ) {
		this.redrawHighlights();
		// reposition menu
		this.focusableSurface.getSurface().getContext().updateDimensions( true );
	}
};

/**
 * Check if node is focused.
 *
 * @method
 * @returns {boolean} Node is focused
 */
ve.ce.FocusableNode.prototype.isFocused = function () {
	return this.focused;
};

/**
 * Set the selected state of the node.
 *
 * @method
 * @param {boolean} value Node is focused
 * @fires focus
 * @fires blur
 */
ve.ce.FocusableNode.prototype.setFocused = function ( value ) {
	value = !!value;
	if ( this.focused !== value ) {
		this.focused = value;
		if ( this.focused ) {
			this.emit( 'focus' );
			this.$element.addClass( 've-ce-focusableNode-focused' );
			this.createHighlights();
			this.focusableSurface.appendHighlights( this.$highlights, this.focused );
			this.focusableSurface.$element.off( '.ve-ce-focusableNode' );
		} else {
			this.emit( 'blur' );
			this.$element.removeClass( 've-ce-focusableNode-focused' );
			this.clearHighlights();
		}
	}
};

/**
 * Creates highlights.
 *
 * @method
 */
ve.ce.FocusableNode.prototype.createHighlights = function () {
	if ( this.highlighted ) {
		return;
	}

	this.$highlights.on( {
		mousedown: this.onFocusableMouseDown.bind( this ),
		dblclick: this.onFocusableDblClick.bind( this )
	} );

	this.highlighted = true;

	this.positionHighlights();

	this.focusableSurface.appendHighlights( this.$highlights, this.focused );

	// Events
	if ( !this.focused ) {
		this.focusableSurface.$element.on( {
			'mousemove.ve-ce-focusableNode': this.onSurfaceMouseMove.bind( this ),
			'mouseout.ve-ce-focusableNode': this.onSurfaceMouseOut.bind( this )
		} );
	}
	this.focusableSurface.connect( this, { position: 'positionHighlights' } );
};

/**
 * Clears highlight.
 *
 * @method
 */
ve.ce.FocusableNode.prototype.clearHighlights = function () {
	if ( !this.highlighted ) {
		return;
	}
	this.$highlights.remove().empty();
	this.focusableSurface.$element.off( '.ve-ce-focusableNode' );
	this.focusableSurface.disconnect( this, { position: 'positionHighlights' } );
	this.highlighted = false;
	this.boundingRect = null;
};

/**
 * Redraws highlight.
 *
 * @method
 */
ve.ce.FocusableNode.prototype.redrawHighlights = function () {
	this.clearHighlights();
	this.createHighlights();
};

/**
 * Calculate position of highlights
 */
ve.ce.FocusableNode.prototype.calculateHighlights = function () {
	var i, l, $set, columnCount, columnWidth,
		rects = [],
		filteredRects = [],
		webkitColumns = 'webkitColumnCount' in document.createElement( 'div' ).style,
		surfaceOffset = this.focusableSurface.getSurface().getBoundingClientRect();

	function contains( rect1, rect2 ) {
		return rect2.left >= rect1.left &&
			rect2.top >= rect1.top &&
			rect2.right <= rect1.right &&
			rect2.bottom <= rect1.bottom;
	}

	function process( el ) {
		var i, j, il, jl, contained, clientRects,
			$el = $( el );

		if ( $el.hasClass( 've-ce-noHighlight' ) ) {
			return;
		}

		if ( webkitColumns ) {
			columnCount = $el.css( '-webkit-column-count' );
			columnWidth = $el.css( '-webkit-column-width' );
			if ( ( columnCount && columnCount !== 'auto' ) || ( columnWidth && columnWidth !== 'auto' ) ) {
				// Chrome incorrectly measures children of nodes with columns [1], let's
				// just ignore them rather than render a possibly bizarre highlight. They
				// will usually not be positioned, because Chrome also doesn't position
				// them correctly [2] and so people avoid doing it.
				//
				// Of course there are other ways to render a node outside the bounding
				// box of its parent, like negative margin. We do not handle these cases,
				// and the highlight may not correctly cover the entire node if that
				// happens. This can't be worked around without implementing CSS
				// layouting logic ourselves, which is not worth it.
				//
				// [1] https://code.google.com/p/chromium/issues/detail?id=391271
				// [2] https://code.google.com/p/chromium/issues/detail?id=291616

				// jQuery keeps nodes in its collections in document order, so the
				// children have not been processed yet and can be safely removed.
				$set = $set.not( $el.find( '*' ) );
			}
		}

		clientRects = el.getClientRects();

		for ( i = 0, il = clientRects.length; i < il; i++ ) {
			contained = false;
			for ( j = 0, jl = rects.length; j < jl; j++ ) {
				// This rect is contained by an existing rect, discard
				if ( contains( rects[j], clientRects[i] ) ) {
					contained = true;
					break;
				}
				// An existing rect is contained by this rect, discard the existing rect
				if ( contains( clientRects[i], rects[j] ) ) {
					rects.splice( j, 1 );
					j--;
					jl--;
				}
			}
			if ( !contained ) {
				rects.push( clientRects[i] );
			}
		}
	}

	$set = this.$focusable.find( '*' ).addBack();
	// Calling process() may change $set.length
	for ( i = 0; i < $set.length; i++ ) {
		process( $set[i] );
	}

	// Elements with a width/height of 0 return a clientRect with a width/height of 1
	// As elements with an actual width/height of 1 aren't that useful anyway, just
	// throw away anything that is <=1
	filteredRects = rects.filter( function ( rect ) {
		return rect.width > 1 && rect.height > 1;
	} );
	// But if this filtering doesn't leave any rects at all, then we do want to use the 1px rects
	if ( filteredRects.length > 0 ) {
		rects = filteredRects;
	}

	this.boundingRect = null;
	// startAndEndRects is lazily evaluated in getStartAndEndRects from rects
	this.startAndEndRects = null;

	for ( i = 0, l = rects.length; i < l; i++ ) {
		// Translate to relative
		rects[i] = ve.translateRect( rects[i], -surfaceOffset.left, -surfaceOffset.top );
		this.$highlights.append(
			this.createHighlight().css( {
				top: rects[i].top,
				left: rects[i].left,
				width: rects[i].width,
				height: rects[i].height
			} )
		);

		if ( !this.boundingRect ) {
			this.boundingRect = ve.copy( rects[i] );
		} else {
			this.boundingRect.top = Math.min( this.boundingRect.top, rects[i].top );
			this.boundingRect.left = Math.min( this.boundingRect.left, rects[i].left );
			this.boundingRect.bottom = Math.max( this.boundingRect.bottom, rects[i].bottom );
			this.boundingRect.right = Math.max( this.boundingRect.right, rects[i].right );
		}
	}
	if ( this.boundingRect ) {
		this.boundingRect.width = this.boundingRect.right - this.boundingRect.left;
		this.boundingRect.height = this.boundingRect.bottom - this.boundingRect.top;
	}

	this.rects = rects;
};

/**
 * Positions highlights, and remove collapsed ones
 *
 * @method
 */
ve.ce.FocusableNode.prototype.positionHighlights = function () {
	if ( !this.highlighted ) {
		return;
	}

	var i, l;

	this.calculateHighlights();
	this.$highlights.empty();

	for ( i = 0, l = this.rects.length; i < l; i++ ) {
		this.$highlights.append(
			this.createHighlight().css( {
				top: this.rects[i].top,
				left: this.rects[i].left,
				width: this.rects[i].width,
				height: this.rects[i].height
			} )
		);
	}
};

/**
 * Get list of rectangles outlining the shape of the node relative to the surface
 *
 * @return {Object[]} List of rectangle objects
 */
ve.ce.FocusableNode.prototype.getRects = function () {
	if ( !this.highlighted ) {
		this.calculateHighlights();
	}
	return this.rects;
};

/**
 * Get the bounding rectangle of the focusable node highlight relative to the surface
 *
 * @return {Object|null} Top, left, bottom & right positions of the focusable node relative to the surface
 */
ve.ce.FocusableNode.prototype.getBoundingRect = function () {
	if ( !this.highlighted ) {
		this.calculateHighlights();
	}
	return this.boundingRect;
};

/**
 * Get start and end rectangles of an inline focusable node relative to the surface
 *
 * @return {Object|null} Start and end rectangles
 */
ve.ce.FocusableNode.prototype.getStartAndEndRects = function () {
	if ( !this.highlighted ) {
		this.calculateHighlights();
	}
	if ( !this.startAndEndRects ) {
		this.startAndEndRects = ve.getStartAndEndRects( this.rects );
	}
	return this.startAndEndRects;
};

/*!
 * VisualEditor ContentEditable ResizableNode class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable resizable node.
 *
 * @class
 * @abstract
 *
 * @constructor
 * @param {jQuery} [$resizable=this.$element] Resizable DOM element
 * @param {Object} [config] Configuration options
 * @cfg {number|null} [snapToGrid=10] Snap to a grid of size X when the shift key is held. Null disables.
 * @cfg {boolean} [outline=false] Resize using an outline of the element only, don't live preview.
 * @cfg {boolean} [showSizeLabel=true] Show a label with the current dimensions while resizing
 * @cfg {boolean} [showScaleLabel=true] Show a label with the current scale while resizing
 */
ve.ce.ResizableNode = function VeCeResizableNode( $resizable, config ) {
	config = config || {};

	// Properties
	this.$resizable = $resizable || this.$element;
	this.resizing = false;
	this.$resizeHandles = this.$( '<div>' );
	this.snapToGrid = config.snapToGrid !== undefined ? config.snapToGrid : 10;
	this.outline = !!config.outline;
	this.showSizeLabel = config.showSizeLabel !== false;
	this.showScaleLabel = config.showScaleLabel !== false;
	// Only gets enabled when the original dimensions are provided
	this.canShowScaleLabel = false;
	if ( this.showSizeLabel || this.showScaleLabel ) {
		this.$sizeText = this.$( '<span>' ).addClass( 've-ce-resizableNode-sizeText' );
		this.$sizeLabel = this.$( '<div>' ).addClass( 've-ce-resizableNode-sizeLabel' ).append( this.$sizeText );
	}
	this.resizableOffset = null;
	this.resizableSurface = null;

	// Events
	this.connect( this, {
		focus: 'onResizableFocus',
		blur: 'onResizableBlur',
		setup: 'onResizableSetup',
		teardown: 'onResizableTeardown',
		resizing: 'onResizableResizing',
		resizeEnd: 'onResizableFocus',
		rerender: 'onResizableFocus',
		align: 'onResizableAlign'
	} );
	this.model.connect( this, {
		attributeChange: 'onResizableAttributeChange'
	} );

	// Initialization
	this.$resizeHandles
		.addClass( 've-ce-resizableNode-handles' )
		.append( this.$( '<div>' )
			.addClass( 've-ce-resizableNode-nwHandle' )
			.data( 'handle', 'nw' ) )
		.append( this.$( '<div>' )
			.addClass( 've-ce-resizableNode-neHandle' )
			.data( 'handle', 'ne' ) )
		.append( this.$( '<div>' )
			.addClass( 've-ce-resizableNode-seHandle' )
			.data( 'handle', 'se' ) )
		.append( this.$( '<div>' )
			.addClass( 've-ce-resizableNode-swHandle' )
			.data( 'handle', 'sw' ) );
};

/* Inheritance */

OO.initClass( ve.ce.ResizableNode );

/* Events */

/**
 * @event resizeStart
 */

/**
 * @event resizing
 * @param {Object} dimensions Dimension object containing width & height
 */

/**
 * @event resizeEnd
 */

/* Methods */

/**
 * Get and cache the relative offset of the $resizable node
 *
 * @returns {Object} Position coordinates, containing top & left
 */
ve.ce.ResizableNode.prototype.getResizableOffset = function () {
	if ( !this.resizableOffset ) {
		this.resizableOffset = OO.ui.Element.static.getRelativePosition(
			this.$resizable, this.resizableSurface.getSurface().$element
		);
	}
	return this.resizableOffset;
};

/** */
ve.ce.ResizableNode.prototype.setOriginalDimensions = function ( dimensions ) {
	var scalable = this.model.getScalable();

	scalable.setOriginalDimensions( dimensions );

	// If dimensions are valid and the scale label is desired, enable it
	this.canShowScaleLabel = this.showScaleLabel &&
		scalable.getOriginalDimensions().width &&
		scalable.getOriginalDimensions().height;
};

/**
 * Hide the size label
 */
ve.ce.ResizableNode.prototype.hideSizeLabel = function () {
	var node = this;
	// Defer the removal of this class otherwise other DOM changes may cause
	// the opacity transition to not play out smoothly
	setTimeout( function () {
		node.$sizeLabel.removeClass( 've-ce-resizableNode-sizeLabel-resizing' );
	} );
	// Actually hide the size label after it's done animating
	setTimeout( function () {
		node.$sizeLabel.addClass( 'oo-ui-element-hidden' );
	}, 200 );
};

/**
 * Update the contents and position of the size label
 */
ve.ce.ResizableNode.prototype.updateSizeLabel = function () {
	if ( !this.showSizeLabel && !this.canShowScaleLabel ) {
		return;
	}

	var top, height,
		scalable = this.model.getScalable(),
		dimensions = scalable.getCurrentDimensions(),
		offset = this.getResizableOffset(),
		minWidth = ( this.showSizeLabel ? 100 : 0 ) + ( this.showScaleLabel ? 30 : 0 );

	// Put the label on the outside when too narrow
	if ( dimensions.width < minWidth ) {
		top = offset.top + dimensions.height;
		height = 30;
	} else {
		top = offset.top;
		height = dimensions.height;
	}
	this.$sizeLabel
		.removeClass( 'oo-ui-element-hidden' )
		.addClass( 've-ce-resizableNode-sizeLabel-resizing' )
		.css( {
			top: top,
			left: offset.left,
			width: dimensions.width,
			height: height,
			lineHeight: height + 'px'
		} );
	this.$sizeText.empty();
	if ( this.showSizeLabel ) {
		this.$sizeText.append( this.$( '<span>' )
			.addClass( 've-ce-resizableNode-sizeText-size' )
			.text( Math.round( dimensions.width ) + ' × ' + Math.round( dimensions.height ) )
		);
	}
	if ( this.canShowScaleLabel ) {
		this.$sizeText.append( this.$( '<span>' )
			.addClass( 've-ce-resizableNode-sizeText-scale' )
			.text( Math.round( 100 * scalable.getCurrentScale() ) + '%' )
		);
	}
	this.$sizeText.toggleClass( 've-ce-resizableNode-sizeText-warning', scalable.isTooSmall() || scalable.isTooLarge() );
};

/**
 * Show specific resize handles
 *
 * @param {string[]} [handles] List of handles to show: 'nw', 'ne', 'sw', 'se'. Show all if undefined.
 */
ve.ce.ResizableNode.prototype.showHandles = function ( handles ) {
	var i, len,
		add = [],
		remove = [],
		allDirections = [ 'nw', 'ne', 'sw', 'se' ];

	for ( i = 0, len = allDirections.length; i < len; i++ ) {
		if ( handles === undefined || handles.indexOf( allDirections[i] ) !== -1 ) {
			remove.push( 've-ce-resizableNode-hide-' + allDirections[i] );
		} else {
			add.push( 've-ce-resizableNode-hide-' + allDirections[i] );
		}
	}

	this.$resizeHandles
		.addClass( add.join( ' ' ) )
		.removeClass( remove.join( ' ' ) );
};

/**
 * Handle node focus.
 *
 * @method
 */
ve.ce.ResizableNode.prototype.onResizableFocus = function () {
	this.$resizeHandles.appendTo( this.resizableSurface.getSurface().$controls );
	if ( this.$sizeLabel ) {
		this.$sizeLabel.appendTo( this.resizableSurface.getSurface().$controls );
	}

	// Call getScalable to pre-fetch the extended data
	this.model.getScalable();

	this.setResizableHandlesSizeAndPosition();

	this.$resizeHandles
		.find( '.ve-ce-resizableNode-neHandle' )
			.css( { marginRight: -this.$resizable.width() } )
			.end()
		.find( '.ve-ce-resizableNode-swHandle' )
			.css( { marginBottom: -this.$resizable.height() } )
			.end()
		.find( '.ve-ce-resizableNode-seHandle' )
			.css( {
				marginRight: -this.$resizable.width(),
				marginBottom: -this.$resizable.height()
			} );

	this.$resizeHandles.children()
		.off( '.ve-ce-resizableNode' )
		.on(
			'mousedown.ve-ce-resizableNode',
			this.onResizeHandlesCornerMouseDown.bind( this )
		);

	this.resizableSurface.connect( this, { position: 'setResizableHandlesSizeAndPosition' } );

};

/**
 * Handle node blur.
 *
 * @method
 */
ve.ce.ResizableNode.prototype.onResizableBlur = function () {
	// Node may have already been torn down, e.g. after delete
	if ( !this.root ) {
		return;
	}

	this.$resizeHandles.detach();
	if ( this.$sizeLabel ) {
		this.$sizeLabel.detach();
	}

	this.resizableSurface.disconnect( this, { position: 'setResizableHandlesSizeAndPosition' } );

};

/**
 * Respond to AlignableNodes changing their alignment by hiding useless resize handles.
 *
 * @param {string} align Alignment
 */
ve.ce.ResizableNode.prototype.onResizableAlign = function ( align ) {
	switch ( align ) {
		case 'right':
			this.showHandles( ['sw'] );
			break;
		case 'left':
			this.showHandles( ['se'] );
			break;
		case 'center':
			this.showHandles( ['sw', 'se'] );
			break;
		default:
			this.showHandles();
			break;
	}
};

/**
 * Handle setup event.
 *
 * @method
 */
ve.ce.ResizableNode.prototype.onResizableSetup = function () {
	// Exit if already setup or not attached
	if ( this.isResizableSetup || !this.root ) {
		return;
	}

	this.resizableSurface = this.root.getSurface();
	this.isResizableSetup = true;
};

/**
 * Handle teardown event.
 *
 * @method
 */
ve.ce.ResizableNode.prototype.onResizableTeardown = function () {
	// Exit if not setup or not attached
	if ( !this.isResizableSetup || !this.root ) {
		return;
	}

	this.onResizableBlur();
	this.resizableSurface = null;
	this.isResizableSetup = false;
};

/**
 * Handle resizing event.
 *
 * @method
 * @param {Object} dimensions Dimension object containing width & height
 */
ve.ce.ResizableNode.prototype.onResizableResizing = function ( dimensions ) {
	// Clear cached resizable offset position as it may have changed
	this.resizableOffset = null;
	this.model.getScalable().setCurrentDimensions( dimensions );
	if ( !this.outline ) {
		this.$resizable.css( this.model.getScalable().getCurrentDimensions() );
		this.setResizableHandlesPosition();
	}
	this.updateSizeLabel();
};

/**
 * Handle attribute change events from the model.
 *
 * @method
 * @param {string} key Attribute key
 * @param {string} from Old value
 * @param {string} to New value
 */
ve.ce.ResizableNode.prototype.onResizableAttributeChange = function ( key, from, to ) {
	if ( key === 'width' || key === 'height' ) {
		this.$resizable.css( key, to );
	}
};

/**
 * Handle bounding box handle mousedown.
 *
 * @method
 * @param {jQuery.Event} e Click event
 * @fires resizeStart
 */
ve.ce.ResizableNode.prototype.onResizeHandlesCornerMouseDown = function ( e ) {
	// Hide context menu
	// TODO: Maybe there's a more generic way to handle this sort of thing? For relocation it's
	// handled in ve.ce.Surface
	this.root.getSurface().getSurface().getContext().toggle( false );

	// Set bounding box width and undo the handle margins
	this.$resizeHandles
		.addClass( 've-ce-resizableNode-handles-resizing' )
		.css( {
			width: this.$resizable.width(),
			height: this.$resizable.height()
		} );

	this.$resizeHandles.children().css( 'margin', 0 );

	// Values to calculate adjusted bounding box size
	this.resizeInfo = {
		mouseX: e.screenX,
		mouseY: e.screenY,
		top: this.$resizeHandles.position().top,
		left: this.$resizeHandles.position().left,
		height: this.$resizeHandles.height(),
		width: this.$resizeHandles.width(),
		handle: $( e.target ).data( 'handle' )
	};

	// Bind resize events
	this.resizing = true;
	this.root.getSurface().resizing = true;

	this.model.getScalable().setCurrentDimensions( {
		width: this.resizeInfo.width,
		height: this.resizeInfo.height
	} );
	this.updateSizeLabel();
	this.$( this.getElementDocument() ).on( {
		'mousemove.ve-ce-resizableNode': this.onDocumentMouseMove.bind( this ),
		'mouseup.ve-ce-resizableNode': this.onDocumentMouseUp.bind( this )
	} );
	this.emit( 'resizeStart' );

	return false;
};

/**
 * Set the proper size and position for resize handles
 *
 * @method
 */
ve.ce.ResizableNode.prototype.setResizableHandlesSizeAndPosition = function () {
	var width = this.$resizable.width(),
		height = this.$resizable.height();

	// Clear cached resizable offset position as it may have changed
	this.resizableOffset = null;

	this.setResizableHandlesPosition();

	this.$resizeHandles
		.css( {
			width: 0,
			height: 0
		} )
		.find( '.ve-ce-resizableNode-neHandle' )
			.css( { marginRight: -width } )
			.end()
		.find( '.ve-ce-resizableNode-swHandle' )
			.css( { marginBottom: -height } )
			.end()
		.find( '.ve-ce-resizableNode-seHandle' )
			.css( {
				marginRight: -width,
				marginBottom: -height
			} );
};

/**
 * Set the proper position for resize handles
 *
 * @method
 */
ve.ce.ResizableNode.prototype.setResizableHandlesPosition = function () {
	var offset = this.getResizableOffset();

	this.$resizeHandles.css( {
		top: offset.top,
		left: offset.left
	} );
};

/**
 * Handle body mousemove.
 *
 * @method
 * @param {jQuery.Event} e Click event
 * @fires resizing
 */
ve.ce.ResizableNode.prototype.onDocumentMouseMove = function ( e ) {
	var diff = {},
		dimensions = {
			width: 0,
			height: 0,
			top: this.resizeInfo.top,
			left: this.resizeInfo.left
		};

	if ( this.resizing ) {
		// X and Y diff
		switch ( this.resizeInfo.handle ) {
			case 'se':
				diff.x = e.screenX - this.resizeInfo.mouseX;
				diff.y = e.screenY - this.resizeInfo.mouseY;
				break;
			case 'nw':
				diff.x = this.resizeInfo.mouseX - e.screenX;
				diff.y = this.resizeInfo.mouseY - e.screenY;
				break;
			case 'ne':
				diff.x = e.screenX - this.resizeInfo.mouseX;
				diff.y = this.resizeInfo.mouseY - e.screenY;
				break;
			case 'sw':
				diff.x = this.resizeInfo.mouseX - e.screenX;
				diff.y = e.screenY - this.resizeInfo.mouseY;
				break;
		}

		dimensions = this.model.getScalable().getBoundedDimensions( {
			width: this.resizeInfo.width + diff.x,
			height: this.resizeInfo.height + diff.y
		}, e.shiftKey && this.snapToGrid );

		// Fix the position
		switch ( this.resizeInfo.handle ) {
			case 'ne':
				dimensions.top = this.resizeInfo.top +
					( this.resizeInfo.height - dimensions.height );
				break;
			case 'sw':
				dimensions.left = this.resizeInfo.left +
					( this.resizeInfo.width - dimensions.width );
				break;
			case 'nw':
				dimensions.top = this.resizeInfo.top +
					( this.resizeInfo.height - dimensions.height );
				dimensions.left = this.resizeInfo.left +
					( this.resizeInfo.width - dimensions.width );
				break;
		}

		// Update bounding box
		this.$resizeHandles.css( dimensions );
		this.emit( 'resizing', {
			width: dimensions.width,
			height: dimensions.height
		} );
	}
};

/**
 * Handle body mouseup.
 *
 * @method
 * @fires resizeEnd
 */
ve.ce.ResizableNode.prototype.onDocumentMouseUp = function () {
	var attrChanges,
		offset = this.model.getOffset(),
		width = this.$resizeHandles.outerWidth(),
		height = this.$resizeHandles.outerHeight(),
		surfaceModel = this.resizableSurface.getModel(),
		documentModel = surfaceModel.getDocument(),
		selection = surfaceModel.getSelection();

	this.$resizeHandles.removeClass( 've-ce-resizableNode-handles-resizing' );
	this.$( this.getElementDocument() ).off( '.ve-ce-resizableNode' );
	this.resizing = false;
	this.root.getSurface().resizing = false;
	this.hideSizeLabel();

	// Apply changes to the model
	attrChanges = this.getAttributeChanges( width, height );
	if ( !ve.isEmptyObject( attrChanges ) ) {
		surfaceModel.change(
			ve.dm.Transaction.newFromAttributeChanges( documentModel, offset, attrChanges ),
			selection
		);
	}

	// Update the context menu. This usually happens with the redraw, but not if the
	// user doesn't perform a drag
	this.root.getSurface().getSurface().getContext().updateDimensions();

	this.emit( 'resizeEnd' );
};

/**
 * Generate an object of attributes changes from the new width and height.
 *
 * @param {number} width New image width
 * @param {number} height New image height
 * @returns {Object} Attribute changes
 */
ve.ce.ResizableNode.prototype.getAttributeChanges = function ( width, height ) {
	var attrChanges = {};
	if ( this.model.getAttribute( 'width' ) !== width ) {
		attrChanges.width = width;
	}
	if ( this.model.getAttribute( 'height' ) !== height ) {
		attrChanges.height = height;
	}
	return attrChanges;
};

/*!
 * VisualEditor ContentEditable Surface class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable surface.
 *
 * @class
 * @extends OO.ui.Element
 * @mixins OO.EventEmitter
 *
 * @constructor
 * @param {jQuery} $container
 * @param {ve.dm.Surface} model Surface model to observe
 * @param {ve.ui.Surface} ui Surface user interface
 * @param {Object} [config] Configuration options
 */
ve.ce.Surface = function VeCeSurface( model, ui, options ) {
	var surface = this;

	// Parent constructor
	OO.ui.Element.call( this, options );

	// Mixin constructors
	OO.EventEmitter.call( this );

	// Properties
	this.surface = ui;
	this.model = model;
	this.documentView = new ve.ce.Document( model.getDocument(), this );
	this.surfaceObserver = new ve.ce.SurfaceObserver( this );
	this.selectionTimeout = null;
	this.$window = this.$( this.getElementWindow() );
	this.$document = this.$( this.getElementDocument() );
	this.$documentNode = this.getDocument().getDocumentNode().$element;
	// Window.getSelection returns a live singleton representing the document's selection
	this.nativeSelection = this.getElementWindow().getSelection();
	this.eventSequencer = new ve.EventSequencer( [
		'keydown', 'keypress', 'keyup',
		'compositionstart', 'compositionend',
		'input'
	] );
	this.clipboard = [];
	this.clipboardId = String( Math.random() );
	this.renderLocks = 0;
	this.dragging = false;
	this.relocatingNode = false;
	this.selecting = false;
	this.resizing = false;
	this.focused = false;
	this.deactivated = false;
	this.$deactivatedSelection = this.$( '<div>' );
	this.activeTableNode = null;
	this.contentBranchNodeChanged = false;
	this.$highlightsFocused = this.$( '<div>' );
	this.$highlightsBlurred = this.$( '<div>' );
	this.$highlights = this.$( '<div>' ).append(
		this.$highlightsFocused, this.$highlightsBlurred
	);
	this.$findResults = this.$( '<div>' );
	this.$dropMarker = this.$( '<div>' ).addClass( 've-ce-surface-dropMarker oo-ui-element-hidden' );
	this.$lastDropTarget = null;
	this.lastDropPosition = null;
	this.$pasteTarget = this.$( '<div>' );
	this.pasting = false;
	this.copying = false;
	this.pasteSpecial = false;
	this.focusedBlockSlug = null;
	this.focusedNode = null;
	// This is set on entering changeModel, then unset when leaving.
	// It is used to test whether a reflected change event is emitted.
	this.newModelSelection = null;
	// These are set during cursor moves (but not text additions/deletions at the cursor)
	this.cursorEvent = null;
	// A frozen selection from the start of a cursor keydown. The nodes are live and mutable,
	// and therefore the offsets may come to point to places that are misleadingly different
	// from when the selection was saved.
	this.misleadingCursorStartSelection = null;
	this.cursorDirectionality = null;
	this.unicorningNode = null;
	this.setUnicorningRecursionGuard = false;

	this.hasSelectionChangeEvents = 'onselectionchange' in this.getElementDocument();

	// Events
	this.surfaceObserver.connect( this, {
		contentChange: 'onSurfaceObserverContentChange',
		rangeChange: 'onSurfaceObserverRangeChange',
		branchNodeChange: 'onSurfaceObserverBranchNodeChange'
	} );
	this.model.connect( this, {
		select: 'onModelSelect',
		documentUpdate: 'onModelDocumentUpdate',
		insertionAnnotationsChange: 'onInsertionAnnotationsChange'
	} );

	this.onDocumentMouseUpHandler = this.onDocumentMouseUp.bind( this );
	this.$documentNode.on( {
		// mouse events shouldn't be sequenced as the event sequencer
		// is detached on blur
		mousedown: this.onDocumentMouseDown.bind( this ),
		// mouseup is bound to the whole document on mousedown
		mousemove: this.onDocumentMouseMove.bind( this ),
		cut: this.onCut.bind( this ),
		copy: this.onCopy.bind( this )
	} );

	this.onWindowResizeHandler = this.onWindowResize.bind( this );
	this.$window.on( 'resize', this.onWindowResizeHandler );

	this.onDocumentFocusInOutHandler = this.onDocumentFocusInOut.bind( this );
	this.$document.on( 'focusin focusout', this.onDocumentFocusInOutHandler );
	// It is possible for a mousedown to clear the selection
	// without triggering a focus change event (e.g. if the
	// document has been programmatically blurred) so trigger
	// a focus change to check if we still have a selection
	this.debounceFocusChange = ve.debounce( this.onFocusChange ).bind( this );
	this.$document.on( 'mousedown', this.debounceFocusChange );

	this.$pasteTarget.on( {
		cut: this.onCut.bind( this ),
		copy: this.onCopy.bind( this ),
		paste: this.onPaste.bind( this )
	} );

	this.$documentNode
		// Bug 65714: MSIE possibly needs `beforepaste` to also be bound; to test.
		.on( 'paste', this.onPaste.bind( this ) )
		.on( 'focus', 'a', function () {
			// Opera <= 12 triggers 'blur' on document node before any link is
			// focused and we don't want that
			surface.$documentNode[0].focus();
		} );

	if ( this.hasSelectionChangeEvents ) {
		this.$document.on( 'selectionchange', this.onDocumentSelectionChange.bind( this ) );
	} else {
		this.$documentNode.on( 'mousemove', this.onDocumentSelectionChange.bind( this ) );
	}

	this.$element.on( {
		dragstart: this.onDocumentDragStart.bind( this ),
		dragover: this.onDocumentDragOver.bind( this ),
		drop: this.onDocumentDrop.bind( this )
	} );

	// Add listeners to the eventSequencer. They won't get called until
	// eventSequencer.attach(node) has been called.
	this.eventSequencer.on( {
		keydown: this.onDocumentKeyDown.bind( this ),
		keyup: this.onDocumentKeyUp.bind( this ),
		keypress: this.onDocumentKeyPress.bind( this ),
		input: this.onDocumentInput.bind( this )
	} ).after( {
		keydown: this.afterDocumentKeyDown.bind( this )
	} );

	// Initialization
	// Add 'notranslate' class to prevent Chrome's translate feature from
	// completely messing up the CE DOM (T59124)
	this.$element.addClass( 've-ce-surface notranslate' );
	this.$highlights.addClass( 've-ce-surface-highlights' );
	this.$highlightsFocused.addClass( 've-ce-surface-highlights-focused' );
	this.$highlightsBlurred.addClass( 've-ce-surface-highlights-blurred' );
	this.$deactivatedSelection.addClass( 've-ce-surface-deactivatedSelection' );
	this.$pasteTarget
		.addClass( 've-ce-surface-paste' )
		.prop( {
			tabIndex: -1,
			contentEditable: 'true'
		} );

	// Add elements to the DOM
	this.$highlights.append( this.$dropMarker );
	this.$element.append( this.$documentNode, this.$pasteTarget );
	this.surface.$blockers.append( this.$highlights );
	this.surface.$selections.append( this.$deactivatedSelection );
};

/* Inheritance */

OO.inheritClass( ve.ce.Surface, OO.ui.Element );

OO.mixinClass( ve.ce.Surface, OO.EventEmitter );

/* Events */

/**
 * @event selectionStart
 */

/**
 * @event selectionEnd
 */

/**
 * @event relocationStart
 */

/**
 * @event relocationEnd
 */

/**
 * When the surface changes its position (only if it happens
 * after initialize has already been called).
 *
 * @event position
 */

/**
 * @event focus
 * Note that it's possible for a focus event to occur immediately after a blur event, if the focus
 * moves to or from a FocusableNode. In this case the surface doesn't lose focus conceptually, but
 * a pair of blur-focus events is emitted anyway.
 */

/**
 * @event blur
 * Note that it's possible for a focus event to occur immediately after a blur event, if the focus
 * moves to or from a FocusableNode. In this case the surface doesn't lose focus conceptually, but
 * a pair of blur-focus events is emitted anyway.
 */

/* Static properties */

/**
 * Attributes considered 'unsafe' for copy/paste
 *
 * These attributes may be dropped by the browser during copy/paste, so
 * any element containing these attributes will have them JSON encoded into
 * data-ve-attributes on copy.
 *
 * @type {string[]}
 */
ve.ce.Surface.static.unsafeAttributes = [
	// RDFa: Firefox ignores these
	'about',
	'content',
	'datatype',
	'property',
	'rel',
	'resource',
	'rev',
	'typeof',
	// CSS: Values are often added or modified
	'style'
];

/* Static methods */

/**
 * When pasting, browsers normalize HTML to varying degrees.
 * This hash creates a comparable string for validating clipboard contents.
 *
 * @param {jQuery} $elements Clipboard HTML
 * @param {Object} [beforePasteData] Paste information, including leftText and rightText to strip
 * @returns {string} Hash
 */
ve.ce.Surface.static.getClipboardHash = function ( $elements, beforePasteData ) {
	beforePasteData = beforePasteData || {};
	return $elements.text().slice(
		beforePasteData.leftText ? beforePasteData.leftText.length : 0,
		beforePasteData.rightText ? -beforePasteData.rightText.length : undefined
	)
	// Whitespace may be modified (e.g. ' ' to '&nbsp;'), so strip it all
	.replace( /\s/gm, '' );
};

/* Methods */

/**
 * Destroy the surface, removing all DOM elements.
 *
 * @method
 */
ve.ce.Surface.prototype.destroy = function () {
	var documentNode = this.documentView.getDocumentNode();

	// Detach observer and event sequencer
	this.surfaceObserver.detach();
	this.eventSequencer.detach();

	// Make document node not live
	documentNode.setLive( false );

	// Disconnect events
	this.surfaceObserver.disconnect( this );
	this.model.disconnect( this );

	// Disconnect DOM events on the document
	this.$document.off( 'focusin focusout', this.onDocumentFocusInOutHandler );
	this.$document.off( 'mousedown', this.debounceFocusChange );

	// Disconnect DOM events on the window
	this.$window.off( 'resize', this.onWindowResizeHandler );

	// HACK: Blur to make selection/cursor disappear (needed in Firefox
	// in some cases, and in iOS to hide the keyboard)
	this.$documentNode[0].blur();

	// Remove DOM elements (also disconnects their events)
	this.$element.remove();
	this.$highlights.remove();
};

/**
 * Get linear model offset from absolute coords
 *
 * @param {number} x X offset
 * @param {number} y Y offset
 * @return {number} Linear model offset, or -1 if coordinates are out of bounds
 */
ve.ce.Surface.prototype.getOffsetFromCoords = function ( x, y ) {
	var offset, caretPosition, range, textRange, $marker,
		doc = this.getElementDocument();

	try {
		if ( doc.caretPositionFromPoint ) {
			// Gecko
			// http://dev.w3.org/csswg/cssom-view/#extensions-to-the-document-interface
			caretPosition = document.caretPositionFromPoint( x, y );
			offset = ve.ce.getOffset( caretPosition.offsetNode, caretPosition.offset );
		} else if ( doc.caretRangeFromPoint ) {
			// Webkit
			// http://www.w3.org/TR/2009/WD-cssom-view-20090804/
			range = document.caretRangeFromPoint( x, y );
			offset = ve.ce.getOffset( range.startContainer, range.startOffset );
		} else if ( document.body.createTextRange ) {
			// Trident
			// http://msdn.microsoft.com/en-gb/library/ie/ms536632(v=vs.85).aspx
			textRange = document.body.createTextRange();
			textRange.moveToPoint( x, y );
			textRange.pasteHTML( '<span class="ve-ce-textRange-drop-marker">&nbsp;</span>' );
			$marker = this.$( '.ve-ce-textRange-drop-marker' );
			offset = ve.ce.getOffset( $marker.get( 0 ), 0 );
			$marker.remove();
		}
		return offset;
	} catch ( e ) {
		// Both ve.ce.getOffset and TextRange.moveToPoint can throw out of bounds exceptions
		return -1;
	}
};

/**
 * Get a client rect from the range's end node
 *
 * This function is used internally by getSelectionRects and
 * getSelectionBoundingRect as a fallback when Range.getClientRects
 * fails. The width is hard-coded to 0 as the function is used to
 * locate the selection focus position.
 *
 * @private
 * @param {Range} range Range to get client rect for
 * @return {Object} ClientRect-like object
 */
ve.ce.Surface.prototype.getNodeClientRectFromRange = function ( range ) {
	var rect, side, x, adjacentNode, unicornRect,
		node = range.endContainer;

	while ( node && node.nodeType !== Node.ELEMENT_NODE ) {
		node = node.parentNode;
	}

	if ( !node ) {
		return null;
	}

	// When possible, pretend the cursor is the left/right border of the node
	// (depending on directionality) as a fallback.

	// We would use getBoundingClientRect(), but in iOS7 that's relative to the
	// document rather than to the viewport
	rect = node.getClientRects()[0];
	if ( !rect ) {
		// FF can return null when focusNode is invisible
		return null;
	}

	side = this.getModel().getDocument().getDir() === 'rtl' ? 'right' : 'left';
	adjacentNode = range.endContainer.childNodes[ range.endOffset ];
	if ( range.collapsed && $( adjacentNode ).hasClass( 've-ce-unicorn' ) ) {
		// We're next to a unicorn; use its left/right position
		unicornRect = adjacentNode.getClientRects()[0];
		if ( !unicornRect ) {
			return null;
		}
		x = unicornRect[ side ];
	} else {
		x = rect[ side ];
	}

	return {
		top: rect.top,
		bottom: rect.bottom,
		left: x,
		right: x,
		width: 0,
		height: rect.height
	};
};

/**
 * Get the rectangles of the selection relative to the surface.
 *
 * @method
 * @param {ve.dm.Selection} [selection] Optional selection to get the rectangles for, defaults to current selection
 * @returns {Object[]|null} Selection rectangles
 */
ve.ce.Surface.prototype.getSelectionRects = function ( selection ) {
	var i, l, range, nativeRange, surfaceRect, focusedNode, rect,
		rects = [],
		relativeRects = [];

	selection = selection || this.getModel().getSelection();
	if ( !( selection instanceof ve.dm.LinearSelection ) ) {
		return null;
	}

	range = selection.getRange();
	focusedNode = this.getFocusedNode( range );

	if ( focusedNode ) {
		return focusedNode.getRects();
	}

	nativeRange = this.getNativeRange( range );
	if ( !nativeRange ) {
		return null;
	}

	// Calling getClientRects sometimes fails:
	// * in Firefox on page load when the address bar is still focused
	// * in empty paragraphs
	try {
		rects = RangeFix.getClientRects( nativeRange );
		if ( !rects.length ) {
			throw new Error( 'getClientRects returned empty list' );
		}
	} catch ( e ) {
		rect = this.getNodeClientRectFromRange( nativeRange );
		if ( rect ) {
			rects = [ rect ];
		}
	}

	surfaceRect = this.getSurface().getBoundingClientRect();
	if ( !rects || !surfaceRect ) {
		return null;
	}

	for ( i = 0, l = rects.length; i < l; i++ ) {
		relativeRects.push( ve.translateRect( rects[i], -surfaceRect.left, -surfaceRect.top ) );
	}
	return relativeRects;
};

/**
 * Get the start and end rectangles of the selection relative to the surface.
 *
 * @method
 * @param {ve.dm.Selection} [selection] Optional selection to get the rectangles for, defaults to current selection
 * @returns {Object|null} Start and end selection rectangles
 */
ve.ce.Surface.prototype.getSelectionStartAndEndRects = function ( selection ) {
	var range, focusedNode;

	selection = selection || this.getModel().getSelection();
	if ( !( selection instanceof ve.dm.LinearSelection ) ) {
		return null;
	}

	range = selection.getRange();
	focusedNode = this.getFocusedNode( range );

	if ( focusedNode ) {
		return focusedNode.getStartAndEndRects();
	}

	return ve.getStartAndEndRects( this.getSelectionRects() );
};

/**
 * Get the coordinates of the selection's bounding rectangle relative to the surface.
 *
 * Returned coordinates are relative to the surface.
 *
 * @method
 * @param {ve.dm.Selection} [selection] Optional selection to get the rectangles for, defaults to current selection
 * @returns {Object|null} Selection rectangle, with keys top, bottom, left, right, width, height
 */
ve.ce.Surface.prototype.getSelectionBoundingRect = function ( selection ) {
	var range, nativeRange, boundingRect, surfaceRect, focusedNode;

	selection = selection || this.getModel().getSelection();
	if ( !( selection instanceof ve.dm.LinearSelection ) ) {
		return null;
	}

	range = selection.getRange();
	focusedNode = this.getFocusedNode( range );

	if ( focusedNode ) {
		return focusedNode.getBoundingRect();
	}

	nativeRange = this.getNativeRange( range );
	if ( !nativeRange ) {
		return null;
	}

	try {
		boundingRect = RangeFix.getBoundingClientRect( nativeRange );
		if ( !boundingRect ) {
			throw new Error( 'getBoundingClientRect returned null' );
		}
	} catch ( e ) {
		boundingRect = this.getNodeClientRectFromRange( nativeRange );
	}

	surfaceRect = this.getSurface().getBoundingClientRect();
	if ( !boundingRect || !surfaceRect ) {
		return null;
	}
	return ve.translateRect( boundingRect, -surfaceRect.left, -surfaceRect.top );
};

/*! Initialization */

/**
 * Initialize surface.
 *
 * This should be called after the surface has been attached to the DOM.
 *
 * @method
 */
ve.ce.Surface.prototype.initialize = function () {
	this.documentView.getDocumentNode().setLive( true );
	if ( $.client.profile().layout === 'gecko' ) {
		// Turn off native object editing. This must be tried after the surface has been added to DOM.
		// This is only needed in Gecko. In other engines, these properties are off by default,
		// and turning them off again is expensive; see https://phabricator.wikimedia.org/T89928
		try {
			this.$document[0].execCommand( 'enableObjectResizing', false, false );
			this.$document[0].execCommand( 'enableInlineTableEditing', false, false );
		} catch ( e ) { /* Silently ignore */ }
	}
};

/**
 * Enable editing.
 *
 * @method
 */
ve.ce.Surface.prototype.enable = function () {
	this.documentView.getDocumentNode().enable();
	this.emit('enable');
};

/**
 * Disable editing.
 *
 * @method
 */
ve.ce.Surface.prototype.disable = function () {
	this.documentView.getDocumentNode().disable();
	this.emit('disable');
};

/**
 * Give focus to the surface, reapplying the model selection, or selecting the first content offset
 * if the model selection is null.
 *
 * This is used when switching between surfaces, e.g. when closing a dialog window. Calling this
 * function will also reapply the selection, even if the surface is already focused.
 */
ve.ce.Surface.prototype.focus = function () {
	var node,
		surface = this,
		selection = this.getModel().getSelection();

	// Focus the documentNode for text selections, or the pasteTarget for focusedNode selections
	if ( this.focusedNode || selection instanceof ve.dm.TableSelection ) {
		this.$pasteTarget[0].focus();
	} else if ( selection instanceof ve.dm.LinearSelection ) {
		node = this.getDocument().getNodeAndOffset( selection.getRange().start ).node;
		$( node ).closest( '[contenteditable=true]' )[0].focus();
	} else if ( selection instanceof ve.dm.NullSelection ) {
		this.getModel().selectFirstContentOffset();
		return;
	}

	// If we are calling focus after replacing a node the selection may be gone
	// but onDocumentFocus won't fire so restore the selection here too.
	this.onModelSelect();
	setTimeout( function () {
		// In some browsers (e.g. Chrome) giving the document node focus doesn't
		// necessarily give you a selection (e.g. if the first child is a <figure>)
		// so if the surface isn't 'focused' (has no selection) give it a selection
		// manually
		// TODO: rename isFocused and other methods to something which reflects
		// the fact they actually mean "has a native selection"
		if ( !surface.isFocused() ) {
			surface.getModel().selectFirstContentOffset();
		}
	} );
	// onDocumentFocus takes care of the rest
};

/**
 * Handler for focusin and focusout events. Filters events and debounces to #onFocusChange.
 * @param {jQuery.Event} e focusin/out event
 */
ve.ce.Surface.prototype.onDocumentFocusInOut = function ( e ) {
	// Filter out focusin/out events on iframes
	// IE11 emits these when the focus moves into/out of an iframed document,
	// but these events are misleading because the focus in this document didn't
	// actually move.
	if ( e.target.nodeName.toLowerCase() === 'iframe' ) {
		return;
	}
	this.debounceFocusChange();
};

/**
 * Handle global focus change.
 */
ve.ce.Surface.prototype.onFocusChange = function () {
	var hasFocus = false;

	hasFocus = OO.ui.contains(
		[
			this.$documentNode[0],
			this.$pasteTarget[0]
		],
		this.nativeSelection.anchorNode,
		true
	);

	if ( this.deactivated ) {
		if ( OO.ui.contains( this.$documentNode[0], this.nativeSelection.anchorNode, true ) ) {
			this.onDocumentFocus();
		}
	} else {
		if ( hasFocus && !this.isFocused() ) {
			this.onDocumentFocus();
		}
		if ( !hasFocus && this.isFocused() ) {
			this.onDocumentBlur();
		}
	}
};

/**
 * Deactivate the surface, stopping the surface observer and replacing the native
 * range with a fake rendered one.
 *
 * Used by dialogs so they can take focus without losing the original document selection.
 */
ve.ce.Surface.prototype.deactivate = function () {
	if ( !this.deactivated ) {
		// Disable the surface observer, there can be no observeable changes
		// until the surface is activated
		this.surfaceObserver.disable();
		this.deactivated = true;
		// Remove ranges so the user can't accidentally type into the document
		this.nativeSelection.removeAllRanges();
		this.updateDeactivatedSelection();
	}
};

/**
 * Reactivate the surface and restore the native selection
 */
ve.ce.Surface.prototype.activate = function () {
	if ( this.deactivated ) {
		this.deactivated = false;
		this.updateDeactivatedSelection();
		this.surfaceObserver.enable();
		if ( OO.ui.contains( this.$documentNode[0], this.nativeSelection.anchorNode, true ) ) {
			// The selection has been placed back in the document, either by the user clicking
			// or by the closing window updating the model. Poll in case it was the user clicking.
			this.surfaceObserver.clear();
			this.surfaceObserver.pollOnce();
		} else {
			// Clear focused node so onModelSelect re-selects it if necessary
			this.focusedNode = null;
			this.onModelSelect();
		}
	}
};

/**
 * Update the fake selection while the surface is deactivated.
 *
 * While the surface is deactivated, all calls to showSelection will get redirected here.
 */
ve.ce.Surface.prototype.updateDeactivatedSelection = function () {
	var i, l, rects,
		selection = this.getModel().getSelection();

	this.$deactivatedSelection.empty();

	if (
		!this.deactivated || this.focusedNode ||
		!( selection instanceof ve.dm.LinearSelection ) ||
		selection.isCollapsed()
	) {
		return;
	}
	rects = this.getSelectionRects( selection );
	if ( rects ) {
		for ( i = 0, l = rects.length; i < l; i++ ) {
			this.$deactivatedSelection.append( this.$( '<div>' ).css( {
				top: rects[i].top,
				left: rects[i].left,
				width: rects[i].width,
				height: rects[i].height
			} ) );
		}
	}
};

/**
 * Handle document focus events.
 *
 * This is triggered by a global focusin/focusout event noticing a selection on the document.
 *
 * @method
 * @fires focus
 */
ve.ce.Surface.prototype.onDocumentFocus = function () {
	if ( this.getModel().getSelection().isNull() ) {
		// If the document is being focused by a non-mouse/non-touch user event,
		// find the first content offset and place the cursor there.
		this.getModel().selectFirstContentOffset();
	}
	this.eventSequencer.attach( this.$element );
	this.surfaceObserver.startTimerLoop();
	this.focused = true;
	this.activate();
	this.emit( 'focus' );
};

/**
 * Handle document blur events.
 *
 * This is triggered by a global focusin/focusout event noticing no selection on the document.
 *
 * @method
 * @fires blur
 */
ve.ce.Surface.prototype.onDocumentBlur = function () {
	this.eventSequencer.detach();
	this.surfaceObserver.stopTimerLoop();
	this.surfaceObserver.pollOnce();
	this.surfaceObserver.clear();
	this.dragging = false;
	this.focused = false;
	if ( this.focusedNode ) {
		this.focusedNode.setFocused( false );
		this.focusedNode = null;
	}
	this.getModel().setNullSelection();
	this.emit( 'blur' );
};

/**
 * Check if surface is focused.
 *
 * @returns {boolean} Surface is focused
 */
ve.ce.Surface.prototype.isFocused = function () {
	return this.focused;
};

/**
 * Handle document mouse down events.
 *
 * @method
 * @param {jQuery.Event} e Mouse down event
 */
ve.ce.Surface.prototype.onDocumentMouseDown = function ( e ) {
	var newFragment;
	if ( e.which !== 1 ) {
		return;
	}

	// Remember the mouse is down
	this.dragging = true;

	// Bind mouseup to the whole document in case of dragging out of the surface
	this.$document.on( 'mouseup', this.onDocumentMouseUpHandler );

	this.surfaceObserver.stopTimerLoop();
	// In some browsers the selection doesn't change until after the event
	// so poll in the 'after' function
	setTimeout( this.afterDocumentMouseDown.bind( this, e, this.getModel().getSelection() ) );

	// Handle triple click
	// HACK: do not do triple click handling in IE, because their click counting is broken
	if ( e.originalEvent.detail >= 3 && !ve.init.platform.constructor.static.isInternetExplorer() ) {
		// Browser default behaviour for triple click won't behave as we want
		e.preventDefault();

		newFragment = this.getModel().getFragment()
			// After double-clicking in an inline slug, we'll get a selection like
			// <p><span><img />|</span></p><p>|Foo</p>. This selection spans a CBN boundary,
			// so we can't expand to the nearest CBN. To handle this case and other possible
			// cases where the selection spans a CBN boundary, collapse the selection before
			// expanding it. If the selection is entirely within the same CBN as it should be,
			// this won't change the result.
			.collapseToStart()
			// Cover the CBN we're in
			.expandLinearSelection( 'closest', ve.dm.ContentBranchNode )
			// ...but that covered the entire CBN, we only want the contents
			.adjustLinearSelection( 1, -1 );
		// If something weird happened (e.g. no CBN found), newFragment will be null.
		// Don't select it in that case, because that'll blur the surface.
		if ( !newFragment.isNull() ) {
			newFragment.select();
		}
	}
};

/**
 * Deferred until after document mouse down
 *
 * @param {jQuery.Event} e Mouse down event
 * @param {ve.dm.Selection} selectionBefore Selection before the mouse event
 */
ve.ce.Surface.prototype.afterDocumentMouseDown = function ( e, selectionBefore ) {
	// TODO: guard with incRenderLock?
	this.surfaceObserver.pollOnce();
	if ( e.shiftKey ) {
		this.fixShiftClickSelect( selectionBefore );
	}
};

/**
 * Handle document mouse up events.
 *
 * @method
 * @param {jQuery.Event} e Mouse up event
 * @fires selectionEnd
 */
ve.ce.Surface.prototype.onDocumentMouseUp = function ( e ) {
	this.$document.off( 'mouseup', this.onDocumentMouseUpHandler );
	this.surfaceObserver.startTimerLoop();
	// In some browsers the selection doesn't change until after the event
	// so poll in the 'after' function
	setTimeout( this.afterDocumentMouseUp.bind( this, e, this.getModel().getSelection() ) );
};

/**
 * Deferred until after document mouse up
 *
 * @param {jQuery.Event} e Mouse up event
 * @param {ve.dm.Selection} selectionBefore Selection before the mouse event
 */
ve.ce.Surface.prototype.afterDocumentMouseUp = function ( e, selectionBefore ) {
	// TODO: guard with incRenderLock?
	this.surfaceObserver.pollOnce();
	if ( e.shiftKey ) {
		this.fixShiftClickSelect( selectionBefore );
	}
	if ( !e.shiftKey && this.selecting ) {
		this.emit( 'selectionEnd' );
		this.selecting = false;
	}
	this.dragging = false;
};

/**
 * Fix shift-click selection
 *
 * When shift-clicking on links Chrome tries to collapse the selection
 * so check for this and fix manually.
 *
 * This can occur on mousedown or, if the existing selection covers the
 * link, on mouseup.
 *
 * https://code.google.com/p/chromium/issues/detail?id=345745
 *
 * @param {ve.dm.Selection} selectionBefore Selection before the mouse event
 */
ve.ce.Surface.prototype.fixShiftClickSelect = function ( selectionBefore ) {
	if ( !( selectionBefore instanceof ve.dm.LinearSelection ) ) {
		return;
	}
	var newSelection = this.getModel().getSelection();
	if ( newSelection.isCollapsed() && !newSelection.equals( selectionBefore ) ) {
		this.getModel().setLinearSelection( new ve.Range( selectionBefore.getRange().from, newSelection.getRange().to ) );
	}
};

/**
 * Handle document mouse move events.
 *
 * @method
 * @param {jQuery.Event} e Mouse move event
 * @fires selectionStart
 */
ve.ce.Surface.prototype.onDocumentMouseMove = function () {
	// Detect beginning of selection by moving mouse while dragging
	if ( this.dragging && !this.selecting ) {
		this.selecting = true;
		this.emit( 'selectionStart' );
	}
};

/**
 * Handle document selection change events.
 *
 * @method
 * @param {jQuery.Event} e Selection change event
 */
ve.ce.Surface.prototype.onDocumentSelectionChange = function () {
	if ( !this.dragging ) {
		// Optimisation
		return;
	}

	this.surfaceObserver.pollOnceSelection();
};

/**
 * Handle document drag start events.
 *
 * @method
 * @param {jQuery.Event} e Drag start event
 */
ve.ce.Surface.prototype.onDocumentDragStart = function ( e ) {
	var dataTransfer = e.originalEvent.dataTransfer;
	try {
		dataTransfer.setData( 'application-x/VisualEditor', JSON.stringify( this.getModel().getSelection() ) );
	} catch ( err ) {
		// IE doesn't support custom data types, but overwriting the actual drag data should be avoided
		// TODO: Do this with an internal state to avoid overwriting drag data even in IE
		dataTransfer.setData( 'text', '__ve__' + JSON.stringify( this.getModel().getSelection() ) );
	}
};

/**
 * Handle document drag over events.
 *
 * @method
 * @param {jQuery.Event} e Drag over event
 */
ve.ce.Surface.prototype.onDocumentDragOver = function ( e ) {
	if ( !this.relocatingNode ) {
		return;
	}
	var $target, $dropTarget, node, dropPosition, targetPosition, top, left,
		nodeType, inIgnoreChildren;

	if ( !this.relocatingNode.isContent() ) {
		e.preventDefault();
		$target = $( e.target ).closest( '.ve-ce-branchNode, .ve-ce-leafNode' );
		if ( $target.length ) {
			// Find the nearest node which will accept this node type
			nodeType = this.relocatingNode.getType();
			node = $target.data( 'view' );
			while ( node.parent && !node.parent.isAllowedChildNodeType( nodeType ) ) {
				node = node.parent;
			}
			if ( node.parent ) {
				inIgnoreChildren = false;
				node.parent.traverseUpstream( function ( n ) {
					if ( n.shouldIgnoreChildren() ) {
						inIgnoreChildren = true;
						return false;
					}
				} );
			}
			if ( node.parent && !inIgnoreChildren ) {
				$dropTarget = node.$element;
				dropPosition = e.originalEvent.pageY - $dropTarget.offset().top > $dropTarget.outerHeight() / 2 ? 'bottom' : 'top';
			} else {
				$dropTarget = this.$lastDropTarget;
				dropPosition = this.lastDropPosition;
			}
		}
		if ( this.$lastDropTarget && (
			!this.$lastDropTarget.is( $dropTarget ) || dropPosition !== this.lastDropPosition
		) ) {
			this.$dropMarker.addClass( 'oo-ui-element-hidden' );
			$dropTarget = null;
		}
		if ( $dropTarget && (
			!$dropTarget.is( this.$lastDropTarget ) || dropPosition !== this.lastDropPosition
		) ) {
			targetPosition = $dropTarget.position();
			// Go beyond margins as they can overlap
			top = targetPosition.top + parseFloat( $dropTarget.css( 'margin-top' ) );
			left = targetPosition.left + parseFloat( $dropTarget.css( 'margin-left' ) );
			if ( dropPosition === 'bottom' ) {
				top += $dropTarget.outerHeight();
			}
			this.$dropMarker
				.css( {
					top: top,
					left: left
				} )
				.width( $dropTarget.outerWidth() )
				.removeClass( 'oo-ui-element-hidden' );
		}
		if ( $dropTarget !== undefined ) {
			this.$lastDropTarget = $dropTarget;
			this.lastDropPosition = dropPosition;
		}
	}
	if ( this.selecting ) {
		this.emit( 'selectionEnd' );
		this.selecting = false;
		this.dragging = false;
	}
};

/**
 * Handle document drop events.
 *
 * Limits native drag and drop behaviour.
 *
 * @method
 * @param {jQuery.Event} e Drop event
 */
ve.ce.Surface.prototype.onDocumentDrop = function ( e ) {
	// Properties may be nullified by other events, so cache before setTimeout
	var selectionJSON, dragSelection, dragRange, originFragment, originData,
		targetRange, targetOffset, targetFragment,
		dataTransfer = e.originalEvent.dataTransfer,
		$dropTarget = this.$lastDropTarget,
		dropPosition = this.lastDropPosition;

	// Prevent native drop event from modifying view
	e.preventDefault();

	// Determine drop position
	if ( this.relocatingNode && !this.relocatingNode.getModel().isContent() ) {
		// Block level drag and drop: use the lastDropTarget to get the targetOffset
		if ( $dropTarget ) {
			targetRange = $dropTarget.data( 'view' ).getModel().getOuterRange();
			if ( dropPosition === 'top' ) {
				targetOffset = targetRange.start;
			} else {
				targetOffset = targetRange.end;
			}
		} else {
			return;
		}
	} else {
		targetOffset = this.getOffsetFromCoords(
			e.originalEvent.pageX - this.$document.scrollLeft(),
			e.originalEvent.pageY - this.$document.scrollTop()
		);
		if ( targetOffset === -1 ) {
			return;
		}
	}
	targetFragment = this.getModel().getLinearFragment( new ve.Range( targetOffset ) );

	// Get source range from drag data
	try {
		selectionJSON = dataTransfer.getData( 'application-x/VisualEditor' );
	} catch ( err ) {
		selectionJSON = dataTransfer.getData( 'text' );
		if ( selectionJSON.slice( 0, 6 ) === '__ve__' ) {
			selectionJSON = selectionJSON.slice( 6 );
		} else {
			selectionJSON = null;
		}
	}
	if ( this.relocatingNode ) {
		dragRange = this.relocatingNode.getModel().getOuterRange();
	} else if ( selectionJSON ) {
		dragSelection = ve.dm.Selection.static.newFromJSON( this.getModel().getDocument(), selectionJSON );
		if ( dragSelection instanceof ve.dm.LinearSelection ) {
			dragRange = dragSelection.getRange();
		}
	}

	// Internal drop
	if ( dragRange ) {
		// Get a fragment and data of the node being dragged
		originFragment = this.getModel().getLinearFragment( dragRange );
		originData = originFragment.getData();

		// Remove node from old location
		originFragment.removeContent();

		// Re-insert data at new location
		targetFragment.insertContent( originData );
	} else {
		// External drop
		this.handleDataTransfer( dataTransfer, false, targetFragment );
	}
	this.endRelocation();
};

/**
 * Handle document key down events.
 *
 * @method
 * @param {jQuery.Event} e Key down event
 * @fires selectionStart
 */
ve.ce.Surface.prototype.onDocumentKeyDown = function ( e ) {
	var trigger, focusedNode,
		selection = this.getModel().getSelection(),
		updateFromModel = false;

	if ( selection instanceof ve.dm.NullSelection ) {
		return;
	}

	if ( e.which === 229 ) {
		// Ignore fake IME events (emitted in IE and Chromium)
		return;
	}

	this.surfaceObserver.stopTimerLoop();
	this.incRenderLock();
	try {
		// TODO: is this correct?
		this.surfaceObserver.pollOnce();
	} finally {
		this.decRenderLock();
	}

	this.storeKeyDownState( e );

	switch ( e.keyCode ) {
		case OO.ui.Keys.LEFT:
		case OO.ui.Keys.RIGHT:
		case OO.ui.Keys.UP:
		case OO.ui.Keys.DOWN:
			if ( !this.dragging && !this.selecting && e.shiftKey ) {
				this.selecting = true;
				this.emit( 'selectionStart' );
			}

			if ( selection instanceof ve.dm.LinearSelection ) {
				this.handleLinearArrowKey( e );
				updateFromModel = true;
			} else if ( selection instanceof ve.dm.TableSelection ) {
				this.handleTableArrowKey( e );
			}
			break;
		case OO.ui.Keys.END:
		case OO.ui.Keys.HOME:
		case OO.ui.Keys.PAGEUP:
		case OO.ui.Keys.PAGEDOWN:
			if ( selection instanceof ve.dm.TableSelection ) {
				this.handleTableArrowKey( e );
			}
			break;
		case OO.ui.Keys.ENTER:
			e.preventDefault();
			focusedNode = this.getFocusedNode();
			if ( focusedNode ) {
				focusedNode.executeCommand();
			} else if ( selection instanceof ve.dm.LinearSelection ) {
				this.handleLinearEnter( e );
				updateFromModel = true;
			} else if ( selection instanceof ve.dm.TableSelection ) {
				this.handleTableEnter( e );
			}
			break;
		case OO.ui.Keys.BACKSPACE:
		case OO.ui.Keys.DELETE:
			if ( selection instanceof ve.dm.LinearSelection ) {
				if ( this.handleLinearDelete( e ) ) {
					e.preventDefault();
				}
				updateFromModel = true;
			} else if ( selection instanceof ve.dm.TableSelection ) {
				e.preventDefault();
				this.handleTableDelete( e );
			}
			break;
		case OO.ui.Keys.ESCAPE:
			if ( this.getActiveTableNode() ) {
				this.handleTableEditingEscape( e );
			}
			break;
		default:
			trigger = new ve.ui.Trigger( e );
			if ( trigger.isComplete() && this.surface.execute( trigger ) ) {
				e.preventDefault();
				e.stopPropagation();
				updateFromModel = true;
			}
			break;
	}
	if ( !updateFromModel ) {
		this.incRenderLock();
	}
	try {
		this.surfaceObserver.pollOnce();
	} finally {
		if ( !updateFromModel ) {
			this.decRenderLock();
		}
	}
	this.surfaceObserver.startTimerLoop();
};

/**
 * Handle document key press events.
 *
 * @method
 * @param {jQuery.Event} e Key press event
 */
ve.ce.Surface.prototype.onDocumentKeyPress = function ( e ) {
	// Filter out non-character keys. Doing this prevents:
	// * Unexpected content deletion when selection is not collapsed and the user presses, for
	//   example, the Home key (Firefox fires 'keypress' for it)
	// TODO: Should be covered with Selenium tests.
	if (
		// Catches most keys that don't produce output (charCode === 0, thus no character)
		e.which === 0 || e.charCode === 0 ||
		// Opera 12 doesn't always adhere to that convention
		e.keyCode === OO.ui.Keys.TAB || e.keyCode === OO.ui.Keys.ESCAPE ||
		// Ignore all keypresses with Ctrl / Cmd modifier keys
		ve.ce.isShortcutKey( e )
	) {
		return;
	}

	this.handleInsertion();
};

/**
 * Deferred until after document key down event
 *
 * @param {jQuery.Event} e keydown event
 */
ve.ce.Surface.prototype.afterDocumentKeyDown = function ( e ) {
	var direction, focusableNode, startOffset, endOffset, offsetDiff, dmFocus, dmSelection,
		ceNode, range, fixupCursorForUnicorn, matrix,
		surface = this,
		isArrow = (
			e.keyCode === OO.ui.Keys.UP ||
			e.keyCode === OO.ui.Keys.DOWN ||
			e.keyCode === OO.ui.Keys.LEFT ||
			e.keyCode === OO.ui.Keys.RIGHT
		);

	/**
	 * Determine whether a position is editable, and if so which focusable node it is in
	 *
	 * We can land inside ce=false in many browsers:
	 * - Firefox has normal cursor positions at most node boundaries inside ce=false
	 * - Chromium has superfluous cursor positions around a ce=false img
	 * - IE hardly restricts editing at all inside ce=false
	 * If ce=false then we have landed inside the focusable node.
	 * If we land in a non-text position, assume we should have hit the node
	 * immediately after the position we hit (in the direction of motion)

	 * @private
	 * @param {Node} DOM node of cursor position
	 * @param {number} offset Offset of cursor position
	 * @param {number} direction Cursor motion direction (1=forward, -1=backward)
	 * @returns {ve.ce.Node|null} node, or null if not in a focusable node
	 */
	function getSurroundingFocusableNode( node, offset, direction ) {
		var focusNode;
		if ( node.nodeType === Node.TEXT_NODE ) {
			focusNode = node;
		} else if ( direction > 0 && offset < node.childNodes.length ) {
			focusNode = node.childNodes[ offset ];
		} else if ( direction < 0 && offset > 0 ) {
			focusNode = node.childNodes[ offset - 1 ];
		} else {
			focusNode = node;
		}
		return $( focusNode ).closest( '.ve-ce-focusableNode, .ve-ce-tableNode:not(.ve-ce-tableNode-editing)' ).data( 'view' ) || null;
	}

	/**
	 * Compute the direction of cursor movement, if any
	 *
	 * Even if the user pressed a cursor key in the interior of the document, there may not
	 * be any movement: browser BIDI and ce=false handling can be quite quirky
	 *
	 * @returns {number|null} -1 for startwards, 1 for endwards, null for none
	 */
	function getDirection() {
		return (
			isArrow &&
			surface.misleadingCursorStartSelection.focusNode &&
			surface.nativeSelection.focusNode &&
			ve.compareDocumentOrder(
				surface.nativeSelection.focusNode,
				surface.nativeSelection.focusOffset,
				surface.misleadingCursorStartSelection.focusNode,
				surface.misleadingCursorStartSelection.focusOffset
			)
		) || null;
	}

	if (
		( e.keyCode === OO.ui.Keys.BACKSPACE || e.keyCode === OO.ui.Keys.DELETE ) &&
		this.nativeSelection.focusNode &&
		this.nativeSelection.focusNode.nodeType === Node.ELEMENT_NODE &&
		!this.nativeSelection.focusNode.classList.contains( 've-ce-branchNode-inlineSlug' )
	) {
		// In a non-slug element. Sync the DM, then see if we need a slug.
		this.incRenderLock();
		try {
			this.surfaceObserver.pollOnce();
		} finally {
			this.decRenderLock();
		}

		dmSelection = surface.model.getSelection();
		if ( dmSelection instanceof ve.dm.LinearSelection ) {
			dmFocus = dmSelection.getRange().end;
			ceNode = this.documentView.getBranchNodeFromOffset( dmFocus );
			if ( ceNode && ceNode.getModel().hasSlugAtOffset( dmFocus ) ) {
				ceNode.setupBlockSlugs();
			}
		}
		return;
	}

	if ( e !== this.cursorEvent ) {
		return;
	}

	// Restore the selection and stop, if we cursored out of a table edit cell.
	// Assumption: if we cursored out of a table cell, then none of the fixups below this point
	// would have got the selection back inside the cell. Therefore it's OK to check here.
	if ( isArrow && this.restoreActiveTableNodeSelection() ) {
		return;
	}

	// If we arrowed a collapsed cursor across a focusable node, select the node instead
	if (
		isArrow &&
		!e.ctrlKey &&
		!e.altKey &&
		!e.metaKey &&
		this.misleadingCursorStartSelection.isCollapsed &&
		this.nativeSelection.isCollapsed &&
		( direction = getDirection() ) !== null
	) {
		focusableNode = getSurroundingFocusableNode(
			this.nativeSelection.focusNode,
			this.nativeSelection.focusOffset,
			direction
		);

		if ( !focusableNode ) {
			// Calculate the DM offsets of our motion
			try {
				startOffset = ve.ce.getOffset(
					this.misleadingCursorStartSelection.focusNode,
					this.misleadingCursorStartSelection.focusOffset
				);
				endOffset = ve.ce.getOffset(
					this.nativeSelection.focusNode,
					this.nativeSelection.focusOffset
				);
				offsetDiff = endOffset - startOffset;
			} catch ( ex ) {
				startOffset = endOffset = offsetDiff = undefined;
			}

			if ( Math.abs( offsetDiff ) === 2 ) {
				// Test whether we crossed a focusable node
				// (this applies even if we cursored up/down)
				focusableNode = (
					this.model.documentModel.documentNode
					.getNodeFromOffset( ( startOffset + endOffset ) / 2 )
				);

				if ( focusableNode.isFocusable() ) {
					range = new ve.Range( startOffset, endOffset );
				} else {
					focusableNode = undefined;
				}
			}
		}

		if ( focusableNode ) {
			if ( !range ) {
				range = focusableNode.getOuterRange();
				if ( direction < 0 ) {
					range = range.flip();
				}
			}
			if ( focusableNode instanceof ve.ce.TableNode ) {
				if ( direction > 0 ) {
					this.model.setSelection( new ve.dm.TableSelection(
						this.model.documentModel, range, 0, 0
					) );
				} else {
					matrix = focusableNode.getModel().getMatrix();
					this.model.setSelection( new ve.dm.TableSelection(
						this.model.documentModel, range, matrix.getColCount() - 1, matrix.getRowCount() - 1
					) );
				}
			} else {
				this.model.setLinearSelection( range );
			}
			if ( e.keyCode === OO.ui.Keys.LEFT ) {
				this.cursorDirectionality = direction > 0 ? 'rtl' : 'ltr';
			} else if ( e.keyCode === OO.ui.Keys.RIGHT ) {
				this.cursorDirectionality = direction < 0 ? 'rtl' : 'ltr';
			}
			// else up/down pressed; leave this.cursorDirectionality as null
			// (it was set by setLinearSelection calling onModelSelect)
		}
	}

	fixupCursorForUnicorn = (
		!e.shiftKey &&
		( e.keyCode === OO.ui.Keys.LEFT || e.keyCode === OO.ui.Keys.RIGHT )
	);
	this.incRenderLock();
	try {
		this.surfaceObserver.pollOnce();
	} finally {
		this.decRenderLock();
	}
	this.checkUnicorns( fixupCursorForUnicorn );
};

/**
 * Check whether the selection has moved out of the unicorned area (i.e. is not currently between
 * two unicorns) and if so, destroy the unicorns. If there are no active unicorns, this function
 * does nothing.
 *
 * If the unicorns are destroyed as a consequence of the user moving the cursor across a unicorn
 * with the arrow keys, the cursor will have to be moved again to produce the cursor movement
 * the user expected. Set the fixupCursor parameter to true to enable this behavior.
 *
 * @param {boolean} fixupCursor If destroying unicorns, fix the cursor position for expected movement
 */
ve.ce.Surface.prototype.checkUnicorns = function ( fixupCursor ) {
	var preUnicorn, postUnicorn, range, node, fixup;
	if ( !this.unicorningNode || !this.unicorningNode.unicorns ) {
		return;
	}
	preUnicorn = this.unicorningNode.unicorns[ 0 ];
	postUnicorn = this.unicorningNode.unicorns[ 1 ];

	if ( this.nativeSelection.rangeCount === 0 ) {
		// XXX do we want to clear unicorns in this case?
		return;
	}
	range = this.nativeSelection.getRangeAt( 0 );

	// Test whether the selection endpoint is between unicorns. If so, do nothing.
	// Unicorns can only contain text, so just move backwards until we hit a non-text node.
	node = range.endContainer;
	if ( node.nodeType === Node.ELEMENT_NODE ) {
		node = range.endOffset > 0 ? node.childNodes[ range.endOffset - 1 ] : null;
	}
	while ( node !== null && node.nodeType === Node.TEXT_NODE ) {
		node = node.previousSibling;
	}
	if ( node === preUnicorn ) {
		return;
	}

	// Selection endpoint is not between unicorns.
	// Test whether it is before or after the pre-unicorn (i.e. before/after both unicorns)
	if ( ve.compareDocumentOrder(
		range.endContainer,
		range.endOffset,
		preUnicorn.parentNode,
		Array.prototype.indexOf.call( preUnicorn.parentNode.childNodes, preUnicorn )
	) < 0 ) {
		// before the pre-unicorn
		fixup = -1;
	} else {
		// at or after the pre-unicorn (actually must be after the post-unicorn)
		fixup = 1;
	}
	if ( fixupCursor ) {
		this.incRenderLock();
		try {
			this.moveModelCursor( fixup );
		} finally {
			this.decRenderLock();
		}
	}
	this.renderSelectedContentBranchNode();
	this.showSelection( this.getModel().getSelection() );
};

/**
 * Handle document key up events.
 *
 * @method
 * @param {jQuery.Event} e Key up event
 * @fires selectionEnd
 */
ve.ce.Surface.prototype.onDocumentKeyUp = function ( e ) {
	// Detect end of selecting by letting go of shift
	if ( !this.dragging && this.selecting && e.keyCode === OO.ui.Keys.SHIFT ) {
		this.selecting = false;
		this.emit( 'selectionEnd' );
	}

	var nativeRange, clientRect, scrollTo;

	if ( !this.surface.toolbarHeight ) {
		return;
	}

	nativeRange = this.getNativeRange();
	if ( !nativeRange ) {
		return null;
	}

	clientRect = RangeFix.getBoundingClientRect( nativeRange );

	if ( clientRect && clientRect.top < this.surface.toolbarHeight ) {
		scrollTo = this.getScrollPosition() + clientRect.top - this.surface.toolbarHeight;
		this.setScrollPosition( scrollTo );
	}
};

/**
 * Handle cut events.
 *
 * @method
 * @param {jQuery.Event} e Cut event
 */
ve.ce.Surface.prototype.onCut = function ( e ) {
	var surface = this;
	this.onCopy( e );
	setTimeout( function () {
		surface.getModel().getFragment().delete().select();
	} );
};

/**
 * Handle copy events.
 *
 * @method
 * @param {jQuery.Event} e Copy event
 */
ve.ce.Surface.prototype.onCopy = function ( e ) {
	var originalRange,
		clipboardIndex, clipboardItem, pasteData,
		scrollTop, unsafeSelector, range, slice,
		selection = this.getModel().getSelection(),
		view = this,
		htmlDoc = this.getModel().getDocument().getHtmlDocument(),
		clipboardData = e.originalEvent.clipboardData;

	this.$pasteTarget.empty();

	if ( selection instanceof ve.dm.LinearSelection ||
		( selection instanceof ve.dm.TableSelection && selection.isSingleCell() )
	) {
		range = selection.getRanges()[0];
	} else {
		return;
	}

	slice = this.model.documentModel.cloneSliceFromRange( range );

	pasteData = slice.data.clone();

	// Clone the elements in the slice
	slice.data.cloneElements( true );

	ve.dm.converter.getDomSubtreeFromModel( slice, this.$pasteTarget[0], true );

	// Some browsers strip out spans when they match the styling of the
	// paste target (e.g. plain spans) so we must protect against this
	// by adding a dummy class, which we can remove after paste.
	this.$pasteTarget.find( 'span' ).addClass( 've-pasteProtect' );

	// href absolutization either doesn't occur (because we copy HTML to the clipboard
	// directly with clipboardData#setData) or it resolves against the wrong document
	// (window.document instead of ve.dm.Document#getHtmlDocument) so do it manually
	// with ve#resolveUrl
	this.$pasteTarget.find( 'a' ).attr( 'href', function ( i, href ) {
		return ve.resolveUrl( href, htmlDoc );
	} );

	// Some attributes (e.g RDFa attributes in Firefox) aren't preserved by copy
	unsafeSelector = '[' + ve.ce.Surface.static.unsafeAttributes.join( '],[') + ']';
	this.$pasteTarget.find( unsafeSelector ).each( function () {
		var i, val,
			attrs = {},
			ua = ve.ce.Surface.static.unsafeAttributes;

		i = ua.length;
		while ( i-- ) {
			val = this.getAttribute( ua[i] );
			if ( val !== null ) {
				attrs[ua[i]] = val;
			}
		}
		this.setAttribute( 'data-ve-attributes', JSON.stringify( attrs ) );
	} );

	clipboardItem = { slice: slice, hash: null };
	clipboardIndex = this.clipboard.push( clipboardItem ) - 1;

	// Check we have a W3C clipboardData API
	if (
		clipboardData && clipboardData.items
	) {
		// Webkit allows us to directly edit the clipboard
		// Disable the default event so we can override the data
		e.preventDefault();

		clipboardData.setData( 'text/xcustom', this.clipboardId + '-' + clipboardIndex );
		// As we've disabled the default event we need to set the normal clipboard data
		// It is apparently impossible to set text/xcustom without setting the other
		// types manually too.
		clipboardData.setData( 'text/html', this.$pasteTarget.html() );
		clipboardData.setData( 'text/plain', this.$pasteTarget.text() );
	} else {
		clipboardItem.hash = this.constructor.static.getClipboardHash( this.$pasteTarget.contents() );
		this.$pasteTarget.prepend(
			this.$( '<span>' ).attr( 'data-ve-clipboard-key', this.clipboardId + '-' + clipboardIndex ).html( '&nbsp;' )
		);

		// If direct clipboard editing is not allowed, we must use the pasteTarget to
		// select the data we want to go in the clipboard

		// If we have a range in the document, preserve it so it can restored
		originalRange = this.getNativeRange();
		if ( originalRange ) {
			// Save scroll position before changing focus to "offscreen" paste target
			scrollTop = this.getScrollPosition();

			// Prevent surface observation due to native range changing
			this.surfaceObserver.disable();
			ve.selectElement( this.$pasteTarget[0] );

			// Restore scroll position after changing focus
			this.setScrollPosition( scrollTop );

			setTimeout( function () {
				// Change focus back
				view.$documentNode[0].focus();
				view.nativeSelection.removeAllRanges();
				view.nativeSelection.addRange( originalRange.cloneRange() );
				// Restore scroll position
				view.setScrollPosition( scrollTop );
				view.surfaceObserver.clear();
				view.surfaceObserver.enable();
			} );
		} else {
			// If nativeRange is null, the pasteTarget *should* already be selected...
			ve.selectElement( this.$pasteTarget[0] );
		}
	}
};

/**
 * Handle native paste event
 *
 * @param {jQuery.Event} e Paste event
 */
ve.ce.Surface.prototype.onPaste = function ( e ) {
	var surface = this;
	// Prevent pasting until after we are done
	if ( this.pasting ) {
		return false;
	}
	this.beforePaste( e );
	this.surfaceObserver.disable();
	this.pasting = true;
	setTimeout( function () {
		try {
			if ( !e.isDefaultPrevented() ) {
				surface.afterPaste( e );
			}
		} finally {
			surface.surfaceObserver.clear();
			surface.surfaceObserver.enable();

			// Allow pasting again
			surface.pasting = false;
			surface.pasteSpecial = false;
			surface.beforePasteData = null;
		}
	} );
};

/**
 * Handle pre-paste events.
 *
 * @param {jQuery.Event} e Paste event
 */
ve.ce.Surface.prototype.beforePaste = function ( e ) {
	var tx, range, node, nodeRange, contextElement, nativeRange,
		context, leftText, rightText, textNode, textStart, textEnd,
		selection = this.getModel().getSelection(),
		clipboardData = e.originalEvent.clipboardData,
		doc = this.getModel().getDocument(),
		nodeFactory = doc.getNodeFactory();

	if ( selection instanceof ve.dm.LinearSelection ||
		( selection instanceof ve.dm.TableSelection && selection.isSingleCell() )
	) {
		range = selection.getRanges()[0];
	} else {
		e.preventDefault();
		return;
	}

	this.beforePasteData = {};
	if ( clipboardData ) {
		if ( this.handleDataTransfer( clipboardData, true ) ) {
			e.preventDefault();
			return;
		}
		this.beforePasteData.custom = clipboardData.getData( 'text/xcustom' );
		this.beforePasteData.html = clipboardData.getData( 'text/html' );
		if ( this.beforePasteData.html ) {
			// http://msdn.microsoft.com/en-US/en-%20us/library/ms649015(VS.85).aspx
			this.beforePasteData.html = this.beforePasteData.html
				.replace( /^[\s\S]*<!-- *StartFragment *-->/, '' )
				.replace( /<!-- *EndFragment *-->[\s\S]*$/, '' );
		}
	}

	// Pasting into a range? Remove first.
	if ( !range.isCollapsed() ) {
		tx = ve.dm.Transaction.newFromRemoval( doc, range );
		selection = selection.translateByTransaction( tx );
		this.model.change( tx, selection );
		range = selection.getRanges()[0];
	}

	// Save scroll position before changing focus to "offscreen" paste target
	this.beforePasteData.scrollTop = this.getScrollPosition();

	this.$pasteTarget.empty();

	// Get node from cursor position
	node = doc.getBranchNodeFromOffset( range.start );
	if ( node.canContainContent() ) {
		// If this is a content branch node, then add its DM HTML
		// to the paste target to give CE some context.
		textStart = textEnd = 0;
		nodeRange = node.getRange();
		contextElement = node.getClonedElement();
		context = [ contextElement ];
		// If there is content to the left of the cursor, put a placeholder
		// character to the left of the cursor
		if ( range.start > nodeRange.start ) {
			leftText = '☀';
			context.push( leftText );
			textStart = textEnd = 1;
		}
		// If there is content to the right of the cursor, put a placeholder
		// character to the right of the cursor
		if ( range.end < nodeRange.end ) {
			rightText = '☂';
			context.push( rightText );
		}
		// If there is no text context, select some text to be replaced
		if ( !leftText && !rightText ) {
			context.push( '☁' );
			textEnd = 1;
		}
		context.push( { type: '/' + context[0].type } );

		// Throw away 'internal', specifically inner whitespace,
		// before conversion as it can affect textStart/End offsets.
		delete contextElement.internal;
		ve.dm.converter.getDomSubtreeFromModel(
			doc.createDocument(
				new ve.dm.ElementLinearData( doc.getStore(), context, nodeFactory ),
				nodeFactory,
				doc.getHtmlDocument(), undefined, doc.getInternalList(),
				doc.getLang(), doc.getDir()
			),
			this.$pasteTarget[0]
		);

		// Giving the paste target focus too late can cause problems in FF (!?)
		// so do it up here.
		this.$pasteTarget[0].focus();

		nativeRange = this.getElementDocument().createRange();
		// Assume that the DM node only generated one child
		textNode = this.$pasteTarget.children().contents()[0];
		// Place the cursor between the placeholder characters
		nativeRange.setStart( textNode, textStart );
		nativeRange.setEnd( textNode, textEnd );
		this.nativeSelection.removeAllRanges();
		this.nativeSelection.addRange( nativeRange );

		this.beforePasteData.context = context;
		this.beforePasteData.leftText = leftText;
		this.beforePasteData.rightText = rightText;
	} else {
		// If we're not in a content branch node, don't bother trying to do
		// anything clever with paste context
		this.$pasteTarget[0].focus();
	}

	// Restore scroll position after focusing the paste target
	this.setScrollPosition( this.beforePasteData.scrollTop );

};

/**
 * Handle post-paste events.
 *
 * @param {jQuery.Event} e Paste event
 */
ve.ce.Surface.prototype.afterPaste = function () {
	var clipboardKey, clipboardId, clipboardIndex, clipboardHash, range,
		$elements, parts, pasteData, slice, tx, internalListRange,
		data, doc, htmlDoc, $images, i,
		context, left, right, contextRange,
		items = [],
		importantSpan = 'span[id],span[typeof],span[rel]',
		importRules = this.getSurface().getImportRules(),
		beforePasteData = this.beforePasteData || {},
		selection = this.model.getSelection(),
		view = this;

	// If the selection doesn't collapse after paste then nothing was inserted
	if ( !this.nativeSelection.isCollapsed ) {
		return;
	}

	if ( selection instanceof ve.dm.LinearSelection ||
		( selection instanceof ve.dm.TableSelection && selection.isSingleCell() )
	) {
		range = selection.getRanges()[0];
	} else {
		return;
	}

	// Remove style attributes. Any valid styles will be restored by data-ve-attributes.
	this.$pasteTarget.find( '[style]' ).removeAttr( 'style' );

	// Remove the pasteProtect class (see #onCopy) and unwrap empty spans.
	this.$pasteTarget.find( 'span' ).each( function () {
		var $this = $( this );
		$this.removeClass( 've-pasteProtect' );
		if ( $this.attr( 'class' ) === '' ) {
			$this.removeAttr( 'class' );
		}
		// Unwrap empty spans
		if ( !this.attributes.length ) {
			$this.replaceWith( this.childNodes );
		}
	} );

	// Restore attributes. See #onCopy.
	this.$pasteTarget.find( '[data-ve-attributes]' ).each( function () {
		var attrs;
		try {
			attrs = JSON.parse( this.getAttribute( 'data-ve-attributes' ) );
		} catch ( e ) {
			// Invalid JSON
			return;
		}
		$( this ).attr( attrs );
		this.removeAttribute( 'data-ve-attributes' );
	} );

	// Find the clipboard key
	if ( beforePasteData.custom ) {
		clipboardKey = beforePasteData.custom;
	} else {
		if ( beforePasteData.html ) {
			$elements = this.$( $.parseHTML( beforePasteData.html ) );

			// Try to find the clipboard key hidden in the HTML
			$elements = $elements.filter( function () {
				var val = this.getAttribute && this.getAttribute( 'data-ve-clipboard-key' );
				if ( val ) {
					clipboardKey = val;
					// Remove the clipboard key span once read
					return false;
				}
				return true;
			} );
			clipboardHash = this.constructor.static.getClipboardHash( $elements );
		} else {
			// HTML in pasteTarget my get wrapped, so use the recursive $.find to look for the clipboard key
			clipboardKey = this.$pasteTarget.find( 'span[data-ve-clipboard-key]' ).data( 've-clipboard-key' );
			// Pass beforePasteData so context gets stripped
			clipboardHash = this.constructor.static.getClipboardHash( this.$pasteTarget, beforePasteData );
		}
	}

	// Remove the clipboard key
	this.$pasteTarget.find( 'span[data-ve-clipboard-key]' ).remove();

	// If we have a clipboard key, validate it and fetch data
	if ( clipboardKey ) {
		parts = clipboardKey.split( '-' );
		clipboardId = parts[0];
		clipboardIndex = parts[1];
		if ( clipboardId === this.clipboardId && this.clipboard[clipboardIndex] ) {
			// Hash validation: either text/xcustom was used or the hash must be
			// equal to the hash of the pasted HTML to assert that the HTML
			// hasn't been modified in another editor before being pasted back.
			if ( beforePasteData.custom ||
				this.clipboard[clipboardIndex].hash === clipboardHash
			) {
				slice = this.clipboard[clipboardIndex].slice;
			}
		}
	}

	if ( slice ) {
		// Internal paste
		try {
			// Try to paste in the original data
			// Take a copy to prevent the data being annotated a second time in the catch block
			// and to prevent actions in the data model affecting view.clipboard
			pasteData = new ve.dm.ElementLinearData(
				slice.getStore(),
				ve.copy( slice.getOriginalData() ),
				this.getModel().getDocument().getNodeFactory()
			);

			if ( importRules.all || this.pasteSpecial ) {
				pasteData.sanitize( importRules.all || {}, this.pasteSpecial );
			}

			// Annotate
			ve.dm.Document.static.addAnnotationsToData( pasteData.getData(), this.model.getInsertionAnnotations() );

			// Transaction
			tx = ve.dm.Transaction.newFromInsertion(
				this.documentView.model,
				range.start,
				pasteData.getData()
			);
		} catch ( err ) {
			// If that fails, use the balanced data
			// Take a copy to prevent actions in the data model affecting view.clipboard
			pasteData = new ve.dm.ElementLinearData(
				slice.getStore(),
				ve.copy( slice.getBalancedData() ),
				this.getModel().getDocument().getNodeFactory()
			);

			if ( importRules.all || this.pasteSpecial ) {
				pasteData.sanitize( importRules.all || {}, this.pasteSpecial );
			}

			// Annotate
			ve.dm.Document.static.addAnnotationsToData( pasteData.getData(), this.model.getInsertionAnnotations() );

			// Transaction
			tx = ve.dm.Transaction.newFromInsertion(
				this.documentView.model,
				range.start,
				pasteData.getData()
			);
		}
	} else {
		if ( clipboardKey && beforePasteData.html ) {
			// If the clipboardKey is set (paste from other VE instance), and clipboard
			// data is available, then make sure important spans haven't been dropped
			if ( !$elements ) {
				$elements = this.$( $.parseHTML( beforePasteData.html ) );
			}
			if (
				// HACK: Allow the test runner to force the use of clipboardData
				clipboardKey === 'useClipboardData-0' || (
					$elements.find( importantSpan ).andSelf().filter( importantSpan ).length > 0 &&
					this.$pasteTarget.find( importantSpan ).length === 0
				)
			) {
				// CE destroyed an important span, so revert to using clipboard data
				htmlDoc = ve.createDocumentFromHtml( beforePasteData.html );
				// Remove the pasteProtect class. See #onCopy.
				$( htmlDoc ).find( 'span' ).removeClass( 've-pasteProtect' );
				beforePasteData.context = null;
			}
		}
		if ( !htmlDoc ) {
			// If there were no problems, let CE do its sanitizing as it may
			// contain all sorts of horrible metadata (head tags etc.)
			// TODO: IE will always take this path, and so may have bugs with span unwrapping
			// in edge cases (e.g. pasting a single MWReference)
			htmlDoc = ve.createDocumentFromHtml( this.$pasteTarget.html() );
		}
		// Some browsers don't provide pasted image data through the clipboardData API and
		// instead create img tags with data URLs, so detect those here
		$images = $( htmlDoc.body ).find( 'img[src^=data\\:]' );
		if ( $images.length ) {
			for ( i = 0; i < $images.length; i++ ) {
				items.push( ve.ui.DataTransferItem.static.newFromDataUri( $images.eq( i ).attr( 'src' ) ) );
			}
			if ( this.handleDataTransferItems( items, true ) ) {
				return;
			}
		}
		// External paste
		// TODO: what about 'lang' and 'dir'?
		doc = ve.dm.converter.getModelFromDom( htmlDoc, this.getModel().getDocument().getHtmlDocument(), null, null, this.getModel().getDocument());
		data = doc.data;
		// Clear metadata
		doc.metadata = new ve.dm.MetaLinearData( doc.getStore(), new Array( 1 + data.getLength() ) );
		// If the clipboardKey isn't set (paste from non-VE instance) use external import rules
		if ( !clipboardKey ) {
			data.sanitize( importRules.external, this.pasteSpecial );
			if ( importRules.all ) {
				data.sanitize( importRules.all );
			}
		} else {
			data.sanitize( importRules.all || {}, this.pasteSpecial );
		}
		data.remapInternalListKeys( this.model.getDocument().getInternalList() );

		// Initialize node tree
		doc.buildNodeTree();

		// If the paste was given context, calculate the range of the inserted data
		if ( beforePasteData.context ) {
			internalListRange = doc.getInternalList().getListNode().getOuterRange();
			context = new ve.dm.ElementLinearData(
				doc.getStore(),
				ve.copy( beforePasteData.context ),
				doc.getNodeFactory()
			);
			if ( this.pasteSpecial ) {
				// The context may have been sanitized, so sanitize here as well for comparison
				context.sanitize( importRules, this.pasteSpecial, true );
			}

			// Remove matching context from the left
			left = 0;
			while (
				context.getLength() &&
				ve.dm.ElementLinearData.static.compareElements(
					data.getData( left ),
					data.isElementData( left ) ? context.getData( 0 ) : beforePasteData.leftText
				)
			) {
				left++;
				context.splice( 0, 1 );
			}

			// Remove matching context from the right
			right = internalListRange.start;
			while (
				right > 0 &&
				context.getLength() &&
				ve.dm.ElementLinearData.static.compareElements(
					data.getData( right - 1 ),
					data.isElementData( right - 1 ) ? context.getData( context.getLength() - 1 ) : beforePasteData.rightText
				)
			) {
				right--;
				context.splice( context.getLength() - 1, 1 );
			}
			// HACK: Strip trailing linebreaks probably introduced by Chrome bug
			while ( right > 0 && data.getType( right - 1 ) === 'break' ) {
				right--;
			}
			contextRange = new ve.Range( left, right );
		}

		tx = ve.dm.Transaction.newFromDocumentInsertion(
			this.documentView.model,
			range.start,
			doc,
			contextRange
		);
	}

	// Restore focus and scroll position
	this.$documentNode[0].focus();
	// Firefox sometimes doesn't change scrollTop immediately when pasting
	// line breaks so wait until we fix it.
	setTimeout( function () {
		view.setScrollPosition( beforePasteData.scrollTop );
	} );

	selection = selection.translateByTransaction( tx );
	this.model.change( tx, selection.collapseToStart() );
	// Move cursor to end of selection
	this.model.setSelection( selection.collapseToEnd() );
};

/**
 * Handle the insertion of a data transfer object
 *
 * @param {DataTransfer} dataTransfer Data transfer
 * @param {boolean} isPaste Handlers being used for paste
 * @param {ve.dm.SurfaceFragment} [targetFragment] Fragment to inserto data items at, defaults to current selection
 * @return {boolean} One more items was handled
 */
ve.ce.Surface.prototype.handleDataTransfer = function ( dataTransfer, isPaste, targetFragment ) {
	var i, l, stringData,
		items = [],
		stringTypes = ['text/html', 'text/plain'];

	if ( dataTransfer.items ) {
		for ( i = 0, l = dataTransfer.items.length; i < l; i++ ) {
			if ( dataTransfer.items[i].kind !== 'string' ) {
				items.push( ve.ui.DataTransferItem.static.newFromItem( dataTransfer.items[i] ) );
			}
		}
	} else if ( dataTransfer.files ) {
		for ( i = 0, l = dataTransfer.files.length; i < l; i++ ) {
			items.push( ve.ui.DataTransferItem.static.newFromBlob( dataTransfer.files[i] ) );
		}
	}

	for ( i = 0, l = stringTypes.length; i < stringTypes.length; i++ ) {
		stringData = dataTransfer.getData( stringTypes[i] );
		if ( stringData ) {
			items.push( ve.ui.DataTransferItem.static.newFromString( stringData, stringTypes[i] ) );
		}
	}

	return this.handleDataTransferItems( items, isPaste, targetFragment );
};

/**
 * Handle the insertion of data tranfer items
 *
 * @param {ve.ui.DataTransferItem[]} items Data transfer items
 * @param {boolean} isPaste Handlers being used for paste
 * @param {ve.dm.SurfaceFragment} [targetFragment] Fragment to inserto data items at, defaults to current selection
 * @return {boolean} One more items was handled
 */
ve.ce.Surface.prototype.handleDataTransferItems = function ( items, isPaste, targetFragment ) {
	var i, l, name,
		handled = false;

	targetFragment = targetFragment || this.getModel().getFragment();

	function insert( docOrData ) {
		if ( docOrData instanceof ve.dm.Document ) {
			targetFragment.collapseToEnd().insertDocument( docOrData );
		} else {
			targetFragment.collapseToEnd().insertContent( docOrData );
		}
	}

	for ( i = 0, l = items.length; i < l; i++ ) {
		name = ve.ui.dataTransferHandlerFactory.getHandlerNameForItem( items[i], isPaste );
		if ( name ) {
			ve.ui.dataTransferHandlerFactory.create( name, this.surface, items[i] )
				.getInsertableData().done( insert );
			handled = true;
			break;
		}
	}
	return handled;
};

/**
 * Select all the contents within the current context
 */
ve.ce.Surface.prototype.selectAll = function () {
	var internalListRange, range, matrix,
		selection = this.getModel().getSelection();

	if ( selection instanceof ve.dm.LinearSelection ) {
		if ( this.getActiveTableNode() && this.getActiveTableNode().getEditingFragment() ) {
			range = this.getActiveTableNode().getEditingRange();
			range = new ve.Range( range.from + 1, range.to - 1 );
		} else {
			internalListRange = this.getModel().getDocument().getInternalList().getListNode().getOuterRange();
			range = new ve.Range(
				this.getNearestCorrectOffset( 0, 1 ),
				this.getNearestCorrectOffset( internalListRange.start, -1 )
			);
		}
		this.getModel().setLinearSelection( range );
	} else if ( selection instanceof ve.dm.TableSelection ) {
		matrix = selection.getTableNode().getMatrix();
		this.getModel().setSelection(
			new ve.dm.TableSelection(
				selection.getDocument(), selection.tableRange,
				0, 0, matrix.getColCount() - 1, matrix.getRowCount() - 1
			)
		);

	}
};

/**
 * Handle document composition end events.
 *
 * @method
 * @param {jQuery.Event} e Input event
 */
ve.ce.Surface.prototype.onDocumentInput = function () {
	this.incRenderLock();
	try {
		this.surfaceObserver.pollOnce();
	} finally {
		this.decRenderLock();
	}
};

/*! Custom Events */

/**
 * Handle model select events.
 *
 * @see ve.dm.Surface#method-change
 */
ve.ce.Surface.prototype.onModelSelect = function () {
	var focusedNode, blockSlug,
		selection = this.getModel().getSelection();

	this.cursorDirectionality = null;
	this.contentBranchNodeChanged = false;

	if ( selection instanceof ve.dm.LinearSelection ) {
		blockSlug = this.findBlockSlug( selection.getRange() );
		if ( blockSlug !== this.focusedBlockSlug ) {
			if ( this.focusedBlockSlug ) {
				this.focusedBlockSlug.classList.remove(
					've-ce-branchNode-blockSlug-focused'
				);
				this.focusedBlockSlug = null;
			}

			if ( blockSlug ) {
				blockSlug.classList.add( 've-ce-branchNode-blockSlug-focused' );
				this.focusedBlockSlug = blockSlug;
				this.$pasteTarget.text( '☢' );
				ve.selectElement( this.$pasteTarget[0] );
				this.$pasteTarget[0].focus();
			}
		}

		focusedNode = this.findFocusedNode( selection.getRange() );

		// If focus has changed, update nodes and this.focusedNode
		if ( focusedNode !== this.focusedNode ) {
			if ( this.focusedNode ) {
				this.focusedNode.setFocused( false );
				this.focusedNode = null;
			}
			if ( focusedNode ) {
				focusedNode.setFocused( true );
				this.focusedNode = focusedNode;

				// If dragging, we already have a native selection, so don't mess with it
				if ( !this.dragging ) {
					// As FF won't fire a copy event with nothing selected, make
					// a dummy selection of one character in the pasteTarget.
					// Previously this was a single space but this isn't selected programmatically
					// properly, and in Safari results in a collapsed selection.
					// onCopy will ignore this native selection and use the DM selection
					this.$pasteTarget.text( '☢' );
					ve.selectElement( this.$pasteTarget[0] );
					this.$pasteTarget[0].focus();
					// Since the selection is no longer in the documentNode, clear the SurfaceObserver's
					// selection state. Otherwise, if the user places the selection back into the documentNode
					// in exactly the same place where it was before, the observer won't consider that a change.
					this.surfaceObserver.clear();
				}
				// If the node is outside the view, scroll to it
				OO.ui.Element.static.scrollIntoView( this.focusedNode.$element.get( 0 ) );
			}
		}
	} else {
		if ( selection instanceof ve.dm.TableSelection ) {
			this.$pasteTarget.text( '☢' );
			ve.selectElement( this.$pasteTarget[0] );
			this.$pasteTarget[0].focus();
		}
		if ( this.focusedNode ) {
			this.focusedNode.setFocused( false );
		}
		this.focusedNode = null;
	}

	// Ignore the selection if changeModelSelection is currently being
	// called with the same (object-identical) selection object
	// (i.e. if the model is calling us back)
	if ( !this.isRenderingLocked() && selection !== this.newModelSelection ) {
		this.showSelection( selection );
		this.checkUnicorns( false );
	}
	// Update the selection state in the SurfaceObserver
	this.surfaceObserver.pollOnceNoEmit();
};

/**
 * Get the focused node (optionally at a specified range), or null if one is not present
 *
 * @param {ve.Range} [range] Optional range to check for focused node, defaults to current selection's range
 * @return {ve.ce.Node|null} Focused node
 */
ve.ce.Surface.prototype.getFocusedNode = function ( range ) {
	if ( !range ) {
		return this.focusedNode;
	}
	var selection = this.getModel().getSelection();
	if (
		selection instanceof ve.dm.LinearSelection &&
		range.equalsSelection( selection.getRange() )
	) {
		return this.focusedNode;
	}
	return this.findFocusedNode( range );
};

/**
 * Find the block slug a given range is in.
 * @param {ve.Range} range Range to check
 * @return {HTMLElement|null} Slug, or null if no slug or if range is not collapsed
 */
ve.ce.Surface.prototype.findBlockSlug = function ( range ) {
	if ( !range.isCollapsed() ) {
		return null;
	}
	return this.documentView.getDocumentNode().getSlugAtOffset( range.end );
};

/**
 * Find the focusedNode at a specified range
 *
 * @param {ve.Range} range Range to search at for a focusable node
 * @return {ve.ce.Node|null} Focused node
 */
ve.ce.Surface.prototype.findFocusedNode = function ( range ) {
	var startNode, endNode,
		documentNode = this.documentView.getDocumentNode();
	// Detect when only a single focusable element is selected
	if ( !range.isCollapsed() ) {
		startNode = documentNode.getNodeFromOffset( range.start + 1 );
		if ( startNode && startNode.isFocusable() ) {
			endNode = documentNode.getNodeFromOffset( range.end - 1 );
			if ( startNode === endNode ) {
				return startNode;
			}
		}
	} else {
		// Check if the range is inside a focusable node with a collapsed selection
		startNode = documentNode.getNodeFromOffset( range.start );
		if ( startNode && startNode.isFocusable() ) {
			return startNode;
		}
	}
	return null;
};

/**
 * Handle documentUpdate events on the surface model.
 */
ve.ce.Surface.prototype.onModelDocumentUpdate = function () {
	var surface = this;
	if ( this.contentBranchNodeChanged ) {
		// Update the selection state from model
		this.onModelSelect();
	}
	// Update the state of the SurfaceObserver
	this.surfaceObserver.pollOnceNoEmit();
	// Wait for other documentUpdate listeners to run before emitting
	setTimeout( function () {
		surface.emit( 'position' );
	} );
};

/**
 * Handle insertionAnnotationsChange events on the surface model.
 * @param {ve.dm.AnnotationSet} insertionAnnotations
 */
ve.ce.Surface.prototype.onInsertionAnnotationsChange = function () {
	var changed = this.renderSelectedContentBranchNode();
	if ( !changed ) {
		return;
	}
	// Must re-apply the selection after re-rendering
	this.showSelection( this.surface.getModel().getSelection() );
	this.surfaceObserver.pollOnceNoEmit();
};

/**
 * Re-render the ContentBranchNode the selection is currently in.
 *
 * @return {boolean} Whether a re-render actually happened
 */
ve.ce.Surface.prototype.renderSelectedContentBranchNode = function () {
	var selection, ceNode;
	selection = this.model.getSelection();
	if ( !( selection instanceof ve.dm.LinearSelection ) ) {
		return false;
	}
	ceNode = this.documentView.getBranchNodeFromOffset( selection.getRange().start );
	if ( ceNode === null ) {
		return false;
	}
	if ( !( ceNode instanceof ve.ce.ContentBranchNode ) ) {
		// not a content branch node
		return false;
	}
	return ceNode.renderContents();
};

/**
 * Handle branch node change events.
 *
 * @see ve.ce.SurfaceObserver#pollOnce
 *
 * @method
 * @param {ve.ce.BranchNode} oldBranchNode Node from which the range anchor has just moved
 * @param {ve.ce.BranchNode} newBranchNode Node into which the range anchor has just moved
 */
ve.ce.Surface.prototype.onSurfaceObserverBranchNodeChange = function ( oldBranchNode ) {
	if ( oldBranchNode instanceof ve.ce.ContentBranchNode ) {
		oldBranchNode.renderContents();
	}
	// Re-apply selection in case the branch node change left us at an invalid offset
	// e.g. in the document node.
	this.showSelection( this.getModel().getSelection() );
};

/**
 * Create a slug out of a DOM element
 *
 * @param {HTMLElement} element Slug element
 */
ve.ce.Surface.prototype.createSlug = function ( element ) {
	var $slug,
		surface = this,
		offset = ve.ce.getOffsetOfSlug( element ),
		doc = this.getModel().getDocument();

	this.changeModel( ve.dm.Transaction.newFromInsertion(
		doc, offset, [
			{ type: 'paragraph', internal: { generated: 'slug' } },
			{ type: '/paragraph' }
		]
	), new ve.dm.LinearSelection( doc, new ve.Range( offset + 1 ) ) );

	// Animate the slug open
	$slug = this.getDocument().getDocumentNode().getNodeFromOffset( offset + 1 ).$element;
	$slug.addClass( 've-ce-branchNode-newSlug' );
	setTimeout( function () {
		$slug.addClass( 've-ce-branchNode-newSlug-open' );
		setTimeout( function () {
			surface.emit( 'position' );
		}, 200 );
	} );

	this.onModelSelect();
};

/**
 * Handle selection change events.
 *
 * @see ve.ce.SurfaceObserver#pollOnce
 *
 * @method
 * @param {ve.Range|null} oldRange
 * @param {ve.Range|null} newRange
 */
ve.ce.Surface.prototype.onSurfaceObserverRangeChange = function ( oldRange, newRange ) {
	if ( oldRange && oldRange.equalsSelection( newRange ) ) {
		// Ignore when the newRange is just a flipped oldRange
		return;
	}
	this.incRenderLock();
	try {
		this.changeModel(
			null,
			newRange ?
				new ve.dm.LinearSelection( this.getModel().getDocument(), newRange ) :
				new ve.dm.NullSelection( this.getModel().getDocument() )
		);
	} finally {
		this.decRenderLock();
	}
	this.checkUnicorns( false );
};

/**
 * Handle content change events.
 *
 * @see ve.ce.SurfaceObserver#pollOnce
 *
 * @method
 * @param {ve.ce.Node} node CE node the change occurred in
 * @param {Object} previous Old data
 * @param {Object} previous.text Old plain text content
 * @param {Object} previous.hash Old DOM hash
 * @param {ve.Range} previous.range Old selection
 * @param {Object} next New data
 * @param {Object} next.text New plain text content
 * @param {Object} next.hash New DOM hash
 * @param {ve.Range} next.range New selection
 */
ve.ce.Surface.prototype.onSurfaceObserverContentChange = function ( node, previous, next ) {
	var data, range, len, annotations, offsetDiff, sameLeadingAndTrailing,
		previousStart, nextStart, newRange, replacementRange,
		fromLeft = 0,
		fromRight = 0,
		nodeOffset = node.getModel().getOffset(),
		previousData = previous.text.split( '' ),
		nextData = next.text.split( '' ),
		modelData = this.model.getDocument().data,
		lengthDiff = next.text.length - previous.text.length,
		nextDataString = new ve.dm.DataString( nextData ),
		surface = this;

	/**
	 * Given a naïvely computed set of annotations to apply to the content we're about to insert,
	 * this function will check if we're inserting at a word break, check if there are any
	 * annotations in the set that need to be split at a word break, and remove those.
	 *
	 * @private
	 * @param {ve.dm.AnnotationSet} annotations Annotations to apply. Will be modified.
	 * @param {ve.Range} range Range covering removed content, or collapsed range at insertion offset.
	 */
	function filterForWordbreak( annotations, range ) {
		var i, length, annotation, annotationIndex, annotationsLeft, annotationsRight,
			left = range.start,
			right = range.end,
			// - nodeOffset - 1 to adjust from absolute to relative
			// adjustment from prev to next not needed because we're before the replacement
			breakLeft = unicodeJS.wordbreak.isBreak( nextDataString, left - nodeOffset - 1 ),
			// - nodeOffset - 1 to adjust from absolute to relative
			// + lengthDiff to adjust from prev to next
			breakRight = unicodeJS.wordbreak.isBreak( nextDataString, right + lengthDiff - nodeOffset - 1 );

		if ( !breakLeft && !breakRight ) {
			// No word breaks either side, so nothing to do
			return;
		}

		annotationsLeft = modelData.getAnnotationsFromOffset( left - 1 );
		annotationsRight = modelData.getAnnotationsFromOffset( right );

		for ( i = 0, length = annotations.getLength(); i < length; i++ ) {
			annotation = annotations.get( i );
			annotationIndex = annotations.getIndex( i );
			if (
				// This annotation splits on wordbreak, and...
				annotation.constructor.static.splitOnWordbreak &&
				(
					// either we're at its right-hand boundary (its end is to our left) and
					// there's a wordbreak to our left
					( breakLeft && !annotationsRight.containsIndex( annotationIndex ) ) ||
					// or we're at its left-hand boundary (its beginning is to our right) and
					// there's a wordbreak to our right
					( breakRight && !annotationsLeft.containsIndex( annotationIndex ) )
				)
			) {
				annotations.removeAt( i );
				i--;
				length--;
			}
		}
	}

	if ( previous.range && next.range ) {
		offsetDiff = ( previous.range.isCollapsed() && next.range.isCollapsed() ) ?
			next.range.start - previous.range.start : null;
		previousStart = previous.range.start - nodeOffset - 1;
		nextStart = next.range.start - nodeOffset - 1;
		sameLeadingAndTrailing = offsetDiff !== null && (
			(
				lengthDiff > 0 &&
				previous.text.slice( 0, previousStart ) ===
					next.text.slice( 0, previousStart ) &&
				previous.text.slice( previousStart ) ===
					next.text.slice( nextStart )
			) ||
			(
				lengthDiff < 0 &&
				previous.text.slice( 0, nextStart ) ===
					next.text.slice( 0, nextStart ) &&
				previous.text.slice( previousStart - lengthDiff + offsetDiff ) ===
					next.text.slice( nextStart )
			)
		);

		// Simple insertion
		if ( lengthDiff > 0 && offsetDiff === lengthDiff && sameLeadingAndTrailing ) {
			data = nextData.slice( previousStart, nextStart );
			// Apply insertion annotations
			annotations = node.unicornAnnotations || this.model.getInsertionAnnotations();
			if ( annotations.getLength() ) {
				filterForWordbreak( annotations, new ve.Range( previous.range.start ) );
				ve.dm.Document.static.addAnnotationsToData( data, annotations );
			}

			this.incRenderLock();
			try {
				this.changeModel(
					ve.dm.Transaction.newFromInsertion(
						this.documentView.model, previous.range.start, data
					),
					new ve.dm.LinearSelection( this.documentView.model, next.range )
				);
			} finally {
				this.decRenderLock();
			}
			setTimeout( function () {
				surface.checkSequences();
			} );
			return;
		}

		// Simple deletion
		if ( ( offsetDiff === 0 || offsetDiff === lengthDiff ) && sameLeadingAndTrailing ) {
			if ( offsetDiff === 0 ) {
				range = new ve.Range( next.range.start, next.range.start - lengthDiff );
			} else {
				range = new ve.Range( next.range.start, previous.range.start );
			}
			this.incRenderLock();
			try {
				this.changeModel(
					ve.dm.Transaction.newFromRemoval( this.documentView.model,
						range ),
					new ve.dm.LinearSelection( this.documentView.model, next.range )
				);
			} finally {
				this.decRenderLock();
			}
			return;
		}
	}

	// Complex change:
	// 1. Count unchanged characters from left and right;
	// 2. Assume that the minimal changed region indicates the replacement made by the user;
	// 3. Hence guess how to map annotations.
	// N.B. this logic can go wrong; e.g. this code will see slice->slide and
	// assume that the user changed 'c' to 'd', but the user could instead have changed 'ic'
	// to 'id', which would map annotations differently.

	len = Math.min( previousData.length, nextData.length );

	while ( fromLeft < len && previousData[fromLeft] === nextData[fromLeft] ) {
		++fromLeft;
	}

	while (
		fromRight < len - fromLeft &&
		previousData[previousData.length - 1 - fromRight] ===
		nextData[nextData.length - 1 - fromRight]
	) {
		++fromRight;
	}
	replacementRange = new ve.Range(
		nodeOffset + 1 + fromLeft,
		nodeOffset + 1 + previousData.length - fromRight
	);
	data = nextData.slice( fromLeft, nextData.length - fromRight );

	if ( node.unicornAnnotations ) {
		// This CBN is unicorned. Use the stored annotations.
		annotations = node.unicornAnnotations;
	} else if ( fromLeft + fromRight < previousData.length ) {
		// Content is being removed, so guess that we want to use the annotations from the
		// start of the removed content.
		annotations = modelData.getAnnotationsFromOffset( replacementRange.start );
	} else {
		// No content is being removed, so guess that we want to use the annotations from
		// just before the insertion (which means none at all if the insertion is at the
		// start of a CBN).
		annotations = modelData.getAnnotationsFromOffset( replacementRange.start - 1 );
	}
	if ( annotations.getLength() ) {
		filterForWordbreak( annotations, replacementRange );
		ve.dm.Document.static.addAnnotationsToData( data, annotations );
	}
	newRange = next.range;
	if ( newRange.isCollapsed() ) {
		newRange = new ve.Range( this.getNearestCorrectOffset( newRange.start, 1 ) );
	}

	this.changeModel(
		ve.dm.Transaction.newFromReplacement( this.documentView.model, replacementRange, data ),
		new ve.dm.LinearSelection( this.documentView.model, newRange )
	);
	this.queueCheckSequences = true;
	setTimeout( function () {
		surface.checkSequences();
	} );
};

/**
 * Check the current surface offset for sequence matches
 */
ve.ce.Surface.prototype.checkSequences = function () {
	var i, sequences,
		executed = false,
		surfaceModel = this.surface.getModel(),
		selection = surfaceModel.getSelection();

	if ( !( selection instanceof ve.dm.LinearSelection ) ) {
		return;
	}

	sequences = ve.ui.sequenceRegistry.findMatching( surfaceModel.getDocument().data, selection.getRange().end );

	// sequences.length will likely be 0 or 1 so don't cache
	for ( i = 0; i < sequences.length; i++ ) {
		executed = sequences[i].execute( this.surface ) || executed;
	}
	if ( executed ) {
		this.showSelection( this.surface.getModel().getSelection() );
	}
};

/**
 * Handle window resize event.
 *
 * @param {jQuery.Event} e Window resize event
 */
ve.ce.Surface.prototype.onWindowResize = ve.debounce( function () {
	this.emit( 'position' );
}, 50 );

/*! Relocation */

/**
 * Start a relocation action.
 *
 * @see ve.ce.FocusableNode
 *
 * @method
 * @param {ve.ce.Node} node Node being relocated
 */
ve.ce.Surface.prototype.startRelocation = function ( node ) {
	this.relocatingNode = node;
	this.emit( 'relocationStart', node );
};

/**
 * Complete a relocation action.
 *
 * @see ve.ce.FocusableNode
 *
 * @method
 * @param {ve.ce.Node} node Node being relocated
 */
ve.ce.Surface.prototype.endRelocation = function () {
	if ( this.relocatingNode ) {
		this.emit( 'relocationEnd', this.relocatingNode );
		this.relocatingNode = null;
		if ( this.$lastDropTarget ) {
			this.$dropMarker.addClass( 'oo-ui-element-hidden' );
			this.$lastDropTarget = null;
			this.lastDropPosition = null;
		}
	}
};

/**
 * Set the active table node
 *
 * @param {ve.ce.TableNode|null} tableNode Table node
 */
ve.ce.Surface.prototype.setActiveTableNode = function ( tableNode ) {
	this.activeTableNode = tableNode;
};

/**
 * Get the active table node
 *
 * @return {ve.ce.TableNode|null} Table node
 */
ve.ce.Surface.prototype.getActiveTableNode = function () {
	return this.activeTableNode;
};

/*! Utilities */

/**
 * Store the current selection range, and a key down event if relevant
 *
 * @param {jQuery.Event|null} e Key down event
 */
ve.ce.Surface.prototype.storeKeyDownState = function ( e ) {
	if ( this.nativeSelection.rangeCount === 0 ) {
		this.cursorEvent = null;
		this.misleadingCursorStartSelection = null;
		return;
	}
	this.cursorEvent = e;
	this.misleadingCursorStartSelection = null;
	if (
		e.keyCode === OO.ui.Keys.UP ||
		e.keyCode === OO.ui.Keys.DOWN ||
		e.keyCode === OO.ui.Keys.LEFT ||
		e.keyCode === OO.ui.Keys.RIGHT
	) {
		this.misleadingCursorStartSelection = {
			isCollapsed: this.nativeSelection.isCollapsed,
			anchorNode: this.nativeSelection.anchorNode,
			anchorOffset: this.nativeSelection.anchorOffset,
			focusNode: this.nativeSelection.focusNode,
			focusOffset: this.nativeSelection.focusOffset
		};
	}
};

/**
 * Move the DM surface cursor
 *
 * @param {number} offset Distance to move (negative = toward document start)
 */
ve.ce.Surface.prototype.moveModelCursor = function ( offset ) {
	var selection = this.model.getSelection();
	if ( selection instanceof ve.dm.LinearSelection ) {
		this.model.setLinearSelection( this.model.getDocument().getRelativeRange(
			selection.getRange(),
			offset,
			'character',
			false
		) );
	}
};

/**
 * Get the directionality at the current focused node
 * @returns {string} 'ltr' or 'rtl'
 */
ve.ce.Surface.prototype.getFocusedNodeDirectionality = function () {
	var cursorNode,
		range = this.model.getSelection().getRange();

	// Use stored directionality if we have one.
	if ( this.cursorDirectionality ) {
		return this.cursorDirectionality;
	}

	// Else fall back on the CSS directionality of the focused node at the DM selection focus,
	// which is less reliable because it does not take plaintext bidi into account.
	// (range.to will actually be at the edge of the focused node, but the
	// CSS directionality will be the same).
	cursorNode = this.getDocument().getNodeAndOffset( range.to ).node;
	if ( cursorNode.nodeType === Node.TEXT_NODE ) {
		cursorNode = cursorNode.parentNode;
	}
	return this.$( cursorNode ).css( 'direction' );
};

/**
 * Restore the selection from the model if it is outside the active table node
 *
 * This is only useful if the DOM selection and the model selection are out of sync
 * @returns {boolean} Whether the selection was restored
 */
ve.ce.Surface.prototype.restoreActiveTableNodeSelection = function () {
	var activeTableNode, editingRange;
	if (
		( activeTableNode = this.getActiveTableNode() ) &&
		( editingRange = activeTableNode.getEditingRange() ) &&
		!editingRange.containsRange( ve.ce.veRangeFromSelection( this.nativeSelection ) )
	) {
		this.showSelection( this.getModel().getSelection() );
		return true;
	} else {
		return false;
	}
};

/**
 * Handle up or down arrow key events with a linear selection.
 *
 * @param {jQuery.Event} e Up or down key down event
 */
ve.ce.Surface.prototype.handleLinearArrowKey = function ( e ) {
	var nativeRange, collapseNode, collapseOffset, direction, directionality, upOrDown,
		startFocusNode, startFocusOffset,
		range = this.model.getSelection().getRange(),
		surface = this;

	// TODO: onDocumentKeyDown did this already
	this.surfaceObserver.stopTimerLoop();
	// TODO: onDocumentKeyDown did this already
	this.surfaceObserver.pollOnce();

	upOrDown = e.keyCode === OO.ui.Keys.UP || e.keyCode === OO.ui.Keys.DOWN;

	if ( this.focusedBlockSlug ) {
		// Block level selection, so directionality is just css directionality
		if ( upOrDown ) {
			direction = e.keyCode === OO.ui.Keys.DOWN ? 1 : -1;
		} else {
			directionality = $( this.focusedBlockSlug ).css( 'direction' );
			/*jshint bitwise:false */
			if ( e.keyCode === OO.ui.Keys.LEFT ^ directionality === 'rtl' ) {
				// leftarrow in ltr, or rightarrow in rtl
				direction = -1;
			} else {
				// leftarrow in rtl, or rightarrow in ltr
				direction = 1;
			}
		}
		range = this.model.getDocument().getRelativeRange(
			range,
			direction,
			'character',
			e.shiftKey,
			this.getActiveTableNode() ? this.getActiveTableNode().getEditingRange() : null
		);
		this.model.setLinearSelection( range );
		e.preventDefault();
		return;
	}

	if ( this.focusedNode ) {
		if ( upOrDown ) {
			direction = e.keyCode === OO.ui.Keys.DOWN ? 1 : -1;
		} else {
			directionality = this.getFocusedNodeDirectionality();
			/*jshint bitwise:false */
			if ( e.keyCode === OO.ui.Keys.LEFT ^ directionality === 'rtl' ) {
				// leftarrow in ltr, or rightarrow in rtl
				direction = -1;
			} else {
				// leftarrow in rtl, or rightarrow in ltr
				direction = 1;
			}
		}

		if ( !this.focusedNode.isContent() ) {
			// Block focusable node: move back/forward in DM (and DOM) and preventDefault
			range = this.model.getDocument().getRelativeRange(
				range,
				direction,
				'character',
				e.shiftKey,
				this.getActiveTableNode() ? this.getActiveTableNode().getEditingRange() : null
			);
			this.model.setLinearSelection( range );
			e.preventDefault();
			return;
		}
		// Else inline focusable node

		if ( e.shiftKey ) {
			// There is no DOM range to expand (because the selection is faked), so
			// use "collapse to focus - observe - expand". Define "focus" to be the
			// edge of the focusedNode in the direction of motion (so the selection
			// always grows). This means that clicking on the focusableNode then
			// modifying the selection will always include the node.
			if ( direction === -1 ^ range.isBackwards() ) {
				range = range.flip();
			}
			this.model.setLinearSelection( new ve.Range( range.to ) );
		} else {
			// Move to start/end of node in the model in DM (and DOM)
			range = new ve.Range( direction === 1 ? range.end : range.start );
			this.model.setLinearSelection( range );
			if ( !upOrDown ) {
				// un-shifted left/right: we've already moved so preventDefault
				e.preventDefault();
				return;
			}
			// Else keep going with the cursor in the new place
		}
		// Else keep DM range and DOM selection as-is
	}

	if ( !this.nativeSelection.extend && range.isBackwards() ) {
		// If the browser doesn't support backwards selections, but the dm range
		// is backwards, then use "collapse to anchor - observe - expand".
		collapseNode = this.nativeSelection.anchorNode;
		collapseOffset = this.nativeSelection.anchorOffset;
	} else if ( !range.isCollapsed() && upOrDown ) {
		// If selection is expanded and cursoring is up/down, use
		// "collapse to focus - observe - expand" to work round quirks.
		collapseNode = this.nativeSelection.focusNode;
		collapseOffset = this.nativeSelection.focusOffset;
	}
	// Else don't collapse the selection

	if ( collapseNode ) {
		nativeRange = this.getElementDocument().createRange();
		nativeRange.setStart( collapseNode, collapseOffset );
		nativeRange.setEnd( collapseNode, collapseOffset );
		this.nativeSelection.removeAllRanges();
		this.nativeSelection.addRange( nativeRange );
	}

	startFocusNode = this.nativeSelection.focusNode;
	startFocusOffset = this.nativeSelection.focusOffset;

	// Re-expand (or fixup) the selection after the native action, if necessary
	this.eventSequencer.afterOne( { keydown: function () {
		var viewNode, newRange, afterDirection;

		// Chrome bug lets you cursor into a multi-line contentEditable=false with up/down...
		viewNode = $( surface.nativeSelection.focusNode ).closest( '.ve-ce-leafNode,.ve-ce-branchNode' ).data( 'view' );
		if ( !viewNode ) {
			// Irrelevant selection (or none)
			return;
		}

		if ( viewNode.isFocusable() ) {
			// We've landed in a focusable node; fixup the range
			if ( upOrDown ) {
				// The intended direction is clear, even if the cursor did not move
				// or did something completely preposterous
				afterDirection = e.keyCode === OO.ui.Keys.DOWN ? 1 : -1;
			} else {
				// Observe which way the cursor moved
				afterDirection = ve.compareDocumentOrder(
					startFocusNode,
					startFocusOffset,
					surface.nativeSelection.focusNode,
					surface.nativeSelection.focusOffset
				);
			}
			newRange = (
				afterDirection === 1 ?
				viewNode.getOuterRange() :
				viewNode.getOuterRange().flip()
			);
		} else {
			// Check where the range has moved to
			surface.surfaceObserver.pollOnceNoEmit();
			newRange = new ve.Range( surface.surfaceObserver.getRange().to );
		}

		// Adjust range to use old anchor, if necessary
		if ( e.shiftKey ) {
			newRange = new ve.Range( range.from, newRange.to );
			surface.getModel().setLinearSelection( newRange );
		}
		surface.surfaceObserver.pollOnce();
	} } );
};

/**
 * Handle arrow key events with a table selection.
 *
 * @param {jQuery.Event} e Arrow key down event
 */
ve.ce.Surface.prototype.handleTableArrowKey = function ( e ) {
	var tableNode, newSelection,
		checkDir = false,
		selection = this.getModel().getSelection(),
		colOffset = 0,
		rowOffset = 0;

	switch ( e.keyCode ) {
		case OO.ui.Keys.LEFT:
			colOffset = -1;
			checkDir = true;
			break;
		case OO.ui.Keys.RIGHT:
			colOffset = 1;
			checkDir = true;
			break;
		case OO.ui.Keys.UP:
			rowOffset = -1;
			break;
		case OO.ui.Keys.DOWN:
			rowOffset = 1;
			break;
		case OO.ui.Keys.HOME:
			colOffset = -Infinity;
			break;
		case OO.ui.Keys.END:
			colOffset = Infinity;
			break;
		case OO.ui.Keys.PAGEUP:
			rowOffset = -Infinity;
			break;
		case OO.ui.Keys.PAGEDOWN:
			rowOffset = Infinity;
			break;
	}

	e.preventDefault();

	if ( colOffset && checkDir ) {
		tableNode = this.documentView.getBranchNodeFromOffset( selection.tableRange.start + 1 );
		if ( tableNode.$element.css( 'direction' ) !== 'ltr' ) {
			colOffset *= -1;
		}
	}
	if ( !e.shiftKey && !selection.isSingleCell() ) {
		selection = selection.collapseToFrom();
	}
	newSelection = selection.newFromAdjustment(
		e.shiftKey ? 0 : colOffset,
		e.shiftKey ? 0 : rowOffset,
		colOffset,
		rowOffset
	);
	this.getModel().setSelection( newSelection );
};

/**
 * Handle insertion of content.
 */
ve.ce.Surface.prototype.handleInsertion = function () {
	// Don't allow a user to delete a focusable node just by typing
	if ( this.focusedNode ) {
		return;
	}

	var range, annotations,
		cellSelection,
		hasChanged = false,
		selection = this.model.getSelection(),
		documentModel = this.model.getDocument();

	if ( selection instanceof ve.dm.TableSelection ) {
		cellSelection = selection.collapseToFrom();
		annotations = documentModel.data.getAnnotationsFromRange( cellSelection.getRanges()[0] );
		this.model.setSelection( cellSelection );
		this.handleTableDelete();
		this.documentView.getBranchNodeFromOffset( selection.tableRange.start + 1 ).setEditing( true );
		this.model.setInsertionAnnotations( annotations );
		selection = this.model.getSelection();
	}

	if ( !( selection instanceof ve.dm.LinearSelection ) ) {
		return;
	}

	range = selection.getRange();

	// Handles removing expanded selection before inserting new text
	if ( !range.isCollapsed() ) {
		// Pull annotations from the first character in the selection
		annotations = documentModel.data.getAnnotationsFromRange(
			new ve.Range( range.start, range.start + 1 )
		);
		if ( !this.documentView.rangeInsideOneLeafNode( range ) ) {
			this.model.change(
				ve.dm.Transaction.newFromRemoval(
					this.documentView.model,
					range
				),
				new ve.dm.LinearSelection( documentModel, new ve.Range( range.start ) )
			);
			hasChanged = true;
			this.surfaceObserver.clear();
			range = this.model.getSelection().getRange();
		}
		this.model.setInsertionAnnotations( annotations );
	}

	if ( hasChanged ) {
		this.surfaceObserver.stopTimerLoop();
		this.surfaceObserver.pollOnce();
	}
};

/**
 * Handle enter key down events with a linear selection.
 *
 * @param {jQuery.Event} e Enter key down event
 */
ve.ce.Surface.prototype.handleLinearEnter = function ( e ) {
	var txRemove, txInsert, outerParent, outerChildrenCount, list, prevContentOffset,
		insertEmptyParagraph, node,
		range = this.model.getSelection().getRange(),
		cursor = range.from,
		documentModel = this.model.getDocument(),
		emptyParagraph = [{ type: 'paragraph' }, { type: '/paragraph' }],
		advanceCursor = true,
		stack = [],
		outermostNode = null,
		nodeModel = null,
		nodeModelRange = null;

	// Handle removal first
	if ( !range.isCollapsed() ) {
		txRemove = ve.dm.Transaction.newFromRemoval( documentModel, range );
		range = txRemove.translateRange( range );
		// We do want this to propagate to the surface
		this.model.change( txRemove, new ve.dm.LinearSelection( documentModel, range ) );
	}

	node = this.documentView.getBranchNodeFromOffset( range.from );
	if ( node !== null ) {
		// assertion: node is certainly a contentBranchNode
		nodeModel = node.getModel();
		nodeModelRange = nodeModel.getRange();
	}

	if (node && node.handleEnter) {
		node.handleEnter(this, range.from);
		this.surfaceObserver.clear();
		return;
	}

	// Handle insertion
	if ( node === null ) {
		throw new Error( 'node === null' );
	} else if (
		nodeModel.getType() !== 'paragraph' &&
		(
			cursor === nodeModelRange.from ||
			cursor === nodeModelRange.to
		)
	) {
		// If we're at the start/end of something that's not a paragraph, insert a paragraph
		// before/after. Insert after for empty nodes (from === to).
		if ( cursor === nodeModelRange.to ) {
			txInsert = ve.dm.Transaction.newFromInsertion(
				documentModel, nodeModel.getOuterRange().to, emptyParagraph
			);
		} else if ( cursor === nodeModelRange.from ) {
			txInsert = ve.dm.Transaction.newFromInsertion(
				documentModel, nodeModel.getOuterRange().from, emptyParagraph
			);
			advanceCursor = false;
		}
	} else if ( e.shiftKey && nodeModel.hasSignificantWhitespace() ) {
		// Insert newline
		txInsert = ve.dm.Transaction.newFromInsertion( documentModel, range.from, '\n' );
	} else if ( !node.splitOnEnter() ) {
		// Cannot split, so insert some appropriate node

		insertEmptyParagraph = false;
		if ( documentModel.hasSlugAtOffset( range.from ) ) {
			insertEmptyParagraph = true;
		} else {
			prevContentOffset = documentModel.data.getNearestContentOffset(
				cursor,
				-1
			);
			if ( prevContentOffset === -1 ) {
				insertEmptyParagraph = true;
			}
		}

		if ( insertEmptyParagraph ) {
			txInsert = ve.dm.Transaction.newFromInsertion(
				documentModel, cursor, emptyParagraph
			);
		} else {
			// Act as if cursor were at previous content offset
			cursor = prevContentOffset;
			node = this.documentView.getBranchNodeFromOffset( cursor );
			txInsert = undefined;
			// Continue to traverseUpstream below. That will succeed because all
			// ContentBranchNodes have splitOnEnter === true.
			// HACK / WIP: we want to be able to veto the split behavior in certain cases
			// which are not covered by the current impl.
			// Particularly we want to use ce.ContentBranchNode as it solves the rendering
			// of annotated text, but allow splitOnEnter = false
			return;
		}
		insertEmptyParagraph = undefined;
	}

	// Assertion: if txInsert === undefined then node.splitOnEnter() === true

	if ( txInsert === undefined ) {
		// This node has splitOnEnter = true. Traverse upstream until the first node
		// that has splitOnEnter = false, splitting each node as it is reached. Set
		// outermostNode to the last splittable node.

		node.traverseUpstream( function ( node ) {
			if ( !node.splitOnEnter() ) {
				return false;
			}
			stack.splice(
				stack.length / 2,
				0,
				{ type: '/' + node.type },
				node.getModel().getClonedElement()
			);
			outermostNode = node;
			if ( e.shiftKey ) {
				return false;
			} else {
				return true;
			}
		} );

		outerParent = outermostNode.getModel().getParent();
		outerChildrenCount = outerParent.getChildren().length;

		if (
			// This is a list item
			outermostNode.type === 'listItem' &&
			// This is the last list item
			outerParent.getChildren()[outerChildrenCount - 1] === outermostNode.getModel() &&
			// There is one child
			outermostNode.children.length === 1 &&
			// The child is empty
			node.getModel().length === 0
		) {
			// Enter was pressed in an empty list item.
			list = outermostNode.getModel().getParent();
			if ( list.getChildren().length === 1 ) {
				// The list item we're about to remove is the only child of the list
				// Remove the list
				txInsert = ve.dm.Transaction.newFromRemoval(
					documentModel, list.getOuterRange()
				);
			} else {
				// Remove the list item
				txInsert = ve.dm.Transaction.newFromRemoval(
					documentModel, outermostNode.getModel().getOuterRange()
				);
				this.model.change( txInsert );
				range = txInsert.translateRange( range );
				// Insert a paragraph
				txInsert = ve.dm.Transaction.newFromInsertion(
					documentModel, list.getOuterRange().to, emptyParagraph
				);
			}
			advanceCursor = false;
		} else {
			// We must process the transaction first because getRelativeContentOffset can't help us yet
			txInsert = ve.dm.Transaction.newFromInsertion( documentModel, range.from, stack );
		}
	}

	// Commit the transaction
	this.model.change( txInsert );
	range = txInsert.translateRange( range );

	// Now we can move the cursor forward
	if ( advanceCursor ) {
		cursor = documentModel.data.getRelativeContentOffset( range.from, 1 );
	} else {
		cursor = documentModel.data.getNearestContentOffset( range.from );
	}
	if ( cursor === -1 ) {
		// Cursor couldn't be placed in a nearby content node, so create an empty paragraph
		this.model.change(
			ve.dm.Transaction.newFromInsertion(
				documentModel, range.from, emptyParagraph
			)
		);
		this.model.setLinearSelection( new ve.Range( range.from + 1 ) );
	} else {
		this.model.setLinearSelection( new ve.Range( cursor ) );
	}
	// Reset and resume polling
	this.surfaceObserver.clear();
};

/**
 * Handle enter key down events with a table selection.
 *
 * @param {jQuery.Event} e Enter key down event
 */
ve.ce.Surface.prototype.handleTableEnter = function ( e ) {
	var selection = this.getModel().getSelection(),
		tableNode = this.documentView.getBranchNodeFromOffset( selection.tableRange.start + 1 );

	e.preventDefault();
	tableNode.setEditing( true );
};

/**
 * Handle delete and backspace key down events with a linear selection.
 *
 * The handler just schedules a poll to observe the native content removal, unless
 * one of the following is true:
 * - The ctrlKey is down; or
 * - The selection is expanded; or
 * - We are directly adjacent to an element node in the deletion direction.
 * In these cases, it will perform the content removal itself.
 *
 * @param {jQuery.Event} e Delete key down event
 * @return {boolean} Whether the content was removed by this method
 */
ve.ce.Surface.prototype.handleLinearDelete = function ( e ) {
	var docLength, startNode, tableEditingRange,
		documentModelSelectedNodes, i, node, nodeOuterRange, matrix,
		direction = e.keyCode === OO.ui.Keys.DELETE ? 1 : -1,
		unit = ( e.altKey === true || e.ctrlKey === true ) ? 'word' : 'character',
		offset = 0,
		rangeToRemove = this.getModel().getSelection().getRange(),
		documentModel = this.getModel().getDocument(),
		data = documentModel.data;

	if ( rangeToRemove.isCollapsed() ) {
		// Use native behaviour then poll, unless we are adjacent to some element (or CTRL
		// is down, in which case we can't reliably predict whether the native behaviour
		// would delete far enough to remove some element)
		offset = rangeToRemove.start;
		if ( !e.ctrlKey && (
			( direction === -1 && !data.isElementData( offset - 1 ) ) ||
			( direction === 1 && !data.isElementData( offset ) )
		) ) {
			this.eventSequencer.afterOne( {
				keydown: this.surfaceObserver.pollOnce.bind( this.surfaceObserver )
			} );
			return false;
		}

		// In case when the range is collapsed use the same logic that is used for cursor left and
		// right movement in order to figure out range to remove.
		rangeToRemove = documentModel.getRelativeRange( rangeToRemove, direction, unit, true );
		tableEditingRange = this.getActiveTableNode() ? this.getActiveTableNode().getEditingRange() : null;
		if ( tableEditingRange && !tableEditingRange.containsRange( rangeToRemove ) ) {
			return true;
		}

		// Prevent backspacing/deleting over table cells, select the cell instead
		documentModelSelectedNodes = documentModel.selectNodes( rangeToRemove, 'siblings' );
		for ( i = 0; i < documentModelSelectedNodes.length; i++ ) {
			node = documentModelSelectedNodes[ i ].node;
			nodeOuterRange = documentModelSelectedNodes[ i ].nodeOuterRange;
			if ( node instanceof ve.dm.TableNode ) {
				if ( rangeToRemove.containsOffset( nodeOuterRange.start ) ) {
					this.getModel().setSelection( new ve.dm.TableSelection(
						documentModel, nodeOuterRange, 0, 0
					) );
				} else {
					matrix = node.getMatrix();
					this.getModel().setSelection( new ve.dm.TableSelection(
						documentModel, nodeOuterRange, matrix.getColCount() - 1, matrix.getRowCount() - 1
					) );
				}
				return true;
			}
		}

		offset = rangeToRemove.start;
		docLength = data.getLength();
		if ( offset < docLength ) {
			while ( offset < docLength && data.isCloseElementData( offset ) ) {
				offset++;
			}
			// If the user tries to delete a focusable node from a collapsed selection,
			// just select the node and cancel the deletion.
			startNode = documentModel.getDocumentNode().getNodeFromOffset( offset + 1 );
			if ( startNode.isFocusable() ) {
				this.getModel().setLinearSelection( startNode.getOuterRange() );
				return true;
			}
		}
		if ( rangeToRemove.isCollapsed() ) {
			// For instance beginning or end of the document.
			return true;
		}
	}

	this.getModel().getLinearFragment( rangeToRemove, true ).delete( direction ).select();
	// Rerender selection even if it didn't change
	// TODO: is any of this necessary?
	this.focus();
	this.surfaceObserver.clear();
	return true;
};

/**
 * Handle delete and backspace key down events with a table selection.
 *
 * Performs a strip-delete removing all the cell contents but not altering the structure.
 *
 * @param {jQuery.Event} e Delete key down event
 */
ve.ce.Surface.prototype.handleTableDelete = function () {
	var i, l,
		surfaceModel = this.getModel(),
		fragments = [],
		ranges = surfaceModel.getSelection().getRanges();

	for ( i = 0, l = ranges.length; i < l; i++ ) {
		// Create auto-updating fragments from ranges
		fragments.push( surfaceModel.getLinearFragment( ranges[i], true ) );
	}

	for ( i = 0, l = fragments.length; i < l; i++ ) {
		// Replace contents with empty wrapper paragraphs
		fragments[i].insertContent( [
			{ type: 'paragraph', internal: { generated: 'wrapper' } },
			{ type: '/paragraph' }
		] );
	}
};

/**
 * Handle escape key down events with a linear selection while table editing.
 *
 * @param {jQuery.Event} e Delete key down event
 */
ve.ce.Surface.prototype.handleTableEditingEscape = function ( e ) {
	e.preventDefault();
	e.stopPropagation();
	this.getActiveTableNode().setEditing( false );
};

/**
 * Get an approximate range covering data visible in the viewport
 *
 * It is assumed that vertical offset increases as you progress through the DM.
 * Items with custom positioning may throw off results given by this method, so
 * it should only be treated as an approximation.
 *
 * @return {ve.Range} Range covering data visible in the viewport
 */
ve.ce.Surface.prototype.getViewportRange = function () {
	var surface = this,
		documentModel = this.getModel().getDocument(),
		data = documentModel.data,
		surfaceRect = this.getSurface().getBoundingClientRect(),
		padding = 50,
		top = Math.max( this.surface.toolbarHeight - surfaceRect.top - padding, 0 ),
		bottom = top + this.$window.height() - this.surface.toolbarHeight + ( padding * 2 ),
		documentRange = new ve.Range( 0, this.getModel().getDocument().getInternalList().getListNode().getOuterRange().start );

	function binarySearch( offset, range, side ) {
		var mid, rect,
			start = range.start,
			end = range.end,
			lastLength = Infinity;
		while ( range.getLength() < lastLength ) {
			lastLength = range.getLength();
			mid = data.getNearestContentOffset(
				Math.round( ( range.start + range.end ) / 2 )
			);
			rect = surface.getSelectionBoundingRect( new ve.dm.LinearSelection( documentModel, new ve.Range( mid ) ) );
			if ( rect[side] > offset ) {
				end = mid;
				range = new ve.Range( range.start, end );
			} else {
				start = mid;
				range = new ve.Range( start, range.end );
			}
		}
		return side === 'bottom' ? start : end;
	}

	return new ve.Range(
		binarySearch( top, documentRange, 'bottom' ),
		binarySearch( bottom, documentRange, 'top' )
	);
};

/**
 * Show selection
 *
 * @method
 * @param {ve.dm.Selection} selection Selection to show
 */
ve.ce.Surface.prototype.showSelection = function ( selection ) {
	if ( this.deactivated ) {
		// Defer until view has updated
		setTimeout( this.updateDeactivatedSelection.bind( this ) );
		return;
	}

	if (
		!( selection instanceof ve.dm.LinearSelection ) ||
		this.focusedNode ||
		this.focusedBlockSlug
	) {
		return;
	}

	var endRange, oldRange, $node,
		range = selection.getRange(),
		rangeSelection = this.getRangeSelection( range ),
		nativeRange = this.getElementDocument().createRange();

	nativeRange.setStart( rangeSelection.start.node, rangeSelection.start.offset );
	if ( rangeSelection.end ) {
		nativeRange.setEnd( rangeSelection.end.node, rangeSelection.end.offset );
	}
	if ( rangeSelection.end && rangeSelection.isBackwards && this.nativeSelection.extend ) {
		endRange = nativeRange.cloneRange();
		endRange.collapse( false );
		this.nativeSelection.removeAllRanges();
		this.nativeSelection.addRange( endRange );
		try {
			this.nativeSelection.extend( nativeRange.startContainer, nativeRange.startOffset );
		} catch ( e ) {
			// Firefox sometimes fails when nodes are different,
			// see https://bugzilla.mozilla.org/show_bug.cgi?id=921444
			this.nativeSelection.addRange( nativeRange );
		}
	} else if ( !(
		this.nativeSelection.rangeCount > 0 &&
		( oldRange = this.nativeSelection.getRangeAt( 0 ) ) &&
		oldRange.startContainer === nativeRange.startContainer &&
		oldRange.startOffset === nativeRange.startOffset &&
		oldRange.endContainer === nativeRange.endContainer &&
		oldRange.endOffset === nativeRange.endOffset
	) ) {
		// Genuine selection change: apply it.
		// TODO: this is slightly too zealous, because a cursor position at a node edge
		// can have more than one (container,offset) representation
		this.nativeSelection.removeAllRanges();
		this.nativeSelection.addRange( nativeRange );
	} else {
		// Not a selection change: don't needlessly reapply the same selection.
		return;
	}

	// Setting a range doesn't give focus in all browsers so make sure this happens
	// Also set focus after range to prevent scrolling to top
	if ( !OO.ui.contains( this.getElementDocument().activeElement, rangeSelection.start.node, true ) ) {
		$( rangeSelection.start.node ).closest( '[contenteditable=true]' ).focus();
	} else {
		$node = $( rangeSelection.start.node ).closest( '*' );
		// Scroll the node into view
		OO.ui.Element.static.scrollIntoView( $node.get( 0 ) );
	}
};

/**
 * Get selection for a range.
 *
 * @method
 * @param {ve.Range} range Range to get selection for
 * @returns {Object} Object containing start and end node/offset selections, and an isBackwards flag.
 */
ve.ce.Surface.prototype.getRangeSelection = function ( range ) {
	range = new ve.Range(
		this.getNearestCorrectOffset( range.from, -1 ),
		this.getNearestCorrectOffset( range.to, 1 )
	);

	if ( !range.isCollapsed() ) {
		return {
			start: this.documentView.getNodeAndOffset( range.start ),
			end: this.documentView.getNodeAndOffset( range.end ),
			isBackwards: range.isBackwards()
		};
	} else {
		return {
			start: this.documentView.getNodeAndOffset( range.start )
		};
	}
};

/**
 * Get a native range object for a specified range
 *
 * Native ranges are only used by linear selections.
 *
 * Doesn't correct backwards selection so should be used for measurement only.
 *
 * @param {ve.Range} [range] Optional range to get the native range for, defaults to current selection's range
 * @return {Range|null} Native range object, or null if there is no suitable selection
 */
ve.ce.Surface.prototype.getNativeRange = function ( range ) {
	var nativeRange, rangeSelection,
		selection = this.getModel().getSelection();

	if (
		range && !this.deactivated &&
		selection instanceof ve.dm.LinearSelection && selection.getRange().equalsSelection( range )
	) {
		// Range requested is equivalent to native selection so reset
		range = null;
	}
	if ( !range ) {
		// Use native range, unless selection is null
		if ( !( selection instanceof ve.dm.LinearSelection ) ) {
			return null;
		}
		if ( this.nativeSelection.rangeCount > 0 ) {
			try {
				return this.nativeSelection.getRangeAt( 0 );
			} catch ( e ) {}
		}
		return null;
	}

	nativeRange = document.createRange();
	rangeSelection = this.getRangeSelection( range );

	nativeRange.setStart( rangeSelection.start.node, rangeSelection.start.offset );
	if ( rangeSelection.end ) {
		nativeRange.setEnd( rangeSelection.end.node, rangeSelection.end.offset );
	}
	return nativeRange;
};

/**
 * Append passed highlights to highlight container.
 *
 * @method
 * @param {jQuery} $highlights Highlights to append
 * @param {boolean} focused Highlights are currently focused
 */
ve.ce.Surface.prototype.appendHighlights = function ( $highlights, focused ) {
	// Only one item can be blurred-highlighted at a time, so remove the others.
	// Remove by detaching so they don't lose their event handlers, in case they
	// are attached again.
	this.$highlightsBlurred.children().detach();
	if ( focused ) {
		this.$highlightsFocused.append( $highlights );
	} else {
		this.$highlightsBlurred.append( $highlights );
	}
};

/*! Helpers */

/**
 * Get the nearest offset that a cursor can be placed at.
 *
 * TODO: Find a better name and a better place for this method
 *
 * @method
 * @param {number} offset Offset to start looking at
 * @param {number} [direction=-1] Direction to look in, +1 or -1
 * @returns {number} Nearest offset a cursor can be placed at
 */
ve.ce.Surface.prototype.getNearestCorrectOffset = function ( offset, direction ) {
	var contentOffset, structuralOffset,
		documentModel = this.getModel().getDocument(),
		data = documentModel.data;

	direction = direction > 0 ? 1 : -1;
	if (
		data.isContentOffset( offset ) ||
		documentModel.hasSlugAtOffset( offset )
	) {
		return offset;
	}

	contentOffset = data.getNearestContentOffset( offset, direction );
	structuralOffset = data.getNearestStructuralOffset( offset, direction, true );

	if ( !documentModel.hasSlugAtOffset( structuralOffset ) && contentOffset !== -1 ) {
		return contentOffset;
	}

	if ( direction === 1 ) {
		if ( contentOffset < offset ) {
			return structuralOffset;
		} else {
			return Math.min( contentOffset, structuralOffset );
		}
	} else {
		if ( contentOffset > offset ) {
			return structuralOffset;
		} else {
			return Math.max( contentOffset, structuralOffset );
		}
	}
};

/*! Getters */

/**
 * Get the top-level surface.
 *
 * @method
 * @returns {ve.ui.Surface} Surface
 */
ve.ce.Surface.prototype.getSurface = function () {
	return this.surface;
};

/**
 * Get the surface model.
 *
 * @method
 * @returns {ve.dm.Surface} Surface model
 */
ve.ce.Surface.prototype.getModel = function () {
	return this.model;
};

/**
 * Get the document view.
 *
 * @method
 * @returns {ve.ce.Document} Document view
 */
ve.ce.Surface.prototype.getDocument = function () {
	return this.documentView;
};

/**
 * Check whether there are any render locks
 *
 * @method
 * @returns {boolean} Render is locked
 */
ve.ce.Surface.prototype.isRenderingLocked = function () {
	return this.renderLocks > 0;
};

/**
 * Add a single render lock (to disable rendering)
 *
 * @method
 */
ve.ce.Surface.prototype.incRenderLock = function () {
	this.renderLocks++;
};

/**
 * Remove a single render lock
 *
 * @method
 */
ve.ce.Surface.prototype.decRenderLock = function () {
	this.renderLocks--;
};

/**
 * Change the model only, not the CE surface
 *
 * This avoids event storms when the CE surface is already correct
 *
 * @method
 * @param {ve.dm.Transaction|ve.dm.Transaction[]|null} transactions One or more transactions to
 * process, or null to process none
 * @param {ve.dm.Selection} selection New selection
 * @throws {Error} If calls to this method are nested
 */
ve.ce.Surface.prototype.changeModel = function ( transaction, selection ) {
	if ( this.newModelSelection !== null ) {
		throw new Error( 'Nested change of newModelSelection' );
	}
	this.newModelSelection = selection;
	try {
		this.model.change( transaction, selection );
	} finally {
		this.newModelSelection = null;
	}
};

/**
 * Inform the surface that one of its ContentBranchNodes' rendering has changed.
 * @see ve.ce.ContentBranchNode#renderContents
 */
ve.ce.Surface.prototype.setContentBranchNodeChanged = function () {
	this.contentBranchNodeChanged = true;
	this.cursorEvent = null;
	this.cursorStartRange = null;
};

/**
 * Set the node that has the current unicorn.
 *
 * If another node currently has a unicorn, it will be rerendered, which will
 * cause it to release its unicorn.
 *
 * @param {ve.ce.ContentBranchNode} node The node claiming the unicorn
 */
ve.ce.Surface.prototype.setUnicorning = function ( node ) {
	if ( this.setUnicorningRecursionGuard ) {
		throw new Error( 'setUnicorning recursing' );
	}
	if ( this.unicorningNode && this.unicorningNode !== node ) {
		this.setUnicorningRecursionGuard = true;
		try {
			this.unicorningNode.renderContents();
		} finally {
			this.setUnicorningRecursionGuard = false;
		}
	}
	this.unicorningNode = node;
};

/**
 * Release the current unicorn held by a given node.
 *
 * If the node doesn't hold the current unicorn, nothing happens.
 * This function does not cause any node to be rerendered.
 *
 * @param {ve.ce.ContentBranchNode} node The node releasing the unicorn
 */
ve.ce.Surface.prototype.setNotUnicorning = function ( node ) {
	if ( this.unicorningNode === node ) {
		this.unicorningNode = null;
	}
};

/**
 * Ensure that no node has a unicorn.
 *
 * If the given node currently has the unicorn, it will be released and
 * no rerender will happen. If another node has the unicorn, that node
 * will be rerendered to get rid of the unicorn.
 *
 * @param {ve.ce.ContentBranchNode} node The node releasing the unicorn
 */
ve.ce.Surface.prototype.setNotUnicorningAll = function ( node ) {
	if ( this.unicorningNode === node ) {
		// Don't call back node.renderContents()
		this.unicorningNode = null;
	}
	this.setUnicorning( null );
};

ve.ce.Surface.prototype.setScrollPosition = function ( pos ) {
	this.$window.scrollTop(pos);
};

ve.ce.Surface.prototype.getScrollPosition = function () {
	return this.$window.scrollTop();
};

/*!
 * VisualEditor ContentEditable Surface class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable surface observer.
 *
 * @class
 * @mixins OO.EventEmitter
 *
 * @constructor
 * @param {ve.ce.Surface} surface Surface to observe
 */
ve.ce.SurfaceObserver = function VeCeSurfaceObserver( surface ) {
	// Mixin constructors
	OO.EventEmitter.call( this );

	// Properties
	this.surface = surface;
	this.documentView = surface.getDocument();
	this.domDocument = this.documentView.getDocumentNode().getElementDocument();
	this.polling = false;
	this.disabled = false;
	this.timeoutId = null;
	this.pollInterval = 250; // ms
	this.rangeState = null;
};

/* Inheritance */

OO.mixinClass( ve.ce.SurfaceObserver, OO.EventEmitter );

/* Events */

/**
 * When #poll sees a change this event is emitted (before the
 * properties are updated).
 *
 * @event contentChange
 * @param {HTMLElement} node DOM node the change occurred in
 * @param {Object} previous Old data
 * @param {Object} previous.text Old plain text content
 * @param {Object} previous.hash Old DOM hash
 * @param {ve.Range} previous.range Old selection
 * @param {Object} next New data
 * @param {Object} next.text New plain text content
 * @param {Object} next.hash New DOM hash
 * @param {ve.Range} next.range New selection
 */

/**
 * When #poll observes a change in the document and the new selection anchor
 * branch node does not equal the last known one, this event is emitted.
 *
 * @event branchNodeChange
 * @param {ve.ce.BranchNode} oldBranchNode
 * @param {ve.ce.BranchNode} newBranchNode
 */

/**
 * When #poll observes a change in the document and the new selection does
 * not equal the last known selection, this event is emitted (before the
 * properties are updated).
 *
 * @event rangeChange
 * @param {ve.Range|null} oldRange Old range
 * @param {ve.Range|null} newRange New range
 */

/* Methods */

/**
 * Clear polling data.
 *
 * @method
 */
ve.ce.SurfaceObserver.prototype.clear = function () {
	this.rangeState = null;
};

/**
 * Detach from the document view
 *
 * @method
 */
ve.ce.SurfaceObserver.prototype.detach = function () {
	this.surface = null;
	this.documentView = null;
	this.domDocument = null;
};

/**
 * Start the setTimeout synchronisation loop
 *
 * @method
 */
ve.ce.SurfaceObserver.prototype.startTimerLoop = function () {
	this.polling = true;
	this.timerLoop( true ); // will not sync immediately, because timeoutId should be null
};

/**
 * Loop once with `setTimeout`
 * @method
 * @param {boolean} firstTime Wait before polling
 */
ve.ce.SurfaceObserver.prototype.timerLoop = function ( firstTime ) {
	if ( this.timeoutId ) {
		// in case we're not running from setTimeout
		clearTimeout( this.timeoutId );
		this.timeoutId = null;
	}
	if ( !firstTime ) {
		this.pollOnce();
	}
	// only reach this point if pollOnce does not throw an exception
	if ( this.pollInterval !== null ) {
		this.timeoutId = this.setTimeout(
			this.timerLoop.bind( this ),
			this.pollInterval
		);
	}
};

/**
 * Stop polling
 *
 * @method
 */
ve.ce.SurfaceObserver.prototype.stopTimerLoop = function () {
	if ( this.polling === true ) {
		this.polling = false;
		clearTimeout( this.timeoutId );
		this.timeoutId = null;
	}
};

/**
 * Disable the surface observer
 */
ve.ce.SurfaceObserver.prototype.disable = function () {
	this.disabled = true;
};

/**
 * Enable the surface observer
 */
ve.ce.SurfaceObserver.prototype.enable = function () {
	this.disabled = false;
};

/**
 * Poll for changes.
 *
 * TODO: fixing selection in certain cases, handling selection across multiple nodes in Firefox
 *
 * @method
 * @fires contentChange
 * @fires rangeChange
 */
ve.ce.SurfaceObserver.prototype.pollOnce = function () {
	this.pollOnceInternal( true );
};

/**
 * Poll to update SurfaceObserver, but don't emit change events
 *
 * @method
 */
ve.ce.SurfaceObserver.prototype.pollOnceNoEmit = function () {
	this.pollOnceInternal( false );
};

/**
 * Poll to update SurfaceObserver, but only check for selection changes
 *
 * Used as an optimisation when you know the content hasn't changed
 *
 * @method
 */
ve.ce.SurfaceObserver.prototype.pollOnceSelection = function () {
	this.pollOnceInternal( true, true );
};

/**
 * Poll for changes.
 *
 * TODO: fixing selection in certain cases, handling selection across multiple nodes in Firefox
 *
 * @method
 * @private
 * @param {boolean} emitChanges Emit change events if selection changed
 * @param {boolean} selectionOnly Check for selection changes only
 * @fires contentChange
 * @fires rangeChange
 */
ve.ce.SurfaceObserver.prototype.pollOnceInternal = function ( emitChanges, selectionOnly ) {
	var oldState, newState;

	if ( !this.domDocument || this.disabled ) {
		return;
	}

	oldState = this.rangeState;
	newState = new ve.ce.RangeState(
		oldState,
		this.documentView.getDocumentNode(),
		selectionOnly
	);

	this.rangeState = newState;

	if ( !selectionOnly && newState.node !== null && newState.contentChanged && emitChanges ) {
		this.emit(
			'contentChange',
			newState.node,
			{ text: oldState.text, hash: oldState.hash, range: oldState.veRange },
			{ text: newState.text, hash: newState.hash, range: newState.veRange }
		);
	}

	if ( newState.branchNodeChanged ) {
		this.emit(
			'branchNodeChange',
			( oldState && oldState.node && oldState.node.root ? oldState.node : null ),
			newState.node
		);
	}

	if ( newState.selectionChanged && emitChanges ) {
		this.emit(
			'rangeChange',
			( oldState ? oldState.veRange : null ),
			newState.veRange
		);
	}
};

/**
 * Wrapper for setTimeout, for ease of debugging
 *
 * @param {Function} callback Callback
 * @param {number} timeout Timeout ms
 */
ve.ce.SurfaceObserver.prototype.setTimeout = function ( callback, timeout ) {
	return setTimeout( callback, timeout );
};

/**
 * Get the range last observed.
 *
 * Used when you have just polled, but don't want to wait for a 'rangeChange' event.
 *
 * @return {ve.Range} Range
 */
ve.ce.SurfaceObserver.prototype.getRange = function () {
	if ( !this.rangeState ) {
		return null;
	}
	return this.rangeState.veRange;
};

/*!
 * VisualEditor ContentEditable GeneratedContentNode class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable generated content node.
 *
 * @class
 * @abstract
 *
 * @constructor
 */
ve.ce.GeneratedContentNode = function VeCeGeneratedContentNode() {
	// Properties
	this.generatingPromise = null;

	// Events
	this.model.connect( this, { update: 'onGeneratedContentNodeUpdate' } );
	this.connect( this, { teardown: 'abortGenerating' } );

	// Initialization
	this.update();
};

/* Inheritance */

OO.initClass( ve.ce.GeneratedContentNode );

/* Events */

/**
 * @event setup
 */

/**
 * @event teardown
 */

/**
 * @event rerender
 */

/* Static members */

// We handle rendering ourselves, no need to render attributes from originalDomElements
ve.ce.GeneratedContentNode.static.renderHtmlAttributes = false;

/* Abstract methods */

/**
 * Start a deferred process to generate the contents of the node.
 *
 * If successful, the returned promise must be resolved with the generated DOM elements passed
 * in as the first parameter, i.e. promise.resolve( domElements ); . Any other parameters to
 * .resolve() are ignored.
 *
 * If the returned promise object is abortable (has an .abort() method), .abort() will be called if
 * a newer update is started before the current update has finished. When a promise is aborted, it
 * should cease its work and shouldn't be resolved or rejected. If an outdated update's promise
 * is resolved or rejected anyway (which may happen if an aborted promise misbehaves, or if the
 * promise wasn't abortable), this is ignored and doneGenerating()/failGenerating() is not called.
 *
 * Additional data may be passed in the config object to instruct this function to render something
 * different than what's in the model. This data is implementation-specific and is passed through
 * by forceUpdate().
 *
 * @abstract
 * @param {Object} [config] Optional additional data
 * @returns {jQuery.Promise} Promise object, may be abortable
 */
ve.ce.GeneratedContentNode.prototype.generateContents = function () {
	throw new Error( 've.ce.GeneratedContentNode subclass must implement generateContents' );
};

/* Methods */

/**
 * Handler for the update event
 */
ve.ce.GeneratedContentNode.prototype.onGeneratedContentNodeUpdate = function () {
	this.update();
};

/**
 * Make an array of DOM elements suitable for rendering.
 *
 * Subclasses can override this to provide their own cleanup steps. This function takes an
 * array of DOM elements cloned within the source document and returns an array of DOM elements
 * cloned into the target document. If it's important that the DOM elements still be associated
 * with the original document, you should modify domElements before calling the parent
 * implementation, otherwise you should call the parent implementation first and modify its
 * return value.
 *
 * @param {HTMLElement[]} domElements Clones of the DOM elements from the store
 * @returns {HTMLElement[]} Clones of the DOM elements in the right document, with modifications
 */
ve.ce.GeneratedContentNode.prototype.getRenderedDomElements = function ( domElements ) {
	var i, len, attr, $rendering,
		doc = this.getElementDocument();

	/**
	 * Callback for jQuery.fn.each that resolves the value of attr to the computed
	 * property value. Called in the context of an HTMLElement.
	 * @private
	 */
	function resolveAttribute() {
		var origDoc = domElements[0].ownerDocument,
			nodeInOrigDoc = origDoc.createElement( this.nodeName );
		nodeInOrigDoc.setAttribute( attr, this.getAttribute( attr ) );
		this.setAttribute( attr, nodeInOrigDoc[attr] );
	}

	// Clone the elements into the target document
	$rendering = $( ve.copyDomElements( domElements, doc ) );

	// Filter out link and style tags for bug 50043
	// Previously filtered out meta tags, but restore these as they
	// can be made visible.
	$rendering = $rendering.not( 'link, style' );
	// Also remove link and style tags nested inside other tags
	$rendering.find( 'link, style' ).remove();

	if ( $rendering.length ) {
		// Span wrap root text nodes so they can be measured
		for ( i = 0, len = $rendering.length; i < len; i++ ) {
			if ( $rendering[i].nodeType === Node.TEXT_NODE ) {
				$rendering[i] = this.$( '<span>' ).append( $rendering[i] )[0];
			}
		}
	} else {
		$rendering = this.$( '<span>' );
	}

	// Render the computed values of some attributes
	for ( i = 0, len = ve.dm.Converter.computedAttributes.length; i < len; i++ ) {
		attr = ve.dm.Converter.computedAttributes[i];
		$rendering.find( '[' + attr + ']' ).each( resolveAttribute );
		$rendering.filter( '[' + attr + ']' ).each( resolveAttribute );
	}

	return $rendering.toArray();
};

/**
 * Rerender the contents of this node.
 *
 * @param {Object|string|Array} generatedContents Generated contents, in the default case an HTMLElement array
 * @fires setup
 * @fires teardown
 */
ve.ce.GeneratedContentNode.prototype.render = function ( generatedContents ) {
	if ( this.live ) {
		this.emit( 'teardown' );
	}
	var $newElements = this.$( this.getRenderedDomElements( ve.copyDomElements( generatedContents ) ) );
	if ( !this.$element[0].parentNode ) {
		// this.$element hasn't been attached yet, so just overwrite it
		this.$element = $newElements;
	} else {
		// Switch out this.$element (which can contain multiple siblings) in place
		this.$element.first().replaceWith( $newElements );
		this.$element.remove();
		this.$element = $newElements;
	}

	// Update focusable and resizable elements if necessary
	if ( this.$focusable ) {
		this.$focusable = this.getFocusableElement();
	}
	if ( this.$resizable ) {
		this.$resizable = this.getResizableElement();
	}

	if ( this.live ) {
		this.emit( 'setup' );
	}

	this.afterRender();
};

/**
 * Trigger rerender events after rendering the contents of the node.
 *
 * Nodes may override this method if the rerender event needs to be deferred (e.g. until images have loaded)
 *
 * @fires rerender
 */
ve.ce.GeneratedContentNode.prototype.afterRender = function () {
	this.emit( 'rerender' );
};

/**
 * Update the contents of this node based on the model and config data. If this combination of
 * model and config data has been rendered before, the cached rendering in the store will be used.
 *
 * @param {Object} [config] Optional additional data to pass to generateContents()
 */
ve.ce.GeneratedContentNode.prototype.update = function ( config ) {
	var store = this.model.doc.getStore(),
		index = store.indexOfHash( OO.getHash( [ this.model, config ] ) );
	if ( index !== null ) {
		this.render( store.value( index ) );
	} else {
		this.forceUpdate( config );
	}
};

/**
 * Force the contents to be updated. Like update(), but bypasses the store.
 *
 * @param {Object} [config] Optional additional data to pass to generateContents()
 */
ve.ce.GeneratedContentNode.prototype.forceUpdate = function ( config ) {
	var promise, node = this;

	if ( this.generatingPromise ) {
		// Abort the currently pending generation process if possible
		this.abortGenerating();
	} else {
		// Only call startGenerating if we weren't generating before
		this.startGenerating();
	}

	// Create a new promise
	promise = this.generatingPromise = this.generateContents( config );
	promise
		// If this promise is no longer the currently pending one, ignore it completely
		.done( function ( generatedContents ) {
			if ( node.generatingPromise === promise ) {
				node.doneGenerating( generatedContents, config );
			}
		} )
		.fail( function () {
			if ( node.generatingPromise === promise ) {
				node.failGenerating();
			}
		} );
};

/**
 * Called when the node starts generating new content.
 *
 * This function is only called when the node wasn't already generating content. If a second update
 * comes in, this function will only be called if the first update has already finished (i.e.
 * doneGenerating or failGenerating has already been called).
 *
 * @method
 */
ve.ce.GeneratedContentNode.prototype.startGenerating = function () {
	this.$element.addClass( 've-ce-generatedContentNode-generating' );
};

/**
 * Abort the currently pending generation, if any, and remove the generating CSS class.
 *
 * This invokes .abort() on the pending promise if the promise has that method. It also ensures
 * that if the promise does get resolved or rejected later, this is ignored.
 */
ve.ce.GeneratedContentNode.prototype.abortGenerating = function () {
	var promise = this.generatingPromise;
	if ( promise ) {
		// Unset this.generatingPromise first so that if the promise is resolved or rejected
		// from within .abort(), this is ignored as it should be
		this.generatingPromise = null;
		if ( $.isFunction( promise.abort ) ) {
			promise.abort();
		}
	}
	this.$element.removeClass( 've-ce-generatedContentNode-generating' );
};

/**
 * Called when the node successfully finishes generating new content.
 *
 * @method
 * @param {Object|string|Array} generatedContents Generated contents
 * @param {Object} [config] Config object passed to forceUpdate()
 */
ve.ce.GeneratedContentNode.prototype.doneGenerating = function ( generatedContents, config ) {
	var store, hash;

	// Because doneGenerating is invoked asynchronously, the model node may have become detached
	// in the meantime. Handle this gracefully.
	if ( this.model.doc ) {
		store = this.model.doc.getStore();
		hash = OO.getHash( [ this.model, config ] );
		store.index( generatedContents, hash );
	}

	this.$element.removeClass( 've-ce-generatedContentNode-generating' );
	this.generatingPromise = null;
	this.render( generatedContents );
};

/**
 * Called when the GeneratedContentNode has failed to generate new content.
 *
 * @method
 */
ve.ce.GeneratedContentNode.prototype.failGenerating = function () {
	this.$element.removeClass( 've-ce-generatedContentNode-generating' );
	this.generatingPromise = null;
};

/**
 * Check whether this GeneratedContentNode is currently generating new content.
 *
 * @return {boolean} Whether we're generating
 */
ve.ce.GeneratedContentNode.prototype.isGenerating = function () {
	return !!this.generatingPromise;
};

/**
 * Get the focusable element
 *
 * @return {jQuery} Focusable element
 */
ve.ce.GeneratedContentNode.prototype.getFocusableElement = function () {
	return this.$element;
};

/**
 * Get the resizable element
 *
 * @return {jQuery} Resizable element
 */
ve.ce.GeneratedContentNode.prototype.getResizableElement = function () {
	return this.$element;
};

/**
 * Check if the rendering is visible
 *
 * @return {boolean} The rendering is visible
 */
ve.ce.GeneratedContentNode.prototype.isVisible = function () {
	if ( this.$element.text().trim() !== '' ) {
		return true;
	}
	var visible = false;
	this.$element.each( function () {
		var $this = $( this );
		if ( $this.width() >= 8 && $this.height() >= 8 ) {
			visible = true;
			return false;
		}
	} );
	return visible;
};

/*!
 * VisualEditor ContentEditable AlienNode, AlienBlockNode and AlienInlineNode classes.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable alien node.
 *
 * @class
 * @abstract
 * @extends ve.ce.LeafNode
 * @mixins ve.ce.FocusableNode
 *
 * @constructor
 * @param {ve.dm.AlienNode} model
 * @param {Object} [config]
 */
ve.ce.AlienNode = function VeCeAlienNode() {
	// Parent constructor
	ve.ce.AlienNode.super.apply( this, arguments );

	// DOM changes
	this.$element = $( ve.copyDomElements( this.model.getOriginalDomElements(), document ) );

	// Mixin constructors
	ve.ce.FocusableNode.call( this, this.$element, {
		classes: [ 've-ce-alienNode-highlights' ]
	} );
};

/* Inheritance */

OO.inheritClass( ve.ce.AlienNode, ve.ce.LeafNode );

OO.mixinClass( ve.ce.AlienNode, ve.ce.FocusableNode );

/* Static Properties */

ve.ce.AlienNode.static.name = 'alien';

/* Methods */

/**
 * @inheritdoc
 */
ve.ce.AlienNode.static.getDescription = function () {
	return ve.msg( 'visualeditor-aliennode-tooltip' );
};

/* Concrete subclasses */

/**
 * ContentEditable alien block node.
 *
 * @class
 * @extends ve.ce.AlienNode
 *
 * @constructor
 * @param {ve.dm.AlienBlockNode} model
 * @param {Object} [config]
 */
ve.ce.AlienBlockNode = function VeCeAlienBlockNode() {
	// Parent constructor
	ve.ce.AlienBlockNode.super.apply( this, arguments );
};

/* Inheritance */

OO.inheritClass( ve.ce.AlienBlockNode, ve.ce.AlienNode );

/* Static Properties */

ve.ce.AlienBlockNode.static.name = 'alienBlock';

/**
 * ContentEditable alien inline node.
 *
 * @class
 * @extends ve.ce.AlienNode
 *
 * @constructor
 * @param {ve.dm.AlienInlineNode} model
 * @param {Object} [config]
 */
ve.ce.AlienInlineNode = function VeCeAlienInlineNode() {
	// Parent constructor
	ve.ce.AlienInlineNode.super.apply( this, arguments );
};

/* Inheritance */

OO.inheritClass( ve.ce.AlienInlineNode, ve.ce.AlienNode );

/* Static Properties */

ve.ce.AlienInlineNode.static.name = 'alienInline';

/* Registration */

ve.ce.nodeFactory.register( ve.ce.AlienBlockNode );
ve.ce.nodeFactory.register( ve.ce.AlienInlineNode );

/*!
 * VisualEditor ContentEditable BlockquoteNode class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see AUTHORS.txt
 * @license The MIT License (MIT); see LICENSE.txt
 */

/**
 * ContentEditable Blockquote node.
 *
 * @class
 * @extends ve.ce.ContentBranchNode
 * @constructor
 * @param {ve.dm.BlockquoteNode} model Model to observe
 * @param {Object} [config] Configuration options
 */
ve.ce.BlockquoteNode = function VeCeBlockquoteNode( model, config ) {
	// Parent constructor
	ve.ce.ContentBranchNode.call( this, model, config );
};

/* Inheritance */

OO.inheritClass( ve.ce.BlockquoteNode, ve.ce.ContentBranchNode );

/* Static Properties */

ve.ce.BlockquoteNode.static.name = 'blockquote';

ve.ce.BlockquoteNode.static.tagName = 'blockquote';

/* Registration */

ve.ce.nodeFactory.register( ve.ce.BlockquoteNode );

/*!
 * VisualEditor ContentEditable BreakNode class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable break node.
 *
 * @class
 * @extends ve.ce.LeafNode
 * @constructor
 * @param {ve.dm.BreakNode} model Model to observe
 * @param {Object} [config] Configuration options
 */
ve.ce.BreakNode = function VeCeBreakNode() {
	// Parent constructor
	ve.ce.BreakNode.super.apply( this, arguments );

	// DOM changes
	this.$element.addClass( 've-ce-breakNode' );
};

/* Inheritance */

OO.inheritClass( ve.ce.BreakNode, ve.ce.LeafNode );

/* Static Properties */

ve.ce.BreakNode.static.name = 'break';

ve.ce.BreakNode.static.tagName = 'br';

/* Registration */

ve.ce.nodeFactory.register( ve.ce.BreakNode );

/*!
 * VisualEditor ContentEditable CenterNode class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable center node.
 *
 * @class
 * @extends ve.ce.BranchNode
 * @constructor
 * @param {ve.dm.CenterNode} model Model to observe
 * @param {Object} [config] Configuration options
 */
ve.ce.CenterNode = function VeCeCenterNode() {
	// Parent constructor
	ve.ce.CenterNode.super.apply( this, arguments );
};

/* Inheritance */

OO.inheritClass( ve.ce.CenterNode, ve.ce.BranchNode );

/* Static Properties */

ve.ce.CenterNode.static.name = 'center';

ve.ce.CenterNode.static.tagName = 'center';

/* Registration */

ve.ce.nodeFactory.register( ve.ce.CenterNode );

/*!
 * VisualEditor ContentEditable CommentNode class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable comment node.
 *
 * @class
 * @extends ve.ce.LeafNode
 * @mixins ve.ce.FocusableNode
 * @mixins OO.ui.IndicatorElement
 *
 * @constructor
 * @param {ve.dm.CommentNode} model Model to observe
 * @param {Object} [config] Configuration options
 */
ve.ce.CommentNode = function VeCeCommentNode( model, config ) {
	// Parent constructor
	ve.ce.CommentNode.super.call( this, model, config );

	// Mixin constructors
	ve.ce.FocusableNode.call( this, this.$element, config );
	OO.ui.IndicatorElement.call( this, $.extend( {}, config, {
		$indicator: this.$element, indicator: 'alert'
	} ) );

	// DOM changes
	this.$element
		.addClass( 've-ce-commentNode' )
		// Add em space for selection highlighting
		.text( '\u2003' );
};

/* Inheritance */

OO.inheritClass( ve.ce.CommentNode, ve.ce.LeafNode );
OO.mixinClass( ve.ce.CommentNode, ve.ce.FocusableNode );
OO.mixinClass( ve.ce.CommentNode, OO.ui.IndicatorElement );

/* Static Properties */

ve.ce.CommentNode.static.name = 'comment';

ve.ce.CommentNode.static.primaryCommandName = 'comment';

/* Static Methods */

/**
 * @inheritdoc
 */
ve.ce.CommentNode.static.getDescription = function ( model ) {
	return model.getAttribute( 'text' );
};

/* Registration */

ve.ce.nodeFactory.register( ve.ce.CommentNode );

/*!
 * VisualEditor ContentEditable DefinitionListItemNode class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable definition list item node.
 *
 * @class
 * @extends ve.ce.BranchNode
 * @constructor
 * @param {ve.dm.DefinitionListItemNode} model Model to observe
 * @param {Object} [config] Configuration options
 */
ve.ce.DefinitionListItemNode = function VeCeDefinitionListItemNode() {
	// Parent constructor
	ve.ce.DefinitionListItemNode.super.apply( this, arguments );

	// Events
	this.model.connect( this, { update: 'onUpdate' } );
};

/* Inheritance */

OO.inheritClass( ve.ce.DefinitionListItemNode, ve.ce.BranchNode );

/* Static Properties */

ve.ce.DefinitionListItemNode.static.name = 'definitionListItem';

ve.ce.DefinitionListItemNode.static.splitOnEnter = true;

/* Methods */

/**
 * Get the HTML tag name.
 *
 * Tag name is selected based on the model's style attribute.
 *
 * @returns {string} HTML tag name
 * @throws {Error} If style is invalid
 */
ve.ce.DefinitionListItemNode.prototype.getTagName = function () {
	var style = this.model.getAttribute( 'style' ),
		types = { definition: 'dd', term: 'dt' };

	if ( !Object.prototype.hasOwnProperty.call( types, style ) ) {
		throw new Error( 'Invalid style' );
	}
	return types[style];
};

/**
 * Handle model update events.
 *
 * If the style changed since last update the DOM wrapper will be replaced with an appropriate one.
 *
 * @method
 */
ve.ce.DefinitionListItemNode.prototype.onUpdate = function () {
	this.updateTagName();
};

/* Registration */

ve.ce.nodeFactory.register( ve.ce.DefinitionListItemNode );

/*!
 * VisualEditor ContentEditable DefinitionListNode class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable definition list node.
 *
 * @class
 * @extends ve.ce.BranchNode
 * @constructor
 * @param {ve.dm.DefinitionListNode} model Model to observe
 * @param {Object} [config] Configuration options
 */
ve.ce.DefinitionListNode = function VeCeDefinitionListNode() {
	// Parent constructor
	ve.ce.DefinitionListNode.super.apply( this, arguments );
};

/* Inheritance */

OO.inheritClass( ve.ce.DefinitionListNode, ve.ce.BranchNode );

/* Static Properties */

ve.ce.DefinitionListNode.static.name = 'definitionList';

ve.ce.DefinitionListNode.static.tagName = 'dl';

/* Registration */

ve.ce.nodeFactory.register( ve.ce.DefinitionListNode );

/*!
 * VisualEditor ContentEditable DivNode class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable div node.
 *
 * @class
 * @extends ve.ce.BranchNode
 * @constructor
 * @param {ve.dm.DivNode} model Model to observe
 * @param {Object} [config] Configuration options
 */
ve.ce.DivNode = function VeCeDivNode() {
	// Parent constructor
	ve.ce.DivNode.super.apply( this, arguments );
};

/* Inheritance */

OO.inheritClass( ve.ce.DivNode, ve.ce.BranchNode );

/* Static Properties */

ve.ce.DivNode.static.name = 'div';

/* Registration */

ve.ce.nodeFactory.register( ve.ce.DivNode );

/*!
 * VisualEditor ContentEditable DocumentNode class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable document node.
 *
 * @class
 * @extends ve.ce.BranchNode
 * @constructor
 * @param {ve.dm.DocumentNode} model Model to observe
 * @param {ve.ce.Surface} surface Surface document is part of
 * @param {Object} [config] Configuration options
 */
ve.ce.DocumentNode = function VeCeDocumentNode( model, surface, config ) {
	// Parent constructor
	ve.ce.DocumentNode.super.call( this, model, config );

	// Properties
	this.surface = surface;

	// Set root
	this.setRoot( this );

	// DOM changes
	this.$element.addClass( 've-ce-documentNode' );
	this.$element.prop( { contentEditable: 'true', spellcheck: true } );
};

/* Inheritance */

OO.inheritClass( ve.ce.DocumentNode, ve.ce.BranchNode );

/* Static Properties */

ve.ce.DocumentNode.static.name = 'document';

/* Methods */

/**
 * Get the outer length.
 *
 * For a document node is the same as the inner length, which is why we override it here.
 *
 * @method
 * @returns {number} Length of the entire node
 */
ve.ce.DocumentNode.prototype.getOuterLength = function () {
	return this.length;
};

/**
 * Get the surface the document is attached to.
 *
 * @method
 * @returns {ve.ce.Surface} Surface the document is attached to
 */
ve.ce.DocumentNode.prototype.getSurface = function () {
	return this.surface;
};

/**
 * Disable editing.
 *
 * @method
 */
ve.ce.DocumentNode.prototype.disable = function () {
	this.$element.prop( 'contentEditable', 'false' );
};

/**
 * Enable editing.
 *
 * @method
 */
ve.ce.DocumentNode.prototype.enable = function () {
	this.$element.prop( 'contentEditable', 'true' );
};

/* Registration */

ve.ce.nodeFactory.register( ve.ce.DocumentNode );

/*!
 * VisualEditor ContentEditable HeadingNode class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable heading node.
 *
 * @class
 * @extends ve.ce.ContentBranchNode
 * @constructor
 * @param {ve.dm.HeadingNode} model Model to observe
 * @param {Object} [config] Configuration options
 */
ve.ce.HeadingNode = function VeCeHeadingNode() {
	// Parent constructor
	ve.ce.HeadingNode.super.apply( this, arguments );

	// Events
	this.model.connect( this, { update: 'onUpdate' } );
};

/* Inheritance */

OO.inheritClass( ve.ce.HeadingNode, ve.ce.ContentBranchNode );

/* Static Properties */

ve.ce.HeadingNode.static.name = 'heading';

/* Methods */

/**
 * Get the HTML tag name.
 *
 * Tag name is selected based on the model's level attribute.
 *
 * @returns {string} HTML tag name
 * @throws {Error} If level is invalid
 */
ve.ce.HeadingNode.prototype.getTagName = function () {
	var level = this.model.getAttribute( 'level' ),
		types = { 1: 'h1', 2: 'h2', 3: 'h3', 4: 'h4', 5: 'h5', 6: 'h6' };

	if ( !Object.prototype.hasOwnProperty.call( types, level ) ) {
		throw new Error( 'Invalid level' );
	}
	return types[level];
};

/**
 * Handle model update events.
 *
 * If the level changed since last update the DOM wrapper will be replaced with an appropriate one.
 *
 * @method
 */
ve.ce.HeadingNode.prototype.onUpdate = function () {
	this.updateTagName();
};

/* Registration */

ve.ce.nodeFactory.register( ve.ce.HeadingNode );

/*!
 * VisualEditor InternalItemNode class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable internal item node.
 *
 * @class
 * @extends ve.ce.BranchNode
 * @constructor
 * @param {ve.dm.InternalItemNode} model Model to observe
 * @param {Object} [config] Configuration options
 */
ve.ce.InternalItemNode = function VeCeInternalItemNode() {
	// Parent constructor
	ve.ce.InternalItemNode.super.apply( this, arguments );

	this.$element.addClass( 've-ce-internalItemNode' );
};

/* Inheritance */

OO.inheritClass( ve.ce.InternalItemNode, ve.ce.BranchNode );

/* Static Properties */

ve.ce.InternalItemNode.static.name = 'internalItem';

ve.ce.InternalItemNode.static.tagName = 'span';

/* Registration */

ve.ce.nodeFactory.register( ve.ce.InternalItemNode );

/*!
 * VisualEditor InternalListNode class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable internal list node.
 *
 * @class
 * @extends ve.ce.BranchNode
 * @constructor
 * @param {ve.dm.InternalListNode} model Model to observe
 * @param {Object} [config] Configuration options
 */
ve.ce.InternalListNode = function VeCeInternalListNode() {
	// Parent constructor
	ve.ce.InternalListNode.super.apply( this, arguments );

	// An internal list has no rendering
	this.$element = this.$( [] );
};

/* Inheritance */

OO.inheritClass( ve.ce.InternalListNode, ve.ce.BranchNode );

/* Static Properties */

ve.ce.InternalListNode.static.name = 'internalList';

/* Methods */

/**
 * Deliberately empty: don't build an entire CE tree with DOM elements for things that won't render
 * @inheritdoc
 */
ve.ce.InternalListNode.prototype.onSplice = function () {
};

/* Registration */

ve.ce.nodeFactory.register( ve.ce.InternalListNode );

/*!
 * VisualEditor ContentEditable ListItemNode class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable list item node.
 *
 * @class
 * @extends ve.ce.BranchNode
 * @constructor
 * @param {ve.dm.ListItemNode} model Model to observe
 * @param {Object} [config] Configuration options
 */
ve.ce.ListItemNode = function VeCeListItemNode() {
	// Parent constructor
	ve.ce.ListItemNode.super.apply( this, arguments );
};

/* Inheritance */

OO.inheritClass( ve.ce.ListItemNode, ve.ce.BranchNode );

/* Static Properties */

ve.ce.ListItemNode.static.name = 'listItem';

ve.ce.ListItemNode.static.tagName = 'li';

ve.ce.ListItemNode.static.splitOnEnter = true;

/* Registration */

ve.ce.nodeFactory.register( ve.ce.ListItemNode );

/*!
 * VisualEditor ContentEditable ListNode class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable list node.
 *
 * @class
 * @extends ve.ce.BranchNode
 * @constructor
 * @param {ve.dm.ListNode} model Model to observe
 * @param {Object} [config] Configuration options
 */
ve.ce.ListNode = function VeCeListNode() {
	// Parent constructor
	ve.ce.ListNode.super.apply( this, arguments );

	// Events
	this.model.connect( this, { update: 'onUpdate' } );
};

/* Inheritance */

OO.inheritClass( ve.ce.ListNode, ve.ce.BranchNode );

/* Static Properties */

ve.ce.ListNode.static.name = 'list';

/* Methods */

/**
 * Get the HTML tag name.
 *
 * Tag name is selected based on the model's style attribute.
 *
 * @returns {string} HTML tag name
 * @throws {Error} If style is invalid
 */
ve.ce.ListNode.prototype.getTagName = function () {
	var style = this.model.getAttribute( 'style' ),
		types = { bullet: 'ul', number: 'ol' };

	if ( !Object.prototype.hasOwnProperty.call( types, style ) ) {
		throw new Error( 'Invalid style' );
	}
	return types[style];
};

/**
 * Handle model update events.
 *
 * If the style changed since last update the DOM wrapper will be replaced with an appropriate one.
 *
 * @method
 */
ve.ce.ListNode.prototype.onUpdate = function () {
	this.updateTagName();
};

/* Registration */

ve.ce.nodeFactory.register( ve.ce.ListNode );

/*!
 * VisualEditor ContentEditable ParagraphNode class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable paragraph node.
 *
 * @class
 * @extends ve.ce.ContentBranchNode
 * @constructor
 * @param {ve.dm.ParagraphNode} model Model to observe
 * @param {Object} [config] Configuration options
 */
ve.ce.ParagraphNode = function VeCeParagraphNode() {
	// Parent constructor
	ve.ce.ParagraphNode.super.apply( this, arguments );

	// DOM changes
	this.$element.addClass( 've-ce-paragraphNode' );
	if (
		this.model.getElement().internal &&
		this.model.getElement().internal.generated === 'wrapper'
	) {
		this.$element.addClass( 've-ce-generated-wrapper' );
	}
};

/* Inheritance */

OO.inheritClass( ve.ce.ParagraphNode, ve.ce.ContentBranchNode );

/* Static Properties */

ve.ce.ParagraphNode.static.name = 'paragraph';

ve.ce.ParagraphNode.static.tagName = 'p';

/* Registration */

ve.ce.nodeFactory.register( ve.ce.ParagraphNode );

/*!
 * VisualEditor ContentEditable PreformattedNode class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable preformatted node.
 *
 * @class
 * @extends ve.ce.ContentBranchNode
 * @constructor
 * @param {ve.dm.PreformattedNode} model Model to observe
 * @param {Object} [config] Configuration options
 */
ve.ce.PreformattedNode = function VeCePreformattedNode() {
	// Parent constructor
	ve.ce.PreformattedNode.super.apply( this, arguments );
};

/* Inheritance */

OO.inheritClass( ve.ce.PreformattedNode, ve.ce.ContentBranchNode );

/* Static Properties */

ve.ce.PreformattedNode.static.name = 'preformatted';

ve.ce.PreformattedNode.static.tagName = 'pre';

/* Registration */

ve.ce.nodeFactory.register( ve.ce.PreformattedNode );

/*!
 * VisualEditor ContentEditable TableCaptionNode class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable table caption node.
 *
 * @class
 * @extends ve.ce.BranchNode
 * @constructor
 * @param {ve.dm.TableCaptionNode} model Model to observe
 * @param {Object} [config] Configuration options
 */
ve.ce.TableCaptionNode = function VeCeTableCaptionNode() {
	// Parent constructor
	ve.ce.TableCaptionNode.super.apply( this, arguments );

	// DOM changes
	this.$element
		.addClass( 've-ce-tableCaptionNode' )
		.prop( 'contentEditable', 'true' );
};

/* Inheritance */

OO.inheritClass( ve.ce.TableCaptionNode, ve.ce.BranchNode );

/* Static Properties */

ve.ce.TableCaptionNode.static.name = 'tableCaption';

ve.ce.TableCaptionNode.static.tagName = 'caption';

/* Registration */

ve.ce.nodeFactory.register( ve.ce.TableCaptionNode );

/*!
 * VisualEditor ContentEditable TableCellNode class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable table cell node.
 *
 * @class
 * @extends ve.ce.BranchNode
 * @constructor
 * @param {ve.dm.TableCellNode} model Model to observe
 * @param {Object} [config] Configuration options
 */
ve.ce.TableCellNode = function VeCeTableCellNode() {
	// Parent constructor
	ve.ce.TableCellNode.super.apply( this, arguments );

	var rowspan = this.model.getRowspan(),
		colspan = this.model.getColspan();

	// DOM changes
	this.$element
		// The following classes can be used here:
		// ve-ce-tableCellNode-data
		// ve-ce-tableCellNode-header
		.addClass( 've-ce-tableCellNode ve-ce-tableCellNode-' + this.model.getAttribute( 'style' ) );

	// Set attributes (keep in sync with #onSetup)
	if ( rowspan > 1 ) {
		this.$element.attr( 'rowspan', rowspan );
	}
	if ( colspan > 1 ) {
		this.$element.attr( 'colspan', colspan );
	}

	// Add tooltip
	this.$element.attr( 'title', ve.msg( 'visualeditor-tablecell-tooltip' ) );

	// Events
	this.model.connect( this, {
		update: 'onUpdate',
		attributeChange: 'onAttributeChange'
	} );
};

/* Inheritance */

OO.inheritClass( ve.ce.TableCellNode, ve.ce.BranchNode );

/* Static Properties */

ve.ce.TableCellNode.static.name = 'tableCell';

/* Methods */

/**
 * Get the HTML tag name.
 *
 * Tag name is selected based on the model's style attribute.
 *
 * @returns {string} HTML tag name
 * @throws {Error} Invalid style
 */
ve.ce.TableCellNode.prototype.getTagName = function () {
	var style = this.model.getAttribute( 'style' ),
		types = { data: 'td', header: 'th' };

	if ( !Object.prototype.hasOwnProperty.call( types, style ) ) {
		throw new Error( 'Invalid style' );
	}
	return types[style];
};

/**
 * Set the editing mode of a table cell node
 *
 * @param {boolean} enable Enable editing
 */
ve.ce.TableCellNode.prototype.setEditing = function ( enable ) {
	this.$element
		.toggleClass( 've-ce-tableCellNode-editing', enable )
		.prop( 'contentEditable', enable.toString() );
};

/**
 * Handle model update events.
 *
 * If the style changed since last update the DOM wrapper will be replaced with an appropriate one.
 *
 * @method
 */
ve.ce.TableCellNode.prototype.onUpdate = function () {
	this.updateTagName();
};

/**
 * @inheritdoc
 */
ve.ce.TableCellNode.prototype.onSetup = function () {
	// Parent method
	ve.ce.TableCellNode.super.prototype.onSetup.call( this );

	var rowspan = this.model.getRowspan(),
		colspan = this.model.getColspan();
	// Set attributes (duplicated from constructor in case this.$element is replaced)
	if ( rowspan > 1 ) {
		this.$element.attr( 'rowspan', rowspan );
	}
	if ( colspan > 1 ) {
		this.$element.attr( 'colspan', colspan );
	}
};

/**
 * Handle attribute changes to keep the live HTML element updated.
 */
ve.ce.TableCellNode.prototype.onAttributeChange = function ( key, from, to ) {
	switch ( key ) {
		case 'colspan':
		case 'rowspan':
			if ( to > 1 ) {
				this.$element.attr( key, to );
			} else {
				this.$element.removeAttr( key );
			}
			break;
		case 'style':
			this.$element
				.removeClass( 've-ce-tableCellNode-' + from )
				.addClass( 've-ce-tableCellNode-' + to );
			this.updateTagName();
			break;
	}
};

/* Registration */

ve.ce.nodeFactory.register( ve.ce.TableCellNode );

/*!
 * VisualEditor ContentEditable TableNode class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable table node.
 *
 * @class
 * @extends ve.ce.BranchNode
 * @constructor
 * @param {ve.dm.TableNode} model Model to observe
 * @param {Object} [config] Configuration options
 */
ve.ce.TableNode = function VeCeTableNode() {
	// Parent constructor
	ve.ce.TableNode.super.apply( this, arguments );

	// Properties
	this.surface = null;
	this.active = false;
	this.startCell = null;
	this.editingFragment = null;

	// DOM changes
	this.$element
		.addClass( 've-ce-tableNode' )
		.prop( 'contentEditable', 'false' );
};

/* Inheritance */

OO.inheritClass( ve.ce.TableNode, ve.ce.BranchNode );

/* Methods */

/**
 * @inheritdoc
 */
ve.ce.TableNode.prototype.onSetup = function () {
	// Parent method
	ve.ce.TableNode.super.prototype.onSetup.call( this );

	// Exit if already setup or not attached
	if ( this.isSetup || !this.root ) {
		return;
	}
	this.surface = this.getRoot().getSurface();

	// Overlay
	this.$selectionBox = this.$( '<div>' ).addClass( 've-ce-tableNodeOverlay-selection-box' );
	this.$selectionBoxAnchor = this.$( '<div>' ).addClass( 've-ce-tableNodeOverlay-selection-box-anchor' );
	this.colContext = new ve.ui.TableContext( this, 'table-col', {
		$: this.$,
		classes: ['ve-ui-tableContext-colContext'],
		indicator: 'down'
	} );
	this.rowContext = new ve.ui.TableContext( this, 'table-row', {
		$: this.$,
		classes: ['ve-ui-tableContext-rowContext'],
		indicator: 'next'
	} );

	this.$overlay = this.$( '<div>' )
		.addClass( 've-ce-tableNodeOverlay oo-ui-element-hidden' )
		.append( [
			this.$selectionBox,
			this.$selectionBoxAnchor,
			this.colContext.$element,
			this.rowContext.$element,
			this.$rowBracket,
			this.$colBracket
		] );
	this.surface.surface.$blockers.append( this.$overlay );

	// Events
	this.$element.on( {
		'mousedown.ve-ce-tableNode': this.onTableMouseDown.bind( this ),
		'dblclick.ve-ce-tableNode': this.onTableDblClick.bind( this )
	} );
	this.onTableMouseUpHandler = this.onTableMouseUp.bind( this );
	this.onTableMouseMoveHandler = this.onTableMouseMove.bind( this );
	// Select and position events both fire updateOverlay, so debounce. Also makes
	// sure that this.selectedRectangle is up to date before redrawing.
	this.updateOverlayDebounced = ve.debounce( this.updateOverlay.bind( this ) );
	this.surface.getModel().connect( this, { select: 'onSurfaceModelSelect' } );
	this.surface.connect( this, { position: this.updateOverlayDebounced } );
};

/**
 * @inheritdoc
 */
ve.ce.TableNode.prototype.onTeardown = function () {
	// Parent method
	ve.ce.TableNode.super.prototype.onTeardown.call( this );
	// Events
	this.$element.off( '.ve-ce-tableNode' );
	this.surface.getModel().disconnect( this );
	this.surface.disconnect( this );
	this.$overlay.remove();
};

/**
 * Handle table double click events
 *
 * @param {jQuery.Event} e Double click event
 */
ve.ce.TableNode.prototype.onTableDblClick = function ( e ) {
	if ( !this.getCellNodeFromTarget( e.target ) ) {
		return;
	}
	if ( this.surface.getModel().getSelection() instanceof ve.dm.TableSelection ) {
		this.setEditing( true );
	}
};

/**
 * Handle mouse down or touch start events
 *
 * @param {jQuery.Event} e Mouse down or touch start event
 */
ve.ce.TableNode.prototype.onTableMouseDown = function ( e ) {
	var cellNode, startCell, endCell, selection, newSelection;

	if ( e.type === 'touchstart' && e.originalEvent.touches.length > 1 ) {
		// Ignore multi-touch
		return;
	}

	cellNode = this.getCellNodeFromTarget( e.target );
	if ( !cellNode ) {
		return;
	}

	endCell = this.getModel().getMatrix().lookupCell( cellNode.getModel() );
	if ( !endCell ) {
		e.preventDefault();
		return;
	}
	selection = this.surface.getModel().getSelection();
	startCell = e.shiftKey && this.active ? { col: selection.fromCol, row: selection.fromRow } : endCell;
	newSelection = new ve.dm.TableSelection(
		this.getModel().getDocument(),
		this.getModel().getOuterRange(),
		startCell.col,
		startCell.row,
		endCell.col,
		endCell.row,
		true
	);
	if ( this.editingFragment ) {
		if ( newSelection.equals( this.editingFragment.getSelection() ) ) {
			// Clicking on the editing cell, don't prevent default
			return;
		} else {
			this.setEditing( false, true );
		}
	}
	this.surface.getModel().setSelection( newSelection );
	this.startCell = startCell;
	this.surface.$document.on( {
		'mouseup touchend': this.onTableMouseUpHandler,
		'mousemove touchmove': this.onTableMouseMoveHandler
	} );
	e.preventDefault();
};

/**
 * Get the table and cell node from an event target
 *
 * @param {HTMLElement} target Element target to find nearest cell node to
 * @return {ve.ce.TableCellNode|null} Table cell node, or null if none found
 */
ve.ce.TableNode.prototype.getCellNodeFromTarget = function ( target ) {
	var $target = $( target ),
		$table = $target.closest( 'table' );

	// Nested table, ignore
	if ( !this.$element.is( $table ) ) {
		return null;
	}

	return $target.closest( 'td, th' ).data( 'view' );
};

/**
 * Handle mouse/touch move events
 *
 * @param {jQuery.Event} e Mouse/touch move event
 */
ve.ce.TableNode.prototype.onTableMouseMove = function ( e ) {
	var cell, selection, touch, target, cellNode;

	// 'touchmove' doesn't give a correct e.target, so calculate it from coordinates
	if ( e.type === 'touchmove' ) {
		if ( e.originalEvent.touches.length > 1 ) {
			// Ignore multi-touch
			return;
		}
		touch = e.originalEvent.touches[0];
		target = this.surface.getElementDocument().elementFromPoint( touch.clientX, touch.clientY );
	} else {
		target = e.target;
	}

	cellNode = this.getCellNodeFromTarget( target );
	if ( !cellNode ) {
		return;
	}

	cell = this.getModel().matrix.lookupCell( cellNode.getModel() );
	if ( !cell ) {
		return;
	}

	selection = new ve.dm.TableSelection(
		this.getModel().getDocument(),
		this.getModel().getOuterRange(),
		this.startCell.col, this.startCell.row, cell.col, cell.row,
		true
	);
	this.surface.getModel().setSelection( selection );
};

/**
 * Handle mouse up or touch end events
 *
 * @param {jQuery.Event} e Mouse up or touch end event
 */
ve.ce.TableNode.prototype.onTableMouseUp = function () {
	this.startCell = null;
	this.surface.$document.off( {
		'mouseup touchend': this.onTableMouseUpHandler,
		'mousemove touchmove': this.onTableMouseMoveHandler
	} );
};

/**
 * Set the editing state of the table
 *
 * @param {boolean} isEditing The table is being edited
 * @param {boolean} noSelect Don't change the selection
 */
ve.ce.TableNode.prototype.setEditing = function ( isEditing, noSelect ) {
	if ( isEditing ) {
		var cell, selection = this.surface.getModel().getSelection();
		if ( !selection.isSingleCell() ) {
			selection = selection.collapseToFrom();
			this.surface.getModel().setSelection( selection );
		}
		this.editingFragment = this.surface.getModel().getFragment( selection );
		cell = this.getCellNodesFromSelection( selection )[0];
		cell.setEditing( true );
		if ( !noSelect ) {
			// TODO: Find content offset within cell
			this.surface.getModel().setLinearSelection( new ve.Range( cell.getModel().getRange().end - 1 ) );
		}
	} else if ( this.editingFragment ) {
		this.getCellNodesFromSelection( this.editingFragment.getSelection() )[0].setEditing( false );
		if ( !noSelect ) {
			this.surface.getModel().setSelection( this.editingFragment.getSelection() );
		}
		this.editingFragment = null;
	}
	this.$element.toggleClass( 've-ce-tableNode-editing', isEditing );
	this.$overlay.toggleClass( 've-ce-tableNodeOverlay-editing', isEditing );
};

/**
 * Get fragment with table selection covering cell being edited
 *
 * @return {ve.dm.SurfaceFragment} Fragment, or null if not cell editing
 */
ve.ce.TableNode.prototype.getEditingFragment = function () {
	return this.editingFragment;
};

/**
 * Get range of cell being edited from editing fragment
 *
 * @return {ve.Range} Range, or null if not cell editing
 */
ve.ce.TableNode.prototype.getEditingRange = function () {
	var fragment = this.getEditingFragment();
	return fragment ? fragment.getSelection().getRanges()[0] : null;
};

/**
 * Handle select events from the surface model.
 *
 * @param {ve.dm.Selection} selection Selection
 */
ve.ce.TableNode.prototype.onSurfaceModelSelect = function ( selection ) {
	// The table is active if it is a linear selection inside a cell being edited
	// or a table selection matching this table.
	var active = (
			this.editingFragment !== null &&
			selection instanceof ve.dm.LinearSelection &&
			this.editingFragment.getSelection().getRanges()[0].containsRange( selection.getRange() )
		) ||
		(
			selection instanceof ve.dm.TableSelection &&
			selection.tableRange.equalsSelection( this.getModel().getOuterRange() )
		);

	if ( active ) {
		if ( !this.active ) {
			this.$overlay.removeClass( 'oo-ui-element-hidden' );
			// Only register touchstart event after table has become active to prevent
			// accidental focusing of the table while scrolling
			this.$element.on( 'touchstart.ve-ce-tableNode', this.onTableMouseDown.bind( this ) );
		}
		this.surface.setActiveTableNode( this );
		this.updateOverlayDebounced();
	} else if ( !active && this.active ) {
		this.$overlay.addClass( 'oo-ui-element-hidden' );
		if ( this.editingFragment ) {
			this.setEditing( false, true );
		}
		if ( this.surface.getActiveTableNode() === this ) {
			this.surface.setActiveTableNode( null );
		}
		this.$element.off( 'touchstart.ve-ce-tableNode' );
	}
	this.$element.toggleClass( 've-ce-tableNode-active', active );
	this.active = active;
};

/**
 * Update the overlay positions
 */
ve.ce.TableNode.prototype.updateOverlay = function () {
	if ( !this.active ) {
		return;
	}

	var i, l, nodes, cellOffset, anchorNode, anchorOffset, selectionOffset,
		top, left, bottom, right,
		selection = this.editingFragment ?
			this.editingFragment.getSelection() :
			this.surface.getModel().getSelection(),
		// getBoundingClientRect is more accurate but must be used consistently
		// due to the iOS7 bug where it is relative to the document.
		tableOffset = this.getFirstSectionNode().$element[0].getBoundingClientRect(),
		surfaceOffset = this.surface.getSurface().$element[0].getBoundingClientRect();

	if ( !tableOffset ) {
		return;
	}

	nodes = this.getCellNodesFromSelection( selection );
	anchorNode = this.getCellNodesFromSelection( selection.collapseToFrom() )[0];
	anchorOffset = ve.translateRect( anchorNode.$element[0].getBoundingClientRect(), -tableOffset.left, -tableOffset.top );

	top = Infinity;
	bottom = -Infinity;
	left = Infinity;
	right = -Infinity;

	// Compute a bounding box for the given cell elements
	for ( i = 0, l = nodes.length; i < l; i++) {
		cellOffset = nodes[i].$element[0].getBoundingClientRect();

		top = Math.min( top, cellOffset.top );
		bottom = Math.max( bottom, cellOffset.bottom );
		left = Math.min( left, cellOffset.left );
		right = Math.max( right, cellOffset.right );
	}

	selectionOffset = ve.translateRect(
		{ top: top, bottom: bottom, left: left, right: right, width: right - left, height: bottom - top },
		-tableOffset.left, -tableOffset.top
	);

	// Resize controls
	this.$selectionBox.css( {
		top: selectionOffset.top,
		left: selectionOffset.left,
		width: selectionOffset.width,
		height: selectionOffset.height
	} );
	this.$selectionBoxAnchor.css( {
		top: anchorOffset.top,
		left: anchorOffset.left,
		width: anchorOffset.width,
		height: anchorOffset.height
	} );

	// Position controls
	this.$overlay.css( {
		top: tableOffset.top - surfaceOffset.top,
		left: tableOffset.left - surfaceOffset.left,
		width: tableOffset.width
	} );
	this.colContext.$element.css( {
		left: selectionOffset.left
	} );
	this.colContext.indicator.$element.css( {
		width: selectionOffset.width
	} );
	this.colContext.popup.$element.css( {
		'margin-left': selectionOffset.width / 2
	} );
	this.rowContext.$element.css( {
		top: selectionOffset.top
	} );
	this.rowContext.indicator.$element.css( {
		height: selectionOffset.height
	} );
	this.rowContext.popup.$element.css( {
		'margin-top': selectionOffset.height / 2
	} );

	// Classes
	this.$selectionBox
		.toggleClass( 've-ce-tableNodeOverlay-selection-box-fullRow', selection.isFullRow() )
		.toggleClass( 've-ce-tableNodeOverlay-selection-box-fullCol', selection.isFullCol() );
};

/**
 * Get the first section node of the table, skipping over any caption nodes
 *
 * @return {ve.ce.TableSectionNode} First table section node
 */
ve.ce.TableNode.prototype.getFirstSectionNode = function () {
	var i = 0;
	while ( !( this.children[i] instanceof ve.ce.TableSectionNode ) ) {
		i++;
	}
	return this.children[i];
};

/**
 * Get a cell node from a single cell selection
 *
 * @param {ve.dm.TableSelection} selection Single cell table selection
 * @return {ve.ce.TableCellNode[]} Cell nodes
 */
ve.ce.TableNode.prototype.getCellNodesFromSelection = function ( selection ) {
	var i, l, cellModel, cellView,
		cells = selection.getMatrixCells(),
		nodes = [];

	for ( i = 0, l = cells.length; i < l; i++ ) {
		cellModel = cells[i].node;
		cellView = this.getNodeFromOffset( cellModel.getOffset() - this.model.getOffset() );
		nodes.push( cellView );
	}
	return nodes;
};

/* Static Properties */

ve.ce.TableNode.static.name = 'table';

ve.ce.TableNode.static.tagName = 'table';

/* Registration */

ve.ce.nodeFactory.register( ve.ce.TableNode );

/*!
 * VisualEditor ContentEditable TableRowNode class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable table row node.
 *
 * @class
 * @extends ve.ce.BranchNode
 * @constructor
 * @param {ve.dm.TableRowNode} model Model to observe
 * @param {Object} [config] Configuration options
 */
ve.ce.TableRowNode = function VeCeTableRowNode() {
	// Parent constructor
	ve.ce.TableRowNode.super.apply( this, arguments );
};

/* Inheritance */

OO.inheritClass( ve.ce.TableRowNode, ve.ce.BranchNode );

/* Static Properties */

ve.ce.TableRowNode.static.name = 'tableRow';

ve.ce.TableRowNode.static.tagName = 'tr';

/* Registration */

ve.ce.nodeFactory.register( ve.ce.TableRowNode );

/*!
 * VisualEditor ContentEditable TableSectionNode class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable table section node.
 *
 * @class
 * @extends ve.ce.BranchNode
 * @constructor
 * @param {ve.dm.TableSectionNode} model Model to observe
 * @param {Object} [config] Configuration options
 */
ve.ce.TableSectionNode = function VeCeTableSectionNode() {
	// Parent constructor
	ve.ce.TableSectionNode.super.apply( this, arguments );

	// Events
	this.model.connect( this, { update: 'onUpdate' } );
};

/* Inheritance */

OO.inheritClass( ve.ce.TableSectionNode, ve.ce.BranchNode );

/* Static Properties */

ve.ce.TableSectionNode.static.name = 'tableSection';

/* Methods */

/**
 * Get the HTML tag name.
 *
 * Tag name is selected based on the model's style attribute.
 *
 * @returns {string} HTML tag name
 * @throws {Error} If style is invalid
 */
ve.ce.TableSectionNode.prototype.getTagName = function () {
	var style = this.model.getAttribute( 'style' ),
		types = { header: 'thead', body: 'tbody', footer: 'tfoot' };

	if ( !Object.prototype.hasOwnProperty.call( types, style ) ) {
		throw new Error( 'Invalid style' );
	}
	return types[style];
};

/**
 * Handle model update events.
 *
 * If the style changed since last update the DOM wrapper will be replaced with an appropriate one.
 *
 * @method
 */
ve.ce.TableSectionNode.prototype.onUpdate = function () {
	this.updateTagName();
};

/* Registration */

ve.ce.nodeFactory.register( ve.ce.TableSectionNode );

/*!
 * VisualEditor ContentEditable TextNode class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable text node.
 *
 * @class
 * @extends ve.ce.LeafNode
 * @constructor
 * @param {ve.dm.TextNode} model Model to observe
 * @param {Object} [config] Configuration options
 */
ve.ce.TextNode = function VeCeTextNode() {
	// Parent constructor
	ve.ce.TextNode.super.apply( this, arguments );

	this.$element = $( [] );
};

/* Inheritance */

OO.inheritClass( ve.ce.TextNode, ve.ce.LeafNode );

/* Static Properties */

ve.ce.TextNode.static.name = 'text';

ve.ce.TextNode.static.splitOnEnter = true;

ve.ce.TextNode.whitespaceHtmlCharacters = {
	'\n': '\u21b5', // &crarr; / ↵
	'\t': '\u279e' // &#10142; / ➞
};

/* Methods */

/**
 * Get an HTML rendering of the text.
 *
 * @method
 * @returns {Array} Array of rendered HTML fragments with annotations
 */
ve.ce.TextNode.prototype.getAnnotatedHtml = function () {
	var i, chr,
		data = this.model.getDocument().getDataFromNode( this.model ),
		whitespaceHtmlChars = ve.ce.TextNode.whitespaceHtmlCharacters,
		significantWhitespace = this.getModel().getParent().hasSignificantWhitespace();

	function setChar( chr, index, data ) {
		if ( Array.isArray( data[index] ) ) {
			// Don't modify the original array, clone it first
			data[index] = data[index].slice( 0 );
			data[index][0] = chr;
		} else {
			data[index] = chr;
		}
	}

	function getChar( index, data ) {
		if ( Array.isArray( data[index] ) ) {
			return data[index][0];
		} else {
			return data[index];
		}
	}

	if ( !significantWhitespace ) {
		// Replace spaces with &nbsp; where needed
		// \u00a0 == &#160; == &nbsp;
		if ( data.length > 0 ) {
			// Leading space
			if ( getChar( 0, data ) === ' ' ) {
				setChar( '\u00a0', 0, data );
			}
		}
		if ( data.length > 1 ) {
			// Trailing space
			if ( getChar( data.length - 1, data ) === ' ' ) {
				setChar( '\u00a0', data.length - 1, data );
			}
		}

		for ( i = 0; i < data.length; i++ ) {
			chr = getChar( i, data );

			// Replace any sequence of 2+ spaces with an alternating pattern
			// (space-nbsp-space-nbsp-...).
			// The leading and trailing space, if present, have already been converted
			// to nbsp, so we know that i is between 1 and data.length - 2.
			if ( chr === ' ' && getChar( i + 1, data ) === ' ' ) {
				setChar( '\u00a0', i + 1, data );
			}

			// Show meaningful whitespace characters
			if ( Object.prototype.hasOwnProperty.call( whitespaceHtmlChars, chr ) ) {
				setChar( whitespaceHtmlChars[chr], i, data );
			}
		}
	}
	return data;
};

/* Registration */

ve.ce.nodeFactory.register( ve.ce.TextNode );

/*!
 * VisualEditor ContentEditable ImageNode class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable image node.
 *
 * @class
 * @abstract
 * @mixins ve.ce.FocusableNode
 * @mixins ve.ce.ResizableNode
 *
 * @constructor
 * @param {jQuery} $figure Image or figure element
 * @param {jQuery} [$image] Actual image element, if $figure is just a container
 * @param {Object} [config] Configuration options
 */
ve.ce.ImageNode = function VeCeImageNode( $figure, $image, config ) {
	config = ve.extendObject( {
		enforceMax: false,
		minDimensions: { width: 1, height: 1 }
	}, config );

	this.$figure = $figure;
	this.$image = $image || $figure;

	// Mixin constructors
	ve.ce.FocusableNode.call( this, this.$figure, config );
	ve.ce.ResizableNode.call( this, this.$image, config );

	// Events
	this.$image.on( 'load', this.onLoad.bind( this ) );
	this.model.connect( this, { attributeChange: 'onAttributeChange' } );

	// Initialization
	this.$element.addClass( 've-ce-imageNode' );
};

/* Inheritance */

OO.mixinClass( ve.ce.ImageNode, ve.ce.FocusableNode );

OO.mixinClass( ve.ce.ImageNode, ve.ce.ResizableNode );

/* Static Methods */

/**
 * @inheritdoc ve.ce.Node
 */
ve.ce.ImageNode.static.getDescription = function ( model ) {
	return model.getAttribute( 'src' );
};

/* Methods */

/**
 * Update the rendering of the 'align', src', 'width' and 'height' attributes
 * when they change in the model.
 *
 * @method
 * @param {string} key Attribute key
 * @param {string} from Old value
 * @param {string} to New value
 */
ve.ce.ImageNode.prototype.onAttributeChange = function ( key, from, to ) {
	switch ( key ) {
		case 'src':
			this.$image.prop( 'src', this.getResolvedAttribute( 'src' ) );
			break;

		case 'width':
		case 'height':
			this.$image.css( key, to !== null ? to : '' );
			break;
	}
};

/**
 * Handle the image load
 *
 * @method
 * @param {jQuery.Event} e Load event
 */
ve.ce.ImageNode.prototype.onLoad = function () {
	this.setOriginalDimensions( {
		width: this.$image.prop( 'naturalWidth' ),
		height: this.$image.prop( 'naturalHeight' )
	} );
};

/*!
 * VisualEditor ContentEditable block image node class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable block image node.
 *
 * @class
 * @extends ve.ce.BranchNode
 * @mixins ve.ce.ImageNode
 * @mixins ve.ce.AlignableNode
 *
 * @constructor
 * @param {ve.dm.BlockImageNode} model Model to observe
 * @param {Object} [config] Configuration options
 */
ve.ce.BlockImageNode = function VeCeBlockImageNode( model, config ) {
	config = ve.extendObject( {
		minDimensions: { width: 1, height: 1 }
	}, config );

	// Parent constructor
	ve.ce.BlockImageNode.super.call( this, model, config );

	// Build DOM
	this.$image = this.$( '<img>' )
		.prop( 'src', this.getResolvedAttribute( 'src' ) )
		.prependTo( this.$element );

	// Mixin constructors
	ve.ce.ImageNode.call( this, this.$element, this.$image, config );
	ve.ce.AlignableNode.call( this, this.$element, config );

	// Initialization
	this.$element.addClass( 've-ce-blockImageNode' );
	this.$image
		.prop( {
			alt: this.model.getAttribute( 'alt' ),
			src: this.getResolvedAttribute( 'src' )
		} )
		.css( {
			width: this.model.getAttribute( 'width' ),
			height: this.model.getAttribute( 'height' )
		} );
};

/* Inheritance */

OO.inheritClass( ve.ce.BlockImageNode, ve.ce.BranchNode );

OO.mixinClass( ve.ce.BlockImageNode, ve.ce.ImageNode );

// Mixin Alignable's parent class
OO.mixinClass( ve.ce.BlockImageNode, ve.ce.ClassAttributeNode );

OO.mixinClass( ve.ce.BlockImageNode, ve.ce.AlignableNode );

/* Static Properties */

ve.ce.BlockImageNode.static.name = 'blockImage';

ve.ce.BlockImageNode.static.tagName = 'figure';

/* Registration */

ve.ce.nodeFactory.register( ve.ce.BlockImageNode );

/*!
 * VisualEditor ContentEditable block image caption node class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable block image caption item node.
 *
 * @class
 * @extends ve.ce.BranchNode
 * @constructor
 * @param {ve.dm.BlockImageCaptionNode} model Model to observe
 * @param {Object} [config] Configuration options
 */
ve.ce.BlockImageCaptionNode = function VeCeBlockImageCaptionNode() {
	// Parent constructor
	ve.ce.BlockImageCaptionNode.super.apply( this, arguments );
};

/* Inheritance */

OO.inheritClass( ve.ce.BlockImageCaptionNode, ve.ce.BranchNode );

/* Static Properties */

ve.ce.BlockImageCaptionNode.static.name = 'imageCaption';

ve.ce.BlockImageCaptionNode.static.tagName = 'figcaption';

/* Registration */

ve.ce.nodeFactory.register( ve.ce.BlockImageCaptionNode );

/*!
 * VisualEditor ContentEditable InlineImageNode class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable inline image node.
 *
 * @class
 * @extends ve.ce.LeafNode
 * @mixins ve.ce.ImageNode
 * @mixins ve.ce.ResizableNode
 *
 * @constructor
 * @param {ve.dm.InlineImageNode} model Model to observe
 * @param {Object} [config] Configuration options
 */
ve.ce.InlineImageNode = function VeCeInlineImageNode( model, config ) {
	config = ve.extendObject( {
		minDimensions: { width: 1, height: 1 }
	}, config );

	// Parent constructor
	ve.ce.InlineImageNode.super.call( this, model, config );

	// Mixin constructors
	ve.ce.ImageNode.call( this, this.$element, null, config );

	// Initialization
	this.$element
		.addClass( 've-ce-inlineImageNode' )
		.prop( {
			alt: this.model.getAttribute( 'alt' ),
			src: this.getResolvedAttribute( 'src' )
		} )
		.css( {
			width: this.model.getAttribute( 'width' ),
			height: this.model.getAttribute( 'height' )
		} );
};

/* Inheritance */

OO.inheritClass( ve.ce.InlineImageNode, ve.ce.LeafNode );

OO.mixinClass( ve.ce.InlineImageNode, ve.ce.ImageNode );

/* Static Properties */

ve.ce.InlineImageNode.static.name = 'inlineImage';

ve.ce.InlineImageNode.static.tagName = 'img';

/* Registration */

ve.ce.nodeFactory.register( ve.ce.InlineImageNode );

ve.ce.SectionNode = function VeCeSectionNode() {
	// Parent constructor
	ve.ce.SectionNode.super.apply( this, arguments );

	this.$element.addClass('ve-ce-sectionnode');
};

/* Inheritance */

OO.inheritClass( ve.ce.SectionNode, ve.ce.BranchNode );

/* Static Properties */

ve.ce.SectionNode.static.name = 'section';

ve.ce.SectionNode.static.tagName = 'section';

/* Methods */

/* Registration */

ve.ce.nodeFactory.register( ve.ce.SectionNode );

/*!
 * VisualEditor ContentEditable LanguageAnnotation class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable language annotation.
 *
 * @class
 * @extends ve.ce.Annotation
 * @constructor
 * @param {ve.dm.LanguageAnnotation} model Model to observe
 * @param {ve.ce.ContentBranchNode} [parentNode] Node rendering this annotation
 * @param {Object} [config] Configuration options
 */
ve.ce.LanguageAnnotation = function VeCeLanguageAnnotation() {
	// Parent constructor
	ve.ce.LanguageAnnotation.super.apply( this, arguments );

	// DOM changes
	this.$element
		.addClass( 've-ce-languageAnnotation' )
		.addClass( 've-ce-bidi-isolate' )
		.prop( {
			lang: this.model.getAttribute( 'lang' ),
			dir: this.model.getAttribute( 'dir' ),
			title: this.constructor.static.getDescription( this.model )
		} );
};

/* Inheritance */

OO.inheritClass( ve.ce.LanguageAnnotation, ve.ce.Annotation );

/* Static Properties */

ve.ce.LanguageAnnotation.static.name = 'meta/language';

ve.ce.LanguageAnnotation.static.tagName = 'span';

/* Static Methods */

/**
 * @inheritdoc
 */
ve.ce.LanguageAnnotation.static.getDescription = function ( model ) {
	var lang = ( model.getAttribute( 'lang' ) || '' ).toLowerCase(),
		name = ve.init.platform.getLanguageName( lang ),
		dir = ( model.getAttribute( 'dir' ) || '' ).toUpperCase();

	if ( !dir || dir === ve.init.platform.getLanguageDirection( lang ).toUpperCase() ) {
		return ve.msg( 'visualeditor-languageannotation-description', name );
	}

	return ve.msg( 'visualeditor-languageannotation-description-with-dir', name, dir );
};

/* Registration */

ve.ce.annotationFactory.register( ve.ce.LanguageAnnotation );

/*!
 * VisualEditor ContentEditable LinkAnnotation class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable link annotation.
 *
 * @class
 * @extends ve.ce.Annotation
 * @constructor
 * @param {ve.dm.LinkAnnotation} model Model to observe
 * @param {ve.ce.ContentBranchNode} [parentNode] Node rendering this annotation
 * @param {Object} [config] Configuration options
 */
ve.ce.LinkAnnotation = function VeCeLinkAnnotation() {
	// Parent constructor
	ve.ce.LinkAnnotation.super.apply( this, arguments );

	// Initialization
	this.$element
		.addClass( 've-ce-linkAnnotation' )
		.prop( {
			href: ve.resolveUrl( this.model.getHref(), this.getModelHtmlDocument() ),
			title: this.constructor.static.getDescription( this.model )
		} );
};

/* Inheritance */

OO.inheritClass( ve.ce.LinkAnnotation, ve.ce.Annotation );

/* Static Properties */

ve.ce.LinkAnnotation.static.name = 'link';

ve.ce.LinkAnnotation.static.tagName = 'a';

ve.ce.LinkAnnotation.static.forceContinuation = true;

/* Static Methods */

/**
 * @inheritdoc
 */
ve.ce.LinkAnnotation.static.getDescription = function ( model ) {
	return model.getHref();
};

/* Registration */

ve.ce.annotationFactory.register( ve.ce.LinkAnnotation );

/*!
 * VisualEditor ContentEditable TextStyleAnnotation class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable text style annotation.
 *
 * @class
 * @abstract
 * @extends ve.ce.Annotation
 * @constructor
 * @param {ve.dm.TextStyleAnnotation} model Model to observe
 * @param {ve.ce.ContentBranchNode} [parentNode] Node rendering this annotation
 * @param {Object} [config] Configuration options
 */
ve.ce.TextStyleAnnotation = function VeCeTextStyleAnnotation() {
	// Parent constructor
	ve.ce.TextStyleAnnotation.super.apply( this, arguments );

	// DOM changes
	this.$element.addClass( 've-ce-textStyleAnnotation' );
};

/* Inheritance */

OO.inheritClass( ve.ce.TextStyleAnnotation, ve.ce.Annotation );

/* Static Properties */

ve.ce.TextStyleAnnotation.static.name = 'textStyle';

/* Methods */

ve.ce.TextStyleAnnotation.prototype.getTagName = function () {
	return this.getModel().getAttribute( 'nodeName' ) || this.constructor.static.tagName;
};

/* Registration */

ve.ce.annotationFactory.register( ve.ce.TextStyleAnnotation );

/*!
 * VisualEditor ContentEditable AbbreviationAnnotation class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable abbreviation annotation.
 *
 * @class
 * @extends ve.ce.TextStyleAnnotation
 * @constructor
 * @param {ve.dm.AbbreviationAnnotation} model Model to observe
 * @param {ve.ce.ContentBranchNode} [parentNode] Node rendering this annotation
 * @param {Object} [config] Configuration options
 */
ve.ce.AbbreviationAnnotation = function VeCeAbbreviationAnnotation() {
	// Parent constructor
	ve.ce.AbbreviationAnnotation.super.apply( this, arguments );

	// DOM changes
	this.$element.addClass( 've-ce-abbreviationAnnotation' );
};

/* Inheritance */

OO.inheritClass( ve.ce.AbbreviationAnnotation, ve.ce.TextStyleAnnotation );

/* Static Properties */

ve.ce.AbbreviationAnnotation.static.name = 'textStyle/abbreviation';

ve.ce.AbbreviationAnnotation.static.tagName = 'abbr';

/* Registration */

ve.ce.annotationFactory.register( ve.ce.AbbreviationAnnotation );

/*!
 * VisualEditor ContentEditable BigAnnotation class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable big annotation.
 *
 * @class
 * @extends ve.ce.TextStyleAnnotation
 * @constructor
 * @param {ve.dm.BigAnnotation} model Model to observe
 * @param {ve.ce.ContentBranchNode} [parentNode] Node rendering this annotation
 * @param {Object} [config] Configuration options
 */
ve.ce.BigAnnotation = function VeCeBigAnnotation() {
	// Parent constructor
	ve.ce.BigAnnotation.super.apply( this, arguments );

	// DOM changes
	this.$element.addClass( 've-ce-bigAnnotation' );
};

/* Inheritance */

OO.inheritClass( ve.ce.BigAnnotation, ve.ce.TextStyleAnnotation );

/* Static Properties */

ve.ce.BigAnnotation.static.name = 'textStyle/big';

ve.ce.BigAnnotation.static.tagName = 'big';

/* Registration */

ve.ce.annotationFactory.register( ve.ce.BigAnnotation );

/*!
 * VisualEditor ContentEditable BoldAnnotation class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable bold annotation.
 *
 * @class
 * @extends ve.ce.TextStyleAnnotation
 * @constructor
 * @param {ve.dm.BoldAnnotation} model Model to observe
 * @param {ve.ce.ContentBranchNode} [parentNode] Node rendering this annotation
 * @param {Object} [config] Configuration options
 */
ve.ce.BoldAnnotation = function VeCeBoldAnnotation() {
	// Parent constructor
	ve.ce.BoldAnnotation.super.apply( this, arguments );

	// DOM changes
	this.$element.addClass( 've-ce-boldAnnotation' );
};

/* Inheritance */

OO.inheritClass( ve.ce.BoldAnnotation, ve.ce.TextStyleAnnotation );

/* Static Properties */

ve.ce.BoldAnnotation.static.name = 'textStyle/bold';

ve.ce.BoldAnnotation.static.tagName = 'b';

/* Registration */

ve.ce.annotationFactory.register( ve.ce.BoldAnnotation );

/*!
 * VisualEditor ContentEditable CodeAnnotation class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable code annotation.
 *
 * @class
 * @extends ve.ce.TextStyleAnnotation
 * @constructor
 * @param {ve.dm.CodeAnnotation} model Model to observe
 * @param {ve.ce.ContentBranchNode} [parentNode] Node rendering this annotation
 * @param {Object} [config] Configuration options
 */
ve.ce.CodeAnnotation = function VeCeCodeAnnotation() {
	// Parent constructor
	ve.ce.CodeAnnotation.super.apply( this, arguments );

	// DOM changes
	this.$element.addClass( 've-ce-codeAnnotation' );
};

/* Inheritance */

OO.inheritClass( ve.ce.CodeAnnotation, ve.ce.TextStyleAnnotation );

/* Static Properties */

ve.ce.CodeAnnotation.static.name = 'textStyle/code';

ve.ce.CodeAnnotation.static.tagName = 'code';

/* Registration */

ve.ce.annotationFactory.register( ve.ce.CodeAnnotation );

/*!
 * VisualEditor ContentEditable CodeSampleAnnotation class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable code sample annotation.
 *
 * @class
 * @extends ve.ce.TextStyleAnnotation
 * @constructor
 * @param {ve.dm.CodeSampleAnnotation} model Model to observe
 * @param {ve.ce.ContentBranchNode} [parentNode] Node rendering this annotation
 * @param {Object} [config] Configuration options
 */
ve.ce.CodeSampleAnnotation = function VeCeCodeSampleAnnotation() {
	// Parent constructor
	ve.ce.CodeSampleAnnotation.super.apply( this, arguments );

	// DOM changes
	this.$element.addClass( 've-ce-codeSampleAnnotation' );
};

/* Inheritance */

OO.inheritClass( ve.ce.CodeSampleAnnotation, ve.ce.TextStyleAnnotation );

/* Static Properties */

ve.ce.CodeSampleAnnotation.static.name = 'textStyle/codeSample';

ve.ce.CodeSampleAnnotation.static.tagName = 'samp';

/* Registration */

ve.ce.annotationFactory.register( ve.ce.CodeSampleAnnotation );

/*!
 * VisualEditor ContentEditable DatetimeAnnotation class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable datetime annotation.
 *
 * @class
 * @extends ve.ce.TextStyleAnnotation
 * @constructor
 * @param {ve.dm.DatetimeAnnotation} model Model to observe
 * @param {ve.ce.ContentBranchNode} [parentNode] Node rendering this annotation
 * @param {Object} [config] Configuration options
 */
ve.ce.DatetimeAnnotation = function VeCeDatetimeAnnotation() {
	// Parent constructor
	ve.ce.DatetimeAnnotation.super.apply( this, arguments );

	// DOM changes
	this.$element.addClass( 've-ce-datetimeAnnotation' );
};

/* Inheritance */

OO.inheritClass( ve.ce.DatetimeAnnotation, ve.ce.TextStyleAnnotation );

/* Static Properties */

ve.ce.DatetimeAnnotation.static.name = 'textStyle/datetime';

ve.ce.DatetimeAnnotation.static.tagName = 'time';

/* Registration */

ve.ce.annotationFactory.register( ve.ce.DatetimeAnnotation );

/*!
 * VisualEditor ContentEditable DefinitionAnnotation class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable definition annotation.
 *
 * @class
 * @extends ve.ce.TextStyleAnnotation
 * @constructor
 * @param {ve.dm.DefinitionAnnotation} model Model to observe
 * @param {ve.ce.ContentBranchNode} [parentNode] Node rendering this annotation
 * @param {Object} [config] Configuration options
 */
ve.ce.DefinitionAnnotation = function VeCeDefinitionAnnotation() {
	// Parent constructor
	ve.ce.DefinitionAnnotation.super.apply( this, arguments );

	// DOM changes
	this.$element.addClass( 've-ce-definitionAnnotation' );
};

/* Inheritance */

OO.inheritClass( ve.ce.DefinitionAnnotation, ve.ce.TextStyleAnnotation );

/* Static Properties */

ve.ce.DefinitionAnnotation.static.name = 'textStyle/definition';

ve.ce.DefinitionAnnotation.static.tagName = 'dfn';

/* Registration */

ve.ce.annotationFactory.register( ve.ce.DefinitionAnnotation );

/*!
 * VisualEditor ContentEditable FontAnnotation class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable font annotation.
 *
 * @class
 * @extends ve.ce.TextStyleAnnotation
 * @constructor
 * @param {ve.dm.FontAnnotation} model Model to observe
 * @param {ve.ce.ContentBranchNode} [parentNode] Node rendering this annotation
 * @param {Object} [config] Configuration options
 */
ve.ce.FontAnnotation = function VeCeFontAnnotation() {
	// Parent constructor
	ve.ce.FontAnnotation.super.apply( this, arguments );

	// DOM changes
	this.$element.addClass( 've-ce-fontAnnotation' );
};

/* Inheritance */

OO.inheritClass( ve.ce.FontAnnotation, ve.ce.TextStyleAnnotation );

/* Static Properties */

ve.ce.FontAnnotation.static.name = 'textStyle/font';

ve.ce.FontAnnotation.static.tagName = 'font';

/* Registration */

ve.ce.annotationFactory.register( ve.ce.FontAnnotation );

/*!
 * VisualEditor ContentEditable HighlightAnnotation class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable highlight annotation.
 *
 * @class
 * @extends ve.ce.TextStyleAnnotation
 * @constructor
 * @param {ve.dm.HighlightAnnotation} model Model to observe
 * @param {ve.ce.ContentBranchNode} [parentNode] Node rendering this annotation
 * @param {Object} [config] Configuration options
 */
ve.ce.HighlightAnnotation = function VeCeHighlightAnnotation() {
	// Parent constructor
	ve.ce.HighlightAnnotation.super.apply( this, arguments );

	// DOM changes
	this.$element.addClass( 've-ce-highlightAnnotation' );
};

/* Inheritance */

OO.inheritClass( ve.ce.HighlightAnnotation, ve.ce.TextStyleAnnotation );

/* Static Properties */

ve.ce.HighlightAnnotation.static.name = 'textStyle/highlight';

ve.ce.HighlightAnnotation.static.tagName = 'mark';

/* Registration */

ve.ce.annotationFactory.register( ve.ce.HighlightAnnotation );

/*!
 * VisualEditor ContentEditable ItalicAnnotation class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable italic annotation.
 *
 * @class
 * @extends ve.ce.TextStyleAnnotation
 * @constructor
 * @param {ve.dm.ItalicAnnotation} model Model to observe
 * @param {ve.ce.ContentBranchNode} [parentNode] Node rendering this annotation
 * @param {Object} [config] Configuration options
 */
ve.ce.ItalicAnnotation = function VeCeItalicAnnotation() {
	// Parent constructor
	ve.ce.ItalicAnnotation.super.apply( this, arguments );

	// DOM changes
	this.$element.addClass( 've-ce-italicAnnotation' );
};

/* Inheritance */

OO.inheritClass( ve.ce.ItalicAnnotation, ve.ce.TextStyleAnnotation );

/* Static Properties */

ve.ce.ItalicAnnotation.static.name = 'textStyle/italic';

ve.ce.ItalicAnnotation.static.tagName = 'i';

/* Registration */

ve.ce.annotationFactory.register( ve.ce.ItalicAnnotation );

/*!
 * VisualEditor ContentEditable QuotationAnnotation class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable quotation annotation.
 *
 * @class
 * @extends ve.ce.TextStyleAnnotation
 * @constructor
 * @param {ve.dm.QuotationAnnotation} model Model to observe
 * @param {ve.ce.ContentBranchNode} [parentNode] Node rendering this annotation
 * @param {Object} [config] Configuration options
 */
ve.ce.QuotationAnnotation = function VeCeQuotationAnnotation() {
	// Parent constructor
	ve.ce.QuotationAnnotation.super.apply( this, arguments );

	// DOM changes
	this.$element.addClass( 've-ce-quotationAnnotation' );
};

/* Inheritance */

OO.inheritClass( ve.ce.QuotationAnnotation, ve.ce.TextStyleAnnotation );

/* Static Properties */

ve.ce.QuotationAnnotation.static.name = 'textStyle/quotation';

ve.ce.QuotationAnnotation.static.tagName = 'q';

/* Registration */

ve.ce.annotationFactory.register( ve.ce.QuotationAnnotation );

/*!
 * VisualEditor ContentEditable SmallAnnotation class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable small annotation.
 *
 * @class
 * @extends ve.ce.TextStyleAnnotation
 * @constructor
 * @param {ve.dm.SmallAnnotation} model Model to observe
 * @param {ve.ce.ContentBranchNode} [parentNode] Node rendering this annotation
 * @param {Object} [config] Configuration options
 */
ve.ce.SmallAnnotation = function VeCeSmallAnnotation() {
	// Parent constructor
	ve.ce.SmallAnnotation.super.apply( this, arguments );

	// DOM changes
	this.$element.addClass( 've-ce-smallAnnotation' );
};

/* Inheritance */

OO.inheritClass( ve.ce.SmallAnnotation, ve.ce.TextStyleAnnotation );

/* Static Properties */

ve.ce.SmallAnnotation.static.name = 'textStyle/small';

ve.ce.SmallAnnotation.static.tagName = 'small';

/* Registration */

ve.ce.annotationFactory.register( ve.ce.SmallAnnotation );

/*!
 * VisualEditor ContentEditable SpanAnnotation class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable span annotation.
 *
 * @class
 * @extends ve.ce.TextStyleAnnotation
 * @constructor
 * @param {ve.dm.SpanAnnotation} model Model to observe
 * @param {ve.ce.ContentBranchNode} [parentNode] Node rendering this annotation
 * @param {Object} [config] Configuration options
 */
ve.ce.SpanAnnotation = function VeCeSpanAnnotation() {
	// Parent constructor
	ve.ce.SpanAnnotation.super.apply( this, arguments );

	// DOM changes
	this.$element.addClass( 've-ce-spanAnnotation' );
};

/* Inheritance */

OO.inheritClass( ve.ce.SpanAnnotation, ve.ce.TextStyleAnnotation );

/* Static Properties */

ve.ce.SpanAnnotation.static.name = 'textStyle/span';

ve.ce.SpanAnnotation.static.tagName = 'span';

/* Registration */

ve.ce.annotationFactory.register( ve.ce.SpanAnnotation );

/*!
 * VisualEditor ContentEditable StrikethroughAnnotation class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable strikethrough annotation.
 *
 * @class
 * @extends ve.ce.TextStyleAnnotation
 * @constructor
 * @param {ve.dm.StrikethroughAnnotation} model Model to observe
 * @param {ve.ce.ContentBranchNode} [parentNode] Node rendering this annotation
 * @param {Object} [config] Configuration options
 */
ve.ce.StrikethroughAnnotation = function VeCeStrikethroughAnnotation() {
	// Parent constructor
	ve.ce.StrikethroughAnnotation.super.apply( this, arguments );

	// DOM changes
	this.$element.addClass( 've-ce-strikethroughAnnotation' );
};

/* Inheritance */

OO.inheritClass( ve.ce.StrikethroughAnnotation, ve.ce.TextStyleAnnotation );

/* Static Properties */

ve.ce.StrikethroughAnnotation.static.name = 'textStyle/strikethrough';

ve.ce.StrikethroughAnnotation.static.tagName = 's';

/* Registration */

ve.ce.annotationFactory.register( ve.ce.StrikethroughAnnotation );

/*!
 * VisualEditor ContentEditable SubscriptAnnotation class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable subscript annotation.
 *
 * @class
 * @extends ve.ce.TextStyleAnnotation
 * @constructor
 * @param {ve.dm.SubscriptAnnotation} model Model to observe
 * @param {ve.ce.ContentBranchNode} [parentNode] Node rendering this annotation
 * @param {Object} [config] Configuration options
 */
ve.ce.SubscriptAnnotation = function VeCeSubscriptAnnotation() {
	// Parent constructor
	ve.ce.SubscriptAnnotation.super.apply( this, arguments );

	// DOM changes
	this.$element.addClass( 've-ce-subscriptAnnotation' );
};

/* Inheritance */

OO.inheritClass( ve.ce.SubscriptAnnotation, ve.ce.TextStyleAnnotation );

/* Static Properties */

ve.ce.SubscriptAnnotation.static.name = 'textStyle/subscript';

ve.ce.SubscriptAnnotation.static.tagName = 'sub';

/* Registration */

ve.ce.annotationFactory.register( ve.ce.SubscriptAnnotation );

/*!
 * VisualEditor ContentEditable SuperscriptAnnotation class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable superscript annotation.
 *
 * @class
 * @extends ve.ce.TextStyleAnnotation
 * @constructor
 * @param {ve.dm.SuperscriptAnnotation} model Model to observe
 * @param {ve.ce.ContentBranchNode} [parentNode] Node rendering this annotation
 * @param {Object} [config] Configuration options
 */
ve.ce.SuperscriptAnnotation = function VeCeSuperscriptAnnotation() {
	// Parent constructor
	ve.ce.SuperscriptAnnotation.super.apply( this, arguments );

	// DOM changes
	this.$element.addClass( 've-ce-superscriptAnnotation' );
};

/* Inheritance */

OO.inheritClass( ve.ce.SuperscriptAnnotation, ve.ce.TextStyleAnnotation );

/* Static Properties */

ve.ce.SuperscriptAnnotation.static.name = 'textStyle/superscript';

ve.ce.SuperscriptAnnotation.static.tagName = 'sup';

/* Registration */

ve.ce.annotationFactory.register( ve.ce.SuperscriptAnnotation );

/*!
 * VisualEditor ContentEditable UnderlineAnnotation class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable underline annotation.
 *
 * @class
 * @extends ve.ce.TextStyleAnnotation
 * @constructor
 * @param {ve.dm.UnderlineAnnotation} model Model to observe
 * @param {ve.ce.ContentBranchNode} [parentNode] Node rendering this annotation
 * @param {Object} [config] Configuration options
 */
ve.ce.UnderlineAnnotation = function VeCeUnderlineAnnotation() {
	// Parent constructor
	ve.ce.UnderlineAnnotation.super.apply( this, arguments );

	// DOM changes
	this.$element.addClass( 've-ce-underlineAnnotation' );
};

/* Inheritance */

OO.inheritClass( ve.ce.UnderlineAnnotation, ve.ce.TextStyleAnnotation );

/* Static Properties */

ve.ce.UnderlineAnnotation.static.name = 'textStyle/underline';

ve.ce.UnderlineAnnotation.static.tagName = 'u';

/* Registration */

ve.ce.annotationFactory.register( ve.ce.UnderlineAnnotation );

/*!
 * VisualEditor ContentEditable UserInputAnnotation class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable user input annotation.
 *
 * @class
 * @extends ve.ce.TextStyleAnnotation
 * @constructor
 * @param {ve.dm.UserInputAnnotation} model Model to observe
 * @param {ve.ce.ContentBranchNode} [parentNode] Node rendering this annotation
 * @param {Object} [config] Configuration options
 */
ve.ce.UserInputAnnotation = function VeCeUserInputAnnotation() {
	// Parent constructor
	ve.ce.UserInputAnnotation.super.apply( this, arguments );

	// DOM changes
	this.$element.addClass( 've-ce-userInputAnnotation' );
};

/* Inheritance */

OO.inheritClass( ve.ce.UserInputAnnotation, ve.ce.TextStyleAnnotation );

/* Static Properties */

ve.ce.UserInputAnnotation.static.name = 'textStyle/userInput';

ve.ce.UserInputAnnotation.static.tagName = 'kbd';

/* Registration */

ve.ce.annotationFactory.register( ve.ce.UserInputAnnotation );

/*!
 * VisualEditor ContentEditable VariableAnnotation class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * ContentEditable variable annotation.
 *
 * @class
 * @extends ve.ce.TextStyleAnnotation
 * @constructor
 * @param {ve.dm.VariableAnnotation} model Model to observe
 * @param {ve.ce.ContentBranchNode} [parentNode] Node rendering this annotation
 * @param {Object} [config] Configuration options
 */
ve.ce.VariableAnnotation = function VeCeVariableAnnotation() {
	// Parent constructor
	ve.ce.VariableAnnotation.super.apply( this, arguments );

	// DOM changes
	this.$element.addClass( 've-ce-variableAnnotation' );
};

/* Inheritance */

OO.inheritClass( ve.ce.VariableAnnotation, ve.ce.TextStyleAnnotation );

/* Static Properties */

ve.ce.VariableAnnotation.static.name = 'textStyle/variable';

ve.ce.VariableAnnotation.static.tagName = 'var';

/* Registration */

ve.ce.annotationFactory.register( ve.ce.VariableAnnotation );

/*!
 * VisualEditor UserInterface namespace.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Namespace for all VisualEditor UserInterface classes, static methods and static properties.
 *
 * @class
 * @singleton
 */
ve.ui = {
	// 'actionFactory' instantiated in ve.ui.ActionFactory.js
	// 'commandRegistry' instantiated in ve.ui.CommandRegistry.js
	// 'triggerRegistry' instantiated in ve.ui.TriggerRegistry.js
	// 'toolFactory' instantiated in ve.ui.ToolFactory.js
	// 'contextItemFactory' instantiated in ve.ui.ContextItemFactory.js
	// 'dataTransferHandlerFactory' instantiated in ve.ui.DataTransferHandlerFactory.js
	windowFactory: new OO.Factory()
};

ve.ui.windowFactory.register( OO.ui.MessageDialog );

/*!
 * VisualEditor UserInterface Overlay class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Container for content that should appear in front of everything else.
 *
 * @class
 * @abstract
 * @extends OO.ui.Element
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
ve.ui.Overlay = function VeUiOverlay( config ) {
	// Parent constructor
	OO.ui.Element.call( this, config );

	// Initialization
	this.$element.addClass( 've-ui-overlay' );
};

/* Inheritance */

OO.inheritClass( ve.ui.Overlay, OO.ui.Element );

/*!
 * VisualEditor UserInterface Surface class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * A surface is a top-level object which contains both a surface model and a surface view.
 *
 * @class
 * @abstract
 * @extends OO.ui.Element
 * @mixins OO.EventEmitter
 *
 * @constructor
 * @param {HTMLDocument|Array|ve.dm.LinearData|ve.dm.Document} dataOrDoc Document data to edit
 * @param {Object} [config] Configuration options
 * @cfg {string[]} [excludeCommands] List of commands to exclude
 * @cfg {Object} [importRules] Import rules
 */
ve.ui.Surface = function VeUiSurface( surfaceModel, config ) {
	config = config || {};

	var documentModel;

	// Parent constructor
	OO.ui.Element.call( this, config );

	// Mixin constructor
	OO.EventEmitter.call( this, config );

	// Properties
	this.globalOverlay = new ve.ui.Overlay( { classes: ['ve-ui-overlay-global'] } );
	this.localOverlay = new ve.ui.Overlay( { $: this.$, classes: ['ve-ui-overlay-local'] } );
	this.$selections = this.$( '<div>' );
	this.$blockers = this.$( '<div>' );
	this.$controls = this.$( '<div>' );
	this.$menus = this.$( '<div>' );
	this.triggerListener = new ve.TriggerListener( OO.simpleArrayDifference(
		Object.keys( ve.ui.commandRegistry.registry ), config.excludeCommands || []
	) );

	this.model = surfaceModel;
	documentModel = surfaceModel.getDocument();

	this.view = new ve.ce.Surface( this.model, this, { $: this.$ } );
	this.dialogs = this.createDialogWindowManager();
	this.importRules = config.importRules || { external: { blacklist: [] }, all: null };
	this.enabled = true;
	this.context = this.createContext();
	this.progresses = [];
	this.showProgressDebounced = ve.debounce( this.showProgress.bind( this ) );
	this.filibuster = null;
	this.debugBar = null;

	this.toolbarHeight = 0;
	this.toolbarDialogs = new ve.ui.ToolbarDialogWindowManager( this, {
		$: this.$,
		factory: ve.ui.windowFactory,
		modal: false
	} );

	// Initialization
	this.$menus.append( this.context.$element );
	this.$element
		.addClass( 've-ui-surface' )
		.append( this.view.$element );
	this.view.$element.after( this.localOverlay.$element );
	this.localOverlay.$element.append( this.$selections, this.$blockers, this.$controls, this.$menus );
	this.globalOverlay.$element.append( this.dialogs.$element );
};

/* Inheritance */

OO.inheritClass( ve.ui.Surface, OO.ui.Element );

OO.mixinClass( ve.ui.Surface, OO.EventEmitter );

/* Events */

/**
 * When a surface is destroyed.
 *
 * @event destroy
 */

/* Methods */

/**
 * Destroy the surface, releasing all memory and removing all DOM elements.
 *
 * @method
 * @fires destroy
 */
ve.ui.Surface.prototype.destroy = function () {
	// Stop periodic history tracking in model
	this.model.stopHistoryTracking();

	// Destroy the ce.Surface, the ui.Context and window managers
	this.view.destroy();
	this.context.destroy();
	this.dialogs.destroy();
	this.toolbarDialogs.destroy();
	if ( this.debugBar ) {
		this.debugBar.destroy();
	}

	// Remove DOM elements
	this.$element.remove();
	this.globalOverlay.$element.remove();

	// Let others know we have been destroyed
	this.emit( 'destroy' );
};

/**
 * Initialize surface.
 *
 * This must be called after the surface has been attached to the DOM.
 */
ve.ui.Surface.prototype.initialize = function () {
	// Attach globalOverlay to the global <body>, not the local frame's <body>
	$( 'body' ).append( this.globalOverlay.$element );

	if ( ve.debug ) {
		this.setupDebugBar();
	}

	// The following classes can be used here:
	// ve-ui-surface-dir-ltr
	// ve-ui-surface-dir-rtl
	this.$element.addClass( 've-ui-surface-dir-' + this.getDir() );

	this.getView().initialize();
	this.getModel().startHistoryTracking();
};

/**
 * Create a context.
 *
 * @method
 * @abstract
 * @return {ve.ui.Context} Context
 * @throws {Error} If this method is not overridden in a concrete subclass
 */
ve.ui.Surface.prototype.createContext = function () {
	throw new Error( 've.ui.Surface.createContext must be overridden in subclass' );
};

/**
 * Create a dialog window manager.
 *
 * @method
 * @abstract
 * @return {ve.ui.WindowManager} Dialog window manager
 * @throws {Error} If this method is not overridden in a concrete subclass
 */
ve.ui.Surface.prototype.createDialogWindowManager = function () {
	throw new Error( 've.ui.Surface.createDialogWindowManager must be overridden in subclass' );
};

/**
 * Set up the debug bar and insert it into the DOM.
 */
ve.ui.Surface.prototype.setupDebugBar = function () {
	this.debugBar = new ve.ui.DebugBar( this );
	this.debugBar.$element.insertAfter( this.$element );
};

/**
 * Get the bounding rectangle of the surface, relative to the viewport.
 * @returns {Object} Object with top, bottom, left, right, width and height properties.
 */
ve.ui.Surface.prototype.getBoundingClientRect = function () {
	// We would use getBoundingClientRect(), but in iOS7 that's relative to the
	// document rather than to the viewport
	return this.$element[0].getClientRects()[0];
};

/**
 * Check if editing is enabled.
 *
 * @method
 * @returns {boolean} Editing is enabled
 */
ve.ui.Surface.prototype.isEnabled = function () {
	return this.enabled;
};

/**
 * Get the surface model.
 *
 * @method
 * @returns {ve.dm.Surface} Surface model
 */
ve.ui.Surface.prototype.getModel = function () {
	return this.model;
};

/**
 * Get the surface view.
 *
 * @method
 * @returns {ve.ce.Surface} Surface view
 */
ve.ui.Surface.prototype.getView = function () {
	return this.view;
};

/**
 * Get the context menu.
 *
 * @method
 * @returns {ve.ui.Context} Context user interface
 */
ve.ui.Surface.prototype.getContext = function () {
	return this.context;
};

/**
 * Get dialogs window set.
 *
 * @method
 * @returns {ve.ui.WindowManager} Dialogs window set
 */
ve.ui.Surface.prototype.getDialogs = function () {
	return this.dialogs;
};

/**
 * Get toolbar dialogs window set.
 * @returns {ve.ui.WindowManager} Toolbar dialogs window set
 */
ve.ui.Surface.prototype.getToolbarDialogs = function () {
	return this.toolbarDialogs;
};

/**
 * Get the local overlay.
 *
 * Local overlays are attached to the same frame as the surface.
 *
 * @method
 * @returns {ve.ui.Overlay} Local overlay
 */
ve.ui.Surface.prototype.getLocalOverlay = function () {
	return this.localOverlay;
};

/**
 * Get the global overlay.
 *
 * Global overlays are attached to the top-most frame.
 *
 * @method
 * @returns {ve.ui.Overlay} Global overlay
 */
ve.ui.Surface.prototype.getGlobalOverlay = function () {
	return this.globalOverlay;
};

/**
 * Disable editing.
 *
 * @method
 */
ve.ui.Surface.prototype.disable = function () {
	this.view.disable();
	this.model.disable();
	this.enabled = false;
};

/**
 * Enable editing.
 *
 * @method
 */
ve.ui.Surface.prototype.enable = function () {
	this.enabled = true;
	this.view.enable();
	this.model.enable();
};

/**
 * Execute an action or command.
 *
 * @method
 * @param {ve.ui.Trigger|string} triggerOrAction Trigger or symbolic name of action
 * @param {string} [method] Action method name
 * @param {Mixed...} [args] Additional arguments for action
 * @returns {boolean} Action or command was executed
 */
ve.ui.Surface.prototype.execute = function ( triggerOrAction, method ) {
	var command, obj, ret;

	if ( !this.enabled ) {
		return;
	}

	if ( triggerOrAction instanceof ve.ui.Trigger ) {
		command = this.triggerListener.getCommandByTrigger( triggerOrAction.toString() );
		if ( command ) {
			// Have command call execute with action arguments
			return command.execute( this );
		}
	} else if ( typeof triggerOrAction === 'string' && typeof method === 'string' ) {
		// Validate method
		if ( ve.ui.actionFactory.doesActionSupportMethod( triggerOrAction, method ) ) {
			// Create an action object and execute the method on it
			obj = ve.ui.actionFactory.create( triggerOrAction, this );
			ret = obj[method].apply( obj, Array.prototype.slice.call( arguments, 2 ) );
			return ret === undefined || !!ret;
		}
	}
	return false;
};

/**
 * Set the current height of the toolbar.
 *
 * Used for scroll-into-view calculations.
 *
 * @param {number} toolbarHeight Toolbar height
 */
ve.ui.Surface.prototype.setToolbarHeight = function ( toolbarHeight ) {
	this.toolbarHeight = toolbarHeight;
};

/**
 * Create a progress bar in the progress dialog
 *
 * @param {jQuery.Promise} progressCompletePromise Promise which resolves when the progress action is complete
 * @param {jQuery|string|Function} label Progress bar label
 * @return {jQuery.Promise} Promise which resolves with a progress bar widget and a promise which fails if cancelled
 */
ve.ui.Surface.prototype.createProgress = function ( progressCompletePromise, label ) {
	var progressBarDeferred = $.Deferred();

	this.progresses.push( {
		label: label,
		progressCompletePromise: progressCompletePromise,
		progressBarDeferred: progressBarDeferred
	} );

	this.showProgressDebounced();

	return progressBarDeferred.promise();
};

ve.ui.Surface.prototype.showProgress = function () {
	var dialogs = this.dialogs,
		progresses = this.progresses;

	dialogs.openWindow( 'progress', { progresses: progresses } );
	this.progresses = [];
};

/**
 * Get sanitization rules for rich paste
 *
 * @returns {Object} Import rules
 */
ve.ui.Surface.prototype.getImportRules = function () {
	return this.importRules;
};

/**
 * Surface 'dir' property (GUI/User-Level Direction)
 *
 * @returns {string} 'ltr' or 'rtl'
 */
ve.ui.Surface.prototype.getDir = function () {
	return this.$element.css( 'direction' );
};

ve.ui.Surface.prototype.initFilibuster = function () {
	var surface = this;
	this.filibuster = new ve.Filibuster()
		.wrapClass( ve.EventSequencer )
		.wrapNamespace( ve.dm, 've.dm', [
			// blacklist
			ve.dm.LinearSelection.prototype.getDescription,
			ve.dm.TableSelection.prototype.getDescription,
			ve.dm.NullSelection.prototype.getDescription
		] )
		.wrapNamespace( ve.ce, 've.ce' )
		.wrapNamespace( ve.ui, 've.ui', [
			// blacklist
			ve.ui.Surface.prototype.startFilibuster,
			ve.ui.Surface.prototype.stopFilibuster
		] )
		.setObserver( 'dm doc', function () {
			return JSON.stringify( surface.model.documentModel.data.data );
		} )
		.setObserver( 'dm selection', function () {
			var selection = surface.model.selection;
			if ( !selection ) {
				return null;
			}
			return selection.getDescription();
		} )
		.setObserver( 'DOM doc', function () {
			return ve.serializeNodeDebug( surface.view.$element[0] );
		} )
		.setObserver( 'DOM selection', function () {
			var nativeRange,
				nativeSelection = surface.view.nativeSelection;
			if ( nativeSelection.rangeCount === 0 ) {
				return null;
			}
			nativeRange = nativeSelection.getRangeAt( 0 );
			return JSON.stringify( {
				startContainer: ve.serializeNodeDebug( nativeRange.startContainer ),
				startOffset: nativeRange.startOffset,
				endContainer: (
					nativeRange.startContainer === nativeRange.endContainer ?
					'(=startContainer)' :
					ve.serializeNodeDebug( nativeRange.endContainer )
				),
				endOffset: nativeRange.endOffset
			} );
		} );
};

ve.ui.Surface.prototype.startFilibuster = function () {
	if ( !this.filibuster ) {
		this.initFilibuster();
	} else {
		this.filibuster.clearLogs();
	}
	this.filibuster.start();
};

ve.ui.Surface.prototype.stopFilibuster = function () {
	this.filibuster.stop();
};

/*!
 * VisualEditor UserInterface Context class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * UserInterface context.
 *
 * @class
 * @abstract
 * @extends OO.ui.Element
 * @mixins OO.ui.GroupElement
 *
 * @constructor
 * @param {ve.ui.Surface} surface
 * @param {Object} [config] Configuration options
 */
ve.ui.Context = function VeUiContext( surface, config ) {
	// Parent constructor
	ve.ui.Context.super.call( this, config );

	// Mixin constructors
	OO.ui.GroupElement.call( this, config );

	// Properties
	this.surface = surface;
	this.visible = false;
	this.choosing = false;
	this.inspector = null;
	this.inspectors = this.createInspectorWindowManager();
	this.lastSelectedNode = null;
	this.afterContextChangeTimeout = null;
	this.afterContextChangeHandler = this.afterContextChange.bind( this );
	this.updateDimensionsDebounced = ve.debounce( this.updateDimensions.bind( this ) );

	// Events
	this.surface.getModel().connect( this, {
		contextChange: 'onContextChange',
		documentUpdate: 'onDocumentUpdate'
	} );
	this.inspectors.connect( this, { opening: 'onInspectorOpening' } );

	// Initialization
	// Hide element using a class, not this.toggle, as child implementations
	// of toggle may require the instance to be fully constructed before running.
	this.$group.addClass( 've-ui-context-menu' );
	this.$element
		.addClass( 've-ui-context oo-ui-element-hidden' )
		.append( this.$group );
	this.inspectors.$element.addClass( 've-ui-context-inspectors' );
};

/* Inheritance */

OO.inheritClass( ve.ui.Context, OO.ui.Element );
OO.mixinClass( ve.ui.Context, OO.ui.GroupElement );

/* Static Property */

/**
 * Instruct items to provide only a basic rendering.
 *
 * @static
 * @inheritable
 * @property {boolean}
 */
ve.ui.Context.static.basicRendering = false;

/* Methods */

ve.ui.Context.prototype.shouldUseBasicRendering = function () {
	return this.constructor.static.basicRendering;
};

/**
 * Handle context change event.
 *
 * While an inspector is opening or closing, all changes are ignored so as to prevent inspectors
 * that change the selection from within their setup or teardown processes changing context state.
 *
 * The response to selection changes is deferred to prevent teardown processes handlers that change
 * the selection from causing this function to recurse. These responses are also debounced for
 * efficiency, so that if there are three selection changes in the same tick, #afterContextChange only
 * runs once.
 *
 * @see #afterContextChange
 */
ve.ui.Context.prototype.onContextChange = function () {
	if ( this.inspector && ( this.inspector.isOpening() || this.inspector.isClosing() ) ) {
		// Cancel debounced change handler
		clearTimeout( this.afterContextChangeTimeout );
		this.afterContextChangeTimeout = null;
		this.lastSelectedNode = this.surface.getModel().getSelectedNode();
	} else {
		if ( this.afterContextChangeTimeout === null ) {
			// Ensure change is handled on next cycle
			this.afterContextChangeTimeout = setTimeout( this.afterContextChangeHandler );
		}
	}
	// Purge related items cache
	this.relatedSources = null;
};

/**
 * Handle document update event.
 */
ve.ui.Context.prototype.onDocumentUpdate = function () {
	// Only mind this event if the menu is visible
	if ( this.isVisible() && !this.isEmpty() ) {
		// Reuse the debounced context change hanlder
		this.onContextChange();
	}
};

/**
 * Handle debounced context change events.
 */
ve.ui.Context.prototype.afterContextChange = function () {
	var selectedNode = this.surface.getModel().getSelectedNode();

	// Reset debouncing state
	this.afterContextChangeTimeout = null;

	if ( this.isVisible() ) {
		if ( !this.isEmpty() ) {
			if ( this.isInspectable() ) {
				// Change state: menu -> menu
				this.teardownMenuItems();
				this.setupMenuItems();
				this.updateDimensionsDebounced();
			} else {
				// Change state: menu -> closed
				this.toggleMenu( false );
				this.toggle( false );
			}
		} else if (
			this.inspector &&
			( !selectedNode || ( selectedNode !== this.lastSelectedNode ) )
		) {
			// Change state: inspector -> (closed|menu)
			// Unless there is a selectedNode that hasn't changed (e.g. your inspector is editing a node)
			this.inspector.close();
		}
	} else {
		if ( this.isInspectable() ) {
			// Change state: closed -> menu
			this.toggleMenu( true );
			this.toggle( true );
		}
	}

	this.lastSelectedNode = selectedNode;
};

/**
 * Handle an inspector opening event.
 *
 * @param {OO.ui.Window} win Window that's being opened
 * @param {jQuery.Promise} opening Promise resolved when window is opened; when the promise is
 *   resolved the first argument will be a promise which will be resolved when the window begins
 *   closing, the second argument will be the opening data
 * @param {Object} data Window opening data
 */
ve.ui.Context.prototype.onInspectorOpening = function ( win, opening ) {
	var context = this,
		observer = this.surface.getView().surfaceObserver;
	this.inspector = win;

	// Shut down the SurfaceObserver as soon as possible, so it doesn't get confused
	// by the selection moving around in IE. Will be reenabled when inspector closes.
	// FIXME this should be done in a nicer way, managed by the Surface classes
	observer.pollOnce();
	observer.stopTimerLoop();

	opening
		.progress( function ( data ) {
			if ( data.state === 'setup' ) {
				if ( !context.isEmpty() ) {
					// Change state: menu -> inspector
					context.toggleMenu( false );
				} else if ( !context.isVisible() ) {
					// Change state: closed -> inspector
					context.toggle( true );
				}
			}
			context.updateDimensionsDebounced();
		} )
		.always( function ( opened ) {
			opened.always( function ( closed ) {
				closed.always( function () {
					var inspectable = context.isInspectable();

					context.inspector = null;

					// Reenable observer
					observer.startTimerLoop();

					if ( inspectable ) {
						// Change state: inspector -> menu
						context.toggleMenu( true );
						context.updateDimensionsDebounced();
					} else {
						// Change state: inspector -> closed
						context.toggle( false );
					}

					// Restore selection
					if ( context.getSurface().getModel().getSelection() ) {
						context.getSurface().getView().focus();
					}
				} );
			} );
		} );
};

/**
 * Check if context is visible.
 *
 * @return {boolean} Context is visible
 */
ve.ui.Context.prototype.isVisible = function () {
	return this.visible;
};

/**
 * Check if current content is inspectable.
 *
 * @return {boolean} Content is inspectable
 */
ve.ui.Context.prototype.isInspectable = function () {
	return !!this.getRelatedSources().length;
};

/**
 * Check if the context menu for current content is embeddable.
 *
 * @return {boolean} Context menu is embeddable
 */
ve.ui.Context.prototype.isEmbeddable = function () {
	var i, len,
		sources = this.getRelatedSources();

	for ( i = 0, len = sources.length; i < len; i++ ) {
		if ( !sources[i].embeddable ) {
			return false;
		}
	}

	return true;
};

/**
 * Get related item sources.
 *
 * Result is cached, and cleared when the model or selection changes.
 *
 * @returns {Object[]} List of objects containing `type`, `name` and `model` properties,
 *   representing each compatible type (either `item` or `tool`), symbolic name of the item or tool
 *   and the model the item or tool is compatible with
 */
ve.ui.Context.prototype.getRelatedSources = function () {
	var i, len, toolClass, items, tools, models, selectedModels;

	if ( !this.relatedSources ) {
		this.relatedSources = [];
		if ( this.surface.getModel().getSelection() instanceof ve.dm.LinearSelection ) {
			selectedModels = this.surface.getModel().getFragment().getSelectedModels();
			models = [];
			items = ve.ui.contextItemFactory.getRelatedItems( selectedModels );
			for ( i = 0, len = items.length; i < len; i++ ) {
				if ( ve.ui.contextItemFactory.isExclusive( items[i].name ) ) {
					models.push( items[i].model );
				}
				this.relatedSources.push( {
					type: 'item',
					embeddable: ve.ui.contextItemFactory.isEmbeddable( items[i].name ),
					name: items[i].name,
					model: items[i].model
				} );
			}
			tools = ve.ui.toolFactory.getRelatedItems( selectedModels );
			for ( i = 0, len = tools.length; i < len; i++ ) {
				if ( models.indexOf( tools[i].model ) === -1 ) {
					toolClass = ve.ui.toolFactory.lookup( tools[i].name );
					this.relatedSources.push( {
						type: 'tool',
						embeddable: !toolClass ||
							!( toolClass.prototype instanceof ve.ui.InspectorTool ),
						name: tools[i].name,
						model: tools[i].model
					} );
				}
			}
		}
	}

	return this.relatedSources;
};

/**
 * Get the surface the context is being used with.
 *
 * @return {ve.ui.Surface}
 */
ve.ui.Context.prototype.getSurface = function () {
	return this.surface;
};

/**
 * Get inspector window set.
 *
 * @return {ve.ui.WindowManager}
 */
ve.ui.Context.prototype.getInspectors = function () {
	return this.inspectors;
};

/**
 * Create a inspector window manager.
 *
 * @method
 * @abstract
 * @return {ve.ui.WindowManager} Inspector window manager
 * @throws {Error} If this method is not overridden in a concrete subclass
 */
ve.ui.Context.prototype.createInspectorWindowManager = function () {
	throw new Error( 've.ui.Context.createInspectorWindowManager must be overridden in subclass' );
};

/**
 * Toggle the menu.
 *
 * @param {boolean} [show] Show the menu, omit to toggle
 * @chainable
 */
ve.ui.Context.prototype.toggleMenu = function ( show ) {
	show = show === undefined ? !this.choosing : !!show;

	if ( show !== this.choosing ) {
		this.choosing = show;
		this.$element.toggleClass( 've-ui-context-choosing', show );
		if ( show ) {
			this.setupMenuItems();
		} else {
			this.teardownMenuItems();
		}
	}

	return this;
};

/**
 * Setup menu items.
 *
 * @protected
 * @chainable
 */
ve.ui.Context.prototype.setupMenuItems = function () {
	var i, len, source,
		sources = this.getRelatedSources(),
		items = [];

	for ( i = 0, len = sources.length; i < len; i++ ) {
		source = sources[i];
		if ( source.type === 'item' ) {
			items.push( ve.ui.contextItemFactory.create(
				sources[i].name, this, sources[i].model, { $: this.$ }
			) );
		} else if ( source.type === 'tool' ) {
			items.push( new ve.ui.ToolContextItem(
				this, sources[i].model, ve.ui.toolFactory.lookup( sources[i].name ), { $: this.$ }
			) );
		}
	}

	this.addItems( items );
	for ( i = 0, len = items.length; i < len; i++ ) {
		items[i].setup();
	}

	return this;
};

/**
 * Teardown menu items.
 *
 * @protected
 * @chainable
 */
ve.ui.Context.prototype.teardownMenuItems = function () {
	var i, len;

	for ( i = 0, len = this.items.length; i < len; i++ ) {
		this.items[i].teardown();
	}
	this.clearItems();

	return this;
};

/**
 * Toggle the visibility of the context.
 *
 * @param {boolean} [show] Show the context, omit to toggle
 * @return {jQuery.Promise} Promise resolved when context is finished showing/hiding
 */
ve.ui.Context.prototype.toggle = function ( show ) {
	show = show === undefined ? !this.visible : !!show;
	if ( show !== this.visible ) {
		this.visible = show;
		this.$element.toggleClass( 'oo-ui-element-hidden', !this.visible );
	}
	return $.Deferred().resolve().promise();
};

/**
 * Update the size and position of the context.
 *
 * @chainable
 */
ve.ui.Context.prototype.updateDimensions = function () {
	// Override in subclass if context is positioned relative to content
	return this;
};

/**
 * Destroy the context, removing all DOM elements.
 */
ve.ui.Context.prototype.destroy = function () {
	// Disconnect events
	this.surface.getModel().disconnect( this );
	this.inspectors.disconnect( this );

	// Destroy inspectors WindowManager
	this.inspectors.destroy();

	// Stop timers
	clearTimeout( this.afterContextChangeTimeout );

	this.$element.remove();
	return this;
};

/*!
 * VisualEditor UserInterface ModeledFactory class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Mixin for factories whose items associate with specific models.
 *
 * Classes registered with the factory should have a static method named `isCompatibleWith` that
 * accepts a model and returns a boolean.
 *
 * @class
 *
 * @constructor
 */
ve.ui.ModeledFactory = function VeUiModeledFactory() {};

/* Inheritance */

OO.initClass( ve.ui.ModeledFactory );

/* Methods */

/**
 * Get a list of symbolic names for classes related to a list of models.
 *
 * The lowest compatible item in each inheritance chain will be used.
 *
 * @param {Object[]} models Models to find relationships with
 * @returns {Object[]} List of objects containing `name` and `model` properties, representing
 *   each compatible class's symbolic name and the model it is compatible with
 */
ve.ui.ModeledFactory.prototype.getRelatedItems = function ( models ) {
	var i, iLen, j, jLen, name, classes, model,
		registry = this.registry,
		names = {},
		matches = [];

	/**
	 * Collect the most specific compatible classes for a model.
	 *
	 * @private
	 * @param {Object} model Model to find compatability with
	 * @returns {Function[]} List of compatible classes
	 */
	function collect( model ) {
		var i, len, name, candidate, add,
			candidates = [];

		for ( name in registry ) {
			candidate = registry[name];
			if ( candidate.static.isCompatibleWith( model ) ) {
				add = true;
				for ( i = 0, len = candidates.length; i < len; i++ ) {
					if ( candidate.prototype instanceof candidates[i] ) {
						candidates.splice( i, 1, candidate );
						add = false;
						break;
					} else if ( candidates[i].prototype instanceof candidate ) {
						add = false;
						break;
					}
				}
				if ( add ) {
					candidates.push( candidate );
				}
			}
		}

		return candidates;
	}

	// Collect compatible classes and the models they are specifically compatible with,
	// discarding class's with duplicate symbolic names
	for ( i = 0, iLen = models.length; i < iLen; i++ ) {
		model = models[i];
		classes = collect( model );
		for ( j = 0, jLen = classes.length; j < jLen; j++ ) {
			name = classes[j].static.name;
			if ( !names[name] ) {
				matches.push( { name: name, model: model } );
			}
			names[name] = true;
		}
	}

	return matches;
};

/*!
 * VisualEditor UserInterface ContextItem class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Item in a context.
 *
 * @class
 * @extends OO.ui.Widget
 * @mixins OO.ui.IconElement
 * @mixins OO.ui.LabelElement
 * @mixins OO.ui.PendingElement
 *
 * @constructor
 * @param {ve.ui.Context} context Context item is in
 * @param {ve.dm.Model} model Model item is related to
 * @param {Object} [config] Configuration options
 * @cfg {boolean} [basic] Render only basic information
 */
ve.ui.ContextItem = function ( context, model, config ) {
	// Parent constructor
	ve.ui.ContextItem.super.call( this, config );

	// Mixin constructors
	OO.ui.IconElement.call( this, config );
	OO.ui.LabelElement.call( this, config );
	OO.ui.PendingElement.call( this, config );

	// Properties
	this.context = context;
	this.model = model;
	this.$head = $( '<div>' );
	this.$title = $( '<div>' );
	this.$actions = $( '<div>' );
	this.$body = $( '<div>' );
	this.$info = $( '<div>' );
	this.$description = $( '<div>' );
	this.editButton = new OO.ui.ButtonWidget( {
		label: ve.msg( 'visualeditor-contextitemwidget-label-secondary' ),
		flags: [ 'progressive' ],
		classes: [ 've-ui-contextItem-editButton' ]
	} );
	this.fragment = null;

	// Events
	this.editButton.connect( this, { click: 'onEditButtonClick' } );
	this.$element.on( 'mousedown', false );

	// Initialization
	this.$label.addClass( 've-ui-contextItem-label' );
	this.$icon.addClass( 've-ui-contextItem-icon' );
	this.$description.addClass( 've-ui-contextItem-description' );
	this.$info
		.addClass( 've-ui-contextItem-info' )
		.append( this.$description );
	this.$title
		.addClass( 've-ui-contextItem-title' )
		.append( this.$icon, this.$label );
	this.$actions
		.addClass( 've-ui-contextItem-actions' )
		.append( this.editButton.$element );
	this.$head
		.addClass( 've-ui-contextItem-head' )
		.append( this.$title, this.$info, this.$actions );
	this.$body.addClass( 've-ui-contextItem-body' );
	this.$element
		.addClass( 've-ui-contextItem' )
		.toggleClass( 've-ui-contextItem-basic', this.context.shouldUseBasicRendering() )
		.append( this.$head, this.$body );
};

/* Inheritance */

OO.inheritClass( ve.ui.ContextItem, OO.ui.Widget );
OO.mixinClass( ve.ui.ContextItem, OO.ui.IconElement );
OO.mixinClass( ve.ui.ContextItem, OO.ui.LabelElement );
OO.mixinClass( ve.ui.ContextItem, OO.ui.PendingElement );

/* Static Properties */

ve.ui.ContextItem.static.editable = true;

ve.ui.ContextItem.static.embeddable = true;

/**
 * Whether this item exclusively handles any model class
 *
 * @static
 * @property {boolean}
 * @inheritable
 */
ve.ui.ContextItem.static.exclusive = true;

ve.ui.ContextItem.static.commandName = null;

/**
 * Annotation or node models this item is related to.
 *
 * Used by #isCompatibleWith.
 *
 * @static
 * @property {Function[]}
 * @inheritable
 */
ve.ui.ContextItem.static.modelClasses = [];

/* Methods */

/**
 * Handle edit button click events.
 *
 * @localdoc Executes the command related to #static-commandName on the context's surface
 *
 * @protected
 */
ve.ui.ContextItem.prototype.onEditButtonClick = function () {
	var command = this.getCommand();

	if ( command ) {
		command.execute( this.context.getSurface() );
	}
};

/**
 * Check if this item is compatible with a given model.
 *
 * @static
 * @inheritable
 * @param {ve.dm.Model} model Model to check
 * @return {boolean} Item can be used with model
 */
ve.ui.ContextItem.static.isCompatibleWith = function ( model ) {
	return ve.isInstanceOfAny( model, this.modelClasses );
};

/**
 * Check if item is editable.
 *
 * @return {boolean} Item is editable
 */
ve.ui.ContextItem.prototype.isEditable = function () {
	return this.constructor.static.editable;
};

/**
 * Get the command for this item.
 *
 * @return {ve.ui.Command} Command
 */
ve.ui.ContextItem.prototype.getCommand = function () {
	return ve.ui.commandRegistry.lookup( this.constructor.static.commandName );
};

/**
 * Get a surface fragment covering the related model item
 *
 * @return {ve.dm.SurfaceFragment} Surface fragment
 */
ve.ui.ContextItem.prototype.getFragment = function () {
	if ( !this.fragment ) {
		this.fragment = this.context.getSurface().getModel().getLinearFragment( this.model.getOuterRange() );
	}
	return this.fragment;
};

/**
 * Get the description.
 *
 * @localdoc Override for custom description content
 * @return {string} Item description
 */
ve.ui.ContextItem.prototype.getDescription = function () {
	return '';
};

/**
 * Render the body.
 *
 * @localdoc Renders the result of #getDescription, override for custom body rendering
 */
ve.ui.ContextItem.prototype.renderBody = function () {
	this.$body.text( this.getDescription() );
};

/**
 * Render the description.
 *
 * @localdoc Renders the result of #getDescription, override for custom description rendering
 */
ve.ui.ContextItem.prototype.renderDescription = function () {
	this.$description.text( this.getDescription() );
};

/**
 * Setup the item.
 *
 * @localdoc Calls #renderDescription if the context suggests basic rendering or #renderBody if not,
 *   override to start any async rendering common to the body and description
 * @chainable
 */
ve.ui.ContextItem.prototype.setup = function () {
	this.editButton.toggle( this.isEditable() );

	if ( this.context.shouldUseBasicRendering() ) {
		this.renderDescription();
	} else {
		this.renderBody();
	}

	return this;
};

/**
 * Teardown the item.
 *
 * @localdoc Empties the description and body, override to abort any async rendering
 * @chainable
 */
ve.ui.ContextItem.prototype.teardown = function () {
	this.$description.empty();
	this.$body.empty();
	return this;
};

/*!
 * VisualEditor UserInterface ContextItemFactory class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Factory for context items.
 *
 * @class
 * @extends OO.Factory
 * @mixins ve.ui.ModeledFactory
 *
 * @constructor
 */
ve.ui.ContextItemFactory = function VeUiContextItemFactory() {
	// Parent constructor
	ve.ui.ContextItemFactory.super.call( this );

	// Mixin constructors
	ve.ui.ModeledFactory.call( this );
};

/* Inheritance */

OO.inheritClass( ve.ui.ContextItemFactory, OO.Factory );
OO.mixinClass( ve.ui.ContextItemFactory, ve.ui.ModeledFactory );

/* Methods */

/**
 * Check if an item is embeddable.
 *
 * @param {string} name Symbolic item name
 * @return {boolean} Item is embeddable
 */
ve.ui.ContextItemFactory.prototype.isEmbeddable = function ( name ) {
	if ( Object.prototype.hasOwnProperty.call( this.registry, name ) ) {
		return !!this.registry[name].static.embeddable;
	}
	throw new Error( 'Unrecognized symbolic name: ' + name );
};

/**
 * Check if an item is exclusive.
 *
 * @param {string} name Symbolic item name
 * @return {boolean} Item is exclusive
 */
ve.ui.ContextItemFactory.prototype.isExclusive = function ( name ) {
	if ( Object.prototype.hasOwnProperty.call( this.registry, name ) ) {
		return !!this.registry[name].static.exclusive;
	}
	throw new Error( 'Unrecognized symbolic name: ' + name );
};

/* Initialization */

ve.ui.contextItemFactory = new ve.ui.ContextItemFactory();

/*!
 * VisualEditor Alignable class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Context item for an alignable node.
 *
 * @extends ve.ui.ContextItem
 *
 * @param {ve.ui.Context} context Context item is in
 * @param {ve.dm.Model} model Model item is related to
 * @param {Object} config Configuration options
 */
ve.ui.AlignableContextItem = function VeAlignable( context, model, config ) {
	// Parent constructor
	ve.ui.AlignableContextItem.super.call( this, context, model, config );

	var align = model.getAttribute( 'align' );

	this.align = new ve.ui.AlignWidget( {
		dir: this.context.getSurface().getDir()
	} );
	if ( align ) {
		this.align.selectItem( this.align.getItemFromData( align ) );
	}
	this.align.connect( this, { choose: 'onAlignChoose' } );

	// Initialization
	this.$element.addClass( 've-ui-alignableContextItem' );
};

/* Inheritance */

OO.inheritClass( ve.ui.AlignableContextItem, ve.ui.ContextItem );

/* Static Properties */

ve.ui.AlignableContextItem.static.name = 'alignable';

ve.ui.AlignableContextItem.static.icon = 'align-float-left';

ve.ui.AlignableContextItem.static.label = OO.ui.deferMsg( 'visualeditor-alignablecontextitem-title' );

ve.ui.AlignableContextItem.static.editable = false;

ve.ui.AlignableContextItem.static.exclusive = false;

ve.ui.AlignableContextItem.static.isCompatibleWith = function ( model ) {
	return model instanceof ve.dm.Node && model.isAlignable();
};

/* Methods */

/**
 * @inheritdoc
 */
ve.ui.AlignableContextItem.prototype.renderBody = function () {
	this.$body.empty().append( this.align.$element );
};

/**
 * @inheritdoc
 */
ve.ui.AlignableContextItem.prototype.renderDescription = function () {
	this.$description.empty().append( this.align.$element );
};

ve.ui.AlignableContextItem.prototype.onAlignChoose = function ( item ) {
	this.getFragment().changeAttributes( { align: item.getData() } );
};

/* Registration */

ve.ui.contextItemFactory.register( ve.ui.AlignableContextItem );

/*!
 * VisualEditor CommentContextItem class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Context item for a comment.
 *
 * @extends ve.ui.ContextItem
 *
 * @param {ve.ui.Context} context Context item is in
 * @param {ve.dm.Model} model Model item is related to
 * @param {Object} config Configuration options
 */
ve.ui.CommentContextItem = function VeCommentContextItem( context, model, config ) {
	// Parent constructor
	ve.ui.CommentContextItem.super.call( this, context, model, config );

	// Initialization
	this.$element.addClass( 've-ui-commentContextItem' );
};

/* Inheritance */

OO.inheritClass( ve.ui.CommentContextItem, ve.ui.ContextItem );

/* Static Properties */

ve.ui.CommentContextItem.static.name = 'comment';

ve.ui.CommentContextItem.static.icon = 'comment';

ve.ui.CommentContextItem.static.label = OO.ui.deferMsg( 'visualeditor-commentinspector-title' );

ve.ui.CommentContextItem.static.modelClasses = [ ve.dm.CommentNode ];

ve.ui.CommentContextItem.static.embeddable = false;

ve.ui.CommentContextItem.static.commandName = 'comment';

/* Methods */

/**
 * @inheritdoc
 */
ve.ui.CommentContextItem.prototype.getDescription = function () {
	return this.model.getAttribute( 'text' ).trim();
};

/* Registration */

ve.ui.contextItemFactory.register( ve.ui.CommentContextItem );

/*!
 * VisualEditor LanguageContextItem class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Context item for a language.
 *
 * @extends ve.ui.ContextItem
 *
 * @param {ve.ui.Context} context Context item is in
 * @param {ve.dm.Model} model Model item is related to
 * @param {Object} config Configuration options
 */
ve.ui.LanguageContextItem = function VeLanguageContextItem( context, model, config ) {
	// Parent constructor
	ve.ui.LanguageContextItem.super.call( this, context, model, config );

	// Initialization
	this.$element.addClass( 've-ui-languageContextItem' );
};

/* Inheritance */

OO.inheritClass( ve.ui.LanguageContextItem, ve.ui.ContextItem );

/* Static Properties */

ve.ui.LanguageContextItem.static.name = 'language';

ve.ui.LanguageContextItem.static.icon = 'language';

ve.ui.LanguageContextItem.static.label = OO.ui.deferMsg( 'visualeditor-languageinspector-title' );

ve.ui.LanguageContextItem.static.modelClasses = [ ve.dm.LanguageAnnotation ];

ve.ui.LanguageContextItem.static.embeddable = false;

ve.ui.LanguageContextItem.static.commandName = 'language';

/* Methods */

/**
 * @inheritdoc
 */
ve.ui.LanguageContextItem.prototype.getDescription = function () {
	return ve.ce.LanguageAnnotation.static.getDescription( this.model );
};

/* Registration */

ve.ui.contextItemFactory.register( ve.ui.LanguageContextItem );

/*!
 * VisualEditor LinkContextItem class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Context item for a link.
 *
 * @extends ve.ui.ContextItem
 *
 * @param {ve.ui.Context} context Context item is in
 * @param {ve.dm.Model} model Model item is related to
 * @param {Object} config Configuration options
 */
ve.ui.LinkContextItem = function VeLinkContextItem( context, model, config ) {
	// Parent constructor
	ve.ui.LinkContextItem.super.call( this, context, model, config );

	// Initialization
	this.$element.addClass( 've-ui-linkContextItem' );
};

/* Inheritance */

OO.inheritClass( ve.ui.LinkContextItem, ve.ui.ContextItem );

/* Static Properties */

ve.ui.LinkContextItem.static.name = 'link';

ve.ui.LinkContextItem.static.icon = 'link';

ve.ui.LinkContextItem.static.label = OO.ui.deferMsg( 'visualeditor-linkinspector-title' );

ve.ui.LinkContextItem.static.modelClasses = [ ve.dm.LinkAnnotation ];

ve.ui.LinkContextItem.static.embeddable = false;

ve.ui.LinkContextItem.static.commandName = 'link';

/* Methods */

/**
 * @inheritdoc
 */
ve.ui.LinkContextItem.prototype.getDescription = function () {
	return this.model.getHref();
};

/**
 * @inheritdoc
 */
ve.ui.LinkContextItem.prototype.renderBody = function () {
	var htmlDoc = this.context.getSurface().getModel().getDocument().getHtmlDocument();
	this.$body.empty().append(
		$( '<a>' )
			.text( this.getDescription() )
			.attr( {
				href: ve.resolveUrl( this.model.getHref(), htmlDoc ),
				target: '_blank'
			} )
	);
};

/* Registration */

ve.ui.contextItemFactory.register( ve.ui.LinkContextItem );

/*!
 * VisualEditor ToolContextItem class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Context item for a tool.
 *
 * @extends ve.ui.ContextItem
 *
 * @param {ve.ui.Context} context Context item is in
 * @param {ve.dm.Model} model Model the item is related to
 * @param {Function} tool Tool class the item is based on
 * @param {Object} config Configuration options
 */
ve.ui.ToolContextItem = function VeToolContextItem( context, model, tool, config ) {
	// Parent constructor
	ve.ui.ToolContextItem.super.call( this, context, model, config );

	// Properties
	this.tool = tool;

	// Initialization
	this.setIcon( tool.static.icon );
	this.setLabel( tool.static.title );
	this.$element.addClass( 've-ui-toolContextItem' );
};

/* Inheritance */

OO.inheritClass( ve.ui.ToolContextItem, ve.ui.ContextItem );

/* Methods */

/**
 * @inheritdoc
 */
ve.ui.ToolContextItem.prototype.getCommand = function () {
	return ve.ui.commandRegistry.lookup( this.tool.static.commandName );
};

/**
 * Get a description of the model.
 *
 * @return {string} Description of model
 */
ve.ui.ToolContextItem.prototype.getDescription = function () {
	var description = '';

	if ( this.model instanceof ve.dm.Annotation ) {
		description = ve.ce.annotationFactory.getDescription( this.model );
	} else if ( this.model instanceof ve.dm.Node ) {
		description = ve.ce.nodeFactory.getDescription( this.model );
	}

	return description;
};

/*!
 * VisualEditor UserInterface Table Context class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Context menu for editing tables.
 *
 * Two are usually generated for column and row actions separately.
 *
 * @class
 * @extends OO.ui.Element
 *
 * @constructor
 * @param {ve.ce.TableNode} tableNode
 * @param {string} toolGroup Tool group to use, 'table-col' or 'table-row'
 * @param {Object} [config] Configuration options
 * @cfg {string} [indicator] Indicator to use on button
 */
ve.ui.TableContext = function VeUiTableContext( tableNode, toolGroup, config ) {
	config = config || {};

	// Parent constructor
	ve.ui.TableContext.super.call( this, config );

	// Properties
	this.tableNode = tableNode;
	this.toolGroup = toolGroup;
	this.surface = tableNode.surface.getSurface();
	this.visible = false;
	this.indicator = new OO.ui.IndicatorWidget( {
		$: this.$,
		classes: ['ve-ui-tableContext-indicator'],
		indicator: config.indicator
	} );
	this.menu = new ve.ui.ContextSelectWidget( { $: this.$ } );
	this.popup = new OO.ui.PopupWidget( {
		$: this.$,
		$container: this.surface.$element,
		width: 150
	} );

	// Events
	this.indicator.$element.on( 'mousedown', this.onIndicatorMouseDown.bind( this ) );
	this.menu.connect( this, { choose: 'onContextItemChoose' } );
	this.onDocumentMouseDownHandler = this.onDocumentMouseDown.bind( this );

	// Initialization
	this.populateMenu();
	this.menu.$element.addClass( 've-ui-tableContext-menu' );
	this.popup.$body.append( this.menu.$element );
	this.$element.addClass( 've-ui-tableContext' ).append( this.indicator.$element, this.popup.$element );
};

/* Inheritance */

OO.inheritClass( ve.ui.TableContext, OO.ui.Element );

/* Methods */

/**
 * Populate menu items.
 */
ve.ui.TableContext.prototype.populateMenu = function () {
	var i, l, tool,
		items = [],
		toolList = ve.ui.toolFactory.getTools( [ { group: this.toolGroup } ] );

	this.menu.clearItems();
	for ( i = 0, l = toolList.length; i < l; i++ ) {
		tool = ve.ui.toolFactory.lookup( toolList[i] );
		items.push( new ve.ui.ContextOptionWidget(
			tool, this.tableNode.getModel(), { $: this.$, data: tool.static.name }
		) );
	}
	this.menu.addItems( items );
};

/**
 * Handle context item choose events.
 *
 * @param {ve.ui.ContextOptionWidget} item Chosen item
 */
ve.ui.TableContext.prototype.onContextItemChoose = function ( item ) {
	item.getCommand().execute( this.surface );
	this.toggle( false );
};

/**
 * Handle mouse down events on the indicator
 *
 * @param {jQuery.Event} e Mouse down event
 */
ve.ui.TableContext.prototype.onIndicatorMouseDown = function ( e ) {
	e.preventDefault();
	this.toggle();
};

/**
 * Handle document mouse down events
 *
 * @param {jQuery.Event} e Mouse down event
 */
ve.ui.TableContext.prototype.onDocumentMouseDown = function ( e ) {
	if ( !$( e.target ).closest( this.$element ).length ) {
		this.toggle( false );
	}
};

/**
 * Toggle visibility
 *
 * @param {boolean} [show] Show the context menu
 */
ve.ui.TableContext.prototype.toggle = function ( show ) {
	var dir,
		surfaceModel = this.surface.getModel(),
		surfaceView = this.surface.getView();
	this.popup.toggle( show );
	if ( this.popup.isVisible() ) {
		this.tableNode.setEditing( false );
		surfaceModel.connect( this, { select: 'toggle' } );
		surfaceView.$document.on( 'mousedown', this.onDocumentMouseDownHandler );
		dir = surfaceView.getDocument().getDirectionFromSelection( surfaceModel.getSelection() ) || surfaceModel.getDocument().getDir();
		this.$element
			.removeClass( 've-ui-dir-block-rtl ve-ui-dir-block-ltr' )
			.addClass( 've-ui-dir-block-' + dir );
	} else {
		surfaceModel.disconnect( this );
		surfaceView.$document.off( 'mousedown', this.onDocumentMouseDownHandler );
	}
};

/*!
 * VisualEditor UserInterface Tool classes.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * UserInterface annotation tool.
 *
 * @class
 * @abstract
 * @extends OO.ui.Tool
 *
 * @constructor
 * @param {OO.ui.ToolGroup} toolGroup
 * @param {Object} [config] Configuration options
 */
ve.ui.Tool = function VeUiTool( toolGroup, config ) {
	// Parent constructor
	OO.ui.Tool.call( this, toolGroup, config );
};

/* Inheritance */

OO.inheritClass( ve.ui.Tool, OO.ui.Tool );

/* Static Properties */

/**
 * Command to execute when tool is selected.
 *
 * @static
 * @property {string|null}
 * @inheritable
 */
ve.ui.Tool.static.commandName = null;

/**
 * Deactivate tool after it's been selected.
 *
 * Use this for tools which don't display as active when relevant content is selected, such as
 * insertion-only tools.
 *
 * @static
 * @property {boolean}
 * @inheritable
 */
ve.ui.Tool.static.deactivateOnSelect = true;

/**
 * Get the symbolic command name for this tool.
 *
 * @return {ve.ui.Command}
 */
ve.ui.Tool.static.getCommandName = function () {
	return this.commandName;
};

/* Methods */

/**
 * Handle the toolbar state being updated.
 *
 * @method
 * @param {ve.dm.SurfaceFragment|null} fragment Surface fragment
 * @param {Object|null} direction Context direction with 'inline' & 'block' properties
 */
ve.ui.Tool.prototype.onUpdateState = function ( fragment ) {
	var command = this.getCommand();
	if ( command !== null ) {
		this.setDisabled( !command || !fragment || !command.isExecutable( fragment ) );
	}
};

/**
 * @inheritdoc
 */
ve.ui.Tool.prototype.onSelect = function () {
	var command = this.getCommand();
	if ( command instanceof ve.ui.Command ) {
		command.execute( this.toolbar.getSurface() );
	}
	if ( this.constructor.static.deactivateOnSelect ) {
		this.setActive( false );
	}
};

/**
 * Get the command for this tool.
 *
 * @return {ve.ui.Command|null|undefined} Undefined means command not found, null means no command set
 */
ve.ui.Tool.prototype.getCommand = function () {
	if ( this.constructor.static.commandName === null ) {
		return null;
	}
	return ve.ui.commandRegistry.lookup( this.constructor.static.commandName );
};

/*!
 * VisualEditor UserInterface Toolbar class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * UserInterface surface toolbar.
 *
 * @class
 * @extends OO.ui.Toolbar
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {boolean} [floatable] Toolbar floats when scrolled off the page
 */
ve.ui.Toolbar = function VeUiToolbar( config ) {
	config = config || {};

	// Parent constructor
	OO.ui.Toolbar.call( this, ve.ui.toolFactory, ve.ui.toolGroupFactory, config );

	// Properties
	this.floating = false;
	this.floatable = !!config.floatable;
	this.$window = this.$( this.getElementWindow() );
	this.elementOffset = null;
	this.windowEvents = {
		// Must use Function#bind (or a closure) instead of direct reference
		// because we need a unique function references for each Toolbar instance
		// to avoid $window.off() from unbinding other toolbars' event handlers.
		scroll: this.onWindowScroll.bind( this )
	};
	// Default directions
	this.contextDirection = { inline: 'ltr', block: 'ltr' };
	// The following classes can be used here:
	// ve-ui-dir-inline-ltr
	// ve-ui-dir-inline-rtl
	// ve-ui-dir-block-ltr
	// ve-ui-dir-block-rtl
	this.$element
		.addClass( 've-ui-toolbar' )
		.addClass( 've-ui-dir-inline-' + this.contextDirection.inline )
		.addClass( 've-ui-dir-block-' + this.contextDirection.block );
};

/* Inheritance */

OO.inheritClass( ve.ui.Toolbar, OO.ui.Toolbar );

/* Events */

/**
 * @event updateState
 * @param {ve.dm.SurfaceFragment|null} fragment Surface fragment. Null if no surface is active.
 * @param {Object|null} direction Context direction with 'inline' & 'block' properties if a surface exists. Null if no surface is active.
 */

/* Methods */

/**
 * Setup toolbar
 *
 * @param {Object} groups List of tool group configurations
 * @param {ve.ui.Surface} [surface] Surface to attach to
 */
ve.ui.Toolbar.prototype.setup = function ( groups, surface ) {
	this.detach();

	this.surface = surface;

	// Parent method
	ve.ui.Toolbar.super.prototype.setup.call( this, groups );

	// Events
	this.getSurface().getModel().connect( this, { contextChange: 'onContextChange' } );
	this.getSurface().getToolbarDialogs().connect( this, {
		opening: 'onToolbarDialogsOpeningOrClosing',
		closing: 'onToolbarDialogsOpeningOrClosing'
	} );
};

/**
 * @inheritdoc
 */
ve.ui.Toolbar.prototype.isToolAvailable = function ( name ) {
	if ( !ve.ui.Toolbar.super.prototype.isToolAvailable.apply( this, arguments ) ) {
		return false;
	}
	// Check the tool's command is available on the surface
	var commandName,
		tool = this.getToolFactory().lookup( name );
	if ( !tool ) {
		return false;
	}
	// FIXME should use .static.getCommandName(), but we have tools that aren't ve.ui.Tool subclasses :(
	commandName = tool.static.commandName;
	return !commandName || this.getCommands().indexOf( commandName ) !== -1;
};

/**
 * Handle window scroll events.
 *
 * @param {jQuery.Event} e Window scroll event
 */
ve.ui.Toolbar.prototype.onWindowScroll = function () {
	var scrollTop = this.$window.scrollTop();

	if ( scrollTop > this.elementOffset.top ) {
		this.float();
	} else if ( this.floating ) {
		this.unfloat();
	}
};

/**
 * @inheritdoc
 *
 * While toolbar floating is enabled,
 * the toolbar will stick to the top of the screen unless it would be over or under the last visible
 * branch node in the root of the document being edited, at which point it will stop just above it.
 */
ve.ui.Toolbar.prototype.onWindowResize = function () {
	ve.ui.Toolbar.super.prototype.onWindowResize.call( this );

	// Update offsets after resize (see #float)
	this.calculateOffset();

	if ( this.floating ) {
		this.$bar.css( {
			left: this.elementOffset.left,
			right: this.elementOffset.right
		} );
	}
};

/**
 * Handle windows opening or closing in the toolbar window manager.
 *
 * @param {OO.ui.Window} win
 * @param {jQuery.Promise} openingOrClosing
 * @param {Object} data
 */
ve.ui.Toolbar.prototype.onToolbarDialogsOpeningOrClosing = function ( win, openingOrClosing ) {
	var toolbar = this;
	openingOrClosing.then( function () {
		toolbar.updateToolState();
		// Wait for window transition
		setTimeout( function () {
			if ( toolbar.floating ) {
				// Re-calculate height
				toolbar.unfloat();
				toolbar.float();
			}
		}, 250 );
	} );
};

/**
 * Handle context changes on the surface.
 *
 * @fires updateState
 */
ve.ui.Toolbar.prototype.onContextChange = function () {
	this.updateToolState();
};

/**
 * Update the state of the tools
 */
ve.ui.Toolbar.prototype.updateToolState = function () {
	if ( !this.getSurface() ) {
		this.emit( 'updateState', null, null );
		return;
	}

	var dirInline, dirBlock, fragmentAnnotation,
		fragment = this.getSurface().getModel().getFragment();

	// Update context direction for button icons UI.
	// By default, inline and block directions are the same.
	// If no context direction is available, use document model direction.
	dirInline = dirBlock = this.surface.getView().documentView.getDirectionFromSelection( fragment.getSelection() ) ||
		fragment.getDocument().getDir();

	// 'inline' direction is different only if we are inside a language annotation
	fragmentAnnotation = fragment.getAnnotations();
	if ( fragmentAnnotation.hasAnnotationWithName( 'meta/language' ) ) {
		dirInline = fragmentAnnotation.getAnnotationsByName( 'meta/language' ).get( 0 ).getAttribute( 'dir' );
	}

	if ( dirInline !== this.contextDirection.inline ) {
		// remove previous class:
		this.$element.removeClass( 've-ui-dir-inline-rtl ve-ui-dir-inline-ltr' );
		// The following classes can be used here:
		// ve-ui-dir-inline-ltr
		// ve-ui-dir-inline-rtl
		this.$element.addClass( 've-ui-dir-inline-' + dirInline );
		this.contextDirection.inline = dirInline;
	}
	if ( dirBlock !== this.contextDirection.block ) {
		this.$element.removeClass( 've-ui-dir-block-rtl ve-ui-dir-block-ltr' );
		// The following classes can be used here:
		// ve-ui-dir-block-ltr
		// ve-ui-dir-block-rtl
		this.$element.addClass( 've-ui-dir-block-' + dirBlock );
		this.contextDirection.block = dirBlock;
	}
	this.emit( 'updateState', fragment, this.contextDirection );
};

/**
 * Get triggers for a specified name.
 *
 * @param {string} name Trigger name
 * @returns {ve.ui.Trigger[]|undefined} Triggers
 */
ve.ui.Toolbar.prototype.getTriggers = function ( name ) {
	return this.getSurface().triggerListener.getTriggers( name );
};

/**
 * Get a list of commands available to this toolbar's surface
 *
 * @return {string[]} Command names
 */
ve.ui.Toolbar.prototype.getCommands = function () {
	return this.getSurface().triggerListener.getCommands();
};

/**
 * @inheritdoc
 */
ve.ui.Toolbar.prototype.getToolAccelerator = function ( name ) {
	var messages = ve.ui.triggerRegistry.getMessages( name );

	return messages ? messages.join( ', ' ) : undefined;
};

/**
 * Gets the surface which the toolbar controls.
 *
 * @returns {ve.ui.Surface} Surface being controlled
 */
ve.ui.Toolbar.prototype.getSurface = function () {
	return this.surface;
};

/**
 * @inheritdoc
 */
ve.ui.Toolbar.prototype.initialize = function () {
	// Parent method
	OO.ui.Toolbar.prototype.initialize.call( this );

	// #calculateOffset was called by parent method via #onWindowResize

	if ( this.floatable ) {
		this.$window.on( this.windowEvents );
		// The page may start with a non-zero scroll position
		this.onWindowScroll();
	}
};

/**
 * Calculate the left and right offsets of the toolbar
 */
ve.ui.Toolbar.prototype.calculateOffset = function () {
	this.elementOffset = this.$element.offset();
	this.elementOffset.right = this.$window.width() - this.$element.outerWidth() - this.elementOffset.left;
};

/**
 * Detach toolbar from surface and all event listeners
 */
ve.ui.Toolbar.prototype.detach = function () {
	this.unfloat();

	// Events
	if ( this.getSurface() ) {
		this.getSurface().getModel().disconnect( this );
		this.getSurface().getToolbarDialogs().disconnect( this );
		this.getSurface().getToolbarDialogs().clearWindows();
		this.surface = null;
	}
};

/**
 * Destroys toolbar, removing event handlers and DOM elements.
 *
 * Call this whenever you are done using a toolbar.
 */
ve.ui.Toolbar.prototype.destroy = function () {
	// Parent method
	OO.ui.Toolbar.prototype.destroy.call( this );

	// Events
	if ( this.$window ) {
		this.$window.off( this.windowEvents );
	}

	// Detach surface last, because tool destructors need getSurface()
	this.detach();
};

/**
 * Float the toolbar.
 */
ve.ui.Toolbar.prototype.float = function () {
	if ( !this.floating ) {
		var height = this.$element.height();
		// When switching into floating mode, set the height of the wrapper and
		// move the bar to the same offset as the in-flow element
		this.$element
			.css( 'height', height )
			.addClass( 've-ui-toolbar-floating' );
		this.$bar.css( {
			left: this.elementOffset.left,
			right: this.elementOffset.right
		} );
		this.floating = true;
		this.surface.setToolbarHeight( height );
	}
};

/**
 * Reset the toolbar to it's default non-floating position.
 */
ve.ui.Toolbar.prototype.unfloat = function () {
	if ( this.floating ) {
		this.$element
			.css( 'height', '' )
			.removeClass( 've-ui-toolbar-floating' );
		this.$bar.css( { left: '', right: '' } );
		this.floating = false;
		this.surface.setToolbarHeight( 0 );
	}
};

/*!
 * VisualEditor UserInterface TargetToolbar class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * UserInterface target toolbar.
 *
 * @class
 * @extends ve.ui.Toolbar
 *
 * @constructor
 * @param {ve.init.Target} target Target to control
 * @param {Object} [config] Configuration options
 */
ve.ui.TargetToolbar = function VeUiTargetToolbar( target, config ) {
	// Parent constructor
	ve.ui.TargetToolbar.super.call( this, config );

	// Properties
	this.target = target;
};

/* Inheritance */

OO.inheritClass( ve.ui.TargetToolbar, ve.ui.Toolbar );

/* Methods */

/**
 * Gets the target which the toolbar controls.
 *
 * @returns {ve.init.Target} Target being controlled
 */
ve.ui.TargetToolbar.prototype.getTarget = function () {
	return this.target;
};

/**
 * @inheritdoc
 */
ve.ui.TargetToolbar.prototype.getTriggers = function ( name ) {
	var triggers = ve.ui.TargetToolbar.super.prototype.getTriggers.apply( this, arguments );
	return triggers ||
		this.getTarget().targetTriggerListener.getTriggers( name ) ||
		this.getTarget().documentTriggerListener.getTriggers( name );
};

/**
 * @inheritdoc
 */
ve.ui.TargetToolbar.prototype.getCommands = function () {
	return ve.ui.TargetToolbar.super.prototype.getCommands.apply( this, arguments ).concat(
		this.getTarget().targetTriggerListener.getCommands(),
		this.getTarget().documentTriggerListener.getCommands()
	);
};

/*!
 * VisualEditor UserInterface ToolFactory class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Factory for tools.
 *
 * @class
 * @extends OO.ui.ToolFactory
 * @mixins ve.ui.ModeledFactory
 *
 * @constructor
 */
ve.ui.ToolFactory = function VeUiToolFactory() {
	// Parent constructor
	ve.ui.ToolFactory.super.call( this );

	// Mixin constructors
	ve.ui.ModeledFactory.call( this );
};

/* Inheritance */

OO.inheritClass( ve.ui.ToolFactory, OO.ui.ToolFactory );
OO.mixinClass( ve.ui.ToolFactory, ve.ui.ModeledFactory );

/* Initialization */

ve.ui.toolFactory = new ve.ui.ToolFactory();

ve.ui.toolGroupFactory = new OO.ui.ToolGroupFactory();

/*!
 * VisualEditor UserInterface Command class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Command that executes an action.
 *
 * @class
 *
 * @constructor
 * @param {string} name Symbolic name for the command
 * @param {string} action Action to execute when command is triggered
 * @param {string} method Method to call on action when executing
 * @param {Object} [options] Command options
 * @param {string[]|null} [options.supportedSelections] List of supported selection types, or null for all
 * @param {Array} [options.args] Additional arguments to pass to the action when executing
 */
ve.ui.Command = function VeUiCommand( name, action, method, options ) {
	options = options || {};
	this.name = name;
	this.action = action;
	this.method = method;
	this.supportedSelections = options.supportedSelections || null;
	this.args = options.args || [];
};

/* Methods */

/**
 * Execute command on a surface.
 *
 * @param {ve.ui.Surface} surface Surface to execute command on
 * @return {boolean} Command was executed
 */
ve.ui.Command.prototype.execute = function ( surface ) {
	if ( this.isExecutable( surface.getModel().getFragment() ) ) {
		return surface.execute.apply( surface, [ this.action, this.method ].concat( this.args ) );
	} else {
		return false;
	}
};

/**
 * Check if this command is executable on a given surface fragment
 *
 * @param {ve.dm.SurfaceFragment} fragment Surface fragment
 * @return {boolean} The command can execute on this fragment
 */
ve.ui.Command.prototype.isExecutable = function ( fragment ) {
	return !this.supportedSelections ||
		this.supportedSelections.indexOf( fragment.getSelection().constructor.static.name ) !== -1;
};

/**
 * Get command action.
 *
 * @returns {string} action Action to execute when command is triggered
 */
ve.ui.Command.prototype.getAction = function () {
	return this.action;
};

/**
 * Get command method.
 *
 * @returns {string} method Method to call on action when executing
 */
ve.ui.Command.prototype.getMethod = function () {
	return this.method;
};

/**
 * Get command name.
 *
 * @returns {string} name The symbolic name of the command.
 */
ve.ui.Command.prototype.getName = function () {
	return this.name;
};

/**
 * Get command arguments.
 *
 * @returns {Array} args Additional arguments to pass to the action when executing
 */
ve.ui.Command.prototype.getArgs = function () {
	return this.args;
};

/*!
 * VisualEditor CommandRegistry class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Command registry.
 *
 * @class
 * @extends OO.Registry
 * @constructor
 */
ve.ui.CommandRegistry = function VeCommandRegistry() {
	// Parent constructor
	OO.Registry.call( this );
};

/* Inheritance */

OO.inheritClass( ve.ui.CommandRegistry, OO.Registry );

/* Methods */

/**
 * Register a command with the factory.
 *
 * @method
 * @param {ve.ui.Command} command Command object
 * @throws {Error} If command is not an instance of ve.ui.Command
 */
ve.ui.CommandRegistry.prototype.register = function ( command ) {
	// Validate arguments
	if ( !( command instanceof ve.ui.Command ) ) {
		throw new Error(
			'command must be an instance of ve.ui.Command, cannot be a ' + typeof command
		);
	}

	OO.Registry.prototype.register.call( this, command.getName(), command );
};

/**
 * Returns the primary command for for node.
 *
 * @param {ve.ce.Node} node Node to get command for
 * @returns {ve.ui.Command}
 */
ve.ui.CommandRegistry.prototype.getCommandForNode = function ( node ) {
	return this.lookup( node.constructor.static.primaryCommandName );
};

/* Initialization */

ve.ui.commandRegistry = new ve.ui.CommandRegistry();

/* Registrations */

ve.ui.commandRegistry.register(
	new ve.ui.Command(
		'bold', 'annotation', 'toggle',
		{ args: ['textStyle/bold'], supportedSelections: ['linear', 'table'] }
	)
);
ve.ui.commandRegistry.register(
	new ve.ui.Command(
		'italic', 'annotation', 'toggle',
		{ args: ['textStyle/italic'], supportedSelections: ['linear', 'table'] }
	)
);
ve.ui.commandRegistry.register(
	new ve.ui.Command(
		'code', 'annotation', 'toggle',
		{ args: ['textStyle/code'], supportedSelections: ['linear', 'table'] }
	)
);
ve.ui.commandRegistry.register(
	new ve.ui.Command(
		'strikethrough', 'annotation', 'toggle',
		{ args: ['textStyle/strikethrough'], supportedSelections: ['linear', 'table'] }
	)
);
ve.ui.commandRegistry.register(
	new ve.ui.Command(
		'underline', 'annotation', 'toggle',
		{ args: ['textStyle/underline'], supportedSelections: ['linear', 'table'] }
	)
);
ve.ui.commandRegistry.register(
	new ve.ui.Command(
		'subscript', 'annotation', 'toggle',
		{ args: ['textStyle/subscript'], supportedSelections: ['linear', 'table'] }
	)
);
ve.ui.commandRegistry.register(
	new ve.ui.Command(
		'superscript', 'annotation', 'toggle',
		{ args: ['textStyle/superscript'], supportedSelections: ['linear', 'table'] }
	)
);
ve.ui.commandRegistry.register(
	new ve.ui.Command(
		'link', 'window', 'open',
		{ args: ['link'], supportedSelections: ['linear'] }
	)
);
ve.ui.commandRegistry.register(
	new ve.ui.Command(
		'specialCharacter', 'window', 'toggle',
		{ args: ['specialCharacter'], supportedSelections: ['linear'] }
	)
);
ve.ui.commandRegistry.register(
	new ve.ui.Command(
		'number', 'list', 'toggle',
		{ args: ['number'], supportedSelections: ['linear'] }
	)
);
ve.ui.commandRegistry.register(
	new ve.ui.Command(
		'bullet', 'list', 'toggle',
		{ args: ['bullet'], supportedSelections: ['linear'] }
	)
);
ve.ui.commandRegistry.register(
	new ve.ui.Command(
		'numberWrapOnce', 'list', 'wrapOnce',
		{ args: ['number', true], supportedSelections: ['linear'] }
	)
);
ve.ui.commandRegistry.register(
	new ve.ui.Command(
		'bulletWrapOnce', 'list', 'wrapOnce',
		{ args: ['bullet', true], supportedSelections: ['linear'] }
	)
);
ve.ui.commandRegistry.register(
	new ve.ui.Command(
		'commandHelp', 'window', 'open', { args: ['commandHelp'] }
	)
);
ve.ui.commandRegistry.register(
	new ve.ui.Command(
		'findAndReplace', 'window', 'toggle', { args: ['findAndReplace'] }
	)
);
ve.ui.commandRegistry.register(
	new ve.ui.Command(
		'findNext', 'window', 'open', { args: ['findAndReplace', null, 'findNext'] }
	)
);
ve.ui.commandRegistry.register(
	new ve.ui.Command(
		'findPrevious', 'window', 'open', { args: ['findAndReplace', null, 'findPrevious'] }
	)
);
ve.ui.commandRegistry.register(
	new ve.ui.Command(
		'code', 'annotation', 'toggle',
		{ args: ['textStyle/code'], supportedSelections: ['linear', 'table'] }
	)
);
ve.ui.commandRegistry.register(
	new ve.ui.Command(
		'strikethrough', 'annotation', 'toggle',
		{ args: ['textStyle/strikethrough'], supportedSelections: ['linear', 'table'] }
	)
);
ve.ui.commandRegistry.register(
	new ve.ui.Command(
		'language', 'window', 'open',
		{ args: ['language'], supportedSelections: ['linear'] }
	)
);
ve.ui.commandRegistry.register(
	new ve.ui.Command(
		'paragraph', 'format', 'convert',
		{ args: ['paragraph'], supportedSelections: ['linear'] }
	)
);
ve.ui.commandRegistry.register(
	new ve.ui.Command(
		'heading1', 'format', 'convert',
		{ args: ['heading', { level: 1 } ], supportedSelections: ['linear'] }
	)
);
ve.ui.commandRegistry.register(
	new ve.ui.Command(
		'heading2', 'format', 'convert',
		{ args: ['heading', { level: 2 } ], supportedSelections: ['linear'] }
	)
);
ve.ui.commandRegistry.register(
	new ve.ui.Command(
		'heading3', 'format', 'convert',
		{ args: ['heading', { level: 3 } ], supportedSelections: ['linear'] }
	)
);
ve.ui.commandRegistry.register(
	new ve.ui.Command(
		'heading4', 'format', 'convert',
		{ args: ['heading', { level: 4 } ], supportedSelections: ['linear'] }
	)
);
ve.ui.commandRegistry.register(
	new ve.ui.Command(
		'heading5', 'format', 'convert',
		{ args: ['heading', { level: 5 } ], supportedSelections: ['linear'] }
	)
);
ve.ui.commandRegistry.register(
	new ve.ui.Command(
		'heading6', 'format', 'convert',
		{ args: ['heading', { level: 6 } ], supportedSelections: ['linear'] }
	)
);
ve.ui.commandRegistry.register(
	new ve.ui.Command(
		'preformatted', 'format', 'convert',
		{ args: ['preformatted'], supportedSelections: ['linear'] }
	)
);
ve.ui.commandRegistry.register(
	new ve.ui.Command(
		'blockquote', 'format', 'convert',
		{ args: ['blockquote'], supportedSelections: ['linear'] }
	)
);
ve.ui.commandRegistry.register(
	new ve.ui.Command(
		'pasteSpecial', 'content', 'pasteSpecial',
		{ supportedSelections: ['linear', 'table'] }
	)
);
ve.ui.commandRegistry.register(
	new ve.ui.Command(
		'selectAll', 'content', 'selectAll',
		{ supportedSelections: ['linear', 'table'] }
	)
);
ve.ui.commandRegistry.register(
	new ve.ui.Command(
		'comment', 'window', 'open',
		{ args: ['comment'], supportedSelections: ['linear'] }
	)
);
ve.ui.commandRegistry.register(
	new ve.ui.Command(
		'insertTable', 'table', 'create',
		{
			args: [ {
				header: true,
				rows: 3,
				cols: 4
			} ],
			supportedSelections: ['linear']
		}
	)
);
ve.ui.commandRegistry.register(
	new ve.ui.Command(
		'deleteTable', 'table', 'delete',
		{ args: ['table'], supportedSelections: ['table'] }
	)
);
ve.ui.commandRegistry.register(
	new ve.ui.Command(
		'insertRowBefore', 'table', 'insert',
		{ args: ['row', 'before'], supportedSelections: ['table'] }
	)
);
ve.ui.commandRegistry.register(
	new ve.ui.Command(
		'insertRowAfter', 'table', 'insert',
		{ args: ['row', 'after'], supportedSelections: ['table'] }
	)
);
ve.ui.commandRegistry.register(
	new ve.ui.Command(
		'deleteRow', 'table', 'delete',
		{ args: ['row'], supportedSelections: ['table'] }
	)
);
ve.ui.commandRegistry.register(
	new ve.ui.Command(
		'insertColumnBefore', 'table', 'insert',
		{ args: ['col', 'before'], supportedSelections: ['table'] }
	)
);
ve.ui.commandRegistry.register(
	new ve.ui.Command(
		'insertColumnAfter', 'table', 'insert',
		{ args: ['col', 'after'], supportedSelections: ['table'] }
	)
);
ve.ui.commandRegistry.register(
	new ve.ui.Command( 'deleteColumn', 'table', 'delete',
		{ args: ['col'], supportedSelections: ['table'] }
	)
);
ve.ui.commandRegistry.register(
	new ve.ui.Command(
		'tableCellHeader', 'table', 'changeCellStyle',
		{ args: ['header'], supportedSelections: ['table'] }
	)
);
ve.ui.commandRegistry.register(
	new ve.ui.Command(
		'tableCellData', 'table', 'changeCellStyle',
		{ args: ['data'], supportedSelections: ['table'] }
	)
);

/*!
 * VisualEditor UserInterface Trigger class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Key trigger.
 *
 * @class
 *
 * @constructor
 * @param {jQuery.Event|string} [e] Event or string to create trigger from
 * @param {boolean} [allowInvalidPrimary] Allow invalid primary keys
 */
ve.ui.Trigger = function VeUiTrigger( e, allowInvalidPrimary ) {
	// Properties
	this.modifiers = {
		meta: false,
		ctrl: false,
		alt: false,
		shift: false
	};
	this.primary = false;

	// Initialization
	var i, len, key, parts,
		keyAliases = ve.ui.Trigger.static.keyAliases,
		primaryKeys = ve.ui.Trigger.static.primaryKeys,
		primaryKeyMap = ve.ui.Trigger.static.primaryKeyMap;
	if ( e instanceof jQuery.Event ) {
		this.modifiers.meta = e.metaKey || false;
		this.modifiers.ctrl = e.ctrlKey || false;
		this.modifiers.alt = e.altKey || false;
		this.modifiers.shift = e.shiftKey || false;
		this.primary = primaryKeyMap[e.which] || false;
	} else if ( typeof e === 'string' ) {
		// Normalization: remove whitespace and force lowercase
		parts = e.replace( /\s*/g, '' ).toLowerCase().split( '+' );
		for ( i = 0, len = parts.length; i < len; i++ ) {
			key = parts[i];
			// Resolve key aliases
			if ( Object.prototype.hasOwnProperty.call( keyAliases, key ) ) {
				key = keyAliases[key];
			}
			// Apply key to trigger
			if ( Object.prototype.hasOwnProperty.call( this.modifiers, key ) ) {
				// Modifier key
				this.modifiers[key] = true;
			} else if ( primaryKeys.indexOf( key ) !== -1 || allowInvalidPrimary ) {
				// WARNING: Only the last primary key will be used
				this.primary = key;
			}
		}
	}
};

/* Inheritance */

OO.initClass( ve.ui.Trigger );

/* Static Properties */

/**
 * Symbolic modifier key names.
 *
 * The order of this array affects the canonical order of a trigger string.
 *
 * @static
 * @property
 * @inheritable
 */
ve.ui.Trigger.static.modifierKeys = ['meta', 'ctrl', 'alt', 'shift'];

/**
 * Symbolic primary key names.
 *
 * @static
 * @property
 * @inheritable
 */
ve.ui.Trigger.static.primaryKeys = [
	// Special keys
	'backspace',
	'tab',
	'enter',
	'escape',
	'page-up',
	'page-down',
	'end',
	'home',
	'left',
	'up',
	'right',
	'down',
	'delete',
	'clear',
	// Numbers
	'0',
	'1',
	'2',
	'3',
	'4',
	'5',
	'6',
	'7',
	'8',
	'9',
	// Letters
	'a',
	'b',
	'c',
	'd',
	'e',
	'f',
	'g',
	'h',
	'i',
	'j',
	'k',
	'l',
	'm',
	'n',
	'o',
	'p',
	'q',
	'r',
	's',
	't',
	'u',
	'v',
	'w',
	'x',
	'y',
	'z',
	// Numpad special keys
	'multiply',
	'add',
	'subtract',
	'decimal',
	'divide',
	// Function keys
	'f1',
	'f2',
	'f3',
	'f4',
	'f5',
	'f6',
	'f7',
	'f8',
	'f9',
	'f10',
	'f11',
	'f12',
	// Punctuation
	';',
	'=',
	',',
	'-',
	'.',
	'/',
	'`',
	'[',
	'\\',
	']',
	'\''
];

/**
 * Filter to use when rendering string for a specific platform.
 *
 * @static
 * @property
 * @inheritable
 */
ve.ui.Trigger.static.platformFilters = {
	mac: ( function () {
		var names = {
			meta: '⌘',
			shift: '⇧',
			backspace: '⌫',
			ctrl: '^',
			alt: '⎇',
			escape: '⎋'
		};
		return function ( keys ) {
			var i, len;
			for ( i = 0, len = keys.length; i < len; i++ ) {
				keys[i] = names[keys[i]] || keys[i];
			}
			return keys.join( '' ).toUpperCase();
		};
	} )()
};

/**
 * Aliases for modifier or primary key names.
 *
 * @static
 * @property
 * @inheritable
 */
ve.ui.Trigger.static.keyAliases = {
	// Platform differences
	command: 'meta',
	apple: 'meta',
	windows: 'meta',
	option: 'alt',
	return: 'enter',
	// Shorthand
	esc: 'escape',
	cmd: 'meta',
	del: 'delete',
	// Longhand
	control: 'ctrl',
	alternate: 'alt',
	// Symbols
	'⌘': 'meta',
	'⎇': 'alt',
	'⇧': 'shift',
	'⏎': 'enter',
	'⌫': 'backspace',
	'⎋': 'escape'
};

/**
 * Mapping of key codes and symbolic key names.
 *
 * @static
 * @property
 * @inheritable
 */
ve.ui.Trigger.static.primaryKeyMap = {
	// Special keys
	8: 'backspace',
	9: 'tab',
	12: 'clear',
	13: 'enter',
	27: 'escape',
	33: 'page-up',
	34: 'page-down',
	35: 'end',
	36: 'home',
	37: 'left',
	38: 'up',
	39: 'right',
	40: 'down',
	46: 'delete',
	// Numbers
	48: '0',
	49: '1',
	50: '2',
	51: '3',
	52: '4',
	53: '5',
	54: '6',
	55: '7',
	56: '8',
	57: '9',
	// Punctuation
	59: ';',
	61: '=',
	// Letters
	65: 'a',
	66: 'b',
	67: 'c',
	68: 'd',
	69: 'e',
	70: 'f',
	71: 'g',
	72: 'h',
	73: 'i',
	74: 'j',
	75: 'k',
	76: 'l',
	77: 'm',
	78: 'n',
	79: 'o',
	80: 'p',
	81: 'q',
	82: 'r',
	83: 's',
	84: 't',
	85: 'u',
	86: 'v',
	87: 'w',
	88: 'x',
	89: 'y',
	90: 'z',
	// Numpad numbers
	96: '0',
	97: '1',
	98: '2',
	99: '3',
	100: '4',
	101: '5',
	102: '6',
	103: '7',
	104: '8',
	105: '9',
	// Numpad special keys
	106: 'multiply',
	107: 'add',
	109: 'subtract',
	110: 'decimal',
	111: 'divide',
	// Function keys
	112: 'f1',
	113: 'f2',
	114: 'f3',
	115: 'f4',
	116: 'f5',
	117: 'f6',
	118: 'f7',
	119: 'f8',
	120: 'f9',
	121: 'f10',
	122: 'f11',
	123: 'f12',
	// Punctuation
	186: ';',
	187: '=',
	188: ',',
	189: '-',
	190: '.',
	191: '/',
	192: '`',
	219: '[',
	220: '\\',
	221: ']',
	222: '\''
};

/* Methods */

/**
 * Check if trigger is complete.
 *
 * For a trigger to be complete, there must be a valid primary key.
 *
 * @returns {boolean} Trigger is complete
 */
ve.ui.Trigger.prototype.isComplete = function () {
	return this.primary !== false;
};

/**
 * Get a trigger string.
 *
 * Trigger strings are canonical representations of triggers made up of the symbolic names of all
 * active modifier keys and the primary key joined together with a '+' sign.
 *
 * To normalize a trigger string simply create a new trigger from a string and then run this method.
 *
 * An incomplete trigger will return an empty string.
 *
 * @returns {string} Canonical trigger string
 */
ve.ui.Trigger.prototype.toString = function () {
	var i, len,
		modifierKeys = ve.ui.Trigger.static.modifierKeys,
		keys = [];
	// Add modifier keywords in the correct order
	for ( i = 0, len = modifierKeys.length; i < len; i++ ) {
		if ( this.modifiers[modifierKeys[i]] ) {
			keys.push( modifierKeys[i] );
		}
	}
	// Check that there were modifiers and the primary key is whitelisted
	if ( this.primary ) {
		// Add a symbolic name for the primary key
		keys.push( this.primary );
		return keys.join( '+' );
	}
	// Alternatively return an empty string
	return '';
};

/**
 * Get a trigger message.
 *
 * This is similar to #toString but the resulting string will be formatted in a way that makes it
 * appear more native for the platform.
 *
 * @returns {string} Message for trigger
 */
ve.ui.Trigger.prototype.getMessage = function () {
	var keys,
		platformFilters = ve.ui.Trigger.static.platformFilters,
		platform = ve.getSystemPlatform();

	keys = this.toString().split( '+' );
	if ( Object.prototype.hasOwnProperty.call( platformFilters, platform ) ) {
		return platformFilters[platform]( keys );
	}
	return keys.map( function ( key ) {
		return key[0].toUpperCase() + key.slice( 1 ).toLowerCase();
	} ).join( '+' );
};

/*!
 * VisualEditor UserInterface TriggerRegistry class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Trigger registry.
 *
 * @class
 * @extends OO.Registry
 * @constructor
 */
ve.ui.TriggerRegistry = function VeUiTriggerRegistry() {
	// Parent constructor
	ve.ui.TriggerRegistry.super.call( this );
};

/* Inheritance */

OO.inheritClass( ve.ui.TriggerRegistry, OO.Registry );

/* Methods */

/**
 * Register a constructor with the factory.
 *
 * The only supported platforms are 'mac' and 'pc'. All platforms not identified as 'mac' will be
 * considered to be 'pc', including 'win', 'linux', 'solaris', etc.
 *
 * @method
 * @param {string|string[]} name Symbolic name or list of symbolic names
 * @param {ve.ui.Trigger[]|Object} triggers Trigger object(s) or map of trigger object(s) keyed by
 * platform name e.g. 'mac' or 'pc'
 * @throws {Error} Trigger must be an instance of ve.ui.Trigger
 * @throws {Error} Incomplete trigger
 */
ve.ui.TriggerRegistry.prototype.register = function ( name, triggers ) {
	var i, l, triggerList,
		platform = ve.getSystemPlatform(),
		platformKey = platform === 'mac' ? 'mac' : 'pc';

	if ( ve.isPlainObject( triggers ) ) {
		if ( Object.prototype.hasOwnProperty.call( triggers, platformKey ) ) {
			triggerList = Array.isArray( triggers[platformKey] ) ? triggers[platformKey] : [ triggers[platformKey] ];
		} else {
			return;
		}
	} else {
		triggerList = Array.isArray( triggers ) ? triggers : [ triggers ];
	}

	// Validate arguments
	for ( i = 0, l = triggerList.length; i < l; i++ ) {
		if ( !( triggerList[i] instanceof ve.ui.Trigger ) ) {
			throw new Error( 'Trigger must be an instance of ve.ui.Trigger' );
		}
		if ( !triggerList[i].isComplete() ) {
			throw new Error( 'Incomplete trigger' );
		}
	}

	ve.ui.TriggerRegistry.super.prototype.register.call( this, name, triggerList );
};

/**
 * Get trigger messages for a trigger by name
 *
 * @param {string} name Symbolic name
 * @return {string[]} List of trigger messages
 */
ve.ui.TriggerRegistry.prototype.getMessages = function ( name ) {
	return ( this.lookup( name ) || [] ).map( function ( trigger ) { return trigger.getMessage(); } );
};

/* Initialization */

ve.ui.triggerRegistry = new ve.ui.TriggerRegistry();

/* Registrations */

ve.ui.triggerRegistry.register(
	'undo', { mac: new ve.ui.Trigger( 'cmd+z' ), pc: new ve.ui.Trigger( 'ctrl+z' ) }
);
ve.ui.triggerRegistry.register(
	'redo', {
		mac: [
			new ve.ui.Trigger( 'cmd+shift+z' ),
			new ve.ui.Trigger( 'cmd+y' )
		],
		pc: [
			new ve.ui.Trigger( 'ctrl+shift+z' ),
			new ve.ui.Trigger( 'ctrl+y' )
		]
	}
);
ve.ui.triggerRegistry.register(
	'bold', { mac: new ve.ui.Trigger( 'cmd+b' ), pc: new ve.ui.Trigger( 'ctrl+b' ) }
);
ve.ui.triggerRegistry.register(
	'italic', { mac: new ve.ui.Trigger( 'cmd+i' ), pc: new ve.ui.Trigger( 'ctrl+i' ) }
);
ve.ui.triggerRegistry.register(
	'link', { mac: new ve.ui.Trigger( 'cmd+k' ), pc: new ve.ui.Trigger( 'ctrl+k' ) }
);
ve.ui.triggerRegistry.register(
	'clear', {
		mac: [
			new ve.ui.Trigger( 'cmd+\\' ),
			new ve.ui.Trigger( 'cmd+m' )
		],
		pc: [
			new ve.ui.Trigger( 'ctrl+\\' ),
			new ve.ui.Trigger( 'ctrl+m' )
		]
	}
);
ve.ui.triggerRegistry.register(
	'underline', { mac: new ve.ui.Trigger( 'cmd+u' ), pc: new ve.ui.Trigger( 'ctrl+u' ) }
);
ve.ui.triggerRegistry.register(
	'code', { mac: new ve.ui.Trigger( 'cmd+shift+6' ), pc: new ve.ui.Trigger( 'ctrl+shift+6' ) }
);
ve.ui.triggerRegistry.register(
	'strikethrough', { mac: new ve.ui.Trigger( 'cmd+shift+5' ), pc: new ve.ui.Trigger( 'ctrl+shift+5' ) }
);
ve.ui.triggerRegistry.register(
	'subscript', { mac: new ve.ui.Trigger( 'cmd+,' ), pc: new ve.ui.Trigger( 'ctrl+,' ) }
);
ve.ui.triggerRegistry.register(
	'superscript', { mac: new ve.ui.Trigger( 'cmd+.' ), pc: new ve.ui.Trigger( 'ctrl+.' ) }
);
ve.ui.triggerRegistry.register(
	'indent', new ve.ui.Trigger( 'tab' )
);
ve.ui.triggerRegistry.register(
	'outdent', new ve.ui.Trigger( 'shift+tab' )
);
ve.ui.triggerRegistry.register(
	'commandHelp', {
		mac: [
			new ve.ui.Trigger( 'cmd+/' ),
			new ve.ui.Trigger( 'cmd+shift+/' ) // =cmd+? on most systems, but not all
		],
		pc: [
			new ve.ui.Trigger( 'ctrl+/' ),
			new ve.ui.Trigger( 'ctrl+shift+/' ) // =ctrl+? on most systems, but not all
		]
	}
);
// Ctrl+0-7 below are not mapped to Cmd+0-7 on Mac because Chrome reserves those for switching tabs
ve.ui.triggerRegistry.register(
	'paragraph', new ve.ui.Trigger( 'ctrl+0' )
);
ve.ui.triggerRegistry.register(
	'heading1', new ve.ui.Trigger( 'ctrl+1' )
);
ve.ui.triggerRegistry.register(
	'heading2', new ve.ui.Trigger( 'ctrl+2' )
);
ve.ui.triggerRegistry.register(
	'heading3', new ve.ui.Trigger( 'ctrl+3' )
);
ve.ui.triggerRegistry.register(
	'heading4', new ve.ui.Trigger( 'ctrl+4' )
);
ve.ui.triggerRegistry.register(
	'heading5', new ve.ui.Trigger( 'ctrl+5' )
);
ve.ui.triggerRegistry.register(
	'heading6', new ve.ui.Trigger( 'ctrl+6' )
);
ve.ui.triggerRegistry.register(
	'preformatted', new ve.ui.Trigger( 'ctrl+7' )
);
ve.ui.triggerRegistry.register(
	'blockquote', new ve.ui.Trigger( 'ctrl+8' )
);
ve.ui.triggerRegistry.register(
	'selectAll', { mac: new ve.ui.Trigger( 'cmd+a' ), pc: new ve.ui.Trigger( 'ctrl+a' ) }
);
ve.ui.triggerRegistry.register(
	'pasteSpecial', { mac: new ve.ui.Trigger( 'cmd+shift+v' ), pc: new ve.ui.Trigger( 'ctrl+shift+v' ) }
);
ve.ui.triggerRegistry.register(
	'findAndReplace', { mac: new ve.ui.Trigger( 'cmd+f' ), pc: new ve.ui.Trigger( 'ctrl+f' ) }
);
ve.ui.triggerRegistry.register(
	'findNext', {
		mac: new ve.ui.Trigger( 'cmd+g' ),
		pc: [
			new ve.ui.Trigger( 'ctrl+g' ),
			new ve.ui.Trigger( 'f3' )
		]
	}
);
ve.ui.triggerRegistry.register(
	'findPrevious', {
		mac: new ve.ui.Trigger( 'cmd+shift+g' ),
		pc: [
			new ve.ui.Trigger( 'shift+ctrl+g' ),
			new ve.ui.Trigger( 'shift+f3' )
		]
	}
);

/*!
 * VisualEditor UserInterface Sequence class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Key sequence.
 *
 * @class
 *
 * @constructor
 * @param {string} name Symbolic name
 * @param {string} commandName Command name this sequence executes
 * @param {string|Array} data Data to match
 * @param {number} [strip] Number of data elements to strip after execution (from the right)
 */
ve.ui.Sequence = function VeUiSequence( name, commandName, data, strip ) {
	this.name = name;
	this.commandName = commandName;
	this.data = data;
	this.strip = strip;
};

/* Inheritance */

OO.initClass( ve.ui.Sequence );

/* Methods */

/**
 * Check if the sequence matches a given offset in the data
 *
 * @param {string|Array} data String or linear data
 * @param {number} offset Offset
 * @return {boolean} Sequence matches
 */
ve.ui.Sequence.prototype.match = function ( data, offset ) {
	var i, j = offset - 1;

	for ( i = this.data.length - 1; i >= 0; i--, j-- ) {
		if ( typeof this.data[i] === 'string' ) {
			if ( this.data[i] !== data.getCharacterData( j ) ) {
				return false;
			}
		} else if ( !ve.compare( this.data[i], data.getData( j ), true ) ) {
			return false;
		}
	}
	return true;
};

/**
 * Execute the command associated with the sequence
 *
 * @param {ve.ui.Surface} surface surface
 * @return {boolean} The command executed
 * @throws {Error} Command not found
 */
ve.ui.Sequence.prototype.execute = function ( surface ) {
	var range, executed, stripFragment,
		surfaceModel = surface.getModel(),
		command = ve.ui.commandRegistry.lookup( this.getCommandName() );

	if ( !command ) {
		throw new Error( 'Command not found: ' + this.getCommandName() ) ;
	}

	if ( this.strip ) {
		range = surfaceModel.getSelection().getRange();
		stripFragment = surfaceModel.getLinearFragment( new ve.Range( range.end, range.end - this.strip ) );
	}

	surfaceModel.breakpoint();

	executed = command.execute( surface );

	if ( executed && stripFragment ) {
		stripFragment.removeContent();
	}

	return executed;
};

/**
 * Get the symbolic name of the sequence
 *
 * @return {string} Symbolic name
 */
ve.ui.Sequence.prototype.getName = function () {
	return this.name;
};

/**
 * Get the command name which the sequence will execute
 *
 * @return {string} Command name
 */
ve.ui.Sequence.prototype.getCommandName = function () {
	return this.commandName;
};

/*!
 * VisualEditor UserInterface SequenceRegistry class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Sequence registry.
 *
 * @class
 * @extends OO.Registry
 * @constructor
 */
ve.ui.SequenceRegistry = function VeUiSequenceRegistry() {
	// Parent constructor
	ve.ui.SequenceRegistry.super.call( this );
};

/* Inheritance */

OO.inheritClass( ve.ui.SequenceRegistry, OO.Registry );

/**
 * Register a sequence with the factory.
 *
 * @method
 * @param {ve.ui.Sequence} sequence Sequence object
 * @throws {Error} If sequence is not an instance of ve.ui.Sequence
 */
ve.ui.SequenceRegistry.prototype.register = function ( sequence ) {
	// Validate arguments
	if ( !( sequence instanceof ve.ui.Sequence ) ) {
		throw new Error(
			'sequence must be an instance of ve.ui.Sequence, cannot be a ' + typeof sequence
		);
	}

	ve.ui.SequenceRegistry.super.prototype.register.call( this, sequence.getName(), sequence );
};

/**
 * Find sequence matches a given offset in the data
 *
 * @param {ve.dm.ElementLinearData} data Linear data
 * @param {number} offset Offset
 * @return {ve.ui.Sequence[]} Sequences which match
 */
ve.ui.SequenceRegistry.prototype.findMatching = function ( data, offset ) {
	var name, sequences = [];
	for ( name in this.registry ) {
		if ( this.registry[name].match( data, offset ) ) {
			sequences.push( this.registry[name] );
		}
	}
	return sequences;
};

/* Initialization */

ve.ui.sequenceRegistry = new ve.ui.SequenceRegistry();

/* Registrations */

ve.ui.sequenceRegistry.register(
	new ve.ui.Sequence( 'bulletStar', 'bulletWrapOnce', [ { type: 'paragraph' }, '*', ' ' ], 2 )
);
ve.ui.sequenceRegistry.register(
	new ve.ui.Sequence( 'numberDot', 'numberWrapOnce', [ { type: 'paragraph' }, '1', '.', ' ' ], 3 )
);

/*!
 * VisualEditor UserInterface Action class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Generic action.
 *
 * An action is built around a surface for one-time use. It is a generic way of extending the
 * functionality of a surface. Actions are accessible via {ve.ui.Surface.prototype.execute}.
 *
 * @class
 *
 * @constructor
 * @param {ve.ui.Surface} surface Surface to act on
 */
ve.ui.Action = function VeUiAction( surface ) {
	// Properties
	this.surface = surface;
};

/* Inheritance */

OO.initClass( ve.ui.Action );

/* Static Properties */

/**
 * List of allowed methods for the action.
 *
 * To avoid use of methods not intended to be executed via surface.execute(), the methods must be
 * whitelisted here. This information is checked by ve.ui.Surface before executing an action.
 *
 * If a method returns a value, it will be cast to boolean and be used to determine if the action
 * was canceled. Not returning anything, or returning undefined will be treated the same as
 * returning true. A canceled action will yield to other default behavior. For example, when
 * triggering an action from a keystroke, a canceled action will allow normal insertion behavior to
 * be carried out.
 *
 * @static
 * @property
 * @inheritable
 */
ve.ui.Action.static.methods = [];

/*!
 * VisualEditor UserInterface ActionFactory class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Action factory.
 *
 * @class
 * @extends OO.Factory
 * @constructor
 */
ve.ui.ActionFactory = function VeUiActionFactory() {
	// Parent constructor
	OO.Factory.call( this );
};

/* Inheritance */

OO.inheritClass( ve.ui.ActionFactory, OO.Factory );

/* Methods */

/**
 * Check if an action supports a method.
 *
 * @method
 * @param {string} action Name of action
 * @param {string} method Name of method
 * @returns {boolean} The action supports the method
 */
ve.ui.ActionFactory.prototype.doesActionSupportMethod = function ( action, method ) {
	if ( Object.prototype.hasOwnProperty.call( this.registry, action ) ) {
		return this.registry[action].static.methods.indexOf( method ) !== -1;
	}
	throw new Error( 'Unknown action: ' + action );
};

/* Initialization */

ve.ui.actionFactory = new ve.ui.ActionFactory();

/*!
 * VisualEditor UserInterface data transfer handler class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Data transfer handler.
 *
 * @class
 * @abstract
 *
 * @constructor
 * @param {ve.ui.Surface} surface Surface
 * @param {ve.ui.DataTransferItem} item Data transfer item to handle
 */
ve.ui.DataTransferHandler = function VeUiDataTransferHandler( surface, item ) {
	// Properties
	this.surface = surface;
	this.item = item;

	this.insertableDataDeferred = $.Deferred();
};

/* Inheritance */

OO.initClass( ve.ui.DataTransferHandler );

/* Static properties */

/**
 * Symbolic name for this handler. Must be unique.
 *
 * @static
 * @property {string}
 * @inheritable
 */
ve.ui.DataTransferHandler.static.name = null;

/**
 * List of transfer kinds supported by this handler
 *
 * Null means all kinds are supported.
 *
 * @static
 * @property {string[]|null}
 * @inheritable
 */
ve.ui.DataTransferHandler.static.kinds = null;

/**
 * List of mime types supported by this handler
 *
 * @static
 * @property {string[]}
 * @inheritable
 */
ve.ui.DataTransferHandler.static.types = [];

/**
 * Use handler when data transfer source is a paste
 *
 * @static
 * @type {boolean}
 * @inheritable
 */
ve.ui.DataTransferHandler.static.handlesPaste = true;

/**
 * Custom match function which is given the data transfer item as its only argument
 * and returns a boolean indicating if the handler matches
 *
 * Null means the handler always matches
 *
 * @static
 * @type {Function}
 * @inheritable
 */
ve.ui.DataTransferHandler.static.matchFunction = null;

/* Methods */

/**
 * Process the file
 *
 * Implementations should aim to resolve this.insertableDataDeferred.
 */
ve.ui.DataTransferHandler.prototype.process = function () {
	throw new Error( 've.ui.DataTransferHandler subclass must implement process' );
};

/**
 * Insert the file at a specified fragment
 *
 * @return {jQuery.Promise} Promise which resolves with data to insert
 */
ve.ui.DataTransferHandler.prototype.getInsertableData = function () {
	this.process();

	return this.insertableDataDeferred.promise();
};

/**
 * Abort the data transfer handler
 */
ve.ui.DataTransferHandler.prototype.abort = function () {
	this.insertableDataDeferred.reject();
};

/*!
 * VisualEditor UserInterface data transfer handler class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Data transfer handler.
 *
 * @class
 * @extends ve.ui.DataTransferHandler
 * @abstract
 *
 * @constructor
 * @param {ve.ui.Surface} surface
 * @param {ve.ui.DataTransferItem} item
 */
ve.ui.FileTransferHandler = function VeUiFileTransferHandler() {
	// Parent constructor
	ve.ui.FileTransferHandler.super.apply( this, arguments );

	// Properties
	this.file = this.item.getAsFile();

	this.reader = new FileReader();

	this.progress = false;
	this.progressBar = null;

	// Events
	this.reader.addEventListener( 'progress', this.onFileProgress.bind( this ) );
	this.reader.addEventListener( 'load', this.onFileLoad.bind( this ) );
	this.reader.addEventListener( 'loadend', this.onFileLoadEnd.bind( this ) );
};

/* Inheritance */

OO.inheritClass( ve.ui.FileTransferHandler, ve.ui.DataTransferHandler );

/* Static properties */

ve.ui.FileTransferHandler.static.kinds = [ 'file' ];

/* Methods */

/**
 * Handle progress events from the file reader
 *
 * @param {Event} e Progress event
 */
ve.ui.FileTransferHandler.prototype.onFileProgress = function () {};

/**
 * Handle load events from the file reader
 *
 * @param {Event} e Load event
 */
ve.ui.FileTransferHandler.prototype.onFileLoad = function () {};

/**
 * Handle load end events from the file reader
 *
 * @param {Event} e Load end event
 */
ve.ui.FileTransferHandler.prototype.onFileLoadEnd = function () {};

/**
 * Create a progress bar with a specified label
 *
 * @param {jQuery.Promise} progressCompletePromise Promise which resolves when the progress action is complete
 * @param {jQuery|string|Function} [label] Progress bar label, defaults to file name
 */
ve.ui.FileTransferHandler.prototype.createProgress = function ( progressCompletePromise, label ) {
	var handler = this;

	this.surface.createProgress( progressCompletePromise, label || this.file.name ).done( function ( progressBar, cancelPromise ) {
		// Set any progress that was achieved before this resolved
		progressBar.setProgress( handler.progress );
		handler.progressBar = progressBar;
		cancelPromise.fail( handler.abort.bind( handler ) );
	} );
};

/**
 * Set progress bar progress
 *
 * Progress is stored in a property in case the progress bar doesn't exist yet.
 *
 * @param {number} progress Progress percent
 */
ve.ui.FileTransferHandler.prototype.setProgress = function ( progress ) {
	this.progress = progress;
	if ( this.progressBar ) {
		this.progressBar.setProgress( this.progress );
	}
};

/*!
 * VisualEditor DataTransferHandlerFactory class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Drop handler Factory.
 *
 * @class
 * @extends OO.Factory
 * @constructor
 */
ve.ui.DataTransferHandlerFactory = function VeUiDataTransferHandlerFactory() {
	// Parent constructor
	ve.ui.DataTransferHandlerFactory.super.apply( this, arguments );

	// Handlers which match all kinds and a specific type
	this.handlerNamesByType = {};
	// Handlers which match a specific kind and type
	this.handlerNamesByKindAndType = {};
};

/* Inheritance */

OO.inheritClass( ve.ui.DataTransferHandlerFactory, OO.Factory );

/* Methods */

/**
 * @inheritdoc
 */
ve.ui.DataTransferHandlerFactory.prototype.register = function ( constructor ) {
	// Parent method
	ve.ui.DataTransferHandlerFactory.super.prototype.register.call( this, constructor );

	var i, j, ilen, jlen,
		kinds = constructor.static.kinds,
		types = constructor.static.types;

	if ( !kinds ) {
		for ( j = 0, jlen = types.length; j < jlen; j++ ) {
			this.handlerNamesByType[types[j]] = constructor.static.name;
		}
	} else {
		for ( i = 0, ilen = kinds.length; i < ilen; i++ ) {
			for ( j = 0, jlen = types.length; j < jlen; j++ ) {
				this.handlerNamesByKindAndType[kinds[i]] = this.handlerNamesByKindAndType[kinds[i]] || {};
				this.handlerNamesByKindAndType[kinds[i]][types[j]] = constructor.static.name;
			}
		}
	}
};

/**
 * Returns the primary command for for node.
 *
 * @param {ve.ui.DataTransferItem} item Data transfer item
 * @param {boolean} isPaste Handler being used for paste
 * @returns {string|undefined} Handler name, or undefined if not found
 */
ve.ui.DataTransferHandlerFactory.prototype.getHandlerNameForItem = function ( item, isPaste ) {
	var constructor,
		name = ( this.handlerNamesByKindAndType[item.kind] && this.handlerNamesByKindAndType[item.kind][item.type] ) ||
		this.handlerNamesByType[item.type];

	if ( !name ) {
		return;
	}

	constructor = this.registry[name];

	if ( isPaste && !constructor.static.handlesPaste ) {
		return;
	}

	if ( constructor.static.matchFunction && !constructor.static.matchFunction( item ) ) {
		return;
	}

	return name;
};

/* Initialization */

ve.ui.dataTransferHandlerFactory = new ve.ui.DataTransferHandlerFactory();

/**
 * Data transfer item wrapper
 *
 * @class
 * @constructor
 * @param {string} kind Item kind, e.g. 'string' or 'file'
 * @param {string} type MIME type
 * @param {Object} [data] Data object to wrap or convert
 * @param {string} [data.dataUri] Data URI to convert to a blob
 * @param {Blob} [data.blob] File blob
 * @param {string} [data.stringData] String data
 * @param {DataTransferItem} [data.item] Native data transfer item
 */
ve.ui.DataTransferItem = function VeUiDataTransferItem( kind, type, data ) {
	this.kind = kind;
	this.type = type;
	this.data = data;
	this.blob = this.data.blob || null;
	this.stringData = this.data.stringData || ve.getProp( this.blob, 'name' ) || null;
};

/* Inheritance */

OO.initClass( ve.ui.DataTransferItem );

/* Static methods */

/**
 * Create a data transfer item from a file blob.
 *
 * @param {Blob} blob File blob
 * @return {ve.ui.DataTransferItem} New data transfer item
 */
ve.ui.DataTransferItem.static.newFromBlob = function ( blob ) {
	return new ve.ui.DataTransferItem( 'file', blob.type, { blob: blob } );
};

/**
 * Create a data transfer item from a data URI.
 *
 * @param {string} dataUri Data URI
 * @return {ve.ui.DataTransferItem} New data transfer item
 */
ve.ui.DataTransferItem.static.newFromDataUri = function ( dataUri ) {
	var parts = dataUri.split( ',' );
	return new ve.ui.DataTransferItem( 'file', parts[0].match( /^data:([^;]+)/ )[1], { dataUri: parts[1] } );
};

/**
 * Create a data transfer item from string data.
 *
 * @param {string} stringData String data
 * @param {string} type MIME type
 * @return {ve.ui.DataTransferItem} New data transfer item
 */
ve.ui.DataTransferItem.static.newFromString = function ( stringData, type ) {
	return new ve.ui.DataTransferItem( 'string', type || 'text/plain', { stringData: stringData } );
};

/**
 * Create a data transfer item from a native data transfer item.
 *
 * @param {DataTransferItem} item Native data transfer item
 * @return {ve.ui.DataTransferItem} New data transfer item
 */
ve.ui.DataTransferItem.static.newFromItem = function ( item ) {
	return new ve.ui.DataTransferItem( item.kind, item.type, { item: item } );
};

/**
 * Get file blob
 *
 * Generically getAsFile returns a Blob, which could be a File.
 *
 * @return {Blob} File blob
 */
ve.ui.DataTransferItem.prototype.getAsFile = function () {
	if ( this.data.item ) {
		return this.data.item.getAsFile();
	}

	var binary, array, i;

	if ( !this.blob && this.data.dataUri ) {
		binary = atob( this.data.dataUri );
		delete this.data.dataUri;
		array = [];
		for ( i = 0; i < binary.length; i++ ) {
			array.push( binary.charCodeAt( i ) );
		}
		this.blob = new Blob(
			[ new Uint8Array( array ) ],
			{ type: this.type }
		);
	}
	return this.blob;
};

/**
 * Get string data
 *
 * Differs from native DataTransferItem#getAsString by being synchronous
 *
 * @return {string} String data
 */
ve.ui.DataTransferItem.prototype.getAsString = function () {
	return this.stringData;
};

/*!
 * VisualEditor UserInterface WindowManager class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Window manager.
 *
 * @class
 * @extends OO.ui.WindowManager
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {ve.ui.Overlay} [overlay] Overlay to use for menus
 */
ve.ui.WindowManager = function VeUiWindowManager( config ) {
	// Configuration initialization
	config = config || {};

	// Parent constructor
	ve.ui.WindowManager.super.call( this, config );

	// Properties
	this.overlay = config.overlay || null;

	this.$element
		.addClass( 've-ui-dir-block-' + this.getDir() );
};

/* Inheritance */

OO.inheritClass( ve.ui.WindowManager, OO.ui.WindowManager );

/* Methods */

/**
 * Get directionality
 * @return {string} UI directionality
 */
ve.ui.WindowManager.prototype.getDir = function () {
	return $( 'body' ).css( 'direction' );
};

/**
 * Get overlay for menus.
 *
 * @return {ve.ui.Overlay|null} Menu overlay, null if none was configured
 */
ve.ui.WindowManager.prototype.getOverlay = function () {
	return this.overlay;
};

/*!
 * VisualEditor UserInterface SurfaceWindowManager class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Window manager for desktop inspectors.
 *
 * @class
 * @extends ve.ui.WindowManager
 *
 * @constructor
 * @param {ve.ui.Surface} Surface this belongs to
 * @param {Object} [config] Configuration options
 * @cfg {ve.ui.Overlay} [overlay] Overlay to use for menus
 */
ve.ui.SurfaceWindowManager = function VeUiSurfaceWindowManager( surface, config ) {
	// Properties
	// Set up surface before calling the parent so we can request
	// specific surface-related details from within the constructor.
	this.surface = surface;

	// Parent constructor
	ve.ui.SurfaceWindowManager.super.call( this, config );
};

/* Inheritance */

OO.inheritClass( ve.ui.SurfaceWindowManager, ve.ui.WindowManager );

/* Methods */

/**
 * Override the window manager's directionality method to get the
 * directionality from the surface. The surface sometimes does not
 * have a directionality set; fallback to direction from the document.
 * @return {string} UI directionality
 */
ve.ui.SurfaceWindowManager.prototype.getDir = function () {
	return this.surface.getDir() ||
		// Fallback to parent method
		ve.ui.SurfaceWindowManager.super.prototype.getDir.call( this );
};

/**
 * Get surface.
 *
 * @return {ve.ui.Surface} Surface this belongs to
 */
ve.ui.SurfaceWindowManager.prototype.getSurface = function () {
	return this.surface;
};

/*!
 * VisualEditor UserInterface AnnotationAction class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Annotation action.
 *
 * @class
 * @extends ve.ui.Action
 *
 * @constructor
 * @param {ve.ui.Surface} surface Surface to act on
 */
ve.ui.AnnotationAction = function VeUiAnnotationAction( surface ) {
	// Parent constructor
	ve.ui.Action.call( this, surface );
};

/* Inheritance */

OO.inheritClass( ve.ui.AnnotationAction, ve.ui.Action );

/* Static Properties */

ve.ui.AnnotationAction.static.name = 'annotation';

/**
 * List of allowed methods for the action.
 *
 * @static
 * @property
 */
ve.ui.AnnotationAction.static.methods = [ 'set', 'clear', 'toggle', 'clearAll' ];

/* Methods */

/**
 * Set an annotation.
 *
 * @method
 * @param {string} name Annotation name, for example: 'textStyle/bold'
 * @param {Object} [data] Additional annotation data
 * @return {boolean} Action was executed
 */
ve.ui.AnnotationAction.prototype.set = function ( name, data ) {
	var i, trimmedFragment,
		fragment = this.surface.getModel().getFragment(),
		annotationClass = ve.dm.annotationFactory.lookup( name ),
		removes = annotationClass.static.removes;

	if ( fragment.getSelection() instanceof ve.dm.LinearSelection ) {
		trimmedFragment = fragment.trimLinearSelection();
		if ( !trimmedFragment.getSelection().isCollapsed() ) {
			fragment = trimmedFragment;
		}
	}

	for ( i = removes.length - 1; i >= 0; i-- ) {
		fragment.annotateContent( 'clear', removes[i] );
	}
	fragment.annotateContent( 'set', name, data );
	return true;
};

/**
 * Clear an annotation.
 *
 * @method
 * @param {string} name Annotation name, for example: 'textStyle/bold'
 * @param {Object} [data] Additional annotation data
 * @return {boolean} Action was executed
 */
ve.ui.AnnotationAction.prototype.clear = function ( name, data ) {
	this.surface.getModel().getFragment().annotateContent( 'clear', name, data );
	return true;
};

/**
 * Toggle an annotation.
 *
 * If the selected text is completely covered with the annotation already the annotation will be
 * cleared. Otherwise the annotation will be set.
 *
 * @method
 * @param {string} name Annotation name, for example: 'textStyle/bold'
 * @param {Object} [data] Additional annotation data
 * @return {boolean} Action was executed
 */
ve.ui.AnnotationAction.prototype.toggle = function ( name, data ) {
	var existingAnnotations, insertionAnnotations, removesAnnotations,
		surfaceModel = this.surface.getModel(),
		fragment = surfaceModel.getFragment(),
		annotation = ve.dm.annotationFactory.create( name, data ),
		removes = annotation.constructor.static.removes;

	if ( !fragment.getSelection().isCollapsed() ) {
		if ( !fragment.getAnnotations().containsComparable( annotation ) ) {
			this.set( name, data );
		} else {
			fragment.annotateContent( 'clear', name );
		}
	} else {
		insertionAnnotations = surfaceModel.getInsertionAnnotations();
		existingAnnotations = insertionAnnotations.getAnnotationsByName( annotation.name );
		if ( existingAnnotations.isEmpty() ) {
			removesAnnotations = insertionAnnotations.filter( function ( annotation ) {
				return removes.indexOf( annotation.name ) !== -1;
			} );
			surfaceModel.removeInsertionAnnotations( removesAnnotations );
			surfaceModel.addInsertionAnnotations( annotation );
		} else {
			surfaceModel.removeInsertionAnnotations( existingAnnotations );
		}
	}
	return true;
};

/**
 * Clear all annotations.
 *
 * @method
 * @return {boolean} Action was executed
 */
ve.ui.AnnotationAction.prototype.clearAll = function () {
	var i, len, arr,
		surfaceModel = this.surface.getModel(),
		fragment = surfaceModel.getFragment(),
		annotations = fragment.getAnnotations( true );

	arr = annotations.get();
	// TODO: Allow multiple annotations to be set or cleared by ve.dm.SurfaceFragment, probably
	// using an annotation set and ideally building a single transaction
	for ( i = 0, len = arr.length; i < len; i++ ) {
		fragment.annotateContent( 'clear', arr[i].name, arr[i].data );
	}
	surfaceModel.setInsertionAnnotations( null );
	return true;
};

/* Registration */

ve.ui.actionFactory.register( ve.ui.AnnotationAction );

/*!
 * VisualEditor UserInterface ContentAction class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Content action.
 *
 * @class
 * @extends ve.ui.Action
 *
 * @constructor
 * @param {ve.ui.Surface} surface Surface to act on
 */
ve.ui.ContentAction = function VeUiContentAction( surface ) {
	// Parent constructor
	ve.ui.Action.call( this, surface );
};

/* Inheritance */

OO.inheritClass( ve.ui.ContentAction, ve.ui.Action );

/* Static Properties */

ve.ui.ContentAction.static.name = 'content';

/**
 * List of allowed methods for the action.
 *
 * @static
 * @property
 */
ve.ui.ContentAction.static.methods = [ 'insert', 'remove', 'select', 'pasteSpecial', 'selectAll' ];

/* Methods */

/**
 * Insert content.
 *
 * @method
 * @param {string|Array} content Content to insert, can be either a string or array of data
 * @param {boolean} annotate Content should be automatically annotated to match surrounding content
 * @return {boolean} Action was executed
 */
ve.ui.ContentAction.prototype.insert = function ( content, annotate ) {
	this.surface.getModel().getFragment().insertContent( content, annotate );
	return true;
};

/**
 * Remove content.
 *
 * @method
 * @return {boolean} Action was executed
 */
ve.ui.ContentAction.prototype.remove = function () {
	this.surface.getModel().getFragment().removeContent();
	return true;
};

/**
 * Select content.
 *
 * @method
 * @param {ve.dm.Selection} selection Selection
 * @return {boolean} Action was executed
 */
ve.ui.ContentAction.prototype.select = function ( selection ) {
	this.surface.getModel().setSelection( selection );
	return true;
};

/**
 * Select all content.
 *
 * @method
 * @return {boolean} Action was executed
 */
ve.ui.ContentAction.prototype.selectAll = function () {
	this.surface.getView().selectAll();
	return true;
};

/**
 * Paste special.
 *
 * @method
 * @return {boolean} Action was executed
 */
ve.ui.ContentAction.prototype.pasteSpecial = function () {
	this.surface.getView().pasteSpecial = true;
	// Return false to allow the paste event to occur
	return false;
};

/* Registration */

ve.ui.actionFactory.register( ve.ui.ContentAction );

/*!
 * VisualEditor UserInterface FormatAction class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Format action.
 *
 * @class
 * @extends ve.ui.Action
 *
 * @constructor
 * @param {ve.ui.Surface} surface Surface to act on
 */
ve.ui.FormatAction = function VeUiFormatAction( surface ) {
	// Parent constructor
	ve.ui.Action.call( this, surface );
};

/* Inheritance */

OO.inheritClass( ve.ui.FormatAction, ve.ui.Action );

/* Static Properties */

ve.ui.FormatAction.static.name = 'format';

/**
 * List of allowed methods for this action.
 *
 * @static
 * @property
 */
ve.ui.FormatAction.static.methods = [ 'convert' ];

/* Methods */

/**
 * Convert the format of content.
 *
 * Conversion splits and unwraps all lists and replaces content branch nodes.
 *
 * TODO: Refactor functionality into {ve.dm.SurfaceFragment}.
 *
 * @param {string} type
 * @param {Object} attributes
 * @return {boolean} Action was executed
 */
ve.ui.FormatAction.prototype.convert = function ( type, attributes ) {
	var selected, i, length, contentBranch, txs,
		surfaceModel = this.surface.getModel(),
		selection = surfaceModel.getSelection(),
		fragmentForSelection = surfaceModel.getFragment( selection, true ),
		doc = surfaceModel.getDocument(),
		fragments = [];

	if ( !( selection instanceof ve.dm.LinearSelection ) ) {
		return;
	}

	// We can't have headings or pre's in a list, so if we're trying to convert
	// things that are in lists to a heading or a pre, split the list
	selected = doc.selectNodes( selection.getRange(), 'leaves' );
	for ( i = 0, length = selected.length; i < length; i++ ) {
		contentBranch = selected[i].node.isContent() ?
			selected[i].node.getParent() :
			selected[i].node;

		fragments.push( surfaceModel.getLinearFragment( contentBranch.getOuterRange(), true ) );
	}

	for ( i = 0, length = fragments.length; i < length; i++ ) {
		fragments[i].isolateAndUnwrap( type );
	}
	selection = fragmentForSelection.getSelection();

	txs = ve.dm.Transaction.newFromContentBranchConversion( doc, selection.getRange(), type, attributes );
	surfaceModel.change( txs, selection );
	this.surface.getView().focus();
	return true;
};

/* Registration */

ve.ui.actionFactory.register( ve.ui.FormatAction );

/*!
 * VisualEditor UserInterface HistoryAction class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * History action.
 *
 * @class
 * @extends ve.ui.Action
 *
 * @constructor
 * @param {ve.ui.Surface} surface Surface to act on
 */
ve.ui.HistoryAction = function VeUiHistoryAction( surface ) {
	// Parent constructor
	ve.ui.Action.call( this, surface );
};

/* Inheritance */

OO.inheritClass( ve.ui.HistoryAction, ve.ui.Action );

/* Static Properties */

ve.ui.HistoryAction.static.name = 'history';

/**
 * List of allowed methods for the action.
 *
 * @static
 * @property
 */
ve.ui.HistoryAction.static.methods = [ 'undo', 'redo' ];

/* Methods */

/**
 * Step backwards in time.
 *
 * @method
 * @return {boolean} Action was executed
 */
ve.ui.HistoryAction.prototype.undo = function () {
	this.surface.getModel().undo();
	return true;
};

/**
 * Step forwards in time.
 *
 * @method
 * @return {boolean} Action was executed
 */
ve.ui.HistoryAction.prototype.redo = function () {
	this.surface.getModel().redo();
	return true;
};

/* Registration */

ve.ui.actionFactory.register( ve.ui.HistoryAction );

/*!
 * VisualEditor UserInterface IndentationAction class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Indentation action.
 *
 * @class
 * @extends ve.ui.Action
 *
 * @constructor
 * @param {ve.ui.Surface} surface Surface to act on
 */
ve.ui.IndentationAction = function VeUiIndentationAction( surface ) {
	// Parent constructor
	ve.ui.Action.call( this, surface );
};

/* Inheritance */

OO.inheritClass( ve.ui.IndentationAction, ve.ui.Action );

/* Static Properties */

ve.ui.IndentationAction.static.name = 'indentation';

/**
 * List of allowed methods for the action.
 *
 * @static
 * @property
 */
ve.ui.IndentationAction.static.methods = [ 'increase', 'decrease' ];

/* Methods */

/**
 * Indent content.
 *
 * TODO: Refactor functionality into {ve.dm.SurfaceFragment}.
 *
 * @method
 * @returns {boolean} Indentation increase occurred
 */
ve.ui.IndentationAction.prototype.increase = function () {
	var i, group, groups,
		fragments = [],
		increased = false,
		surfaceModel = this.surface.getModel(),
		documentModel = surfaceModel.getDocument(),
		fragment = surfaceModel.getFragment();

	if ( !( fragment.getSelection() instanceof ve.dm.LinearSelection ) ) {
		return;
	}

	groups = documentModel.getCoveredSiblingGroups( fragment.getSelection().getRange() );

	// Build fragments from groups (we need their ranges since the nodes will be rebuilt on change)
	for ( i = 0; i < groups.length; i++ ) {
		group = groups[i];
		if ( group.grandparent && group.grandparent.getType() === 'list' ) {
			fragments.push( surfaceModel.getLinearFragment( group.parent.getRange(), true ) );
			increased = true;
		}
	}

	// Process each fragment (their ranges are automatically adjusted on change)
	for ( i = 0; i < fragments.length; i++ ) {
		this.indentListItem(
			documentModel.getBranchNodeFromOffset( fragments[i].getSelection().getRange().start )
		);
	}

	fragment.select();

	return increased;
};

/**
 * Unindent content.
 *
 * TODO: Refactor functionality into {ve.dm.SurfaceFragment}.
 *
 * @method
 * @returns {boolean} Indentation decrease occurred
 */
ve.ui.IndentationAction.prototype.decrease = function () {
	var i, group, groups,
		fragments = [],
		decreased = false,
		surfaceModel = this.surface.getModel(),
		documentModel = surfaceModel.getDocument(),
		fragment = surfaceModel.getFragment();

	if ( !( fragment.getSelection() instanceof ve.dm.LinearSelection ) ) {
		return;
	}

	groups = documentModel.getCoveredSiblingGroups( fragment.getSelection().getRange() );

	// Build fragments from groups (we need their ranges since the nodes will be rebuilt on change)
	for ( i = 0; i < groups.length; i++ ) {
		group = groups[i];
		if ( group.grandparent && group.grandparent.getType() === 'list' ) {
			fragments.push( surfaceModel.getLinearFragment( group.parent.getRange(), true ) );
			decreased = true;
		} else if ( group.parent && group.parent.getType() === 'list' ) {
			// In a slug, the node will be the listItem.
			fragments.push( surfaceModel.getLinearFragment( group.nodes[0].getRange(), true ) );
			decreased = true;
		}

	}

	// Process each fragment (their ranges are automatically adjusted on change)
	for ( i = 0; i < fragments.length; i++ ) {
		this.unindentListItem(
			documentModel.getBranchNodeFromOffset( fragments[i].getSelection().getRange().start )
		);
	}

	fragment.select();

	return decreased;
};

/**
 * Indent a list item.
 *
 * TODO: Refactor functionality into {ve.dm.SurfaceFragment}.
 *
 * @method
 * @param {ve.dm.ListItemNode} listItem List item to indent
 * @throws {Error} listItem must be a ve.dm.ListItemNode
 */
ve.ui.IndentationAction.prototype.indentListItem = function ( listItem ) {
	if ( !( listItem instanceof ve.dm.ListItemNode ) ) {
		throw new Error( 'listItem must be a ve.dm.ListItemNode' );
	}
	/*
	 * Indenting a list item is done as follows:
	 *
	 * 1. Wrap the listItem in a list and a listItem (<li> --> <li><ul><li>)
	 * 2. Merge this wrapped listItem into the previous listItem if present
	 *    (<li>Previous</li><li><ul><li>This --> <li>Previous<ul><li>This)
	 * 3. If this results in the wrapped list being preceded by another list,
	 *    merge those lists.
	 */
	var tx, range,
		surfaceModel = this.surface.getModel(),
		documentModel = surfaceModel.getDocument(),
		selection = surfaceModel.getSelection(),
		listType = listItem.getParent().getAttribute( 'style' ),
		listItemRange = listItem.getOuterRange(),
		innerListItemRange,
		outerListItemRange,
		mergeStart,
		mergeEnd;

	if ( !( selection instanceof ve.dm.LinearSelection ) ) {
		return;
	}

	range = selection.getRange();

	// CAREFUL: after initializing the variables above, we cannot use the model tree!
	// The first transaction will cause rebuilds so the nodes we have references to now
	// will be detached and useless after the first transaction. Instead, inspect
	// documentModel.data to find out things about the current structure.

	// (1) Wrap the listItem in a list and a listItem
	tx = ve.dm.Transaction.newFromWrap( documentModel,
		listItemRange,
		[],
		[ { type: 'listItem' }, { type: 'list', attributes: { style: listType } } ],
		[],
		[]
	);
	surfaceModel.change( tx );
	range = tx.translateRange( range );
	// tx.translateRange( innerListItemRange ) doesn't do what we want
	innerListItemRange = listItemRange.translate( 2 );
	outerListItemRange = new ve.Range( listItemRange.start, listItemRange.end + 2 );

	// (2) Merge the listItem into the previous listItem (if there is one)
	if (
		documentModel.data.getData( listItemRange.start ).type === 'listItem' &&
		documentModel.data.getData( listItemRange.start - 1 ).type === '/listItem'
	) {
		mergeStart = listItemRange.start - 1;
		mergeEnd = listItemRange.start + 1;
		// (3) If this results in adjacent lists, merge those too
		if (
			documentModel.data.getData( mergeEnd ).type === 'list' &&
			documentModel.data.getData( mergeStart - 1 ).type === '/list'
		) {
			mergeStart--;
			mergeEnd++;
		}
		tx = ve.dm.Transaction.newFromRemoval( documentModel, new ve.Range( mergeStart, mergeEnd ) );
		surfaceModel.change( tx );
		range = tx.translateRange( range );
		innerListItemRange = tx.translateRange( innerListItemRange );
		outerListItemRange = tx.translateRange( outerListItemRange );
	}

	// TODO If this listItem has a child list, split&unwrap it

	surfaceModel.setLinearSelection( range );
};

/**
 * Unindent a list item.
 *
 * TODO: Refactor functionality into {ve.dm.SurfaceFragment}.
 *
 * @method
 * @param {ve.dm.ListItemNode} listItem List item to unindent
 * @throws {Error} listItem must be a ve.dm.ListItemNode
 */
ve.ui.IndentationAction.prototype.unindentListItem = function ( listItem ) {
	if ( !( listItem instanceof ve.dm.ListItemNode ) ) {
		throw new Error( 'listItem must be a ve.dm.ListItemNode' );
	}
	/*
	 * Outdenting a list item is done as follows:
	 * 1. Split the parent list to isolate the listItem in its own list
	 * 1a. Split the list before the listItem if it's not the first child
	 * 1b. Split the list after the listItem if it's not the last child
	 * 2. If this isolated list's parent is not a listItem, unwrap the listItem and the isolated list, and stop.
	 * 3. Split the parent listItem to isolate the list in its own listItem
	 * 3a. Split the listItem before the list if it's not the first child
	 * 3b. Split the listItem after the list if it's not the last child
	 * 4. Unwrap the now-isolated listItem and the isolated list
	 */
	// TODO: Child list handling, gotta figure that out.
	var tx, i, length, children, child, splitListRange,
		surfaceModel = this.surface.getModel(),
		documentModel = surfaceModel.getDocument(),
		fragment = surfaceModel.getLinearFragment( listItem.getOuterRange(), true ),
		list = listItem.getParent(),
		listElement = list.getClonedElement(),
		grandParentType = list.getParent().getType(),
		listItemRange = listItem.getOuterRange();

	// CAREFUL: after initializing the variables above, we cannot use the model tree!
	// The first transaction will cause rebuilds so the nodes we have references to now
	// will be detached and useless after the first transaction. Instead, inspect
	// documentModel.data to find out things about the current structure.

	// (1) Split the listItem into a separate list
	if ( documentModel.data.getData( listItemRange.start - 1 ).type !== 'list' ) {
		// (1a) listItem is not the first child, split the list before listItem
		tx = ve.dm.Transaction.newFromInsertion( documentModel, listItemRange.start,
			[ { type: '/list' }, listElement ]
		);
		surfaceModel.change( tx );
		// tx.translateRange( listItemRange ) doesn't do what we want
		listItemRange = listItemRange.translate( 2 );
	}
	if ( documentModel.data.getData( listItemRange.end ).type !== '/list' ) {
		// (1b) listItem is not the last child, split the list after listItem
		tx = ve.dm.Transaction.newFromInsertion( documentModel, listItemRange.end,
			[ { type: '/list' }, listElement ]
		);
		surfaceModel.change( tx );
		// listItemRange is not affected by this transaction
	}
	splitListRange = new ve.Range( listItemRange.start - 1, listItemRange.end + 1 );

	if ( grandParentType !== 'listItem' ) {
		// The user is trying to unindent a list item that's not nested
		// (2) Unwrap both the list and the listItem, dumping the listItem's contents
		// into the list's parent
		tx = ve.dm.Transaction.newFromWrap( documentModel,
			new ve.Range( listItemRange.start + 1, listItemRange.end - 1 ),
			[ { type: 'list' }, { type: 'listItem' } ],
			[],
			[],
			[]
		);
		surfaceModel.change( tx );

		// ensure paragraphs are not wrapper paragraphs now
		// that they are not in a list
		children = fragment.getSiblingNodes();
		for ( i = 0, length = children.length; i < length; i++ ) {
			child = children[i].node;
			if (
				child.type === 'paragraph' &&
				child.element.internal &&
				child.element.internal.generated === 'wrapper'
			) {
				delete child.element.internal.generated;
				if ( ve.isEmptyObject( child.element.internal ) ) {
					delete child.element.internal;
				}
			}
		}
	} else {
		// (3) Split the list away from parentListItem into its own listItem
		// TODO factor common split logic somehow?
		if ( documentModel.data.getData( splitListRange.start - 1 ).type !== 'listItem' ) {
			// (3a) Split parentListItem before list
			tx = ve.dm.Transaction.newFromInsertion( documentModel, splitListRange.start,
				[ { type: '/listItem' }, { type: 'listItem' } ]
			);
			surfaceModel.change( tx );
			// tx.translateRange( splitListRange ) doesn't do what we want
			splitListRange = splitListRange.translate( 2 );
		}
		if ( documentModel.data.getData( splitListRange.end ).type !== '/listItem' ) {
			// (3b) Split parentListItem after list
			tx = ve.dm.Transaction.newFromInsertion( documentModel, splitListRange.end,
				[ { type: '/listItem' }, { type: 'listItem' } ]
			);
			surfaceModel.change( tx );
			// splitListRange is not affected by this transaction
		}

		// (4) Unwrap the list and its containing listItem
		tx = ve.dm.Transaction.newFromWrap( documentModel,
			new ve.Range( splitListRange.start + 1, splitListRange.end - 1 ),
			[ { type: 'listItem' }, { type: 'list' } ],
			[],
			[],
			[]
		);
		surfaceModel.change( tx );
	}
};

/* Registration */

ve.ui.actionFactory.register( ve.ui.IndentationAction );

/*!
 * VisualEditor UserInterface ListAction class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * List action.
 *
 * @class
 * @extends ve.ui.Action
 * @constructor
 * @param {ve.ui.Surface} surface Surface to act on
 */
ve.ui.ListAction = function VeUiListAction( surface ) {
	// Parent constructor
	ve.ui.Action.call( this, surface );
};

/* Inheritance */

OO.inheritClass( ve.ui.ListAction, ve.ui.Action );

/* Static Properties */

ve.ui.ListAction.static.name = 'list';

/**
 * List of allowed methods for the action.
 *
 * @static
 * @property
 */
ve.ui.ListAction.static.methods = [ 'wrap', 'unwrap', 'toggle', 'wrapOnce' ];

/* Methods */

/**
 * Check if the current selection is wrapped in a list of a given style
 *
 * @method
 * @param {string|null} style List style, e.g. 'number' or 'bullet', or null for any style
 * @return {boolean} Current selection is all wrapped in a list
 */
ve.ui.ListAction.prototype.allWrapped = function ( style ) {
	var i, len,
		attributes = style ? { style: style } : undefined,
		nodes = this.surface.getModel().getFragment().getLeafNodes(),
		all = !!nodes.length;

	for ( i = 0, len = nodes.length; i < len; i++ ) {
		if (
			( len === 1 || !nodes[i].range || nodes[i].range.getLength() ) &&
			!nodes[i].node.hasMatchingAncestor( 'list', attributes )
		) {
			all = false;
			break;
		}
	}
	return all;
};

/**
 * Toggle a list around content.
 *
 * @method
 * @param {string} style List style, e.g. 'number' or 'bullet'
 * @param {boolean} noBreakpoints Don't create breakpoints
 * @return {boolean} Action was executed
 */
ve.ui.ListAction.prototype.toggle = function ( style, noBreakpoints ) {
	return this[this.allWrapped( style ) ? 'unwrap' : 'wrap']( style, noBreakpoints );
};

/**
 * Add a list around content only if it has no list already.
 *
 * @method
 * @param {string} style List style, e.g. 'number' or 'bullet'
 * @param {boolean} noBreakpoints Don't create breakpoints
 * @return {boolean} Action was executed
 */
ve.ui.ListAction.prototype.wrapOnce = function ( style, noBreakpoints ) {
	// Check for a list of any style
	if ( !this.allWrapped() ) {
		return this.wrap( style, noBreakpoints );
	}
	return false;
};

/**
 * Add a list around content.
 *
 * TODO: Refactor functionality into {ve.dm.SurfaceFragment}.
 *
 * @method
 * @param {string} style List style, e.g. 'number' or 'bullet'
 * @param {boolean} noBreakpoints Don't create breakpoints
 * @return {boolean} Action was executed
 */
ve.ui.ListAction.prototype.wrap = function ( style, noBreakpoints ) {
	var tx, i, previousList, groupRange, group, range,
		surfaceModel = this.surface.getModel(),
		documentModel = surfaceModel.getDocument(),
		selection = surfaceModel.getSelection(),
		groups;

	if ( !( selection instanceof ve.dm.LinearSelection ) ) {
		return false;
	}

	range = selection.getRange();

	if ( !noBreakpoints ) {
		surfaceModel.breakpoint();
	}

	// TODO: Would be good to refactor at some point and avoid/abstract path split for block slug
	// and not block slug.

	if (
		range.isCollapsed() &&
		!documentModel.data.isContentOffset( range.to ) &&
		documentModel.hasSlugAtOffset( range.to )
	) {
		// Inside block level slug
		surfaceModel.change(
			ve.dm.Transaction.newFromInsertion(
				documentModel,
				range.from,
				[
					{ type: 'list', attributes: { style: style } },
					{ type: 'listItem' },
					{ type: 'paragraph' },
					{ type: '/paragraph' },
					{ type: '/listItem' },
					{ type: '/list' }

				]
			),
			new ve.dm.LinearSelection( documentModel, new ve.Range( range.to + 3 ) )
		);
	} else {
		groups = documentModel.getCoveredSiblingGroups( range );
		for ( i = 0; i < groups.length; i++ ) {
			group = groups[i];
			if ( group.grandparent && group.grandparent.getType() === 'list' ) {
				if ( group.grandparent !== previousList ) {
					// Change the list style
					surfaceModel.change(
						ve.dm.Transaction.newFromAttributeChanges(
							documentModel, group.grandparent.getOffset(), { style: style }
						),
						selection
					);
					// Skip this one next time
					previousList = group.grandparent;
				}
			} else {
				// Get a range that covers the whole group
				groupRange = new ve.Range(
					group.nodes[0].getOuterRange().start,
					group.nodes[group.nodes.length - 1].getOuterRange().end
				);
				// Convert everything to paragraphs first
				surfaceModel.change(
					ve.dm.Transaction.newFromContentBranchConversion(
						documentModel, groupRange, 'paragraph'
					),
					selection
				);
				// Wrap everything in a list and each content branch in a listItem
				tx = ve.dm.Transaction.newFromWrap(
					documentModel,
					groupRange,
					[],
					[{ type: 'list', attributes: { style: style } }],
					[],
					[{ type: 'listItem' }]
				);
				surfaceModel.change(
					tx,
					new ve.dm.LinearSelection( documentModel, tx.translateRange( range ) )
				);
			}
		}
	}
	if ( !noBreakpoints ) {
		surfaceModel.breakpoint();
	}
	this.surface.getView().focus();
	return true;
};

/**
 * Remove list around content.
 *
 * TODO: Refactor functionality into {ve.dm.SurfaceFragment}.
 *
 * @method
 * @param {boolean} noBreakpoints Don't create breakpoints
 * @return {boolean} Action was executed
 */
ve.ui.ListAction.prototype.unwrap = function ( noBreakpoints ) {
	var node,
		surfaceModel = this.surface.getModel(),
		documentModel = surfaceModel.getDocument();

	if ( !( surfaceModel.getSelection() instanceof ve.dm.LinearSelection ) ) {
		return false;
	}

	if ( !noBreakpoints ) {
		surfaceModel.breakpoint();
	}

	do {
		node = documentModel.getBranchNodeFromOffset( surfaceModel.getSelection().getRange().start );
	} while ( node.hasMatchingAncestor( 'list' ) && this.surface.execute( 'indentation', 'decrease' ) );

	if ( !noBreakpoints ) {
		surfaceModel.breakpoint();
	}

	this.surface.getView().focus();
	return true;
};

/* Registration */

ve.ui.actionFactory.register( ve.ui.ListAction );

/*!
 * VisualEditor ContentEditable TableNode class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see AUTHORS.txt
 * @license The MIT License (MIT); see LICENSE.txt
 */

/**
 * Table action.
 *
 * @class
 * @extends ve.ui.Action
 *
 * @constructor
 * @param {ve.ui.Surface} surface Surface to act on
 */
ve.ui.TableAction = function VeUiTableAction( surface ) {
	// Parent constructor
	ve.ui.Action.call( this, surface );
};

/* Inheritance */

OO.inheritClass( ve.ui.TableAction, ve.ui.Action );

/* Static Properties */

ve.ui.TableAction.static.name = 'table';

/**
 * List of allowed methods for the action.
 *
 * @static
 * @property
 */
ve.ui.TableAction.static.methods = [ 'create', 'insert', 'delete', 'changeCellStyle', 'mergeCells', 'caption' ];

/* Methods */

/**
 * Creates a new table.
 *
 * @param {Object} [options] Table creation options
 * @param {number} [options.cols=4] Number of rows
 * @param {number} [options.rows=3] Number of columns
 * @param {boolean} [options.header] Make the first row a header row
 * @param {Object} [options.type='table'] Table node type, must inherit from table
 * @param {Object} [options.attributes] Attributes to give the table
 * @return {boolean} Action was executed
 */
ve.ui.TableAction.prototype.create = function ( options ) {
	options = options || {};
	var i,
		type = options.type || 'table',
		tableElement = { type: type },
		surfaceModel = this.surface.getModel(),
		fragment = surfaceModel.getFragment(),
		data = [],
		numberOfCols = options.cols || 4,
		numberOfRows = options.rows || 3;

	if ( !( fragment.getSelection() instanceof ve.dm.LinearSelection ) ) {
		return false;
	}

	if ( options.attributes ) {
		tableElement.attributes = ve.copy( options.attributes );
	}

	data.push( tableElement );
	data.push( { type: 'tableSection', attributes: { style: 'body' } } );
	if ( options.header ) {
		data = data.concat( ve.dm.TableRowNode.static.createData( { style: 'header', cellCount: numberOfCols } ) );
	}
	for ( i = 0; i < numberOfRows; i++ ) {
		data = data.concat( ve.dm.TableRowNode.static.createData( { style: 'data', cellCount: numberOfCols } ) );
	}
	data.push( { type: '/tableSection' } );
	data.push( { type: '/' + type } );

	fragment.insertContent( data, false );
	surfaceModel.setSelection( new ve.dm.TableSelection(
		fragment.getDocument(), fragment.getSelection().getRange(), 0, 0, 0, 0
	) );
	return true;
};

/**
 * Inserts a new row or column into the currently focused table.
 *
 * @param {String} mode Insertion mode; 'row' to insert a new row, 'col' for a new column
 * @param {String} position Insertion position; 'before' to insert before the current selection,
 *   'after' to insert after it
 * @return {boolean} Action was executed
 */
ve.ui.TableAction.prototype.insert = function ( mode, position ) {
	var index,
		surfaceModel = this.surface.getModel(),
		selection = surfaceModel.getSelection();

	if ( !( selection instanceof ve.dm.TableSelection ) ) {
		return false;
	}
	if ( mode === 'col' ) {
		index = position === 'before' ? selection.startCol : selection.endCol;
	} else {
		index = position === 'before' ? selection.startRow : selection.endRow;
	}
	if ( position === 'before' ) {
		if ( mode === 'col' ) {
			selection = selection.newFromAdjustment( 1, 0 );
		} else {
			selection = selection.newFromAdjustment( 0, 1 );
		}
		surfaceModel.setSelection( selection );
	}
	this.insertRowOrCol( selection.getTableNode(), mode, index, position, selection );
	return true;
};

/**
 * Deletes selected rows, columns, or the whole table.
 *
 * @param {String} mode Deletion mode; 'row' to delete rows, 'col' for columns, 'table' to remove the whole table
 * @return {boolean} Action was executed
 */
ve.ui.TableAction.prototype.delete = function ( mode ) {
	var tableNode, minIndex, maxIndex, isFull,
		selection = this.surface.getModel().getSelection();

	if ( !( selection instanceof ve.dm.TableSelection ) ) {
		return false;
	}

	tableNode = selection.getTableNode();
	// Either delete the table or rows or columns
	if ( mode === 'table' ) {
		this.deleteTable( tableNode );
	} else {
		if ( mode === 'col' ) {
			minIndex = selection.startCol;
			maxIndex = selection.endCol;
			isFull = selection.isFullRow();
		} else {
			minIndex = selection.startRow;
			maxIndex = selection.endRow;
			isFull = selection.isFullCol();
		}
		// delete the whole table if all rows or cols get deleted
		if ( isFull ) {
			this.deleteTable( tableNode );
		} else {
			this.deleteRowsOrColumns( tableNode.matrix, mode, minIndex, maxIndex );
		}
	}
	return true;
};

/**
 * Change cell style
 *
 * @param {string} style Cell style; 'header' or 'data'
 * @return {boolean} Action was executed
 */
ve.ui.TableAction.prototype.changeCellStyle = function ( style ) {
	var i, ranges,
		txs = [],
		surfaceModel = this.surface.getModel(),
		selection = surfaceModel.getSelection();

	if ( !( selection instanceof ve.dm.TableSelection ) ) {
		return false;
	}

	ranges = selection.getOuterRanges();
	for ( i = ranges.length - 1; i >= 0; i-- ) {
		txs.push(
			ve.dm.Transaction.newFromAttributeChanges(
				surfaceModel.getDocument(), ranges[i].start, { style: style }
			)
		);
	}
	surfaceModel.change( txs );
	return true;
};

/**
 * Merge multiple cells into one, or split a merged cell.
 *
 * @return {boolean} Action was executed
 */
ve.ui.TableAction.prototype.mergeCells = function () {
	var i, r, c, cell, cells, hasNonPlaceholders,
		txs = [],
		surfaceModel = this.surface.getModel(),
		selection = surfaceModel.getSelection(),
		matrix = selection.getTableNode().getMatrix();

	if ( !( selection instanceof ve.dm.TableSelection ) ) {
		return false;
	}

	if ( selection.isSingleCell() ) {
		// Split
		cells = selection.getMatrixCells( true );
		txs.push(
			ve.dm.Transaction.newFromAttributeChanges(
				surfaceModel.getDocument(), cells[0].node.getOuterRange().start,
				{ colspan: 1, rowspan: 1 }
			)
		);
		for ( i = cells.length - 1; i >= 1; i-- ) {
			txs.push(
				this.replacePlaceholder(
					matrix,
					cells[i],
					{ style: cells[0].node.getStyle() }
				)
			);
		}
		surfaceModel.change( txs );
	} else {
		// Merge
		cells = selection.getMatrixCells();
		txs.push(
			ve.dm.Transaction.newFromAttributeChanges(
				surfaceModel.getDocument(), cells[0].node.getOuterRange().start,
				{
					colspan: 1 + selection.endCol - selection.startCol,
					rowspan: 1 + selection.endRow - selection.startRow
				}
			)
		);
		for ( i = cells.length - 1; i >= 1; i-- ) {
			txs.push(
				ve.dm.Transaction.newFromRemoval(
					surfaceModel.getDocument(), cells[i].node.getOuterRange()
				)
			);
		}
		surfaceModel.change( txs );

		// Check for rows filled with entirely placeholders. If such a row exists, delete it.
		for ( r = selection.endRow; r >= selection.startRow; r-- ) {
			hasNonPlaceholders = false;
			for ( c = 0; ( cell = matrix.getCell( r, c ) ) !== undefined; c++ ) {
				if ( cell && !cell.isPlaceholder() ) {
					hasNonPlaceholders = true;
					break;
				}
			}
			if ( !hasNonPlaceholders ) {
				this.deleteRowsOrColumns( matrix, 'row', r, r );
			}
		}

		// Check for columns filled with entirely placeholders. If such a column exists, delete it.
		for ( c = selection.endCol; c >= selection.startCol; c-- ) {
			hasNonPlaceholders = false;
			for ( r = 0; ( cell = matrix.getCell( r, c ) ) !== undefined; r++ ) {
				if ( cell && !cell.isPlaceholder() ) {
					hasNonPlaceholders = true;
					break;
				}
			}
			if ( !hasNonPlaceholders ) {
				this.deleteRowsOrColumns( matrix, 'col', c, c );
			}
		}
	}
	return true;
};

/**
 * Toggle the existence of a caption node on the table
 *
 * @return {boolean} Action was executed
 */
ve.ui.TableAction.prototype.caption = function () {
	var fragment, captionNode, nodes, node, tableFragment,
		surfaceModel = this.surface.getModel(),
		selection = surfaceModel.getSelection();

	if ( selection instanceof ve.dm.TableSelection ) {
		captionNode = selection.getTableNode().getCaptionNode();
	} else if ( selection instanceof ve.dm.LinearSelection ) {
		nodes = surfaceModel.getFragment().getSelectedLeafNodes();

		node = nodes[0];
		while ( node ) {
			if ( node instanceof ve.dm.TableCaptionNode ) {
				captionNode = node;
				break;
			}
			node = node.getParent();
		}
		if ( !captionNode ) {
			return;
		}
		tableFragment = surfaceModel.getFragment( new ve.dm.TableSelection(
			surfaceModel.getDocument(),
			captionNode.getParent().getOuterRange(),
			0, 0, 0, 0,
			true
		) );
	} else {
		return false;
	}

	if ( captionNode ) {
		fragment = surfaceModel.getLinearFragment( captionNode.getOuterRange(), true );
		fragment.removeContent();
		if ( tableFragment ) {
			tableFragment.select();
		}
	} else {
		fragment = surfaceModel.getLinearFragment( new ve.Range( selection.tableRange.start + 1 ), true );

		fragment.insertContent( [
			{ type: 'tableCaption' },
			{ type: 'paragraph', internal: { generated: 'wrapper' } },
			{ type: '/paragraph' },
			{ type: '/tableCaption' }
		], false );

		fragment.collapseToStart().adjustLinearSelection( 2, 2 ).select();
	}
	return true;
};

/* Low-level API */
// TODO: This API does only depends on the model so it should possibly be moved

/**
 * Deletes a whole table.
 *
 * @param {ve.dm.TableNode} tableNode Table node
 */
ve.ui.TableAction.prototype.deleteTable = function ( tableNode ) {
	this.surface.getModel().getLinearFragment( tableNode.getOuterRange() ).delete();
};

/**
 * Inserts a new row or column.
 *
 * Example: a new row can be inserted after the 2nd row using
 *
 *    insertRowOrCol( table, 'row', 1, 'after' );
 *
 * @param {ve.dm.TableNode} tableNode Table node
 * @param {String} mode Insertion mode; 'row' or 'col'
 * @param {Number} index Row or column index of the base row or column.
 * @param {String} position Insertion position; 'before' or 'after'
 * @param {ve.dm.TableSelection} [selection] Selection to move to after insertion
 */
ve.ui.TableAction.prototype.insertRowOrCol = function ( tableNode, mode, index, position, selection ) {
	var refIndex, cells, refCells, before,
		offset, range, i, l, cell, refCell, data, style,
		matrix = tableNode.matrix,
		txs = [],
		updated = {},
		inserts = [],
		surfaceModel = this.surface.getModel();

	before = position === 'before';

	// Note: when we insert a new row (or column) we might need to increment a span property
	// instead of inserting a new cell.
	// To achieve this we look at the so called base row and a so called reference row.
	// The base row is the one after or before which the new row will be inserted.
	// The reference row is the one which is currently at the place of the new one.
	// E.g., consider inserting a new row after the second: the base row is the second, the
	// reference row is the third.
	// A span must be increased if the base cell and the reference cell have the same 'owner'.
	// E.g.:  C* | P**; C | P* | P**, i.e., one of the two cells might be the owner of the other,
	// or vice versa, or both a placeholders of a common cell.

	// The index of the reference row or column
	refIndex = index + ( before ? -1 : 1 );
	// cells of the selected row or column
	if ( mode === 'row' ) {
		cells = matrix.getRow( index ) || [];
		refCells = matrix.getRow( refIndex ) || [];
	} else {
		cells = matrix.getColumn( index ) || [];
		refCells = matrix.getColumn( refIndex ) || [];
	}

	for ( i = 0, l = cells.length; i < l; i++ ) {
		cell = cells[i];
		if ( !cell ) {
			continue;
		}
		refCell = refCells[i];
		// Detect if span update is necessary
		if ( refCell && ( cell.isPlaceholder() || refCell.isPlaceholder() ) ) {
			if ( cell.node === refCell.node ) {
				cell = cell.owner || cell;
				if ( !updated[cell.key] ) {
					// Note: we can safely record span modifications as they do not affect range offsets.
					txs.push( this.incrementSpan( cell, mode ) );
					updated[cell.key] = true;
				}
				continue;
			}
		}
		// If it is not a span changer, we record the base cell as a reference for insertion
		inserts.push( cell );
	}

	// Inserting a new row differs completely from inserting a new column:
	// For a new row, a new row node is created, and inserted relative to an existing row node.
	// For a new column, new cells are inserted into existing row nodes at appropriate positions,
	// i.e., relative to an existing cell node.
	if ( mode === 'row' ) {
		data = ve.dm.TableRowNode.static.createData( {
			cellCount: inserts.length,
			// Take the style of the first cell of the selected row
			style: cells[0].node.getStyle()
		} );
		range = matrix.getRowNode( index ).getOuterRange();
		offset = before ? range.start : range.end;
		txs.push( ve.dm.Transaction.newFromInsertion( surfaceModel.getDocument(), offset, data ) );
	} else {
		// Make sure that the inserts are in descending offset order
		// so that the transactions do not affect subsequent range offsets.
		inserts.sort( ve.dm.TableMatrixCell.static.sortDescending );

		// For inserting a new cell we need to find a reference cell node
		// which we can use to get a proper insertion offset.
		for ( i = 0; i < inserts.length; i++ ) {
			cell = inserts[i];
			if ( !cell ) {
				continue;
			}
			// If the cell is a placeholder this will find a close cell node in the same row
			refCell = matrix.findClosestCell( cell );
			if ( refCell ) {
				range = refCell.node.getOuterRange();
				// if the found cell is before the base cell the new cell must be placed after it, in any case,
				// Only if the base cell is not a placeholder we have to consider the insert mode.
				if ( refCell.col < cell.col || ( refCell.col === cell.col && !before ) ) {
					offset = range.end;
				} else {
					offset = range.start;
				}
				style = refCell.node.getStyle();
			} else {
				// if there are only placeholders in the row, we use the row node's inner range
				// for the insertion offset
				range = matrix.getRowNode( cell.row ).getRange();
				offset = before ? range.start : range.end;
				style = cells[0].node.getStyle();
			}
			data = ve.dm.TableCellNode.static.createData( { style: style } );
			txs.push( ve.dm.Transaction.newFromInsertion( surfaceModel.getDocument(), offset, data ) );
		}
	}
	surfaceModel.change( txs, selection.translateByTransactions( txs ) );
};

/**
 * Increase the span of a cell by one.
 *
 * @param {ve.dm.TableMatrixCell} cell Table matrix cell
 * @param {String} mode Span to increment; 'row' or 'col'
 * @return {ve.dm.Transaction} Transaction
 */
ve.ui.TableAction.prototype.incrementSpan = function ( cell, mode ) {
	var data,
		surfaceModel = this.surface.getModel();

	if ( mode === 'row' ) {
		data = { rowspan: cell.node.getRowspan() + 1 };
	} else {
		data = { colspan: cell.node.getColspan() + 1 };
	}

	return ve.dm.Transaction.newFromAttributeChanges( surfaceModel.getDocument(), cell.node.getOuterRange().start, data );
};

/**
 * Decreases the span of a cell so that the given interval is removed.
 *
 * @param {ve.dm.TableMatrixCell} cell Table matrix cell
 * @param {String} mode Span to decrement 'row' or 'col'
 * @param {Number} minIndex Smallest row or column index (inclusive)
 * @param {Number} maxIndex Largest row or column index (inclusive)
 * @return {ve.dm.Transaction} Transaction
 */
ve.ui.TableAction.prototype.decrementSpan = function ( cell, mode, minIndex, maxIndex ) {
	var span, data,
		surfaceModel = this.surface.getModel();

	span = ( minIndex - cell[mode] ) + Math.max( 0, cell[mode] + cell.node.getSpans()[mode] - 1 - maxIndex );
	if ( mode === 'row' ) {
		data = { rowspan: span };
	} else {
		data = { colspan: span };
	}

	return ve.dm.Transaction.newFromAttributeChanges( surfaceModel.getDocument(), cell.node.getOuterRange().start, data );
};

/**
 * Deletes rows or columns within a given range.
 *
 * e.g. rows 2-4 can be deleted using
 *
 *    ve.ui.TableAction.deleteRowsOrColumns( matrix, 'row', 1, 3 );
 *
 * @param {ve.dm.TableMatrix} matrix Table matrix
 * @param {String} mode 'row' or 'col'
 * @param {Number} minIndex Smallest row or column index to be deleted
 * @param {Number} maxIndex Largest row or column index to be deleted (inclusive)
 */
ve.ui.TableAction.prototype.deleteRowsOrColumns = function ( matrix, mode, minIndex, maxIndex ) {
	var row, col, i, l, cell, key,
		span, startRow, startCol, endRow, endCol, rowNode,
		cells = [],
		txs = [],
		adapted = {},
		actions = [],
		surfaceModel = this.surface.getModel();

	// Deleting cells can have two additional consequences:
	// 1. The cell is a Placeholder. The owner's span must be decreased.
	// 2. The cell is owner of placeholders which get orphaned by the deletion.
	//    The first of the placeholders now becomes the real cell, with the span adjusted.
	//    It also inherits all of the properties and content of the removed cell.
	// Insertions and deletions of cells must be done in an appropriate order, so that the transactions
	// do not interfere with each other. To achieve that, we record insertions and deletions and
	// sort them by the position of the cell (row, column) in the table matrix.

	if ( mode === 'row' ) {
		for ( row = minIndex; row <= maxIndex; row++ ) {
			cells = cells.concat( matrix.getRow( row ) );
		}
	} else {
		for ( col = minIndex; col <= maxIndex; col++ ) {
			cells = cells.concat( matrix.getColumn( col ) );
		}
	}

	for ( i = 0, l = cells.length; i < l; i++ ) {
		cell = cells[i];
		if ( !cell ) {
			continue;
		}
		if ( cell.isPlaceholder() ) {
			key = cell.owner.key;
			if ( !adapted[key] ) {
				// Note: we can record this transaction already, as it does not have an effect on the
				// node range
				txs.push( this.decrementSpan( cell.owner, mode, minIndex, maxIndex ) );
				adapted[key] = true;
			}
			continue;
		}

		// Detect if the owner of a spanning cell gets deleted and
		// leaves orphaned placeholders
		span = cell.node.getSpans()[mode];
		if ( cell[mode] + span - 1  > maxIndex ) {
			// add inserts for orphaned place holders
			if ( mode === 'col' ) {
				startRow = cell.row;
				startCol = maxIndex + 1;
			} else {
				startRow = maxIndex + 1;
				startCol = cell.col;
			}
			endRow = cell.row + cell.node.getRowspan() - 1;
			endCol = cell.col + cell.node.getColspan() - 1;

			// Record the insertion to apply it later
			actions.push( {
				action: 'insert',
				cell: matrix.getCell( startRow, startCol ),
				colspan: 1 + endCol - startCol,
				rowspan: 1 + endRow - startRow,
				style: cell.node.getStyle(),
				content: surfaceModel.getDocument().getData( cell.node.getRange() )
			} );
		}

		// Cell nodes only get deleted when deleting columns (otherwise row nodes)
		if ( mode === 'col' ) {
			actions.push( { action: 'delete', cell: cell });
		}
	}

	// Make sure that the actions are in descending offset order
	// so that the transactions do not affect subsequent range offsets.
	// Sort recorded actions to make sure the transactions will not interfere with respect to offsets
	actions.sort( function ( a, b ) {
		return ve.dm.TableMatrixCell.static.sortDescending( a.cell, b.cell );
	} );

	if ( mode === 'row' ) {
		// First replace orphaned placeholders which are below the last deleted row,
		// thus, this works with regard to transaction offsets
		for ( i = 0; i < actions.length; i++ ) {
			txs.push( this.replacePlaceholder( matrix, actions[i].cell, actions[i] ) );
		}
		// Remove rows in reverse order to have valid transaction offsets
		for ( row = maxIndex; row >= minIndex; row-- ) {
			rowNode = matrix.getRowNode( row );
			txs.push( ve.dm.Transaction.newFromRemoval( surfaceModel.getDocument(), rowNode.getOuterRange() ) );
		}
	} else {
		for ( i = 0; i < actions.length; i++ ) {
			if ( actions[i].action === 'insert' ) {
				txs.push( this.replacePlaceholder( matrix, actions[i].cell, actions[i] ) );
			} else {
				txs.push( ve.dm.Transaction.newFromRemoval( surfaceModel.getDocument(), actions[i].cell.node.getOuterRange() ) );
			}
		}
	}
	surfaceModel.change( txs, new ve.dm.NullSelection( surfaceModel.getDocument() ) );
};

/**
 * Inserts a new cell for an orphaned placeholder.
 *
 * @param {ve.dm.TableMatrix} matrix Table matrix
 * @param {ve.dm.TableMatrixCell} placeholder Placeholder cell to replace
 * @param {Object} [options] Options to pass to ve.dm.TableCellNode.static.createData
 * @return {ve.dm.Transaction} Transaction
 */
ve.ui.TableAction.prototype.replacePlaceholder = function ( matrix, placeholder, options ) {
	var range, offset, data,
		// For inserting the new cell a reference cell node
		// which is used to get an insertion offset.
		refCell = matrix.findClosestCell( placeholder ),
		surfaceModel = this.surface.getModel();

	if ( refCell ) {
		range = refCell.node.getOuterRange();
		offset = ( placeholder.col < refCell.col ) ? range.start : range.end;
	} else {
		// if there are only placeholders in the row, the row node's inner range is used
		range = matrix.getRowNode( placeholder.row ).getRange();
		offset = range.start;
	}
	data = ve.dm.TableCellNode.static.createData( options );
	return ve.dm.Transaction.newFromInsertion( surfaceModel.getDocument(), offset, data );
};

/* Registration */

ve.ui.actionFactory.register( ve.ui.TableAction );

/*!
 * VisualEditor UserInterface WindowAction class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Window action.
 *
 * @class
 * @extends ve.ui.Action
 * @constructor
 * @param {ve.ui.Surface} surface Surface to act on
 */
ve.ui.WindowAction = function VeUiWindowAction( surface ) {
	// Parent constructor
	ve.ui.Action.call( this, surface );
};

/* Inheritance */

OO.inheritClass( ve.ui.WindowAction, ve.ui.Action );

/* Static Properties */

ve.ui.WindowAction.static.name = 'window';

/**
 * List of allowed methods for the action.
 *
 * @static
 * @property
 */
ve.ui.WindowAction.static.methods = [ 'open', 'close', 'toggle' ];

/* Methods */

/**
 * Open a window.
 *
 * @method
 * @param {string} name Symbolic name of window to open
 * @param {Object} [data] Window opening data
 * @param {string} [action] Action to execute after opening, or immediately if the window is already open
 * @return {boolean} Action was executed
 */
ve.ui.WindowAction.prototype.open = function ( name, data, action ) {
	var windowType = this.getWindowType( name ),
		windowManager = windowType && this.getWindowManager( windowType ),
		autoClosePromise = $.Deferred().resolve().promise(),
		surface = this.surface,
		fragment = surface.getModel().getFragment( undefined, true ),
		dir = surface.getView().getDocument().getDirectionFromSelection( fragment.getSelection() ) ||
			surface.getModel().getDocument().getDir();

	if ( !windowManager ) {
		return false;
	}

	data = ve.extendObject( { dir: dir }, data, { fragment: fragment } );
	if ( windowType === 'toolbar' || windowType === 'inspector' ) {
		data = ve.extendObject( data, { surface: surface } );
		// TODO: Make auto-close a window manager setting
		autoClosePromise = windowManager.closeWindow( windowManager.getCurrentWindow() );
	}

	autoClosePromise.always( function () {
		windowManager.getWindow( name ).then( function ( win ) {
			var opening = windowManager.openWindow( win, data );

			surface.getView().emit( 'position' );

			if ( !win.constructor.static.activeSurface ) {
				surface.getView().deactivate();
			}

			opening.then( function ( closing ) {
				closing.then( function ( closed ) {
					if ( !win.constructor.static.activeSurface ) {
						surface.getView().activate();
					}
					closed.then( function () {
						surface.getView().emit( 'position' );
					} );
				} );
			} ).always( function () {
				if ( action ) {
					win.executeAction( action );
				}
			} );
		} );
	} );

	return true;
};

/**
 * Close a window
 *
 * @method
 * @param {string} name Symbolic name of window to open
 * @param {Object} [data] Window closing data
 * @return {boolean} Action was executed
 */
ve.ui.WindowAction.prototype.close = function ( name, data ) {
	var windowType = this.getWindowType( name ),
		windowManager = windowType && this.getWindowManager( windowType );

	if ( !windowManager ) {
		return false;
	}

	windowManager.closeWindow( name, data );
	return true;
};

/**
 * Toggle a window between open and close
 *
 * @method
 * @param {string} name Symbolic name of window to open or close
 * @param {Object} [data] Window opening or closing data
 * @return {boolean} Action was executed
 */
ve.ui.WindowAction.prototype.toggle = function ( name, data ) {
	var win,
		windowType = this.getWindowType( name ),
		windowManager = windowType && this.getWindowManager( windowType );

	if ( !windowManager ) {
		return false;
	}

	win = windowManager.getCurrentWindow();
	if ( !win || win.constructor.static.name !== name ) {
		this.open( name, data );
	} else {
		this.close( name, data );
	}
	return true;
};

/**
 * Get the type of a window class
 *
 * @param {string} name Window name
 * @return {string|null} Window type: 'inspector', 'toolbar' or 'dialog'
 */
ve.ui.WindowAction.prototype.getWindowType = function ( name ) {
	var windowClass = ve.ui.windowFactory.lookup( name );
	if ( windowClass.prototype instanceof ve.ui.FragmentInspector ) {
		return 'inspector';
	} else if ( windowClass.prototype instanceof ve.ui.ToolbarDialog ) {
		return 'toolbar';
	} else if ( windowClass.prototype instanceof OO.ui.Dialog ) {
		return 'dialog';
	}
	return null;
};

/**
 * Get the window manager for a specified window class
 *
 * @param {Function} windowClass Window class
 * @return {ve.ui.WindowManager|null} Window manager
 */
ve.ui.WindowAction.prototype.getWindowManager = function ( windowType ) {
	switch ( windowType ) {
		case 'inspector':
			return this.surface.getContext().getInspectors();
		case 'toolbar':
			return this.surface.getToolbarDialogs();
		case 'dialog':
			return this.surface.getDialogs();
	}
	return null;
};

/* Registration */

ve.ui.actionFactory.register( ve.ui.WindowAction );

/*!
 * VisualEditor UserInterface ClearAnnotationCommand class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * UserInterface clear all annotations command.
 *
 * @class
 * @extends ve.ui.Command
 *
 * @constructor
 */
ve.ui.ClearAnnotationCommand = function VeUiClearAnnotationCommand() {
	// Parent constructor
	ve.ui.ClearAnnotationCommand.super.call(
		this, 'clear', 'annotation', 'clearAll',
		{ supportedSelections: ['linear', 'table'] }
	);
};

/* Inheritance */

OO.inheritClass( ve.ui.ClearAnnotationCommand, ve.ui.Command );

/* Methods */

/**
 * @inheritdoc
 */
ve.ui.ClearAnnotationCommand.prototype.isExecutable = function ( fragment ) {
	// Parent method
	return ve.ui.ClearAnnotationCommand.super.prototype.isExecutable.apply( this, arguments ) &&
		fragment.hasAnnotations();
};

/* Registration */

ve.ui.commandRegistry.register( new ve.ui.ClearAnnotationCommand() );

/*!
 * VisualEditor UserInterface HistoryCommand class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * UserInterface history command.
 *
 * @class
 * @extends ve.ui.Command
 *
 * @constructor
 * @param {string} name
 * @param {string} method
 */
ve.ui.HistoryCommand = function VeUiHistoryCommand( name, method ) {
	// Parent constructor
	ve.ui.HistoryCommand.super.call( this, name, 'history', method );

	this.check = {
		undo: 'canUndo',
		redo: 'canRedo'
	}[method];
};

/* Inheritance */

OO.inheritClass( ve.ui.HistoryCommand, ve.ui.Command );

/* Methods */

/**
 * @inheritdoc
 */
ve.ui.HistoryCommand.prototype.isExecutable = function ( fragment ) {
	var surface = fragment.getSurface();

	// Parent method
	return ve.ui.HistoryCommand.super.prototype.isExecutable.apply( this, arguments ) &&
		surface[this.check].call( surface );
};

/* Registration */

ve.ui.commandRegistry.register( new ve.ui.HistoryCommand( 'undo', 'undo' ) );

ve.ui.commandRegistry.register( new ve.ui.HistoryCommand( 'redo', 'redo' ) );

/*!
 * VisualEditor UserInterface IndentationCommand class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * UserInterface indentation command.
 *
 * @class
 * @extends ve.ui.Command
 *
 * @constructor
 * @param {string} name
 * @param {string} method
 */
ve.ui.IndentationCommand = function VeUiIndentationCommand( name, method ) {
	// Parent constructor
	ve.ui.IndentationCommand.super.call(
		this, name, 'indentation', method,
		{ supportedSelections: ['linear'] }
	);
};

/* Inheritance */

OO.inheritClass( ve.ui.IndentationCommand, ve.ui.Command );

/* Methods */

/**
 * @inheritdoc
 */
ve.ui.IndentationCommand.prototype.isExecutable = function ( fragment ) {
	// Parent method
	if ( !ve.ui.IndentationCommand.super.prototype.isExecutable.apply( this, arguments ) ) {
		return false;
	}
	var i, len,
		nodes = fragment.getSelectedLeafNodes(),
		any = false;
	for ( i = 0, len = nodes.length; i < len; i++ ) {
		if ( nodes[i].hasMatchingAncestor( 'listItem' ) ) {
			any = true;
			break;
		}
	}
	return any;
};

/* Registration */

ve.ui.commandRegistry.register( new ve.ui.IndentationCommand( 'indent', 'increase' ) );

ve.ui.commandRegistry.register( new ve.ui.IndentationCommand( 'outdent', 'decrease' ) );

/*!
 * VisualEditor UserInterface MergeCellsCommand class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * UserInterface merge cells command.
 *
 * @class
 * @extends ve.ui.Command
 *
 * @constructor
 */
ve.ui.MergeCellsCommand = function VeUiMergeCellsCommand() {
	// Parent constructor
	ve.ui.MergeCellsCommand.super.call(
		this, 'mergeCells', 'table', 'mergeCells',
		{ supportedSelections: ['table'] }
	);
};

/* Inheritance */

OO.inheritClass( ve.ui.MergeCellsCommand, ve.ui.Command );

/* Methods */

/**
 * @inheritdoc
 */
ve.ui.MergeCellsCommand.prototype.isExecutable = function ( fragment ) {
	// Parent method
	return ve.ui.MergeCellsCommand.super.prototype.isExecutable.apply( this, arguments ) &&
		fragment.getSelection().getMatrixCells( true ).length > 1;
};

/* Registration */

ve.ui.commandRegistry.register( new ve.ui.MergeCellsCommand() );

/*!
 * VisualEditor UserInterface TableCaptionCommand class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * UserInterface table caption command.
 *
 * @class
 * @extends ve.ui.Command
 *
 * @constructor
 */
ve.ui.TableCaptionCommand = function VeUiTableCaptionCommand() {
	// Parent constructor
	ve.ui.TableCaptionCommand.super.call(
		this, 'tableCaption', 'table', 'caption',
		{ supportedSelections: ['linear', 'table'] }
	);
};

/* Inheritance */

OO.inheritClass( ve.ui.TableCaptionCommand, ve.ui.Command );

/* Methods */

/**
 * @inheritdoc
 */
ve.ui.TableCaptionCommand.prototype.isExecutable = function ( fragment ) {
	// Parent method
	if ( !ve.ui.TableCaptionCommand.super.prototype.isExecutable.apply( this, arguments ) ) {
		return false;
	}

	var i, len, nodes, hasCaptionNode,
		selection = fragment.getSelection();

	if ( selection instanceof ve.dm.TableSelection ) {
		return true;
	} else {
		nodes = fragment.getSelectedLeafNodes();
		hasCaptionNode = !!nodes.length;

		for ( i = 0, len = nodes.length; i < len; i++ ) {
			if ( !nodes[i].hasMatchingAncestor( 'tableCaption' ) ) {
				hasCaptionNode = false;
				break;
			}
		}
		return hasCaptionNode;
	}
};

/* Registration */

ve.ui.commandRegistry.register( new ve.ui.TableCaptionCommand() );

/*!
 * VisualEditor UserInterface FragmentDialog class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Dialog for working with fragments of content.
 *
 * @class
 * @abstract
 * @extends OO.ui.ProcessDialog
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
ve.ui.FragmentDialog = function VeUiFragmentDialog( config ) {
	// Parent constructor
	ve.ui.FragmentDialog.super.call( this, config );

	// Properties
	this.fragment = null;
};

/* Inheritance */

OO.inheritClass( ve.ui.FragmentDialog, OO.ui.ProcessDialog );

/**
 * @inheritdoc
 * @throws {Error} If fragment was not provided through data parameter
 */
ve.ui.FragmentDialog.prototype.getSetupProcess = function ( data ) {
	data = data || {};
	return ve.ui.FragmentDialog.super.prototype.getSetupProcess.apply( this, data )
		.next( function () {
			if ( !( data.fragment instanceof ve.dm.SurfaceFragment ) ) {
				throw new Error( 'Cannot open dialog: opening data must contain a fragment' );
			}
			this.fragment = data.fragment;
		}, this );
};

/**
 * @inheritdoc
 */
ve.ui.FragmentDialog.prototype.getTeardownProcess = function ( data ) {
	return ve.ui.FragmentDialog.super.prototype.getTeardownProcess.apply( this, data )
		.first( function () {
			this.fragment.select();
			this.fragment = null;
		}, this );
};

/**
 * Get the surface fragment the dialog is for
 *
 * @returns {ve.dm.SurfaceFragment|null} Surface fragment the dialog is for, null if the dialog is closed
 */
ve.ui.FragmentDialog.prototype.getFragment = function () {
	return this.fragment;
};

/*!
 * VisualEditor user interface NodeDialog class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Dialog for working with a node.
 *
 * @class
 * @extends ve.ui.FragmentDialog
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
ve.ui.NodeDialog = function VeUiNodeDialog( config ) {
	// Parent constructor
	ve.ui.NodeDialog.super.call( this, config );

	// Properties
	this.selectedNode = null;
};

/* Inheritance */

OO.inheritClass( ve.ui.NodeDialog, ve.ui.FragmentDialog );

/* Static Properties */

/**
 * Node classes compatible with this dialog.
 *
 * @static
 * @property {Function}
 * @inheritable
 */
ve.ui.NodeDialog.static.modelClasses = [];

/* Methods */

/**
 * Get the selected node.
 *
 * Should only be called after setup and before teardown.
 * If no node is selected or the selected node is incompatible, null will be returned.
 *
 * @param {Object} [data] Dialog opening data
 * @return {ve.dm.Node} Selected node
 */
ve.ui.NodeDialog.prototype.getSelectedNode = function () {
	var i, len,
		modelClasses = this.constructor.static.modelClasses,
		selectedNode = this.getFragment().getSelectedNode();

	for ( i = 0, len = modelClasses.length; i < len; i++ ) {
		if ( selectedNode instanceof modelClasses[i] ) {
			return selectedNode;
		}
	}
	return null;
};

/**
 * @inheritdoc
 */
ve.ui.NodeDialog.prototype.initialize = function ( data ) {
	// Parent method
	ve.ui.NodeDialog.super.prototype.initialize.call( this, data );

	// Initialization
	this.$content.addClass( 've-ui-nodeDialog' );
};

/**
 * @inheritdoc
 */
ve.ui.NodeDialog.prototype.getSetupProcess = function ( data ) {
	return ve.ui.NodeDialog.super.prototype.getSetupProcess.call( this, data )
		.next( function () {
			this.selectedNode = this.getSelectedNode( data );
		}, this );
};

/**
 * @inheritdoc
 */
ve.ui.NodeDialog.prototype.getTeardownProcess = function ( data ) {
	return ve.ui.NodeDialog.super.prototype.getTeardownProcess.call( this, data )
		.first( function () {
			this.selectedNode = null;
		}, this );
};

/*!
 * VisualEditor UserInterface ToolbarDialog class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Toolbar dialog.
 *
 * @class
 * @abstract
 * @extends OO.ui.Dialog
 *
 * @constructor
 * @param {ve.ui.Surface} surface
 * @param {Object} [config] Configuration options
 */
ve.ui.ToolbarDialog = function VeUiToolbarDialog( config ) {
	// Parent constructor
	ve.ui.ToolbarDialog.super.call( this, config );

	// Properties
	this.disabled = false;
	this.$shield = this.$( '<div>' ).addClass( 've-ui-toolbarDialog-shield' );

	// Pre-initialization
	// This class needs to exist before setup to constrain the height
	// of the dialog when it first loads.
	this.$element.addClass( 've-ui-toolbarDialog' );
};

/* Inheritance */

OO.inheritClass( ve.ui.ToolbarDialog, OO.ui.Dialog );

/* Static Properties */

ve.ui.ToolbarDialog.static.size = 'full';

ve.ui.ToolbarDialog.static.activeSurface = true;

ve.ui.ToolbarDialog.static.padded = true;

/* Methods */

/**
 * @inheritdoc
 */
ve.ui.ToolbarDialog.prototype.initialize = function () {
	// Parent method
	ve.ui.ToolbarDialog.super.prototype.initialize.call( this );

	this.$body.append( this.$shield );
	this.$content.addClass( 've-ui-toolbarDialog-content' );
	if ( this.constructor.static.padded ) {
		this.$element.addClass( 've-ui-toolbarDialog-padded' );
	}
};

/**
 * Set the disabled state of the toolbar dialog
 *
 * @param {boolean} disabled Disable the dialog
 */
ve.ui.ToolbarDialog.prototype.setDisabled = function ( disabled ) {
	this.$content.addClass( 've-ui-toolbarDialog-content' );
	if ( disabled !== this.disabled ) {
		this.disabled = disabled;
		this.$body
			// Make sure sheild is last child
			.append( this.$shield )
			.toggleClass( 've-ui-toolbarDialog-disabled', this.disabled );
	}
};

/*!
 * VisualEditor UserInterface CommandHelpDialog class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Dialog for listing all command keyboard shortcuts.
 *
 * @class
 * @extends OO.ui.ProcessDialog
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
ve.ui.CommandHelpDialog = function VeUiCommandHelpDialog( config ) {
	// Parent constructor
	ve.ui.CommandHelpDialog.super.call( this, config );
};

/* Inheritance */

OO.inheritClass( ve.ui.CommandHelpDialog, OO.ui.ProcessDialog );

/* Static Properties */

ve.ui.CommandHelpDialog.static.name = 'commandHelp';

ve.ui.CommandHelpDialog.static.size = 'large';

ve.ui.CommandHelpDialog.static.title =
	OO.ui.deferMsg( 'visualeditor-dialog-command-help-title' );

ve.ui.CommandHelpDialog.static.actions = [
	{
		label: OO.ui.deferMsg( 'visualeditor-dialog-action-done' ),
		flags: 'safe'
	}
];

/* Methods */

/**
 * @inheritdoc
 */
ve.ui.CommandHelpDialog.prototype.getBodyHeight = function () {
	return Math.round( this.contentLayout.$element[0].scrollHeight );
};

/**
 * @inheritdoc
 */
ve.ui.CommandHelpDialog.prototype.initialize = function () {
	// Parent method
	ve.ui.CommandHelpDialog.super.prototype.initialize.call( this );

	var i, j, jLen, k, kLen, triggerList, commands, shortcut,
		platform = ve.getSystemPlatform(),
		platformKey = platform === 'mac' ? 'mac' : 'pc',
		$list, $shortcut,
		commandGroups = this.constructor.static.getCommandGroups();

	this.contentLayout = new OO.ui.PanelLayout( {
		$: this.$,
		scrollable: true,
		padded: true,
		expanded: false
	} );
	this.$container = this.$( '<div>' ).addClass( 've-ui-commandHelpDialog-container' );

	for ( i in commandGroups ) {
		commands = commandGroups[i].commands;
		$list = this.$( '<dl>' ).addClass( 've-ui-commandHelpDialog-list' );
		for ( j = 0, jLen = commands.length; j < jLen; j++ ) {
			if ( commands[j].trigger ) {
				triggerList = ve.ui.triggerRegistry.lookup( commands[j].trigger );
			} else {
				triggerList = [];
				for ( k = 0, kLen = commands[j].shortcuts.length; k < kLen; k++ ) {
					shortcut = commands[j].shortcuts[k];
					triggerList.push(
						new ve.ui.Trigger(
							ve.isPlainObject( shortcut ) ? shortcut[platformKey] : shortcut,
							true
						)
					);
				}
			}
			$shortcut = this.$( '<dt>' );
			for ( k = 0, kLen = triggerList.length; k < kLen; k++ ) {
				$shortcut.append( this.$( '<kbd>' ).text(
					triggerList[k].getMessage().replace( /\+/g, ' + ' )
				) );
			}
			$list.append(
				$shortcut,
				this.$( '<dd>' ).text( ve.msg( commands[j].msg ) )
			);
		}
		this.$container.append(
			this.$( '<div>' )
				.addClass( 've-ui-commandHelpDialog-section' )
				.append(
					this.$( '<h3>' ).text( ve.msg( commandGroups[i].title ) ),
					$list
				)
		);
	}

	this.contentLayout.$element.append( this.$container );
	this.$body.append( this.contentLayout.$element );
};

/* Static methods */

/**
 * Get the list of commands, grouped by type
 *
 * @static
 * @returns {Object} Object containing command groups, consist of a title message and array of commands
 */
ve.ui.CommandHelpDialog.static.getCommandGroups = function () {
	return {
		textStyle: {
			title: 'visualeditor-shortcuts-text-style',
			commands: [
				{ trigger: 'bold', msg: 'visualeditor-annotationbutton-bold-tooltip' },
				{ trigger: 'italic', msg: 'visualeditor-annotationbutton-italic-tooltip' },
				{ trigger: 'link', msg: 'visualeditor-annotationbutton-link-tooltip' },
				{ trigger: 'superscript', msg: 'visualeditor-annotationbutton-superscript-tooltip' },
				{ trigger: 'subscript', msg: 'visualeditor-annotationbutton-subscript-tooltip' },
				{ trigger: 'underline', msg: 'visualeditor-annotationbutton-underline-tooltip' },
				{ trigger: 'code', msg: 'visualeditor-annotationbutton-code-tooltip' },
				{ trigger: 'strikethrough', msg: 'visualeditor-annotationbutton-strikethrough-tooltip' },
				{ trigger: 'clear', msg: 'visualeditor-clearbutton-tooltip' }
			]
		},
		clipboard: {
			title: 'visualeditor-shortcuts-clipboard',
			commands: [
				{
					shortcuts: [ {
						mac: 'cmd+x',
						pc: 'ctrl+x'
					} ],
					msg: 'visualeditor-clipboard-cut'
				},
				{
					shortcuts: [ {
						mac: 'cmd+c',
						pc: 'ctrl+c'
					} ],
					msg: 'visualeditor-clipboard-copy'
				},
				{
					shortcuts: [ {
						mac: 'cmd+v',
						pc: 'ctrl+v'
					} ],
					msg: 'visualeditor-clipboard-paste'
				},
				{ trigger: 'pasteSpecial', msg: 'visualeditor-clipboard-paste-special' }
			]
		},
		formatting: {
			title: 'visualeditor-shortcuts-formatting',
			commands: [
				{ trigger: 'paragraph', msg: 'visualeditor-formatdropdown-format-paragraph' },
				{ shortcuts: ['ctrl+(1-6)'], msg: 'visualeditor-formatdropdown-format-heading-label' },
				{ trigger: 'preformatted', msg: 'visualeditor-formatdropdown-format-preformatted' },
				{ trigger: 'blockquote', msg: 'visualeditor-formatdropdown-format-blockquote' },
				{ trigger: 'indent', msg: 'visualeditor-indentationbutton-indent-tooltip' },
				{ trigger: 'outdent', msg: 'visualeditor-indentationbutton-outdent-tooltip' }
			]
		},
		history: {
			title: 'visualeditor-shortcuts-history',
			commands: [
				{ trigger: 'undo', msg: 'visualeditor-historybutton-undo-tooltip' },
				{ trigger: 'redo', msg: 'visualeditor-historybutton-redo-tooltip' }
			]
		},
		other: {
			title: 'visualeditor-shortcuts-other',
			commands: [
				{ trigger: 'findAndReplace', msg: 'visualeditor-find-and-replace-title' },
				{ trigger: 'findNext', msg: 'visualeditor-find-and-replace-next-button' },
				{ trigger: 'findPrevious', msg: 'visualeditor-find-and-replace-previous-button' },
				{ trigger: 'selectAll', msg: 'visualeditor-content-select-all' },
				{ trigger: 'commandHelp', msg: 'visualeditor-dialog-command-help-title' }
			]
		}
	};
};

/* Registration */

ve.ui.windowFactory.register( ve.ui.CommandHelpDialog );

/*!
 * VisualEditor UserInterface FindAndReplaceDialog class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Find and replace dialog.
 *
 * @class
 * @extends ve.ui.ToolbarDialog
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
ve.ui.FindAndReplaceDialog = function VeUiFindAndReplaceDialog( config ) {
	// Parent constructor
	ve.ui.FindAndReplaceDialog.super.call( this, config );

	// Properties
	this.surface = null;
	this.invalidRegex = false;

	// Pre-initialization
	this.$element.addClass( 've-ui-findAndReplaceDialog' );
};

/* Inheritance */

OO.inheritClass( ve.ui.FindAndReplaceDialog, ve.ui.ToolbarDialog );

ve.ui.FindAndReplaceDialog.static.name = 'findAndReplace';

ve.ui.FindAndReplaceDialog.static.title = OO.ui.deferMsg( 'visualeditor-find-and-replace-title' );

/**
 * Maximum number of results to render
 *
 * @property {number}
 */
ve.ui.FindAndReplaceDialog.static.maxRenderedResults = 100;

/* Methods */

/**
 * @inheritdoc
 */
ve.ui.FindAndReplaceDialog.prototype.initialize = function () {
	// Parent method
	ve.ui.FindAndReplaceDialog.super.prototype.initialize.call( this );

	this.$findResults = this.$( '<div>' ).addClass( 've-ui-findAndReplaceDialog-findResults' );
	this.fragments = [];
	this.results = 0;
	// Range over the list of fragments indicating which ones where rendered,
	// e.g. [1,3] means fragments 1 & 2 were rendered
	this.renderedFragments = null;
	this.replacing = false;
	this.focusedIndex = 0;
	this.query = null;
	this.findText = new OO.ui.TextInputWidget( {
		$: this.$,
		placeholder: ve.msg( 'visualeditor-find-and-replace-find-text' )
	} );
	this.matchCaseToggle = new OO.ui.ToggleButtonWidget( {
		$: this.$,
		icon: 'case-sensitive',
		iconTitle: ve.msg( 'visualeditor-find-and-replace-match-case' )
	} );
	this.regexToggle = new OO.ui.ToggleButtonWidget( {
		$: this.$,
		icon: 'regular-expression',
		iconTitle: ve.msg( 'visualeditor-find-and-replace-regular-expression' )
	} );

	this.previousButton = new OO.ui.ButtonWidget( {
		$: this.$,
		icon: 'previous',
		iconTitle: ve.msg( 'visualeditor-find-and-replace-previous-button' ) + ' ' +
			ve.ui.triggerRegistry.getMessages( 'findPrevious' ).join( ', ' )
	} );
	this.nextButton = new OO.ui.ButtonWidget( {
		$: this.$,
		icon: 'next',
		iconTitle: ve.msg( 'visualeditor-find-and-replace-next-button' ) + ' ' +
			ve.ui.triggerRegistry.getMessages( 'findNext' ).join( ', ' )
	} );
	this.replaceText = new OO.ui.TextInputWidget( {
		$: this.$,
		placeholder: ve.msg( 'visualeditor-find-and-replace-replace-text' )
	} );
	this.replaceButton = new OO.ui.ButtonWidget( {
		$: this.$,
		label: ve.msg( 'visualeditor-find-and-replace-replace-button' )
	} );
	this.replaceAllButton = new OO.ui.ButtonWidget( {
		$: this.$,
		label: ve.msg( 'visualeditor-find-and-replace-replace-all-button' )
	} );

	var optionsGroup = new OO.ui.ButtonGroupWidget( {
			$: this.$,
			classes: ['ve-ui-findAndReplaceDialog-cell'],
			items: [
				this.matchCaseToggle,
				this.regexToggle
			]
		} ),
		navigateGroup = new OO.ui.ButtonGroupWidget( {
			$: this.$,
			classes: ['ve-ui-findAndReplaceDialog-cell'],
			items: [
				this.previousButton,
				this.nextButton
			]
		} ),
		replaceGroup = new OO.ui.ButtonGroupWidget( {
			$: this.$,
			classes: ['ve-ui-findAndReplaceDialog-cell'],
			items: [
				this.replaceButton,
				this.replaceAllButton
			]
		} ),
		doneButton = new OO.ui.ButtonWidget( {
			$: this.$,
			classes: ['ve-ui-findAndReplaceDialog-cell'],
			label: ve.msg( 'visualeditor-find-and-replace-done' )
		} ),
		$findRow = this.$( '<div>' ).addClass( 've-ui-findAndReplaceDialog-row' ),
		$replaceRow = this.$( '<div>' ).addClass( 've-ui-findAndReplaceDialog-row' );

	// Events
	this.onWindowScrollDebounced = ve.debounce( this.onWindowScroll.bind( this ), 250 );
	this.updateFragmentsDebounced = ve.debounce( this.updateFragments.bind( this ) );
	this.renderFragmentsDebounced = ve.debounce( this.renderFragments.bind( this ) );
	this.findText.connect( this, {
		change: 'onFindChange',
		enter: 'onFindTextEnter'
	} );
	this.matchCaseToggle.connect( this, { change: 'onFindChange' } );
	this.regexToggle.connect( this, { change: 'onFindChange' } );
	this.nextButton.connect( this, { click: 'findNext' } );
	this.previousButton.connect( this, { click: 'findPrevious' } );
	this.replaceButton.connect( this, { click: 'onReplaceButtonClick' } );
	this.replaceAllButton.connect( this, { click: 'onReplaceAllButtonClick' } );
	doneButton.connect( this, { click: 'close' } );

	// Initialization
	this.findText.$input.prop( 'tabIndex', 1 );
	this.replaceText.$input.prop( 'tabIndex', 2 );
	this.$content.addClass( 've-ui-findAndReplaceDialog-content' );
	this.$body
		.append(
			$findRow.append(
				this.$( '<div>' ).addClass( 've-ui-findAndReplaceDialog-cell ve-ui-findAndReplaceDialog-cell-input' ).append(
					this.findText.$element
				),
				navigateGroup.$element,
				optionsGroup.$element
			),
			$replaceRow.append(
				this.$( '<div>' ).addClass( 've-ui-findAndReplaceDialog-cell ve-ui-findAndReplaceDialog-cell-input' ).append(
					this.replaceText.$element
				),
				replaceGroup.$element,
				doneButton.$element
			)
		);
};

/**
 * @inheritdoc
 */
ve.ui.FindAndReplaceDialog.prototype.getSetupProcess = function ( data ) {
	data = data || {};
	return ve.ui.FindAndReplaceDialog.super.prototype.getSetupProcess.call( this, data )
		.first( function () {
			this.surface = data.surface;
			this.surface.$selections.append( this.$findResults );

			// Events
			this.surface.getModel().connect( this, { documentUpdate: this.updateFragmentsDebounced } );
			this.surface.getView().connect( this, { position: this.renderFragmentsDebounced } );
			this.surface.getView().$window.on( 'scroll', this.onWindowScrollDebounced );

			var text = data.fragment.getText();
			if ( text && text !== this.findText.getValue() ) {
				this.findText.setValue( text );
			} else {
				this.onFindChange();
			}
		}, this );
};

/**
 * @inheritdoc
 */
ve.ui.FindAndReplaceDialog.prototype.getReadyProcess = function ( data ) {
	return ve.ui.FindAndReplaceDialog.super.prototype.getReadyProcess.call( this, data )
		.next( function () {
			this.findText.focus().select();
		}, this );
};

/**
 * @inheritdoc
 */
ve.ui.FindAndReplaceDialog.prototype.getTeardownProcess = function ( data ) {
	return ve.ui.FindAndReplaceDialog.super.prototype.getTeardownProcess.call( this, data )
		.next( function () {
			var surfaceView = this.surface.getView();

			// Events
			this.surface.getModel().disconnect( this );
			surfaceView.disconnect( this );
			this.surface.getView().$window.off( 'scroll', this.onWindowScrollDebounced );

			surfaceView.focus();
			this.$findResults.empty().detach();
			this.fragments = [];
			this.surface = null;
		}, this );
};

/**
 * Handle window scroll events
 */
ve.ui.FindAndReplaceDialog.prototype.onWindowScroll = function () {
	if ( this.renderedFragments.getLength() < this.results ) {
		// If viewport clipping is being used, reposition results based on the current viewport
		this.renderFragments();
	}
};

/**
 * Handle change events to the find inputs (text or match case)
 */
ve.ui.FindAndReplaceDialog.prototype.onFindChange = function () {
	this.updateFragments();
	this.renderFragments();
	this.highlightFocused( true );
};

/**
 * Handle enter events on the find text input
 *
 * @param {jQuery.Event} e
 */
ve.ui.FindAndReplaceDialog.prototype.onFindTextEnter = function ( e ) {
	if ( !this.results ) {
		return;
	}
	if ( e.shiftKey ) {
		this.findPrevious();
	} else {
		this.findNext();
	}
};

/**
 * Update search result fragments
 */
ve.ui.FindAndReplaceDialog.prototype.updateFragments = function () {
	var i, l,
		surfaceModel = this.surface.getModel(),
		documentModel = surfaceModel.getDocument(),
		ranges = [],
		matchCase = this.matchCaseToggle.getValue(),
		isRegex = this.regexToggle.getValue(),
		find = this.findText.getValue();

	this.invalidRegex = false;

	if ( isRegex && find ) {
		try {
			this.query = new RegExp( find );
		} catch ( e ) {
			this.invalidRegex = true;
		}
	} else {
		this.query = find;
	}
	this.findText.$element.toggleClass( 've-ui-findAndReplaceDialog-findText-error', this.invalidRegex );

	this.fragments = [];
	if ( this.query ) {
		ranges = documentModel.findText( this.query, matchCase, true );
		for ( i = 0, l = ranges.length; i < l; i++ ) {
			this.fragments.push( surfaceModel.getLinearFragment( ranges[i], true, true ) );
		}
	}
	this.results = this.fragments.length;
	this.focusedIndex = Math.min( this.focusedIndex, this.results ? this.results - 1 : 0 );
	this.nextButton.setDisabled( !this.results );
	this.previousButton.setDisabled( !this.results );
	this.replaceButton.setDisabled( !this.results );
	this.replaceAllButton.setDisabled( !this.results );
};

/**
 * Position results markers
 */
ve.ui.FindAndReplaceDialog.prototype.renderFragments = function () {
	if ( this.replacing ) {
		return;
	}

	var i, selection, viewportRange,
		start = 0,
		end = this.results;

	// When there are a large number of results, calculate the viewport range for clipping
	if ( this.results > 50 ) {
		viewportRange = this.surface.getView().getViewportRange();
		for ( i = 0; i < this.results; i++ ) {
			selection = this.fragments[i].getSelection();
			if ( viewportRange && selection.getRange().start < viewportRange.start ) {
				start = i + 1;
				continue;
			}
			if ( viewportRange && selection.getRange().end > viewportRange.end ) {
				end = i;
				break;
			}
		}
	}

	// When there are too many results to render, just render the current one
	if ( end - start <= this.constructor.static.maxRenderedResults ) {
		this.renderRangeOfFragments( new ve.Range( start, end ) );
	} else {
		this.renderRangeOfFragments( new ve.Range( this.focusedIndex, this.focusedIndex + 1 ) );
	}
};

/**
 * Render subset of search result fragments
 *
 * @param {ve.Range} range Range of fragments to render
 */
ve.ui.FindAndReplaceDialog.prototype.renderRangeOfFragments = function ( range ) {
	var i, j, jlen, rects, $result, top;
	this.$findResults.empty();
	for ( i = range.start; i < range.end; i++ ) {
		rects = this.surface.getView().getSelectionRects( this.fragments[i].getSelection() );
		$result = this.$( '<div>' ).addClass( 've-ui-findAndReplaceDialog-findResult' );
		top = Infinity;
		for ( j = 0, jlen = rects.length; j < jlen; j++ ) {
			top = Math.min( top, rects[j].top );
			$result.append( this.$( '<div>' ).css( {
				top: rects[j].top,
				left: rects[j].left,
				width: rects[j].width,
				height: rects[j].height
			} ) );
		}
		$result.data( 'top', top );
		this.$findResults.append( $result );
	}
	this.renderedFragments = range;
	this.highlightFocused();
};

/**
 * Highlight the focused result marker
 *
 * @param {boolean} scrollIntoView Scroll the marker into view
 */
ve.ui.FindAndReplaceDialog.prototype.highlightFocused = function ( scrollIntoView ) {
	var $result, rect, top,
		offset, windowScrollTop, windowScrollHeight,
		surfaceView = this.surface.getView();

	if ( this.results ) {
		this.findText.setLabel(
			ve.msg( 'visualeditor-find-and-replace-results', this.focusedIndex + 1, this.results )
		);
	} else {
		this.findText.setLabel(
			this.invalidRegex ? ve.msg( 'visualeditor-find-and-replace-invalid-regex' ) : ''
		);
		return;
	}

	this.$findResults
		.find( '.ve-ui-findAndReplaceDialog-findResult-focused' )
		.removeClass( 've-ui-findAndReplaceDialog-findResult-focused' );

	if ( this.renderedFragments.containsOffset( this.focusedIndex ) ) {
		$result = this.$findResults.children().eq( this.focusedIndex - this.renderedFragments.start )
			.addClass( 've-ui-findAndReplaceDialog-findResult-focused' );

		top = $result.data( 'top' );
	} else {
		// Focused result hasn't been rendered yet so find its offset manually
		rect = surfaceView.getSelectionBoundingRect( this.fragments[this.focusedIndex].getSelection() );
		top = rect.top;
		this.renderRangeOfFragments( new ve.Range( this.focusedIndex, this.focusedIndex + 1 ) );
	}

	if ( scrollIntoView ) {
		surfaceView = this.surface.getView();
		offset = top + surfaceView.$element.offset().top;
		windowScrollTop = surfaceView.$window.scrollTop() + this.surface.toolbarHeight;
		windowScrollHeight = surfaceView.$window.height() - this.surface.toolbarHeight;

		if ( offset < windowScrollTop || offset > windowScrollTop + windowScrollHeight ) {
			surfaceView.$( 'body, html' ).animate( { scrollTop: offset - ( windowScrollHeight / 2  ) }, 'fast' );
		}
	}
};

/**
 * Find the next result
 */
ve.ui.FindAndReplaceDialog.prototype.findNext = function () {
	this.focusedIndex = ( this.focusedIndex + 1 ) % this.results;
	this.highlightFocused( true );
};

/**
 * Find the previous result
 */
ve.ui.FindAndReplaceDialog.prototype.findPrevious = function () {
	this.focusedIndex = ( this.focusedIndex + this.results - 1 ) % this.results;
	this.highlightFocused( true );
};

/**
 * Handle click events on the replace button
 */
ve.ui.FindAndReplaceDialog.prototype.onReplaceButtonClick = function () {
	var end;

	if ( !this.results ) {
		return;
	}

	this.replace( this.focusedIndex );

	// Find the next fragment after this one ends. Ensures that if we replace
	// 'foo' with 'foofoo' we don't select the just-inserted text.
	end = this.fragments[this.focusedIndex].getSelection().getRange().end;
	// updateFragmentsDebounced is triggered by insertContent, but call it immediately
	// so we can find the next fragment to select.
	this.updateFragments();
	if ( !this.results ) {
		this.focusedIndex = 0;
		return;
	}
	while ( this.fragments[this.focusedIndex] && this.fragments[this.focusedIndex].getSelection().getRange().end <= end ) {
		this.focusedIndex++;
	}
	// We may have iterated off the end
	this.focusedIndex = this.focusedIndex % this.results;
};

/**
 * Handle click events on the previous all button
 */
ve.ui.FindAndReplaceDialog.prototype.onReplaceAllButtonClick = function () {
	var i, l;

	for ( i = 0, l = this.results; i < l; i++ ) {
		this.replace( i );
	}
};

/**
 * Replace the result at a specified index
 *
 * @param {number} index Index to replace
 */
ve.ui.FindAndReplaceDialog.prototype.replace = function ( index ) {
	var replace = this.replaceText.getValue();

	if ( this.query instanceof RegExp ) {
		this.fragments[index].insertContent(
			this.fragments[index].getText().replace( this.query, replace ),
			true
		);
	} else {
		this.fragments[index].insertContent( replace, true );
	}
};

/**
 * @inheritdoc
 */
ve.ui.FindAndReplaceDialog.prototype.getActionProcess = function ( action ) {
	if ( action === 'findNext' || action === 'findPrevious' ) {
		return new OO.ui.Process( this[action], this );
	}
	return ve.ui.FindAndReplaceDialog.super.prototype.getActionProcess.call( this, action );
};

/* Registration */

ve.ui.windowFactory.register( ve.ui.FindAndReplaceDialog );

/*!
 * VisualEditor UserInterface ProgressDialog class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Dialog for showing operations in progress.
 *
 * @class
 * @extends OO.ui.MessageDialog
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
ve.ui.ProgressDialog = function VeUiProgressDialog( config ) {
	// Parent constructor
	ve.ui.ProgressDialog.super.call( this, config );
};

/* Inheritance */

OO.inheritClass( ve.ui.ProgressDialog, OO.ui.MessageDialog );

/* Static Properties */

ve.ui.ProgressDialog.static.name = 'progress';

ve.ui.ProgressDialog.static.size = 'medium';

ve.ui.ProgressDialog.static.actions = [
	{
		action: 'cancel',
		label: OO.ui.deferMsg( 'visualeditor-dialog-action-cancel' ),
		flags: 'destructive'
	}
];

/* Methods */

/**
 * @inheritdoc
 */
ve.ui.ProgressDialog.prototype.initialize = function () {
	// Parent method
	ve.ui.ProgressDialog.super.prototype.initialize.call( this );

	// Properties
	this.inProgress = 0;
	this.cancelDeferreds = [];
};

/**
 * @inheritdoc
 */
ve.ui.ProgressDialog.prototype.getSetupProcess = function ( data ) {
	data = data || {};

	// Parent method
	return ve.ui.ProgressDialog.super.prototype.getSetupProcess.call( this, data )
		.next( function () {
			var i, l, $row, progressBar, fieldLayout, cancelButton, cancelDeferred,
				progresses = data.progresses;

			this.inProgress = progresses.length;
			this.text.$element.empty();
			this.cancelDeferreds = [];

			for ( i = 0, l = progresses.length; i < l; i++ ) {
				cancelDeferred = $.Deferred();
				$row = this.$( '<div>' ).addClass( 've-ui-progressDialog-row' );
				progressBar = new OO.ui.ProgressBarWidget( { $: this.$ } );
				fieldLayout = new OO.ui.FieldLayout(
					progressBar,
					{
						$: this.$,
						label: progresses[i].label,
						align: 'top'
					}
				);
				cancelButton = new OO.ui.ButtonWidget( {
					$: this.$,
					framed: false,
					icon: 'clear',
					iconTitle: OO.ui.deferMsg( 'visualeditor-dialog-action-cancel' )
				} ).on( 'click', cancelDeferred.reject.bind( cancelDeferred ) );

				this.text.$element.append(
					$row.append(
						fieldLayout.$element, cancelButton.$element
					)
				);
				progresses[i].progressBarDeferred.resolve( progressBar, cancelDeferred.promise() );
				/*jshint loopfunc:true */
				progresses[i].progressCompletePromise.then(
					this.progressComplete.bind( this, $row, false ),
					this.progressComplete.bind( this, $row, true )
				);
				this.cancelDeferreds.push( cancelDeferred );
			}
		}, this );
};

/**
 * @inheritdoc
 */
ve.ui.ProgressDialog.prototype.getActionProcess = function ( action ) {
	return new OO.ui.Process( function () {
		var i, l;
		if ( action === 'cancel' ) {
			for ( i = 0, l = this.cancelDeferreds.length; i < l; i++ ) {
				this.cancelDeferreds[i].reject();
			}
		}
		this.close( { action: action } );
	}, this );
};

/**
 * Progress has completed for an item
 *
 * @param {jQuery} $row Row containing progress bar which has completed
 * @param {boolean} failed The item failed
 */
ve.ui.ProgressDialog.prototype.progressComplete = function ( $row, failed ) {
	this.inProgress--;
	if ( !this.inProgress ) {
		this.close();
	}
	if ( failed ) {
		$row.remove();
		this.updateSize();
	}
};

/* Static methods */

/* Registration */

ve.ui.windowFactory.register( ve.ui.ProgressDialog );

/*!
 * VisualEditor UserInterface SpecialCharacterDialog class.
 *
 * @copyright 2011-2014 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Inspector for inserting special characters.
 *
 * @class
 * @extends ve.ui.ToolbarDialog
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
ve.ui.SpecialCharacterDialog = function VeUiSpecialCharacterDialog( config ) {
	// Parent constructor
	ve.ui.ToolbarDialog.call( this, config );

	this.characters = null;
	this.$buttonDomList = null;
	this.categories = null;

	this.$element.addClass( 've-ui-specialCharacterDialog' );
};

/* Inheritance */

OO.inheritClass( ve.ui.SpecialCharacterDialog, ve.ui.ToolbarDialog );

/* Static properties */

ve.ui.SpecialCharacterDialog.static.name = 'specialCharacter';

ve.ui.SpecialCharacterDialog.static.title =
	OO.ui.deferMsg( 'visualeditor-specialCharacterDialog-title' );

ve.ui.SpecialCharacterDialog.static.size = 'full';

ve.ui.SpecialCharacterDialog.static.padded = false;

/* Methods */

/**
 * @inheritdoc
 */
ve.ui.SpecialCharacterDialog.prototype.initialize = function () {
	// Parent method
	ve.ui.SpecialCharacterDialog.super.prototype.initialize.call( this );

	this.$spinner = this.$( '<div>' ).addClass( 've-ui-specialCharacterDialog-spinner' );
	this.$content.append( this.$spinner );
};

/**
 * @inheritdoc
 */
ve.ui.SpecialCharacterDialog.prototype.getSetupProcess = function ( data ) {
	return ve.ui.SpecialCharacterDialog.super.prototype.getSetupProcess.call( this, data )
		.next( function () {
			this.surface = data.surface;
			this.surface.getView().focus();
			this.surface.getModel().connect( this, { contextChange: 'onContextChange' } );

			var inspector = this;
			if ( !this.characters ) {
				this.$spinner.show();
				ve.init.platform.fetchSpecialCharList()
					.done( function ( specialChars ) {
						inspector.characters = specialChars;
						inspector.buildButtonList();
					} )
					// TODO: show error message on fetchCharList().fail
					.always( function () {
						// TODO: generalize push/pop pending, like we do in Dialog
						inspector.$spinner.hide();
					} );
			}
		}, this );
};

/**
 * @inheritdoc
 */
ve.ui.SpecialCharacterDialog.prototype.getTeardownProcess = function ( data ) {
	data = data || {};
	return ve.ui.SpecialCharacterDialog.super.prototype.getTeardownProcess.call( this, data )
		.first( function () {
			this.surface.getModel().disconnect( this );
			this.surface = null;
		}, this );
};

/**
 * @inheritdoc
 */
ve.ui.SpecialCharacterDialog.prototype.getReadyProcess = function ( data ) {
	data = data || {};
	return ve.ui.SpecialCharacterDialog.super.prototype.getReadyProcess.call( this, data )
		.first( function () {
			this.surface.getView().focus();
		}, this );
};

/**
 * @inheritdoc
 */
ve.ui.SpecialCharacterDialog.prototype.getActionProcess = function ( action ) {
	return new OO.ui.Process( function () {
		this.close( { action: action } );
	}, this );
};

/**
 * Handle context change events from the surface model
 */
ve.ui.SpecialCharacterDialog.prototype.onContextChange = function () {
	this.setDisabled( !( this.surface.getModel().getSelection() instanceof ve.dm.LinearSelection ) );
};

/**
 * Builds the button DOM list based on the character list
 */
ve.ui.SpecialCharacterDialog.prototype.buildButtonList = function () {
	var category,
		// HACK: When displaying this inside a dialog, menu would tend to be wider than content
		isInsideDialog = !!this.manager.$element.closest( '.oo-ui-dialog' ).length;

	this.bookletLayout = new OO.ui.BookletLayout( {
		$: this.$,
		outlined: true,
		menuSize: isInsideDialog ? '10em' : '18em',
		continuous: true
	} );
	this.pages = [];
	for ( category in this.characters ) {
		this.pages.push(
			new ve.ui.SpecialCharacterPage( category, {
				$: this.$,
				label: category,
				characters: this.characters[category]
			} )
		);
	}
	this.bookletLayout.addPages( this.pages );
	this.bookletLayout.$element.on(
		'click',
		'.ve-ui-specialCharacterPage-character',
		this.onListClick.bind( this )
	);

	this.$body.append( this.bookletLayout.$element );
};

/**
 * Handle the click event on the list
 */
ve.ui.SpecialCharacterDialog.prototype.onListClick = function ( e ) {
	var character = $( e.target ).data( 'character' );
	if ( character ) {
		this.surface.getModel().getFragment().insertContent( character, true ).collapseToEnd().select();
	}
};

/* Registration */

ve.ui.windowFactory.register( ve.ui.SpecialCharacterDialog );

/*!
 * VisualEditor UserInterface HTML string transfer handler class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * HTML string transfer handler.
 *
 * @class
 * @extends ve.ui.DataTransferHandler
 *
 * @constructor
 * @param {ve.ui.Surface} surface
 * @param {ve.ui.DataTransferItem} item
 */
ve.ui.HTMLStringTransferHandler = function VeUiHTMLStringTransferHandler() {
	// Parent constructor
	ve.ui.HTMLStringTransferHandler.super.apply( this, arguments );
};

/* Inheritance */

OO.inheritClass( ve.ui.HTMLStringTransferHandler, ve.ui.DataTransferHandler );

/* Static properties */

ve.ui.HTMLStringTransferHandler.static.name = 'htmlString';

ve.ui.HTMLStringTransferHandler.static.types = [ 'text/html', 'application/xhtml+xml' ];

ve.ui.HTMLStringTransferHandler.static.handlesPaste = false;

/* Methods */

/**
 * @inheritdoc
 */
ve.ui.HTMLStringTransferHandler.prototype.process = function () {
	this.insertableDataDeferred.resolve(
		this.surface.getModel().getDocument().newFromHtml( this.item.getAsString(), this.surface.getImportRules() )
	);
};

/* Registration */

ve.ui.dataTransferHandlerFactory.register( ve.ui.HTMLStringTransferHandler );

/*!
 * VisualEditor UserInterface Plain text string transfer handler class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Plain text string transfer handler.
 *
 * @class
 * @extends ve.ui.DataTransferHandler
 *
 * @constructor
 * @param {ve.ui.Surface} surface
 * @param {ve.ui.DataTransferItem} item
 */
ve.ui.PlainTextStringTransferHandler = function VeUiPlainTextStringTransferHandler() {
	// Parent constructor
	ve.ui.PlainTextStringTransferHandler.super.apply( this, arguments );
};

/* Inheritance */

OO.inheritClass( ve.ui.PlainTextStringTransferHandler, ve.ui.DataTransferHandler );

/* Static properties */

ve.ui.PlainTextStringTransferHandler.static.name = 'plainTextString';

ve.ui.PlainTextStringTransferHandler.static.types = [ 'text/plain' ];

ve.ui.PlainTextStringTransferHandler.static.handlesPaste = false;

/* Methods */

/**
 * @inheritdoc
 */
ve.ui.PlainTextStringTransferHandler.prototype.process = function () {
	this.insertableDataDeferred.resolve( this.item.getAsString() );
};

/* Registration */

ve.ui.dataTransferHandlerFactory.register( ve.ui.PlainTextStringTransferHandler );

/*!
 * VisualEditor UserInterface delimiter-separated values file transfer handler class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Delimiter-separated values file transfer handler.
 *
 * @class
 * @extends ve.ui.FileTransferHandler
 *
 * @constructor
 * @param {ve.ui.Surface} surface
 * @param {ve.ui.DataTransferItem} item
 */
ve.ui.DSVFileTransferHandler = function VeUiDSVFileTransferHandler() {
	// Parent constructor
	ve.ui.DSVFileTransferHandler.super.apply( this, arguments );
};

/* Inheritance */

OO.inheritClass( ve.ui.DSVFileTransferHandler, ve.ui.FileTransferHandler );

/* Static properties */

ve.ui.DSVFileTransferHandler.static.name = 'dsv';

ve.ui.DSVFileTransferHandler.static.types = [ 'text/csv', 'text/tab-separated-values' ];

/* Methods */

/**
 * @inheritdoc
 */
ve.ui.DSVFileTransferHandler.prototype.process = function () {
	this.createProgress( this.insertableDataDeferred.promise() );
	this.reader.readAsText( this.file );
};

/**
 * @inheritdoc
 */
ve.ui.DSVFileTransferHandler.prototype.onFileProgress = function ( e ) {
	if ( e.lengthComputable ) {
		this.setProgress( 100 * e.loaded / e.total );
	} else {
		this.setProgress( false );
	}
};

/**
 * @inheritdoc
 */
ve.ui.DSVFileTransferHandler.prototype.onFileLoad = function () {
	var i, j, line,
		data = [],
		input = Papa.parse( this.reader.result );

	if ( input.meta.aborted || ( input.data.length <= 0 ) ) {
		this.insertableDataDeffered.reject();
		return;
	}

	data.push( { type: 'table' } );
	data.push( { type: 'tableSection', attributes: { style: 'body' } } );

	for ( i = 0; i < input.data.length; i++ ) {
		data.push( { type: 'tableRow' } );
		line = input.data[i];
		for ( j = 0; j < line.length; j++ ) {
			data.push( { type: 'tableCell', attributes: { style: ( i === 0 ? 'header' : 'data' ) } } );
			data.push( { type: 'paragraph', internal: { generated: 'wrapper' } } );
			data = data.concat( line[j].split( '' ) );
			data.push( { type: '/paragraph' } );
			data.push( { type: '/tableCell' } );
		}
		data.push( { type: '/tableRow' } );
	}

	data.push( { type: '/tableSection' } );
	data.push( { type: '/table' } );

	this.insertableDataDeferred.resolve( data );
	this.setProgress( 100 );
};

/**
 * @inheritdoc
 */
ve.ui.DSVFileTransferHandler.prototype.onFileLoadEnd = function () {
	// 'loadend' fires after 'load'/'abort'/'error'.
	// Reject the deferred if it hasn't already resolved.
	this.insertableDataDeferred.reject();
};

/**
 * @inheritdoc
 */
ve.ui.DSVFileTransferHandler.prototype.abort = function () {
	// Parent method
	ve.ui.DSVFileTransferHandler.super.prototype.abort.call( this );

	this.reader.abort();
};

/* Registration */

ve.ui.dataTransferHandlerFactory.register( ve.ui.DSVFileTransferHandler );

/*!
 * VisualEditor UserInterface plain text file transfer handler class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Plain text file transfer handler.
 *
 * @class
 * @extends ve.ui.FileTransferHandler
 *
 * @constructor
 * @param {ve.ui.Surface} surface
 * @param {ve.ui.DataTransferItem} item
 */
ve.ui.PlainTextFileTransferHandler = function VeUiPlainTextFileTransferHandler() {
	// Parent constructor
	ve.ui.PlainTextFileTransferHandler.super.apply( this, arguments );
};

/* Inheritance */

OO.inheritClass( ve.ui.PlainTextFileTransferHandler, ve.ui.FileTransferHandler );

/* Static properties */

ve.ui.PlainTextFileTransferHandler.static.name = 'plainTextFile';

ve.ui.PlainTextFileTransferHandler.static.types = ['text/plain'];

/* Methods */

/**
 * @inheritdoc
 */
ve.ui.PlainTextFileTransferHandler.prototype.process = function () {
	this.createProgress( this.insertableDataDeferred.promise() );
	this.reader.readAsText( this.file );
};

/**
 * @inheritdoc
 */
ve.ui.PlainTextFileTransferHandler.prototype.onFileProgress = function ( e ) {
	if ( e.lengthComputable ) {
		this.setProgress( 100 * e.loaded / e.total );
	} else {
		this.setProgress( false );
	}
};

/**
 * @inheritdoc
 */
ve.ui.PlainTextFileTransferHandler.prototype.onFileLoad = function () {
	this.insertableDataDeferred.resolve( this.reader.result );
	this.setProgress( 100 );
};

/**
 * @inheritdoc
 */
ve.ui.PlainTextFileTransferHandler.prototype.onFileLoadEnd = function () {
	// 'loadend' fires after 'load'/'abort'/'error'.
	// Reject the deferred if it hasn't already resolved.
	this.insertableDataDeferred.reject();
};

/**
 * @inheritdoc
 */
ve.ui.PlainTextFileTransferHandler.prototype.abort = function () {
	// Parent method
	ve.ui.PlainTextFileTransferHandler.super.prototype.abort.call( this );

	this.reader.abort();
};

/* Registration */

ve.ui.dataTransferHandlerFactory.register( ve.ui.PlainTextFileTransferHandler );

/*!
 * VisualEditor UserInterface HTML file transfer handler class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * HTML file transfer handler.
 *
 * @class
 * @extends ve.ui.FileTransferHandler
 *
 * @constructor
 * @param {ve.ui.Surface} surface
 * @param {ve.ui.DataTransferItem} item
 */
ve.ui.HTMLFileTransferHandler = function VeUiHTMLFileTransferHandler() {
	// Parent constructor
	ve.ui.HTMLFileTransferHandler.super.apply( this, arguments );
};

/* Inheritance */

OO.inheritClass( ve.ui.HTMLFileTransferHandler, ve.ui.FileTransferHandler );

/* Static properties */

ve.ui.HTMLFileTransferHandler.static.name = 'htmlFile';

ve.ui.HTMLFileTransferHandler.static.types = [ 'text/html', 'application/xhtml+xml' ];

/* Methods */

/**
 * @inheritdoc
 */
ve.ui.HTMLFileTransferHandler.prototype.process = function () {
	this.createProgress( this.insertableDataDeferred.promise() );
	this.reader.readAsText( this.file );
};

/**
 * @inheritdoc
 */
ve.ui.HTMLFileTransferHandler.prototype.onFileProgress = function ( e ) {
	if ( e.lengthComputable ) {
		this.setProgress( 100 * e.loaded / e.total );
	} else {
		this.setProgress( false );
	}
};

/**
 * @inheritdoc
 */
ve.ui.HTMLFileTransferHandler.prototype.onFileLoad = function () {
	this.insertableDataDeferred.resolve(
		this.surface.getModel().getDocument().newFromHtml( this.reader.result, this.surface.getImportRules() )
	);
	this.setProgress( 100 );
};

/**
 * @inheritdoc
 */
ve.ui.HTMLFileTransferHandler.prototype.onFileLoadEnd = function () {
	// 'loadend' fires after 'load'/'abort'/'error'.
	// Reject the deferred if it hasn't already resolved.
	this.insertableDataDeferred.reject();
};

/**
 * @inheritdoc
 */
ve.ui.HTMLFileTransferHandler.prototype.abort = function () {
	// Parent method
	ve.ui.HTMLFileTransferHandler.super.prototype.abort.call( this );

	this.reader.abort();
};

/* Registration */

ve.ui.dataTransferHandlerFactory.register( ve.ui.HTMLFileTransferHandler );

/*!
 * VisualEditor UserInterface ToolbarDialogWindowManager class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Window manager for toolbar dialogs.
 *
 * @class
 * @extends ve.ui.SurfaceWindowManager
 *
 * @constructor
 * @param {ve.ui.Surface} Surface this belongs to
 * @param {Object} [config] Configuration options
 * @cfg {ve.ui.Overlay} [overlay] Overlay to use for menus
 */
ve.ui.ToolbarDialogWindowManager = function VeUiToolbarDialogWindowManager( surface, config ) {
	// Parent constructor
	ve.ui.ToolbarDialogWindowManager.super.call( this, surface, config );
};

/* Inheritance */

OO.inheritClass( ve.ui.ToolbarDialogWindowManager, ve.ui.SurfaceWindowManager );

/* Static Properties */

ve.ui.ToolbarDialogWindowManager.static.sizes = ve.copy(
	ve.ui.ToolbarDialogWindowManager.super.static.sizes
);
ve.ui.ToolbarDialogWindowManager.static.sizes.full = {
	width: '100%',
	maxHeight: '100%'
};

/* Methods */

/**
 * @inheritdoc
 */
ve.ui.ToolbarDialogWindowManager.prototype.getTeardownDelay = function () {
	return 250;
};

/*!
 * VisualEditor UserInterface AlignWidget class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Widget that lets the user edit alignment of an object
 *
 * @class
 * @extends OO.ui.ButtonSelectWidget
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {string} [dir='ltr'] Interface directionality
 */
ve.ui.AlignWidget = function VeUiAlignWidget( config ) {
	config = config || {};

	// Parent constructor
	ve.ui.AlignWidget.super.call( this, config );

	var alignButtons = [
			new OO.ui.ButtonOptionWidget( {
				$: this.$,
				data: 'left',
				icon: 'align-float-left',
				label: ve.msg( 'visualeditor-align-widget-left' )
			} ),
			new OO.ui.ButtonOptionWidget( {
				$: this.$,
				data: 'center',
				icon: 'align-center',
				label: ve.msg( 'visualeditor-align-widget-center' )
			} ),
			new OO.ui.ButtonOptionWidget( {
				$: this.$,
				data: 'right',
				icon: 'align-float-right',
				label: ve.msg( 'visualeditor-align-widget-right' )
			} )
		];

	if ( config.dir === 'rtl' ) {
		alignButtons = alignButtons.reverse();
	}

	this.addItems( alignButtons, 0 );

};

/* Inheritance */

OO.inheritClass( ve.ui.AlignWidget, OO.ui.ButtonSelectWidget );

/*!
 * VisualEditor UserInterface LanguageSearchWidget class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Creates an ve.ui.LanguageSearchWidget object.
 *
 * @class
 * @extends OO.ui.SearchWidget
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
ve.ui.LanguageSearchWidget = function VeUiLanguageSearchWidget( config ) {
	// Configuration initialization
	config = ve.extendObject( {
		placeholder: ve.msg( 'visualeditor-language-search-input-placeholder' )
	}, config );

	// Parent constructor
	OO.ui.SearchWidget.call( this, config );

	// Properties
	this.languageResultWidgets = [];
	this.filteredLanguageResultWidgets = [];

	var i, l, languageCode,
		languageCodes = ve.init.platform.getLanguageCodes().sort();

	for ( i = 0, l = languageCodes.length; i < l; i++ ) {
		languageCode = languageCodes[i];
		this.languageResultWidgets.push(
			new ve.ui.LanguageResultWidget( {
				$: this.$,
				data: {
					code: languageCode,
					name: ve.init.platform.getLanguageName( languageCode ),
					autonym: ve.init.platform.getLanguageAutonym( languageCode )
				}
			} )
		);
	}
	this.setAvailableLanguages();

	// Initialization
	this.$element.addClass( 've-ui-languageSearchWidget' );
};

/* Inheritance */

OO.inheritClass( ve.ui.LanguageSearchWidget, OO.ui.SearchWidget );

/* Methods */

/**
 * @inheritdoc
 */
ve.ui.LanguageSearchWidget.prototype.onQueryChange = function () {
	// Parent method
	OO.ui.SearchWidget.prototype.onQueryChange.call( this );

	// Populate
	this.addResults();
};

/**
 * Set available languages to show
 *
 * @param {string[]} Available language codes to show, all if undefined
 */
ve.ui.LanguageSearchWidget.prototype.setAvailableLanguages = function ( availableLanguages ) {
	if ( !availableLanguages ) {
		this.filteredLanguageResultWidgets = this.languageResultWidgets.slice();
		return;
	}
	var i, iLen, languageResult, data;

	this.filteredLanguageResultWidgets = [];

	for ( i = 0, iLen = this.languageResultWidgets.length; i < iLen; i++ ) {
		languageResult = this.languageResultWidgets[i];
		data = languageResult.getData();
		if ( availableLanguages.indexOf( data.code ) !== -1 ) {
			this.filteredLanguageResultWidgets.push( languageResult );
		}
	}
};

/**
 * Update search results from current query
 */
ve.ui.LanguageSearchWidget.prototype.addResults = function () {
	var i, iLen, j, jLen, languageResult, data, matchedProperty,
		matchProperties = ['name', 'autonym', 'code'],
		query = this.query.getValue().trim(),
		matcher = new RegExp( '^' + this.constructor.static.escapeRegex( query ), 'i' ),
		hasQuery = !!query.length,
		items = [];

	this.results.clearItems();

	for ( i = 0, iLen = this.filteredLanguageResultWidgets.length; i < iLen; i++ ) {
		languageResult = this.filteredLanguageResultWidgets[i];
		data = languageResult.getData();
		matchedProperty = null;

		for ( j = 0, jLen = matchProperties.length; j < jLen; j++ ) {
			if ( matcher.test( data[matchProperties[j]] ) ) {
				matchedProperty = matchProperties[j];
				break;
			}
		}

		if ( query === '' || matchedProperty ) {
			items.push(
				languageResult
					.updateLabel( query, matchedProperty )
					.setSelected( false )
					.setHighlighted( false )
			);
		}
	}

	this.results.addItems( items );
	if ( hasQuery ) {
		this.results.highlightItem( this.results.getFirstSelectableItem() );
	}
};

/**
 * Escape regex.
 *
 * Ported from Languagefilter#escapeRegex in jquery.uls.
 *
 * @param {string} value Text
 * @returns {string} Text escaped for use in regex
 */
ve.ui.LanguageSearchWidget.static.escapeRegex = function ( value ) {
	return value.replace( /[\-\[\]{}()*+?.,\\\^$\|#\s]/g, '\\$&' );
};

/*!
 * VisualEditor UserInterface LanguageResultWidget class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Creates an ve.ui.LanguageResultWidget object.
 *
 * @class
 * @extends OO.ui.OptionWidget
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
ve.ui.LanguageResultWidget = function VeUiLanguageResultWidget( config ) {
	// Parent constructor
	OO.ui.OptionWidget.call( this, config );

	// Initialization
	this.$element.addClass( 've-ui-languageResultWidget' );
	this.$name = this.$( '<div>' ).addClass( 've-ui-languageResultWidget-name' );
	this.$otherMatch = this.$( '<div>' ).addClass( 've-ui-languageResultWidget-otherMatch' );
	this.setLabel( this.$otherMatch.add( this.$name ) );
};

/* Inheritance */

OO.inheritClass( ve.ui.LanguageResultWidget, OO.ui.OptionWidget );

/* Methods */

/**
 * Update labels based on query
 *
 * @param {string} [query] Query text which matched this result
 * @param {string} [matchedProperty] Data property which matched the query text
 * @chainable
 */
ve.ui.LanguageResultWidget.prototype.updateLabel = function ( query, matchedProperty ) {
	var $highlighted, data = this.getData();

	// Reset text
	this.$name.text( data.name );
	this.$otherMatch.text( data.code );

	// Highlight where applicable
	if ( matchedProperty ) {
		$highlighted = this.highlightQuery( data[matchedProperty], query );
		if ( matchedProperty === 'name' ) {
			this.$name.empty().append( $highlighted );
		} else {
			this.$otherMatch.empty().append( $highlighted );
		}
	}

	return this;
};

/**
 * Highlight text where a substring query matches
 *
 * @param {string} text Text
 * @param {string} query Query to find
 * @returns {jQuery} Text with query substring wrapped in highlighted span
 */
ve.ui.LanguageResultWidget.prototype.highlightQuery = function ( text, query ) {
	var $result = this.$( '<span>' ),
		offset = text.toLowerCase().indexOf( query.toLowerCase() );

	if ( !query.length || offset === -1 ) {
		return $result.text( text );
	}
	$result.append(
		document.createTextNode( text.slice( 0, offset ) ),
		this.$( '<span>' )
			.addClass( 've-ui-languageResultWidget-highlight' )
			.text( text.slice( offset, offset + query.length ) ),
		document.createTextNode( text.slice( offset + query.length ) )
	);
	return $result.contents();
};

/*!
 * VisualEditor UserInterface LanguageSearchDialog class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Dialog for searching for and selecting a language.
 *
 * @class
 * @extends OO.ui.ProcessDialog
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
ve.ui.LanguageSearchDialog = function VeUiLanguageSearchDialog( config ) {
	// Parent constructor
	ve.ui.LanguageSearchDialog.super.call( this, config );
};

/* Inheritance */

OO.inheritClass( ve.ui.LanguageSearchDialog, OO.ui.ProcessDialog );

/* Static Properties */

ve.ui.LanguageSearchDialog.static.name = 'languageSearch';

ve.ui.LanguageSearchDialog.static.size = 'medium';

ve.ui.LanguageSearchDialog.static.title =
	OO.ui.deferMsg( 'visualeditor-dialog-language-search-title' );

ve.ui.LanguageSearchDialog.static.actions = [
	{
		label: OO.ui.deferMsg( 'visualeditor-dialog-action-cancel' )
	}
];

/**
 * Language search widget class to use.
 *
 * @static
 * @property {Function}
 * @inheritable
 */
ve.ui.LanguageSearchDialog.static.languageSearchWidget = ve.ui.LanguageSearchWidget;

/* Methods */

/**
 * @inheritdoc
 */
ve.ui.LanguageSearchDialog.prototype.initialize = function () {
	ve.ui.LanguageSearchDialog.super.prototype.initialize.apply( this, arguments );

	this.searchWidget = new this.constructor.static.languageSearchWidget( {
		$: this.$
	} );
	this.searchWidget.getResults().connect( this, { choose: 'onSearchResultsChoose' } );
	this.$body.append( this.searchWidget.$element );
};

/**
 * Handle the search widget being selected
 *
 * @param {ve.ui.LanguageResultWidget} item Chosen item
 */
ve.ui.LanguageSearchDialog.prototype.onSearchResultsChoose = function ( item ) {
	var data = item.getData();
	this.close( {
		action: 'apply',
		lang: data.code,
		dir: ve.init.platform.getLanguageDirection( data.code )
	} );
};

/**
 * @inheritdoc
 */
ve.ui.LanguageSearchDialog.prototype.getSetupProcess = function ( data ) {
	return ve.ui.LanguageSearchDialog.super.prototype.getSetupProcess.call( this, data )
		.next( function () {
			this.searchWidget.setAvailableLanguages( data.availableLanguages );
			this.searchWidget.addResults();
		}, this );
};

/**
 * @inheritdoc
 */
ve.ui.LanguageSearchDialog.prototype.getReadyProcess = function ( data ) {
	return ve.ui.LanguageSearchDialog.super.prototype.getReadyProcess.call( this, data )
		.next( function () {
			this.searchWidget.getQuery().focus();
		}, this );
};

/**
 * @inheritdoc
 */
ve.ui.LanguageSearchDialog.prototype.getTeardownProcess = function ( data ) {
	return ve.ui.LanguageSearchDialog.super.prototype.getTeardownProcess.call( this, data )
		.first( function () {
			this.searchWidget.getQuery().setValue( '' );
		}, this );
};

/**
 * @inheritdoc
 */
ve.ui.LanguageSearchDialog.prototype.getBodyHeight = function () {
	return 300;
};

/* Registration */

ve.ui.windowFactory.register( ve.ui.LanguageSearchDialog );

/*!
 * VisualEditor UserInterface LanguageInputWidget class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Creates an ve.ui.LanguageInputWidget object.
 *
 * @class
 * @extends OO.ui.Widget
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {boolean} [requireDir] Require directionality to be set (no 'auto' value)
 * @cfg {ve.ui.WindowManager} [dialogManager] Window manager to launch the language search dialog in
 * @cfg {string[]} [availableLanguages] Available language codes to show in search dialog
 */
ve.ui.LanguageInputWidget = function VeUiLanguageInputWidget( config ) {
	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.Widget.call( this, config );

	// Properties
	this.lang = null;
	this.dir = null;
	this.overlay = new ve.ui.Overlay( { classes: ['ve-ui-overlay-global'] } );
	this.dialogs = config.dialogManager || new ve.ui.WindowManager( { factory: ve.ui.windowFactory, isolate: true } );
	this.availableLanguages = config.availableLanguages;
	this.findLanguageButton = new OO.ui.ButtonWidget( {
		$: this.$,
		classes: [ 've-ui-languageInputWidget-findLanguageButton' ],
		label: ve.msg( 'visualeditor-languageinspector-widget-changelang' ),
		indicator: 'next'
	} );
	this.languageCodeTextInput = new OO.ui.TextInputWidget( {
		$: this.$,
		classes: [ 've-ui-languageInputWidget-languageCodeTextInput' ]
	} );
	this.directionSelect = new OO.ui.ButtonSelectWidget( {
		$: this.$,
		classes: [ 've-ui-languageInputWidget-directionSelect' ]
	} );
	this.findLanguageField = new OO.ui.FieldLayout( this.findLanguageButton, {
		$: this.$,
		align: 'left',
		label: ve.msg( 'visualeditor-languageinspector-widget-label-language' )
	} );
	this.languageCodeField = new OO.ui.FieldLayout( this.languageCodeTextInput, {
		$: this.$,
		align: 'left',
		label: ve.msg( 'visualeditor-languageinspector-widget-label-langcode' )
	} );
	this.directionField = new OO.ui.FieldLayout( this.directionSelect, {
		$: this.$,
		align: 'left',
		label: ve.msg( 'visualeditor-languageinspector-widget-label-direction' )
	} );

	// Events
	this.findLanguageButton.connect( this, { click: 'onFindLanguageButtonClick' } );
	this.languageCodeTextInput.connect( this, { change: 'onChange' } );
	this.directionSelect.connect( this, { select: 'onChange' } );

	// Initialization
	var dirItems = [
		new OO.ui.ButtonOptionWidget( {
			$: this.$,
			data: 'rtl',
			icon: 'text-dir-rtl'
		} ),
		new OO.ui.ButtonOptionWidget( {
			$: this.$,
			data: 'ltr',
			icon: 'text-dir-ltr'
		} )
	];
	if ( !config.requireDir ) {
		dirItems.splice(
			1, 0, new OO.ui.ButtonOptionWidget( {
				$: this.$,
				data: null,
				label: ve.msg( 'visualeditor-dialog-language-auto-direction' )
			} )
		);
	}
	this.directionSelect.addItems( dirItems );
	this.overlay.$element.append( this.dialogs.$element );
	$( 'body' ).append( this.overlay.$element );

	this.$element
		.addClass( 've-ui-languageInputWidget' )
		.append(
			this.findLanguageField.$element,
			this.languageCodeField.$element,
			this.directionField.$element
		);
};

/* Inheritance */

OO.inheritClass( ve.ui.LanguageInputWidget, OO.ui.Widget );

/* Events */

/**
 * @event change
 * @param {string} lang Language code
 * @param {string} dir Directionality
 */

/* Methods */

/**
 * Handle find language button click events.
 */
ve.ui.LanguageInputWidget.prototype.onFindLanguageButtonClick = function () {
	var widget = this;
	this.dialogs.openWindow( 'languageSearch', { availableLanguages: this.availableLanguages } )
		.then( function ( opened ) {
			opened.then( function ( closing ) {
				closing.then( function ( data ) {
					data = data || {};
					if ( data.action === 'apply' ) {
						widget.setLangAndDir( data.lang, data.dir );
					}
				} );
			} );
		} );
};

/**
 * Handle input widget change events.
 */
ve.ui.LanguageInputWidget.prototype.onChange = function () {
	if ( this.updating ) {
		return;
	}

	var selectedItem = this.directionSelect.getSelectedItem();
	this.setLangAndDir(
		this.languageCodeTextInput.getValue(),
		selectedItem ? selectedItem.getData() : null
	);
};

/**
 * Set language and directionality
 *
 * The inputs value will automatically be updated.
 *
 * @param {string} lang Language code
 * @param {string} dir Directionality
 * @fires change
 */
ve.ui.LanguageInputWidget.prototype.setLangAndDir = function ( lang, dir ) {
	if ( lang === this.lang && dir === this.dir ) {
		// No change
		return;
	}

	// Set state flag while programmatically changing input widget values
	this.updating = true;
	if ( lang || dir ) {
		lang = lang || '';
		this.languageCodeTextInput.setValue( lang );
		this.findLanguageButton.setLabel(
			ve.init.platform.getLanguageName( lang.toLowerCase() ) ||
			ve.msg( 'visualeditor-languageinspector-widget-changelang' )
		);
		this.directionSelect.selectItem(
			this.directionSelect.getItemFromData( dir || null )
		);
	} else {
		this.languageCodeTextInput.setValue( '' );
		this.findLanguageButton.setLabel(
			ve.msg( 'visualeditor-languageinspector-widget-changelang' )
		);
		this.directionSelect.selectItem( this.directionSelect.getItemFromData( null ) );
	}
	this.updating = false;

	this.emit( 'change', lang, dir );
	this.lang = lang;
	this.dir = dir;
};

/**
 * Get the language
 *
 * @returns {string} Language code
 */
ve.ui.LanguageInputWidget.prototype.getLang = function () {
	return this.lang;
};

/**
 * Get the directionality
 *
 * @returns {string} Directionality (ltr/rtl)
 */
ve.ui.LanguageInputWidget.prototype.getDir = function () {
	return this.dir;
};

/*!
 * VisualEditor UserInterface SurfaceWidget class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Creates an ve.ui.SurfaceWidget object.
 *
 * @class
 * @abstract
 * @extends OO.ui.Widget
 *
 * @constructor
 * @param {ve.dm.Document} doc Document model
 * @param {Object} [config] Configuration options
 * @cfg {Object[]} [tools] Toolbar configuration
 * @cfg {string[]} [excludeCommands] List of commands to exclude
 * @cfg {Object} [importRules] Import rules
 */
ve.ui.SurfaceWidget = function VeUiSurfaceWidget( doc, config ) {
	// Config initialization
	config = config || {};

	// Parent constructor
	OO.ui.Widget.call( this, config );

	// Properties
	this.surface = ve.init.target.createSurface( doc, {
		$: this.$,
		excludeCommands: config.excludeCommands,
		importRules: config.importRules
	} );
	this.toolbar = new ve.ui.Toolbar();

	// Initialization
	this.surface.$element.addClass( 've-ui-surfaceWidget-surface' );
	this.toolbar.$element.addClass( 've-ui-surfaceWidget-toolbar' );
	this.toolbar.$bar.append( this.surface.getToolbarDialogs().$element );
	this.$element
		.addClass( 've-ui-surfaceWidget' )
		.append( this.toolbar.$element, this.surface.$element );
	if ( config.tools ) {
		this.toolbar.setup( config.tools, this.surface );
	}
};

/* Inheritance */

OO.inheritClass( ve.ui.SurfaceWidget, OO.ui.Widget );

/* Methods */

/**
 * Get surface.
 *
 * @method
 * @returns {ve.ui.Surface} Surface
 */
ve.ui.SurfaceWidget.prototype.getSurface = function () {
	return this.surface;
};

/**
 * Get toolbar.
 *
 * @method
 * @returns {OO.ui.Toolbar} Toolbar
 */
ve.ui.SurfaceWidget.prototype.getToolbar = function () {
	return this.toolbar;
};

/**
 * Get content data.
 *
 * @method
 * @returns {ve.dm.ElementLinearData} Content data
 */
ve.ui.SurfaceWidget.prototype.getContent = function () {
	return this.surface.getModel().getDocument().getData();
};

/**
 * Initialize surface and toolbar.
 *
 * Widget must be attached to DOM before initializing.
 *
 * @method
 */
ve.ui.SurfaceWidget.prototype.initialize = function () {
	this.toolbar.initialize();
	this.surface.initialize();
};

/**
 * Destroy surface and toolbar.
 *
 * @method
 */
ve.ui.SurfaceWidget.prototype.destroy = function () {
	if ( this.surface ) {
		this.surface.destroy();
	}
	if ( this.toolbar ) {
		this.toolbar.destroy();
	}
	this.$element.remove();
};

/**
 * Focus the surface.
 */
ve.ui.SurfaceWidget.prototype.focus = function () {
	this.surface.getView().focus();
};

/*!
 * VisualEditor UserInterface LinkTargetInputWidget class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Creates an ve.ui.LinkTargetInputWidget object.
 *
 * @class
 * @extends OO.ui.TextInputWidget
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
ve.ui.LinkTargetInputWidget = function VeUiLinkTargetInputWidget( config ) {
	// Parent constructor
	OO.ui.TextInputWidget.call( this, $.extend( {
		validate: /^(https?:\/\/)?[\w-]+(\.[\w-]+)+\.?(:\d+)?(\/\S*)?/gi
	}, config ) );

	// Properties
	this.annotation = null;

	// Initialization
	this.$element.addClass( 've-ui-linkTargetInputWidget' );

	// Default RTL/LTR check
	// Has to use global $() instead of this.$() because only the main document's <body> has
	// the 'rtl' class; inspectors and dialogs have oo-ui-rtl instead.
	if ( $( 'body' ).hasClass( 'rtl' ) ) {
		this.$input.addClass( 'oo-ui-rtl' );
	}
};

/* Inheritance */

OO.inheritClass( ve.ui.LinkTargetInputWidget, OO.ui.TextInputWidget );

/* Methods */

/**
 * Handle value-changing events
 *
 * Overrides onEdit to perform RTL test based on the typed URL
 *
 * @method
 */
ve.ui.LinkTargetInputWidget.prototype.onEdit = function () {
	var widget = this;
	if ( !this.disabled ) {

		// Allow the stack to clear so the value will be updated
		setTimeout( function () {
			// RTL/LTR check
			// Has to use global $() instead of this.$() because only the main document's <body> has
			// the 'rtl' class; inspectors and dialogs have oo-ui-rtl instead.
			if ( $( 'body' ).hasClass( 'rtl' ) ) {
				var isExt = ve.init.platform.getExternalLinkUrlProtocolsRegExp()
					.test( widget.$input.val() );
				// If URL is external, flip to LTR. Otherwise, set back to RTL
				widget.setRTL( !isExt );
			}
			widget.setValue( widget.$input.val(), true );
		} );
	}
};

/**
 * Set the value of the input.
 *
 * Overrides setValue to keep annotations in sync.
 *
 * @method
 * @param {string} value New value
 * @param {boolean} [fromInput] Value was generated from input element
 */
ve.ui.LinkTargetInputWidget.prototype.setValue = function ( value, fromInput ) {
	// Keep annotation in sync with value
	value = this.cleanUpValue( value );
	if ( value === '' ) {
		this.annotation = null;
	} else {
		this.setAnnotation( new ve.dm.LinkAnnotation( {
			type: 'link',
			attributes: {
				href: value.trim()
			}
		} ), fromInput );
	}

	// Parent method
	OO.ui.TextInputWidget.prototype.setValue.call( this, value );
};

/**
 * Sets the annotation value.
 *
 * The input value will automatically be updated.
 *
 * @method
 * @param {ve.dm.LinkAnnotation} annotation Link annotation
 * @param {boolean} [fromInput] Annotation was generated from input element value
 * @chainable
 */
ve.ui.LinkTargetInputWidget.prototype.setAnnotation = function ( annotation, fromInput ) {
	this.annotation = annotation;

	// If this method was triggered by the user typing into the input, don't update
	// the input element to avoid the cursor jumping as the user types
	if ( !fromInput ) {
		// Parent method
		OO.ui.TextInputWidget.prototype.setValue.call(
			this, this.getTargetFromAnnotation( annotation )
		);
	}

	return this;
};

/**
 * Gets the annotation value.
 *
 * @method
 * @returns {ve.dm.LinkAnnotation} Link annotation
 */
ve.ui.LinkTargetInputWidget.prototype.getAnnotation = function () {
	return this.annotation;
};

/**
 * Get the hyperlink location.
 *
 * @return {string} Hyperlink location
 */
ve.ui.LinkTargetInputWidget.prototype.getHref = function () {
	return this.getValue();
};

/**
 * Gets a target from an annotation.
 *
 * @method
 * @param {ve.dm.LinkAnnotation} annotation Link annotation
 * @returns {string} Target
 */
ve.ui.LinkTargetInputWidget.prototype.getTargetFromAnnotation = function ( annotation ) {
	if ( annotation instanceof ve.dm.LinkAnnotation ) {
		return annotation.getAttribute( 'href' );
	}
	return '';
};

/*!
 * VisualEditor Context Menu widget class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Menu of items, each an inspectable attribute of the current context.
 *
 * Use with ve.ui.ContextOptionWidget.
 *
 * @class
 * @extends OO.ui.SelectWidget
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
ve.ui.ContextSelectWidget = function VeUiContextSelectWidget( config ) {
	// Config initialization
	config = config || {};

	// Parent constructor
	ve.ui.ContextSelectWidget.super.call( this, config );

	this.connect( this, { choose: 'onChooseItem' } );

	// Initialization
	this.$element.addClass( 've-ui-contextSelectWidget' );
};

/* Setup */

OO.inheritClass( ve.ui.ContextSelectWidget, OO.ui.SelectWidget );

/* Methods */

/**
 * Handle choose item events.
 */
ve.ui.ContextSelectWidget.prototype.onChooseItem = function () {
	// Auto-deselect
	this.selectItem( null );
};

/*!
 * VisualEditor Context Item widget class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Proxy for a tool, displaying information about the current context.
 *
 * Use with ve.ui.ContextSelectWidget.
 *
 * @class
 * @extends OO.ui.DecoratedOptionWidget
 *
 * @constructor
 * @param {Function} tool Tool item is a proxy for
 * @param {ve.dm.Node|ve.dm.Annotation} model Node or annotation item is related to
 * @param {Object} [config] Configuration options
 */
ve.ui.ContextOptionWidget = function VeUiContextOptionWidget( tool, model, config ) {
	// Config initialization
	config = config || {};

	// Parent constructor
	ve.ui.ContextOptionWidget.super.call( this, config );

	// Properties
	this.tool = tool;
	this.model = model;

	// Initialization
	this.$element.addClass( 've-ui-contextOptionWidget' );
	this.setIcon( this.tool.static.icon );

	this.setLabel( this.getDescription() );
};

/* Setup */

OO.inheritClass( ve.ui.ContextOptionWidget, OO.ui.DecoratedOptionWidget );

/* Methods */

/**
 * Get a description of the model.
 *
 * @return {string} Description of model
 */
ve.ui.ContextOptionWidget.prototype.getDescription = function () {
	var description;

	if ( this.model instanceof ve.dm.Annotation ) {
		description = ve.ce.annotationFactory.getDescription( this.model );
	} else if ( this.model instanceof ve.dm.Node ) {
		description = ve.ce.nodeFactory.getDescription( this.model );
	}
	if ( !description ) {
		description = this.tool.static.title;
	}

	return description;
};

/**
 * Get the command for this item.
 *
 * @return {ve.ui.Command} Command
 */
ve.ui.ContextOptionWidget.prototype.getCommand = function () {
	return ve.ui.commandRegistry.lookup( this.tool.static.commandName );
};

/*!
 * VisualEditor UserInterface DimensionsWidget class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Widget that visually displays width and height inputs.
 * This widget is for presentation-only, no calculation is done.
 *
 * @class
 * @extends OO.ui.Widget
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {Object} [defaults] Default dimensions
 */
ve.ui.DimensionsWidget = function VeUiDimensionsWidget( config ) {
	var labelTimes, labelPx;

	// Configuration
	config = config || {};

	// Parent constructor
	OO.ui.Widget.call( this, config );

	this.widthInput = new OO.ui.TextInputWidget( {
		$: this.$
	} );
	this.heightInput = new OO.ui.TextInputWidget( {
		$: this.$
	} );

	this.defaults = config.defaults || { width: '', height: '' };
	this.renderDefaults();

	labelTimes = new OO.ui.LabelWidget( {
		$: this.$,
		label: ve.msg( 'visualeditor-dimensionswidget-times' )
	} );
	labelPx = new OO.ui.LabelWidget( {
		$: this.$,
		label: ve.msg( 'visualeditor-dimensionswidget-px' )
	} );

	// Events
	this.widthInput.connect( this, { change: 'onWidthChange' } );
	this.heightInput.connect( this, { change: 'onHeightChange' } );

	// Setup
	this.$element
		.addClass( 've-ui-dimensionsWidget' )
		.append(
			this.widthInput.$element,
			labelTimes.$element
				.addClass( 've-ui-dimensionsWidget-label-times' ),
			this.heightInput.$element,
			labelPx.$element
				.addClass( 've-ui-dimensionsWidget-label-px' )
		);
};

/* Inheritance */

OO.inheritClass( ve.ui.DimensionsWidget, OO.ui.Widget );

/* Events */

/**
 * @event widthChange
 * @param {string} value The new width
 */

/**
 * @event heightChange
 * @param {string} value The new width
 */

/* Methods */

/**
 * Respond to width change, propagate the input change event
 * @param {string} value The new changed value
 * @fires widthChange
 */
ve.ui.DimensionsWidget.prototype.onWidthChange = function ( value ) {
	this.emit( 'widthChange', value );
};

/**
 * Respond to height change, propagate the input change event
 * @param {string} value The new changed value
 * @fires heightChange
 */
ve.ui.DimensionsWidget.prototype.onHeightChange = function ( value ) {
	this.emit( 'heightChange', value );
};

/**
 * Set default dimensions
 * @param {Object} dimensions Default dimensions, width and height
 */
ve.ui.DimensionsWidget.prototype.setDefaults = function ( dimensions ) {
	if ( dimensions.width && dimensions.height ) {
		this.defaults = ve.copy( dimensions );
		this.renderDefaults();
	}
};

/**
 * Render the default dimensions as input placeholders
 */
ve.ui.DimensionsWidget.prototype.renderDefaults = function () {
	this.widthInput.$input.prop( 'placeholder', this.getDefaults().width );
	this.heightInput.$input.prop( 'placeholder', this.getDefaults().height );
};

/**
 * Get the default dimensions
 * @returns {Object} Default dimensions
 */
ve.ui.DimensionsWidget.prototype.getDefaults = function () {
	return this.defaults;
};

/**
 * Remove the default dimensions
 */
ve.ui.DimensionsWidget.prototype.removeDefaults = function () {
	this.defaults = { width: '', height: '' };
	this.renderDefaults();
};

/**
 * Check whether the widget is empty.
 * @returns {boolean} Both values are empty
 */
ve.ui.DimensionsWidget.prototype.isEmpty = function () {
	return (
		this.widthInput.getValue() === '' &&
		this.heightInput.getValue() === ''
	);
};

/**
 * Set an empty value for the dimensions inputs so they show
 * the placeholders if those exist.
 */
ve.ui.DimensionsWidget.prototype.clear = function () {
	this.widthInput.setValue( '' );
	this.heightInput.setValue( '' );
};

/**
 * Reset the dimensions to the default dimensions.
 */
ve.ui.DimensionsWidget.prototype.reset = function () {
	this.setDimensions( this.getDefaults() );
};

/**
 * Set the dimensions value of the inputs
 * @param {Object} dimensions The width and height values of the inputs
 * @param {number} dimensions.width The value of the width input
 * @param {number} dimensions.height The value of the height input
 */
ve.ui.DimensionsWidget.prototype.setDimensions = function ( dimensions ) {
	if ( dimensions.width ) {
		this.setWidth( dimensions.width );
	}
	if ( dimensions.height ) {
		this.setHeight( dimensions.height );
	}
};

/**
 * Return the current dimension values in the widget
 * @returns {Object} dimensions The width and height values of the inputs
 * @returns {number} dimensions.width The value of the width input
 * @returns {number} dimensions.height The value of the height input
 */
ve.ui.DimensionsWidget.prototype.getDimensions = function () {
	return {
		width: this.widthInput.getValue(),
		height: this.heightInput.getValue()
	};
};

/**
 * Disable or enable the inputs
 * @param {boolean} isDisabled Set disabled or enabled
 */
ve.ui.DimensionsWidget.prototype.setDisabled = function ( isDisabled ) {
	// The 'setDisabled' method runs in the constructor before the
	// inputs are initialized
	if ( this.widthInput ) {
		this.widthInput.setDisabled( isDisabled );
	}
	if ( this.heightInput ) {
		this.heightInput.setDisabled( isDisabled );
	}
};

/**
 * Get the current value in the width input
 * @returns {string} Input value
 */
ve.ui.DimensionsWidget.prototype.getWidth = function () {
	return this.widthInput.getValue();
};

/**
 * Get the current value in the height input
 * @returns {string} Input value
 */
ve.ui.DimensionsWidget.prototype.getHeight = function () {
	return this.heightInput.getValue();
};

/**
 * Set a value for the width input
 * @param {string} value
 */
ve.ui.DimensionsWidget.prototype.setWidth = function ( value ) {
	this.widthInput.setValue( value );
};

/**
 * Set a value for the height input
 * @param {string} value
 */
ve.ui.DimensionsWidget.prototype.setHeight = function ( value ) {
	this.heightInput.setValue( value );
};

/*!
 * VisualEditor UserInterface MediaSizeWidget class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Widget that lets the user edit dimensions (width and height),
 * based on a scalable object.
 *
 * @class
 * @extends OO.ui.Widget
 *
 * @constructor
 * @param {ve.dm.Scalable} scalable A scalable object
 * @param {Object} [config] Configuration options
 */
ve.ui.MediaSizeWidget = function VeUiMediaSizeWidget( scalable, config ) {
	var fieldScale, fieldCustom, scalePercentLabel;

	// Configuration
	config = config || {};

	this.scalable = scalable || {};

	// Parent constructor
	OO.ui.Widget.call( this, config );

	// Properties
	this.ratio = {};
	this.currentDimensions = {};
	this.maxDimensions = {};
	this.valid = null;

	// Define button select widget
	this.sizeTypeSelectWidget = new OO.ui.ButtonSelectWidget( {
		$: this.$,
		classes: [ 've-ui-mediaSizeWidget-section-sizetype' ]
	} );
	this.sizeTypeSelectWidget.addItems( [
		new OO.ui.ButtonOptionWidget( {
			$: this.$,
			data: 'default',
			label: ve.msg( 'visualeditor-mediasizewidget-sizeoptions-default' )
		} ),
		// TODO: when upright is supported by Parsoid
		// new OO.ui.ButtonOptionWidget( {
		// $: this.$,
		// data: 'scale',
		// label: ve.msg( 'visualeditor-mediasizewidget-sizeoptions-scale' )
		// } ),
		new OO.ui.ButtonOptionWidget( {
			$: this.$,
			data: 'custom',
			label: ve.msg( 'visualeditor-mediasizewidget-sizeoptions-custom' )
		} )
	] );

	// Define scale
	this.scaleInput = new OO.ui.TextInputWidget( {
		$: this.$
	} );
	scalePercentLabel = new OO.ui.LabelWidget( {
		$: this.$,
		input: this.scaleInput,
		label: ve.msg( 'visualeditor-mediasizewidget-label-scale-percent' )
	} );

	this.dimensionsWidget = new ve.ui.DimensionsWidget( {
		$: this.$
	} );

	// Error label is available globally so it can be displayed and
	// hidden as needed
	this.errorLabel = new OO.ui.LabelWidget( {
		$: this.$,
		label: ve.msg( 'visualeditor-mediasizewidget-label-defaulterror' )
	} );

	// Field layouts
	fieldScale = new OO.ui.FieldLayout(
		this.scaleInput, {
			$: this.$,
			align: 'right',
			// TODO: when upright is supported by Parsoid
			// classes: ['ve-ui-mediaSizeWidget-section-scale'],
			label: ve.msg( 'visualeditor-mediasizewidget-label-scale' )
		}
	);
	// TODO: when upright is supported by Parsoid
	// this.scaleInput.$element.append( scalePercentLabel.$element );
	fieldCustom = new OO.ui.FieldLayout(
		this.dimensionsWidget, {
			$: this.$,
			align: 'right',
			label: ve.msg( 'visualeditor-mediasizewidget-label-custom' ),
			classes: ['ve-ui-mediaSizeWidget-section-custom']
		}
	);

	// Buttons
	this.fullSizeButton = new OO.ui.ButtonWidget( {
		$: this.$,
		label: ve.msg( 'visualeditor-mediasizewidget-button-originaldimensions' ),
		classes: ['ve-ui-mediaSizeWidget-button-fullsize']
	} );

	// Build GUI
	this.$element
		.addClass( 've-ui-mediaSizeWidget' )
		.append(
			this.sizeTypeSelectWidget.$element,
			// TODO: when upright is supported by Parsoid
			// fieldScale.$element,
			fieldCustom.$element,
			this.fullSizeButton.$element,
			this.$( '<div>' )
				.addClass( 've-ui-mediaSizeWidget-label-error' )
				.append( this.errorLabel.$element )
		);

	// Events
	this.dimensionsWidget.connect( this, {
		widthChange: ['onDimensionsChange', 'width'],
		heightChange: ['onDimensionsChange', 'height']
	} );
	// TODO: when upright is supported by Parsoid
	// this.scaleInput.connect( this, { change: 'onScaleChange' } );
	this.sizeTypeSelectWidget.connect( this, { choose: 'onSizeTypeChoose' } );
	this.fullSizeButton.connect( this, { click: 'onFullSizeButtonClick' } );

};

/* Inheritance */

OO.inheritClass( ve.ui.MediaSizeWidget, OO.ui.Widget );

/* Events */

/**
 * @event change
 * @param {Object} dimensions Width and height dimensions
 */

/**
 * @event valid
 * @param {boolean} isValid Current dimensions are valid
 */

/**
 * @event changeSizeType
 * @param {string} sizeType 'default', 'custom' or 'scale'
 */

/* Methods */

/**
 * Respond to change in original dimensions in the scalable object.
 * Specifically, enable or disable to 'set full size' button and the 'default' option.
 *
 * @param {Object} dimensions Original dimensions
 */
ve.ui.MediaSizeWidget.prototype.onScalableOriginalSizeChange = function ( dimensions ) {
	var disabled = !dimensions || $.isEmptyObject( dimensions );
	this.fullSizeButton.setDisabled( disabled );
	this.sizeTypeSelectWidget.getItemFromData( 'default' ).setDisabled( disabled );
	// Revalidate current dimensions
	this.validateDimensions();
};

/**
 * Respond to change in current dimensions in the scalable object.
 *
 * @param {Object} dimensions Original dimensions
 */
ve.ui.MediaSizeWidget.prototype.onScalableCurrentSizeChange = function ( dimensions ) {
	if ( !$.isEmptyObject( dimensions ) ) {
		this.setCurrentDimensions( dimensions );
		this.validateDimensions();
	}
};

/**
 * Respond to default size or status change in the scalable object.
 * @param {boolean} isDefault Current default state
 */
ve.ui.MediaSizeWidget.prototype.onScalableDefaultSizeChange = function ( isDefault ) {
	// Update the default size into the dimensions widget
	this.updateDefaultDimensions();
	// TODO: When 'scale' ('upright' support) is ready, this will need to be adjusted
	// to support that as well
	this.setSizeType(
		isDefault ?
		'default' :
		'custom'
	);
	this.validateDimensions();
};

/**
 * Respond to width/height input value change. Only update dimensions if
 * the value is numeric. Invoke validation for every change.
 *
 * This is triggered every time the dimension widget has its values changed
 * either by the user or externally. The external call to 'setCurrentDimensions'
 * will result in this event being evoked if the dimension inputs have changed,
 * and same with clicking the 'full size' button and changing dimensions type.
 * The 'change' event for the entire widget is emitted through this method, as
 * it means that the actual values have changed, regardless of whether they
 * are valid or not.
 *
 * @param {string} type The input that was updated, 'width' or 'height'
 * @param {string} value The new value of the input
 * @fires change
 */
ve.ui.MediaSizeWidget.prototype.onDimensionsChange = function ( type, value ) {
	var dimensions = {};

	if ( Number( value ) === 0 ) {
		this.setSizeType( 'default' );
	} else {
		this.setSizeType( 'custom' );
		if ( $.isNumeric( value ) ) {
			dimensions[type] = Number( value );
			this.setCurrentDimensions( dimensions );
		} else {
			this.validateDimensions();
		}
	}
};

/**
 * Respond to change of the scale input
 */
ve.ui.MediaSizeWidget.prototype.onScaleChange = function () {
	// If the input changed (and not empty), set to 'custom'
	// Otherwise, set to 'default'
	if ( !this.dimensionsWidget.isEmpty() ) {
		this.sizeTypeSelectWidget.selectItem(
			this.sizeTypeSelectWidget.getItemFromData( 'scale' )
		);
	} else {
		this.sizeTypeSelectWidget.selectItem(
			this.sizeTypeSelectWidget.getItemFromData( 'default' )
		);
	}
};

/**
 * Respond to size type change
 * @param {OO.ui.OptionWidget} item Selected size type item
 * @fires changeSizeType
 */
ve.ui.MediaSizeWidget.prototype.onSizeTypeChoose = function ( item ) {
	var selectedType = item.getData(),
		wasDefault = this.scalable.isDefault();

	this.scalable.toggleDefault( selectedType === 'default' );

	if ( selectedType === 'default' ) {
		this.scaleInput.setDisabled( true );
		// If there are defaults, put them into the values
		if ( !$.isEmptyObject( this.dimensionsWidget.getDefaults() ) ) {
			this.dimensionsWidget.clear();
		}
	} else if ( selectedType === 'scale' ) {
		// Disable the dimensions widget
		this.dimensionsWidget.setDisabled( true );
		// Enable the scale input
		this.scaleInput.setDisabled( false );
	} else if ( selectedType === 'custom' ) {
		// Enable the dimensions widget
		this.dimensionsWidget.setDisabled( false );
		// Disable the scale input
		this.scaleInput.setDisabled( true );
		// If we were default size before, set the current dimensions to the default size
		if ( wasDefault && !$.isEmptyObject( this.dimensionsWidget.getDefaults() ) ) {
			this.setCurrentDimensions( this.dimensionsWidget.getDefaults() );
		}
		this.validateDimensions();
	}

	this.emit( 'changeSizeType', selectedType );
	this.validateDimensions();
};

/**
 * Set the placeholder value of the scale input
 * @param {number} value Placeholder value
 */
ve.ui.MediaSizeWidget.prototype.setScalePlaceholder = function ( value ) {
	this.scaleInput.$element.prop( 'placeholder', value );
};

/**
 * Get the placeholder value of the scale input
 * @returns {string} Placeholder value
 */
ve.ui.MediaSizeWidget.prototype.getScalePlaceholder = function () {
	return this.scaleInput.$element.prop( 'placeholder' );
};

/**
 * Select a size type in the select widget
 * @param {string} sizeType The size type to select
 */
ve.ui.MediaSizeWidget.prototype.setSizeType = function ( sizeType ) {
	if (
		this.getSizeType() !== sizeType ||
		// If the dimensions widget has zeros make sure to
		// allow for the change in size type
		Number( this.dimensionsWidget.getWidth() ) === 0 ||
		Number( this.dimensionsWidget.getHeight() ) === 0
	) {
		this.sizeTypeSelectWidget.chooseItem(
			this.sizeTypeSelectWidget.getItemFromData( sizeType )
		);
	}
};
/**
 * Get the size type from the select widget
 *
 * @returns {string} The size type
 */
ve.ui.MediaSizeWidget.prototype.getSizeType = function () {
	return this.sizeTypeSelectWidget.getSelectedItem() ? this.sizeTypeSelectWidget.getSelectedItem().getData() : '';
};

/**
 * Set the scalable object the widget deals with
 *
 * @param {ve.dm.Scalable} scalable A scalable object representing the media source being resized.
 */
ve.ui.MediaSizeWidget.prototype.setScalable = function ( scalable ) {
	if ( this.scalable instanceof ve.dm.Scalable ) {
		this.scalable.disconnect( this );
	}
	this.scalable = scalable;
	// Events
	this.scalable.connect( this, {
		defaultSizeChange: 'onScalableDefaultSizeChange',
		originalSizeChange: 'onScalableOriginalSizeChange',
		currentSizeChange: 'onScalableCurrentSizeChange'
	} );

	this.updateDefaultDimensions();

	if ( !this.scalable.isDefault() ) {
		// Reset current dimensions to new scalable object
		this.setCurrentDimensions( this.scalable.getCurrentDimensions() );
	}

	// If we don't have original dimensions, disable the full size button
	if ( !this.scalable.getOriginalDimensions() ) {
		this.fullSizeButton.setDisabled( true );
		this.sizeTypeSelectWidget.getItemFromData( 'default' ).setDisabled( true );
	} else {
		this.fullSizeButton.setDisabled( false );
		this.sizeTypeSelectWidget.getItemFromData( 'default' ).setDisabled( false );

		// Call for the set size type according to default or custom settings of the scalable
		this.setSizeType(
			this.scalable.isDefault() ?
			'default' :
			'custom'
		);
	}
	this.validateDimensions();
};

/**
 * Get the attached scalable object
 * @returns {ve.dm.Scalable} The scalable object representing the media
 * source being resized.
 */
ve.ui.MediaSizeWidget.prototype.getScalable = function () {
	return this.scalable;
};

/**
 * Handle click events on the full size button.
 * Set the width/height values to the original media dimensions
 */
ve.ui.MediaSizeWidget.prototype.onFullSizeButtonClick = function () {
	this.sizeTypeSelectWidget.chooseItem(
		this.sizeTypeSelectWidget.getItemFromData( 'custom' )
	);
	this.setCurrentDimensions( this.scalable.getOriginalDimensions() );
	this.dimensionsWidget.setDisabled( false );
};

/**
 * Set the image aspect ratio explicitly
 * @param {number} Numerical value of an aspect ratio
 */
ve.ui.MediaSizeWidget.prototype.setRatio = function ( ratio ) {
	this.scalable.setRatio( ratio );
};

/**
 * Get the current aspect ratio
 * @returns {number} Aspect ratio
 */
ve.ui.MediaSizeWidget.prototype.getRatio = function () {
	return this.scalable.getRatio();
};

/**
 * Set the maximum dimensions for the image. These will be limited only if
 * enforcedMax is true.
 * @param {Object} dimensions Height and width
 */
ve.ui.MediaSizeWidget.prototype.setMaxDimensions = function ( dimensions ) {
	// Normalize dimensions before setting
	var maxDimensions = ve.dm.Scalable.static.getDimensionsFromValue( dimensions, this.scalable.getRatio() );
	this.scalable.setMaxDimensions( maxDimensions );
};

/**
 * Retrieve the currently defined maximum dimensions
 * @returns {Object} dimensions Height and width
 */
ve.ui.MediaSizeWidget.prototype.getMaxDimensions = function () {
	return this.scalable.getMaxDimensions();
};

/**
 * Retrieve the current dimensions
 * @returns {Object} Width and height
 */
ve.ui.MediaSizeWidget.prototype.getCurrentDimensions = function () {
	return this.currentDimensions;
};

/**
 * Disable or enable the entire widget
 * @param {boolean} isDisabled Disable the widget
 */
ve.ui.MediaSizeWidget.prototype.setDisabled = function ( isDisabled ) {
	// The 'setDisabled' method seems to be called before the widgets
	// are fully defined. So, before disabling/enabling anything,
	// make sure the objects exist
	if ( this.sizeTypeSelectWidget &&
		this.dimensionsWidget &&
		this.scalable &&
		this.fullSizeButton
	) {
		// Disable the type select
		this.sizeTypeSelectWidget.setDisabled( isDisabled );

		// Disable the dimensions widget
		this.dimensionsWidget.setDisabled( isDisabled );

		// Double negatives aren't never fun!
		this.fullSizeButton.setDisabled(
			// Disable if asked to disable
			isDisabled ||
			// Only enable if the scalable has
			// the original dimensions available
			!this.scalable.getOriginalDimensions()
		);
	}
};

/**
 * Updates the current dimensions in the inputs, either one at a time or both
 *
 * @param {Object} dimensions Dimensions with width and height
 * @fires change
 */
ve.ui.MediaSizeWidget.prototype.setCurrentDimensions = function ( dimensions ) {
	var normalizedDimensions;

	// Recursion protection
	if ( this.preventChangeRecursion ) {
		return;
	}
	this.preventChangeRecursion = true;

	// Normalize the new dimensions
	normalizedDimensions = ve.dm.Scalable.static.getDimensionsFromValue( dimensions, this.scalable.getRatio() );

	if (
		// Update only if the dimensions object is valid
		this.scalable.isDimensionsObjectValid( normalizedDimensions ) &&
		// And only if the dimensions object is not default
		!this.scalable.isDefault()
	) {
		this.currentDimensions = normalizedDimensions;
		// This will only update if the value has changed
		// Set width & height individually as they may be 0
		this.dimensionsWidget.setWidth( this.currentDimensions.width );
		this.dimensionsWidget.setHeight( this.currentDimensions.height );

		// Update scalable object
		this.scalable.setCurrentDimensions( this.currentDimensions );

		this.validateDimensions();
		// Emit change event
		this.emit( 'change', this.currentDimensions );
	}
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
	var isValid = this.isValid();

	if ( this.valid !== isValid ) {
		this.valid = isValid;
		this.errorLabel.toggle( !isValid );
		this.$element.toggleClass( 've-ui-mediaSizeWidget-input-hasError', !isValid );
		// Emit change event
		this.emit( 'valid', this.valid );
	}
	return isValid;
};

/**
 * Set default dimensions for the widget. Values are given by scalable's
 * defaultDimensions. If no default dimensions are available,
 * the defaults are removed.
 */
ve.ui.MediaSizeWidget.prototype.updateDefaultDimensions = function () {
	var defaultDimensions = this.scalable.getDefaultDimensions();

	if ( !$.isEmptyObject( defaultDimensions ) ) {
		this.dimensionsWidget.setDefaults( defaultDimensions );
	} else {
		this.dimensionsWidget.removeDefaults();
	}
	this.sizeTypeSelectWidget.getItemFromData( 'default' ).setDisabled(
		$.isEmptyObject( defaultDimensions )
	);
	this.validateDimensions();
};

/**
 * Check if the custom dimensions are empty.
 * @returns {boolean} Both width/height values are empty
 */
ve.ui.MediaSizeWidget.prototype.isCustomEmpty = function () {
	return this.dimensionsWidget.isEmpty();
};

/**
 * Toggle a disabled state for the full size button
 * @param {boolean} isDisabled Disabled or not
 */
ve.ui.MediaSizeWidget.prototype.toggleFullSizeButtonDisabled = function ( isDisabled ) {
	this.fullSizeButton.setDisabled( isDisabled );
};

/**
 * Check if the scale input is empty.
 * @returns {boolean} Scale input value is empty
 */
ve.ui.MediaSizeWidget.prototype.isScaleEmpty = function () {
	return ( this.scaleInput.getValue() === '' );
};

/**
 * Check if all inputs are empty.
 * @returns {boolean} All input values are empty
 */
ve.ui.MediaSizeWidget.prototype.isEmpty = function () {
	return ( this.isCustomEmpty() && this.isScaleEmpty() );
};

/**
 * Check whether the current value inputs are valid
 * 1. If placeholders are visible, the input is valid
 * 2. If inputs have non numeric values, input is invalid
 * 3. If inputs have numeric values, validate through scalable
 *    calculations to see if the dimensions follow the rules.
 * @returns {boolean} Valid or invalid dimension values
 */
ve.ui.MediaSizeWidget.prototype.isValid = function () {
	var itemType = this.sizeTypeSelectWidget.getSelectedItem() ?
		this.sizeTypeSelectWidget.getSelectedItem().getData() : 'custom';

	// TODO: when upright is supported by Parsoid add validation for scale

	if ( itemType === 'custom' ) {
		if (
			this.dimensionsWidget.getDefaults() &&
			this.dimensionsWidget.isEmpty()
		) {
			return true;
		} else if (
			$.isNumeric( this.dimensionsWidget.getWidth() ) &&
			$.isNumeric( this.dimensionsWidget.getHeight() )
		) {
			return this.scalable.isCurrentDimensionsValid();
		} else {
			return false;
		}
	} else {
		// Default images are always valid size
		return true;
	}
};

/*!
 * VisualEditor UserInterface WhitespacePreservingTextInputWidget class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Text input widget which hides but preserves leading and trailing whitespace
 *
 * @class
 * @extends OO.ui.TextInputWidget
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {string} [valueAndWhitespace] Initial value and whitespace
 * @cfg {number} [limit] Maximum number of characters to preserve at each end
 */
ve.ui.WhitespacePreservingTextInputWidget = function VeUiWhitespacePreservingTextInputWidget( config ) {
	// Configuration
	config = config || {};

	// Parent constructor
	ve.ui.WhitespacePreservingTextInputWidget.super.call( this, config );

	this.limit = config.limit;

	this.whitespace = [ '', '' ];
	this.setValueAndWhitespace( config.valueAndWhitespace || '' );

	this.$element.addClass( 've-ui-WhitespacePreservingTextInputWidget' );
};

/* Inheritance */

OO.inheritClass( ve.ui.WhitespacePreservingTextInputWidget, OO.ui.TextInputWidget );

/* Methods */

/**
 * Set the value of the widget and extract whitespace.
 *
 * @param {string} value Value
 */
ve.ui.WhitespacePreservingTextInputWidget.prototype.setValueAndWhitespace = function ( value ) {
	var leftValue, rightValue;

	leftValue = this.limit ? value.slice( 0, this.limit ) : value;
	this.whitespace[0] = leftValue.match( /^\s*/ )[0];
	value = value.slice( this.whitespace[0].length );

	rightValue = this.limit ? value.slice( -this.limit ) : value;
	this.whitespace[1] = rightValue.match( /\s*$/ )[0];
	value = value.slice( 0, value.length - this.whitespace[1].length );

	this.setValue( value );
};

/**
 * Set the value of the widget and extract whitespace.
 *
 * @param {string[]} whitespace Outer whitespace
 */
ve.ui.WhitespacePreservingTextInputWidget.prototype.setWhitespace = function ( whitespace ) {
	this.whitespace = whitespace;
};

/**
 * @inheritdoc
 */
ve.ui.WhitespacePreservingTextInputWidget.prototype.getValue = function () {
	if ( !this.whitespace ) {
		// In case getValue() is called from a parent constructor
		return this.value;
	}
	return this.whitespace[0] + this.value + this.whitespace[1];
};

/**
 * Get the inner/displayed value of text widget, excluding hidden outer whitespace
 *
 * @return {string} Inner/displayed value
 */
ve.ui.WhitespacePreservingTextInputWidget.prototype.getInnerValue = function () {
	return this.value;
};

/*!
 * VisualEditor UserInterface AnnotationTool classes.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * UserInterface annotation tool.
 *
 * @class
 * @abstract
 * @extends ve.ui.Tool
 * @constructor
 * @param {OO.ui.ToolGroup} toolGroup
 * @param {Object} [config] Configuration options
 */
ve.ui.AnnotationTool = function VeUiAnnotationTool( toolGroup, config ) {
	// Parent constructor
	ve.ui.Tool.call( this, toolGroup, config );
};

/* Inheritance */

OO.inheritClass( ve.ui.AnnotationTool, ve.ui.Tool );

/* Static Properties */

/**
 * Annotation name and data the tool applies.
 *
 * @abstract
 * @static
 * @property {Object}
 * @inheritable
 */
ve.ui.AnnotationTool.static.annotation = { name: '' };

ve.ui.AnnotationTool.static.deactivateOnSelect = false;

/* Methods */

/**
 * @inheritdoc
 */
ve.ui.AnnotationTool.prototype.onUpdateState = function ( fragment ) {
	// Parent method
	ve.ui.Tool.prototype.onUpdateState.apply( this, arguments );

	this.setActive(
		fragment && fragment.getAnnotations().hasAnnotationWithName( this.constructor.static.annotation.name )
	);
};

/**
 * UserInterface bold tool.
 *
 * @class
 * @extends ve.ui.AnnotationTool
 * @constructor
 * @param {OO.ui.ToolGroup} toolGroup
 * @param {Object} [config] Configuration options
 */
ve.ui.BoldAnnotationTool = function VeUiBoldAnnotationTool( toolGroup, config ) {
	ve.ui.AnnotationTool.call( this, toolGroup, config );
};
OO.inheritClass( ve.ui.BoldAnnotationTool, ve.ui.AnnotationTool );
ve.ui.BoldAnnotationTool.static.name = 'bold';
ve.ui.BoldAnnotationTool.static.group = 'textStyle';
ve.ui.BoldAnnotationTool.static.icon = {
	default: 'bold-a',
	ar: 'bold-arab-ain',
	be: 'bold-cyrl-te',
	cs: 'bold-b',
	da: 'bold-f',
	de: 'bold-f',
	en: 'bold-b',
	es: 'bold-n',
	eu: 'bold-l',
	fa: 'bold-arab-dad',
	fi: 'bold-l',
	fr: 'bold-g',
	gl: 'bold-n',
	he: 'bold-b',
	hu: 'bold-f',
	hy: 'bold-armn-to',
	it: 'bold-g',
	ka: 'bold-geor-man',
	ksh: 'bold-f',
	ky: 'bold-cyrl-zhe',
	ml: 'bold-b',
	nl: 'bold-v',
	nn: 'bold-f',
	no: 'bold-f',
	os: 'bold-cyrl-be',
	pl: 'bold-b',
	pt: 'bold-n',
	ru: 'bold-cyrl-zhe',
	sv: 'bold-f'
};
ve.ui.BoldAnnotationTool.static.title =
	OO.ui.deferMsg( 'visualeditor-annotationbutton-bold-tooltip' );
ve.ui.BoldAnnotationTool.static.annotation = { name: 'textStyle/bold' };
ve.ui.BoldAnnotationTool.static.commandName = 'bold';
ve.ui.toolFactory.register( ve.ui.BoldAnnotationTool );

/**
 * UserInterface italic tool.
 *
 * @class
 * @extends ve.ui.AnnotationTool
 * @constructor
 * @param {OO.ui.ToolGroup} toolGroup
 * @param {Object} [config] Configuration options
 */
ve.ui.ItalicAnnotationTool = function VeUiItalicAnnotationTool( toolGroup, config ) {
	ve.ui.AnnotationTool.call( this, toolGroup, config );
};
OO.inheritClass( ve.ui.ItalicAnnotationTool, ve.ui.AnnotationTool );
ve.ui.ItalicAnnotationTool.static.name = 'italic';
ve.ui.ItalicAnnotationTool.static.group = 'textStyle';
ve.ui.ItalicAnnotationTool.static.icon = {
	default: 'italic-a',
	ar: 'italic-arab-meem',
	be: 'italic-cyrl-ka',
	cs: 'italic-i',
	da: 'italic-k',
	de: 'italic-k',
	en: 'italic-i',
	es: 'italic-c',
	eu: 'italic-e',
	fa: 'italic-arab-keheh-jeem',
	fi: 'italic-k',
	fr: 'italic-i',
	gl: 'italic-c',
	he: 'italic-i',
	hu: 'italic-d',
	hy: 'italic-armn-sha',
	it: 'italic-c',
	ka: 'italic-geor-kan',
	ksh: 'italic-s',
	ky: 'italic-cyrl-ka',
	ml: 'italic-i',
	nl: 'italic-c',
	nn: 'italic-k',
	no: 'italic-k',
	os: 'italic-cyrl-ka',
	pl: 'italic-i',
	pt: 'italic-i',
	ru: 'italic-cyrl-ka',
	sv: 'italic-k'
};
ve.ui.ItalicAnnotationTool.static.title =
	OO.ui.deferMsg( 'visualeditor-annotationbutton-italic-tooltip' );
ve.ui.ItalicAnnotationTool.static.annotation = { name: 'textStyle/italic' };
ve.ui.ItalicAnnotationTool.static.commandName = 'italic';
ve.ui.toolFactory.register( ve.ui.ItalicAnnotationTool );

/**
 * UserInterface code tool.
 *
 * @class
 * @extends ve.ui.AnnotationTool
 * @constructor
 * @param {OO.ui.ToolGroup} toolGroup
 * @param {Object} [config] Configuration options
 */
ve.ui.CodeAnnotationTool = function VeUiCodeAnnotationTool( toolGroup, config ) {
	ve.ui.AnnotationTool.call( this, toolGroup, config );
};
OO.inheritClass( ve.ui.CodeAnnotationTool, ve.ui.AnnotationTool );
ve.ui.CodeAnnotationTool.static.name = 'code';
ve.ui.CodeAnnotationTool.static.group = 'textStyle';
ve.ui.CodeAnnotationTool.static.icon = 'code';
ve.ui.CodeAnnotationTool.static.title =
	OO.ui.deferMsg( 'visualeditor-annotationbutton-code-tooltip' );
ve.ui.CodeAnnotationTool.static.annotation = { name: 'textStyle/code' };
ve.ui.CodeAnnotationTool.static.commandName = 'code';
ve.ui.toolFactory.register( ve.ui.CodeAnnotationTool );

/**
 * UserInterface strikethrough tool.
 *
 * @class
 * @extends ve.ui.AnnotationTool
 * @constructor
 * @param {OO.ui.ToolGroup} toolGroup
 * @param {Object} [config] Configuration options
 */
ve.ui.StrikethroughAnnotationTool = function VeUiStrikethroughAnnotationTool( toolGroup, config ) {
	ve.ui.AnnotationTool.call( this, toolGroup, config );
};
OO.inheritClass( ve.ui.StrikethroughAnnotationTool, ve.ui.AnnotationTool );
ve.ui.StrikethroughAnnotationTool.static.name = 'strikethrough';
ve.ui.StrikethroughAnnotationTool.static.group = 'textStyle';
ve.ui.StrikethroughAnnotationTool.static.icon = {
	default: 'strikethrough-a',
	en: 'strikethrough-s',
	fi: 'strikethrough-y'
};
ve.ui.StrikethroughAnnotationTool.static.title =
	OO.ui.deferMsg( 'visualeditor-annotationbutton-strikethrough-tooltip' );
ve.ui.StrikethroughAnnotationTool.static.annotation = { name: 'textStyle/strikethrough' };
ve.ui.StrikethroughAnnotationTool.static.commandName = 'strikethrough';
ve.ui.toolFactory.register( ve.ui.StrikethroughAnnotationTool );

/**
 * UserInterface underline tool.
 *
 * @class
 * @extends ve.ui.AnnotationTool
 * @constructor
 * @param {OO.ui.ToolGroup} toolGroup
 * @param {Object} [config] Configuration options
 */
ve.ui.UnderlineAnnotationTool = function VeUiUnderlineAnnotationTool( toolGroup, config ) {
	ve.ui.AnnotationTool.call( this, toolGroup, config );
};
OO.inheritClass( ve.ui.UnderlineAnnotationTool, ve.ui.AnnotationTool );
ve.ui.UnderlineAnnotationTool.static.name = 'underline';
ve.ui.UnderlineAnnotationTool.static.group = 'textStyle';
ve.ui.UnderlineAnnotationTool.static.icon = {
	default: 'underline-a',
	en: 'underline-u'
};
ve.ui.UnderlineAnnotationTool.static.title =
	OO.ui.deferMsg( 'visualeditor-annotationbutton-underline-tooltip' );
ve.ui.UnderlineAnnotationTool.static.annotation = { name: 'textStyle/underline' };
ve.ui.UnderlineAnnotationTool.static.commandName = 'underline';
ve.ui.toolFactory.register( ve.ui.UnderlineAnnotationTool );

/**
 * UserInterface superscript tool.
 *
 * @class
 * @extends ve.ui.AnnotationTool
 * @constructor
 * @param {OO.ui.ToolGroup} toolGroup
 * @param {Object} [config] Configuration options
 */
ve.ui.SuperscriptAnnotationTool = function VeUiSuperscriptAnnotationTool( toolGroup, config ) {
	ve.ui.AnnotationTool.call( this, toolGroup, config );
};
OO.inheritClass( ve.ui.SuperscriptAnnotationTool, ve.ui.AnnotationTool );
ve.ui.SuperscriptAnnotationTool.static.name = 'superscript';
ve.ui.SuperscriptAnnotationTool.static.group = 'textStyle';
ve.ui.SuperscriptAnnotationTool.static.icon = 'superscript';
ve.ui.SuperscriptAnnotationTool.static.title =
	OO.ui.deferMsg( 'visualeditor-annotationbutton-superscript-tooltip' );
ve.ui.SuperscriptAnnotationTool.static.annotation = { name: 'textStyle/superscript' };
ve.ui.SuperscriptAnnotationTool.static.commandName = 'superscript';
ve.ui.toolFactory.register( ve.ui.SuperscriptAnnotationTool );

/**
 * UserInterface subscript tool.
 *
 * @class
 * @extends ve.ui.AnnotationTool
 * @constructor
 * @param {OO.ui.ToolGroup} toolGroup
 * @param {Object} [config] Configuration options
 */
ve.ui.SubscriptAnnotationTool = function VeUiSubscriptAnnotationTool( toolGroup, config ) {
	ve.ui.AnnotationTool.call( this, toolGroup, config );
};
OO.inheritClass( ve.ui.SubscriptAnnotationTool, ve.ui.AnnotationTool );
ve.ui.SubscriptAnnotationTool.static.name = 'subscript';
ve.ui.SubscriptAnnotationTool.static.group = 'textStyle';
ve.ui.SubscriptAnnotationTool.static.icon = 'subscript';
ve.ui.SubscriptAnnotationTool.static.title =
	OO.ui.deferMsg( 'visualeditor-annotationbutton-subscript-tooltip' );
ve.ui.SubscriptAnnotationTool.static.annotation = { name: 'textStyle/subscript' };
ve.ui.SubscriptAnnotationTool.static.commandName = 'subscript';
ve.ui.toolFactory.register( ve.ui.SubscriptAnnotationTool );

/**
 * UserInterface more text styles tool.
 *
 * @class
 * @extends OO.ui.ToolGroupTool
 * @constructor
 * @param {OO.ui.ToolGroup} toolGroup
 * @param {Object} [config] Configuration options
 */
ve.ui.MoreTextStyleTool = function VeUiMoreTextStyleTool( toolGroup, config ) {
	OO.ui.ToolGroupTool.call( this, toolGroup, config );
};
OO.inheritClass( ve.ui.MoreTextStyleTool, OO.ui.ToolGroupTool );
ve.ui.MoreTextStyleTool.static.autoAddToCatchall = false;
ve.ui.MoreTextStyleTool.static.name = 'moreTextStyle';
ve.ui.MoreTextStyleTool.static.group = 'textStyleExpansion';
ve.ui.MoreTextStyleTool.static.title =
	OO.ui.deferMsg( 'visualeditor-toolbar-style-tooltip' );
ve.ui.MoreTextStyleTool.static.groupConfig = {
	header: OO.ui.deferMsg( 'visualeditor-toolbar-text-style' ),
	icon: 'text-style',
	indicator: 'down',
	title: OO.ui.deferMsg( 'visualeditor-toolbar-style-tooltip' ),
	include: [ { group: 'textStyle' }, 'language', 'clear' ],
	demote: [ 'strikethrough', 'code', 'underline', 'language', 'clear' ]
};
ve.ui.toolFactory.register( ve.ui.MoreTextStyleTool );

/*!
 * VisualEditor UserInterface ClearAnnotationTool class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * UserInterface clear all annotations tool.
 *
 * @class
 * @extends ve.ui.Tool
 * @constructor
 * @param {OO.ui.ToolGroup} toolGroup
 * @param {Object} [config] Configuration options
 */
ve.ui.ClearAnnotationTool = function VeUiClearAnnotationTool( toolGroup, config ) {
	// Parent constructor
	ve.ui.Tool.call( this, toolGroup, config );

	// Initialization
	this.setDisabled( true );
};

/* Inheritance */

OO.inheritClass( ve.ui.ClearAnnotationTool, ve.ui.Tool );

/* Static Properties */

ve.ui.ClearAnnotationTool.static.name = 'clear';

ve.ui.ClearAnnotationTool.static.group = 'utility';

ve.ui.ClearAnnotationTool.static.icon = 'clear';

ve.ui.ClearAnnotationTool.static.title =
	OO.ui.deferMsg( 'visualeditor-clearbutton-tooltip' );

ve.ui.ClearAnnotationTool.static.commandName = 'clear';

/* Registration */

ve.ui.toolFactory.register( ve.ui.ClearAnnotationTool );

/*!
 * VisualEditor UserInterface DialogTool class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * UserInterface dialog tool.
 *
 * @abstract
 * @class
 * @extends ve.ui.Tool
 * @constructor
 * @param {OO.ui.ToolGroup} toolGroup
 * @param {Object} [config] Configuration options
 */
ve.ui.DialogTool = function VeUiDialogTool() {
	// Parent constructor
	ve.ui.DialogTool.super.apply( this, arguments );
};

/* Inheritance */

OO.inheritClass( ve.ui.DialogTool, ve.ui.Tool );

/* Static Properties */

/**
 * Annotation or node models this tool is related to.
 *
 * Used by #isCompatibleWith.
 *
 * @static
 * @property {Function[]}
 * @inheritable
 */
ve.ui.DialogTool.static.modelClasses = [];

/**
 * @inheritdoc
 */
ve.ui.DialogTool.static.isCompatibleWith = function ( model ) {
	return ve.isInstanceOfAny( model, this.modelClasses );
};

/* Methods */

/**
 * @inheritdoc
 */
ve.ui.DialogTool.prototype.onUpdateState = function () {
	// Parent method
	ve.ui.DialogTool.super.prototype.onUpdateState.apply( this, arguments );
	// Never show the tool as active
	this.setActive( false );
};

/**
 * Command help tool.
 *
 * @class
 * @extends ve.ui.DialogTool
 * @constructor
 * @param {OO.ui.ToolGroup} toolGroup
 * @param {Object} [config] Configuration options
 */
ve.ui.CommandHelpDialogTool = function VeUiCommandHelpDialogTool() {
	ve.ui.CommandHelpDialogTool.super.apply( this, arguments );
};
OO.inheritClass( ve.ui.CommandHelpDialogTool, ve.ui.DialogTool );
ve.ui.CommandHelpDialogTool.static.name = 'commandHelp';
ve.ui.CommandHelpDialogTool.static.group = 'dialog';
ve.ui.CommandHelpDialogTool.static.icon = 'help';
ve.ui.CommandHelpDialogTool.static.title =
	OO.ui.deferMsg( 'visualeditor-dialog-command-help-title' );
ve.ui.CommandHelpDialogTool.static.autoAddToCatchall = false;
ve.ui.CommandHelpDialogTool.static.autoAddToGroup = false;
ve.ui.CommandHelpDialogTool.static.commandName = 'commandHelp';
ve.ui.toolFactory.register( ve.ui.CommandHelpDialogTool );

/*!
 * VisualEditor UserInterface ToolbarDialogTool class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * UserInterface toolbar dialog tool.
 *
 * @abstract
 * @class
 * @extends ve.ui.DialogTool
 * @constructor
 * @param {OO.ui.ToolGroup} toolGroup
 * @param {Object} [config] Configuration options
 */
ve.ui.ToolbarDialogTool = function VeUiToolbarDialogTool() {
	// Parent constructor
	ve.ui.ToolbarDialogTool.super.apply( this, arguments );
};

/* Inheritance */

OO.inheritClass( ve.ui.ToolbarDialogTool, ve.ui.DialogTool );

/* Static Properties */

ve.ui.ToolbarDialogTool.static.deactivateOnSelect = false;

/**
 * Name of the associated window
 *
 * The tool will display as active only if this window is open
 *
 * @static
 * @property {string}
 * @inheritable
 */
ve.ui.ToolbarDialogTool.static.activeWindow = null;

/* Methods */

/**
 * @inheritdoc
 */
ve.ui.ToolbarDialogTool.prototype.onUpdateState = function () {
	// Parent method
	ve.ui.ToolbarDialogTool.super.prototype.onUpdateState.apply( this, arguments );

	// Show the tool as active if its associated window is open
	var currentWindow = this.toolbar.getSurface().getToolbarDialogs().currentWindow;
	this.setActive( currentWindow && currentWindow.constructor.static.name === this.constructor.static.activeWindow );
};

/**
 * Find and replace tool.
 *
 * @class
 * @extends ve.ui.ToolbarDialogTool
 * @constructor
 * @param {OO.ui.ToolGroup} toolGroup
 * @param {Object} [config] Configuration options
 */
ve.ui.FindAndReplaceTool = function VeUiFindAndReplaceTool() {
	ve.ui.FindAndReplaceTool.super.apply( this, arguments );
};
OO.inheritClass( ve.ui.FindAndReplaceTool, ve.ui.ToolbarDialogTool );
ve.ui.FindAndReplaceTool.static.name = 'findAndReplace';
ve.ui.FindAndReplaceTool.static.group = 'dialog';
ve.ui.FindAndReplaceTool.static.icon = 'find';
ve.ui.FindAndReplaceTool.static.title =
	OO.ui.deferMsg( 'visualeditor-find-and-replace-title' );
ve.ui.FindAndReplaceTool.static.autoAddToCatchall = false;
ve.ui.FindAndReplaceTool.static.autoAddToGroup = false;
ve.ui.FindAndReplaceTool.static.commandName = 'findAndReplace';
ve.ui.FindAndReplaceTool.static.activeWindow = 'findAndReplace';
ve.ui.toolFactory.register( ve.ui.FindAndReplaceTool );

/**
 * Special character tool.
 *
 * @class
 * @extends ve.ui.ToolbarDialogTool
 * @constructor
 * @param {OO.ui.ToolGroup} toolGroup
 * @param {Object} [config] Configuration options
 */
ve.ui.SpecialCharacterDialogTool = function VeUiSpecialCharacterDialogTool() {
	ve.ui.SpecialCharacterDialogTool.super.apply( this, arguments );
};
OO.inheritClass( ve.ui.SpecialCharacterDialogTool, ve.ui.ToolbarDialogTool );
ve.ui.SpecialCharacterDialogTool.static.name = 'specialCharacter';
ve.ui.SpecialCharacterDialogTool.static.group = 'dialog';
ve.ui.SpecialCharacterDialogTool.static.icon = 'special-character';
ve.ui.SpecialCharacterDialogTool.static.title =
	OO.ui.deferMsg( 'visualeditor-specialcharacter-button-tooltip' );
ve.ui.SpecialCharacterDialogTool.static.autoAddToCatchall = false;
ve.ui.SpecialCharacterDialogTool.static.autoAddToGroup = false;
ve.ui.SpecialCharacterDialogTool.static.commandName = 'specialCharacter';
ve.ui.SpecialCharacterDialogTool.static.activeWindow = 'specialCharacter';
ve.ui.toolFactory.register( ve.ui.SpecialCharacterDialogTool );

/*!
 * VisualEditor UserInterface FormatTool classes.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * UserInterface format tool.
 *
 * @abstract
 * @class
 * @extends ve.ui.Tool
 * @constructor
 * @param {OO.ui.ToolGroup} toolGroup
 * @param {Object} [config] Configuration options
 */
ve.ui.FormatTool = function VeUiFormatTool( toolGroup, config ) {
	// Parent constructor
	ve.ui.Tool.call( this, toolGroup, config );

	// Properties
	this.convertible = false;
};

/* Inheritance */

OO.inheritClass( ve.ui.FormatTool, ve.ui.Tool );

/* Static Properties */

ve.ui.FormatTool.static.deactivateOnSelect = false;

/**
 * Format the tool applies.
 *
 * Object should contain a required `type` and optional `attributes` property.
 *
 * @abstract
 * @static
 * @property {Object}
 * @inheritable
 */
ve.ui.FormatTool.static.format = null;

/* Methods */

/**
 * @inheritdoc
 */
ve.ui.FormatTool.prototype.onUpdateState = function ( fragment ) {
	// Parent method
	ve.ui.FormatTool.super.prototype.onUpdateState.apply( this, arguments );

	// Hide and de-activate disabled tools
	if ( this.isDisabled() ) {
		this.toggle( false );
		this.setActive( false );
		return;
	}

	this.toggle( true );

	var i, len, nodes, all, cells,
		selection = fragment.getSelection(),
		format = this.constructor.static.format;

	if ( selection instanceof ve.dm.LinearSelection ) {
		nodes = fragment.getSelectedLeafNodes();
		all = !!nodes.length;
		for ( i = 0, len = nodes.length; i < len; i++ ) {
			if ( !nodes[i].hasMatchingAncestor( format.type, format.attributes ) ) {
				all = false;
				break;
			}
		}
	} else if ( selection instanceof ve.dm.TableSelection ) {
		cells = selection.getMatrixCells();
		all = true;
		for ( i = cells.length - 1; i >= 0; i-- ) {
			if ( !cells[i].node.matches( format.type, format.attributes ) ) {
				all = false;
				break;
			}
		}
	}
	this.convertible = !all;
	this.setActive( all );
};

/**
 * UserInterface paragraph tool.
 *
 * @class
 * @extends ve.ui.FormatTool
 * @constructor
 * @param {OO.ui.ToolGroup} toolGroup
 * @param {Object} [config] Configuration options
 */
ve.ui.ParagraphFormatTool = function VeUiParagraphFormatTool( toolGroup, config ) {
	ve.ui.FormatTool.call( this, toolGroup, config );
};
OO.inheritClass( ve.ui.ParagraphFormatTool, ve.ui.FormatTool );
ve.ui.ParagraphFormatTool.static.name = 'paragraph';
ve.ui.ParagraphFormatTool.static.group = 'format';
ve.ui.ParagraphFormatTool.static.title =
	OO.ui.deferMsg( 'visualeditor-formatdropdown-format-paragraph' );
ve.ui.ParagraphFormatTool.static.format = { type: 'paragraph' };
ve.ui.ParagraphFormatTool.static.commandName = 'paragraph';
ve.ui.toolFactory.register( ve.ui.ParagraphFormatTool );

/**
 * UserInterface heading 1 tool.
 *
 * @class
 * @extends ve.ui.FormatTool
 * @constructor
 * @param {OO.ui.ToolGroup} toolGroup
 * @param {Object} [config] Configuration options
 */
ve.ui.Heading1FormatTool = function VeUiHeading1FormatTool( toolGroup, config ) {
	ve.ui.FormatTool.call( this, toolGroup, config );
};
OO.inheritClass( ve.ui.Heading1FormatTool, ve.ui.FormatTool );
ve.ui.Heading1FormatTool.static.name = 'heading1';
ve.ui.Heading1FormatTool.static.group = 'format';
ve.ui.Heading1FormatTool.static.title =
	OO.ui.deferMsg( 'visualeditor-formatdropdown-format-heading1' );
ve.ui.Heading1FormatTool.static.format = { type: 'heading', attributes: { level: 1 } };
ve.ui.Heading1FormatTool.static.commandName = 'heading1';
ve.ui.toolFactory.register( ve.ui.Heading1FormatTool );

/**
 * UserInterface heading 2 tool.
 *
 * @class
 * @extends ve.ui.FormatTool
 * @constructor
 * @param {OO.ui.ToolGroup} toolGroup
 * @param {Object} [config] Configuration options
 */
ve.ui.Heading2FormatTool = function VeUiHeading2FormatTool( toolGroup, config ) {
	ve.ui.FormatTool.call( this, toolGroup, config );
};
OO.inheritClass( ve.ui.Heading2FormatTool, ve.ui.FormatTool );
ve.ui.Heading2FormatTool.static.name = 'heading2';
ve.ui.Heading2FormatTool.static.group = 'format';
ve.ui.Heading2FormatTool.static.title =
	OO.ui.deferMsg( 'visualeditor-formatdropdown-format-heading2' );
ve.ui.Heading2FormatTool.static.format = { type: 'heading', attributes: { level: 2 } };
ve.ui.Heading2FormatTool.static.commandName = 'heading2';
ve.ui.toolFactory.register( ve.ui.Heading2FormatTool );

/**
 * UserInterface heading 3 tool.
 *
 * @class
 * @extends ve.ui.FormatTool
 * @constructor
 * @param {OO.ui.ToolGroup} toolGroup
 * @param {Object} [config] Configuration options
 */
ve.ui.Heading3FormatTool = function VeUiHeading3FormatTool( toolGroup, config ) {
	ve.ui.FormatTool.call( this, toolGroup, config );
};
OO.inheritClass( ve.ui.Heading3FormatTool, ve.ui.FormatTool );
ve.ui.Heading3FormatTool.static.name = 'heading3';
ve.ui.Heading3FormatTool.static.group = 'format';
ve.ui.Heading3FormatTool.static.title =
	OO.ui.deferMsg( 'visualeditor-formatdropdown-format-heading3' );
ve.ui.Heading3FormatTool.static.format = { type: 'heading', attributes: { level: 3 } };
ve.ui.Heading3FormatTool.static.commandName = 'heading3';
ve.ui.toolFactory.register( ve.ui.Heading3FormatTool );

/**
 * UserInterface heading 4 tool.
 *
 * @class
 * @extends ve.ui.FormatTool
 * @constructor
 * @param {OO.ui.ToolGroup} toolGroup
 * @param {Object} [config] Configuration options
 */
ve.ui.Heading4FormatTool = function VeUiHeading4FormatTool( toolGroup, config ) {
	ve.ui.FormatTool.call( this, toolGroup, config );
};
OO.inheritClass( ve.ui.Heading4FormatTool, ve.ui.FormatTool );
ve.ui.Heading4FormatTool.static.name = 'heading4';
ve.ui.Heading4FormatTool.static.group = 'format';
ve.ui.Heading4FormatTool.static.title =
	OO.ui.deferMsg( 'visualeditor-formatdropdown-format-heading4' );
ve.ui.Heading4FormatTool.static.format = { type: 'heading', attributes: { level: 4 } };
ve.ui.Heading4FormatTool.static.commandName = 'heading4';
ve.ui.toolFactory.register( ve.ui.Heading4FormatTool );

/**
 * UserInterface heading 5 tool.
 *
 * @class
 * @extends ve.ui.FormatTool
 * @constructor
 * @param {OO.ui.ToolGroup} toolGroup
 * @param {Object} [config] Configuration options
 */
ve.ui.Heading5FormatTool = function VeUiHeading5FormatTool( toolGroup, config ) {
	ve.ui.FormatTool.call( this, toolGroup, config );
};
OO.inheritClass( ve.ui.Heading5FormatTool, ve.ui.FormatTool );
ve.ui.Heading5FormatTool.static.name = 'heading5';
ve.ui.Heading5FormatTool.static.group = 'format';
ve.ui.Heading5FormatTool.static.title =
	OO.ui.deferMsg( 'visualeditor-formatdropdown-format-heading5' );
ve.ui.Heading5FormatTool.static.format = { type: 'heading', attributes: { level: 5 } };
ve.ui.Heading5FormatTool.static.commandName = 'heading5';
ve.ui.toolFactory.register( ve.ui.Heading5FormatTool );

/**
 * UserInterface heading 6 tool.
 *
 * @class
 * @extends ve.ui.FormatTool
 * @constructor
 * @param {OO.ui.ToolGroup} toolGroup
 * @param {Object} [config] Configuration options
 */
ve.ui.Heading6FormatTool = function VeUiHeading6FormatTool( toolGroup, config ) {
	ve.ui.FormatTool.call( this, toolGroup, config );
};
OO.inheritClass( ve.ui.Heading6FormatTool, ve.ui.FormatTool );
ve.ui.Heading6FormatTool.static.name = 'heading6';
ve.ui.Heading6FormatTool.static.group = 'format';
ve.ui.Heading6FormatTool.static.title =
	OO.ui.deferMsg( 'visualeditor-formatdropdown-format-heading6' );
ve.ui.Heading6FormatTool.static.format = { type: 'heading', attributes: { level: 6 } };
ve.ui.Heading6FormatTool.static.commandName = 'heading6';
ve.ui.toolFactory.register( ve.ui.Heading6FormatTool );

/**
 * UserInterface preformatted tool.
 *
 * @class
 * @extends ve.ui.FormatTool
 * @constructor
 * @param {OO.ui.ToolGroup} toolGroup
 * @param {Object} [config] Configuration options
 */
ve.ui.PreformattedFormatTool = function VeUiPreformattedFormatTool( toolGroup, config ) {
	ve.ui.FormatTool.call( this, toolGroup, config );
};
OO.inheritClass( ve.ui.PreformattedFormatTool, ve.ui.FormatTool );
ve.ui.PreformattedFormatTool.static.name = 'preformatted';
ve.ui.PreformattedFormatTool.static.group = 'format';
ve.ui.PreformattedFormatTool.static.title =
	OO.ui.deferMsg( 'visualeditor-formatdropdown-format-preformatted' );
ve.ui.PreformattedFormatTool.static.format = { type: 'preformatted' };
ve.ui.PreformattedFormatTool.static.commandName = 'preformatted';
ve.ui.toolFactory.register( ve.ui.PreformattedFormatTool );

/**
 * UserInterface blockquote tool.
 *
 * @class
 * @extends ve.ui.FormatTool
 * @constructor
 * @param {OO.ui.ToolGroup} toolGroup
 * @param {Object} [config] Configuration options
 */
ve.ui.BlockquoteFormatTool = function VeUiBlockquoteFormatTool( toolGroup, config ) {
	ve.ui.FormatTool.call( this, toolGroup, config );
};
OO.inheritClass( ve.ui.BlockquoteFormatTool, ve.ui.FormatTool );
ve.ui.BlockquoteFormatTool.static.name = 'blockquote';
ve.ui.BlockquoteFormatTool.static.group = 'format';
ve.ui.BlockquoteFormatTool.static.title =
	OO.ui.deferMsg( 'visualeditor-formatdropdown-format-blockquote' );
ve.ui.BlockquoteFormatTool.static.format = { type: 'blockquote' };
ve.ui.BlockquoteFormatTool.static.commandName = 'blockquote';
ve.ui.toolFactory.register( ve.ui.BlockquoteFormatTool );

/**
 * UserInterface table cell header tool.
 *
 * @class
 * @extends ve.ui.FormatTool
 * @constructor
 * @param {OO.ui.ToolGroup} toolGroup
 * @param {Object} [config] Configuration options
 */
ve.ui.TableCellHeaderFormatTool = function VeUiTableCellHeaderFormatTool( toolGroup, config ) {
	ve.ui.FormatTool.call( this, toolGroup, config );
};
OO.inheritClass( ve.ui.TableCellHeaderFormatTool, ve.ui.FormatTool );
ve.ui.TableCellHeaderFormatTool.static.name = 'tableCellHeader';
ve.ui.TableCellHeaderFormatTool.static.group = 'format';
ve.ui.TableCellHeaderFormatTool.static.title =
	OO.ui.deferMsg( 'visualeditor-table-format-header' );
ve.ui.TableCellHeaderFormatTool.static.format = { type: 'tableCell', attributes: { style: 'header' } };
ve.ui.TableCellHeaderFormatTool.static.commandName = 'tableCellHeader';
ve.ui.toolFactory.register( ve.ui.TableCellHeaderFormatTool );

/**
 * UserInterface table cell data tool.
 *
 * @class
 * @extends ve.ui.FormatTool
 * @constructor
 * @param {OO.ui.ToolGroup} toolGroup
 * @param {Object} [config] Configuration options
 */
ve.ui.TableCellDataFormatTool = function VeUiTableCellDataFormatTool( toolGroup, config ) {
	ve.ui.FormatTool.call( this, toolGroup, config );
};
OO.inheritClass( ve.ui.TableCellDataFormatTool, ve.ui.FormatTool );
ve.ui.TableCellDataFormatTool.static.name = 'tableCellData';
ve.ui.TableCellDataFormatTool.static.group = 'format';
ve.ui.TableCellDataFormatTool.static.title =
	OO.ui.deferMsg( 'visualeditor-table-format-data' );
ve.ui.TableCellDataFormatTool.static.format = { type: 'tableCell', attributes: { style: 'data' } };
ve.ui.TableCellDataFormatTool.static.commandName = 'tableCellData';
ve.ui.toolFactory.register( ve.ui.TableCellDataFormatTool );

/*!
 * VisualEditor UserInterface HistoryTool classes.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * UserInterface history tool.
 *
 * @class
 * @extends ve.ui.Tool
 * @constructor
 * @param {OO.ui.ToolGroup} toolGroup
 * @param {Object} [config] Configuration options
 */
ve.ui.HistoryTool = function VeUiHistoryTool( toolGroup, config ) {
	// Parent constructor
	ve.ui.Tool.call( this, toolGroup, config );

	// Events
	this.toolbar.getSurface().getModel().connect( this, { history: 'onHistory' } );

	// Initialization
	this.setDisabled( true );
};

/* Inheritance */

OO.inheritClass( ve.ui.HistoryTool, ve.ui.Tool );

/* Methods */

/**
 * Handle history events on the surface model
 */
ve.ui.HistoryTool.prototype.onHistory = function () {
	this.onUpdateState( this.toolbar.getSurface().getModel().getFragment() );
};

/**
 * @inheritdoc
 */
ve.ui.HistoryTool.prototype.destroy = function () {
	this.toolbar.getSurface().getModel().disconnect( this );
	ve.ui.HistoryTool.super.prototype.destroy.call( this );
};

/**
 * UserInterface undo tool.
 *
 * @class
 * @extends ve.ui.HistoryTool
 * @constructor
 * @param {OO.ui.ToolGroup} toolGroup
 * @param {Object} [config] Configuration options
 */
ve.ui.UndoHistoryTool = function VeUiUndoHistoryTool( toolGroup, config ) {
	ve.ui.HistoryTool.call( this, toolGroup, config );
};
OO.inheritClass( ve.ui.UndoHistoryTool, ve.ui.HistoryTool );
ve.ui.UndoHistoryTool.static.name = 'undo';
ve.ui.UndoHistoryTool.static.group = 'history';
ve.ui.UndoHistoryTool.static.icon = 'undo';
ve.ui.UndoHistoryTool.static.title =
	OO.ui.deferMsg( 'visualeditor-historybutton-undo-tooltip' );
ve.ui.UndoHistoryTool.static.commandName = 'undo';
ve.ui.toolFactory.register( ve.ui.UndoHistoryTool );

/**
 * UserInterface redo tool.
 *
 * @class
 * @extends ve.ui.HistoryTool
 * @constructor
 * @param {OO.ui.ToolGroup} toolGroup
 * @param {Object} [config] Configuration options
 */
ve.ui.RedoHistoryTool = function VeUiRedoHistoryTool( toolGroup, config ) {
	ve.ui.HistoryTool.call( this, toolGroup, config );
};
OO.inheritClass( ve.ui.RedoHistoryTool, ve.ui.HistoryTool );
ve.ui.RedoHistoryTool.static.name = 'redo';
ve.ui.RedoHistoryTool.static.group = 'history';
ve.ui.RedoHistoryTool.static.icon = 'redo';
ve.ui.RedoHistoryTool.static.title =
	OO.ui.deferMsg( 'visualeditor-historybutton-redo-tooltip' );
ve.ui.RedoHistoryTool.static.commandName = 'redo';
ve.ui.toolFactory.register( ve.ui.RedoHistoryTool );

/*!
 * VisualEditor UserInterface IndentationTool classes.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * UserInterface indentation tool.
 *
 * @abstract
 * @class
 * @extends ve.ui.Tool
 * @constructor
 * @param {OO.ui.ToolGroup} toolGroup
 * @param {Object} [config] Configuration options
 */
ve.ui.IndentationTool = function VeUiIndentationTool( toolGroup, config ) {
	// Parent constructor
	ve.ui.Tool.call( this, toolGroup, config );
};

/* Inheritance */

OO.inheritClass( ve.ui.IndentationTool, ve.ui.Tool );

/**
 * UserInterface indent tool.
 *
 * @class
 * @extends ve.ui.IndentationTool
 * @constructor
 * @param {OO.ui.ToolGroup} toolGroup
 * @param {Object} [config] Configuration options
 */
ve.ui.IncreaseIndentationTool = function VeUiIncreaseIndentationTool( toolGroup, config ) {
	ve.ui.IndentationTool.call( this, toolGroup, config );
};
OO.inheritClass( ve.ui.IncreaseIndentationTool, ve.ui.IndentationTool );
ve.ui.IncreaseIndentationTool.static.name = 'indent';
ve.ui.IncreaseIndentationTool.static.group = 'structure';
ve.ui.IncreaseIndentationTool.static.icon = 'indent-list';
ve.ui.IncreaseIndentationTool.static.title =
	OO.ui.deferMsg( 'visualeditor-indentationbutton-indent-tooltip' );
ve.ui.IncreaseIndentationTool.static.commandName = 'indent';
ve.ui.toolFactory.register( ve.ui.IncreaseIndentationTool );

/**
 * UserInterface outdent tool.
 *
 * TODO: Consistency between increase/decrease, indent/outdent and indent/unindent.
 *
 * @class
 * @extends ve.ui.IndentationTool
 * @constructor
 * @param {OO.ui.ToolGroup} toolGroup
 * @param {Object} [config] Configuration options
 */
ve.ui.DecreaseIndentationTool = function VeUiDecreaseIndentationTool( toolGroup, config ) {
	ve.ui.IndentationTool.call( this, toolGroup, config );
};
OO.inheritClass( ve.ui.DecreaseIndentationTool, ve.ui.IndentationTool );
ve.ui.DecreaseIndentationTool.static.name = 'outdent';
ve.ui.DecreaseIndentationTool.static.group = 'structure';
ve.ui.DecreaseIndentationTool.static.icon = 'outdent-list';
ve.ui.DecreaseIndentationTool.static.title =
	OO.ui.deferMsg( 'visualeditor-indentationbutton-outdent-tooltip' );
ve.ui.DecreaseIndentationTool.static.commandName = 'outdent';
ve.ui.toolFactory.register( ve.ui.DecreaseIndentationTool );

/*!
 * VisualEditor UserInterface InspectorTool classes.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * UserInterface inspector tool.
 *
 * @abstract
 * @class
 * @extends ve.ui.Tool
 * @constructor
 * @param {OO.ui.ToolGroup} toolGroup
 * @param {Object} [config] Configuration options
 */
ve.ui.InspectorTool = function VeUiInspectorTool( toolGroup, config ) {
	// Parent constructor
	ve.ui.Tool.call( this, toolGroup, config );
};

/* Inheritance */

OO.inheritClass( ve.ui.InspectorTool, ve.ui.Tool );

/* Static Properties */

/**
 * Annotation or node models this tool is related to.
 *
 * Used by #isCompatibleWith.
 *
 * @static
 * @property {Function[]}
 * @inheritable
 */
ve.ui.InspectorTool.static.modelClasses = [];

ve.ui.InspectorTool.static.deactivateOnSelect = false;

/**
 * @inheritdoc
 */
ve.ui.InspectorTool.static.isCompatibleWith = function ( model ) {
	return ve.isInstanceOfAny( model, this.modelClasses );
};

/* Methods */

/**
 * @inheritdoc
 */
ve.ui.InspectorTool.prototype.onUpdateState = function ( fragment ) {
	var i, len, models,
		active = false;

	// Parent method
	ve.ui.Tool.prototype.onUpdateState.apply( this, arguments );

	models = fragment ? fragment.getSelectedModels() : [];
	for ( i = 0, len = models.length; i < len; i++ ) {
		if ( this.constructor.static.isCompatibleWith( models[i] ) ) {
			active = true;
			break;
		}
	}
	this.setActive( active );
};

/**
 * UserInterface link tool.
 *
 * @class
 * @extends ve.ui.InspectorTool
 * @constructor
 * @param {OO.ui.ToolGroup} toolGroup
 * @param {Object} [config] Configuration options
 */
ve.ui.LinkInspectorTool = function VeUiLinkInspectorTool( toolGroup, config ) {
	ve.ui.InspectorTool.call( this, toolGroup, config );
};
OO.inheritClass( ve.ui.LinkInspectorTool, ve.ui.InspectorTool );
ve.ui.LinkInspectorTool.static.name = 'link';
ve.ui.LinkInspectorTool.static.group = 'meta';
ve.ui.LinkInspectorTool.static.icon = 'link';
ve.ui.LinkInspectorTool.static.title =
	OO.ui.deferMsg( 'visualeditor-annotationbutton-link-tooltip' );
ve.ui.LinkInspectorTool.static.modelClasses = [ ve.dm.LinkAnnotation ];
ve.ui.LinkInspectorTool.static.commandName = 'link';
ve.ui.toolFactory.register( ve.ui.LinkInspectorTool );

/**
 * UserInterface comment tool.
 *
 * @class
 * @extends ve.ui.InspectorTool
 * @constructor
 * @param {OO.ui.ToolGroup} toolGroup
 * @param {Object} [config] Configuration options
 */
ve.ui.CommentInspectorTool = function VeUiCommentInspectorTool( toolGroup, config ) {
	ve.ui.InspectorTool.call( this, toolGroup, config );
};
OO.inheritClass( ve.ui.CommentInspectorTool, ve.ui.InspectorTool );
ve.ui.CommentInspectorTool.static.name = 'comment';
ve.ui.CommentInspectorTool.static.group = 'meta';
ve.ui.CommentInspectorTool.static.icon = 'comment';
ve.ui.CommentInspectorTool.static.title =
	OO.ui.deferMsg( 'visualeditor-commentinspector-tooltip' );
ve.ui.CommentInspectorTool.static.modelClasses = [ ve.dm.CommentNode ];
ve.ui.CommentInspectorTool.static.commandName = 'comment';
ve.ui.CommentInspectorTool.static.deactivateOnSelect = true;
ve.ui.toolFactory.register( ve.ui.CommentInspectorTool );

/*!
 * VisualEditor UserInterface language tool class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * UserInterface language tool.
 *
 * @class
 * @extends ve.ui.InspectorTool
 * @constructor
 * @param {OO.ui.ToolGroup} toolGroup
 * @param {Object} [config] Configuration options
 */
ve.ui.LanguageInspectorTool = function VeUiLanguageInspectorTool( toolGroup, config ) {
	ve.ui.InspectorTool.call( this, toolGroup, config );
};
OO.inheritClass( ve.ui.LanguageInspectorTool, ve.ui.InspectorTool );
ve.ui.LanguageInspectorTool.static.name = 'language';
ve.ui.LanguageInspectorTool.static.group = 'meta';
ve.ui.LanguageInspectorTool.static.icon = 'language';
ve.ui.LanguageInspectorTool.static.title =
	OO.ui.deferMsg( 'visualeditor-annotationbutton-language-tooltip' );
ve.ui.LanguageInspectorTool.static.modelClasses = [ ve.dm.LanguageAnnotation ];
ve.ui.LanguageInspectorTool.static.commandName = 'language';
ve.ui.toolFactory.register( ve.ui.LanguageInspectorTool );

/*!
 * VisualEditor UserInterface ListTool classes.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * UserInterface list tool.
 *
 * @abstract
 * @class
 * @extends ve.ui.Tool
 * @constructor
 * @param {OO.ui.ToolGroup} toolGroup
 * @param {Object} [config] Configuration options
 */
ve.ui.ListTool = function VeUiListTool( toolGroup, config ) {
	// Parent constructor
	ve.ui.Tool.call( this, toolGroup, config );

	// Properties
	this.method = null;
};

/* Inheritance */

OO.inheritClass( ve.ui.ListTool, ve.ui.Tool );

/* Static Properties */

/**
 * List style the tool applies.
 *
 * @abstract
 * @static
 * @property {string}
 * @inheritable
 */
ve.ui.ListTool.static.style = '';

ve.ui.ListTool.static.deactivateOnSelect = false;

/* Methods */

/**
 * @inheritdoc
 */
ve.ui.ListTool.prototype.onUpdateState = function ( fragment ) {
	// Parent method
	ve.ui.Tool.prototype.onUpdateState.apply( this, arguments );

	var i, len,
		nodes = fragment ? fragment.getSelectedLeafNodes() : [],
		style = this.constructor.static.style,
		all = !!nodes.length;

	for ( i = 0, len = nodes.length; i < len; i++ ) {
		if ( !nodes[i].hasMatchingAncestor( 'list', { style: style } ) ) {
			all = false;
			break;
		}
	}
	this.setActive( all );
};

/**
 * UserInterface bullet tool.
 *
 * @class
 * @extends ve.ui.ListTool
 * @constructor
 * @param {OO.ui.ToolGroup} toolGroup
 * @param {Object} [config] Configuration options
 */
ve.ui.BulletListTool = function VeUiBulletListTool( toolGroup, config ) {
	ve.ui.ListTool.call( this, toolGroup, config );
};
OO.inheritClass( ve.ui.BulletListTool, ve.ui.ListTool );
ve.ui.BulletListTool.static.name = 'bullet';
ve.ui.BulletListTool.static.group = 'structure';
ve.ui.BulletListTool.static.icon = 'bullet-list';
ve.ui.BulletListTool.static.title =
	OO.ui.deferMsg( 'visualeditor-listbutton-bullet-tooltip' );
ve.ui.BulletListTool.static.style = 'bullet';
ve.ui.BulletListTool.static.commandName = 'bullet';
ve.ui.toolFactory.register( ve.ui.BulletListTool );

/**
 * UserInterface number tool.
 *
 * @class
 * @extends ve.ui.ListTool
 * @constructor
 * @param {OO.ui.ToolGroup} toolGroup
 * @param {Object} [config] Configuration options
 */
ve.ui.NumberListTool = function VeUiNumberListTool( toolGroup, config ) {
	ve.ui.ListTool.call( this, toolGroup, config );
};
OO.inheritClass( ve.ui.NumberListTool, ve.ui.ListTool );
ve.ui.NumberListTool.static.name = 'number';
ve.ui.NumberListTool.static.group = 'structure';
ve.ui.NumberListTool.static.icon = 'number-list';
ve.ui.NumberListTool.static.title =
	OO.ui.deferMsg( 'visualeditor-listbutton-number-tooltip' );
ve.ui.NumberListTool.static.style = 'number';
ve.ui.NumberListTool.static.commandName = 'number';
ve.ui.toolFactory.register( ve.ui.NumberListTool );

/*!
 * VisualEditor UserInterface ListTool classes.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see AUTHORS.txt
 * @license The MIT License (MIT); see LICENSE.txt
 */

/* Tools */

ve.ui.InsertTableTool = function VeUiInsertTableTool( toolGroup, config ) {
	ve.ui.Tool.call( this, toolGroup, config );
};
OO.inheritClass( ve.ui.InsertTableTool, ve.ui.Tool );
ve.ui.InsertTableTool.static.name = 'insertTable';
ve.ui.InsertTableTool.static.group = 'insert';
ve.ui.InsertTableTool.static.icon = 'table-insert';
ve.ui.InsertTableTool.static.title = OO.ui.deferMsg( 'visualeditor-table-insert-table' );
ve.ui.InsertTableTool.static.commandName = 'insertTable';
ve.ui.toolFactory.register( ve.ui.InsertTableTool );

ve.ui.DeleteTableTool = function VeUiDeleteTableTool( toolGroup, config ) {
	ve.ui.Tool.call( this, toolGroup, config );
};
OO.inheritClass( ve.ui.DeleteTableTool, ve.ui.Tool );
ve.ui.DeleteTableTool.static.name = 'deleteTable';
ve.ui.DeleteTableTool.static.group = 'table';
ve.ui.DeleteTableTool.static.autoAddToCatchall = false;
ve.ui.DeleteTableTool.static.icon = 'remove';
ve.ui.DeleteTableTool.static.title = OO.ui.deferMsg( 'visualeditor-table-delete-table' );
ve.ui.DeleteTableTool.static.commandName = 'deleteTable';
ve.ui.toolFactory.register( ve.ui.DeleteTableTool );

ve.ui.InsertRowBeforeTool = function VeUiInsertRowBeforeTool( toolGroup, config ) {
	ve.ui.Tool.call( this, toolGroup, config );
};
OO.inheritClass( ve.ui.InsertRowBeforeTool, ve.ui.Tool );
ve.ui.InsertRowBeforeTool.static.name = 'insertRowBefore';
ve.ui.InsertRowBeforeTool.static.group = 'table-row';
ve.ui.InsertRowBeforeTool.static.autoAddToCatchall = false;
ve.ui.InsertRowBeforeTool.static.icon = 'table-insert-row-before';
ve.ui.InsertRowBeforeTool.static.title =
	OO.ui.deferMsg( 'visualeditor-table-insert-row-before' );
ve.ui.InsertRowBeforeTool.static.commandName = 'insertRowBefore';
ve.ui.toolFactory.register( ve.ui.InsertRowBeforeTool );

ve.ui.InsertRowAfterTool = function VeUiInsertRowAfterTool( toolGroup, config ) {
	ve.ui.Tool.call( this, toolGroup, config );
};
OO.inheritClass( ve.ui.InsertRowAfterTool, ve.ui.Tool );
ve.ui.InsertRowAfterTool.static.name = 'insertRowAfter';
ve.ui.InsertRowAfterTool.static.group = 'table-row';
ve.ui.InsertRowAfterTool.static.autoAddToCatchall = false;
ve.ui.InsertRowAfterTool.static.icon = 'table-insert-row-after';
ve.ui.InsertRowAfterTool.static.title =
	OO.ui.deferMsg( 'visualeditor-table-insert-row-after' );
ve.ui.InsertRowAfterTool.static.commandName = 'insertRowAfter';
ve.ui.toolFactory.register( ve.ui.InsertRowAfterTool );

ve.ui.DeleteRowTool = function VeUiDeleteRowTool( toolGroup, config ) {
	ve.ui.Tool.call( this, toolGroup, config );
};
OO.inheritClass( ve.ui.DeleteRowTool, ve.ui.Tool );
ve.ui.DeleteRowTool.static.name = 'deleteRow';
ve.ui.DeleteRowTool.static.group = 'table-row';
ve.ui.DeleteRowTool.static.autoAddToCatchall = false;
ve.ui.DeleteRowTool.static.icon = 'remove';
ve.ui.DeleteRowTool.static.title =
	OO.ui.deferMsg( 'visualeditor-table-delete-row' );
ve.ui.DeleteRowTool.static.commandName = 'deleteRow';
ve.ui.toolFactory.register( ve.ui.DeleteRowTool );

ve.ui.InsertColumnBeforeTool = function VeUiInsertColumnBeforeTool( toolGroup, config ) {
	ve.ui.Tool.call( this, toolGroup, config );
};
OO.inheritClass( ve.ui.InsertColumnBeforeTool, ve.ui.Tool );
ve.ui.InsertColumnBeforeTool.static.name = 'insertColumnBefore';
ve.ui.InsertColumnBeforeTool.static.group = 'table-col';
ve.ui.InsertColumnBeforeTool.static.autoAddToCatchall = false;
ve.ui.InsertColumnBeforeTool.static.icon = 'table-insert-column-before';
ve.ui.InsertColumnBeforeTool.static.title =
	OO.ui.deferMsg( 'visualeditor-table-insert-col-before' );
ve.ui.InsertColumnBeforeTool.static.commandName = 'insertColumnBefore';
ve.ui.toolFactory.register( ve.ui.InsertColumnBeforeTool );

ve.ui.InsertColumnAfterTool = function VeUiInsertColumnAfterTool( toolGroup, config ) {
	ve.ui.Tool.call( this, toolGroup, config );
};
OO.inheritClass( ve.ui.InsertColumnAfterTool, ve.ui.Tool );
ve.ui.InsertColumnAfterTool.static.name = 'insertColumnAfter';
ve.ui.InsertColumnAfterTool.static.group = 'table-col';
ve.ui.InsertColumnAfterTool.static.autoAddToCatchall = false;
ve.ui.InsertColumnAfterTool.static.icon = 'table-insert-column-after';
ve.ui.InsertColumnAfterTool.static.title =
	OO.ui.deferMsg( 'visualeditor-table-insert-col-after' );
ve.ui.InsertColumnAfterTool.static.commandName = 'insertColumnAfter';
ve.ui.toolFactory.register( ve.ui.InsertColumnAfterTool );

ve.ui.DeleteColumnTool = function VeUiDeleteColumnTool( toolGroup, config ) {
	ve.ui.Tool.call( this, toolGroup, config );
};
OO.inheritClass( ve.ui.DeleteColumnTool, ve.ui.Tool );
ve.ui.DeleteColumnTool.static.name = 'deleteColumn';
ve.ui.DeleteColumnTool.static.group = 'table-col';
ve.ui.DeleteColumnTool.static.autoAddToCatchall = false;
ve.ui.DeleteColumnTool.static.icon = 'remove';
ve.ui.DeleteColumnTool.static.title =
	OO.ui.deferMsg( 'visualeditor-table-delete-col' );
ve.ui.DeleteColumnTool.static.commandName = 'deleteColumn';
ve.ui.toolFactory.register( ve.ui.DeleteColumnTool );

ve.ui.MergeCellsTool = function VeUiMergeCellsTool( toolGroup, config ) {
	ve.ui.Tool.call( this, toolGroup, config );
};
OO.inheritClass( ve.ui.MergeCellsTool, ve.ui.Tool );
ve.ui.MergeCellsTool.static.name = 'mergeCells';
ve.ui.MergeCellsTool.static.group = 'table';
ve.ui.MergeCellsTool.static.autoAddToCatchall = false;
ve.ui.MergeCellsTool.static.icon = 'table-merge-cells';
ve.ui.MergeCellsTool.static.title =
	OO.ui.deferMsg( 'visualeditor-table-merge-cells' );
ve.ui.MergeCellsTool.static.commandName = 'mergeCells';
ve.ui.MergeCellsTool.static.deactivateOnSelect = false;

ve.ui.MergeCellsTool.prototype.onUpdateState = function ( fragment ) {
	// Parent method
	ve.ui.MergeCellsTool.super.prototype.onUpdateState.apply( this, arguments );

	if ( this.isDisabled() ) {
		this.setActive( false );
		return;
	}

	// If not disabled, selection must be table and spanning multiple matrix cells
	this.setActive( fragment.getSelection().isSingleCell() );
};
ve.ui.toolFactory.register( ve.ui.MergeCellsTool );

ve.ui.TableCaptionTool = function VeUiTableCaptionTool( toolGroup, config ) {
	ve.ui.Tool.call( this, toolGroup, config );
};
OO.inheritClass( ve.ui.TableCaptionTool, ve.ui.Tool );
ve.ui.TableCaptionTool.static.name = 'tableCaption';
ve.ui.TableCaptionTool.static.group = 'table';
ve.ui.TableCaptionTool.static.autoAddToCatchall = false;
ve.ui.TableCaptionTool.static.icon = 'table-caption';
ve.ui.TableCaptionTool.static.title =
	OO.ui.deferMsg( 'visualeditor-table-caption' );
ve.ui.TableCaptionTool.static.commandName = 'tableCaption';
ve.ui.TableCaptionTool.static.deactivateOnSelect = false;

ve.ui.TableCaptionTool.prototype.onUpdateState = function ( fragment ) {
	// Parent method
	ve.ui.TableCaptionTool.super.prototype.onUpdateState.apply( this, arguments );

	if ( this.isDisabled() ) {
		this.setActive( false );
		return;
	}

	var hasCaptionNode,
		selection = fragment.getSelection();

	if ( selection instanceof ve.dm.TableSelection ) {
		hasCaptionNode = !!selection.getTableNode().getCaptionNode();
	} else {
		// If not disabled, linear selection must have a caption
		hasCaptionNode = true;
	}
	this.setActive( hasCaptionNode );
};
ve.ui.toolFactory.register( ve.ui.TableCaptionTool );

/*!
 * VisualEditor UserInterface FragmentInspector class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Inspector for working with fragments of content.
 *
 * @class
 * @extends OO.ui.ProcessDialog
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
ve.ui.FragmentInspector = function VeUiFragmentInspector( config ) {
	// Parent constructor
	ve.ui.FragmentInspector.super.call( this, config );

	// Properties
	this.fragment = null;
	this.previousSelection = null;
};

/* Inheritance */

OO.inheritClass( ve.ui.FragmentInspector, OO.ui.ProcessDialog );

/* Static Properties */

ve.ui.FragmentInspector.static.actions = ve.ui.FragmentInspector.super.static.actions.concat( [
	{
		action: 'done',
		label: OO.ui.deferMsg( 'visualeditor-dialog-action-done' ),
		flags: [ 'progressive', 'primary' ],
		modes: 'edit'
	},
	{
		action: 'done',
		label: OO.ui.deferMsg( 'visualeditor-dialog-action-insert' ),
		flags: [ 'constructive', 'primary' ],
		modes: 'insert'
	}
] );

/* Methods */

/**
 * Handle form submit events.
 *
 * Executes the 'done' action when the user presses enter in the form.
 *
 * @method
 */
ve.ui.FragmentInspector.prototype.onFormSubmit = function () {
	this.executeAction( 'done' );
};

/**
 * Get the surface fragment the inspector is for.
 *
 * @returns {ve.dm.SurfaceFragment|null} Surface fragment the inspector is for, null if the
 *   inspector is closed
 */
ve.ui.FragmentInspector.prototype.getFragment = function () {
	return this.fragment;
};

/**
 * Get a symbolic mode name.
 *
 * @localdoc If the fragment being inspected selects at least one model the mode will be `edit`,
 *   otherwise the mode will be `insert`
 *
 * @return {string} Symbolic mode name
 */
ve.ui.FragmentInspector.prototype.getMode = function () {
	if ( this.fragment ) {
		return this.fragment.getSelectedModels().length ? 'edit' : 'insert';
	}
	return '';
};

/**
 * @inheritdoc
 */
ve.ui.FragmentInspector.prototype.initialize = function () {
	// Parent method
	ve.ui.FragmentInspector.super.prototype.initialize.call( this );

	// Properties
	this.container = new OO.ui.PanelLayout( {
		$: this.$, scrollable: true, classes: [ 've-ui-fragmentInspector-container' ]
	} );
	this.form = new OO.ui.FormLayout( {
		$: this.$, classes: [ 've-ui-fragmentInspector-form' ]
	} );

	// Events
	this.form.connect( this, { submit: 'onFormSubmit' } );

	// Initialization
	this.$element.addClass( 've-ui-fragmentInspector' );
	this.$content.addClass( 've-ui-fragmentInspector-content' );
	this.container.$element.append( this.form.$element, this.$otherActions );
	this.$body.append( this.container.$element );
};

/**
 * @inheritdoc
 */
ve.ui.FragmentInspector.prototype.getActionProcess = function ( action ) {
	if ( action === 'done' ) {
		return new OO.ui.Process( function () {
			this.close( { action: 'done' } );
		}, this );
	}
	return ve.ui.FragmentInspector.super.prototype.getActionProcess.call( this, action );
};

/**
 * @inheritdoc
 */
ve.ui.FragmentInspector.prototype.getSetupProcess = function ( data ) {
	data = data || {};
	return ve.ui.FragmentInspector.super.prototype.getSetupProcess.call( this, data )
		.first( function () {
			if ( !( data.fragment instanceof ve.dm.SurfaceFragment ) ) {
				throw new Error( 'Cannot open inspector: opening data must contain a fragment' );
			}
			this.fragment = data.fragment;
			this.previousSelection = this.fragment.getSelection();
		}, this )
		.next( function () {
			this.actions.setMode( this.getMode() );
		}, this );
};

/**
 * @inheritdoc
 */
ve.ui.FragmentInspector.prototype.getTeardownProcess = function ( data ) {
	return ve.ui.FragmentDialog.super.prototype.getTeardownProcess.apply( this, data )
		.next( function () {
			this.fragment = null;
			this.previousSelection = null;
		}, this );
};

/**
 * @inheritdoc
 */
ve.ui.FragmentInspector.prototype.getReadyProcess = function ( data ) {
	return ve.ui.FragmentInspector.super.prototype.getReadyProcess.call( this, data )
		// Add a 0ms timeout before doing anything. Because... Internet Explorer :(
		.first( 0 );
};

/**
 * @inheritdoc
 */
ve.ui.FragmentInspector.prototype.getBodyHeight = function () {
	// HACK: Chrome gets the height wrong by 1px for elements with opacity < 1
	// e.g. a disabled button.
	return Math.ceil( this.container.$element[0].scrollHeight ) + 1;
};

/*!
 * VisualEditor UserInterface AnnotationInspector class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Inspector for working with content annotations.
 *
 * @class
 * @abstract
 * @extends ve.ui.FragmentInspector
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
ve.ui.AnnotationInspector = function VeUiAnnotationInspector( config ) {
	// Parent constructor
	ve.ui.FragmentInspector.call( this, config );

	// Properties
	this.initialSelection = null;
	this.initialAnnotation = null;
	this.initialAnnotationIsCovering = false;
};

/* Inheritance */

OO.inheritClass( ve.ui.AnnotationInspector, ve.ui.FragmentInspector );

/**
 * Annotation models this inspector can edit.
 *
 * @static
 * @inheritable
 * @property {Function[]}
 */
ve.ui.AnnotationInspector.static.modelClasses = [];

ve.ui.AnnotationInspector.static.actions = [
	{
		action: 'remove',
		label: OO.ui.deferMsg( 'visualeditor-inspector-remove-tooltip' ),
		flags: 'destructive',
		modes: 'edit'
	}
].concat( ve.ui.FragmentInspector.static.actions );

/* Methods */

/**
 * Check if form is empty, which if saved should result in removing the annotation.
 *
 * Only override this if the form provides the user a way to blank out primary information, allowing
 * them to remove the annotation by clearing the form.
 *
 * @returns {boolean} Form is empty
 */
ve.ui.AnnotationInspector.prototype.shouldRemoveAnnotation = function () {
	return false;
};

/**
 * Get data to insert if nothing was selected when the inspector opened.
 *
 * Defaults to using #getInsertionText.
 *
 * @returns {Array} Linear model content to insert
 */
ve.ui.AnnotationInspector.prototype.getInsertionData = function () {
	return this.getInsertionText().split( '' );
};

/**
 * Get text to insert if nothing was selected when the inspector opened.
 *
 * @returns {string} Text to insert
 */
ve.ui.AnnotationInspector.prototype.getInsertionText = function () {
	return '';
};

/**
 * Get the annotation object to apply.
 *
 * This method is called when the inspector is closing, and should return the annotation to apply
 * to the text. If this method returns a falsey value like null, no annotation will be applied,
 * but existing annotations won't be removed either.
 *
 * @abstract
 * @returns {ve.dm.Annotation} Annotation to apply
 * @throws {Error} If not overridden in subclass
 */
ve.ui.AnnotationInspector.prototype.getAnnotation = function () {
	throw new Error(
		've.ui.AnnotationInspector.getAnnotation not implemented in subclass'
	);
};

/**
 * Get an annotation object from a fragment.
 *
 * @abstract
 * @param {ve.dm.SurfaceFragment} fragment Surface fragment
 * @returns {ve.dm.Annotation} Annotation
 * @throws {Error} If not overridden in a subclass
 */
ve.ui.AnnotationInspector.prototype.getAnnotationFromFragment = function () {
	throw new Error(
		've.ui.AnnotationInspector.getAnnotationFromFragment not implemented in subclass'
	);
};

/**
 * Get matching annotations within a fragment.
 *
 * @method
 * @param {ve.dm.SurfaceFragment} fragment Fragment to get matching annotations within
 * @param {boolean} [all] Get annotations which only cover some of the fragment
 * @returns {ve.dm.AnnotationSet} Matching annotations
 */
ve.ui.AnnotationInspector.prototype.getMatchingAnnotations = function ( fragment, all ) {
	var modelClasses = this.constructor.static.modelClasses;

	return fragment.getAnnotations( all ).filter( function ( annotation ) {
		return ve.isInstanceOfAny( annotation, modelClasses );
	} );
};

/**
 * @inheritdoc
 */
ve.ui.AnnotationInspector.prototype.getMode = function () {
	if ( this.fragment ) {
		// Trim the fragment before getting selected models to match the behavior of
		// #getSetupProcess
		return this.fragment.trimLinearSelection().getSelectedModels().length ? 'edit' : 'insert';
	}
	return '';
};

/**
 * @inheritdoc
 */
ve.ui.AnnotationInspector.prototype.getActionProcess = function ( action ) {
	if ( action === 'remove' ) {
		return new OO.ui.Process( function () {
			this.close( { action: 'remove' } );
		}, this );
	}
	return ve.ui.AnnotationInspector.super.prototype.getActionProcess.call( this, action );
};

/**
 * Handle the inspector being setup.
 *
 * There are 4 scenarios:
 *
 * - Zero-length selection not near a word -> no change, text will be inserted on close
 * - Zero-length selection inside or adjacent to a word -> expand selection to cover word
 * - Selection covering non-annotated text -> trim selection to remove leading/trailing whitespace
 * - Selection covering annotated text -> expand selection to cover annotation
 *
 * @method
 * @param {Object} [data] Inspector opening data
 */
ve.ui.AnnotationInspector.prototype.getSetupProcess = function ( data ) {
	return ve.ui.AnnotationInspector.super.prototype.getSetupProcess.call( this, data )
		.next( function () {
			var expandedFragment, trimmedFragment, initialCoveringAnnotation,
				inspector = this,
				annotationSet, annotations,
				fragment = this.getFragment(),
				surfaceModel = fragment.getSurface(),
				annotation = this.getMatchingAnnotations( fragment, true ).get( 0 );

			surfaceModel.pushStaging();

			// Initialize range
			if ( this.previousSelection instanceof ve.dm.LinearSelection && !annotation ) {
				if (
					fragment.getSelection().isCollapsed() &&
					fragment.getDocument().data.isContentOffset( fragment.getSelection().getRange().start )
				) {
					// Expand to nearest word
					expandedFragment = fragment.expandLinearSelection( 'word' );
					fragment = expandedFragment;

					// TODO: We should review how getMatchingAnnotation works in light of the fact
					// that in the case of a collapsed range, the method falls back to retrieving
					// insertion annotations.

					// Check if we're inside a relevant annotation and if so, define it
					annotationSet = fragment.document.data.getAnnotationsFromRange( fragment.selection.range );
					annotations = annotationSet.filter( function ( existingAnnotation ) {
						return ve.isInstanceOfAny( existingAnnotation, inspector.constructor.static.modelClasses );
					} );
					if ( annotations.getLength() > 0 ) {
						// We're in the middle of an annotation, let's make sure we expand
						// our selection to include the entire existing annotation
						annotation = annotations.get( 0 );
					}
				} else {
					// Trim whitespace
					trimmedFragment = fragment.trimLinearSelection();
					fragment = trimmedFragment;
				}

				if ( !fragment.getSelection().isCollapsed() && !annotation ) {
					// Create annotation from selection
					annotation = this.getAnnotationFromFragment( fragment );
					if ( annotation ) {
						fragment.annotateContent( 'set', annotation );
					}
				}
			}
			if ( annotation ) {
				// Expand range to cover annotation
				expandedFragment = fragment.expandLinearSelection( 'annotation', annotation );
				fragment = expandedFragment;
			}

			// Update selection
			fragment.select();
			this.initialSelection = fragment.getSelection();

			// The initial annotation is the first matching annotation in the fragment
			this.initialAnnotation = this.getMatchingAnnotations( fragment, true ).get( 0 );
			initialCoveringAnnotation = this.getMatchingAnnotations( fragment ).get( 0 );
			// Fallback to a default annotation
			if ( !this.initialAnnotation ) {
				this.initialAnnotation = this.getAnnotationFromFragment( fragment );
			} else if (
				initialCoveringAnnotation &&
				initialCoveringAnnotation.compareTo( this.initialAnnotation )
			) {
				// If the initial annotation doesn't cover the fragment, record this as we'll need
				// to forcefully apply it to the rest of the fragment later
				this.initialAnnotationIsCovering = true;
			}

			this.fragment = fragment;

			// Set the mode - this was done already in FragmentInspector but now that we may have
			// changed what the fragment is covering we need to run it again
			this.actions.setMode( this.getMode() );
		}, this );
};

/**
 * @inheritdoc
 */
ve.ui.AnnotationInspector.prototype.getTeardownProcess = function ( data ) {
	data = data || {};
	return ve.ui.AnnotationInspector.super.prototype.getTeardownProcess.call( this, data )
		.first( function () {
			var i, len, annotations, insertion,
				insertionAnnotation = false,
				insertText = false,
				replace = false,
				annotation = this.getAnnotation(),
				remove = this.shouldRemoveAnnotation() || data.action === 'remove',
				surfaceModel = this.fragment.getSurface(),
				fragment = surfaceModel.getFragment( this.initialSelection, false ),
				selection = this.fragment.getSelection();

			if (
				!( selection instanceof ve.dm.LinearSelection ) ||
				( remove && selection.getRange().isCollapsed() )
			) {
				// Since we pushStaging on SetupProcess we need to make sure
				// all terminations pop
				surfaceModel.popStaging();
				return;
			}

			if ( !remove ) {
				if ( this.initialSelection.isCollapsed() ) {
					if ( data.action !== 'done' ) {
						surfaceModel.popStaging();
						return;
					}
					insertText = true;
				}
				if ( annotation ) {
					// Check if the initial annotation has changed, or didn't cover the whole fragment
					// to begin with
					if (
						!this.initialAnnotationIsCovering ||
						!this.initialAnnotation ||
						!this.initialAnnotation.compareTo( annotation )
					) {
						replace = true;
					}
				}
			}
			// If we are setting a new annotation, clear any annotations the inspector may have
			// applied up to this point. Otherwise keep them.
			if ( replace ) {
				surfaceModel.popStaging();
			} else {
				surfaceModel.applyStaging();
			}
			if ( insertText ) {
				insertion = this.getInsertionData();
				if ( insertion.length ) {
					fragment.insertContent( insertion, true );
					// Move cursor to the end of the inserted content, even if back button is used
					fragment.adjustLinearSelection( -insertion.length, 0 );
					this.previousSelection = new ve.dm.LinearSelection( fragment.getDocument(), new ve.Range(
						this.initialSelection.getRange().start + insertion.length
					) );
				}
			}
			if ( remove || replace ) {
				// Clear all existing annotations
				annotations = this.getMatchingAnnotations( fragment, true ).get();
				for ( i = 0, len = annotations.length; i < len; i++ ) {
					fragment.annotateContent( 'clear', annotations[i] );
				}
			}
			if ( replace ) {
				// Apply new annotation
				if ( fragment.getSelection().isCollapsed() ) {
					insertionAnnotation = true;
				} else {
					fragment.annotateContent( 'set', annotation );
				}
			}
			if ( !data.action || insertText ) {
				// Restore selection to what it was before we expanded it
				selection = this.previousSelection;
			}
			if ( data.action ) {
				surfaceModel.setSelection( selection );
			}

			if ( insertionAnnotation ) {
				surfaceModel.addInsertionAnnotations( annotation );
			}
		}, this )
		.next( function () {
			// Reset state
			this.initialSelection = null;
			this.initialAnnotation = null;
			this.initialAnnotationIsCovering = false;
		}, this );
};

/*!
 * VisualEditor user interface NodeInspector class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Inspector for working with a node.
 *
 * @class
 * @extends ve.ui.FragmentInspector
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
ve.ui.NodeInspector = function VeUiNodeInspector( config ) {
	// Parent constructor
	ve.ui.FragmentInspector.call( this, config );

	// Properties
	this.selectedNode = null;
};

/* Inheritance */

OO.inheritClass( ve.ui.NodeInspector, ve.ui.FragmentInspector );

/* Static Properties */

/**
 * Node classes compatible with this dialog.
 *
 * @static
 * @property {Function}
 * @inheritable
 */
ve.ui.NodeInspector.static.modelClasses = [];

/* Methods */

/**
 * Get the selected node.
 *
 * Should only be called after setup and before teardown.
 * If no node is selected or the selected node is incompatible, null will be returned.
 *
 * @param {Object} [data] Inspector opening data
 * @return {ve.dm.Node} Selected node
 */
ve.ui.NodeInspector.prototype.getSelectedNode = function () {
	var i, len,
		modelClasses = this.constructor.static.modelClasses,
		selectedNode = this.getFragment().getSelectedNode();

	for ( i = 0, len = modelClasses.length; i < len; i++ ) {
		if ( selectedNode instanceof modelClasses[i] ) {
			return selectedNode;
		}
	}
	return null;
};

/**
 * @inheritdoc
 */
ve.ui.NodeInspector.prototype.initialize = function ( data ) {
	// Parent method
	ve.ui.NodeInspector.super.prototype.initialize.call( this, data );

	// Initialization
	this.$content.addClass( 've-ui-nodeInspector' );
};

/**
 * @inheritdoc
 */
ve.ui.NodeInspector.prototype.getSetupProcess = function ( data ) {
	return ve.ui.NodeInspector.super.prototype.getSetupProcess.call( this, data )
		.next( function () {
			this.selectedNode = this.getSelectedNode( data );
		}, this );
};

/**
 * @inheritdoc
 */
ve.ui.NodeInspector.prototype.getTeardownProcess = function ( data ) {
	return ve.ui.NodeInspector.super.prototype.getTeardownProcess.call( this, data )
		.next( function () {
			this.selectedNode = null;
		}, this );
};

/*!
 * VisualEditor UserInterface LinkInspector class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Inspector for linked content.
 *
 * @class
 * @extends ve.ui.AnnotationInspector
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
ve.ui.LinkInspector = function VeUiLinkInspector( config ) {
	// Parent constructor
	ve.ui.AnnotationInspector.call( this, config );
};

/* Inheritance */

OO.inheritClass( ve.ui.LinkInspector, ve.ui.AnnotationInspector );

/* Static properties */

ve.ui.LinkInspector.static.name = 'link';

ve.ui.LinkInspector.static.title = OO.ui.deferMsg( 'visualeditor-linkinspector-title' );

ve.ui.LinkInspector.static.linkTargetInputWidget = ve.ui.LinkTargetInputWidget;

ve.ui.LinkInspector.static.modelClasses = [ ve.dm.LinkAnnotation ];

ve.ui.LinkInspector.static.actions = ve.ui.LinkInspector.super.static.actions.concat( [
	{
		action: 'open',
		label: OO.ui.deferMsg( 'visualeditor-linkinspector-open' ),
		modes: [ 'edit', 'insert' ]
	}
] );

/* Methods */

/**
 * Handle target input change events.
 *
 * Updates the open button's hyperlink location.
 *
 * @param {string} value New target input value
 */
ve.ui.LinkInspector.prototype.onTargetInputChange = function () {
	var href = this.targetInput.getHref(),
		inspector = this;
	this.targetInput.isValid().done( function ( valid ) {
		inspector.actions.forEach( { actions: 'open' }, function ( action ) {
			action.setHref( href ).setTarget( '_blank' ).setDisabled( !valid );
			// HACK: Chrome renders a dark outline around the action when it's a link, but causing it to
			// re-render makes it magically go away; this is incredibly evil and needs further
			// investigation
			action.$element.hide().fadeIn( 0 );
		} );
	} );
};

/**
 * @inheritdoc
 */
ve.ui.LinkInspector.prototype.shouldRemoveAnnotation = function () {
	return !this.targetInput.getValue().length;
};

/**
 * @inheritdoc
 */
ve.ui.LinkInspector.prototype.getInsertionText = function () {
	return this.targetInput.getValue();
};

/**
 * @inheritdoc
 */
ve.ui.LinkInspector.prototype.getAnnotation = function () {
	return this.targetInput.getAnnotation();
};

/**
 * @inheritdoc
 */
ve.ui.LinkInspector.prototype.getAnnotationFromFragment = function ( fragment ) {
	return new ve.dm.LinkAnnotation( {
		type: 'link',
		attributes: { href: fragment.getText() }
	} );
};

/**
 * @inheritdoc
 */
ve.ui.LinkInspector.prototype.initialize = function () {
	var overlay = this.manager.getOverlay();

	// Parent method
	ve.ui.LinkInspector.super.prototype.initialize.call( this );

	// Properties
	this.targetInput = new this.constructor.static.linkTargetInputWidget( {
		$: this.$,
		$overlay: overlay ? overlay.$element : this.$frame,
		disabled: true,
		classes: [ 've-ui-linkInspector-target' ]
	} );

	// Events
	this.targetInput.connect( this, { change: 'onTargetInputChange' } );

	// Initialization
	this.$content.addClass( 've-ui-linkInspector-content' );
	this.form.$element.append( this.targetInput.$element );
};

/**
 * @inheritdoc
 */
ve.ui.LinkInspector.prototype.getSetupProcess = function ( data ) {
	return ve.ui.LinkInspector.super.prototype.getSetupProcess.call( this, data )
		.next( function () {
			// Disable surface until animation is complete; will be reenabled in ready()
			this.getFragment().getSurface().disable();
			this.targetInput.setAnnotation( this.initialAnnotation );
		}, this );
};

/**
 * @inheritdoc
 */
ve.ui.LinkInspector.prototype.getReadyProcess = function ( data ) {
	return ve.ui.LinkInspector.super.prototype.getReadyProcess.call( this, data )
		.next( function () {
			this.targetInput.setDisabled( false ).focus().select();
			this.getFragment().getSurface().enable();
			this.onTargetInputChange();
		}, this );
};

/**
 * @inheritdoc
 */
ve.ui.LinkInspector.prototype.getHoldProcess = function ( data ) {
	return ve.ui.LinkInspector.super.prototype.getHoldProcess.call( this, data )
		.next( function () {
			this.targetInput.setDisabled( true ).blur();
		}, this );
};

/**
 * @inheritdoc
 */
ve.ui.LinkInspector.prototype.getTeardownProcess = function ( data ) {
	return ve.ui.LinkInspector.super.prototype.getTeardownProcess.call( this, data )
		.next( function () {
			this.targetInput.setAnnotation( null );
		}, this );
};

/* Registration */

ve.ui.windowFactory.register( ve.ui.LinkInspector );

/*!
 * VisualEditor UserInterface CommentInspector class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Comment inspector.
 *
 * @class
 * @extends ve.ui.NodeInspector
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
ve.ui.CommentInspector = function VeUiCommentInspector( config ) {
	// Parent constructor
	ve.ui.NodeInspector.call( this, config );
};

/* Inheritance */

OO.inheritClass( ve.ui.CommentInspector, ve.ui.NodeInspector );

/* Static properties */

ve.ui.CommentInspector.static.name = 'comment';

ve.ui.CommentInspector.static.icon = 'comment';

ve.ui.CommentInspector.static.title =
	OO.ui.deferMsg( 'visualeditor-commentinspector-title' );

ve.ui.CommentInspector.static.modelClasses = [ ve.dm.CommentNode ];

ve.ui.CommentInspector.static.size = 'large';

ve.ui.CommentInspector.static.actions = [
	{
		action: 'remove',
		label: OO.ui.deferMsg( 'visualeditor-inspector-remove-tooltip' ),
		flags: 'destructive',
		modes: 'edit'
	}
].concat( ve.ui.FragmentInspector.static.actions );

/**
 * Handle frame ready events.
 *
 * @method
 */
ve.ui.CommentInspector.prototype.initialize = function () {
	// Parent method
	ve.ui.CommentInspector.super.prototype.initialize.call( this );

	this.textWidget = new ve.ui.WhitespacePreservingTextInputWidget( {
		$: this.$,
		multiline: true,
		autosize: true
	} );
	this.previousTextWidgetHeight = 0;

	this.textWidget.connect( this, { change: 'onTextInputWidgetChange' } );

	this.$content.addClass( 've-ui-commentInspector-content' );
	this.form.$element.append( this.textWidget.$element );
};

/**
 * Called when the text input widget value has changed.
 */
ve.ui.CommentInspector.prototype.onTextInputWidgetChange = function () {
	var height = this.textWidget.$element.height();
	if ( height !== this.previousTextWidgetHeight ) {
		this.updateSize();
		this.previousTextWidgetHeight = height;
	}
};

/**
 * @inheritdoc
 */
ve.ui.CommentInspector.prototype.getActionProcess = function ( action ) {
	if ( action === 'remove' || action === 'insert' ) {
		return new OO.ui.Process( function () {
			this.close( { action: action } );
		}, this );
	}
	return ve.ui.CommentInspector.super.prototype.getActionProcess.call( this, action );
};

/**
 * Handle the inspector being setup.
 *
 * @method
 * @param {Object} [data] Inspector opening data
 */
ve.ui.CommentInspector.prototype.getSetupProcess = function ( data ) {
	return ve.ui.CommentInspector.super.prototype.getSetupProcess.call( this, data )
		.next( function () {
			this.getFragment().getSurface().pushStaging();

			this.commentNode = this.getSelectedNode();
			if ( this.commentNode ) {
				this.textWidget.setValueAndWhitespace( this.commentNode.getAttribute( 'text' ) || '' );
			} else {
				this.textWidget.setWhitespace( [ ' ', ' ' ] );
				this.getFragment().insertContent( [
					{
						type: 'comment',
						attributes: { text: '' }
					},
					{ type: '/comment' }
				] );
				this.commentNode = this.getSelectedNode();
			}
		}, this );
};

/**
 * @inheritdoc
 */
ve.ui.CommentInspector.prototype.getReadyProcess = function ( data ) {
	return ve.ui.CommentInspector.super.prototype.getReadyProcess.call( this, data )
		.next( function () {
			this.getFragment().getSurface().enable();
			this.textWidget.focus();
		}, this );
};

/**
 * @inheritdoc
 */
ve.ui.CommentInspector.prototype.getTeardownProcess = function ( data ) {
	data = data || {};
	return ve.ui.CommentInspector.super.prototype.getTeardownProcess.call( this, data )
		.first( function () {
			var surfaceModel = this.getFragment().getSurface(),
				text = this.textWidget.getValue(),
				innerText = this.textWidget.getInnerValue();

			if ( data.action === 'remove' || innerText === '' ) {
				surfaceModel.popStaging();
				// If popStaging removed the node then this will be a no-op
				this.getFragment().removeContent();
			} else {
				// Edit comment node
				this.getFragment().changeAttributes( { text: text } );
				surfaceModel.applyStaging();
			}

			// Reset inspector
			this.textWidget.setValueAndWhitespace( '' );
		}, this );
};

/* Registration */

ve.ui.windowFactory.register( ve.ui.CommentInspector );

/*!
 * VisualEditor UserInterface LanguageInspector class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Inspector for specifying the language of content.
 *
 * @class
 * @extends ve.ui.AnnotationInspector
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
ve.ui.LanguageInspector = function VeUiLanguageInspector( config ) {
	// Parent constructor
	ve.ui.AnnotationInspector.call( this, config );
};

/* Inheritance */

OO.inheritClass( ve.ui.LanguageInspector, ve.ui.AnnotationInspector );

/* Static properties */

ve.ui.LanguageInspector.static.name = 'language';

ve.ui.LanguageInspector.static.title =
	OO.ui.deferMsg( 'visualeditor-languageinspector-title' );

ve.ui.LanguageInspector.static.modelClasses = [ ve.dm.LanguageAnnotation ];

/* Methods */

/**
 * @inheritdoc
 */
ve.ui.LanguageInspector.prototype.getAnnotation = function () {
	var lang = this.languageInput.getLang(),
		dir = this.languageInput.getDir();
	return ( lang || dir ?
		new ve.dm.LanguageAnnotation( {
			type: 'meta/language',
			attributes: {
				lang: lang,
				dir: dir
			}
		} ) :
		null
	);
};

/**
 * @inheritdoc
 */
ve.ui.LanguageInspector.prototype.getAnnotationFromFragment = function ( fragment ) {
	return new ve.dm.LanguageAnnotation( {
		type: 'meta/language',
		attributes: {
			lang: fragment.getDocument().getLang(),
			dir: fragment.getDocument().getDir()
		}
	} );
};

/**
 * @inheritdoc
 */
ve.ui.LanguageInspector.prototype.initialize = function () {
	// Parent method
	ve.ui.LanguageInspector.super.prototype.initialize.call( this );

	// Properties
	this.languageInput = new ve.ui.LanguageInputWidget( {
		$: this.$,
		dialogManager: this.manager.getSurface().getDialogs()
	} );

	// Initialization
	this.form.$element.append( this.languageInput.$element );
};

/**
 * @inheritdoc
 */
ve.ui.LanguageInspector.prototype.getSetupProcess = function ( data ) {
	return ve.ui.LanguageInspector.super.prototype.getSetupProcess.call( this, data )
		.next( function () {
			this.languageInput.setLangAndDir(
				this.initialAnnotation.getAttribute( 'lang' ),
				this.initialAnnotation.getAttribute( 'dir' )
			);
		}, this );
};

/* Registration */

ve.ui.windowFactory.register( ve.ui.LanguageInspector );

/*!
 * VisualEditor user interface SpecialCharacterPage class.
 *
 * @copyright 2011-2014 VisualEditor Team and others; see AUTHORS.txt
 * @license The MIT License (MIT); see LICENSE.txt
 */

/**
 * MediaWiki meta dialog Languages page.
 *
 * @class
 * @extends OO.ui.PageLayout
 *
 * @constructor
 * @param {string} name Unique symbolic name of page
 * @param {Object} [config] Configuration options
 */
ve.ui.SpecialCharacterPage = function VeUiSpecialCharacterPage( name, config ) {
	// Parent constructor
	OO.ui.PageLayout.call( this, name, config );

	this.label = config.label;
	this.icon = config.icon;

	var character,
		characters = config.characters,
		$characters = this.$( '<div>' ).addClass( 've-ui-specialCharacterPage-characters' );

	for ( character in characters ) {
		$characters.append(
			this.$( '<div>' )
				.addClass( 've-ui-specialCharacterPage-character' )
				.data( 'character', characters[character] )
				.text( character )
		);
	}

	this.$element
		.addClass( 've-ui-specialCharacterPage')
		.append( this.$( '<h3>' ).text( name ), $characters );
};

/* Inheritance */

OO.inheritClass( ve.ui.SpecialCharacterPage, OO.ui.PageLayout );

/* Methods */

ve.ui.SpecialCharacterPage.prototype.setupOutlineItem = function ( outlineItem ) {
	ve.ui.SpecialCharacterPage.super.prototype.setupOutlineItem.call( this, outlineItem );
	this.outlineItem.setLabel( this.label );
};

/*!
 * VisualEditor UserInterface DesktopSurface class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * A surface is a top-level object which contains both a surface model and a surface view.
 * This is the mobile version of the surface.
 *
 * @class
 * @extends ve.ui.Surface
 *
 * @constructor
 * @param {HTMLDocument|Array|ve.dm.LinearData|ve.dm.Document} dataOrDoc Document data to edit
 * @param {Object} [config] Configuration options
 */
ve.ui.DesktopSurface = function VeUiDesktopSurface() {
	// Parent constructor
	ve.ui.Surface.apply( this, arguments );
};

/* Inheritance */

OO.inheritClass( ve.ui.DesktopSurface, ve.ui.Surface );

/* Methods */

/**
 * @inheritdoc
 */
ve.ui.DesktopSurface.prototype.createContext = function () {
	return new ve.ui.DesktopContext( this, { $: this.$ } );
};

/**
 * @inheritdoc
 */
ve.ui.DesktopSurface.prototype.createDialogWindowManager = function () {
	return new ve.ui.SurfaceWindowManager( this, { factory: ve.ui.windowFactory } );
};

/*!
 * VisualEditor UserInterface DesktopContext class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Context menu and inspectors.
 *
 * @class
 * @extends ve.ui.Context
 *
 * @constructor
 * @param {ve.ui.Surface} surface
 * @param {Object} [config] Configuration options
 */
ve.ui.DesktopContext = function VeUiDesktopContext( surface, config ) {
	// Parent constructor
	ve.ui.DesktopContext.super.call( this, surface, config );

	// Properties
	this.popup = new OO.ui.PopupWidget( { $: this.$, $container: this.surface.$element } );
	this.transitioning = null;
	this.suppressed = false;
	this.onWindowResizeHandler = this.onPosition.bind( this );
	this.$window = this.$( this.getElementWindow() );

	// Events
	this.surface.getView().connect( this, {
		relocationStart: 'onSuppress',
		relocationEnd: 'onUnsuppress',
		blur: 'onSuppress',
		focus: 'onUnsuppress',
		position: 'onPosition'
	} );
	this.surface.getModel().connect( this, {
		select: 'onModelSelect'
	} );
	this.inspectors.connect( this, {
		resize: 'setPopupSize'
	} );
	this.$window.on( 'resize', this.onWindowResizeHandler );

	// Initialization
	this.$element
		.addClass( 've-ui-desktopContext' )
		.append( this.popup.$element );
	this.$group.addClass( 've-ui-desktopContext-menu' );
	this.inspectors.$element.addClass( 've-ui-desktopContext-inspectors' );
	this.popup.$body.append( this.$group, this.inspectors.$element );
};

/* Inheritance */

OO.inheritClass( ve.ui.DesktopContext, ve.ui.Context );

/* Methods */

/**
 * @inheritdoc
 */
ve.ui.DesktopContext.prototype.afterContextChange = function () {
	// Parent method
	ve.ui.DesktopContext.super.prototype.afterContextChange.call( this );

	// Bypass while dragging
	if ( this.suppressed ) {
		return;
	}
};

/**
 * Handle context suppression event.
 */
ve.ui.DesktopContext.prototype.onSuppress = function () {
	this.suppressed = true;
	if ( this.isVisible() ) {
		if ( !this.isEmpty() ) {
			// Change state: menu -> closed
			this.toggleMenu( false );
			this.toggle( false );
		} else if ( this.inspector ) {
			// Change state: inspector -> closed
			this.inspector.close();
		}
	}
};

/**
 * Handle context unsuppression event.
 */
ve.ui.DesktopContext.prototype.onUnsuppress = function () {
	this.suppressed = false;

	if ( this.isInspectable() ) {
		// Change state: closed -> menu
		this.toggleMenu( true );
		this.toggle( true );
	}
};

/**
 * Handle model select event.
 */
ve.ui.DesktopContext.prototype.onModelSelect = function () {
	if ( this.isVisible() ) {
		if ( this.inspector && this.inspector.isOpened() ) {
			this.inspector.close();
		}
		this.updateDimensionsDebounced();
	}
};

/**
 * Handle cursor position change event.
 */
ve.ui.DesktopContext.prototype.onPosition = function () {
	if ( this.isVisible() ) {
		this.updateDimensionsDebounced();
	}
};

/**
 * @inheritdoc
 */
ve.ui.DesktopContext.prototype.createInspectorWindowManager = function () {
	return new ve.ui.DesktopInspectorWindowManager( this.surface, {
		$: this.$,
		factory: ve.ui.windowFactory,
		overlay: this.surface.getLocalOverlay(),
		modal: false
	} );
};

/**
 * @inheritdoc
 */
ve.ui.DesktopContext.prototype.onInspectorOpening = function () {
	ve.ui.DesktopContext.super.prototype.onInspectorOpening.apply( this, arguments );
	// Resize the popup before opening so the body height of the window is measured correctly
	this.setPopupSize();
};

/**
 * @inheritdoc
 */
ve.ui.DesktopContext.prototype.toggle = function ( show ) {
	var promise;

	if ( this.transitioning ) {
		return this.transitioning;
	}
	show = show === undefined ? !this.visible : !!show;
	if ( show === this.visible ) {
		return $.Deferred().resolve().promise();
	}

	this.transitioning = $.Deferred();
	promise = this.transitioning.promise();

	this.popup.toggle( show );

	// Parent method
	ve.ui.DesktopContext.super.prototype.toggle.call( this, show );

	this.transitioning.resolve();
	this.transitioning = null;
	this.visible = show;

	if ( show ) {
		if ( this.inspector ) {
			this.inspector.updateSize();
		}
		// updateDimensionsDebounced is not necessary here and causes a movement flicker
		this.updateDimensions();
	} else if ( this.inspector ) {
		this.inspector.close();
	}

	return promise;
};

/**
 * @inheritdoc
 */
ve.ui.DesktopContext.prototype.updateDimensions = function () {
	if ( !this.isVisible() ) {
		return;
	}

	var startAndEndRects, position, embeddable, middle, boundingRect,
		rtl = this.surface.getModel().getDocument().getDir() === 'rtl',
		surface = this.surface.getView(),
		selection = this.inspector && this.inspector.previousSelection,
		focusedNode = surface.getFocusedNode();

	boundingRect = surface.getSelectionBoundingRect( selection );

	if ( !boundingRect ) {
		// If !boundingRect, the surface apparently isn't selected.
		// This shouldn't happen because the context is only supposed to be
		// displayed in response to a selection, but it sometimes does happen due
		// to browser weirdness.
		// Skip updating the cursor position, but still update the width and height.
		this.popup.toggleAnchor( true );
		this.popup.align = 'center';
	} else if ( focusedNode && !focusedNode.isContent() ) {
		embeddable = this.isEmbeddable() &&
			boundingRect.height > this.$group.outerHeight() + 5 &&
			boundingRect.width > this.$group.outerWidth() + 10;
		this.popup.toggleAnchor( !embeddable );
		if ( embeddable ) {
			// Embedded context position depends on directionality
			position = {
				x: rtl ? boundingRect.left : boundingRect.right,
				y: boundingRect.top
			};
			this.popup.align = rtl ? 'left' : 'right';
		} else {
			// Position the context underneath the center of the node
			middle = ( boundingRect.left + boundingRect.right ) / 2;
			position = {
				x: middle,
				y: boundingRect.bottom
			};
			this.popup.align = 'center';
		}
	} else {
		// The selection is text or an inline focused node
		startAndEndRects = surface.getSelectionStartAndEndRects( selection );
		if ( startAndEndRects ) {
			middle = ( boundingRect.left + boundingRect.right ) / 2;
			if (
				( !rtl && startAndEndRects.end.right > middle ) ||
				( rtl && startAndEndRects.end.left < middle )
			) {
				// If the middle position is within the end rect, use it
				position = {
					x: middle,
					y: boundingRect.bottom
				};
			} else {
				// ..otherwise use the side of the end rect
				position = {
					x: rtl ? startAndEndRects.end.left : startAndEndRects.end.right,
					y: startAndEndRects.end.bottom
				};
			}
		}

		this.popup.toggleAnchor( true );
		this.popup.align = 'center';
	}

	if ( position ) {
		this.$element.css( { left: position.x, top: position.y } );
	}

	// HACK: setPopupSize() has to be called at the end because it reads this.popup.align,
	// which we set directly in the code above
	this.setPopupSize();

	return this;
};

/**
 * Resize the popup to match the size of its contents (menu or inspector).
 */
ve.ui.DesktopContext.prototype.setPopupSize = function () {
	var $container = this.inspector ? this.inspector.$frame : this.$group;

	// PopupWidget normally is clippable, suppress that to be able to resize and scroll it into view.
	// Needs to be repeated before every call, as it resets itself when the popup is shown or hidden.
	this.popup.toggleClipping( false );

	this.popup.setSize(
		$container.outerWidth( true ),
		$container.outerHeight( true )
	);

	this.popup.scrollElementIntoView();
};

/**
 * @inheritdoc
 */
ve.ui.DesktopContext.prototype.destroy = function () {
	// Disconnect
	this.surface.getView().disconnect( this );
	this.surface.getModel().disconnect( this );
	this.$window.off( 'resize', this.onWindowResizeHandler );

	// Parent method
	return ve.ui.DesktopContext.super.prototype.destroy.call( this );
};

/*!
 * VisualEditor UserInterface DesktopInspectorWindowManager class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Window manager for desktop inspectors.
 *
 * @class
 * @extends ve.ui.SurfaceWindowManager
 *
 * @constructor
 * @param {ve.ui.Surface} Surface this belongs to
 * @param {Object} [config] Configuration options
 * @cfg {ve.ui.Overlay} [overlay] Overlay to use for menus
 */
ve.ui.DesktopInspectorWindowManager = function VeUiDesktopInspectorWindowManager( surface, config ) {
	// Parent constructor
	ve.ui.DesktopInspectorWindowManager.super.call( this, surface, config );
};

/* Inheritance */

OO.inheritClass( ve.ui.DesktopInspectorWindowManager, ve.ui.SurfaceWindowManager );

/* Static Properties */

ve.ui.DesktopInspectorWindowManager.static.sizes = {
	small: {
		width: 200,
		maxHeight: '100%'
	},
	medium: {
		width: 300,
		maxHeight: '100%'
	},
	large: {
		width: 400,
		maxHeight: '100%'
	},
	full: {
		// These can be non-numeric because they are never used in calculations
		width: '100%',
		height: '100%'
	}
};
