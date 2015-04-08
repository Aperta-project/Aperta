/**
 * jQuery Internationalization library
 *
 * Copyright (C) 2012 Santhosh Thottingal
 *
 * jquery.i18n is dual licensed GPLv2 or later and MIT. You don't have to do
 * anything special to choose one license or the other and you don't have to
 * notify anyone which license you are using. You are free to use
 * UniversalLanguageSelector in commercial projects as long as the copyright
 * header is left intact. See files GPL-LICENSE and MIT-LICENSE for details.
 *
 * @licence GNU General Public Licence 2.0 or later
 * @licence MIT License
 */

( function ( $ ) {
	'use strict';

	var nav, I18N,
		slice = Array.prototype.slice;
	/**
	 * @constructor
	 * @param {Object} options
	 */
	I18N = function ( options ) {
		// Load defaults
		this.options = $.extend( {}, I18N.defaults, options );

		this.parser = this.options.parser;
		this.locale = this.options.locale;
		this.messageStore = this.options.messageStore;
		this.languages = {};

		this.init();
	};

	I18N.prototype = {
		/**
		 * Initialize by loading locales and setting up
		 * String.prototype.toLocaleString and String.locale.
		 */
		init: function () {
			var i18n = this;

			// Set locale of String environment
			String.locale = i18n.locale;

			// Override String.localeString method
			String.prototype.toLocaleString = function () {
				var localeParts, localePartIndex, value, locale, fallbackIndex,
					tryingLocale, message;

				value = this.valueOf();
				locale = i18n.locale;
				fallbackIndex = 0;

				while ( locale ) {
					// Iterate through locales starting at most-specific until
					// localization is found. As in fi-Latn-FI, fi-Latn and fi.
					localeParts = locale.split( '-' );
					localePartIndex = localeParts.length;

					do {
						tryingLocale = localeParts.slice( 0, localePartIndex ).join( '-' );
						message = i18n.messageStore.get( tryingLocale, value );

						if ( message ) {
							return message;
						}

						localePartIndex--;
					} while ( localePartIndex );

					if ( locale === 'en' ) {
						break;
					}

					locale = ( $.i18n.fallbacks[i18n.locale] && $.i18n.fallbacks[i18n.locale][fallbackIndex] ) ||
						i18n.options.fallbackLocale;
					$.i18n.log( 'Trying fallback locale for ' + i18n.locale + ': ' + locale );

					fallbackIndex++;
				}

				// key not found
				return '';
			};
		},

		/*
		 * Destroy the i18n instance.
		 */
		destroy: function () {
			$.removeData( document, 'i18n' );
		},

		/**
		 * General message loading API This can take a URL string for
		 * the json formatted messages.
		 * <code>load('path/to/all_localizations.json');</code>
		 *
		 * This can also load a localization file for a locale <code>
		 * load('path/to/de-messages.json', 'de' );
		 * </code>
		 * A data object containing message key- message translation mappings
		 * can also be passed Eg:
		 * <code>
		 * load( { 'hello' : 'Hello' }, optionalLocale );
		 * </code> If the data argument is
		 * null/undefined/false,
		 * all cached messages for the i18n instance will get reset.
		 *
		 * @param {String|Object} source
		 * @param {String} locale Language tag
		 * @returns {jQuery.Promise}
		 */
		load: function ( source, locale ) {
			return this.messageStore.load( source, locale );
		},

		/**
		 * Does parameter and magic word substitution.
		 *
		 * @param {string} key Message key
		 * @param {Array} parameters Message parameters
		 * @return {string}
		 */
		parse: function ( key, parameters ) {
			var message = key.toLocaleString();
			// FIXME: This changes the state of the I18N object,
			// should probably not change the 'this.parser' but just
			// pass it to the parser.
			this.parser.language = $.i18n.languages[$.i18n().locale] || $.i18n.languages['default'];
			if( message === '' ) {
				message = key;
			}
			return this.parser.parse( message, parameters );
		}
	};

	/**
	 * Process a message from the $.I18N instance
	 * for the current document, stored in jQuery.data(document).
	 *
	 * @param {string} key Key of the message.
	 * @param {string} param1 [param...] Variadic list of parameters for {key}.
	 * @return {string|$.I18N} Parsed message, or if no key was given
	 * the instance of $.I18N is returned.
	 */
	$.i18n = function ( key, param1 ) {
		var parameters,
			i18n = $.data( document, 'i18n' ),
			options = typeof key === 'object' && key;

		// If the locale option for this call is different then the setup so far,
		// update it automatically. This doesn't just change the context for this
		// call but for all future call as well.
		// If there is no i18n setup yet, don't do this. It will be taken care of
		// by the `new I18N` construction below.
		// NOTE: It should only change language for this one call.
		// Then cache instances of I18N somewhere.
		if ( options && options.locale && i18n && i18n.locale !== options.locale ) {
			String.locale = i18n.locale = options.locale;
		}

		if ( !i18n ) {
			i18n = new I18N( options );
			$.data( document, 'i18n', i18n );
		}

		if ( typeof key === 'string' ) {
			if ( param1 !== undefined ) {
				parameters = slice.call( arguments, 1 );
			} else {
				parameters = [];
			}

			return i18n.parse( key, parameters );
		} else {
			// FIXME: remove this feature/bug.
			return i18n;
		}
	};

	$.fn.i18n = function () {
		var i18n = $.data( document, 'i18n' );

		if ( !i18n ) {
			i18n = new I18N();
			$.data( document, 'i18n', i18n );
		}
		String.locale = i18n.locale;
		return this.each( function () {
			var $this = $( this ),
				messageKey = $this.data( 'i18n' );

			if ( messageKey ) {
				$this.text( i18n.parse( messageKey ) );
			} else {
				$this.find( '[data-i18n]' ).i18n();
			}
		} );
	};

	String.locale = String.locale || $( 'html' ).attr( 'lang' );

	if ( !String.locale ) {
		if ( typeof window.navigator !== undefined ) {
			nav = window.navigator;
			String.locale = nav.language || nav.userLanguage || '';
		} else {
			String.locale = '';
		}
	}

	$.i18n.languages = {};
	$.i18n.messageStore = $.i18n.messageStore || {};
	$.i18n.parser = {
		// The default parser only handles variable substitution
		parse: function ( message, parameters ) {
			return message.replace( /\$(\d+)/g, function ( str, match ) {
				var index = parseInt( match, 10 ) - 1;
				return parameters[index] !== undefined ? parameters[index] : '$' + match;
			} );
		},
		emitter: {}
	};
	$.i18n.fallbacks = {};
	$.i18n.debug = false;
	$.i18n.log = function ( /* arguments */ ) {
		if ( window.console && $.i18n.debug ) {
			window.console.log.apply( window.console, arguments );
		}
	};
	/* Static members */
	I18N.defaults = {
		locale: String.locale,
		fallbackLocale: 'en',
		parser: $.i18n.parser,
		messageStore: $.i18n.messageStore
	};

	// Expose constructor
	$.i18n.constructor = I18N;
}( jQuery ) );

/**
 * jQuery Internationalization library - Message Store
 *
 * Copyright (C) 2012 Santhosh Thottingal
 *
 * jquery.i18n is dual licensed GPLv2 or later and MIT. You don't have to do anything special to
 * choose one license or the other and you don't have to notify anyone which license you are using.
 * You are free to use UniversalLanguageSelector in commercial projects as long as the copyright
 * header is left intact. See files GPL-LICENSE and MIT-LICENSE for details.
 *
 * @licence GNU General Public Licence 2.0 or later
 * @licence MIT License
 */

( function ( $, window, undefined ) {
	'use strict';

	var MessageStore = function () {
		this.messages = {};
		this.sources = {};
	};

	/**
	 * See https://github.com/wikimedia/jquery.i18n/wiki/Specification#wiki-Message_File_Loading
	 */
	MessageStore.prototype = {

		/**
		 * General message loading API This can take a URL string for
		 * the json formatted messages.
		 * <code>load('path/to/all_localizations.json');</code>
		 *
		 * This can also load a localization file for a locale <code>
		 * load( 'path/to/de-messages.json', 'de' );
		 * </code>
		 * A data object containing message key- message translation mappings
		 * can also be passed Eg:
		 * <code>
		 * load( { 'hello' : 'Hello' }, optionalLocale );
		 * </code> If the data argument is
		 * null/undefined/false,
		 * all cached messages for the i18n instance will get reset.
		 *
		 * @param {String|Object} source
		 * @param {String} locale Language tag
		 * @return {jQuery.Promise}
		 */
		load: function ( source, locale ) {
			var key = null,
				deferred = null,
				deferreds = [],
				messageStore = this;

			if ( typeof source === 'string' ) {
				// This is a URL to the messages file.
				$.i18n.log( 'Loading messages from: ' + source );
				deferred = jsonMessageLoader( source )
					.done( function ( localization ) {
						messageStore.set( locale, localization );
					} );

				return deferred.promise();
			}

			if ( locale ) {
				// source is an key-value pair of messages for given locale
				messageStore.set( locale, source );

				return $.Deferred().resolve();
			} else {
				// source is a key-value pair of locales and their source
				for ( key in source ) {
					if ( Object.prototype.hasOwnProperty.call( source, key ) ) {
						locale = key;
						// No {locale} given, assume data is a group of languages,
						// call this function again for each language.
						deferreds.push( messageStore.load( source[key], locale ) );
					}
				}
				return $.when.apply( $, deferreds );
			}

		},

		/**
		 * Set messages to the given locale.
		 * If locale exists, add messages to the locale.
		 * @param locale
		 * @param messages
		 */
		set: function( locale, messages ) {
			if ( !this.messages[locale] ) {
				this.messages[locale] = messages;
			} else {
				this.messages[locale] = $.extend( this.messages[locale], messages );
			}
		},

		/**
		 *
		 * @param locale
		 * @param messageKey
		 * @returns {Boolean}
		 */
		get: function ( locale, messageKey ) {
			return this.messages[locale] && this.messages[locale][messageKey];
		}
	};

	function jsonMessageLoader( url ) {
		return $.getJSON( url ).fail( function ( jqxhr, settings, exception ) {
			$.i18n.log( 'Error in loading messages from ' + url + ' Exception: ' + exception );
		} );
	}

	$.extend( $.i18n.messageStore, new MessageStore() );
}( jQuery, window ) );

/**
 * jQuery Internationalization library
 *
 * Copyright (C) 2011-2013 Santhosh Thottingal, Neil Kandalgaonkar
 *
 * jquery.i18n is dual licensed GPLv2 or later and MIT. You don't have to do
 * anything special to choose one license or the other and you don't have to
 * notify anyone which license you are using. You are free to use
 * UniversalLanguageSelector in commercial projects as long as the copyright
 * header is left intact. See files GPL-LICENSE and MIT-LICENSE for details.
 *
 * @licence GNU General Public Licence 2.0 or later
 * @licence MIT License
 */

( function ( $ ) {
	'use strict';

	var MessageParser = function ( options ) {
		this.options = $.extend( {}, $.i18n.parser.defaults, options );
		this.language = $.i18n.languages[String.locale] || $.i18n.languages['default'];
		this.emitter = $.i18n.parser.emitter;
	};

	MessageParser.prototype = {

		constructor: MessageParser,

		simpleParse: function ( message, parameters ) {
			return message.replace( /\$(\d+)/g, function ( str, match ) {
				var index = parseInt( match, 10 ) - 1;

				return parameters[index] !== undefined ? parameters[index] : '$' + match;
			} );
		},

		parse: function ( message, replacements ) {
			if ( message.indexOf( '{{' ) < 0 ) {
				return this.simpleParse( message, replacements );
			}

			this.emitter.language = $.i18n.languages[$.i18n().locale] ||
				$.i18n.languages['default'];

			return this.emitter.emit( this.ast( message ), replacements );
		},

		ast: function ( message ) {
			var pipe, colon, backslash, anyCharacter, dollar, digits, regularLiteral,
				regularLiteralWithoutBar, regularLiteralWithoutSpace, escapedOrLiteralWithoutBar,
				escapedOrRegularLiteral, templateContents, templateName, openTemplate,
				closeTemplate, expression, paramExpression, result,
				pos = 0;

			// Try parsers until one works, if none work return null
			function choice ( parserSyntax ) {
				return function () {
					var i, result;

					for ( i = 0; i < parserSyntax.length; i++ ) {
						result = parserSyntax[i]();

						if ( result !== null ) {
							return result;
						}
					}

					return null;
				};
			}

			// Try several parserSyntax-es in a row.
			// All must succeed; otherwise, return null.
			// This is the only eager one.
			function sequence ( parserSyntax ) {
				var i, res,
					originalPos = pos,
					result = [];

				for ( i = 0; i < parserSyntax.length; i++ ) {
					res = parserSyntax[i]();

					if ( res === null ) {
						pos = originalPos;

						return null;
					}

					result.push( res );
				}

				return result;
			}

			// Run the same parser over and over until it fails.
			// Must succeed a minimum of n times; otherwise, return null.
			function nOrMore ( n, p ) {
				return function () {
					var originalPos = pos,
						result = [],
						parsed = p();

					while ( parsed !== null ) {
						result.push( parsed );
						parsed = p();
					}

					if ( result.length < n ) {
						pos = originalPos;

						return null;
					}

					return result;
				};
			}

			// Helpers -- just make parserSyntax out of simpler JS builtin types

			function makeStringParser ( s ) {
				var len = s.length;

				return function () {
					var result = null;

					if ( message.substr( pos, len ) === s ) {
						result = s;
						pos += len;
					}

					return result;
				};
			}

			function makeRegexParser ( regex ) {
				return function () {
					var matches = message.substr( pos ).match( regex );

					if ( matches === null ) {
						return null;
					}

					pos += matches[0].length;

					return matches[0];
				};
			}

			pipe = makeStringParser( '|' );
			colon = makeStringParser( ':' );
			backslash = makeStringParser( '\\' );
			anyCharacter = makeRegexParser( /^./ );
			dollar = makeStringParser( '$' );
			digits = makeRegexParser( /^\d+/ );
			regularLiteral = makeRegexParser( /^[^{}\[\]$\\]/ );
			regularLiteralWithoutBar = makeRegexParser( /^[^{}\[\]$\\|]/ );
			regularLiteralWithoutSpace = makeRegexParser( /^[^{}\[\]$\s]/ );

			// There is a general pattern:
			// parse a thing;
			// if it worked, apply transform,
			// otherwise return null.
			// But using this as a combinator seems to cause problems
			// when combined with nOrMore().
			// May be some scoping issue.
			function transform ( p, fn ) {
				return function () {
					var result = p();

					return result === null ? null : fn( result );
				};
			}

			// Used to define "literals" within template parameters. The pipe
			// character is the parameter delimeter, so by default
			// it is not a literal in the parameter
			function literalWithoutBar () {
				var result = nOrMore( 1, escapedOrLiteralWithoutBar )();

				return result === null ? null : result.join( '' );
			}

			function literal () {
				var result = nOrMore( 1, escapedOrRegularLiteral )();

				return result === null ? null : result.join( '' );
			}

			function escapedLiteral () {
				var result = sequence( [ backslash, anyCharacter ] );

				return result === null ? null : result[1];
			}

			choice( [ escapedLiteral, regularLiteralWithoutSpace ] );
			escapedOrLiteralWithoutBar = choice( [ escapedLiteral, regularLiteralWithoutBar ] );
			escapedOrRegularLiteral = choice( [ escapedLiteral, regularLiteral ] );

			function replacement () {
				var result = sequence( [ dollar, digits ] );

				if ( result === null ) {
					return null;
				}

				return [ 'REPLACE', parseInt( result[1], 10 ) - 1 ];
			}

			templateName = transform(
				// see $wgLegalTitleChars
				// not allowing : due to the need to catch "PLURAL:$1"
				makeRegexParser( /^[ !"$&'()*,.\/0-9;=?@A-Z\^_`a-z~\x80-\xFF+\-]+/ ),

				function ( result ) {
					return result.toString();
				}
			);

			function templateParam () {
				var expr,
					result = sequence( [ pipe, nOrMore( 0, paramExpression ) ] );

				if ( result === null ) {
					return null;
				}

				expr = result[1];

				// use a "CONCAT" operator if there are multiple nodes,
				// otherwise return the first node, raw.
				return expr.length > 1 ? [ 'CONCAT' ].concat( expr ) : expr[0];
			}

			function templateWithReplacement () {
				var result = sequence( [ templateName, colon, replacement ] );

				return result === null ? null : [ result[0], result[2] ];
			}

			function templateWithOutReplacement () {
				var result = sequence( [ templateName, colon, paramExpression ] );

				return result === null ? null : [ result[0], result[2] ];
			}

			templateContents = choice( [
				function () {
					var res = sequence( [
						// templates can have placeholders for dynamic
						// replacement eg: {{PLURAL:$1|one car|$1 cars}}
						// or no placeholders eg:
						// {{GRAMMAR:genitive|{{SITENAME}}}
						choice( [ templateWithReplacement, templateWithOutReplacement ] ),
						nOrMore( 0, templateParam )
					] );

					return res === null ? null : res[0].concat( res[1] );
				},
				function () {
					var res = sequence( [ templateName, nOrMore( 0, templateParam ) ] );

					if ( res === null ) {
						return null;
					}

					return [ res[0] ].concat( res[1] );
				}
			] );

			openTemplate = makeStringParser( '{{' );
			closeTemplate = makeStringParser( '}}' );

			function template () {
				var result = sequence( [ openTemplate, templateContents, closeTemplate ] );

				return result === null ? null : result[1];
			}

			expression = choice( [ template, replacement, literal ] );
			paramExpression = choice( [ template, replacement, literalWithoutBar ] );

			function start () {
				var result = nOrMore( 0, expression )();

				if ( result === null ) {
					return null;
				}

				return [ 'CONCAT' ].concat( result );
			}

			result = start();

			/*
			 * For success, the pos must have gotten to the end of the input
			 * and returned a non-null.
			 * n.b. This is part of language infrastructure, so we do not throw an internationalizable message.
			 */
			if ( result === null || pos !== message.length ) {
				throw new Error( 'Parse error at position ' + pos.toString() + ' in input: ' + message );
			}

			return result;
		}

	};

	$.extend( $.i18n.parser, new MessageParser() );
}( jQuery ) );

/**
 * jQuery Internationalization library
 *
 * Copyright (C) 2011-2013 Santhosh Thottingal, Neil Kandalgaonkar
 *
 * jquery.i18n is dual licensed GPLv2 or later and MIT. You don't have to do
 * anything special to choose one license or the other and you don't have to
 * notify anyone which license you are using. You are free to use
 * UniversalLanguageSelector in commercial projects as long as the copyright
 * header is left intact. See files GPL-LICENSE and MIT-LICENSE for details.
 *
 * @licence GNU General Public Licence 2.0 or later
 * @licence MIT License
 */

( function ( $ ) {
	'use strict';

	var MessageParserEmitter = function () {
		this.language = $.i18n.languages[String.locale] || $.i18n.languages['default'];
	};

	MessageParserEmitter.prototype = {
		constructor: MessageParserEmitter,

		/**
		 * (We put this method definition here, and not in prototype, to make
		 * sure it's not overwritten by any magic.) Walk entire node structure,
		 * applying replacements and template functions when appropriate
		 *
		 * @param {Mixed} node abstract syntax tree (top node or subnode)
		 * @param {Array} replacements for $1, $2, ... $n
		 * @return {Mixed} single-string node or array of nodes suitable for
		 *  jQuery appending.
		 */
		emit: function ( node, replacements ) {
			var ret, subnodes, operation,
				messageParserEmitter = this;

			switch ( typeof node ) {
			case 'string':
			case 'number':
				ret = node;
				break;
			case 'object':
				// node is an array of nodes
				subnodes = $.map( node.slice( 1 ), function ( n ) {
					return messageParserEmitter.emit( n, replacements );
				} );

				operation = node[0].toLowerCase();

				if ( typeof messageParserEmitter[operation] === 'function' ) {
					ret = messageParserEmitter[operation]( subnodes, replacements );
				} else {
					throw new Error( 'unknown operation "' + operation + '"' );
				}

				break;
			case 'undefined':
				// Parsing the empty string (as an entire expression, or as a
				// paramExpression in a template) results in undefined
				// Perhaps a more clever parser can detect this, and return the
				// empty string? Or is that useful information?
				// The logical thing is probably to return the empty string here
				// when we encounter undefined.
				ret = '';
				break;
			default:
				throw new Error( 'unexpected type in AST: ' + typeof node );
			}

			return ret;
		},

		/**
		 * Parsing has been applied depth-first we can assume that all nodes
		 * here are single nodes Must return a single node to parents -- a
		 * jQuery with synthetic span However, unwrap any other synthetic spans
		 * in our children and pass them upwards
		 *
		 * @param {Array} nodes Mixed, some single nodes, some arrays of nodes.
		 * @return String
		 */
		concat: function ( nodes ) {
			var result = '';

			$.each( nodes, function ( i, node ) {
				// strings, integers, anything else
				result += node;
			} );

			return result;
		},

		/**
		 * Return escaped replacement of correct index, or string if
		 * unavailable. Note that we expect the parsed parameter to be
		 * zero-based. i.e. $1 should have become [ 0 ]. if the specified
		 * parameter is not found return the same string (e.g. "$99" ->
		 * parameter 98 -> not found -> return "$99" ) TODO throw error if
		 * nodes.length > 1 ?
		 *
		 * @param {Array} nodes One element, integer, n >= 0
		 * @param {Array} replacements for $1, $2, ... $n
		 * @return {string} replacement
		 */
		replace: function ( nodes, replacements ) {
			var index = parseInt( nodes[0], 10 );

			if ( index < replacements.length ) {
				// replacement is not a string, don't touch!
				return replacements[index];
			} else {
				// index not found, fallback to displaying variable
				return '$' + ( index + 1 );
			}
		},

		/**
		 * Transform parsed structure into pluralization n.b. The first node may
		 * be a non-integer (for instance, a string representing an Arabic
		 * number). So convert it back with the current language's
		 * convertNumber.
		 *
		 * @param {Array} nodes List [ {String|Number}, {String}, {String} ... ]
		 * @return {String} selected pluralized form according to current
		 *  language.
		 */
		plural: function ( nodes ) {
			var count = parseFloat( this.language.convertNumber( nodes[0], 10 ) ),
				forms = nodes.slice( 1 );

			return forms.length ? this.language.convertPlural( count, forms ) : '';
		},

		/**
		 * Transform parsed structure into gender Usage
		 * {{gender:gender|masculine|feminine|neutral}}.
		 *
		 * @param {Array} nodes List [ {String}, {String}, {String} , {String} ]
		 * @return {String} selected gender form according to current language
		 */
		gender: function ( nodes ) {
			var gender = nodes[0],
				forms = nodes.slice( 1 );

			return this.language.gender( gender, forms );
		},

		/**
		 * Transform parsed structure into grammar conversion. Invoked by
		 * putting {{grammar:form|word}} in a message
		 *
		 * @param {Array} nodes List [{Grammar case eg: genitive}, {String word}]
		 * @return {String} selected grammatical form according to current
		 *  language.
		 */
		grammar: function ( nodes ) {
			var form = nodes[0],
				word = nodes[1];

			return word && form && this.language.convertGrammar( word, form );
		}
	};

	$.extend( $.i18n.parser.emitter, new MessageParserEmitter() );
}( jQuery ) );

/*global pluralRuleParser */
( function ( $ ) {
	'use strict';

	var language = {
		// CLDR plural rules generated using
		// libs/CLDRPluralRuleParser/tools/PluralXML2JSON.html
		'pluralRules': {
			'ak': {
				'one': 'n = 0..1'
			},
			'am': {
				'one': 'i = 0 or n = 1'
			},
			'ar': {
				'zero': 'n = 0',
				'one': 'n = 1',
				'two': 'n = 2',
				'few': 'n % 100 = 3..10',
				'many': 'n % 100 = 11..99'
			},
			'be': {
				'one': 'n % 10 = 1 and n % 100 != 11',
				'few': 'n % 10 = 2..4 and n % 100 != 12..14',
				'many': 'n % 10 = 0 or n % 10 = 5..9 or n % 100 = 11..14'
			},
			'bh': {
				'one': 'n = 0..1'
			},
			'bn': {
				'one': 'i = 0 or n = 1'
			},
			'br': {
				'one': 'n % 10 = 1 and n % 100 != 11,71,91',
				'two': 'n % 10 = 2 and n % 100 != 12,72,92',
				'few': 'n % 10 = 3..4,9 and n % 100 != 10..19,70..79,90..99',
				'many': 'n != 0 and n % 1000000 = 0'
			},
			'bs': {
				'one': 'v = 0 and i % 10 = 1 and i % 100 != 11 or f % 10 = 1 and f % 100 != 11',
				'few': 'v = 0 and i % 10 = 2..4 and i % 100 != 12..14 or f % 10 = 2..4 and f % 100 != 12..14'
			},
			'cs': {
				'one': 'i = 1 and v = 0',
				'few': 'i = 2..4 and v = 0',
				'many': 'v != 0'
			},
			'cy': {
				'zero': 'n = 0',
				'one': 'n = 1',
				'two': 'n = 2',
				'few': 'n = 3',
				'many': 'n = 6'
			},
			'da': {
				'one': 'n = 1 or t != 0 and i = 0,1'
			},
			'fa': {
				'one': 'i = 0 or n = 1'
			},
			'ff': {
				'one': 'i = 0,1'
			},
			'fil': {
				'one': 'i = 0..1 and v = 0'
			},
			'fr': {
				'one': 'i = 0,1'
			},
			'ga': {
				'one': 'n = 1',
				'two': 'n = 2',
				'few': 'n = 3..6',
				'many': 'n = 7..10'
			},
			'gd': {
				'one': 'n = 1,11',
				'two': 'n = 2,12',
				'few': 'n = 3..10,13..19'
			},
			'gu': {
				'one': 'i = 0 or n = 1'
			},
			'guw': {
				'one': 'n = 0..1'
			},
			'gv': {
				'one': 'n % 10 = 1',
				'two': 'n % 10 = 2',
				'few': 'n % 100 = 0,20,40,60'
			},
			'he': {
				'one': 'i = 1 and v = 0',
				'two': 'i = 2 and v = 0',
				'many': 'v = 0 and n != 0..10 and n % 10 = 0'
			},
			'hi': {
				'one': 'i = 0 or n = 1'
			},
			'hr': {
				'one': 'v = 0 and i % 10 = 1 and i % 100 != 11 or f % 10 = 1 and f % 100 != 11',
				'few': 'v = 0 and i % 10 = 2..4 and i % 100 != 12..14 or f % 10 = 2..4 and f % 100 != 12..14'
			},
			'hy': {
				'one': 'i = 0,1'
			},
			'is': {
				'one': 't = 0 and i % 10 = 1 and i % 100 != 11 or t != 0'
			},
			'iu': {
				'one': 'n = 1',
				'two': 'n = 2'
			},
			'iw': {
				'one': 'i = 1 and v = 0',
				'two': 'i = 2 and v = 0',
				'many': 'v = 0 and n != 0..10 and n % 10 = 0'
			},
			'kab': {
				'one': 'i = 0,1'
			},
			'kn': {
				'one': 'i = 0 or n = 1'
			},
			'kw': {
				'one': 'n = 1',
				'two': 'n = 2'
			},
			'lag': {
				'zero': 'n = 0',
				'one': 'i = 0,1 and n != 0'
			},
			'ln': {
				'one': 'n = 0..1'
			},
			'lt': {
				'one': 'n % 10 = 1 and n % 100 != 11..19',
				'few': 'n % 10 = 2..9 and n % 100 != 11..19',
				'many': 'f != 0'
			},
			'lv': {
				'zero': 'n % 10 = 0 or n % 100 = 11..19 or v = 2 and f % 100 = 11..19',
				'one': 'n % 10 = 1 and n % 100 != 11 or v = 2 and f % 10 = 1 and f % 100 != 11 or v != 2 and f % 10 = 1'
			},
			'mg': {
				'one': 'n = 0..1'
			},
			'mk': {
				'one': 'v = 0 and i % 10 = 1 or f % 10 = 1'
			},
			'mo': {
				'one': 'i = 1 and v = 0',
				'few': 'v != 0 or n = 0 or n != 1 and n % 100 = 1..19'
			},
			'mr': {
				'one': 'i = 0 or n = 1'
			},
			'mt': {
				'one': 'n = 1',
				'few': 'n = 0 or n % 100 = 2..10',
				'many': 'n % 100 = 11..19'
			},
			'naq': {
				'one': 'n = 1',
				'two': 'n = 2'
			},
			'nso': {
				'one': 'n = 0..1'
			},
			'pa': {
				'one': 'n = 0..1'
			},
			'pl': {
				'one': 'i = 1 and v = 0',
				'few': 'v = 0 and i % 10 = 2..4 and i % 100 != 12..14',
				'many': 'v = 0 and i != 1 and i % 10 = 0..1 or v = 0 and i % 10 = 5..9 or v = 0 and i % 100 = 12..14'
			},
			'pt': {
				'one': 'i = 1 and v = 0 or i = 0 and t = 1'
			},
			'pt_PT': {
				'one': 'n = 1 and v = 0'
			},
			'ro': {
				'one': 'i = 1 and v = 0',
				'few': 'v != 0 or n = 0 or n != 1 and n % 100 = 1..19'
			},
			'ru': {
				'one': 'v = 0 and i % 10 = 1 and i % 100 != 11',
				'many': 'v = 0 and i % 10 = 0 or v = 0 and i % 10 = 5..9 or v = 0 and i % 100 = 11..14'
			},
			'se': {
				'one': 'n = 1',
				'two': 'n = 2'
			},
			'sh': {
				'one': 'v = 0 and i % 10 = 1 and i % 100 != 11 or f % 10 = 1 and f % 100 != 11',
				'few': 'v = 0 and i % 10 = 2..4 and i % 100 != 12..14 or f % 10 = 2..4 and f % 100 != 12..14'
			},
			'shi': {
				'one': 'i = 0 or n = 1',
				'few': 'n = 2..10'
			},
			'si': {
				'one': 'n = 0,1 or i = 0 and f = 1'
			},
			'sk': {
				'one': 'i = 1 and v = 0',
				'few': 'i = 2..4 and v = 0',
				'many': 'v != 0'
			},
			'sl': {
				'one': 'v = 0 and i % 100 = 1',
				'two': 'v = 0 and i % 100 = 2',
				'few': 'v = 0 and i % 100 = 3..4 or v != 0'
			},
			'sma': {
				'one': 'n = 1',
				'two': 'n = 2'
			},
			'smi': {
				'one': 'n = 1',
				'two': 'n = 2'
			},
			'smj': {
				'one': 'n = 1',
				'two': 'n = 2'
			},
			'smn': {
				'one': 'n = 1',
				'two': 'n = 2'
			},
			'sms': {
				'one': 'n = 1',
				'two': 'n = 2'
			},
			'sr': {
				'one': 'v = 0 and i % 10 = 1 and i % 100 != 11 or f % 10 = 1 and f % 100 != 11',
				'few': 'v = 0 and i % 10 = 2..4 and i % 100 != 12..14 or f % 10 = 2..4 and f % 100 != 12..14'
			},
			'ti': {
				'one': 'n = 0..1'
			},
			'tl': {
				'one': 'i = 0..1 and v = 0'
			},
			'tzm': {
				'one': 'n = 0..1 or n = 11..99'
			},
			'uk': {
				'one': 'v = 0 and i % 10 = 1 and i % 100 != 11',
				'few': 'v = 0 and i % 10 = 2..4 and i % 100 != 12..14',
				'many': 'v = 0 and i % 10 = 0 or v = 0 and i % 10 = 5..9 or v = 0 and i % 100 = 11..14'
			},
			'wa': {
				'one': 'n = 0..1'
			},
			'zu': {
				'one': 'i = 0 or n = 1'
			}
		},


		/**
		 * Plural form transformations, needed for some languages.
		 *
		 * @param count
		 *            integer Non-localized quantifier
		 * @param forms
		 *            array List of plural forms
		 * @return string Correct form for quantifier in this language
		 */
		convertPlural: function ( count, forms ) {
			var pluralRules,
				pluralFormIndex,
				index,
				explicitPluralPattern = new RegExp('\\d+=', 'i'),
				formCount,
				form;

			if ( !forms || forms.length === 0 ) {
				return '';
			}

			// Handle for Explicit 0= & 1= values
			for ( index = 0; index < forms.length; index++ ) {
				form = forms[index];
				if ( explicitPluralPattern.test( form ) ) {
					formCount = parseInt( form.substring( 0, form.indexOf( '=' ) ), 10 );
					if ( formCount === count ) {
						return ( form.substr( form.indexOf( '=' ) + 1 ) );
					}
					forms[index] = undefined;
				}
			}

			forms = $.map( forms, function ( form ) {
				if ( form !== undefined ) {
					return form;
				}
			} );

			pluralRules = this.pluralRules[$.i18n().locale];

			if ( !pluralRules ) {
				// default fallback.
				return ( count === 1 ) ? forms[0] : forms[1];
			}

			pluralFormIndex = this.getPluralForm( count, pluralRules );
			pluralFormIndex = Math.min( pluralFormIndex, forms.length - 1 );

			return forms[pluralFormIndex];
		},

		/**
		 * For the number, get the plural for index
		 *
		 * @param number
		 * @param pluralRules
		 * @return plural form index
		 */
		getPluralForm: function ( number, pluralRules ) {
			var i,
				pluralForms = [ 'zero', 'one', 'two', 'few', 'many', 'other' ],
				pluralFormIndex = 0;

			for ( i = 0; i < pluralForms.length; i++ ) {
				if ( pluralRules[pluralForms[i]] ) {
					if ( pluralRuleParser( pluralRules[pluralForms[i]], number ) ) {
						return pluralFormIndex;
					}

					pluralFormIndex++;
				}
			}

			return pluralFormIndex;
		},

		/**
		 * Converts a number using digitTransformTable.
		 *
		 * @param {number} num Value to be converted
		 * @param {boolean} integer Convert the return value to an integer
		 */
		'convertNumber': function ( num, integer ) {
			var tmp, item, i,
				transformTable, numberString, convertedNumber;

			// Set the target Transform table:
			transformTable = this.digitTransformTable( $.i18n().locale );
			numberString = '' + num;
			convertedNumber = '';

			if ( !transformTable ) {
				return num;
			}

			// Check if the restore to Latin number flag is set:
			if ( integer ) {
				if ( parseFloat( num, 10 ) === num ) {
					return num;
				}

				tmp = [];

				for ( item in transformTable ) {
					tmp[transformTable[item]] = item;
				}

				transformTable = tmp;
			}

			for ( i = 0; i < numberString.length; i++ ) {
				if ( transformTable[numberString[i]] ) {
					convertedNumber += transformTable[numberString[i]];
				} else {
					convertedNumber += numberString[i];
				}
			}

			return integer ? parseFloat( convertedNumber, 10 ) : convertedNumber;
		},

		/**
		 * Grammatical transformations, needed for inflected languages.
		 * Invoked by putting {{grammar:form|word}} in a message.
		 * Override this method for languages that need special grammar rules
		 * applied dynamically.
		 *
		 * @param word {String}
		 * @param form {String}
		 * @return {String}
		 */
		convertGrammar: function ( word, form ) { /*jshint unused: false */
			return word;
		},

		/**
		 * Provides an alternative text depending on specified gender. Usage
		 * {{gender:[gender|user object]|masculine|feminine|neutral}}. If second
		 * or third parameter are not specified, masculine is used.
		 *
		 * These details may be overriden per language.
		 *
		 * @param gender
		 *      string male, female, or anything else for neutral.
		 * @param forms
		 *      array List of gender forms
		 *
		 * @return string
		 */
		'gender': function ( gender, forms ) {
			if ( !forms || forms.length === 0 ) {
				return '';
			}

			while ( forms.length < 2 ) {
				forms.push( forms[forms.length - 1] );
			}

			if ( gender === 'male' ) {
				return forms[0];
			}

			if ( gender === 'female' ) {
				return forms[1];
			}

			return ( forms.length === 3 ) ? forms[2] : forms[0];
		},

		/**
		 * Get the digit transform table for the given language
		 * See http://cldr.unicode.org/translation/numbering-systems
		 * @param language
		 * @returns {Array|boolean} List of digits in the passed language or false
		 * representation, or boolean false if there is no information.
		 */
		digitTransformTable: function ( language ) {
			var tables = {
				ar: '٠١٢٣٤٥٦٧٨٩',
				fa: '۰۱۲۳۴۵۶۷۸۹',
				ml: '൦൧൨൩൪൫൬൭൮൯',
				kn: '೦೧೨೩೪೫೬೭೮೯',
				lo: '໐໑໒໓໔໕໖໗໘໙',
				or: '୦୧୨୩୪୫୬୭୮୯',
				kh: '០១២៣៤៥៦៧៨៩',
				pa: '੦੧੨੩੪੫੬੭੮੯',
				gu: '૦૧૨૩૪૫૬૭૮૯',
				hi: '०१२३४५६७८९',
				my: '၀၁၂၃၄၅၆၇၈၉',
				ta: '௦௧௨௩௪௫௬௭௮௯',
				te: '౦౧౨౩౪౫౬౭౮౯',
				th: '๐๑๒๓๔๕๖๗๘๙', //FIXME use iso 639 codes
				bo: '༠༡༢༣༤༥༦༧༨༩' //FIXME use iso 639 codes
			};

			if ( !tables[language] ) {
				return false;
			}

			return tables[language].split( '' );
		}
	};

	$.extend( $.i18n.languages, {
		'default': language
	} );
}( jQuery ) );

/**
 * jQuery Internationalization library
 *
 * Copyright (C) 2012 Santhosh Thottingal
 *
 * jquery.i18n is dual licensed GPLv2 or later and MIT. You don't have to do anything special to
 * choose one license or the other and you don't have to notify anyone which license you are using.
 * You are free to use UniversalLanguageSelector in commercial projects as long as the copyright
 * header is left intact. See files GPL-LICENSE and MIT-LICENSE for details.
 *
 * @licence GNU General Public Licence 2.0 or later
 * @licence MIT License
 */
( function ( $, undefined ) {
	'use strict';

	$.i18n = $.i18n || {};
	$.extend( $.i18n.fallbacks, {
		'ab': ['ru'],
		'ace': ['id'],
		'aln': ['sq'],
		// Not so standard - als is supposed to be Tosk Albanian,
		// but in Wikipedia it's used for a Germanic language.
		'als': ['gsw', 'de'],
		'an': ['es'],
		'anp': ['hi'],
		'arn': ['es'],
		'arz': ['ar'],
		'av': ['ru'],
		'ay': ['es'],
		'ba': ['ru'],
		'bar': ['de'],
		'bat-smg': ['sgs', 'lt'],
		'bcc': ['fa'],
		'be-x-old': ['be-tarask'],
		'bh': ['bho'],
		'bjn': ['id'],
		'bm': ['fr'],
		'bpy': ['bn'],
		'bqi': ['fa'],
		'bug': ['id'],
		'cbk-zam': ['es'],
		'ce': ['ru'],
		'crh': ['crh-latn'],
		'crh-cyrl': ['ru'],
		'csb': ['pl'],
		'cv': ['ru'],
		'de-at': ['de'],
		'de-ch': ['de'],
		'de-formal': ['de'],
		'dsb': ['de'],
		'dtp': ['ms'],
		'egl': ['it'],
		'eml': ['it'],
		'ff': ['fr'],
		'fit': ['fi'],
		'fiu-vro': ['vro', 'et'],
		'frc': ['fr'],
		'frp': ['fr'],
		'frr': ['de'],
		'fur': ['it'],
		'gag': ['tr'],
		'gan': ['gan-hant', 'zh-hant', 'zh-hans'],
		'gan-hans': ['zh-hans'],
		'gan-hant': ['zh-hant', 'zh-hans'],
		'gl': ['pt'],
		'glk': ['fa'],
		'gn': ['es'],
		'gsw': ['de'],
		'hif': ['hif-latn'],
		'hsb': ['de'],
		'ht': ['fr'],
		'ii': ['zh-cn', 'zh-hans'],
		'inh': ['ru'],
		'iu': ['ike-cans'],
		'jut': ['da'],
		'jv': ['id'],
		'kaa': ['kk-latn', 'kk-cyrl'],
		'kbd': ['kbd-cyrl'],
		'khw': ['ur'],
		'kiu': ['tr'],
		'kk': ['kk-cyrl'],
		'kk-arab': ['kk-cyrl'],
		'kk-latn': ['kk-cyrl'],
		'kk-cn': ['kk-arab', 'kk-cyrl'],
		'kk-kz': ['kk-cyrl'],
		'kk-tr': ['kk-latn', 'kk-cyrl'],
		'kl': ['da'],
		'ko-kp': ['ko'],
		'koi': ['ru'],
		'krc': ['ru'],
		'ks': ['ks-arab'],
		'ksh': ['de'],
		'ku': ['ku-latn'],
		'ku-arab': ['ckb'],
		'kv': ['ru'],
		'lad': ['es'],
		'lb': ['de'],
		'lbe': ['ru'],
		'lez': ['ru'],
		'li': ['nl'],
		'lij': ['it'],
		'liv': ['et'],
		'lmo': ['it'],
		'ln': ['fr'],
		'ltg': ['lv'],
		'lzz': ['tr'],
		'mai': ['hi'],
		'map-bms': ['jv', 'id'],
		'mg': ['fr'],
		'mhr': ['ru'],
		'min': ['id'],
		'mo': ['ro'],
		'mrj': ['ru'],
		'mwl': ['pt'],
		'myv': ['ru'],
		'mzn': ['fa'],
		'nah': ['es'],
		'nap': ['it'],
		'nds': ['de'],
		'nds-nl': ['nl'],
		'nl-informal': ['nl'],
		'no': ['nb'],
		'os': ['ru'],
		'pcd': ['fr'],
		'pdc': ['de'],
		'pdt': ['de'],
		'pfl': ['de'],
		'pms': ['it'],
		'pt': ['pt-br'],
		'pt-br': ['pt'],
		'qu': ['es'],
		'qug': ['qu', 'es'],
		'rgn': ['it'],
		'rmy': ['ro'],
		'roa-rup': ['rup'],
		'rue': ['uk', 'ru'],
		'ruq': ['ruq-latn', 'ro'],
		'ruq-cyrl': ['mk'],
		'ruq-latn': ['ro'],
		'sa': ['hi'],
		'sah': ['ru'],
		'scn': ['it'],
		'sg': ['fr'],
		'sgs': ['lt'],
		'sli': ['de'],
		'sr': ['sr-ec'],
		'srn': ['nl'],
		'stq': ['de'],
		'su': ['id'],
		'szl': ['pl'],
		'tcy': ['kn'],
		'tg': ['tg-cyrl'],
		'tt': ['tt-cyrl', 'ru'],
		'tt-cyrl': ['ru'],
		'ty': ['fr'],
		'udm': ['ru'],
		'ug': ['ug-arab'],
		'uk': ['ru'],
		'vec': ['it'],
		'vep': ['et'],
		'vls': ['nl'],
		'vmf': ['de'],
		'vot': ['fi'],
		'vro': ['et'],
		'wa': ['fr'],
		'wo': ['fr'],
		'wuu': ['zh-hans'],
		'xal': ['ru'],
		'xmf': ['ka'],
		'yi': ['he'],
		'za': ['zh-hans'],
		'zea': ['nl'],
		'zh': ['zh-hans'],
		'zh-classical': ['lzh'],
		'zh-cn': ['zh-hans'],
		'zh-hant': ['zh-hans'],
		'zh-hk': ['zh-hant', 'zh-hans'],
		'zh-min-nan': ['nan'],
		'zh-mo': ['zh-hk', 'zh-hant', 'zh-hans'],
		'zh-my': ['zh-sg', 'zh-hans'],
		'zh-sg': ['zh-hans'],
		'zh-tw': ['zh-hant', 'zh-hans'],
		'zh-yue': ['yue']
	} );
}( jQuery ) );

/**
 * Bosnian (bosanski) language functions
 */
( function ( $ ) {
	'use strict';

	$.i18n.languages.bs = $.extend( {}, $.i18n.languages['default'], {
		convertGrammar: function ( word, form ) {
			switch ( form ) {
			case 'instrumental': // instrumental
				word = 's ' + word;
				break;
			case 'lokativ': // locative
				word = 'o ' + word;
				break;
			}

			return word;
		}
	} );

}( jQuery ) );

/**
 * Lower Sorbian (Dolnoserbski) language functions
 */
( function ( $ ) {
	'use strict';

	$.i18n.languages.dsb = $.extend( {}, $.i18n.languages['default'], {
		convertGrammar: function ( word, form ) {
			switch ( form ) {
				case 'instrumental': // instrumental
					word = 'z ' + word;
					break;
				case 'lokatiw': // lokatiw
					word = 'wo ' + word;
					break;
			}

			return word;
		}
	} );

}( jQuery ) );

/**
 * Finnish (Suomi) language functions
 *
 * @author Santhosh Thottingal
 */

( function ( $ ) {
	'use strict';

	$.i18n.languages.fi = $.extend( {}, $.i18n.languages['default'], {
		convertGrammar: function ( word, form ) {
			// vowel harmony flag
			var aou = word.match( /[aou][^äöy]*$/i ),
				origWord = word;
			if ( word.match( /wiki$/i ) ) {
				aou = false;
			}

			// append i after final consonant
			if ( word.match( /[bcdfghjklmnpqrstvwxz]$/i ) ) {
				word += 'i';
			}

			switch ( form ) {
			case 'genitive':
				word += 'n';
				break;
			case 'elative':
				word += ( aou ? 'sta' : 'stä' );
				break;
			case 'partitive':
				word += ( aou ? 'a' : 'ä' );
				break;
			case 'illative':
				// Double the last letter and add 'n'
				word += word.substr( word.length - 1 ) + 'n';
				break;
			case 'inessive':
				word += ( aou ? 'ssa' : 'ssä' );
				break;
			default:
				word = origWord;
				break;
			}

			return word;
		}
	} );
}( jQuery ) );

/**
 * Irish (Gaeilge) language functions
 */
( function ( $ ) {
	'use strict';

	$.i18n.languages.ga = $.extend( {}, $.i18n.languages['default'], {
		convertGrammar: function ( word, form ) {
			if ( form === 'ainmlae' ) {
				switch ( word ) {
				case 'an Domhnach':
					word = 'Dé Domhnaigh';
					break;
				case 'an Luan':
					word = 'Dé Luain';
					break;
				case 'an Mháirt':
					word = 'Dé Mháirt';
					break;
				case 'an Chéadaoin':
					word = 'Dé Chéadaoin';
					break;
				case 'an Déardaoin':
					word = 'Déardaoin';
					break;
				case 'an Aoine':
					word = 'Dé hAoine';
					break;
				case 'an Satharn':
					word = 'Dé Sathairn';
					break;
				}
			}

			return word;
		}
	} );
}( jQuery ) );

/**
 * Hebrew (עברית) language functions
 */
( function ( $ ) {
	'use strict';

	$.i18n.languages.he = $.extend( {}, $.i18n.languages['default'], {
		convertGrammar: function ( word, form ) {
			switch ( form ) {
			case 'prefixed':
			case 'תחילית': // the same word in Hebrew
				// Duplicate prefixed "Waw", but only if it's not already double
				if ( word.substr( 0, 1 ) === 'ו' && word.substr( 0, 2 ) !== 'וו' ) {
					word = 'ו' + word;
				}

				// Remove the "He" if prefixed
				if ( word.substr( 0, 1 ) === 'ה' ) {
					word = word.substr( 1, word.length );
				}

				// Add a hyphen (maqaf) before numbers and non-Hebrew letters
				if ( word.substr( 0, 1 ) < 'א' || word.substr( 0, 1 ) > 'ת' ) {
					word = '־' + word;
				}
			}

			return word;
		}
	} );
}( jQuery ) );

/**
 * Upper Sorbian (Hornjoserbsce) language functions
 */
( function ( $ ) {
	'use strict';

	$.i18n.languages.hsb = $.extend( {}, $.i18n.languages['default'], {
		convertGrammar: function ( word, form ) {
			switch ( form ) {
			case 'instrumental': // instrumental
				word = 'z ' + word;
				break;
			case 'lokatiw': // lokatiw
				word = 'wo ' + word;
				break;
			}

			return word;
		}
	} );
}( jQuery ) );

/**
 * Hungarian language functions
 *
 * @author Santhosh Thottingal
 */
( function ( $ ) {
	'use strict';

	$.i18n.languages.hu = $.extend( {}, $.i18n.languages['default'], {
		convertGrammar: function ( word, form ) {
			switch ( form ) {
			case 'rol':
				word += 'ról';
				break;
			case 'ba':
				word += 'ba';
				break;
			case 'k':
				word += 'k';
				break;
			}

			return word;
		}
	} );
}( jQuery ) );

/**
 * Armenian (Հայերեն) language functions
 */

( function ( $ ) {
	'use strict';

	$.i18n.languages.hy = $.extend( {}, $.i18n.languages['default'], {
		convertGrammar: function ( word, form ) {
			if ( form === 'genitive' ) { // սեռական հոլով
				if ( word.substr( -1 ) === 'ա' ) {
					word = word.substr( 0, word.length - 1 ) + 'այի';
				} else if ( word.substr( -1 ) === 'ո' ) {
					word = word.substr( 0, word.length - 1 ) + 'ոյի';
				} else if ( word.substr( -4 ) === 'գիրք' ) {
					word = word.substr( 0, word.length - 4 ) + 'գրքի';
				} else {
					word = word + 'ի';
				}
			}

			return word;
		}
	} );
}( jQuery ) );

/**
 * Latin (lingua Latina) language functions
 *
 * @author Santhosh Thottingal
 */

( function ( $ ) {
	'use strict';

	$.i18n.languages.la = $.extend( {}, $.i18n.languages['default'], {
		convertGrammar: function ( word, form ) {
			switch ( form ) {
			case 'genitive':
				// only a few declensions, and even for those mostly the singular only
				word = word.replace( /u[ms]$/i, 'i' ); // 2nd declension singular
				word = word.replace( /ommunia$/i, 'ommunium' ); // 3rd declension neuter plural (partly)
				word = word.replace( /a$/i, 'ae' ); // 1st declension singular
				word = word.replace( /libri$/i, 'librorum' ); // 2nd declension plural (partly)
				word = word.replace( /nuntii$/i, 'nuntiorum' ); // 2nd declension plural (partly)
				word = word.replace( /tio$/i, 'tionis' ); // 3rd declension singular (partly)
				word = word.replace( /ns$/i, 'ntis' );
				word = word.replace( /as$/i, 'atis' );
				word = word.replace( /es$/i, 'ei' ); // 5th declension singular
				break;
			case 'accusative':
				// only a few declensions, and even for those mostly the singular only
				word = word.replace( /u[ms]$/i, 'um' ); // 2nd declension singular
				word = word.replace( /ommunia$/i, 'am' ); // 3rd declension neuter plural (partly)
				word = word.replace( /a$/i, 'ommunia' ); // 1st declension singular
				word = word.replace( /libri$/i, 'libros' ); // 2nd declension plural (partly)
				word = word.replace( /nuntii$/i, 'nuntios' );// 2nd declension plural (partly)
				word = word.replace( /tio$/i, 'tionem' ); // 3rd declension singular (partly)
				word = word.replace( /ns$/i, 'ntem' );
				word = word.replace( /as$/i, 'atem' );
				word = word.replace( /es$/i, 'em' ); // 5th declension singular
				break;
			case 'ablative':
				// only a few declensions, and even for those mostly the singular only
				word = word.replace( /u[ms]$/i, 'o' ); // 2nd declension singular
				word = word.replace( /ommunia$/i, 'ommunibus' ); // 3rd declension neuter plural (partly)
				word = word.replace( /a$/i, 'a' ); // 1st declension singular
				word = word.replace( /libri$/i, 'libris' ); // 2nd declension plural (partly)
				word = word.replace( /nuntii$/i, 'nuntiis' ); // 2nd declension plural (partly)
				word = word.replace( /tio$/i, 'tione' ); // 3rd declension singular (partly)
				word = word.replace( /ns$/i, 'nte' );
				word = word.replace( /as$/i, 'ate' );
				word = word.replace( /es$/i, 'e' ); // 5th declension singular
				break;
			}

			return word;
		}
	} );
}( jQuery ) );

/**
 * Malayalam language functions
 *
 * @author Santhosh Thottingal
 */

( function ( $ ) {
	'use strict';

	$.i18n.languages.ml = $.extend( {}, $.i18n.languages['default'], {
		convertGrammar: function ( word, form ) {
			form = form.toLowerCase();
			switch ( form ) {
				case 'ഉദ്ദേശിക':
				case 'dative':
					if ( word.substr( -1 ) === 'ു' ||
						word.substr( -1 ) === 'ൂ' ||
						word.substr( -1 ) === 'ൗ' ||
						word.substr( -1 ) === 'ൌ'
					) {
						word += 'വിന്';
					} else if ( word.substr( -1 ) === 'ം' ) {
						word = word.substr( 0, word.length - 1 ) + 'ത്തിന്';
					} else if ( word.substr( -1 ) === 'ൻ' ) {
						// Atomic chillu n. അവൻ -> അവന്
						word = word.substr( 0, word.length - 1 ) + 'ന്';
					} else if ( word.substr( -3 ) === 'ന്\u200d' ) {
						// chillu n. അവൻ -> അവന്
						word = word.substr( 0, word.length - 1 );
					} else if ( word.substr( -1 ) === 'ൾ' || word.substr( -3 ) === 'ള്\u200d' ) {
						word += 'ക്ക്';
					} else if ( word.substr( -1 ) === 'ർ' || word.substr( -3 ) === 'ര്\u200d' ) {
						word += 'ക്ക്';
					} else if ( word.substr( -1 ) === 'ൽ' ) {
						// Atomic chillu ൽ , ഫയൽ -> ഫയലിന്
						word = word.substr( 0, word.length - 1 ) + 'ലിന്';
					} else if ( word.substr( -3 ) === 'ല്\u200d' ) {
						// chillu ല്\u200d , ഫയല്\u200d -> ഫയലിന്
						word = word.substr( 0, word.length - 2 ) + 'ിന്';
					} else if ( word.substr( -2 ) === 'ു്' ) {
						word = word.substr( 0, word.length - 2 ) + 'ിന്';
					} else if ( word.substr( -1 ) === '്' ) {
						word = word.substr( 0, word.length - 1 ) + 'ിന്';
					} else {
						// കാവ്യ -> കാവ്യയ്ക്ക്, ഹരി -> ഹരിയ്ക്ക്, മല -> മലയ്ക്ക്
						word += 'യ്ക്ക്';
					}

					break;
				case 'സംബന്ധിക':
				case 'genitive':
					if ( word.substr( -1 ) === 'ം' ) {
						word = word.substr( 0, word.length - 1 ) + 'ത്തിന്റെ';
					} else if ( word.substr( -2 ) === 'ു്' ) {
						word = word.substr( 0, word.length - 2 ) + 'ിന്റെ';
					} else if ( word.substr( -1 ) === '്' ) {
						word = word.substr( 0, word.length - 1 ) + 'ിന്റെ';
					} else if (  word.substr( -1 ) === 'ു' ||
						word.substr( -1 ) === 'ൂ' ||
						word.substr( -1 ) === 'ൗ' ||
						word.substr( -1 ) === 'ൌ'
					) {
						word += 'വിന്റെ';
					} else if ( word.substr( -1 ) === 'ൻ' ) {
						// Atomic chillu n. അവൻ -> അവന്റെ
						word = word.substr( 0, word.length - 1 ) + 'ന്റെ';
					} else if ( word.substr( -3 ) === 'ന്\u200d' ) {
						// chillu n. അവൻ -> അവന്റെ
						word = word.substr( 0, word.length - 1 ) + 'റെ';
					} else if ( word.substr( -3 ) === 'ള്\u200d' ) {
						// chillu n. അവൾ -> അവളുടെ
						word = word.substr( 0, word.length - 2 ) + 'ുടെ';
					} else if ( word.substr( -1 ) === 'ൾ' ) {
						// Atomic chillu n. അവള്\u200d -> അവളുടെ
						word = word.substr( 0, word.length - 1 ) + 'ളുടെ';
					} else if ( word.substr( -1 ) === 'ൽ' ) {
						// Atomic l. മുയല്\u200d -> മുയലിന്റെ
						word = word.substr( 0, word.length - 1 ) + 'ലിന്റെ';
					} else if ( word.substr( -3 ) === 'ല്\u200d' ) {
						// chillu l. മുയല്\u200d -> അവളുടെ
						word = word.substr( 0, word.length - 2 ) + 'ിന്റെ';
					} else if ( word.substr( -3 ) === 'ര്\u200d' ) {
						// chillu r. അവര്\u200d -> അവരുടെ
						word = word.substr( 0, word.length - 2 ) + 'ുടെ';
					} else if ( word.substr( -1 ) === 'ർ' ) {
						// Atomic chillu r. അവർ -> അവരുടെ
						word = word.substr( 0, word.length - 1 ) + 'രുടെ';
					} else {
						word += 'യുടെ';
					}

					break;
			}

			return word;
		}
	} );
}( jQuery ) );

/**
 * Ossetian (Ирон) language functions
 *
 * @author Santhosh Thottingal
 */

( function ( $ ) {
	'use strict';

	$.i18n.languages.os = $.extend( {}, $.i18n.languages['default'], {
		convertGrammar: function ( word, form ) {
			var endAllative, jot, hyphen, ending;

			// Ending for allative case
			endAllative = 'мæ';
			// Variable for 'j' beetwen vowels
			jot = '';
			// Variable for "-" for not Ossetic words
			hyphen = '';
			// Variable for ending
			ending = '';

			// Checking if the $word is in plural form
			if ( word.match( /тæ$/i ) ) {
				word = word.substring( 0, word.length - 1 );
				endAllative = 'æм';
			}
			// Works if word is in singular form.
			// Checking if word ends on one of the vowels: е, ё, и, о, ы, э, ю,
			// я.
			else if ( word.match( /[аæеёиоыэюя]$/i ) ) {
				jot = 'й';
			}
			// Checking if word ends on 'у'. 'У' can be either consonant 'W' or
			// vowel 'U' in cyrillic Ossetic.
			// Examples: {{grammar:genitive|аунеу}} = аунеуы,
			// {{grammar:genitive|лæппу}} = лæппуйы.
			else if ( word.match( /у$/i ) ) {
				if ( !word.substring( word.length - 2, word.length - 1 )
						.match( /[аæеёиоыэюя]$/i ) ) {
					jot = 'й';
				}
			} else if ( !word.match( /[бвгджзйклмнопрстфхцчшщьъ]$/i ) ) {
				hyphen = '-';
			}

			switch ( form ) {
			case 'genitive':
				ending = hyphen + jot + 'ы';
				break;
			case 'dative':
				ending = hyphen + jot + 'æн';
				break;
			case 'allative':
				ending = hyphen + endAllative;
				break;
			case 'ablative':
				if ( jot === 'й' ) {
					ending = hyphen + jot + 'æ';
				} else {
					ending = hyphen + jot + 'æй';
				}
				break;
			case 'superessive':
				ending = hyphen + jot + 'ыл';
				break;
			case 'equative':
				ending = hyphen + jot + 'ау';
				break;
			case 'comitative':
				ending = hyphen + 'имæ';
				break;
			}

			return word + ending;
		}
	} );
}( jQuery ) );

/**
 * Russian (Русский) language functions
 */

( function ( $ ) {
	'use strict';

	$.i18n.languages.ru = $.extend( {}, $.i18n.languages['default'], {
		convertGrammar: function ( word, form ) {
			if ( form === 'genitive' ) { // родительный падеж
				if ( word.substr( -1 ) === 'ь' ) {
					word = word.substr( 0, word.length - 1 ) + 'я';
				} else if ( word.substr( -2 ) === 'ия' ) {
					word = word.substr( 0, word.length - 2 ) + 'ии';
				} else if ( word.substr( -2 ) === 'ка' ) {
					word = word.substr( 0, word.length - 2 ) + 'ки';
				} else if ( word.substr( -2 ) === 'ти' ) {
					word = word.substr( 0, word.length - 2 ) + 'тей';
				} else if ( word.substr( -2 ) === 'ды' ) {
					word = word.substr( 0, word.length - 2 ) + 'дов';
				} else if ( word.substr( -3 ) === 'ник' ) {
					word = word.substr( 0, word.length - 3 ) + 'ника';
				}
			}

			return word;
		}
	} );
}( jQuery ) );

/**
 * Slovenian (Slovenščina) language functions
 */

( function ( $ ) {
	'use strict';

	$.i18n.languages.sl = $.extend( {}, $.i18n.languages['default'], {
		convertGrammar: function ( word, form ) {
			switch ( form ) {
				// locative
				case 'mestnik':
					word = 'o ' + word;

					break;
				// instrumental
				case 'orodnik':
					word = 'z ' + word;

					break;
			}

			return word;
		}
	} );
}( jQuery ) );

/**
 * Ukrainian (Українська) language functions
 */

( function ( $ ) {
	'use strict';

	$.i18n.languages.uk = $.extend( {}, $.i18n.languages['default'], {
		convertGrammar: function ( word, form ) {
			switch ( form ) {
			case 'genitive': // родовий відмінок
				if ( word.substr( -1 ) === 'ь' ) {
					word = word.substr( 0, word.length - 1 ) + 'я';
				} else if ( word.substr( -2 ) === 'ія' ) {
					word = word.substr( 0, word.length - 2 ) + 'ії';
				} else if ( word.substr( -2 ) === 'ка' ) {
					word = word.substr( 0, word.length - 2 ) + 'ки';
				} else if ( word.substr( -2 ) === 'ти' ) {
					word = word.substr( 0, word.length - 2 ) + 'тей';
				} else if ( word.substr( -2 ) === 'ды' ) {
					word = word.substr( 0, word.length - 2 ) + 'дов';
				} else if ( word.substr( -3 ) === 'ник' ) {
					word = word.substr( 0, word.length - 3 ) + 'ника';
				}

				break;
			case 'accusative': // знахідний відмінок
				if ( word.substr( -2 ) === 'ія' ) {
					word = word.substr( 0, word.length - 2 ) + 'ію';
				}

				break;
			}

			return word;
		}
	} );

}( jQuery ) );

// Please do not edit. This file is generated from data/langdb.yaml by ulsdata2json.php
( function ( $ ) {
	'use strict';
	$.uls = $.uls || {};
	//noinspection JSHint
	$.uls.data = {"languages":{"aa":["Latn",["AF"],"Qafár af"],"ab":["Cyrl",["EU"],"Аҧсшәа"],"ace":["Latn",["AS","PA"],"Acèh"],"ady":["Cyrl",["EU","ME"],"Адыгэбзэ"],"ady-cyrl":["ady"],"ady-latn":["Latn",["EU","ME"],"Adygabze"],"aeb":["Arab",["AF"],"زَوُن"],"af":["Latn",["AF"],"Afrikaans"],"ahr":["Deva",["AS"],"अहिराणी"],"ak":["Latn",["AF"],"Akan"],"akz":["Latn",["AM"],"Albaamo innaaɬiilka"],"aln":["Latn",["EU"],"Gegë"],"am":["Ethi",["AF"],"አማርኛ"],"an":["Latn",["EU"],"aragonés"],"ang":["Latn",["EU"],"Ænglisc"],"anp":["Deva",["AS"],"अङ्गिका"],"ar":["Arab",["ME"],"العربية"],"arc":["Syrc",["ME"],"ܐܪܡܝܐ"],"arn":["Latn",["AM"],"mapudungun"],"aro":["Latn",["AM"],"Araona"],"arq":["Latn",["AF"],"Dziri"],"ary":["Latn",["ME"],"Maġribi"],"arz":["Arab",["ME"],"مصرى"],"as":["Beng",["AS"],"অসমীয়া"],"ase":["Sgnw",["AM"],"American sign language"],"ast":["Latn",["EU"],"asturianu"],"av":["Cyrl",["EU"],"авар"],"avk":["Latn",["WW"],"Kotava"],"ay":["Latn",["AM"],"Aymar aru"],"az":["az-latn"],"az-latn":["Latn",["EU","ME"],"azərbaycanca"],"az-arab":["Arab",["EU","ME"],"آذربايجانجا"],"az-cyrl":["Latn",["EU","ME"],"азәрбајҹанҹа"],"azb":["az-arab"],"ba":["Cyrl",["EU"],"башҡортса"],"bar":["Latn",["EU"],"Boarisch"],"bat-smg":["sgs"],"bbc-latn":["Latn",["AS"],"Batak Toba"],"bbc-batk":["Batk",["AS"],"Batak Toba"],"bbc":["Latn",["AS"],"Batak Toba"],"bcc":["Arab",["AS","ME"],"بلوچی مکرانی"],"bcl":["Latn",["AS"],"Bikol Central"],"be-tarask":["Cyrl",["EU"],"беларуская (тарашкевіца)"],"be-x-old":["be-tarask"],"be":["Cyrl",["EU"],"беларуская"],"bew":["Latn",["AS"],"Bahasa Betawi"],"bfq":["Taml",["AS"],"படகா"],"bg":["Cyrl",["EU"],"български"],"bh":["Deva",["AS"],"भोजपुरी"],"bho":["Deva",["AS"],"भोजपुरी"],"bi":["Latn",["PA"],"Bislama"],"bjn":["Latn",["AS"],"Bahasa Banjar"],"bm":["Latn",["AF"],"bamanankan"],"bn":["Beng",["AS"],"বাংলা"],"bo":["Tibt",["AS"],"བོད་ཡིག"],"bpy":["Beng",["AS"],"বিষ্ণুপ্রিয়া মণিপুরী"],"bqi":["Arab",["ME"],"بختياري"],"br":["Latn",["EU"],"brezhoneg"],"brh":["Latn",["ME","AS"],"Bráhuí"],"brx":["Deva",["AS"],"बड़ो"],"bs":["Latn",["EU"],"bosanski"],"bto":["Latn",["AS"],"Iriga Bicolano"],"bug":["Bugi",["AS"],"ᨅᨔ ᨕᨘᨁᨗ"],"bxr":["Cyrl",["AS"],"буряад"],"ca":["Latn",["EU"],"català"],"cbk-zam":["Latn",["AS"],"Chavacano de Zamboanga"],"cdo":["Latn",["AS"],"Mìng-dĕ̤ng-ngṳ̄"],"ce":["Cyrl",["EU"],"нохчийн"],"ceb":["Latn",["AS"],"Cebuano"],"ch":["Latn",["PA"],"Chamoru"],"cho":["Latn",["AM"],"Choctaw"],"chr":["Cher",["AM"],"ᏣᎳᎩ"],"chy":["Latn",["AM"],"Tsetsêhestâhese"],"ckb":["Arab",["ME"],"کوردی"],"co":["Latn",["EU"],"corsu"],"cps":["Latn",["AS"],"Capiceño"],"cr":["Cans",["AM"],"ᓀᐦᐃᔭᐍᐏᐣ"],"cr-cans":["cr"],"cr-latn":["Latn",["AM"],"Nēhiyawēwin"],"crh":["Latn",["EU"],"qırımtatarca"],"crh-cyrl":["Cyrl",["EU"],"къырымтатарджа"],"crh-latn":["crh"],"cs":["Latn",["EU"],"česky"],"csb":["Latn",["EU"],"kaszëbsczi"],"cu":["Cyrl",["EU"],"словѣньскъ \/ ⰔⰎⰑⰂⰡⰐⰠⰔⰍⰟ"],"cv":["Cyrl",["EU"],"Чӑвашла"],"cy":["Latn",["EU"],"Cymraeg"],"da":["Latn",["EU"],"dansk"],"de-at":["Latn",["EU"],"Österreichisches Deutsch"],"de-ch":["Latn",["EU"],"Schweizer Hochdeutsch"],"de-formal":["Latn",["EU"],"Deutsch (Sie-Form)"],"de":["Latn",["EU"],"Deutsch"],"diq":["Latn",["EU","AS"],"Zazaki"],"dsb":["Latn",["EU"],"dolnoserbski"],"dtp":["Latn",["AS"],"Dusun Bundu-liwan"],"dv":["Thaa",["AS"],"ދިވެހިބަސް"],"dz":["Tibt",["AS"],"ཇོང་ཁ"],"ee":["Latn",["AF"],"eʋegbe"],"egl":["Latn",["EU"],"Emiliàn"],"el":["Grek",["EU"],"Ελληνικά"],"eml":["Latn",["EU"],"emiliàn e rumagnòl"],"en-ca":["Latn",["AM"],"Canadian English"],"en-gb":["Latn",["EU","AS","PA"],"British English"],"en":["Latn",["EU","AM","AF","ME","AS","PA","WW"],"English"],"eo":["Latn",["WW"],"Esperanto"],"es-419":["Latn",["AM"],"español de America Latina"],"es-formal":["Latn",["EU","AM","AF","WW"],"español (formal)"],"es":["Latn",["EU","AM","AF","WW"],"español"],"esu":["Latn",["AM"],"Yup'ik"],"et":["Latn",["EU"],"eesti"],"eu":["Latn",["EU"],"euskara"],"ext":["Latn",["EU"],"estremeñu"],"fa":["Arab",["ME"],"فارسی"],"ff":["Latn",["AF"],"Fulfulde"],"fi":["Latn",["EU"],"suomi"],"fil":["tl"],"fit":["Latn",["EU"],"meänkieli"],"fiu-vro":["vro"],"fj":["Latn",["PA"],"Na Vosa Vakaviti"],"fo":["Latn",["EU"],"føroyskt"],"fr":["Latn",["EU","AM","WW"],"français"],"frc":["Latn",["AM"],"français cadien"],"frp":["Latn",["EU"],"arpetan"],"frr":["Latn",["EU"],"Nordfriisk"],"fur":["Latn",["EU"],"furlan"],"fy":["Latn",["EU"],"Frysk"],"ga":["Latn",["EU"],"Gaeilge"],"gag":["Latn",["EU"],"Gagauz"],"gah":["Latn",["AS"],"Alekano"],"gan-hans":["Hans",["AS"],"赣语（简体）"],"gan-hant":["gan"],"gan":["Hant",["AS"],"贛語"],"gbz":["Latn",["AS"],"Dari"],"gcf":["Latn",["AM"],"Guadeloupean Creole French"],"gd":["Latn",["EU"],"Gàidhlig"],"gl":["Latn",["EU"],"galego"],"glk":["Arab",["ME"],"گیلکی"],"gn":["Latn",["AM"],"Avañe'ẽ"],"gom":["Deva",["AS"],"कोंकणी"],"gom-deva":["gom"],"gom-latn":["Latn",["AS"],"Konknni"],"got":["Goth",["EU"],"𐌲𐌿𐍄𐌹𐍃𐌺"],"grc":["Grek",["EU"],"Ἀρχαία ἑλληνικὴ"],"gsw":["Latn",["EU"],"Alemannisch"],"gu":["Gujr",["AS"],"ગુજરાતી"],"guc":["Latn",["AM"],"Wayúu"],"gur":["Latn",["AF"],"Gurenɛ"],"gv":["Latn",["EU"],"Gaelg"],"ha-arab":["Arab",["AF"],"هَوُسَ"],"ha-latn":["Latn",["AF"],"Hausa"],"ha":["ha-latn"],"hak":["Latn",["AS"],"Hak-kâ-fa"],"haw":["Latn",["AM","PA"],"Hawai`i"],"he":["Hebr",["ME"],"עברית"],"hi":["Deva",["AS"],"हिन्दी"],"hif":["Latn",["PA","AS"],"Fiji Hindi"],"hif-deva":["Deva",["AS"],"फ़ीजी हिन्दी"],"hif-latn":["hif"],"hil":["Latn",["AS"],"Ilonggo"],"hne":["Deva",["AS"],"छत्तीसगढ़ी"],"ho":["Latn",["PA"],"Hiri Motu"],"hr":["Latn",["EU"],"hrvatski"],"hsb":["Latn",["EU"],"hornjoserbsce"],"hsn":["Hans",["AS"],"湘语"],"ht":["Latn",["AM"],"Kreyòl ayisyen"],"hu-formal":["Latn",["EU"],"Magyar (magázó)"],"hu":["Latn",["EU"],"magyar"],"hy":["Armn",["EU","ME"],"Հայերեն"],"hz":["Latn",["AF"],"Otsiherero"],"ia":["Latn",["WW"],"interlingua"],"id":["Latn",["AS"],"Bahasa Indonesia"],"ie":["Latn",["WW"],"Interlingue"],"ig":["Latn",["AF"],"Igbo"],"ii":["Yiii",["AS"],"ꆇꉙ"],"ik":["Latn",["AM"],"Iñupiak"],"ike-cans":["Cans",["AM"],"ᐃᓄᒃᑎᑐᑦ"],"ike-latn":["Latn",["AM"],"inuktitut"],"ilo":["Latn",["AS"],"Ilokano"],"inh":["Cyrl",["EU"],"ГӀалгӀай"],"io":["Latn",["WW"],"Ido"],"is":["Latn",["EU"],"íslenska"],"it":["Latn",["EU"],"italiano"],"iu":["Cans",["AM"],"ᐃᓄᒃᑎᑐᑦ"],"ja":["Jpan",["AS"],"日本語"],"jam":["Latn",["AM"],"Patois"],"jbo":["Latn",["WW"],"lojban"],"jut":["Latn",["EU"],"jysk"],"jv":["Latn",["AS","PA"],"Basa Jawa"],"jv-java":["Java",["AS","PA"],"ꦧꦱꦗꦮ"],"ka":["Geor",["EU"],"ქართული"],"kaa":["Latn",["AS"],"Qaraqalpaqsha"],"kab":["Latn",["AF","EU"],"Taqbaylit"],"kbd-cyrl":["kbd"],"kbd-latn":["Latn",["EU"],"Qabardjajəbza"],"kbd":["Cyrl",["EU","ME"],"Адыгэбзэ"],"kea":["Latn",["AF"],"Kabuverdianu"],"kg":["Latn",["AF"],"Kongo"],"kgp":["Latn",["AM"],"Kaingáng"],"khw":["Arab",["ME","AS"],"کھوار"],"ki":["Latn",["AF"],"Gĩkũyũ"],"kiu":["Latn",["EU","ME"],"Kırmancki"],"kj":["Latn",["AF"],"Kwanyama"],"kk":["kk-cyrl"],"kk-arab":["Arab",["EU","AS"],"قازاقشا (تٶتە)"],"kk-cn":["kk-arab"],"kk-cyrl":["Cyrl",["EU","AS"],"қазақша"],"kk-kz":["kk-cyrl"],"kk-latn":["Latn",["EU","AS","ME"],"qazaqşa"],"kk-tr":["kk-latn"],"kl":["Latn",["AM","EU"],"kalaallisut"],"km":["Khmr",["AS"],"ភាសាខ្មែរ"],"kn":["Knda",["AS"],"ಕನ್ನಡ"],"ko-kp":["Kore",["AS"],"한국어 (조선)"],"ko":["Kore",["AS"],"한국어"],"koi":["Cyrl",["EU"],"Перем Коми"],"kr":["Latn",["AF"],"Kanuri"],"krc":["Cyrl",["EU"],"къарачай-малкъар"],"kri":["Latn",["AF"],"Krio"],"krj":["Latn",["ME","EU"],"Kinaray-a"],"krl":["Latn",["EU"],"Karjala"],"ks-arab":["Arab",["AS"],"کٲشُر"],"ks-deva":["Deva",["AS"],"कॉशुर"],"ks":["Arab",["AS"],"کٲشُر"],"ksf":["Latn",["AF"],"Bafia"],"ksh":["Latn",["EU"],"Ripoarisch"],"ku":["ku-latn"],"ku-arab":["Arab",["EU","ME"],"كوردي"],"ku-latn":["Latn",["EU","ME"],"Kurdî"],"kv":["Cyrl",["EU"],"коми"],"kw":["Latn",["EU"],"kernowek"],"ky":["Cyrl",["AS"],"Кыргызча"],"la":["Latn",["EU"],"Latina"],"lad":["lad-latn"],"lad-latn":["Latn",["ME","EU","AM"],"Ladino"],"lad-hebr":["Hebr",["ME","EU","AM"],"לאדינו"],"lb":["Latn",["EU"],"Lëtzebuergesch"],"lbe":["Cyrl",["EU"],"лакку"],"lez":["Cyrl",["EU"],"лезги"],"lfn":["Latn",["WW"],"Lingua Franca Nova"],"lg":["Latn",["AF"],"Luganda"],"li":["Latn",["EU"],"Limburgs"],"lij":["Latn",["EU"],"Ligure"],"liv":["Latn",["EU"],"Līvõ kēļ"],"lld":["Latn",["EU"],"Ladin"],"lmo":["Latn",["EU"],"lumbaart"],"ln":["Latn",["AF"],"lingála"],"lo":["Laoo",["AS"],"ລາວ"],"loz":["Latn",["AF"],"Silozi"],"lt":["Latn",["EU"],"lietuvių"],"lrc":["Arab",["AS"],"لوری"],"ltg":["Latn",["EU"],"latgaļu"],"lus":["Latn",["AS"],"Mizo ţawng"],"lut":["Latn",["AM"],"dxʷləšucid"],"lv":["Latn",["EU"],"latviešu"],"lzh":["Hant",["AS"],"文言"],"lzz":["Latn",["EU","ME"],"Lazuri"],"mai":["Deva",["AS"],"मैथिली"],"map-bms":["Latn",["AS"],"Basa Banyumasan"],"mdf":["Cyrl",["EU"],"мокшень"],"mfe":["Latn",["AM"],"Morisyen"],"mg":["Latn",["AF"],"Malagasy"],"mh":["Latn",["PA"],"Ebon"],"mhr":["Cyrl",["EU"],"олык марий"],"mi":["Latn",["PA"],"Māori"],"mic":["Latn",["AM"],"Mi'kmaq"],"min":["Latn",["AS"],"Baso Minangkabau"],"mk":["Cyrl",["EU"],"македонски"],"ml":["Mlym",["AS","ME"],"മലയാളം"],"mn":["Cyrl",["AS"],"монгол"],"mnc":["Mong",["AS"],"ᠮᠠᠨᠵᡠ ᡤᡳᠰᡠᠨ"],"mni":["Beng",["AS"],"মেইতেই লোন্"],"mnw":["Mymr",["AS"],"ဘာသာ မန်"],"mo":["Cyrl",["EU"],"молдовеняскэ"],"mr":["Deva",["AS","ME"],"मराठी"],"mrj":["Cyrl",["EU"],"кырык мары"],"ms":["Latn",["AS"],"Bahasa Melayu"],"mt":["Latn",["EU"],"Malti"],"mui":["Latn",["AS"],"Musi"],"mus":["Latn",["AM"],"Mvskoke"],"mwl":["Latn",["EU"],"Mirandés"],"mwv":["Latn",["AS"],"Behase Mentawei"],"my":["Mymr",["AS"],"မြန်မာဘာသာ"],"myv":["Cyrl",["EU"],"эрзянь"],"mzn":["Arab",["ME","AS"],"مازِرونی"],"na":["Latn",["PA"],"Dorerin Naoero"],"nah":["Latn",["AM"],"Nāhuatl"],"nan":["Latn",["AS"],"Bân-lâm-gú"],"nap":["Latn",["EU"],"Nnapulitano"],"nb":["Latn",["EU"],"norsk (bokmål)"],"nds-nl":["Latn",["EU"],"Nedersaksisch"],"nds":["Latn",["EU"],"Plattdüütsch"],"ne":["Deva",["AS"],"नेपाली"],"new":["Deva",["AS"],"नेपाल भाषा"],"ng":["Latn",["AF"],"Oshiwambo"],"niu":["Latn",["PA"],"ko e vagahau Niuē"],"njo":["Latn",["AS"],"Ao"],"nl-informal":["Latn",["EU","AM"],"Nederlands (informeel)"],"nl":["Latn",["EU","AM"],"Nederlands"],"nn":["Latn",["EU"],"norsk (nynorsk)"],"no":["Latn",["EU"],"norsk"],"nov":["Latn",["WW"],"Novial"],"nqo":["Nkoo",["AF"],"ߒߞߏ"],"nrm":["Latn",["EU"],"Nouormand"],"nso":["Latn",["AF"],"Sesotho sa Leboa"],"nv":["Latn",["AM"],"Diné bizaad"],"ny":["Latn",["AF"],"Chi-Chewa"],"oc":["Latn",["EU"],"occitan"],"om":["Latn",["AF"],"Oromoo"],"or":["Orya",["AS"],"ଓଡ଼ିଆ"],"os":["Cyrl",["EU"],"Ирон"],"ota":["Latn",["AS","EU"],"Ottoman Turkish"],"pa":["pa-guru"],"pa-guru":["Guru",["AS"],"ਪੰਜਾਬੀ"],"pag":["Latn",["AS"],"Pangasinan"],"pam":["Latn",["AS"],"Kapampangan"],"pap":["Latn",["AM"],"Papiamentu"],"pcd":["Latn",["EU"],"Picard"],"pdc":["Latn",["EU","AM"],"Deitsch"],"pdt":["Latn",["EU","AM"],"Plautdietsch"],"pfl":["Latn",["EU"],"Pälzisch"],"pi":["Deva",["AS"],"पालि"],"pih":["Latn",["PA"],"Norfuk \/ Pitkern"],"pis":["Latn",["PA"],"Pijin"],"pko":["Latn",["AF"],"Pökoot"],"pl":["Latn",["EU"],"polski"],"pms":["Latn",["EU"],"Piemontèis"],"pnb":["Arab",["AS","ME"],"پنجابی"],"pnt":["Grek",["EU"],"Ποντιακά"],"ppl":["Latn",["AM"],"Nawat"],"prg":["Latn",["EU"],"Prūsiskan"],"ps":["Arab",["AS","ME"],"پښتو"],"pt-br":["Latn",["AM"],"português do Brasil"],"pt":["Latn",["EU","AM","AS","PA","AF","WW"],"português"],"qu":["Latn",["AM"],"Runa Simi"],"qug":["Latn",["AM"],"Runa shimi"],"rap":["Latn",["AM"],"arero rapa nui"],"rgn":["Latn",["EU"],"Rumagnôl"],"rif":["Latn",["AF"],"Tarifit"],"rki":["Mymr",["AS"],"ရခိုင်"],"rm":["Latn",["EU"],"rumantsch"],"rmf":["Latn",["EU"],"kaalengo tšimb"],"rmy":["Latn",["EU"],"Romani"],"rn":["Latn",["AF"],"Kirundi"],"ro":["Latn",["EU"],"română"],"roa-rup":["rup"],"roa-tara":["Latn",["EU"],"tarandíne"],"rtm":["Latn",["PA"],"Faeag Rotuma"],"ru":["Cyrl",["EU","AS","ME"],"русский"],"rue":["Cyrl",["EU"],"русиньскый"],"rup":["Latn",["EU"],"Armãneashce"],"ruq":["Cyrl",["EU"],"Влахесте"],"ruq-cyrl":["ruq"],"ruq-grek":["Grek",["EU"],"Megleno-Romanian (Greek script)"],"ruq-latn":["Latn",["EU"],"Vlăheşte"],"rw":["Latn",["AF"],"Kinyarwanda"],"rwr":["Deva",["AS"],"मारवाड़ी"],"ryu":["Kana",["AS"],"ʔucināguci"],"sa":["Deva",["AS"],"संस्कृतम्"],"sah":["Cyrl",["EU","AS"],"саха тыла"],"sat":["Latn",["AS"],"Santali"],"saz":["Saur",["AS"],"ꢱꣃꢬꢵꢯ꣄ꢡ꣄ꢬꢵ"],"sc":["Latn",["EU"],"sardu"],"scn":["Latn",["EU"],"sicilianu"],"sco":["Latn",["EU"],"Scots"],"sd":["Arab",["AS"],"سنڌي"],"sdc":["Latn",["EU"],"Sassaresu"],"se":["Latn",["EU"],"sámegiella"],"ses":["Latn",["AF"],"Koyraboro Senni"],"sei":["Latn",["AM"],"Cmique Itom"],"sg":["Latn",["AF"],"Sängö"],"sgs":["Latn",["EU"],"žemaitėška"],"sh":["Latn",["EU"],"srpskohrvatski"],"shi-latn":["Latn",["AF"],"Tašlḥiyt"],"shi-tfng":["Tfng",["AF"],"ⵜⴰⵛⵍⵃⵉⵜ"],"shi":["shi-latn"],"shn":["Mymr",["AS"],"လိၵ်ႈတႆး"],"si":["Sinh",["AS"],"සිංහල"],"simple":["Latn",["WW"],"Simple English"],"sk":["Latn",["EU"],"slovenčina"],"sl":["Latn",["EU"],"slovenščina"],"sli":["Latn",["EU"],"Schläsch"],"slr":["Latn",["AS"],"Salırça"],"sly":["Latn",["AS"],"Bahasa Selayar"],"syc":["Syrc",["ME"],"ܣܘܪܝܝܐ"],"sm":["Latn",["PA"],"Gagana Samoa"],"sma":["Latn",["EU"],"åarjelsaemien"],"smj":["Latn",["EU"],"julevsámegiella"],"smn":["Latn",["EU"],"anarâškielâ"],"sms":["Latn",["EU"],"sää´mǩiõll"],"sn":["Latn",["AF"],"chiShona"],"so":["Latn",["AF"],"Soomaaliga"],"sq":["Latn",["EU"],"shqip"],"sr":["sr-cyrl"],"sr-ec":["sr-cyrl"],"sr-cyrl":["Cyrl",["EU"],"српски"],"sr-el":["sr-latn"],"sr-latn":["Latn",["EU"],"srpski"],"srn":["Latn",["AM","EU"],"Sranantongo"],"ss":["Latn",["AF"],"SiSwati"],"st":["Latn",["AF"],"Sesotho"],"stq":["Latn",["EU"],"Seeltersk"],"su":["Latn",["AS"],"Basa Sunda"],"sv":["Latn",["EU"],"svenska"],"sw":["Latn",["AF"],"Kiswahili"],"swb":["Latn",["AF"],"Shikomoro"],"sxu":["Latn",["EU"],"Säggssch"],"szl":["Latn",["EU"],"ślůnski"],"ta":["Taml",["AS"],"தமிழ்"],"tcy":["Knda",["AS"],"ತುಳು"],"te":["Telu",["AS"],"తెలుగు"],"tet":["Latn",["AS","PA"],"tetun"],"tg-cyrl":["Cyrl",["AS"],"тоҷикӣ"],"tg-latn":["Latn",["AS"],"tojikī"],"tg":["Cyrl",["AS"],"тоҷикӣ"],"th":["Thai",["AS"],"ไทย"],"ti":["Ethi",["AF"],"ትግርኛ"],"tk":["Latn",["AS"],"Türkmençe"],"tkr":["Cyrl",["AS"],"ЦӀаьхна миз"],"tl":["Latn",["AS"],"Tagalog"],"tly":["Cyrl",["EU","AS","ME"],"толышә зывон"],"tn":["Latn",["AF"],"Setswana"],"to":["Latn",["PA"],"lea faka-Tonga"],"tokipona":["Latn",["WW"],"Toki Pona"],"tpi":["Latn",["PA","AS"],"Tok Pisin"],"tr":["Latn",["EU","ME"],"Türkçe"],"trp":["Latn",["AS"],"Kokborok (Tripuri)"],"tru":["Latn",["AS"],"Ṫuroyo"],"ts":["Latn",["AF"],"Xitsonga"],"tsd":["Grek",["EU"],"Τσακωνικά"],"tt":["Cyrl",["EU"],"татарча"],"tt-cyrl":["tt"],"tt-latn":["Latn",["EU"],"tatarça"],"ttt":["Cyrl",["AS"],"Tati"],"tum":["Latn",["AF"],"chiTumbuka"],"tw":["Latn",["AF"],"Twi"],"twd":["Latn",["EU"],"Tweants"],"ty":["Latn",["PA"],"Reo Mā`ohi"],"tyv":["Cyrl",["AS"],"тыва дыл"],"tzm":["Tfng",["AF"],"ⵜⴰⵎⴰⵣⵉⵖⵜ"],"udm":["Cyrl",["EU"],"удмурт"],"ug":["ug-arab"],"ug-arab":["Arab",["AS"],"ئۇيغۇرچە"],"ug-latn":["Latn",["AS"],"uyghurche"],"ug-cyrl":["Cyrl",["AS"],"уйғурчә"],"uk":["Cyrl",["EU"],"українська"],"ur":["Arab",["AS","ME"],"اردو"],"uz":["Latn",["AS"],"oʻzbekcha"],"ve":["Latn",["AF"],"Tshivenda"],"vec":["Latn",["EU"],"vèneto"],"vep":["Latn",["EU"],"vepsän kel’"],"vi":["Latn",["AS"],"Tiếng Việt"],"vls":["Latn",["EU"],"West-Vlams"],"vmf":["Latn",["EU"],"Mainfränkisch"],"vo":["Latn",["WW"],"Volapük"],"vot":["Latn",["EU"],"Vaďďa"],"vro":["Latn",["EU"],"Võro"],"wa":["Latn",["EU"],"walon"],"war":["Latn",["AS"],"Winaray"],"wls":["Latn",["PA"],"Faka'uvea"],"wo":["Latn",["AF"],"Wolof"],"wuu":["Hans",["AS"],"吴语"],"xal":["Cyrl",["EU"],"хальмг"],"xh":["Latn",["AF"],"isiXhosa"],"xmf":["Geor",["EU"],"მარგალური"],"ydd":["Hebr",["AS","EU"],"Eastern Yiddish"],"yi":["Hebr",["ME","EU","AM"],"ייִדיש"],"yo":["Latn",["AF"],"Yorùbá"],"yrk":["Cyrl",["AS"],"Ненэцяʼ вада"],"yrl":["Latn",["AM"],"ñe'engatú"],"yua":["Latn",["AM"],"Maaya T'aan"],"yue":["Hant",["AS"],"粵語"],"za":["Latn",["AS"],"Vahcuengh"],"zea":["Latn",["EU"],"Zeêuws"],"zh":["Hans",["AS"],"中文"],"zh-classical":["Hant",["AS"],"文言"],"zh-cn":["Hans",["AS"],"中文（中国大陆）"],"zh-hans":["Hans",["AS"],"中文（简体）"],"zh-hant":["Hant",["AS"],"中文（繁體）"],"zh-hk":["Hant",["AS"],"中文（香港）"],"zh-min-nan":["nan"],"zh-mo":["Hant",["AS"],"中文（澳門）"],"zh-my":["Hans",["AS"],"中文（马来西亚）"],"zh-sg":["Hans",["AS"],"中文（新加坡）"],"zh-tw":["Hant",["AS"],"中文（台灣）"],"zh-yue":["yue"],"zu":["Latn",["AF"],"isiZulu"]},"scriptgroups":{"Latin":["Latn","Goth"],"Greek":["Grek"],"WestCaucasian":["Armn","Geor"],"Arabic":["Arab"],"MiddleEastern":["Hebr","Syrc"],"African":["Ethi","Nkoo","Tfng"],"SouthAsian":["Beng","Deva","Gujr","Guru","Knda","Mlym","Orya","Saur","Sinh","Taml","Telu","Tibt","Thaa"],"Cyrillic":["Cyrl"],"CJK":["Hans","Hant","Kana","Kore","Jpan","Yiii"],"SouthEastAsian":["Batk","Bugi","Java","Khmr","Laoo","Mymr","Thai"],"Mongolian":["Mong"],"SignWriting":["Sgnw"],"NativeAmerican":["Cher","Cans"],"Special":["Zyyy"]},"rtlscripts":["Arab","Hebr","Syrc","Nkoo","Thaa"],"regiongroups":{"WW":1,"SP":1,"AM":2,"EU":3,"ME":3,"AF":3,"AS":4,"PA":4},"territories":{"AC":["en"],"AD":["ca","es","fr"],"AE":["ar","ml","ps","bal","fa"],"AF":["fa","ps","haz","uz-arab","tk-latn","prd","bal","ug-arab","kk-arab"],"AG":["en","pt"],"AI":["en"],"AL":["sq","el","mk"],"AM":["hy","az-latn","ku-latn"],"AO":["pt","umb","kmb","ln"],"AQ":["und"],"AR":["es","cy","gn"],"AS":["sm","en"],"AT":["de","hr","sl","hu"],"AU":["en","zh-hant","it"],"AW":["nl","pap","en"],"AX":["sv"],"AZ":["az-latn","az-cyrl","ku-latn"],"BA":["bs-cyrl","bs-latn","hr","sr-cyrl","sr-latn"],"BB":["en"],"BD":["bn","rkt","syl","ccp","my","grt","mni"],"BE":["nl","en","fr","wa","de"],"BF":["mos","dyu","fr"],"BG":["bg","tr"],"BH":["ar","ml"],"BI":["rn","fr","sw"],"BJ":["fr","fon","yo"],"BL":["fr"],"BM":["en"],"BN":["ms-latn","zh-hant","ms-arab","en"],"BO":["es","qu","ay","gn"],"BQ":["pap","nl"],"BR":["pt","de","it","ja","ko","kgp","gub","xav"],"BS":["en"],"BT":["dz","ne","tsj","lep"],"BV":["und"],"BW":["en","tn","af"],"BY":["be","ru"],"BZ":["en","es"],"CA":["en","fr","it","de","cr-cans","crk","yi","iu","moe","crj","atj","crl","csw","crm","ikt","dgr","den","scs","nsk","chp","gwi"],"CC":["ms-arab","en"],"CD":["sw","lua","swc","fr","ln","lu","kg","lol","rw"],"CF":["fr","sg","ln"],"CG":["fr","ln"],"CH":["de","fr","gsw","it","lmo","rm","rmo","wae"],"CI":["fr","bci","sef","daf","kfo","bqv"],"CK":["en"],"CL":["es"],"CM":["fr","en","bum","ff","ewo","ybb","bbj","nnh","bkm","bas","bax","byv","mua","maf","bfd","bss","kkj","dua","mgo","ar","jgo","ksf","agq","ha-arab","nmg","yav"],"CN":["zh-hans","ii","ug-arab","za","mn-mong","bo","ko","kk-arab","lis","ky-arab","nbf","khb","tdd","lcp","en","ru","vi","uz-cyrl"],"CO":["es"],"CP":["und"],"CR":["es"],"CU":["es"],"CV":["kea","pt"],"CW":["pap","nl","es"],"CX":["en"],"CY":["el","tr","hy","ar"],"CZ":["cs","de","pl"],"DE":["de","en","nds","tr","hr","it","ku-latn","ru","el","ksh","pl","es","nl","da","dsb"],"DG":["en"],"DJ":["aa","so","ar","fr"],"DK":["da","de","kl"],"DM":["en"],"DO":["es","en"],"DZ":["ar","fr","kab"],"EA":["es"],"EC":["es"],"EE":["et","ru"],"EG":["ar","el"],"EH":["ar"],"ER":["ti","en","tig","ar","aa","ssy","byn"],"ES":["es","en","ca","gl","eu","ast"],"ET":["en","am","om","so","ti","sid","wal","aa"],"FI":["fi","sv","ru","en","et","rmf","se","smn","sms"],"FJ":["en","hi","fj"],"FK":["en"],"FM":["chk","pon","kos","yap","en","uli"],"FO":["fo"],"FR":["fr","en","oc","it","pt","gsw","br","co","ca","nl","eu","ia"],"GA":["fr","puu"],"GB":["en","sco","pa-guru","cy","bn","zh-hant","syl","el","it","ks-arab","gd","yi","ml","ga","fr","kw"],"GD":["en"],"GE":["ka","ru","hy","ab","os","ku-latn"],"GF":["fr","gcr","zh-hant"],"GG":["en"],"GH":["ak","en","ee","abr","gaa","ha-latn","saf"],"GI":["en"],"GL":["kl","da"],"GM":["en","man-latn"],"GN":["fr","ff","man-nkoo","sus","kpe"],"GP":["fr"],"GQ":["es","fan","fr","bvb"],"GR":["el","mk","tr","bg","sq"],"GS":["und"],"GT":["es"],"GU":["en","ch"],"GW":["pt"],"GY":["en"],"HK":["zh-hant","en","zh-hans"],"HM":["und"],"HN":["es","en"],"HR":["hr","it"],"HT":["ht","fr"],"HU":["hu","de","ro","hr","sk","sl"],"IC":["es"],"ID":["id","jv","su","mad","ms-arab","min","bya","bjn","ban","bug","ace","bew","sas","bbc","zh-hant","mak","ljp","rej","gor","nij","kge","aoz","kvr","lbw","rob","mdr","sxn"],"IE":["en","ga"],"IL":["he","ar","ru","ro","yi","en","pl","hu","am","ti","ml"],"IM":["en","gv"],"IN":["hi","en","bn","te","mr","ta","ur","gu","kn","ml","or","pa-guru","bho","awa","as","bgc","mag","mwr","mai","hne","dcc","bjj","ne","sat","wtm","rkt","ks-arab","kok","swv","gbm","lmn","sd-arab","gon-telu","kfy","doi","kru","sck","tcy","wbq","xnr","wbr","khn","brx","noe","bhb","mni","raj","hoc","mtr","unr-beng","bhi","hoj","kha","kfr","grt","unx-beng","bfy","srx","saz","ccp","sd-deva","bfq","ria","bo","bft","bra","lep","btv","lif-deva","lah","sa","kht","dv","dz"],"IO":["en"],"IQ":["ar","ckb","fa","syr"],"IR":["fa","az-arab","glk","ckb","tk-latn","sdh","lrc","ar","bal","rmt","bqi","luz","lki","prd","hy","ps","ka","kk-arab"],"IS":["is","da"],"IT":["it","en","nap","scn","fur","de","fr","sl","ca","el","hr"],"JE":["en"],"JM":["en"],"JO":["ar"],"JP":["ja","ryu","ko"],"KE":["en","sw","ki","luy","luo","kam","kln","guz","mer","mas","ebu","so","dav","teo","pko","om","saq","ar","pa-guru","gu"],"KG":["ky-cyrl","ru"],"KH":["km","cja","kdt"],"KI":["en","gil"],"KM":["ar","fr","zdj"],"KN":["en"],"KP":["ko"],"KR":["ko"],"KW":["ar"],"KY":["en"],"KZ":["ru","kk-cyrl","de","ug-cyrl"],"LA":["lo","kjg","kdt"],"LB":["ar","hy","ku-arab","fr","en"],"LC":["en"],"LI":["de","gsw","wae"],"LK":["si","ta","en"],"LR":["en","kpe","vai-vaii","men","vai-latn"],"LS":["st","zu","ss","en","xh"],"LT":["lt","ru"],"LU":["fr","lb","de"],"LV":["lv","ru"],"LY":["ar"],"MA":["ar","zgh","fr","tzm-latn","shi-latn","shi-tfng","rif","es"],"MC":["fr"],"MD":["ro","uk","bg","gag","ru"],"ME":["sr-latn","sq","sr-cyrl"],"MF":["fr"],"MG":["mg","fr","en"],"MH":["en","mh"],"MK":["mk","sq","tr"],"ML":["bm","fr","ffm","snk","mwk","ses","tmh","khq","dtm","kao","ar","bmq","bze"],"MM":["my","shn","mnw","kht"],"MN":["mn-cyrl","kk-arab","zh-hans","ru","ug-cyrl"],"MO":["zh-hant","pt","zh-hans","en"],"MP":["en","ch"],"MQ":["fr"],"MR":["ar","fr","ff","wo"],"MS":["en"],"MT":["mt","en"],"MU":["mfe","en","bho","ur","fr","ta"],"MV":["dv"],"MW":["en","ny","tum","zu"],"MX":["es","yua","nhe","nhw","maz","nch"],"MY":["ms-latn","en","zh-hant","ta","bjn","jv","zmi","ml","bug"],"MZ":["pt","vmw","ndc","ts","ngl","seh","mgh","rng","ny","yao","sw","zu"],"NA":["af","kj","ng","naq","en","de","tn"],"NC":["fr"],"NE":["ha-latn","fr","dje","fuq","tmh","ar","twq"],"NF":["en"],"NG":["en","pcm","ha-latn","ig","yo","fuv","tiv","efi","ibb","ha-arab","bin","kaj","kcg","ar","cch","amo"],"NI":["es"],"NL":["nl","en","li","fy","gos","id","zea","rif","tr"],"NO":["nb","nn","se"],"NP":["ne","mai","bho","new","jml","taj","awa","thl","bap","tdg","thr","mgp","lif-deva","thq","mrd","bfy","xsr","rjs","tsf","hi","ggn","gvr","bo","tkt","tdh","bn","unr-deva","lep"],"NR":["en","na"],"NU":["en","niu"],"NZ":["en","mi"],"OM":["ar","bal","fa"],"PA":["es","en","zh-hant"],"PE":["es","qu","ay"],"PF":["fr","ty","zh-hant"],"PG":["tpi","en","ho"],"PH":["en","fil","es","ceb","ilo","hil","bik","war","bhk","pam","pag","mdh","tsg","zh-hant","bto","hnn","tbw","bku"],"PK":["ur","pa-arab","en","lah","ps","sd-arab","skr","bal","brh","hno","fa","hnd","tg-arab","gju","bft","kvx","khw","mvy","kxp","gjk","ks-arab","btv"],"PL":["pl","be","uk","csb","de","lt"],"PM":["fr","en"],"PN":["en"],"PR":["es","en"],"PS":["ar"],"PT":["pt","gl"],"PW":["pau","en"],"PY":["gn","es","de"],"QA":["ar","fa","ml"],"RE":["fr","rcf","ta"],"RO":["ro","hu","de","tr","sr-latn","bg","el","pl"],"RS":["sr-cyrl","sr-latn","sq","hu","ro","hr","sk","uk"],"RU":["ru","tt","ba","cv","hy","ce","av","udm","chm","sah","os","kbd","myv","dar","bua","mdf","kum","kv","lez","krc","inh","tyv","az-cyrl","ady","krl","koi","lbe","mrj","alt","fi","sr-latn","mn-cyrl","cu"],"RW":["rw","fr","en"],"SA":["ar"],"SB":["en"],"SC":["crs","fr","en"],"SD":["ar","en","nus","ha-arab"],"SE":["sv","fi","fit","se","rmu","yi","smj","sma","ia"],"SG":["en","zh-hans","ms-latn","ta","ml","pa-guru"],"SH":["en"],"SI":["sl","hu","it"],"SJ":["nb","ru"],"SK":["sk","hu","uk","pl","de"],"SL":["kri","en","men","tem"],"SM":["it","eo"],"SN":["fr","wo","ff","srr","dyo"],"SO":["so","ar","sw","om"],"SR":["nl","srn","zh-hant"],"SS":["ar","en"],"ST":["pt"],"SV":["es"],"SX":["en","es","vic","nl"],"SY":["ar","ku-latn","fr","hy","syr"],"SZ":["en","ss","zu","ts"],"TA":["en"],"TC":["en"],"TD":["fr","ar"],"TF":["fr"],"TG":["fr","ee"],"TH":["th","tts","nod","sou","mfa","zh-hant","kxm","kdt","mnw","shn","lcp","lwl"],"TJ":["tg-cyrl","fa","ar"],"TK":["en","tkl"],"TL":["pt","tet"],"TM":["tk-latn","ru","uz-latn","ku-latn"],"TN":["ar","fr"],"TO":["to","en"],"TR":["tr","ku-latn","zza","kbd","az-latn","ar","bgx","bg","ady","hy","ka","sr-latn","sq","ab","el","uz-latn","ky-latn","kk-cyrl"],"TT":["en","es"],"TV":["tvl","en"],"TW":["zh-hant","trv"],"TZ":["sw","en","suk","nym","kde","bez","ksb","mas","mgy","asa","lag","jmc","rof","vun","rwk","sbp"],"UA":["uk","ru","pl","yi","rue","be","ro","bg","tr","hu","el"],"UG":["sw","lg","nyn","cgg","xog","en","teo","laj","ach","myx","rw","ttj","hi"],"UM":["en"],"US":["en","es","zh-hant","fr","de","fil","it","vi","ko","ru","nv","yi","haw","chr","lkt","ik"],"UY":["es"],"UZ":["uz-latn","uz-cyrl","ru","kaa","tr"],"VA":["it","la"],"VC":["en"],"VE":["es"],"VG":["en"],"VI":["en"],"VN":["vi","zh-hant","cjm"],"VU":["bi","en","fr"],"WF":["wls","fr","fud"],"WS":["sm","en"],"XK":["sq","sr-cyrl","sr-latn"],"YE":["ar"],"YT":["swb","fr","buc","sw"],"ZA":["en","zu","xh","af","nso","tn","st","ts","ss","ve","hi","nr","sw"],"ZM":["en","bem","ny","loz"],"ZW":["en","sn","nd","mxc","ndc","kck","ny","ve","tn"],"ZZ":[]}};
} ( jQuery ) );

/**
 * Utility functions for querying language data.
 *
 * Copyright (C) 2012 Alolita Sharma, Amir Aharoni, Arun Ganesh, Brandon Harris,
 * Niklas Laxström, Pau Giner, Santhosh Thottingal, Siebrand Mazeland and other
 * contributors. See CREDITS for a list.
 *
 * UniversalLanguageSelector is dual licensed GPLv2 or later and MIT. You don't
 * have to do anything special to choose one license or the other and you don't
 * have to notify anyone which license you are using. You are free to use
 * UniversalLanguageSelector in commercial projects as long as the copyright
 * header is left intact. See files GPL-LICENSE and MIT-LICENSE for details.
 *
 * @file
 * @ingroup Extensions
 * @licence GNU General Public Licence 2.0 or later
 * @licence MIT License
 */

( function ( $ ) {
	'use strict';

	/**
	 * Is this language a redirect to another language?
	 * @param language string Language code
	 * @return Target language code if it's a redirect or false if it's not
	 */
	$.uls.data.isRedirect = function ( language ) {
		return ( $.uls.data.languages[language] !== undefined &&
			$.uls.data.languages[language].length === 1 ) ? $.uls.data.languages[language][0] : false;
	};

	/**
	 * Returns the script of the language.
	 * @param language string Language code
	 * @return string
	 */
	$.uls.data.getScript = function ( language ) {
		var target = $.uls.data.isRedirect( language );

		if ( target ) {
			return $.uls.data.getScript( target );
		}

		if ( !$.uls.data.languages[language] ) {
			// Undetermined
			return 'Zyyy';
		}

		return $.uls.data.languages[language][0];
	};

	/**
	 * Returns the regions in which a language is spoken.
	 * @param language string Language code
	 * @return array|string 'UNKNOWN'
	 */
	$.uls.data.getRegions = function ( language ) {
		var target = $.uls.data.isRedirect( language );

		if ( target ) {
			return $.uls.data.getRegions( target );
		}

		return ( $.uls.data.languages[language] && $.uls.data.languages[language][1] ) || 'UNKNOWN';
	};

	/**
	 * Returns the autonym of the language.
	 * @param language string Language code
	 * @return string
	 */
	$.uls.data.getAutonym = function ( language ) {
		var target = $.uls.data.isRedirect( language );

		if ( target ) {
			return $.uls.data.getAutonym( target );
		}

		return ( $.uls.data.languages[language] && $.uls.data.languages[language][2] ) || language;
	};

	/**
	 * Returns all language codes and corresponding autonyms
	 * @return array
	 */
	$.uls.data.getAutonyms = function () {
		var language,
			autonymsByCode = {};

		for ( language in $.uls.data.languages ) {
			if ( $.uls.data.isRedirect( language ) ) {
				continue;
			}

			autonymsByCode[language] = $.uls.data.getAutonym( language );
		}

		return autonymsByCode;
	};

	/**
	 * Returns an array of all region codes.
	 * @return array
	 */
	$.uls.data.getAllRegions = function () {
		var region,
			allRegions = [];

		for ( region in $.uls.data.regiongroups ) {
			allRegions.push( region );
		}

		return allRegions;
	};

	/**
	 * Returns all languages written in script.
	 * @param script string
	 * @return array of strings (languages codes)
	 */
	$.uls.data.getLanguagesInScript = function ( script ) {
		return $.uls.data.getLanguagesInScripts( [ script ] );
	};

	/**
	 * Returns all languages written in the given scripts.
	 * @param scripts array of strings
	 * @return array of strings (languages codes)
	 */
	$.uls.data.getLanguagesInScripts = function ( scripts ) {
		var language, i,
			languagesInScripts = [];

		for ( language in $.uls.data.languages ) {
			if ( $.uls.data.isRedirect( language ) ) {
				continue;
			}

			for ( i = 0; i < scripts.length; i++ ) {
				if ( scripts[i] === $.uls.data.getScript( language ) ) {
					languagesInScripts.push( language );
					break;
				}
			}
		}

		return languagesInScripts;
	};

	/**
	 * Returns all languages in a given region.
	 * @param region string
	 * @return array of strings (languages codes)
	 */
	$.uls.data.getLanguagesInRegion = function ( region ) {
		return $.uls.data.getLanguagesInRegions( [ region ] );
	};

	/**
	 * Returns all languages in given regions.
	 * @param regions array of strings.
	 * @return array of strings (languages codes)
	 */
	$.uls.data.getLanguagesInRegions = function ( regions ) {
		var language, i,
			languagesInRegions = [];

		for ( language in $.uls.data.languages ) {
			if ( $.uls.data.isRedirect( language ) ) {
				continue;
			}

			for ( i = 0; i < regions.length; i++ ) {
				if ( $.inArray( regions[i], $.uls.data.getRegions( language ) ) !== -1 ) {
					languagesInRegions.push( language );
					break;
				}
			}
		}

		return languagesInRegions;
	};

	/**
	 * Returns all languages in a region group.
	 * @param groupNum number.
	 * @return array of strings (languages codes)
	 */
	$.uls.data.getLanguagesInRegionGroup = function ( groupNum ) {
		return $.uls.data.getLanguagesInRegions( $.uls.data.getRegionsInGroup( groupNum ) );
	};

	/**
	 * Returns an associative array of languages in a region,
	 * grouped by script.
	 * @param region string Region code
	 * @return associative array
	 */
	$.uls.data.getLanguagesByScriptInRegion = function ( region ) {
		var language, script,
			languagesByScriptInRegion = {};

		for ( language in $.uls.data.languages ) {
			if ( $.uls.data.isRedirect( language ) ) {
				continue;
			}

			if ( $.inArray( region, $.uls.data.getRegions( language ) ) !== -1 ) {
				script = $.uls.data.getScript( language );

				if ( languagesByScriptInRegion[script] === undefined ) {
					languagesByScriptInRegion[script] = [];
				}
				languagesByScriptInRegion[script].push( language );
			}
		}

		return languagesByScriptInRegion;
	};

	/**
	 * Returns an associative array of languages in a region,
	 * grouped by script group.
	 * @param region string Region code
	 * @return associative array
	 */
	$.uls.data.getLanguagesByScriptGroupInRegion = function ( region ) {
		return $.uls.data.getLanguagesByScriptGroupInRegions( [ region ] );
	};

	/**
	 * Returns an associative array of all languages,
	 * grouped by script group.
	 * @return associative array
	 */
	$.uls.data.getAllLanguagesByScriptGroup = function () {
		return $.uls.data.getLanguagesByScriptGroupInRegions( $.uls.data.getAllRegions() );
	};

	/**
	 * Get the given list of languages grouped by script.
	 * @param languages Array of language codes
	 * @return {Object} Array of languages indexed by script codes
	 */
	$.uls.data.getLanguagesByScriptGroup = function ( languages ) {
		var languagesByScriptGroup = {},
			language, codeToAdd, langScriptGroup;

		for ( language in languages ) {
			codeToAdd = $.uls.data.isRedirect( language ) || language;

			langScriptGroup = $.uls.data.getScriptGroupOfLanguage( codeToAdd );

			if ( !languagesByScriptGroup[langScriptGroup] ) {
				languagesByScriptGroup[langScriptGroup] = [];
			}

			// Prevent duplicate adding of redirects
			if ( $.inArray( codeToAdd, languagesByScriptGroup[langScriptGroup] ) === -1 ) {
				languagesByScriptGroup[langScriptGroup].push( codeToAdd );
			}
		}

		return languagesByScriptGroup;
	};

	/**
	 * Returns an associative array of languages in several regions,
	 * grouped by script group.
	 * @param regions array of strings - region codes
	 * @return associative array
	 */
	$.uls.data.getLanguagesByScriptGroupInRegions = function ( regions ) {
		var language, i, scriptGroup,
			languagesByScriptGroupInRegions = {};

		for ( language in $.uls.data.languages ) {
			if ( $.uls.data.isRedirect( language ) ) {
				continue;
			}

			for ( i = 0; i < regions.length; i++ ) {
				if ( $.inArray( regions[i], $.uls.data.getRegions( language ) ) !== -1 ) {
					scriptGroup = $.uls.data.getScriptGroupOfLanguage( language );

					if ( languagesByScriptGroupInRegions[scriptGroup] === undefined ) {
						languagesByScriptGroupInRegions[scriptGroup] = [];
					}

					languagesByScriptGroupInRegions[scriptGroup].push( language );
					break;
				}
			}
		}

		return languagesByScriptGroupInRegions;
	};

	/**
	 * Returns an array of languages grouped by region group,
	 * region, script group and script.
	 * @return associative array
	 */
	$.uls.data.getAllLanguagesByRegionAndScript = function () {
		var region, regionGroup, language,
			script, scriptGroup, regions, regionNum,
			allLanguagesByRegionAndScript = {};

		for ( region in $.uls.data.regiongroups ) {
			regionGroup = $.uls.data.regiongroups[region];

			if ( allLanguagesByRegionAndScript[regionGroup] === undefined ) {
				allLanguagesByRegionAndScript[regionGroup] = {};
			}

			allLanguagesByRegionAndScript[regionGroup][region] = {};
		}

		for ( language in $.uls.data.languages ) {
			if ( $.uls.data.isRedirect( language ) ) {
				continue;
			}

			script = $.uls.data.getScript( language );
			scriptGroup = $.uls.data.getGroupOfScript( script );
			regions = $.uls.data.getRegions( language );

			for ( regionNum = 0; regionNum < regions.length; regionNum++ ) {
				region = regions[regionNum];
				regionGroup = $.uls.data.regiongroups[region];

				if ( allLanguagesByRegionAndScript[regionGroup][region][scriptGroup] === undefined ) {
					allLanguagesByRegionAndScript[regionGroup][region][scriptGroup] = {};
				}

				if ( allLanguagesByRegionAndScript[regionGroup][region][scriptGroup][script] === undefined ) {
					allLanguagesByRegionAndScript[regionGroup][region][scriptGroup][script] = [];
				}

				allLanguagesByRegionAndScript[regionGroup][region][scriptGroup][script].push( language );
			}
		}

		return allLanguagesByRegionAndScript;
	};

	/**
	 * Returns all regions in a region group.
	 * @param groupNum int
	 * @return array of strings
	 */
	$.uls.data.getRegionsInGroup = function ( groupNum ) {
		var region,
			regionsInGroup = [];

		for ( region in $.uls.data.regiongroups ) {
			if ( $.uls.data.regiongroups[region] === groupNum ) {
				regionsInGroup.push( region );
			}
		}

		return regionsInGroup;
	};

	/**
	 * Returns the script group of a script or 'Other' if it doesn't
	 * belong to any group.
	 * @param script string Script code
	 * @return string script group name
	 */
	$.uls.data.getGroupOfScript = function ( script ) {
		var scriptGroup;

		for ( scriptGroup in $.uls.data.scriptgroups ) {
			if ( $.inArray( script, $.uls.data.scriptgroups[scriptGroup] ) !== -1 ) {
				return scriptGroup;
			}
		}

		return 'Other';
	};

	/**
	 * Returns the script group of a language.
	 * @param language string Language code
	 * @return string script group name
	 */
	$.uls.data.getScriptGroupOfLanguage = function ( language ) {
		return $.uls.data.getGroupOfScript( $.uls.data.getScript( language ) );
	};

	/**
	 * A callback for sorting languages by autonym.
	 * Can be used as an argument to a sort function.
	 * @param a string Language code
	 * @param b string Language code
	 */
	$.uls.data.sortByAutonym = function ( a, b ) {
		var autonymA = $.uls.data.getAutonym( a ) || a,
			autonymB = $.uls.data.getAutonym( b ) || b;

		return ( autonymA.toLowerCase() < autonymB.toLowerCase() ) ? -1 : 1;
	};

	/**
	 * Check if a language is right-to-left.
	 * @param language string Language code
	 * @return boolean
	 */
	$.uls.data.isRtl = function ( language ) {
		return $.inArray( $.uls.data.getScript( language ), $.uls.data.rtlscripts ) !== -1;
	};

	/**
	 * Return the direction of the language
	 * @param language string Language code
	 * @return string
	 */
	$.uls.data.getDir = function ( language ) {
		return $.uls.data.isRtl( language ) ? 'rtl' : 'ltr';
	};

	/**
	 * Returns the languages spoken in a territory.
	 * @param territory string Territory code
	 * @return list of language codes
	 */
	$.uls.data.getLanguagesInTerritory = function ( territory ) {
		return $.uls.data.territories[territory];
	};

	/**
	 * Adds a language in run time and sets its options as provided.
	 * If the target option is provided, the language is defined as a redirect.
	 * Other possible options are script, regions and autonym.
	 *
	 * @param code string New language code.
	 * @param options Object Language properties.
	 * @return list of language codes
	 */
	$.uls.data.addLanguage = function( code, options ) {
		if ( options.target ) {
			$.uls.data.languages[code] = [options.target];
		} else {
			$.uls.data.languages[code] = [options.script, options.regions, options.autonym];
		}
	};

	/**
	 * Removes a language from the langdb in run time.
	 *
	 * @param code string Language code to delete.
	 * @return true if the language was removed, false otherwise.
	 */
	$.uls.data.deleteLanguage = function( code ) {
		if ( $.uls.data.languages[code] ) {
			delete $.uls.data.languages[code];

			return true;
		}

		return false;
	};
} ( jQuery ) );

/*!
 * OOjs v1.1.5 optimised for jQuery
 * https://www.mediawiki.org/wiki/OOjs
 *
 * Copyright 2011-2015 OOjs Team and other contributors.
 * Released under the MIT license
 * http://oojs.mit-license.org
 *
 * Date: 2015-02-26T01:51:06Z
 */
( function ( global ) {

'use strict';

/*exported toString */
var
	/**
	 * Namespace for all classes, static methods and static properties.
	 * @class OO
	 * @singleton
	 */
	oo = {},
	// Optimisation: Local reference to Object.prototype.hasOwnProperty
	hasOwn = oo.hasOwnProperty,
	toString = oo.toString;

/* Class Methods */

/**
 * Utility to initialize a class for OO inheritance.
 *
 * Currently this just initializes an empty static object.
 *
 * @param {Function} fn
 */
oo.initClass = function ( fn ) {
	fn.static = fn.static || {};
};

/**
 * Inherit from prototype to another using Object#create.
 *
 * Beware: This redefines the prototype, call before setting your prototypes.
 *
 * Beware: This redefines the prototype, can only be called once on a function.
 * If called multiple times on the same function, the previous prototype is lost.
 * This is how prototypal inheritance works, it can only be one straight chain
 * (just like classical inheritance in PHP for example). If you need to work with
 * multiple constructors consider storing an instance of the other constructor in a
 * property instead, or perhaps use a mixin (see OO.mixinClass).
 *
 *     function Thing() {}
 *     Thing.prototype.exists = function () {};
 *
 *     function Person() {
 *         Person.super.apply( this, arguments );
 *     }
 *     OO.inheritClass( Person, Thing );
 *     Person.static.defaultEyeCount = 2;
 *     Person.prototype.walk = function () {};
 *
 *     function Jumper() {
 *         Jumper.super.apply( this, arguments );
 *     }
 *     OO.inheritClass( Jumper, Person );
 *     Jumper.prototype.jump = function () {};
 *
 *     Jumper.static.defaultEyeCount === 2;
 *     var x = new Jumper();
 *     x.jump();
 *     x.walk();
 *     x instanceof Thing && x instanceof Person && x instanceof Jumper;
 *
 * @param {Function} targetFn
 * @param {Function} originFn
 * @throws {Error} If target already inherits from origin
 */
oo.inheritClass = function ( targetFn, originFn ) {
	if ( targetFn.prototype instanceof originFn ) {
		throw new Error( 'Target already inherits from origin' );
	}

	var targetConstructor = targetFn.prototype.constructor;

	// Using ['super'] instead of .super because 'super' is not supported
	// by IE 8 and below (bug 63303).
	// Provide .parent as alias for code supporting older browsers which
	// allows people to comply with their style guide.
	targetFn['super'] = targetFn.parent = originFn;

	targetFn.prototype = Object.create( originFn.prototype, {
		// Restore constructor property of targetFn
		constructor: {
			value: targetConstructor,
			enumerable: false,
			writable: true,
			configurable: true
		}
	} );

	// Extend static properties - always initialize both sides
	oo.initClass( originFn );
	targetFn.static = Object.create( originFn.static );
};

/**
 * Copy over *own* prototype properties of a mixin.
 *
 * The 'constructor' (whether implicit or explicit) is not copied over.
 *
 * This does not create inheritance to the origin. If inheritance is needed
 * use oo.inheritClass instead.
 *
 * Beware: This can redefine a prototype property, call before setting your prototypes.
 *
 * Beware: Don't call before oo.inheritClass.
 *
 *     function Foo() {}
 *     function Context() {}
 *
 *     // Avoid repeating this code
 *     function ContextLazyLoad() {}
 *     ContextLazyLoad.prototype.getContext = function () {
 *         if ( !this.context ) {
 *             this.context = new Context();
 *         }
 *         return this.context;
 *     };
 *
 *     function FooBar() {}
 *     OO.inheritClass( FooBar, Foo );
 *     OO.mixinClass( FooBar, ContextLazyLoad );
 *
 * @param {Function} targetFn
 * @param {Function} originFn
 */
oo.mixinClass = function ( targetFn, originFn ) {
	var key;

	// Copy prototype properties
	for ( key in originFn.prototype ) {
		if ( key !== 'constructor' && hasOwn.call( originFn.prototype, key ) ) {
			targetFn.prototype[key] = originFn.prototype[key];
		}
	}

	// Copy static properties - always initialize both sides
	oo.initClass( targetFn );
	if ( originFn.static ) {
		for ( key in originFn.static ) {
			if ( hasOwn.call( originFn.static, key ) ) {
				targetFn.static[key] = originFn.static[key];
			}
		}
	} else {
		oo.initClass( originFn );
	}
};

/* Object Methods */

/**
 * Get a deeply nested property of an object using variadic arguments, protecting against
 * undefined property errors.
 *
 * `quux = oo.getProp( obj, 'foo', 'bar', 'baz' );` is equivalent to `quux = obj.foo.bar.baz;`
 * except that the former protects against JS errors if one of the intermediate properties
 * is undefined. Instead of throwing an error, this function will return undefined in
 * that case.
 *
 * @param {Object} obj
 * @param {Mixed...} [keys]
 * @return obj[arguments[1]][arguments[2]].... or undefined
 */
oo.getProp = function ( obj ) {
	var i,
		retval = obj;
	for ( i = 1; i < arguments.length; i++ ) {
		if ( retval === undefined || retval === null ) {
			// Trying to access a property of undefined or null causes an error
			return undefined;
		}
		retval = retval[arguments[i]];
	}
	return retval;
};

/**
 * Set a deeply nested property of an object using variadic arguments, protecting against
 * undefined property errors.
 *
 * `oo.setProp( obj, 'foo', 'bar', 'baz' );` is equivalent to `obj.foo.bar = baz;` except that
 * the former protects against JS errors if one of the intermediate properties is
 * undefined. Instead of throwing an error, undefined intermediate properties will be
 * initialized to an empty object. If an intermediate property is not an object, or if obj itself
 * is not an object, this function will silently abort.
 *
 * @param {Object} obj
 * @param {Mixed...} [keys]
 * @param {Mixed} [value]
 */
oo.setProp = function ( obj ) {
	var i,
		prop = obj;
	if ( Object( obj ) !== obj ) {
		return;
	}
	for ( i = 1; i < arguments.length - 2; i++ ) {
		if ( prop[arguments[i]] === undefined ) {
			prop[arguments[i]] = {};
		}
		if ( Object( prop[arguments[i]] ) !== prop[arguments[i]] ) {
			return;
		}
		prop = prop[arguments[i]];
	}
	prop[arguments[arguments.length - 2]] = arguments[arguments.length - 1];
};

/**
 * Create a new object that is an instance of the same
 * constructor as the input, inherits from the same object
 * and contains the same own properties.
 *
 * This makes a shallow non-recursive copy of own properties.
 * To create a recursive copy of plain objects, use #copy.
 *
 *     var foo = new Person( mom, dad );
 *     foo.setAge( 21 );
 *     var foo2 = OO.cloneObject( foo );
 *     foo.setAge( 22 );
 *
 *     // Then
 *     foo2 !== foo; // true
 *     foo2 instanceof Person; // true
 *     foo2.getAge(); // 21
 *     foo.getAge(); // 22
 *
 * @param {Object} origin
 * @return {Object} Clone of origin
 */
oo.cloneObject = function ( origin ) {
	var key, r;

	r = Object.create( origin.constructor.prototype );

	for ( key in origin ) {
		if ( hasOwn.call( origin, key ) ) {
			r[key] = origin[key];
		}
	}

	return r;
};

/**
 * Get an array of all property values in an object.
 *
 * @param {Object} Object to get values from
 * @return {Array} List of object values
 */
oo.getObjectValues = function ( obj ) {
	var key, values;

	if ( obj !== Object( obj ) ) {
		throw new TypeError( 'Called on non-object' );
	}

	values = [];
	for ( key in obj ) {
		if ( hasOwn.call( obj, key ) ) {
			values[values.length] = obj[key];
		}
	}

	return values;
};

/**
 * Recursively compare properties between two objects.
 *
 * A false result may be caused by property inequality or by properties in one object missing from
 * the other. An asymmetrical test may also be performed, which checks only that properties in the
 * first object are present in the second object, but not the inverse.
 *
 * If either a or b is null or undefined it will be treated as an empty object.
 *
 * @param {Object|undefined|null} a First object to compare
 * @param {Object|undefined|null} b Second object to compare
 * @param {boolean} [asymmetrical] Whether to check only that a's values are equal to b's
 *  (i.e. a is a subset of b)
 * @return {boolean} If the objects contain the same values as each other
 */
oo.compare = function ( a, b, asymmetrical ) {
	var aValue, bValue, aType, bType, k;

	if ( a === b ) {
		return true;
	}

	a = a || {};
	b = b || {};

	if ( typeof a.nodeType === 'number' && typeof a.isEqualNode === 'function' ) {
		return a.isEqualNode( b );
	}

	for ( k in a ) {
		if ( !hasOwn.call( a, k ) || a[k] === undefined || a[k] === b[k] ) {
			// Support es3-shim: Without the hasOwn filter, comparing [] to {} will be false in ES3
			// because the shimmed "forEach" is enumerable and shows up in Array but not Object.
			// Also ignore undefined values, because there is no conceptual difference between
			// a key that is absent and a key that is present but whose value is undefined.
			continue;
		}

		aValue = a[k];
		bValue = b[k];
		aType = typeof aValue;
		bType = typeof bValue;
		if ( aType !== bType ||
			(
				( aType === 'string' || aType === 'number' || aType === 'boolean' ) &&
				aValue !== bValue
			) ||
			( aValue === Object( aValue ) && !oo.compare( aValue, bValue, true ) ) ) {
			return false;
		}
	}
	// If the check is not asymmetrical, recursing with the arguments swapped will verify our result
	return asymmetrical ? true : oo.compare( b, a, true );
};

/**
 * Create a plain deep copy of any kind of object.
 *
 * Copies are deep, and will either be an object or an array depending on `source`.
 *
 * @param {Object} source Object to copy
 * @param {Function} [leafCallback] Applied to leaf values after they are cloned but before they are added to the clone
 * @param {Function} [nodeCallback] Applied to all values before they are cloned.  If the nodeCallback returns a value other than undefined, the returned value is used instead of attempting to clone.
 * @return {Object} Copy of source object
 */
oo.copy = function ( source, leafCallback, nodeCallback ) {
	var key, destination;

	if ( nodeCallback ) {
		// Extensibility: check before attempting to clone source.
		destination = nodeCallback( source );
		if ( destination !== undefined ) {
			return destination;
		}
	}

	if ( Array.isArray( source ) ) {
		// Array (fall through)
		destination = new Array( source.length );
	} else if ( source && typeof source.clone === 'function' ) {
		// Duck type object with custom clone method
		return leafCallback ? leafCallback( source.clone() ) : source.clone();
	} else if ( source && typeof source.cloneNode === 'function' ) {
		// DOM Node
		return leafCallback ?
			leafCallback( source.cloneNode( true ) ) :
			source.cloneNode( true );
	} else if ( oo.isPlainObject( source ) ) {
		// Plain objects (fall through)
		destination = {};
	} else {
		// Non-plain objects (incl. functions) and primitive values
		return leafCallback ? leafCallback( source ) : source;
	}

	// source is an array or a plain object
	for ( key in source ) {
		destination[key] = oo.copy( source[key], leafCallback, nodeCallback );
	}

	// This is an internal node, so we don't apply the leafCallback.
	return destination;
};

/**
 * Generate a hash of an object based on its name and data.
 *
 * Performance optimization: <http://jsperf.com/ve-gethash-201208#/toJson_fnReplacerIfAoForElse>
 *
 * To avoid two objects with the same values generating different hashes, we utilize the replacer
 * argument of JSON.stringify and sort the object by key as it's being serialized. This may or may
 * not be the fastest way to do this; we should investigate this further.
 *
 * Objects and arrays are hashed recursively. When hashing an object that has a .getHash()
 * function, we call that function and use its return value rather than hashing the object
 * ourselves. This allows classes to define custom hashing.
 *
 * @param {Object} val Object to generate hash for
 * @return {string} Hash of object
 */
oo.getHash = function ( val ) {
	return JSON.stringify( val, oo.getHash.keySortReplacer );
};

/**
 * Sort objects by key (helper function for OO.getHash).
 *
 * This is a callback passed into JSON.stringify.
 *
 * @method getHash_keySortReplacer
 * @param {string} key Property name of value being replaced
 * @param {Mixed} val Property value to replace
 * @return {Mixed} Replacement value
 */
oo.getHash.keySortReplacer = function ( key, val ) {
	var normalized, keys, i, len;
	if ( val && typeof val.getHashObject === 'function' ) {
		// This object has its own custom hash function, use it
		val = val.getHashObject();
	}
	if ( !Array.isArray( val ) && Object( val ) === val ) {
		// Only normalize objects when the key-order is ambiguous
		// (e.g. any object not an array).
		normalized = {};
		keys = Object.keys( val ).sort();
		i = 0;
		len = keys.length;
		for ( ; i < len; i += 1 ) {
			normalized[keys[i]] = val[keys[i]];
		}
		return normalized;

	// Primitive values and arrays get stable hashes
	// by default. Lets those be stringified as-is.
	} else {
		return val;
	}
};

/**
 * Compute the union (duplicate-free merge) of a set of arrays.
 *
 * Arrays values must be convertable to object keys (strings).
 *
 * By building an object (with the values for keys) in parallel with
 * the array, a new item's existence in the union can be computed faster.
 *
 * @param {Array...} arrays Arrays to union
 * @return {Array} Union of the arrays
 */
oo.simpleArrayUnion = function () {
	var i, ilen, arr, j, jlen,
		obj = {},
		result = [];

	for ( i = 0, ilen = arguments.length; i < ilen; i++ ) {
		arr = arguments[i];
		for ( j = 0, jlen = arr.length; j < jlen; j++ ) {
			if ( !obj[ arr[j] ] ) {
				obj[ arr[j] ] = true;
				result.push( arr[j] );
			}
		}
	}

	return result;
};

/**
 * Combine arrays (intersection or difference).
 *
 * An intersection checks the item exists in 'b' while difference checks it doesn't.
 *
 * Arrays values must be convertable to object keys (strings).
 *
 * By building an object (with the values for keys) of 'b' we can
 * compute the result faster.
 *
 * @private
 * @param {Array} a First array
 * @param {Array} b Second array
 * @param {boolean} includeB Whether to items in 'b'
 * @return {Array} Combination (intersection or difference) of arrays
 */
function simpleArrayCombine( a, b, includeB ) {
	var i, ilen, isInB,
		bObj = {},
		result = [];

	for ( i = 0, ilen = b.length; i < ilen; i++ ) {
		bObj[ b[i] ] = true;
	}

	for ( i = 0, ilen = a.length; i < ilen; i++ ) {
		isInB = !!bObj[ a[i] ];
		if ( isInB === includeB ) {
			result.push( a[i] );
		}
	}

	return result;
}

/**
 * Compute the intersection of two arrays (items in both arrays).
 *
 * Arrays values must be convertable to object keys (strings).
 *
 * @param {Array} a First array
 * @param {Array} b Second array
 * @return {Array} Intersection of arrays
 */
oo.simpleArrayIntersection = function ( a, b ) {
	return simpleArrayCombine( a, b, true );
};

/**
 * Compute the difference of two arrays (items in 'a' but not 'b').
 *
 * Arrays values must be convertable to object keys (strings).
 *
 * @param {Array} a First array
 * @param {Array} b Second array
 * @return {Array} Intersection of arrays
 */
oo.simpleArrayDifference = function ( a, b ) {
	return simpleArrayCombine( a, b, false );
};

/*global $ */

oo.isPlainObject = $.isPlainObject;

/*global hasOwn */

( function () {

	/**
	 * @class OO.EventEmitter
	 *
	 * @constructor
	 */
	oo.EventEmitter = function OoEventEmitter() {
		// Properties

		/**
		 * Storage of bound event handlers by event name.
		 *
		 * @property
		 */
		this.bindings = {};
	};

	oo.initClass( oo.EventEmitter );

	/* Private helper functions */

	/**
	 * Validate a function or method call in a context
	 *
	 * For a method name, check that it names a function in the context object
	 *
	 * @private
	 * @param {Function|string} method Function or method name
	 * @param {Mixed} context The context of the call
	 * @throws {Error} A method name is given but there is no context
	 * @throws {Error} In the context object, no property exists with the given name
	 * @throws {Error} In the context object, the named property is not a function
	 */
	function validateMethod( method, context ) {
		// Validate method and context
		if ( typeof method === 'string' ) {
			// Validate method
			if ( context === undefined || context === null ) {
				throw new Error( 'Method name "' + method + '" has no context.' );
			}
			if ( typeof context[method] !== 'function' ) {
				// Technically the property could be replaced by a function before
				// call time. But this probably signals a typo.
				throw new Error( 'Property "' + method + '" is not a function' );
			}
		} else if ( typeof method !== 'function' ) {
			throw new Error( 'Invalid callback. Function or method name expected.' );
		}
	}

	/* Methods */

	/**
	 * Add a listener to events of a specific event.
	 *
	 * The listener can be a function or the string name of a method; if the latter, then the
	 * name lookup happens at the time the listener is called.
	 *
	 * @param {string} event Type of event to listen to
	 * @param {Function|string} method Function or method name to call when event occurs
	 * @param {Array} [args] Arguments to pass to listener, will be prepended to emitted arguments
	 * @param {Object} [context=null] Context object for function or method call
	 * @throws {Error} Listener argument is not a function or a valid method name
	 * @chainable
	 */
	oo.EventEmitter.prototype.on = function ( event, method, args, context ) {
		var bindings;

		validateMethod( method, context );

		if ( hasOwn.call( this.bindings, event ) ) {
			bindings = this.bindings[event];
		} else {
			// Auto-initialize bindings list
			bindings = this.bindings[event] = [];
		}
		// Add binding
		bindings.push( {
			method: method,
			args: args,
			context: ( arguments.length < 4 ) ? null : context
		} );
		return this;
	};

	/**
	 * Add a one-time listener to a specific event.
	 *
	 * @param {string} event Type of event to listen to
	 * @param {Function} listener Listener to call when event occurs
	 * @chainable
	 */
	oo.EventEmitter.prototype.once = function ( event, listener ) {
		var eventEmitter = this,
			wrapper = function () {
				eventEmitter.off( event, wrapper );
				return listener.apply( this, arguments );
			};
		return this.on( event, wrapper );
	};

	/**
	 * Remove a specific listener from a specific event.
	 *
	 * @param {string} event Type of event to remove listener from
	 * @param {Function|string} [method] Listener to remove. Must be in the same form as was passed
	 * to "on". Omit to remove all listeners.
	 * @param {Object} [context=null] Context object function or method call
	 * @chainable
	 * @throws {Error} Listener argument is not a function or a valid method name
	 */
	oo.EventEmitter.prototype.off = function ( event, method, context ) {
		var i, bindings;

		if ( arguments.length === 1 ) {
			// Remove all bindings for event
			delete this.bindings[event];
			return this;
		}

		validateMethod( method, context );

		if ( !hasOwn.call( this.bindings, event ) || !this.bindings[event].length ) {
			// No matching bindings
			return this;
		}

		// Default to null context
		if ( arguments.length < 3 ) {
			context = null;
		}

		// Remove matching handlers
		bindings = this.bindings[event];
		i = bindings.length;
		while ( i-- ) {
			if ( bindings[i].method === method && bindings[i].context === context ) {
				bindings.splice( i, 1 );
			}
		}

		// Cleanup if now empty
		if ( bindings.length === 0 ) {
			delete this.bindings[event];
		}
		return this;
	};

	/**
	 * Emit an event.
	 *
	 * TODO: Should this be chainable? What is the usefulness of the boolean
	 * return value here?
	 *
	 * @param {string} event Type of event
	 * @param {Mixed} args First in a list of variadic arguments passed to event handler (optional)
	 * @return {boolean} If event was handled by at least one listener
	 */
	oo.EventEmitter.prototype.emit = function ( event ) {
		var args = [],
			i, len, binding, bindings, method;

		if ( hasOwn.call( this.bindings, event ) ) {
			// Slicing ensures that we don't get tripped up by event handlers that add/remove bindings
			bindings = this.bindings[event].slice();
			for ( i = 1, len = arguments.length; i < len; i++ ) {
				args.push( arguments[i] );
			}
			for ( i = 0, len = bindings.length; i < len; i++ ) {
				binding = bindings[i];
				if ( typeof binding.method === 'string' ) {
					// Lookup method by name (late binding)
					method = binding.context[ binding.method ];
				} else {
					method = binding.method;
				}
				method.apply(
					binding.context,
					binding.args ? binding.args.concat( args ) : args
				);
			}
			return true;
		}
		return false;
	};

	/**
	 * Connect event handlers to an object.
	 *
	 * @param {Object} context Object to call methods on when events occur
	 * @param {Object.<string,string>|Object.<string,Function>|Object.<string,Array>} methods List of
	 *  event bindings keyed by event name containing either method names, functions or arrays containing
	 *  method name or function followed by a list of arguments to be passed to callback before emitted
	 *  arguments
	 * @chainable
	 */
	oo.EventEmitter.prototype.connect = function ( context, methods ) {
		var method, args, event;

		for ( event in methods ) {
			method = methods[event];
			// Allow providing additional args
			if ( Array.isArray( method ) ) {
				args = method.slice( 1 );
				method = method[0];
			} else {
				args = [];
			}
			// Add binding
			this.on( event, method, args, context );
		}
		return this;
	};

	/**
	 * Disconnect event handlers from an object.
	 *
	 * @param {Object} context Object to disconnect methods from
	 * @param {Object.<string,string>|Object.<string,Function>|Object.<string,Array>} [methods] List of
	 * event bindings keyed by event name. Values can be either method names or functions, but must be
	 * consistent with those used in the corresponding call to "connect".
	 * @chainable
	 */
	oo.EventEmitter.prototype.disconnect = function ( context, methods ) {
		var i, event, bindings;

		if ( methods ) {
			// Remove specific connections to the context
			for ( event in methods ) {
				this.off( event, methods[event], context );
			}
		} else {
			// Remove all connections to the context
			for ( event in this.bindings ) {
				bindings = this.bindings[event];
				i = bindings.length;
				while ( i-- ) {
					// bindings[i] may have been removed by the previous step's
					// this.off so check it still exists
					if ( bindings[i] && bindings[i].context === context ) {
						this.off( event, bindings[i].method, context );
					}
				}
			}
		}

		return this;
	};

}() );

/*global hasOwn */

/**
 * @class OO.Registry
 * @mixins OO.EventEmitter
 *
 * @constructor
 */
oo.Registry = function OoRegistry() {
	// Mixin constructors
	oo.EventEmitter.call( this );

	// Properties
	this.registry = {};
};

/* Inheritance */

oo.mixinClass( oo.Registry, oo.EventEmitter );

/* Events */

/**
 * @event register
 * @param {string} name
 * @param {Mixed} data
 */

/* Methods */

/**
 * Associate one or more symbolic names with some data.
 *
 * Only the base name will be registered, overriding any existing entry with the same base name.
 *
 * @param {string|string[]} name Symbolic name or list of symbolic names
 * @param {Mixed} data Data to associate with symbolic name
 * @fires register
 * @throws {Error} Name argument must be a string or array
 */
oo.Registry.prototype.register = function ( name, data ) {
	var i, len;
	if ( typeof name === 'string' ) {
		this.registry[name] = data;
		this.emit( 'register', name, data );
	} else if ( Array.isArray( name ) ) {
		for ( i = 0, len = name.length; i < len; i++ ) {
			this.register( name[i], data );
		}
	} else {
		throw new Error( 'Name must be a string or array, cannot be a ' + typeof name );
	}
};

/**
 * Get data for a given symbolic name.
 *
 * Lookups are done using the base name.
 *
 * @param {string} name Symbolic name
 * @return {Mixed|undefined} Data associated with symbolic name
 */
oo.Registry.prototype.lookup = function ( name ) {
	if ( hasOwn.call( this.registry, name ) ) {
		return this.registry[name];
	}
};

/**
 * @class OO.Factory
 * @extends OO.Registry
 *
 * @constructor
 */
oo.Factory = function OoFactory() {
	oo.Factory.parent.call( this );

	// Properties
	this.entries = [];
};

/* Inheritance */

oo.inheritClass( oo.Factory, oo.Registry );

/* Methods */

/**
 * Register a constructor with the factory.
 *
 * Classes must have a static `name` property to be registered.
 *
 *     function MyClass() {};
 *     OO.initClass( MyClass );
 *     // Adds a static property to the class defining a symbolic name
 *     MyClass.static.name = 'mine';
 *     // Registers class with factory, available via symbolic name 'mine'
 *     factory.register( MyClass );
 *
 * @param {Function} constructor Constructor to use when creating object
 * @throws {Error} Name must be a string and must not be empty
 * @throws {Error} Constructor must be a function
 */
oo.Factory.prototype.register = function ( constructor ) {
	var name;

	if ( typeof constructor !== 'function' ) {
		throw new Error( 'constructor must be a function, cannot be a ' + typeof constructor );
	}
	name = constructor.static && constructor.static.name;
	if ( typeof name !== 'string' || name === '' ) {
		throw new Error( 'Name must be a string and must not be empty' );
	}
	this.entries.push( name );

	oo.Factory.parent.prototype.register.call( this, name, constructor );
};

/**
 * Create an object based on a name.
 *
 * Name is used to look up the constructor to use, while all additional arguments are passed to the
 * constructor directly, so leaving one out will pass an undefined to the constructor.
 *
 * @param {string} name Object name
 * @param {Mixed...} [args] Arguments to pass to the constructor
 * @return {Object} The new object
 * @throws {Error} Unknown object name
 */
oo.Factory.prototype.create = function ( name ) {
	var obj, i,
		args = [],
		constructor = this.lookup( name );

	if ( !constructor ) {
		throw new Error( 'No class registered by that name: ' + name );
	}

	// Convert arguments to array and shift the first argument (name) off
	for ( i = 1; i < arguments.length; i++ ) {
		args.push( arguments[i] );
	}

	// We can't use the "new" operator with .apply directly because apply needs a
	// context. So instead just do what "new" does: create an object that inherits from
	// the constructor's prototype (which also makes it an "instanceof" the constructor),
	// then invoke the constructor with the object as context, and return it (ignoring
	// the constructor's return value).
	obj = Object.create( constructor.prototype );
	constructor.apply( obj, args );
	return obj;
};

/*jshint node:true */
if ( typeof module !== 'undefined' && module.exports ) {
	module.exports = oo;
} else {
	global.OO = oo;
}

}( this ) );

/*!
 * OOjs UI v0.9.0
 * https://www.mediawiki.org/wiki/OOjs_UI
 *
 * Copyright 2011–2015 OOjs Team and other contributors.
 * Released under the MIT license
 * http://oojs.mit-license.org
 *
 * Date: 2015-03-04T23:55:34Z
 */
( function ( OO ) {

'use strict';

/**
 * Namespace for all classes, static methods and static properties.
 *
 * @class
 * @singleton
 */
OO.ui = {};

OO.ui.bind = $.proxy;

/**
 * @property {Object}
 */
OO.ui.Keys = {
	UNDEFINED: 0,
	BACKSPACE: 8,
	DELETE: 46,
	LEFT: 37,
	RIGHT: 39,
	UP: 38,
	DOWN: 40,
	ENTER: 13,
	END: 35,
	HOME: 36,
	TAB: 9,
	PAGEUP: 33,
	PAGEDOWN: 34,
	ESCAPE: 27,
	SHIFT: 16,
	SPACE: 32
};

/**
 * Get the user's language and any fallback languages.
 *
 * These language codes are used to localize user interface elements in the user's language.
 *
 * In environments that provide a localization system, this function should be overridden to
 * return the user's language(s). The default implementation returns English (en) only.
 *
 * @return {string[]} Language codes, in descending order of priority
 */
OO.ui.getUserLanguages = function () {
	return [ 'en' ];
};

/**
 * Get a value in an object keyed by language code.
 *
 * @param {Object.<string,Mixed>} obj Object keyed by language code
 * @param {string|null} [lang] Language code, if omitted or null defaults to any user language
 * @param {string} [fallback] Fallback code, used if no matching language can be found
 * @return {Mixed} Local value
 */
OO.ui.getLocalValue = function ( obj, lang, fallback ) {
	var i, len, langs;

	// Requested language
	if ( obj[ lang ] ) {
		return obj[ lang ];
	}
	// Known user language
	langs = OO.ui.getUserLanguages();
	for ( i = 0, len = langs.length; i < len; i++ ) {
		lang = langs[ i ];
		if ( obj[ lang ] ) {
			return obj[ lang ];
		}
	}
	// Fallback language
	if ( obj[ fallback ] ) {
		return obj[ fallback ];
	}
	// First existing language
	for ( lang in obj ) {
		return obj[ lang ];
	}

	return undefined;
};

/**
 * Check if a node is contained within another node
 *
 * Similar to jQuery#contains except a list of containers can be supplied
 * and a boolean argument allows you to include the container in the match list
 *
 * @param {HTMLElement|HTMLElement[]} containers Container node(s) to search in
 * @param {HTMLElement} contained Node to find
 * @param {boolean} [matchContainers] Include the container(s) in the list of nodes to match, otherwise only match descendants
 * @return {boolean} The node is in the list of target nodes
 */
OO.ui.contains = function ( containers, contained, matchContainers ) {
	var i;
	if ( !Array.isArray( containers ) ) {
		containers = [ containers ];
	}
	for ( i = containers.length - 1; i >= 0; i-- ) {
		if ( ( matchContainers && contained === containers[ i ] ) || $.contains( containers[ i ], contained ) ) {
			return true;
		}
	}
	return false;
};

/**
 * Reconstitute a JavaScript object corresponding to a widget created by
 * the PHP implementation.
 *
 * This is an alias for `OO.ui.Element.static.infuse()`.
 *
 * @param {string|HTMLElement|jQuery} idOrNode
 *   A DOM id (if a string) or node for the widget to infuse.
 * @return {OO.ui.Element}
 *   The `OO.ui.Element` corresponding to this (infusable) document node.
 */
OO.ui.infuse = function ( idOrNode ) {
	return OO.ui.Element.static.infuse( idOrNode );
};

( function () {
	/**
	 * Message store for the default implementation of OO.ui.msg
	 *
	 * Environments that provide a localization system should not use this, but should override
	 * OO.ui.msg altogether.
	 *
	 * @private
	 */
	var messages = {
		// Tool tip for a button that moves items in a list down one place
		'ooui-outline-control-move-down': 'Move item down',
		// Tool tip for a button that moves items in a list up one place
		'ooui-outline-control-move-up': 'Move item up',
		// Tool tip for a button that removes items from a list
		'ooui-outline-control-remove': 'Remove item',
		// Label for the toolbar group that contains a list of all other available tools
		'ooui-toolbar-more': 'More',
		// Label for the fake tool that expands the full list of tools in a toolbar group
		'ooui-toolgroup-expand': 'More',
		// Label for the fake tool that collapses the full list of tools in a toolbar group
		'ooui-toolgroup-collapse': 'Fewer',
		// Default label for the accept button of a confirmation dialog
		'ooui-dialog-message-accept': 'OK',
		// Default label for the reject button of a confirmation dialog
		'ooui-dialog-message-reject': 'Cancel',
		// Title for process dialog error description
		'ooui-dialog-process-error': 'Something went wrong',
		// Label for process dialog dismiss error button, visible when describing errors
		'ooui-dialog-process-dismiss': 'Dismiss',
		// Label for process dialog retry action button, visible when describing only recoverable errors
		'ooui-dialog-process-retry': 'Try again',
		// Label for process dialog retry action button, visible when describing only warnings
		'ooui-dialog-process-continue': 'Continue'
	};

	/**
	 * Get a localized message.
	 *
	 * In environments that provide a localization system, this function should be overridden to
	 * return the message translated in the user's language. The default implementation always returns
	 * English messages.
	 *
	 * After the message key, message parameters may optionally be passed. In the default implementation,
	 * any occurrences of $1 are replaced with the first parameter, $2 with the second parameter, etc.
	 * Alternative implementations of OO.ui.msg may use any substitution system they like, as long as
	 * they support unnamed, ordered message parameters.
	 *
	 * @abstract
	 * @param {string} key Message key
	 * @param {Mixed...} [params] Message parameters
	 * @return {string} Translated message with parameters substituted
	 */
	OO.ui.msg = function ( key ) {
		var message = messages[ key ],
			params = Array.prototype.slice.call( arguments, 1 );
		if ( typeof message === 'string' ) {
			// Perform $1 substitution
			message = message.replace( /\$(\d+)/g, function ( unused, n ) {
				var i = parseInt( n, 10 );
				return params[ i - 1 ] !== undefined ? params[ i - 1 ] : '$' + n;
			} );
		} else {
			// Return placeholder if message not found
			message = '[' + key + ']';
		}
		return message;
	};

	/**
	 * Package a message and arguments for deferred resolution.
	 *
	 * Use this when you are statically specifying a message and the message may not yet be present.
	 *
	 * @param {string} key Message key
	 * @param {Mixed...} [params] Message parameters
	 * @return {Function} Function that returns the resolved message when executed
	 */
	OO.ui.deferMsg = function () {
		var args = arguments;
		return function () {
			return OO.ui.msg.apply( OO.ui, args );
		};
	};

	/**
	 * Resolve a message.
	 *
	 * If the message is a function it will be executed, otherwise it will pass through directly.
	 *
	 * @param {Function|string} msg Deferred message, or message text
	 * @return {string} Resolved message
	 */
	OO.ui.resolveMsg = function ( msg ) {
		if ( $.isFunction( msg ) ) {
			return msg();
		}
		return msg;
	};

} )();

/**
 * Element that can be marked as pending.
 *
 * @abstract
 * @class
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {jQuery} [$pending] Element to mark as pending, defaults to this.$element
 */
OO.ui.PendingElement = function OoUiPendingElement( config ) {
	// Configuration initialization
	config = config || {};

	// Properties
	this.pending = 0;
	this.$pending = null;

	// Initialisation
	this.setPendingElement( config.$pending || this.$element );
};

/* Setup */

OO.initClass( OO.ui.PendingElement );

/* Methods */

/**
 * Set the pending element (and clean up any existing one).
 *
 * @param {jQuery} $pending The element to set to pending.
 */
OO.ui.PendingElement.prototype.setPendingElement = function ( $pending ) {
	if ( this.$pending ) {
		this.$pending.removeClass( 'oo-ui-pendingElement-pending' );
	}

	this.$pending = $pending;
	if ( this.pending > 0 ) {
		this.$pending.addClass( 'oo-ui-pendingElement-pending' );
	}
};

/**
 * Check if input is pending.
 *
 * @return {boolean}
 */
OO.ui.PendingElement.prototype.isPending = function () {
	return !!this.pending;
};

/**
 * Increase the pending stack.
 *
 * @chainable
 */
OO.ui.PendingElement.prototype.pushPending = function () {
	if ( this.pending === 0 ) {
		this.$pending.addClass( 'oo-ui-pendingElement-pending' );
		this.updateThemeClasses();
	}
	this.pending++;

	return this;
};

/**
 * Reduce the pending stack.
 *
 * Clamped at zero.
 *
 * @chainable
 */
OO.ui.PendingElement.prototype.popPending = function () {
	if ( this.pending === 1 ) {
		this.$pending.removeClass( 'oo-ui-pendingElement-pending' );
		this.updateThemeClasses();
	}
	this.pending = Math.max( 0, this.pending - 1 );

	return this;
};

/**
 * ActionSets manage the behavior of the {@link OO.ui.ActionWidget Action widgets} that comprise them.
 * Actions can be made available for specific contexts (modes) and circumstances
 * (abilities). Please see the [OOjs UI documentation on MediaWiki][1] for more information.
 *
 *     @example
 *     // Example: An action set used in a process dialog
 *     function ProcessDialog( config ) {
 *         ProcessDialog.super.call( this, config );
 *     }
 *     OO.inheritClass( ProcessDialog, OO.ui.ProcessDialog );
 *     ProcessDialog.static.title = 'An action set in a process dialog';
 *     // An action set that uses modes ('edit' and 'help' mode, in this example).
 *     ProcessDialog.static.actions = [
 *        { action: 'continue', modes: 'edit', label: 'Continue', flags: [ 'primary', 'constructive' ] },
 *        { action: 'help', modes: 'edit', label: 'Help' },
 *        { modes: 'edit', label: 'Cancel', flags: 'safe' },
 *        { action: 'back', modes: 'help', label: 'Back', flags: 'safe' }
 *     ];
 *
 *     ProcessDialog.prototype.initialize = function () {
 *         ProcessDialog.super.prototype.initialize.apply( this, arguments );
 *         this.panel1 = new OO.ui.PanelLayout( { padded: true, expanded: false } );
 *         this.panel1.$element.append( '<p>This dialog uses an action set (continue, help, cancel, back) configured with modes. This is edit mode. Click \'help\' to see help mode. </p>' );
 *         this.panel2 = new OO.ui.PanelLayout( { padded: true, expanded: false } );
 *         this.panel2.$element.append( '<p>This is help mode. Only the \'back\' action widget is configured to be visible here. Click \'back\' to return to \'edit\' mode</p>' );
 *         this.stackLayout= new OO.ui.StackLayout( {
 *             items: [ this.panel1, this.panel2 ]
 *         });
 *         this.$body.append( this.stackLayout.$element );
 *     };
 *     ProcessDialog.prototype.getSetupProcess = function ( data ) {
 *         return ProcessDialog.super.prototype.getSetupProcess.call( this, data )
 *         .next( function () {
 *         this.actions.setMode('edit');
 *         }, this );
 *     };
 *     ProcessDialog.prototype.getActionProcess = function ( action ) {
 *         if ( action === 'help' ) {
 *             this.actions.setMode( 'help' );
 *             this.stackLayout.setItem( this.panel2 );
 *             } else if ( action === 'back' ) {
 *             this.actions.setMode( 'edit' );
 *             this.stackLayout.setItem( this.panel1 );
 *             } else if ( action === 'continue' ) {
 *             var dialog = this;
 *             return new OO.ui.Process( function () {
 *                 dialog.close();
 *             } );
 *         }
 *         return ProcessDialog.super.prototype.getActionProcess.call( this, action );
 *     };
 *     ProcessDialog.prototype.getBodyHeight = function () {
 *         return this.panel1.$element.outerHeight( true );
 *     };
 *     var windowManager = new OO.ui.WindowManager();
 *     $( 'body' ).append( windowManager.$element );
 *     var processDialog = new ProcessDialog({
 *        size: 'medium'});
 *     windowManager.addWindows( [ processDialog ] );
 *     windowManager.openWindow( processDialog );
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Windows/Process_Dialogs#Action_sets
 *
 * @abstract
 * @class
 * @mixins OO.EventEmitter
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
OO.ui.ActionSet = function OoUiActionSet( config ) {
	// Configuration initialization
	config = config || {};

	// Mixin constructors
	OO.EventEmitter.call( this );

	// Properties
	this.list = [];
	this.categories = {
		actions: 'getAction',
		flags: 'getFlags',
		modes: 'getModes'
	};
	this.categorized = {};
	this.special = {};
	this.others = [];
	this.organized = false;
	this.changing = false;
	this.changed = false;
};

/* Setup */

OO.mixinClass( OO.ui.ActionSet, OO.EventEmitter );

/* Static Properties */

/**
 * Symbolic name of the flags used to identify special actions. Special actions are displayed in the
 *  header of a {@link OO.ui.ProcessDialog process dialog}.
 *  See the [OOjs UI documentation on MediaWiki][2] for more information and examples.
 *
 *  [2]:https://www.mediawiki.org/wiki/OOjs_UI/Windows/Process_Dialogs
 *
 * @abstract
 * @static
 * @inheritable
 * @property {string}
 */
OO.ui.ActionSet.static.specialFlags = [ 'safe', 'primary' ];

/* Events */

/**
 * @event click
 * @param {OO.ui.ActionWidget} action Action that was clicked
 */

/**
 * @event resize
 * @param {OO.ui.ActionWidget} action Action that was resized
 */

/**
 * @event add
 * @param {OO.ui.ActionWidget[]} added Actions added
 */

/**
 * @event remove
 * @param {OO.ui.ActionWidget[]} added Actions removed
 */

/**
 * @event change
 */

/* Methods */

/**
 * Handle action change events.
 *
 * @private
 * @fires change
 */
OO.ui.ActionSet.prototype.onActionChange = function () {
	this.organized = false;
	if ( this.changing ) {
		this.changed = true;
	} else {
		this.emit( 'change' );
	}
};

/**
 * Check if a action is one of the special actions.
 *
 * @param {OO.ui.ActionWidget} action Action to check
 * @return {boolean} Action is special
 */
OO.ui.ActionSet.prototype.isSpecial = function ( action ) {
	var flag;

	for ( flag in this.special ) {
		if ( action === this.special[ flag ] ) {
			return true;
		}
	}

	return false;
};

/**
 * Get actions.
 *
 * @param {Object} [filters] Filters to use, omit to get all actions
 * @param {string|string[]} [filters.actions] Actions that actions must have
 * @param {string|string[]} [filters.flags] Flags that actions must have
 * @param {string|string[]} [filters.modes] Modes that actions must have
 * @param {boolean} [filters.visible] Actions must be visible
 * @param {boolean} [filters.disabled] Actions must be disabled
 * @return {OO.ui.ActionWidget[]} Actions matching all criteria
 */
OO.ui.ActionSet.prototype.get = function ( filters ) {
	var i, len, list, category, actions, index, match, matches;

	if ( filters ) {
		this.organize();

		// Collect category candidates
		matches = [];
		for ( category in this.categorized ) {
			list = filters[ category ];
			if ( list ) {
				if ( !Array.isArray( list ) ) {
					list = [ list ];
				}
				for ( i = 0, len = list.length; i < len; i++ ) {
					actions = this.categorized[ category ][ list[ i ] ];
					if ( Array.isArray( actions ) ) {
						matches.push.apply( matches, actions );
					}
				}
			}
		}
		// Remove by boolean filters
		for ( i = 0, len = matches.length; i < len; i++ ) {
			match = matches[ i ];
			if (
				( filters.visible !== undefined && match.isVisible() !== filters.visible ) ||
				( filters.disabled !== undefined && match.isDisabled() !== filters.disabled )
			) {
				matches.splice( i, 1 );
				len--;
				i--;
			}
		}
		// Remove duplicates
		for ( i = 0, len = matches.length; i < len; i++ ) {
			match = matches[ i ];
			index = matches.lastIndexOf( match );
			while ( index !== i ) {
				matches.splice( index, 1 );
				len--;
				index = matches.lastIndexOf( match );
			}
		}
		return matches;
	}
	return this.list.slice();
};

/**
 * Get special actions.
 *
 * Special actions are the first visible actions with special flags, such as 'safe' and 'primary'.
 * Special flags can be configured by changing #static-specialFlags in a subclass.
 *
 * @return {OO.ui.ActionWidget|null} Safe action
 */
OO.ui.ActionSet.prototype.getSpecial = function () {
	this.organize();
	return $.extend( {}, this.special );
};

/**
 * Get other actions.
 *
 * Other actions include all non-special visible actions.
 *
 * @return {OO.ui.ActionWidget[]} Other actions
 */
OO.ui.ActionSet.prototype.getOthers = function () {
	this.organize();
	return this.others.slice();
};

/**
 * Toggle actions based on their modes.
 *
 * Unlike calling toggle on actions with matching flags, this will enforce mutually exclusive
 * visibility; matching actions will be shown, non-matching actions will be hidden.
 *
 * @param {string} mode Mode actions must have
 * @chainable
 * @fires toggle
 * @fires change
 */
OO.ui.ActionSet.prototype.setMode = function ( mode ) {
	var i, len, action;

	this.changing = true;
	for ( i = 0, len = this.list.length; i < len; i++ ) {
		action = this.list[ i ];
		action.toggle( action.hasMode( mode ) );
	}

	this.organized = false;
	this.changing = false;
	this.emit( 'change' );

	return this;
};

/**
 * Change which actions are able to be performed.
 *
 * Actions with matching actions will be disabled/enabled. Other actions will not be changed.
 *
 * @param {Object.<string,boolean>} actions List of abilities, keyed by action name, values
 *   indicate actions are able to be performed
 * @chainable
 */
OO.ui.ActionSet.prototype.setAbilities = function ( actions ) {
	var i, len, action, item;

	for ( i = 0, len = this.list.length; i < len; i++ ) {
		item = this.list[ i ];
		action = item.getAction();
		if ( actions[ action ] !== undefined ) {
			item.setDisabled( !actions[ action ] );
		}
	}

	return this;
};

/**
 * Executes a function once per action.
 *
 * When making changes to multiple actions, use this method instead of iterating over the actions
 * manually to defer emitting a change event until after all actions have been changed.
 *
 * @param {Object|null} actions Filters to use for which actions to iterate over; see #get
 * @param {Function} callback Callback to run for each action; callback is invoked with three
 *   arguments: the action, the action's index, the list of actions being iterated over
 * @chainable
 */
OO.ui.ActionSet.prototype.forEach = function ( filter, callback ) {
	this.changed = false;
	this.changing = true;
	this.get( filter ).forEach( callback );
	this.changing = false;
	if ( this.changed ) {
		this.emit( 'change' );
	}

	return this;
};

/**
 * Add actions.
 *
 * @param {OO.ui.ActionWidget[]} actions Actions to add
 * @chainable
 * @fires add
 * @fires change
 */
OO.ui.ActionSet.prototype.add = function ( actions ) {
	var i, len, action;

	this.changing = true;
	for ( i = 0, len = actions.length; i < len; i++ ) {
		action = actions[ i ];
		action.connect( this, {
			click: [ 'emit', 'click', action ],
			resize: [ 'emit', 'resize', action ],
			toggle: [ 'onActionChange' ]
		} );
		this.list.push( action );
	}
	this.organized = false;
	this.emit( 'add', actions );
	this.changing = false;
	this.emit( 'change' );

	return this;
};

/**
 * Remove actions.
 *
 * @param {OO.ui.ActionWidget[]} actions Actions to remove
 * @chainable
 * @fires remove
 * @fires change
 */
OO.ui.ActionSet.prototype.remove = function ( actions ) {
	var i, len, index, action;

	this.changing = true;
	for ( i = 0, len = actions.length; i < len; i++ ) {
		action = actions[ i ];
		index = this.list.indexOf( action );
		if ( index !== -1 ) {
			action.disconnect( this );
			this.list.splice( index, 1 );
		}
	}
	this.organized = false;
	this.emit( 'remove', actions );
	this.changing = false;
	this.emit( 'change' );

	return this;
};

/**
 * Remove all actions.
 *
 * @chainable
 * @fires remove
 * @fires change
 */
OO.ui.ActionSet.prototype.clear = function () {
	var i, len, action,
		removed = this.list.slice();

	this.changing = true;
	for ( i = 0, len = this.list.length; i < len; i++ ) {
		action = this.list[ i ];
		action.disconnect( this );
	}

	this.list = [];

	this.organized = false;
	this.emit( 'remove', removed );
	this.changing = false;
	this.emit( 'change' );

	return this;
};

/**
 * Organize actions.
 *
 * This is called whenever organized information is requested. It will only reorganize the actions
 * if something has changed since the last time it ran.
 *
 * @private
 * @chainable
 */
OO.ui.ActionSet.prototype.organize = function () {
	var i, iLen, j, jLen, flag, action, category, list, item, special,
		specialFlags = this.constructor.static.specialFlags;

	if ( !this.organized ) {
		this.categorized = {};
		this.special = {};
		this.others = [];
		for ( i = 0, iLen = this.list.length; i < iLen; i++ ) {
			action = this.list[ i ];
			if ( action.isVisible() ) {
				// Populate categories
				for ( category in this.categories ) {
					if ( !this.categorized[ category ] ) {
						this.categorized[ category ] = {};
					}
					list = action[ this.categories[ category ] ]();
					if ( !Array.isArray( list ) ) {
						list = [ list ];
					}
					for ( j = 0, jLen = list.length; j < jLen; j++ ) {
						item = list[ j ];
						if ( !this.categorized[ category ][ item ] ) {
							this.categorized[ category ][ item ] = [];
						}
						this.categorized[ category ][ item ].push( action );
					}
				}
				// Populate special/others
				special = false;
				for ( j = 0, jLen = specialFlags.length; j < jLen; j++ ) {
					flag = specialFlags[ j ];
					if ( !this.special[ flag ] && action.hasFlag( flag ) ) {
						this.special[ flag ] = action;
						special = true;
						break;
					}
				}
				if ( !special ) {
					this.others.push( action );
				}
			}
		}
		this.organized = true;
	}

	return this;
};

/**
 * Each Element represents a rendering in the DOM—a button or an icon, for example, or anything
 * that is visible to a user. Unlike {@link OO.ui.Widget widgets}, plain elements usually do not have events
 * connected to them and can't be interacted with.
 *
 * @abstract
 * @class
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {string[]} [classes] The names of the CSS classes to apply to the element. CSS styles are added
 *  to the top level (e.g., the outermost div) of the element. See the [OOjs UI documentation on MediaWiki][2]
 *  for an example.
 *  [2]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Buttons_and_Switches#cssExample
 * @cfg {string} [id] The HTML id attribute used in the rendered tag.
 * @cfg {string} [text] Text to insert
 * @cfg {Array} [content] An array of content elements to append (after #text).
 *  Strings will be html-escaped; use an OO.ui.HtmlSnippet to append raw HTML.
 *  Instances of OO.ui.Element will have their $element appended.
 * @cfg {jQuery} [$content] Content elements to append (after #text)
 * @cfg {Mixed} [data] Custom data of any type or combination of types (e.g., string, number, array, object).
 *  Data can also be specified with the #setData method.
 */
OO.ui.Element = function OoUiElement( config ) {
	// Configuration initialization
	config = config || {};

	// Properties
	this.$ = $;
	this.visible = true;
	this.data = config.data;
	this.$element = config.$element ||
		$( document.createElement( this.getTagName() ) );
	this.elementGroup = null;
	this.debouncedUpdateThemeClassesHandler = this.debouncedUpdateThemeClasses.bind( this );
	this.updateThemeClassesPending = false;

	// Initialization
	if ( Array.isArray( config.classes ) ) {
		this.$element.addClass( config.classes.join( ' ' ) );
	}
	if ( config.id ) {
		this.$element.attr( 'id', config.id );
	}
	if ( config.text ) {
		this.$element.text( config.text );
	}
	if ( config.content ) {
		// The `content` property treats plain strings as text; use an
		// HtmlSnippet to append HTML content.  `OO.ui.Element`s get their
		// appropriate $element appended.
		this.$element.append( config.content.map( function ( v ) {
			if ( typeof v === 'string' ) {
				// Escape string so it is properly represented in HTML.
				return document.createTextNode( v );
			} else if ( v instanceof OO.ui.HtmlSnippet ) {
				// Bypass escaping.
				return v.toString();
			} else if ( v instanceof OO.ui.Element ) {
				return v.$element;
			}
			return v;
		} ) );
	}
	if ( config.$content ) {
		// The `$content` property treats plain strings as HTML.
		this.$element.append( config.$content );
	}
};

/* Setup */

OO.initClass( OO.ui.Element );

/* Static Properties */

/**
 * The name of the HTML tag used by the element.
 *
 * The static value may be ignored if the #getTagName method is overridden.
 *
 * @static
 * @inheritable
 * @property {string}
 */
OO.ui.Element.static.tagName = 'div';

/* Static Methods */

/**
 * Reconstitute a JavaScript object corresponding to a widget created
 * by the PHP implementation.
 *
 * @param {string|HTMLElement|jQuery} idOrNode
 *   A DOM id (if a string) or node for the widget to infuse.
 * @return {OO.ui.Element}
 *   The `OO.ui.Element` corresponding to this (infusable) document node.
 *   For `Tag` objects emitted on the HTML side (used occasionally for content)
 *   the value returned is a newly-created Element wrapping around the existing
 *   DOM node.
 */
OO.ui.Element.static.infuse = function ( idOrNode ) {
	var obj = OO.ui.Element.static.unsafeInfuse( idOrNode, true );
	// Verify that the type matches up.
	// FIXME: uncomment after T89721 is fixed (see T90929)
	/*
	if ( !( obj instanceof this['class'] ) ) {
		throw new Error( 'Infusion type mismatch!' );
	}
	*/
	return obj;
};

/**
 * Implementation helper for `infuse`; skips the type check and has an
 * extra property so that only the top-level invocation touches the DOM.
 * @private
 * @param {string|HTMLElement|jQuery} idOrNode
 * @param {boolean} top True only for top-level invocation.
 * @return {OO.ui.Element}
 */
OO.ui.Element.static.unsafeInfuse = function ( idOrNode, top ) {
	// look for a cached result of a previous infusion.
	var id, $elem, data, cls, obj;
	if ( typeof idOrNode === 'string' ) {
		id = idOrNode;
		$elem = $( document.getElementById( id ) );
	} else {
		$elem = $( idOrNode );
		id = $elem.attr( 'id' );
	}
	data = $elem.data( 'ooui-infused' );
	if ( data ) {
		// cached!
		if ( data === true ) {
			throw new Error( 'Circular dependency! ' + id );
		}
		return data;
	}
	if ( !$elem.length ) {
		throw new Error( 'Widget not found: ' + id );
	}
	data = $elem.attr( 'data-ooui' );
	if ( !data ) {
		throw new Error( 'No infusion data found: ' + id );
	}
	try {
		data = $.parseJSON( data );
	} catch ( _ ) {
		data = null;
	}
	if ( !( data && data._ ) ) {
		throw new Error( 'No valid infusion data found: ' + id );
	}
	if ( data._ === 'Tag' ) {
		// Special case: this is a raw Tag; wrap existing node, don't rebuild.
		return new OO.ui.Element( { $element: $elem } );
	}
	cls = OO.ui[data._];
	if ( !cls ) {
		throw new Error( 'Unknown widget type: ' + id );
	}
	$elem.data( 'ooui-infused', true ); // prevent loops
	data.id = id; // implicit
	data = OO.copy( data, null, function deserialize( value ) {
		if ( OO.isPlainObject( value ) ) {
			if ( value.tag ) {
				return OO.ui.Element.static.unsafeInfuse( value.tag, false );
			}
			if ( value.html ) {
				return new OO.ui.HtmlSnippet( value.html );
			}
		}
	} );
	// jscs:disable requireCapitalizedConstructors
	obj = new cls( data ); // rebuild widget
	// now replace old DOM with this new DOM.
	if ( top ) {
		$elem.replaceWith( obj.$element );
	}
	obj.$element.data( 'ooui-infused', obj );
	// set the 'data-ooui' attribute so we can identify infused widgets
	obj.$element.attr( 'data-ooui', '' );
	return obj;
};

/**
 * Get a jQuery function within a specific document.
 *
 * @static
 * @param {jQuery|HTMLElement|HTMLDocument|Window} context Context to bind the function to
 * @param {jQuery} [$iframe] HTML iframe element that contains the document, omit if document is
 *   not in an iframe
 * @return {Function} Bound jQuery function
 */
OO.ui.Element.static.getJQuery = function ( context, $iframe ) {
	function wrapper( selector ) {
		return $( selector, wrapper.context );
	}

	wrapper.context = this.getDocument( context );

	if ( $iframe ) {
		wrapper.$iframe = $iframe;
	}

	return wrapper;
};

/**
 * Get the document of an element.
 *
 * @static
 * @param {jQuery|HTMLElement|HTMLDocument|Window} obj Object to get the document for
 * @return {HTMLDocument|null} Document object
 */
OO.ui.Element.static.getDocument = function ( obj ) {
	// jQuery - selections created "offscreen" won't have a context, so .context isn't reliable
	return ( obj[ 0 ] && obj[ 0 ].ownerDocument ) ||
		// Empty jQuery selections might have a context
		obj.context ||
		// HTMLElement
		obj.ownerDocument ||
		// Window
		obj.document ||
		// HTMLDocument
		( obj.nodeType === 9 && obj ) ||
		null;
};

/**
 * Get the window of an element or document.
 *
 * @static
 * @param {jQuery|HTMLElement|HTMLDocument|Window} obj Context to get the window for
 * @return {Window} Window object
 */
OO.ui.Element.static.getWindow = function ( obj ) {
	var doc = this.getDocument( obj );
	return doc.parentWindow || doc.defaultView;
};

/**
 * Get the direction of an element or document.
 *
 * @static
 * @param {jQuery|HTMLElement|HTMLDocument|Window} obj Context to get the direction for
 * @return {string} Text direction, either 'ltr' or 'rtl'
 */
OO.ui.Element.static.getDir = function ( obj ) {
	var isDoc, isWin;

	if ( obj instanceof jQuery ) {
		obj = obj[ 0 ];
	}
	isDoc = obj.nodeType === 9;
	isWin = obj.document !== undefined;
	if ( isDoc || isWin ) {
		if ( isWin ) {
			obj = obj.document;
		}
		obj = obj.body;
	}
	return $( obj ).css( 'direction' );
};

/**
 * Get the offset between two frames.
 *
 * TODO: Make this function not use recursion.
 *
 * @static
 * @param {Window} from Window of the child frame
 * @param {Window} [to=window] Window of the parent frame
 * @param {Object} [offset] Offset to start with, used internally
 * @return {Object} Offset object, containing left and top properties
 */
OO.ui.Element.static.getFrameOffset = function ( from, to, offset ) {
	var i, len, frames, frame, rect;

	if ( !to ) {
		to = window;
	}
	if ( !offset ) {
		offset = { top: 0, left: 0 };
	}
	if ( from.parent === from ) {
		return offset;
	}

	// Get iframe element
	frames = from.parent.document.getElementsByTagName( 'iframe' );
	for ( i = 0, len = frames.length; i < len; i++ ) {
		if ( frames[ i ].contentWindow === from ) {
			frame = frames[ i ];
			break;
		}
	}

	// Recursively accumulate offset values
	if ( frame ) {
		rect = frame.getBoundingClientRect();
		offset.left += rect.left;
		offset.top += rect.top;
		if ( from !== to ) {
			this.getFrameOffset( from.parent, offset );
		}
	}
	return offset;
};

/**
 * Get the offset between two elements.
 *
 * The two elements may be in a different frame, but in that case the frame $element is in must
 * be contained in the frame $anchor is in.
 *
 * @static
 * @param {jQuery} $element Element whose position to get
 * @param {jQuery} $anchor Element to get $element's position relative to
 * @return {Object} Translated position coordinates, containing top and left properties
 */
OO.ui.Element.static.getRelativePosition = function ( $element, $anchor ) {
	var iframe, iframePos,
		pos = $element.offset(),
		anchorPos = $anchor.offset(),
		elementDocument = this.getDocument( $element ),
		anchorDocument = this.getDocument( $anchor );

	// If $element isn't in the same document as $anchor, traverse up
	while ( elementDocument !== anchorDocument ) {
		iframe = elementDocument.defaultView.frameElement;
		if ( !iframe ) {
			throw new Error( '$element frame is not contained in $anchor frame' );
		}
		iframePos = $( iframe ).offset();
		pos.left += iframePos.left;
		pos.top += iframePos.top;
		elementDocument = iframe.ownerDocument;
	}
	pos.left -= anchorPos.left;
	pos.top -= anchorPos.top;
	return pos;
};

/**
 * Get element border sizes.
 *
 * @static
 * @param {HTMLElement} el Element to measure
 * @return {Object} Dimensions object with `top`, `left`, `bottom` and `right` properties
 */
OO.ui.Element.static.getBorders = function ( el ) {
	var doc = el.ownerDocument,
		win = doc.parentWindow || doc.defaultView,
		style = win && win.getComputedStyle ?
			win.getComputedStyle( el, null ) :
			el.currentStyle,
		$el = $( el ),
		top = parseFloat( style ? style.borderTopWidth : $el.css( 'borderTopWidth' ) ) || 0,
		left = parseFloat( style ? style.borderLeftWidth : $el.css( 'borderLeftWidth' ) ) || 0,
		bottom = parseFloat( style ? style.borderBottomWidth : $el.css( 'borderBottomWidth' ) ) || 0,
		right = parseFloat( style ? style.borderRightWidth : $el.css( 'borderRightWidth' ) ) || 0;

	return {
		top: top,
		left: left,
		bottom: bottom,
		right: right
	};
};

/**
 * Get dimensions of an element or window.
 *
 * @static
 * @param {HTMLElement|Window} el Element to measure
 * @return {Object} Dimensions object with `borders`, `scroll`, `scrollbar` and `rect` properties
 */
OO.ui.Element.static.getDimensions = function ( el ) {
	var $el, $win,
		doc = el.ownerDocument || el.document,
		win = doc.parentWindow || doc.defaultView;

	if ( win === el || el === doc.documentElement ) {
		$win = $( win );
		return {
			borders: { top: 0, left: 0, bottom: 0, right: 0 },
			scroll: {
				top: $win.scrollTop(),
				left: $win.scrollLeft()
			},
			scrollbar: { right: 0, bottom: 0 },
			rect: {
				top: 0,
				left: 0,
				bottom: $win.innerHeight(),
				right: $win.innerWidth()
			}
		};
	} else {
		$el = $( el );
		return {
			borders: this.getBorders( el ),
			scroll: {
				top: $el.scrollTop(),
				left: $el.scrollLeft()
			},
			scrollbar: {
				right: $el.innerWidth() - el.clientWidth,
				bottom: $el.innerHeight() - el.clientHeight
			},
			rect: el.getBoundingClientRect()
		};
	}
};

/**
 * Get scrollable object parent
 *
 * documentElement can't be used to get or set the scrollTop
 * property on Blink. Changing and testing its value lets us
 * use 'body' or 'documentElement' based on what is working.
 *
 * https://code.google.com/p/chromium/issues/detail?id=303131
 *
 * @static
 * @param {HTMLElement} el Element to find scrollable parent for
 * @return {HTMLElement} Scrollable parent
 */
OO.ui.Element.static.getRootScrollableElement = function ( el ) {
	var scrollTop, body;

	if ( OO.ui.scrollableElement === undefined ) {
		body = el.ownerDocument.body;
		scrollTop = body.scrollTop;
		body.scrollTop = 1;

		if ( body.scrollTop === 1 ) {
			body.scrollTop = scrollTop;
			OO.ui.scrollableElement = 'body';
		} else {
			OO.ui.scrollableElement = 'documentElement';
		}
	}

	return el.ownerDocument[ OO.ui.scrollableElement ];
};

/**
 * Get closest scrollable container.
 *
 * Traverses up until either a scrollable element or the root is reached, in which case the window
 * will be returned.
 *
 * @static
 * @param {HTMLElement} el Element to find scrollable container for
 * @param {string} [dimension] Dimension of scrolling to look for; `x`, `y` or omit for either
 * @return {HTMLElement} Closest scrollable container
 */
OO.ui.Element.static.getClosestScrollableContainer = function ( el, dimension ) {
	var i, val,
		props = [ 'overflow' ],
		$parent = $( el ).parent();

	if ( dimension === 'x' || dimension === 'y' ) {
		props.push( 'overflow-' + dimension );
	}

	while ( $parent.length ) {
		if ( $parent[ 0 ] === this.getRootScrollableElement( el ) ) {
			return $parent[ 0 ];
		}
		i = props.length;
		while ( i-- ) {
			val = $parent.css( props[ i ] );
			if ( val === 'auto' || val === 'scroll' ) {
				return $parent[ 0 ];
			}
		}
		$parent = $parent.parent();
	}
	return this.getDocument( el ).body;
};

/**
 * Scroll element into view.
 *
 * @static
 * @param {HTMLElement} el Element to scroll into view
 * @param {Object} [config] Configuration options
 * @param {string} [config.duration] jQuery animation duration value
 * @param {string} [config.direction] Scroll in only one direction, e.g. 'x' or 'y', omit
 *  to scroll in both directions
 * @param {Function} [config.complete] Function to call when scrolling completes
 */
OO.ui.Element.static.scrollIntoView = function ( el, config ) {
	// Configuration initialization
	config = config || {};

	var rel, anim = {},
		callback = typeof config.complete === 'function' && config.complete,
		sc = this.getClosestScrollableContainer( el, config.direction ),
		$sc = $( sc ),
		eld = this.getDimensions( el ),
		scd = this.getDimensions( sc ),
		$win = $( this.getWindow( el ) );

	// Compute the distances between the edges of el and the edges of the scroll viewport
	if ( $sc.is( 'html, body' ) ) {
		// If the scrollable container is the root, this is easy
		rel = {
			top: eld.rect.top,
			bottom: $win.innerHeight() - eld.rect.bottom,
			left: eld.rect.left,
			right: $win.innerWidth() - eld.rect.right
		};
	} else {
		// Otherwise, we have to subtract el's coordinates from sc's coordinates
		rel = {
			top: eld.rect.top - ( scd.rect.top + scd.borders.top ),
			bottom: scd.rect.bottom - scd.borders.bottom - scd.scrollbar.bottom - eld.rect.bottom,
			left: eld.rect.left - ( scd.rect.left + scd.borders.left ),
			right: scd.rect.right - scd.borders.right - scd.scrollbar.right - eld.rect.right
		};
	}

	if ( !config.direction || config.direction === 'y' ) {
		if ( rel.top < 0 ) {
			anim.scrollTop = scd.scroll.top + rel.top;
		} else if ( rel.top > 0 && rel.bottom < 0 ) {
			anim.scrollTop = scd.scroll.top + Math.min( rel.top, -rel.bottom );
		}
	}
	if ( !config.direction || config.direction === 'x' ) {
		if ( rel.left < 0 ) {
			anim.scrollLeft = scd.scroll.left + rel.left;
		} else if ( rel.left > 0 && rel.right < 0 ) {
			anim.scrollLeft = scd.scroll.left + Math.min( rel.left, -rel.right );
		}
	}
	if ( !$.isEmptyObject( anim ) ) {
		$sc.stop( true ).animate( anim, config.duration || 'fast' );
		if ( callback ) {
			$sc.queue( function ( next ) {
				callback();
				next();
			} );
		}
	} else {
		if ( callback ) {
			callback();
		}
	}
};

/**
 * Force the browser to reconsider whether it really needs to render scrollbars inside the element
 * and reserve space for them, because it probably doesn't.
 *
 * Workaround primarily for <https://code.google.com/p/chromium/issues/detail?id=387290>, but also
 * similar bugs in other browsers. "Just" forcing a reflow is not sufficient in all cases, we need
 * to first actually detach (or hide, but detaching is simpler) all children, *then* force a reflow,
 * and then reattach (or show) them back.
 *
 * @static
 * @param {HTMLElement} el Element to reconsider the scrollbars on
 */
OO.ui.Element.static.reconsiderScrollbars = function ( el ) {
	var i, len, nodes = [];
	// Detach all children
	while ( el.firstChild ) {
		nodes.push( el.firstChild );
		el.removeChild( el.firstChild );
	}
	// Force reflow
	void el.offsetHeight;
	// Reattach all children
	for ( i = 0, len = nodes.length; i < len; i++ ) {
		el.appendChild( nodes[ i ] );
	}
};

/* Methods */

/**
 * Toggle visibility of an element.
 *
 * @param {boolean} [show] Make element visible, omit to toggle visibility
 * @fires visible
 * @chainable
 */
OO.ui.Element.prototype.toggle = function ( show ) {
	show = show === undefined ? !this.visible : !!show;

	if ( show !== this.isVisible() ) {
		this.visible = show;
		this.$element.toggleClass( 'oo-ui-element-hidden', !this.visible );
		this.emit( 'toggle', show );
	}

	return this;
};

/**
 * Check if element is visible.
 *
 * @return {boolean} element is visible
 */
OO.ui.Element.prototype.isVisible = function () {
	return this.visible;
};

/**
 * Get element data.
 *
 * @return {Mixed} Element data
 */
OO.ui.Element.prototype.getData = function () {
	return this.data;
};

/**
 * Set element data.
 *
 * @param {Mixed} Element data
 * @chainable
 */
OO.ui.Element.prototype.setData = function ( data ) {
	this.data = data;
	return this;
};

/**
 * Check if element supports one or more methods.
 *
 * @param {string|string[]} methods Method or list of methods to check
 * @return {boolean} All methods are supported
 */
OO.ui.Element.prototype.supports = function ( methods ) {
	var i, len,
		support = 0;

	methods = Array.isArray( methods ) ? methods : [ methods ];
	for ( i = 0, len = methods.length; i < len; i++ ) {
		if ( $.isFunction( this[ methods[ i ] ] ) ) {
			support++;
		}
	}

	return methods.length === support;
};

/**
 * Update the theme-provided classes.
 *
 * @localdoc This is called in element mixins and widget classes any time state changes.
 *   Updating is debounced, minimizing overhead of changing multiple attributes and
 *   guaranteeing that theme updates do not occur within an element's constructor
 */
OO.ui.Element.prototype.updateThemeClasses = function () {
	if ( !this.updateThemeClassesPending ) {
		this.updateThemeClassesPending = true;
		setTimeout( this.debouncedUpdateThemeClassesHandler );
	}
};

/**
 * @private
 */
OO.ui.Element.prototype.debouncedUpdateThemeClasses = function () {
	OO.ui.theme.updateElementClasses( this );
	this.updateThemeClassesPending = false;
};

/**
 * Get the HTML tag name.
 *
 * Override this method to base the result on instance information.
 *
 * @return {string} HTML tag name
 */
OO.ui.Element.prototype.getTagName = function () {
	return this.constructor.static.tagName;
};

/**
 * Check if the element is attached to the DOM
 * @return {boolean} The element is attached to the DOM
 */
OO.ui.Element.prototype.isElementAttached = function () {
	return $.contains( this.getElementDocument(), this.$element[ 0 ] );
};

/**
 * Get the DOM document.
 *
 * @return {HTMLDocument} Document object
 */
OO.ui.Element.prototype.getElementDocument = function () {
	// Don't cache this in other ways either because subclasses could can change this.$element
	return OO.ui.Element.static.getDocument( this.$element );
};

/**
 * Get the DOM window.
 *
 * @return {Window} Window object
 */
OO.ui.Element.prototype.getElementWindow = function () {
	return OO.ui.Element.static.getWindow( this.$element );
};

/**
 * Get closest scrollable container.
 */
OO.ui.Element.prototype.getClosestScrollableElementContainer = function () {
	return OO.ui.Element.static.getClosestScrollableContainer( this.$element[ 0 ] );
};

/**
 * Get group element is in.
 *
 * @return {OO.ui.GroupElement|null} Group element, null if none
 */
OO.ui.Element.prototype.getElementGroup = function () {
	return this.elementGroup;
};

/**
 * Set group element is in.
 *
 * @param {OO.ui.GroupElement|null} group Group element, null if none
 * @chainable
 */
OO.ui.Element.prototype.setElementGroup = function ( group ) {
	this.elementGroup = group;
	return this;
};

/**
 * Scroll element into view.
 *
 * @param {Object} [config] Configuration options
 */
OO.ui.Element.prototype.scrollElementIntoView = function ( config ) {
	return OO.ui.Element.static.scrollIntoView( this.$element[ 0 ], config );
};

/**
 * Container for elements.
 *
 * @abstract
 * @class
 * @extends OO.ui.Element
 * @mixins OO.EventEmitter
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
OO.ui.Layout = function OoUiLayout( config ) {
	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.Layout.super.call( this, config );

	// Mixin constructors
	OO.EventEmitter.call( this );

	// Initialization
	this.$element.addClass( 'oo-ui-layout' );
};

/* Setup */

OO.inheritClass( OO.ui.Layout, OO.ui.Element );
OO.mixinClass( OO.ui.Layout, OO.EventEmitter );

/**
 * Widgets are compositions of one or more OOjs UI elements that users can both view
 * and interact with. All widgets can be configured and modified via a standard API,
 * and their state can change dynamically according to a model.
 *
 * @abstract
 * @class
 * @extends OO.ui.Element
 * @mixins OO.EventEmitter
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {boolean} [disabled=false] Disable
 */
OO.ui.Widget = function OoUiWidget( config ) {
	// Initialize config
	config = $.extend( { disabled: false }, config );

	// Parent constructor
	OO.ui.Widget.super.call( this, config );

	// Mixin constructors
	OO.EventEmitter.call( this );

	// Properties
	this.disabled = null;
	this.wasDisabled = null;

	// Initialization
	this.$element.addClass( 'oo-ui-widget' );
	this.setDisabled( !!config.disabled );
};

/* Setup */

OO.inheritClass( OO.ui.Widget, OO.ui.Element );
OO.mixinClass( OO.ui.Widget, OO.EventEmitter );

/* Events */

/**
 * @event disable
 * @param {boolean} disabled Widget is disabled
 */

/**
 * @event toggle
 * @param {boolean} visible Widget is visible
 */

/* Methods */

/**
 * Check if the widget is disabled.
 *
 * @return {boolean} Button is disabled
 */
OO.ui.Widget.prototype.isDisabled = function () {
	return this.disabled;
};

/**
 * Set the disabled state of the widget.
 *
 * This should probably change the widgets' appearance and prevent it from being used.
 *
 * @param {boolean} disabled Disable widget
 * @chainable
 */
OO.ui.Widget.prototype.setDisabled = function ( disabled ) {
	var isDisabled;

	this.disabled = !!disabled;
	isDisabled = this.isDisabled();
	if ( isDisabled !== this.wasDisabled ) {
		this.$element.toggleClass( 'oo-ui-widget-disabled', isDisabled );
		this.$element.toggleClass( 'oo-ui-widget-enabled', !isDisabled );
		this.$element.attr( 'aria-disabled', isDisabled.toString() );
		this.emit( 'disable', isDisabled );
		this.updateThemeClasses();
	}
	this.wasDisabled = isDisabled;

	return this;
};

/**
 * Update the disabled state, in case of changes in parent widget.
 *
 * @chainable
 */
OO.ui.Widget.prototype.updateDisabled = function () {
	this.setDisabled( this.disabled );
	return this;
};

/**
 * A window is a container for elements that are in a child frame. They are used with
 * a window manager (OO.ui.WindowManager), which is used to open and close the window and control
 * its presentation. The size of a window is specified using a symbolic name (e.g., ‘small’, ‘medium’,
 * ‘large’), which is interpreted by the window manager. If the requested size is not recognized,
 * the window manager will choose a sensible fallback.
 *
 * The lifecycle of a window has three primary stages (opening, opened, and closing) in which
 * different processes are executed:
 *
 * **opening**: The opening stage begins when the window manager's {@link OO.ui.WindowManager#openWindow
 * openWindow} or the window's {@link #open open} methods are used, and the window manager begins to open
 * the window.
 *
 * - {@link #getSetupProcess} method is called and its result executed
 * - {@link #getReadyProcess} method is called and its result executed
 *
 * **opened**: The window is now open
 *
 * **closing**: The closing stage begins when the window manager's
 * {@link OO.ui.WindowManager#closeWindow closeWindow}
 * or the window's {@link #close} methods are used, and the window manager begins to close the window.
 *
 * - {@link #getHoldProcess} method is called and its result executed
 * - {@link #getTeardownProcess} method is called and its result executed. The window is now closed
 *
 * Each of the window's processes (setup, ready, hold, and teardown) can be extended in subclasses
 * by overriding the window's #getSetupProcess, #getReadyProcess, #getHoldProcess and #getTeardownProcess
 * methods. Note that each {@link OO.ui.Process process} is executed in series, so asynchronous
 * processing can complete. Always assume window processes are executed asynchronously.
 *
 * For more information, please see the [OOjs UI documentation on MediaWiki] [1].
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Windows
 *
 * @abstract
 * @class
 * @extends OO.ui.Element
 * @mixins OO.EventEmitter
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {string} [size] Symbolic name of dialog size, `small`, `medium`, `large`, `larger` or
 *  `full`; omit to use #static-size
 */
OO.ui.Window = function OoUiWindow( config ) {
	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.Window.super.call( this, config );

	// Mixin constructors
	OO.EventEmitter.call( this );

	// Properties
	this.manager = null;
	this.size = config.size || this.constructor.static.size;
	this.$frame = $( '<div>' );
	this.$overlay = $( '<div>' );
	this.$content = $( '<div>' );

	// Initialization
	this.$overlay.addClass( 'oo-ui-window-overlay' );
	this.$content
		.addClass( 'oo-ui-window-content' )
		.attr( 'tabIndex', 0 );
	this.$frame
		.addClass( 'oo-ui-window-frame' )
		.append( this.$content );

	this.$element
		.addClass( 'oo-ui-window' )
		.append( this.$frame, this.$overlay );

	// Initially hidden - using #toggle may cause errors if subclasses override toggle with methods
	// that reference properties not initialized at that time of parent class construction
	// TODO: Find a better way to handle post-constructor setup
	this.visible = false;
	this.$element.addClass( 'oo-ui-element-hidden' );
};

/* Setup */

OO.inheritClass( OO.ui.Window, OO.ui.Element );
OO.mixinClass( OO.ui.Window, OO.EventEmitter );

/* Static Properties */

/**
 * Symbolic name of size.
 *
 * Size is used if no size is configured during construction.
 *
 * @static
 * @inheritable
 * @property {string}
 */
OO.ui.Window.static.size = 'medium';

/* Methods */

/**
 * Handle mouse down events.
 *
 * @param {jQuery.Event} e Mouse down event
 */
OO.ui.Window.prototype.onMouseDown = function ( e ) {
	// Prevent clicking on the click-block from stealing focus
	if ( e.target === this.$element[ 0 ] ) {
		return false;
	}
};

/**
 * Check if window has been initialized.
 *
 * Initialization occurs when a window is added to a manager.
 *
 * @return {boolean} Window has been initialized
 */
OO.ui.Window.prototype.isInitialized = function () {
	return !!this.manager;
};

/**
 * Check if window is visible.
 *
 * @return {boolean} Window is visible
 */
OO.ui.Window.prototype.isVisible = function () {
	return this.visible;
};

/**
 * Check if window is opening.
 *
 * This is a wrapper around OO.ui.WindowManager#isOpening.
 *
 * @return {boolean} Window is opening
 */
OO.ui.Window.prototype.isOpening = function () {
	return this.manager.isOpening( this );
};

/**
 * Check if window is closing.
 *
 * This is a wrapper around OO.ui.WindowManager#isClosing.
 *
 * @return {boolean} Window is closing
 */
OO.ui.Window.prototype.isClosing = function () {
	return this.manager.isClosing( this );
};

/**
 * Check if window is opened.
 *
 * This is a wrapper around OO.ui.WindowManager#isOpened.
 *
 * @return {boolean} Window is opened
 */
OO.ui.Window.prototype.isOpened = function () {
	return this.manager.isOpened( this );
};

/**
 * Get the window manager.
 *
 * @return {OO.ui.WindowManager} Manager of window
 */
OO.ui.Window.prototype.getManager = function () {
	return this.manager;
};

/**
 * Get the window size.
 *
 * @return {string} Symbolic size name, e.g. `small`, `medium`, `large`, `larger`, `full`
 */
OO.ui.Window.prototype.getSize = function () {
	return this.size;
};

/**
 * Disable transitions on window's frame for the duration of the callback function, then enable them
 * back.
 *
 * @private
 * @param {Function} callback Function to call while transitions are disabled
 */
OO.ui.Window.prototype.withoutSizeTransitions = function ( callback ) {
	// Temporarily resize the frame so getBodyHeight() can use scrollHeight measurements.
	// Disable transitions first, otherwise we'll get values from when the window was animating.
	var oldTransition,
		styleObj = this.$frame[ 0 ].style;
	oldTransition = styleObj.transition || styleObj.OTransition || styleObj.MsTransition ||
		styleObj.MozTransition || styleObj.WebkitTransition;
	styleObj.transition = styleObj.OTransition = styleObj.MsTransition =
		styleObj.MozTransition = styleObj.WebkitTransition = 'none';
	callback();
	// Force reflow to make sure the style changes done inside callback really are not transitioned
	this.$frame.height();
	styleObj.transition = styleObj.OTransition = styleObj.MsTransition =
		styleObj.MozTransition = styleObj.WebkitTransition = oldTransition;
};

/**
 * Get the height of the dialog contents.
 *
 * @return {number} Content height
 */
OO.ui.Window.prototype.getContentHeight = function () {
	var bodyHeight,
		win = this,
		bodyStyleObj = this.$body[ 0 ].style,
		frameStyleObj = this.$frame[ 0 ].style;

	// Temporarily resize the frame so getBodyHeight() can use scrollHeight measurements.
	// Disable transitions first, otherwise we'll get values from when the window was animating.
	this.withoutSizeTransitions( function () {
		var oldHeight = frameStyleObj.height,
			oldPosition = bodyStyleObj.position;
		frameStyleObj.height = '1px';
		// Force body to resize to new width
		bodyStyleObj.position = 'relative';
		bodyHeight = win.getBodyHeight();
		frameStyleObj.height = oldHeight;
		bodyStyleObj.position = oldPosition;
	} );

	return (
		// Add buffer for border
		( this.$frame.outerHeight() - this.$frame.innerHeight() ) +
		// Use combined heights of children
		( this.$head.outerHeight( true ) + bodyHeight + this.$foot.outerHeight( true ) )
	);
};

/**
 * Get the height of the dialog contents.
 *
 * When this function is called, the dialog will temporarily have been resized
 * to height=1px, so .scrollHeight measurements can be taken accurately.
 *
 * @return {number} Height of content
 */
OO.ui.Window.prototype.getBodyHeight = function () {
	return this.$body[ 0 ].scrollHeight;
};

/**
 * Get the directionality of the frame
 *
 * @return {string} Directionality, 'ltr' or 'rtl'
 */
OO.ui.Window.prototype.getDir = function () {
	return this.dir;
};

/**
 * Get a process for setting up a window for use.
 *
 * Each time the window is opened this process will set it up for use in a particular context, based
 * on the `data` argument.
 *
 * When you override this method, you can add additional setup steps to the process the parent
 * method provides using the 'first' and 'next' methods.
 *
 * @abstract
 * @param {Object} [data] Window opening data
 * @return {OO.ui.Process} Setup process
 */
OO.ui.Window.prototype.getSetupProcess = function () {
	return new OO.ui.Process();
};

/**
 * Get a process for readying a window for use.
 *
 * Each time the window is open and setup, this process will ready it up for use in a particular
 * context, based on the `data` argument.
 *
 * When you override this method, you can add additional setup steps to the process the parent
 * method provides using the 'first' and 'next' methods.
 *
 * @abstract
 * @param {Object} [data] Window opening data
 * @return {OO.ui.Process} Setup process
 */
OO.ui.Window.prototype.getReadyProcess = function () {
	return new OO.ui.Process();
};

/**
 * Get a process for holding a window from use.
 *
 * Each time the window is closed, this process will hold it from use in a particular context, based
 * on the `data` argument.
 *
 * When you override this method, you can add additional setup steps to the process the parent
 * method provides using the 'first' and 'next' methods.
 *
 * @abstract
 * @param {Object} [data] Window closing data
 * @return {OO.ui.Process} Hold process
 */
OO.ui.Window.prototype.getHoldProcess = function () {
	return new OO.ui.Process();
};

/**
 * Get a process for tearing down a window after use.
 *
 * Each time the window is closed this process will tear it down and do something with the user's
 * interactions within the window, based on the `data` argument.
 *
 * When you override this method, you can add additional teardown steps to the process the parent
 * method provides using the 'first' and 'next' methods.
 *
 * @abstract
 * @param {Object} [data] Window closing data
 * @return {OO.ui.Process} Teardown process
 */
OO.ui.Window.prototype.getTeardownProcess = function () {
	return new OO.ui.Process();
};

/**
 * Set the window manager.
 *
 * This will cause the window to initialize. Calling it more than once will cause an error.
 *
 * @param {OO.ui.WindowManager} manager Manager for this window
 * @throws {Error} If called more than once
 * @chainable
 */
OO.ui.Window.prototype.setManager = function ( manager ) {
	if ( this.manager ) {
		throw new Error( 'Cannot set window manager, window already has a manager' );
	}

	this.manager = manager;
	this.initialize();

	return this;
};

/**
 * Set the window size.
 *
 * @param {string} size Symbolic size name, e.g. 'small', 'medium', 'large', 'full'
 * @chainable
 */
OO.ui.Window.prototype.setSize = function ( size ) {
	this.size = size;
	this.updateSize();
	return this;
};

/**
 * Update the window size.
 *
 * @throws {Error} If not attached to a manager
 * @chainable
 */
OO.ui.Window.prototype.updateSize = function () {
	if ( !this.manager ) {
		throw new Error( 'Cannot update window size, must be attached to a manager' );
	}

	this.manager.updateWindowSize( this );

	return this;
};

/**
 * Set window dimensions.
 *
 * Properties are applied to the frame container.
 *
 * @param {Object} dim CSS dimension properties
 * @param {string|number} [dim.width] Width
 * @param {string|number} [dim.minWidth] Minimum width
 * @param {string|number} [dim.maxWidth] Maximum width
 * @param {string|number} [dim.width] Height, omit to set based on height of contents
 * @param {string|number} [dim.minWidth] Minimum height
 * @param {string|number} [dim.maxWidth] Maximum height
 * @chainable
 */
OO.ui.Window.prototype.setDimensions = function ( dim ) {
	var height,
		win = this,
		styleObj = this.$frame[ 0 ].style;

	// Calculate the height we need to set using the correct width
	if ( dim.height === undefined ) {
		this.withoutSizeTransitions( function () {
			var oldWidth = styleObj.width;
			win.$frame.css( 'width', dim.width || '' );
			height = win.getContentHeight();
			styleObj.width = oldWidth;
		} );
	} else {
		height = dim.height;
	}

	this.$frame.css( {
		width: dim.width || '',
		minWidth: dim.minWidth || '',
		maxWidth: dim.maxWidth || '',
		height: height || '',
		minHeight: dim.minHeight || '',
		maxHeight: dim.maxHeight || ''
	} );

	return this;
};

/**
 * Initialize window contents.
 *
 * The first time the window is opened, #initialize is called so that changes to the window that
 * will persist between openings can be made. See #getSetupProcess for a way to make changes each
 * time the window opens.
 *
 * @throws {Error} If not attached to a manager
 * @chainable
 */
OO.ui.Window.prototype.initialize = function () {
	if ( !this.manager ) {
		throw new Error( 'Cannot initialize window, must be attached to a manager' );
	}

	// Properties
	this.$head = $( '<div>' );
	this.$body = $( '<div>' );
	this.$foot = $( '<div>' );
	this.dir = OO.ui.Element.static.getDir( this.$content ) || 'ltr';
	this.$document = $( this.getElementDocument() );

	// Events
	this.$element.on( 'mousedown', this.onMouseDown.bind( this ) );

	// Initialization
	this.$head.addClass( 'oo-ui-window-head' );
	this.$body.addClass( 'oo-ui-window-body' );
	this.$foot.addClass( 'oo-ui-window-foot' );
	this.$content.append( this.$head, this.$body, this.$foot );

	return this;
};

/**
 * Open window.
 *
 * This is a wrapper around calling {@link OO.ui.WindowManager#openWindow} on the window manager.
 * To do something each time the window opens, use #getSetupProcess or #getReadyProcess.
 *
 * @param {Object} [data] Window opening data
 * @return {jQuery.Promise} Promise resolved when window is opened; when the promise is resolved the
 *   first argument will be a promise which will be resolved when the window begins closing
 * @throws {Error} If not attached to a manager
 */
OO.ui.Window.prototype.open = function ( data ) {
	if ( !this.manager ) {
		throw new Error( 'Cannot open window, must be attached to a manager' );
	}

	return this.manager.openWindow( this, data );
};

/**
 * Close window.
 *
 * This is a wrapper around calling OO.ui.WindowManager#closeWindow on the window manager.
 * To do something each time the window closes, use #getHoldProcess or #getTeardownProcess.
 *
 * @param {Object} [data] Window closing data
 * @return {jQuery.Promise} Promise resolved when window is closed
 * @throws {Error} If not attached to a manager
 */
OO.ui.Window.prototype.close = function ( data ) {
	if ( !this.manager ) {
		throw new Error( 'Cannot close window, must be attached to a manager' );
	}

	return this.manager.closeWindow( this, data );
};

/**
 * Setup window.
 *
 * This is called by OO.ui.WindowManager during window opening, and should not be called directly
 * by other systems.
 *
 * @param {Object} [data] Window opening data
 * @return {jQuery.Promise} Promise resolved when window is setup
 */
OO.ui.Window.prototype.setup = function ( data ) {
	var win = this,
		deferred = $.Deferred();

	this.toggle( true );

	this.getSetupProcess( data ).execute().done( function () {
		// Force redraw by asking the browser to measure the elements' widths
		win.$element.addClass( 'oo-ui-window-active oo-ui-window-setup' ).width();
		win.$content.addClass( 'oo-ui-window-content-setup' ).width();
		deferred.resolve();
	} );

	return deferred.promise();
};

/**
 * Ready window.
 *
 * This is called by OO.ui.WindowManager during window opening, and should not be called directly
 * by other systems.
 *
 * @param {Object} [data] Window opening data
 * @return {jQuery.Promise} Promise resolved when window is ready
 */
OO.ui.Window.prototype.ready = function ( data ) {
	var win = this,
		deferred = $.Deferred();

	this.$content.focus();
	this.getReadyProcess( data ).execute().done( function () {
		// Force redraw by asking the browser to measure the elements' widths
		win.$element.addClass( 'oo-ui-window-ready' ).width();
		win.$content.addClass( 'oo-ui-window-content-ready' ).width();
		deferred.resolve();
	} );

	return deferred.promise();
};

/**
 * Hold window.
 *
 * This is called by OO.ui.WindowManager during window closing, and should not be called directly
 * by other systems.
 *
 * @param {Object} [data] Window closing data
 * @return {jQuery.Promise} Promise resolved when window is held
 */
OO.ui.Window.prototype.hold = function ( data ) {
	var win = this,
		deferred = $.Deferred();

	this.getHoldProcess( data ).execute().done( function () {
		// Get the focused element within the window's content
		var $focus = win.$content.find( OO.ui.Element.static.getDocument( win.$content ).activeElement );

		// Blur the focused element
		if ( $focus.length ) {
			$focus[ 0 ].blur();
		}

		// Force redraw by asking the browser to measure the elements' widths
		win.$element.removeClass( 'oo-ui-window-ready' ).width();
		win.$content.removeClass( 'oo-ui-window-content-ready' ).width();
		deferred.resolve();
	} );

	return deferred.promise();
};

/**
 * Teardown window.
 *
 * This is called by OO.ui.WindowManager during window closing, and should not be called directly
 * by other systems.
 *
 * @param {Object} [data] Window closing data
 * @return {jQuery.Promise} Promise resolved when window is torn down
 */
OO.ui.Window.prototype.teardown = function ( data ) {
	var win = this;

	return this.getTeardownProcess( data ).execute()
		.done( function () {
			// Force redraw by asking the browser to measure the elements' widths
			win.$element.removeClass( 'oo-ui-window-active oo-ui-window-setup' ).width();
			win.$content.removeClass( 'oo-ui-window-content-setup' ).width();
			win.toggle( false );
		} );
};

/**
 * The Dialog class serves as the base class for the other types of dialogs.
 * Unless extended to include controls, the rendered dialog box is a simple window
 * that users can close by hitting the ‘Esc’ key. Dialog windows are used with OO.ui.WindowManager,
 * which opens, closes, and controls the presentation of the window. See the
 * [OOjs UI documentation on MediaWiki] [1] for more information.
 *
 *     @example
 *     // A simple dialog window.
 *     function MyDialog( config ) {
 *         MyDialog.super.call( this, config );
 *     }
 *     OO.inheritClass( MyDialog, OO.ui.Dialog );
 *     MyDialog.prototype.initialize = function () {
 *         MyDialog.super.prototype.initialize.call( this );
 *         this.content = new OO.ui.PanelLayout( { padded: true, expanded: false } );
 *         this.content.$element.append( '<p>A simple dialog window. Press \'Esc\' to close.</p>' );
 *         this.$body.append( this.content.$element );
 *     };
 *     MyDialog.prototype.getBodyHeight = function () {
 *         return this.content.$element.outerHeight( true );
 *     };
 *     var myDialog = new MyDialog( {
 *         size: 'medium'
 *     } );
 *     // Create and append a window manager, which opens and closes the window.
 *     var windowManager = new OO.ui.WindowManager();
 *     $( 'body' ).append( windowManager.$element );
 *     windowManager.addWindows( [ myDialog ] );
 *     // Open the window!
 *     windowManager.openWindow( myDialog );
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Windows/Dialogs
 *
 * @abstract
 * @class
 * @extends OO.ui.Window
 * @mixins OO.ui.PendingElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
OO.ui.Dialog = function OoUiDialog( config ) {
	// Parent constructor
	OO.ui.Dialog.super.call( this, config );

	// Mixin constructors
	OO.ui.PendingElement.call( this );

	// Properties
	this.actions = new OO.ui.ActionSet();
	this.attachedActions = [];
	this.currentAction = null;
	this.onDocumentKeyDownHandler = this.onDocumentKeyDown.bind( this );

	// Events
	this.actions.connect( this, {
		click: 'onActionClick',
		resize: 'onActionResize',
		change: 'onActionsChange'
	} );

	// Initialization
	this.$element
		.addClass( 'oo-ui-dialog' )
		.attr( 'role', 'dialog' );
};

/* Setup */

OO.inheritClass( OO.ui.Dialog, OO.ui.Window );
OO.mixinClass( OO.ui.Dialog, OO.ui.PendingElement );

/* Static Properties */

/**
 * Symbolic name of dialog.
 *
 * @abstract
 * @static
 * @inheritable
 * @property {string}
 */
OO.ui.Dialog.static.name = '';

/**
 * Dialog title.
 *
 * @abstract
 * @static
 * @inheritable
 * @property {jQuery|string|Function} Label nodes, text or a function that returns nodes or text
 */
OO.ui.Dialog.static.title = '';

/**
 * List of OO.ui.ActionWidget configuration options.
 *
 * @static
 * inheritable
 * @property {Object[]}
 */
OO.ui.Dialog.static.actions = [];

/**
 * Close dialog when the escape key is pressed.
 *
 * @static
 * @abstract
 * @inheritable
 * @property {boolean}
 */
OO.ui.Dialog.static.escapable = true;

/* Methods */

/**
 * Handle frame document key down events.
 *
 * @param {jQuery.Event} e Key down event
 */
OO.ui.Dialog.prototype.onDocumentKeyDown = function ( e ) {
	if ( e.which === OO.ui.Keys.ESCAPE ) {
		this.close();
		e.preventDefault();
		e.stopPropagation();
	}
};

/**
 * Handle action resized events.
 *
 * @param {OO.ui.ActionWidget} action Action that was resized
 */
OO.ui.Dialog.prototype.onActionResize = function () {
	// Override in subclass
};

/**
 * Handle action click events.
 *
 * @param {OO.ui.ActionWidget} action Action that was clicked
 */
OO.ui.Dialog.prototype.onActionClick = function ( action ) {
	if ( !this.isPending() ) {
		this.executeAction( action.getAction() );
	}
};

/**
 * Handle actions change event.
 */
OO.ui.Dialog.prototype.onActionsChange = function () {
	this.detachActions();
	if ( !this.isClosing() ) {
		this.attachActions();
	}
};

/**
 * Get set of actions.
 *
 * @return {OO.ui.ActionSet}
 */
OO.ui.Dialog.prototype.getActions = function () {
	return this.actions;
};

/**
 * Get a process for taking action.
 *
 * When you override this method, you can add additional accept steps to the process the parent
 * method provides using the 'first' and 'next' methods.
 *
 * @abstract
 * @param {string} [action] Symbolic name of action
 * @return {OO.ui.Process} Action process
 */
OO.ui.Dialog.prototype.getActionProcess = function ( action ) {
	return new OO.ui.Process()
		.next( function () {
			if ( !action ) {
				// An empty action always closes the dialog without data, which should always be
				// safe and make no changes
				this.close();
			}
		}, this );
};

/**
 * @inheritdoc
 *
 * @param {Object} [data] Dialog opening data
 * @param {jQuery|string|Function|null} [data.title] Dialog title, omit to use #static-title
 * @param {Object[]} [data.actions] List of OO.ui.ActionWidget configuration options for each
 *   action item, omit to use #static-actions
 */
OO.ui.Dialog.prototype.getSetupProcess = function ( data ) {
	data = data || {};

	// Parent method
	return OO.ui.Dialog.super.prototype.getSetupProcess.call( this, data )
		.next( function () {
			var i, len,
				items = [],
				config = this.constructor.static,
				actions = data.actions !== undefined ? data.actions : config.actions;

			this.title.setLabel(
				data.title !== undefined ? data.title : this.constructor.static.title
			);
			for ( i = 0, len = actions.length; i < len; i++ ) {
				items.push(
					new OO.ui.ActionWidget( actions[ i ] )
				);
			}
			this.actions.add( items );

			if ( this.constructor.static.escapable ) {
				this.$document.on( 'keydown', this.onDocumentKeyDownHandler );
			}
		}, this );
};

/**
 * @inheritdoc
 */
OO.ui.Dialog.prototype.getTeardownProcess = function ( data ) {
	// Parent method
	return OO.ui.Dialog.super.prototype.getTeardownProcess.call( this, data )
		.first( function () {
			if ( this.constructor.static.escapable ) {
				this.$document.off( 'keydown', this.onDocumentKeyDownHandler );
			}

			this.actions.clear();
			this.currentAction = null;
		}, this );
};

/**
 * @inheritdoc
 */
OO.ui.Dialog.prototype.initialize = function () {
	// Parent method
	OO.ui.Dialog.super.prototype.initialize.call( this );

	// Properties
	this.title = new OO.ui.LabelWidget();

	// Initialization
	this.$content.addClass( 'oo-ui-dialog-content' );
	this.setPendingElement( this.$head );
};

/**
 * Attach action actions.
 */
OO.ui.Dialog.prototype.attachActions = function () {
	// Remember the list of potentially attached actions
	this.attachedActions = this.actions.get();
};

/**
 * Detach action actions.
 *
 * @chainable
 */
OO.ui.Dialog.prototype.detachActions = function () {
	var i, len;

	// Detach all actions that may have been previously attached
	for ( i = 0, len = this.attachedActions.length; i < len; i++ ) {
		this.attachedActions[ i ].$element.detach();
	}
	this.attachedActions = [];
};

/**
 * Execute an action.
 *
 * @param {string} action Symbolic name of action to execute
 * @return {jQuery.Promise} Promise resolved when action completes, rejected if it fails
 */
OO.ui.Dialog.prototype.executeAction = function ( action ) {
	this.pushPending();
	this.currentAction = action;
	return this.getActionProcess( action ).execute()
		.always( this.popPending.bind( this ) );
};

/**
 * Window managers are used to open and close {@link OO.ui.Window windows} and control their presentation.
 * Managed windows are mutually exclusive. If a new window is opened while a current window is opening
 * or is opened, the current window will be closed and any ongoing {@link OO.ui.Process process} will be cancelled. Windows
 * themselves are persistent and—rather than being torn down when closed—can be repopulated with the
 * pertinent data and reused.
 *
 * Over the lifecycle of a window, the window manager makes available three promises: `opening`,
 * `opened`, and `closing`, which represent the primary stages of the cycle:
 *
 * **Opening**: the opening stage begins when the window manager’s #openWindow or a window’s
 * {@link OO.ui.Window#open open} method is used, and the window manager begins to open the window.
 *
 * - an `opening` event is emitted with an `opening` promise
 * - the #getSetupDelay method is called and the returned value is used to time a pause in execution before
 *   the window’s {@link OO.ui.Window#getSetupProcess getSetupProcess} method is called on the
 *   window and its result executed
 * - a `setup` progress notification is emitted from the `opening` promise
 * - the #getReadyDelay method is called the returned value is used to time a pause in execution before
 *   the window’s {@link OO.ui.Window#getReadyProcess getReadyProcess} method is called on the
 *   window and its result executed
 * - a `ready` progress notification is emitted from the `opening` promise
 * - the `opening` promise is resolved with an `opened` promise
 *
 * **Opened**: the window is now open.
 *
 * **Closing**: the closing stage begins when the window manager's #closeWindow or the
 * window's {@link OO.ui.Window#close close} methods is used, and the window manager begins
 * to close the window.
 *
 * - the `opened` promise is resolved with `closing` promise and a `closing` event is emitted
 * - the #getHoldDelay method is called and the returned value is used to time a pause in execution before
 *   the window's {@link OO.ui.Window#getHoldProcess getHoldProces} method is called on the
 *   window and its result executed
 * - a `hold` progress notification is emitted from the `closing` promise
 * - the #getTeardownDelay() method is called and the returned value is used to time a pause in execution before
 *   the window's {@link OO.ui.Window#getTeardownProcess getTeardownProcess} method is called on the
 *   window and its result executed
 * - a `teardown` progress notification is emitted from the `closing` promise
 * - the `closing` promise is resolved. The window is now closed
 *
 * See the [OOjs UI documentation on MediaWiki][1] for more information.
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Windows/Window_managers
 *
 * @class
 * @extends OO.ui.Element
 * @mixins OO.EventEmitter
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {OO.Factory} [factory] Window factory to use for automatic instantiation
 * @cfg {boolean} [modal=true] Prevent interaction outside the dialog
 */
OO.ui.WindowManager = function OoUiWindowManager( config ) {
	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.WindowManager.super.call( this, config );

	// Mixin constructors
	OO.EventEmitter.call( this );

	// Properties
	this.factory = config.factory;
	this.modal = config.modal === undefined || !!config.modal;
	this.windows = {};
	this.opening = null;
	this.opened = null;
	this.closing = null;
	this.preparingToOpen = null;
	this.preparingToClose = null;
	this.currentWindow = null;
	this.globalEvents = false;
	this.$ariaHidden = null;
	this.onWindowResizeTimeout = null;
	this.onWindowResizeHandler = this.onWindowResize.bind( this );
	this.afterWindowResizeHandler = this.afterWindowResize.bind( this );

	// Initialization
	this.$element
		.addClass( 'oo-ui-windowManager' )
		.toggleClass( 'oo-ui-windowManager-modal', this.modal );
};

/* Setup */

OO.inheritClass( OO.ui.WindowManager, OO.ui.Element );
OO.mixinClass( OO.ui.WindowManager, OO.EventEmitter );

/* Events */

/**
 * Window is opening.
 *
 * Fired when the window begins to be opened.
 *
 * @event opening
 * @param {OO.ui.Window} win Window that's being opened
 * @param {jQuery.Promise} opening Promise resolved when window is opened; when the promise is
 *   resolved the first argument will be a promise which will be resolved when the window begins
 *   closing, the second argument will be the opening data; progress notifications will be fired on
 *   the promise for `setup` and `ready` when those processes are completed respectively.
 * @param {Object} data Window opening data
 */

/**
 * Window is closing.
 *
 * Fired when the window begins to be closed.
 *
 * @event closing
 * @param {OO.ui.Window} win Window that's being closed
 * @param {jQuery.Promise} opening Promise resolved when window is closed; when the promise
 *   is resolved the first argument will be a the closing data; progress notifications will be fired
 *   on the promise for `hold` and `teardown` when those processes are completed respectively.
 * @param {Object} data Window closing data
 */

/**
 * Window was resized.
 *
 * @event resize
 * @param {OO.ui.Window} win Window that was resized
 */

/* Static Properties */

/**
 * Map of symbolic size names and CSS properties.
 *
 * @static
 * @inheritable
 * @property {Object}
 */
OO.ui.WindowManager.static.sizes = {
	small: {
		width: 300
	},
	medium: {
		width: 500
	},
	large: {
		width: 700
	},
	larger: {
		width: 900
	},
	full: {
		// These can be non-numeric because they are never used in calculations
		width: '100%',
		height: '100%'
	}
};

/**
 * Symbolic name of default size.
 *
 * Default size is used if the window's requested size is not recognized.
 *
 * @static
 * @inheritable
 * @property {string}
 */
OO.ui.WindowManager.static.defaultSize = 'medium';

/* Methods */

/**
 * Handle window resize events.
 *
 * @param {jQuery.Event} e Window resize event
 */
OO.ui.WindowManager.prototype.onWindowResize = function () {
	clearTimeout( this.onWindowResizeTimeout );
	this.onWindowResizeTimeout = setTimeout( this.afterWindowResizeHandler, 200 );
};

/**
 * Handle window resize events.
 *
 * @param {jQuery.Event} e Window resize event
 */
OO.ui.WindowManager.prototype.afterWindowResize = function () {
	if ( this.currentWindow ) {
		this.updateWindowSize( this.currentWindow );
	}
};

/**
 * Check if window is opening.
 *
 * @return {boolean} Window is opening
 */
OO.ui.WindowManager.prototype.isOpening = function ( win ) {
	return win === this.currentWindow && !!this.opening && this.opening.state() === 'pending';
};

/**
 * Check if window is closing.
 *
 * @return {boolean} Window is closing
 */
OO.ui.WindowManager.prototype.isClosing = function ( win ) {
	return win === this.currentWindow && !!this.closing && this.closing.state() === 'pending';
};

/**
 * Check if window is opened.
 *
 * @return {boolean} Window is opened
 */
OO.ui.WindowManager.prototype.isOpened = function ( win ) {
	return win === this.currentWindow && !!this.opened && this.opened.state() === 'pending';
};

/**
 * Check if a window is being managed.
 *
 * @param {OO.ui.Window} win Window to check
 * @return {boolean} Window is being managed
 */
OO.ui.WindowManager.prototype.hasWindow = function ( win ) {
	var name;

	for ( name in this.windows ) {
		if ( this.windows[ name ] === win ) {
			return true;
		}
	}

	return false;
};

/**
 * Get the number of milliseconds to wait between beginning opening and executing setup process.
 *
 * @param {OO.ui.Window} win Window being opened
 * @param {Object} [data] Window opening data
 * @return {number} Milliseconds to wait
 */
OO.ui.WindowManager.prototype.getSetupDelay = function () {
	return 0;
};

/**
 * Get the number of milliseconds to wait between finishing setup and executing ready process.
 *
 * @param {OO.ui.Window} win Window being opened
 * @param {Object} [data] Window opening data
 * @return {number} Milliseconds to wait
 */
OO.ui.WindowManager.prototype.getReadyDelay = function () {
	return 0;
};

/**
 * Get the number of milliseconds to wait between beginning closing and executing hold process.
 *
 * @param {OO.ui.Window} win Window being closed
 * @param {Object} [data] Window closing data
 * @return {number} Milliseconds to wait
 */
OO.ui.WindowManager.prototype.getHoldDelay = function () {
	return 0;
};

/**
 * Get the number of milliseconds to wait between finishing hold and executing teardown process.
 *
 * @param {OO.ui.Window} win Window being closed
 * @param {Object} [data] Window closing data
 * @return {number} Milliseconds to wait
 */
OO.ui.WindowManager.prototype.getTeardownDelay = function () {
	return this.modal ? 250 : 0;
};

/**
 * Get managed window by symbolic name.
 *
 * If window is not yet instantiated, it will be instantiated and added automatically.
 *
 * @param {string} name Symbolic window name
 * @return {jQuery.Promise} Promise resolved with matching window, or rejected with an OO.ui.Error
 * @throws {Error} If the symbolic name is unrecognized by the factory
 * @throws {Error} If the symbolic name unrecognized as a managed window
 */
OO.ui.WindowManager.prototype.getWindow = function ( name ) {
	var deferred = $.Deferred(),
		win = this.windows[ name ];

	if ( !( win instanceof OO.ui.Window ) ) {
		if ( this.factory ) {
			if ( !this.factory.lookup( name ) ) {
				deferred.reject( new OO.ui.Error(
					'Cannot auto-instantiate window: symbolic name is unrecognized by the factory'
				) );
			} else {
				win = this.factory.create( name );
				this.addWindows( [ win ] );
				deferred.resolve( win );
			}
		} else {
			deferred.reject( new OO.ui.Error(
				'Cannot get unmanaged window: symbolic name unrecognized as a managed window'
			) );
		}
	} else {
		deferred.resolve( win );
	}

	return deferred.promise();
};

/**
 * Get current window.
 *
 * @return {OO.ui.Window|null} Currently opening/opened/closing window
 */
OO.ui.WindowManager.prototype.getCurrentWindow = function () {
	return this.currentWindow;
};

/**
 * Open a window.
 *
 * @param {OO.ui.Window|string} win Window object or symbolic name of window to open
 * @param {Object} [data] Window opening data
 * @return {jQuery.Promise} Promise resolved when window is done opening; see {@link #event-opening}
 *   for more details about the `opening` promise
 * @fires opening
 */
OO.ui.WindowManager.prototype.openWindow = function ( win, data ) {
	var manager = this,
		opening = $.Deferred();

	// Argument handling
	if ( typeof win === 'string' ) {
		return this.getWindow( win ).then( function ( win ) {
			return manager.openWindow( win, data );
		} );
	}

	// Error handling
	if ( !this.hasWindow( win ) ) {
		opening.reject( new OO.ui.Error(
			'Cannot open window: window is not attached to manager'
		) );
	} else if ( this.preparingToOpen || this.opening || this.opened ) {
		opening.reject( new OO.ui.Error(
			'Cannot open window: another window is opening or open'
		) );
	}

	// Window opening
	if ( opening.state() !== 'rejected' ) {
		// If a window is currently closing, wait for it to complete
		this.preparingToOpen = $.when( this.closing );
		// Ensure handlers get called after preparingToOpen is set
		this.preparingToOpen.done( function () {
			if ( manager.modal ) {
				manager.toggleGlobalEvents( true );
				manager.toggleAriaIsolation( true );
			}
			manager.currentWindow = win;
			manager.opening = opening;
			manager.preparingToOpen = null;
			manager.emit( 'opening', win, opening, data );
			setTimeout( function () {
				win.setup( data ).then( function () {
					manager.updateWindowSize( win );
					manager.opening.notify( { state: 'setup' } );
					setTimeout( function () {
						win.ready( data ).then( function () {
							manager.opening.notify( { state: 'ready' } );
							manager.opening = null;
							manager.opened = $.Deferred();
							opening.resolve( manager.opened.promise(), data );
						} );
					}, manager.getReadyDelay() );
				} );
			}, manager.getSetupDelay() );
		} );
	}

	return opening.promise();
};

/**
 * Close a window.
 *
 * @param {OO.ui.Window|string} win Window object or symbolic name of window to close
 * @param {Object} [data] Window closing data
 * @return {jQuery.Promise} Promise resolved when window is done closing; see {@link #event-closing}
 *   for more details about the `closing` promise
 * @throws {Error} If no window by that name is being managed
 * @fires closing
 */
OO.ui.WindowManager.prototype.closeWindow = function ( win, data ) {
	var manager = this,
		closing = $.Deferred(),
		opened;

	// Argument handling
	if ( typeof win === 'string' ) {
		win = this.windows[ win ];
	} else if ( !this.hasWindow( win ) ) {
		win = null;
	}

	// Error handling
	if ( !win ) {
		closing.reject( new OO.ui.Error(
			'Cannot close window: window is not attached to manager'
		) );
	} else if ( win !== this.currentWindow ) {
		closing.reject( new OO.ui.Error(
			'Cannot close window: window already closed with different data'
		) );
	} else if ( this.preparingToClose || this.closing ) {
		closing.reject( new OO.ui.Error(
			'Cannot close window: window already closing with different data'
		) );
	}

	// Window closing
	if ( closing.state() !== 'rejected' ) {
		// If the window is currently opening, close it when it's done
		this.preparingToClose = $.when( this.opening );
		// Ensure handlers get called after preparingToClose is set
		this.preparingToClose.done( function () {
			manager.closing = closing;
			manager.preparingToClose = null;
			manager.emit( 'closing', win, closing, data );
			opened = manager.opened;
			manager.opened = null;
			opened.resolve( closing.promise(), data );
			setTimeout( function () {
				win.hold( data ).then( function () {
					closing.notify( { state: 'hold' } );
					setTimeout( function () {
						win.teardown( data ).then( function () {
							closing.notify( { state: 'teardown' } );
							if ( manager.modal ) {
								manager.toggleGlobalEvents( false );
								manager.toggleAriaIsolation( false );
							}
							manager.closing = null;
							manager.currentWindow = null;
							closing.resolve( data );
						} );
					}, manager.getTeardownDelay() );
				} );
			}, manager.getHoldDelay() );
		} );
	}

	return closing.promise();
};

/**
 * Add windows.
 *
 * @param {Object.<string,OO.ui.Window>|OO.ui.Window[]} windows Windows to add
 * @throws {Error} If one of the windows being added without an explicit symbolic name does not have
 *   a statically configured symbolic name
 */
OO.ui.WindowManager.prototype.addWindows = function ( windows ) {
	var i, len, win, name, list;

	if ( Array.isArray( windows ) ) {
		// Convert to map of windows by looking up symbolic names from static configuration
		list = {};
		for ( i = 0, len = windows.length; i < len; i++ ) {
			name = windows[ i ].constructor.static.name;
			if ( typeof name !== 'string' ) {
				throw new Error( 'Cannot add window' );
			}
			list[ name ] = windows[ i ];
		}
	} else if ( OO.isPlainObject( windows ) ) {
		list = windows;
	}

	// Add windows
	for ( name in list ) {
		win = list[ name ];
		this.windows[ name ] = win.toggle( false );
		this.$element.append( win.$element );
		win.setManager( this );
	}
};

/**
 * Remove windows.
 *
 * Windows will be closed before they are removed.
 *
 * @param {string[]} names Symbolic names of windows to remove
 * @return {jQuery.Promise} Promise resolved when window is closed and removed
 * @throws {Error} If windows being removed are not being managed
 */
OO.ui.WindowManager.prototype.removeWindows = function ( names ) {
	var i, len, win, name, cleanupWindow,
		manager = this,
		promises = [],
		cleanup = function ( name, win ) {
			delete manager.windows[ name ];
			win.$element.detach();
		};

	for ( i = 0, len = names.length; i < len; i++ ) {
		name = names[ i ];
		win = this.windows[ name ];
		if ( !win ) {
			throw new Error( 'Cannot remove window' );
		}
		cleanupWindow = cleanup.bind( null, name, win );
		promises.push( this.closeWindow( name ).then( cleanupWindow, cleanupWindow ) );
	}

	return $.when.apply( $, promises );
};

/**
 * Remove all windows.
 *
 * Windows will be closed before they are removed.
 *
 * @return {jQuery.Promise} Promise resolved when all windows are closed and removed
 */
OO.ui.WindowManager.prototype.clearWindows = function () {
	return this.removeWindows( Object.keys( this.windows ) );
};

/**
 * Set dialog size.
 *
 * Fullscreen mode will be used if the dialog is too wide to fit in the screen.
 *
 * @chainable
 */
OO.ui.WindowManager.prototype.updateWindowSize = function ( win ) {
	// Bypass for non-current, and thus invisible, windows
	if ( win !== this.currentWindow ) {
		return;
	}

	var viewport = OO.ui.Element.static.getDimensions( win.getElementWindow() ),
		sizes = this.constructor.static.sizes,
		size = win.getSize();

	if ( !sizes[ size ] ) {
		size = this.constructor.static.defaultSize;
	}
	if ( size !== 'full' && viewport.rect.right - viewport.rect.left < sizes[ size ].width ) {
		size = 'full';
	}

	this.$element.toggleClass( 'oo-ui-windowManager-fullscreen', size === 'full' );
	this.$element.toggleClass( 'oo-ui-windowManager-floating', size !== 'full' );
	win.setDimensions( sizes[ size ] );

	this.emit( 'resize', win );

	return this;
};

/**
 * Bind or unbind global events for scrolling.
 *
 * @param {boolean} [on] Bind global events
 * @chainable
 */
OO.ui.WindowManager.prototype.toggleGlobalEvents = function ( on ) {
	on = on === undefined ? !!this.globalEvents : !!on;

	var $body = $( this.getElementDocument().body ),
		// We could have multiple window managers open to only modify
		// the body class at the bottom of the stack
		stackDepth = $body.data( 'windowManagerGlobalEvents' ) || 0 ;

	if ( on ) {
		if ( !this.globalEvents ) {
			$( this.getElementWindow() ).on( {
				// Start listening for top-level window dimension changes
				'orientationchange resize': this.onWindowResizeHandler
			} );
			if ( stackDepth === 0 ) {
				$body.css( 'overflow', 'hidden' );
			}
			stackDepth++;
			this.globalEvents = true;
		}
	} else if ( this.globalEvents ) {
		$( this.getElementWindow() ).off( {
			// Stop listening for top-level window dimension changes
			'orientationchange resize': this.onWindowResizeHandler
		} );
		stackDepth--;
		if ( stackDepth === 0 ) {
			$( this.getElementDocument().body ).css( 'overflow', '' );
		}
		this.globalEvents = false;
	}
	$body.data( 'windowManagerGlobalEvents', stackDepth );

	return this;
};

/**
 * Toggle screen reader visibility of content other than the window manager.
 *
 * @param {boolean} [isolate] Make only the window manager visible to screen readers
 * @chainable
 */
OO.ui.WindowManager.prototype.toggleAriaIsolation = function ( isolate ) {
	isolate = isolate === undefined ? !this.$ariaHidden : !!isolate;

	if ( isolate ) {
		if ( !this.$ariaHidden ) {
			// Hide everything other than the window manager from screen readers
			this.$ariaHidden = $( 'body' )
				.children()
				.not( this.$element.parentsUntil( 'body' ).last() )
				.attr( 'aria-hidden', '' );
		}
	} else if ( this.$ariaHidden ) {
		// Restore screen reader visibility
		this.$ariaHidden.removeAttr( 'aria-hidden' );
		this.$ariaHidden = null;
	}

	return this;
};

/**
 * Destroy window manager.
 */
OO.ui.WindowManager.prototype.destroy = function () {
	this.toggleGlobalEvents( false );
	this.toggleAriaIsolation( false );
	this.clearWindows();
	this.$element.remove();
};

/**
 * @class
 *
 * @constructor
 * @param {string|jQuery} message Description of error
 * @param {Object} [config] Configuration options
 * @cfg {boolean} [recoverable=true] Error is recoverable
 * @cfg {boolean} [warning=false] Whether this error is a warning or not.
 */
OO.ui.Error = function OoUiError( message, config ) {
	// Allow passing positional parameters inside the config object
	if ( OO.isPlainObject( message ) && config === undefined ) {
		config = message;
		message = config.message;
	}

	// Configuration initialization
	config = config || {};

	// Properties
	this.message = message instanceof jQuery ? message : String( message );
	this.recoverable = config.recoverable === undefined || !!config.recoverable;
	this.warning = !!config.warning;
};

/* Setup */

OO.initClass( OO.ui.Error );

/* Methods */

/**
 * Check if error can be recovered from.
 *
 * @return {boolean} Error is recoverable
 */
OO.ui.Error.prototype.isRecoverable = function () {
	return this.recoverable;
};

/**
 * Check if the error is a warning
 *
 * @return {boolean} Error is warning
 */
OO.ui.Error.prototype.isWarning = function () {
	return this.warning;
};

/**
 * Get error message as DOM nodes.
 *
 * @return {jQuery} Error message in DOM nodes
 */
OO.ui.Error.prototype.getMessage = function () {
	return this.message instanceof jQuery ?
		this.message.clone() :
		$( '<div>' ).text( this.message ).contents();
};

/**
 * Get error message as text.
 *
 * @return {string} Error message
 */
OO.ui.Error.prototype.getMessageText = function () {
	return this.message instanceof jQuery ? this.message.text() : this.message;
};

/**
 * Wraps an HTML snippet for use with configuration values which default
 * to strings.  This bypasses the default html-escaping done to string
 * values.
 *
 * @class
 *
 * @constructor
 * @param {string} [content] HTML content
 */
OO.ui.HtmlSnippet = function OoUiHtmlSnippet( content ) {
	// Properties
	this.content = content;
};

/* Setup */

OO.initClass( OO.ui.HtmlSnippet );

/* Methods */

/**
 * Render into HTML.
 *
 * @return {string} Unchanged HTML snippet.
 */
OO.ui.HtmlSnippet.prototype.toString = function () {
	return this.content;
};

/**
 * A list of functions, called in sequence.
 *
 * If a function added to a process returns boolean false the process will stop; if it returns an
 * object with a `promise` method the process will use the promise to either continue to the next
 * step when the promise is resolved or stop when the promise is rejected.
 *
 * @class
 *
 * @constructor
 * @param {number|jQuery.Promise|Function} step Time to wait, promise to wait for or function to
 *   call, see #createStep for more information
 * @param {Object} [context=null] Context to call the step function in, ignored if step is a number
 *   or a promise
 * @return {Object} Step object, with `callback` and `context` properties
 */
OO.ui.Process = function ( step, context ) {
	// Properties
	this.steps = [];

	// Initialization
	if ( step !== undefined ) {
		this.next( step, context );
	}
};

/* Setup */

OO.initClass( OO.ui.Process );

/* Methods */

/**
 * Start the process.
 *
 * @return {jQuery.Promise} Promise that is resolved when all steps have completed or rejected when
 *   any of the steps return boolean false or a promise which gets rejected; upon stopping the
 *   process, the remaining steps will not be taken
 */
OO.ui.Process.prototype.execute = function () {
	var i, len, promise;

	/**
	 * Continue execution.
	 *
	 * @ignore
	 * @param {Array} step A function and the context it should be called in
	 * @return {Function} Function that continues the process
	 */
	function proceed( step ) {
		return function () {
			// Execute step in the correct context
			var deferred,
				result = step.callback.call( step.context );

			if ( result === false ) {
				// Use rejected promise for boolean false results
				return $.Deferred().reject( [] ).promise();
			}
			if ( typeof result === 'number' ) {
				if ( result < 0 ) {
					throw new Error( 'Cannot go back in time: flux capacitor is out of service' );
				}
				// Use a delayed promise for numbers, expecting them to be in milliseconds
				deferred = $.Deferred();
				setTimeout( deferred.resolve, result );
				return deferred.promise();
			}
			if ( result instanceof OO.ui.Error ) {
				// Use rejected promise for error
				return $.Deferred().reject( [ result ] ).promise();
			}
			if ( Array.isArray( result ) && result.length && result[ 0 ] instanceof OO.ui.Error ) {
				// Use rejected promise for list of errors
				return $.Deferred().reject( result ).promise();
			}
			// Duck-type the object to see if it can produce a promise
			if ( result && $.isFunction( result.promise ) ) {
				// Use a promise generated from the result
				return result.promise();
			}
			// Use resolved promise for other results
			return $.Deferred().resolve().promise();
		};
	}

	if ( this.steps.length ) {
		// Generate a chain reaction of promises
		promise = proceed( this.steps[ 0 ] )();
		for ( i = 1, len = this.steps.length; i < len; i++ ) {
			promise = promise.then( proceed( this.steps[ i ] ) );
		}
	} else {
		promise = $.Deferred().resolve().promise();
	}

	return promise;
};

/**
 * Create a process step.
 *
 * @private
 * @param {number|jQuery.Promise|Function} step
 *
 * - Number of milliseconds to wait; or
 * - Promise to wait to be resolved; or
 * - Function to execute
 *   - If it returns boolean false the process will stop
 *   - If it returns an object with a `promise` method the process will use the promise to either
 *     continue to the next step when the promise is resolved or stop when the promise is rejected
 *   - If it returns a number, the process will wait for that number of milliseconds before
 *     proceeding
 * @param {Object} [context=null] Context to call the step function in, ignored if step is a number
 *   or a promise
 * @return {Object} Step object, with `callback` and `context` properties
 */
OO.ui.Process.prototype.createStep = function ( step, context ) {
	if ( typeof step === 'number' || $.isFunction( step.promise ) ) {
		return {
			callback: function () {
				return step;
			},
			context: null
		};
	}
	if ( $.isFunction( step ) ) {
		return {
			callback: step,
			context: context
		};
	}
	throw new Error( 'Cannot create process step: number, promise or function expected' );
};

/**
 * Add step to the beginning of the process.
 *
 * @inheritdoc #createStep
 * @return {OO.ui.Process} this
 * @chainable
 */
OO.ui.Process.prototype.first = function ( step, context ) {
	this.steps.unshift( this.createStep( step, context ) );
	return this;
};

/**
 * Add step to the end of the process.
 *
 * @inheritdoc #createStep
 * @return {OO.ui.Process} this
 * @chainable
 */
OO.ui.Process.prototype.next = function ( step, context ) {
	this.steps.push( this.createStep( step, context ) );
	return this;
};

/**
 * Factory for tools.
 *
 * @class
 * @extends OO.Factory
 * @constructor
 */
OO.ui.ToolFactory = function OoUiToolFactory() {
	// Parent constructor
	OO.ui.ToolFactory.super.call( this );
};

/* Setup */

OO.inheritClass( OO.ui.ToolFactory, OO.Factory );

/* Methods */

/**
 * Get tools from the factory
 *
 * @param {Array} include Included tools
 * @param {Array} exclude Excluded tools
 * @param {Array} promote Promoted tools
 * @param {Array} demote Demoted tools
 * @return {string[]} List of tools
 */
OO.ui.ToolFactory.prototype.getTools = function ( include, exclude, promote, demote ) {
	var i, len, included, promoted, demoted,
		auto = [],
		used = {};

	// Collect included and not excluded tools
	included = OO.simpleArrayDifference( this.extract( include ), this.extract( exclude ) );

	// Promotion
	promoted = this.extract( promote, used );
	demoted = this.extract( demote, used );

	// Auto
	for ( i = 0, len = included.length; i < len; i++ ) {
		if ( !used[ included[ i ] ] ) {
			auto.push( included[ i ] );
		}
	}

	return promoted.concat( auto ).concat( demoted );
};

/**
 * Get a flat list of names from a list of names or groups.
 *
 * Tools can be specified in the following ways:
 *
 * - A specific tool: `{ name: 'tool-name' }` or `'tool-name'`
 * - All tools in a group: `{ group: 'group-name' }`
 * - All tools: `'*'`
 *
 * @private
 * @param {Array|string} collection List of tools
 * @param {Object} [used] Object with names that should be skipped as properties; extracted
 *  names will be added as properties
 * @return {string[]} List of extracted names
 */
OO.ui.ToolFactory.prototype.extract = function ( collection, used ) {
	var i, len, item, name, tool,
		names = [];

	if ( collection === '*' ) {
		for ( name in this.registry ) {
			tool = this.registry[ name ];
			if (
				// Only add tools by group name when auto-add is enabled
				tool.static.autoAddToCatchall &&
				// Exclude already used tools
				( !used || !used[ name ] )
			) {
				names.push( name );
				if ( used ) {
					used[ name ] = true;
				}
			}
		}
	} else if ( Array.isArray( collection ) ) {
		for ( i = 0, len = collection.length; i < len; i++ ) {
			item = collection[ i ];
			// Allow plain strings as shorthand for named tools
			if ( typeof item === 'string' ) {
				item = { name: item };
			}
			if ( OO.isPlainObject( item ) ) {
				if ( item.group ) {
					for ( name in this.registry ) {
						tool = this.registry[ name ];
						if (
							// Include tools with matching group
							tool.static.group === item.group &&
							// Only add tools by group name when auto-add is enabled
							tool.static.autoAddToGroup &&
							// Exclude already used tools
							( !used || !used[ name ] )
						) {
							names.push( name );
							if ( used ) {
								used[ name ] = true;
							}
						}
					}
				// Include tools with matching name and exclude already used tools
				} else if ( item.name && ( !used || !used[ item.name ] ) ) {
					names.push( item.name );
					if ( used ) {
						used[ item.name ] = true;
					}
				}
			}
		}
	}
	return names;
};

/**
 * Factory for tool groups.
 *
 * @class
 * @extends OO.Factory
 * @constructor
 */
OO.ui.ToolGroupFactory = function OoUiToolGroupFactory() {
	// Parent constructor
	OO.Factory.call( this );

	var i, l,
		defaultClasses = this.constructor.static.getDefaultClasses();

	// Register default toolgroups
	for ( i = 0, l = defaultClasses.length; i < l; i++ ) {
		this.register( defaultClasses[ i ] );
	}
};

/* Setup */

OO.inheritClass( OO.ui.ToolGroupFactory, OO.Factory );

/* Static Methods */

/**
 * Get a default set of classes to be registered on construction
 *
 * @return {Function[]} Default classes
 */
OO.ui.ToolGroupFactory.static.getDefaultClasses = function () {
	return [
		OO.ui.BarToolGroup,
		OO.ui.ListToolGroup,
		OO.ui.MenuToolGroup
	];
};

/**
 * Theme logic.
 *
 * @abstract
 * @class
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
OO.ui.Theme = function OoUiTheme( config ) {
	// Configuration initialization
	config = config || {};
};

/* Setup */

OO.initClass( OO.ui.Theme );

/* Methods */

/**
 * Get a list of classes to be applied to a widget.
 *
 * The 'on' and 'off' lists combined MUST contain keys for all classes the theme adds or removes,
 * otherwise state transitions will not work properly.
 *
 * @param {OO.ui.Element} element Element for which to get classes
 * @return {Object.<string,string[]>} Categorized class names with `on` and `off` lists
 */
OO.ui.Theme.prototype.getElementClasses = function ( /* element */ ) {
	return { on: [], off: [] };
};

/**
 * Update CSS classes provided by the theme.
 *
 * For elements with theme logic hooks, this should be called any time there's a state change.
 *
 * @param {OO.ui.Element} element Element for which to update classes
 * @return {Object.<string,string[]>} Categorized class names with `on` and `off` lists
 */
OO.ui.Theme.prototype.updateElementClasses = function ( element ) {
	var classes = this.getElementClasses( element );

	element.$element
		.removeClass( classes.off.join( ' ' ) )
		.addClass( classes.on.join( ' ' ) );
};

/**
 * The TabIndexedElement class is an attribute mixin used to add additional functionality to an
 * element created by another class. The mixin provides a ‘tabIndex’ property, which specifies the
 * order in which users will navigate through the focusable elements via the "tab" key.
 *
 *     @example
 *     // TabIndexedElement is mixed into the ButtonWidget class
 *     // to provide a tabIndex property.
 *     var button1 = new OO.ui.ButtonWidget( {
 *         label : 'fourth',
 *         tabIndex : 4
 *     } );
 *     var button2 = new OO.ui.ButtonWidget( {
 *         label : 'second',
 *         tabIndex : 2
 *     } );
 *     var button3 = new OO.ui.ButtonWidget( {
 *         label : 'third',
 *         tabIndex : 3
 *     } );
 *     var button4 = new OO.ui.ButtonWidget( {
 *         label : 'first',
 *         tabIndex : 1
 *     } );
 *     $( 'body' ).append( button1.$element, button2.$element, button3.$element, button4.$element );
 *
 * @abstract
 * @class
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {jQuery} [$tabIndexed] tabIndexed node, assigned to #$tabIndexed, omit to use #$element
 * @cfg {number|null} [tabIndex=0] Tab index value. Use 0 to use default ordering, use -1 to
 *  prevent tab focusing, use null to suppress the `tabindex` attribute.
 */
OO.ui.TabIndexedElement = function OoUiTabIndexedElement( config ) {
	// Configuration initialization
	config = $.extend( { tabIndex: 0 }, config );

	// Properties
	this.$tabIndexed = null;
	this.tabIndex = null;

	// Events
	this.connect( this, { disable: 'onDisable' } );

	// Initialization
	this.setTabIndex( config.tabIndex );
	this.setTabIndexedElement( config.$tabIndexed || this.$element );
};

/* Setup */

OO.initClass( OO.ui.TabIndexedElement );

/* Methods */

/**
 * Set the element with `tabindex` attribute.
 *
 * If an element is already set, it will be cleaned up before setting up the new element.
 *
 * @param {jQuery} $tabIndexed Element to set tab index on
 * @chainable
 */
OO.ui.TabIndexedElement.prototype.setTabIndexedElement = function ( $tabIndexed ) {
	var tabIndex = this.tabIndex;
	// Remove attributes from old $tabIndexed
	this.setTabIndex( null );
	// Force update of new $tabIndexed
	this.$tabIndexed = $tabIndexed;
	this.tabIndex = tabIndex;
	return this.updateTabIndex();
};

/**
 * Set tab index value.
 *
 * @param {number|null} tabIndex Tab index value or null for no tab index
 * @chainable
 */
OO.ui.TabIndexedElement.prototype.setTabIndex = function ( tabIndex ) {
	tabIndex = typeof tabIndex === 'number' ? tabIndex : null;

	if ( this.tabIndex !== tabIndex ) {
		this.tabIndex = tabIndex;
		this.updateTabIndex();
	}

	return this;
};

/**
 * Update the `tabindex` attribute, in case of changes to tab index or
 * disabled state.
 *
 * @chainable
 */
OO.ui.TabIndexedElement.prototype.updateTabIndex = function () {
	if ( this.$tabIndexed ) {
		if ( this.tabIndex !== null ) {
			// Do not index over disabled elements
			this.$tabIndexed.attr( {
				tabindex: this.isDisabled() ? -1 : this.tabIndex,
				// ChromeVox and NVDA do not seem to inherit this from parent elements
				'aria-disabled': this.isDisabled().toString()
			} );
		} else {
			this.$tabIndexed.removeAttr( 'tabindex aria-disabled' );
		}
	}
	return this;
};

/**
 * Handle disable events.
 *
 * @private
 * @param {boolean} disabled Element is disabled
 */
OO.ui.TabIndexedElement.prototype.onDisable = function () {
	this.updateTabIndex();
};

/**
 * Get tab index value.
 *
 * @return {number|null} Tab index value
 */
OO.ui.TabIndexedElement.prototype.getTabIndex = function () {
	return this.tabIndex;
};

/**
 * ButtonElement is often mixed into other classes to generate a button, which is a clickable
 * interface element that can be configured with access keys for accessibility.
 * See the [OOjs UI documentation on MediaWiki] [1] for examples.
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Buttons_and_Switches#Buttons
 * @abstract
 * @class
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {jQuery} [$button] Button node, assigned to #$button, omit to use a generated `<a>`
 * @cfg {boolean} [framed=true] Render button with a frame
 * @cfg {string} [accessKey] Button's access key
 */
OO.ui.ButtonElement = function OoUiButtonElement( config ) {
	// Configuration initialization
	config = config || {};

	// Properties
	this.$button = config.$button || $( '<a>' );
	this.framed = null;
	this.accessKey = null;
	this.active = false;
	this.onMouseUpHandler = this.onMouseUp.bind( this );
	this.onMouseDownHandler = this.onMouseDown.bind( this );
	this.onKeyDownHandler = this.onKeyDown.bind( this );
	this.onKeyUpHandler = this.onKeyUp.bind( this );
	this.onClickHandler = this.onClick.bind( this );
	this.onKeyPressHandler = this.onKeyPress.bind( this );

	// Initialization
	this.$element.addClass( 'oo-ui-buttonElement' );
	this.toggleFramed( config.framed === undefined || config.framed );
	this.setAccessKey( config.accessKey );
	this.setButtonElement( this.$button );
};

/* Setup */

OO.initClass( OO.ui.ButtonElement );

/* Static Properties */

/**
 * Cancel mouse down events.
 *
 * @static
 * @inheritable
 * @property {boolean}
 */
OO.ui.ButtonElement.static.cancelButtonMouseDownEvents = true;

/* Events */

/**
 * @event click
 */

/* Methods */

/**
 * Set the button element.
 *
 * If an element is already set, it will be cleaned up before setting up the new element.
 *
 * @param {jQuery} $button Element to use as button
 */
OO.ui.ButtonElement.prototype.setButtonElement = function ( $button ) {
	if ( this.$button ) {
		this.$button
			.removeClass( 'oo-ui-buttonElement-button' )
			.removeAttr( 'role accesskey' )
			.off( {
				mousedown: this.onMouseDownHandler,
				keydown: this.onKeyDownHandler,
				click: this.onClickHandler,
				keypress: this.onKeyPressHandler
			} );
	}

	this.$button = $button
		.addClass( 'oo-ui-buttonElement-button' )
		.attr( { role: 'button', accesskey: this.accessKey } )
		.on( {
			mousedown: this.onMouseDownHandler,
			keydown: this.onKeyDownHandler,
			click: this.onClickHandler,
			keypress: this.onKeyPressHandler
		} );
};

/**
 * Handles mouse down events.
 *
 * @protected
 * @param {jQuery.Event} e Mouse down event
 */
OO.ui.ButtonElement.prototype.onMouseDown = function ( e ) {
	if ( this.isDisabled() || e.which !== 1 ) {
		return;
	}
	this.$element.addClass( 'oo-ui-buttonElement-pressed' );
	// Run the mouseup handler no matter where the mouse is when the button is let go, so we can
	// reliably remove the pressed class
	this.getElementDocument().addEventListener( 'mouseup', this.onMouseUpHandler, true );
	// Prevent change of focus unless specifically configured otherwise
	if ( this.constructor.static.cancelButtonMouseDownEvents ) {
		return false;
	}
};

/**
 * Handles mouse up events.
 *
 * @protected
 * @param {jQuery.Event} e Mouse up event
 */
OO.ui.ButtonElement.prototype.onMouseUp = function ( e ) {
	if ( this.isDisabled() || e.which !== 1 ) {
		return;
	}
	this.$element.removeClass( 'oo-ui-buttonElement-pressed' );
	// Stop listening for mouseup, since we only needed this once
	this.getElementDocument().removeEventListener( 'mouseup', this.onMouseUpHandler, true );
};

/**
 * Handles mouse click events.
 *
 * @protected
 * @param {jQuery.Event} e Mouse click event
 * @fires click
 */
OO.ui.ButtonElement.prototype.onClick = function ( e ) {
	if ( !this.isDisabled() && e.which === 1 ) {
		this.emit( 'click' );
	}
	return false;
};

/**
 * Handles key down events.
 *
 * @protected
 * @param {jQuery.Event} e Key down event
 */
OO.ui.ButtonElement.prototype.onKeyDown = function ( e ) {
	if ( this.isDisabled() || ( e.which !== OO.ui.Keys.SPACE && e.which !== OO.ui.Keys.ENTER ) ) {
		return;
	}
	this.$element.addClass( 'oo-ui-buttonElement-pressed' );
	// Run the keyup handler no matter where the key is when the button is let go, so we can
	// reliably remove the pressed class
	this.getElementDocument().addEventListener( 'keyup', this.onKeyUpHandler, true );
};

/**
 * Handles key up events.
 *
 * @protected
 * @param {jQuery.Event} e Key up event
 */
OO.ui.ButtonElement.prototype.onKeyUp = function ( e ) {
	if ( this.isDisabled() || ( e.which !== OO.ui.Keys.SPACE && e.which !== OO.ui.Keys.ENTER ) ) {
		return;
	}
	this.$element.removeClass( 'oo-ui-buttonElement-pressed' );
	// Stop listening for keyup, since we only needed this once
	this.getElementDocument().removeEventListener( 'keyup', this.onKeyUpHandler, true );
};

/**
 * Handles key press events.
 *
 * @protected
 * @param {jQuery.Event} e Key press event
 * @fires click
 */
OO.ui.ButtonElement.prototype.onKeyPress = function ( e ) {
	if ( !this.isDisabled() && ( e.which === OO.ui.Keys.SPACE || e.which === OO.ui.Keys.ENTER ) ) {
		this.emit( 'click' );
	}
	return false;
};

/**
 * Check if button has a frame.
 *
 * @return {boolean} Button is framed
 */
OO.ui.ButtonElement.prototype.isFramed = function () {
	return this.framed;
};

/**
 * Toggle frame.
 *
 * @param {boolean} [framed] Make button framed, omit to toggle
 * @chainable
 */
OO.ui.ButtonElement.prototype.toggleFramed = function ( framed ) {
	framed = framed === undefined ? !this.framed : !!framed;
	if ( framed !== this.framed ) {
		this.framed = framed;
		this.$element
			.toggleClass( 'oo-ui-buttonElement-frameless', !framed )
			.toggleClass( 'oo-ui-buttonElement-framed', framed );
		this.updateThemeClasses();
	}

	return this;
};

/**
 * Set access key.
 *
 * @param {string} accessKey Button's access key, use empty string to remove
 * @chainable
 */
OO.ui.ButtonElement.prototype.setAccessKey = function ( accessKey ) {
	accessKey = typeof accessKey === 'string' && accessKey.length ? accessKey : null;

	if ( this.accessKey !== accessKey ) {
		if ( this.$button ) {
			if ( accessKey !== null ) {
				this.$button.attr( 'accesskey', accessKey );
			} else {
				this.$button.removeAttr( 'accesskey' );
			}
		}
		this.accessKey = accessKey;
	}

	return this;
};

/**
 * Set active state.
 *
 * @param {boolean} [value] Make button active
 * @chainable
 */
OO.ui.ButtonElement.prototype.setActive = function ( value ) {
	this.$element.toggleClass( 'oo-ui-buttonElement-active', !!value );
	return this;
};

/**
 * Any OOjs UI widget that contains other widgets (such as {@link OO.ui.ButtonWidget buttons} or
 * {@link OO.ui.OptionWidget options}) mixes in GroupElement. Adding, removing, and clearing
 * items from the group is done through the interface the class provides.
 * For more information, please see the [OOjs UI documentation on MediaWiki] [1].
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Elements/Groups
 *
 * @abstract
 * @class
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {jQuery} [$group] Container node, assigned to #$group, omit to use a generated `<div>`
 */
OO.ui.GroupElement = function OoUiGroupElement( config ) {
	// Configuration initialization
	config = config || {};

	// Properties
	this.$group = null;
	this.items = [];
	this.aggregateItemEvents = {};

	// Initialization
	this.setGroupElement( config.$group || $( '<div>' ) );
};

/* Methods */

/**
 * Set the group element.
 *
 * If an element is already set, items will be moved to the new element.
 *
 * @param {jQuery} $group Element to use as group
 */
OO.ui.GroupElement.prototype.setGroupElement = function ( $group ) {
	var i, len;

	this.$group = $group;
	for ( i = 0, len = this.items.length; i < len; i++ ) {
		this.$group.append( this.items[ i ].$element );
	}
};

/**
 * Check if there are no items.
 *
 * @return {boolean} Group is empty
 */
OO.ui.GroupElement.prototype.isEmpty = function () {
	return !this.items.length;
};

/**
 * Get items.
 *
 * @return {OO.ui.Element[]} Items
 */
OO.ui.GroupElement.prototype.getItems = function () {
	return this.items.slice( 0 );
};

/**
 * Get an item by its data.
 *
 * Data is compared by a hash of its value. Only the first item with matching data will be returned.
 *
 * @param {Object} data Item data to search for
 * @return {OO.ui.Element|null} Item with equivalent data, `null` if none exists
 */
OO.ui.GroupElement.prototype.getItemFromData = function ( data ) {
	var i, len, item,
		hash = OO.getHash( data );

	for ( i = 0, len = this.items.length; i < len; i++ ) {
		item = this.items[ i ];
		if ( hash === OO.getHash( item.getData() ) ) {
			return item;
		}
	}

	return null;
};

/**
 * Get items by their data.
 *
 * Data is compared by a hash of its value. All items with matching data will be returned.
 *
 * @param {Object} data Item data to search for
 * @return {OO.ui.Element[]} Items with equivalent data
 */
OO.ui.GroupElement.prototype.getItemsFromData = function ( data ) {
	var i, len, item,
		hash = OO.getHash( data ),
		items = [];

	for ( i = 0, len = this.items.length; i < len; i++ ) {
		item = this.items[ i ];
		if ( hash === OO.getHash( item.getData() ) ) {
			items.push( item );
		}
	}

	return items;
};

/**
 * Add an aggregate item event.
 *
 * Aggregated events are listened to on each item and then emitted by the group under a new name,
 * and with an additional leading parameter containing the item that emitted the original event.
 * Other arguments that were emitted from the original event are passed through.
 *
 * @param {Object.<string,string|null>} events Aggregate events emitted by group, keyed by item
 *   event, use null value to remove aggregation
 * @throws {Error} If aggregation already exists
 */
OO.ui.GroupElement.prototype.aggregate = function ( events ) {
	var i, len, item, add, remove, itemEvent, groupEvent;

	for ( itemEvent in events ) {
		groupEvent = events[ itemEvent ];

		// Remove existing aggregated event
		if ( Object.prototype.hasOwnProperty.call( this.aggregateItemEvents, itemEvent ) ) {
			// Don't allow duplicate aggregations
			if ( groupEvent ) {
				throw new Error( 'Duplicate item event aggregation for ' + itemEvent );
			}
			// Remove event aggregation from existing items
			for ( i = 0, len = this.items.length; i < len; i++ ) {
				item = this.items[ i ];
				if ( item.connect && item.disconnect ) {
					remove = {};
					remove[ itemEvent ] = [ 'emit', groupEvent, item ];
					item.disconnect( this, remove );
				}
			}
			// Prevent future items from aggregating event
			delete this.aggregateItemEvents[ itemEvent ];
		}

		// Add new aggregate event
		if ( groupEvent ) {
			// Make future items aggregate event
			this.aggregateItemEvents[ itemEvent ] = groupEvent;
			// Add event aggregation to existing items
			for ( i = 0, len = this.items.length; i < len; i++ ) {
				item = this.items[ i ];
				if ( item.connect && item.disconnect ) {
					add = {};
					add[ itemEvent ] = [ 'emit', groupEvent, item ];
					item.connect( this, add );
				}
			}
		}
	}
};

/**
 * Add items.
 *
 * Adding an existing item will move it.
 *
 * @param {OO.ui.Element[]} items Items
 * @param {number} [index] Index to insert items at
 * @chainable
 */
OO.ui.GroupElement.prototype.addItems = function ( items, index ) {
	var i, len, item, event, events, currentIndex,
		itemElements = [];

	for ( i = 0, len = items.length; i < len; i++ ) {
		item = items[ i ];

		// Check if item exists then remove it first, effectively "moving" it
		currentIndex = $.inArray( item, this.items );
		if ( currentIndex >= 0 ) {
			this.removeItems( [ item ] );
			// Adjust index to compensate for removal
			if ( currentIndex < index ) {
				index--;
			}
		}
		// Add the item
		if ( item.connect && item.disconnect && !$.isEmptyObject( this.aggregateItemEvents ) ) {
			events = {};
			for ( event in this.aggregateItemEvents ) {
				events[ event ] = [ 'emit', this.aggregateItemEvents[ event ], item ];
			}
			item.connect( this, events );
		}
		item.setElementGroup( this );
		itemElements.push( item.$element.get( 0 ) );
	}

	if ( index === undefined || index < 0 || index >= this.items.length ) {
		this.$group.append( itemElements );
		this.items.push.apply( this.items, items );
	} else if ( index === 0 ) {
		this.$group.prepend( itemElements );
		this.items.unshift.apply( this.items, items );
	} else {
		this.items[ index ].$element.before( itemElements );
		this.items.splice.apply( this.items, [ index, 0 ].concat( items ) );
	}

	return this;
};

/**
 * Remove items.
 *
 * Items will be detached, not removed, so they can be used later.
 *
 * @param {OO.ui.Element[]} items Items to remove
 * @chainable
 */
OO.ui.GroupElement.prototype.removeItems = function ( items ) {
	var i, len, item, index, remove, itemEvent;

	// Remove specific items
	for ( i = 0, len = items.length; i < len; i++ ) {
		item = items[ i ];
		index = $.inArray( item, this.items );
		if ( index !== -1 ) {
			if (
				item.connect && item.disconnect &&
				!$.isEmptyObject( this.aggregateItemEvents )
			) {
				remove = {};
				if ( Object.prototype.hasOwnProperty.call( this.aggregateItemEvents, itemEvent ) ) {
					remove[ itemEvent ] = [ 'emit', this.aggregateItemEvents[ itemEvent ], item ];
				}
				item.disconnect( this, remove );
			}
			item.setElementGroup( null );
			this.items.splice( index, 1 );
			item.$element.detach();
		}
	}

	return this;
};

/**
 * Clear all items.
 *
 * Items will be detached, not removed, so they can be used later.
 *
 * @chainable
 */
OO.ui.GroupElement.prototype.clearItems = function () {
	var i, len, item, remove, itemEvent;

	// Remove all items
	for ( i = 0, len = this.items.length; i < len; i++ ) {
		item = this.items[ i ];
		if (
			item.connect && item.disconnect &&
			!$.isEmptyObject( this.aggregateItemEvents )
		) {
			remove = {};
			if ( Object.prototype.hasOwnProperty.call( this.aggregateItemEvents, itemEvent ) ) {
				remove[ itemEvent ] = [ 'emit', this.aggregateItemEvents[ itemEvent ], item ];
			}
			item.disconnect( this, remove );
		}
		item.setElementGroup( null );
		item.$element.detach();
	}

	this.items = [];
	return this;
};

/**
 * DraggableElement is a mixin class used to create elements that can be clicked
 * and dragged by a mouse to a new position within a group. This class must be used
 * in conjunction with OO.ui.DraggableGroupElement, which provides a container for
 * the draggable elements.
 *
 * @abstract
 * @class
 *
 * @constructor
 */
OO.ui.DraggableElement = function OoUiDraggableElement() {
	// Properties
	this.index = null;

	// Initialize and events
	this.$element
		.attr( 'draggable', true )
		.addClass( 'oo-ui-draggableElement' )
		.on( {
			dragstart: this.onDragStart.bind( this ),
			dragover: this.onDragOver.bind( this ),
			dragend: this.onDragEnd.bind( this ),
			drop: this.onDrop.bind( this )
		} );
};

OO.initClass( OO.ui.DraggableElement );

/* Events */

/**
 * @event dragstart
 *
 * A dragstart event is emitted when the user clicks and begins dragging an item.
 * @param {OO.ui.DraggableElement} item The item the user has clicked and is dragging with the mouse.
 */

/**
 * @event dragend
 * A dragend event is emitted when the user drags an item and releases the mouse,
 * thus terminating the drag operation.
 */

/**
 * @event drop
 * A drop event is emitted when the user drags an item and then releases the mouse button
 * over a valid target.
 */

/* Static Properties */

/**
 * @inheritdoc OO.ui.ButtonElement
 */
OO.ui.DraggableElement.static.cancelButtonMouseDownEvents = false;

/* Methods */

/**
 * Respond to dragstart event.
 *
 * @private
 * @param {jQuery.Event} event jQuery event
 * @fires dragstart
 */
OO.ui.DraggableElement.prototype.onDragStart = function ( e ) {
	var dataTransfer = e.originalEvent.dataTransfer;
	// Define drop effect
	dataTransfer.dropEffect = 'none';
	dataTransfer.effectAllowed = 'move';
	// We must set up a dataTransfer data property or Firefox seems to
	// ignore the fact the element is draggable.
	try {
		dataTransfer.setData( 'application-x/OOjs-UI-draggable', this.getIndex() );
	} catch ( err ) {
		// The above is only for firefox. No need to set a catch clause
		// if it fails, move on.
	}
	// Add dragging class
	this.$element.addClass( 'oo-ui-draggableElement-dragging' );
	// Emit event
	this.emit( 'dragstart', this );
	return true;
};

/**
 * Respond to dragend event.
 *
 * @private
 * @fires dragend
 */
OO.ui.DraggableElement.prototype.onDragEnd = function () {
	this.$element.removeClass( 'oo-ui-draggableElement-dragging' );
	this.emit( 'dragend' );
};

/**
 * Handle drop event.
 *
 * @private
 * @param {jQuery.Event} event jQuery event
 * @fires drop
 */
OO.ui.DraggableElement.prototype.onDrop = function ( e ) {
	e.preventDefault();
	this.emit( 'drop', e );
};

/**
 * In order for drag/drop to work, the dragover event must
 * return false and stop propogation.
 *
 * @private
 */
OO.ui.DraggableElement.prototype.onDragOver = function ( e ) {
	e.preventDefault();
};

/**
 * Set item index.
 * Store it in the DOM so we can access from the widget drag event
 *
 * @private
 * @param {number} Item index
 */
OO.ui.DraggableElement.prototype.setIndex = function ( index ) {
	if ( this.index !== index ) {
		this.index = index;
		this.$element.data( 'index', index );
	}
};

/**
 * Get item index
 *
 * @private
 * @return {number} Item index
 */
OO.ui.DraggableElement.prototype.getIndex = function () {
	return this.index;
};

/**
 * DraggableGroupElement is a mixin class used to create a group element to
 * contain draggable elements, which are items that can be clicked and dragged by a mouse.
 * The class is used with OO.ui.DraggableElement.
 *
 * @abstract
 * @class
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {jQuery} [$group] Container node, assigned to #$group, omit to use a generated `<div>`
 * @cfg {string} [orientation] Item orientation, 'horizontal' or 'vertical'. Defaults to 'vertical'
 */
OO.ui.DraggableGroupElement = function OoUiDraggableGroupElement( config ) {
	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.GroupElement.call( this, config );

	// Properties
	this.orientation = config.orientation || 'vertical';
	this.dragItem = null;
	this.itemDragOver = null;
	this.itemKeys = {};
	this.sideInsertion = '';

	// Events
	this.aggregate( {
		dragstart: 'itemDragStart',
		dragend: 'itemDragEnd',
		drop: 'itemDrop'
	} );
	this.connect( this, {
		itemDragStart: 'onItemDragStart',
		itemDrop: 'onItemDrop',
		itemDragEnd: 'onItemDragEnd'
	} );
	this.$element.on( {
		dragover: $.proxy( this.onDragOver, this ),
		dragleave: $.proxy( this.onDragLeave, this )
	} );

	// Initialize
	if ( Array.isArray( config.items ) ) {
		this.addItems( config.items );
	}
	this.$placeholder = $( '<div>' )
		.addClass( 'oo-ui-draggableGroupElement-placeholder' );
	this.$element
		.addClass( 'oo-ui-draggableGroupElement' )
		.append( this.$status )
		.toggleClass( 'oo-ui-draggableGroupElement-horizontal', this.orientation === 'horizontal' )
		.prepend( this.$placeholder );
};

/* Setup */
OO.mixinClass( OO.ui.DraggableGroupElement, OO.ui.GroupElement );

/* Events */

/**
 * @event reorder
 * @param {OO.ui.DraggableElement} item Reordered item
 * @param {number} [newIndex] New index for the item
 */

/* Methods */

/**
 * Respond to item drag start event
 * @param {OO.ui.DraggableElement} item Dragged item
 */
OO.ui.DraggableGroupElement.prototype.onItemDragStart = function ( item ) {
	var i, len;

	// Map the index of each object
	for ( i = 0, len = this.items.length; i < len; i++ ) {
		this.items[ i ].setIndex( i );
	}

	if ( this.orientation === 'horizontal' ) {
		// Set the height of the indicator
		this.$placeholder.css( {
			height: item.$element.outerHeight(),
			width: 2
		} );
	} else {
		// Set the width of the indicator
		this.$placeholder.css( {
			height: 2,
			width: item.$element.outerWidth()
		} );
	}
	this.setDragItem( item );
};

/**
 * Respond to item drag end event
 */
OO.ui.DraggableGroupElement.prototype.onItemDragEnd = function () {
	this.unsetDragItem();
	return false;
};

/**
 * Handle drop event and switch the order of the items accordingly
 * @param {OO.ui.DraggableElement} item Dropped item
 * @fires reorder
 */
OO.ui.DraggableGroupElement.prototype.onItemDrop = function ( item ) {
	var toIndex = item.getIndex();
	// Check if the dropped item is from the current group
	// TODO: Figure out a way to configure a list of legally droppable
	// elements even if they are not yet in the list
	if ( this.getDragItem() ) {
		// If the insertion point is 'after', the insertion index
		// is shifted to the right (or to the left in RTL, hence 'after')
		if ( this.sideInsertion === 'after' ) {
			toIndex++;
		}
		// Emit change event
		this.emit( 'reorder', this.getDragItem(), toIndex );
	}
	this.unsetDragItem();
	// Return false to prevent propogation
	return false;
};

/**
 * Handle dragleave event.
 */
OO.ui.DraggableGroupElement.prototype.onDragLeave = function () {
	// This means the item was dragged outside the widget
	this.$placeholder
		.css( 'left', 0 )
		.addClass( 'oo-ui-element-hidden' );
};

/**
 * Respond to dragover event
 * @param {jQuery.Event} event Event details
 */
OO.ui.DraggableGroupElement.prototype.onDragOver = function ( e ) {
	var dragOverObj, $optionWidget, itemOffset, itemMidpoint, itemBoundingRect,
		itemSize, cssOutput, dragPosition, itemIndex, itemPosition,
		clientX = e.originalEvent.clientX,
		clientY = e.originalEvent.clientY;

	// Get the OptionWidget item we are dragging over
	dragOverObj = this.getElementDocument().elementFromPoint( clientX, clientY );
	$optionWidget = $( dragOverObj ).closest( '.oo-ui-draggableElement' );
	if ( $optionWidget[ 0 ] ) {
		itemOffset = $optionWidget.offset();
		itemBoundingRect = $optionWidget[ 0 ].getBoundingClientRect();
		itemPosition = $optionWidget.position();
		itemIndex = $optionWidget.data( 'index' );
	}

	if (
		itemOffset &&
		this.isDragging() &&
		itemIndex !== this.getDragItem().getIndex()
	) {
		if ( this.orientation === 'horizontal' ) {
			// Calculate where the mouse is relative to the item width
			itemSize = itemBoundingRect.width;
			itemMidpoint = itemBoundingRect.left + itemSize / 2;
			dragPosition = clientX;
			// Which side of the item we hover over will dictate
			// where the placeholder will appear, on the left or
			// on the right
			cssOutput = {
				left: dragPosition < itemMidpoint ? itemPosition.left : itemPosition.left + itemSize,
				top: itemPosition.top
			};
		} else {
			// Calculate where the mouse is relative to the item height
			itemSize = itemBoundingRect.height;
			itemMidpoint = itemBoundingRect.top + itemSize / 2;
			dragPosition = clientY;
			// Which side of the item we hover over will dictate
			// where the placeholder will appear, on the top or
			// on the bottom
			cssOutput = {
				top: dragPosition < itemMidpoint ? itemPosition.top : itemPosition.top + itemSize,
				left: itemPosition.left
			};
		}
		// Store whether we are before or after an item to rearrange
		// For horizontal layout, we need to account for RTL, as this is flipped
		if (  this.orientation === 'horizontal' && this.$element.css( 'direction' ) === 'rtl' ) {
			this.sideInsertion = dragPosition < itemMidpoint ? 'after' : 'before';
		} else {
			this.sideInsertion = dragPosition < itemMidpoint ? 'before' : 'after';
		}
		// Add drop indicator between objects
		this.$placeholder
			.css( cssOutput )
			.removeClass( 'oo-ui-element-hidden' );
	} else {
		// This means the item was dragged outside the widget
		this.$placeholder
			.css( 'left', 0 )
			.addClass( 'oo-ui-element-hidden' );
	}
	// Prevent default
	e.preventDefault();
};

/**
 * Set a dragged item
 * @param {OO.ui.DraggableElement} item Dragged item
 */
OO.ui.DraggableGroupElement.prototype.setDragItem = function ( item ) {
	this.dragItem = item;
};

/**
 * Unset the current dragged item
 */
OO.ui.DraggableGroupElement.prototype.unsetDragItem = function () {
	this.dragItem = null;
	this.itemDragOver = null;
	this.$placeholder.addClass( 'oo-ui-element-hidden' );
	this.sideInsertion = '';
};

/**
 * Get the current dragged item
 * @return {OO.ui.DraggableElement|null} item Dragged item or null if no item is dragged
 */
OO.ui.DraggableGroupElement.prototype.getDragItem = function () {
	return this.dragItem;
};

/**
 * Check if there's an item being dragged.
 * @return {Boolean} Item is being dragged
 */
OO.ui.DraggableGroupElement.prototype.isDragging = function () {
	return this.getDragItem() !== null;
};

/**
 * IconElement is often mixed into other classes to generate an icon.
 * Icons are graphics, about the size of normal text. They are used to aid the user
 * in locating a control or to convey information in a space-efficient way. See the
 * [OOjs UI documentation on MediaWiki] [1] for a list of icons
 * included in the library.
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Icons,_Indicators,_and_Labels#Icons
 *
 * @abstract
 * @class
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {jQuery} [$icon] The icon element created by the class. If this configuration is omitted,
 *  the icon element will use a generated `<span>`. To use a different HTML tag, or to specify that
 *  the icon element be set to an existing icon instead of the one generated by this class, set a
 *  value using a jQuery selection. For example:
 *
 *      // Use a <div> tag instead of a <span>
 *     $icon: $("<div>")
 *     // Use an existing icon element instead of the one generated by the class
 *     $icon: this.$element
 *     // Use an icon element from a child widget
 *     $icon: this.childwidget.$element
 * @cfg {Object|string} [icon=''] The symbolic name of the icon (e.g., ‘remove’ or ‘menu’), or a map of
 *  symbolic names.  A map is used for i18n purposes and contains a `default` icon
 *  name and additional names keyed by language code. The `default` name is used when no icon is keyed
 *  by the user's language.
 *
 *  Example of an i18n map:
 *
 *     { default: 'bold-a', en: 'bold-b', de: 'bold-f' }
 *  See the [OOjs UI documentation on MediaWiki] [2] for a list of icons included in the library.
 * [2]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Icons,_Indicators,_and_Labels#Icons
 * @cfg {string|Function} [iconTitle] A text string used as the icon title, or a function that returns title
 *  text. The icon title is displayed when users move the mouse over the icon.
 */
OO.ui.IconElement = function OoUiIconElement( config ) {
	// Configuration initialization
	config = config || {};

	// Properties
	this.$icon = null;
	this.icon = null;
	this.iconTitle = null;

	// Initialization
	this.setIcon( config.icon || this.constructor.static.icon );
	this.setIconTitle( config.iconTitle || this.constructor.static.iconTitle );
	this.setIconElement( config.$icon || $( '<span>' ) );
};

/* Setup */

OO.initClass( OO.ui.IconElement );

/* Static Properties */

/**
 * The symbolic name of the icon (e.g., ‘remove’ or ‘menu’), or a map of symbolic names. A map is used
 * for i18n purposes and contains a `default` icon name and additional names keyed by
 * language code. The `default` name is used when no icon is keyed by the user's language.
 *
 * Example of an i18n map:
 *
 *     { default: 'bold-a', en: 'bold-b', de: 'bold-f' }
 *
 * Note: the static property will be overridden if the #icon configuration is used.
 *
 * @static
 * @inheritable
 * @property {Object|string}
 */
OO.ui.IconElement.static.icon = null;

/**
 * The icon title, displayed when users move the mouse over the icon. The value can be text, a
 * function that returns title text, or `null` for no title.
 *
 * The static property will be overridden if the #iconTitle configuration is used.
 *
 * @static
 * @inheritable
 * @property {string|Function|null}
 */
OO.ui.IconElement.static.iconTitle = null;

/* Methods */

/**
 * Set the icon element. This method is used to retarget an icon mixin so that its functionality
 * applies to the specified icon element instead of the one created by the class. If an icon
 * element is already set, the mixin’s effect on that element is removed. Generated CSS classes
 * and mixin methods will no longer affect the element.
 *
 * @param {jQuery} $icon Element to use as icon
 */
OO.ui.IconElement.prototype.setIconElement = function ( $icon ) {
	if ( this.$icon ) {
		this.$icon
			.removeClass( 'oo-ui-iconElement-icon oo-ui-icon-' + this.icon )
			.removeAttr( 'title' );
	}

	this.$icon = $icon
		.addClass( 'oo-ui-iconElement-icon' )
		.toggleClass( 'oo-ui-icon-' + this.icon, !!this.icon );
	if ( this.iconTitle !== null ) {
		this.$icon.attr( 'title', this.iconTitle );
	}
};

/**
 * Set icon by symbolic name (e.g., ‘remove’ or ‘menu’). Use `null` to remove an icon.
 * The icon parameter can also be set to a map of icon names. See the #icon config setting
 * for an example.
 *
 * @param {Object|string|null} icon A symbolic icon name, a {@link #icon map of icon names} keyed
 *  by language code, or `null` to remove the icon.
 * @chainable
 */
OO.ui.IconElement.prototype.setIcon = function ( icon ) {
	icon = OO.isPlainObject( icon ) ? OO.ui.getLocalValue( icon, null, 'default' ) : icon;
	icon = typeof icon === 'string' && icon.trim().length ? icon.trim() : null;

	if ( this.icon !== icon ) {
		if ( this.$icon ) {
			if ( this.icon !== null ) {
				this.$icon.removeClass( 'oo-ui-icon-' + this.icon );
			}
			if ( icon !== null ) {
				this.$icon.addClass( 'oo-ui-icon-' + icon );
			}
		}
		this.icon = icon;
	}

	this.$element.toggleClass( 'oo-ui-iconElement', !!this.icon );
	this.updateThemeClasses();

	return this;
};

/**
 * Set the icon title. Use `null` to remove the title.
 *
 * @param {string|Function|null} iconTitle A text string used as the icon title,
 *  a function that returns title text, or `null` for no title.
 * @chainable
 */
OO.ui.IconElement.prototype.setIconTitle = function ( iconTitle ) {
	iconTitle = typeof iconTitle === 'function' ||
		( typeof iconTitle === 'string' && iconTitle.length ) ?
			OO.ui.resolveMsg( iconTitle ) : null;

	if ( this.iconTitle !== iconTitle ) {
		this.iconTitle = iconTitle;
		if ( this.$icon ) {
			if ( this.iconTitle !== null ) {
				this.$icon.attr( 'title', iconTitle );
			} else {
				this.$icon.removeAttr( 'title' );
			}
		}
	}

	return this;
};

/**
 * Get the symbolic name of the icon.
 *
 * @return {string} Icon name
 */
OO.ui.IconElement.prototype.getIcon = function () {
	return this.icon;
};

/**
 * Get the icon title. The title text is displayed when a user moves the mouse over the icon.
 *
 * @return {string} Icon title text
 */
OO.ui.IconElement.prototype.getIconTitle = function () {
	return this.iconTitle;
};

/**
 * IndicatorElement is often mixed into other classes to generate an indicator.
 * Indicators are small graphics that are generally used in two ways:
 *
 * - To draw attention to the status of an item. For example, an indicator might be
 *   used to show that an item in a list has errors that need to be resolved.
 * - To clarify the function of a control that acts in an exceptional way (a button
 *   that opens a menu instead of performing an action directly, for example).
 *
 * For a list of indicators included in the library, please see the
 * [OOjs UI documentation on MediaWiki] [1].
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Icons,_Indicators,_and_Labels#Indicators
 *
 * @abstract
 * @class
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {jQuery} [$indicator] The indicator element created by the class. If this
 *  configuration is omitted, the indicator element will use a generated `<span>`.
 * @cfg {string} [indicator] Symbolic name of the indicator (e.g., ‘alert’ or  ‘down’).
 *  See the [OOjs UI documentation on MediaWiki][2] for a list of indicators included
 *  in the library.
 * [2]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Icons,_Indicators,_and_Labels#Indicators
 * @cfg {string|Function} [indicatorTitle] A text string used as the indicator title,
 *  or a function that returns title text. The indicator title is displayed when users move
 *  the mouse over the indicator.
 */
OO.ui.IndicatorElement = function OoUiIndicatorElement( config ) {
	// Configuration initialization
	config = config || {};

	// Properties
	this.$indicator = null;
	this.indicator = null;
	this.indicatorTitle = null;

	// Initialization
	this.setIndicator( config.indicator || this.constructor.static.indicator );
	this.setIndicatorTitle( config.indicatorTitle || this.constructor.static.indicatorTitle );
	this.setIndicatorElement( config.$indicator || $( '<span>' ) );
};

/* Setup */

OO.initClass( OO.ui.IndicatorElement );

/* Static Properties */

/**
 * Symbolic name of the indicator (e.g., ‘alert’ or  ‘down’).
 * The static property will be overridden if the #indicator configuration is used.
 *
 * @static
 * @inheritable
 * @property {string|null}
 */
OO.ui.IndicatorElement.static.indicator = null;

/**
 * A text string used as the indicator title, a function that returns title text, or `null`
 * for no title. The static property will be overridden if the #indicatorTitle configuration is used.
 *
 * @static
 * @inheritable
 * @property {string|Function|null}
 */
OO.ui.IndicatorElement.static.indicatorTitle = null;

/* Methods */

/**
 * Set the indicator element.
 *
 * If an element is already set, it will be cleaned up before setting up the new element.
 *
 * @param {jQuery} $indicator Element to use as indicator
 */
OO.ui.IndicatorElement.prototype.setIndicatorElement = function ( $indicator ) {
	if ( this.$indicator ) {
		this.$indicator
			.removeClass( 'oo-ui-indicatorElement-indicator oo-ui-indicator-' + this.indicator )
			.removeAttr( 'title' );
	}

	this.$indicator = $indicator
		.addClass( 'oo-ui-indicatorElement-indicator' )
		.toggleClass( 'oo-ui-indicator-' + this.indicator, !!this.indicator );
	if ( this.indicatorTitle !== null ) {
		this.$indicator.attr( 'title', this.indicatorTitle );
	}
};

/**
 * Set indicator name.
 *
 * @param {string|null} indicator Symbolic name of indicator to use or null for no indicator
 * @chainable
 */
OO.ui.IndicatorElement.prototype.setIndicator = function ( indicator ) {
	indicator = typeof indicator === 'string' && indicator.length ? indicator.trim() : null;

	if ( this.indicator !== indicator ) {
		if ( this.$indicator ) {
			if ( this.indicator !== null ) {
				this.$indicator.removeClass( 'oo-ui-indicator-' + this.indicator );
			}
			if ( indicator !== null ) {
				this.$indicator.addClass( 'oo-ui-indicator-' + indicator );
			}
		}
		this.indicator = indicator;
	}

	this.$element.toggleClass( 'oo-ui-indicatorElement', !!this.indicator );
	this.updateThemeClasses();

	return this;
};

/**
 * Set indicator title.
 *
 * @param {string|Function|null} indicator Indicator title text, a function that returns text or
 *   null for no indicator title
 * @chainable
 */
OO.ui.IndicatorElement.prototype.setIndicatorTitle = function ( indicatorTitle ) {
	indicatorTitle = typeof indicatorTitle === 'function' ||
		( typeof indicatorTitle === 'string' && indicatorTitle.length ) ?
			OO.ui.resolveMsg( indicatorTitle ) : null;

	if ( this.indicatorTitle !== indicatorTitle ) {
		this.indicatorTitle = indicatorTitle;
		if ( this.$indicator ) {
			if ( this.indicatorTitle !== null ) {
				this.$indicator.attr( 'title', indicatorTitle );
			} else {
				this.$indicator.removeAttr( 'title' );
			}
		}
	}

	return this;
};

/**
 * Get indicator name.
 *
 * @return {string} Symbolic name of indicator
 */
OO.ui.IndicatorElement.prototype.getIndicator = function () {
	return this.indicator;
};

/**
 * Get indicator title.
 *
 * @return {string} Indicator title text
 */
OO.ui.IndicatorElement.prototype.getIndicatorTitle = function () {
	return this.indicatorTitle;
};

/**
 * LabelElement is often mixed into other classes to generate a label, which
 * helps identify the function of an interface element.
 * See the [OOjs UI documentation on MediaWiki] [1] for more information.
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Icons,_Indicators,_and_Labels#Labels
 *
 * @abstract
 * @class
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {jQuery} [$label] The label element created by the class. If this
 *  configuration is omitted, the label element will use a generated `<span>`.
 * @cfg {jQuery|string|Function} [label] The label text. The label can be specified as a plaintext string,
 *  a jQuery selection of elements, or a function that will produce a string in the future. See the
 *  [OOjs UI documentation on MediaWiki] [2] for examples.
 *  [2]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Icons,_Indicators,_and_Labels#Labels
 * @cfg {boolean} [autoFitLabel=true] Fit the label to the width of the parent element.
 *  The label will be truncated to fit if necessary.
 */
OO.ui.LabelElement = function OoUiLabelElement( config ) {
	// Configuration initialization
	config = config || {};

	// Properties
	this.$label = null;
	this.label = null;
	this.autoFitLabel = config.autoFitLabel === undefined || !!config.autoFitLabel;

	// Initialization
	this.setLabel( config.label || this.constructor.static.label );
	this.setLabelElement( config.$label || $( '<span>' ) );
};

/* Setup */

OO.initClass( OO.ui.LabelElement );

/* Events */

/**
 * @event labelChange
 * @param {string} value
 */

/* Static Properties */

/**
 * The label text. The label can be specified as a plaintext string, a function that will
 * produce a string in the future, or `null` for no label. The static value will
 * be overridden if a label is specified with the #label config option.
 *
 * @static
 * @inheritable
 * @property {string|Function|null}
 */
OO.ui.LabelElement.static.label = null;

/* Methods */

/**
 * Set the label element.
 *
 * If an element is already set, it will be cleaned up before setting up the new element.
 *
 * @param {jQuery} $label Element to use as label
 */
OO.ui.LabelElement.prototype.setLabelElement = function ( $label ) {
	if ( this.$label ) {
		this.$label.removeClass( 'oo-ui-labelElement-label' ).empty();
	}

	this.$label = $label.addClass( 'oo-ui-labelElement-label' );
	this.setLabelContent( this.label );
};

/**
 * Set the label.
 *
 * An empty string will result in the label being hidden. A string containing only whitespace will
 * be converted to a single `&nbsp;`.
 *
 * @param {jQuery|string|OO.ui.HtmlSnippet|Function|null} label Label nodes; text; a function that returns nodes or
 *  text; or null for no label
 * @chainable
 */
OO.ui.LabelElement.prototype.setLabel = function ( label ) {
	label = typeof label === 'function' ? OO.ui.resolveMsg( label ) : label;
	label = ( ( typeof label === 'string' && label.length ) || label instanceof jQuery || label instanceof OO.ui.HtmlSnippet ) ? label : null;

	this.$element.toggleClass( 'oo-ui-labelElement', !!label );

	if ( this.label !== label ) {
		if ( this.$label ) {
			this.setLabelContent( label );
		}
		this.label = label;
		this.emit( 'labelChange' );
	}

	return this;
};

/**
 * Get the label.
 *
 * @return {jQuery|string|Function|null} Label nodes; text; a function that returns nodes or
 *  text; or null for no label
 */
OO.ui.LabelElement.prototype.getLabel = function () {
	return this.label;
};

/**
 * Fit the label.
 *
 * @chainable
 */
OO.ui.LabelElement.prototype.fitLabel = function () {
	if ( this.$label && this.$label.autoEllipsis && this.autoFitLabel ) {
		this.$label.autoEllipsis( { hasSpan: false, tooltip: true } );
	}

	return this;
};

/**
 * Set the content of the label.
 *
 * Do not call this method until after the label element has been set by #setLabelElement.
 *
 * @private
 * @param {jQuery|string|Function|null} label Label nodes; text; a function that returns nodes or
 *  text; or null for no label
 */
OO.ui.LabelElement.prototype.setLabelContent = function ( label ) {
	if ( typeof label === 'string' ) {
		if ( label.match( /^\s*$/ ) ) {
			// Convert whitespace only string to a single non-breaking space
			this.$label.html( '&nbsp;' );
		} else {
			this.$label.text( label );
		}
	} else if ( label instanceof OO.ui.HtmlSnippet ) {
		this.$label.html( label.toString() );
	} else if ( label instanceof jQuery ) {
		this.$label.empty().append( label );
	} else {
		this.$label.empty();
	}
};

/**
 * Mixin that adds a menu showing suggested values for a OO.ui.TextInputWidget.
 *
 * Subclasses that set the value of #lookupInput from #onLookupMenuItemChoose should
 * be aware that this will cause new suggestions to be looked up for the new value. If this is
 * not desired, disable lookups with #setLookupsDisabled, then set the value, then re-enable lookups.
 *
 * @class
 * @abstract
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {jQuery} [$overlay] Overlay for dropdown; defaults to relative positioning
 * @cfg {jQuery} [$container=this.$element] Element to render menu under
 */
OO.ui.LookupElement = function OoUiLookupElement( config ) {
	// Configuration initialization
	config = config || {};

	// Properties
	this.$overlay = config.$overlay || this.$element;
	this.lookupMenu = new OO.ui.TextInputMenuSelectWidget( this, {
		widget: this,
		input: this,
		$container: config.$container
	} );
	this.lookupCache = {};
	this.lookupQuery = null;
	this.lookupRequest = null;
	this.lookupsDisabled = false;
	this.lookupInputFocused = false;

	// Events
	this.$input.on( {
		focus: this.onLookupInputFocus.bind( this ),
		blur: this.onLookupInputBlur.bind( this ),
		mousedown: this.onLookupInputMouseDown.bind( this )
	} );
	this.connect( this, { change: 'onLookupInputChange' } );
	this.lookupMenu.connect( this, {
		toggle: 'onLookupMenuToggle',
		choose: 'onLookupMenuItemChoose'
	} );

	// Initialization
	this.$element.addClass( 'oo-ui-lookupElement' );
	this.lookupMenu.$element.addClass( 'oo-ui-lookupElement-menu' );
	this.$overlay.append( this.lookupMenu.$element );
};

/* Methods */

/**
 * Handle input focus event.
 *
 * @param {jQuery.Event} e Input focus event
 */
OO.ui.LookupElement.prototype.onLookupInputFocus = function () {
	this.lookupInputFocused = true;
	this.populateLookupMenu();
};

/**
 * Handle input blur event.
 *
 * @param {jQuery.Event} e Input blur event
 */
OO.ui.LookupElement.prototype.onLookupInputBlur = function () {
	this.closeLookupMenu();
	this.lookupInputFocused = false;
};

/**
 * Handle input mouse down event.
 *
 * @param {jQuery.Event} e Input mouse down event
 */
OO.ui.LookupElement.prototype.onLookupInputMouseDown = function () {
	// Only open the menu if the input was already focused.
	// This way we allow the user to open the menu again after closing it with Esc
	// by clicking in the input. Opening (and populating) the menu when initially
	// clicking into the input is handled by the focus handler.
	if ( this.lookupInputFocused && !this.lookupMenu.isVisible() ) {
		this.populateLookupMenu();
	}
};

/**
 * Handle input change event.
 *
 * @param {string} value New input value
 */
OO.ui.LookupElement.prototype.onLookupInputChange = function () {
	if ( this.lookupInputFocused ) {
		this.populateLookupMenu();
	}
};

/**
 * Handle the lookup menu being shown/hidden.
 *
 * @param {boolean} visible Whether the lookup menu is now visible.
 */
OO.ui.LookupElement.prototype.onLookupMenuToggle = function ( visible ) {
	if ( !visible ) {
		// When the menu is hidden, abort any active request and clear the menu.
		// This has to be done here in addition to closeLookupMenu(), because
		// MenuSelectWidget will close itself when the user presses Esc.
		this.abortLookupRequest();
		this.lookupMenu.clearItems();
	}
};

/**
 * Handle menu item 'choose' event, updating the text input value to the value of the clicked item.
 *
 * @param {OO.ui.MenuOptionWidget|null} item Selected item
 */
OO.ui.LookupElement.prototype.onLookupMenuItemChoose = function ( item ) {
	if ( item ) {
		this.setValue( item.getData() );
	}
};

/**
 * Get lookup menu.
 *
 * @return {OO.ui.TextInputMenuSelectWidget}
 */
OO.ui.LookupElement.prototype.getLookupMenu = function () {
	return this.lookupMenu;
};

/**
 * Disable or re-enable lookups.
 *
 * When lookups are disabled, calls to #populateLookupMenu will be ignored.
 *
 * @param {boolean} disabled Disable lookups
 */
OO.ui.LookupElement.prototype.setLookupsDisabled = function ( disabled ) {
	this.lookupsDisabled = !!disabled;
};

/**
 * Open the menu. If there are no entries in the menu, this does nothing.
 *
 * @chainable
 */
OO.ui.LookupElement.prototype.openLookupMenu = function () {
	if ( !this.lookupMenu.isEmpty() ) {
		this.lookupMenu.toggle( true );
	}
	return this;
};

/**
 * Close the menu, empty it, and abort any pending request.
 *
 * @chainable
 */
OO.ui.LookupElement.prototype.closeLookupMenu = function () {
	this.lookupMenu.toggle( false );
	this.abortLookupRequest();
	this.lookupMenu.clearItems();
	return this;
};

/**
 * Request menu items based on the input's current value, and when they arrive,
 * populate the menu with these items and show the menu.
 *
 * If lookups have been disabled with #setLookupsDisabled, this function does nothing.
 *
 * @chainable
 */
OO.ui.LookupElement.prototype.populateLookupMenu = function () {
	var widget = this,
		value = this.getValue();

	if ( this.lookupsDisabled ) {
		return;
	}

	// If the input is empty, clear the menu
	if ( value === '' ) {
		this.closeLookupMenu();
	// Skip population if there is already a request pending for the current value
	} else if ( value !== this.lookupQuery ) {
		this.getLookupMenuItems()
			.done( function ( items ) {
				widget.lookupMenu.clearItems();
				if ( items.length ) {
					widget.lookupMenu
						.addItems( items )
						.toggle( true );
					widget.initializeLookupMenuSelection();
				} else {
					widget.lookupMenu.toggle( false );
				}
			} )
			.fail( function () {
				widget.lookupMenu.clearItems();
			} );
	}

	return this;
};

/**
 * Select and highlight the first selectable item in the menu.
 *
 * @chainable
 */
OO.ui.LookupElement.prototype.initializeLookupMenuSelection = function () {
	if ( !this.lookupMenu.getSelectedItem() ) {
		this.lookupMenu.selectItem( this.lookupMenu.getFirstSelectableItem() );
	}
	this.lookupMenu.highlightItem( this.lookupMenu.getSelectedItem() );
};

/**
 * Get lookup menu items for the current query.
 *
 * @return {jQuery.Promise} Promise object which will be passed menu items as the first argument of
 *   the done event. If the request was aborted to make way for a subsequent request, this promise
 *   will not be rejected: it will remain pending forever.
 */
OO.ui.LookupElement.prototype.getLookupMenuItems = function () {
	var widget = this,
		value = this.getValue(),
		deferred = $.Deferred(),
		ourRequest;

	this.abortLookupRequest();
	if ( Object.prototype.hasOwnProperty.call( this.lookupCache, value ) ) {
		deferred.resolve( this.getLookupMenuOptionsFromData( this.lookupCache[ value ] ) );
	} else {
		this.pushPending();
		this.lookupQuery = value;
		ourRequest = this.lookupRequest = this.getLookupRequest();
		ourRequest
			.always( function () {
				// We need to pop pending even if this is an old request, otherwise
				// the widget will remain pending forever.
				// TODO: this assumes that an aborted request will fail or succeed soon after
				// being aborted, or at least eventually. It would be nice if we could popPending()
				// at abort time, but only if we knew that we hadn't already called popPending()
				// for that request.
				widget.popPending();
			} )
			.done( function ( data ) {
				// If this is an old request (and aborting it somehow caused it to still succeed),
				// ignore its success completely
				if ( ourRequest === widget.lookupRequest ) {
					widget.lookupQuery = null;
					widget.lookupRequest = null;
					widget.lookupCache[ value ] = widget.getLookupCacheDataFromResponse( data );
					deferred.resolve( widget.getLookupMenuOptionsFromData( widget.lookupCache[ value ] ) );
				}
			} )
			.fail( function () {
				// If this is an old request (or a request failing because it's being aborted),
				// ignore its failure completely
				if ( ourRequest === widget.lookupRequest ) {
					widget.lookupQuery = null;
					widget.lookupRequest = null;
					deferred.reject();
				}
			} );
	}
	return deferred.promise();
};

/**
 * Abort the currently pending lookup request, if any.
 */
OO.ui.LookupElement.prototype.abortLookupRequest = function () {
	var oldRequest = this.lookupRequest;
	if ( oldRequest ) {
		// First unset this.lookupRequest to the fail handler will notice
		// that the request is no longer current
		this.lookupRequest = null;
		this.lookupQuery = null;
		oldRequest.abort();
	}
};

/**
 * Get a new request object of the current lookup query value.
 *
 * @abstract
 * @return {jQuery.Promise} jQuery AJAX object, or promise object with an .abort() method
 */
OO.ui.LookupElement.prototype.getLookupRequest = function () {
	// Stub, implemented in subclass
	return null;
};

/**
 * Pre-process data returned by the request from #getLookupRequest.
 *
 * The return value of this function will be cached, and any further queries for the given value
 * will use the cache rather than doing API requests.
 *
 * @abstract
 * @param {Mixed} data Response from server
 * @return {Mixed} Cached result data
 */
OO.ui.LookupElement.prototype.getLookupCacheDataFromResponse = function () {
	// Stub, implemented in subclass
	return [];
};

/**
 * Get a list of menu option widgets from the (possibly cached) data returned by
 * #getLookupCacheDataFromResponse.
 *
 * @abstract
 * @param {Mixed} data Cached result data, usually an array
 * @return {OO.ui.MenuOptionWidget[]} Menu items
 */
OO.ui.LookupElement.prototype.getLookupMenuOptionsFromData = function () {
	// Stub, implemented in subclass
	return [];
};

/**
 * PopupElement is mixed into other classes to generate a {@link OO.ui.PopupWidget popup widget}.
 * A popup is a container for content. It is overlaid and positioned absolutely. By default, each
 * popup has an anchor, which is an arrow-like protrusion that points toward the popup’s origin.
 * See {@link OO.ui.PopupWidget PopupWidget} for an example.
 *
 * @abstract
 * @class
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {Object} [popup] Configuration to pass to popup
 * @cfg {boolean} [popup.autoClose=true] Popup auto-closes when it loses focus
 */
OO.ui.PopupElement = function OoUiPopupElement( config ) {
	// Configuration initialization
	config = config || {};

	// Properties
	this.popup = new OO.ui.PopupWidget( $.extend(
		{ autoClose: true },
		config.popup,
		{ $autoCloseIgnore: this.$element }
	) );
};

/* Methods */

/**
 * Get popup.
 *
 * @return {OO.ui.PopupWidget} Popup widget
 */
OO.ui.PopupElement.prototype.getPopup = function () {
	return this.popup;
};

/**
 * The FlaggedElement class is an attribute mixin, meaning that it is used to add
 * additional functionality to an element created by another class. The class provides
 * a ‘flags’ property assigned the name (or an array of names) of styling flags,
 * which are used to customize the look and feel of a widget to better describe its
 * importance and functionality.
 *
 * The library currently contains the following styling flags for general use:
 *
 * - **progressive**:  Progressive styling is applied to convey that the widget will move the user forward in a process.
 * - **destructive**: Destructive styling is applied to convey that the widget will remove something.
 * - **constructive**: Constructive styling is applied to convey that the widget will create something.
 *
 * {@link OO.ui.ActionWidget ActionWidgets}, which are a special kind of button that execute an action, use these flags: **primary** and **safe**.
 * Please see the [OOjs UI documentation on MediaWiki] [1] for more information.
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Elements/Flagged
 *
 * @abstract
 * @class
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {string|string[]} [flags] The name or names of the flags (e.g., 'constructive' or 'primary') to apply.
 *  Please see the [OOjs UI documentation on MediaWiki] [2] for more information about available flags.
 *  [2]: https://www.mediawiki.org/wiki/OOjs_UI/Elements/Flagged
 * @cfg {jQuery} [$flagged] Flagged node, assigned to $flagged, omit to use $element
 */
OO.ui.FlaggedElement = function OoUiFlaggedElement( config ) {
	// Configuration initialization
	config = config || {};

	// Properties
	this.flags = {};
	this.$flagged = null;

	// Initialization
	this.setFlags( config.flags );
	this.setFlaggedElement( config.$flagged || this.$element );
};

/* Events */

/**
 * @event flag
 * A flag event is emitted when the #clearFlags or #setFlags methods are used. The `changes`
 * parameter contains the name of each modified flag and indicates whether it was
 * added or removed.
 *
 * @param {Object.<string,boolean>} changes Object keyed by flag name. A Boolean `true` indicates
 * that the flag was added, `false` that the flag was removed.
 */

/* Methods */

/**
 * Set the flagged element.
 *
 * If an element is already set, it will be cleaned up before setting up the new element.
 *
 * @param {jQuery} $flagged Element to add flags to
 */
OO.ui.FlaggedElement.prototype.setFlaggedElement = function ( $flagged ) {
	var classNames = Object.keys( this.flags ).map( function ( flag ) {
		return 'oo-ui-flaggedElement-' + flag;
	} ).join( ' ' );

	if ( this.$flagged ) {
		this.$flagged.removeClass( classNames );
	}

	this.$flagged = $flagged.addClass( classNames );
};

/**
 * Check if a flag is set.
 *
 * @param {string} flag Name of flag
 * @return {boolean} Has flag
 */
OO.ui.FlaggedElement.prototype.hasFlag = function ( flag ) {
	return flag in this.flags;
};

/**
 * Get the names of all flags set.
 *
 * @return {string[]} Flag names
 */
OO.ui.FlaggedElement.prototype.getFlags = function () {
	return Object.keys( this.flags );
};

/**
 * Clear all flags.
 *
 * @chainable
 * @fires flag
 */
OO.ui.FlaggedElement.prototype.clearFlags = function () {
	var flag, className,
		changes = {},
		remove = [],
		classPrefix = 'oo-ui-flaggedElement-';

	for ( flag in this.flags ) {
		className = classPrefix + flag;
		changes[ flag ] = false;
		delete this.flags[ flag ];
		remove.push( className );
	}

	if ( this.$flagged ) {
		this.$flagged.removeClass( remove.join( ' ' ) );
	}

	this.updateThemeClasses();
	this.emit( 'flag', changes );

	return this;
};

/**
 * Add one or more flags.
 *
 * @param {string|string[]|Object.<string, boolean>} flags One or more flags to add, or an object
 *  keyed by flag name containing boolean set/remove instructions.
 * @chainable
 * @fires flag
 */
OO.ui.FlaggedElement.prototype.setFlags = function ( flags ) {
	var i, len, flag, className,
		changes = {},
		add = [],
		remove = [],
		classPrefix = 'oo-ui-flaggedElement-';

	if ( typeof flags === 'string' ) {
		className = classPrefix + flags;
		// Set
		if ( !this.flags[ flags ] ) {
			this.flags[ flags ] = true;
			add.push( className );
		}
	} else if ( Array.isArray( flags ) ) {
		for ( i = 0, len = flags.length; i < len; i++ ) {
			flag = flags[ i ];
			className = classPrefix + flag;
			// Set
			if ( !this.flags[ flag ] ) {
				changes[ flag ] = true;
				this.flags[ flag ] = true;
				add.push( className );
			}
		}
	} else if ( OO.isPlainObject( flags ) ) {
		for ( flag in flags ) {
			className = classPrefix + flag;
			if ( flags[ flag ] ) {
				// Set
				if ( !this.flags[ flag ] ) {
					changes[ flag ] = true;
					this.flags[ flag ] = true;
					add.push( className );
				}
			} else {
				// Remove
				if ( this.flags[ flag ] ) {
					changes[ flag ] = false;
					delete this.flags[ flag ];
					remove.push( className );
				}
			}
		}
	}

	if ( this.$flagged ) {
		this.$flagged
			.addClass( add.join( ' ' ) )
			.removeClass( remove.join( ' ' ) );
	}

	this.updateThemeClasses();
	this.emit( 'flag', changes );

	return this;
};

/**
 * TitledElement is mixed into other classes to provide a `title` attribute.
 * Titles are rendered by the browser and are made visible when the user moves
 * the mouse over the element. Titles are not visible on touch devices.
 *
 *     @example
 *     // TitledElement provides a 'title' attribute to the
 *     // ButtonWidget class
 *     var button = new OO.ui.ButtonWidget( {
 *         label : 'Button with Title',
 *         title : 'I am a button'
 *     } );
 *     $( 'body' ).append( button.$element );
 *
 * @abstract
 * @class
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {jQuery} [$titled] The element to which the `title` attribute is applied.
 *  If this config is omitted, the title functionality is applied to $element, the
 *  element created by the class.
 * @cfg {string|Function} [title] The title text or a function that returns text. If
 *  this config is omitted, the value of the static `title` property is used.
 */
OO.ui.TitledElement = function OoUiTitledElement( config ) {
	// Configuration initialization
	config = config || {};

	// Properties
	this.$titled = null;
	this.title = null;

	// Initialization
	this.setTitle( config.title || this.constructor.static.title );
	this.setTitledElement( config.$titled || this.$element );
};

/* Setup */

OO.initClass( OO.ui.TitledElement );

/* Static Properties */

/**
 * The title text, a function that returns text, or `null` for no title. The value of the static property
 * is overridden if the #title config option is used.
 *
 * @static
 * @inheritable
 * @property {string|Function|null}
 */
OO.ui.TitledElement.static.title = null;

/* Methods */

/**
 * Set the titled element.
 *
 * If an element is already set, it will be cleaned up before setting up the new element.
 *
 * @param {jQuery} $titled Element to set title on
 */
OO.ui.TitledElement.prototype.setTitledElement = function ( $titled ) {
	if ( this.$titled ) {
		this.$titled.removeAttr( 'title' );
	}

	this.$titled = $titled;
	if ( this.title ) {
		this.$titled.attr( 'title', this.title );
	}
};

/**
 * Set title.
 *
 * @param {string|Function|null} title Title text, a function that returns text or null for no title
 * @chainable
 */
OO.ui.TitledElement.prototype.setTitle = function ( title ) {
	title = typeof title === 'string' ? OO.ui.resolveMsg( title ) : null;

	if ( this.title !== title ) {
		if ( this.$titled ) {
			if ( title !== null ) {
				this.$titled.attr( 'title', title );
			} else {
				this.$titled.removeAttr( 'title' );
			}
		}
		this.title = title;
	}

	return this;
};

/**
 * Get title.
 *
 * @return {string} Title string
 */
OO.ui.TitledElement.prototype.getTitle = function () {
	return this.title;
};

/**
 * Element that can be automatically clipped to visible boundaries.
 *
 * Whenever the element's natural height changes, you have to call
 * #clip to make sure it's still clipping correctly.
 *
 * @abstract
 * @class
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {jQuery} [$clippable] Nodes to clip, assigned to #$clippable, omit to use #$element
 */
OO.ui.ClippableElement = function OoUiClippableElement( config ) {
	// Configuration initialization
	config = config || {};

	// Properties
	this.$clippable = null;
	this.clipping = false;
	this.clippedHorizontally = false;
	this.clippedVertically = false;
	this.$clippableContainer = null;
	this.$clippableScroller = null;
	this.$clippableWindow = null;
	this.idealWidth = null;
	this.idealHeight = null;
	this.onClippableContainerScrollHandler = this.clip.bind( this );
	this.onClippableWindowResizeHandler = this.clip.bind( this );

	// Initialization
	this.setClippableElement( config.$clippable || this.$element );
};

/* Methods */

/**
 * Set clippable element.
 *
 * If an element is already set, it will be cleaned up before setting up the new element.
 *
 * @param {jQuery} $clippable Element to make clippable
 */
OO.ui.ClippableElement.prototype.setClippableElement = function ( $clippable ) {
	if ( this.$clippable ) {
		this.$clippable.removeClass( 'oo-ui-clippableElement-clippable' );
		this.$clippable.css( { width: '', height: '', overflowX: '', overflowY: '' } );
		OO.ui.Element.static.reconsiderScrollbars( this.$clippable[ 0 ] );
	}

	this.$clippable = $clippable.addClass( 'oo-ui-clippableElement-clippable' );
	this.clip();
};

/**
 * Toggle clipping.
 *
 * Do not turn clipping on until after the element is attached to the DOM and visible.
 *
 * @param {boolean} [clipping] Enable clipping, omit to toggle
 * @chainable
 */
OO.ui.ClippableElement.prototype.toggleClipping = function ( clipping ) {
	clipping = clipping === undefined ? !this.clipping : !!clipping;

	if ( this.clipping !== clipping ) {
		this.clipping = clipping;
		if ( clipping ) {
			this.$clippableContainer = $( this.getClosestScrollableElementContainer() );
			// If the clippable container is the root, we have to listen to scroll events and check
			// jQuery.scrollTop on the window because of browser inconsistencies
			this.$clippableScroller = this.$clippableContainer.is( 'html, body' ) ?
				$( OO.ui.Element.static.getWindow( this.$clippableContainer ) ) :
				this.$clippableContainer;
			this.$clippableScroller.on( 'scroll', this.onClippableContainerScrollHandler );
			this.$clippableWindow = $( this.getElementWindow() )
				.on( 'resize', this.onClippableWindowResizeHandler );
			// Initial clip after visible
			this.clip();
		} else {
			this.$clippable.css( { width: '', height: '', overflowX: '', overflowY: '' } );
			OO.ui.Element.static.reconsiderScrollbars( this.$clippable[ 0 ] );

			this.$clippableContainer = null;
			this.$clippableScroller.off( 'scroll', this.onClippableContainerScrollHandler );
			this.$clippableScroller = null;
			this.$clippableWindow.off( 'resize', this.onClippableWindowResizeHandler );
			this.$clippableWindow = null;
		}
	}

	return this;
};

/**
 * Check if the element will be clipped to fit the visible area of the nearest scrollable container.
 *
 * @return {boolean} Element will be clipped to the visible area
 */
OO.ui.ClippableElement.prototype.isClipping = function () {
	return this.clipping;
};

/**
 * Check if the bottom or right of the element is being clipped by the nearest scrollable container.
 *
 * @return {boolean} Part of the element is being clipped
 */
OO.ui.ClippableElement.prototype.isClipped = function () {
	return this.clippedHorizontally || this.clippedVertically;
};

/**
 * Check if the right of the element is being clipped by the nearest scrollable container.
 *
 * @return {boolean} Part of the element is being clipped
 */
OO.ui.ClippableElement.prototype.isClippedHorizontally = function () {
	return this.clippedHorizontally;
};

/**
 * Check if the bottom of the element is being clipped by the nearest scrollable container.
 *
 * @return {boolean} Part of the element is being clipped
 */
OO.ui.ClippableElement.prototype.isClippedVertically = function () {
	return this.clippedVertically;
};

/**
 * Set the ideal size. These are the dimensions the element will have when it's not being clipped.
 *
 * @param {number|string} [width] Width as a number of pixels or CSS string with unit suffix
 * @param {number|string} [height] Height as a number of pixels or CSS string with unit suffix
 */
OO.ui.ClippableElement.prototype.setIdealSize = function ( width, height ) {
	this.idealWidth = width;
	this.idealHeight = height;

	if ( !this.clipping ) {
		// Update dimensions
		this.$clippable.css( { width: width, height: height } );
	}
	// While clipping, idealWidth and idealHeight are not considered
};

/**
 * Clip element to visible boundaries and allow scrolling when needed. Call this method when
 * the element's natural height changes.
 *
 * Element will be clipped the bottom or right of the element is within 10px of the edge of, or
 * overlapped by, the visible area of the nearest scrollable container.
 *
 * @chainable
 */
OO.ui.ClippableElement.prototype.clip = function () {
	if ( !this.clipping ) {
		// this.$clippableContainer and this.$clippableWindow are null, so the below will fail
		return this;
	}

	var buffer = 7, // Chosen by fair dice roll
		cOffset = this.$clippable.offset(),
		$container = this.$clippableContainer.is( 'html, body' ) ?
			this.$clippableWindow : this.$clippableContainer,
		ccOffset = $container.offset() || { top: 0, left: 0 },
		ccHeight = $container.innerHeight() - buffer,
		ccWidth = $container.innerWidth() - buffer,
		cHeight = this.$clippable.outerHeight() + buffer,
		cWidth = this.$clippable.outerWidth() + buffer,
		scrollTop = this.$clippableScroller.scrollTop(),
		scrollLeft = this.$clippableScroller.scrollLeft(),
		desiredWidth = cOffset.left < 0 ?
			cWidth + cOffset.left :
			( ccOffset.left + scrollLeft + ccWidth ) - cOffset.left,
		desiredHeight = cOffset.top < 0 ?
			cHeight + cOffset.top :
			( ccOffset.top + scrollTop + ccHeight ) - cOffset.top,
		naturalWidth = this.$clippable.prop( 'scrollWidth' ),
		naturalHeight = this.$clippable.prop( 'scrollHeight' ),
		clipWidth = desiredWidth < naturalWidth,
		clipHeight = desiredHeight < naturalHeight;

	if ( clipWidth ) {
		this.$clippable.css( { overflowX: 'scroll', width: desiredWidth } );
	} else {
		this.$clippable.css( { width: this.idealWidth || '', overflowX: '' } );
	}
	if ( clipHeight ) {
		this.$clippable.css( { overflowY: 'scroll', height: desiredHeight } );
	} else {
		this.$clippable.css( { height: this.idealHeight || '', overflowY: '' } );
	}

	// If we stopped clipping in at least one of the dimensions
	if ( !clipWidth || !clipHeight ) {
		OO.ui.Element.static.reconsiderScrollbars( this.$clippable[ 0 ] );
	}

	this.clippedHorizontally = clipWidth;
	this.clippedVertically = clipHeight;

	return this;
};

/**
 * Generic toolbar tool.
 *
 * @abstract
 * @class
 * @extends OO.ui.Widget
 * @mixins OO.ui.IconElement
 * @mixins OO.ui.FlaggedElement
 *
 * @constructor
 * @param {OO.ui.ToolGroup} toolGroup
 * @param {Object} [config] Configuration options
 * @cfg {string|Function} [title] Title text or a function that returns text
 */
OO.ui.Tool = function OoUiTool( toolGroup, config ) {
	// Allow passing positional parameters inside the config object
	if ( OO.isPlainObject( toolGroup ) && config === undefined ) {
		config = toolGroup;
		toolGroup = config.toolGroup;
	}

	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.Tool.super.call( this, config );

	// Mixin constructors
	OO.ui.IconElement.call( this, config );
	OO.ui.FlaggedElement.call( this, config );

	// Properties
	this.toolGroup = toolGroup;
	this.toolbar = this.toolGroup.getToolbar();
	this.active = false;
	this.$title = $( '<span>' );
	this.$accel = $( '<span>' );
	this.$link = $( '<a>' );
	this.title = null;

	// Events
	this.toolbar.connect( this, { updateState: 'onUpdateState' } );

	// Initialization
	this.$title.addClass( 'oo-ui-tool-title' );
	this.$accel
		.addClass( 'oo-ui-tool-accel' )
		.prop( {
			// This may need to be changed if the key names are ever localized,
			// but for now they are essentially written in English
			dir: 'ltr',
			lang: 'en'
		} );
	this.$link
		.addClass( 'oo-ui-tool-link' )
		.append( this.$icon, this.$title, this.$accel )
		.prop( 'tabIndex', 0 )
		.attr( 'role', 'button' );
	this.$element
		.data( 'oo-ui-tool', this )
		.addClass(
			'oo-ui-tool ' + 'oo-ui-tool-name-' +
			this.constructor.static.name.replace( /^([^\/]+)\/([^\/]+).*$/, '$1-$2' )
		)
		.append( this.$link );
	this.setTitle( config.title || this.constructor.static.title );
};

/* Setup */

OO.inheritClass( OO.ui.Tool, OO.ui.Widget );
OO.mixinClass( OO.ui.Tool, OO.ui.IconElement );
OO.mixinClass( OO.ui.Tool, OO.ui.FlaggedElement );

/* Events */

/**
 * @event select
 */

/* Static Properties */

/**
 * @static
 * @inheritdoc
 */
OO.ui.Tool.static.tagName = 'span';

/**
 * Symbolic name of tool.
 *
 * @abstract
 * @static
 * @inheritable
 * @property {string}
 */
OO.ui.Tool.static.name = '';

/**
 * Tool group.
 *
 * @abstract
 * @static
 * @inheritable
 * @property {string}
 */
OO.ui.Tool.static.group = '';

/**
 * Tool title.
 *
 * Title is used as a tooltip when the tool is part of a bar tool group, or a label when the tool
 * is part of a list or menu tool group. If a trigger is associated with an action by the same name
 * as the tool, a description of its keyboard shortcut for the appropriate platform will be
 * appended to the title if the tool is part of a bar tool group.
 *
 * @abstract
 * @static
 * @inheritable
 * @property {string|Function} Title text or a function that returns text
 */
OO.ui.Tool.static.title = '';

/**
 * Tool can be automatically added to catch-all groups.
 *
 * @static
 * @inheritable
 * @property {boolean}
 */
OO.ui.Tool.static.autoAddToCatchall = true;

/**
 * Tool can be automatically added to named groups.
 *
 * @static
 * @property {boolean}
 * @inheritable
 */
OO.ui.Tool.static.autoAddToGroup = true;

/**
 * Check if this tool is compatible with given data.
 *
 * @static
 * @inheritable
 * @param {Mixed} data Data to check
 * @return {boolean} Tool can be used with data
 */
OO.ui.Tool.static.isCompatibleWith = function () {
	return false;
};

/* Methods */

/**
 * Handle the toolbar state being updated.
 *
 * This is an abstract method that must be overridden in a concrete subclass.
 *
 * @abstract
 */
OO.ui.Tool.prototype.onUpdateState = function () {
	throw new Error(
		'OO.ui.Tool.onUpdateState not implemented in this subclass:' + this.constructor
	);
};

/**
 * Handle the tool being selected.
 *
 * This is an abstract method that must be overridden in a concrete subclass.
 *
 * @abstract
 */
OO.ui.Tool.prototype.onSelect = function () {
	throw new Error(
		'OO.ui.Tool.onSelect not implemented in this subclass:' + this.constructor
	);
};

/**
 * Check if the button is active.
 *
 * @return {boolean} Button is active
 */
OO.ui.Tool.prototype.isActive = function () {
	return this.active;
};

/**
 * Make the button appear active or inactive.
 *
 * @param {boolean} state Make button appear active
 */
OO.ui.Tool.prototype.setActive = function ( state ) {
	this.active = !!state;
	if ( this.active ) {
		this.$element.addClass( 'oo-ui-tool-active' );
	} else {
		this.$element.removeClass( 'oo-ui-tool-active' );
	}
};

/**
 * Get the tool title.
 *
 * @param {string|Function} title Title text or a function that returns text
 * @chainable
 */
OO.ui.Tool.prototype.setTitle = function ( title ) {
	this.title = OO.ui.resolveMsg( title );
	this.updateTitle();
	return this;
};

/**
 * Get the tool title.
 *
 * @return {string} Title text
 */
OO.ui.Tool.prototype.getTitle = function () {
	return this.title;
};

/**
 * Get the tool's symbolic name.
 *
 * @return {string} Symbolic name of tool
 */
OO.ui.Tool.prototype.getName = function () {
	return this.constructor.static.name;
};

/**
 * Update the title.
 */
OO.ui.Tool.prototype.updateTitle = function () {
	var titleTooltips = this.toolGroup.constructor.static.titleTooltips,
		accelTooltips = this.toolGroup.constructor.static.accelTooltips,
		accel = this.toolbar.getToolAccelerator( this.constructor.static.name ),
		tooltipParts = [];

	this.$title.text( this.title );
	this.$accel.text( accel );

	if ( titleTooltips && typeof this.title === 'string' && this.title.length ) {
		tooltipParts.push( this.title );
	}
	if ( accelTooltips && typeof accel === 'string' && accel.length ) {
		tooltipParts.push( accel );
	}
	if ( tooltipParts.length ) {
		this.$link.attr( 'title', tooltipParts.join( ' ' ) );
	} else {
		this.$link.removeAttr( 'title' );
	}
};

/**
 * Destroy tool.
 */
OO.ui.Tool.prototype.destroy = function () {
	this.toolbar.disconnect( this );
	this.$element.remove();
};

/**
 * Collection of tool groups.
 *
 * @class
 * @extends OO.ui.Element
 * @mixins OO.EventEmitter
 * @mixins OO.ui.GroupElement
 *
 * @constructor
 * @param {OO.ui.ToolFactory} toolFactory Factory for creating tools
 * @param {OO.ui.ToolGroupFactory} toolGroupFactory Factory for creating tool groups
 * @param {Object} [config] Configuration options
 * @cfg {boolean} [actions] Add an actions section opposite to the tools
 * @cfg {boolean} [shadow] Add a shadow below the toolbar
 */
OO.ui.Toolbar = function OoUiToolbar( toolFactory, toolGroupFactory, config ) {
	// Allow passing positional parameters inside the config object
	if ( OO.isPlainObject( toolFactory ) && config === undefined ) {
		config = toolFactory;
		toolFactory = config.toolFactory;
		toolGroupFactory = config.toolGroupFactory;
	}

	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.Toolbar.super.call( this, config );

	// Mixin constructors
	OO.EventEmitter.call( this );
	OO.ui.GroupElement.call( this, config );

	// Properties
	this.toolFactory = toolFactory;
	this.toolGroupFactory = toolGroupFactory;
	this.groups = [];
	this.tools = {};
	this.$bar = $( '<div>' );
	this.$actions = $( '<div>' );
	this.initialized = false;

	// Events
	this.$element
		.add( this.$bar ).add( this.$group ).add( this.$actions )
		.on( 'mousedown touchstart', this.onPointerDown.bind( this ) );

	// Initialization
	this.$group.addClass( 'oo-ui-toolbar-tools' );
	if ( config.actions ) {
		this.$bar.append( this.$actions.addClass( 'oo-ui-toolbar-actions' ) );
	}
	this.$bar
		.addClass( 'oo-ui-toolbar-bar' )
		.append( this.$group, '<div style="clear:both"></div>' );
	if ( config.shadow ) {
		this.$bar.append( '<div class="oo-ui-toolbar-shadow"></div>' );
	}
	this.$element.addClass( 'oo-ui-toolbar' ).append( this.$bar );
};

/* Setup */

OO.inheritClass( OO.ui.Toolbar, OO.ui.Element );
OO.mixinClass( OO.ui.Toolbar, OO.EventEmitter );
OO.mixinClass( OO.ui.Toolbar, OO.ui.GroupElement );

/* Methods */

/**
 * Get the tool factory.
 *
 * @return {OO.ui.ToolFactory} Tool factory
 */
OO.ui.Toolbar.prototype.getToolFactory = function () {
	return this.toolFactory;
};

/**
 * Get the tool group factory.
 *
 * @return {OO.Factory} Tool group factory
 */
OO.ui.Toolbar.prototype.getToolGroupFactory = function () {
	return this.toolGroupFactory;
};

/**
 * Handles mouse down events.
 *
 * @param {jQuery.Event} e Mouse down event
 */
OO.ui.Toolbar.prototype.onPointerDown = function ( e ) {
	var $closestWidgetToEvent = $( e.target ).closest( '.oo-ui-widget' ),
		$closestWidgetToToolbar = this.$element.closest( '.oo-ui-widget' );
	if ( !$closestWidgetToEvent.length || $closestWidgetToEvent[ 0 ] === $closestWidgetToToolbar[ 0 ] ) {
		return false;
	}
};

/**
 * Sets up handles and preloads required information for the toolbar to work.
 * This must be called after it is attached to a visible document and before doing anything else.
 */
OO.ui.Toolbar.prototype.initialize = function () {
	this.initialized = true;
};

/**
 * Setup toolbar.
 *
 * Tools can be specified in the following ways:
 *
 * - A specific tool: `{ name: 'tool-name' }` or `'tool-name'`
 * - All tools in a group: `{ group: 'group-name' }`
 * - All tools: `'*'` - Using this will make the group a list with a "More" label by default
 *
 * @param {Object.<string,Array>} groups List of tool group configurations
 * @param {Array|string} [groups.include] Tools to include
 * @param {Array|string} [groups.exclude] Tools to exclude
 * @param {Array|string} [groups.promote] Tools to promote to the beginning
 * @param {Array|string} [groups.demote] Tools to demote to the end
 */
OO.ui.Toolbar.prototype.setup = function ( groups ) {
	var i, len, type, group,
		items = [],
		defaultType = 'bar';

	// Cleanup previous groups
	this.reset();

	// Build out new groups
	for ( i = 0, len = groups.length; i < len; i++ ) {
		group = groups[ i ];
		if ( group.include === '*' ) {
			// Apply defaults to catch-all groups
			if ( group.type === undefined ) {
				group.type = 'list';
			}
			if ( group.label === undefined ) {
				group.label = OO.ui.msg( 'ooui-toolbar-more' );
			}
		}
		// Check type has been registered
		type = this.getToolGroupFactory().lookup( group.type ) ? group.type : defaultType;
		items.push(
			this.getToolGroupFactory().create( type, this, group )
		);
	}
	this.addItems( items );
};

/**
 * Remove all tools and groups from the toolbar.
 */
OO.ui.Toolbar.prototype.reset = function () {
	var i, len;

	this.groups = [];
	this.tools = {};
	for ( i = 0, len = this.items.length; i < len; i++ ) {
		this.items[ i ].destroy();
	}
	this.clearItems();
};

/**
 * Destroys toolbar, removing event handlers and DOM elements.
 *
 * Call this whenever you are done using a toolbar.
 */
OO.ui.Toolbar.prototype.destroy = function () {
	this.reset();
	this.$element.remove();
};

/**
 * Check if tool has not been used yet.
 *
 * @param {string} name Symbolic name of tool
 * @return {boolean} Tool is available
 */
OO.ui.Toolbar.prototype.isToolAvailable = function ( name ) {
	return !this.tools[ name ];
};

/**
 * Prevent tool from being used again.
 *
 * @param {OO.ui.Tool} tool Tool to reserve
 */
OO.ui.Toolbar.prototype.reserveTool = function ( tool ) {
	this.tools[ tool.getName() ] = tool;
};

/**
 * Allow tool to be used again.
 *
 * @param {OO.ui.Tool} tool Tool to release
 */
OO.ui.Toolbar.prototype.releaseTool = function ( tool ) {
	delete this.tools[ tool.getName() ];
};

/**
 * Get accelerator label for tool.
 *
 * This is a stub that should be overridden to provide access to accelerator information.
 *
 * @param {string} name Symbolic name of tool
 * @return {string|undefined} Tool accelerator label if available
 */
OO.ui.Toolbar.prototype.getToolAccelerator = function () {
	return undefined;
};

/**
 * Collection of tools.
 *
 * Tools can be specified in the following ways:
 *
 * - A specific tool: `{ name: 'tool-name' }` or `'tool-name'`
 * - All tools in a group: `{ group: 'group-name' }`
 * - All tools: `'*'`
 *
 * @abstract
 * @class
 * @extends OO.ui.Widget
 * @mixins OO.ui.GroupElement
 *
 * @constructor
 * @param {OO.ui.Toolbar} toolbar
 * @param {Object} [config] Configuration options
 * @cfg {Array|string} [include=[]] List of tools to include
 * @cfg {Array|string} [exclude=[]] List of tools to exclude
 * @cfg {Array|string} [promote=[]] List of tools to promote to the beginning
 * @cfg {Array|string} [demote=[]] List of tools to demote to the end
 */
OO.ui.ToolGroup = function OoUiToolGroup( toolbar, config ) {
	// Allow passing positional parameters inside the config object
	if ( OO.isPlainObject( toolbar ) && config === undefined ) {
		config = toolbar;
		toolbar = config.toolbar;
	}

	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.ToolGroup.super.call( this, config );

	// Mixin constructors
	OO.ui.GroupElement.call( this, config );

	// Properties
	this.toolbar = toolbar;
	this.tools = {};
	this.pressed = null;
	this.autoDisabled = false;
	this.include = config.include || [];
	this.exclude = config.exclude || [];
	this.promote = config.promote || [];
	this.demote = config.demote || [];
	this.onCapturedMouseUpHandler = this.onCapturedMouseUp.bind( this );

	// Events
	this.$element.on( {
		'mousedown touchstart': this.onPointerDown.bind( this ),
		'mouseup touchend': this.onPointerUp.bind( this ),
		mouseover: this.onMouseOver.bind( this ),
		mouseout: this.onMouseOut.bind( this )
	} );
	this.toolbar.getToolFactory().connect( this, { register: 'onToolFactoryRegister' } );
	this.aggregate( { disable: 'itemDisable' } );
	this.connect( this, { itemDisable: 'updateDisabled' } );

	// Initialization
	this.$group.addClass( 'oo-ui-toolGroup-tools' );
	this.$element
		.addClass( 'oo-ui-toolGroup' )
		.append( this.$group );
	this.populate();
};

/* Setup */

OO.inheritClass( OO.ui.ToolGroup, OO.ui.Widget );
OO.mixinClass( OO.ui.ToolGroup, OO.ui.GroupElement );

/* Events */

/**
 * @event update
 */

/* Static Properties */

/**
 * Show labels in tooltips.
 *
 * @static
 * @inheritable
 * @property {boolean}
 */
OO.ui.ToolGroup.static.titleTooltips = false;

/**
 * Show acceleration labels in tooltips.
 *
 * @static
 * @inheritable
 * @property {boolean}
 */
OO.ui.ToolGroup.static.accelTooltips = false;

/**
 * Automatically disable the toolgroup when all tools are disabled
 *
 * @static
 * @inheritable
 * @property {boolean}
 */
OO.ui.ToolGroup.static.autoDisable = true;

/* Methods */

/**
 * @inheritdoc
 */
OO.ui.ToolGroup.prototype.isDisabled = function () {
	return this.autoDisabled || OO.ui.ToolGroup.super.prototype.isDisabled.apply( this, arguments );
};

/**
 * @inheritdoc
 */
OO.ui.ToolGroup.prototype.updateDisabled = function () {
	var i, item, allDisabled = true;

	if ( this.constructor.static.autoDisable ) {
		for ( i = this.items.length - 1; i >= 0; i-- ) {
			item = this.items[ i ];
			if ( !item.isDisabled() ) {
				allDisabled = false;
				break;
			}
		}
		this.autoDisabled = allDisabled;
	}
	OO.ui.ToolGroup.super.prototype.updateDisabled.apply( this, arguments );
};

/**
 * Handle mouse down events.
 *
 * @param {jQuery.Event} e Mouse down event
 */
OO.ui.ToolGroup.prototype.onPointerDown = function ( e ) {
	// e.which is 0 for touch events, 1 for left mouse button
	if ( !this.isDisabled() && e.which <= 1 ) {
		this.pressed = this.getTargetTool( e );
		if ( this.pressed ) {
			this.pressed.setActive( true );
			this.getElementDocument().addEventListener(
				'mouseup', this.onCapturedMouseUpHandler, true
			);
		}
	}
	return false;
};

/**
 * Handle captured mouse up events.
 *
 * @param {Event} e Mouse up event
 */
OO.ui.ToolGroup.prototype.onCapturedMouseUp = function ( e ) {
	this.getElementDocument().removeEventListener( 'mouseup', this.onCapturedMouseUpHandler, true );
	// onPointerUp may be called a second time, depending on where the mouse is when the button is
	// released, but since `this.pressed` will no longer be true, the second call will be ignored.
	this.onPointerUp( e );
};

/**
 * Handle mouse up events.
 *
 * @param {jQuery.Event} e Mouse up event
 */
OO.ui.ToolGroup.prototype.onPointerUp = function ( e ) {
	var tool = this.getTargetTool( e );

	// e.which is 0 for touch events, 1 for left mouse button
	if ( !this.isDisabled() && e.which <= 1 && this.pressed && this.pressed === tool ) {
		this.pressed.onSelect();
	}

	this.pressed = null;
	return false;
};

/**
 * Handle mouse over events.
 *
 * @param {jQuery.Event} e Mouse over event
 */
OO.ui.ToolGroup.prototype.onMouseOver = function ( e ) {
	var tool = this.getTargetTool( e );

	if ( this.pressed && this.pressed === tool ) {
		this.pressed.setActive( true );
	}
};

/**
 * Handle mouse out events.
 *
 * @param {jQuery.Event} e Mouse out event
 */
OO.ui.ToolGroup.prototype.onMouseOut = function ( e ) {
	var tool = this.getTargetTool( e );

	if ( this.pressed && this.pressed === tool ) {
		this.pressed.setActive( false );
	}
};

/**
 * Get the closest tool to a jQuery.Event.
 *
 * Only tool links are considered, which prevents other elements in the tool such as popups from
 * triggering tool group interactions.
 *
 * @private
 * @param {jQuery.Event} e
 * @return {OO.ui.Tool|null} Tool, `null` if none was found
 */
OO.ui.ToolGroup.prototype.getTargetTool = function ( e ) {
	var tool,
		$item = $( e.target ).closest( '.oo-ui-tool-link' );

	if ( $item.length ) {
		tool = $item.parent().data( 'oo-ui-tool' );
	}

	return tool && !tool.isDisabled() ? tool : null;
};

/**
 * Handle tool registry register events.
 *
 * If a tool is registered after the group is created, we must repopulate the list to account for:
 *
 * - a tool being added that may be included
 * - a tool already included being overridden
 *
 * @param {string} name Symbolic name of tool
 */
OO.ui.ToolGroup.prototype.onToolFactoryRegister = function () {
	this.populate();
};

/**
 * Get the toolbar this group is in.
 *
 * @return {OO.ui.Toolbar} Toolbar of group
 */
OO.ui.ToolGroup.prototype.getToolbar = function () {
	return this.toolbar;
};

/**
 * Add and remove tools based on configuration.
 */
OO.ui.ToolGroup.prototype.populate = function () {
	var i, len, name, tool,
		toolFactory = this.toolbar.getToolFactory(),
		names = {},
		add = [],
		remove = [],
		list = this.toolbar.getToolFactory().getTools(
			this.include, this.exclude, this.promote, this.demote
		);

	// Build a list of needed tools
	for ( i = 0, len = list.length; i < len; i++ ) {
		name = list[ i ];
		if (
			// Tool exists
			toolFactory.lookup( name ) &&
			// Tool is available or is already in this group
			( this.toolbar.isToolAvailable( name ) || this.tools[ name ] )
		) {
			// Hack to prevent infinite recursion via ToolGroupTool. We need to reserve the tool before
			// creating it, but we can't call reserveTool() yet because we haven't created the tool.
			this.toolbar.tools[ name ] = true;
			tool = this.tools[ name ];
			if ( !tool ) {
				// Auto-initialize tools on first use
				this.tools[ name ] = tool = toolFactory.create( name, this );
				tool.updateTitle();
			}
			this.toolbar.reserveTool( tool );
			add.push( tool );
			names[ name ] = true;
		}
	}
	// Remove tools that are no longer needed
	for ( name in this.tools ) {
		if ( !names[ name ] ) {
			this.tools[ name ].destroy();
			this.toolbar.releaseTool( this.tools[ name ] );
			remove.push( this.tools[ name ] );
			delete this.tools[ name ];
		}
	}
	if ( remove.length ) {
		this.removeItems( remove );
	}
	// Update emptiness state
	if ( add.length ) {
		this.$element.removeClass( 'oo-ui-toolGroup-empty' );
	} else {
		this.$element.addClass( 'oo-ui-toolGroup-empty' );
	}
	// Re-add tools (moving existing ones to new locations)
	this.addItems( add );
	// Disabled state may depend on items
	this.updateDisabled();
};

/**
 * Destroy tool group.
 */
OO.ui.ToolGroup.prototype.destroy = function () {
	var name;

	this.clearItems();
	this.toolbar.getToolFactory().disconnect( this );
	for ( name in this.tools ) {
		this.toolbar.releaseTool( this.tools[ name ] );
		this.tools[ name ].disconnect( this ).destroy();
		delete this.tools[ name ];
	}
	this.$element.remove();
};

/**
 * Dialog for showing a message.
 *
 * User interface:
 * - Registers two actions by default (safe and primary).
 * - Renders action widgets in the footer.
 *
 * @class
 * @extends OO.ui.Dialog
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
OO.ui.MessageDialog = function OoUiMessageDialog( config ) {
	// Parent constructor
	OO.ui.MessageDialog.super.call( this, config );

	// Properties
	this.verticalActionLayout = null;

	// Initialization
	this.$element.addClass( 'oo-ui-messageDialog' );
};

/* Inheritance */

OO.inheritClass( OO.ui.MessageDialog, OO.ui.Dialog );

/* Static Properties */

OO.ui.MessageDialog.static.name = 'message';

OO.ui.MessageDialog.static.size = 'small';

OO.ui.MessageDialog.static.verbose = false;

/**
 * Dialog title.
 *
 * A confirmation dialog's title should describe what the progressive action will do. An alert
 * dialog's title should describe what event occurred.
 *
 * @static
 * inheritable
 * @property {jQuery|string|Function|null}
 */
OO.ui.MessageDialog.static.title = null;

/**
 * A confirmation dialog's message should describe the consequences of the progressive action. An
 * alert dialog's message should describe why the event occurred.
 *
 * @static
 * inheritable
 * @property {jQuery|string|Function|null}
 */
OO.ui.MessageDialog.static.message = null;

OO.ui.MessageDialog.static.actions = [
	{ action: 'accept', label: OO.ui.deferMsg( 'ooui-dialog-message-accept' ), flags: 'primary' },
	{ action: 'reject', label: OO.ui.deferMsg( 'ooui-dialog-message-reject' ), flags: 'safe' }
];

/* Methods */

/**
 * @inheritdoc
 */
OO.ui.MessageDialog.prototype.setManager = function ( manager ) {
	OO.ui.MessageDialog.super.prototype.setManager.call( this, manager );

	// Events
	this.manager.connect( this, {
		resize: 'onResize'
	} );

	return this;
};

/**
 * @inheritdoc
 */
OO.ui.MessageDialog.prototype.onActionResize = function ( action ) {
	this.fitActions();
	return OO.ui.MessageDialog.super.prototype.onActionResize.call( this, action );
};

/**
 * Handle window resized events.
 */
OO.ui.MessageDialog.prototype.onResize = function () {
	var dialog = this;
	dialog.fitActions();
	// Wait for CSS transition to finish and do it again :(
	setTimeout( function () {
		dialog.fitActions();
	}, 300 );
};

/**
 * Toggle action layout between vertical and horizontal.
 *
 * @param {boolean} [value] Layout actions vertically, omit to toggle
 * @chainable
 */
OO.ui.MessageDialog.prototype.toggleVerticalActionLayout = function ( value ) {
	value = value === undefined ? !this.verticalActionLayout : !!value;

	if ( value !== this.verticalActionLayout ) {
		this.verticalActionLayout = value;
		this.$actions
			.toggleClass( 'oo-ui-messageDialog-actions-vertical', value )
			.toggleClass( 'oo-ui-messageDialog-actions-horizontal', !value );
	}

	return this;
};

/**
 * @inheritdoc
 */
OO.ui.MessageDialog.prototype.getActionProcess = function ( action ) {
	if ( action ) {
		return new OO.ui.Process( function () {
			this.close( { action: action } );
		}, this );
	}
	return OO.ui.MessageDialog.super.prototype.getActionProcess.call( this, action );
};

/**
 * @inheritdoc
 *
 * @param {Object} [data] Dialog opening data
 * @param {jQuery|string|Function|null} [data.title] Description of the action being confirmed
 * @param {jQuery|string|Function|null} [data.message] Description of the action's consequence
 * @param {boolean} [data.verbose] Message is verbose and should be styled as a long message
 * @param {Object[]} [data.actions] List of OO.ui.ActionOptionWidget configuration options for each
 *   action item
 */
OO.ui.MessageDialog.prototype.getSetupProcess = function ( data ) {
	data = data || {};

	// Parent method
	return OO.ui.MessageDialog.super.prototype.getSetupProcess.call( this, data )
		.next( function () {
			this.title.setLabel(
				data.title !== undefined ? data.title : this.constructor.static.title
			);
			this.message.setLabel(
				data.message !== undefined ? data.message : this.constructor.static.message
			);
			this.message.$element.toggleClass(
				'oo-ui-messageDialog-message-verbose',
				data.verbose !== undefined ? data.verbose : this.constructor.static.verbose
			);
		}, this );
};

/**
 * @inheritdoc
 */
OO.ui.MessageDialog.prototype.getBodyHeight = function () {
	var bodyHeight, oldOverflow,
		$scrollable = this.container.$element;

	oldOverflow = $scrollable[ 0 ].style.overflow;
	$scrollable[ 0 ].style.overflow = 'hidden';

	OO.ui.Element.static.reconsiderScrollbars( $scrollable[ 0 ] );

	bodyHeight = this.text.$element.outerHeight( true );
	$scrollable[ 0 ].style.overflow = oldOverflow;

	return bodyHeight;
};

/**
 * @inheritdoc
 */
OO.ui.MessageDialog.prototype.setDimensions = function ( dim ) {
	var $scrollable = this.container.$element;
	OO.ui.MessageDialog.super.prototype.setDimensions.call( this, dim );

	// Twiddle the overflow property, otherwise an unnecessary scrollbar will be produced.
	// Need to do it after transition completes (250ms), add 50ms just in case.
	setTimeout( function () {
		var oldOverflow = $scrollable[ 0 ].style.overflow;
		$scrollable[ 0 ].style.overflow = 'hidden';

		OO.ui.Element.static.reconsiderScrollbars( $scrollable[ 0 ] );

		$scrollable[ 0 ].style.overflow = oldOverflow;
	}, 300 );

	return this;
};

/**
 * @inheritdoc
 */
OO.ui.MessageDialog.prototype.initialize = function () {
	// Parent method
	OO.ui.MessageDialog.super.prototype.initialize.call( this );

	// Properties
	this.$actions = $( '<div>' );
	this.container = new OO.ui.PanelLayout( {
		scrollable: true, classes: [ 'oo-ui-messageDialog-container' ]
	} );
	this.text = new OO.ui.PanelLayout( {
		padded: true, expanded: false, classes: [ 'oo-ui-messageDialog-text' ]
	} );
	this.message = new OO.ui.LabelWidget( {
		classes: [ 'oo-ui-messageDialog-message' ]
	} );

	// Initialization
	this.title.$element.addClass( 'oo-ui-messageDialog-title' );
	this.$content.addClass( 'oo-ui-messageDialog-content' );
	this.container.$element.append( this.text.$element );
	this.text.$element.append( this.title.$element, this.message.$element );
	this.$body.append( this.container.$element );
	this.$actions.addClass( 'oo-ui-messageDialog-actions' );
	this.$foot.append( this.$actions );
};

/**
 * @inheritdoc
 */
OO.ui.MessageDialog.prototype.attachActions = function () {
	var i, len, other, special, others;

	// Parent method
	OO.ui.MessageDialog.super.prototype.attachActions.call( this );

	special = this.actions.getSpecial();
	others = this.actions.getOthers();
	if ( special.safe ) {
		this.$actions.append( special.safe.$element );
		special.safe.toggleFramed( false );
	}
	if ( others.length ) {
		for ( i = 0, len = others.length; i < len; i++ ) {
			other = others[ i ];
			this.$actions.append( other.$element );
			other.toggleFramed( false );
		}
	}
	if ( special.primary ) {
		this.$actions.append( special.primary.$element );
		special.primary.toggleFramed( false );
	}

	if ( !this.isOpening() ) {
		// If the dialog is currently opening, this will be called automatically soon.
		// This also calls #fitActions.
		this.updateSize();
	}
};

/**
 * Fit action actions into columns or rows.
 *
 * Columns will be used if all labels can fit without overflow, otherwise rows will be used.
 */
OO.ui.MessageDialog.prototype.fitActions = function () {
	var i, len, action,
		previous = this.verticalActionLayout,
		actions = this.actions.get();

	// Detect clipping
	this.toggleVerticalActionLayout( false );
	for ( i = 0, len = actions.length; i < len; i++ ) {
		action = actions[ i ];
		if ( action.$element.innerWidth() < action.$label.outerWidth( true ) ) {
			this.toggleVerticalActionLayout( true );
			break;
		}
	}

	// Move the body out of the way of the foot
	this.$body.css( 'bottom', this.$foot.outerHeight( true ) );

	if ( this.verticalActionLayout !== previous ) {
		// We changed the layout, window height might need to be updated.
		this.updateSize();
	}
};

/**
 * Navigation dialog window.
 *
 * Logic:
 * - Show and hide errors.
 * - Retry an action.
 *
 * User interface:
 * - Renders header with dialog title and one action widget on either side
 *   (a 'safe' button on the left, and a 'primary' button on the right, both of
 *   which close the dialog).
 * - Displays any action widgets in the footer (none by default).
 * - Ability to dismiss errors.
 *
 * Subclass responsibilities:
 * - Register a 'safe' action.
 * - Register a 'primary' action.
 * - Add content to the dialog.
 *
 * @abstract
 * @class
 * @extends OO.ui.Dialog
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
OO.ui.ProcessDialog = function OoUiProcessDialog( config ) {
	// Parent constructor
	OO.ui.ProcessDialog.super.call( this, config );

	// Initialization
	this.$element.addClass( 'oo-ui-processDialog' );
};

/* Setup */

OO.inheritClass( OO.ui.ProcessDialog, OO.ui.Dialog );

/* Methods */

/**
 * Handle dismiss button click events.
 *
 * Hides errors.
 */
OO.ui.ProcessDialog.prototype.onDismissErrorButtonClick = function () {
	this.hideErrors();
};

/**
 * Handle retry button click events.
 *
 * Hides errors and then tries again.
 */
OO.ui.ProcessDialog.prototype.onRetryButtonClick = function () {
	this.hideErrors();
	this.executeAction( this.currentAction );
};

/**
 * @inheritdoc
 */
OO.ui.ProcessDialog.prototype.onActionResize = function ( action ) {
	if ( this.actions.isSpecial( action ) ) {
		this.fitLabel();
	}
	return OO.ui.ProcessDialog.super.prototype.onActionResize.call( this, action );
};

/**
 * @inheritdoc
 */
OO.ui.ProcessDialog.prototype.initialize = function () {
	// Parent method
	OO.ui.ProcessDialog.super.prototype.initialize.call( this );

	// Properties
	this.$navigation = $( '<div>' );
	this.$location = $( '<div>' );
	this.$safeActions = $( '<div>' );
	this.$primaryActions = $( '<div>' );
	this.$otherActions = $( '<div>' );
	this.dismissButton = new OO.ui.ButtonWidget( {
		label: OO.ui.msg( 'ooui-dialog-process-dismiss' )
	} );
	this.retryButton = new OO.ui.ButtonWidget();
	this.$errors = $( '<div>' );
	this.$errorsTitle = $( '<div>' );

	// Events
	this.dismissButton.connect( this, { click: 'onDismissErrorButtonClick' } );
	this.retryButton.connect( this, { click: 'onRetryButtonClick' } );

	// Initialization
	this.title.$element.addClass( 'oo-ui-processDialog-title' );
	this.$location
		.append( this.title.$element )
		.addClass( 'oo-ui-processDialog-location' );
	this.$safeActions.addClass( 'oo-ui-processDialog-actions-safe' );
	this.$primaryActions.addClass( 'oo-ui-processDialog-actions-primary' );
	this.$otherActions.addClass( 'oo-ui-processDialog-actions-other' );
	this.$errorsTitle
		.addClass( 'oo-ui-processDialog-errors-title' )
		.text( OO.ui.msg( 'ooui-dialog-process-error' ) );
	this.$errors
		.addClass( 'oo-ui-processDialog-errors oo-ui-element-hidden' )
		.append( this.$errorsTitle, this.dismissButton.$element, this.retryButton.$element );
	this.$content
		.addClass( 'oo-ui-processDialog-content' )
		.append( this.$errors );
	this.$navigation
		.addClass( 'oo-ui-processDialog-navigation' )
		.append( this.$safeActions, this.$location, this.$primaryActions );
	this.$head.append( this.$navigation );
	this.$foot.append( this.$otherActions );
};

/**
 * @inheritdoc
 */
OO.ui.ProcessDialog.prototype.attachActions = function () {
	var i, len, other, special, others;

	// Parent method
	OO.ui.ProcessDialog.super.prototype.attachActions.call( this );

	special = this.actions.getSpecial();
	others = this.actions.getOthers();
	if ( special.primary ) {
		this.$primaryActions.append( special.primary.$element );
		special.primary.toggleFramed( true );
	}
	for ( i = 0, len = others.length; i < len; i++ ) {
		other = others[ i ];
		this.$otherActions.append( other.$element );
		other.toggleFramed( true );
	}
	if ( special.safe ) {
		this.$safeActions.append( special.safe.$element );
		special.safe.toggleFramed( true );
	}

	this.fitLabel();
	this.$body.css( 'bottom', this.$foot.outerHeight( true ) );
};

/**
 * @inheritdoc
 */
OO.ui.ProcessDialog.prototype.executeAction = function ( action ) {
	OO.ui.ProcessDialog.super.prototype.executeAction.call( this, action )
		.fail( this.showErrors.bind( this ) );
};

/**
 * Fit label between actions.
 *
 * @chainable
 */
OO.ui.ProcessDialog.prototype.fitLabel = function () {
	var width = Math.max(
		this.$safeActions.is( ':visible' ) ? this.$safeActions.width() : 0,
		this.$primaryActions.is( ':visible' ) ? this.$primaryActions.width() : 0
	);
	this.$location.css( { paddingLeft: width, paddingRight: width } );

	return this;
};

/**
 * Handle errors that occurred during accept or reject processes.
 *
 * @param {OO.ui.Error[]} errors Errors to be handled
 */
OO.ui.ProcessDialog.prototype.showErrors = function ( errors ) {
	var i, len, $item, actions,
		items = [],
		abilities = {},
		recoverable = true,
		warning = false;

	for ( i = 0, len = errors.length; i < len; i++ ) {
		if ( !errors[ i ].isRecoverable() ) {
			recoverable = false;
		}
		if ( errors[ i ].isWarning() ) {
			warning = true;
		}
		$item = $( '<div>' )
			.addClass( 'oo-ui-processDialog-error' )
			.append( errors[ i ].getMessage() );
		items.push( $item[ 0 ] );
	}
	this.$errorItems = $( items );
	if ( recoverable ) {
		abilities[this.currentAction] = true;
		// Copy the flags from the first matching action
		actions = this.actions.get( { actions: this.currentAction } );
		if ( actions.length ) {
			this.retryButton.clearFlags().setFlags( actions[0].getFlags() );
		}
	} else {
		abilities[this.currentAction] = false;
		this.actions.setAbilities( abilities );
	}
	if ( warning ) {
		this.retryButton.setLabel( OO.ui.msg( 'ooui-dialog-process-continue' ) );
	} else {
		this.retryButton.setLabel( OO.ui.msg( 'ooui-dialog-process-retry' ) );
	}
	this.retryButton.toggle( recoverable );
	this.$errorsTitle.after( this.$errorItems );
	this.$errors.removeClass( 'oo-ui-element-hidden' ).scrollTop( 0 );
};

/**
 * Hide errors.
 */
OO.ui.ProcessDialog.prototype.hideErrors = function () {
	this.$errors.addClass( 'oo-ui-element-hidden' );
	if ( this.$errorItems ) {
		this.$errorItems.remove();
		this.$errorItems = null;
	}
};

/**
 * @inheritdoc
 */
OO.ui.ProcessDialog.prototype.getTeardownProcess = function ( data ) {
	// Parent method
	return OO.ui.ProcessDialog.super.prototype.getTeardownProcess.call( this, data )
		.first( function () {
			// Make sure to hide errors
			this.hideErrors();
		}, this );
};

/**
 * FieldLayouts are used with OO.ui.FieldsetLayout. Each FieldLayout requires a field-widget,
 * which is a widget that is specified by reference before any optional configuration settings.
 *
 * Field layouts can be configured with help text and/or labels. Labels are aligned in one of four ways:
 *
 * - **left**: The label is placed before the field-widget and aligned with the left margin.
 *   A left-alignment is used for forms with many fields.
 * - **right**: The label is placed before the field-widget and aligned to the right margin.
 *   A right-alignment is used for long but familiar forms which users tab through,
 *   verifying the current field with a quick glance at the label.
 * - **top**: The label is placed above the field-widget. A top-alignment is used for brief forms
 *   that users fill out from top to bottom.
 * - **inline**: The label is placed after the field-widget and aligned to the left.
 *   An inline-alignment is best used with checkboxes or radio buttons.
 *
 * Help text is accessed via a help icon that appears in the upper right corner of the rendered field layout.
 * Please see the [OOjs UI documentation on MediaWiki] [1] for examples and more information.
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Layouts/Fields_and_Fieldsets
 * @class
 * @extends OO.ui.Layout
 * @mixins OO.ui.LabelElement
 *
 * @constructor
 * @param {OO.ui.Widget} fieldWidget Field widget
 * @param {Object} [config] Configuration options
 * @cfg {string} [align='left'] Alignment mode, either 'left', 'right', 'top' or 'inline'
 * @cfg {string} [help] Explanatory text shown as a '?' icon.
 */
OO.ui.FieldLayout = function OoUiFieldLayout( fieldWidget, config ) {
	// Allow passing positional parameters inside the config object
	if ( OO.isPlainObject( fieldWidget ) && config === undefined ) {
		config = fieldWidget;
		fieldWidget = config.fieldWidget;
	}

	var hasInputWidget = fieldWidget instanceof OO.ui.InputWidget;

	// Configuration initialization
	config = $.extend( { align: 'left' }, config );

	// Parent constructor
	OO.ui.FieldLayout.super.call( this, config );

	// Mixin constructors
	OO.ui.LabelElement.call( this, config );

	// Properties
	this.fieldWidget = fieldWidget;
	this.$field = $( '<div>' );
	this.$body = $( '<' + ( hasInputWidget ? 'label' : 'div' ) + '>' );
	this.align = null;
	if ( config.help ) {
		this.popupButtonWidget = new OO.ui.PopupButtonWidget( {
			classes: [ 'oo-ui-fieldLayout-help' ],
			framed: false,
			icon: 'info'
		} );

		this.popupButtonWidget.getPopup().$body.append(
			$( '<div>' )
				.text( config.help )
				.addClass( 'oo-ui-fieldLayout-help-content' )
		);
		this.$help = this.popupButtonWidget.$element;
	} else {
		this.$help = $( [] );
	}

	// Events
	if ( hasInputWidget ) {
		this.$label.on( 'click', this.onLabelClick.bind( this ) );
	}
	this.fieldWidget.connect( this, { disable: 'onFieldDisable' } );

	// Initialization
	this.$element
		.addClass( 'oo-ui-fieldLayout' )
		.append( this.$help, this.$body );
	this.$body.addClass( 'oo-ui-fieldLayout-body' );
	this.$field
		.addClass( 'oo-ui-fieldLayout-field' )
		.toggleClass( 'oo-ui-fieldLayout-disable', this.fieldWidget.isDisabled() )
		.append( this.fieldWidget.$element );

	this.setAlignment( config.align );
};

/* Setup */

OO.inheritClass( OO.ui.FieldLayout, OO.ui.Layout );
OO.mixinClass( OO.ui.FieldLayout, OO.ui.LabelElement );

/* Methods */

/**
 * Handle field disable events.
 *
 * @param {boolean} value Field is disabled
 */
OO.ui.FieldLayout.prototype.onFieldDisable = function ( value ) {
	this.$element.toggleClass( 'oo-ui-fieldLayout-disabled', value );
};

/**
 * Handle label mouse click events.
 *
 * @param {jQuery.Event} e Mouse click event
 */
OO.ui.FieldLayout.prototype.onLabelClick = function () {
	this.fieldWidget.simulateLabelClick();
	return false;
};

/**
 * Get the field.
 *
 * @return {OO.ui.Widget} Field widget
 */
OO.ui.FieldLayout.prototype.getField = function () {
	return this.fieldWidget;
};

/**
 * Set the field alignment mode.
 *
 * @private
 * @param {string} value Alignment mode, either 'left', 'right', 'top' or 'inline'
 * @chainable
 */
OO.ui.FieldLayout.prototype.setAlignment = function ( value ) {
	if ( value !== this.align ) {
		// Default to 'left'
		if ( [ 'left', 'right', 'top', 'inline' ].indexOf( value ) === -1 ) {
			value = 'left';
		}
		// Reorder elements
		if ( value === 'inline' ) {
			this.$body.append( this.$field, this.$label );
		} else {
			this.$body.append( this.$label, this.$field );
		}
		// Set classes. The following classes can be used here:
		// * oo-ui-fieldLayout-align-left
		// * oo-ui-fieldLayout-align-right
		// * oo-ui-fieldLayout-align-top
		// * oo-ui-fieldLayout-align-inline
		if ( this.align ) {
			this.$element.removeClass( 'oo-ui-fieldLayout-align-' + this.align );
		}
		this.$element.addClass( 'oo-ui-fieldLayout-align-' + value );
		this.align = value;
	}

	return this;
};

/**
 * Layout made of a field, a button, and an optional label.
 *
 * @class
 * @extends OO.ui.FieldLayout
 *
 * @constructor
 * @param {OO.ui.Widget} fieldWidget Field widget
 * @param {OO.ui.ButtonWidget} buttonWidget Button widget
 * @param {Object} [config] Configuration options
 * @cfg {string} [align='left'] Alignment mode, either 'left', 'right', 'top' or 'inline'
 * @cfg {string} [help] Explanatory text shown as a '?' icon.
 */
OO.ui.ActionFieldLayout = function OoUiActionFieldLayout( fieldWidget, buttonWidget, config ) {
	// Allow passing positional parameters inside the config object
	if ( OO.isPlainObject( fieldWidget ) && config === undefined ) {
		config = fieldWidget;
		fieldWidget = config.fieldWidget;
		buttonWidget = config.buttonWidget;
	}

	// Configuration initialization
	config = $.extend( { align: 'left' }, config );

	// Parent constructor
	OO.ui.ActionFieldLayout.super.call( this, fieldWidget, config );

	// Properties
	this.fieldWidget = fieldWidget;
	this.buttonWidget = buttonWidget;
	this.$button = $( '<div>' )
		.addClass( 'oo-ui-actionFieldLayout-button' )
		.append( this.buttonWidget.$element );
	this.$input = $( '<div>' )
		.addClass( 'oo-ui-actionFieldLayout-input' )
		.append( this.fieldWidget.$element );
	this.$field
		.addClass( 'oo-ui-actionFieldLayout' )
		.append( this.$input, this.$button );
};

/* Setup */

OO.inheritClass( OO.ui.ActionFieldLayout, OO.ui.FieldLayout );

/**
 * Layout made of a fieldset and optional legend.
 *
 * Just add OO.ui.FieldLayout items.
 *
 * @class
 * @extends OO.ui.Layout
 * @mixins OO.ui.IconElement
 * @mixins OO.ui.LabelElement
 * @mixins OO.ui.GroupElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {OO.ui.FieldLayout[]} [items] Items to add
 */
OO.ui.FieldsetLayout = function OoUiFieldsetLayout( config ) {
	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.FieldsetLayout.super.call( this, config );

	// Mixin constructors
	OO.ui.IconElement.call( this, config );
	OO.ui.LabelElement.call( this, config );
	OO.ui.GroupElement.call( this, config );

	if ( config.help ) {
		this.popupButtonWidget = new OO.ui.PopupButtonWidget( {
			classes: [ 'oo-ui-fieldsetLayout-help' ],
			framed: false,
			icon: 'info'
		} );

		this.popupButtonWidget.getPopup().$body.append(
			$( '<div>' )
				.text( config.help )
				.addClass( 'oo-ui-fieldsetLayout-help-content' )
		);
		this.$help = this.popupButtonWidget.$element;
	} else {
		this.$help = $( [] );
	}

	// Initialization
	this.$element
		.addClass( 'oo-ui-fieldsetLayout' )
		.prepend( this.$help, this.$icon, this.$label, this.$group );
	if ( Array.isArray( config.items ) ) {
		this.addItems( config.items );
	}
};

/* Setup */

OO.inheritClass( OO.ui.FieldsetLayout, OO.ui.Layout );
OO.mixinClass( OO.ui.FieldsetLayout, OO.ui.IconElement );
OO.mixinClass( OO.ui.FieldsetLayout, OO.ui.LabelElement );
OO.mixinClass( OO.ui.FieldsetLayout, OO.ui.GroupElement );

/**
 * Layout with an HTML form.
 *
 * @class
 * @extends OO.ui.Layout
 * @mixins OO.ui.GroupElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {string} [method] HTML form `method` attribute
 * @cfg {string} [action] HTML form `action` attribute
 * @cfg {string} [enctype] HTML form `enctype` attribute
 * @cfg {OO.ui.FieldsetLayout[]} [items] Items to add
 */
OO.ui.FormLayout = function OoUiFormLayout( config ) {
	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.FormLayout.super.call( this, config );

	// Mixin constructors
	OO.ui.GroupElement.call( this, $.extend( {}, config, { $group: this.$element } ) );

	// Events
	this.$element.on( 'submit', this.onFormSubmit.bind( this ) );

	// Initialization
	this.$element
		.addClass( 'oo-ui-formLayout' )
		.attr( {
			method: config.method,
			action: config.action,
			enctype: config.enctype
		} );
	if ( Array.isArray( config.items ) ) {
		this.addItems( config.items );
	}
};

/* Setup */

OO.inheritClass( OO.ui.FormLayout, OO.ui.Layout );
OO.mixinClass( OO.ui.FormLayout, OO.ui.GroupElement );

/* Events */

/**
 * @event submit
 */

/* Static Properties */

OO.ui.FormLayout.static.tagName = 'form';

/* Methods */

/**
 * Handle form submit events.
 *
 * @param {jQuery.Event} e Submit event
 * @fires submit
 */
OO.ui.FormLayout.prototype.onFormSubmit = function () {
	this.emit( 'submit' );
	return false;
};

/**
 * Layout with a content and menu area.
 *
 * The menu area can be positioned at the top, after, bottom or before. The content area will fill
 * all remaining space.
 *
 * @class
 * @extends OO.ui.Layout
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {number|string} [menuSize='18em'] Size of menu in pixels or any CSS unit
 * @cfg {boolean} [showMenu=true] Show menu
 * @cfg {string} [position='before'] Position of menu, either `top`, `after`, `bottom` or `before`
 * @cfg {boolean} [collapse] Collapse the menu out of view
 */
OO.ui.MenuLayout = function OoUiMenuLayout( config ) {
	var positions = this.constructor.static.menuPositions;

	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.MenuLayout.super.call( this, config );

	// Properties
	this.showMenu = config.showMenu !== false;
	this.menuSize = config.menuSize || '18em';
	this.menuPosition = positions[ config.menuPosition ] || positions.before;

	/**
	 * Menu DOM node
	 *
	 * @property {jQuery}
	 */
	this.$menu = $( '<div>' );
	/**
	 * Content DOM node
	 *
	 * @property {jQuery}
	 */
	this.$content = $( '<div>' );

	// Initialization
	this.toggleMenu( this.showMenu );
	this.updateSizes();
	this.$menu
		.addClass( 'oo-ui-menuLayout-menu' )
		.css( this.menuPosition.sizeProperty, this.menuSize );
	this.$content.addClass( 'oo-ui-menuLayout-content' );
	this.$element
		.addClass( 'oo-ui-menuLayout ' + this.menuPosition.className )
		.append( this.$content, this.$menu );
};

/* Setup */

OO.inheritClass( OO.ui.MenuLayout, OO.ui.Layout );

/* Static Properties */

OO.ui.MenuLayout.static.menuPositions = {
	top: {
		sizeProperty: 'height',
		className: 'oo-ui-menuLayout-top'
	},
	after: {
		sizeProperty: 'width',
		className: 'oo-ui-menuLayout-after'
	},
	bottom: {
		sizeProperty: 'height',
		className: 'oo-ui-menuLayout-bottom'
	},
	before: {
		sizeProperty: 'width',
		className: 'oo-ui-menuLayout-before'
	}
};

/* Methods */

/**
 * Toggle menu.
 *
 * @param {boolean} showMenu Show menu, omit to toggle
 * @chainable
 */
OO.ui.MenuLayout.prototype.toggleMenu = function ( showMenu ) {
	showMenu = showMenu === undefined ? !this.showMenu : !!showMenu;

	if ( this.showMenu !== showMenu ) {
		this.showMenu = showMenu;
		this.updateSizes();
	}

	return this;
};

/**
 * Check if menu is visible
 *
 * @return {boolean} Menu is visible
 */
OO.ui.MenuLayout.prototype.isMenuVisible = function () {
	return this.showMenu;
};

/**
 * Set menu size.
 *
 * @param {number|string} size Size of menu in pixels or any CSS unit
 * @chainable
 */
OO.ui.MenuLayout.prototype.setMenuSize = function ( size ) {
	this.menuSize = size;
	this.updateSizes();

	return this;
};

/**
 * Update menu and content CSS based on current menu size and visibility
 *
 * This method is called internally when size or position is changed.
 */
OO.ui.MenuLayout.prototype.updateSizes = function () {
	if ( this.showMenu ) {
		this.$menu
			.css( this.menuPosition.sizeProperty, this.menuSize )
			.css( 'overflow', '' );
		// Set offsets on all sides. CSS resets all but one with
		// 'important' rules so directionality flips are supported
		this.$content.css( {
			top: this.menuSize,
			right: this.menuSize,
			bottom: this.menuSize,
			left: this.menuSize
		} );
	} else {
		this.$menu
			.css( this.menuPosition.sizeProperty, 0 )
			.css( 'overflow', 'hidden' );
		this.$content.css( {
			top: 0,
			right: 0,
			bottom: 0,
			left: 0
		} );
	}
};

/**
 * Get menu size.
 *
 * @return {number|string} Menu size
 */
OO.ui.MenuLayout.prototype.getMenuSize = function () {
	return this.menuSize;
};

/**
 * Set menu position.
 *
 * @param {string} position Position of menu, either `top`, `after`, `bottom` or `before`
 * @throws {Error} If position value is not supported
 * @chainable
 */
OO.ui.MenuLayout.prototype.setMenuPosition = function ( position ) {
	var positions = this.constructor.static.menuPositions;

	if ( !positions[ position ] ) {
		throw new Error( 'Cannot set position; unsupported position value: ' + position );
	}

	this.$menu.css( this.menuPosition.sizeProperty, '' );
	this.$element.removeClass( this.menuPosition.className );

	this.menuPosition = positions[ position ];

	this.updateSizes();
	this.$element.addClass( this.menuPosition.className );

	return this;
};

/**
 * Get menu position.
 *
 * @return {string} Menu position
 */
OO.ui.MenuLayout.prototype.getMenuPosition = function () {
	return this.menuPosition;
};

/**
 * Layout containing a series of pages.
 *
 * @class
 * @extends OO.ui.MenuLayout
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {boolean} [continuous=false] Show all pages, one after another
 * @cfg {boolean} [autoFocus=true] Focus on the first focusable element when changing to a page
 * @cfg {boolean} [outlined=false] Show an outline
 * @cfg {boolean} [editable=false] Show controls for adding, removing and reordering pages
 */
OO.ui.BookletLayout = function OoUiBookletLayout( config ) {
	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.BookletLayout.super.call( this, config );

	// Properties
	this.currentPageName = null;
	this.pages = {};
	this.ignoreFocus = false;
	this.stackLayout = new OO.ui.StackLayout( { continuous: !!config.continuous } );
	this.$content.append( this.stackLayout.$element );
	this.autoFocus = config.autoFocus === undefined || !!config.autoFocus;
	this.outlineVisible = false;
	this.outlined = !!config.outlined;
	if ( this.outlined ) {
		this.editable = !!config.editable;
		this.outlineControlsWidget = null;
		this.outlineSelectWidget = new OO.ui.OutlineSelectWidget();
		this.outlinePanel = new OO.ui.PanelLayout( { scrollable: true } );
		this.$menu.append( this.outlinePanel.$element );
		this.outlineVisible = true;
		if ( this.editable ) {
			this.outlineControlsWidget = new OO.ui.OutlineControlsWidget(
				this.outlineSelectWidget
			);
		}
	}
	this.toggleMenu( this.outlined );

	// Events
	this.stackLayout.connect( this, { set: 'onStackLayoutSet' } );
	if ( this.outlined ) {
		this.outlineSelectWidget.connect( this, { select: 'onOutlineSelectWidgetSelect' } );
	}
	if ( this.autoFocus ) {
		// Event 'focus' does not bubble, but 'focusin' does
		this.stackLayout.$element.on( 'focusin', this.onStackLayoutFocus.bind( this ) );
	}

	// Initialization
	this.$element.addClass( 'oo-ui-bookletLayout' );
	this.stackLayout.$element.addClass( 'oo-ui-bookletLayout-stackLayout' );
	if ( this.outlined ) {
		this.outlinePanel.$element
			.addClass( 'oo-ui-bookletLayout-outlinePanel' )
			.append( this.outlineSelectWidget.$element );
		if ( this.editable ) {
			this.outlinePanel.$element
				.addClass( 'oo-ui-bookletLayout-outlinePanel-editable' )
				.append( this.outlineControlsWidget.$element );
		}
	}
};

/* Setup */

OO.inheritClass( OO.ui.BookletLayout, OO.ui.MenuLayout );

/* Events */

/**
 * @event set
 * @param {OO.ui.PageLayout} page Current page
 */

/**
 * @event add
 * @param {OO.ui.PageLayout[]} page Added pages
 * @param {number} index Index pages were added at
 */

/**
 * @event remove
 * @param {OO.ui.PageLayout[]} pages Removed pages
 */

/* Methods */

/**
 * Handle stack layout focus.
 *
 * @param {jQuery.Event} e Focusin event
 */
OO.ui.BookletLayout.prototype.onStackLayoutFocus = function ( e ) {
	var name, $target;

	// Find the page that an element was focused within
	$target = $( e.target ).closest( '.oo-ui-pageLayout' );
	for ( name in this.pages ) {
		// Check for page match, exclude current page to find only page changes
		if ( this.pages[ name ].$element[ 0 ] === $target[ 0 ] && name !== this.currentPageName ) {
			this.setPage( name );
			break;
		}
	}
};

/**
 * Handle stack layout set events.
 *
 * @param {OO.ui.PanelLayout|null} page The page panel that is now the current panel
 */
OO.ui.BookletLayout.prototype.onStackLayoutSet = function ( page ) {
	var layout = this;
	if ( page ) {
		page.scrollElementIntoView( { complete: function () {
			if ( layout.autoFocus ) {
				layout.focus();
			}
		} } );
	}
};

/**
 * Focus the first input in the current page.
 *
 * If no page is selected, the first selectable page will be selected.
 * If the focus is already in an element on the current page, nothing will happen.
 */
OO.ui.BookletLayout.prototype.focus = function () {
	var $input, page = this.stackLayout.getCurrentItem();
	if ( !page && this.outlined ) {
		this.selectFirstSelectablePage();
		page = this.stackLayout.getCurrentItem();
	}
	if ( !page ) {
		return;
	}
	// Only change the focus if is not already in the current page
	if ( !page.$element.find( ':focus' ).length ) {
		$input = page.$element.find( ':input:first' );
		if ( $input.length ) {
			$input[ 0 ].focus();
		}
	}
};

/**
 * Handle outline widget select events.
 *
 * @param {OO.ui.OptionWidget|null} item Selected item
 */
OO.ui.BookletLayout.prototype.onOutlineSelectWidgetSelect = function ( item ) {
	if ( item ) {
		this.setPage( item.getData() );
	}
};

/**
 * Check if booklet has an outline.
 *
 * @return {boolean}
 */
OO.ui.BookletLayout.prototype.isOutlined = function () {
	return this.outlined;
};

/**
 * Check if booklet has editing controls.
 *
 * @return {boolean}
 */
OO.ui.BookletLayout.prototype.isEditable = function () {
	return this.editable;
};

/**
 * Check if booklet has a visible outline.
 *
 * @return {boolean}
 */
OO.ui.BookletLayout.prototype.isOutlineVisible = function () {
	return this.outlined && this.outlineVisible;
};

/**
 * Hide or show the outline.
 *
 * @param {boolean} [show] Show outline, omit to invert current state
 * @chainable
 */
OO.ui.BookletLayout.prototype.toggleOutline = function ( show ) {
	if ( this.outlined ) {
		show = show === undefined ? !this.outlineVisible : !!show;
		this.outlineVisible = show;
		this.toggleMenu( show );
	}

	return this;
};

/**
 * Get the outline widget.
 *
 * @param {OO.ui.PageLayout} page Page to be selected
 * @return {OO.ui.PageLayout|null} Closest page to another
 */
OO.ui.BookletLayout.prototype.getClosestPage = function ( page ) {
	var next, prev, level,
		pages = this.stackLayout.getItems(),
		index = $.inArray( page, pages );

	if ( index !== -1 ) {
		next = pages[ index + 1 ];
		prev = pages[ index - 1 ];
		// Prefer adjacent pages at the same level
		if ( this.outlined ) {
			level = this.outlineSelectWidget.getItemFromData( page.getName() ).getLevel();
			if (
				prev &&
				level === this.outlineSelectWidget.getItemFromData( prev.getName() ).getLevel()
			) {
				return prev;
			}
			if (
				next &&
				level === this.outlineSelectWidget.getItemFromData( next.getName() ).getLevel()
			) {
				return next;
			}
		}
	}
	return prev || next || null;
};

/**
 * Get the outline widget.
 *
 * @return {OO.ui.OutlineSelectWidget|null} Outline widget, or null if booklet has no outline
 */
OO.ui.BookletLayout.prototype.getOutline = function () {
	return this.outlineSelectWidget;
};

/**
 * Get the outline controls widget. If the outline is not editable, null is returned.
 *
 * @return {OO.ui.OutlineControlsWidget|null} The outline controls widget.
 */
OO.ui.BookletLayout.prototype.getOutlineControls = function () {
	return this.outlineControlsWidget;
};

/**
 * Get a page by name.
 *
 * @param {string} name Symbolic name of page
 * @return {OO.ui.PageLayout|undefined} Page, if found
 */
OO.ui.BookletLayout.prototype.getPage = function ( name ) {
	return this.pages[ name ];
};

/**
 * Get the current page
 *
 * @return {OO.ui.PageLayout|undefined} Current page, if found
 */
OO.ui.BookletLayout.prototype.getCurrentPage = function () {
	var name = this.getCurrentPageName();
	return name ? this.getPage( name ) : undefined;
};

/**
 * Get the current page name.
 *
 * @return {string|null} Current page name
 */
OO.ui.BookletLayout.prototype.getCurrentPageName = function () {
	return this.currentPageName;
};

/**
 * Add a page to the layout.
 *
 * When pages are added with the same names as existing pages, the existing pages will be
 * automatically removed before the new pages are added.
 *
 * @param {OO.ui.PageLayout[]} pages Pages to add
 * @param {number} index Index to insert pages after
 * @fires add
 * @chainable
 */
OO.ui.BookletLayout.prototype.addPages = function ( pages, index ) {
	var i, len, name, page, item, currentIndex,
		stackLayoutPages = this.stackLayout.getItems(),
		remove = [],
		items = [];

	// Remove pages with same names
	for ( i = 0, len = pages.length; i < len; i++ ) {
		page = pages[ i ];
		name = page.getName();

		if ( Object.prototype.hasOwnProperty.call( this.pages, name ) ) {
			// Correct the insertion index
			currentIndex = $.inArray( this.pages[ name ], stackLayoutPages );
			if ( currentIndex !== -1 && currentIndex + 1 < index ) {
				index--;
			}
			remove.push( this.pages[ name ] );
		}
	}
	if ( remove.length ) {
		this.removePages( remove );
	}

	// Add new pages
	for ( i = 0, len = pages.length; i < len; i++ ) {
		page = pages[ i ];
		name = page.getName();
		this.pages[ page.getName() ] = page;
		if ( this.outlined ) {
			item = new OO.ui.OutlineOptionWidget( { data: name } );
			page.setOutlineItem( item );
			items.push( item );
		}
	}

	if ( this.outlined && items.length ) {
		this.outlineSelectWidget.addItems( items, index );
		this.selectFirstSelectablePage();
	}
	this.stackLayout.addItems( pages, index );
	this.emit( 'add', pages, index );

	return this;
};

/**
 * Remove a page from the layout.
 *
 * @fires remove
 * @chainable
 */
OO.ui.BookletLayout.prototype.removePages = function ( pages ) {
	var i, len, name, page,
		items = [];

	for ( i = 0, len = pages.length; i < len; i++ ) {
		page = pages[ i ];
		name = page.getName();
		delete this.pages[ name ];
		if ( this.outlined ) {
			items.push( this.outlineSelectWidget.getItemFromData( name ) );
			page.setOutlineItem( null );
		}
	}
	if ( this.outlined && items.length ) {
		this.outlineSelectWidget.removeItems( items );
		this.selectFirstSelectablePage();
	}
	this.stackLayout.removeItems( pages );
	this.emit( 'remove', pages );

	return this;
};

/**
 * Clear all pages from the layout.
 *
 * @fires remove
 * @chainable
 */
OO.ui.BookletLayout.prototype.clearPages = function () {
	var i, len,
		pages = this.stackLayout.getItems();

	this.pages = {};
	this.currentPageName = null;
	if ( this.outlined ) {
		this.outlineSelectWidget.clearItems();
		for ( i = 0, len = pages.length; i < len; i++ ) {
			pages[ i ].setOutlineItem( null );
		}
	}
	this.stackLayout.clearItems();

	this.emit( 'remove', pages );

	return this;
};

/**
 * Set the current page by name.
 *
 * @fires set
 * @param {string} name Symbolic name of page
 */
OO.ui.BookletLayout.prototype.setPage = function ( name ) {
	var selectedItem,
		$focused,
		page = this.pages[ name ];

	if ( name !== this.currentPageName ) {
		if ( this.outlined ) {
			selectedItem = this.outlineSelectWidget.getSelectedItem();
			if ( selectedItem && selectedItem.getData() !== name ) {
				this.outlineSelectWidget.selectItem( this.outlineSelectWidget.getItemFromData( name ) );
			}
		}
		if ( page ) {
			if ( this.currentPageName && this.pages[ this.currentPageName ] ) {
				this.pages[ this.currentPageName ].setActive( false );
				// Blur anything focused if the next page doesn't have anything focusable - this
				// is not needed if the next page has something focusable because once it is focused
				// this blur happens automatically
				if ( this.autoFocus && !page.$element.find( ':input' ).length ) {
					$focused = this.pages[ this.currentPageName ].$element.find( ':focus' );
					if ( $focused.length ) {
						$focused[ 0 ].blur();
					}
				}
			}
			this.currentPageName = name;
			this.stackLayout.setItem( page );
			page.setActive( true );
			this.emit( 'set', page );
		}
	}
};

/**
 * Select the first selectable page.
 *
 * @chainable
 */
OO.ui.BookletLayout.prototype.selectFirstSelectablePage = function () {
	if ( !this.outlineSelectWidget.getSelectedItem() ) {
		this.outlineSelectWidget.selectItem( this.outlineSelectWidget.getFirstSelectableItem() );
	}

	return this;
};

/**
 * Layout that expands to cover the entire area of its parent, with optional scrolling and padding.
 *
 * @class
 * @extends OO.ui.Layout
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {boolean} [scrollable=false] Allow vertical scrolling
 * @cfg {boolean} [padded=false] Pad the content from the edges
 * @cfg {boolean} [expanded=true] Expand size to fill the entire parent element
 */
OO.ui.PanelLayout = function OoUiPanelLayout( config ) {
	// Configuration initialization
	config = $.extend( {
		scrollable: false,
		padded: false,
		expanded: true
	}, config );

	// Parent constructor
	OO.ui.PanelLayout.super.call( this, config );

	// Initialization
	this.$element.addClass( 'oo-ui-panelLayout' );
	if ( config.scrollable ) {
		this.$element.addClass( 'oo-ui-panelLayout-scrollable' );
	}
	if ( config.padded ) {
		this.$element.addClass( 'oo-ui-panelLayout-padded' );
	}
	if ( config.expanded ) {
		this.$element.addClass( 'oo-ui-panelLayout-expanded' );
	}
};

/* Setup */

OO.inheritClass( OO.ui.PanelLayout, OO.ui.Layout );

/**
 * Page within an booklet layout.
 *
 * @class
 * @extends OO.ui.PanelLayout
 *
 * @constructor
 * @param {string} name Unique symbolic name of page
 * @param {Object} [config] Configuration options
 */
OO.ui.PageLayout = function OoUiPageLayout( name, config ) {
	// Allow passing positional parameters inside the config object
	if ( OO.isPlainObject( name ) && config === undefined ) {
		config = name;
		name = config.name;
	}

	// Configuration initialization
	config = $.extend( { scrollable: true }, config );

	// Parent constructor
	OO.ui.PageLayout.super.call( this, config );

	// Properties
	this.name = name;
	this.outlineItem = null;
	this.active = false;

	// Initialization
	this.$element.addClass( 'oo-ui-pageLayout' );
};

/* Setup */

OO.inheritClass( OO.ui.PageLayout, OO.ui.PanelLayout );

/* Events */

/**
 * @event active
 * @param {boolean} active Page is active
 */

/* Methods */

/**
 * Get page name.
 *
 * @return {string} Symbolic name of page
 */
OO.ui.PageLayout.prototype.getName = function () {
	return this.name;
};

/**
 * Check if page is active.
 *
 * @return {boolean} Page is active
 */
OO.ui.PageLayout.prototype.isActive = function () {
	return this.active;
};

/**
 * Get outline item.
 *
 * @return {OO.ui.OutlineOptionWidget|null} Outline item widget
 */
OO.ui.PageLayout.prototype.getOutlineItem = function () {
	return this.outlineItem;
};

/**
 * Set outline item.
 *
 * @localdoc Subclasses should override #setupOutlineItem instead of this method to adjust the
 *   outline item as desired; this method is called for setting (with an object) and unsetting
 *   (with null) and overriding methods would have to check the value of `outlineItem` to avoid
 *   operating on null instead of an OO.ui.OutlineOptionWidget object.
 *
 * @param {OO.ui.OutlineOptionWidget|null} outlineItem Outline item widget, null to clear
 * @chainable
 */
OO.ui.PageLayout.prototype.setOutlineItem = function ( outlineItem ) {
	this.outlineItem = outlineItem || null;
	if ( outlineItem ) {
		this.setupOutlineItem();
	}
	return this;
};

/**
 * Setup outline item.
 *
 * @localdoc Subclasses should override this method to adjust the outline item as desired.
 *
 * @param {OO.ui.OutlineOptionWidget} outlineItem Outline item widget to setup
 * @chainable
 */
OO.ui.PageLayout.prototype.setupOutlineItem = function () {
	return this;
};

/**
 * Set page active state.
 *
 * @param {boolean} Page is active
 * @fires active
 */
OO.ui.PageLayout.prototype.setActive = function ( active ) {
	active = !!active;

	if ( active !== this.active ) {
		this.active = active;
		this.$element.toggleClass( 'oo-ui-pageLayout-active', active );
		this.emit( 'active', this.active );
	}
};

/**
 * Layout containing a series of mutually exclusive pages.
 *
 * @class
 * @extends OO.ui.PanelLayout
 * @mixins OO.ui.GroupElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {boolean} [continuous=false] Show all pages, one after another
 * @cfg {OO.ui.Layout[]} [items] Layouts to add
 */
OO.ui.StackLayout = function OoUiStackLayout( config ) {
	// Configuration initialization
	config = $.extend( { scrollable: true }, config );

	// Parent constructor
	OO.ui.StackLayout.super.call( this, config );

	// Mixin constructors
	OO.ui.GroupElement.call( this, $.extend( {}, config, { $group: this.$element } ) );

	// Properties
	this.currentItem = null;
	this.continuous = !!config.continuous;

	// Initialization
	this.$element.addClass( 'oo-ui-stackLayout' );
	if ( this.continuous ) {
		this.$element.addClass( 'oo-ui-stackLayout-continuous' );
	}
	if ( Array.isArray( config.items ) ) {
		this.addItems( config.items );
	}
};

/* Setup */

OO.inheritClass( OO.ui.StackLayout, OO.ui.PanelLayout );
OO.mixinClass( OO.ui.StackLayout, OO.ui.GroupElement );

/* Events */

/**
 * @event set
 * @param {OO.ui.Layout|null} item Current item or null if there is no longer a layout shown
 */

/* Methods */

/**
 * Get the current item.
 *
 * @return {OO.ui.Layout|null}
 */
OO.ui.StackLayout.prototype.getCurrentItem = function () {
	return this.currentItem;
};

/**
 * Unset the current item.
 *
 * @private
 * @param {OO.ui.StackLayout} layout
 * @fires set
 */
OO.ui.StackLayout.prototype.unsetCurrentItem = function () {
	var prevItem = this.currentItem;
	if ( prevItem === null ) {
		return;
	}

	this.currentItem = null;
	this.emit( 'set', null );
};

/**
 * Add items.
 *
 * Adding an existing item (by value) will move it.
 *
 * @param {OO.ui.Layout[]} items Items to add
 * @param {number} [index] Index to insert items after
 * @chainable
 */
OO.ui.StackLayout.prototype.addItems = function ( items, index ) {
	// Update the visibility
	this.updateHiddenState( items, this.currentItem );

	// Mixin method
	OO.ui.GroupElement.prototype.addItems.call( this, items, index );

	if ( !this.currentItem && items.length ) {
		this.setItem( items[ 0 ] );
	}

	return this;
};

/**
 * Remove items.
 *
 * Items will be detached, not removed, so they can be used later.
 *
 * @param {OO.ui.Layout[]} items Items to remove
 * @chainable
 * @fires set
 */
OO.ui.StackLayout.prototype.removeItems = function ( items ) {
	// Mixin method
	OO.ui.GroupElement.prototype.removeItems.call( this, items );

	if ( $.inArray( this.currentItem, items ) !== -1 ) {
		if ( this.items.length ) {
			this.setItem( this.items[ 0 ] );
		} else {
			this.unsetCurrentItem();
		}
	}

	return this;
};

/**
 * Clear all items.
 *
 * Items will be detached, not removed, so they can be used later.
 *
 * @chainable
 * @fires set
 */
OO.ui.StackLayout.prototype.clearItems = function () {
	this.unsetCurrentItem();
	OO.ui.GroupElement.prototype.clearItems.call( this );

	return this;
};

/**
 * Show item.
 *
 * Any currently shown item will be hidden.
 *
 * FIXME: If the passed item to show has not been added in the items list, then
 * this method drops it and unsets the current item.
 *
 * @param {OO.ui.Layout} item Item to show
 * @chainable
 * @fires set
 */
OO.ui.StackLayout.prototype.setItem = function ( item ) {
	if ( item !== this.currentItem ) {
		this.updateHiddenState( this.items, item );

		if ( $.inArray( item, this.items ) !== -1 ) {
			this.currentItem = item;
			this.emit( 'set', item );
		} else {
			this.unsetCurrentItem();
		}
	}

	return this;
};

/**
 * Update the visibility of all items in case of non-continuous view.
 *
 * Ensure all items are hidden except for the selected one.
 * This method does nothing when the stack is continuous.
 *
 * @param {OO.ui.Layout[]} items Item list iterate over
 * @param {OO.ui.Layout} [selectedItem] Selected item to show
 */
OO.ui.StackLayout.prototype.updateHiddenState = function ( items, selectedItem ) {
	var i, len;

	if ( !this.continuous ) {
		for ( i = 0, len = items.length; i < len; i++ ) {
			if ( !selectedItem || selectedItem !== items[ i ] ) {
				items[ i ].$element.addClass( 'oo-ui-element-hidden' );
			}
		}
		if ( selectedItem ) {
			selectedItem.$element.removeClass( 'oo-ui-element-hidden' );
		}
	}
};

/**
 * Horizontal bar layout of tools as icon buttons.
 *
 * @class
 * @extends OO.ui.ToolGroup
 *
 * @constructor
 * @param {OO.ui.Toolbar} toolbar
 * @param {Object} [config] Configuration options
 */
OO.ui.BarToolGroup = function OoUiBarToolGroup( toolbar, config ) {
	// Allow passing positional parameters inside the config object
	if ( OO.isPlainObject( toolbar ) && config === undefined ) {
		config = toolbar;
		toolbar = config.toolbar;
	}

	// Parent constructor
	OO.ui.BarToolGroup.super.call( this, toolbar, config );

	// Initialization
	this.$element.addClass( 'oo-ui-barToolGroup' );
};

/* Setup */

OO.inheritClass( OO.ui.BarToolGroup, OO.ui.ToolGroup );

/* Static Properties */

OO.ui.BarToolGroup.static.titleTooltips = true;

OO.ui.BarToolGroup.static.accelTooltips = true;

OO.ui.BarToolGroup.static.name = 'bar';

/**
 * Popup list of tools with an icon and optional label.
 *
 * @abstract
 * @class
 * @extends OO.ui.ToolGroup
 * @mixins OO.ui.IconElement
 * @mixins OO.ui.IndicatorElement
 * @mixins OO.ui.LabelElement
 * @mixins OO.ui.TitledElement
 * @mixins OO.ui.ClippableElement
 *
 * @constructor
 * @param {OO.ui.Toolbar} toolbar
 * @param {Object} [config] Configuration options
 * @cfg {string} [header] Text to display at the top of the pop-up
 */
OO.ui.PopupToolGroup = function OoUiPopupToolGroup( toolbar, config ) {
	// Allow passing positional parameters inside the config object
	if ( OO.isPlainObject( toolbar ) && config === undefined ) {
		config = toolbar;
		toolbar = config.toolbar;
	}

	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.PopupToolGroup.super.call( this, toolbar, config );

	// Mixin constructors
	OO.ui.IconElement.call( this, config );
	OO.ui.IndicatorElement.call( this, config );
	OO.ui.LabelElement.call( this, config );
	OO.ui.TitledElement.call( this, config );
	OO.ui.ClippableElement.call( this, $.extend( {}, config, { $clippable: this.$group } ) );

	// Properties
	this.active = false;
	this.dragging = false;
	this.onBlurHandler = this.onBlur.bind( this );
	this.$handle = $( '<span>' );

	// Events
	this.$handle.on( {
		'mousedown touchstart': this.onHandlePointerDown.bind( this ),
		'mouseup touchend': this.onHandlePointerUp.bind( this )
	} );

	// Initialization
	this.$handle
		.addClass( 'oo-ui-popupToolGroup-handle' )
		.append( this.$icon, this.$label, this.$indicator );
	// If the pop-up should have a header, add it to the top of the toolGroup.
	// Note: If this feature is useful for other widgets, we could abstract it into an
	// OO.ui.HeaderedElement mixin constructor.
	if ( config.header !== undefined ) {
		this.$group
			.prepend( $( '<span>' )
				.addClass( 'oo-ui-popupToolGroup-header' )
				.text( config.header )
			);
	}
	this.$element
		.addClass( 'oo-ui-popupToolGroup' )
		.prepend( this.$handle );
};

/* Setup */

OO.inheritClass( OO.ui.PopupToolGroup, OO.ui.ToolGroup );
OO.mixinClass( OO.ui.PopupToolGroup, OO.ui.IconElement );
OO.mixinClass( OO.ui.PopupToolGroup, OO.ui.IndicatorElement );
OO.mixinClass( OO.ui.PopupToolGroup, OO.ui.LabelElement );
OO.mixinClass( OO.ui.PopupToolGroup, OO.ui.TitledElement );
OO.mixinClass( OO.ui.PopupToolGroup, OO.ui.ClippableElement );

/* Static Properties */

/* Methods */

/**
 * @inheritdoc
 */
OO.ui.PopupToolGroup.prototype.setDisabled = function () {
	// Parent method
	OO.ui.PopupToolGroup.super.prototype.setDisabled.apply( this, arguments );

	if ( this.isDisabled() && this.isElementAttached() ) {
		this.setActive( false );
	}
};

/**
 * Handle focus being lost.
 *
 * The event is actually generated from a mouseup, so it is not a normal blur event object.
 *
 * @param {jQuery.Event} e Mouse up event
 */
OO.ui.PopupToolGroup.prototype.onBlur = function ( e ) {
	// Only deactivate when clicking outside the dropdown element
	if ( $( e.target ).closest( '.oo-ui-popupToolGroup' )[ 0 ] !== this.$element[ 0 ] ) {
		this.setActive( false );
	}
};

/**
 * @inheritdoc
 */
OO.ui.PopupToolGroup.prototype.onPointerUp = function ( e ) {
	// e.which is 0 for touch events, 1 for left mouse button
	// Only close toolgroup when a tool was actually selected
	// FIXME: this duplicates logic from the parent class
	if ( !this.isDisabled() && e.which <= 1 && this.pressed && this.pressed === this.getTargetTool( e ) ) {
		this.setActive( false );
	}
	return OO.ui.PopupToolGroup.super.prototype.onPointerUp.call( this, e );
};

/**
 * Handle mouse up events.
 *
 * @param {jQuery.Event} e Mouse up event
 */
OO.ui.PopupToolGroup.prototype.onHandlePointerUp = function () {
	return false;
};

/**
 * Handle mouse down events.
 *
 * @param {jQuery.Event} e Mouse down event
 */
OO.ui.PopupToolGroup.prototype.onHandlePointerDown = function ( e ) {
	// e.which is 0 for touch events, 1 for left mouse button
	if ( !this.isDisabled() && e.which <= 1 ) {
		this.setActive( !this.active );
	}
	return false;
};

/**
 * Switch into active mode.
 *
 * When active, mouseup events anywhere in the document will trigger deactivation.
 */
OO.ui.PopupToolGroup.prototype.setActive = function ( value ) {
	value = !!value;
	if ( this.active !== value ) {
		this.active = value;
		if ( value ) {
			this.getElementDocument().addEventListener( 'mouseup', this.onBlurHandler, true );

			// Try anchoring the popup to the left first
			this.$element.addClass( 'oo-ui-popupToolGroup-active oo-ui-popupToolGroup-left' );
			this.toggleClipping( true );
			if ( this.isClippedHorizontally() ) {
				// Anchoring to the left caused the popup to clip, so anchor it to the right instead
				this.toggleClipping( false );
				this.$element
					.removeClass( 'oo-ui-popupToolGroup-left' )
					.addClass( 'oo-ui-popupToolGroup-right' );
				this.toggleClipping( true );
			}
		} else {
			this.getElementDocument().removeEventListener( 'mouseup', this.onBlurHandler, true );
			this.$element.removeClass(
				'oo-ui-popupToolGroup-active oo-ui-popupToolGroup-left  oo-ui-popupToolGroup-right'
			);
			this.toggleClipping( false );
		}
	}
};

/**
 * Drop down list layout of tools as labeled icon buttons.
 *
 * This layout allows some tools to be collapsible, controlled by a "More" / "Fewer" option at the
 * bottom of the main list. These are not automatically positioned at the bottom of the list; you
 * may want to use the 'promote' and 'demote' configuration options to achieve this.
 *
 * @class
 * @extends OO.ui.PopupToolGroup
 *
 * @constructor
 * @param {OO.ui.Toolbar} toolbar
 * @param {Object} [config] Configuration options
 * @cfg {Array} [allowCollapse] List of tools that can be collapsed. Remaining tools will be always
 *  shown.
 * @cfg {Array} [forceExpand] List of tools that *may not* be collapsed. All remaining tools will be
 *  allowed to be collapsed.
 * @cfg {boolean} [expanded=false] Whether the collapsible tools are expanded by default
 */
OO.ui.ListToolGroup = function OoUiListToolGroup( toolbar, config ) {
	// Allow passing positional parameters inside the config object
	if ( OO.isPlainObject( toolbar ) && config === undefined ) {
		config = toolbar;
		toolbar = config.toolbar;
	}

	// Configuration initialization
	config = config || {};

	// Properties (must be set before parent constructor, which calls #populate)
	this.allowCollapse = config.allowCollapse;
	this.forceExpand = config.forceExpand;
	this.expanded = config.expanded !== undefined ? config.expanded : false;
	this.collapsibleTools = [];

	// Parent constructor
	OO.ui.ListToolGroup.super.call( this, toolbar, config );

	// Initialization
	this.$element.addClass( 'oo-ui-listToolGroup' );
};

/* Setup */

OO.inheritClass( OO.ui.ListToolGroup, OO.ui.PopupToolGroup );

/* Static Properties */

OO.ui.ListToolGroup.static.accelTooltips = true;

OO.ui.ListToolGroup.static.name = 'list';

/* Methods */

/**
 * @inheritdoc
 */
OO.ui.ListToolGroup.prototype.populate = function () {
	var i, len, allowCollapse = [];

	OO.ui.ListToolGroup.super.prototype.populate.call( this );

	// Update the list of collapsible tools
	if ( this.allowCollapse !== undefined ) {
		allowCollapse = this.allowCollapse;
	} else if ( this.forceExpand !== undefined ) {
		allowCollapse = OO.simpleArrayDifference( Object.keys( this.tools ), this.forceExpand );
	}

	this.collapsibleTools = [];
	for ( i = 0, len = allowCollapse.length; i < len; i++ ) {
		if ( this.tools[ allowCollapse[ i ] ] !== undefined ) {
			this.collapsibleTools.push( this.tools[ allowCollapse[ i ] ] );
		}
	}

	// Keep at the end, even when tools are added
	this.$group.append( this.getExpandCollapseTool().$element );

	this.getExpandCollapseTool().toggle( this.collapsibleTools.length !== 0 );
	this.updateCollapsibleState();
};

OO.ui.ListToolGroup.prototype.getExpandCollapseTool = function () {
	if ( this.expandCollapseTool === undefined ) {
		var ExpandCollapseTool = function () {
			ExpandCollapseTool.super.apply( this, arguments );
		};

		OO.inheritClass( ExpandCollapseTool, OO.ui.Tool );

		ExpandCollapseTool.prototype.onSelect = function () {
			this.toolGroup.expanded = !this.toolGroup.expanded;
			this.toolGroup.updateCollapsibleState();
			this.setActive( false );
		};
		ExpandCollapseTool.prototype.onUpdateState = function () {
			// Do nothing. Tool interface requires an implementation of this function.
		};

		ExpandCollapseTool.static.name = 'more-fewer';

		this.expandCollapseTool = new ExpandCollapseTool( this );
	}
	return this.expandCollapseTool;
};

/**
 * @inheritdoc
 */
OO.ui.ListToolGroup.prototype.onPointerUp = function ( e ) {
	var ret = OO.ui.ListToolGroup.super.prototype.onPointerUp.call( this, e );

	// Do not close the popup when the user wants to show more/fewer tools
	if ( $( e.target ).closest( '.oo-ui-tool-name-more-fewer' ).length ) {
		// Prevent the popup list from being hidden
		this.setActive( true );
	}

	return ret;
};

OO.ui.ListToolGroup.prototype.updateCollapsibleState = function () {
	var i, len;

	this.getExpandCollapseTool()
		.setIcon( this.expanded ? 'collapse' : 'expand' )
		.setTitle( OO.ui.msg( this.expanded ? 'ooui-toolgroup-collapse' : 'ooui-toolgroup-expand' ) );

	for ( i = 0, len = this.collapsibleTools.length; i < len; i++ ) {
		this.collapsibleTools[ i ].toggle( this.expanded );
	}
};

/**
 * Drop down menu layout of tools as selectable menu items.
 *
 * @class
 * @extends OO.ui.PopupToolGroup
 *
 * @constructor
 * @param {OO.ui.Toolbar} toolbar
 * @param {Object} [config] Configuration options
 */
OO.ui.MenuToolGroup = function OoUiMenuToolGroup( toolbar, config ) {
	// Allow passing positional parameters inside the config object
	if ( OO.isPlainObject( toolbar ) && config === undefined ) {
		config = toolbar;
		toolbar = config.toolbar;
	}

	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.MenuToolGroup.super.call( this, toolbar, config );

	// Events
	this.toolbar.connect( this, { updateState: 'onUpdateState' } );

	// Initialization
	this.$element.addClass( 'oo-ui-menuToolGroup' );
};

/* Setup */

OO.inheritClass( OO.ui.MenuToolGroup, OO.ui.PopupToolGroup );

/* Static Properties */

OO.ui.MenuToolGroup.static.accelTooltips = true;

OO.ui.MenuToolGroup.static.name = 'menu';

/* Methods */

/**
 * Handle the toolbar state being updated.
 *
 * When the state changes, the title of each active item in the menu will be joined together and
 * used as a label for the group. The label will be empty if none of the items are active.
 */
OO.ui.MenuToolGroup.prototype.onUpdateState = function () {
	var name,
		labelTexts = [];

	for ( name in this.tools ) {
		if ( this.tools[ name ].isActive() ) {
			labelTexts.push( this.tools[ name ].getTitle() );
		}
	}

	this.setLabel( labelTexts.join( ', ' ) || ' ' );
};

/**
 * Tool that shows a popup when selected.
 *
 * @abstract
 * @class
 * @extends OO.ui.Tool
 * @mixins OO.ui.PopupElement
 *
 * @constructor
 * @param {OO.ui.ToolGroup} toolGroup
 * @param {Object} [config] Configuration options
 */
OO.ui.PopupTool = function OoUiPopupTool( toolGroup, config ) {
	// Allow passing positional parameters inside the config object
	if ( OO.isPlainObject( toolGroup ) && config === undefined ) {
		config = toolGroup;
		toolGroup = config.toolGroup;
	}

	// Parent constructor
	OO.ui.PopupTool.super.call( this, toolGroup, config );

	// Mixin constructors
	OO.ui.PopupElement.call( this, config );

	// Initialization
	this.$element
		.addClass( 'oo-ui-popupTool' )
		.append( this.popup.$element );
};

/* Setup */

OO.inheritClass( OO.ui.PopupTool, OO.ui.Tool );
OO.mixinClass( OO.ui.PopupTool, OO.ui.PopupElement );

/* Methods */

/**
 * Handle the tool being selected.
 *
 * @inheritdoc
 */
OO.ui.PopupTool.prototype.onSelect = function () {
	if ( !this.isDisabled() ) {
		this.popup.toggle();
	}
	this.setActive( false );
	return false;
};

/**
 * Handle the toolbar state being updated.
 *
 * @inheritdoc
 */
OO.ui.PopupTool.prototype.onUpdateState = function () {
	this.setActive( false );
};

/**
 * Tool that has a tool group inside. This is a bad workaround for the lack of proper hierarchical
 * menus in toolbars (T74159).
 *
 * @abstract
 * @class
 * @extends OO.ui.Tool
 *
 * @constructor
 * @param {OO.ui.ToolGroup} toolGroup
 * @param {Object} [config] Configuration options
 */
OO.ui.ToolGroupTool = function OoUiToolGroupTool( toolGroup, config ) {
	// Allow passing positional parameters inside the config object
	if ( OO.isPlainObject( toolGroup ) && config === undefined ) {
		config = toolGroup;
		toolGroup = config.toolGroup;
	}

	// Parent constructor
	OO.ui.ToolGroupTool.super.call( this, toolGroup, config );

	// Properties
	this.innerToolGroup = this.createGroup( this.constructor.static.groupConfig );

	// Initialization
	this.$link.remove();
	this.$element
		.addClass( 'oo-ui-toolGroupTool' )
		.append( this.innerToolGroup.$element );
};

/* Setup */

OO.inheritClass( OO.ui.ToolGroupTool, OO.ui.Tool );

/* Static Properties */

/**
 * Tool group configuration. See OO.ui.Toolbar#setup for the accepted values.
 *
 * @property {Object.<string,Array>}
 */
OO.ui.ToolGroupTool.static.groupConfig = {};

/* Methods */

/**
 * Handle the tool being selected.
 *
 * @inheritdoc
 */
OO.ui.ToolGroupTool.prototype.onSelect = function () {
	this.innerToolGroup.setActive( !this.innerToolGroup.active );
	return false;
};

/**
 * Handle the toolbar state being updated.
 *
 * @inheritdoc
 */
OO.ui.ToolGroupTool.prototype.onUpdateState = function () {
	this.setActive( false );
};

/**
 * Build a OO.ui.ToolGroup from the configuration.
 *
 * @param {Object.<string,Array>} group Tool group configuration. See OO.ui.Toolbar#setup for the
 *   accepted values.
 * @return {OO.ui.ListToolGroup}
 */
OO.ui.ToolGroupTool.prototype.createGroup = function ( group ) {
	if ( group.include === '*' ) {
		// Apply defaults to catch-all groups
		if ( group.label === undefined ) {
			group.label = OO.ui.msg( 'ooui-toolbar-more' );
		}
	}

	return this.toolbar.getToolGroupFactory().create( 'list', this.toolbar, group );
};

/**
 * Mixin for OO.ui.Widget subclasses to provide OO.ui.GroupElement.
 *
 * Use together with OO.ui.ItemWidget to make disabled state inheritable.
 *
 * @private
 * @abstract
 * @class
 * @extends OO.ui.GroupElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
OO.ui.GroupWidget = function OoUiGroupWidget( config ) {
	// Parent constructor
	OO.ui.GroupWidget.super.call( this, config );
};

/* Setup */

OO.inheritClass( OO.ui.GroupWidget, OO.ui.GroupElement );

/* Methods */

/**
 * Set the disabled state of the widget.
 *
 * This will also update the disabled state of child widgets.
 *
 * @param {boolean} disabled Disable widget
 * @chainable
 */
OO.ui.GroupWidget.prototype.setDisabled = function ( disabled ) {
	var i, len;

	// Parent method
	// Note: Calling #setDisabled this way assumes this is mixed into an OO.ui.Widget
	OO.ui.Widget.prototype.setDisabled.call( this, disabled );

	// During construction, #setDisabled is called before the OO.ui.GroupElement constructor
	if ( this.items ) {
		for ( i = 0, len = this.items.length; i < len; i++ ) {
			this.items[ i ].updateDisabled();
		}
	}

	return this;
};

/**
 * Mixin for widgets used as items in widgets that inherit OO.ui.GroupWidget.
 *
 * Item widgets have a reference to a OO.ui.GroupWidget while they are attached to the group. This
 * allows bidirectional communication.
 *
 * Use together with OO.ui.GroupWidget to make disabled state inheritable.
 *
 * @private
 * @abstract
 * @class
 *
 * @constructor
 */
OO.ui.ItemWidget = function OoUiItemWidget() {
	//
};

/* Methods */

/**
 * Check if widget is disabled.
 *
 * Checks parent if present, making disabled state inheritable.
 *
 * @return {boolean} Widget is disabled
 */
OO.ui.ItemWidget.prototype.isDisabled = function () {
	return this.disabled ||
		( this.elementGroup instanceof OO.ui.Widget && this.elementGroup.isDisabled() );
};

/**
 * Set group element is in.
 *
 * @param {OO.ui.GroupElement|null} group Group element, null if none
 * @chainable
 */
OO.ui.ItemWidget.prototype.setElementGroup = function ( group ) {
	// Parent method
	// Note: Calling #setElementGroup this way assumes this is mixed into an OO.ui.Element
	OO.ui.Element.prototype.setElementGroup.call( this, group );

	// Initialize item disabled states
	this.updateDisabled();

	return this;
};

/**
 * Set of controls for an OO.ui.OutlineSelectWidget.
 *
 * Controls include moving items up and down, removing items, and adding different kinds of items.
 *
 * @class
 * @extends OO.ui.Widget
 * @mixins OO.ui.GroupElement
 * @mixins OO.ui.IconElement
 *
 * @constructor
 * @param {OO.ui.OutlineSelectWidget} outline Outline to control
 * @param {Object} [config] Configuration options
 */
OO.ui.OutlineControlsWidget = function OoUiOutlineControlsWidget( outline, config ) {
	// Allow passing positional parameters inside the config object
	if ( OO.isPlainObject( outline ) && config === undefined ) {
		config = outline;
		outline = config.outline;
	}

	// Configuration initialization
	config = $.extend( { icon: 'add' }, config );

	// Parent constructor
	OO.ui.OutlineControlsWidget.super.call( this, config );

	// Mixin constructors
	OO.ui.GroupElement.call( this, config );
	OO.ui.IconElement.call( this, config );

	// Properties
	this.outline = outline;
	this.$movers = $( '<div>' );
	this.upButton = new OO.ui.ButtonWidget( {
		framed: false,
		icon: 'collapse',
		title: OO.ui.msg( 'ooui-outline-control-move-up' )
	} );
	this.downButton = new OO.ui.ButtonWidget( {
		framed: false,
		icon: 'expand',
		title: OO.ui.msg( 'ooui-outline-control-move-down' )
	} );
	this.removeButton = new OO.ui.ButtonWidget( {
		framed: false,
		icon: 'remove',
		title: OO.ui.msg( 'ooui-outline-control-remove' )
	} );

	// Events
	outline.connect( this, {
		select: 'onOutlineChange',
		add: 'onOutlineChange',
		remove: 'onOutlineChange'
	} );
	this.upButton.connect( this, { click: [ 'emit', 'move', -1 ] } );
	this.downButton.connect( this, { click: [ 'emit', 'move', 1 ] } );
	this.removeButton.connect( this, { click: [ 'emit', 'remove' ] } );

	// Initialization
	this.$element.addClass( 'oo-ui-outlineControlsWidget' );
	this.$group.addClass( 'oo-ui-outlineControlsWidget-items' );
	this.$movers
		.addClass( 'oo-ui-outlineControlsWidget-movers' )
		.append( this.removeButton.$element, this.upButton.$element, this.downButton.$element );
	this.$element.append( this.$icon, this.$group, this.$movers );
};

/* Setup */

OO.inheritClass( OO.ui.OutlineControlsWidget, OO.ui.Widget );
OO.mixinClass( OO.ui.OutlineControlsWidget, OO.ui.GroupElement );
OO.mixinClass( OO.ui.OutlineControlsWidget, OO.ui.IconElement );

/* Events */

/**
 * @event move
 * @param {number} places Number of places to move
 */

/**
 * @event remove
 */

/* Methods */

/**
 * Handle outline change events.
 */
OO.ui.OutlineControlsWidget.prototype.onOutlineChange = function () {
	var i, len, firstMovable, lastMovable,
		items = this.outline.getItems(),
		selectedItem = this.outline.getSelectedItem(),
		movable = selectedItem && selectedItem.isMovable(),
		removable = selectedItem && selectedItem.isRemovable();

	if ( movable ) {
		i = -1;
		len = items.length;
		while ( ++i < len ) {
			if ( items[ i ].isMovable() ) {
				firstMovable = items[ i ];
				break;
			}
		}
		i = len;
		while ( i-- ) {
			if ( items[ i ].isMovable() ) {
				lastMovable = items[ i ];
				break;
			}
		}
	}
	this.upButton.setDisabled( !movable || selectedItem === firstMovable );
	this.downButton.setDisabled( !movable || selectedItem === lastMovable );
	this.removeButton.setDisabled( !removable );
};

/**
 * ToggleWidget is mixed into other classes to create widgets with an on/off state.
 * Please see OO.ui.ToggleButtonWidget and OO.ui.ToggleSwitchWidget for examples.
 *
 * @abstract
 * @class
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {boolean} [value=false] The toggle’s initial on/off state.
 *  By default, the toggle is in the 'off' state.
 */
OO.ui.ToggleWidget = function OoUiToggleWidget( config ) {
	// Configuration initialization
	config = config || {};

	// Properties
	this.value = null;

	// Initialization
	this.$element.addClass( 'oo-ui-toggleWidget' );
	this.setValue( !!config.value );
};

/* Events */

/**
 * @event change
 *
 * A change event is emitted when the on/off state of the toggle changes.
 *
 * @param {boolean} value Value representing the new state of the toggle
 */

/* Methods */

/**
 * Get the value representing the toggle’s state.
 *
 * @return {boolean} The on/off state of the toggle
 */
OO.ui.ToggleWidget.prototype.getValue = function () {
	return this.value;
};

/**
 * Set the state of the toggle: `true` for 'on', `false' for 'off'.
 *
 * @param {boolean} value The state of the toggle
 * @fires change
 * @chainable
 */
OO.ui.ToggleWidget.prototype.setValue = function ( value ) {
	value = !!value;
	if ( this.value !== value ) {
		this.value = value;
		this.emit( 'change', value );
		this.$element.toggleClass( 'oo-ui-toggleWidget-on', value );
		this.$element.toggleClass( 'oo-ui-toggleWidget-off', !value );
		this.$element.attr( 'aria-checked', value.toString() );
	}
	return this;
};

/**
 * A ButtonGroupWidget groups related buttons and is used together with OO.ui.ButtonWidget and
 * its subclasses. Each button in a group is addressed by a unique reference. Buttons can be added,
 * removed, and cleared from the group.
 *
 *     @example
 *     // Example: A ButtonGroupWidget with two buttons
 *     var button1 = new OO.ui.PopupButtonWidget( {
 *         label : 'Select a category',
 *         icon : 'menu',
 *         popup : {
 *             $content: $( '<p>List of categories...</p>' ),
 *             padded: true,
 *             align: 'left'
 *         }
 *     } );
 *     var button2 = new OO.ui.ButtonWidget( {
 *         label : 'Add item'
 *     });
 *     var buttonGroup = new OO.ui.ButtonGroupWidget( {
 *         items: [button1, button2]
 *     } );
 *     $('body').append(buttonGroup.$element);
 *
 * @class
 * @extends OO.ui.Widget
 * @mixins OO.ui.GroupElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {OO.ui.ButtonWidget[]} [items] Buttons to add
 */
OO.ui.ButtonGroupWidget = function OoUiButtonGroupWidget( config ) {
	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.ButtonGroupWidget.super.call( this, config );

	// Mixin constructors
	OO.ui.GroupElement.call( this, $.extend( {}, config, { $group: this.$element } ) );

	// Initialization
	this.$element.addClass( 'oo-ui-buttonGroupWidget' );
	if ( Array.isArray( config.items ) ) {
		this.addItems( config.items );
	}
};

/* Setup */

OO.inheritClass( OO.ui.ButtonGroupWidget, OO.ui.Widget );
OO.mixinClass( OO.ui.ButtonGroupWidget, OO.ui.GroupElement );

/**
 * ButtonWidget is a generic widget for buttons. A wide variety of looks,
 * feels, and functionality can be customized via the class’s configuration options
 * and methods. Please see the [OOjs UI documentation on MediaWiki] [1] for more information
 * and examples.
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Buttons_and_Switches
 *
 *     @example
 *     // A button widget
 *     var button = new OO.ui.ButtonWidget( {
 *         label : 'Button with Icon',
 *         icon : 'remove',
 *         iconTitle : 'Remove'
 *     } );
 *     $( 'body' ).append( button.$element );
 *
 * NOTE: HTML form buttons should use the OO.ui.ButtonInputWidget class.
 *
 * @class
 * @extends OO.ui.Widget
 * @mixins OO.ui.ButtonElement
 * @mixins OO.ui.IconElement
 * @mixins OO.ui.IndicatorElement
 * @mixins OO.ui.LabelElement
 * @mixins OO.ui.TitledElement
 * @mixins OO.ui.FlaggedElement
 * @mixins OO.ui.TabIndexedElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {string} [href] Hyperlink to visit when the button is clicked.
 * @cfg {string} [target] The frame or window in which to open the hyperlink.
 * @cfg {boolean} [noFollow] Search engine traversal hint (default: true)
 */
OO.ui.ButtonWidget = function OoUiButtonWidget( config ) {
	// Configuration initialization
	// FIXME: The `nofollow` alias is deprecated and will be removed (T89767)
	config = $.extend( { noFollow: config && config.nofollow }, config );

	// Parent constructor
	OO.ui.ButtonWidget.super.call( this, config );

	// Mixin constructors
	OO.ui.ButtonElement.call( this, config );
	OO.ui.IconElement.call( this, config );
	OO.ui.IndicatorElement.call( this, config );
	OO.ui.LabelElement.call( this, config );
	OO.ui.TitledElement.call( this, $.extend( {}, config, { $titled: this.$button } ) );
	OO.ui.FlaggedElement.call( this, config );
	OO.ui.TabIndexedElement.call( this, $.extend( {}, config, { $tabIndexed: this.$button } ) );

	// Properties
	this.href = null;
	this.target = null;
	this.noFollow = false;
	this.isHyperlink = false;

	// Initialization
	this.$button.append( this.$icon, this.$label, this.$indicator );
	this.$element
		.addClass( 'oo-ui-buttonWidget' )
		.append( this.$button );
	this.setHref( config.href );
	this.setTarget( config.target );
	this.setNoFollow( config.noFollow );
};

/* Setup */

OO.inheritClass( OO.ui.ButtonWidget, OO.ui.Widget );
OO.mixinClass( OO.ui.ButtonWidget, OO.ui.ButtonElement );
OO.mixinClass( OO.ui.ButtonWidget, OO.ui.IconElement );
OO.mixinClass( OO.ui.ButtonWidget, OO.ui.IndicatorElement );
OO.mixinClass( OO.ui.ButtonWidget, OO.ui.LabelElement );
OO.mixinClass( OO.ui.ButtonWidget, OO.ui.TitledElement );
OO.mixinClass( OO.ui.ButtonWidget, OO.ui.FlaggedElement );
OO.mixinClass( OO.ui.ButtonWidget, OO.ui.TabIndexedElement );

/* Methods */

/**
 * @inheritdoc
 */
OO.ui.ButtonWidget.prototype.onMouseDown = function ( e ) {
	if ( !this.isDisabled() ) {
		// Remove the tab-index while the button is down to prevent the button from stealing focus
		this.$button.removeAttr( 'tabindex' );
	}

	return OO.ui.ButtonElement.prototype.onMouseDown.call( this, e );
};

/**
 * @inheritdoc
 */
OO.ui.ButtonWidget.prototype.onMouseUp = function ( e ) {
	if ( !this.isDisabled() ) {
		// Restore the tab-index after the button is up to restore the button's accessibility
		this.$button.attr( 'tabindex', this.tabIndex );
	}

	return OO.ui.ButtonElement.prototype.onMouseUp.call( this, e );
};

/**
 * @inheritdoc
 */
OO.ui.ButtonWidget.prototype.onClick = function ( e ) {
	var ret = OO.ui.ButtonElement.prototype.onClick.call( this, e );
	if ( this.isHyperlink ) {
		return true;
	}
	return ret;
};

/**
 * @inheritdoc
 */
OO.ui.ButtonWidget.prototype.onKeyPress = function ( e ) {
	var ret = OO.ui.ButtonElement.prototype.onKeyPress.call( this, e );
	if ( this.isHyperlink ) {
		return true;
	}
	return ret;
};

/**
 * Get hyperlink location.
 *
 * @return {string} Hyperlink location
 */
OO.ui.ButtonWidget.prototype.getHref = function () {
	return this.href;
};

/**
 * Get hyperlink target.
 *
 * @return {string} Hyperlink target
 */
OO.ui.ButtonWidget.prototype.getTarget = function () {
	return this.target;
};

/**
 * Get search engine traversal hint.
 *
 * @return {boolean} Whether search engines should avoid traversing this hyperlink
 */
OO.ui.ButtonWidget.prototype.getNoFollow = function () {
	return this.noFollow;
};

/**
 * Set hyperlink location.
 *
 * @param {string|null} href Hyperlink location, null to remove
 */
OO.ui.ButtonWidget.prototype.setHref = function ( href ) {
	href = typeof href === 'string' ? href : null;

	if ( href !== this.href ) {
		this.href = href;
		if ( href !== null ) {
			this.$button.attr( 'href', href );
			this.isHyperlink = true;
		} else {
			this.$button.removeAttr( 'href' );
			this.isHyperlink = false;
		}
	}

	return this;
};

/**
 * Set hyperlink target.
 *
 * @param {string|null} target Hyperlink target, null to remove
 */
OO.ui.ButtonWidget.prototype.setTarget = function ( target ) {
	target = typeof target === 'string' ? target : null;

	if ( target !== this.target ) {
		this.target = target;
		if ( target !== null ) {
			this.$button.attr( 'target', target );
		} else {
			this.$button.removeAttr( 'target' );
		}
	}

	return this;
};

/**
 * Set search engine traversal hint.
 *
 * @param {boolean} noFollow True if search engines should avoid traversing this hyperlink
 */
OO.ui.ButtonWidget.prototype.setNoFollow = function ( noFollow ) {
	noFollow = typeof noFollow === 'boolean' ? noFollow : true;

	if ( noFollow !== this.noFollow ) {
		this.noFollow = noFollow;
		if ( noFollow ) {
			this.$button.attr( 'rel', 'nofollow' );
		} else {
			this.$button.removeAttr( 'rel' );
		}
	}

	return this;
};

/**
 * An ActionWidget is a {@link OO.ui.ButtonWidget button widget} that executes an action.
 * Action widgets are used with OO.ui.ActionSet, which manages the behavior and availability
 * of the actions. Please see the [OOjs UI documentation on MediaWiki] [1] for more information
 * and examples.
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Windows/Process_Dialogs#Action_sets
 *
 * @class
 * @extends OO.ui.ButtonWidget
 * @mixins OO.ui.PendingElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {string} [action] Symbolic action name
 * @cfg {string[]} [modes] Symbolic mode names
 * @cfg {boolean} [framed=false] Render button with a frame
 */
OO.ui.ActionWidget = function OoUiActionWidget( config ) {
	// Configuration initialization
	config = $.extend( { framed: false }, config );

	// Parent constructor
	OO.ui.ActionWidget.super.call( this, config );

	// Mixin constructors
	OO.ui.PendingElement.call( this, config );

	// Properties
	this.action = config.action || '';
	this.modes = config.modes || [];
	this.width = 0;
	this.height = 0;

	// Initialization
	this.$element.addClass( 'oo-ui-actionWidget' );
};

/* Setup */

OO.inheritClass( OO.ui.ActionWidget, OO.ui.ButtonWidget );
OO.mixinClass( OO.ui.ActionWidget, OO.ui.PendingElement );

/* Events */

/**
 * @event resize
 */

/* Methods */

/**
 * Check if action is available in a certain mode.
 *
 * @param {string} mode Name of mode
 * @return {boolean} Has mode
 */
OO.ui.ActionWidget.prototype.hasMode = function ( mode ) {
	return this.modes.indexOf( mode ) !== -1;
};

/**
 * Get symbolic action name.
 *
 * @return {string}
 */
OO.ui.ActionWidget.prototype.getAction = function () {
	return this.action;
};

/**
 * Get symbolic action name.
 *
 * @return {string}
 */
OO.ui.ActionWidget.prototype.getModes = function () {
	return this.modes.slice();
};

/**
 * Emit a resize event if the size has changed.
 *
 * @chainable
 */
OO.ui.ActionWidget.prototype.propagateResize = function () {
	var width, height;

	if ( this.isElementAttached() ) {
		width = this.$element.width();
		height = this.$element.height();

		if ( width !== this.width || height !== this.height ) {
			this.width = width;
			this.height = height;
			this.emit( 'resize' );
		}
	}

	return this;
};

/**
 * @inheritdoc
 */
OO.ui.ActionWidget.prototype.setIcon = function () {
	// Mixin method
	OO.ui.IconElement.prototype.setIcon.apply( this, arguments );
	this.propagateResize();

	return this;
};

/**
 * @inheritdoc
 */
OO.ui.ActionWidget.prototype.setLabel = function () {
	// Mixin method
	OO.ui.LabelElement.prototype.setLabel.apply( this, arguments );
	this.propagateResize();

	return this;
};

/**
 * @inheritdoc
 */
OO.ui.ActionWidget.prototype.setFlags = function () {
	// Mixin method
	OO.ui.FlaggedElement.prototype.setFlags.apply( this, arguments );
	this.propagateResize();

	return this;
};

/**
 * @inheritdoc
 */
OO.ui.ActionWidget.prototype.clearFlags = function () {
	// Mixin method
	OO.ui.FlaggedElement.prototype.clearFlags.apply( this, arguments );
	this.propagateResize();

	return this;
};

/**
 * Toggle visibility of button.
 *
 * @param {boolean} [show] Show button, omit to toggle visibility
 * @chainable
 */
OO.ui.ActionWidget.prototype.toggle = function () {
	// Parent method
	OO.ui.ActionWidget.super.prototype.toggle.apply( this, arguments );
	this.propagateResize();

	return this;
};

/**
 * PopupButtonWidgets toggle the visibility of a contained {@link OO.ui.PopupWidget PopupWidget},
 * which is used to display additional information or options.
 *
 *     @example
 *     // Example of a popup button.
 *     var popupButton = new OO.ui.PopupButtonWidget( {
 *         label: 'Popup button with options',
 *         icon: 'menu',
 *         popup: {
 *             $content: $( '<p>Additional options here.</p>' ),
 *             padded: true,
 *             align: 'left'
 *         }
 *     } );
 *     // Append the button to the DOM.
 *     $( 'body' ).append( popupButton.$element );
 *
 * @class
 * @extends OO.ui.ButtonWidget
 * @mixins OO.ui.PopupElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
OO.ui.PopupButtonWidget = function OoUiPopupButtonWidget( config ) {
	// Parent constructor
	OO.ui.PopupButtonWidget.super.call( this, config );

	// Mixin constructors
	OO.ui.PopupElement.call( this, config );

	// Events
	this.connect( this, { click: 'onAction' } );

	// Initialization
	this.$element
		.addClass( 'oo-ui-popupButtonWidget' )
		.attr( 'aria-haspopup', 'true' )
		.append( this.popup.$element );
};

/* Setup */

OO.inheritClass( OO.ui.PopupButtonWidget, OO.ui.ButtonWidget );
OO.mixinClass( OO.ui.PopupButtonWidget, OO.ui.PopupElement );

/* Methods */

/**
 * Handle the button action being triggered.
 *
 * @private
 */
OO.ui.PopupButtonWidget.prototype.onAction = function () {
	this.popup.toggle();
};

/**
 * ToggleButtons are buttons that have a state (‘on’ or ‘off’) that is represented by a
 * Boolean value. Like other {@link OO.ui.ButtonWidget buttons}, toggle buttons can be
 * configured with {@link OO.ui.IconElement icons}, {@link OO.ui.IndicatorElement indicators},
 * {@link OO.ui.TitledElement titles}, {@link OO.ui.FlaggedElement styling flags},
 * and {@link OO.ui.LabelElement labels}. Please see
 * the [OOjs UI documentation][1] on MediaWiki for more information.
 *
 *     @example
 *     // Toggle buttons in the 'off' and 'on' state.
 *     var toggleButton1 = new OO.ui.ToggleButtonWidget( {
 *         label: 'Toggle Button off'
 *     } );
 *     var toggleButton2 = new OO.ui.ToggleButtonWidget( {
 *         label: 'Toggle Button on',
 *         value: true
 *     } );
 *     // Append the buttons to the DOM.
 *     $( 'body' ).append( toggleButton1.$element, toggleButton2.$element );
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Buttons_and_Switches#Toggle_buttons
 *
 * @class
 * @extends OO.ui.ButtonWidget
 * @mixins OO.ui.ToggleWidget
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {boolean} [value=false] The toggle button’s initial on/off
 *  state. By default, the button is in the 'off' state.
 */
OO.ui.ToggleButtonWidget = function OoUiToggleButtonWidget( config ) {
	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.ToggleButtonWidget.super.call( this, config );

	// Mixin constructors
	OO.ui.ToggleWidget.call( this, config );

	// Events
	this.connect( this, { click: 'onAction' } );

	// Initialization
	this.$element.addClass( 'oo-ui-toggleButtonWidget' );
};

/* Setup */

OO.inheritClass( OO.ui.ToggleButtonWidget, OO.ui.ButtonWidget );
OO.mixinClass( OO.ui.ToggleButtonWidget, OO.ui.ToggleWidget );

/* Methods */

/**
 *
 * @private
 * Handle the button action being triggered.
 */
OO.ui.ToggleButtonWidget.prototype.onAction = function () {
	this.setValue( !this.value );
};

/**
 * @inheritdoc
 */
OO.ui.ToggleButtonWidget.prototype.setValue = function ( value ) {
	value = !!value;
	if ( value !== this.value ) {
		this.$button.attr( 'aria-pressed', value.toString() );
		this.setActive( value );
	}

	// Parent method (from mixin)
	OO.ui.ToggleWidget.prototype.setValue.call( this, value );

	return this;
};

/**
 * DropdownWidgets are not menus themselves, rather they contain a menu of options created with
 * OO.ui.MenuOptionWidget. The DropdownWidget takes care of opening and displaying the menu so that
 * users can interact with it.
 *
 *     @example
 *     // Example: A DropdownWidget with a menu that contains three options
 *     var dropDown=new OO.ui.DropdownWidget( {
 *         label: 'Dropdown menu: Select a menu option',
 *         menu: {
 *             items: [
 *                 new OO.ui.MenuOptionWidget( {
 *                     data: 'a',
 *                     label: 'First'
 *                 } ),
 *                 new OO.ui.MenuOptionWidget( {
 *                     data: 'b',
 *                     label: 'Second'
 *                 } ),
 *                 new OO.ui.MenuOptionWidget( {
 *                     data: 'c',
 *                     label: 'Third'
 *                 } )
 *             ]
 *         }
 *     } );
 *
 *     $('body').append(dropDown.$element);
 *
 * For more information, please see the [OOjs UI documentation on MediaWiki] [1].
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Selects_and_Options#Menu_selects_and_options
 *
 * @class
 * @extends OO.ui.Widget
 * @mixins OO.ui.IconElement
 * @mixins OO.ui.IndicatorElement
 * @mixins OO.ui.LabelElement
 * @mixins OO.ui.TitledElement
 * @mixins OO.ui.TabIndexedElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {Object} [menu] Configuration options to pass to menu widget
 */
OO.ui.DropdownWidget = function OoUiDropdownWidget( config ) {
	// Configuration initialization
	config = $.extend( { indicator: 'down' }, config );

	// Parent constructor
	OO.ui.DropdownWidget.super.call( this, config );

	// Properties (must be set before TabIndexedElement constructor call)
	this.$handle = this.$( '<span>' );

	// Mixin constructors
	OO.ui.IconElement.call( this, config );
	OO.ui.IndicatorElement.call( this, config );
	OO.ui.LabelElement.call( this, config );
	OO.ui.TitledElement.call( this, $.extend( {}, config, { $titled: this.$label } ) );
	OO.ui.TabIndexedElement.call( this, $.extend( {}, config, { $tabIndexed: this.$handle } ) );

	// Properties
	this.menu = new OO.ui.MenuSelectWidget( $.extend( { widget: this }, config.menu ) );

	// Events
	this.$handle.on( {
		click: this.onClick.bind( this ),
		keypress: this.onKeyPress.bind( this )
	} );
	this.menu.connect( this, { select: 'onMenuSelect' } );

	// Initialization
	this.$handle
		.addClass( 'oo-ui-dropdownWidget-handle' )
		.append( this.$icon, this.$label, this.$indicator );
	this.$element
		.addClass( 'oo-ui-dropdownWidget' )
		.append( this.$handle, this.menu.$element );
};

/* Setup */

OO.inheritClass( OO.ui.DropdownWidget, OO.ui.Widget );
OO.mixinClass( OO.ui.DropdownWidget, OO.ui.IconElement );
OO.mixinClass( OO.ui.DropdownWidget, OO.ui.IndicatorElement );
OO.mixinClass( OO.ui.DropdownWidget, OO.ui.LabelElement );
OO.mixinClass( OO.ui.DropdownWidget, OO.ui.TitledElement );
OO.mixinClass( OO.ui.DropdownWidget, OO.ui.TabIndexedElement );

/* Methods */

/**
 * Get the menu.
 *
 * @return {OO.ui.MenuSelectWidget} Menu of widget
 */
OO.ui.DropdownWidget.prototype.getMenu = function () {
	return this.menu;
};

/**
 * Handles menu select events.
 *
 * @private
 * @param {OO.ui.MenuOptionWidget} item Selected menu item
 */
OO.ui.DropdownWidget.prototype.onMenuSelect = function ( item ) {
	var selectedLabel;

	if ( !item ) {
		return;
	}

	selectedLabel = item.getLabel();

	// If the label is a DOM element, clone it, because setLabel will append() it
	if ( selectedLabel instanceof jQuery ) {
		selectedLabel = selectedLabel.clone();
	}

	this.setLabel( selectedLabel );
};

/**
 * Handle mouse click events.
 *
 * @private
 * @param {jQuery.Event} e Mouse click event
 */
OO.ui.DropdownWidget.prototype.onClick = function ( e ) {
	if ( !this.isDisabled() && e.which === 1 ) {
		this.menu.toggle();
	}
	return false;
};

/**
 * Handle key press events.
 *
 * @private
 * @param {jQuery.Event} e Key press event
 */
OO.ui.DropdownWidget.prototype.onKeyPress = function ( e ) {
	if ( !this.isDisabled() && ( e.which === OO.ui.Keys.SPACE || e.which === OO.ui.Keys.ENTER ) ) {
		this.menu.toggle();
	}
	return false;
};

/**
 * IconWidget is a generic widget for {@link OO.ui.IconElement icons}. In general, IconWidgets should be used with OO.ui.LabelWidget,
 * which creates a label that identifies the icon’s function. See the [OOjs UI documentation on MediaWiki] [1]
 * for a list of icons included in the library.
 *
 *     @example
 *     // An icon widget with a label
 *     var myIcon = new OO.ui.IconWidget({
 *         icon: 'help',
 *         iconTitle: 'Help'
 *      });
 *      // Create a label.
 *      var iconLabel = new OO.ui.LabelWidget({
 *          label: 'Help'
 *      });
 *      $('body').append(myIcon.$element, iconLabel.$element);
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Icons,_Indicators,_and_Labels#Icons
 *
 * @class
 * @extends OO.ui.Widget
 * @mixins OO.ui.IconElement
 * @mixins OO.ui.TitledElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
OO.ui.IconWidget = function OoUiIconWidget( config ) {
	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.IconWidget.super.call( this, config );

	// Mixin constructors
	OO.ui.IconElement.call( this, $.extend( {}, config, { $icon: this.$element } ) );
	OO.ui.TitledElement.call( this, $.extend( {}, config, { $titled: this.$element } ) );

	// Initialization
	this.$element.addClass( 'oo-ui-iconWidget' );
};

/* Setup */

OO.inheritClass( OO.ui.IconWidget, OO.ui.Widget );
OO.mixinClass( OO.ui.IconWidget, OO.ui.IconElement );
OO.mixinClass( OO.ui.IconWidget, OO.ui.TitledElement );

/* Static Properties */

OO.ui.IconWidget.static.tagName = 'span';

/**
 * IndicatorWidgets create indicators, which are small graphics that are generally used to draw
 * attention to the status of an item or to clarify the function of a control. For a list of
 * indicators included in the library, please see the [OOjs UI documentation on MediaWiki][1].
 *
 *     @example
 *     // Example of an indicator widget
 *     var indicator1 = new OO.ui.IndicatorWidget( {
 *         indicator: 'alert'
 *     });
 *
 *     // Create a fieldset layout to add a label
 *     var fieldset = new OO.ui.FieldsetLayout( );
 *     fieldset.addItems( [
 *         new OO.ui.FieldLayout( indicator1, {label: 'An alert indicator:'} )
 *     ] );
 *     $( 'body' ).append( fieldset.$element );
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Icons,_Indicators,_and_Labels#Indicators
 *
 * @class
 * @extends OO.ui.Widget
 * @mixins OO.ui.IndicatorElement
 * @mixins OO.ui.TitledElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
OO.ui.IndicatorWidget = function OoUiIndicatorWidget( config ) {
	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.IndicatorWidget.super.call( this, config );

	// Mixin constructors
	OO.ui.IndicatorElement.call( this, $.extend( {}, config, { $indicator: this.$element } ) );
	OO.ui.TitledElement.call( this, $.extend( {}, config, { $titled: this.$element } ) );

	// Initialization
	this.$element.addClass( 'oo-ui-indicatorWidget' );
};

/* Setup */

OO.inheritClass( OO.ui.IndicatorWidget, OO.ui.Widget );
OO.mixinClass( OO.ui.IndicatorWidget, OO.ui.IndicatorElement );
OO.mixinClass( OO.ui.IndicatorWidget, OO.ui.TitledElement );

/* Static Properties */

OO.ui.IndicatorWidget.static.tagName = 'span';

/**
 * InputWidget is the base class for all input widgets, which
 * include {@link OO.ui.TextInputWidget text inputs}, {@link OO.ui.CheckboxInputWidget checkbox inputs},
 * {@link OO.ui.RadioInputWidget radio inputs}, and {@link OO.ui.ButtonInputWidget button inputs}.
 * See the [OOjs UI documentation on MediaWiki] [1] for more information and examples.
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Inputs
 *
 * @abstract
 * @class
 * @extends OO.ui.Widget
 * @mixins OO.ui.FlaggedElement
 * @mixins OO.ui.TabIndexedElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {string} [name=''] HTML input name
 * @cfg {string} [value=''] Input value
 * @cfg {Function} [inputFilter] Filter function to apply to the input. Takes a string argument and returns a string.
 */
OO.ui.InputWidget = function OoUiInputWidget( config ) {
	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.InputWidget.super.call( this, config );

	// Properties
	this.$input = this.getInputElement( config );
	this.value = '';
	this.inputFilter = config.inputFilter;

	// Mixin constructors
	OO.ui.FlaggedElement.call( this, config );
	OO.ui.TabIndexedElement.call( this, $.extend( {}, config, { $tabIndexed: this.$input } ) );

	// Events
	this.$input.on( 'keydown mouseup cut paste change input select', this.onEdit.bind( this ) );

	// Initialization
	this.$input
		.attr( 'name', config.name )
		.prop( 'disabled', this.isDisabled() );
	this.$element.addClass( 'oo-ui-inputWidget' ).append( this.$input, $( '<span>' ) );
	this.setValue( config.value );
};

/* Setup */

OO.inheritClass( OO.ui.InputWidget, OO.ui.Widget );
OO.mixinClass( OO.ui.InputWidget, OO.ui.FlaggedElement );
OO.mixinClass( OO.ui.InputWidget, OO.ui.TabIndexedElement );

/* Events */

/**
 * @event change
 * @param {string} value
 */

/* Methods */

/**
 * Get input element.
 *
 * Subclasses of OO.ui.InputWidget use the `config` parameter to produce different elements in
 * different circumstances. The element must have a `value` property (like form elements).
 *
 * @private
 * @param {Object} config Configuration options
 * @return {jQuery} Input element
 */
OO.ui.InputWidget.prototype.getInputElement = function () {
	return $( '<input>' );
};

/**
 * Handle potentially value-changing events.
 *
 * @param {jQuery.Event} e Key down, mouse up, cut, paste, change, input, or select event
 */
OO.ui.InputWidget.prototype.onEdit = function () {
	var widget = this;
	if ( !this.isDisabled() ) {
		// Allow the stack to clear so the value will be updated
		setTimeout( function () {
			widget.setValue( widget.$input.val() );
		} );
	}
};

/**
 * Get the value of the input.
 *
 * @return {string} Input value
 */
OO.ui.InputWidget.prototype.getValue = function () {
	// Resynchronize our internal data with DOM data. Other scripts executing on the page can modify
	// it, and we won't know unless they're kind enough to trigger a 'change' event.
	var value = this.$input.val();
	if ( this.value !== value ) {
		this.setValue( value );
	}
	return this.value;
};

/**
 * Sets the direction of the current input, either RTL or LTR
 *
 * @param {boolean} isRTL
 */
OO.ui.InputWidget.prototype.setRTL = function ( isRTL ) {
	this.$input.prop( 'dir', isRTL ? 'rtl' : 'ltr' );
};

/**
 * Set the value of the input.
 *
 * @param {string} value New value
 * @fires change
 * @chainable
 */
OO.ui.InputWidget.prototype.setValue = function ( value ) {
	value = this.cleanUpValue( value );
	// Update the DOM if it has changed. Note that with cleanUpValue, it
	// is possible for the DOM value to change without this.value changing.
	if ( this.$input.val() !== value ) {
		this.$input.val( value );
	}
	if ( this.value !== value ) {
		this.value = value;
		this.emit( 'change', this.value );
	}
	return this;
};

/**
 * Clean up incoming value.
 *
 * Ensures value is a string, and converts undefined and null to empty string.
 *
 * @private
 * @param {string} value Original value
 * @return {string} Cleaned up value
 */
OO.ui.InputWidget.prototype.cleanUpValue = function ( value ) {
	if ( value === undefined || value === null ) {
		return '';
	} else if ( this.inputFilter ) {
		return this.inputFilter( String( value ) );
	} else {
		return String( value );
	}
};

/**
 * Simulate the behavior of clicking on a label bound to this input.
 */
OO.ui.InputWidget.prototype.simulateLabelClick = function () {
	if ( !this.isDisabled() ) {
		if ( this.$input.is( ':checkbox, :radio' ) ) {
			this.$input.click();
		}
		if ( this.$input.is( ':input' ) ) {
			this.$input[ 0 ].focus();
		}
	}
};

/**
 * @inheritdoc
 */
OO.ui.InputWidget.prototype.setDisabled = function ( state ) {
	OO.ui.InputWidget.super.prototype.setDisabled.call( this, state );
	if ( this.$input ) {
		this.$input.prop( 'disabled', this.isDisabled() );
	}
	return this;
};

/**
 * Focus the input.
 *
 * @chainable
 */
OO.ui.InputWidget.prototype.focus = function () {
	this.$input[ 0 ].focus();
	return this;
};

/**
 * Blur the input.
 *
 * @chainable
 */
OO.ui.InputWidget.prototype.blur = function () {
	this.$input[ 0 ].blur();
	return this;
};

/**
 * ButtonInputWidget is used to submit HTML forms and is intended to be used within
 * a OO.ui.FormLayout. If you do not need the button to work with HTML forms, you probably
 * want to use OO.ui.ButtonWidget instead. Button input widgets can be rendered as either an
 * HTML `<button/>` (the default) or an HTML `<input/>` tags. See the
 * [OOjs UI documentation on MediaWiki] [1] for more information.
 *
 *     @example
 *     // A ButtonInputWidget rendered as an HTML button, the default.
 *     var button = new OO.ui.ButtonInputWidget( {
 *         label: 'Input button',
 *         icon: 'check',
 *         value: 'check'
 *     } );
 *     $( 'body' ).append( button.$element );
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Inputs#Button_inputs
 *
 * @class
 * @extends OO.ui.InputWidget
 * @mixins OO.ui.ButtonElement
 * @mixins OO.ui.IconElement
 * @mixins OO.ui.IndicatorElement
 * @mixins OO.ui.LabelElement
 * @mixins OO.ui.TitledElement
 * @mixins OO.ui.FlaggedElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {string} [type='button'] HTML tag `type` attribute, may be 'button', 'submit' or 'reset'
 * @cfg {boolean} [useInputTag=false] Whether to use `<input/>` rather than `<button/>`. Only useful
 *  if you need IE 6 support in a form with multiple buttons. If you use this option, icons and
 *  indicators will not be displayed, it won't be possible to have a non-plaintext label, and it
 *  won't be possible to set a value (which will internally become identical to the label).
 */
OO.ui.ButtonInputWidget = function OoUiButtonInputWidget( config ) {
	// Configuration initialization
	config = $.extend( { type: 'button', useInputTag: false }, config );

	// Properties (must be set before parent constructor, which calls #setValue)
	this.useInputTag = config.useInputTag;

	// Parent constructor
	OO.ui.ButtonInputWidget.super.call( this, config );

	// Mixin constructors
	OO.ui.ButtonElement.call( this, $.extend( {}, config, { $button: this.$input } ) );
	OO.ui.IconElement.call( this, config );
	OO.ui.IndicatorElement.call( this, config );
	OO.ui.LabelElement.call( this, config );
	OO.ui.TitledElement.call( this, $.extend( {}, config, { $titled: this.$input } ) );
	OO.ui.FlaggedElement.call( this, config );

	// Initialization
	if ( !config.useInputTag ) {
		this.$input.append( this.$icon, this.$label, this.$indicator );
	}
	this.$element.addClass( 'oo-ui-buttonInputWidget' );
};

/* Setup */

OO.inheritClass( OO.ui.ButtonInputWidget, OO.ui.InputWidget );
OO.mixinClass( OO.ui.ButtonInputWidget, OO.ui.ButtonElement );
OO.mixinClass( OO.ui.ButtonInputWidget, OO.ui.IconElement );
OO.mixinClass( OO.ui.ButtonInputWidget, OO.ui.IndicatorElement );
OO.mixinClass( OO.ui.ButtonInputWidget, OO.ui.LabelElement );
OO.mixinClass( OO.ui.ButtonInputWidget, OO.ui.TitledElement );
OO.mixinClass( OO.ui.ButtonInputWidget, OO.ui.FlaggedElement );

/* Methods */

/**
 * @inheritdoc
 * @private
 */
OO.ui.ButtonInputWidget.prototype.getInputElement = function ( config ) {
	var html = '<' + ( config.useInputTag ? 'input' : 'button' ) + ' type="' + config.type + '">';
	return $( html );
};

/**
 * Set label value.
 *
 * Overridden to support setting the 'value' of `<input/>` elements.
 *
 * @param {jQuery|string|Function|null} label Label nodes; text; a function that returns nodes or
 *  text; or null for no label
 * @chainable
 */
OO.ui.ButtonInputWidget.prototype.setLabel = function ( label ) {
	OO.ui.LabelElement.prototype.setLabel.call( this, label );

	if ( this.useInputTag ) {
		if ( typeof label === 'function' ) {
			label = OO.ui.resolveMsg( label );
		}
		if ( label instanceof jQuery ) {
			label = label.text();
		}
		if ( !label ) {
			label = '';
		}
		this.$input.val( label );
	}

	return this;
};

/**
 * Set the value of the input.
 *
 * Overridden to disable for `<input/>` elements, which have value identical to the label.
 *
 * @param {string} value New value
 * @chainable
 */
OO.ui.ButtonInputWidget.prototype.setValue = function ( value ) {
	if ( !this.useInputTag ) {
		OO.ui.ButtonInputWidget.super.prototype.setValue.call( this, value );
	}
	return this;
};

/**
 * CheckboxInputWidgets, like HTML checkboxes, can be selected and/or configured with a value.
 *  Note that these {@link OO.ui.InputWidget input widgets} are best laid out
 * in {@link OO.ui.FieldLayout field layouts} that use the {@link OO.ui.FieldLayout#align inline}
 * alignment. For more information, please see the [OOjs UI documentation on MediaWiki][1].
 *
 *     @example
 *     // An example of selected, unselected, and disabled checkbox inputs
 *     var checkbox1=new OO.ui.CheckboxInputWidget({
 *          value: 'a',
 *          selected: true
 *     });
 *     var checkbox2=new OO.ui.CheckboxInputWidget({
 *         value: 'b'
 *     });
 *     var checkbox3=new OO.ui.CheckboxInputWidget( {
 *         value:'c',
 *         disabled: true
 *     } );
 *     // Create a fieldset layout with fields for each checkbox.
 *     var fieldset = new OO.ui.FieldsetLayout( {
 *         label: 'Checkboxes'
 *     } );
 *     fieldset.addItems( [
 *         new OO.ui.FieldLayout( checkbox1, {label : 'Selected checkbox', align : 'inline'}),
 *         new OO.ui.FieldLayout( checkbox2, {label : 'Unselected checkbox', align : 'inline'}),
 *         new OO.ui.FieldLayout( checkbox3, {label : 'Disabled checkbox', align : 'inline'}),
 *     ] );
 *     $( 'body' ).append( fieldset.$element );
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Inputs
 *
 * @class
 * @extends OO.ui.InputWidget
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {boolean} [selected=false] Select the checkbox initially. By default, the checkbox is not selected.
 */
OO.ui.CheckboxInputWidget = function OoUiCheckboxInputWidget( config ) {
	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.CheckboxInputWidget.super.call( this, config );

	// Initialization
	this.$element.addClass( 'oo-ui-checkboxInputWidget' );
	this.setSelected( config.selected !== undefined ? config.selected : false );
};

/* Setup */

OO.inheritClass( OO.ui.CheckboxInputWidget, OO.ui.InputWidget );

/* Methods */

/**
 * @inheritdoc
 * @private
 */
OO.ui.CheckboxInputWidget.prototype.getInputElement = function () {
	return $( '<input type="checkbox" />' );
};

/**
 * @inheritdoc
 */
OO.ui.CheckboxInputWidget.prototype.onEdit = function () {
	var widget = this;
	if ( !this.isDisabled() ) {
		// Allow the stack to clear so the value will be updated
		setTimeout( function () {
			widget.setSelected( widget.$input.prop( 'checked' ) );
		} );
	}
};

/**
 * Set selection state of this checkbox.
 *
 * @param {boolean} state `true` for selected
 * @chainable
 */
OO.ui.CheckboxInputWidget.prototype.setSelected = function ( state ) {
	state = !!state;
	if ( this.selected !== state ) {
		this.selected = state;
		this.$input.prop( 'checked', this.selected );
		this.emit( 'change', this.selected );
	}
	return this;
};

/**
 * Check if this checkbox is selected.
 *
 * @return {boolean} Checkbox is selected
 */
OO.ui.CheckboxInputWidget.prototype.isSelected = function () {
	// Resynchronize our internal data with DOM data. Other scripts executing on the page can modify
	// it, and we won't know unless they're kind enough to trigger a 'change' event.
	var selected = this.$input.prop( 'checked' );
	if ( this.selected !== selected ) {
		this.setSelected( selected );
	}
	return this.selected;
};

/**
 * DropdownInputWidget is a {@link OO.ui.DropdownWidget DropdownWidget} intended to be used
 * within a {@link OO.ui.FormLayout form}. The selected value is synchronized with the value
 * of  a hidden HTML `input` tag. Please see the [OOjs UI documentation on MediaWiki][1] for
 * more information about input widgets.
 *
 *     @example
 *     // Example: A DropdownInputWidget with three options
 *     var dropDown=new OO.ui.DropdownInputWidget( {
 *         label: 'Dropdown menu: Select a menu option',
 *         options: [
 *             { data: 'a', label: 'First' } ,
 *             { data: 'b', label: 'Second'} ,
 *             { data: 'c', label: 'Third' }
 *         ]
 *     } );
 *     $('body').append(dropDown.$element);
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Inputs
 *
 * @class
 * @extends OO.ui.InputWidget
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {Object[]} [options=[]] Array of menu options in the format `{ data: …, label: … }`
 */
OO.ui.DropdownInputWidget = function OoUiDropdownInputWidget( config ) {
	// Configuration initialization
	config = config || {};

	// Properties (must be done before parent constructor which calls #setDisabled)
	this.dropdownWidget = new OO.ui.DropdownWidget();

	// Parent constructor
	OO.ui.DropdownInputWidget.super.call( this, config );

	// Events
	this.dropdownWidget.getMenu().connect( this, { select: 'onMenuSelect' } );

	// Initialization
	this.setOptions( config.options || [] );
	this.$element
		.addClass( 'oo-ui-dropdownInputWidget' )
		.append( this.dropdownWidget.$element );
};

/* Setup */

OO.inheritClass( OO.ui.DropdownInputWidget, OO.ui.InputWidget );

/* Methods */

/**
 * @inheritdoc
 * @private
 */
OO.ui.DropdownInputWidget.prototype.getInputElement = function () {
	return $( '<input type="hidden">' );
};

/**
 * Handles menu select events.
 *
 * @private
 * @param {OO.ui.MenuOptionWidget} item Selected menu item
 */
OO.ui.DropdownInputWidget.prototype.onMenuSelect = function ( item ) {
	this.setValue( item.getData() );
};

/**
 * @inheritdoc
 */
OO.ui.DropdownInputWidget.prototype.setValue = function ( value ) {
	var item = this.dropdownWidget.getMenu().getItemFromData( value );
	if ( item ) {
		this.dropdownWidget.getMenu().selectItem( item );
	}
	OO.ui.DropdownInputWidget.super.prototype.setValue.call( this, value );
	return this;
};

/**
 * @inheritdoc
 */
OO.ui.DropdownInputWidget.prototype.setDisabled = function ( state ) {
	this.dropdownWidget.setDisabled( state );
	OO.ui.DropdownInputWidget.super.prototype.setDisabled.call( this, state );
	return this;
};

/**
 * Set the options available for this input.
 *
 * @param {Object[]} options Array of menu options in the format `{ data: …, label: … }`
 * @chainable
 */
OO.ui.DropdownInputWidget.prototype.setOptions = function ( options ) {
	var value = this.getValue();

	// Rebuild the dropdown menu
	this.dropdownWidget.getMenu()
		.clearItems()
		.addItems( options.map( function ( opt ) {
			return new OO.ui.MenuOptionWidget( {
				data: opt.data,
				label: opt.label !== undefined ? opt.label : opt.data
			} );
		} ) );

	// Restore the previous value, or reset to something sensible
	if ( this.dropdownWidget.getMenu().getItemFromData( value ) ) {
		// Previous value is still available, ensure consistency with the dropdown
		this.setValue( value );
	} else {
		// No longer valid, reset
		if ( options.length ) {
			this.setValue( options[ 0 ].data );
		}
	}

	return this;
};

/**
 * @inheritdoc
 */
OO.ui.DropdownInputWidget.prototype.focus = function () {
	this.dropdownWidget.getMenu().toggle( true );
	return this;
};

/**
 * @inheritdoc
 */
OO.ui.DropdownInputWidget.prototype.blur = function () {
	this.dropdownWidget.getMenu().toggle( false );
	return this;
};

/**
 * RadioInputWidget creates a single radio button. Because radio buttons are usually used as a set,
 * in most cases you will want to use a {@link OO.ui.RadioSelectWidget radio select}
 * with {@link OO.ui.RadioOptionWidget radio options} instead of this class. For more information,
 * please see the [OOjs UI documentation on MediaWiki][1].
 *
 *     @example
 *     // An example of selected, unselected, and disabled radio inputs
 *     var radio1=new OO.ui.RadioInputWidget({
 *         value: 'a',
 *         selected: true
 *     });
 *     var radio2=new OO.ui.RadioInputWidget({
 *         value: 'b'
 *     });
 *     var radio3=new OO.ui.RadioInputWidget( {
 *         value:'c',
 *         disabled: true
 *     } );
 *     // Create a fieldset layout with fields for each radio button.
 *     var fieldset = new OO.ui.FieldsetLayout( {
 *         label: 'Radio inputs'
 *     } );
 *     fieldset.addItems( [
 *         new OO.ui.FieldLayout( radio1, {label : 'Selected', align : 'inline'}),
 *         new OO.ui.FieldLayout( radio2, {label : 'Unselected', align : 'inline'}),
 *         new OO.ui.FieldLayout( radio3, {label : 'Disabled', align : 'inline'}),
 *     ] );
 *     $( 'body' ).append( fieldset.$element );
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Inputs
 *
 * @class
 * @extends OO.ui.InputWidget
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {boolean} [selected=false] Select the radio button initially. By default, the radio button is not selected.
 */
OO.ui.RadioInputWidget = function OoUiRadioInputWidget( config ) {
	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.RadioInputWidget.super.call( this, config );

	// Initialization
	this.$element.addClass( 'oo-ui-radioInputWidget' );
	this.setSelected( config.selected !== undefined ? config.selected : false );
};

/* Setup */

OO.inheritClass( OO.ui.RadioInputWidget, OO.ui.InputWidget );

/* Methods */

/**
 * @inheritdoc
 * @private
 */
OO.ui.RadioInputWidget.prototype.getInputElement = function () {
	return $( '<input type="radio" />' );
};

/**
 * @inheritdoc
 */
OO.ui.RadioInputWidget.prototype.onEdit = function () {
	// RadioInputWidget doesn't track its state.
};

/**
 * Set selection state of this radio button.
 *
 * @param {boolean} state `true` for selected
 * @chainable
 */
OO.ui.RadioInputWidget.prototype.setSelected = function ( state ) {
	// RadioInputWidget doesn't track its state.
	this.$input.prop( 'checked', state );
	return this;
};

/**
 * Check if this radio button is selected.
 *
 * @return {boolean} Radio is selected
 */
OO.ui.RadioInputWidget.prototype.isSelected = function () {
	return this.$input.prop( 'checked' );
};

/**
 * TextInputWidgets, like HTML text inputs, can be configured with options that customize the
 * size of the field as well as its presentation. In addition, these widgets can be configured
 * with {@link OO.ui.IconElement icons}, {@link OO.ui.IndicatorElement indicators}, an optional
 * validation-pattern (used to determine if an input value is valid or not) and an input filter,
 * which modifies incoming values rather than validating them.
 * Please see the [OOjs UI documentation on MediaWiki] [1] for more information and examples.
 *
 *     @example
 *     // Example of a text input widget
 *     var textInput=new OO.ui.TextInputWidget( {
 *         value: 'Text input'
 *     } )
 *     $('body').append(textInput.$element);
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Inputs
 *
 * @class
 * @extends OO.ui.InputWidget
 * @mixins OO.ui.IconElement
 * @mixins OO.ui.IndicatorElement
 * @mixins OO.ui.PendingElement
 * @mixins OO.ui.LabelElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {string} [type='text'] The value of the HTML `type` attribute
 * @cfg {string} [placeholder] Placeholder text
 * @cfg {boolean} [autofocus=false] Use an HTML `autofocus` attribute to
 *  instruct the browser to focus this widget.
 * @cfg {boolean} [readOnly=false] Prevent changes to the value of the text input.
 * @cfg {number} [maxLength] Maximum number of characters allowed in the input.
 * @cfg {boolean} [multiline=false] Allow multiple lines of text
 * @cfg {boolean} [autosize=false] Automatically resize the text input to fit its content.
 *  Use the #maxRows config to specify a maximum number of displayed rows.
 * @cfg {boolean} [maxRows=10] Maximum number of rows to display when #autosize is set to true.
 * @cfg {string} [labelPosition='after'] The position of the inline label relative to that of
 *  the value or placeholder text: `'before'` or `'after'`
 * @cfg {boolean} [required=false] Mark the field as required
 * @cfg {RegExp|string} [validate] Validation pattern, either a regular expression or the
 *  symbolic name of a pattern defined by the class: 'non-empty' (the value cannot be an empty string)
 *  or 'integer' (the value must contain only numbers).
 */
OO.ui.TextInputWidget = function OoUiTextInputWidget( config ) {
	// Configuration initialization
	config = $.extend( {
		type: 'text',
		labelPosition: 'after',
		maxRows: 10
	}, config );

	// Parent constructor
	OO.ui.TextInputWidget.super.call( this, config );

	// Mixin constructors
	OO.ui.IconElement.call( this, config );
	OO.ui.IndicatorElement.call( this, config );
	OO.ui.PendingElement.call( this, config );
	OO.ui.LabelElement.call( this, config );

	// Properties
	this.readOnly = false;
	this.multiline = !!config.multiline;
	this.autosize = !!config.autosize;
	this.maxRows = config.maxRows;
	this.validate = null;

	// Clone for resizing
	if ( this.autosize ) {
		this.$clone = this.$input
			.clone()
			.insertAfter( this.$input )
			.attr( 'aria-hidden', 'true' )
			.addClass( 'oo-ui-element-hidden' );
	}

	this.setValidation( config.validate );
	this.setLabelPosition( config.labelPosition );

	// Events
	this.$input.on( {
		keypress: this.onKeyPress.bind( this ),
		blur: this.setValidityFlag.bind( this )
	} );
	this.$element.on( 'DOMNodeInsertedIntoDocument', this.onElementAttach.bind( this ) );
	this.$icon.on( 'mousedown', this.onIconMouseDown.bind( this ) );
	this.$indicator.on( 'mousedown', this.onIndicatorMouseDown.bind( this ) );
	this.on( 'labelChange', this.updatePosition.bind( this ) );

	// Initialization
	this.$element
		.addClass( 'oo-ui-textInputWidget' )
		.append( this.$icon, this.$indicator );
	this.setReadOnly( !!config.readOnly );
	if ( config.placeholder ) {
		this.$input.attr( 'placeholder', config.placeholder );
	}
	if ( config.maxLength !== undefined ) {
		this.$input.attr( 'maxlength', config.maxLength );
	}
	if ( config.autofocus ) {
		this.$input.attr( 'autofocus', 'autofocus' );
	}
	if ( config.required ) {
		this.$input.attr( 'required', 'true' );
	}
};

/* Setup */

OO.inheritClass( OO.ui.TextInputWidget, OO.ui.InputWidget );
OO.mixinClass( OO.ui.TextInputWidget, OO.ui.IconElement );
OO.mixinClass( OO.ui.TextInputWidget, OO.ui.IndicatorElement );
OO.mixinClass( OO.ui.TextInputWidget, OO.ui.PendingElement );
OO.mixinClass( OO.ui.TextInputWidget, OO.ui.LabelElement );

/* Static properties */

OO.ui.TextInputWidget.static.validationPatterns = {
	'non-empty': /.+/,
	integer: /^\d+$/
};

/* Events */

/**
 * An `enter` event is emitted when the user presses 'enter' inside the text box.
 *
 * Not emitted if the input is multiline.
 *
 * @event enter
 */

/* Methods */

/**
 * Handle icon mouse down events.
 *
 * @private
 * @param {jQuery.Event} e Mouse down event
 * @fires icon
 */
OO.ui.TextInputWidget.prototype.onIconMouseDown = function ( e ) {
	if ( e.which === 1 ) {
		this.$input[ 0 ].focus();
		return false;
	}
};

/**
 * Handle indicator mouse down events.
 *
 * @private
 * @param {jQuery.Event} e Mouse down event
 * @fires indicator
 */
OO.ui.TextInputWidget.prototype.onIndicatorMouseDown = function ( e ) {
	if ( e.which === 1 ) {
		this.$input[ 0 ].focus();
		return false;
	}
};

/**
 * Handle key press events.
 *
 * @private
 * @param {jQuery.Event} e Key press event
 * @fires enter If enter key is pressed and input is not multiline
 */
OO.ui.TextInputWidget.prototype.onKeyPress = function ( e ) {
	if ( e.which === OO.ui.Keys.ENTER && !this.multiline ) {
		this.emit( 'enter', e );
	}
};

/**
 * Handle element attach events.
 *
 * @private
 * @param {jQuery.Event} e Element attach event
 */
OO.ui.TextInputWidget.prototype.onElementAttach = function () {
	// Any previously calculated size is now probably invalid if we reattached elsewhere
	this.valCache = null;
	this.adjustSize();
	this.positionLabel();
};

/**
 * @inheritdoc
 */
OO.ui.TextInputWidget.prototype.onEdit = function () {
	this.adjustSize();

	// Parent method
	return OO.ui.TextInputWidget.super.prototype.onEdit.call( this );
};

/**
 * @inheritdoc
 */
OO.ui.TextInputWidget.prototype.setValue = function ( value ) {
	// Parent method
	OO.ui.TextInputWidget.super.prototype.setValue.call( this, value );

	this.setValidityFlag();
	this.adjustSize();
	return this;
};

/**
 * Check if the input is {@link #readOnly read-only}.
 *
 * @return {boolean}
 */
OO.ui.TextInputWidget.prototype.isReadOnly = function () {
	return this.readOnly;
};

/**
 * Set the {@link #readOnly read-only} state of the input.
 *
 * @param {boolean} state Make input read-only
 * @chainable
 */
OO.ui.TextInputWidget.prototype.setReadOnly = function ( state ) {
	this.readOnly = !!state;
	this.$input.prop( 'readOnly', this.readOnly );
	return this;
};

/**
 * Automatically adjust the size of the text input.
 *
 * This only affects #multiline inputs that are {@link #autosize autosized}.
 *
 * @chainable
 */
OO.ui.TextInputWidget.prototype.adjustSize = function () {
	var scrollHeight, innerHeight, outerHeight, maxInnerHeight, measurementError, idealHeight;

	if ( this.multiline && this.autosize && this.$input.val() !== this.valCache ) {
		this.$clone
			.val( this.$input.val() )
			.attr( 'rows', '' )
			// Set inline height property to 0 to measure scroll height
			.css( 'height', 0 );

		this.$clone.removeClass( 'oo-ui-element-hidden' );

		this.valCache = this.$input.val();

		scrollHeight = this.$clone[ 0 ].scrollHeight;

		// Remove inline height property to measure natural heights
		this.$clone.css( 'height', '' );
		innerHeight = this.$clone.innerHeight();
		outerHeight = this.$clone.outerHeight();

		// Measure max rows height
		this.$clone
			.attr( 'rows', this.maxRows )
			.css( 'height', 'auto' )
			.val( '' );
		maxInnerHeight = this.$clone.innerHeight();

		// Difference between reported innerHeight and scrollHeight with no scrollbars present
		// Equals 1 on Blink-based browsers and 0 everywhere else
		measurementError = maxInnerHeight - this.$clone[ 0 ].scrollHeight;
		idealHeight = Math.min( maxInnerHeight, scrollHeight + measurementError );

		this.$clone.addClass( 'oo-ui-element-hidden' );

		// Only apply inline height when expansion beyond natural height is needed
		if ( idealHeight > innerHeight ) {
			// Use the difference between the inner and outer height as a buffer
			this.$input.css( 'height', idealHeight + ( outerHeight - innerHeight ) );
		} else {
			this.$input.css( 'height', '' );
		}
	}
	return this;
};

/**
 * @inheritdoc
 * @private
 */
OO.ui.TextInputWidget.prototype.getInputElement = function ( config ) {
	return config.multiline ? $( '<textarea>' ) : $( '<input type="' + config.type + '" />' );
};

/**
 * Check if the input supports multiple lines.
 *
 * @return {boolean}
 */
OO.ui.TextInputWidget.prototype.isMultiline = function () {
	return !!this.multiline;
};

/**
 * Check if the input automatically adjusts its size.
 *
 * @return {boolean}
 */
OO.ui.TextInputWidget.prototype.isAutosizing = function () {
	return !!this.autosize;
};

/**
 * Select the entire text of the input.
 *
 * @chainable
 */
OO.ui.TextInputWidget.prototype.select = function () {
	this.$input.select();
	return this;
};

/**
 * Set the validation pattern.
 *
 * The validation pattern is either a regular expression or the symbolic name of a pattern
 * defined by the class: 'non-empty' (the value cannot be an empty string) or 'integer' (the
 * value must contain only numbers).
 *
 * @param {RegExp|string|null} validate Regular expression or the symbolic name of a
 *  pattern (either ‘integer’ or ‘non-empty’) defined by the class.
 */
OO.ui.TextInputWidget.prototype.setValidation = function ( validate ) {
	if ( validate instanceof RegExp ) {
		this.validate = validate;
	} else {
		this.validate = this.constructor.static.validationPatterns[ validate ] || /.*/;
	}
};

/**
 * Sets the 'invalid' flag appropriately.
 */
OO.ui.TextInputWidget.prototype.setValidityFlag = function () {
	var widget = this;
	this.isValid().done( function ( valid ) {
		widget.setFlags( { invalid: !valid } );
	} );
};

/**
 * Check if a value is valid.
 *
 * This method returns a promise that resolves with a boolean `true` if the current value is
 * considered valid according to the supplied {@link #validate validation pattern}.
 *
 * @return {jQuery.Deferred} A promise that resolves to a boolean `true` if the value is valid.
 */
OO.ui.TextInputWidget.prototype.isValid = function () {
	return $.Deferred().resolve( !!this.getValue().match( this.validate ) ).promise();
};

/**
 * Set the position of the inline label relative to that of the value: `‘before’` or `‘after’`.
 *
 * @param {string} labelPosition Label position, 'before' or 'after'
 * @chainable
 */
OO.ui.TextInputWidget.prototype.setLabelPosition = function ( labelPosition ) {
	this.labelPosition = labelPosition;
	this.updatePosition();
	return this;
};

/**
 * Deprecated alias of #setLabelPosition
 *
 * @deprecated Use setLabelPosition instead.
 */
OO.ui.TextInputWidget.prototype.setPosition =
	OO.ui.TextInputWidget.prototype.setLabelPosition;

/**
 * Update the position of the inline label.
 *
 * This method is called by #setLabelPosition, and can also be called on its own if
 * something causes the label to be mispositioned.
 *
 *
 * @chainable
 */
OO.ui.TextInputWidget.prototype.updatePosition = function () {
	var after = this.labelPosition === 'after';

	this.$element
		.toggleClass( 'oo-ui-textInputWidget-labelPosition-after', !!this.label && after )
		.toggleClass( 'oo-ui-textInputWidget-labelPosition-before', !!this.label && !after );

	if ( this.label ) {
		this.positionLabel();
	}

	return this;
};

/**
 * Position the label by setting the correct padding on the input.
 *
 * @private
 * @chainable
 */
OO.ui.TextInputWidget.prototype.positionLabel = function () {
	// Clear old values
	this.$input
		// Clear old values if present
		.css( {
			'padding-right': '',
			'padding-left': ''
		} );

	if ( this.label ) {
		this.$element.append( this.$label );
	} else {
		this.$label.detach();
		return;
	}

	var after = this.labelPosition === 'after',
		rtl = this.$element.css( 'direction' ) === 'rtl',
		property = after === rtl ? 'padding-left' : 'padding-right';

	this.$input.css( property, this.$label.outerWidth( true ) );

	return this;
};

/**
 * ComboBoxWidgets combine a {@link OO.ui.TextInputWidget text input} (where a value
 * can be entered manually) and a {@link OO.ui.MenuSelectWidget menu of options} (from which
 * a value can be chosen instead). Users can choose options from the combo box in one of two ways:
 *
 * - by typing a value in the text input field. If the value exactly matches the value of a menu
 *   option, that option will appear to be selected.
 * - by choosing a value from the menu. The value of the chosen option will then appear in the text
 *   input field.
 *
 * For more information about menus and options, please see the [OOjs UI documentation on MediaWiki][1].
 *
 *     @example
 *     // Example: A ComboBoxWidget.
 *     var comboBox=new OO.ui.ComboBoxWidget( {
 *         label: 'ComboBoxWidget',
 *         input: { value: 'Option One' },
 *         menu: {
 *             items: [
 *                 new OO.ui.MenuOptionWidget( {
 *                     data: 'Option 1',
 *                     label: 'Option One' } ),
 *                 new OO.ui.MenuOptionWidget( {
 *                     data: 'Option 2',
 *                     label: 'Option Two' } ),
 *                 new OO.ui.MenuOptionWidget( {
 *                     data: 'Option 3',
 *                     label: 'Option Three'} ),
 *                 new OO.ui.MenuOptionWidget( {
 *                     data: 'Option 4',
 *                     label: 'Option Four' } ),
 *                 new OO.ui.MenuOptionWidget( {
 *                     data: 'Option 5',
 *                     label: 'Option Five' } )
 *             ]
 *         }
 *     } );
 *     $('body').append(comboBox.$element);
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Selects_and_Options#Menu_selects_and_options
 *
 * @class
 * @extends OO.ui.Widget
 * @mixins OO.ui.TabIndexedElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {Object} [menu] Configuration options to pass to the {@link OO.ui.MenuSelectWidget menu select widget}.
 * @cfg {Object} [input] Configuration options to pass to the {@link OO.ui.TextInputWidget text input widget}.
 * @cfg {jQuery} [$overlay] Render the menu into a separate layer. This configuration is useful in cases where
 *  the expanded menu is larger than its containing `<div>`. The specified overlay layer is usually on top of the
 *  containing `<div>` and has a larger area. By default, the menu uses relative positioning.
 */
OO.ui.ComboBoxWidget = function OoUiComboBoxWidget( config ) {
	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.ComboBoxWidget.super.call( this, config );

	// Properties (must be set before TabIndexedElement constructor call)
	this.$indicator = this.$( '<span>' );

	// Mixin constructors
	OO.ui.TabIndexedElement.call( this, $.extend( {}, config, { $tabIndexed: this.$indicator } ) );

	// Properties
	this.$overlay = config.$overlay || this.$element;
	this.input = new OO.ui.TextInputWidget( $.extend(
		{
			indicator: 'down',
			$indicator: this.$indicator,
			disabled: this.isDisabled()
		},
		config.input
	) );
	this.input.$input.eq( 0 ).attr( {
		role: 'combobox',
		'aria-autocomplete': 'list'
	} );
	this.menu = new OO.ui.TextInputMenuSelectWidget( this.input, $.extend(
		{
			widget: this,
			input: this.input,
			disabled: this.isDisabled()
		},
		config.menu
	) );

	// Events
	this.$indicator.on( {
		click: this.onClick.bind( this ),
		keypress: this.onKeyPress.bind( this )
	} );
	this.input.connect( this, {
		change: 'onInputChange',
		enter: 'onInputEnter'
	} );
	this.menu.connect( this, {
		choose: 'onMenuChoose',
		add: 'onMenuItemsChange',
		remove: 'onMenuItemsChange'
	} );

	// Initialization
	this.$element.addClass( 'oo-ui-comboBoxWidget' ).append( this.input.$element );
	this.$overlay.append( this.menu.$element );
	this.onMenuItemsChange();
};

/* Setup */

OO.inheritClass( OO.ui.ComboBoxWidget, OO.ui.Widget );
OO.mixinClass( OO.ui.ComboBoxWidget, OO.ui.TabIndexedElement );

/* Methods */

/**
 * Get the combobox's menu.
 * @return {OO.ui.TextInputMenuSelectWidget} Menu widget
 */
OO.ui.ComboBoxWidget.prototype.getMenu = function () {
	return this.menu;
};

/**
 * Handle input change events.
 *
 * @private
 * @param {string} value New value
 */
OO.ui.ComboBoxWidget.prototype.onInputChange = function ( value ) {
	var match = this.menu.getItemFromData( value );

	this.menu.selectItem( match );
	if ( this.menu.getHighlightedItem() ) {
		this.menu.highlightItem( match );
	}

	if ( !this.isDisabled() ) {
		this.menu.toggle( true );
	}
};

/**
 * Handle mouse click events.
 *
 *
 * @private
 * @param {jQuery.Event} e Mouse click event
 */
OO.ui.ComboBoxWidget.prototype.onClick = function ( e ) {
	if ( !this.isDisabled() && e.which === 1 ) {
		this.menu.toggle();
		this.input.$input[ 0 ].focus();
	}
	return false;
};

/**
 * Handle key press events.
 *
 *
 * @private
 * @param {jQuery.Event} e Key press event
 */
OO.ui.ComboBoxWidget.prototype.onKeyPress = function ( e ) {
	if ( !this.isDisabled() && ( e.which === OO.ui.Keys.SPACE || e.which === OO.ui.Keys.ENTER ) ) {
		this.menu.toggle();
		this.input.$input[ 0 ].focus();
	}
	return false;
};

/**
 * Handle input enter events.
 *
 * @private
 */
OO.ui.ComboBoxWidget.prototype.onInputEnter = function () {
	if ( !this.isDisabled() ) {
		this.menu.toggle( false );
	}
};

/**
 * Handle menu choose events.
 *
 * @private
 * @param {OO.ui.OptionWidget} item Chosen item
 */
OO.ui.ComboBoxWidget.prototype.onMenuChoose = function ( item ) {
	if ( item ) {
		this.input.setValue( item.getData() );
	}
};

/**
 * Handle menu item change events.
 *
 * @private
 */
OO.ui.ComboBoxWidget.prototype.onMenuItemsChange = function () {
	var match = this.menu.getItemFromData( this.input.getValue() );
	this.menu.selectItem( match );
	if ( this.menu.getHighlightedItem() ) {
		this.menu.highlightItem( match );
	}
	this.$element.toggleClass( 'oo-ui-comboBoxWidget-empty', this.menu.isEmpty() );
};

/**
 * @inheritdoc
 */
OO.ui.ComboBoxWidget.prototype.setDisabled = function ( disabled ) {
	// Parent method
	OO.ui.ComboBoxWidget.super.prototype.setDisabled.call( this, disabled );

	if ( this.input ) {
		this.input.setDisabled( this.isDisabled() );
	}
	if ( this.menu ) {
		this.menu.setDisabled( this.isDisabled() );
	}

	return this;
};

/**
 * LabelWidgets help identify the function of interface elements. Each LabelWidget can
 * be configured with a `label` option that is set to a string, a label node, or a function:
 *
 * - String: a plaintext string
 * - jQuery selection: a jQuery selection, used for anything other than a plaintext label, e.g., a
 *   label that includes a link or special styling, such as a gray color or additional graphical elements.
 * - Function: a function that will produce a string in the future. Functions are used
 *   in cases where the value of the label is not currently defined.
 *
 * In addition, the LabelWidget can be associated with an {@link OO.ui.InputWidget input widget}, which
 * will come into focus when the label is clicked.
 *
 *     @example
 *     // Examples of LabelWidgets
 *     var label1 = new OO.ui.LabelWidget({
 *         label: 'plaintext label'
 *     });
 *     var label2 = new OO.ui.LabelWidget({
 *         label: $( '<a href="default.html">jQuery label</a>'  )
 *     });
 *     // Create a fieldset layout with fields for each example
 *     var fieldset = new OO.ui.FieldsetLayout( );
 *     fieldset.addItems( [
 *         new OO.ui.FieldLayout( label1 ),
 *         new OO.ui.FieldLayout( label2 )
 *     ] );
 *     $( 'body' ).append( fieldset.$element );
 *
 *
 * @class
 * @extends OO.ui.Widget
 * @mixins OO.ui.LabelElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {OO.ui.InputWidget} [input] {@link OO.ui.InputWidget Input widget} that uses the label.
 *  Clicking the label will focus the specified input field.
 */
OO.ui.LabelWidget = function OoUiLabelWidget( config ) {
	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.LabelWidget.super.call( this, config );

	// Mixin constructors
	OO.ui.LabelElement.call( this, $.extend( {}, config, { $label: this.$element } ) );
	OO.ui.TitledElement.call( this, config );

	// Properties
	this.input = config.input;

	// Events
	if ( this.input instanceof OO.ui.InputWidget ) {
		this.$element.on( 'click', this.onClick.bind( this ) );
	}

	// Initialization
	this.$element.addClass( 'oo-ui-labelWidget' );
};

/* Setup */

OO.inheritClass( OO.ui.LabelWidget, OO.ui.Widget );
OO.mixinClass( OO.ui.LabelWidget, OO.ui.LabelElement );
OO.mixinClass( OO.ui.LabelWidget, OO.ui.TitledElement );

/* Static Properties */

OO.ui.LabelWidget.static.tagName = 'span';

/* Methods */

/**
 * Handles label mouse click events.
 *
 * @private
 * @param {jQuery.Event} e Mouse click event
 */
OO.ui.LabelWidget.prototype.onClick = function () {
	this.input.simulateLabelClick();
	return false;
};

/**
 * OptionWidgets are special elements that can be selected and configured with data. The
 * data is often unique for each option, but it does not have to be. OptionWidgets are used
 * with OO.ui.SelectWidget to create a selection of mutually exclusive options. For more information
 * and examples, please see the [OOjs UI documentation on MediaWiki][1].
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Selects_and_Options
 *
 * @class
 * @extends OO.ui.Widget
 * @mixins OO.ui.LabelElement
 * @mixins OO.ui.FlaggedElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
OO.ui.OptionWidget = function OoUiOptionWidget( config ) {
	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.OptionWidget.super.call( this, config );

	// Mixin constructors
	OO.ui.ItemWidget.call( this );
	OO.ui.LabelElement.call( this, config );
	OO.ui.FlaggedElement.call( this, config );

	// Properties
	this.selected = false;
	this.highlighted = false;
	this.pressed = false;

	// Initialization
	this.$element
		.data( 'oo-ui-optionWidget', this )
		.attr( 'role', 'option' )
		.addClass( 'oo-ui-optionWidget' )
		.append( this.$label );
};

/* Setup */

OO.inheritClass( OO.ui.OptionWidget, OO.ui.Widget );
OO.mixinClass( OO.ui.OptionWidget, OO.ui.ItemWidget );
OO.mixinClass( OO.ui.OptionWidget, OO.ui.LabelElement );
OO.mixinClass( OO.ui.OptionWidget, OO.ui.FlaggedElement );

/* Static Properties */

OO.ui.OptionWidget.static.selectable = true;

OO.ui.OptionWidget.static.highlightable = true;

OO.ui.OptionWidget.static.pressable = true;

OO.ui.OptionWidget.static.scrollIntoViewOnSelect = false;

/* Methods */

/**
 * Check if the option can be selected.
 *
 * @return {boolean} Item is selectable
 */
OO.ui.OptionWidget.prototype.isSelectable = function () {
	return this.constructor.static.selectable && !this.isDisabled();
};

/**
 * Check if the option can be highlighted. A highlight indicates that the option
 * may be selected when a user presses enter or clicks. Disabled items cannot
 * be highlighted.
 *
 * @return {boolean} Item is highlightable
 */
OO.ui.OptionWidget.prototype.isHighlightable = function () {
	return this.constructor.static.highlightable && !this.isDisabled();
};

/**
 * Check if the option can be pressed. The pressed state occurs when a user mouses
 * down on an item, but has not yet let go of the mouse.
 *
 * @return {boolean} Item is pressable
 */
OO.ui.OptionWidget.prototype.isPressable = function () {
	return this.constructor.static.pressable && !this.isDisabled();
};

/**
 * Check if the option is selected.
 *
 * @return {boolean} Item is selected
 */
OO.ui.OptionWidget.prototype.isSelected = function () {
	return this.selected;
};

/**
 * Check if the option is highlighted. A highlight indicates that the
 * item may be selected when a user presses enter or clicks.
 *
 * @return {boolean} Item is highlighted
 */
OO.ui.OptionWidget.prototype.isHighlighted = function () {
	return this.highlighted;
};

/**
 * Check if the option is pressed. The pressed state occurs when a user mouses
 * down on an item, but has not yet let go of the mouse. The item may appear
 * selected, but it will not be selected until the user releases the mouse.
 *
 * @return {boolean} Item is pressed
 */
OO.ui.OptionWidget.prototype.isPressed = function () {
	return this.pressed;
};

/**
 * Set the option’s selected state. In general, all modifications to the selection
 * should be handled by the SelectWidget’s {@link OO.ui.SelectWidget#selectItem selectItem( [item] )}
 * method instead of this method.
 *
 * @param {boolean} [state=false] Select option
 * @chainable
 */
OO.ui.OptionWidget.prototype.setSelected = function ( state ) {
	if ( this.constructor.static.selectable ) {
		this.selected = !!state;
		this.$element
			.toggleClass( 'oo-ui-optionWidget-selected', state )
			.attr( 'aria-selected', state.toString() );
		if ( state && this.constructor.static.scrollIntoViewOnSelect ) {
			this.scrollElementIntoView();
		}
		this.updateThemeClasses();
	}
	return this;
};

/**
 * Set the option’s highlighted state. In general, all programmatic
 * modifications to the highlight should be handled by the
 * SelectWidget’s {@link OO.ui.SelectWidget#highlightItem highlightItem( [item] )}
 * method instead of this method.
 *
 * @param {boolean} [state=false] Highlight option
 * @chainable
 */
OO.ui.OptionWidget.prototype.setHighlighted = function ( state ) {
	if ( this.constructor.static.highlightable ) {
		this.highlighted = !!state;
		this.$element.toggleClass( 'oo-ui-optionWidget-highlighted', state );
		this.updateThemeClasses();
	}
	return this;
};

/**
 * Set the option’s pressed state. In general, all
 * programmatic modifications to the pressed state should be handled by the
 * SelectWidget’s {@link OO.ui.SelectWidget#pressItem pressItem( [item] )}
 * method instead of this method.
 *
 * @param {boolean} [state=false] Press option
 * @chainable
 */
OO.ui.OptionWidget.prototype.setPressed = function ( state ) {
	if ( this.constructor.static.pressable ) {
		this.pressed = !!state;
		this.$element.toggleClass( 'oo-ui-optionWidget-pressed', state );
		this.updateThemeClasses();
	}
	return this;
};

/**
 * DecoratedOptionWidgets are {@link OO.ui.OptionWidget options} that can be configured
 * with an {@link OO.ui.IconElement icon} and/or {@link OO.ui.IndicatorElement indicator}.
 * This class is used with OO.ui.SelectWidget to create a selection of mutually exclusive
 * options. For more information about options and selects, please see the
 * [OOjs UI documentation on MediaWiki][1].
 *
 *     @example
 *     // Decorated options in a select widget
 *     var select=new OO.ui.SelectWidget( {
 *         items: [
 *             new OO.ui.DecoratedOptionWidget( {
 *                 data: 'a',
 *                 label: 'Option with icon',
 *                 icon: 'help'
 *             } ),
 *             new OO.ui.DecoratedOptionWidget( {
 *                 data: 'b',
 *                 label: 'Option with indicator',
 *                 indicator: 'next'
 *             } )
 *         ]
 *     } );
 *     $('body').append(select.$element);
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Selects_and_Options
 *
 * @class
 * @extends OO.ui.OptionWidget
 * @mixins OO.ui.IconElement
 * @mixins OO.ui.IndicatorElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
OO.ui.DecoratedOptionWidget = function OoUiDecoratedOptionWidget( config ) {
	// Parent constructor
	OO.ui.DecoratedOptionWidget.super.call( this, config );

	// Mixin constructors
	OO.ui.IconElement.call( this, config );
	OO.ui.IndicatorElement.call( this, config );

	// Initialization
	this.$element
		.addClass( 'oo-ui-decoratedOptionWidget' )
		.prepend( this.$icon )
		.append( this.$indicator );
};

/* Setup */

OO.inheritClass( OO.ui.DecoratedOptionWidget, OO.ui.OptionWidget );
OO.mixinClass( OO.ui.OptionWidget, OO.ui.IconElement );
OO.mixinClass( OO.ui.OptionWidget, OO.ui.IndicatorElement );

/**
 * ButtonOptionWidget is a special type of {@link OO.ui.ButtonElement button element} that
 * can be selected and configured with data. The class is
 * used with OO.ui.ButtonSelectWidget to create a selection of button options. Please see the
 * [OOjs UI documentation on MediaWiki] [1] for more information.
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Selects_and_Options#Button_selects_and_options
 *
 * @class
 * @extends OO.ui.DecoratedOptionWidget
 * @mixins OO.ui.ButtonElement
 * @mixins OO.ui.TabIndexedElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
OO.ui.ButtonOptionWidget = function OoUiButtonOptionWidget( config ) {
	// Configuration initialization
	config = $.extend( { tabIndex: -1 }, config );

	// Parent constructor
	OO.ui.ButtonOptionWidget.super.call( this, config );

	// Mixin constructors
	OO.ui.ButtonElement.call( this, config );
	OO.ui.TabIndexedElement.call( this, $.extend( {}, config, { $tabIndexed: this.$button } ) );

	// Initialization
	this.$element.addClass( 'oo-ui-buttonOptionWidget' );
	this.$button.append( this.$element.contents() );
	this.$element.append( this.$button );
};

/* Setup */

OO.inheritClass( OO.ui.ButtonOptionWidget, OO.ui.DecoratedOptionWidget );
OO.mixinClass( OO.ui.ButtonOptionWidget, OO.ui.ButtonElement );
OO.mixinClass( OO.ui.ButtonOptionWidget, OO.ui.TabIndexedElement );

/* Static Properties */

// Allow button mouse down events to pass through so they can be handled by the parent select widget
OO.ui.ButtonOptionWidget.static.cancelButtonMouseDownEvents = false;

OO.ui.ButtonOptionWidget.static.highlightable = false;

/* Methods */

/**
 * @inheritdoc
 */
OO.ui.ButtonOptionWidget.prototype.setSelected = function ( state ) {
	OO.ui.ButtonOptionWidget.super.prototype.setSelected.call( this, state );

	if ( this.constructor.static.selectable ) {
		this.setActive( state );
	}

	return this;
};

/**
 * RadioOptionWidget is an option widget that looks like a radio button.
 * The class is used with OO.ui.RadioSelectWidget to create a selection of radio options.
 * Please see the [OOjs UI documentation on MediaWiki] [1] for more information.
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Selects_and_Options#Button_selects_and_option
 *
 * @class
 * @extends OO.ui.OptionWidget
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
OO.ui.RadioOptionWidget = function OoUiRadioOptionWidget( config ) {
	// Configuration initialization
	config = config || {};

	// Properties (must be done before parent constructor which calls #setDisabled)
	this.radio = new OO.ui.RadioInputWidget( { value: config.data, tabIndex: -1 } );

	// Parent constructor
	OO.ui.RadioOptionWidget.super.call( this, config );

	// Initialization
	this.$element
		.addClass( 'oo-ui-radioOptionWidget' )
		.prepend( this.radio.$element );
};

/* Setup */

OO.inheritClass( OO.ui.RadioOptionWidget, OO.ui.OptionWidget );

/* Static Properties */

OO.ui.RadioOptionWidget.static.highlightable = false;

OO.ui.RadioOptionWidget.static.scrollIntoViewOnSelect = true;

OO.ui.RadioOptionWidget.static.pressable = false;

OO.ui.RadioOptionWidget.static.tagName = 'label';

/* Methods */

/**
 * @inheritdoc
 */
OO.ui.RadioOptionWidget.prototype.setSelected = function ( state ) {
	OO.ui.RadioOptionWidget.super.prototype.setSelected.call( this, state );

	this.radio.setSelected( state );

	return this;
};

/**
 * @inheritdoc
 */
OO.ui.RadioOptionWidget.prototype.setDisabled = function ( disabled ) {
	OO.ui.RadioOptionWidget.super.prototype.setDisabled.call( this, disabled );

	this.radio.setDisabled( this.isDisabled() );

	return this;
};

/**
 * MenuOptionWidget is an option widget that looks like a menu item. The class is used with
 * OO.ui.MenuSelectWidget to create a menu of mutually exclusive options. Please see
 * the [OOjs UI documentation on MediaWiki] [1] for more information.
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Selects_and_Options#Menu_selects_and_options
 *
 * @class
 * @extends OO.ui.DecoratedOptionWidget
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
OO.ui.MenuOptionWidget = function OoUiMenuOptionWidget( config ) {
	// Configuration initialization
	config = $.extend( { icon: 'check' }, config );

	// Parent constructor
	OO.ui.MenuOptionWidget.super.call( this, config );

	// Initialization
	this.$element
		.attr( 'role', 'menuitem' )
		.addClass( 'oo-ui-menuOptionWidget' );
};

/* Setup */

OO.inheritClass( OO.ui.MenuOptionWidget, OO.ui.DecoratedOptionWidget );

/* Static Properties */

OO.ui.MenuOptionWidget.static.scrollIntoViewOnSelect = true;

/**
 * Section to group one or more items in a OO.ui.MenuSelectWidget.
 *
 * @class
 * @extends OO.ui.DecoratedOptionWidget
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
OO.ui.MenuSectionOptionWidget = function OoUiMenuSectionOptionWidget( config ) {
	// Parent constructor
	OO.ui.MenuSectionOptionWidget.super.call( this, config );

	// Initialization
	this.$element.addClass( 'oo-ui-menuSectionOptionWidget' );
};

/* Setup */

OO.inheritClass( OO.ui.MenuSectionOptionWidget, OO.ui.DecoratedOptionWidget );

/* Static Properties */

OO.ui.MenuSectionOptionWidget.static.selectable = false;

OO.ui.MenuSectionOptionWidget.static.highlightable = false;

/**
 * Items for an OO.ui.OutlineSelectWidget.
 *
 * @class
 * @extends OO.ui.DecoratedOptionWidget
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {number} [level] Indentation level
 * @cfg {boolean} [movable] Allow modification from outline controls
 */
OO.ui.OutlineOptionWidget = function OoUiOutlineOptionWidget( config ) {
	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.OutlineOptionWidget.super.call( this, config );

	// Properties
	this.level = 0;
	this.movable = !!config.movable;
	this.removable = !!config.removable;

	// Initialization
	this.$element.addClass( 'oo-ui-outlineOptionWidget' );
	this.setLevel( config.level );
};

/* Setup */

OO.inheritClass( OO.ui.OutlineOptionWidget, OO.ui.DecoratedOptionWidget );

/* Static Properties */

OO.ui.OutlineOptionWidget.static.highlightable = false;

OO.ui.OutlineOptionWidget.static.scrollIntoViewOnSelect = true;

OO.ui.OutlineOptionWidget.static.levelClass = 'oo-ui-outlineOptionWidget-level-';

OO.ui.OutlineOptionWidget.static.levels = 3;

/* Methods */

/**
 * Check if item is movable.
 *
 * Movability is used by outline controls.
 *
 * @return {boolean} Item is movable
 */
OO.ui.OutlineOptionWidget.prototype.isMovable = function () {
	return this.movable;
};

/**
 * Check if item is removable.
 *
 * Removability is used by outline controls.
 *
 * @return {boolean} Item is removable
 */
OO.ui.OutlineOptionWidget.prototype.isRemovable = function () {
	return this.removable;
};

/**
 * Get indentation level.
 *
 * @return {number} Indentation level
 */
OO.ui.OutlineOptionWidget.prototype.getLevel = function () {
	return this.level;
};

/**
 * Set movability.
 *
 * Movability is used by outline controls.
 *
 * @param {boolean} movable Item is movable
 * @chainable
 */
OO.ui.OutlineOptionWidget.prototype.setMovable = function ( movable ) {
	this.movable = !!movable;
	this.updateThemeClasses();
	return this;
};

/**
 * Set removability.
 *
 * Removability is used by outline controls.
 *
 * @param {boolean} movable Item is removable
 * @chainable
 */
OO.ui.OutlineOptionWidget.prototype.setRemovable = function ( removable ) {
	this.removable = !!removable;
	this.updateThemeClasses();
	return this;
};

/**
 * Set indentation level.
 *
 * @param {number} [level=0] Indentation level, in the range of [0,#maxLevel]
 * @chainable
 */
OO.ui.OutlineOptionWidget.prototype.setLevel = function ( level ) {
	var levels = this.constructor.static.levels,
		levelClass = this.constructor.static.levelClass,
		i = levels;

	this.level = level ? Math.max( 0, Math.min( levels - 1, level ) ) : 0;
	while ( i-- ) {
		if ( this.level === i ) {
			this.$element.addClass( levelClass + i );
		} else {
			this.$element.removeClass( levelClass + i );
		}
	}
	this.updateThemeClasses();

	return this;
};

/**
 * PopupWidget is a container for content. The popup is overlaid and positioned absolutely.
 * By default, each popup has an anchor that points toward its origin.
 * Please see the [OOjs UI documentation on Mediawiki] [1] for more information and examples.
 *
 *     @example
 *     // A popup widget.
 *     var popup=new OO.ui.PopupWidget({
 *         $content: $( '<p>Hi there!</p>' ),
 *         padded: true,
 *         width: 300
 *     } );
 *
 *     $('body').append(popup.$element);
 *     // To display the popup, toggle the visibility to 'true'.
 *     popup.toggle(true);
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Popups
 *
 * @class
 * @extends OO.ui.Widget
 * @mixins OO.ui.LabelElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {number} [width=320] Width of popup in pixels
 * @cfg {number} [height] Height of popup in pixels. Omit to use the automatic height.
 * @cfg {boolean} [anchor=true] Show anchor pointing to origin of popup
 * @cfg {string} [align='center'] Alignment of the popup: `center`, `left`, or `right`.
 *  If the popup is right-aligned, the right edge of the popup is aligned to the anchor.
 *  For left-aligned popups, the left edge is aligned to the anchor.
 * @cfg {jQuery} [$container] Constrain the popup to the boundaries of the specified container.
 *  See the [OOjs UI docs on MediaWiki][3] for an example.
 *  [3]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Popups#containerExample
 * @cfg {number} [containerPadding=10] Padding between the popup and its container, specified as a number of pixels.
 * @cfg {jQuery} [$content] Content to append to the popup's body
 * @cfg {boolean} [autoClose=false] Automatically close the popup when it loses focus.
 * @cfg {jQuery} [$autoCloseIgnore] Elements that will not close the popup when clicked.
 *  This config option is only relevant if #autoClose is set to `true`. See the [OOjs UI docs on MediaWiki][2]
 *  for an example.
 *  [2]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Popups#autocloseExample
 * @cfg {boolean} [head] Show a popup header that contains a #label (if specified) and close
 *  button.
 * @cfg {boolean} [padded] Add padding to the popup's body
 */
OO.ui.PopupWidget = function OoUiPopupWidget( config ) {
	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.PopupWidget.super.call( this, config );

	// Properties (must be set before ClippableElement constructor call)
	this.$body = $( '<div>' );

	// Mixin constructors
	OO.ui.LabelElement.call( this, config );
	OO.ui.ClippableElement.call( this, $.extend( {}, config, { $clippable: this.$body } ) );

	// Properties
	this.$popup = $( '<div>' );
	this.$head = $( '<div>' );
	this.$anchor = $( '<div>' );
	// If undefined, will be computed lazily in updateDimensions()
	this.$container = config.$container;
	this.containerPadding = config.containerPadding !== undefined ? config.containerPadding : 10;
	this.autoClose = !!config.autoClose;
	this.$autoCloseIgnore = config.$autoCloseIgnore;
	this.transitionTimeout = null;
	this.anchor = null;
	this.width = config.width !== undefined ? config.width : 320;
	this.height = config.height !== undefined ? config.height : null;
	this.align = config.align || 'center';
	this.closeButton = new OO.ui.ButtonWidget( { framed: false, icon: 'close' } );
	this.onMouseDownHandler = this.onMouseDown.bind( this );
	this.onDocumentKeyDownHandler = this.onDocumentKeyDown.bind( this );

	// Events
	this.closeButton.connect( this, { click: 'onCloseButtonClick' } );

	// Initialization
	this.toggleAnchor( config.anchor === undefined || config.anchor );
	this.$body.addClass( 'oo-ui-popupWidget-body' );
	this.$anchor.addClass( 'oo-ui-popupWidget-anchor' );
	this.$head
		.addClass( 'oo-ui-popupWidget-head' )
		.append( this.$label, this.closeButton.$element );
	if ( !config.head ) {
		this.$head.addClass( 'oo-ui-element-hidden' );
	}
	this.$popup
		.addClass( 'oo-ui-popupWidget-popup' )
		.append( this.$head, this.$body );
	this.$element
		.addClass( 'oo-ui-popupWidget' )
		.append( this.$popup, this.$anchor );
	// Move content, which was added to #$element by OO.ui.Widget, to the body
	if ( config.$content instanceof jQuery ) {
		this.$body.append( config.$content );
	}
	if ( config.padded ) {
		this.$body.addClass( 'oo-ui-popupWidget-body-padded' );
	}

	// Initially hidden - using #toggle may cause errors if subclasses override toggle with methods
	// that reference properties not initialized at that time of parent class construction
	// TODO: Find a better way to handle post-constructor setup
	this.visible = false;
	this.$element.addClass( 'oo-ui-element-hidden' );
};

/* Setup */

OO.inheritClass( OO.ui.PopupWidget, OO.ui.Widget );
OO.mixinClass( OO.ui.PopupWidget, OO.ui.LabelElement );
OO.mixinClass( OO.ui.PopupWidget, OO.ui.ClippableElement );

/* Methods */

/**
 * Handles mouse down events.
 *
 * @private
 * @param {MouseEvent} e Mouse down event
 */
OO.ui.PopupWidget.prototype.onMouseDown = function ( e ) {
	if (
		this.isVisible() &&
		!$.contains( this.$element[ 0 ], e.target ) &&
		( !this.$autoCloseIgnore || !this.$autoCloseIgnore.has( e.target ).length )
	) {
		this.toggle( false );
	}
};

/**
 * Bind mouse down listener.
 *
 * @private
 */
OO.ui.PopupWidget.prototype.bindMouseDownListener = function () {
	// Capture clicks outside popup
	this.getElementWindow().addEventListener( 'mousedown', this.onMouseDownHandler, true );
};

/**
 * Handles close button click events.
 *
 * @private
 */
OO.ui.PopupWidget.prototype.onCloseButtonClick = function () {
	if ( this.isVisible() ) {
		this.toggle( false );
	}
};

/**
 * Unbind mouse down listener.
 *
 * @private
 */
OO.ui.PopupWidget.prototype.unbindMouseDownListener = function () {
	this.getElementWindow().removeEventListener( 'mousedown', this.onMouseDownHandler, true );
};

/**
 * Handles key down events.
 *
 * @private
 * @param {KeyboardEvent} e Key down event
 */
OO.ui.PopupWidget.prototype.onDocumentKeyDown = function ( e ) {
	if (
		e.which === OO.ui.Keys.ESCAPE &&
		this.isVisible()
	) {
		this.toggle( false );
		e.preventDefault();
		e.stopPropagation();
	}
};

/**
 * Bind key down listener.
 *
 * @private
 */
OO.ui.PopupWidget.prototype.bindKeyDownListener = function () {
	this.getElementWindow().addEventListener( 'keydown', this.onDocumentKeyDownHandler, true );
};

/**
 * Unbind key down listener.
 *
 * @private
 */
OO.ui.PopupWidget.prototype.unbindKeyDownListener = function () {
	this.getElementWindow().removeEventListener( 'keydown', this.onDocumentKeyDownHandler, true );
};

/**
 * Show, hide, or toggle the visibility of the anchor.
 *
 * @param {boolean} [show] Show anchor, omit to toggle
 */
OO.ui.PopupWidget.prototype.toggleAnchor = function ( show ) {
	show = show === undefined ? !this.anchored : !!show;

	if ( this.anchored !== show ) {
		if ( show ) {
			this.$element.addClass( 'oo-ui-popupWidget-anchored' );
		} else {
			this.$element.removeClass( 'oo-ui-popupWidget-anchored' );
		}
		this.anchored = show;
	}
};

/**
 * Check if the anchor is visible.
 *
 * @return {boolean} Anchor is visible
 */
OO.ui.PopupWidget.prototype.hasAnchor = function () {
	return this.anchor;
};

/**
 * @inheritdoc
 */
OO.ui.PopupWidget.prototype.toggle = function ( show ) {
	show = show === undefined ? !this.isVisible() : !!show;

	var change = show !== this.isVisible();

	// Parent method
	OO.ui.PopupWidget.super.prototype.toggle.call( this, show );

	if ( change ) {
		if ( show ) {
			if ( this.autoClose ) {
				this.bindMouseDownListener();
				this.bindKeyDownListener();
			}
			this.updateDimensions();
			this.toggleClipping( true );
		} else {
			this.toggleClipping( false );
			if ( this.autoClose ) {
				this.unbindMouseDownListener();
				this.unbindKeyDownListener();
			}
		}
	}

	return this;
};

/**
 * Set the size of the popup.
 *
 * Changing the size may also change the popup's position depending on the alignment.
 *
 * @param {number} width Width in pixels
 * @param {number} height Height in pixels
 * @param {boolean} [transition=false] Use a smooth transition
 * @chainable
 */
OO.ui.PopupWidget.prototype.setSize = function ( width, height, transition ) {
	this.width = width;
	this.height = height !== undefined ? height : null;
	if ( this.isVisible() ) {
		this.updateDimensions( transition );
	}
};

/**
 * Update the size and position.
 *
 * Only use this to keep the popup properly anchored. Use #setSize to change the size, and this will
 * be called automatically.
 *
 * @param {boolean} [transition=false] Use a smooth transition
 * @chainable
 */
OO.ui.PopupWidget.prototype.updateDimensions = function ( transition ) {
	var popupOffset, originOffset, containerLeft, containerWidth, containerRight,
		popupLeft, popupRight, overlapLeft, overlapRight, anchorWidth,
		widget = this;

	if ( !this.$container ) {
		// Lazy-initialize $container if not specified in constructor
		this.$container = $( this.getClosestScrollableElementContainer() );
	}

	// Set height and width before measuring things, since it might cause our measurements
	// to change (e.g. due to scrollbars appearing or disappearing)
	this.$popup.css( {
		width: this.width,
		height: this.height !== null ? this.height : 'auto'
	} );

	// Compute initial popupOffset based on alignment
	popupOffset = this.width * ( { left: 0, center: -0.5, right: -1 } )[ this.align ];

	// Figure out if this will cause the popup to go beyond the edge of the container
	originOffset = this.$element.offset().left;
	containerLeft = this.$container.offset().left;
	containerWidth = this.$container.innerWidth();
	containerRight = containerLeft + containerWidth;
	popupLeft = popupOffset - this.containerPadding;
	popupRight = popupOffset + this.containerPadding + this.width + this.containerPadding;
	overlapLeft = ( originOffset + popupLeft ) - containerLeft;
	overlapRight = containerRight - ( originOffset + popupRight );

	// Adjust offset to make the popup not go beyond the edge, if needed
	if ( overlapRight < 0 ) {
		popupOffset += overlapRight;
	} else if ( overlapLeft < 0 ) {
		popupOffset -= overlapLeft;
	}

	// Adjust offset to avoid anchor being rendered too close to the edge
	// $anchor.width() doesn't work with the pure CSS anchor (returns 0)
	// TODO: Find a measurement that works for CSS anchors and image anchors
	anchorWidth = this.$anchor[ 0 ].scrollWidth * 2;
	if ( popupOffset + this.width < anchorWidth ) {
		popupOffset = anchorWidth - this.width;
	} else if ( -popupOffset < anchorWidth ) {
		popupOffset = -anchorWidth;
	}

	// Prevent transition from being interrupted
	clearTimeout( this.transitionTimeout );
	if ( transition ) {
		// Enable transition
		this.$element.addClass( 'oo-ui-popupWidget-transitioning' );
	}

	// Position body relative to anchor
	this.$popup.css( 'margin-left', popupOffset );

	if ( transition ) {
		// Prevent transitioning after transition is complete
		this.transitionTimeout = setTimeout( function () {
			widget.$element.removeClass( 'oo-ui-popupWidget-transitioning' );
		}, 200 );
	} else {
		// Prevent transitioning immediately
		this.$element.removeClass( 'oo-ui-popupWidget-transitioning' );
	}

	// Reevaluate clipping state since we've relocated and resized the popup
	this.clip();

	return this;
};

/**
 * Progress bars visually display the status of an operation, such as a download,
 * and can be either determinate or indeterminate:
 *
 * - **determinate** process bars show the percent of an operation that is complete.
 *
 * - **indeterminate** process bars use a visual display of motion to indicate that an operation
 *   is taking place. Because the extent of an indeterminate operation is unknown, the bar does
 *   not use percentages.
 *
 * The value of the `progress` configuration determines whether the bar is determinate or indeterminate.
 *
 *     @example
 *     // Examples of determinate and indeterminate progress bars.
 *     var progressBar1=new OO.ui.ProgressBarWidget( {
 *         progress: 33
 *     } );
 *
 *     var progressBar2=new OO.ui.ProgressBarWidget( {
 *         progress: false
 *     } );
 *     // Create a FieldsetLayout to layout progress bars
 *     var fieldset = new OO.ui.FieldsetLayout;
 *     fieldset.addItems( [
 *        new OO.ui.FieldLayout( progressBar1, {label : 'Determinate', align : 'top'}),
 *        new OO.ui.FieldLayout( progressBar2, {label : 'Indeterminate', align : 'top'})
 *     ] );
 *     $( 'body' ).append( fieldset.$element );
 *
 * @class
 * @extends OO.ui.Widget
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {number|boolean} [progress=false] The type of progress bar (determinate or indeterminate).
 *  To create a determinate progress bar, specify a number that reflects the initial percent complete.
 *  By default, the progress bar is indeterminate.
 */
OO.ui.ProgressBarWidget = function OoUiProgressBarWidget( config ) {
	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.ProgressBarWidget.super.call( this, config );

	// Properties
	this.$bar = $( '<div>' );
	this.progress = null;

	// Initialization
	this.setProgress( config.progress !== undefined ? config.progress : false );
	this.$bar.addClass( 'oo-ui-progressBarWidget-bar' );
	this.$element
		.attr( {
			role: 'progressbar',
			'aria-valuemin': 0,
			'aria-valuemax': 100
		} )
		.addClass( 'oo-ui-progressBarWidget' )
		.append( this.$bar );
};

/* Setup */

OO.inheritClass( OO.ui.ProgressBarWidget, OO.ui.Widget );

/* Static Properties */

OO.ui.ProgressBarWidget.static.tagName = 'div';

/* Methods */

/**
 * Get the percent of the progress that has been completed. Indeterminate progresses will return `false`.
 *
 * @return {number|boolean} Progress percent
 */
OO.ui.ProgressBarWidget.prototype.getProgress = function () {
	return this.progress;
};

/**
 * Set the percent of the process completed or `false` for an indeterminate process.
 *
 * @param {number|boolean} progress Progress percent or `false` for indeterminate
 */
OO.ui.ProgressBarWidget.prototype.setProgress = function ( progress ) {
	this.progress = progress;

	if ( progress !== false ) {
		this.$bar.css( 'width', this.progress + '%' );
		this.$element.attr( 'aria-valuenow', this.progress );
	} else {
		this.$bar.css( 'width', '' );
		this.$element.removeAttr( 'aria-valuenow' );
	}
	this.$element.toggleClass( 'oo-ui-progressBarWidget-indeterminate', !progress );
};

/**
 * Search widget.
 *
 * Search widgets combine a query input, placed above, and a results selection widget, placed below.
 * Results are cleared and populated each time the query is changed.
 *
 * @class
 * @extends OO.ui.Widget
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {string|jQuery} [placeholder] Placeholder text for query input
 * @cfg {string} [value] Initial query value
 */
OO.ui.SearchWidget = function OoUiSearchWidget( config ) {
	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.SearchWidget.super.call( this, config );

	// Properties
	this.query = new OO.ui.TextInputWidget( {
		icon: 'search',
		placeholder: config.placeholder,
		value: config.value
	} );
	this.results = new OO.ui.SelectWidget();
	this.$query = $( '<div>' );
	this.$results = $( '<div>' );

	// Events
	this.query.connect( this, {
		change: 'onQueryChange',
		enter: 'onQueryEnter'
	} );
	this.results.connect( this, {
		highlight: 'onResultsHighlight',
		select: 'onResultsSelect'
	} );
	this.query.$input.on( 'keydown', this.onQueryKeydown.bind( this ) );

	// Initialization
	this.$query
		.addClass( 'oo-ui-searchWidget-query' )
		.append( this.query.$element );
	this.$results
		.addClass( 'oo-ui-searchWidget-results' )
		.append( this.results.$element );
	this.$element
		.addClass( 'oo-ui-searchWidget' )
		.append( this.$results, this.$query );
};

/* Setup */

OO.inheritClass( OO.ui.SearchWidget, OO.ui.Widget );

/* Events */

/**
 * @event highlight
 * @param {Object|null} item Item data or null if no item is highlighted
 */

/**
 * @event select
 * @param {Object|null} item Item data or null if no item is selected
 */

/* Methods */

/**
 * Handle query key down events.
 *
 * @param {jQuery.Event} e Key down event
 */
OO.ui.SearchWidget.prototype.onQueryKeydown = function ( e ) {
	var highlightedItem, nextItem,
		dir = e.which === OO.ui.Keys.DOWN ? 1 : ( e.which === OO.ui.Keys.UP ? -1 : 0 );

	if ( dir ) {
		highlightedItem = this.results.getHighlightedItem();
		if ( !highlightedItem ) {
			highlightedItem = this.results.getSelectedItem();
		}
		nextItem = this.results.getRelativeSelectableItem( highlightedItem, dir );
		this.results.highlightItem( nextItem );
		nextItem.scrollElementIntoView();
	}
};

/**
 * Handle select widget select events.
 *
 * Clears existing results. Subclasses should repopulate items according to new query.
 *
 * @param {string} value New value
 */
OO.ui.SearchWidget.prototype.onQueryChange = function () {
	// Reset
	this.results.clearItems();
};

/**
 * Handle select widget enter key events.
 *
 * Selects highlighted item.
 *
 * @param {string} value New value
 */
OO.ui.SearchWidget.prototype.onQueryEnter = function () {
	// Reset
	this.results.selectItem( this.results.getHighlightedItem() );
};

/**
 * Handle select widget highlight events.
 *
 * @param {OO.ui.OptionWidget} item Highlighted item
 * @fires highlight
 */
OO.ui.SearchWidget.prototype.onResultsHighlight = function ( item ) {
	this.emit( 'highlight', item ? item.getData() : null );
};

/**
 * Handle select widget select events.
 *
 * @param {OO.ui.OptionWidget} item Selected item
 * @fires select
 */
OO.ui.SearchWidget.prototype.onResultsSelect = function ( item ) {
	this.emit( 'select', item ? item.getData() : null );
};

/**
 * Get the query input.
 *
 * @return {OO.ui.TextInputWidget} Query input
 */
OO.ui.SearchWidget.prototype.getQuery = function () {
	return this.query;
};

/**
 * Get the results list.
 *
 * @return {OO.ui.SelectWidget} Select list
 */
OO.ui.SearchWidget.prototype.getResults = function () {
	return this.results;
};

/**
 * A SelectWidget is of a generic selection of options. The OOjs UI library contains several types of
 * select widgets, including {@link OO.ui.ButtonSelectWidget button selects},
 * {@link OO.ui.RadioSelectWidget radio selects}, and {@link OO.ui.MenuSelectWidget
 * menu selects}.
 *
 * This class should be used together with OO.ui.OptionWidget or OO.ui.DecoratedOptionWidget. For more
 * information, please see the [OOjs UI documentation on MediaWiki][1].
 *
 *     @example
 *     // Example of a select widget with three options
 *     var select=new OO.ui.SelectWidget( {
 *         items: [
 *             new OO.ui.OptionWidget( {
 *                 data: 'a',
 *                 label: 'Option One',
 *             } ),
 *             new OO.ui.OptionWidget( {
 *                 data: 'b',
 *                 label: 'Option Two',
 *             } ),
 *             new OO.ui.OptionWidget( {
 *                 data: 'c',
 *                 label: 'Option Three',
 *             } ),
 *         ]
 *     } );
 *     $('body').append(select.$element);
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Selects_and_Options
 *
 * @class
 * @extends OO.ui.Widget
 * @mixins OO.ui.GroupElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {OO.ui.OptionWidget[]} [items] An array of options to add to the select.
 *  Options are created with {@link OO.ui.OptionWidget OptionWidget} classes. See
 *  the [OOjs UI documentation on MediaWiki] [2] for examples.
 *  [2]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Selects_and_Options
 */
OO.ui.SelectWidget = function OoUiSelectWidget( config ) {
	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.SelectWidget.super.call( this, config );

	// Mixin constructors
	OO.ui.GroupWidget.call( this, $.extend( {}, config, { $group: this.$element } ) );

	// Properties
	this.pressed = false;
	this.selecting = null;
	this.onMouseUpHandler = this.onMouseUp.bind( this );
	this.onMouseMoveHandler = this.onMouseMove.bind( this );
	this.onKeyDownHandler = this.onKeyDown.bind( this );

	// Events
	this.$element.on( {
		mousedown: this.onMouseDown.bind( this ),
		mouseover: this.onMouseOver.bind( this ),
		mouseleave: this.onMouseLeave.bind( this )
	} );

	// Initialization
	this.$element
		.addClass( 'oo-ui-selectWidget oo-ui-selectWidget-depressed' )
		.attr( 'role', 'listbox' );
	if ( Array.isArray( config.items ) ) {
		this.addItems( config.items );
	}
};

/* Setup */

OO.inheritClass( OO.ui.SelectWidget, OO.ui.Widget );

// Need to mixin base class as well
OO.mixinClass( OO.ui.SelectWidget, OO.ui.GroupElement );
OO.mixinClass( OO.ui.SelectWidget, OO.ui.GroupWidget );

/* Events */

/**
 * @event highlight
 *
 * A `highlight` event is emitted when the highlight is changed with the #highlightItem method.
 *
 * @param {OO.ui.OptionWidget|null} item Highlighted item
 */

/**
 * @event press
 *
 * A `press` event is emitted when the #pressItem method is used to programmatically modify the
 * pressed state of an option.
 *
 * @param {OO.ui.OptionWidget|null} item Pressed item
 */

/**
 * @event select
 *
 * A `select` event is emitted when the selection is modified programmatically with the #selectItem method.
 *
 * @param {OO.ui.OptionWidget|null} item Selected item
 */

/**
 * @event choose
 * A `choose` event is emitted when an item is chosen with the #chooseItem method.
 * @param {OO.ui.OptionWidget|null} item Chosen item
 */

/**
 * @event add
 *
 * An `add` event is emitted when options are added to the select with the #addItems method.
 *
 * @param {OO.ui.OptionWidget[]} items Added items
 * @param {number} index Index of insertion point
 */

/**
 * @event remove
 *
 * A `remove` event is emitted when options are removed from the select with the #clearItems
 * or #removeItems methods.
 *
 * @param {OO.ui.OptionWidget[]} items Removed items
 */

/* Methods */

/**
 * Handle mouse down events.
 *
 * @private
 * @param {jQuery.Event} e Mouse down event
 */
OO.ui.SelectWidget.prototype.onMouseDown = function ( e ) {
	var item;

	if ( !this.isDisabled() && e.which === 1 ) {
		this.togglePressed( true );
		item = this.getTargetItem( e );
		if ( item && item.isSelectable() ) {
			this.pressItem( item );
			this.selecting = item;
			this.getElementDocument().addEventListener(
				'mouseup',
				this.onMouseUpHandler,
				true
			);
			this.getElementDocument().addEventListener(
				'mousemove',
				this.onMouseMoveHandler,
				true
			);
		}
	}
	return false;
};

/**
 * Handle mouse up events.
 *
 * @private
 * @param {jQuery.Event} e Mouse up event
 */
OO.ui.SelectWidget.prototype.onMouseUp = function ( e ) {
	var item;

	this.togglePressed( false );
	if ( !this.selecting ) {
		item = this.getTargetItem( e );
		if ( item && item.isSelectable() ) {
			this.selecting = item;
		}
	}
	if ( !this.isDisabled() && e.which === 1 && this.selecting ) {
		this.pressItem( null );
		this.chooseItem( this.selecting );
		this.selecting = null;
	}

	this.getElementDocument().removeEventListener(
		'mouseup',
		this.onMouseUpHandler,
		true
	);
	this.getElementDocument().removeEventListener(
		'mousemove',
		this.onMouseMoveHandler,
		true
	);

	return false;
};

/**
 * Handle mouse move events.
 *
 * @private
 * @param {jQuery.Event} e Mouse move event
 */
OO.ui.SelectWidget.prototype.onMouseMove = function ( e ) {
	var item;

	if ( !this.isDisabled() && this.pressed ) {
		item = this.getTargetItem( e );
		if ( item && item !== this.selecting && item.isSelectable() ) {
			this.pressItem( item );
			this.selecting = item;
		}
	}
	return false;
};

/**
 * Handle mouse over events.
 *
 * @private
 * @param {jQuery.Event} e Mouse over event
 */
OO.ui.SelectWidget.prototype.onMouseOver = function ( e ) {
	var item;

	if ( !this.isDisabled() ) {
		item = this.getTargetItem( e );
		this.highlightItem( item && item.isHighlightable() ? item : null );
	}
	return false;
};

/**
 * Handle mouse leave events.
 *
 * @private
 * @param {jQuery.Event} e Mouse over event
 */
OO.ui.SelectWidget.prototype.onMouseLeave = function () {
	if ( !this.isDisabled() ) {
		this.highlightItem( null );
	}
	return false;
};

/**
 * Handle key down events.
 *
 * @protected
 * @param {jQuery.Event} e Key down event
 */
OO.ui.SelectWidget.prototype.onKeyDown = function ( e ) {
	var nextItem,
		handled = false,
		currentItem = this.getHighlightedItem() || this.getSelectedItem();

	if ( !this.isDisabled() && this.isVisible() ) {
		switch ( e.keyCode ) {
			case OO.ui.Keys.ENTER:
				if ( currentItem && currentItem.constructor.static.highlightable ) {
					// Was only highlighted, now let's select it. No-op if already selected.
					this.chooseItem( currentItem );
					handled = true;
				}
				break;
			case OO.ui.Keys.UP:
			case OO.ui.Keys.LEFT:
				nextItem = this.getRelativeSelectableItem( currentItem, -1 );
				handled = true;
				break;
			case OO.ui.Keys.DOWN:
			case OO.ui.Keys.RIGHT:
				nextItem = this.getRelativeSelectableItem( currentItem, 1 );
				handled = true;
				break;
			case OO.ui.Keys.ESCAPE:
			case OO.ui.Keys.TAB:
				if ( currentItem && currentItem.constructor.static.highlightable ) {
					currentItem.setHighlighted( false );
				}
				this.unbindKeyDownListener();
				// Don't prevent tabbing away / defocusing
				handled = false;
				break;
		}

		if ( nextItem ) {
			if ( nextItem.constructor.static.highlightable ) {
				this.highlightItem( nextItem );
			} else {
				this.chooseItem( nextItem );
			}
			nextItem.scrollElementIntoView();
		}

		if ( handled ) {
			// Can't just return false, because e is not always a jQuery event
			e.preventDefault();
			e.stopPropagation();
		}
	}
};

/**
 * Bind key down listener.
 *
 * @protected
 */
OO.ui.SelectWidget.prototype.bindKeyDownListener = function () {
	this.getElementWindow().addEventListener( 'keydown', this.onKeyDownHandler, true );
};

/**
 * Unbind key down listener.
 *
 * @protected
 */
OO.ui.SelectWidget.prototype.unbindKeyDownListener = function () {
	this.getElementWindow().removeEventListener( 'keydown', this.onKeyDownHandler, true );
};

/**
 * Get the closest item to a jQuery.Event.
 *
 * @private
 * @param {jQuery.Event} e
 * @return {OO.ui.OptionWidget|null} Outline item widget, `null` if none was found
 */
OO.ui.SelectWidget.prototype.getTargetItem = function ( e ) {
	var $item = $( e.target ).closest( '.oo-ui-optionWidget' );
	if ( $item.length ) {
		return $item.data( 'oo-ui-optionWidget' );
	}
	return null;
};

/**
 * Get selected item.
 *
 * @return {OO.ui.OptionWidget|null} Selected item, `null` if no item is selected
 */
OO.ui.SelectWidget.prototype.getSelectedItem = function () {
	var i, len;

	for ( i = 0, len = this.items.length; i < len; i++ ) {
		if ( this.items[ i ].isSelected() ) {
			return this.items[ i ];
		}
	}
	return null;
};

/**
 * Get highlighted item.
 *
 * @return {OO.ui.OptionWidget|null} Highlighted item, `null` if no item is highlighted
 */
OO.ui.SelectWidget.prototype.getHighlightedItem = function () {
	var i, len;

	for ( i = 0, len = this.items.length; i < len; i++ ) {
		if ( this.items[ i ].isHighlighted() ) {
			return this.items[ i ];
		}
	}
	return null;
};

/**
 * Toggle pressed state.
 *
 * Press is a state that occurs when a user mouses down on an item, but
 * has not yet let go of the mouse. The item may appear selected, but it will not be selected
 * until the user releases the mouse.
 *
 * @param {boolean} pressed An option is being pressed
 */
OO.ui.SelectWidget.prototype.togglePressed = function ( pressed ) {
	if ( pressed === undefined ) {
		pressed = !this.pressed;
	}
	if ( pressed !== this.pressed ) {
		this.$element
			.toggleClass( 'oo-ui-selectWidget-pressed', pressed )
			.toggleClass( 'oo-ui-selectWidget-depressed', !pressed );
		this.pressed = pressed;
	}
};

/**
 * Highlight an option. If the `item` param is omitted, no options will be highlighted
 * and any existing highlight will be removed. The highlight is mutually exclusive.
 *
 * @param {OO.ui.OptionWidget} [item] Item to highlight, omit for no highlight
 * @fires highlight
 * @chainable
 */
OO.ui.SelectWidget.prototype.highlightItem = function ( item ) {
	var i, len, highlighted,
		changed = false;

	for ( i = 0, len = this.items.length; i < len; i++ ) {
		highlighted = this.items[ i ] === item;
		if ( this.items[ i ].isHighlighted() !== highlighted ) {
			this.items[ i ].setHighlighted( highlighted );
			changed = true;
		}
	}
	if ( changed ) {
		this.emit( 'highlight', item );
	}

	return this;
};

/**
 * Programmatically select an option by its reference. If the `item` parameter is omitted,
 * all options will be deselected.
 *
 * @param {OO.ui.OptionWidget} [item] Item to select, omit to deselect all
 * @fires select
 * @chainable
 */
OO.ui.SelectWidget.prototype.selectItem = function ( item ) {
	var i, len, selected,
		changed = false;

	for ( i = 0, len = this.items.length; i < len; i++ ) {
		selected = this.items[ i ] === item;
		if ( this.items[ i ].isSelected() !== selected ) {
			this.items[ i ].setSelected( selected );
			changed = true;
		}
	}
	if ( changed ) {
		this.emit( 'select', item );
	}

	return this;
};

/**
 * Press an item.
 *
 * Press is a state that occurs when a user mouses down on an item, but has not
 * yet let go of the mouse. The item may appear selected, but it will not be selected until the user
 * releases the mouse.
 *
 * @param {OO.ui.OptionWidget} [item] Item to press, omit to depress all
 * @fires press
 * @chainable
 */
OO.ui.SelectWidget.prototype.pressItem = function ( item ) {
	var i, len, pressed,
		changed = false;

	for ( i = 0, len = this.items.length; i < len; i++ ) {
		pressed = this.items[ i ] === item;
		if ( this.items[ i ].isPressed() !== pressed ) {
			this.items[ i ].setPressed( pressed );
			changed = true;
		}
	}
	if ( changed ) {
		this.emit( 'press', item );
	}

	return this;
};

/**
 * Choose an item.
 *
 * Note that ‘choose’ should never be modified programmatically. A user can choose
 * an option with the keyboard or mouse and it becomes selected. To select an item programmatically,
 * use the #selectItem method.
 *
 * This method is identical to #selectItem, but may vary in subclasses that take additional action
 * when users choose an item with the keyboard or mouse.
 *
 * @param {OO.ui.OptionWidget} item Item to choose
 * @fires choose
 * @chainable
 */
OO.ui.SelectWidget.prototype.chooseItem = function ( item ) {
	this.selectItem( item );
	this.emit( 'choose', item );

	return this;
};

/**
 * Get an option by its position relative to the specified item (or to the start of the option array,
 * if item is `null`). The direction in which to search through the option array is specified with a
 * number: -1 for reverse (the default) or 1 for forward. The method will return an option, or
 * `null` if there are no options in the array.
 *
 * @param {OO.ui.OptionWidget|null} item Item to describe the start position, or `null` to start at the beginning of the array.
 * @param {number} direction Direction to move in: -1 to move backward, 1 to move forward
 * @return {OO.ui.OptionWidget|null} Item at position, `null` if there are no items in the select
 */
OO.ui.SelectWidget.prototype.getRelativeSelectableItem = function ( item, direction ) {
	var currentIndex, nextIndex, i,
		increase = direction > 0 ? 1 : -1,
		len = this.items.length;

	if ( item instanceof OO.ui.OptionWidget ) {
		currentIndex = $.inArray( item, this.items );
		nextIndex = ( currentIndex + increase + len ) % len;
	} else {
		// If no item is selected and moving forward, start at the beginning.
		// If moving backward, start at the end.
		nextIndex = direction > 0 ? 0 : len - 1;
	}

	for ( i = 0; i < len; i++ ) {
		item = this.items[ nextIndex ];
		if ( item instanceof OO.ui.OptionWidget && item.isSelectable() ) {
			return item;
		}
		nextIndex = ( nextIndex + increase + len ) % len;
	}
	return null;
};

/**
 * Get the next selectable item or `null` if there are no selectable items.
 * Disabled options and menu-section markers and breaks are not selectable.
 *
 * @return {OO.ui.OptionWidget|null} Item, `null` if there aren't any selectable items
 */
OO.ui.SelectWidget.prototype.getFirstSelectableItem = function () {
	var i, len, item;

	for ( i = 0, len = this.items.length; i < len; i++ ) {
		item = this.items[ i ];
		if ( item instanceof OO.ui.OptionWidget && item.isSelectable() ) {
			return item;
		}
	}

	return null;
};

/**
 * Add an array of options to the select. Optionally, an index number can be used to
 * specify an insertion point.
 *
 * @param {OO.ui.OptionWidget[]} items Items to add
 * @param {number} [index] Index to insert items after
 * @fires add
 * @chainable
 */
OO.ui.SelectWidget.prototype.addItems = function ( items, index ) {
	// Mixin method
	OO.ui.GroupWidget.prototype.addItems.call( this, items, index );

	// Always provide an index, even if it was omitted
	this.emit( 'add', items, index === undefined ? this.items.length - items.length - 1 : index );

	return this;
};

/**
 * Remove the specified array of options from the select. Options will be detached
 * from the DOM, not removed, so they can be reused later. To remove all options from
 * the select, you may wish to use the #clearItems method instead.
 *
 * @param {OO.ui.OptionWidget[]} items Items to remove
 * @fires remove
 * @chainable
 */
OO.ui.SelectWidget.prototype.removeItems = function ( items ) {
	var i, len, item;

	// Deselect items being removed
	for ( i = 0, len = items.length; i < len; i++ ) {
		item = items[ i ];
		if ( item.isSelected() ) {
			this.selectItem( null );
		}
	}

	// Mixin method
	OO.ui.GroupWidget.prototype.removeItems.call( this, items );

	this.emit( 'remove', items );

	return this;
};

/**
 * Clear all options from the select. Options will be detached from the DOM, not removed,
 * so that they can be reused later. To remove a subset of options from the select, use
 * the #removeItems method.
 *
 * @fires remove
 * @chainable
 */
OO.ui.SelectWidget.prototype.clearItems = function () {
	var items = this.items.slice();

	// Mixin method
	OO.ui.GroupWidget.prototype.clearItems.call( this );

	// Clear selection
	this.selectItem( null );

	this.emit( 'remove', items );

	return this;
};

/**
 * ButtonSelectWidget is a {@link OO.ui.SelectWidget select widget} that contains
 * button options and is used together with
 * OO.ui.ButtonOptionWidget. The ButtonSelectWidget provides an interface for
 * highlighting, choosing, and selecting mutually exclusive options. Please see
 * the [OOjs UI documentation on MediaWiki] [1] for more information.
 *
 *     @example
 *     // Example: A ButtonSelectWidget that contains three ButtonOptionWidgets
 *     var option1 = new OO.ui.ButtonOptionWidget( {
 *         data: 1,
 *         label: 'Option 1',
 *         title:'Button option 1'
 *     } );
 *
 *     var option2 = new OO.ui.ButtonOptionWidget( {
 *         data: 2,
 *         label: 'Option 2',
 *         title:'Button option 2'
 *     } );
 *
 *     var option3 = new OO.ui.ButtonOptionWidget( {
 *         data: 3,
 *         label: 'Option 3',
 *         title:'Button option 3'
 *     } );
 *
 *     var buttonSelect=new OO.ui.ButtonSelectWidget( {
 *         items: [option1, option2, option3]
 *     } );
 *     $('body').append(buttonSelect.$element);
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Selects_and_Options
 *
 * @class
 * @extends OO.ui.SelectWidget
 * @mixins OO.ui.TabIndexedElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
OO.ui.ButtonSelectWidget = function OoUiButtonSelectWidget( config ) {
	// Parent constructor
	OO.ui.ButtonSelectWidget.super.call( this, config );

	// Mixin constructors
	OO.ui.TabIndexedElement.call( this, config );

	// Events
	this.$element.on( {
		focus: this.bindKeyDownListener.bind( this ),
		blur: this.unbindKeyDownListener.bind( this )
	} );

	// Initialization
	this.$element.addClass( 'oo-ui-buttonSelectWidget' );
};

/* Setup */

OO.inheritClass( OO.ui.ButtonSelectWidget, OO.ui.SelectWidget );
OO.mixinClass( OO.ui.ButtonSelectWidget, OO.ui.TabIndexedElement );

/**
 * RadioSelectWidget is a {@link OO.ui.SelectWidget select widget} that contains radio
 * options and is used together with OO.ui.RadioOptionWidget. The RadioSelectWidget provides
 * an interface for adding, removing and selecting options.
 * Please see the [OOjs UI documentation on MediaWiki][1] for more information.
 *
 *     @example
 *     // A RadioSelectWidget with RadioOptions.
 *     var option1 = new OO.ui.RadioOptionWidget( {
 *         data: 'a',
 *         label: 'Selected radio option'
 *     } );
 *
 *     var option2 = new OO.ui.RadioOptionWidget( {
 *         data: 'b',
 *         label: 'Unselected radio option'
 *     } );
 *
 *     var radioSelect=new OO.ui.RadioSelectWidget( {
 *         items: [option1, option2]
 *      } );
 *
 *     // Select 'option 1' using the RadioSelectWidget's selectItem() method.
 *     radioSelect.selectItem( option1 );
 *
 *     $('body').append(radioSelect.$element);
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Selects_and_Options

 *
 * @class
 * @extends OO.ui.SelectWidget
 * @mixins OO.ui.TabIndexedElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
OO.ui.RadioSelectWidget = function OoUiRadioSelectWidget( config ) {
	// Parent constructor
	OO.ui.RadioSelectWidget.super.call( this, config );

	// Mixin constructors
	OO.ui.TabIndexedElement.call( this, config );

	// Events
	this.$element.on( {
		focus: this.bindKeyDownListener.bind( this ),
		blur: this.unbindKeyDownListener.bind( this )
	} );

	// Initialization
	this.$element.addClass( 'oo-ui-radioSelectWidget' );
};

/* Setup */

OO.inheritClass( OO.ui.RadioSelectWidget, OO.ui.SelectWidget );
OO.mixinClass( OO.ui.RadioSelectWidget, OO.ui.TabIndexedElement );

/**
 * MenuSelectWidget is a {@link OO.ui.SelectWidget select widget} that contains options and
 * is used together with OO.ui.MenuOptionWidget. See {@link OO.ui.DropdownWidget DropdownWidget} and
 * {@link OO.ui.ComboBoxWidget ComboBoxWidget} for examples of interfaces that contain menus.
 * MenuSelectWidgets themselves are not designed to be instantiated directly, rather subclassed
 * and customized to be opened, closed, and displayed as needed.
 *
 * By default, menus are clipped to the visible viewport and are not visible when a user presses the
 * mouse outside the menu.
 *
 * Menus also have support for keyboard interaction:
 *
 * - Enter/Return key: choose and select a menu option
 * - Up-arrow key: highlight the previous menu option
 * - Down-arrow key: highlight the next menu option
 * - Esc key: hide the menu
 *
 * Please see the [OOjs UI documentation on MediaWiki][1] for more information.
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Selects_and_Options
 *
 * @class
 * @extends OO.ui.SelectWidget
 * @mixins OO.ui.ClippableElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {OO.ui.TextInputWidget} [input] Input to bind keyboard handlers to
 * @cfg {OO.ui.Widget} [widget] Widget to bind mouse handlers to
 * @cfg {boolean} [autoHide=true] Hide the menu when the mouse is pressed outside the menu
 */
OO.ui.MenuSelectWidget = function OoUiMenuSelectWidget( config ) {
	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.MenuSelectWidget.super.call( this, config );

	// Mixin constructors
	OO.ui.ClippableElement.call( this, $.extend( {}, config, { $clippable: this.$group } ) );

	// Properties
	this.newItems = null;
	this.autoHide = config.autoHide === undefined || !!config.autoHide;
	this.$input = config.input ? config.input.$input : null;
	this.$widget = config.widget ? config.widget.$element : null;
	this.onDocumentMouseDownHandler = this.onDocumentMouseDown.bind( this );

	// Initialization
	this.$element
		.addClass( 'oo-ui-menuSelectWidget' )
		.attr( 'role', 'menu' );

	// Initially hidden - using #toggle may cause errors if subclasses override toggle with methods
	// that reference properties not initialized at that time of parent class construction
	// TODO: Find a better way to handle post-constructor setup
	this.visible = false;
	this.$element.addClass( 'oo-ui-element-hidden' );
};

/* Setup */

OO.inheritClass( OO.ui.MenuSelectWidget, OO.ui.SelectWidget );
OO.mixinClass( OO.ui.MenuSelectWidget, OO.ui.ClippableElement );

/* Methods */

/**
 * Handles document mouse down events.
 *
 * @protected
 * @param {jQuery.Event} e Key down event
 */
OO.ui.MenuSelectWidget.prototype.onDocumentMouseDown = function ( e ) {
	if (
		!OO.ui.contains( this.$element[ 0 ], e.target, true ) &&
		( !this.$widget || !OO.ui.contains( this.$widget[ 0 ], e.target, true ) )
	) {
		this.toggle( false );
	}
};

/**
 * @inheritdoc
 */
OO.ui.MenuSelectWidget.prototype.onKeyDown = function ( e ) {
	var currentItem = this.getHighlightedItem() || this.getSelectedItem();

	if ( !this.isDisabled() && this.isVisible() ) {
		switch ( e.keyCode ) {
			case OO.ui.Keys.LEFT:
			case OO.ui.Keys.RIGHT:
				// Do nothing if a text field is associated, arrow keys will be handled natively
				if ( !this.$input ) {
					OO.ui.MenuSelectWidget.super.prototype.onKeyDown.call( this, e );
				}
				break;
			case OO.ui.Keys.ESCAPE:
			case OO.ui.Keys.TAB:
				if ( currentItem ) {
					currentItem.setHighlighted( false );
				}
				this.toggle( false );
				// Don't prevent tabbing away, prevent defocusing
				if ( e.keyCode === OO.ui.Keys.ESCAPE ) {
					e.preventDefault();
					e.stopPropagation();
				}
				break;
			default:
				OO.ui.MenuSelectWidget.super.prototype.onKeyDown.call( this, e );
				return;
		}
	}
};

/**
 * @inheritdoc
 */
OO.ui.MenuSelectWidget.prototype.bindKeyDownListener = function () {
	if ( this.$input ) {
		this.$input.on( 'keydown', this.onKeyDownHandler );
	} else {
		OO.ui.MenuSelectWidget.super.prototype.bindKeyDownListener.call( this );
	}
};

/**
 * @inheritdoc
 */
OO.ui.MenuSelectWidget.prototype.unbindKeyDownListener = function () {
	if ( this.$input ) {
		this.$input.off( 'keydown', this.onKeyDownHandler );
	} else {
		OO.ui.MenuSelectWidget.super.prototype.unbindKeyDownListener.call( this );
	}
};

/**
 * Choose an item.
 *
 * This will close the menu, unlike #selectItem which only changes selection.
 *
 * @param {OO.ui.OptionWidget} item Item to choose
 * @chainable
 */
OO.ui.MenuSelectWidget.prototype.chooseItem = function ( item ) {
	OO.ui.MenuSelectWidget.super.prototype.chooseItem.call( this, item );
	this.toggle( false );
	return this;
};

/**
 * @inheritdoc
 */
OO.ui.MenuSelectWidget.prototype.addItems = function ( items, index ) {
	var i, len, item;

	// Parent method
	OO.ui.MenuSelectWidget.super.prototype.addItems.call( this, items, index );

	// Auto-initialize
	if ( !this.newItems ) {
		this.newItems = [];
	}

	for ( i = 0, len = items.length; i < len; i++ ) {
		item = items[ i ];
		if ( this.isVisible() ) {
			// Defer fitting label until item has been attached
			item.fitLabel();
		} else {
			this.newItems.push( item );
		}
	}

	// Reevaluate clipping
	this.clip();

	return this;
};

/**
 * @inheritdoc
 */
OO.ui.MenuSelectWidget.prototype.removeItems = function ( items ) {
	// Parent method
	OO.ui.MenuSelectWidget.super.prototype.removeItems.call( this, items );

	// Reevaluate clipping
	this.clip();

	return this;
};

/**
 * @inheritdoc
 */
OO.ui.MenuSelectWidget.prototype.clearItems = function () {
	// Parent method
	OO.ui.MenuSelectWidget.super.prototype.clearItems.call( this );

	// Reevaluate clipping
	this.clip();

	return this;
};

/**
 * @inheritdoc
 */
OO.ui.MenuSelectWidget.prototype.toggle = function ( visible ) {
	visible = ( visible === undefined ? !this.visible : !!visible ) && !!this.items.length;

	var i, len,
		change = visible !== this.isVisible();

	// Parent method
	OO.ui.MenuSelectWidget.super.prototype.toggle.call( this, visible );

	if ( change ) {
		if ( visible ) {
			this.bindKeyDownListener();

			if ( this.newItems && this.newItems.length ) {
				for ( i = 0, len = this.newItems.length; i < len; i++ ) {
					this.newItems[ i ].fitLabel();
				}
				this.newItems = null;
			}
			this.toggleClipping( true );

			// Auto-hide
			if ( this.autoHide ) {
				this.getElementDocument().addEventListener(
					'mousedown', this.onDocumentMouseDownHandler, true
				);
			}
		} else {
			this.unbindKeyDownListener();
			this.getElementDocument().removeEventListener(
				'mousedown', this.onDocumentMouseDownHandler, true
			);
			this.toggleClipping( false );
		}
	}

	return this;
};

/**
 * Menu for a text input widget.
 *
 * This menu is specially designed to be positioned beneath a text input widget. The menu's position
 * is automatically calculated and maintained when the menu is toggled or the window is resized.
 *
 * @class
 * @extends OO.ui.MenuSelectWidget
 *
 * @constructor
 * @param {OO.ui.TextInputWidget} inputWidget Text input widget to provide menu for
 * @param {Object} [config] Configuration options
 * @cfg {jQuery} [$container=input.$element] Element to render menu under
 */
OO.ui.TextInputMenuSelectWidget = function OoUiTextInputMenuSelectWidget( inputWidget, config ) {
	// Allow passing positional parameters inside the config object
	if ( OO.isPlainObject( inputWidget ) && config === undefined ) {
		config = inputWidget;
		inputWidget = config.inputWidget;
	}

	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.TextInputMenuSelectWidget.super.call( this, config );

	// Properties
	this.inputWidget = inputWidget;
	this.$container = config.$container || this.inputWidget.$element;
	this.onWindowResizeHandler = this.onWindowResize.bind( this );

	// Initialization
	this.$element.addClass( 'oo-ui-textInputMenuSelectWidget' );
};

/* Setup */

OO.inheritClass( OO.ui.TextInputMenuSelectWidget, OO.ui.MenuSelectWidget );

/* Methods */

/**
 * Handle window resize event.
 *
 * @param {jQuery.Event} e Window resize event
 */
OO.ui.TextInputMenuSelectWidget.prototype.onWindowResize = function () {
	this.position();
};

/**
 * @inheritdoc
 */
OO.ui.TextInputMenuSelectWidget.prototype.toggle = function ( visible ) {
	visible = visible === undefined ? !this.isVisible() : !!visible;

	var change = visible !== this.isVisible();

	if ( change && visible ) {
		// Make sure the width is set before the parent method runs.
		// After this we have to call this.position(); again to actually
		// position ourselves correctly.
		this.position();
	}

	// Parent method
	OO.ui.TextInputMenuSelectWidget.super.prototype.toggle.call( this, visible );

	if ( change ) {
		if ( this.isVisible() ) {
			this.position();
			$( this.getElementWindow() ).on( 'resize', this.onWindowResizeHandler );
		} else {
			$( this.getElementWindow() ).off( 'resize', this.onWindowResizeHandler );
		}
	}

	return this;
};

/**
 * Position the menu.
 *
 * @chainable
 */
OO.ui.TextInputMenuSelectWidget.prototype.position = function () {
	var $container = this.$container,
		pos = OO.ui.Element.static.getRelativePosition( $container, this.$element.offsetParent() );

	// Position under input
	pos.top += $container.height();
	this.$element.css( pos );

	// Set width
	this.setIdealSize( $container.width() );
	// We updated the position, so re-evaluate the clipping state
	this.clip();

	return this;
};

/**
 * Structured list of items.
 *
 * Use with OO.ui.OutlineOptionWidget.
 *
 * @class
 * @extends OO.ui.SelectWidget
 * @mixins OO.ui.TabIndexedElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
OO.ui.OutlineSelectWidget = function OoUiOutlineSelectWidget( config ) {
	// Parent constructor
	OO.ui.OutlineSelectWidget.super.call( this, config );

	// Mixin constructors
	OO.ui.TabIndexedElement.call( this, config );

	// Events
	this.$element.on( {
		focus: this.bindKeyDownListener.bind( this ),
		blur: this.unbindKeyDownListener.bind( this )
	} );

	// Initialization
	this.$element.addClass( 'oo-ui-outlineSelectWidget' );
};

/* Setup */

OO.inheritClass( OO.ui.OutlineSelectWidget, OO.ui.SelectWidget );
OO.mixinClass( OO.ui.OutlineSelectWidget, OO.ui.TabIndexedElement );

/**
 * ToggleSwitches are switches that slide on and off. Their state is represented by a Boolean
 * value (`true` for ‘on’, and `false` otherwise, the default). The ‘off’ state is represented
 * visually by a slider in the leftmost position.
 *
 *     @example
 *     // Toggle switches in the 'off' and 'on' position.
 *     var toggleSwitch1 = new OO.ui.ToggleSwitchWidget({
 *         value: false
 *      } );
 *     var toggleSwitch2 = new OO.ui.ToggleSwitchWidget({
 *         value: true
 *     } );
 *
 *     // Create a FieldsetLayout to layout and label switches
 *     var fieldset = new OO.ui.FieldsetLayout( {
 *        label: 'Toggle switches'
 *     } );
 *     fieldset.addItems( [
 *         new OO.ui.FieldLayout( toggleSwitch1, {label : 'Off', align : 'top'}),
 *         new OO.ui.FieldLayout( toggleSwitch2, {label : 'On', align : 'top'})
 *     ] );
 *     $( 'body' ).append( fieldset.$element );
 *
 * @class
 * @extends OO.ui.Widget
 * @mixins OO.ui.ToggleWidget
 * @mixins OO.ui.TabIndexedElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {boolean} [value=false] The toggle switch’s initial on/off state.
 *  By default, the toggle switch is in the 'off' position.
 */
OO.ui.ToggleSwitchWidget = function OoUiToggleSwitchWidget( config ) {
	// Parent constructor
	OO.ui.ToggleSwitchWidget.super.call( this, config );

	// Mixin constructors
	OO.ui.ToggleWidget.call( this, config );
	OO.ui.TabIndexedElement.call( this, config );

	// Properties
	this.dragging = false;
	this.dragStart = null;
	this.sliding = false;
	this.$glow = $( '<span>' );
	this.$grip = $( '<span>' );

	// Events
	this.$element.on( {
		click: this.onClick.bind( this ),
		keypress: this.onKeyPress.bind( this )
	} );

	// Initialization
	this.$glow.addClass( 'oo-ui-toggleSwitchWidget-glow' );
	this.$grip.addClass( 'oo-ui-toggleSwitchWidget-grip' );
	this.$element
		.addClass( 'oo-ui-toggleSwitchWidget' )
		.attr( 'role', 'checkbox' )
		.append( this.$glow, this.$grip );
};

/* Setup */

OO.inheritClass( OO.ui.ToggleSwitchWidget, OO.ui.Widget );
OO.mixinClass( OO.ui.ToggleSwitchWidget, OO.ui.ToggleWidget );
OO.mixinClass( OO.ui.ToggleSwitchWidget, OO.ui.TabIndexedElement );

/* Methods */

/**
 * Handle mouse click events.
 *
 * @private
 * @param {jQuery.Event} e Mouse click event
 */
OO.ui.ToggleSwitchWidget.prototype.onClick = function ( e ) {
	if ( !this.isDisabled() && e.which === 1 ) {
		this.setValue( !this.value );
	}
	return false;
};

/**
 * Handle key press events.
 *
 * @private
 * @param {jQuery.Event} e Key press event
 */
OO.ui.ToggleSwitchWidget.prototype.onKeyPress = function ( e ) {
	if ( !this.isDisabled() && ( e.which === OO.ui.Keys.SPACE || e.which === OO.ui.Keys.ENTER ) ) {
		this.setValue( !this.value );
	}
	return false;
};

}( OO ) );

/*!
 * OOjs UI v0.9.0
 * https://www.mediawiki.org/wiki/OOjs_UI
 *
 * Copyright 2011–2015 OOjs Team and other contributors.
 * Released under the MIT license
 * http://oojs.mit-license.org
 *
 * Date: 2015-03-04T23:55:34Z
 */
/**
 * @class
 * @extends OO.ui.Theme
 *
 * @constructor
 */
OO.ui.ApexTheme = function OoUiApexTheme() {
	// Parent constructor
	OO.ui.ApexTheme.super.call( this );
};

/* Setup */

OO.inheritClass( OO.ui.ApexTheme, OO.ui.Theme );

/* Instantiation */

OO.ui.theme = new OO.ui.ApexTheme();

/*!
 * UnicodeJS v0.1.3
 * https://www.mediawiki.org/wiki/UnicodeJS
 *
 * Copyright 2013-2015 UnicodeJS Team and other contributors.
 * Released under the MIT license
 * http://unicodejs.mit-license.org/
 *
 * Date: 2015-02-05T02:13:05Z
 */
/*!
 * UnicodeJS namespace
 *
 * @copyright 2013–2015 UnicodeJS team and others; see AUTHORS.txt
 * @license The MIT License (MIT); see LICENSE.txt
 */

( function () {
	var unicodeJS;

	/**
	 * Namespace for all UnicodeJS classes, static methods and static properties.
	 * @class
	 * @singleton
	 */
	unicodeJS = {};

	/**
	 * Split a string into Unicode characters, keeping surrogates paired.
	 *
	 * You probably want to call unicodeJS.graphemebreak.splitClusters instead.
	 *
	 * @param {string} text Text to split
	 * @return {string[]} Array of characters
	 */
	unicodeJS.splitCharacters = function ( text ) {
		return text.split( /(?![\uDC00-\uDFFF])/g );
		// TODO: think through handling of invalid UTF-16
	};

	/**
	 * Write a UTF-16 code unit as a javascript string literal.
	 *
	 * @private
	 * @param {number} codeUnit integer between 0x0000 and 0xFFFF
	 * @return {string} String literal ('\u' followed by 4 hex digits)
	 */
	function uEsc( codeUnit ) {
		return '\\u' + ( codeUnit + 0x10000 ).toString( 16 ).slice( -4 );
	}

	/**
	 * Return a regexp string for the code unit range min-max
	 *
	 * @private
	 * @param {number} min the minimum code unit in the range.
	 * @param {number} max the maximum code unit in the range.
	 * @param {boolean} [bracket] If true, then wrap range in [ ... ]
	 * @return {string} Regexp string which matches the range
	 */
	function codeUnitRange( min, max, bracket ) {
		var value;
		if ( min === max ) { // single code unit: never bracket
			return uEsc( min );
		}
		value = uEsc( min ) + '-' + uEsc( max );
		if ( bracket ) {
			return '[' + value + ']';
		} else {
			return value;
		}
	}

	/**
	 * Get a list of boxes in hi-lo surrogate space, corresponding to the given character range
	 *
	 * A box {hi: [x, y], lo: [z, w]} represents a regex [x-y][z-w] to match a surrogate pair
	 *
	 * Suppose ch1 and ch2 have surrogate pairs (hi1, lo1) and (hi2, lo2).
	 * Then the range of chars from ch1 to ch2 can be represented as the
	 * disjunction of three code unit ranges:
	 *
	 *     [hi1 - hi1][lo1 - 0xDFFF]
	 *      |
	 *     [hi1+1 - hi2-1][0xDC00 - 0xDFFF]
	 *      |
	 *     [hi2 - hi2][0xD800 - lo2]
	 *
	 * Often the notation can be optimised (e.g. when hi1 == hi2).
	 *
	 * @private
	 * @param {number} ch1 The min character of the range; must be over 0xFFFF
	 * @param {number} ch2 The max character of the range; must be at least ch1
	 * @return {Object} A list of boxes {hi: [x, y], lo: [z, w]}
	 */
	function getCodeUnitBoxes( ch1, ch2 ) {
		var loMin, loMax, hi1, hi2, lo1, lo2, boxes, hiMinAbove, hiMaxBelow;
		// min and max lo surrogates possible in UTF-16
		loMin = 0xDC00;
		loMax = 0xDFFF;

		// hi and lo surrogates for ch1
		/* jslint bitwise: true */
		hi1 = 0xD800 + ( ( ch1 - 0x10000 ) >> 10 );
		lo1 = 0xDC00 + ( ( ch1 - 0x10000 ) & 0x3FF );

		// hi and lo surrogates for ch2
		hi2 = 0xD800 + ( ( ch2 - 0x10000 ) >> 10 );
		lo2 = 0xDC00 + ( ( ch2 - 0x10000 ) & 0x3FF );
		/* jslint bitwise: false */

		if ( hi1 === hi2 ) {
			return [ { hi: [ hi1, hi2 ], lo: [ lo1, lo2 ] } ];
		}

		boxes = [];

		/* jslint bitwise: true */
		// minimum hi surrogate which only represents characters >= ch1
		hiMinAbove = 0xD800 + ( ( ch1 - 0x10000 + 0x3FF ) >> 10 );
		// maximum hi surrogate which only represents characters <= ch2
		hiMaxBelow = 0xD800 + ( ( ch2 - 0x10000 - 0x3FF ) >> 10 );
		/* jslint bitwise: false */

		if ( hi1 < hiMinAbove ) {
			boxes.push( { hi: [ hi1, hi1 ], lo: [ lo1, loMax ] } );
		}
		if ( hiMinAbove <= hiMaxBelow ) {
			boxes.push( { hi: [ hiMinAbove, hiMaxBelow ], lo: [ loMin, loMax ] } );
		}
		if ( hiMaxBelow < hi2 ) {
			boxes.push( { hi: [ hi2, hi2 ], lo: [ loMin, lo2 ] } );
		}
		return boxes;
	}

	/**
	 * Make a regexp string for an array of Unicode character ranges.
	 *
	 * If either character in a range is above 0xFFFF, then the range will
	 * be encoded as multiple surrogate pair ranges. It is an error for a
	 * range to overlap with the surrogate range 0xD800-0xDFFF (as this would
	 * only match ill-formed strings).
	 *
	 * @param {Array} ranges Array of ranges, each of which is a character or an interval
	 * @return {string} Regexp string for the disjunction of the ranges.
	 */
	unicodeJS.charRangeArrayRegexp = function ( ranges ) {
		var i, j, min, max, hi, lo, range, box,
			boxes = [],
			characterClass = [], // list of (\uXXXX code unit or interval), for BMP
			disjunction = []; // list of regex strings, to be joined with '|'

		for ( i = 0; i < ranges.length; i++ ) {
			range = ranges[i];
			// Handle single code unit
			if ( typeof range === 'number' && range <= 0xFFFF ) {
				if ( range >= 0xD800 && range <= 0xDFFF ) {
					throw new Error( 'Surrogate: ' + range.toString( 16 ) );
				}
				if ( range > 0x10FFFF ) {
					throw new Error( 'Character code too high: ' +
						range.toString( 16 ) );
				}
				characterClass.push( uEsc( range ) );
				continue;
			}

			// Handle single surrogate pair
			if ( typeof range === 'number' && range > 0xFFFF ) {
				/* jslint bitwise: true */
				hi = 0xD800 + ( ( range - 0x10000 ) >> 10 );
				lo = 0xDC00 + ( ( range - 0x10000 ) & 0x3FF );
				/* jslint bitwise: false */
				disjunction.push( uEsc( hi ) + uEsc( lo ) );
				continue;
			}

			// Handle interval
			min = range[0];
			max = range[1];
			if ( min > max ) {
				throw new Error( min.toString( 16 ) + ' > ' + max.toString( 16 ) );
			}
			if ( max > 0x10FFFF ) {
				throw new Error( 'Character code too high: ' +
					max.toString( 16 ) );
			}
			if ( max >= 0xD800 && min <= 0xDFFF ) {
				throw new Error( 'range includes surrogates: ' +
					min.toString( 16 ) + '-' + max.toString( 16 ) );
			}
			if ( max <= 0xFFFF ) {
				// interval is entirely BMP
				characterClass.push( codeUnitRange( min, max ) );
			} else if ( min <= 0xFFFF && max > 0xFFFF ) {
				// interval is BMP and non-BMP
				characterClass.push( codeUnitRange( min, 0xFFFF ) );
				boxes = getCodeUnitBoxes( 0x10000, max );
			} else if ( min > 0xFFFF ) {
				// interval is entirely non-BMP
				boxes = getCodeUnitBoxes( min, max );
			}

			// append hi-lo surrogate space boxes as code unit range pairs
			for ( j = 0; j < boxes.length; j++ ) {
				box = boxes[j];
				hi = codeUnitRange( box.hi[0], box.hi[1], true );
				lo = codeUnitRange( box.lo[0], box.lo[1], true );
				disjunction.push( hi + lo );
			}
		}

		// prepend BMP character class to the disjunction
		if ( characterClass.length === 1 && !characterClass[0].match( /-/ ) ) {
			disjunction.unshift( characterClass[0] ); // single character
		} else if ( characterClass.length > 0 ) {
			disjunction.unshift( '[' + characterClass.join( '' ) + ']' );
		}
		return disjunction.join( '|' );
	};

	// Expose
	/*jshint browser:true */
	window.unicodeJS = unicodeJS;
}() );

// This file is GENERATED by tools/unicodejs-properties.py
// DO NOT EDIT
unicodeJS.derivedcoreproperties = {
	// partial extraction only
	Alphabetic: [[0x0041, 0x005A], [0x0061, 0x007A], 0x00AA, 0x00B5, 0x00BA, [0x00C0, 0x00D6], [0x00D8, 0x00F6], [0x00F8, 0x02C1], [0x02C6, 0x02D1], [0x02E0, 0x02E4], 0x02EC, 0x02EE, 0x0345, [0x0370, 0x0374], 0x0376, 0x0377, [0x037A, 0x037D], 0x037F, 0x0386, [0x0388, 0x038A], 0x038C, [0x038E, 0x03A1], [0x03A3, 0x03F5], [0x03F7, 0x0481], [0x048A, 0x052F], [0x0531, 0x0556], 0x0559, [0x0561, 0x0587], [0x05B0, 0x05BD], 0x05BF, 0x05C1, 0x05C2, 0x05C4, 0x05C5, 0x05C7, [0x05D0, 0x05EA], [0x05F0, 0x05F2], [0x0610, 0x061A], [0x0620, 0x0657], [0x0659, 0x065F], [0x066E, 0x06D3], [0x06D5, 0x06DC], [0x06E1, 0x06E8], [0x06ED, 0x06EF], [0x06FA, 0x06FC], 0x06FF, [0x0710, 0x073F], [0x074D, 0x07B1], [0x07CA, 0x07EA], 0x07F4, 0x07F5, 0x07FA, [0x0800, 0x0817], [0x081A, 0x082C], [0x0840, 0x0858], [0x08A0, 0x08B2], [0x08E4, 0x08E9], [0x08F0, 0x093B], [0x093D, 0x094C], [0x094E, 0x0950], [0x0955, 0x0963], [0x0971, 0x0983], [0x0985, 0x098C], 0x098F, 0x0990, [0x0993, 0x09A8], [0x09AA, 0x09B0], 0x09B2, [0x09B6, 0x09B9], [0x09BD, 0x09C4], 0x09C7, 0x09C8, 0x09CB, 0x09CC, 0x09CE, 0x09D7, 0x09DC, 0x09DD, [0x09DF, 0x09E3], 0x09F0, 0x09F1, [0x0A01, 0x0A03], [0x0A05, 0x0A0A], 0x0A0F, 0x0A10, [0x0A13, 0x0A28], [0x0A2A, 0x0A30], 0x0A32, 0x0A33, 0x0A35, 0x0A36, 0x0A38, 0x0A39, [0x0A3E, 0x0A42], 0x0A47, 0x0A48, 0x0A4B, 0x0A4C, 0x0A51, [0x0A59, 0x0A5C], 0x0A5E, [0x0A70, 0x0A75], [0x0A81, 0x0A83], [0x0A85, 0x0A8D], [0x0A8F, 0x0A91], [0x0A93, 0x0AA8], [0x0AAA, 0x0AB0], 0x0AB2, 0x0AB3, [0x0AB5, 0x0AB9], [0x0ABD, 0x0AC5], [0x0AC7, 0x0AC9], 0x0ACB, 0x0ACC, 0x0AD0, [0x0AE0, 0x0AE3], [0x0B01, 0x0B03], [0x0B05, 0x0B0C], 0x0B0F, 0x0B10, [0x0B13, 0x0B28], [0x0B2A, 0x0B30], 0x0B32, 0x0B33, [0x0B35, 0x0B39], [0x0B3D, 0x0B44], 0x0B47, 0x0B48, 0x0B4B, 0x0B4C, 0x0B56, 0x0B57, 0x0B5C, 0x0B5D, [0x0B5F, 0x0B63], 0x0B71, 0x0B82, 0x0B83, [0x0B85, 0x0B8A], [0x0B8E, 0x0B90], [0x0B92, 0x0B95], 0x0B99, 0x0B9A, 0x0B9C, 0x0B9E, 0x0B9F, 0x0BA3, 0x0BA4, [0x0BA8, 0x0BAA], [0x0BAE, 0x0BB9], [0x0BBE, 0x0BC2], [0x0BC6, 0x0BC8], [0x0BCA, 0x0BCC], 0x0BD0, 0x0BD7, [0x0C00, 0x0C03], [0x0C05, 0x0C0C], [0x0C0E, 0x0C10], [0x0C12, 0x0C28], [0x0C2A, 0x0C39], [0x0C3D, 0x0C44], [0x0C46, 0x0C48], [0x0C4A, 0x0C4C], 0x0C55, 0x0C56, 0x0C58, 0x0C59, [0x0C60, 0x0C63], [0x0C81, 0x0C83], [0x0C85, 0x0C8C], [0x0C8E, 0x0C90], [0x0C92, 0x0CA8], [0x0CAA, 0x0CB3], [0x0CB5, 0x0CB9], [0x0CBD, 0x0CC4], [0x0CC6, 0x0CC8], [0x0CCA, 0x0CCC], 0x0CD5, 0x0CD6, 0x0CDE, [0x0CE0, 0x0CE3], 0x0CF1, 0x0CF2, [0x0D01, 0x0D03], [0x0D05, 0x0D0C], [0x0D0E, 0x0D10], [0x0D12, 0x0D3A], [0x0D3D, 0x0D44], [0x0D46, 0x0D48], [0x0D4A, 0x0D4C], 0x0D4E, 0x0D57, [0x0D60, 0x0D63], [0x0D7A, 0x0D7F], 0x0D82, 0x0D83, [0x0D85, 0x0D96], [0x0D9A, 0x0DB1], [0x0DB3, 0x0DBB], 0x0DBD, [0x0DC0, 0x0DC6], [0x0DCF, 0x0DD4], 0x0DD6, [0x0DD8, 0x0DDF], 0x0DF2, 0x0DF3, [0x0E01, 0x0E3A], [0x0E40, 0x0E46], 0x0E4D, 0x0E81, 0x0E82, 0x0E84, 0x0E87, 0x0E88, 0x0E8A, 0x0E8D, [0x0E94, 0x0E97], [0x0E99, 0x0E9F], [0x0EA1, 0x0EA3], 0x0EA5, 0x0EA7, 0x0EAA, 0x0EAB, [0x0EAD, 0x0EB9], [0x0EBB, 0x0EBD], [0x0EC0, 0x0EC4], 0x0EC6, 0x0ECD, [0x0EDC, 0x0EDF], 0x0F00, [0x0F40, 0x0F47], [0x0F49, 0x0F6C], [0x0F71, 0x0F81], [0x0F88, 0x0F97], [0x0F99, 0x0FBC], [0x1000, 0x1036], 0x1038, [0x103B, 0x103F], [0x1050, 0x1062], [0x1065, 0x1068], [0x106E, 0x1086], 0x108E, 0x109C, 0x109D, [0x10A0, 0x10C5], 0x10C7, 0x10CD, [0x10D0, 0x10FA], [0x10FC, 0x1248], [0x124A, 0x124D], [0x1250, 0x1256], 0x1258, [0x125A, 0x125D], [0x1260, 0x1288], [0x128A, 0x128D], [0x1290, 0x12B0], [0x12B2, 0x12B5], [0x12B8, 0x12BE], 0x12C0, [0x12C2, 0x12C5], [0x12C8, 0x12D6], [0x12D8, 0x1310], [0x1312, 0x1315], [0x1318, 0x135A], 0x135F, [0x1380, 0x138F], [0x13A0, 0x13F4], [0x1401, 0x166C], [0x166F, 0x167F], [0x1681, 0x169A], [0x16A0, 0x16EA], [0x16EE, 0x16F8], [0x1700, 0x170C], [0x170E, 0x1713], [0x1720, 0x1733], [0x1740, 0x1753], [0x1760, 0x176C], [0x176E, 0x1770], 0x1772, 0x1773, [0x1780, 0x17B3], [0x17B6, 0x17C8], 0x17D7, 0x17DC, [0x1820, 0x1877], [0x1880, 0x18AA], [0x18B0, 0x18F5], [0x1900, 0x191E], [0x1920, 0x192B], [0x1930, 0x1938], [0x1950, 0x196D], [0x1970, 0x1974], [0x1980, 0x19AB], [0x19B0, 0x19C9], [0x1A00, 0x1A1B], [0x1A20, 0x1A5E], [0x1A61, 0x1A74], 0x1AA7, [0x1B00, 0x1B33], [0x1B35, 0x1B43], [0x1B45, 0x1B4B], [0x1B80, 0x1BA9], [0x1BAC, 0x1BAF], [0x1BBA, 0x1BE5], [0x1BE7, 0x1BF1], [0x1C00, 0x1C35], [0x1C4D, 0x1C4F], [0x1C5A, 0x1C7D], [0x1CE9, 0x1CEC], [0x1CEE, 0x1CF3], 0x1CF5, 0x1CF6, [0x1D00, 0x1DBF], [0x1DE7, 0x1DF4], [0x1E00, 0x1F15], [0x1F18, 0x1F1D], [0x1F20, 0x1F45], [0x1F48, 0x1F4D], [0x1F50, 0x1F57], 0x1F59, 0x1F5B, 0x1F5D, [0x1F5F, 0x1F7D], [0x1F80, 0x1FB4], [0x1FB6, 0x1FBC], 0x1FBE, [0x1FC2, 0x1FC4], [0x1FC6, 0x1FCC], [0x1FD0, 0x1FD3], [0x1FD6, 0x1FDB], [0x1FE0, 0x1FEC], [0x1FF2, 0x1FF4], [0x1FF6, 0x1FFC], 0x2071, 0x207F, [0x2090, 0x209C], 0x2102, 0x2107, [0x210A, 0x2113], 0x2115, [0x2119, 0x211D], 0x2124, 0x2126, 0x2128, [0x212A, 0x212D], [0x212F, 0x2139], [0x213C, 0x213F], [0x2145, 0x2149], 0x214E, [0x2160, 0x2188], [0x24B6, 0x24E9], [0x2C00, 0x2C2E], [0x2C30, 0x2C5E], [0x2C60, 0x2CE4], [0x2CEB, 0x2CEE], 0x2CF2, 0x2CF3, [0x2D00, 0x2D25], 0x2D27, 0x2D2D, [0x2D30, 0x2D67], 0x2D6F, [0x2D80, 0x2D96], [0x2DA0, 0x2DA6], [0x2DA8, 0x2DAE], [0x2DB0, 0x2DB6], [0x2DB8, 0x2DBE], [0x2DC0, 0x2DC6], [0x2DC8, 0x2DCE], [0x2DD0, 0x2DD6], [0x2DD8, 0x2DDE], [0x2DE0, 0x2DFF], 0x2E2F, [0x3005, 0x3007], [0x3021, 0x3029], [0x3031, 0x3035], [0x3038, 0x303C], [0x3041, 0x3096], [0x309D, 0x309F], [0x30A1, 0x30FA], [0x30FC, 0x30FF], [0x3105, 0x312D], [0x3131, 0x318E], [0x31A0, 0x31BA], [0x31F0, 0x31FF], [0x3400, 0x4DB5], [0x4E00, 0x9FCC], [0xA000, 0xA48C], [0xA4D0, 0xA4FD], [0xA500, 0xA60C], [0xA610, 0xA61F], 0xA62A, 0xA62B, [0xA640, 0xA66E], [0xA674, 0xA67B], [0xA67F, 0xA69D], [0xA69F, 0xA6EF], [0xA717, 0xA71F], [0xA722, 0xA788], [0xA78B, 0xA78E], [0xA790, 0xA7AD], 0xA7B0, 0xA7B1, [0xA7F7, 0xA801], [0xA803, 0xA805], [0xA807, 0xA80A], [0xA80C, 0xA827], [0xA840, 0xA873], [0xA880, 0xA8C3], [0xA8F2, 0xA8F7], 0xA8FB, [0xA90A, 0xA92A], [0xA930, 0xA952], [0xA960, 0xA97C], [0xA980, 0xA9B2], [0xA9B4, 0xA9BF], 0xA9CF, [0xA9E0, 0xA9E4], [0xA9E6, 0xA9EF], [0xA9FA, 0xA9FE], [0xAA00, 0xAA36], [0xAA40, 0xAA4D], [0xAA60, 0xAA76], 0xAA7A, [0xAA7E, 0xAABE], 0xAAC0, 0xAAC2, [0xAADB, 0xAADD], [0xAAE0, 0xAAEF], [0xAAF2, 0xAAF5], [0xAB01, 0xAB06], [0xAB09, 0xAB0E], [0xAB11, 0xAB16], [0xAB20, 0xAB26], [0xAB28, 0xAB2E], [0xAB30, 0xAB5A], [0xAB5C, 0xAB5F], 0xAB64, 0xAB65, [0xABC0, 0xABEA], [0xAC00, 0xD7A3], [0xD7B0, 0xD7C6], [0xD7CB, 0xD7FB], [0xF900, 0xFA6D], [0xFA70, 0xFAD9], [0xFB00, 0xFB06], [0xFB13, 0xFB17], [0xFB1D, 0xFB28], [0xFB2A, 0xFB36], [0xFB38, 0xFB3C], 0xFB3E, 0xFB40, 0xFB41, 0xFB43, 0xFB44, [0xFB46, 0xFBB1], [0xFBD3, 0xFD3D], [0xFD50, 0xFD8F], [0xFD92, 0xFDC7], [0xFDF0, 0xFDFB], [0xFE70, 0xFE74], [0xFE76, 0xFEFC], [0xFF21, 0xFF3A], [0xFF41, 0xFF5A], [0xFF66, 0xFFBE], [0xFFC2, 0xFFC7], [0xFFCA, 0xFFCF], [0xFFD2, 0xFFD7], [0xFFDA, 0xFFDC], [0x10000, 0x1000B], [0x1000D, 0x10026], [0x10028, 0x1003A], 0x1003C, 0x1003D, [0x1003F, 0x1004D], [0x10050, 0x1005D], [0x10080, 0x100FA], [0x10140, 0x10174], [0x10280, 0x1029C], [0x102A0, 0x102D0], [0x10300, 0x1031F], [0x10330, 0x1034A], [0x10350, 0x1037A], [0x10380, 0x1039D], [0x103A0, 0x103C3], [0x103C8, 0x103CF], [0x103D1, 0x103D5], [0x10400, 0x1049D], [0x10500, 0x10527], [0x10530, 0x10563], [0x10600, 0x10736], [0x10740, 0x10755], [0x10760, 0x10767], [0x10800, 0x10805], 0x10808, [0x1080A, 0x10835], 0x10837, 0x10838, 0x1083C, [0x1083F, 0x10855], [0x10860, 0x10876], [0x10880, 0x1089E], [0x10900, 0x10915], [0x10920, 0x10939], [0x10980, 0x109B7], 0x109BE, 0x109BF, [0x10A00, 0x10A03], 0x10A05, 0x10A06, [0x10A0C, 0x10A13], [0x10A15, 0x10A17], [0x10A19, 0x10A33], [0x10A60, 0x10A7C], [0x10A80, 0x10A9C], [0x10AC0, 0x10AC7], [0x10AC9, 0x10AE4], [0x10B00, 0x10B35], [0x10B40, 0x10B55], [0x10B60, 0x10B72], [0x10B80, 0x10B91], [0x10C00, 0x10C48], [0x11000, 0x11045], [0x11082, 0x110B8], [0x110D0, 0x110E8], [0x11100, 0x11132], [0x11150, 0x11172], 0x11176, [0x11180, 0x111BF], [0x111C1, 0x111C4], 0x111DA, [0x11200, 0x11211], [0x11213, 0x11234], 0x11237, [0x112B0, 0x112E8], [0x11301, 0x11303], [0x11305, 0x1130C], 0x1130F, 0x11310, [0x11313, 0x11328], [0x1132A, 0x11330], 0x11332, 0x11333, [0x11335, 0x11339], [0x1133D, 0x11344], 0x11347, 0x11348, 0x1134B, 0x1134C, 0x11357, [0x1135D, 0x11363], [0x11480, 0x114C1], 0x114C4, 0x114C5, 0x114C7, [0x11580, 0x115B5], [0x115B8, 0x115BE], [0x11600, 0x1163E], 0x11640, 0x11644, [0x11680, 0x116B5], [0x118A0, 0x118DF], 0x118FF, [0x11AC0, 0x11AF8], [0x12000, 0x12398], [0x12400, 0x1246E], [0x13000, 0x1342E], [0x16800, 0x16A38], [0x16A40, 0x16A5E], [0x16AD0, 0x16AED], [0x16B00, 0x16B36], [0x16B40, 0x16B43], [0x16B63, 0x16B77], [0x16B7D, 0x16B8F], [0x16F00, 0x16F44], [0x16F50, 0x16F7E], [0x16F93, 0x16F9F], 0x1B000, 0x1B001, [0x1BC00, 0x1BC6A], [0x1BC70, 0x1BC7C], [0x1BC80, 0x1BC88], [0x1BC90, 0x1BC99], 0x1BC9E, [0x1D400, 0x1D454], [0x1D456, 0x1D49C], 0x1D49E, 0x1D49F, 0x1D4A2, 0x1D4A5, 0x1D4A6, [0x1D4A9, 0x1D4AC], [0x1D4AE, 0x1D4B9], 0x1D4BB, [0x1D4BD, 0x1D4C3], [0x1D4C5, 0x1D505], [0x1D507, 0x1D50A], [0x1D50D, 0x1D514], [0x1D516, 0x1D51C], [0x1D51E, 0x1D539], [0x1D53B, 0x1D53E], [0x1D540, 0x1D544], 0x1D546, [0x1D54A, 0x1D550], [0x1D552, 0x1D6A5], [0x1D6A8, 0x1D6C0], [0x1D6C2, 0x1D6DA], [0x1D6DC, 0x1D6FA], [0x1D6FC, 0x1D714], [0x1D716, 0x1D734], [0x1D736, 0x1D74E], [0x1D750, 0x1D76E], [0x1D770, 0x1D788], [0x1D78A, 0x1D7A8], [0x1D7AA, 0x1D7C2], [0x1D7C4, 0x1D7CB], [0x1E800, 0x1E8C4], [0x1EE00, 0x1EE03], [0x1EE05, 0x1EE1F], 0x1EE21, 0x1EE22, 0x1EE24, 0x1EE27, [0x1EE29, 0x1EE32], [0x1EE34, 0x1EE37], 0x1EE39, 0x1EE3B, 0x1EE42, 0x1EE47, 0x1EE49, 0x1EE4B, [0x1EE4D, 0x1EE4F], 0x1EE51, 0x1EE52, 0x1EE54, 0x1EE57, 0x1EE59, 0x1EE5B, 0x1EE5D, 0x1EE5F, 0x1EE61, 0x1EE62, 0x1EE64, [0x1EE67, 0x1EE6A], [0x1EE6C, 0x1EE72], [0x1EE74, 0x1EE77], [0x1EE79, 0x1EE7C], 0x1EE7E, [0x1EE80, 0x1EE89], [0x1EE8B, 0x1EE9B], [0x1EEA1, 0x1EEA3], [0x1EEA5, 0x1EEA9], [0x1EEAB, 0x1EEBB], [0x1F130, 0x1F149], [0x1F150, 0x1F169], [0x1F170, 0x1F189], [0x20000, 0x2A6D6], [0x2A700, 0x2B734], [0x2B740, 0x2B81D], [0x2F800, 0x2FA1D]]
};

// This file is GENERATED by tools/unicodejs-properties.py
// DO NOT EDIT
unicodeJS.derivedgeneralcategories = {
	// partial extraction only
	M: [[0x0300, 0x036F], [0x0483, 0x0489], [0x0591, 0x05BD], 0x05BF, 0x05C1, 0x05C2, 0x05C4, 0x05C5, 0x05C7, [0x0610, 0x061A], [0x064B, 0x065F], 0x0670, [0x06D6, 0x06DC], [0x06DF, 0x06E4], 0x06E7, 0x06E8, [0x06EA, 0x06ED], 0x0711, [0x0730, 0x074A], [0x07A6, 0x07B0], [0x07EB, 0x07F3], [0x0816, 0x0819], [0x081B, 0x0823], [0x0825, 0x0827], [0x0829, 0x082D], [0x0859, 0x085B], [0x08E4, 0x0903], [0x093A, 0x093C], [0x093E, 0x094F], [0x0951, 0x0957], 0x0962, 0x0963, [0x0981, 0x0983], 0x09BC, [0x09BE, 0x09C4], 0x09C7, 0x09C8, [0x09CB, 0x09CD], 0x09D7, 0x09E2, 0x09E3, [0x0A01, 0x0A03], 0x0A3C, [0x0A3E, 0x0A42], 0x0A47, 0x0A48, [0x0A4B, 0x0A4D], 0x0A51, 0x0A70, 0x0A71, 0x0A75, [0x0A81, 0x0A83], 0x0ABC, [0x0ABE, 0x0AC5], [0x0AC7, 0x0AC9], [0x0ACB, 0x0ACD], 0x0AE2, 0x0AE3, [0x0B01, 0x0B03], 0x0B3C, [0x0B3E, 0x0B44], 0x0B47, 0x0B48, [0x0B4B, 0x0B4D], 0x0B56, 0x0B57, 0x0B62, 0x0B63, 0x0B82, [0x0BBE, 0x0BC2], [0x0BC6, 0x0BC8], [0x0BCA, 0x0BCD], 0x0BD7, [0x0C00, 0x0C03], [0x0C3E, 0x0C44], [0x0C46, 0x0C48], [0x0C4A, 0x0C4D], 0x0C55, 0x0C56, 0x0C62, 0x0C63, [0x0C81, 0x0C83], 0x0CBC, [0x0CBE, 0x0CC4], [0x0CC6, 0x0CC8], [0x0CCA, 0x0CCD], 0x0CD5, 0x0CD6, 0x0CE2, 0x0CE3, [0x0D01, 0x0D03], [0x0D3E, 0x0D44], [0x0D46, 0x0D48], [0x0D4A, 0x0D4D], 0x0D57, 0x0D62, 0x0D63, 0x0D82, 0x0D83, 0x0DCA, [0x0DCF, 0x0DD4], 0x0DD6, [0x0DD8, 0x0DDF], 0x0DF2, 0x0DF3, 0x0E31, [0x0E34, 0x0E3A], [0x0E47, 0x0E4E], 0x0EB1, [0x0EB4, 0x0EB9], 0x0EBB, 0x0EBC, [0x0EC8, 0x0ECD], 0x0F18, 0x0F19, 0x0F35, 0x0F37, 0x0F39, 0x0F3E, 0x0F3F, [0x0F71, 0x0F84], 0x0F86, 0x0F87, [0x0F8D, 0x0F97], [0x0F99, 0x0FBC], 0x0FC6, [0x102B, 0x103E], [0x1056, 0x1059], [0x105E, 0x1060], [0x1062, 0x1064], [0x1067, 0x106D], [0x1071, 0x1074], [0x1082, 0x108D], 0x108F, [0x109A, 0x109D], [0x135D, 0x135F], [0x1712, 0x1714], [0x1732, 0x1734], 0x1752, 0x1753, 0x1772, 0x1773, [0x17B4, 0x17D3], 0x17DD, [0x180B, 0x180D], 0x18A9, [0x1920, 0x192B], [0x1930, 0x193B], [0x19B0, 0x19C0], 0x19C8, 0x19C9, [0x1A17, 0x1A1B], [0x1A55, 0x1A5E], [0x1A60, 0x1A7C], 0x1A7F, [0x1AB0, 0x1ABE], [0x1B00, 0x1B04], [0x1B34, 0x1B44], [0x1B6B, 0x1B73], [0x1B80, 0x1B82], [0x1BA1, 0x1BAD], [0x1BE6, 0x1BF3], [0x1C24, 0x1C37], [0x1CD0, 0x1CD2], [0x1CD4, 0x1CE8], 0x1CED, [0x1CF2, 0x1CF4], 0x1CF8, 0x1CF9, [0x1DC0, 0x1DF5], [0x1DFC, 0x1DFF], [0x20D0, 0x20F0], [0x2CEF, 0x2CF1], 0x2D7F, [0x2DE0, 0x2DFF], [0x302A, 0x302F], 0x3099, 0x309A, [0xA66F, 0xA672], [0xA674, 0xA67D], 0xA69F, 0xA6F0, 0xA6F1, 0xA802, 0xA806, 0xA80B, [0xA823, 0xA827], 0xA880, 0xA881, [0xA8B4, 0xA8C4], [0xA8E0, 0xA8F1], [0xA926, 0xA92D], [0xA947, 0xA953], [0xA980, 0xA983], [0xA9B3, 0xA9C0], 0xA9E5, [0xAA29, 0xAA36], 0xAA43, 0xAA4C, 0xAA4D, [0xAA7B, 0xAA7D], 0xAAB0, [0xAAB2, 0xAAB4], 0xAAB7, 0xAAB8, 0xAABE, 0xAABF, 0xAAC1, [0xAAEB, 0xAAEF], 0xAAF5, 0xAAF6, [0xABE3, 0xABEA], 0xABEC, 0xABED, 0xFB1E, [0xFE00, 0xFE0F], [0xFE20, 0xFE2D], 0x101FD, 0x102E0, [0x10376, 0x1037A], [0x10A01, 0x10A03], 0x10A05, 0x10A06, [0x10A0C, 0x10A0F], [0x10A38, 0x10A3A], 0x10A3F, 0x10AE5, 0x10AE6, [0x11000, 0x11002], [0x11038, 0x11046], [0x1107F, 0x11082], [0x110B0, 0x110BA], [0x11100, 0x11102], [0x11127, 0x11134], 0x11173, [0x11180, 0x11182], [0x111B3, 0x111C0], [0x1122C, 0x11237], [0x112DF, 0x112EA], [0x11301, 0x11303], 0x1133C, [0x1133E, 0x11344], 0x11347, 0x11348, [0x1134B, 0x1134D], 0x11357, 0x11362, 0x11363, [0x11366, 0x1136C], [0x11370, 0x11374], [0x114B0, 0x114C3], [0x115AF, 0x115B5], [0x115B8, 0x115C0], [0x11630, 0x11640], [0x116AB, 0x116B7], [0x16AF0, 0x16AF4], [0x16B30, 0x16B36], [0x16F51, 0x16F7E], [0x16F8F, 0x16F92], 0x1BC9D, 0x1BC9E, [0x1D165, 0x1D169], [0x1D16D, 0x1D172], [0x1D17B, 0x1D182], [0x1D185, 0x1D18B], [0x1D1AA, 0x1D1AD], [0x1D242, 0x1D244], [0x1E8D0, 0x1E8D6], [0xE0100, 0xE01EF]],
	Pc: [0x005F, 0x203F, 0x2040, 0x2054, 0xFE33, 0xFE34, [0xFE4D, 0xFE4F], 0xFF3F]
};

/*!
 * UnicodeJS character classes
 *
 * Support for unicode equivalents of JS regex character classes
 *
 * @copyright 2013–2015 UnicodeJS team and others; see AUTHORS.txt
 * @license The MIT License (MIT); see LICENSE.txt
 */
( function () {
	/**
	 * @class unicodeJS.characterclass
	 * @singleton
	 */
	var basicLatinDigitRange = [ 0x30, 0x39 ],
		joinControlRange = [ 0x200C, 0x200D ],
		characterclass = unicodeJS.characterclass = {};

	characterclass.patterns = {
		// \w is defined in http://unicode.org/reports/tr18/
		word: unicodeJS.charRangeArrayRegexp( [].concat(
			unicodeJS.derivedcoreproperties.Alphabetic,
			unicodeJS.derivedgeneralcategories.M,
			[ basicLatinDigitRange ],
			unicodeJS.derivedgeneralcategories.Pc,
			[ joinControlRange ]
		) )
	};
}() );

/*!
 * UnicodeJS TextString class.
 *
 * @copyright 2013–2015 UnicodeJS team and others; see AUTHORS.txt
 * @license The MIT License (MIT); see LICENSE.txt
 */

/**
 * This class provides a simple interface to fetching plain text
 * from a data source. The base class reads data from a string, but
 * an extended class could provide access to a more complex structure,
 * e.g. an array or an HTML document tree.
 *
 * @class unicodeJS.TextString
 * @constructor
 * @param {string} text Text
 */
unicodeJS.TextString = function UnicodeJSTextString( text ) {
	this.clusters = unicodeJS.graphemebreak.splitClusters( text );
};

/* Methods */

/**
 * Read grapheme cluster at specified position
 *
 * @method
 * @param {number} position Position to read from
 * @return {string|null} Grapheme cluster, or null if out of bounds
 */
unicodeJS.TextString.prototype.read = function ( position ) {
	var clusterAt = this.clusters[position];
	return clusterAt !== undefined ? clusterAt : null;
};

/**
 * Return number of grapheme clusters in the text string
 *
 * @method
 * @return {number} Number of grapheme clusters
 */
unicodeJS.TextString.prototype.getLength = function () {
	return this.clusters.length;
};

/**
 * Return a sub-TextString
 *
 * @param {number} start Start offset
 * @param {number} end End offset
 * @return {unicodeJS.TextString} New TextString object containing substring
 */
unicodeJS.TextString.prototype.substring = function ( start, end ) {
	var textString = new unicodeJS.TextString( '' );
	textString.clusters = this.clusters.slice( start, end );
	return textString;
};

/**
 * Get as a plain string
 *
 * @return {string} Plain javascript string
 */
unicodeJS.TextString.prototype.getString = function () {
	return this.clusters.join( '' );
};

// This file is GENERATED by tools/unicodejs-properties.py
// DO NOT EDIT
unicodeJS.graphemebreakproperties = {
	CR: [0x000D],
	LF: [0x000A],
	Control: [[0x0000, 0x0009], 0x000B, 0x000C, [0x000E, 0x001F], [0x007F, 0x009F], 0x00AD, [0x0600, 0x0605], 0x061C, 0x06DD, 0x070F, 0x180E, 0x200B, 0x200E, 0x200F, [0x2028, 0x202E], [0x2060, 0x206F], 0xFEFF, [0xFFF0, 0xFFFB], 0x110BD, [0x1BCA0, 0x1BCA3], [0x1D173, 0x1D17A], [0xE0000, 0xE00FF], [0xE01F0, 0xE0FFF]],
	Extend: [[0x0300, 0x036F], [0x0483, 0x0489], [0x0591, 0x05BD], 0x05BF, 0x05C1, 0x05C2, 0x05C4, 0x05C5, 0x05C7, [0x0610, 0x061A], [0x064B, 0x065F], 0x0670, [0x06D6, 0x06DC], [0x06DF, 0x06E4], 0x06E7, 0x06E8, [0x06EA, 0x06ED], 0x0711, [0x0730, 0x074A], [0x07A6, 0x07B0], [0x07EB, 0x07F3], [0x0816, 0x0819], [0x081B, 0x0823], [0x0825, 0x0827], [0x0829, 0x082D], [0x0859, 0x085B], [0x08E4, 0x0902], 0x093A, 0x093C, [0x0941, 0x0948], 0x094D, [0x0951, 0x0957], 0x0962, 0x0963, 0x0981, 0x09BC, 0x09BE, [0x09C1, 0x09C4], 0x09CD, 0x09D7, 0x09E2, 0x09E3, 0x0A01, 0x0A02, 0x0A3C, 0x0A41, 0x0A42, 0x0A47, 0x0A48, [0x0A4B, 0x0A4D], 0x0A51, 0x0A70, 0x0A71, 0x0A75, 0x0A81, 0x0A82, 0x0ABC, [0x0AC1, 0x0AC5], 0x0AC7, 0x0AC8, 0x0ACD, 0x0AE2, 0x0AE3, 0x0B01, 0x0B3C, 0x0B3E, 0x0B3F, [0x0B41, 0x0B44], 0x0B4D, 0x0B56, 0x0B57, 0x0B62, 0x0B63, 0x0B82, 0x0BBE, 0x0BC0, 0x0BCD, 0x0BD7, 0x0C00, [0x0C3E, 0x0C40], [0x0C46, 0x0C48], [0x0C4A, 0x0C4D], 0x0C55, 0x0C56, 0x0C62, 0x0C63, 0x0C81, 0x0CBC, 0x0CBF, 0x0CC2, 0x0CC6, 0x0CCC, 0x0CCD, 0x0CD5, 0x0CD6, 0x0CE2, 0x0CE3, 0x0D01, 0x0D3E, [0x0D41, 0x0D44], 0x0D4D, 0x0D57, 0x0D62, 0x0D63, 0x0DCA, 0x0DCF, [0x0DD2, 0x0DD4], 0x0DD6, 0x0DDF, 0x0E31, [0x0E34, 0x0E3A], [0x0E47, 0x0E4E], 0x0EB1, [0x0EB4, 0x0EB9], 0x0EBB, 0x0EBC, [0x0EC8, 0x0ECD], 0x0F18, 0x0F19, 0x0F35, 0x0F37, 0x0F39, [0x0F71, 0x0F7E], [0x0F80, 0x0F84], 0x0F86, 0x0F87, [0x0F8D, 0x0F97], [0x0F99, 0x0FBC], 0x0FC6, [0x102D, 0x1030], [0x1032, 0x1037], 0x1039, 0x103A, 0x103D, 0x103E, 0x1058, 0x1059, [0x105E, 0x1060], [0x1071, 0x1074], 0x1082, 0x1085, 0x1086, 0x108D, 0x109D, [0x135D, 0x135F], [0x1712, 0x1714], [0x1732, 0x1734], 0x1752, 0x1753, 0x1772, 0x1773, 0x17B4, 0x17B5, [0x17B7, 0x17BD], 0x17C6, [0x17C9, 0x17D3], 0x17DD, [0x180B, 0x180D], 0x18A9, [0x1920, 0x1922], 0x1927, 0x1928, 0x1932, [0x1939, 0x193B], 0x1A17, 0x1A18, 0x1A1B, 0x1A56, [0x1A58, 0x1A5E], 0x1A60, 0x1A62, [0x1A65, 0x1A6C], [0x1A73, 0x1A7C], 0x1A7F, [0x1AB0, 0x1ABE], [0x1B00, 0x1B03], 0x1B34, [0x1B36, 0x1B3A], 0x1B3C, 0x1B42, [0x1B6B, 0x1B73], 0x1B80, 0x1B81, [0x1BA2, 0x1BA5], 0x1BA8, 0x1BA9, [0x1BAB, 0x1BAD], 0x1BE6, 0x1BE8, 0x1BE9, 0x1BED, [0x1BEF, 0x1BF1], [0x1C2C, 0x1C33], 0x1C36, 0x1C37, [0x1CD0, 0x1CD2], [0x1CD4, 0x1CE0], [0x1CE2, 0x1CE8], 0x1CED, 0x1CF4, 0x1CF8, 0x1CF9, [0x1DC0, 0x1DF5], [0x1DFC, 0x1DFF], 0x200C, 0x200D, [0x20D0, 0x20F0], [0x2CEF, 0x2CF1], 0x2D7F, [0x2DE0, 0x2DFF], [0x302A, 0x302F], 0x3099, 0x309A, [0xA66F, 0xA672], [0xA674, 0xA67D], 0xA69F, 0xA6F0, 0xA6F1, 0xA802, 0xA806, 0xA80B, 0xA825, 0xA826, 0xA8C4, [0xA8E0, 0xA8F1], [0xA926, 0xA92D], [0xA947, 0xA951], [0xA980, 0xA982], 0xA9B3, [0xA9B6, 0xA9B9], 0xA9BC, 0xA9E5, [0xAA29, 0xAA2E], 0xAA31, 0xAA32, 0xAA35, 0xAA36, 0xAA43, 0xAA4C, 0xAA7C, 0xAAB0, [0xAAB2, 0xAAB4], 0xAAB7, 0xAAB8, 0xAABE, 0xAABF, 0xAAC1, 0xAAEC, 0xAAED, 0xAAF6, 0xABE5, 0xABE8, 0xABED, 0xFB1E, [0xFE00, 0xFE0F], [0xFE20, 0xFE2D], 0xFF9E, 0xFF9F, 0x101FD, 0x102E0, [0x10376, 0x1037A], [0x10A01, 0x10A03], 0x10A05, 0x10A06, [0x10A0C, 0x10A0F], [0x10A38, 0x10A3A], 0x10A3F, 0x10AE5, 0x10AE6, 0x11001, [0x11038, 0x11046], [0x1107F, 0x11081], [0x110B3, 0x110B6], 0x110B9, 0x110BA, [0x11100, 0x11102], [0x11127, 0x1112B], [0x1112D, 0x11134], 0x11173, 0x11180, 0x11181, [0x111B6, 0x111BE], [0x1122F, 0x11231], 0x11234, 0x11236, 0x11237, 0x112DF, [0x112E3, 0x112EA], 0x11301, 0x1133C, 0x1133E, 0x11340, 0x11357, [0x11366, 0x1136C], [0x11370, 0x11374], 0x114B0, [0x114B3, 0x114B8], 0x114BA, 0x114BD, 0x114BF, 0x114C0, 0x114C2, 0x114C3, 0x115AF, [0x115B2, 0x115B5], 0x115BC, 0x115BD, 0x115BF, 0x115C0, [0x11633, 0x1163A], 0x1163D, 0x1163F, 0x11640, 0x116AB, 0x116AD, [0x116B0, 0x116B5], 0x116B7, [0x16AF0, 0x16AF4], [0x16B30, 0x16B36], [0x16F8F, 0x16F92], 0x1BC9D, 0x1BC9E, 0x1D165, [0x1D167, 0x1D169], [0x1D16E, 0x1D172], [0x1D17B, 0x1D182], [0x1D185, 0x1D18B], [0x1D1AA, 0x1D1AD], [0x1D242, 0x1D244], [0x1E8D0, 0x1E8D6], [0xE0100, 0xE01EF]],
	RegionalIndicator: [[0x1F1E6, 0x1F1FF]],
	SpacingMark: [0x0903, 0x093B, [0x093E, 0x0940], [0x0949, 0x094C], 0x094E, 0x094F, 0x0982, 0x0983, 0x09BF, 0x09C0, 0x09C7, 0x09C8, 0x09CB, 0x09CC, 0x0A03, [0x0A3E, 0x0A40], 0x0A83, [0x0ABE, 0x0AC0], 0x0AC9, 0x0ACB, 0x0ACC, 0x0B02, 0x0B03, 0x0B40, 0x0B47, 0x0B48, 0x0B4B, 0x0B4C, 0x0BBF, 0x0BC1, 0x0BC2, [0x0BC6, 0x0BC8], [0x0BCA, 0x0BCC], [0x0C01, 0x0C03], [0x0C41, 0x0C44], 0x0C82, 0x0C83, 0x0CBE, 0x0CC0, 0x0CC1, 0x0CC3, 0x0CC4, 0x0CC7, 0x0CC8, 0x0CCA, 0x0CCB, 0x0D02, 0x0D03, 0x0D3F, 0x0D40, [0x0D46, 0x0D48], [0x0D4A, 0x0D4C], 0x0D82, 0x0D83, 0x0DD0, 0x0DD1, [0x0DD8, 0x0DDE], 0x0DF2, 0x0DF3, 0x0E33, 0x0EB3, 0x0F3E, 0x0F3F, 0x0F7F, 0x1031, 0x103B, 0x103C, 0x1056, 0x1057, 0x1084, 0x17B6, [0x17BE, 0x17C5], 0x17C7, 0x17C8, [0x1923, 0x1926], [0x1929, 0x192B], 0x1930, 0x1931, [0x1933, 0x1938], [0x19B5, 0x19B7], 0x19BA, 0x1A19, 0x1A1A, 0x1A55, 0x1A57, [0x1A6D, 0x1A72], 0x1B04, 0x1B35, 0x1B3B, [0x1B3D, 0x1B41], 0x1B43, 0x1B44, 0x1B82, 0x1BA1, 0x1BA6, 0x1BA7, 0x1BAA, 0x1BE7, [0x1BEA, 0x1BEC], 0x1BEE, 0x1BF2, 0x1BF3, [0x1C24, 0x1C2B], 0x1C34, 0x1C35, 0x1CE1, 0x1CF2, 0x1CF3, 0xA823, 0xA824, 0xA827, 0xA880, 0xA881, [0xA8B4, 0xA8C3], 0xA952, 0xA953, 0xA983, 0xA9B4, 0xA9B5, 0xA9BA, 0xA9BB, [0xA9BD, 0xA9C0], 0xAA2F, 0xAA30, 0xAA33, 0xAA34, 0xAA4D, 0xAAEB, 0xAAEE, 0xAAEF, 0xAAF5, 0xABE3, 0xABE4, 0xABE6, 0xABE7, 0xABE9, 0xABEA, 0xABEC, 0x11000, 0x11002, 0x11082, [0x110B0, 0x110B2], 0x110B7, 0x110B8, 0x1112C, 0x11182, [0x111B3, 0x111B5], 0x111BF, 0x111C0, [0x1122C, 0x1122E], 0x11232, 0x11233, 0x11235, [0x112E0, 0x112E2], 0x11302, 0x11303, 0x1133F, [0x11341, 0x11344], 0x11347, 0x11348, [0x1134B, 0x1134D], 0x11362, 0x11363, 0x114B1, 0x114B2, 0x114B9, 0x114BB, 0x114BC, 0x114BE, 0x114C1, 0x115B0, 0x115B1, [0x115B8, 0x115BB], 0x115BE, [0x11630, 0x11632], 0x1163B, 0x1163C, 0x1163E, 0x116AC, 0x116AE, 0x116AF, 0x116B6, [0x16F51, 0x16F7E], 0x1D166, 0x1D16D],
	L: [[0x1100, 0x115F], [0xA960, 0xA97C]],
	V: [[0x1160, 0x11A7], [0xD7B0, 0xD7C6]],
	T: [[0x11A8, 0x11FF], [0xD7CB, 0xD7FB]],
	LV: [0xAC00, 0xAC1C, 0xAC38, 0xAC54, 0xAC70, 0xAC8C, 0xACA8, 0xACC4, 0xACE0, 0xACFC, 0xAD18, 0xAD34, 0xAD50, 0xAD6C, 0xAD88, 0xADA4, 0xADC0, 0xADDC, 0xADF8, 0xAE14, 0xAE30, 0xAE4C, 0xAE68, 0xAE84, 0xAEA0, 0xAEBC, 0xAED8, 0xAEF4, 0xAF10, 0xAF2C, 0xAF48, 0xAF64, 0xAF80, 0xAF9C, 0xAFB8, 0xAFD4, 0xAFF0, 0xB00C, 0xB028, 0xB044, 0xB060, 0xB07C, 0xB098, 0xB0B4, 0xB0D0, 0xB0EC, 0xB108, 0xB124, 0xB140, 0xB15C, 0xB178, 0xB194, 0xB1B0, 0xB1CC, 0xB1E8, 0xB204, 0xB220, 0xB23C, 0xB258, 0xB274, 0xB290, 0xB2AC, 0xB2C8, 0xB2E4, 0xB300, 0xB31C, 0xB338, 0xB354, 0xB370, 0xB38C, 0xB3A8, 0xB3C4, 0xB3E0, 0xB3FC, 0xB418, 0xB434, 0xB450, 0xB46C, 0xB488, 0xB4A4, 0xB4C0, 0xB4DC, 0xB4F8, 0xB514, 0xB530, 0xB54C, 0xB568, 0xB584, 0xB5A0, 0xB5BC, 0xB5D8, 0xB5F4, 0xB610, 0xB62C, 0xB648, 0xB664, 0xB680, 0xB69C, 0xB6B8, 0xB6D4, 0xB6F0, 0xB70C, 0xB728, 0xB744, 0xB760, 0xB77C, 0xB798, 0xB7B4, 0xB7D0, 0xB7EC, 0xB808, 0xB824, 0xB840, 0xB85C, 0xB878, 0xB894, 0xB8B0, 0xB8CC, 0xB8E8, 0xB904, 0xB920, 0xB93C, 0xB958, 0xB974, 0xB990, 0xB9AC, 0xB9C8, 0xB9E4, 0xBA00, 0xBA1C, 0xBA38, 0xBA54, 0xBA70, 0xBA8C, 0xBAA8, 0xBAC4, 0xBAE0, 0xBAFC, 0xBB18, 0xBB34, 0xBB50, 0xBB6C, 0xBB88, 0xBBA4, 0xBBC0, 0xBBDC, 0xBBF8, 0xBC14, 0xBC30, 0xBC4C, 0xBC68, 0xBC84, 0xBCA0, 0xBCBC, 0xBCD8, 0xBCF4, 0xBD10, 0xBD2C, 0xBD48, 0xBD64, 0xBD80, 0xBD9C, 0xBDB8, 0xBDD4, 0xBDF0, 0xBE0C, 0xBE28, 0xBE44, 0xBE60, 0xBE7C, 0xBE98, 0xBEB4, 0xBED0, 0xBEEC, 0xBF08, 0xBF24, 0xBF40, 0xBF5C, 0xBF78, 0xBF94, 0xBFB0, 0xBFCC, 0xBFE8, 0xC004, 0xC020, 0xC03C, 0xC058, 0xC074, 0xC090, 0xC0AC, 0xC0C8, 0xC0E4, 0xC100, 0xC11C, 0xC138, 0xC154, 0xC170, 0xC18C, 0xC1A8, 0xC1C4, 0xC1E0, 0xC1FC, 0xC218, 0xC234, 0xC250, 0xC26C, 0xC288, 0xC2A4, 0xC2C0, 0xC2DC, 0xC2F8, 0xC314, 0xC330, 0xC34C, 0xC368, 0xC384, 0xC3A0, 0xC3BC, 0xC3D8, 0xC3F4, 0xC410, 0xC42C, 0xC448, 0xC464, 0xC480, 0xC49C, 0xC4B8, 0xC4D4, 0xC4F0, 0xC50C, 0xC528, 0xC544, 0xC560, 0xC57C, 0xC598, 0xC5B4, 0xC5D0, 0xC5EC, 0xC608, 0xC624, 0xC640, 0xC65C, 0xC678, 0xC694, 0xC6B0, 0xC6CC, 0xC6E8, 0xC704, 0xC720, 0xC73C, 0xC758, 0xC774, 0xC790, 0xC7AC, 0xC7C8, 0xC7E4, 0xC800, 0xC81C, 0xC838, 0xC854, 0xC870, 0xC88C, 0xC8A8, 0xC8C4, 0xC8E0, 0xC8FC, 0xC918, 0xC934, 0xC950, 0xC96C, 0xC988, 0xC9A4, 0xC9C0, 0xC9DC, 0xC9F8, 0xCA14, 0xCA30, 0xCA4C, 0xCA68, 0xCA84, 0xCAA0, 0xCABC, 0xCAD8, 0xCAF4, 0xCB10, 0xCB2C, 0xCB48, 0xCB64, 0xCB80, 0xCB9C, 0xCBB8, 0xCBD4, 0xCBF0, 0xCC0C, 0xCC28, 0xCC44, 0xCC60, 0xCC7C, 0xCC98, 0xCCB4, 0xCCD0, 0xCCEC, 0xCD08, 0xCD24, 0xCD40, 0xCD5C, 0xCD78, 0xCD94, 0xCDB0, 0xCDCC, 0xCDE8, 0xCE04, 0xCE20, 0xCE3C, 0xCE58, 0xCE74, 0xCE90, 0xCEAC, 0xCEC8, 0xCEE4, 0xCF00, 0xCF1C, 0xCF38, 0xCF54, 0xCF70, 0xCF8C, 0xCFA8, 0xCFC4, 0xCFE0, 0xCFFC, 0xD018, 0xD034, 0xD050, 0xD06C, 0xD088, 0xD0A4, 0xD0C0, 0xD0DC, 0xD0F8, 0xD114, 0xD130, 0xD14C, 0xD168, 0xD184, 0xD1A0, 0xD1BC, 0xD1D8, 0xD1F4, 0xD210, 0xD22C, 0xD248, 0xD264, 0xD280, 0xD29C, 0xD2B8, 0xD2D4, 0xD2F0, 0xD30C, 0xD328, 0xD344, 0xD360, 0xD37C, 0xD398, 0xD3B4, 0xD3D0, 0xD3EC, 0xD408, 0xD424, 0xD440, 0xD45C, 0xD478, 0xD494, 0xD4B0, 0xD4CC, 0xD4E8, 0xD504, 0xD520, 0xD53C, 0xD558, 0xD574, 0xD590, 0xD5AC, 0xD5C8, 0xD5E4, 0xD600, 0xD61C, 0xD638, 0xD654, 0xD670, 0xD68C, 0xD6A8, 0xD6C4, 0xD6E0, 0xD6FC, 0xD718, 0xD734, 0xD750, 0xD76C, 0xD788],
	LVT: [[0xAC01, 0xAC1B], [0xAC1D, 0xAC37], [0xAC39, 0xAC53], [0xAC55, 0xAC6F], [0xAC71, 0xAC8B], [0xAC8D, 0xACA7], [0xACA9, 0xACC3], [0xACC5, 0xACDF], [0xACE1, 0xACFB], [0xACFD, 0xAD17], [0xAD19, 0xAD33], [0xAD35, 0xAD4F], [0xAD51, 0xAD6B], [0xAD6D, 0xAD87], [0xAD89, 0xADA3], [0xADA5, 0xADBF], [0xADC1, 0xADDB], [0xADDD, 0xADF7], [0xADF9, 0xAE13], [0xAE15, 0xAE2F], [0xAE31, 0xAE4B], [0xAE4D, 0xAE67], [0xAE69, 0xAE83], [0xAE85, 0xAE9F], [0xAEA1, 0xAEBB], [0xAEBD, 0xAED7], [0xAED9, 0xAEF3], [0xAEF5, 0xAF0F], [0xAF11, 0xAF2B], [0xAF2D, 0xAF47], [0xAF49, 0xAF63], [0xAF65, 0xAF7F], [0xAF81, 0xAF9B], [0xAF9D, 0xAFB7], [0xAFB9, 0xAFD3], [0xAFD5, 0xAFEF], [0xAFF1, 0xB00B], [0xB00D, 0xB027], [0xB029, 0xB043], [0xB045, 0xB05F], [0xB061, 0xB07B], [0xB07D, 0xB097], [0xB099, 0xB0B3], [0xB0B5, 0xB0CF], [0xB0D1, 0xB0EB], [0xB0ED, 0xB107], [0xB109, 0xB123], [0xB125, 0xB13F], [0xB141, 0xB15B], [0xB15D, 0xB177], [0xB179, 0xB193], [0xB195, 0xB1AF], [0xB1B1, 0xB1CB], [0xB1CD, 0xB1E7], [0xB1E9, 0xB203], [0xB205, 0xB21F], [0xB221, 0xB23B], [0xB23D, 0xB257], [0xB259, 0xB273], [0xB275, 0xB28F], [0xB291, 0xB2AB], [0xB2AD, 0xB2C7], [0xB2C9, 0xB2E3], [0xB2E5, 0xB2FF], [0xB301, 0xB31B], [0xB31D, 0xB337], [0xB339, 0xB353], [0xB355, 0xB36F], [0xB371, 0xB38B], [0xB38D, 0xB3A7], [0xB3A9, 0xB3C3], [0xB3C5, 0xB3DF], [0xB3E1, 0xB3FB], [0xB3FD, 0xB417], [0xB419, 0xB433], [0xB435, 0xB44F], [0xB451, 0xB46B], [0xB46D, 0xB487], [0xB489, 0xB4A3], [0xB4A5, 0xB4BF], [0xB4C1, 0xB4DB], [0xB4DD, 0xB4F7], [0xB4F9, 0xB513], [0xB515, 0xB52F], [0xB531, 0xB54B], [0xB54D, 0xB567], [0xB569, 0xB583], [0xB585, 0xB59F], [0xB5A1, 0xB5BB], [0xB5BD, 0xB5D7], [0xB5D9, 0xB5F3], [0xB5F5, 0xB60F], [0xB611, 0xB62B], [0xB62D, 0xB647], [0xB649, 0xB663], [0xB665, 0xB67F], [0xB681, 0xB69B], [0xB69D, 0xB6B7], [0xB6B9, 0xB6D3], [0xB6D5, 0xB6EF], [0xB6F1, 0xB70B], [0xB70D, 0xB727], [0xB729, 0xB743], [0xB745, 0xB75F], [0xB761, 0xB77B], [0xB77D, 0xB797], [0xB799, 0xB7B3], [0xB7B5, 0xB7CF], [0xB7D1, 0xB7EB], [0xB7ED, 0xB807], [0xB809, 0xB823], [0xB825, 0xB83F], [0xB841, 0xB85B], [0xB85D, 0xB877], [0xB879, 0xB893], [0xB895, 0xB8AF], [0xB8B1, 0xB8CB], [0xB8CD, 0xB8E7], [0xB8E9, 0xB903], [0xB905, 0xB91F], [0xB921, 0xB93B], [0xB93D, 0xB957], [0xB959, 0xB973], [0xB975, 0xB98F], [0xB991, 0xB9AB], [0xB9AD, 0xB9C7], [0xB9C9, 0xB9E3], [0xB9E5, 0xB9FF], [0xBA01, 0xBA1B], [0xBA1D, 0xBA37], [0xBA39, 0xBA53], [0xBA55, 0xBA6F], [0xBA71, 0xBA8B], [0xBA8D, 0xBAA7], [0xBAA9, 0xBAC3], [0xBAC5, 0xBADF], [0xBAE1, 0xBAFB], [0xBAFD, 0xBB17], [0xBB19, 0xBB33], [0xBB35, 0xBB4F], [0xBB51, 0xBB6B], [0xBB6D, 0xBB87], [0xBB89, 0xBBA3], [0xBBA5, 0xBBBF], [0xBBC1, 0xBBDB], [0xBBDD, 0xBBF7], [0xBBF9, 0xBC13], [0xBC15, 0xBC2F], [0xBC31, 0xBC4B], [0xBC4D, 0xBC67], [0xBC69, 0xBC83], [0xBC85, 0xBC9F], [0xBCA1, 0xBCBB], [0xBCBD, 0xBCD7], [0xBCD9, 0xBCF3], [0xBCF5, 0xBD0F], [0xBD11, 0xBD2B], [0xBD2D, 0xBD47], [0xBD49, 0xBD63], [0xBD65, 0xBD7F], [0xBD81, 0xBD9B], [0xBD9D, 0xBDB7], [0xBDB9, 0xBDD3], [0xBDD5, 0xBDEF], [0xBDF1, 0xBE0B], [0xBE0D, 0xBE27], [0xBE29, 0xBE43], [0xBE45, 0xBE5F], [0xBE61, 0xBE7B], [0xBE7D, 0xBE97], [0xBE99, 0xBEB3], [0xBEB5, 0xBECF], [0xBED1, 0xBEEB], [0xBEED, 0xBF07], [0xBF09, 0xBF23], [0xBF25, 0xBF3F], [0xBF41, 0xBF5B], [0xBF5D, 0xBF77], [0xBF79, 0xBF93], [0xBF95, 0xBFAF], [0xBFB1, 0xBFCB], [0xBFCD, 0xBFE7], [0xBFE9, 0xC003], [0xC005, 0xC01F], [0xC021, 0xC03B], [0xC03D, 0xC057], [0xC059, 0xC073], [0xC075, 0xC08F], [0xC091, 0xC0AB], [0xC0AD, 0xC0C7], [0xC0C9, 0xC0E3], [0xC0E5, 0xC0FF], [0xC101, 0xC11B], [0xC11D, 0xC137], [0xC139, 0xC153], [0xC155, 0xC16F], [0xC171, 0xC18B], [0xC18D, 0xC1A7], [0xC1A9, 0xC1C3], [0xC1C5, 0xC1DF], [0xC1E1, 0xC1FB], [0xC1FD, 0xC217], [0xC219, 0xC233], [0xC235, 0xC24F], [0xC251, 0xC26B], [0xC26D, 0xC287], [0xC289, 0xC2A3], [0xC2A5, 0xC2BF], [0xC2C1, 0xC2DB], [0xC2DD, 0xC2F7], [0xC2F9, 0xC313], [0xC315, 0xC32F], [0xC331, 0xC34B], [0xC34D, 0xC367], [0xC369, 0xC383], [0xC385, 0xC39F], [0xC3A1, 0xC3BB], [0xC3BD, 0xC3D7], [0xC3D9, 0xC3F3], [0xC3F5, 0xC40F], [0xC411, 0xC42B], [0xC42D, 0xC447], [0xC449, 0xC463], [0xC465, 0xC47F], [0xC481, 0xC49B], [0xC49D, 0xC4B7], [0xC4B9, 0xC4D3], [0xC4D5, 0xC4EF], [0xC4F1, 0xC50B], [0xC50D, 0xC527], [0xC529, 0xC543], [0xC545, 0xC55F], [0xC561, 0xC57B], [0xC57D, 0xC597], [0xC599, 0xC5B3], [0xC5B5, 0xC5CF], [0xC5D1, 0xC5EB], [0xC5ED, 0xC607], [0xC609, 0xC623], [0xC625, 0xC63F], [0xC641, 0xC65B], [0xC65D, 0xC677], [0xC679, 0xC693], [0xC695, 0xC6AF], [0xC6B1, 0xC6CB], [0xC6CD, 0xC6E7], [0xC6E9, 0xC703], [0xC705, 0xC71F], [0xC721, 0xC73B], [0xC73D, 0xC757], [0xC759, 0xC773], [0xC775, 0xC78F], [0xC791, 0xC7AB], [0xC7AD, 0xC7C7], [0xC7C9, 0xC7E3], [0xC7E5, 0xC7FF], [0xC801, 0xC81B], [0xC81D, 0xC837], [0xC839, 0xC853], [0xC855, 0xC86F], [0xC871, 0xC88B], [0xC88D, 0xC8A7], [0xC8A9, 0xC8C3], [0xC8C5, 0xC8DF], [0xC8E1, 0xC8FB], [0xC8FD, 0xC917], [0xC919, 0xC933], [0xC935, 0xC94F], [0xC951, 0xC96B], [0xC96D, 0xC987], [0xC989, 0xC9A3], [0xC9A5, 0xC9BF], [0xC9C1, 0xC9DB], [0xC9DD, 0xC9F7], [0xC9F9, 0xCA13], [0xCA15, 0xCA2F], [0xCA31, 0xCA4B], [0xCA4D, 0xCA67], [0xCA69, 0xCA83], [0xCA85, 0xCA9F], [0xCAA1, 0xCABB], [0xCABD, 0xCAD7], [0xCAD9, 0xCAF3], [0xCAF5, 0xCB0F], [0xCB11, 0xCB2B], [0xCB2D, 0xCB47], [0xCB49, 0xCB63], [0xCB65, 0xCB7F], [0xCB81, 0xCB9B], [0xCB9D, 0xCBB7], [0xCBB9, 0xCBD3], [0xCBD5, 0xCBEF], [0xCBF1, 0xCC0B], [0xCC0D, 0xCC27], [0xCC29, 0xCC43], [0xCC45, 0xCC5F], [0xCC61, 0xCC7B], [0xCC7D, 0xCC97], [0xCC99, 0xCCB3], [0xCCB5, 0xCCCF], [0xCCD1, 0xCCEB], [0xCCED, 0xCD07], [0xCD09, 0xCD23], [0xCD25, 0xCD3F], [0xCD41, 0xCD5B], [0xCD5D, 0xCD77], [0xCD79, 0xCD93], [0xCD95, 0xCDAF], [0xCDB1, 0xCDCB], [0xCDCD, 0xCDE7], [0xCDE9, 0xCE03], [0xCE05, 0xCE1F], [0xCE21, 0xCE3B], [0xCE3D, 0xCE57], [0xCE59, 0xCE73], [0xCE75, 0xCE8F], [0xCE91, 0xCEAB], [0xCEAD, 0xCEC7], [0xCEC9, 0xCEE3], [0xCEE5, 0xCEFF], [0xCF01, 0xCF1B], [0xCF1D, 0xCF37], [0xCF39, 0xCF53], [0xCF55, 0xCF6F], [0xCF71, 0xCF8B], [0xCF8D, 0xCFA7], [0xCFA9, 0xCFC3], [0xCFC5, 0xCFDF], [0xCFE1, 0xCFFB], [0xCFFD, 0xD017], [0xD019, 0xD033], [0xD035, 0xD04F], [0xD051, 0xD06B], [0xD06D, 0xD087], [0xD089, 0xD0A3], [0xD0A5, 0xD0BF], [0xD0C1, 0xD0DB], [0xD0DD, 0xD0F7], [0xD0F9, 0xD113], [0xD115, 0xD12F], [0xD131, 0xD14B], [0xD14D, 0xD167], [0xD169, 0xD183], [0xD185, 0xD19F], [0xD1A1, 0xD1BB], [0xD1BD, 0xD1D7], [0xD1D9, 0xD1F3], [0xD1F5, 0xD20F], [0xD211, 0xD22B], [0xD22D, 0xD247], [0xD249, 0xD263], [0xD265, 0xD27F], [0xD281, 0xD29B], [0xD29D, 0xD2B7], [0xD2B9, 0xD2D3], [0xD2D5, 0xD2EF], [0xD2F1, 0xD30B], [0xD30D, 0xD327], [0xD329, 0xD343], [0xD345, 0xD35F], [0xD361, 0xD37B], [0xD37D, 0xD397], [0xD399, 0xD3B3], [0xD3B5, 0xD3CF], [0xD3D1, 0xD3EB], [0xD3ED, 0xD407], [0xD409, 0xD423], [0xD425, 0xD43F], [0xD441, 0xD45B], [0xD45D, 0xD477], [0xD479, 0xD493], [0xD495, 0xD4AF], [0xD4B1, 0xD4CB], [0xD4CD, 0xD4E7], [0xD4E9, 0xD503], [0xD505, 0xD51F], [0xD521, 0xD53B], [0xD53D, 0xD557], [0xD559, 0xD573], [0xD575, 0xD58F], [0xD591, 0xD5AB], [0xD5AD, 0xD5C7], [0xD5C9, 0xD5E3], [0xD5E5, 0xD5FF], [0xD601, 0xD61B], [0xD61D, 0xD637], [0xD639, 0xD653], [0xD655, 0xD66F], [0xD671, 0xD68B], [0xD68D, 0xD6A7], [0xD6A9, 0xD6C3], [0xD6C5, 0xD6DF], [0xD6E1, 0xD6FB], [0xD6FD, 0xD717], [0xD719, 0xD733], [0xD735, 0xD74F], [0xD751, 0xD76B], [0xD76D, 0xD787], [0xD789, 0xD7A3]]
};

/*!
 * UnicodeJS Grapheme Break module
 *
 * Implementation of Unicode 7.0.0 Default Grapheme Cluster Boundary Specification
 * http://www.unicode.org/reports/tr29/#Default_Grapheme_Cluster_Table
 *
 * @copyright 2013–2015 UnicodeJS team and others; see AUTHORS.txt
 * @license The MIT License (MIT); see LICENSE.txt
 */
( function () {
	var property, disjunction, graphemeBreakRegexp,
		properties = unicodeJS.graphemebreakproperties,
		// Single unicode character (either a UTF-16 code unit or a surrogate pair)
		oneCharacter = '[^\\ud800-\\udfff]|[\\ud800-\\udbff][\\udc00-\\udfff]',
		/**
		 * @class unicodeJS.graphemebreak
		 * @singleton
		 */
		graphemebreak = unicodeJS.graphemebreak = {},
		patterns = {};

	// build regexes
	for ( property in properties ) {
		patterns[property] = unicodeJS.charRangeArrayRegexp( properties[property] );
	}

	// build disjunction for grapheme cluster split
	// See http://www.unicode.org/reports/tr29/ at "Grapheme Cluster Boundary Rules"
	disjunction = [
		// Break at the start and end of text.
		// GB1: sot ÷
		// GB2: ÷ eot
		// GB1 and GB2 are trivially satisfied

		// Do not break between a CR and LF. Otherwise, break before and after controls.
		// GB3: CR × LF
		'\\r\\n',

		// GB4: ( Control | CR | LF ) ÷
		// GB5: ÷ ( Control | CR | LF )
		patterns.Control,

		// Do not break Hangul syllable sequences.
		// GB6: L × ( L | V | LV | LVT )
		// GB7: ( LV | V ) × ( V | T )
		// GB8: ( LVT | T ) × T
		'(?:' + patterns.L + ')*' +
		'(?:' + patterns.V + ')+' +
		'(?:' + patterns.T + ')*',

		'(?:' + patterns.L + ')*' +
		'(?:' + patterns.LV + ')' +
		'(?:' + patterns.V + ')*' +
		'(?:' + patterns.T + ')*',

		'(?:' + patterns.L + ')*' +
		'(?:' + patterns.LVT + ')' +
		'(?:' + patterns.T + ')*',

		'(?:' + patterns.L + ')+',

		'(?:' + patterns.T + ')+',

		// Do not break between regional indicator symbols.
		// GB8a: Regional_Indicator × Regional_Indicator
		'(?:' + patterns.RegionalIndicator + ')+',

		// Do not break before extending characters.
		// GB9: × Extend

		// Only for extended grapheme clusters:
		// Do not break before SpacingMarks, or after Prepend characters.
		// GB9a: × SpacingMark
		// GB9b: Prepend ×
		// As of Unicode 7.0.0, no characters are "Prepend"
		// TODO: this will break if the extended thing is not oneCharacter
		// e.g. hangul jamo L+V+T. Does it matter?
		'(?:' + oneCharacter + ')' +
		'(?:' + patterns.Extend + '|' +
		patterns.SpacingMark + ')+',

		// Otherwise, break everywhere.
		// GB10: Any ÷ Any
		// Taking care not to split surrogates
		oneCharacter
	];
	graphemeBreakRegexp = new RegExp( '(' + disjunction.join( '|' ) + ')' );

	/**
	 * Split a string into grapheme clusters.
	 *
	 * @param {string} text Text to split
	 * @return {string[]} Array of clusters
	 */
	graphemebreak.splitClusters = function ( text ) {
		var i, parts, length, clusters = [];
		parts = text.split( graphemeBreakRegexp );
		for ( i = 0, length = parts.length; i < length; i++ ) {
			if ( parts[i] !== '' ) {
				clusters.push( parts[i] );
			}
		}
		return clusters;
	};
}() );

// This file is GENERATED by tools/unicodejs-properties.py
// DO NOT EDIT
unicodeJS.wordbreakproperties = {
	DoubleQuote: [0x0022],
	SingleQuote: [0x0027],
	HebrewLetter: [[0x05D0, 0x05EA], [0x05F0, 0x05F2], 0xFB1D, [0xFB1F, 0xFB28], [0xFB2A, 0xFB36], [0xFB38, 0xFB3C], 0xFB3E, 0xFB40, 0xFB41, 0xFB43, 0xFB44, [0xFB46, 0xFB4F]],
	CR: [0x000D],
	LF: [0x000A],
	Newline: [0x000B, 0x000C, 0x0085, 0x2028, 0x2029],
	Extend: [[0x0300, 0x036F], [0x0483, 0x0489], [0x0591, 0x05BD], 0x05BF, 0x05C1, 0x05C2, 0x05C4, 0x05C5, 0x05C7, [0x0610, 0x061A], [0x064B, 0x065F], 0x0670, [0x06D6, 0x06DC], [0x06DF, 0x06E4], 0x06E7, 0x06E8, [0x06EA, 0x06ED], 0x0711, [0x0730, 0x074A], [0x07A6, 0x07B0], [0x07EB, 0x07F3], [0x0816, 0x0819], [0x081B, 0x0823], [0x0825, 0x0827], [0x0829, 0x082D], [0x0859, 0x085B], [0x08E4, 0x0903], [0x093A, 0x093C], [0x093E, 0x094F], [0x0951, 0x0957], 0x0962, 0x0963, [0x0981, 0x0983], 0x09BC, [0x09BE, 0x09C4], 0x09C7, 0x09C8, [0x09CB, 0x09CD], 0x09D7, 0x09E2, 0x09E3, [0x0A01, 0x0A03], 0x0A3C, [0x0A3E, 0x0A42], 0x0A47, 0x0A48, [0x0A4B, 0x0A4D], 0x0A51, 0x0A70, 0x0A71, 0x0A75, [0x0A81, 0x0A83], 0x0ABC, [0x0ABE, 0x0AC5], [0x0AC7, 0x0AC9], [0x0ACB, 0x0ACD], 0x0AE2, 0x0AE3, [0x0B01, 0x0B03], 0x0B3C, [0x0B3E, 0x0B44], 0x0B47, 0x0B48, [0x0B4B, 0x0B4D], 0x0B56, 0x0B57, 0x0B62, 0x0B63, 0x0B82, [0x0BBE, 0x0BC2], [0x0BC6, 0x0BC8], [0x0BCA, 0x0BCD], 0x0BD7, [0x0C00, 0x0C03], [0x0C3E, 0x0C44], [0x0C46, 0x0C48], [0x0C4A, 0x0C4D], 0x0C55, 0x0C56, 0x0C62, 0x0C63, [0x0C81, 0x0C83], 0x0CBC, [0x0CBE, 0x0CC4], [0x0CC6, 0x0CC8], [0x0CCA, 0x0CCD], 0x0CD5, 0x0CD6, 0x0CE2, 0x0CE3, [0x0D01, 0x0D03], [0x0D3E, 0x0D44], [0x0D46, 0x0D48], [0x0D4A, 0x0D4D], 0x0D57, 0x0D62, 0x0D63, 0x0D82, 0x0D83, 0x0DCA, [0x0DCF, 0x0DD4], 0x0DD6, [0x0DD8, 0x0DDF], 0x0DF2, 0x0DF3, 0x0E31, [0x0E34, 0x0E3A], [0x0E47, 0x0E4E], 0x0EB1, [0x0EB4, 0x0EB9], 0x0EBB, 0x0EBC, [0x0EC8, 0x0ECD], 0x0F18, 0x0F19, 0x0F35, 0x0F37, 0x0F39, 0x0F3E, 0x0F3F, [0x0F71, 0x0F84], 0x0F86, 0x0F87, [0x0F8D, 0x0F97], [0x0F99, 0x0FBC], 0x0FC6, [0x102B, 0x103E], [0x1056, 0x1059], [0x105E, 0x1060], [0x1062, 0x1064], [0x1067, 0x106D], [0x1071, 0x1074], [0x1082, 0x108D], 0x108F, [0x109A, 0x109D], [0x135D, 0x135F], [0x1712, 0x1714], [0x1732, 0x1734], 0x1752, 0x1753, 0x1772, 0x1773, [0x17B4, 0x17D3], 0x17DD, [0x180B, 0x180D], 0x18A9, [0x1920, 0x192B], [0x1930, 0x193B], [0x19B0, 0x19C0], 0x19C8, 0x19C9, [0x1A17, 0x1A1B], [0x1A55, 0x1A5E], [0x1A60, 0x1A7C], 0x1A7F, [0x1AB0, 0x1ABE], [0x1B00, 0x1B04], [0x1B34, 0x1B44], [0x1B6B, 0x1B73], [0x1B80, 0x1B82], [0x1BA1, 0x1BAD], [0x1BE6, 0x1BF3], [0x1C24, 0x1C37], [0x1CD0, 0x1CD2], [0x1CD4, 0x1CE8], 0x1CED, [0x1CF2, 0x1CF4], 0x1CF8, 0x1CF9, [0x1DC0, 0x1DF5], [0x1DFC, 0x1DFF], 0x200C, 0x200D, [0x20D0, 0x20F0], [0x2CEF, 0x2CF1], 0x2D7F, [0x2DE0, 0x2DFF], [0x302A, 0x302F], 0x3099, 0x309A, [0xA66F, 0xA672], [0xA674, 0xA67D], 0xA69F, 0xA6F0, 0xA6F1, 0xA802, 0xA806, 0xA80B, [0xA823, 0xA827], 0xA880, 0xA881, [0xA8B4, 0xA8C4], [0xA8E0, 0xA8F1], [0xA926, 0xA92D], [0xA947, 0xA953], [0xA980, 0xA983], [0xA9B3, 0xA9C0], 0xA9E5, [0xAA29, 0xAA36], 0xAA43, 0xAA4C, 0xAA4D, [0xAA7B, 0xAA7D], 0xAAB0, [0xAAB2, 0xAAB4], 0xAAB7, 0xAAB8, 0xAABE, 0xAABF, 0xAAC1, [0xAAEB, 0xAAEF], 0xAAF5, 0xAAF6, [0xABE3, 0xABEA], 0xABEC, 0xABED, 0xFB1E, [0xFE00, 0xFE0F], [0xFE20, 0xFE2D], 0xFF9E, 0xFF9F, 0x101FD, 0x102E0, [0x10376, 0x1037A], [0x10A01, 0x10A03], 0x10A05, 0x10A06, [0x10A0C, 0x10A0F], [0x10A38, 0x10A3A], 0x10A3F, 0x10AE5, 0x10AE6, [0x11000, 0x11002], [0x11038, 0x11046], [0x1107F, 0x11082], [0x110B0, 0x110BA], [0x11100, 0x11102], [0x11127, 0x11134], 0x11173, [0x11180, 0x11182], [0x111B3, 0x111C0], [0x1122C, 0x11237], [0x112DF, 0x112EA], [0x11301, 0x11303], 0x1133C, [0x1133E, 0x11344], 0x11347, 0x11348, [0x1134B, 0x1134D], 0x11357, 0x11362, 0x11363, [0x11366, 0x1136C], [0x11370, 0x11374], [0x114B0, 0x114C3], [0x115AF, 0x115B5], [0x115B8, 0x115C0], [0x11630, 0x11640], [0x116AB, 0x116B7], [0x16AF0, 0x16AF4], [0x16B30, 0x16B36], [0x16F51, 0x16F7E], [0x16F8F, 0x16F92], 0x1BC9D, 0x1BC9E, [0x1D165, 0x1D169], [0x1D16D, 0x1D172], [0x1D17B, 0x1D182], [0x1D185, 0x1D18B], [0x1D1AA, 0x1D1AD], [0x1D242, 0x1D244], [0x1E8D0, 0x1E8D6], [0xE0100, 0xE01EF]],
	RegionalIndicator: [[0x1F1E6, 0x1F1FF]],
	Format: [0x00AD, [0x0600, 0x0605], 0x061C, 0x06DD, 0x070F, 0x180E, 0x200E, 0x200F, [0x202A, 0x202E], [0x2060, 0x2064], [0x2066, 0x206F], 0xFEFF, [0xFFF9, 0xFFFB], 0x110BD, [0x1BCA0, 0x1BCA3], [0x1D173, 0x1D17A], 0xE0001, [0xE0020, 0xE007F]],
	Katakana: [[0x3031, 0x3035], 0x309B, 0x309C, [0x30A0, 0x30FA], [0x30FC, 0x30FF], [0x31F0, 0x31FF], [0x32D0, 0x32FE], [0x3300, 0x3357], [0xFF66, 0xFF9D], 0x1B000],
	ALetter: [[0x0041, 0x005A], [0x0061, 0x007A], 0x00AA, 0x00B5, 0x00BA, [0x00C0, 0x00D6], [0x00D8, 0x00F6], [0x00F8, 0x02C1], [0x02C6, 0x02D1], [0x02E0, 0x02E4], 0x02EC, 0x02EE, [0x0370, 0x0374], 0x0376, 0x0377, [0x037A, 0x037D], 0x037F, 0x0386, [0x0388, 0x038A], 0x038C, [0x038E, 0x03A1], [0x03A3, 0x03F5], [0x03F7, 0x0481], [0x048A, 0x052F], [0x0531, 0x0556], 0x0559, [0x0561, 0x0587], 0x05F3, [0x0620, 0x064A], 0x066E, 0x066F, [0x0671, 0x06D3], 0x06D5, 0x06E5, 0x06E6, 0x06EE, 0x06EF, [0x06FA, 0x06FC], 0x06FF, 0x0710, [0x0712, 0x072F], [0x074D, 0x07A5], 0x07B1, [0x07CA, 0x07EA], 0x07F4, 0x07F5, 0x07FA, [0x0800, 0x0815], 0x081A, 0x0824, 0x0828, [0x0840, 0x0858], [0x08A0, 0x08B2], [0x0904, 0x0939], 0x093D, 0x0950, [0x0958, 0x0961], [0x0971, 0x0980], [0x0985, 0x098C], 0x098F, 0x0990, [0x0993, 0x09A8], [0x09AA, 0x09B0], 0x09B2, [0x09B6, 0x09B9], 0x09BD, 0x09CE, 0x09DC, 0x09DD, [0x09DF, 0x09E1], 0x09F0, 0x09F1, [0x0A05, 0x0A0A], 0x0A0F, 0x0A10, [0x0A13, 0x0A28], [0x0A2A, 0x0A30], 0x0A32, 0x0A33, 0x0A35, 0x0A36, 0x0A38, 0x0A39, [0x0A59, 0x0A5C], 0x0A5E, [0x0A72, 0x0A74], [0x0A85, 0x0A8D], [0x0A8F, 0x0A91], [0x0A93, 0x0AA8], [0x0AAA, 0x0AB0], 0x0AB2, 0x0AB3, [0x0AB5, 0x0AB9], 0x0ABD, 0x0AD0, 0x0AE0, 0x0AE1, [0x0B05, 0x0B0C], 0x0B0F, 0x0B10, [0x0B13, 0x0B28], [0x0B2A, 0x0B30], 0x0B32, 0x0B33, [0x0B35, 0x0B39], 0x0B3D, 0x0B5C, 0x0B5D, [0x0B5F, 0x0B61], 0x0B71, 0x0B83, [0x0B85, 0x0B8A], [0x0B8E, 0x0B90], [0x0B92, 0x0B95], 0x0B99, 0x0B9A, 0x0B9C, 0x0B9E, 0x0B9F, 0x0BA3, 0x0BA4, [0x0BA8, 0x0BAA], [0x0BAE, 0x0BB9], 0x0BD0, [0x0C05, 0x0C0C], [0x0C0E, 0x0C10], [0x0C12, 0x0C28], [0x0C2A, 0x0C39], 0x0C3D, 0x0C58, 0x0C59, 0x0C60, 0x0C61, [0x0C85, 0x0C8C], [0x0C8E, 0x0C90], [0x0C92, 0x0CA8], [0x0CAA, 0x0CB3], [0x0CB5, 0x0CB9], 0x0CBD, 0x0CDE, 0x0CE0, 0x0CE1, 0x0CF1, 0x0CF2, [0x0D05, 0x0D0C], [0x0D0E, 0x0D10], [0x0D12, 0x0D3A], 0x0D3D, 0x0D4E, 0x0D60, 0x0D61, [0x0D7A, 0x0D7F], [0x0D85, 0x0D96], [0x0D9A, 0x0DB1], [0x0DB3, 0x0DBB], 0x0DBD, [0x0DC0, 0x0DC6], 0x0F00, [0x0F40, 0x0F47], [0x0F49, 0x0F6C], [0x0F88, 0x0F8C], [0x10A0, 0x10C5], 0x10C7, 0x10CD, [0x10D0, 0x10FA], [0x10FC, 0x1248], [0x124A, 0x124D], [0x1250, 0x1256], 0x1258, [0x125A, 0x125D], [0x1260, 0x1288], [0x128A, 0x128D], [0x1290, 0x12B0], [0x12B2, 0x12B5], [0x12B8, 0x12BE], 0x12C0, [0x12C2, 0x12C5], [0x12C8, 0x12D6], [0x12D8, 0x1310], [0x1312, 0x1315], [0x1318, 0x135A], [0x1380, 0x138F], [0x13A0, 0x13F4], [0x1401, 0x166C], [0x166F, 0x167F], [0x1681, 0x169A], [0x16A0, 0x16EA], [0x16EE, 0x16F8], [0x1700, 0x170C], [0x170E, 0x1711], [0x1720, 0x1731], [0x1740, 0x1751], [0x1760, 0x176C], [0x176E, 0x1770], [0x1820, 0x1877], [0x1880, 0x18A8], 0x18AA, [0x18B0, 0x18F5], [0x1900, 0x191E], [0x1A00, 0x1A16], [0x1B05, 0x1B33], [0x1B45, 0x1B4B], [0x1B83, 0x1BA0], 0x1BAE, 0x1BAF, [0x1BBA, 0x1BE5], [0x1C00, 0x1C23], [0x1C4D, 0x1C4F], [0x1C5A, 0x1C7D], [0x1CE9, 0x1CEC], [0x1CEE, 0x1CF1], 0x1CF5, 0x1CF6, [0x1D00, 0x1DBF], [0x1E00, 0x1F15], [0x1F18, 0x1F1D], [0x1F20, 0x1F45], [0x1F48, 0x1F4D], [0x1F50, 0x1F57], 0x1F59, 0x1F5B, 0x1F5D, [0x1F5F, 0x1F7D], [0x1F80, 0x1FB4], [0x1FB6, 0x1FBC], 0x1FBE, [0x1FC2, 0x1FC4], [0x1FC6, 0x1FCC], [0x1FD0, 0x1FD3], [0x1FD6, 0x1FDB], [0x1FE0, 0x1FEC], [0x1FF2, 0x1FF4], [0x1FF6, 0x1FFC], 0x2071, 0x207F, [0x2090, 0x209C], 0x2102, 0x2107, [0x210A, 0x2113], 0x2115, [0x2119, 0x211D], 0x2124, 0x2126, 0x2128, [0x212A, 0x212D], [0x212F, 0x2139], [0x213C, 0x213F], [0x2145, 0x2149], 0x214E, [0x2160, 0x2188], [0x24B6, 0x24E9], [0x2C00, 0x2C2E], [0x2C30, 0x2C5E], [0x2C60, 0x2CE4], [0x2CEB, 0x2CEE], 0x2CF2, 0x2CF3, [0x2D00, 0x2D25], 0x2D27, 0x2D2D, [0x2D30, 0x2D67], 0x2D6F, [0x2D80, 0x2D96], [0x2DA0, 0x2DA6], [0x2DA8, 0x2DAE], [0x2DB0, 0x2DB6], [0x2DB8, 0x2DBE], [0x2DC0, 0x2DC6], [0x2DC8, 0x2DCE], [0x2DD0, 0x2DD6], [0x2DD8, 0x2DDE], 0x2E2F, 0x3005, 0x303B, 0x303C, [0x3105, 0x312D], [0x3131, 0x318E], [0x31A0, 0x31BA], [0xA000, 0xA48C], [0xA4D0, 0xA4FD], [0xA500, 0xA60C], [0xA610, 0xA61F], 0xA62A, 0xA62B, [0xA640, 0xA66E], [0xA67F, 0xA69D], [0xA6A0, 0xA6EF], [0xA717, 0xA71F], [0xA722, 0xA788], [0xA78B, 0xA78E], [0xA790, 0xA7AD], 0xA7B0, 0xA7B1, [0xA7F7, 0xA801], [0xA803, 0xA805], [0xA807, 0xA80A], [0xA80C, 0xA822], [0xA840, 0xA873], [0xA882, 0xA8B3], [0xA8F2, 0xA8F7], 0xA8FB, [0xA90A, 0xA925], [0xA930, 0xA946], [0xA960, 0xA97C], [0xA984, 0xA9B2], 0xA9CF, [0xAA00, 0xAA28], [0xAA40, 0xAA42], [0xAA44, 0xAA4B], [0xAAE0, 0xAAEA], [0xAAF2, 0xAAF4], [0xAB01, 0xAB06], [0xAB09, 0xAB0E], [0xAB11, 0xAB16], [0xAB20, 0xAB26], [0xAB28, 0xAB2E], [0xAB30, 0xAB5A], [0xAB5C, 0xAB5F], 0xAB64, 0xAB65, [0xABC0, 0xABE2], [0xAC00, 0xD7A3], [0xD7B0, 0xD7C6], [0xD7CB, 0xD7FB], [0xFB00, 0xFB06], [0xFB13, 0xFB17], [0xFB50, 0xFBB1], [0xFBD3, 0xFD3D], [0xFD50, 0xFD8F], [0xFD92, 0xFDC7], [0xFDF0, 0xFDFB], [0xFE70, 0xFE74], [0xFE76, 0xFEFC], [0xFF21, 0xFF3A], [0xFF41, 0xFF5A], [0xFFA0, 0xFFBE], [0xFFC2, 0xFFC7], [0xFFCA, 0xFFCF], [0xFFD2, 0xFFD7], [0xFFDA, 0xFFDC], [0x10000, 0x1000B], [0x1000D, 0x10026], [0x10028, 0x1003A], 0x1003C, 0x1003D, [0x1003F, 0x1004D], [0x10050, 0x1005D], [0x10080, 0x100FA], [0x10140, 0x10174], [0x10280, 0x1029C], [0x102A0, 0x102D0], [0x10300, 0x1031F], [0x10330, 0x1034A], [0x10350, 0x10375], [0x10380, 0x1039D], [0x103A0, 0x103C3], [0x103C8, 0x103CF], [0x103D1, 0x103D5], [0x10400, 0x1049D], [0x10500, 0x10527], [0x10530, 0x10563], [0x10600, 0x10736], [0x10740, 0x10755], [0x10760, 0x10767], [0x10800, 0x10805], 0x10808, [0x1080A, 0x10835], 0x10837, 0x10838, 0x1083C, [0x1083F, 0x10855], [0x10860, 0x10876], [0x10880, 0x1089E], [0x10900, 0x10915], [0x10920, 0x10939], [0x10980, 0x109B7], 0x109BE, 0x109BF, 0x10A00, [0x10A10, 0x10A13], [0x10A15, 0x10A17], [0x10A19, 0x10A33], [0x10A60, 0x10A7C], [0x10A80, 0x10A9C], [0x10AC0, 0x10AC7], [0x10AC9, 0x10AE4], [0x10B00, 0x10B35], [0x10B40, 0x10B55], [0x10B60, 0x10B72], [0x10B80, 0x10B91], [0x10C00, 0x10C48], [0x11003, 0x11037], [0x11083, 0x110AF], [0x110D0, 0x110E8], [0x11103, 0x11126], [0x11150, 0x11172], 0x11176, [0x11183, 0x111B2], [0x111C1, 0x111C4], 0x111DA, [0x11200, 0x11211], [0x11213, 0x1122B], [0x112B0, 0x112DE], [0x11305, 0x1130C], 0x1130F, 0x11310, [0x11313, 0x11328], [0x1132A, 0x11330], 0x11332, 0x11333, [0x11335, 0x11339], 0x1133D, [0x1135D, 0x11361], [0x11480, 0x114AF], 0x114C4, 0x114C5, 0x114C7, [0x11580, 0x115AE], [0x11600, 0x1162F], 0x11644, [0x11680, 0x116AA], [0x118A0, 0x118DF], 0x118FF, [0x11AC0, 0x11AF8], [0x12000, 0x12398], [0x12400, 0x1246E], [0x13000, 0x1342E], [0x16800, 0x16A38], [0x16A40, 0x16A5E], [0x16AD0, 0x16AED], [0x16B00, 0x16B2F], [0x16B40, 0x16B43], [0x16B63, 0x16B77], [0x16B7D, 0x16B8F], [0x16F00, 0x16F44], 0x16F50, [0x16F93, 0x16F9F], [0x1BC00, 0x1BC6A], [0x1BC70, 0x1BC7C], [0x1BC80, 0x1BC88], [0x1BC90, 0x1BC99], [0x1D400, 0x1D454], [0x1D456, 0x1D49C], 0x1D49E, 0x1D49F, 0x1D4A2, 0x1D4A5, 0x1D4A6, [0x1D4A9, 0x1D4AC], [0x1D4AE, 0x1D4B9], 0x1D4BB, [0x1D4BD, 0x1D4C3], [0x1D4C5, 0x1D505], [0x1D507, 0x1D50A], [0x1D50D, 0x1D514], [0x1D516, 0x1D51C], [0x1D51E, 0x1D539], [0x1D53B, 0x1D53E], [0x1D540, 0x1D544], 0x1D546, [0x1D54A, 0x1D550], [0x1D552, 0x1D6A5], [0x1D6A8, 0x1D6C0], [0x1D6C2, 0x1D6DA], [0x1D6DC, 0x1D6FA], [0x1D6FC, 0x1D714], [0x1D716, 0x1D734], [0x1D736, 0x1D74E], [0x1D750, 0x1D76E], [0x1D770, 0x1D788], [0x1D78A, 0x1D7A8], [0x1D7AA, 0x1D7C2], [0x1D7C4, 0x1D7CB], [0x1E800, 0x1E8C4], [0x1EE00, 0x1EE03], [0x1EE05, 0x1EE1F], 0x1EE21, 0x1EE22, 0x1EE24, 0x1EE27, [0x1EE29, 0x1EE32], [0x1EE34, 0x1EE37], 0x1EE39, 0x1EE3B, 0x1EE42, 0x1EE47, 0x1EE49, 0x1EE4B, [0x1EE4D, 0x1EE4F], 0x1EE51, 0x1EE52, 0x1EE54, 0x1EE57, 0x1EE59, 0x1EE5B, 0x1EE5D, 0x1EE5F, 0x1EE61, 0x1EE62, 0x1EE64, [0x1EE67, 0x1EE6A], [0x1EE6C, 0x1EE72], [0x1EE74, 0x1EE77], [0x1EE79, 0x1EE7C], 0x1EE7E, [0x1EE80, 0x1EE89], [0x1EE8B, 0x1EE9B], [0x1EEA1, 0x1EEA3], [0x1EEA5, 0x1EEA9], [0x1EEAB, 0x1EEBB], [0x1F130, 0x1F149], [0x1F150, 0x1F169], [0x1F170, 0x1F189]],
	MidLetter: [0x003A, 0x00B7, 0x02D7, 0x0387, 0x05F4, 0x2027, 0xFE13, 0xFE55, 0xFF1A],
	MidNum: [0x002C, 0x003B, 0x037E, 0x0589, 0x060C, 0x060D, 0x066C, 0x07F8, 0x2044, 0xFE10, 0xFE14, 0xFE50, 0xFE54, 0xFF0C, 0xFF1B],
	MidNumLet: [0x002E, 0x2018, 0x2019, 0x2024, 0xFE52, 0xFF07, 0xFF0E],
	Numeric: [[0x0030, 0x0039], [0x0660, 0x0669], 0x066B, [0x06F0, 0x06F9], [0x07C0, 0x07C9], [0x0966, 0x096F], [0x09E6, 0x09EF], [0x0A66, 0x0A6F], [0x0AE6, 0x0AEF], [0x0B66, 0x0B6F], [0x0BE6, 0x0BEF], [0x0C66, 0x0C6F], [0x0CE6, 0x0CEF], [0x0D66, 0x0D6F], [0x0DE6, 0x0DEF], [0x0E50, 0x0E59], [0x0ED0, 0x0ED9], [0x0F20, 0x0F29], [0x1040, 0x1049], [0x1090, 0x1099], [0x17E0, 0x17E9], [0x1810, 0x1819], [0x1946, 0x194F], [0x19D0, 0x19D9], [0x1A80, 0x1A89], [0x1A90, 0x1A99], [0x1B50, 0x1B59], [0x1BB0, 0x1BB9], [0x1C40, 0x1C49], [0x1C50, 0x1C59], [0xA620, 0xA629], [0xA8D0, 0xA8D9], [0xA900, 0xA909], [0xA9D0, 0xA9D9], [0xA9F0, 0xA9F9], [0xAA50, 0xAA59], [0xABF0, 0xABF9], [0x104A0, 0x104A9], [0x11066, 0x1106F], [0x110F0, 0x110F9], [0x11136, 0x1113F], [0x111D0, 0x111D9], [0x112F0, 0x112F9], [0x114D0, 0x114D9], [0x11650, 0x11659], [0x116C0, 0x116C9], [0x118E0, 0x118E9], [0x16A60, 0x16A69], [0x16B50, 0x16B59], [0x1D7CE, 0x1D7FF]],
	ExtendNumLet: [0x005F, 0x203F, 0x2040, 0x2054, 0xFE33, 0xFE34, [0xFE4D, 0xFE4F], 0xFF3F]
};

/*!
 * UnicodeJS Word Break module
 *
 * Implementation of Unicode 7.0.0 Default Word Boundary Specification
 * http://www.unicode.org/reports/tr29/#Default_Grapheme_Cluster_Table
 *
 * @copyright 2013–2015 UnicodeJS team and others; see AUTHORS.txt
 * @license The MIT License (MIT); see LICENSE.txt
 */
( function () {
	var property,
		properties = unicodeJS.wordbreakproperties,
		/**
		 * @class unicodeJS.wordbreak
		 * @singleton
		 */
		wordbreak = unicodeJS.wordbreak = {},
		patterns = {};

	// build regexes
	for ( property in properties ) {
		patterns[property] = new RegExp(
			unicodeJS.charRangeArrayRegexp( properties[property] )
		);
	}

	/**
	 * Return the wordbreak property value for the cluster
	 *
	 * This is a slight con, because Unicode wordbreak property values are defined
	 * per character, not per cluster, whereas we're already working with a string
	 * split into clusters.
	 *
	 * We are making a working assumption that we can implement the Unicode
	 * word boundary specification by taking the property value of the *first*
	 * character of the cluster. In particular, this implements WB4 for us, because
	 * non-initial Extend or Format characters disappear.
	 *
	 * See http://www.unicode.org/reports/tr29/#Word_Boundaries
	 *
	 * @private
	 * @param {string} cluster The grapheme cluster
	 * @return {string} The unicode wordbreak property value
	 */
	function getProperty( cluster ) {
		var character, property;
		// cluster is always converted to a string by RegExp#test
		// e.g. null -> 'null' and would match /[a-z]/
		// so return null for any non-string value
		if ( typeof cluster !== 'string' ) {
			return null;
		}
		character = unicodeJS.splitCharacters( cluster )[0];
		for ( property in patterns ) {
			if ( patterns[property].test( character ) ) {
				return property;
			}
		}
		return null;
	}

	/**
	 * Find the next word break offset.
	 * @param {unicodeJS.TextString} string TextString
	 * @param {number} pos Character position
	 * @param {boolean} [onlyAlphaNumeric=false] When set, ignores a break if the previous character is not alphaNumeric
	 * @return {number} Returns the next offset which is a word break
	 */
	wordbreak.nextBreakOffset = function ( string, pos, onlyAlphaNumeric ) {
		return wordbreak.moveBreakOffset( 1, string, pos, onlyAlphaNumeric );
	};

	/**
	 * Find the previous word break offset.
	 * @param {unicodeJS.TextString} string TextString
	 * @param {number} pos Character position
	 * @param {boolean} [onlyAlphaNumeric=false] When set, ignores a break if the previous character is not alphaNumeric
	 * @return {number} Returns the previous offset which is a word break
	 */
	wordbreak.prevBreakOffset = function ( string, pos, onlyAlphaNumeric ) {
		return wordbreak.moveBreakOffset( -1, string, pos, onlyAlphaNumeric );
	};

	/**
	 * Find the next word break offset in a specified direction.
	 * @param {number} direction Direction to search in, should be plus or minus one
	 * @param {unicodeJS.TextString} string TextString
	 * @param {number} pos Character position
	 * @param {boolean} [onlyAlphaNumeric=false] When set, ignores a break if the previous character is not alphaNumeric
	 * @return {number} Returns the previous offset which is word break
	 */
	wordbreak.moveBreakOffset = function ( direction, string, pos, onlyAlphaNumeric ) {
		var lastProperty, i = pos,
			// when moving backwards, use the character to the left of the cursor
			readCharOffset = direction > 0 ? 0 : -1;
		// Search backwards for the previous break point
		while ( string.read( i + readCharOffset ) !== null ) {
			i += direction;
			if ( unicodeJS.wordbreak.isBreak( string, i ) ) {
				// Check previous character was alpha-numeric if required
				if ( onlyAlphaNumeric ) {
					lastProperty = getProperty(
						string.read( i - direction + readCharOffset )
					);
					if ( lastProperty !== 'ALetter' &&
						lastProperty !== 'Numeric' &&
						lastProperty !== 'Katakana' &&
						lastProperty !== 'HebrewLetter' ) {
						continue;
					}
				}
				break;
			}
		}
		return i;
	};

	/**
	 * Evaluates if the specified position within some text is a word boundary.
	 * @param {unicodeJS.TextString} string Text string
	 * @param {number} pos Character position
	 * @return {boolean} Is the position a word boundary
	 */
	wordbreak.isBreak = function ( string, pos ) {
		// Break at the start and end of text.
		// WB1: sot ÷
		// WB2: ÷ eot
		if ( string.read( pos - 1 ) === null || string.read( pos ) === null ) {
			return true;
		}

		// get some context
		var lft = [],
			rgt = [],
			l = 0,
			r = 0;
		rgt.push( getProperty( string.read( pos + r  ) ) );
		lft.push( getProperty( string.read( pos - l - 1 ) ) );

		switch ( true ) {
			// Do not break within CRLF.
			// WB3: CR × LF
			case lft[0] === 'CR' && rgt[0] === 'LF':
				return false;

			// Otherwise break before and after Newlines (including CR and LF)
			// WB3a: (Newline | CR | LF) ÷
			case lft[0] === 'Newline' || lft[0] === 'CR' || lft[0] === 'LF':
			// WB3b: ÷ (Newline | CR | LF)
			case rgt[0] === 'Newline' || rgt[0] === 'CR' || rgt[0] === 'LF':
				return true;
		}

		// Ignore Format and Extend characters, except when they appear at the beginning of a region of text.
		// WB4: X (Extend | Format)* → X
		if ( rgt[0] === 'Extend' || rgt[0] === 'Format' ) {
			// The Extend|Format character is to the right, so it is attached
			// to a character to the left, don't split here
			return false;
		}
		// We've reached the end of an Extend|Format sequence, collapse it
		while ( lft[0] === 'Extend' || lft[0] === 'Format' ) {
			l++;
			if ( pos - l - 1 <= 0 ) {
				// start of document
				return true;
			}
			lft[lft.length - 1] = getProperty( string.read( pos - l - 1 ) );
		}

		// Do not break between most letters.
		// WB5: (ALetter | Hebrew_Letter) × (ALetter | Hebrew_Letter)
		if (
			( lft[0] === 'ALetter' || lft[0] === 'HebrewLetter' ) &&
			( rgt[0] === 'ALetter' || rgt[0] === 'HebrewLetter' )
		) {
			return false;
		}

		// some tests beyond this point require more context
		l++;
		r++;
		rgt.push( getProperty( string.read( pos + r ) ) );
		lft.push( getProperty( string.read( pos - l - 1 ) ) );

		switch ( true ) {
			// Do not break letters across certain punctuation.
			// WB6: (ALetter | Hebrew_Letter) × (MidLetter | MidNumLet | Single_Quote) (ALetter | Hebrew_Letter)
			case ( lft[0] === 'ALetter' || lft[0] === 'HebrewLetter' ) &&
				( rgt[1] === 'ALetter' || rgt[1] === 'HebrewLetter' ) &&
				( rgt[0] === 'MidLetter' || rgt[0] === 'MidNumLet' || rgt[0] === 'SingleQuote' ):
			// WB7: (ALetter | Hebrew_Letter) (MidLetter | MidNumLet | Single_Quote) × (ALetter | Hebrew_Letter)
			case ( rgt[0] === 'ALetter' || rgt[0] === 'HebrewLetter' ) &&
				( lft[1] === 'ALetter' || lft[1] === 'HebrewLetter' ) &&
				( lft[0] === 'MidLetter' || lft[0] === 'MidNumLet' || lft[0] === 'SingleQuote' ):
			// WB7a: Hebrew_Letter × Single_Quote
			case lft[0] === 'HebrewLetter' && rgt[0] === 'SingleQuote':
			// WB7b: Hebrew_Letter × Double_Quote Hebrew_Letter
			case lft[0] === 'HebrewLetter' && rgt[0] === 'DoubleQuote' && rgt[1] === 'HebrewLetter':
			// WB7c: Hebrew_Letter Double_Quote × Hebrew_Letter
			case lft[1] === 'HebrewLetter' && lft[0] === 'DoubleQuote' && rgt[0] === 'HebrewLetter':

			// Do not break within sequences of digits, or digits adjacent to letters (“3a”, or “A3”).
			// WB8: Numeric × Numeric
			case lft[0] === 'Numeric' && rgt[0] === 'Numeric':
			// WB9: (ALetter | Hebrew_Letter) × Numeric
			case ( lft[0] === 'ALetter' || lft[0] === 'HebrewLetter' ) && rgt[0] === 'Numeric':
			// WB10: Numeric × (ALetter | Hebrew_Letter)
			case lft[0] === 'Numeric' && ( rgt[0] === 'ALetter' || rgt[0] === 'HebrewLetter' ):
				return false;

			// Do not break within sequences, such as “3.2” or “3,456.789”.
			// WB11: Numeric (MidNum | MidNumLet | Single_Quote) × Numeric
			case rgt[0] === 'Numeric' && lft[1] === 'Numeric' &&
				( lft[0] === 'MidNum' || lft[0] === 'MidNumLet' || lft[0] === 'SingleQuote' ):
			// WB12: Numeric × (MidNum | MidNumLet | Single_Quote) Numeric
			case lft[0] === 'Numeric' && rgt[1] === 'Numeric' &&
				( rgt[0] === 'MidNum' || rgt[0] === 'MidNumLet' || rgt[0] === 'SingleQuote' ):
				return false;

			// Do not break between Katakana.
			// WB13: Katakana × Katakana
			case lft[0] === 'Katakana' && rgt[0] === 'Katakana':
				return false;

			// Do not break from extenders.
			// WB13a: (ALetter | Hebrew_Letter | Numeric | Katakana | ExtendNumLet) × ExtendNumLet
			case rgt[0] === 'ExtendNumLet' &&
				( lft[0] === 'ALetter' || lft[0] === 'HebrewLetter' || lft[0] === 'Numeric' || lft[0] === 'Katakana' || lft[0] === 'ExtendNumLet' ):
			// WB13b: ExtendNumLet × (ALetter | Hebrew_Letter | Numeric | Katakana)
			case lft[0] === 'ExtendNumLet' &&
				( rgt[0] === 'ALetter' || rgt[0] === 'HebrewLetter' || rgt[0] === 'Numeric' || rgt[0] === 'Katakana' ):
				return false;

			// Do not break between regional indicator symbols.
			// WB13c: Regional_Indicator × Regional_Indicator
			case lft[0] === 'RegionalIndicator' && rgt[0] === 'RegionalIndicator':
				return false;
		}
		// Otherwise, break everywhere (including around ideographs).
		// WB14: Any ÷ Any
		return true;
	};
}() );

/*!
 * RangeFix v0.1.1
 * https://github.com/edg2s/rangefix
 *
 * Copyright 2014 Ed Sanders.
 * Released under the MIT license
 */
( function () {

	var broken,
		rangeFix = {};

	/**
	 * Check if bugs are present in the native functions
	 *
	 * For getClientRects, constructs two lines of text and
	 * creates a range between them. Broken browsers will
	 * return three rectangles instead of two.
	 *
	 * For getBoundingClientRect, create a collapsed range
	 * and check if the resulting rect has non-zero offsets.
	 *
	 * getBoundingClientRect is also considered broken if
	 * getClientRects is broken.
	 *
	 * @private
	 * @return {Object} Object containing boolean properties 'getClientRects'
	 *                  and 'getBoundingClientRect' indicating bugs are present
	 *                  in these functions.
	 */
	function isBroken() {
		if ( broken === undefined ) {
			var boundingRect,
				p1 = document.createElement( 'p' ),
				p2 = document.createElement( 'p' ),
				t1 = document.createTextNode( 'aa' ),
				t2 = document.createTextNode( 'aa' ),
				range = document.createRange();

			broken = {};

			p1.appendChild( t1 );
			p2.appendChild( t2 );

			document.body.appendChild( p1 );
			document.body.appendChild( p2 );

			range.setStart( t1, 1 );
			range.setEnd( t2, 1 );
			broken.getClientRects = broken.getBoundingClientRect = range.getClientRects().length > 2;

			if ( !broken.getBoundingClientRect ) {
				// Safari doesn't return a valid bounding rect for collapsed ranges
				range.setEnd( t1, 1 );
				boundingRect = range.getBoundingClientRect();
				broken.getBoundingClientRect = boundingRect.top === 0 && boundingRect.left === 0;
			}

			document.body.removeChild( p1 );
			document.body.removeChild( p2 );
		}
		return broken;
	}

	/**
	 * Get client rectangles from a range
	 *
	 * @param {Range} range Range
	 * @return {ClientRectList|ClientRect[]} ClientRectList or list of ClientRect objects describing range
	 */
	rangeFix.getClientRects = function ( range ) {
		if ( !isBroken().getClientRects ) {
			return range.getClientRects();
		}

		// Chrome gets the end container rects wrong when spanning
		// nodes so we need to traverse up the tree from the endContainer until
		// we reach the common ancestor, then we can add on from start to where
		// we got up to
		// https://code.google.com/p/chromium/issues/detail?id=324437
		var rects = [],
			endContainer = range.endContainer,
			endOffset = range.endOffset,
			partialRange = document.createRange();

		while ( endContainer !== range.commonAncestorContainer ) {
			partialRange.setStart( endContainer, 0 );
			partialRange.setEnd( endContainer, endOffset );

			Array.prototype.push.apply( rects, partialRange.getClientRects() );

			endOffset = Array.prototype.indexOf.call( endContainer.parentNode.childNodes, endContainer );
			endContainer = endContainer.parentNode;
		}

		// Once we've reached the common ancestor, add on the range from the
		// original start position to where we ended up.
		partialRange = range.cloneRange();
		partialRange.setEnd( endContainer, endOffset );
		Array.prototype.push.apply( rects, partialRange.getClientRects() );
		return rects;
	};

	/**
	 * Get bounding rectangle from a range
	 *
	 * @param {Range} range Range
	 * @return {ClientRect|Object|null} ClientRect or ClientRect-like object describing
	 *                                  bounding rectangle, or null if not computable
	 */
	rangeFix.getBoundingClientRect = function ( range ) {
		var i, l, boundingRect,
			rects = this.getClientRects( range ),
			nativeBoundingRect = range.getBoundingClientRect();

		// If there are no rects return null, otherwise we'll fall through to
		// getBoundingClientRect, which in Chrome and Firefox becomes [0,0,0,0].
		if ( rects.length === 0 ) {
			return null;
		}

		if ( !isBroken().getBoundingClientRect ) {
			return nativeBoundingRect;
		}

		// When nativeRange is a collapsed cursor at the end of a line or
		// the start of a line, the bounding rect is [0,0,0,0] in Chrome.
		// getClientRects returns two rects, one correct, and one at the
		// end of the next line / start of the previous line. We can't tell
		// here which one to use so just pick the first. This matches
		// Firefox's behaviour, which tells you the cursor is at the end
		// of the previous line when it is at the start of the line.
		// See https://code.google.com/p/chromium/issues/detail?id=426017
		if ( nativeBoundingRect.width === 0 && nativeBoundingRect.height === 0 ) {
			return rects[0];
		}

		for ( i = 0, l = rects.length; i < l; i++ ) {
			if ( !boundingRect ) {
				boundingRect = {
					left: rects[i].left,
					top: rects[i].top,
					right: rects[i].right,
					bottom: rects[i].bottom
				};
			} else {
				boundingRect.left = Math.min( boundingRect.left, rects[i].left );
				boundingRect.top = Math.min( boundingRect.top, rects[i].top );
				boundingRect.right = Math.max( boundingRect.right, rects[i].right );
				boundingRect.bottom = Math.max( boundingRect.bottom, rects[i].bottom );
			}
		}
		if ( boundingRect ) {
			boundingRect.width = boundingRect.right - boundingRect.left;
			boundingRect.height = boundingRect.bottom - boundingRect.top;
		}
		return boundingRect;
	};

	// Expose
	window.RangeFix = rangeFix;

} )();

/*!
 * VisualEditor namespace.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Namespace for all VisualEditor classes, static methods and static properties.
 * @class ve
 * @singleton
 */
window.ve = {};

/**
 * Get the current time, measured in milliseconds since January 1, 1970 (UTC).
 *
 * On browsers that implement the Navigation Timing API, this function will produce floating-point
 * values with microsecond precision that are guaranteed to be monotonic. On all other browsers,
 * it will fall back to using `Date.now`.
 *
 * @returns {number} Current time
 */
ve.now = ( function () {
	var perf = window.performance,
		navStart = perf && perf.timing && perf.timing.navigationStart;
	return navStart && typeof perf.now === 'function' ?
		function () { return navStart + perf.now(); } : Date.now;
}() );

/*!
 * VisualEditor utilities.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * @class ve
 */

/**
 * Checks if an object is an instance of one or more classes.
 *
 * @param {Object} subject Object to check
 * @param {Function[]} classes Classes to compare with
 * @returns {boolean} Object inherits from one or more of the classes
 */
ve.isInstanceOfAny = function ( subject, classes ) {
	var i = classes.length;

	while ( classes[--i] ) {
		if ( subject instanceof classes[i] ) {
			return true;
		}
	}
	return false;
};

/**
 * @method
 * @inheritdoc OO#getProp
 */
ve.getProp = OO.getProp;

/**
 * @method
 * @inheritdoc OO#setProp
 */
ve.setProp = OO.setProp;

/**
 * @method
 * @inheritdoc OO#cloneObject
 */
ve.cloneObject = OO.cloneObject;

/**
 * @method
 * @inheritdoc OO#cloneObject
 */
ve.getObjectValues = OO.getObjectValues;

/**
 * @method
 * @until ES5: Object#keys
 * @inheritdoc Object#keys
 */
ve.getObjectKeys = Object.keys;

/**
 * @method
 * @inheritdoc OO#compare
 */
ve.compare = OO.compare;

/**
 * @method
 * @inheritdoc OO#copy
 */
ve.copy = OO.copy;

/**
 * Copy an array of DOM elements, optionally into a different document.
 *
 * @param {HTMLElement[]} domElements DOM elements to copy
 * @param {HTMLDocument} [doc] Document to create the copies in; if unset, simply clone each element
 * @returns {HTMLElement[]} Copy of domElements with copies of each element
 */
ve.copyDomElements = function ( domElements, doc ) {
	return domElements.map( function ( domElement ) {
		return doc ? doc.importNode( domElement, true ) : domElement.cloneNode( true );
	} );
};

/**
 * Check if two arrays of DOM elements are equal (according to .isEqualNode())
 * @param {HTMLElement[]} domElements1 First array of DOM elements
 * @param {HTMLElement[]} domElements2 Second array of DOM elements
 * @return {boolean} All elements are pairwise equal
 */
ve.isEqualDomElements = function ( domElements1, domElements2 ) {
	var i = 0,
		len = domElements1.length;
	if ( len !== domElements2.length ) {
		return false;
	}
	for ( ; i < len; i++ ) {
		if ( !domElements1[i].isEqualNode( domElements2[i] ) ) {
			return false;
		}
	}
	return true;
};

/**
 * Check to see if an object is a plain object (created using "{}" or "new Object").
 *
 * @method
 * @source <http://api.jquery.com/jQuery.isPlainObject/>
 * @param {Object} obj The object that will be checked to see if it's a plain object
 * @returns {boolean}
 */
ve.isPlainObject = $.isPlainObject;

/**
 * Check to see if an object is empty (contains no properties).
 *
 * @method
 * @source <http://api.jquery.com/jQuery.isEmptyObject/>
 * @param {Object} obj The object that will be checked to see if it's empty
 * @returns {boolean}
 */
ve.isEmptyObject = $.isEmptyObject;

/**
 * Wrapper for Array#indexOf.
 *
 * Values are compared without type coercion.
 *
 * @method
 * @source <http://api.jquery.com/jQuery.inArray/>
 * @until ES5: Array#indexOf
 * @param {Mixed} value Element to search for
 * @param {Array} array Array to search in
 * @param {number} [fromIndex=0] Index to being searching from
 * @returns {number} Index of value in array, or -1 if not found
 */
ve.indexOf = $.inArray;

/**
 * Merge properties of one or more objects into another.
 * Preserves original object's inheritance (e.g. Array, Object, whatever).
 * In case of array or array-like objects only the indexed properties
 * are copied over.
 * Beware: If called with only one argument, it will consider
 * 'target' as 'source' and 'this' as 'target'. Which means
 * ve.extendObject( { a: 1 } ); sets ve.a = 1;
 *
 * @method
 * @source <http://api.jquery.com/jQuery.extend/>
 * @param {boolean} [recursive=false]
 * @param {Mixed} [target] Object that will receive the new properties
 * @param {Mixed...} [sources] Variadic list of objects containing properties
 * to be merged into the target.
 * @returns {Mixed} Modified version of first or second argument
 */
ve.extendObject = $.extend;

/**
 * Splice one array into another.
 *
 * This is the equivalent of arr.splice( offset, remove, d1, d2, d3, ... ) except that arguments are
 * specified as an array rather than separate parameters.
 *
 * This method has been proven to be faster than using slice and concat to create a new array, but
 * performance tests should be conducted on each use of this method to verify this is true for the
 * particular use. Also, browsers change fast, never assume anything, always test everything.
 *
 * Includes a replacement for broken implementation of Array.prototype.splice() found in Opera 12.
 *
 * @param {Array|ve.dm.BranchNode} arr Target object (must have `splice` method, object will be modified)
 * @param {number} offset Offset in arr to splice at. This may NOT be negative, unlike the
 *  'index' parameter in Array#splice.
 * @param {number} remove Number of elements to remove at the offset. May be zero
 * @param {Array} data Array of items to insert at the offset. Must be non-empty if remove=0
 * @return {Array} Array of items removed
 */
ve.batchSplice = ( function () {
	var arraySplice;

	// This returns true in Opera 12.15
	function spliceBrokenOpera() {
		var n = 256,
			a = [];
		a[n] = 'a';
		a.splice( n + 1, 0, 'b' );
		return a[n] !== 'a';
	}

	// This returns true in Safari 8
	function spliceBrokenSafari() {
		var a = new Array( 100000 );
		a.splice( 30, 0, 'x' );
		a.splice( 20, 1 );
		return a.indexOf( 'x' ) !== 29;
	}

	if ( !spliceBrokenOpera() && !spliceBrokenSafari() ) {
		arraySplice = Array.prototype.splice;
	} else {
		// Standard Array.prototype.splice() function implemented using .slice() and .push().
		arraySplice = function ( offset, remove/*, data... */ ) {
			var data, begin, removed, end;

			data = Array.prototype.slice.call( arguments, 2 );

			begin = this.slice( 0, offset );
			removed = this.slice( offset, remove );
			end = this.slice( offset + remove );

			this.length = 0;
			ve.batchPush( this, begin );
			ve.batchPush( this, data );
			ve.batchPush( this, end );

			return removed;
		};
	}

	return function ( arr, offset, remove, data ) {
		// We need to splice insertion in in batches, because of parameter list length limits which vary
		// cross-browser - 1024 seems to be a safe batch size on all browsers
		var splice, spliced,
			index = 0,
			batchSize = 1024,
			toRemove = remove,
			removed = [];

		splice = Array.isArray( arr ) ? arraySplice : arr.splice;

		if ( data.length === 0 ) {
			// Special case: data is empty, so we're just doing a removal
			// The code below won't handle that properly, so we do it here
			return splice.call( arr, offset, remove );
		}

		while ( index < data.length ) {
			// Call arr.splice( offset, remove, i0, i1, i2, ..., i1023 );
			// Only set remove on the first call, and set it to zero on subsequent calls
			spliced = splice.apply(
				arr, [index + offset, toRemove].concat( data.slice( index, index + batchSize ) )
			);
			if ( toRemove > 0 ) {
				removed = spliced;
			}
			index += batchSize;
			toRemove = 0;
		}
		return removed;
	};
}() );

/**
 * Insert one array into another.
 *
 * Shortcut for `ve.batchSplice( dst, offset, 0, src )`.
 *
 * @see #batchSplice
 * @param {Array|ve.dm.BranchNode} arr Target object (must have `splice` method)
 * @param {number} offset Offset in arr where items will be inserted
 * @param {Array} data Items to insert at offset
 */
ve.insertIntoArray = function ( dst, offset, src ) {
	ve.batchSplice( dst, offset, 0, src );
};

/**
 * Push one array into another.
 *
 * This is the equivalent of arr.push( d1, d2, d3, ... ) except that arguments are
 * specified as an array rather than separate parameters.
 *
 * @param {Array|ve.dm.BranchNode} arr Object supporting .push() to insert at the end of the array. Will be modified
 * @param {Array} data Array of items to insert.
 * @returns {number} length of the new array
 */
ve.batchPush = function ( arr, data ) {
	// We need to push insertion in batches, because of parameter list length limits which vary
	// cross-browser - 1024 seems to be a safe batch size on all browsers
	var length,
		index = 0,
		batchSize = 1024;
	while ( index < data.length ) {
		// Call arr.push( i0, i1, i2, ..., i1023 );
		length = arr.push.apply(
			arr, data.slice( index, index + batchSize )
		);
		index += batchSize;
	}
	return length;
};

/**
 * Log data to the console.
 *
 * This implementation does nothing, to add a real implementation ve.debug needs to be loaded.
 *
 * @param {Mixed...} [args] Data to log
 */
ve.log = ve.log || function () {
	// don't do anything, this is just a stub
};

/**
 * Log error to the console.
 *
 * This implementation does nothing, to add a real implementation ve.debug needs to be loaded.
 *
 * @param {Mixed...} [args] Data to log
 */
ve.error = ve.error || function () {
	// don't do anything, this is just a stub
};

/**
 * Log an object to the console.
 *
 * This implementation does nothing, to add a real implementation ve.debug needs to be loaded.
 *
 * @param {Object} obj
 */
ve.dir = ve.dir || function () {
	// don't do anything, this is just a stub
};

/**
 * Return a function, that, as long as it continues to be invoked, will not
 * be triggered. The function will be called after it stops being called for
 * N milliseconds. If `immediate` is passed, trigger the function on the
 * leading edge, instead of the trailing.
 *
 * Ported from: http://underscorejs.org/underscore.js
 *
 * @param {Function} func
 * @param {number} wait
 * @param {boolean} immediate
 * @returns {Function}
 */
ve.debounce = function ( func, wait, immediate ) {
	var timeout;
	return function () {
		var context = this,
			args = arguments,
			later = function () {
				timeout = null;
				if ( !immediate ) {
					func.apply( context, args );
				}
			};
		if ( immediate && !timeout ) {
			func.apply( context, args );
		}
		clearTimeout( timeout );
		timeout = setTimeout( later, wait );
	};
};

/**
 * Select the contents of an element
 *
 * @param {HTMLElement} element Element
 */
ve.selectElement = function ( element ) {
	var nativeRange = document.createRange(),
		nativeSelection = window.getSelection();
	nativeRange.setStart( element, 0 );
	nativeRange.setEnd( element, element.childNodes.length );
	nativeSelection.removeAllRanges();
	nativeSelection.addRange( nativeRange );
};

/**
 * Move the selection to the end of an input.
 *
 * @param {HTMLElement} element Input element
 */
ve.selectEnd = function ( element ) {
	element.focus();
	if ( element.selectionStart !== undefined ) {
		element.selectionStart = element.selectionEnd = element.value.length;
	} else if ( element.createTextRange ) {
		var textRange = element.createTextRange();
		textRange.collapse( false );
		textRange.select();
	}
};

/**
 * Get a localized message.
 *
 * @param {string} key Message key
 * @param {Mixed...} [params] Message parameters
 * @returns {string} Localized message
 */
ve.msg = function () {
	// Avoid using bind because ve.init.platform doesn't exist yet.
	// TODO: Fix dependency issues between ve.js and ve.init.platform
	return ve.init.platform.getMessage.apply( ve.init.platform, arguments );
};

/**
 * Get a config value.
 *
 * @param {string|string[]} key Config key, or list of keys
 * @returns {Mixed|Object} Config value, or keyed object of config values if list of keys provided
 */
ve.config = function () {
	// Avoid using bind because ve.init.platform doesn't exist yet.
	// TODO: Fix dependency issues between ve.js and ve.init.platform
	return ve.init.platform.getConfig.apply( ve.init.platform, arguments );
};

/**
 * Determine if the text consists of only unattached combining marks.
 *
 * @param {string} text Text to test
 * @returns {boolean} The text is unattached combining marks
 */
ve.isUnattachedCombiningMark = function ( text ) {
	return ( /^[\u0300-\u036F]+$/ ).test( text );
};

/**
 * Convert a grapheme cluster offset to a byte offset.
 *
 * @param {string} text Text in which to calculate offset
 * @param {number} clusterOffset Grapheme cluster offset
 * @returns {number} Byte offset
 */
ve.getByteOffset = function ( text, clusterOffset ) {
	return unicodeJS.graphemebreak.splitClusters( text )
		.slice( 0, clusterOffset )
		.join( '' )
		.length;
};

/**
 * Convert a byte offset to a grapheme cluster offset.
 *
 * @param {string} text Text in which to calculate offset
 * @param {number} byteOffset Byte offset
 * @returns {number} Grapheme cluster offset
 */
ve.getClusterOffset = function ( text, byteOffset ) {
	return unicodeJS.graphemebreak.splitClusters( text.slice( 0, byteOffset ) ).length;
};

/**
 * Get a text substring, taking care not to split grapheme clusters.
 *
 * @param {string} text Text to take the substring from
 * @param {number} start Start offset
 * @param {number} end End offset
 * @param {boolean} [outer=false] Include graphemes if the offset splits them
 * @returns {string} Substring of text
 */
ve.graphemeSafeSubstring = function ( text, start, end, outer ) {
	// TODO: improve performance by incrementally inspecting characters around the offsets
	var unicodeStart = ve.getByteOffset( text, ve.getClusterOffset( text, start ) ),
		unicodeEnd = ve.getByteOffset( text, ve.getClusterOffset( text, end ) );

	// If the selection collapses and we want an inner, then just return empty
	// otherwise we'll end up crossing over start and end
	if ( unicodeStart === unicodeEnd && !outer ) {
		return '';
	}

	// The above calculations always move to the right of a multibyte grapheme.
	// Depending on the outer flag, we may want to move to the left:
	if ( unicodeStart > start && outer ) {
		unicodeStart = ve.getByteOffset( text, ve.getClusterOffset( text, start ) - 1 );
	}
	if ( unicodeEnd > end && !outer ) {
		unicodeEnd = ve.getByteOffset( text, ve.getClusterOffset( text, end ) - 1 );
	}
	return text.slice( unicodeStart, unicodeEnd );
};

/**
 * Escape non-word characters so they can be safely used as HTML attribute values.
 *
 * @param {string} value Attribute value to escape
 * @returns {string} Escaped attribute value
 */
ve.escapeHtml = ( function () {
	function escape( value ) {
		switch ( value ) {
			case '\'':
				return '&#039;';
			case '"':
				return '&quot;';
			case '<':
				return '&lt;';
			case '>':
				return '&gt;';
			case '&':
				return '&amp;';
		}
	}

	return function ( value ) {
		return value.replace( /['"<>&]/g, escape );
	};
}() );

/**
 * Generate HTML attributes.
 *
 * NOTE: While the values of attributes are escaped, the names of attributes (i.e. the keys in
 * the attributes objects) are NOT ESCAPED. The caller is responsible for making sure these are
 * sane tag/attribute names and do not contain unsanitized content from an external source
 * (e.g. from the user or from the web).
 *
 * @param {Object} [attributes] Key-value map of attributes for the tag
 * @returns {string} HTML attributes
 */
ve.getHtmlAttributes = function ( attributes ) {
	var attrName, attrValue,
		parts = [];

	if ( !ve.isPlainObject( attributes ) || ve.isEmptyObject( attributes ) ) {
		return '';
	}

	for ( attrName in attributes ) {
		attrValue = attributes[attrName];
		if ( attrValue === true ) {
			// Convert name=true to name=name
			attrValue = attrName;
		} else if ( attrValue === false ) {
			// Skip name=false
			continue;
		}
		parts.push( attrName + '="' + ve.escapeHtml( String( attrValue ) ) + '"' );
	}

	return parts.join( ' ' );
};

/**
 * Generate an opening HTML tag.
 *
 * NOTE: While the values of attributes are escaped, the tag name and the names of
 * attributes (i.e. the keys in the attributes objects) are NOT ESCAPED. The caller is
 * responsible for making sure these are sane tag/attribute names and do not contain
 * unsanitized content from an external source (e.g. from the user or from the web).
 *
 * @param {string} tag HTML tag name
 * @param {Object} [attributes] Key-value map of attributes for the tag
 * @returns {string} Opening HTML tag
 */
ve.getOpeningHtmlTag = function ( tagName, attributes ) {
	var attr = ve.getHtmlAttributes( attributes );
	return '<' + tagName + ( attr ? ' ' + attr : '' ) + '>';
};

/**
 * Get the attributes of a DOM element as an object with key/value pairs.
 *
 * @param {HTMLElement} element
 * @returns {Object}
 */
ve.getDomAttributes = function ( element ) {
	var i,
		result = {};
	for ( i = 0; i < element.attributes.length; i++ ) {
		result[element.attributes[i].name] = element.attributes[i].value;
	}
	return result;
};

/**
 * Set the attributes of a DOM element as an object with key/value pairs.
 *
 * Use the `null` or `undefined` value to ensure an attribute's absence.
 *
 * @param {HTMLElement} element DOM element to apply attributes to
 * @param {Object} attributes Attributes to apply
 * @param {string[]} [whitelist] List of attributes to exclusively allow (all lowercase names)
 */
ve.setDomAttributes = function ( element, attributes, whitelist ) {
	var key;
	// Duck-typing for attribute setting
	if ( !element.setAttribute || !element.removeAttribute ) {
		return;
	}
	for ( key in attributes ) {
		if ( whitelist && whitelist.indexOf( key.toLowerCase() ) === -1 ) {
			continue;
		}
		if ( attributes[key] === undefined || attributes[key] === null ) {
			element.removeAttribute( key );
		} else {
			element.setAttribute( key, attributes[key] );
		}
	}
};

/**
 * Build a summary of an HTML element.
 *
 * Summaries include node name, text, attributes and recursive summaries of children.
 * Used for serializing or comparing HTML elements.
 *
 * @private
 * @param {HTMLElement} element Element to summarize
 * @param {boolean} [includeHtml=false] Include an HTML summary for element nodes
 * @returns {Object} Summary of element.
 */
ve.getDomElementSummary = function ( element, includeHtml ) {
	var i,
		summary = {
			type: element.nodeName.toLowerCase(),
			text: element.textContent,
			attributes: {},
			children: []
		};

	if ( includeHtml && element.nodeType === Node.ELEMENT_NODE ) {
		summary.html = element.outerHTML;
	}

	// Gather attributes
	if ( element.attributes ) {
		for ( i = 0; i < element.attributes.length; i++ ) {
			summary.attributes[element.attributes[i].name] = element.attributes[i].value;
		}
	}
	// Summarize children
	if ( element.childNodes ) {
		for ( i = 0; i < element.childNodes.length; i++ ) {
			summary.children.push( ve.getDomElementSummary( element.childNodes[i], includeHtml ) );
		}
	}
	return summary;
};

/**
 * Callback for #copy to convert nodes to a comparable summary.
 *
 * @private
 * @param {Object} value Value in the object/array
 * @returns {Object} DOM element summary if value is a node, otherwise just the value
 */
ve.convertDomElements = function ( value ) {
	// Use duck typing rather than instanceof Node; the latter doesn't always work correctly
	if ( value && value.nodeType ) {
		return ve.getDomElementSummary( value );
	}
	return value;
};

/**
 * Check whether a given DOM element has a block element type.
 *
 * @param {HTMLElement|string} element Element or element name
 * @returns {boolean} Element is a block element
 */
ve.isBlockElement = function ( element ) {
	var elementName = typeof element === 'string' ? element : element.nodeName;
	return ve.indexOf( elementName.toLowerCase(), ve.elementTypes.block ) !== -1;
};

/**
 * Check whether a given DOM element is a void element (can't have children).
 *
 * @param {HTMLElement|string} element Element or element name
 * @returns {boolean} Element is a void element
 */
ve.isVoidElement = function ( element ) {
	var elementName = typeof element === 'string' ? element : element.nodeName;
	return ve.indexOf( elementName.toLowerCase(), ve.elementTypes.void ) !== -1;
};

ve.elementTypes = {
	block: [
		'div', 'p',
		// tables
		'table', 'tbody', 'thead', 'tfoot', 'caption', 'th', 'tr', 'td',
		// lists
		'ul', 'ol', 'li', 'dl', 'dt', 'dd',
		// HTML5 heading content
		'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'hgroup',
		// HTML5 sectioning content
		'article', 'aside', 'body', 'nav', 'section', 'footer', 'header', 'figure',
		'figcaption', 'fieldset', 'details', 'blockquote',
		// other
		'hr', 'button', 'canvas', 'center', 'col', 'colgroup', 'embed',
		'map', 'object', 'pre', 'progress', 'video'
	],
	void: [
		'area', 'base', 'br', 'col', 'command', 'embed', 'hr', 'img',
		'input', 'keygen', 'link', 'meta', 'param', 'source', 'track', 'wbr'
	]
};

/**
 * Create an HTMLDocument from an HTML string.
 *
 * The html parameter is supposed to be a full HTML document with a doctype and an `<html>` tag.
 * If you pass a document fragment, it may or may not work, this is at the mercy of the browser.
 *
 * To create an empty document, pass the empty string.
 *
 * If your input is both valid HTML and valid XML, and you need to work around style
 * normalization bugs in Internet Explorer, use #parseXhtml and #serializeXhtml.
 *
 * @param {string} html HTML string
 * @returns {HTMLDocument} Document constructed from the HTML string
 */
ve.createDocumentFromHtml = function ( html ) {
	// Try using DOMParser if available. This only works in Firefox 12+ and very modern
	// versions of other browsers (Chrome 30+, Opera 17+, IE10+)
	var newDocument, $iframe, iframe;
	try {
		if ( html === '' ) {
			// IE doesn't like empty strings
			html = '<body></body>';
		}
		newDocument = new DOMParser().parseFromString( html, 'text/html' );
		if ( newDocument ) {
			return newDocument;
		}
	} catch ( e ) { }

	// Here's what this fallback code should look like:
	//
	//     var newDocument = document.implementation.createHtmlDocument( '' );
	//     newDocument.open();
	//     newDocument.write( html );
	//     newDocument.close();
	//     return newDocument;
	//
	// Sadly, it's impossible:
	// * On IE 9, calling open()/write() on such a document throws an "Unspecified error" (sic).
	// * On Firefox 20, calling open()/write() doesn't actually do anything, including writing.
	//   This is reported as Firefox bug 867102.
	// * On Opera 12, calling open()/write() behaves as if called on window.document, replacing the
	//   entire contents of the page with new HTML. This is reported as Opera bug DSK-384486.
	//
	// Funnily, in all of those browsers it's apparently perfectly legal and possible to access the
	// newly created document's DOM itself, including modifying documentElement's innerHTML, which
	// would achieve our goal. But that requires some nasty magic to strip off the <html></html> tag
	// itself, so we're not doing that. (We can't use .outerHTML, either, as the spec disallows
	// assigning to it for the root element.)
	//
	// There is one more way - create an <iframe>, append it to current document, and access its
	// contentDocument. The only browser having issues with that is Opera (sometimes the accessible
	// value is not actually a Document, but something which behaves just like an empty regular
	// object...), so we're detecting that and using the innerHTML hack described above.

	// Create an invisible iframe
	$iframe = $( '<iframe frameborder="0" width="0" height="0" />' );
	iframe = $iframe.get( 0 );
	// Attach it to the document. We have to do this to get a new document out of it
	document.documentElement.appendChild( iframe );
	// Write the HTML to it
	newDocument = ( iframe.contentWindow && iframe.contentWindow.document ) || iframe.contentDocument;
	newDocument.open();
	newDocument.write( html ); // Party like it's 1995!
	newDocument.close();
	// Detach the iframe
	// FIXME detaching breaks access to newDocument in IE
	iframe.parentNode.removeChild( iframe );

	if ( !newDocument.documentElement || newDocument.documentElement.cloneNode( false ) === undefined ) {
		// Surprise! The document is not a document! Only happens on Opera.
		// (Or its nodes are not actually nodes, while the document
		// *is* a document. This only happens when debugging with Dragonfly.)
		newDocument = document.implementation.createHTMLDocument( '' );
		// Carefully unwrap the HTML out of the root node (and doctype, if any).
		// <html> might have some arguments here, but they're apparently not important.
		html = html.replace(/^\s*(?:<!doctype[^>]*>)?\s*<html[^>]*>/i, '' );
		html = html.replace(/<\/html>\s*$/i, '' );
		newDocument.documentElement.innerHTML = html;
	}

	return newDocument;
};

/**
 * Resolve a URL relative to a given base.
 *
 * @param {string} url URL to resolve
 * @param {HTMLDocument} base Document whose base URL to use
 * @returns {string} Resolved URL
 */
ve.resolveUrl = function ( url, base ) {
	var node = base.createElement( 'a' );
	node.setAttribute( 'href', url );
	// If doc.baseURI isn't set, node.href will be an empty string
	// This is crazy, returning the original URL is better
	return node.href || url;
};

/**
 * Get the actual inner HTML of a DOM node.
 *
 * In most browsers, .innerHTML is broken and eats newlines in `<pre>` elements, see
 * https://bugzilla.mozilla.org/show_bug.cgi?id=838954 . This function detects this behavior
 * and works around it, to the extent possible. `<pre>\nFoo</pre>` will become `<pre>Foo</pre>`
 * if the browser is broken, but newlines are preserved in all other cases.
 *
 * @param {HTMLElement} element HTML element to get inner HTML of
 * @returns {string} Inner HTML
 */
ve.properInnerHtml = function ( element ) {
	return ve.fixupPreBug( element ).innerHTML;
};

/**
 * Get the actual outer HTML of a DOM node.
 *
 * @see ve#properInnerHtml
 * @param {HTMLElement} element HTML element to get outer HTML of
 * @returns {string} Outer HTML
 */
ve.properOuterHtml = function ( element ) {
	return ve.fixupPreBug( element ).outerHTML;
};

/**
 * Helper function for #properInnerHtml, #properOuterHtml and #serializeXhtml.
 *
 * Detect whether the browser has broken `<pre>` serialization, and if so return a clone
 * of the node with extra newlines added to make it serialize properly. If the browser is not
 * broken, just return the original node.
 *
 * @param {HTMLElement} element HTML element to fix up
 * @returns {HTMLElement} Either element, or a fixed-up clone of it
 */
ve.fixupPreBug = function ( element ) {
	var div, $element;
	if ( ve.isPreInnerHtmlBroken === undefined ) {
		// Test whether newlines in `<pre>` are serialized back correctly
		div = document.createElement( 'div' );
		div.innerHTML = '<pre>\n\n</pre>';
		ve.isPreInnerHtmlBroken = div.innerHTML === '<pre>\n</pre>';
	}

	if ( !ve.isPreInnerHtmlBroken ) {
		return element;
	}

	// Workaround for bug 42469: if a `<pre>` starts with a newline, that means .innerHTML will
	// screw up and stringify it with one fewer newline. Work around this by adding a newline.
	// If we don't see a leading newline, we still don't know if the original HTML was
	// `<pre>Foo</pre>` or `<pre>\nFoo</pre>`, but that's a syntactic difference, not a
	// semantic one, and handling that is the integration target's job.
	$element = $( element ).clone();
	$element.find( 'pre, textarea, listing' ).each( function () {
		var matches;
		if ( this.firstChild && this.firstChild.nodeType === Node.TEXT_NODE ) {
			matches = this.firstChild.data.match( /^(\r\n|\r|\n)/ );
			if ( matches && matches[1] ) {
				// Prepend a newline exactly like the one we saw
				this.firstChild.insertData( 0, matches[1] );
			}
		}
	} );
	return $element.get( 0 );
};

/**
 * Helper function for #transformStyleAttributes.
 *
 * Normalize an attribute value. In compliant browsers, this should be
 * a no-op, but in IE style attributes are normalized on all elements,
 * color and bgcolor attributes are normalized on some elements (like `<tr>`),
 * and width and height attributes are normalized on some elements( like `<table>`).
 *
 * @param {string} name Attribute name
 * @param {string} value Attribute value
 * @param {string} [nodeName='div'] Element name
 * @return {string} Normalized attribute value
 */
ve.normalizeAttributeValue = function ( name, value, nodeName ) {
	var node = document.createElement( nodeName || 'div' );
	node.setAttribute( name, value );
	// IE normalizes invalid CSS to empty string, then if you normalize
	// an empty string again it becomes null. Return an empty string
	// instead of null to make this function idempotent.
	return node.getAttribute( name ) || '';
};

/**
 * Helper function for #parseXhtml and #serializeXhtml.
 *
 * Map attributes that are broken in IE to attributes prefixed with data-ve-
 * or vice versa.
 *
 * @param {string} html HTML string. Must also be valid XML
 * @param {boolean} unmask Map the masked attributes back to their originals
 * @returns {string} HTML string modified to mask/unmask broken attributes
 */
ve.transformStyleAttributes = function ( html, unmask ) {
	var xmlDoc, fromAttr, toAttr, i, len,
		maskAttrs = [
			'style', // IE normalizes 'color:#ffd' to 'color: rgb(255, 255, 221);'
			'bgcolor', // IE normalizes '#FFDEAD' to '#ffdead'
			'color', // IE normalizes 'Red' to 'red'
			'width', // IE normalizes '240px' to '240'
			'height' // Same as width
		];

	// Parse the HTML into an XML DOM
	xmlDoc = new DOMParser().parseFromString( html, 'text/xml' );

	// Go through and mask/unmask each attribute on all elements that have it
	for ( i = 0, len = maskAttrs.length; i < len; i++ ) {
		fromAttr = unmask ? 'data-ve-' + maskAttrs[i] : maskAttrs[i];
		toAttr = unmask ? maskAttrs[i] : 'data-ve-' + maskAttrs[i];
		/*jshint loopfunc:true */
		$( xmlDoc ).find( '[' + fromAttr + ']' ).each( function () {
			var toAttrValue, fromAttrNormalized,
				fromAttrValue = this.getAttribute( fromAttr );

			if ( unmask ) {
				this.removeAttribute( fromAttr );

				// If the data-ve- version doesn't normalize to the same value,
				// the attribute must have changed, so don't overwrite it
				fromAttrNormalized = ve.normalizeAttributeValue( toAttr, fromAttrValue, this.nodeName );
				// toAttr can't not be set, but IE returns null if the value was ''
				toAttrValue = this.getAttribute( toAttr ) || '';
				if ( toAttrValue !== fromAttrNormalized ) {
					return;
				}
			}

			this.setAttribute( toAttr, fromAttrValue );
		} );
	}

	// HACK: Inject empty text nodes into empty non-void tags to prevent
	// things like <a></a> from being serialized as <a /> and wreaking havoc
	$( xmlDoc ).find( ':empty:not(' + ve.elementTypes.void.join( ',' ) + ')' ).each( function () {
		this.appendChild( xmlDoc.createTextNode( '' ) );
	} );

	// Serialize back to a string
	return new XMLSerializer().serializeToString( xmlDoc );
};

/**
 * Parse an HTML string into an HTML DOM, while masking attributes affected by
 * normalization bugs if a broken browser is detected.
 * Since this process uses an XML parser, the input must be valid XML as well as HTML.
 *
 * @param {string} html HTML string. Must also be valid XML
 * @return {HTMLDocument} HTML DOM
 */
ve.parseXhtml = function ( html ) {
	// Feature-detect style attribute breakage in IE
	if ( ve.isStyleAttributeBroken === undefined ) {
		ve.isStyleAttributeBroken = ve.normalizeAttributeValue( 'style', 'color:#ffd' ) !== 'color:#ffd';
	}
	if ( ve.isStyleAttributeBroken ) {
		html = ve.transformStyleAttributes( html, false );
	}
	return ve.createDocumentFromHtml( html );
};

/**
 * Serialize an HTML DOM created with #parseXhtml back to an HTML string, unmasking any
 * attributes that were masked.
 *
 * @param {HTMLDocument} doc HTML DOM
 * @return {string} Serialized HTML string
 */
ve.serializeXhtml = function ( doc ) {
	var xml;
	// Feature-detect style attribute breakage in IE
	if ( ve.isStyleAttributeBroken === undefined ) {
		ve.isStyleAttributeBroken = ve.normalizeAttributeValue( 'style', 'color:#ffd' ) !== 'color:#ffd';
	}
	if ( !ve.isStyleAttributeBroken ) {
		// Use outerHTML if possible because in Firefox, XMLSerializer URL-encodes
		// hrefs but outerHTML doesn't
		return ve.properOuterHtml( doc.documentElement );
	}

	xml = new XMLSerializer().serializeToString( ve.fixupPreBug( doc.documentElement ) );
	// HACK: strip out xmlns
	xml = xml.replace( '<html xmlns="http://www.w3.org/1999/xhtml"', '<html' );
	return ve.transformStyleAttributes( xml, true );
};

/**
 * Wrapper for node.normalize(). The native implementation is broken in IE,
 * so we use our own implementation in that case.
 *
 * @param {Node} node Node to normalize
 */
ve.normalizeNode = function ( node ) {
	var p, nodeIterator, textNode;
	if ( ve.isNormalizeBroken === undefined ) {
		// Feature-detect IE11's broken .normalize() implementation.
		// We know that it fails to remove the empty text node at the end
		// in this example, but for mysterious reasons it also fails to merge
		// text nodes in other cases and we don't quite know why. So if we detect
		// that .normalize() is broken, fall back to a completely manual version.
		p = document.createElement( 'p' );
		p.appendChild( document.createTextNode( 'Foo' ) );
		p.appendChild( document.createTextNode( 'Bar' ) );
		p.appendChild( document.createTextNode( '' ) );
		p.normalize();
		ve.isNormalizeBroken = p.childNodes.length !== 1;
	}

	if ( ve.isNormalizeBroken ) {
		// Perform normalization manually
		nodeIterator = node.ownerDocument.createNodeIterator(
			node,
			NodeFilter.SHOW_TEXT,
			function () { return NodeFilter.FILTER_ACCEPT; },
			false
		);
		while ( ( textNode = nodeIterator.nextNode() ) ) {
			// Remove if empty
			if ( textNode.data === '' ) {
				textNode.parentNode.removeChild( textNode );
				continue;
			}
			// Merge in any adjacent text nodes
			while ( textNode.nextSibling && textNode.nextSibling.nodeType === Node.TEXT_NODE ) {
				textNode.appendData( textNode.nextSibling.data );
				textNode.parentNode.removeChild( textNode.nextSibling );
			}
		}
	} else {
		// Use native implementation
		node.normalize();
	}
};

/**
 * Translate rect by some fixed vector and return a new offset object
 * @param {Object} rect Offset object containing all or any of top, left, bottom, right, width & height
 * @param {number} x Horizontal translation
 * @param {number} y Vertical translation
 * @return {Object} Translated rect
 */
ve.translateRect = function ( rect, x, y ) {
	var translatedRect = {};
	if ( rect.top !== undefined ) {
		translatedRect.top = rect.top + y;
	}
	if ( rect.bottom !== undefined ) {
		translatedRect.bottom = rect.bottom + y;
	}
	if ( rect.left !== undefined ) {
		translatedRect.left = rect.left + x;
	}
	if ( rect.right !== undefined ) {
		translatedRect.right = rect.right + x;
	}
	if ( rect.width !== undefined ) {
		translatedRect.width = rect.width;
	}
	if ( rect.height !== undefined ) {
		translatedRect.height = rect.height;
	}
	return translatedRect;
};

/**
 * Get the start and end rectangles (in a text flow sense) from a list of rectangles
 * @param {Array} rects Full list of rectangles
 * @return {Object|null} Object containing two rectangles: start and end, or null if there are no rectangles
 */
ve.getStartAndEndRects = function ( rects ) {
	var i, l, startRect, endRect;
	if ( !rects || !rects.length ) {
		return null;
	}
	for ( i = 0, l = rects.length; i < l; i++ ) {
		if ( !startRect || rects[i].top < startRect.top ) {
			// Use ve.extendObject as ve.copy copies non-plain objects by reference
			startRect = ve.extendObject( {}, rects[i] );
		} else if ( rects[i].top === startRect.top ) {
			// Merge rects with the same top coordinate
			startRect.left = Math.min( startRect.left, rects[i].left );
			startRect.right = Math.max( startRect.right, rects[i].right );
			startRect.width = startRect.right - startRect.left;
		}
		if ( !endRect || rects[i].bottom > endRect.bottom ) {
			// Use ve.extendObject as ve.copy copies non-plain objects by reference
			endRect = ve.extendObject( {}, rects[i] );
		} else if ( rects[i].bottom === endRect.bottom ) {
			// Merge rects with the same bottom coordinate
			endRect.left = Math.min( endRect.left, rects[i].left );
			endRect.right = Math.max( endRect.right, rects[i].right );
			endRect.width = startRect.right - startRect.left;
		}
	}
	return {
		start: startRect,
		end: endRect
	};
};

/**
 * Find the nearest common ancestor of DOM nodes
 *
 * @param {Node...} DOM nodes in the same document
 * @returns {Node|null} Nearest common ancestor node
 */
ve.getCommonAncestor = function () {
	var i, j, nodeCount, chain, node,
		minHeight = null,
		chains = [],
		args = Array.prototype.slice.call( arguments );
	nodeCount = args.length;
	if ( nodeCount === 0 ) {
		throw new Error( 'Need at least one node' );
	}
	// Build every chain
	for ( i = 0; i < nodeCount; i++ ) {
		chain = [];
		node = args[ i ];
		while ( node !== null ) {
			chain.unshift( node );
			node = node.parentNode;
		}
		if ( chain.length === 0 ) {
			return null;
		}
		if ( i > 0 && chain[ 0 ] !== chains[ chains.length - 1 ][ 0 ] ) {
			return null;
		}
		if ( minHeight === null || minHeight > chain.length ) {
			minHeight = chain.length;
		}
		chains.push( chain );
	}

	// Step through chains in parallel, until they differ
	// All chains are guaranteed to start with documentNode
	for ( i = 1; i < minHeight; i++ ) {
		node = chains[ 0 ][ i ];
		for ( j = 1; j < nodeCount; j++ ) {
			if ( node !== chains[ j ][ i ] ) {
				return chains[ 0 ][ i - 1 ];
			}
		}
	}
	return chains[ 0 ][ minHeight - 1 ];
};

/**
 * Get the offset path from ancestor to offset in descendant
 *
 * @param {Node} ancestor The ancestor node
 * @param {Node} node The descendant node
 * @param {number} nodeOffset The offset in the descendant node
 * @return {number[]} The offset path
 */
ve.getOffsetPath = function ( ancestor, node, nodeOffset ) {
	var path = [ nodeOffset ];
	while ( node !== ancestor ) {
		if ( node.parentNode === null ) {
			ve.log( node, 'is not a descendant of', ancestor );
			throw new Error( 'Not a descendant' );
		}
		path.unshift(
			Array.prototype.indexOf.call( node.parentNode.childNodes, node )
		);
		node = node.parentNode;
	}
	return path;
};

/**
 * Compare two offset paths for position in document
 *
 * @param {number[]} path1 First offset path
 * @param {number[]} path2 Second offset path
 * @return {number} negative, zero or positive number
 */
ve.compareOffsetPaths = function ( path1, path2 ) {
	var i, len;
	for ( i = 0, len = Math.min( path1.length, path2.length ); i < len; i++ ) {
		if ( path1[ i ] !== path2[ i ] ) {
			return path1[ i ] - path2[ i ];
		}
	}
	return path1.length - path2.length;
};

/**
 * Compare two nodes for position in document
 *
 * @param {Node} node1 First node
 * @param {number} offset1 First offset
 * @param {Node} node2 Second node
 * @param {number} offset2 Second offset
 * @return {number} negative, zero or positive number
 */
ve.compareDocumentOrder = function ( node1, offset1, node2, offset2 ) {

	var commonAncestor = ve.getCommonAncestor( node1, node2 );
	if ( commonAncestor === null ) {
		throw new Error( 'No common ancestor' );
	}
	return ve.compareOffsetPaths(
		ve.getOffsetPath( commonAncestor, node1, offset1 ),
		ve.getOffsetPath( commonAncestor, node2, offset2 )
	);
};

/**
 * Get the client platform string from the browser.
 *
 * HACK: This is a wrapper for calling getSystemPlatform() on the current platform
 * except that if the platform hasn't been constructed yet, it falls back to using
 * the base class implementation in {ve.init.Platform}. A proper solution would be
 * not to need this information before the platform is constructed.
 *
 * @see ve.init.Platform#getSystemPlatform
 * @returns {string} Client platform string
 */
ve.getSystemPlatform = function () {
	return ( ve.init.platform && ve.init.platform.constructor || ve.init.Platform ).static.getSystemPlatform();
};

/*!
 * VisualEditor UserInterface TriggerListener class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Trigger listener
 *
 * @class
 *
 * @constructor
 * @param {string[]} commands Commands to listen to triggers for
 */
ve.TriggerListener = function VeUiTriggerListener( commands ) {
	// Properties
	this.commands = [];
	this.commandsByTrigger = {};
	this.triggers = {};

	this.setupCommands( commands );
};

/* Inheritance */

OO.initClass( ve.TriggerListener );

/* Methods */

/**
 * Setup commands
 *
 * @param {string[]} commands Commands to listen to triggers for
 */
ve.TriggerListener.prototype.setupCommands = function ( commands ) {
	var i, j, command, triggers;
	this.commands = commands;
	if ( commands.length ) {
		for ( i = this.commands.length - 1; i >= 0; i-- ) {
			command = this.commands[i];
			triggers = ve.ui.triggerRegistry.lookup( command );
			if ( triggers ) {
				for ( j = triggers.length - 1; j >= 0; j-- ) {
					this.commandsByTrigger[triggers[j].toString()] = ve.ui.commandRegistry.lookup( command );
				}
				this.triggers[command] = triggers;
			}
		}
	}
};

/**
 * Get list of commands.
 *
 * @returns {string[]} Commands
 */
ve.TriggerListener.prototype.getCommands = function () {
	return this.commands;
};

/**
 * Get command associated with trigger string.
 *
 * @method
 * @param {string} trigger Trigger string
 * @returns {ve.ui.Command|undefined} Command
 */
ve.TriggerListener.prototype.getCommandByTrigger = function ( trigger ) {
	return this.commandsByTrigger[trigger];
};

/**
 * Get triggers for a specified name.
 *
 * @param {string} name Trigger name
 * @returns {ve.ui.Trigger[]|undefined} Triggers
 */
ve.TriggerListener.prototype.getTriggers = function ( name ) {
	return this.triggers[name];
};

/*!
 * VisualEditor tracking methods.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

( function () {
	var callbacks = $.Callbacks( 'memory' ),
		queue = [];

	/**
	 * Track an analytic event.
	 *
	 * VisualEditor uses this method internally to track internal changes of state that are of analytic
	 * interest, either because they provide data about how users interact with the editor, or because
	 * they contain exception info, latency measurements, or other metrics that help gauge performance
	 * and reliability. VisualEditor does not transmit these events by default, but it provides a
	 * generic interface for routing these events to an analytics framework.
	 *
	 * @member ve
	 * @param {string} topic Event name
	 * @param {Object} [data] Additional data describing the event, encoded as an object
	 */
	ve.track = function ( topic, data ) {
		queue.push( { topic: topic, timeStamp: ve.now(), data: data } );
		callbacks.fire( queue );
	};

	/**
	 * Register a handler for subset of analytic events, specified by topic
	 *
	 * Handlers will be called once for each tracked event, including any events that fired before the
	 * handler was registered, with the topic, event data payload, and event timestamp as the first,
	 * second, and third arguments, respectively.
	 *
	 * @member ve
	 * @param {string} topic Handle events whose name starts with this string prefix
	 * @param {Function} callback Handler to call for each matching tracked event
	 */
	ve.trackSubscribe = function ( topic, callback ) {
		var seen = 0;

		callbacks.add( function ( queue ) {
			var event;
			for ( ; seen < queue.length; seen++ ) {
				event = queue[ seen ];
				if ( event.topic.indexOf( topic ) === 0 ) {
					callback( event.topic, event.data, event.timeStamp );
				}
			}
		} );
	};

	/**
	 * Register a handler for all analytic events
	 *
	 * Like ve#trackSubscribe, but binds the callback to all events, regardless of topic.
	 *
	 * @member ve
	 * @param {Function} callback
	 */
	ve.trackSubscribeAll = function ( callback ) {
		ve.trackSubscribe( '', callback );
	};
}() );

/*!
 * VisualEditor Initialization namespace.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Namespace for all VisualEditor Initialization classes, static methods and static properties.
 * @class
 * @singleton
 */
ve.init = {
	// platform: Initialized in a file containing a subclass of ve.init.Platform
};

/*!
 * VisualEditor Initialization Platform class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Generic Initialization platform.
 *
 * @abstract
 * @mixins OO.EventEmitter
 *
 * @constructor
 */
ve.init.Platform = function VeInitPlatform() {
	// Mixin constructors
	OO.EventEmitter.call( this );
};

/* Inheritance */

OO.mixinClass( ve.init.Platform, OO.EventEmitter );

/* Static Methods */

/**
 * Get client platform string from browser.
 *
 * @static
 * @method
 * @inheritable
 * @returns {string} Client platform string
 */
ve.init.Platform.static.getSystemPlatform = function () {
	var platforms = ['win', 'mac', 'linux', 'sunos', 'solaris', 'iphone'],
		match = new RegExp( '(' + platforms.join( '|' ) + ')' ).exec( window.navigator.platform.toLowerCase() );
	if ( match ) {
		return match[1];
	}
};

/**
 * Check whether we are running in Internet Explorer.
 *
 * HACK: This should not be needed, and it should eventually be removed. If this hasn't died
 * in a fire by the end of September 2015, Roan has failed.
 *
 * @static
 * @method
 * @inheritable
 * @returns {boolean} Whether we are in IE
 */
ve.init.Platform.static.isInternetExplorer = function () {
	return navigator.userAgent.indexOf( 'Trident' ) !== -1 || navigator.userAgent.indexOf( 'Edge' ) !== -1;
};

/* Methods */

/**
 * Get a regular expression that matches allowed external link URLs.
 *
 * @method
 * @abstract
 * @returns {RegExp} Regular expression object
 */
ve.init.Platform.prototype.getExternalLinkUrlProtocolsRegExp = function () {
	throw new Error( 've.init.Platform.getExternalLinkUrlProtocolsRegExp must be overridden in subclass' );
};

/**
 * Get a config value from the platform.
 *
 * @method
 * @abstract
 * @param {string|string[]} key Config key, or list of keys
 * @returns {Mixed|Object} Config value, or keyed object of config values if list of keys provided
 */
ve.init.Platform.prototype.getConfig = function () {
	throw new Error( 've.init.Platform.getConfig must be overridden in subclass' );
};

/**
 * Add multiple messages to the localization system.
 *
 * @method
 * @abstract
 * @param {Object} messages Containing plain message values
 */
ve.init.Platform.prototype.addMessages = function () {
	throw new Error( 've.init.Platform.addMessages must be overridden in subclass' );
};

/**
 * Get a message from the localization system.
 *
 * @method
 * @abstract
 * @param {string} key Message key
 * @param {Mixed...} [args] List of arguments which will be injected at $1, $2, etc. in the message
 * @returns {string} Localized message, or key or '<' + key + '>' if message not found
 */
ve.init.Platform.prototype.getMessage = function () {
	throw new Error( 've.init.Platform.getMessage must be overridden in subclass' );
};

/**
 * Add multiple parsed messages to the localization system.
 *
 * @method
 * @abstract
 * @param {Object} messages Map of message-key/html pairs
 */
ve.init.Platform.prototype.addParsedMessages = function () {
	throw new Error( 've.init.Platform.addParsedMessages must be overridden in subclass' );
};

/**
 * Get a parsed message as HTML string.
 *
 * Does not support $# replacements.
 *
 * @method
 * @abstract
 * @param {string} key Message key
 * @returns {string} Parsed localized message as HTML string
 */
ve.init.Platform.prototype.getParsedMessage = function () {
	throw new Error( 've.init.Platform.getParsedMessage must be overridden in subclass' );
};

/**
 * Get the user language and any fallback languages.
 *
 * @method
 * @abstract
 * @returns {string[]} User language strings
 */
ve.init.Platform.prototype.getUserLanguages = function () {
	throw new Error( 've.init.Platform.getUserLanguages must be overridden in subclass' );
};

/**
 * Get a list of URL entry points where media can be found.
 *
 * @method
 * @abstract
 * @returns {string[]} API URLs
 */
ve.init.Platform.prototype.getMediaSources = function () {
	throw new Error( 've.init.Platform.getMediaSources must be overridden in subclass' );
};

/**
 * Get a list of all language codes.
 *
 * @method
 * @abstract
 * @returns {string[]} Language codes
 */
ve.init.Platform.prototype.getLanguageCodes = function () {
	throw new Error( 've.init.Platform.getLanguageCodes must be overridden in subclass' );
};

/**
 * Get a language's name from its code, in the current user language if possible.
 *
 * @method
 * @abstract
 * @param {string} code Language code
 * @returns {string} Language name
 */
ve.init.Platform.prototype.getLanguageName = function () {
	throw new Error( 've.init.Platform.getLanguageName must be overridden in subclass' );
};

/**
 * Get a language's autonym from its code.
 *
 * @method
 * @abstract
 * @param {string} code Language code
 * @returns {string} Language autonym
 */
ve.init.Platform.prototype.getLanguageAutonym = function () {
	throw new Error( 've.init.Platform.getLanguageAutonym must be overridden in subclass' );
};

/**
 * Get a language's direction from its code.
 *
 * @method
 * @abstract
 * @param {string} code Language code
 * @returns {string} Language direction
 */
ve.init.Platform.prototype.getLanguageDirection = function () {
	throw new Error( 've.init.Platform.getLanguageDirection must be overridden in subclass' );
};

/**
 * Initialize the platform. The default implementation is to do nothing and return a resolved
 * promise. Subclasses should override this if they have asynchronous initialization work to do.
 *
 * External callers should not call this. Instead, call #getInitializedPromise.
 *
 * @private
 * @returns {jQuery.Promise} Promise that will be resolved once initialization is done
 */
ve.init.Platform.prototype.initialize = function () {
	return $.Deferred().resolve().promise();
};

/**
 * Get a promise to track when the platform has initialized. The platform won't be ready for use
 * until this promise is resolved.
 *
 * Since the initialization only happens once, and the same (resolved) promise
 * is returned when called again, and since the Platform instance is global
 * (shared between different Target instances) it is important not to rely
 * on this promise being asynchronous.
 *
 * @returns {jQuery.Promise} Promise that will be resolved once the platform is ready
 */
ve.init.Platform.prototype.getInitializedPromise = function () {
	if ( !this.initialized ) {
		this.initialized = this.initialize();
	}
	return this.initialized;
};

/*!
 * VisualEditor Initialization Target class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Generic Initialization target.
 *
 * @class
 * @abstract
 * @extends OO.ui.Element
 * @mixins OO.EventEmitter
 *
 * @constructor
 * @param {Object} toolbarConfig Configuration options for the toolbar
 */
ve.init.Target = function VeInitTarget( toolbarConfig ) {
	// Parent constructor
	OO.ui.Element.call( this );

	// Mixin constructors
	OO.EventEmitter.call( this );

	// Properties
	this.surfaces = [];
	this.surface = null;
	this.toolbar = null;
	this.toolbarConfig = toolbarConfig;
	this.documentTriggerListener = new ve.TriggerListener( this.constructor.static.documentCommands );
	this.targetTriggerListener = new ve.TriggerListener( this.constructor.static.targetCommands );

	// Initialization
	this.$element.addClass( 've-init-target' );

	if ( ve.init.platform.constructor.static.isInternetExplorer() ) {
		this.$element.addClass( 've-init-target-ie' );
	}

	// Events
	this.onDocumentKeyDownHandler = this.onDocumentKeyDown.bind( this );
	this.onTargetKeyDownHandler = this.onTargetKeyDown.bind( this );
	this.bindHandlers();

	// Register
	ve.init.target = this;
};

/* Inheritance */

OO.inheritClass( ve.init.Target, OO.ui.Element );

OO.mixinClass( ve.init.Target, OO.EventEmitter );

/* Static Properties */

ve.init.Target.static.toolbarGroups = [
	// History
	{
		header: OO.ui.deferMsg( 'visualeditor-toolbar-history' ),
		include: [ 'undo', 'redo' ]
	},
	// Format
	{
		header: OO.ui.deferMsg( 'visualeditor-toolbar-paragraph-format' ),
		type: 'menu',
		indicator: 'down',
		title: OO.ui.deferMsg( 'visualeditor-toolbar-format-tooltip' ),
		include: [ { group: 'format' } ],
		promote: [ 'paragraph' ],
		demote: [ 'preformatted', 'blockquote' ]
	},
	// Text style
	{
		header: OO.ui.deferMsg( 'visualeditor-toolbar-text-style' ),
		title: OO.ui.deferMsg( 'visualeditor-toolbar-style-tooltip' ),
		include: [ 'bold', 'italic', 'moreTextStyle' ]
	},
	// Link
	{
		header: OO.ui.deferMsg( 'visualeditor-linkinspector-title' ),
		include: [ 'link' ]
	},
	// Structure
	{
		header: OO.ui.deferMsg( 'visualeditor-toolbar-structure' ),
		type: 'list',
		icon: 'bullet-list',
		indicator: 'down',
		include: [ { group: 'structure' } ],
		demote: [ 'outdent', 'indent' ]
	},
	// Insert
	{
		header: OO.ui.deferMsg( 'visualeditor-toolbar-insert' ),
		type: 'list',
		icon: 'insert',
		label: '',
		title: OO.ui.deferMsg( 'visualeditor-toolbar-insert' ),
		indicator: 'down',
		include: '*'
	},
	// Special character toolbar
	{
		header: OO.ui.deferMsg( 'visualeditor-toolbar-insert' ),
		include: [ 'specialCharacter' ]
	},
	// Table
	{
		header: OO.ui.deferMsg( 'visualeditor-toolbar-table' ),
		type: 'list',
		icon: 'table-insert',
		indicator: 'down',
		include: [ { group: 'table' } ],
		demote: [ 'deleteTable' ]
	}
];

/**
 * List of commands which can be triggered anywhere from within the document
 *
 * @type {string[]} List of command names
 */
ve.init.Target.static.documentCommands = ['commandHelp'];

/**
 * List of commands which can be triggered from within the target element
 *
 * @type {string[]} List of command names
 */
ve.init.Target.static.targetCommands = ['findAndReplace', 'findNext', 'findPrevious'];

/**
 * List of commands to exclude from the target entirely
 *
 * @type {string[]} List of command names
 */
ve.init.Target.static.excludeCommands = [];

/**
 * Surface import rules
 *
 * One set for external (non-VE) paste sources and one for all paste sources.
 *
 * @see ve.dm.ElementLinearData#sanitize
 * @type {Object}
 */
ve.init.Target.static.importRules = {
	external: {
		blacklist: [
			// Annotations
			// TODO: allow spans
			'textStyle/span',
			// Nodes
			'alienInline', 'alienBlock', 'comment'
		]
	},
	all: null
};

/* Methods */

/**
 * Bind event handlers to target and document
 */
ve.init.Target.prototype.bindHandlers = function () {
	$( this.getElementDocument() ).on( 'keydown', this.onDocumentKeyDownHandler );
	this.$element.on( 'keydown', this.onTargetKeyDownHandler );
};

/**
 * Unbind event handlers on target and document
 */
ve.init.Target.prototype.unbindHandlers = function () {
	$( this.getElementDocument() ).off( 'keydown', this.onDocumentKeyDownHandler );
	this.$element.off( 'keydown', this.onTargetKeyDownHandler );
};

/**
 * Destroy the target
 */
ve.init.Target.prototype.destroy = function () {
	this.clearSurfaces();
	if ( this.toolbar ) {
		this.toolbar.destroy();
		this.toolbar = null;
	}
	this.$element.remove();
	this.unbindHandlers();
	ve.init.target = null;
};

/**
 * Handle key down events on the document
 *
 * @param {jQuery.Event} e Key down event
 */
ve.init.Target.prototype.onDocumentKeyDown = function ( e ) {
	var command, trigger = new ve.ui.Trigger( e );
	if ( trigger.isComplete() ) {
		command = this.documentTriggerListener.getCommandByTrigger( trigger.toString() );
		if ( command && command.execute( this.getSurface() ) ) {
			e.preventDefault();
		}
	}
};

/**
 * Handle key down events on the target
 *
 * @param {jQuery.Event} e Key down event
 */
ve.init.Target.prototype.onTargetKeyDown = function ( e ) {
	var command, trigger = new ve.ui.Trigger( e );
	if ( trigger.isComplete() ) {
		command = this.targetTriggerListener.getCommandByTrigger( trigger.toString() );
		if ( command && command.execute( this.getSurface() ) ) {
			e.preventDefault();
		}
	}
};

/**
 * Create a surface.
 *
 * @method
 * @param {ve.dm.Document} dmDoc Document model
 * @param {Object} [config] Configuration options
 * @returns {ve.ui.Surface}
 */
ve.init.Target.prototype.createSurface = function ( dmDoc, config ) {
	config = ve.extendObject( {
		excludeCommands: OO.simpleArrayUnion(
			this.constructor.static.excludeCommands,
			this.constructor.static.documentCommands,
			this.constructor.static.targetCommands
		),
		importRules: this.constructor.static.importRules
	}, config );
	return new ve.ui.DesktopSurface( new ve.dm.Surface(dmDoc), config );
};

/**
 * Add a surface to the target
 *
 * @param {ve.dm.Document} dmDoc Document model
 * @param {Object} [config] Configuration options
 * @returns {ve.ui.Surface}
 */
ve.init.Target.prototype.addSurface = function ( dmDoc, config ) {
	var surface = this.createSurface( dmDoc, config );
	this.surfaces.push( surface );
	surface.getView().connect( this, { focus: this.onSurfaceViewFocus.bind( this, surface ) } );
	return surface;
};

/**
 * Destroy and remove all surfaces from the target
 */
ve.init.Target.prototype.clearSurfaces = function () {
	while ( this.surfaces.length ) {
		this.surfaces.pop().destroy();
	}
};

/**
 * Handle focus events from a surface's view
 *
 * @param {ve.ui.Surface} surface Surface firing the event
 */
ve.init.Target.prototype.onSurfaceViewFocus = function ( surface ) {
	this.setSurface( surface );
};

/**
 * Set the target's active surface
 *
 * @param {ve.ui.Surface} surface Surface
 */
ve.init.Target.prototype.setSurface = function ( surface ) {
	if ( surface !== this.surface ) {
		this.surface = surface;
		this.setupToolbar( surface );
	}
};

/**
 * Get the target's active surface
 *
 * @return {ve.ui.Surface} Surface
 */
ve.init.Target.prototype.getSurface = function () {
	return this.surface;
};

/**
 * Get the target's toolbar
 *
 * @return {ve.ui.TargetToolbar} Toolbar
 */
ve.init.Target.prototype.getToolbar = function () {
	if ( !this.toolbar ) {
		this.toolbar = new ve.ui.TargetToolbar( this, this.toolbarConfig );
	}
	return this.toolbar;
};

/**
 * Set up the toolbar, attaching it to a surface.
 *
 * @param {ve.ui.Surface} surface Surface
 */
ve.init.Target.prototype.setupToolbar = function ( surface ) {
	this.getToolbar().setup( this.constructor.static.toolbarGroups, surface );
	this.attachToolbar( surface );
	this.getToolbar().$bar.append( surface.getToolbarDialogs().$element );
};

/**
 * Attach the toolbar to the DOM
 */
ve.init.Target.prototype.attachToolbar = function () {
	this.getToolbar().$element.insertBefore( this.getToolbar().getSurface().$element );
};

/*!
 * VisualEditor Range class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * @class
 *
 * @constructor
 * @param {number} from Starting offset
 * @param {number} [to=from] Ending offset
 */
ve.Range = function VeRange( from, to ) {
	this.from = from || 0;
	this.to = to === undefined ? this.from : to;
	this.start = this.from < this.to ? this.from : this.to;
	this.end = this.from < this.to ? this.to : this.from;
};

/* Inheritance */

OO.initClass( ve.Range );

/**
 * @property {number} from Starting offset
 */

/**
 * @property {number} to Ending offset
 */

/**
 * @property {number} start Starting offset (the lesser of #to and #from)
 */

/**
 * @property {number} end Ending offset (the greater of #to and #from)
 */

/* Static Methods */

/**
 * Create a new range from a JSON serialization of a range
 *
 * @see ve.Range#toJSON
 *
 * @param {string} json JSON serialization
 * @return {ve.Range} New range
 */
ve.Range.static.newFromJSON = function ( json ) {
	return this.newFromHash( JSON.parse( json ) );
};

/**
 * Create a new range from a range hash object
 *
 * @see ve.Range#toJSON
 *
 * @param {Object} hash Hash object
 * @return {ve.Range} New range
 */
ve.Range.static.newFromHash = function ( hash ) {
	return new ve.Range( hash.from, hash.to );
};

/**
 * Create a range object that covers all of the given ranges.
 *
 * @static
 * @param {Array} ranges Array of ve.Range objects (at least one)
 * @param {boolean} backwards Return a backwards range
 * @returns {ve.Range} Range that spans all of the given ranges
 */
ve.Range.static.newCoveringRange = function ( ranges, backwards ) {
	var minStart, maxEnd, i, range;
	if ( !ranges || ranges.length === 0 ) {
		throw new Error( 'newCoveringRange() requires at least one range' );
	}
	minStart = ranges[0].start;
	maxEnd = ranges[0].end;
	for ( i = 1; i < ranges.length; i++ ) {
		if ( ranges[i].start < minStart ) {
			minStart = ranges[i].start;
		}
		if ( ranges[i].end > maxEnd ) {
			maxEnd = ranges[i].end;
		}
	}
	if ( backwards ) {
		range = new ve.Range( maxEnd, minStart );
	} else {
		range = new ve.Range( minStart, maxEnd );
	}
	return range;
};

/* Methods */

/**
 * Get a clone.
 *
 * @returns {ve.Range} Clone of range
 */
ve.Range.prototype.clone = function () {
	return new this.constructor( this.from, this.to );
};

/**
 * Check if an offset is within the range.
 *
 * Specifically we mean the whole element at a specific offset, so in effect
 * this is the same as #containsRange( new ve.Range( offset, offset + 1 ) ).
 *
 * @param {number} offset Offset to check
 * @returns {boolean} If offset is within the range
 */
ve.Range.prototype.containsOffset = function ( offset ) {
	return offset >= this.start && offset < this.end;
};

/**
 * Check if another range is within the range.
 *
 * @param {ve.Range} offset Range to check
 * @returns {boolean} If other range is within the range
 */
ve.Range.prototype.containsRange = function ( range ) {
	return range.start >= this.start && range.end <= this.end;
};

/**
 * Check if another range is intersects with this range.
 *
 * @param {ve.Range} other Range to check
 * @returns {boolean} If other range intersects with the range
 */
ve.Range.prototype.intersects = function ( other ) {
	return !(other.end < this.start || other.start > this.end);
};

/**
 * Get the length of the range.
 *
 * @returns {number} Length of range
 */
ve.Range.prototype.getLength = function () {
	return this.end - this.start;
};

/**
 * Gets a range with reversed direction.
 *
 * @returns {ve.Range} A new range
 */
ve.Range.prototype.flip = function () {
	return new ve.Range( this.to, this.from );
};

/**
 * Get a range that's a translated version of this one.
 *
 * @param {number} distance Distance to move range by
 * @returns {ve.Range} New translated range
 */
ve.Range.prototype.translate = function ( distance ) {
	return new ve.Range( this.from + distance, this.to + distance );
};

/**
 * Check if two ranges are equal, taking direction into account.
 *
 * @param {ve.Range|null} other
 * @returns {boolean}
 */
ve.Range.prototype.equals = function ( other ) {
	return other && this.from === other.from && this.to === other.to;
};

/**
 * Check if two ranges are equal, ignoring direction.
 *
 * @param {ve.Range|null} other
 * @returns {boolean}
 */
ve.Range.prototype.equalsSelection = function ( other ) {
	return other && this.end === other.end && this.start === other.start;
};

/**
 * Create a new range with a limited length.
 *
 * @param {number} length Length of the new range (negative for truncate from right)
 * @returns {ve.Range} A new range
 */
ve.Range.prototype.truncate = function ( length ) {
	if ( length >= 0 ) {
		return new ve.Range(
			this.start, Math.min( this.start + length, this.end )
		);
	} else {
		return new ve.Range(
			Math.max( this.end + length, this.start ), this.end
		);
	}
};

/**
 * Expand a range to include another range, preserving direction.
 *
 * @param {ve.Range} other Range to expand to include
 * @return {ve.Range} Range covering this range and other
 */
ve.Range.prototype.expand = function ( other ) {
	return ve.Range.static.newCoveringRange( [this, other], this.isBackwards() );
};

/**
 * Check if the range is collapsed.
 *
 * A collapsed range has equal start and end values making its length zero.
 *
 * @returns {boolean} Range is collapsed
 */
ve.Range.prototype.isCollapsed = function () {
	return this.from === this.to;
};

/**
 * Check if the range is backwards, i.e. from > to
 *
 * @returns {boolean} Range is backwards
 */
ve.Range.prototype.isBackwards = function () {
	return this.from > this.to;
};

/**
 * Get a object summarizing the range for JSON serialization
 *
 * @returns {Object} Object for JSON serialization
 */
ve.Range.prototype.toJSON = function () {
	return {
		type: 'range',
		from: this.from,
		to: this.to
	};
};

/*!
 * VisualEditor Node class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Generic node.
 *
 * @abstract
 * @mixins OO.EventEmitter
 *
 * @constructor
 */
ve.Node = function VeNode() {
	// Properties
	this.type = this.constructor.static.name;
	this.parent = null;
	this.root = null;
	this.doc = null;
};

/**
 * @event attach
 * @param {ve.Node} parent
 */

/**
 * @event detach
 * @param {ve.Node} parent
 */

/**
 * @event root
 */

/**
 * @event unroot
 */

/* Abstract Methods */

/**
 * Get allowed child node types.
 *
 * @method
 * @abstract
 * @returns {string[]|null} List of node types allowed as children or null if any type is allowed
 */
ve.Node.prototype.getChildNodeTypes = function () {
	throw new Error( 've.Node.getChildNodeTypes must be overridden in subclass' );
};

/**
 * Get allowed parent node types.
 *
 * @method
 * @abstract
 * @returns {string[]|null} List of node types allowed as parents or null if any type is allowed
 */
ve.Node.prototype.getParentNodeTypes = function () {
	throw new Error( 've.Node.getParentNodeTypes must be overridden in subclass' );
};

/**
 * Check if the specified type is an allowed child node type
 *
 * @param {string} type Node type
 * @return {boolean} The type is allowed
 */
ve.Node.prototype.isAllowedChildNodeType = function ( type ) {
	var childTypes = this.getChildNodeTypes();
	return childTypes === null || ve.indexOf( type, childTypes ) !== -1;
};

/**
 * Check if the specified type is an allowed child node type
 *
 * @param {string} type Node type
 * @return {boolean} The type is allowed
 */
ve.Node.prototype.isAllowedParentNodeType = function ( type ) {
	var parentTypes = this.getParentNodeTypes();
	return parentTypes === null || ve.indexOf( type, parentTypes ) !== -1;
};

/**
 * Get suggested parent node types.
 *
 * @method
 * @abstract
 * @returns {string[]|null} List of node types suggested as parents or null if any type is suggested
 */
ve.Node.prototype.getSuggestedParentNodeTypes = function () {
	throw new Error( 've.Node.getSuggestedParentNodeTypes must be overridden in subclass' );
};

/**
 * Check if the node can have children.
 *
 * @method
 * @abstract
 * @returns {boolean} Node can have children
 */
ve.Node.prototype.canHaveChildren = function () {
	throw new Error( 've.Node.canHaveChildren must be overridden in subclass' );
};

/**
 * Check if the node can have children but not content nor be content.
 *
 * @method
 * @abstract
 * @returns {boolean} Node can have children but not content nor be content
 */
ve.Node.prototype.canHaveChildrenNotContent = function () {
	throw new Error( 've.Node.canHaveChildrenNotContent must be overridden in subclass' );
};

/**
 * Check if the node can contain content.
 *
 * @method
 * @abstract
 * @returns {boolean} Node can contain content
 */
ve.Node.prototype.canContainContent = function () {
	throw new Error( 've.Node.canContainContent must be overridden in subclass' );
};

/**
 * Check if the node is content.
 *
 * @method
 * @abstract
 * @returns {boolean} Node is content
 */
ve.Node.prototype.isContent = function () {
	throw new Error( 've.Node.isContent must be overridden in subclass' );
};

/**
 * Check if the node has a wrapped element in the document data.
 *
 * @method
 * @abstract
 * @returns {boolean} Node represents a wrapped element
 */
ve.Node.prototype.isWrapped = function () {
	throw new Error( 've.Node.isWrapped must be overridden in subclass' );
};

/**
 * Check if the node is focusable
 *
 * @method
 * @abstract
 * @returns {boolean} Node is focusable
 */
ve.Node.prototype.isFocusable = function () {
	throw new Error( 've.Node.isFocusable must be overridden in subclass' );
};

/**
 * Check if the node is alignable
 *
 * @method
 * @abstract
 * @returns {boolean} Node is alignable
 */
ve.Node.prototype.isAlignable = function () {
	throw new Error( 've.Node.isAlignable must be overridden in subclass' );
};

/**
 * Check if the node has significant whitespace.
 *
 * Can only be true if canContainContent is also true.
 *
 * @method
 * @abstract
 * @returns {boolean} Node has significant whitespace
 */
ve.Node.prototype.hasSignificantWhitespace = function () {
	throw new Error( 've.Node.hasSignificantWhitespace must be overridden in subclass' );
};

/**
 * Check if the node handles its own children
 *
 * @method
 * @abstract
 * @returns {boolean} Node handles its own children
 */
ve.Node.prototype.handlesOwnChildren = function () {
	throw new Error( 've.Node.handlesOwnChildren must be overridden in subclass' );
};

/**
 * Get the length of the node.
 *
 * @method
 * @abstract
 * @returns {number} Node length
 */
ve.Node.prototype.getLength = function () {
	throw new Error( 've.Node.getLength must be overridden in subclass' );
};

/**
 * Get the offset of the node within the document.
 *
 * If the node has no parent than the result will always be 0.
 *
 * @method
 * @abstract
 * @returns {number} Offset of node
 * @throws {Error} Node not found in parent's children array
 */
ve.Node.prototype.getOffset = function () {
	throw new Error( 've.Node.getOffset must be overridden in subclass' );
};

/**
 * Get the range inside the node.
 *
 * @method
 * @param {boolean} backwards Return a backwards range
 * @returns {ve.Range} Inner node range
 */
ve.Node.prototype.getRange = function ( backwards ) {
	var offset = this.getOffset() + ( this.isWrapped() ? 1 : 0 ),
		range = new ve.Range( offset, offset + this.getLength() );
	return backwards ? range.flip() : range;
};

/**
 * Get the outer range of the node, which includes wrappers if present.
 *
 * @method
 * @param {boolean} backwards Return a backwards range
 * @returns {ve.Range} Node outer range
 */
ve.Node.prototype.getOuterRange = function ( backwards ) {
	var range = new ve.Range( this.getOffset(), this.getOffset() + this.getOuterLength() );
	return backwards ? range.flip() : range;
};

/**
 * Get the outer length of the node, which includes wrappers if present.
 *
 * @method
 * @returns {number} Node outer length
 */
ve.Node.prototype.getOuterLength = function () {
	return this.getLength() + ( this.isWrapped() ? 2 : 0 );
};

/* Methods */

/**
 * Get the symbolic node type name.
 *
 * @method
 * @returns {string} Symbolic name of element type
 */
ve.Node.prototype.getType = function () {
	return this.type;
};

/**
 * Get a reference to the node's parent.
 *
 * @method
 * @returns {ve.Node} Reference to the node's parent
 */
ve.Node.prototype.getParent = function () {
	return this.parent;
};

/**
 * Get the root node of the tree the node is currently attached to.
 *
 * @method
 * @returns {ve.Node} Root node
 */
ve.Node.prototype.getRoot = function () {
	return this.root;
};

/**
 * Set the root node.
 *
 * This method is overridden by nodes with children.
 *
 * @method
 * @param {ve.Node} root Node to use as root
 * @fires root
 * @fires unroot
 */
ve.Node.prototype.setRoot = function ( root ) {
	if ( root !== this.root ) {
		this.root = root;
		if ( this.getRoot() ) {
			this.emit( 'root' );
		} else {
			this.emit( 'unroot' );
		}
	}
};

/**
 * Get the document the node is a part of.
 *
 * @method
 * @returns {ve.Document} Document the node is a part of
 */
ve.Node.prototype.getDocument = function () {
	return this.doc;
};

/**
 * Set the document the node is a part of.
 *
 * This method is overridden by nodes with children.
 *
 * @method
 * @param {ve.Document} doc Document this node is a part of
 */
ve.Node.prototype.setDocument = function ( doc ) {
	this.doc = doc;
};

/**
 * Attach the node to another as a child.
 *
 * @method
 * @param {ve.Node} parent Node to attach to
 * @fires attach
 */
ve.Node.prototype.attach = function ( parent ) {
	this.parent = parent;
	this.setRoot( parent.getRoot() );
	this.setDocument( parent.getDocument() );
	this.emit( 'attach', parent );
};

/**
 * Detach the node from its parent.
 *
 * @method
 * @fires detach
 */
ve.Node.prototype.detach = function () {
	var parent = this.parent;
	this.parent = null;
	this.setRoot( null );
	this.setDocument( null );
	this.emit( 'detach', parent );
};

/**
 * Traverse tree of nodes (model or view) upstream.
 *
 * For each traversed node, the callback function will be passed the traversed node as a parameter.
 *
 * @method
 * @param {Function} callback Callback method to be called for every traversed node. Returning false stops the traversal.
 */
ve.Node.prototype.traverseUpstream = function ( callback ) {
	var node = this;
	while ( node ) {
		if ( callback( node ) === false ) {
			break;
		}
		node = node.getParent();
	}
};

/*!
 * VisualEditor BranchNode class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Branch node mixin.
 *
 * Extenders are expected to inherit from ve.Node.
 *
 * Branch nodes are immutable, which is why there are no methods for adding or removing children.
 * DataModel classes will add this functionality, and other subclasses will implement behavior that
 * mimics changes made to DataModel nodes.
 *
 * @class
 * @abstract
 * @constructor
 * @param {ve.Node[]} children Array of children to add
 */
ve.BranchNode = function VeBranchNode( children ) {
	this.children = Array.isArray( children ) ? children : [];
};

/* Methods */

/**
 * Check if the node has children.
 *
 * @method
 * @returns {boolean} Whether the node has children
 */
ve.BranchNode.prototype.hasChildren = function () {
	return true;
};

/**
 * Get child nodes.
 *
 * @method
 * @returns {ve.Node[]} List of child nodes
 */
ve.BranchNode.prototype.getChildren = function () {
	return this.children;
};

/**
 * Get the index of a child node.
 *
 * @method
 * @param {ve.dm.Node} node Child node to find index of
 * @returns {number} Index of child node or -1 if node was not found
 */
ve.BranchNode.prototype.indexOf = function ( node ) {
	return ve.indexOf( node, this.children );
};

/**
 * Set the root node.
 *
 * @method
 * @see ve.Node#setRoot
 * @param {ve.Node} root Node to use as root
 */
ve.BranchNode.prototype.setRoot = function ( root ) {
	if ( root === this.root ) {
		// Nothing to do, don't recurse into all descendants
		return;
	}
	this.root = root;
	for ( var i = 0; i < this.children.length; i++ ) {
		this.children[i].setRoot( root );
	}
};

/**
 * Set the document the node is a part of.
 *
 * @method
 * @see ve.Node#setDocument
 * @param {ve.Document} root Node to use as root
 */
ve.BranchNode.prototype.setDocument = function ( doc ) {
	if ( doc === this.doc ) {
		// Nothing to do, don't recurse into all descendants
		return;
	}
	this.doc = doc;
	for ( var i = 0; i < this.children.length; i++ ) {
		this.children[i].setDocument( doc );
	}
};

/**
 * Get a node from an offset.
 *
 * This method is pretty expensive. If you need to get different slices of the same content, get
 * the content first, then slice it up locally.
 *
 * TODO: Rewrite this method to not use recursion, because the function call overhead is expensive
 *
 * @method
 * @param {number} offset Offset get node for
 * @param {boolean} [shallow] Do not iterate into child nodes of child nodes
 * @returns {ve.Node|null} Node at offset, or null if none was found
 */
ve.BranchNode.prototype.getNodeFromOffset = function ( offset, shallow ) {
	if ( offset === 0 ) {
		return this;
	}
	// TODO a lot of logic is duplicated in selectNodes(), abstract that into a traverser or something
	if ( this.children.length ) {
		var i, length, nodeLength, childNode,
			nodeOffset = 0;
		for ( i = 0, length = this.children.length; i < length; i++ ) {
			childNode = this.children[i];
			if ( offset === nodeOffset ) {
				// The requested offset is right before childNode,
				// so it's not inside any of this's children, but inside this
				return this;
			}
			nodeLength = childNode.getOuterLength();
			if ( offset >= nodeOffset && offset < nodeOffset + nodeLength ) {
				if ( !shallow && childNode.hasChildren() && childNode.getChildren().length ) {
					return this.getNodeFromOffset.call( childNode, offset - nodeOffset - 1 );
				} else {
					return childNode;
				}
			}
			nodeOffset += nodeLength;
		}
		if ( offset === nodeOffset ) {
			// The requested offset is right before this.children[i],
			// so it's not inside any of this's children, but inside this
			return this;
		}
	}
	return null;
};

/*!
 * VisualEditor LeafNode mixin.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Leaf node mixin.
 *
 * @class
 * @abstract
 * @constructor
 */
ve.LeafNode = function VeLeafNode() {
	//
};

/* Methods */

/**
 * Check if the node has children.
 *
 * @method
 * @returns {boolean} Whether the node has children
 */
ve.LeafNode.prototype.hasChildren = function () {
	return false;
};

/*!
 * VisualEditor Document class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Generic document.
 *
 * @class
 * @mixins OO.EventEmitter
 *
 * @constructor
 * @param {ve.Node} documentNode Document node
 */
ve.Document = function VeDocument( documentNode ) {
	// Mixin constructors
	OO.EventEmitter.call( this );

	// Properties
	this.documentNode = documentNode;
};

/* Inheritance */

OO.mixinClass( ve.Document, OO.EventEmitter );

/* Methods */

/**
 * Get the root of the document's node tree.
 *
 * @method
 * @returns {ve.Node} Root of node tree
 */
ve.Document.prototype.getDocumentNode = function () {
	return this.documentNode;
};

/**
 * Get a node a an offset.
 *
 * @method
 * @param {number} offset Offset to get node at
 * @returns {ve.Node|null} Node at offset
 */
ve.Document.prototype.getBranchNodeFromOffset = function ( offset ) {
	var node = this.getDocumentNode().getNodeFromOffset( offset );
	if ( node && !node.hasChildren() ) {
		node = node.getParent();
	}
	return node;
};

/**
 * Gets a list of nodes and the ranges within them that a selection of the document covers.
 *
 * @method
 * @param {ve.Range} range Range within document to select nodes
 * @param {string} [mode='leaves'] Type of selection to perform:
 *
 * - `leaves`: Return all leaf nodes in the given range (descends all the way down)
 * - `branches`': Return all branch nodes in the given range
 * - `covered`: Do not descend into nodes that are entirely covered by the range. The result
 *   is similar to that of 'leaves' except that if a node is entirely covered, its
 *   children aren't returned separately.
 * - `siblings`: Return a set of adjacent siblings covered by the range (descends as long as the
 *   range is in a single node)
 * @returns {Array} List of objects describing nodes in the selection and the ranges therein:
 *
 * - `node`: Reference to a ve.Node
 * - `range`: ve.Range, missing if the entire node is covered
 * - `index`: Index of the node in its parent, missing if node has no parent
 * - `indexInNode`: If range is a zero-length range between two children of node,
 *   this is set to the index of the child following range (or to
 *   `node.children.length + 1` if range is between the last child and
 *   the end). If range is a zero-length range inside an empty non-content branch node, this is 0.
 *   Missing in all other cases.
 * - `nodeRange`: Range covering the inside of the entire node, not including wrapper
 * - `nodeOuterRange`: Range covering the entire node, including wrapper
 * - `parentOuterRange`: Outer range of node's parent. Missing if there is no parent
 *   or if indexInNode is set.
 *
 * @throws {Error} Invalid mode
 * @throws {Error} Invalid start offset
 * @throws {Error} Invalid end offset
 * @throws {Error} Failed to select any nodes
 */
ve.Document.prototype.selectNodes = function ( range, mode ) {
	var node, prevNode, nextNode, left, right, parentFrame,
		startInside, endInside, startBetween, endBetween,
		nodeRange, parentRange,
		isWrapped, isPrevUnwrapped, isNextUnwrapped, isEmptyBranch,
		doc = this.getDocumentNode(),
		retval = [],
		start = range.start,
		end = range.end,
		stack = [ {
			// Node we are currently stepping through
			// Note each iteration visits a child of node, not node itself
			node: doc,
			// Index of the child in node we're visiting
			index: 0,
			// First offset inside node
			startOffset: 0
		} ],
		currentFrame = stack[0],
		startFound = false;

	mode = mode || 'leaves';
	if ( mode !== 'leaves' && mode !== 'branches' && mode !== 'covered' && mode !== 'siblings' ) {
		throw new Error( 'Invalid mode: ' + mode );
	}

	if ( start < 0 || start > doc.getLength() ) {
		throw new Error( 'Invalid start offset: ' + start );
	}
	if ( end < 0 || end > doc.getLength() ) {
		throw new Error( 'Invalid end offset: ' + end );
	}

	if ( !doc.children || doc.children.length === 0 ) {
		// Document has no children. This is weird
		nodeRange = new ve.Range( 0, doc.getLength() );
		return [ {
			node: doc,
			range: new ve.Range( start, end ),
			index: 0,
			nodeRange: nodeRange,
			nodeOuterRange: nodeRange
		} ];
	}
	left = doc.children[0].isWrapped() ? 1 : 0;

	do {
		node = currentFrame.node.children[currentFrame.index];
		prevNode = currentFrame.node.children[currentFrame.index - 1];
		nextNode = currentFrame.node.children[currentFrame.index + 1];
		right = left + node.getLength();
		// Is the start inside node?
		startInside = start >= left && start <= right;
		// Is the end inside node?
		endInside = end >= left && end <= right;
		// Does the node have wrapping elements around it
		isWrapped = node.isWrapped();
		// Is there an unwrapped node right before this node?
		isPrevUnwrapped = prevNode ? !prevNode.isWrapped() : false;
		// Is there an unwrapped node right after this node?
		isNextUnwrapped = nextNode ? !nextNode.isWrapped() : false;
		// Is this node an empty non-content branch node?
		isEmptyBranch = ( node.getLength() === 0 || node.handlesOwnChildren() ) &&
			!node.isContent() && !node.canContainContent();
		// Is the start between prevNode's closing and node or between the parent's opening and node?
		startBetween = ( isWrapped ? start === left - 1 : start === left ) && !isPrevUnwrapped;
		// Is the end between node and nextNode's opening or between node and the parent's closing?
		endBetween = ( isWrapped ? end === right + 1 : end === right ) && !isNextUnwrapped;
		parentRange = new ve.Range(
			currentFrame.startOffset,
			currentFrame.startOffset + currentFrame.node.getLength()
		);

		if ( isWrapped && end === left - 1 && currentFrame.index === 0 ) {
			// The selection ends here with an empty range at the beginning of the node
			// TODO duplicated code
			isWrapped = currentFrame.node.isWrapped();
			retval.push( {
				node: currentFrame.node,
				indexInNode: 0,
				range: new ve.Range( end, end ),
				nodeRange: parentRange,
				nodeOuterRange: new ve.Range(
					parentRange.start - isWrapped, parentRange.end + isWrapped
				)
			} );
			parentFrame = stack[stack.length - 2];
			if ( parentFrame ) {
				retval[retval.length - 1].index = parentFrame.index;
			}
			return retval;
		}

		if ( start === end && ( startBetween || endBetween ) && isWrapped ) {
			// Empty range in the parent, outside of any child
			isWrapped = currentFrame.node.isWrapped();
			retval = [ {
				node: currentFrame.node,
				indexInNode: currentFrame.index + ( endBetween ? 1 : 0 ),
				range: new ve.Range( start, end ),
				nodeRange: parentRange,
				nodeOuterRange: new ve.Range(
					parentRange.start - isWrapped, parentRange.end + isWrapped
				)
			} ];
			parentFrame = stack[stack.length - 2];
			if ( parentFrame ) {
				retval[0].index = parentFrame.index;
			}
			return retval;
		} else if ( startBetween ) {
			// start is between the previous sibling and node
			// so the selection covers all or part of node

			// Descend if
			// - we are in leaves mode, OR
			// - we are in covered mode and the end is inside node OR
			// - we are in branches mode and node is a branch (can have grandchildren)
			// AND
			// the node is non-empty and doesn't handle its own children
			if ( ( mode === 'leaves' ||
					( mode === 'covered' && endInside ) ||
					( mode === 'branches' && node.canHaveChildrenNotContent() ) ) &&
				node.children && node.children.length && !node.handlesOwnChildren()
			) {
				// Descend into node
				currentFrame = {
					node: node,
					index: 0,
					startOffset: left
				};
				stack.push( currentFrame );
				startFound = true;
				// If the first child of node has an opening, skip over it
				if ( node.children[0].isWrapped() ) {
					left++;
				}
				continue;
			} else if ( !endInside ) {
				// All of node is covered
				retval.push( {
					node: node,
					// no 'range' because the entire node is covered
					index: currentFrame.index,
					nodeRange: new ve.Range( left, right ),
					nodeOuterRange: new ve.Range( left - isWrapped, right + isWrapped ),
					parentOuterRange: new ve.Range(
						parentRange.start - currentFrame.node.isWrapped(),
						parentRange.end + currentFrame.node.isWrapped()
					)
				} );
				startFound = true;
			} else {
				// Part of node is covered
				return [ {
					node: node,
					range: new ve.Range( start, end ),
					index: currentFrame.index,
					nodeRange: new ve.Range( left, right ),
					nodeOuterRange: new ve.Range( left - isWrapped, right + isWrapped ),
					parentOuterRange: new ve.Range(
						parentRange.start - currentFrame.node.isWrapped(),
						parentRange.end + currentFrame.node.isWrapped()
					)
				} ];
			}
		} else if ( startInside && endInside ) {
			if ( node.children && node.children.length &&
				( mode !== 'branches' || node.canHaveChildrenNotContent() ) ) {
				// Descend into node
				currentFrame = {
					node: node,
					index: 0,
					startOffset: left
				};
				stack.push( currentFrame );
				// If the first child of node has an opening, skip over it
				if ( node.children[0].isWrapped() ) {
					left++;
				}
				continue;
			} else {
				// node is a leaf node and the range is entirely inside it
				retval = [ {
					node: node,
					range: new ve.Range( start, end ),
					index: currentFrame.index,
					nodeRange: new ve.Range( left, right ),
					nodeOuterRange: new ve.Range( left - isWrapped, right + isWrapped ),
					parentOuterRange: new ve.Range(
						parentRange.start - currentFrame.node.isWrapped(),
						parentRange.end + currentFrame.node.isWrapped()
					)
				} ];
				if ( isEmptyBranch ) {
					retval[0].indexInNode = 0;
				}
				return retval;
			}
		} else if ( startInside ) {
			if ( ( mode === 'leaves' ||
					mode === 'covered' ||
					( mode === 'branches' && node.canHaveChildrenNotContent() ) ) &&
				node.children && node.children.length
			) {
				// node is a branch node and the start is inside it
				// Descend into it
				currentFrame = {
					node: node,
					index: 0,
					startOffset: left
				};
				stack.push( currentFrame );
				// If the first child of node has an opening, skip over it
				if ( node.children[0].isWrapped() ) {
					left++;
				}
				continue;
			} else {
				// node is a leaf node and the start is inside it
				// Add to retval and keep going
				retval.push( {
					node: node,
					range: new ve.Range( start, right ),
					index: currentFrame.index,
					nodeRange: new ve.Range( left, right ),
					nodeOuterRange: new ve.Range( left - isWrapped, right + isWrapped ),
					parentOuterRange: new ve.Range(
						parentRange.start - currentFrame.node.isWrapped(),
						parentRange.end + currentFrame.node.isWrapped()
					)
				} );
				startFound = true;
			}
		} else if ( endBetween ) {
			// end is between node and the next sibling
			// start is not inside node, so the selection covers
			// all of node, then ends

			if (
				( mode === 'leaves' || ( mode === 'branches' && node.canHaveChildrenNotContent() ) ) &&
				node.children && node.children.length
			) {
				// Descend into node
				currentFrame = {
					node: node,
					index: 0,
					startOffset: left
				};
				stack.push( currentFrame );
				// If the first child of node has an opening, skip over it
				if ( node.children[0].isWrapped() ) {
					left++;
				}
				continue;
			} else {
				// All of node is covered
				retval.push( {
					node: node,
					// no 'range' because the entire node is covered
					index: currentFrame.index,
					nodeRange: new ve.Range( left, right ),
					nodeOuterRange: new ve.Range( left - isWrapped, right + isWrapped ),
					parentOuterRange: new ve.Range(
						parentRange.start - currentFrame.node.isWrapped(),
						parentRange.end + currentFrame.node.isWrapped()
					)
				} );
				return retval;
			}
		} else if ( endInside ) {
			if ( ( mode === 'leaves' ||
					mode === 'covered' ||
					( mode === 'branches' && node.canHaveChildrenNotContent() ) ) &&
				node.children && node.children.length
			) {
				// node is a branch node and the end is inside it
				// Descend into it
				currentFrame = {
					node: node,
					index: 0,
					startOffset: left
				};
				stack.push( currentFrame );
				// If the first child of node has an opening, skip over it
				if ( node.children[0].isWrapped() ) {
					left++;
				}
				continue;
			} else {
				// node is a leaf node and the end is inside it
				// Add to retval and return
				retval.push( {
					node: node,
					range: new ve.Range( left, end ),
					index: currentFrame.index,
					nodeRange: new ve.Range( left, right ),
					nodeOuterRange: new ve.Range( left - isWrapped, right + isWrapped ),
					parentOuterRange: new ve.Range(
						parentRange.start - currentFrame.node.isWrapped(),
						parentRange.end + currentFrame.node.isWrapped()
					)
				} );
				return retval;
			}
		} else if ( startFound && end > right ) {
			// Neither the start nor the end is inside node, but we found the start earlier,
			// so node must be between the start and the end
			// Add the entire node, so no range property

			if (
				( mode === 'leaves' || ( mode === 'branches' && node.canHaveChildrenNotContent() ) ) &&
				node.children && node.children.length
			) {
				// Descend into node
				currentFrame = {
					node: node,
					index: 0,
					startOffset: left
				};
				stack.push( currentFrame );
				// If the first child of node has an opening, skip over it
				if ( node.children[0].isWrapped() ) {
					left++;
				}
				continue;
			} else {
				// All of node is covered
				retval.push( {
					node: node,
					// no 'range' because the entire node is covered
					index: currentFrame.index,
					nodeRange: new ve.Range( left, right ),
					nodeOuterRange: new ve.Range( left - isWrapped, right + isWrapped ),
					parentOuterRange: new ve.Range(
						parentRange.start - currentFrame.node.isWrapped(),
						parentRange.end + currentFrame.node.isWrapped()
					)
				} );
			}
		}

		// Move to the next node
		if ( nextNode ) {
			// The next node exists
			// Advance the index; the start of the next iteration will essentially
			// do node = nextNode;
			currentFrame.index++;
			// Advance to the first offset inside nextNode
			left = right +
				// Skip over node's closing, if present
				( node.isWrapped() ? 1 : 0 ) +
				// Skip over nextNode's opening, if present
				( nextNode.isWrapped() ? 1 : 0 );
		} else {
			// There is no next node, move up the stack until there is one
			left = right +
				// Skip over node's closing, if present
				( node.isWrapped() ? 1 : 0 );
			while ( !nextNode ) {
				// Check if the start is right past the end of this node, at the end of
				// the parent
				if ( node.isWrapped() && start === left ) {
					// TODO duplicated code
					parentRange = new ve.Range( currentFrame.startOffset,
						currentFrame.startOffset + currentFrame.node.getLength()
					);
					isWrapped = currentFrame.node.isWrapped();
					retval = [ {
						node: currentFrame.node,
						indexInNode: currentFrame.index + 1,
						range: new ve.Range( left, left ),
						nodeRange: parentRange,
						nodeOuterRange: new ve.Range(
							parentRange.start - isWrapped, parentRange.end + isWrapped
						)
					} ];
					parentFrame = stack[stack.length - 2];
					if ( parentFrame ) {
						retval[0].index = parentFrame.index;
					}
				}

				// Move up the stack
				stack.pop();
				if ( stack.length === 0 ) {
					// This shouldn't be possible
					return retval;
				}
				currentFrame = stack[stack.length - 1];
				currentFrame.index++;
				nextNode = currentFrame.node.children[currentFrame.index];
				// Skip over the parent node's closing
				// (this is present for sure, because the parent has children)
				left++;
			}

			// Skip over nextNode's opening if present
			if ( nextNode.isWrapped() ) {
				left++;
			}
		}
	} while ( end >= left - 1 );
	if ( retval.length === 0 ) {
		throw new Error( 'Failed to select any nodes' );
	}
	return retval;
};

/**
 * Get groups of sibling nodes covered by the given range.
 *
 * @param {ve.Range} range Range
 * @returns {Array} Array of objects. Each object has the following keys:
 *
 *  - nodes: Array of sibling nodes covered by a part of range
 *  - parent: Parent of all of these nodes
 *  - grandparent: parent's parent
 */
ve.Document.prototype.getCoveredSiblingGroups = function ( range ) {
	var i, firstCoveredSibling, lastCoveredSibling, node, parentNode, siblingNode,
		leaves = this.selectNodes( range, 'leaves' ),
		groups = [],
		lastEndOffset = 0;
	for ( i = 0; i < leaves.length; i++ ) {
		if ( leaves[i].nodeOuterRange.end <= lastEndOffset ) {
			// This range is contained within a range we've already processed
			continue;
		}
		node = leaves[i].node;
		// Traverse up to a content branch from content elements
		if ( node.isContent() ) {
			node = node.getParent();
		}
		parentNode = node.getParent();
		if ( !parentNode ) {
			break;
		}
		// Group this with its covered siblings
		groups.push( {
			parent: parentNode,
			grandparent: parentNode.getParent(),
			nodes: []
		} );
		firstCoveredSibling = node;
		// Seek forward to the last covered sibling
		siblingNode = firstCoveredSibling;
		do {
			// Add this to its sibling's group
			groups[groups.length - 1].nodes.push( siblingNode );
			lastCoveredSibling = siblingNode;
			i++;
			if ( leaves[i] === undefined ) {
				break;
			}
			// Traverse up to a content branch from content elements
			siblingNode = leaves[i].node;
			if ( siblingNode.isContent() ) {
				siblingNode = siblingNode.getParent();
			}
		} while ( siblingNode.getParent() === parentNode );
		i--;
		lastEndOffset = parentNode.getOuterRange().end;
	}
	return groups;
};

/**
 * Test whether a range lies within a single leaf node.
 *
 * @param {ve.Range} range The range to test
 * @returns {boolean} Whether the range lies within a single node
 */
ve.Document.prototype.rangeInsideOneLeafNode = function ( range ) {
	var selected = this.selectNodes( range, 'leaves' );
	return selected.length === 1 && selected[0].nodeRange.containsRange( range ) && selected[0].indexInNode === undefined;
};

/*!
 * VisualEditor EventSequencer class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * EventSequencer class with on-event and after-event listeners.
 *
 * After-event listeners are fired as soon as possible after the
 * corresponding native event. They are similar to the setTimeout(f, 0)
 * idiom, except that they are guaranteed to execute before any subsequent
 * on-event listener. Therefore, events are executed in the 'right order'.
 *
 * This matters when many events are added to the task queue in one go.
 * For instance, browsers often queue 'keydown' and 'keypress' in immediate
 * sequence, so a setTimeout(f, 0) defined in the keydown listener will run
 * *after* the keypress listener (i.e. in the 'wrong' order). EventSequencer
 * ensures that this does not happen.
 *
 * All these listeners receive the jQuery event as an argument. If an on-event
 * listener needs to pass information to a corresponding after-event listener,
 * it can do so by adding properties into the jQuery event itself.
 *
 * There are also 'onLoop' and 'afterLoop' listeners, which only fire once per
 * Javascript event loop iteration, respectively before and after all the
 * other listeners fire.
 *
 * There is special handling for sequences (keydown,keypress), where the
 * keypress handler is called before the native keydown action happens. In
 * this case, after-keydown handlers fire after on-keypress handlers.
 *
 * For further event loop / task queue information, see:
 * http://www.whatwg.org/specs/web-apps/current-work/multipage/webappapis.html#event-loops
 *
 * @class ve.EventSequencer
 */

/**
 *
 * To fire after-event listeners promptly, the EventSequencer may need to
 * listen to some events for which it has no registered on-event or
 * after-event listeners. For instance, to ensure an after-keydown listener
 * is be fired before the native keyup action, you must include both
 * 'keydown' and 'keyup' in the eventNames Array.
 *
 * @constructor
 * @param {string[]} eventNames List of event Names to listen to
 */
ve.EventSequencer = function VeEventSequencer( eventNames ) {
	var i, len, eventName, eventSequencer = this;
	this.$node = null;
	this.eventNames = eventNames;
	this.eventHandlers = {};

	/**
	 * Generate an event handler for a specific event
	 *
	 * @private
	 * @param {string} eventName The event's name
	 * @returns {Function} An event handler
	 */
	function makeEventHandler( eventName ) {
		return function ( ev ) {
			return eventSequencer.onEvent( eventName, ev );
		};
	}

	/**
	 * @property {Object[]}
	 *  - id {number} Id for setTimeout
	 *  - func {Function} Post-event listener
	 *  - ev {jQuery.Event} Browser event
	 *  - eventName {string} Name, such as keydown
	 */
	this.pendingCalls = [];

	/**
	 * @property {Object.<string,Function[]>}
	 */
	this.onListenersForEvent = {};

	/**
	 * @property {Object.<string,Function[]>}
	 */
	this.afterListenersForEvent = {};

	/**
	 * @property {Object.<string,Function[]>}
	 */
	this.afterOneListenersForEvent = {};

	for ( i = 0, len = eventNames.length; i < len; i++ ) {
		eventName = eventNames[i];
		this.onListenersForEvent[eventName] = [];
		this.afterListenersForEvent[eventName] = [];
		this.afterOneListenersForEvent[eventName] = [];
		this.eventHandlers[eventName] = makeEventHandler( eventName );
	}

	/**
	 * @property {Function[]}
	 */
	this.onLoopListeners = [];

	/**
	 * @property {Function[]}
	 */
	this.afterLoopListeners = [];

	/**
	 * @property {Function[]}
	 */
	this.afterLoopOneListeners = [];

	/**
	 * @property {boolean}
	 */
	this.doneOnLoop = false;

	/**
	 * @property {number}
	 */
	this.afterLoopTimeoutId = null;
};

/**
 * Attach to a node, to listen to its jQuery events
 *
 * @method
 * @param {jQuery} $node The node to attach to
 * @chainable
 */
ve.EventSequencer.prototype.attach = function ( $node ) {
	this.detach();
	this.$node = $node.on( this.eventHandlers );
	return this;
};

/**
 * Detach from a node (if attached), to stop listen to its jQuery events
 *
 * @method
 * @chainable
 */
ve.EventSequencer.prototype.detach = function () {
	if ( this.$node === null ) {
		return;
	}
	this.runPendingCalls();
	this.$node.off( this.eventHandlers );
	this.$node = null;
	return this;
};

/**
 * Add listeners to be fired at the start of the Javascript event loop iteration
 * @method
 * @param {Function[]} listeners Listeners that take no arguments
 * @chainable
 */
ve.EventSequencer.prototype.onLoop = function ( listeners ) {
	ve.batchPush( this.onLoopListeners, listeners );
	return this;
};

/**
 * Add listeners to be fired just before the browser native action
 * @method
 * @param {Object.<string,Function>} listeners Function for each event
 * @chainable
 */
ve.EventSequencer.prototype.on = function ( listeners ) {
	var eventName;
	for ( eventName in listeners ) {
		this.onListenersForEvent[eventName].push( listeners[eventName] );
	}
	return this;
};

/**
 * Add listeners to be fired as soon as possible after the native action
 * @method
 * @param {Object.<string,Function>} listeners Function for each event
 * @chainable
 */
ve.EventSequencer.prototype.after = function ( listeners ) {
	var eventName;
	for ( eventName in listeners ) {
		this.afterListenersForEvent[eventName].push( listeners[eventName] );
	}
	return this;
};

/**
 * Add listeners to be fired once, as soon as possible after the native action
 * @method
 * @param {Object.<string,Function[]>} listeners Function for each event
 * @chainable
 */
ve.EventSequencer.prototype.afterOne = function ( listeners ) {
	var eventName;
	for ( eventName in listeners ) {
		this.afterOneListenersForEvent[eventName].push( listeners[eventName] );
	}
	return this;
};

/**
 * Add listeners to be fired at the end of the Javascript event loop iteration
 * @method
 * @param {Function|Function[]} listeners Listener(s) that take no arguments
 * @chainable
 */
ve.EventSequencer.prototype.afterLoop = function ( listeners ) {
	if ( !Array.isArray( listeners ) ) {
		listeners = [listeners];
	}
	ve.batchPush( this.afterLoopListeners, listeners );
	return this;
};

/**
 * Add listeners to be fired once, at the end of the Javascript event loop iteration
 * @method
 * @param {Function|Function[]} listeners Listener(s) that take no arguments
 * @chainable
 */
ve.EventSequencer.prototype.afterLoopOne = function ( listeners ) {
	if ( !Array.isArray( listeners ) ) {
		listeners = [listeners];
	}
	ve.batchPush( this.afterLoopOneListeners, listeners );
	return this;
};

/**
 * Generic listener method which does the sequencing
 * @private
 * @method
 * @param {string} eventName Javascript name of the event, e.g. 'keydown'
 * @param {jQuery.Event} ev The browser event
 */
ve.EventSequencer.prototype.onEvent = function ( eventName, ev ) {
	var i, len, onListener, onListeners, pendingCall, eventSequencer, id;
	this.runPendingCalls( eventName );
	if ( !this.doneOnLoop ) {
		this.doneOnLoop = true;
		this.doOnLoop();
	}

	onListeners = this.onListenersForEvent[ eventName ] || [];

	// Length cache 'len' is required, as an onListener could add another onListener
	for ( i = 0, len = onListeners.length; i < len; i++ ) {
		onListener = onListeners[i];
		this.callListener( 'on', eventName, i, onListener, ev );
	}
	// Create a cancellable pending call. We need one even if there are no after*Listeners, to
	// call resetAfterLoopTimeout which resets doneOneLoop to false.
	// - Create the pendingCall object first
	// - then create the setTimeout invocation to modify pendingCall.id
	// - then set pendingCall.id to the setTimeout id, so the call can cancel itself
	pendingCall = { id: null, ev: ev, eventName: eventName };
	eventSequencer = this;
	id = this.postpone( function () {
		if ( pendingCall.id === null ) {
			// clearTimeout seems not always to work immediately
			return;
		}
		eventSequencer.resetAfterLoopTimeout();
		pendingCall.id = null;
		eventSequencer.afterEvent( eventName, ev );
	} );
	pendingCall.id = id;
	this.pendingCalls.push( pendingCall );
};

/**
 * Generic after listener method which gets queued
 * @private
 * @method
 * @param {string} eventName Javascript name of the event, e.g. 'keydown'
 * @param {jQuery.Event} ev The browser event
 */
ve.EventSequencer.prototype.afterEvent = function ( eventName, ev ) {
	var i, len, afterListeners, afterOneListeners;

	// Snapshot the listener lists, and blank *OneListener list.
	// This ensures reasonable behaviour if a function called adds another listener.
	afterListeners = ( this.afterListenersForEvent[eventName] || [] ).slice();
	afterOneListeners = ( this.afterOneListenersForEvent[eventName] || [] ).slice();
	( this.afterOneListenersForEvent[eventName] || [] ).length = 0;

	for ( i = 0, len = afterListeners.length; i < len; i++ ) {
		this.callListener( 'after', eventName, i, afterListeners[i], ev );
	}

	for ( i = 0, len = afterOneListeners.length; i < len; i++ ) {
		this.callListener( 'afterOne', eventName, i, afterOneListeners[i], ev );
	}
};

/**
 * Call each onLoopListener once
 * @private
 * @method
 */
ve.EventSequencer.prototype.doOnLoop = function () {
	var i, len;
	// Length cache 'len' is required, as the functions called may add another listener
	for ( i = 0, len = this.onLoopListeners.length; i < len; i++ ) {
		this.callListener( 'onLoop', null, i, this.onLoopListeners[i], null );
	}
};

/**
 * Call each afterLoopListener once, unless the setTimeout is already cancelled
 * @private
 * @method
 * @param {number} myTimeoutId The calling setTimeout id
 */
ve.EventSequencer.prototype.doAfterLoop = function ( myTimeoutId ) {
	var i, len, afterLoopListeners, afterLoopOneListeners;

	if ( this.afterLoopTimeoutId !== myTimeoutId ) {
		// cancelled; do nothing
		return;
	}
	this.afterLoopTimeoutId = null;

	// Snapshot the listener lists, and blank *OneListener list.
	// This ensures reasonable behaviour if a function called adds another listener.
	afterLoopListeners = this.afterLoopListeners.slice();
	afterLoopOneListeners = this.afterLoopOneListeners.slice();
	this.afterLoopOneListeners.length = 0;

	for ( i = 0, len = this.afterLoopListeners.length; i < len; i++ ) {
		this.callListener( 'afterLoop', null, i, this.afterLoopListeners[i], null );
	}

	for ( i = 0, len = this.afterLoopOneListeners.length; i < len; i++ ) {
		this.callListener( 'afterLoopOne', null, i, this.afterLoopOneListeners[i], null );
	}
};

/**
 * Push any pending doAfterLoop to end of task queue (cancel, then re-set)
 * @private
 * @method
 */
ve.EventSequencer.prototype.resetAfterLoopTimeout = function () {
	var timeoutId, eventSequencer = this;
	if ( this.afterLoopTimeoutId !== null ) {
		this.cancelPostponed( this.afterLoopTimeoutId );
	}
	timeoutId = this.postpone( function () {
		eventSequencer.doAfterLoop( timeoutId );
	} );
	this.afterLoopTimeoutId = timeoutId;
};

/**
 * Run any pending listeners, and clear the pending queue
 * @private
 * @method
 * @param {string} eventName The name of the event currently being triggered
 */
ve.EventSequencer.prototype.runPendingCalls = function ( eventName ) {
	var i, pendingCall,
	afterKeyDownCalls = [];
	for ( i = 0; i < this.pendingCalls.length; i++ ) {
		// Length cache not possible, as a pending call appends another pending call.
		// It's important that this list remains mutable, in the case that this
		// function indirectly recurses.
		pendingCall = this.pendingCalls[i];
		if ( pendingCall.id === null ) {
			// the call has already run
			continue;
		}
		if ( eventName === 'keypress' && pendingCall.eventName === 'keydown' ) {
			// Delay afterKeyDown till after keypress
			afterKeyDownCalls.push( pendingCall );
			continue;
		}

		this.cancelPostponed( pendingCall.id );
		pendingCall.id = null;
		// Force to run now. It's important that we set id to null before running,
		// so that there's no chance a recursive call will call the listener again.
		this.afterEvent( pendingCall.eventName, pendingCall.ev );
	}
	// This is safe: we only ever appended to the list, so it's definitely exhausted now.
	this.pendingCalls.length = 0;
	this.pendingCalls.push.apply( this.pendingCalls, afterKeyDownCalls );
};

/**
 * Make a postponed call.
 *
 * This is a separate function because that makes it easier to replace when testing
 *
 * @param {Function} callback The function to call
 * @returns {number} Unique postponed timeout id
 */
ve.EventSequencer.prototype.postpone = function ( callback ) {
	return setTimeout( callback );
};

/**
 * Cancel a postponed call.
 *
 * This is a separate function because that makes it easier to replace when testing
 *
 * @param {number} callId Unique postponed timeout id
 */
ve.EventSequencer.prototype.cancelPostponed = function ( timeoutId ) {
	clearTimeout( timeoutId );
};

/*
 * Single method to perform all listener calls, for ease of debugging
 * @param {string} timing on|after|afterOne|onLoop|afterLoop|afterLoopOne
 * @param {string} eventName Name of the event
 * @param {number} i The sequence of the listener
 * @param {Function} listener The listener to call
 * @param {jQuery.Event} ev The browser event
 */
ve.EventSequencer.prototype.callListener = function ( timing, eventName, i, listener, ev ) {
	listener( ev );
};

/*!
 * VisualEditor stand-alone Initialization namespace.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Namespace for all VisualEditor stand-alone Initialization classes, static methods and static
 * properties.
 * @class
 * @singleton
 */
ve.init.sa = {
};

/*!
 * VisualEditor Standalone Initialization Platform class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Initialization Standalone platform.
 *
 * @class
 * @extends ve.init.Platform
 *
 * @constructor
 */
ve.init.sa.Platform = function VeInitSaPlatform() {
	// Parent constructor
	ve.init.Platform.call( this );

	// Properties
	this.externalLinkUrlProtocolsRegExp = /^https?\:\/\//;
	this.messagePaths = [];
	this.parsedMessages = {};
	this.userLanguages = ['en'];
};

/* Inheritance */

OO.inheritClass( ve.init.sa.Platform, ve.init.Platform );

/* Methods */

/** @inheritdoc */
ve.init.sa.Platform.prototype.getExternalLinkUrlProtocolsRegExp = function () {
	return this.externalLinkUrlProtocolsRegExp;
};

/**
 * Add an i18n message folder path
 *
 * @param {string} path Message folder path
 */
ve.init.sa.Platform.prototype.addMessagePath = function ( path ) {
	this.messagePaths.push( path );
};

/**
 * Get message folder paths
 *
 * @returns {string[]} Message folder paths
 */
ve.init.sa.Platform.prototype.getMessagePaths = function () {
	return this.messagePaths;
};

/** @inheritdoc */
ve.init.sa.Platform.prototype.addMessages = function ( messages ) {
	$.i18n().load( messages, $.i18n().locale );
};

/**
 * @method
 * @inheritdoc
 */
ve.init.sa.Platform.prototype.getMessage = $.i18n;

/** @inheritdoc */
ve.init.sa.Platform.prototype.addParsedMessages = function ( messages ) {
	for ( var key in messages ) {
		this.parsedMessages[key] = messages[key];
	}
};

/** @inheritdoc */
ve.init.sa.Platform.prototype.getParsedMessage = function ( key ) {
	if ( Object.prototype.hasOwnProperty.call( this.parsedMessages, key ) ) {
		return this.parsedMessages[key];
	}
	// Fallback to regular messages, html escaping applied.
	return this.getMessage( key ).replace( /['"<>&]/g, function escapeCallback( s ) {
		switch ( s ) {
			case '\'':
				return '&#039;';
			case '"':
				return '&quot;';
			case '<':
				return '&lt;';
			case '>':
				return '&gt;';
			case '&':
				return '&amp;';
		}
	} );
};

/** @inheritdoc */
ve.init.sa.Platform.prototype.getLanguageCodes = function () {
	return Object.keys( $.uls.data.getAutonyms() );
};

/**
 * @method
 * @inheritdoc
 */
ve.init.sa.Platform.prototype.getLanguageName = $.uls.data.getAutonym;

/**
 * @method
 * @inheritdoc
 */
ve.init.sa.Platform.prototype.getLanguageAutonym = $.uls.data.getAutonym;

/**
 * @method
 * @inheritdoc
 */
ve.init.sa.Platform.prototype.getLanguageDirection = $.uls.data.getDir;

/** @inheritdoc */
ve.init.sa.Platform.prototype.getUserLanguages = function () {
	return this.userLanguages;
};

/** @inheritdoc */
ve.init.sa.Platform.prototype.initialize = function () {
	var i, iLen, j, jLen, partialLocale, localeParts, filename, deferred,
		messagePaths = this.getMessagePaths(),
		locale = $.i18n().locale,
		languages = [ locale, 'en' ], // Always use 'en' as the final fallback
		languagesCovered = {},
		promises = [],
		fallbacks = $.i18n.fallbacks[locale];

	if ( !fallbacks ) {
		// Try to find something that has fallbacks (which means it's a language we know about)
		// by stripping things from the end. But collect all the intermediate ones in case we
		// go past languages that don't have fallbacks but do exist.
		localeParts = locale.split( '-' );
		localeParts.pop();
		while ( localeParts.length && !fallbacks ) {
			partialLocale = localeParts.join( '-' );
			languages.push( partialLocale );
			fallbacks = $.i18n.fallbacks[partialLocale];
			localeParts.pop();
		}
	}

	if ( fallbacks ) {
		languages = languages.concat( fallbacks );
	}

	this.userLanguages = languages;

	for ( i = 0, iLen = languages.length; i < iLen; i++ ) {
		if ( languagesCovered[languages[i]] ) {
			continue;
		}
		languagesCovered[languages[i]] = true;

		// Lower-case the language code for the filename. jQuery.i18n does not case-fold
		// language codes, so we should not case-fold the second argument in #load.
		filename = languages[i].toLowerCase() + '.json';

		for ( j = 0, jLen = messagePaths.length; j < jLen; j++ ) {
			deferred = $.Deferred();
			$.i18n().load( messagePaths[j] + filename, languages[i] )
				.always( deferred.resolve );
			promises.push( deferred.promise() );
		}
	}
	return $.when.apply( $, promises );
};

/* Initialization */

ve.init.platform = new ve.init.sa.Platform();

/* Extension */

OO.ui.getUserLanguages = ve.init.platform.getUserLanguages.bind( ve.init.platform );

OO.ui.msg = ve.init.platform.getMessage.bind( ve.init.platform );

/*!
 * VisualEditor Standalone Initialization Target class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Initialization Standalone target.
 *
 * @class
 * @extends ve.init.Target
 *
 * @constructor
 * @param {string} [surfaceType] Type of surface to use, 'desktop' or 'mobile'
 * @throws {Error} Unknown surfaceType
 */
ve.init.sa.Target = function VeInitSaTarget( surfaceType ) {
	// Parent constructor
	ve.init.Target.call( this, { shadow: true, actions: true, floatable: true } );

	this.surfaceType = surfaceType || this.constructor.static.defaultSurfaceType;
	this.actions = null;

	switch ( this.surfaceType ) {
		case 'desktop':
			this.surfaceClass = ve.ui.DesktopSurface;
			break;
		case 'mobile':
			this.surfaceClass = ve.ui.MobileSurface;
			break;
		default:
			throw new Error( 'Unknown surfaceType: ' + this.surfaceType );
	}

	// The following classes can be used here:
	// ve-init-sa-target-mobile
	// ve-init-sa-target-desktop
	this.$element.addClass( 've-init-sa-target ve-init-sa-target-' + this.surfaceType );
};

/* Inheritance */

OO.inheritClass( ve.init.sa.Target, ve.init.Target );

/* Static properties */

ve.init.sa.Target.static.defaultSurfaceType = 'desktop';

/* Methods */

/**
 * @inheritdoc
 */
ve.init.sa.Target.prototype.addSurface = function () {
	var surface = ve.init.sa.Target.super.prototype.addSurface.apply( this, arguments );
	this.$element.append( $( '<div>' ).append( surface.$element ) );
	if ( !this.getSurface() ) {
		this.setSurface( surface );
	}
	surface.initialize();
	return surface;
};

/**
 * @inheritdoc
 */
ve.init.sa.Target.prototype.createSurface = function ( dmDoc, config ) {
	config = ve.extendObject( {
		excludeCommands: OO.simpleArrayUnion(
			this.constructor.static.excludeCommands,
			this.constructor.static.documentCommands,
			this.constructor.static.targetCommands
		),
		importRules: this.constructor.static.importRules
	}, config );
	return new this.surfaceClass( new ve.dm.Surface(dmDoc), config );
};

/**
 * @inheritdoc
 */
ve.init.sa.Target.prototype.setupToolbar = function ( surface ) {
	// Parent method
	ve.init.sa.Target.super.prototype.setupToolbar.call( this, surface );

	if ( !this.getToolbar().initialized ) {
		this.getToolbar().$element.addClass( 've-init-sa-target-toolbar' );
		this.actions = new ve.ui.TargetToolbar( this );
		this.getToolbar().$actions.append( this.actions.$element );
	}
	this.getToolbar().initialize();

	this.actions.setup( [
		{
			type: 'list',
			icon: 'menu',
			title: ve.msg( 'visualeditor-pagemenu-tooltip' ),
			include: [ 'findAndReplace', 'commandHelp' ]
		}
	], this.getSurface() );

	// HACK: On mobile place the context inside toolbar.$bar which floats
	if ( this.surfaceType === 'mobile' ) {
		this.getToolbar().$bar.append( surface.context.$element );
	}
};
