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
		 * the json formatted messages. Example:
		 * <code>load('path/to/all_localizations.json');</code>
		 *
		 * To load a localization file for a locale:
		 * <code>
		 * load('path/to/de-messages.json', 'de' );
		 * </code>
		 *
		 * To load a localization file from a directory:
		 * <code>
		 * load('path/to/i18n/directory', 'de' );
		 * </code>
		 * The above method has the advantage of fallback resolution.
		 * ie, it will automatically load the fallback locales for de.
		 * For most usecases, this is the recommended method.
		 * It is optional to have trailing slash at end.
		 *
		 * A data object containing message key- message translation mappings
		 * can also be passed. Example:
		 * <code>
		 * load( { 'hello' : 'Hello' }, optionalLocale );
		 * </code>
		 *
		 * A source map containing key-value pair of languagename and locations
		 * can also be passed. Example:
		 * <code>
		 * load( {
		 * bn: 'i18n/bn.json',
		 * he: 'i18n/he.json',
		 * en: 'i18n/en.json'
		 * } )
		 * </code>
		 *
		 * If the data argument is null/undefined/false,
		 * all cached messages for the i18n instance will get reset.
		 *
		 * @param {String|Object} source
		 * @param {String} locale Language tag
		 * @return {jQuery.Promise}
		 */
		load: function ( source, locale ) {
			var fallbackLocales, locIndex, fallbackLocale, sourceMap = {};
			if ( !source && !locale ) {
				source = 'i18n/' + $.i18n().locale + '.json';
				locale = $.i18n().locale;
			}
			if ( typeof source === 'string'	&&
				source.split( '.' ).pop() !== 'json'
			) {
				// Load specified locale then check for fallbacks when directory is specified in load()
				sourceMap[locale] = source + '/' + locale + '.json';
				fallbackLocales = ( $.i18n.fallbacks[locale] || [] )
					.concat( this.options.fallbackLocale );
				for ( locIndex in fallbackLocales ) {
					fallbackLocale = fallbackLocales[locIndex];
					sourceMap[fallbackLocale] = source + '/' + fallbackLocale + '.json';
				}
				return this.load( sourceMap );
			} else {
				return this.messageStore.load( source, locale );
			}

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
			if ( message === '' ) {
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
		set: function ( locale, messages ) {
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
		 * @return {Boolean}
		 */
		get: function ( locale, messageKey ) {
			return this.messages[locale] && this.messages[locale][messageKey];
		}
	};

	function jsonMessageLoader( url ) {
		var deferred = $.Deferred();

		$.getJSON( url )
			.done( deferred.resolve )
			.fail( function ( jqxhr, settings, exception ) {
				$.i18n.log( 'Error in loading messages from ' + url + ' Exception: ' + exception );
				// Ignore 404 exception, because we are handling fallabacks explicitly
				deferred.resolve();
			} );

		return deferred.promise();
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
			function choice( parserSyntax ) {
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
			function sequence( parserSyntax ) {
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
			function nOrMore( n, p ) {
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

			function makeStringParser( s ) {
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

			function makeRegexParser( regex ) {
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
			function transform( p, fn ) {
				return function () {
					var result = p();

					return result === null ? null : fn( result );
				};
			}

			// Used to define "literals" within template parameters. The pipe
			// character is the parameter delimeter, so by default
			// it is not a literal in the parameter
			function literalWithoutBar() {
				var result = nOrMore( 1, escapedOrLiteralWithoutBar )();

				return result === null ? null : result.join( '' );
			}

			function literal() {
				var result = nOrMore( 1, escapedOrRegularLiteral )();

				return result === null ? null : result.join( '' );
			}

			function escapedLiteral() {
				var result = sequence( [ backslash, anyCharacter ] );

				return result === null ? null : result[1];
			}

			choice( [ escapedLiteral, regularLiteralWithoutSpace ] );
			escapedOrLiteralWithoutBar = choice( [ escapedLiteral, regularLiteralWithoutBar ] );
			escapedOrRegularLiteral = choice( [ escapedLiteral, regularLiteral ] );

			function replacement() {
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

			function templateParam() {
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

			function templateWithReplacement() {
				var result = sequence( [ templateName, colon, replacement ] );

				return result === null ? null : [ result[0], result[2] ];
			}

			function templateWithOutReplacement() {
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

			function template() {
				var result = sequence( [ openTemplate, templateContents, closeTemplate ] );

				return result === null ? null : result[1];
			}

			expression = choice( [ template, replacement, literal ] );
			paramExpression = choice( [ template, replacement, literalWithoutBar ] );

			function start() {
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

/**
 * BIDI embedding support for jQuery.i18n
 *
 * Copyright (C) 2015, David Chan
 *
 * This code is dual licensed GPLv2 or later and MIT. You don't have to do
 * anything special to choose one license or the other and you don't have to
 * notify anyone which license you are using. You are free to use this code
 * in commercial projects as long as the copyright header is left intact.
 * See files GPL-LICENSE and MIT-LICENSE for details.
 *
 * @licence GNU General Public Licence 2.0 or later
 * @licence MIT License
 */

( function ( $ ) {
	'use strict';
	var strongDirRegExp;

	/**
	 * Matches the first strong directionality codepoint:
	 * - in group 1 if it is LTR
	 * - in group 2 if it is RTL
	 * Does not match if there is no strong directionality codepoint.
	 *
	 * Generated by UnicodeJS (see tools/strongDir) from the UCD; see
	 * https://git.wikimedia.org/summary/unicodejs.git .
	 */
	strongDirRegExp = new RegExp(
		'(?:' +
			'(' +
				'[\u0041-\u005a\u0061-\u007a\u00aa\u00b5\u00ba\u00c0-\u00d6\u00d8-\u00f6\u00f8-\u02b8\u02bb-\u02c1\u02d0\u02d1\u02e0-\u02e4\u02ee\u0370-\u0373\u0376\u0377\u037a-\u037d\u037f\u0386\u0388-\u038a\u038c\u038e-\u03a1\u03a3-\u03f5\u03f7-\u0482\u048a-\u052f\u0531-\u0556\u0559-\u055f\u0561-\u0587\u0589\u0903-\u0939\u093b\u093d-\u0940\u0949-\u094c\u094e-\u0950\u0958-\u0961\u0964-\u0980\u0982\u0983\u0985-\u098c\u098f\u0990\u0993-\u09a8\u09aa-\u09b0\u09b2\u09b6-\u09b9\u09bd-\u09c0\u09c7\u09c8\u09cb\u09cc\u09ce\u09d7\u09dc\u09dd\u09df-\u09e1\u09e6-\u09f1\u09f4-\u09fa\u0a03\u0a05-\u0a0a\u0a0f\u0a10\u0a13-\u0a28\u0a2a-\u0a30\u0a32\u0a33\u0a35\u0a36\u0a38\u0a39\u0a3e-\u0a40\u0a59-\u0a5c\u0a5e\u0a66-\u0a6f\u0a72-\u0a74\u0a83\u0a85-\u0a8d\u0a8f-\u0a91\u0a93-\u0aa8\u0aaa-\u0ab0\u0ab2\u0ab3\u0ab5-\u0ab9\u0abd-\u0ac0\u0ac9\u0acb\u0acc\u0ad0\u0ae0\u0ae1\u0ae6-\u0af0\u0af9\u0b02\u0b03\u0b05-\u0b0c\u0b0f\u0b10\u0b13-\u0b28\u0b2a-\u0b30\u0b32\u0b33\u0b35-\u0b39\u0b3d\u0b3e\u0b40\u0b47\u0b48\u0b4b\u0b4c\u0b57\u0b5c\u0b5d\u0b5f-\u0b61\u0b66-\u0b77\u0b83\u0b85-\u0b8a\u0b8e-\u0b90\u0b92-\u0b95\u0b99\u0b9a\u0b9c\u0b9e\u0b9f\u0ba3\u0ba4\u0ba8-\u0baa\u0bae-\u0bb9\u0bbe\u0bbf\u0bc1\u0bc2\u0bc6-\u0bc8\u0bca-\u0bcc\u0bd0\u0bd7\u0be6-\u0bf2\u0c01-\u0c03\u0c05-\u0c0c\u0c0e-\u0c10\u0c12-\u0c28\u0c2a-\u0c39\u0c3d\u0c41-\u0c44\u0c58-\u0c5a\u0c60\u0c61\u0c66-\u0c6f\u0c7f\u0c82\u0c83\u0c85-\u0c8c\u0c8e-\u0c90\u0c92-\u0ca8\u0caa-\u0cb3\u0cb5-\u0cb9\u0cbd-\u0cc4\u0cc6-\u0cc8\u0cca\u0ccb\u0cd5\u0cd6\u0cde\u0ce0\u0ce1\u0ce6-\u0cef\u0cf1\u0cf2\u0d02\u0d03\u0d05-\u0d0c\u0d0e-\u0d10\u0d12-\u0d3a\u0d3d-\u0d40\u0d46-\u0d48\u0d4a-\u0d4c\u0d4e\u0d57\u0d5f-\u0d61\u0d66-\u0d75\u0d79-\u0d7f\u0d82\u0d83\u0d85-\u0d96\u0d9a-\u0db1\u0db3-\u0dbb\u0dbd\u0dc0-\u0dc6\u0dcf-\u0dd1\u0dd8-\u0ddf\u0de6-\u0def\u0df2-\u0df4\u0e01-\u0e30\u0e32\u0e33\u0e40-\u0e46\u0e4f-\u0e5b\u0e81\u0e82\u0e84\u0e87\u0e88\u0e8a\u0e8d\u0e94-\u0e97\u0e99-\u0e9f\u0ea1-\u0ea3\u0ea5\u0ea7\u0eaa\u0eab\u0ead-\u0eb0\u0eb2\u0eb3\u0ebd\u0ec0-\u0ec4\u0ec6\u0ed0-\u0ed9\u0edc-\u0edf\u0f00-\u0f17\u0f1a-\u0f34\u0f36\u0f38\u0f3e-\u0f47\u0f49-\u0f6c\u0f7f\u0f85\u0f88-\u0f8c\u0fbe-\u0fc5\u0fc7-\u0fcc\u0fce-\u0fda\u1000-\u102c\u1031\u1038\u103b\u103c\u103f-\u1057\u105a-\u105d\u1061-\u1070\u1075-\u1081\u1083\u1084\u1087-\u108c\u108e-\u109c\u109e-\u10c5\u10c7\u10cd\u10d0-\u1248\u124a-\u124d\u1250-\u1256\u1258\u125a-\u125d\u1260-\u1288\u128a-\u128d\u1290-\u12b0\u12b2-\u12b5\u12b8-\u12be\u12c0\u12c2-\u12c5\u12c8-\u12d6\u12d8-\u1310\u1312-\u1315\u1318-\u135a\u1360-\u137c\u1380-\u138f\u13a0-\u13f5\u13f8-\u13fd\u1401-\u167f\u1681-\u169a\u16a0-\u16f8\u1700-\u170c\u170e-\u1711\u1720-\u1731\u1735\u1736\u1740-\u1751\u1760-\u176c\u176e-\u1770\u1780-\u17b3\u17b6\u17be-\u17c5\u17c7\u17c8\u17d4-\u17da\u17dc\u17e0-\u17e9\u1810-\u1819\u1820-\u1877\u1880-\u18a8\u18aa\u18b0-\u18f5\u1900-\u191e\u1923-\u1926\u1929-\u192b\u1930\u1931\u1933-\u1938\u1946-\u196d\u1970-\u1974\u1980-\u19ab\u19b0-\u19c9\u19d0-\u19da\u1a00-\u1a16\u1a19\u1a1a\u1a1e-\u1a55\u1a57\u1a61\u1a63\u1a64\u1a6d-\u1a72\u1a80-\u1a89\u1a90-\u1a99\u1aa0-\u1aad\u1b04-\u1b33\u1b35\u1b3b\u1b3d-\u1b41\u1b43-\u1b4b\u1b50-\u1b6a\u1b74-\u1b7c\u1b82-\u1ba1\u1ba6\u1ba7\u1baa\u1bae-\u1be5\u1be7\u1bea-\u1bec\u1bee\u1bf2\u1bf3\u1bfc-\u1c2b\u1c34\u1c35\u1c3b-\u1c49\u1c4d-\u1c7f\u1cc0-\u1cc7\u1cd3\u1ce1\u1ce9-\u1cec\u1cee-\u1cf3\u1cf5\u1cf6\u1d00-\u1dbf\u1e00-\u1f15\u1f18-\u1f1d\u1f20-\u1f45\u1f48-\u1f4d\u1f50-\u1f57\u1f59\u1f5b\u1f5d\u1f5f-\u1f7d\u1f80-\u1fb4\u1fb6-\u1fbc\u1fbe\u1fc2-\u1fc4\u1fc6-\u1fcc\u1fd0-\u1fd3\u1fd6-\u1fdb\u1fe0-\u1fec\u1ff2-\u1ff4\u1ff6-\u1ffc\u200e\u2071\u207f\u2090-\u209c\u2102\u2107\u210a-\u2113\u2115\u2119-\u211d\u2124\u2126\u2128\u212a-\u212d\u212f-\u2139\u213c-\u213f\u2145-\u2149\u214e\u214f\u2160-\u2188\u2336-\u237a\u2395\u249c-\u24e9\u26ac\u2800-\u28ff\u2c00-\u2c2e\u2c30-\u2c5e\u2c60-\u2ce4\u2ceb-\u2cee\u2cf2\u2cf3\u2d00-\u2d25\u2d27\u2d2d\u2d30-\u2d67\u2d6f\u2d70\u2d80-\u2d96\u2da0-\u2da6\u2da8-\u2dae\u2db0-\u2db6\u2db8-\u2dbe\u2dc0-\u2dc6\u2dc8-\u2dce\u2dd0-\u2dd6\u2dd8-\u2dde\u3005-\u3007\u3021-\u3029\u302e\u302f\u3031-\u3035\u3038-\u303c\u3041-\u3096\u309d-\u309f\u30a1-\u30fa\u30fc-\u30ff\u3105-\u312d\u3131-\u318e\u3190-\u31ba\u31f0-\u321c\u3220-\u324f\u3260-\u327b\u327f-\u32b0\u32c0-\u32cb\u32d0-\u32fe\u3300-\u3376\u337b-\u33dd\u33e0-\u33fe\u3400-\u4db5\u4e00-\u9fd5\ua000-\ua48c\ua4d0-\ua60c\ua610-\ua62b\ua640-\ua66e\ua680-\ua69d\ua6a0-\ua6ef\ua6f2-\ua6f7\ua722-\ua787\ua789-\ua7ad\ua7b0-\ua7b7\ua7f7-\ua801\ua803-\ua805\ua807-\ua80a\ua80c-\ua824\ua827\ua830-\ua837\ua840-\ua873\ua880-\ua8c3\ua8ce-\ua8d9\ua8f2-\ua8fd\ua900-\ua925\ua92e-\ua946\ua952\ua953\ua95f-\ua97c\ua983-\ua9b2\ua9b4\ua9b5\ua9ba\ua9bb\ua9bd-\ua9cd\ua9cf-\ua9d9\ua9de-\ua9e4\ua9e6-\ua9fe\uaa00-\uaa28\uaa2f\uaa30\uaa33\uaa34\uaa40-\uaa42\uaa44-\uaa4b\uaa4d\uaa50-\uaa59\uaa5c-\uaa7b\uaa7d-\uaaaf\uaab1\uaab5\uaab6\uaab9-\uaabd\uaac0\uaac2\uaadb-\uaaeb\uaaee-\uaaf5\uab01-\uab06\uab09-\uab0e\uab11-\uab16\uab20-\uab26\uab28-\uab2e\uab30-\uab65\uab70-\uabe4\uabe6\uabe7\uabe9-\uabec\uabf0-\uabf9\uac00-\ud7a3\ud7b0-\ud7c6\ud7cb-\ud7fb\ue000-\ufa6d\ufa70-\ufad9\ufb00-\ufb06\ufb13-\ufb17\uff21-\uff3a\uff41-\uff5a\uff66-\uffbe\uffc2-\uffc7\uffca-\uffcf\uffd2-\uffd7\uffda-\uffdc]|\ud800[\udc00-\udc0b]|\ud800[\udc0d-\udc26]|\ud800[\udc28-\udc3a]|\ud800\udc3c|\ud800\udc3d|\ud800[\udc3f-\udc4d]|\ud800[\udc50-\udc5d]|\ud800[\udc80-\udcfa]|\ud800\udd00|\ud800\udd02|\ud800[\udd07-\udd33]|\ud800[\udd37-\udd3f]|\ud800[\uddd0-\uddfc]|\ud800[\ude80-\ude9c]|\ud800[\udea0-\uded0]|\ud800[\udf00-\udf23]|\ud800[\udf30-\udf4a]|\ud800[\udf50-\udf75]|\ud800[\udf80-\udf9d]|\ud800[\udf9f-\udfc3]|\ud800[\udfc8-\udfd5]|\ud801[\udc00-\udc9d]|\ud801[\udca0-\udca9]|\ud801[\udd00-\udd27]|\ud801[\udd30-\udd63]|\ud801\udd6f|\ud801[\ude00-\udf36]|\ud801[\udf40-\udf55]|\ud801[\udf60-\udf67]|\ud804\udc00|\ud804[\udc02-\udc37]|\ud804[\udc47-\udc4d]|\ud804[\udc66-\udc6f]|\ud804[\udc82-\udcb2]|\ud804\udcb7|\ud804\udcb8|\ud804[\udcbb-\udcc1]|\ud804[\udcd0-\udce8]|\ud804[\udcf0-\udcf9]|\ud804[\udd03-\udd26]|\ud804\udd2c|\ud804[\udd36-\udd43]|\ud804[\udd50-\udd72]|\ud804[\udd74-\udd76]|\ud804[\udd82-\uddb5]|\ud804[\uddbf-\uddc9]|\ud804\uddcd|\ud804[\uddd0-\udddf]|\ud804[\udde1-\uddf4]|\ud804[\ude00-\ude11]|\ud804[\ude13-\ude2e]|\ud804\ude32|\ud804\ude33|\ud804\ude35|\ud804[\ude38-\ude3d]|\ud804[\ude80-\ude86]|\ud804\ude88|\ud804[\ude8a-\ude8d]|\ud804[\ude8f-\ude9d]|\ud804[\ude9f-\udea9]|\ud804[\udeb0-\udede]|\ud804[\udee0-\udee2]|\ud804[\udef0-\udef9]|\ud804\udf02|\ud804\udf03|\ud804[\udf05-\udf0c]|\ud804\udf0f|\ud804\udf10|\ud804[\udf13-\udf28]|\ud804[\udf2a-\udf30]|\ud804\udf32|\ud804\udf33|\ud804[\udf35-\udf39]|\ud804[\udf3d-\udf3f]|\ud804[\udf41-\udf44]|\ud804\udf47|\ud804\udf48|\ud804[\udf4b-\udf4d]|\ud804\udf50|\ud804\udf57|\ud804[\udf5d-\udf63]|\ud805[\udc80-\udcb2]|\ud805\udcb9|\ud805[\udcbb-\udcbe]|\ud805\udcc1|\ud805[\udcc4-\udcc7]|\ud805[\udcd0-\udcd9]|\ud805[\udd80-\uddb1]|\ud805[\uddb8-\uddbb]|\ud805\uddbe|\ud805[\uddc1-\udddb]|\ud805[\ude00-\ude32]|\ud805\ude3b|\ud805\ude3c|\ud805\ude3e|\ud805[\ude41-\ude44]|\ud805[\ude50-\ude59]|\ud805[\ude80-\udeaa]|\ud805\udeac|\ud805\udeae|\ud805\udeaf|\ud805\udeb6|\ud805[\udec0-\udec9]|\ud805[\udf00-\udf19]|\ud805\udf20|\ud805\udf21|\ud805\udf26|\ud805[\udf30-\udf3f]|\ud806[\udca0-\udcf2]|\ud806\udcff|\ud806[\udec0-\udef8]|\ud808[\udc00-\udf99]|\ud809[\udc00-\udc6e]|\ud809[\udc70-\udc74]|\ud809[\udc80-\udd43]|\ud80c[\udc00-\udfff]|\ud80d[\udc00-\udc2e]|\ud811[\udc00-\ude46]|\ud81a[\udc00-\ude38]|\ud81a[\ude40-\ude5e]|\ud81a[\ude60-\ude69]|\ud81a\ude6e|\ud81a\ude6f|\ud81a[\uded0-\udeed]|\ud81a\udef5|\ud81a[\udf00-\udf2f]|\ud81a[\udf37-\udf45]|\ud81a[\udf50-\udf59]|\ud81a[\udf5b-\udf61]|\ud81a[\udf63-\udf77]|\ud81a[\udf7d-\udf8f]|\ud81b[\udf00-\udf44]|\ud81b[\udf50-\udf7e]|\ud81b[\udf93-\udf9f]|\ud82c\udc00|\ud82c\udc01|\ud82f[\udc00-\udc6a]|\ud82f[\udc70-\udc7c]|\ud82f[\udc80-\udc88]|\ud82f[\udc90-\udc99]|\ud82f\udc9c|\ud82f\udc9f|\ud834[\udc00-\udcf5]|\ud834[\udd00-\udd26]|\ud834[\udd29-\udd66]|\ud834[\udd6a-\udd72]|\ud834\udd83|\ud834\udd84|\ud834[\udd8c-\udda9]|\ud834[\uddae-\udde8]|\ud834[\udf60-\udf71]|\ud835[\udc00-\udc54]|\ud835[\udc56-\udc9c]|\ud835\udc9e|\ud835\udc9f|\ud835\udca2|\ud835\udca5|\ud835\udca6|\ud835[\udca9-\udcac]|\ud835[\udcae-\udcb9]|\ud835\udcbb|\ud835[\udcbd-\udcc3]|\ud835[\udcc5-\udd05]|\ud835[\udd07-\udd0a]|\ud835[\udd0d-\udd14]|\ud835[\udd16-\udd1c]|\ud835[\udd1e-\udd39]|\ud835[\udd3b-\udd3e]|\ud835[\udd40-\udd44]|\ud835\udd46|\ud835[\udd4a-\udd50]|\ud835[\udd52-\udea5]|\ud835[\udea8-\udeda]|\ud835[\udedc-\udf14]|\ud835[\udf16-\udf4e]|\ud835[\udf50-\udf88]|\ud835[\udf8a-\udfc2]|\ud835[\udfc4-\udfcb]|\ud836[\udc00-\uddff]|\ud836[\ude37-\ude3a]|\ud836[\ude6d-\ude74]|\ud836[\ude76-\ude83]|\ud836[\ude85-\ude8b]|\ud83c[\udd10-\udd2e]|\ud83c[\udd30-\udd69]|\ud83c[\udd70-\udd9a]|\ud83c[\udde6-\ude02]|\ud83c[\ude10-\ude3a]|\ud83c[\ude40-\ude48]|\ud83c\ude50|\ud83c\ude51|[\ud840-\ud868][\udc00-\udfff]|\ud869[\udc00-\uded6]|\ud869[\udf00-\udfff]|[\ud86a-\ud86c][\udc00-\udfff]|\ud86d[\udc00-\udf34]|\ud86d[\udf40-\udfff]|\ud86e[\udc00-\udc1d]|\ud86e[\udc20-\udfff]|[\ud86f-\ud872][\udc00-\udfff]|\ud873[\udc00-\udea1]|\ud87e[\udc00-\ude1d]|[\udb80-\udbbe][\udc00-\udfff]|\udbbf[\udc00-\udffd]|[\udbc0-\udbfe][\udc00-\udfff]|\udbff[\udc00-\udffd]' +
			')|(' +
				'[\u0590\u05be\u05c0\u05c3\u05c6\u05c8-\u05ff\u07c0-\u07ea\u07f4\u07f5\u07fa-\u0815\u081a\u0824\u0828\u082e-\u0858\u085c-\u089f\u200f\ufb1d\ufb1f-\ufb28\ufb2a-\ufb4f\u0608\u060b\u060d\u061b-\u064a\u066d-\u066f\u0671-\u06d5\u06e5\u06e6\u06ee\u06ef\u06fa-\u0710\u0712-\u072f\u074b-\u07a5\u07b1-\u07bf\u08a0-\u08e2\ufb50-\ufd3d\ufd40-\ufdcf\ufdf0-\ufdfc\ufdfe\ufdff\ufe70-\ufefe]|\ud802[\udc00-\udd1e]|\ud802[\udd20-\ude00]|\ud802\ude04|\ud802[\ude07-\ude0b]|\ud802[\ude10-\ude37]|\ud802[\ude3b-\ude3e]|\ud802[\ude40-\udee4]|\ud802[\udee7-\udf38]|\ud802[\udf40-\udfff]|\ud803[\udc00-\ude5f]|\ud803[\ude7f-\udfff]|\ud83a[\udc00-\udccf]|\ud83a[\udcd7-\udfff]|\ud83b[\udc00-\uddff]|\ud83b[\udf00-\udfff]|\ud83b[\udf00-\udfff]|\ud83b[\udf00-\udfff]|\ud83b[\udf00-\udfff]|\ud83b[\udf00-\udfff]|\ud83b[\udf00-\udfff]|\ud83b[\udf00-\udfff]|\ud83b[\udf00-\udfff]|\ud83b[\udf00-\udfff]|\ud83b[\udf00-\udfff]|\ud83b[\udf00-\udfff]|\ud83b[\udf00-\udfff]|\ud83b[\udf00-\udfff]|\ud83b[\ude00-\udeef]|\ud83b[\udef2-\udeff]' +
			')' +
		')'
	);

	/**
	 * Gets directionality of the first strongly directional codepoint
	 *
	 * This is the rule the BIDI algorithm uses to determine the directionality of
	 * paragraphs ( http://unicode.org/reports/tr9/#The_Paragraph_Level ) and
	 * FSI isolates ( http://unicode.org/reports/tr9/#Explicit_Directional_Isolates ).
	 *
	 * TODO: Does not handle BIDI control characters inside the text.
	 * TODO: Does not handle unallocated characters.
	 */
	function strongDirFromContent( text ) {
		var m = text.match( strongDirRegExp );
		if ( !m ) {
			return null;
		}
		if ( m[2] === undefined ) {
			return 'ltr';
		}
		return 'rtl';
	}

	$.extend( $.i18n.parser.emitter, {
		/**
		 * Wraps argument with unicode control characters for directionality safety
		 *
		 * This solves the problem where directionality-neutral characters at the edge of
		 * the argument string get interpreted with the wrong directionality from the
		 * enclosing context, giving renderings that look corrupted like "(Ben_(WMF".
		 *
		 * The wrapping is LRE...PDF or RLE...PDF, depending on the detected
		 * directionality of the argument string, using the BIDI algorithm's own "First
		 * strong directional codepoint" rule. Essentially, this works round the fact that
		 * there is no embedding equivalent of U+2068 FSI (isolation with heuristic
		 * direction inference). The latter is cleaner but still not widely supported.
		 */
		bidi: function ( nodes ) {
			var dir = strongDirFromContent( nodes[0] );
			if ( dir === 'ltr' ) {
				// Wrap in LEFT-TO-RIGHT EMBEDDING ... POP DIRECTIONAL FORMATTING
				return '\u202A' + nodes[0] + '\u202C';
			}
			if ( dir === 'rtl' ) {
				// Wrap in RIGHT-TO-LEFT EMBEDDING ... POP DIRECTIONAL FORMATTING
				return '\u202B' + nodes[0] + '\u202C';
			}
			// No strong directionality: do not wrap
			return nodes[0];
		}
	} );
}( jQuery ) );

/*global pluralRuleParser */
( function ( $ ) {
	'use strict';

	var language = {
		// CLDR plural rules generated using
		// libs/CLDRPluralRuleParser/tools/PluralXML2JSON.html
		pluralRules: {
			ak: {
				one: 'n = 0..1'
			},
			am: {
				one: 'i = 0 or n = 1'
			},
			ar: {
				zero: 'n = 0',
				one: 'n = 1',
				two: 'n = 2',
				few: 'n % 100 = 3..10',
				many: 'n % 100 = 11..99'
			},
			be: {
				one: 'n % 10 = 1 and n % 100 != 11',
				few: 'n % 10 = 2..4 and n % 100 != 12..14',
				many: 'n % 10 = 0 or n % 10 = 5..9 or n % 100 = 11..14'
			},
			bh: {
				one: 'n = 0..1'
			},
			bn: {
				one: 'i = 0 or n = 1'
			},
			br: {
				one: 'n % 10 = 1 and n % 100 != 11,71,91',
				two: 'n % 10 = 2 and n % 100 != 12,72,92',
				few: 'n % 10 = 3..4,9 and n % 100 != 10..19,70..79,90..99',
				many: 'n != 0 and n % 1000000 = 0'
			},
			bs: {
				one: 'v = 0 and i % 10 = 1 and i % 100 != 11 or f % 10 = 1 and f % 100 != 11',
				few: 'v = 0 and i % 10 = 2..4 and i % 100 != 12..14 or f % 10 = 2..4 and f % 100 != 12..14'
			},
			cs: {
				one: 'i = 1 and v = 0',
				few: 'i = 2..4 and v = 0',
				many: 'v != 0'
			},
			cy: {
				zero: 'n = 0',
				one: 'n = 1',
				two: 'n = 2',
				few: 'n = 3',
				many: 'n = 6'
			},
			da: {
				one: 'n = 1 or t != 0 and i = 0,1'
			},
			fa: {
				one: 'i = 0 or n = 1'
			},
			ff: {
				one: 'i = 0,1'
			},
			fil: {
				one: 'i = 0..1 and v = 0'
			},
			fr: {
				one: 'i = 0,1'
			},
			ga: {
				one: 'n = 1',
				two: 'n = 2',
				few: 'n = 3..6',
				many: 'n = 7..10'
			},
			gd: {
				one: 'n = 1,11',
				two: 'n = 2,12',
				few: 'n = 3..10,13..19'
			},
			gu: {
				one: 'i = 0 or n = 1'
			},
			guw: {
				one: 'n = 0..1'
			},
			gv: {
				one: 'n % 10 = 1',
				two: 'n % 10 = 2',
				few: 'n % 100 = 0,20,40,60'
			},
			he: {
				one: 'i = 1 and v = 0',
				two: 'i = 2 and v = 0',
				many: 'v = 0 and n != 0..10 and n % 10 = 0'
			},
			hi: {
				one: 'i = 0 or n = 1'
			},
			hr: {
				one: 'v = 0 and i % 10 = 1 and i % 100 != 11 or f % 10 = 1 and f % 100 != 11',
				few: 'v = 0 and i % 10 = 2..4 and i % 100 != 12..14 or f % 10 = 2..4 and f % 100 != 12..14'
			},
			hy: {
				one: 'i = 0,1'
			},
			is: {
				one: 't = 0 and i % 10 = 1 and i % 100 != 11 or t != 0'
			},
			iu: {
				one: 'n = 1',
				two: 'n = 2'
			},
			iw: {
				one: 'i = 1 and v = 0',
				two: 'i = 2 and v = 0',
				many: 'v = 0 and n != 0..10 and n % 10 = 0'
			},
			kab: {
				one: 'i = 0,1'
			},
			kn: {
				one: 'i = 0 or n = 1'
			},
			kw: {
				one: 'n = 1',
				two: 'n = 2'
			},
			lag: {
				zero: 'n = 0',
				one: 'i = 0,1 and n != 0'
			},
			ln: {
				one: 'n = 0..1'
			},
			lt: {
				one: 'n % 10 = 1 and n % 100 != 11..19',
				few: 'n % 10 = 2..9 and n % 100 != 11..19',
				many: 'f != 0'
			},
			lv: {
				zero: 'n % 10 = 0 or n % 100 = 11..19 or v = 2 and f % 100 = 11..19',
				one: 'n % 10 = 1 and n % 100 != 11 or v = 2 and f % 10 = 1 and f % 100 != 11 or v != 2 and f % 10 = 1'
			},
			mg: {
				one: 'n = 0..1'
			},
			mk: {
				one: 'v = 0 and i % 10 = 1 or f % 10 = 1'
			},
			mo: {
				one: 'i = 1 and v = 0',
				few: 'v != 0 or n = 0 or n != 1 and n % 100 = 1..19'
			},
			mr: {
				one: 'i = 0 or n = 1'
			},
			mt: {
				one: 'n = 1',
				few: 'n = 0 or n % 100 = 2..10',
				many: 'n % 100 = 11..19'
			},
			naq: {
				one: 'n = 1',
				two: 'n = 2'
			},
			nso: {
				one: 'n = 0..1'
			},
			pa: {
				one: 'n = 0..1'
			},
			pl: {
				one: 'i = 1 and v = 0',
				few: 'v = 0 and i % 10 = 2..4 and i % 100 != 12..14',
				many: 'v = 0 and i != 1 and i % 10 = 0..1 or v = 0 and i % 10 = 5..9 or v = 0 and i % 100 = 12..14'
			},
			pt: {
				one: 'i = 1 and v = 0 or i = 0 and t = 1'
			},
			// jscs:disable requireCamelCaseOrUpperCaseIdentifiers
			pt_PT: {
				one: 'n = 1 and v = 0'
			},
			// jscs:enable requireCamelCaseOrUpperCaseIdentifiers
			ro: {
				one: 'i = 1 and v = 0',
				few: 'v != 0 or n = 0 or n != 1 and n % 100 = 1..19'
			},
			ru: {
				one: 'v = 0 and i % 10 = 1 and i % 100 != 11',
				many: 'v = 0 and i % 10 = 0 or v = 0 and i % 10 = 5..9 or v = 0 and i % 100 = 11..14'
			},
			se: {
				one: 'n = 1',
				two: 'n = 2'
			},
			sh: {
				one: 'v = 0 and i % 10 = 1 and i % 100 != 11 or f % 10 = 1 and f % 100 != 11',
				few: 'v = 0 and i % 10 = 2..4 and i % 100 != 12..14 or f % 10 = 2..4 and f % 100 != 12..14'
			},
			shi: {
				one: 'i = 0 or n = 1',
				few: 'n = 2..10'
			},
			si: {
				one: 'n = 0,1 or i = 0 and f = 1'
			},
			sk: {
				one: 'i = 1 and v = 0',
				few: 'i = 2..4 and v = 0',
				many: 'v != 0'
			},
			sl: {
				one: 'v = 0 and i % 100 = 1',
				two: 'v = 0 and i % 100 = 2',
				few: 'v = 0 and i % 100 = 3..4 or v != 0'
			},
			sma: {
				one: 'n = 1',
				two: 'n = 2'
			},
			smi: {
				one: 'n = 1',
				two: 'n = 2'
			},
			smj: {
				one: 'n = 1',
				two: 'n = 2'
			},
			smn: {
				one: 'n = 1',
				two: 'n = 2'
			},
			sms: {
				one: 'n = 1',
				two: 'n = 2'
			},
			sr: {
				one: 'v = 0 and i % 10 = 1 and i % 100 != 11 or f % 10 = 1 and f % 100 != 11',
				few: 'v = 0 and i % 10 = 2..4 and i % 100 != 12..14 or f % 10 = 2..4 and f % 100 != 12..14'
			},
			ti: {
				one: 'n = 0..1'
			},
			tl: {
				one: 'i = 0..1 and v = 0'
			},
			tzm: {
				one: 'n = 0..1 or n = 11..99'
			},
			uk: {
				one: 'v = 0 and i % 10 = 1 and i % 100 != 11',
				few: 'v = 0 and i % 10 = 2..4 and i % 100 != 12..14',
				many: 'v = 0 and i % 10 = 0 or v = 0 and i % 10 = 5..9 or v = 0 and i % 100 = 11..14'
			},
			wa: {
				one: 'n = 0..1'
			},
			zu: {
				one: 'i = 0 or n = 1'
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
				explicitPluralPattern = new RegExp( '\\d+=', 'i' ),
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
		convertNumber: function ( num, integer ) {
			var tmp, item, i,
				transformTable, numberString, convertedNumber;

			// Set the target Transform table:
			transformTable = this.digitTransformTable( $.i18n().locale );
			numberString = String( num );
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
		gender: function ( gender, forms ) {
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
		 * @return {Array|boolean} List of digits in the passed language or false
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
				th: '๐๑๒๓๔๕๖๗๘๙', // FIXME use iso 639 codes
				bo: '༠༡༢༣༤༥༦༧༨༩' // FIXME use iso 639 codes
			};

			if ( !tables[language] ) {
				return false;
			}

			return tables[language].split( '' );
		}
	};

	$.extend( $.i18n.languages, {
		default: language
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
		ab: [ 'ru' ],
		ace: [ 'id' ],
		aln: [ 'sq' ],
		// Not so standard - als is supposed to be Tosk Albanian,
		// but in Wikipedia it's used for a Germanic language.
		als: [ 'gsw', 'de' ],
		an: [ 'es' ],
		anp: [ 'hi' ],
		arn: [ 'es' ],
		arz: [ 'ar' ],
		av: [ 'ru' ],
		ay: [ 'es' ],
		ba: [ 'ru' ],
		bar: [ 'de' ],
		'bat-smg': [ 'sgs', 'lt' ],
		bcc: [ 'fa' ],
		'be-x-old': [ 'be-tarask' ],
		bh: [ 'bho' ],
		bjn: [ 'id' ],
		bm: [ 'fr' ],
		bpy: [ 'bn' ],
		bqi: [ 'fa' ],
		bug: [ 'id' ],
		'cbk-zam': [ 'es' ],
		ce: [ 'ru' ],
		crh: [ 'crh-latn' ],
		'crh-cyrl': [ 'ru' ],
		csb: [ 'pl' ],
		cv: [ 'ru' ],
		'de-at': [ 'de' ],
		'de-ch': [ 'de' ],
		'de-formal': [ 'de' ],
		dsb: [ 'de' ],
		dtp: [ 'ms' ],
		egl: [ 'it' ],
		eml: [ 'it' ],
		ff: [ 'fr' ],
		fit: [ 'fi' ],
		'fiu-vro': [ 'vro', 'et' ],
		frc: [ 'fr' ],
		frp: [ 'fr' ],
		frr: [ 'de' ],
		fur: [ 'it' ],
		gag: [ 'tr' ],
		gan: [ 'gan-hant', 'zh-hant', 'zh-hans' ],
		'gan-hans': [ 'zh-hans' ],
		'gan-hant': [ 'zh-hant', 'zh-hans' ],
		gl: [ 'pt' ],
		glk: [ 'fa' ],
		gn: [ 'es' ],
		gsw: [ 'de' ],
		hif: [ 'hif-latn' ],
		hsb: [ 'de' ],
		ht: [ 'fr' ],
		ii: [ 'zh-cn', 'zh-hans' ],
		inh: [ 'ru' ],
		iu: [ 'ike-cans' ],
		jut: [ 'da' ],
		jv: [ 'id' ],
		kaa: [ 'kk-latn', 'kk-cyrl' ],
		kbd: [ 'kbd-cyrl' ],
		khw: [ 'ur' ],
		kiu: [ 'tr' ],
		kk: [ 'kk-cyrl' ],
		'kk-arab': [ 'kk-cyrl' ],
		'kk-latn': [ 'kk-cyrl' ],
		'kk-cn': [ 'kk-arab', 'kk-cyrl' ],
		'kk-kz': [ 'kk-cyrl' ],
		'kk-tr': [ 'kk-latn', 'kk-cyrl' ],
		kl: [ 'da' ],
		'ko-kp': [ 'ko' ],
		koi: [ 'ru' ],
		krc: [ 'ru' ],
		ks: [ 'ks-arab' ],
		ksh: [ 'de' ],
		ku: [ 'ku-latn' ],
		'ku-arab': [ 'ckb' ],
		kv: [ 'ru' ],
		lad: [ 'es' ],
		lb: [ 'de' ],
		lbe: [ 'ru' ],
		lez: [ 'ru' ],
		li: [ 'nl' ],
		lij: [ 'it' ],
		liv: [ 'et' ],
		lmo: [ 'it' ],
		ln: [ 'fr' ],
		ltg: [ 'lv' ],
		lzz: [ 'tr' ],
		mai: [ 'hi' ],
		'map-bms': [ 'jv', 'id' ],
		mg: [ 'fr' ],
		mhr: [ 'ru' ],
		min: [ 'id' ],
		mo: [ 'ro' ],
		mrj: [ 'ru' ],
		mwl: [ 'pt' ],
		myv: [ 'ru' ],
		mzn: [ 'fa' ],
		nah: [ 'es' ],
		nap: [ 'it' ],
		nds: [ 'de' ],
		'nds-nl': [ 'nl' ],
		'nl-informal': [ 'nl' ],
		no: [ 'nb' ],
		os: [ 'ru' ],
		pcd: [ 'fr' ],
		pdc: [ 'de' ],
		pdt: [ 'de' ],
		pfl: [ 'de' ],
		pms: [ 'it' ],
		pt: [ 'pt-br' ],
		'pt-br': [ 'pt' ],
		qu: [ 'es' ],
		qug: [ 'qu', 'es' ],
		rgn: [ 'it' ],
		rmy: [ 'ro' ],
		'roa-rup': [ 'rup' ],
		rue: [ 'uk', 'ru' ],
		ruq: [ 'ruq-latn', 'ro' ],
		'ruq-cyrl': [ 'mk' ],
		'ruq-latn': [ 'ro' ],
		sa: [ 'hi' ],
		sah: [ 'ru' ],
		scn: [ 'it' ],
		sg: [ 'fr' ],
		sgs: [ 'lt' ],
		sli: [ 'de' ],
		sr: [ 'sr-ec' ],
		srn: [ 'nl' ],
		stq: [ 'de' ],
		su: [ 'id' ],
		szl: [ 'pl' ],
		tcy: [ 'kn' ],
		tg: [ 'tg-cyrl' ],
		tt: [ 'tt-cyrl', 'ru' ],
		'tt-cyrl': [ 'ru' ],
		ty: [ 'fr' ],
		udm: [ 'ru' ],
		ug: [ 'ug-arab' ],
		uk: [ 'ru' ],
		vec: [ 'it' ],
		vep: [ 'et' ],
		vls: [ 'nl' ],
		vmf: [ 'de' ],
		vot: [ 'fi' ],
		vro: [ 'et' ],
		wa: [ 'fr' ],
		wo: [ 'fr' ],
		wuu: [ 'zh-hans' ],
		xal: [ 'ru' ],
		xmf: [ 'ka' ],
		yi: [ 'he' ],
		za: [ 'zh-hans' ],
		zea: [ 'nl' ],
		zh: [ 'zh-hans' ],
		'zh-classical': [ 'lzh' ],
		'zh-cn': [ 'zh-hans' ],
		'zh-hant': [ 'zh-hans' ],
		'zh-hk': [ 'zh-hant', 'zh-hans' ],
		'zh-min-nan': [ 'nan' ],
		'zh-mo': [ 'zh-hk', 'zh-hant', 'zh-hans' ],
		'zh-my': [ 'zh-sg', 'zh-hans' ],
		'zh-sg': [ 'zh-hans' ],
		'zh-tw': [ 'zh-hant', 'zh-hans' ],
		'zh-yue': [ 'yue' ]
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

			if ( word.match( /тæ$/i ) ) {
				// Checking if the $word is in plural form
				word = word.substring( 0, word.length - 1 );
				endAllative = 'æм';
			} else if ( word.match( /[аæеёиоыэюя]$/i ) ) {
				// Works if word is in singular form.
				// Checking if word ends on one of the vowels: е, ё, и, о, ы, э, ю,
				// я.
				jot = 'й';
			} else if ( word.match( /у$/i ) ) {
				// Checking if word ends on 'у'. 'У' can be either consonant 'W' or
				// vowel 'U' in cyrillic Ossetic.
				// Examples: {{grammar:genitive|аунеу}} = аунеуы,
				// {{grammar:genitive|лæппу}} = лæппуйы.
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
 * jQuery Client v1.0.0
 * https://www.mediawiki.org/wiki/JQuery_Client
 *
 * Copyright 2010-2015 jquery-client maintainers and other contributors.
 * Released under the MIT license
 * http://jquery-client.mit-license.org
 */

/**
 * User-agent detection
 *
 * @class jQuery.client
 * @singleton
 */
( function ( $ ) {

	/**
	 * @private
	 * @property {Object} profileCache Keyed by userAgent string,
	 * value is the parsed $.client.profile object for that user agent.
	 */
	var profileCache = {};

	$.client = {

		/**
		 * Get an object containing information about the client.
		 *
		 * @param {Object} [nav] An object with a 'userAgent' and 'platform' property.
		 *  Defaults to the global `navigator` object.
		 * @return {Object} The resulting client object will be in the following format:
		 *
		 *     {
		 *         'name': 'firefox',
		 *         'layout': 'gecko',
		 *         'layoutVersion': 20101026,
		 *         'platform': 'linux'
		 *         'version': '3.5.1',
		 *         'versionBase': '3',
		 *         'versionNumber': 3.5,
		 *     }
		 */
		profile: function ( nav ) {
			/*jshint boss:true */

			if ( nav === undefined ) {
				nav = window.navigator;
			}

			// Use the cached version if possible
			if ( profileCache[ nav.userAgent + '|' + nav.platform ] !== undefined ) {
				return profileCache[ nav.userAgent + '|' + nav.platform ];
			}

			var
				versionNumber,
				key = nav.userAgent + '|' + nav.platform,

				// Configuration

				// Name of browsers or layout engines we don't recognize
				uk = 'unknown',
				// Generic version digit
				x = 'x',
				// Strings found in user agent strings that need to be conformed
				wildUserAgents = ['Opera', 'Navigator', 'Minefield', 'KHTML', 'Chrome', 'PLAYSTATION 3', 'Iceweasel'],
				// Translations for conforming user agent strings
				userAgentTranslations = [
					// Tons of browsers lie about being something they are not
					[/(Firefox|MSIE|KHTML,?\slike\sGecko|Konqueror)/, ''],
					// Chrome lives in the shadow of Safari still
					['Chrome Safari', 'Chrome'],
					// KHTML is the layout engine not the browser - LIES!
					['KHTML', 'Konqueror'],
					// Firefox nightly builds
					['Minefield', 'Firefox'],
					// This helps keep different versions consistent
					['Navigator', 'Netscape'],
					// This prevents version extraction issues, otherwise translation would happen later
					['PLAYSTATION 3', 'PS3']
				],
				// Strings which precede a version number in a user agent string - combined and used as
				// match 1 in version detection
				versionPrefixes = [
					'camino', 'chrome', 'firefox', 'iceweasel', 'netscape', 'netscape6', 'opera', 'version', 'konqueror',
					'lynx', 'msie', 'safari', 'ps3', 'android'
				],
				// Used as matches 2, 3 and 4 in version extraction - 3 is used as actual version number
				versionSuffix = '(\\/|\\;?\\s|)([a-z0-9\\.\\+]*?)(\\;|dev|rel|\\)|\\s|$)',
				// Names of known browsers
				names = [
					'camino', 'chrome', 'firefox', 'iceweasel', 'netscape', 'konqueror', 'lynx', 'msie', 'opera',
					'safari', 'ipod', 'iphone', 'blackberry', 'ps3', 'rekonq', 'android'
				],
				// Tanslations for conforming browser names
				nameTranslations = [],
				// Names of known layout engines
				layouts = ['gecko', 'konqueror', 'msie', 'trident', 'edge', 'opera', 'webkit'],
				// Translations for conforming layout names
				layoutTranslations = [ ['konqueror', 'khtml'], ['msie', 'trident'], ['opera', 'presto'] ],
				// Names of supported layout engines for version number
				layoutVersions = ['applewebkit', 'gecko', 'trident', 'edge'],
				// Names of known operating systems
				platforms = ['win', 'wow64', 'mac', 'linux', 'sunos', 'solaris', 'iphone'],
				// Translations for conforming operating system names
				platformTranslations = [ ['sunos', 'solaris'], ['wow64', 'win'] ],

				/**
				 * Performs multiple replacements on a string
				 * @ignore
				 */
				translate = function ( source, translations ) {
					var i;
					for ( i = 0; i < translations.length; i++ ) {
						source = source.replace( translations[i][0], translations[i][1] );
					}
					return source;
				},

				// Pre-processing

				ua = nav.userAgent,
				match,
				name = uk,
				layout = uk,
				layoutversion = uk,
				platform = uk,
				version = x;

			if ( match = new RegExp( '(' + wildUserAgents.join( '|' ) + ')' ).exec( ua ) ) {
				// Takes a userAgent string and translates given text into something we can more easily work with
				ua = translate( ua, userAgentTranslations );
			}
			// Everything will be in lowercase from now on
			ua = ua.toLowerCase();

			// Extraction

			if ( match = new RegExp( '(' + names.join( '|' ) + ')' ).exec( ua ) ) {
				name = translate( match[1], nameTranslations );
			}
			if ( match = new RegExp( '(' + layouts.join( '|' ) + ')' ).exec( ua ) ) {
				layout = translate( match[1], layoutTranslations );
			}
			if ( match = new RegExp( '(' + layoutVersions.join( '|' ) + ')\\\/(\\d+)').exec( ua ) ) {
				layoutversion = parseInt( match[2], 10 );
			}
			if ( match = new RegExp( '(' + platforms.join( '|' ) + ')' ).exec( nav.platform.toLowerCase() ) ) {
				platform = translate( match[1], platformTranslations );
			}
			if ( match = new RegExp( '(' + versionPrefixes.join( '|' ) + ')' + versionSuffix ).exec( ua ) ) {
				version = match[3];
			}

			// Edge Cases -- did I mention about how user agent string lie?

			// Decode Safari's crazy 400+ version numbers
			if ( name === 'safari' && version > 400 ) {
				version = '2.0';
			}
			// Expose Opera 10's lies about being Opera 9.8
			if ( name === 'opera' && version >= 9.8 ) {
				match = ua.match( /\bversion\/([0-9\.]*)/ );
				if ( match && match[1] ) {
					version = match[1];
				} else {
					version = '10';
				}
			}
			// And Opera 15's lies about being Chrome
			if ( name === 'chrome' && ( match = ua.match( /\bopr\/([0-9\.]*)/ ) ) ) {
				if ( match[1] ) {
					name = 'opera';
					version = match[1];
				}
			}
			// And IE 11's lies about being not being IE
			if ( layout === 'trident' && layoutversion >= 7 && ( match = ua.match( /\brv[ :\/]([0-9\.]*)/ ) ) ) {
				if ( match[1] ) {
					name = 'msie';
					version = match[1];
				}
			}
			// And IE 12's different lies about not being IE
			if ( name === 'chrome' && ( match = ua.match( /\bedge\/([0-9\.]*)/ ) ) ) {
				name = 'msie';
				version = match[1];
				layout = 'edge';
				layoutversion = parseInt( match[1], 10 );
			}
			// And Amazon Silk's lies about being Android on mobile or Safari on desktop
			if ( match = ua.match( /\bsilk\/([0-9.\-_]*)/ ) ) {
				if ( match[1] ) {
					name = 'silk';
					version = match[1];
				}
			}

			versionNumber = parseFloat( version, 10 ) || 0.0;

			// Caching

			return profileCache[ key  ] = {
				name: name,
				layout: layout,
				layoutVersion: layoutversion,
				platform: platform,
				version: version,
				versionBase: ( version !== x ? Math.floor( versionNumber ).toString() : x ),
				versionNumber: versionNumber
			};
		},

		/**
		 * Checks the current browser against a support map object.
		 *
		 * Version numbers passed as numeric values will be compared like numbers (1.2 > 1.11).
		 * Version numbers passed as string values will be compared using a simple component-wise
		 * algorithm, similar to PHP's version_compare ('1.2' < '1.11').
		 *
		 * A browser map is in the following format:
		 *
		 *     {
		 *         // Multiple rules with configurable operators
		 *         'msie': [['>=', 7], ['!=', 9]],
		 *         // Match no versions
		 *         'iphone': false,
		 *         // Match any version
		 *         'android': null
		 *     }
		 *
		 * It can optionally be split into ltr/rtl sections:
		 *
		 *     {
		 *         'ltr': {
		 *             'android': null,
		 *             'iphone': false
		 *         },
		 *         'rtl': {
		 *             'android': false,
		 *             // rules are not inherited from ltr
		 *             'iphone': false
		 *         }
		 *     }
		 *
		 * @param {Object} map Browser support map
		 * @param {Object} [profile] A client-profile object
		 * @param {boolean} [exactMatchOnly=false] Only return true if the browser is matched, otherwise
		 * returns true if the browser is not found.
		 *
		 * @return {boolean} The current browser is in the support map
		 */
		test: function ( map, profile, exactMatchOnly ) {
			/*jshint evil:true */

			var conditions, dir, i, op, val, j, pieceVersion, pieceVal, compare;
			profile = $.isPlainObject( profile ) ? profile : $.client.profile();
			if ( map.ltr && map.rtl ) {
				dir = $( 'body' ).is( '.rtl' ) ? 'rtl' : 'ltr';
				map = map[dir];
			}
			// Check over each browser condition to determine if we are running in a compatible client
			if ( typeof map !== 'object' || map[profile.name] === undefined ) {
				// Not found, return true if exactMatchOnly not set, false otherwise
				return !exactMatchOnly;
			}
			conditions = map[profile.name];
			if ( conditions === false ) {
				// Match no versions
				return false;
			}
			if ( conditions === null ) {
				// Match all versions
				return true;
			}
			for ( i = 0; i < conditions.length; i++ ) {
				op = conditions[i][0];
				val = conditions[i][1];
				if ( typeof val === 'string' ) {
					// Perform a component-wise comparison of versions, similar to PHP's version_compare
					// but simpler. '1.11' is larger than '1.2'.
					pieceVersion = profile.version.toString().split( '.' );
					pieceVal = val.split( '.' );
					// Extend with zeroes to equal length
					while ( pieceVersion.length < pieceVal.length ) {
						pieceVersion.push( '0' );
					}
					while ( pieceVal.length < pieceVersion.length ) {
						pieceVal.push( '0' );
					}
					// Compare components
					compare = 0;
					for ( j = 0; j < pieceVersion.length; j++ ) {
						if ( Number( pieceVersion[j] ) < Number( pieceVal[j] ) ) {
							compare = -1;
							break;
						} else if ( Number( pieceVersion[j] ) > Number( pieceVal[j] ) ) {
							compare = 1;
							break;
						}
					}
					// compare will be -1, 0 or 1, depending on comparison result
					if ( !( eval( String( compare + op + '0' ) ) ) ) {
						return false;
					}
				} else if ( typeof val === 'number' ) {
					if ( !( eval( 'profile.versionNumber' + op + val ) ) ) {
						return false;
					}
				}
			}

			return true;
		}
	};
}( jQuery ) );

/*!
 * OOjs v1.1.9 optimised for jQuery
 * https://www.mediawiki.org/wiki/OOjs
 *
 * Copyright 2011-2015 OOjs Team and other contributors.
 * Released under the MIT license
 * http://oojs.mit-license.org
 *
 * Date: 2015-08-25T21:35:29Z
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
	toString = oo.toString,
	// Object.create() is impossible to fully polyfill, so don't require it
	createObject = Object.create || ( function () {
		// Reusable constructor function
		function Empty() {}
		return function ( prototype, properties ) {
			var obj;
			Empty.prototype = prototype;
			obj = new Empty();
			if ( properties && hasOwn.call( properties, 'constructor' ) ) {
				obj.constructor = properties.constructor.value;
			}
			return obj;
		};
	} )();

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

	targetFn.prototype = createObject( originFn.prototype, {
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
	targetFn.static = createObject( originFn.static );
};

/**
 * Copy over *own* prototype properties of a mixin.
 *
 * The 'constructor' (whether implicit or explicit) is not copied over.
 *
 * This does not create inheritance to the origin. If you need inheritance,
 * use OO.inheritClass instead.
 *
 * Beware: This can redefine a prototype property, call before setting your prototypes.
 *
 * Beware: Don't call before OO.inheritClass.
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

	r = createObject( origin.constructor.prototype );

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
 * Get the unique values of an array, removing duplicates
 *
 * @param {Array} arr Array
 * @return {Array} Unique values in array
 */
oo.unique = function ( arr ) {
	return arr.reduce( function ( result, current ) {
		if ( result.indexOf( current ) === -1 ) {
			result.push( current );
		}
		return result;
	}, [] );
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
	 * @param {string} event Type of event
	 * @param {Mixed} args First in a list of variadic arguments passed to event handler (optional)
	 * @return {boolean} Whether the event was handled by at least one listener
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

/**
 * @event unregister
 * @param {string} name
 * @param {Mixed} data Data removed from registry
 */

/* Methods */

/**
 * Associate one or more symbolic names with some data.
 *
 * Any existing entry with the same name will be overridden.
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
 * Remove one or more symbolic names from the registry
 *
 * @param {string|string[]} name Symbolic name or list of symbolic names
 * @fires unregister
 * @throws {Error} Name argument must be a string or array
 */
oo.Registry.prototype.unregister = function ( name ) {
	var i, len, data;
	if ( typeof name === 'string' ) {
		data = this.lookup( name );
		if ( data !== undefined ) {
			delete this.registry[name];
			this.emit( 'unregister', name, data );
		}
	} else if ( Array.isArray( name ) ) {
		for ( i = 0, len = name.length; i < len; i++ ) {
			this.unregister( name[i] );
		}
	} else {
		throw new Error( 'Name must be a string or array, cannot be a ' + typeof name );
	}
};

/**
 * Get data for a given symbolic name.
 *
 * @param {string} name Symbolic name
 * @return {Mixed|undefined} Data associated with symbolic name
 */
oo.Registry.prototype.lookup = function ( name ) {
	if ( hasOwn.call( this.registry, name ) ) {
		return this.registry[name];
	}
};

/*global createObject */

/**
 * @class OO.Factory
 * @extends OO.Registry
 *
 * @constructor
 */
oo.Factory = function OoFactory() {
	// Parent constructor
	oo.Factory.parent.call( this );
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

	// Parent method
	oo.Factory.parent.prototype.register.call( this, name, constructor );
};

/**
 * Unregister a constructor from the factory.
 *
 * @param {Function} constructor Constructor to unregister
 * @throws {Error} Name must be a string and must not be empty
 * @throws {Error} Constructor must be a function
 */
oo.Factory.prototype.unregister = function ( constructor ) {
	var name;

	if ( typeof constructor !== 'function' ) {
		throw new Error( 'constructor must be a function, cannot be a ' + typeof constructor );
	}
	name = constructor.static && constructor.static.name;
	if ( typeof name !== 'string' || name === '' ) {
		throw new Error( 'Name must be a string and must not be empty' );
	}

	// Parent method
	oo.Factory.parent.prototype.unregister.call( this, name );
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
	obj = createObject( constructor.prototype );
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
 * OOjs UI v0.12.6
 * https://www.mediawiki.org/wiki/OOjs_UI
 *
 * Copyright 2011–2015 OOjs UI Team and other contributors.
 * Released under the MIT license
 * http://oojs.mit-license.org
 *
 * Date: 2015-08-26T00:14:36Z
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
 * @property {Number}
 */
OO.ui.elementId = 0;

/**
 * Generate a unique ID for element
 *
 * @return {String} [id]
 */
OO.ui.generateElementId = function () {
	OO.ui.elementId += 1;
	return 'oojsui-' + OO.ui.elementId;
};

/**
 * Check if an element is focusable.
 * Inspired from :focusable in jQueryUI v1.11.4 - 2015-04-14
 *
 * @param {jQuery} element Element to test
 * @return {boolean}
 */
OO.ui.isFocusableElement = function ( $element ) {
	var node = $element[ 0 ],
		nodeName = node.nodeName.toLowerCase(),
		// Check if the element have tabindex set
		isInElementGroup = /^(input|select|textarea|button|object)$/.test( nodeName ),
		// Check if the element is a link with href or if it has tabindex
		isOtherElement = (
			( nodeName === 'a' && node.href ) ||
			!isNaN( $element.attr( 'tabindex' ) )
		),
		// Check if the element is visible
		isVisible = (
			// This is quicker than calling $element.is( ':visible' )
			$.expr.filters.visible( node ) &&
			// Check that all parents are visible
			!$element.parents().addBack().filter( function () {
				return $.css( this, 'visibility' ) === 'hidden';
			} ).length
		),
		isTabOk = isNaN( $element.attr( 'tabindex' ) ) || +$element.attr( 'tabindex' ) >= 0;

	return (
		( isInElementGroup ? !node.disabled : isOtherElement ) &&
		isVisible && isTabOk
	);
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
 * @return {Function}
 */
OO.ui.debounce = function ( func, wait, immediate ) {
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
 * Proxy for `node.addEventListener( eventName, handler, true )`, if the browser supports it.
 * Otherwise falls back to non-capturing event listeners.
 *
 * @param {HTMLElement} node
 * @param {string} eventName
 * @param {Function} handler
 */
OO.ui.addCaptureEventListener = function ( node, eventName, handler ) {
	if ( node.addEventListener ) {
		node.addEventListener( eventName, handler, true );
	} else {
		node.attachEvent( 'on' + eventName, handler );
	}
};

/**
 * Proxy for `node.removeEventListener( eventName, handler, true )`, if the browser supports it.
 * Otherwise falls back to non-capturing event listeners.
 *
 * @param {HTMLElement} node
 * @param {string} eventName
 * @param {Function} handler
 */
OO.ui.removeCaptureEventListener = function ( node, eventName, handler ) {
	if ( node.addEventListener ) {
		node.removeEventListener( eventName, handler, true );
	} else {
		node.detachEvent( 'on' + eventName, handler );
	}
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
		'ooui-dialog-process-continue': 'Continue',
		// Default placeholder for file selection widgets
		'ooui-selectfile-not-supported': 'File selection is not supported',
		// Default placeholder for file selection widgets
		'ooui-selectfile-placeholder': 'No file is selected',
		// Default placeholder for file selection widgets when using drag drop UI
		'ooui-selectfile-dragdrop-placeholder': 'Drop file here (or click to browse)',
		// Semicolon separator
		'ooui-semicolon-separator': '; '
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

	/**
	 * @param {string} url
	 * @return {boolean}
	 */
	OO.ui.isSafeUrl = function ( url ) {
		var protocol,
			// Keep in sync with php/Tag.php
			whitelist = [
				'bitcoin:', 'ftp:', 'ftps:', 'geo:', 'git:', 'gopher:', 'http:', 'https:', 'irc:', 'ircs:',
				'magnet:', 'mailto:', 'mms:', 'news:', 'nntp:', 'redis:', 'sftp:', 'sip:', 'sips:', 'sms:', 'ssh:',
				'svn:', 'tel:', 'telnet:', 'urn:', 'worldwind:', 'xmpp:'
			];

		if ( url.indexOf( ':' ) === -1 ) {
			// No protocol, safe
			return true;
		}

		protocol = url.split( ':', 1 )[ 0 ] + ':';
		if ( !protocol.match( /^([A-za-z0-9\+\.\-])+:/ ) ) {
			// Not a valid protocol, safe
			return true;
		}

		// Safe if in the whitelist
		return whitelist.indexOf( protocol ) !== -1;
	};

} )();

/*!
 * Mixin namespace.
 */

/**
 * Namespace for OOjs UI mixins.
 *
 * Mixins are named according to the type of object they are intended to
 * be mixed in to.  For example, OO.ui.mixin.GroupElement is intended to be
 * mixed in to an instance of OO.ui.Element, and OO.ui.mixin.GroupWidget
 * is intended to be mixed in to an instance of OO.ui.Widget.
 *
 * @class
 * @singleton
 */
OO.ui.mixin = {};

/**
 * PendingElement is a mixin that is used to create elements that notify users that something is happening
 * and that they should wait before proceeding. The pending state is visually represented with a pending
 * texture that appears in the head of a pending {@link OO.ui.ProcessDialog process dialog} or in the input
 * field of a {@link OO.ui.TextInputWidget text input widget}.
 *
 * Currently, {@link OO.ui.ActionWidget Action widgets}, which mix in this class, can also be marked as pending, but only when
 * used in {@link OO.ui.MessageDialog message dialogs}. The behavior is not currently supported for action widgets used
 * in process dialogs.
 *
 *     @example
 *     function MessageDialog( config ) {
 *         MessageDialog.parent.call( this, config );
 *     }
 *     OO.inheritClass( MessageDialog, OO.ui.MessageDialog );
 *
 *     MessageDialog.static.actions = [
 *         { action: 'save', label: 'Done', flags: 'primary' },
 *         { label: 'Cancel', flags: 'safe' }
 *     ];
 *
 *     MessageDialog.prototype.initialize = function () {
 *         MessageDialog.parent.prototype.initialize.apply( this, arguments );
 *         this.content = new OO.ui.PanelLayout( { $: this.$, padded: true } );
 *         this.content.$element.append( '<p>Click the \'Done\' action widget to see its pending state. Note that action widgets can be marked pending in message dialogs but not process dialogs.</p>' );
 *         this.$body.append( this.content.$element );
 *     };
 *     MessageDialog.prototype.getBodyHeight = function () {
 *         return 100;
 *     }
 *     MessageDialog.prototype.getActionProcess = function ( action ) {
 *         var dialog = this;
 *         if ( action === 'save' ) {
 *             dialog.getActions().get({actions: 'save'})[0].pushPending();
 *             return new OO.ui.Process()
 *             .next( 1000 )
 *             .next( function () {
 *                 dialog.getActions().get({actions: 'save'})[0].popPending();
 *             } );
 *         }
 *         return MessageDialog.parent.prototype.getActionProcess.call( this, action );
 *     };
 *
 *     var windowManager = new OO.ui.WindowManager();
 *     $( 'body' ).append( windowManager.$element );
 *
 *     var dialog = new MessageDialog();
 *     windowManager.addWindows( [ dialog ] );
 *     windowManager.openWindow( dialog );
 *
 * @abstract
 * @class
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {jQuery} [$pending] Element to mark as pending, defaults to this.$element
 */
OO.ui.mixin.PendingElement = function OoUiMixinPendingElement( config ) {
	// Configuration initialization
	config = config || {};

	// Properties
	this.pending = 0;
	this.$pending = null;

	// Initialisation
	this.setPendingElement( config.$pending || this.$element );
};

/* Setup */

OO.initClass( OO.ui.mixin.PendingElement );

/* Methods */

/**
 * Set the pending element (and clean up any existing one).
 *
 * @param {jQuery} $pending The element to set to pending.
 */
OO.ui.mixin.PendingElement.prototype.setPendingElement = function ( $pending ) {
	if ( this.$pending ) {
		this.$pending.removeClass( 'oo-ui-pendingElement-pending' );
	}

	this.$pending = $pending;
	if ( this.pending > 0 ) {
		this.$pending.addClass( 'oo-ui-pendingElement-pending' );
	}
};

/**
 * Check if an element is pending.
 *
 * @return {boolean} Element is pending
 */
OO.ui.mixin.PendingElement.prototype.isPending = function () {
	return !!this.pending;
};

/**
 * Increase the pending counter. The pending state will remain active until the counter is zero
 * (i.e., the number of calls to #pushPending and #popPending is the same).
 *
 * @chainable
 */
OO.ui.mixin.PendingElement.prototype.pushPending = function () {
	if ( this.pending === 0 ) {
		this.$pending.addClass( 'oo-ui-pendingElement-pending' );
		this.updateThemeClasses();
	}
	this.pending++;

	return this;
};

/**
 * Decrease the pending counter. The pending state will remain active until the counter is zero
 * (i.e., the number of calls to #pushPending and #popPending is the same).
 *
 * @chainable
 */
OO.ui.mixin.PendingElement.prototype.popPending = function () {
	if ( this.pending === 1 ) {
		this.$pending.removeClass( 'oo-ui-pendingElement-pending' );
		this.updateThemeClasses();
	}
	this.pending = Math.max( 0, this.pending - 1 );

	return this;
};

/**
 * ActionSets manage the behavior of the {@link OO.ui.ActionWidget action widgets} that comprise them.
 * Actions can be made available for specific contexts (modes) and circumstances
 * (abilities). Action sets are primarily used with {@link OO.ui.Dialog Dialogs}.
 *
 * ActionSets contain two types of actions:
 *
 * - Special: Special actions are the first visible actions with special flags, such as 'safe' and 'primary', the default special flags. Additional special flags can be configured in subclasses with the static #specialFlags property.
 * - Other: Other actions include all non-special visible actions.
 *
 * Please see the [OOjs UI documentation on MediaWiki][1] for more information.
 *
 *     @example
 *     // Example: An action set used in a process dialog
 *     function MyProcessDialog( config ) {
 *         MyProcessDialog.parent.call( this, config );
 *     }
 *     OO.inheritClass( MyProcessDialog, OO.ui.ProcessDialog );
 *     MyProcessDialog.static.title = 'An action set in a process dialog';
 *     // An action set that uses modes ('edit' and 'help' mode, in this example).
 *     MyProcessDialog.static.actions = [
 *         { action: 'continue', modes: 'edit', label: 'Continue', flags: [ 'primary', 'constructive' ] },
 *         { action: 'help', modes: 'edit', label: 'Help' },
 *         { modes: 'edit', label: 'Cancel', flags: 'safe' },
 *         { action: 'back', modes: 'help', label: 'Back', flags: 'safe' }
 *     ];
 *
 *     MyProcessDialog.prototype.initialize = function () {
 *         MyProcessDialog.parent.prototype.initialize.apply( this, arguments );
 *         this.panel1 = new OO.ui.PanelLayout( { padded: true, expanded: false } );
 *         this.panel1.$element.append( '<p>This dialog uses an action set (continue, help, cancel, back) configured with modes. This is edit mode. Click \'help\' to see help mode.</p>' );
 *         this.panel2 = new OO.ui.PanelLayout( { padded: true, expanded: false } );
 *         this.panel2.$element.append( '<p>This is help mode. Only the \'back\' action widget is configured to be visible here. Click \'back\' to return to \'edit\' mode.</p>' );
 *         this.stackLayout = new OO.ui.StackLayout( {
 *             items: [ this.panel1, this.panel2 ]
 *         } );
 *         this.$body.append( this.stackLayout.$element );
 *     };
 *     MyProcessDialog.prototype.getSetupProcess = function ( data ) {
 *         return MyProcessDialog.parent.prototype.getSetupProcess.call( this, data )
 *             .next( function () {
 *                 this.actions.setMode( 'edit' );
 *             }, this );
 *     };
 *     MyProcessDialog.prototype.getActionProcess = function ( action ) {
 *         if ( action === 'help' ) {
 *             this.actions.setMode( 'help' );
 *             this.stackLayout.setItem( this.panel2 );
 *         } else if ( action === 'back' ) {
 *             this.actions.setMode( 'edit' );
 *             this.stackLayout.setItem( this.panel1 );
 *         } else if ( action === 'continue' ) {
 *             var dialog = this;
 *             return new OO.ui.Process( function () {
 *                 dialog.close();
 *             } );
 *         }
 *         return MyProcessDialog.parent.prototype.getActionProcess.call( this, action );
 *     };
 *     MyProcessDialog.prototype.getBodyHeight = function () {
 *         return this.panel1.$element.outerHeight( true );
 *     };
 *     var windowManager = new OO.ui.WindowManager();
 *     $( 'body' ).append( windowManager.$element );
 *     var dialog = new MyProcessDialog( {
 *         size: 'medium'
 *     } );
 *     windowManager.addWindows( [ dialog ] );
 *     windowManager.openWindow( dialog );
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
 *
 * A 'click' event is emitted when an action is clicked.
 *
 * @param {OO.ui.ActionWidget} action Action that was clicked
 */

/**
 * @event resize
 *
 * A 'resize' event is emitted when an action widget is resized.
 *
 * @param {OO.ui.ActionWidget} action Action that was resized
 */

/**
 * @event add
 *
 * An 'add' event is emitted when actions are {@link #method-add added} to the action set.
 *
 * @param {OO.ui.ActionWidget[]} added Actions added
 */

/**
 * @event remove
 *
 * A 'remove' event is emitted when actions are {@link #method-remove removed}
 *  or {@link #clear cleared}.
 *
 * @param {OO.ui.ActionWidget[]} added Actions removed
 */

/**
 * @event change
 *
 * A 'change' event is emitted when actions are {@link #method-add added}, {@link #clear cleared},
 * or {@link #method-remove removed} from the action set or when the {@link #setMode mode} is changed.
 *
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
 * Check if an action is one of the special actions.
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
 * Get action widgets based on the specified filter: ‘actions’, ‘flags’, ‘modes’, ‘visible’,
 *  or ‘disabled’.
 *
 * @param {Object} [filters] Filters to use, omit to get all actions
 * @param {string|string[]} [filters.actions] Actions that action widgets must have
 * @param {string|string[]} [filters.flags] Flags that action widgets must have (e.g., 'safe')
 * @param {string|string[]} [filters.modes] Modes that action widgets must have
 * @param {boolean} [filters.visible] Action widgets must be visible
 * @param {boolean} [filters.disabled] Action widgets must be disabled
 * @return {OO.ui.ActionWidget[]} Action widgets matching all criteria
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
 * Get 'special' actions.
 *
 * Special actions are the first visible action widgets with special flags, such as 'safe' and 'primary'.
 * Special flags can be configured in subclasses by changing the static #specialFlags property.
 *
 * @return {OO.ui.ActionWidget[]|null} 'Special' action widgets.
 */
OO.ui.ActionSet.prototype.getSpecial = function () {
	this.organize();
	return $.extend( {}, this.special );
};

/**
 * Get 'other' actions.
 *
 * Other actions include all non-special visible action widgets.
 *
 * @return {OO.ui.ActionWidget[]} 'Other' action widgets
 */
OO.ui.ActionSet.prototype.getOthers = function () {
	this.organize();
	return this.others.slice();
};

/**
 * Set the mode  (e.g., ‘edit’ or ‘view’). Only {@link OO.ui.ActionWidget#modes actions} configured
 * to be available in the specified mode will be made visible. All other actions will be hidden.
 *
 * @param {string} mode The mode. Only actions configured to be available in the specified
 *  mode will be made visible.
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
 * Set the abilities of the specified actions.
 *
 * Action widgets that are configured with the specified actions will be enabled
 * or disabled based on the boolean values specified in the `actions`
 * parameter.
 *
 * @param {Object.<string,boolean>} actions A list keyed by action name with boolean
 *  values that indicate whether or not the action should be enabled.
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
 * manually to defer emitting a #change event until after all actions have been changed.
 *
 * @param {Object|null} actions Filters to use to determine which actions to iterate over; see #get
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
 * Add action widgets to the action set.
 *
 * @param {OO.ui.ActionWidget[]} actions Action widgets to add
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
 * Remove action widgets from the set.
 *
 * To remove all actions, you may wish to use the #clear method instead.
 *
 * @param {OO.ui.ActionWidget[]} actions Action widgets to remove
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
 * Remove all action widets from the set.
 *
 * To remove only specified actions, use the {@link #method-remove remove} method instead.
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
	this.debouncedUpdateThemeClassesHandler = OO.ui.debounce( this.debouncedUpdateThemeClasses );

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
	var obj = OO.ui.Element.static.unsafeInfuse( idOrNode, false );
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
 * @param {jQuery.Promise|boolean} domPromise A promise that will be resolved
 *     when the top-level widget of this infusion is inserted into DOM,
 *     replacing the original node; or false for top-level invocation.
 * @return {OO.ui.Element}
 */
OO.ui.Element.static.unsafeInfuse = function ( idOrNode, domPromise ) {
	// look for a cached result of a previous infusion.
	var id, $elem, data, cls, parts, parent, obj, top, state;
	if ( typeof idOrNode === 'string' ) {
		id = idOrNode;
		$elem = $( document.getElementById( id ) );
	} else {
		$elem = $( idOrNode );
		id = $elem.attr( 'id' );
	}
	if ( !$elem.length ) {
		throw new Error( 'Widget not found: ' + id );
	}
	data = $elem.data( 'ooui-infused' ) || $elem[ 0 ].oouiInfused;
	if ( data ) {
		// cached!
		if ( data === true ) {
			throw new Error( 'Circular dependency! ' + id );
		}
		return data;
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
	parts = data._.split( '.' );
	cls = OO.getProp.apply( OO, [ window ].concat( parts ) );
	if ( cls === undefined ) {
		// The PHP output might be old and not including the "OO.ui" prefix
		// TODO: Remove this back-compat after next major release
		cls = OO.getProp.apply( OO, [ OO.ui ].concat( parts ) );
		if ( cls === undefined ) {
			throw new Error( 'Unknown widget type: id: ' + id + ', class: ' + data._ );
		}
	}

	// Verify that we're creating an OO.ui.Element instance
	parent = cls.parent;

	while ( parent !== undefined ) {
		if ( parent === OO.ui.Element ) {
			// Safe
			break;
		}

		parent = parent.parent;
	}

	if ( parent !== OO.ui.Element ) {
		throw new Error( 'Unknown widget type: id: ' + id + ', class: ' + data._ );
	}

	if ( domPromise === false ) {
		top = $.Deferred();
		domPromise = top.promise();
	}
	$elem.data( 'ooui-infused', true ); // prevent loops
	data.id = id; // implicit
	data = OO.copy( data, null, function deserialize( value ) {
		if ( OO.isPlainObject( value ) ) {
			if ( value.tag ) {
				return OO.ui.Element.static.unsafeInfuse( value.tag, domPromise );
			}
			if ( value.html ) {
				return new OO.ui.HtmlSnippet( value.html );
			}
		}
	} );
	// jscs:disable requireCapitalizedConstructors
	obj = new cls( data ); // rebuild widget
	// pick up dynamic state, like focus, value of form inputs, scroll position, etc.
	state = obj.gatherPreInfuseState( $elem );
	// now replace old DOM with this new DOM.
	if ( top ) {
		$elem.replaceWith( obj.$element );
		// This element is now gone from the DOM, but if anyone is holding a reference to it,
		// let's allow them to OO.ui.infuse() it and do what they expect (T105828).
		// Do not use jQuery.data(), as using it on detached nodes leaks memory in 1.x line by design.
		$elem[ 0 ].oouiInfused = obj;
		top.resolve();
	}
	obj.$element.data( 'ooui-infused', obj );
	// set the 'data-ooui' attribute so we can identify infused widgets
	obj.$element.attr( 'data-ooui', '' );
	// restore dynamic state after the new element is inserted into DOM
	domPromise.done( obj.restorePreInfuseState.bind( obj, state ) );
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
	// Support: IE 8
	// Standard Document.defaultView is IE9+
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
		// Support: IE 8
		// Standard Document.defaultView is IE9+
		win = doc.parentWindow || doc.defaultView,
		style = win && win.getComputedStyle ?
			win.getComputedStyle( el, null ) :
			// Support: IE 8
			// Standard getComputedStyle() is IE9+
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
		// Support: IE 8
		// Standard Document.defaultView is IE9+
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
		// props = [ 'overflow' ] doesn't work due to https://bugzilla.mozilla.org/show_bug.cgi?id=889091
		props = [ 'overflow-x', 'overflow-y' ],
		$parent = $( el ).parent();

	if ( dimension === 'x' || dimension === 'y' ) {
		props = [ 'overflow-' + dimension ];
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
	var rel, anim, callback, sc, $sc, eld, scd, $win;

	// Configuration initialization
	config = config || {};

	anim = {};
	callback = typeof config.complete === 'function' && config.complete;
	sc = this.getClosestScrollableContainer( el, config.direction );
	$sc = $( sc );
	eld = this.getDimensions( el );
	scd = this.getDimensions( sc );
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
	var i, len, scrollLeft, scrollTop, nodes = [];
	// Save scroll position
	scrollLeft = el.scrollLeft;
	scrollTop = el.scrollTop;
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
	// Restore scroll position (no-op if scrollbars disappeared)
	el.scrollLeft = scrollLeft;
	el.scrollTop = scrollTop;
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
	this.debouncedUpdateThemeClassesHandler();
};

/**
 * @private
 * @localdoc This method is called directly from the QUnit tests instead of #updateThemeClasses, to
 *   make them synchronous.
 */
OO.ui.Element.prototype.debouncedUpdateThemeClasses = function () {
	OO.ui.theme.updateElementClasses( this );
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
 * @return {OO.ui.mixin.GroupElement|null} Group element, null if none
 */
OO.ui.Element.prototype.getElementGroup = function () {
	return this.elementGroup;
};

/**
 * Set group element is in.
 *
 * @param {OO.ui.mixin.GroupElement|null} group Group element, null if none
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
 * Gather the dynamic state (focus, value of form inputs, scroll position, etc.) of a HTML DOM node
 * (and its children) that represent an Element of the same type and configuration as the current
 * one, generated by the PHP implementation.
 *
 * This method is called just before `node` is detached from the DOM. The return value of this
 * function will be passed to #restorePreInfuseState after this widget's #$element is inserted into
 * DOM to replace `node`.
 *
 * @protected
 * @param {HTMLElement} node
 * @return {Object}
 */
OO.ui.Element.prototype.gatherPreInfuseState = function () {
	return {};
};

/**
 * Restore the pre-infusion dynamic state for this widget.
 *
 * This method is called after #$element has been inserted into DOM. The parameter is the return
 * value of #gatherPreInfuseState.
 *
 * @protected
 * @param {Object} state
 */
OO.ui.Element.prototype.restorePreInfuseState = function () {
};

/**
 * Layouts are containers for elements and are used to arrange other widgets of arbitrary type in a way
 * that is centrally controlled and can be updated dynamically. Layouts can be, and usually are, combined.
 * See {@link OO.ui.FieldsetLayout FieldsetLayout}, {@link OO.ui.FieldLayout FieldLayout}, {@link OO.ui.FormLayout FormLayout},
 * {@link OO.ui.PanelLayout PanelLayout}, {@link OO.ui.StackLayout StackLayout}, {@link OO.ui.PageLayout PageLayout},
 * {@link OO.ui.HorizontalLayout HorizontalLayout}, and {@link OO.ui.BookletLayout BookletLayout} for more information and examples.
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
	OO.ui.Layout.parent.call( this, config );

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
 * @cfg {boolean} [disabled=false] Disable the widget. Disabled widgets cannot be used and their
 *  appearance reflects this state.
 */
OO.ui.Widget = function OoUiWidget( config ) {
	// Initialize config
	config = $.extend( { disabled: false }, config );

	// Parent constructor
	OO.ui.Widget.parent.call( this, config );

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

/* Static Properties */

/**
 * Whether this widget will behave reasonably when wrapped in a HTML `<label>`. If this is true,
 * wrappers such as OO.ui.FieldLayout may use a `<label>` instead of implementing own label click
 * handling.
 *
 * @static
 * @inheritable
 * @property {boolean}
 */
OO.ui.Widget.static.supportsSimpleLabel = false;

/* Events */

/**
 * @event disable
 *
 * A 'disable' event is emitted when a widget is disabled.
 *
 * @param {boolean} disabled Widget is disabled
 */

/**
 * @event toggle
 *
 * A 'toggle' event is emitted when the visibility of the widget changes.
 *
 * @param {boolean} visible Widget is visible
 */

/* Methods */

/**
 * Check if the widget is disabled.
 *
 * @return {boolean} Widget is disabled
 */
OO.ui.Widget.prototype.isDisabled = function () {
	return this.disabled;
};

/**
 * Set the 'disabled' state of the widget.
 *
 * When a widget is disabled, it cannot be used and its appearance is updated to reflect this state.
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
 * @cfg {string} [size] Symbolic name of the dialog size: `small`, `medium`, `large`, `larger` or
 *  `full`.  If omitted, the value of the {@link #static-size static size} property will be used.
 */
OO.ui.Window = function OoUiWindow( config ) {
	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.Window.parent.call( this, config );

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
		.attr( 'tabindex', 0 );
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
 * Symbolic name of the window size: `small`, `medium`, `large`, `larger` or `full`.
 *
 * The static size is used if no #size is configured during construction.
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
 * @private
 * @param {jQuery.Event} e Mouse down event
 */
OO.ui.Window.prototype.onMouseDown = function ( e ) {
	// Prevent clicking on the click-block from stealing focus
	if ( e.target === this.$element[ 0 ] ) {
		return false;
	}
};

/**
 * Check if the window has been initialized.
 *
 * Initialization occurs when a window is added to a manager.
 *
 * @return {boolean} Window has been initialized
 */
OO.ui.Window.prototype.isInitialized = function () {
	return !!this.manager;
};

/**
 * Check if the window is visible.
 *
 * @return {boolean} Window is visible
 */
OO.ui.Window.prototype.isVisible = function () {
	return this.visible;
};

/**
 * Check if the window is opening.
 *
 * This method is a wrapper around the window manager's {@link OO.ui.WindowManager#isOpening isOpening}
 * method.
 *
 * @return {boolean} Window is opening
 */
OO.ui.Window.prototype.isOpening = function () {
	return this.manager.isOpening( this );
};

/**
 * Check if the window is closing.
 *
 * This method is a wrapper around the window manager's {@link OO.ui.WindowManager#isClosing isClosing} method.
 *
 * @return {boolean} Window is closing
 */
OO.ui.Window.prototype.isClosing = function () {
	return this.manager.isClosing( this );
};

/**
 * Check if the window is opened.
 *
 * This method is a wrapper around the window manager's {@link OO.ui.WindowManager#isOpened isOpened} method.
 *
 * @return {boolean} Window is opened
 */
OO.ui.Window.prototype.isOpened = function () {
	return this.manager.isOpened( this );
};

/**
 * Get the window manager.
 *
 * All windows must be attached to a window manager, which is used to open
 * and close the window and control its presentation.
 *
 * @return {OO.ui.WindowManager} Manager of window
 */
OO.ui.Window.prototype.getManager = function () {
	return this.manager;
};

/**
 * Get the symbolic name of the window size (e.g., `small` or `medium`).
 *
 * @return {string} Symbolic name of the size: `small`, `medium`, `large`, `larger`, `full`
 */
OO.ui.Window.prototype.getSize = function () {
	var viewport = OO.ui.Element.static.getDimensions( this.getElementWindow() ),
		sizes = this.manager.constructor.static.sizes,
		size = this.size;

	if ( !sizes[ size ] ) {
		size = this.manager.constructor.static.defaultSize;
	}
	if ( size !== 'full' && viewport.rect.right - viewport.rect.left < sizes[ size ].width ) {
		size = 'full';
	}

	return size;
};

/**
 * Get the size properties associated with the current window size
 *
 * @return {Object} Size properties
 */
OO.ui.Window.prototype.getSizeProperties = function () {
	return this.manager.constructor.static.sizes[ this.getSize() ];
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
 * Get the height of the full window contents (i.e., the window head, body and foot together).
 *
 * What consistitutes the head, body, and foot varies depending on the window type.
 * A {@link OO.ui.MessageDialog message dialog} displays a title and message in its body,
 * and any actions in the foot. A {@link OO.ui.ProcessDialog process dialog} displays a title
 * and special actions in the head, and dialog content in the body.
 *
 * To get just the height of the dialog body, use the #getBodyHeight method.
 *
 * @return {number} The height of the window contents (the dialog head, body and foot) in pixels
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
 * Get the height of the window body.
 *
 * To get the height of the full window contents (the window body, head, and foot together),
 * use #getContentHeight.
 *
 * When this function is called, the window will temporarily have been resized
 * to height=1px, so .scrollHeight measurements can be taken accurately.
 *
 * @return {number} Height of the window body in pixels
 */
OO.ui.Window.prototype.getBodyHeight = function () {
	return this.$body[ 0 ].scrollHeight;
};

/**
 * Get the directionality of the frame (right-to-left or left-to-right).
 *
 * @return {string} Directionality: `'ltr'` or `'rtl'`
 */
OO.ui.Window.prototype.getDir = function () {
	return OO.ui.Element.static.getDir( this.$content ) || 'ltr';
};

/**
 * Get the 'setup' process.
 *
 * The setup process is used to set up a window for use in a particular context,
 * based on the `data` argument. This method is called during the opening phase of the window’s
 * lifecycle.
 *
 * Override this method to add additional steps to the ‘setup’ process the parent method provides
 * using the {@link OO.ui.Process#first first} and {@link OO.ui.Process#next next} methods
 * of OO.ui.Process.
 *
 * To add window content that persists between openings, you may wish to use the #initialize method
 * instead.
 *
 * @abstract
 * @param {Object} [data] Window opening data
 * @return {OO.ui.Process} Setup process
 */
OO.ui.Window.prototype.getSetupProcess = function () {
	return new OO.ui.Process();
};

/**
 * Get the ‘ready’ process.
 *
 * The ready process is used to ready a window for use in a particular
 * context, based on the `data` argument. This method is called during the opening phase of
 * the window’s lifecycle, after the window has been {@link #getSetupProcess setup}.
 *
 * Override this method to add additional steps to the ‘ready’ process the parent method
 * provides using the {@link OO.ui.Process#first first} and {@link OO.ui.Process#next next}
 * methods of OO.ui.Process.
 *
 * @abstract
 * @param {Object} [data] Window opening data
 * @return {OO.ui.Process} Ready process
 */
OO.ui.Window.prototype.getReadyProcess = function () {
	return new OO.ui.Process();
};

/**
 * Get the 'hold' process.
 *
 * The hold proccess is used to keep a window from being used in a particular context,
 * based on the `data` argument. This method is called during the closing phase of the window’s
 * lifecycle.
 *
 * Override this method to add additional steps to the 'hold' process the parent method provides
 * using the {@link OO.ui.Process#first first} and {@link OO.ui.Process#next next} methods
 * of OO.ui.Process.
 *
 * @abstract
 * @param {Object} [data] Window closing data
 * @return {OO.ui.Process} Hold process
 */
OO.ui.Window.prototype.getHoldProcess = function () {
	return new OO.ui.Process();
};

/**
 * Get the ‘teardown’ process.
 *
 * The teardown process is used to teardown a window after use. During teardown,
 * user interactions within the window are conveyed and the window is closed, based on the `data`
 * argument. This method is called during the closing phase of the window’s lifecycle.
 *
 * Override this method to add additional steps to the ‘teardown’ process the parent method provides
 * using the {@link OO.ui.Process#first first} and {@link OO.ui.Process#next next} methods
 * of OO.ui.Process.
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
 * @throws {Error} An error is thrown if the method is called more than once
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
 * Set the window size by symbolic name (e.g., 'small' or 'medium')
 *
 * @param {string} size Symbolic name of size: `small`, `medium`, `large`, `larger` or
 *  `full`
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
 * @throws {Error} An error is thrown if the window is not attached to a window manager
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
 * Set window dimensions. This method is called by the {@link OO.ui.WindowManager window manager}
 * when the window is opening. In general, setDimensions should not be called directly.
 *
 * To set the size of the window, use the #setSize method.
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
 * Before the window is opened for the first time, #initialize is called so that content that
 * persists between openings can be added to the window.
 *
 * To set up a window with new content each time the window opens, use #getSetupProcess.
 *
 * @throws {Error} An error is thrown if the window is not attached to a window manager
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
 * Open the window.
 *
 * This method is a wrapper around a call to the window manager’s {@link OO.ui.WindowManager#openWindow openWindow}
 * method, which returns a promise resolved when the window is done opening.
 *
 * To customize the window each time it opens, use #getSetupProcess or #getReadyProcess.
 *
 * @param {Object} [data] Window opening data
 * @return {jQuery.Promise} Promise resolved with a value when the window is opened, or rejected
 *  if the window fails to open. When the promise is resolved successfully, the first argument of the
 *  value is a new promise, which is resolved when the window begins closing.
 * @throws {Error} An error is thrown if the window is not attached to a window manager
 */
OO.ui.Window.prototype.open = function ( data ) {
	if ( !this.manager ) {
		throw new Error( 'Cannot open window, must be attached to a manager' );
	}

	return this.manager.openWindow( this, data );
};

/**
 * Close the window.
 *
 * This method is a wrapper around a call to the window
 * manager’s {@link OO.ui.WindowManager#closeWindow closeWindow} method,
 * which returns a closing promise resolved when the window is done closing.
 *
 * The window's #getHoldProcess and #getTeardownProcess methods are called during the closing
 * phase of the window’s lifecycle and can be used to specify closing behavior each time
 * the window closes.
 *
 * @param {Object} [data] Window closing data
 * @return {jQuery.Promise} Promise resolved when window is closed
 * @throws {Error} An error is thrown if the window is not attached to a window manager
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
 *         MyDialog.parent.call( this, config );
 *     }
 *     OO.inheritClass( MyDialog, OO.ui.Dialog );
 *     MyDialog.prototype.initialize = function () {
 *         MyDialog.parent.prototype.initialize.call( this );
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
 * @mixins OO.ui.mixin.PendingElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
OO.ui.Dialog = function OoUiDialog( config ) {
	// Parent constructor
	OO.ui.Dialog.parent.call( this, config );

	// Mixin constructors
	OO.ui.mixin.PendingElement.call( this );

	// Properties
	this.actions = new OO.ui.ActionSet();
	this.attachedActions = [];
	this.currentAction = null;
	this.onDialogKeyDownHandler = this.onDialogKeyDown.bind( this );

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
OO.mixinClass( OO.ui.Dialog, OO.ui.mixin.PendingElement );

/* Static Properties */

/**
 * Symbolic name of dialog.
 *
 * The dialog class must have a symbolic name in order to be registered with OO.Factory.
 * Please see the [OOjs UI documentation on MediaWiki] [3] for more information.
 *
 * [3]: https://www.mediawiki.org/wiki/OOjs_UI/Windows/Window_managers
 *
 * @abstract
 * @static
 * @inheritable
 * @property {string}
 */
OO.ui.Dialog.static.name = '';

/**
 * The dialog title.
 *
 * The title can be specified as a plaintext string, a {@link OO.ui.mixin.LabelElement Label} node, or a function
 * that will produce a Label node or string. The title can also be specified with data passed to the
 * constructor (see #getSetupProcess). In this case, the static value will be overriden.
 *
 * @abstract
 * @static
 * @inheritable
 * @property {jQuery|string|Function}
 */
OO.ui.Dialog.static.title = '';

/**
 * An array of configured {@link OO.ui.ActionWidget action widgets}.
 *
 * Actions can also be specified with data passed to the constructor (see #getSetupProcess). In this case, the static
 * value will be overriden.
 *
 * [2]: https://www.mediawiki.org/wiki/OOjs_UI/Windows/Process_Dialogs#Action_sets
 *
 * @static
 * @inheritable
 * @property {Object[]}
 */
OO.ui.Dialog.static.actions = [];

/**
 * Close the dialog when the 'Esc' key is pressed.
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
 * @private
 * @param {jQuery.Event} e Key down event
 */
OO.ui.Dialog.prototype.onDialogKeyDown = function ( e ) {
	if ( e.which === OO.ui.Keys.ESCAPE ) {
		this.close();
		e.preventDefault();
		e.stopPropagation();
	}
};

/**
 * Handle action resized events.
 *
 * @private
 * @param {OO.ui.ActionWidget} action Action that was resized
 */
OO.ui.Dialog.prototype.onActionResize = function () {
	// Override in subclass
};

/**
 * Handle action click events.
 *
 * @private
 * @param {OO.ui.ActionWidget} action Action that was clicked
 */
OO.ui.Dialog.prototype.onActionClick = function ( action ) {
	if ( !this.isPending() ) {
		this.executeAction( action.getAction() );
	}
};

/**
 * Handle actions change event.
 *
 * @private
 */
OO.ui.Dialog.prototype.onActionsChange = function () {
	this.detachActions();
	if ( !this.isClosing() ) {
		this.attachActions();
	}
};

/**
 * Get the set of actions used by the dialog.
 *
 * @return {OO.ui.ActionSet}
 */
OO.ui.Dialog.prototype.getActions = function () {
	return this.actions;
};

/**
 * Get a process for taking action.
 *
 * When you override this method, you can create a new OO.ui.Process and return it, or add additional
 * accept steps to the process the parent method provides using the {@link OO.ui.Process#first 'first'}
 * and {@link OO.ui.Process#next 'next'} methods of OO.ui.Process.
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
 * @param {jQuery|string|Function|null} [data.title] Dialog title, omit to use
 *  the {@link #static-title static title}
 * @param {Object[]} [data.actions] List of configuration options for each
 *   {@link OO.ui.ActionWidget action widget}, omit to use {@link #static-actions static actions}.
 */
OO.ui.Dialog.prototype.getSetupProcess = function ( data ) {
	data = data || {};

	// Parent method
	return OO.ui.Dialog.parent.prototype.getSetupProcess.call( this, data )
		.next( function () {
			var config = this.constructor.static,
				actions = data.actions !== undefined ? data.actions : config.actions;

			this.title.setLabel(
				data.title !== undefined ? data.title : this.constructor.static.title
			);
			this.actions.add( this.getActionWidgets( actions ) );

			if ( this.constructor.static.escapable ) {
				this.$element.on( 'keydown', this.onDialogKeyDownHandler );
			}
		}, this );
};

/**
 * @inheritdoc
 */
OO.ui.Dialog.prototype.getTeardownProcess = function ( data ) {
	// Parent method
	return OO.ui.Dialog.parent.prototype.getTeardownProcess.call( this, data )
		.first( function () {
			if ( this.constructor.static.escapable ) {
				this.$element.off( 'keydown', this.onDialogKeyDownHandler );
			}

			this.actions.clear();
			this.currentAction = null;
		}, this );
};

/**
 * @inheritdoc
 */
OO.ui.Dialog.prototype.initialize = function () {
	var titleId;

	// Parent method
	OO.ui.Dialog.parent.prototype.initialize.call( this );

	titleId = OO.ui.generateElementId();

	// Properties
	this.title = new OO.ui.LabelWidget( {
		id: titleId
	} );

	// Initialization
	this.$content.addClass( 'oo-ui-dialog-content' );
	this.$element.attr( 'aria-labelledby', titleId );
	this.setPendingElement( this.$head );
};

/**
 * Get action widgets from a list of configs
 *
 * @param {Object[]} actions Action widget configs
 * @return {OO.ui.ActionWidget[]} Action widgets
 */
OO.ui.Dialog.prototype.getActionWidgets = function ( actions ) {
	var i, len, widgets = [];
	for ( i = 0, len = actions.length; i < len; i++ ) {
		widgets.push(
			new OO.ui.ActionWidget( actions[ i ] )
		);
	}
	return widgets;
};

/**
 * Attach action actions.
 *
 * @protected
 */
OO.ui.Dialog.prototype.attachActions = function () {
	// Remember the list of potentially attached actions
	this.attachedActions = this.actions.get();
};

/**
 * Detach action actions.
 *
 * @protected
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
 *  Note that window classes that are instantiated with a factory must have
 *  a {@link OO.ui.Dialog#static-name static name} property that specifies a symbolic name.
 * @cfg {boolean} [modal=true] Prevent interaction outside the dialog
 */
OO.ui.WindowManager = function OoUiWindowManager( config ) {
	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.WindowManager.parent.call( this, config );

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
 * An 'opening' event is emitted when the window begins to be opened.
 *
 * @event opening
 * @param {OO.ui.Window} win Window that's being opened
 * @param {jQuery.Promise} opening An `opening` promise resolved with a value when the window is opened successfully.
 *  When the `opening` promise is resolved, the first argument of the value is an 'opened' promise, the second argument
 *  is the opening data. The `opening` promise emits `setup` and `ready` notifications when those processes are complete.
 * @param {Object} data Window opening data
 */

/**
 * A 'closing' event is emitted when the window begins to be closed.
 *
 * @event closing
 * @param {OO.ui.Window} win Window that's being closed
 * @param {jQuery.Promise} closing A `closing` promise is resolved with a value when the window
 *  is closed successfully. The promise emits `hold` and `teardown` notifications when those
 *  processes are complete. When the `closing` promise is resolved, the first argument of its value
 *  is the closing data.
 * @param {Object} data Window closing data
 */

/**
 * A 'resize' event is emitted when a window is resized.
 *
 * @event resize
 * @param {OO.ui.Window} win Window that was resized
 */

/* Static Properties */

/**
 * Map of the symbolic name of each window size and its CSS properties.
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
 * Symbolic name of the default window size.
 *
 * The default size is used if the window's requested size is not recognized.
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
 * @private
 * @param {jQuery.Event} e Window resize event
 */
OO.ui.WindowManager.prototype.onWindowResize = function () {
	clearTimeout( this.onWindowResizeTimeout );
	this.onWindowResizeTimeout = setTimeout( this.afterWindowResizeHandler, 200 );
};

/**
 * Handle window resize events.
 *
 * @private
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
 * Get the number of milliseconds to wait after opening begins before executing the ‘setup’ process.
 *
 * @param {OO.ui.Window} win Window being opened
 * @param {Object} [data] Window opening data
 * @return {number} Milliseconds to wait
 */
OO.ui.WindowManager.prototype.getSetupDelay = function () {
	return 0;
};

/**
 * Get the number of milliseconds to wait after setup has finished before executing the ‘ready’ process.
 *
 * @param {OO.ui.Window} win Window being opened
 * @param {Object} [data] Window opening data
 * @return {number} Milliseconds to wait
 */
OO.ui.WindowManager.prototype.getReadyDelay = function () {
	return 0;
};

/**
 * Get the number of milliseconds to wait after closing has begun before executing the 'hold' process.
 *
 * @param {OO.ui.Window} win Window being closed
 * @param {Object} [data] Window closing data
 * @return {number} Milliseconds to wait
 */
OO.ui.WindowManager.prototype.getHoldDelay = function () {
	return 0;
};

/**
 * Get the number of milliseconds to wait after the ‘hold’ process has finished before
 * executing the ‘teardown’ process.
 *
 * @param {OO.ui.Window} win Window being closed
 * @param {Object} [data] Window closing data
 * @return {number} Milliseconds to wait
 */
OO.ui.WindowManager.prototype.getTeardownDelay = function () {
	return this.modal ? 250 : 0;
};

/**
 * Get a window by its symbolic name.
 *
 * If the window is not yet instantiated and its symbolic name is recognized by a factory, it will be
 * instantiated and added to the window manager automatically. Please see the [OOjs UI documentation on MediaWiki][3]
 * for more information about using factories.
 * [3]: https://www.mediawiki.org/wiki/OOjs_UI/Windows/Window_managers
 *
 * @param {string} name Symbolic name of the window
 * @return {jQuery.Promise} Promise resolved with matching window, or rejected with an OO.ui.Error
 * @throws {Error} An error is thrown if the symbolic name is not recognized by the factory.
 * @throws {Error} An error is thrown if the named window is not recognized as a managed window.
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
 * @return {jQuery.Promise} An `opening` promise resolved when the window is done opening.
 *  See {@link #event-opening 'opening' event}  for more information about `opening` promises.
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
 * @return {jQuery.Promise} A `closing` promise resolved when the window is done closing.
 *  See {@link #event-closing 'closing' event} for more information about closing promises.
 * @throws {Error} An error is thrown if the window is not managed by the window manager.
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
 * Add windows to the window manager.
 *
 * Windows can be added by reference, symbolic name, or explicitly defined symbolic names.
 * See the [OOjs ui documentation on MediaWiki] [2] for examples.
 * [2]: https://www.mediawiki.org/wiki/OOjs_UI/Windows/Window_managers
 *
 * @param {Object.<string,OO.ui.Window>|OO.ui.Window[]} windows An array of window objects specified
 *  by reference, symbolic name, or explicitly defined symbolic names.
 * @throws {Error} An error is thrown if a window is added by symbolic name, but has neither an
 *  explicit nor a statically configured symbolic name.
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
 * Remove the specified windows from the windows manager.
 *
 * Windows will be closed before they are removed. If you wish to remove all windows, you may wish to use
 * the #clearWindows method instead. If you no longer need the window manager and want to ensure that it no
 * longer listens to events, use the #destroy method.
 *
 * @param {string[]} names Symbolic names of windows to remove
 * @return {jQuery.Promise} Promise resolved when window is closed and removed
 * @throws {Error} An error is thrown if the named windows are not managed by the window manager.
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
 * Remove all windows from the window manager.
 *
 * Windows will be closed before they are removed. Note that the window manager, though not in use, will still
 * listen to events. If the window manager will not be used again, you may wish to use the #destroy method instead.
 * To remove just a subset of windows, use the #removeWindows method.
 *
 * @return {jQuery.Promise} Promise resolved when all windows are closed and removed
 */
OO.ui.WindowManager.prototype.clearWindows = function () {
	return this.removeWindows( Object.keys( this.windows ) );
};

/**
 * Set dialog size. In general, this method should not be called directly.
 *
 * Fullscreen mode will be used if the dialog is too wide to fit in the screen.
 *
 * @chainable
 */
OO.ui.WindowManager.prototype.updateWindowSize = function ( win ) {
	var isFullscreen;

	// Bypass for non-current, and thus invisible, windows
	if ( win !== this.currentWindow ) {
		return;
	}

	isFullscreen = win.getSize() === 'full';

	this.$element.toggleClass( 'oo-ui-windowManager-fullscreen', isFullscreen );
	this.$element.toggleClass( 'oo-ui-windowManager-floating', !isFullscreen );
	win.setDimensions( win.getSizeProperties() );

	this.emit( 'resize', win );

	return this;
};

/**
 * Bind or unbind global events for scrolling.
 *
 * @private
 * @param {boolean} [on] Bind global events
 * @chainable
 */
OO.ui.WindowManager.prototype.toggleGlobalEvents = function ( on ) {
	var scrollWidth, bodyMargin,
		$body = $( this.getElementDocument().body ),
		// We could have multiple window managers open so only modify
		// the body css at the bottom of the stack
		stackDepth = $body.data( 'windowManagerGlobalEvents' ) || 0 ;

	on = on === undefined ? !!this.globalEvents : !!on;

	if ( on ) {
		if ( !this.globalEvents ) {
			$( this.getElementWindow() ).on( {
				// Start listening for top-level window dimension changes
				'orientationchange resize': this.onWindowResizeHandler
			} );
			if ( stackDepth === 0 ) {
				scrollWidth = window.innerWidth - document.documentElement.clientWidth;
				bodyMargin = parseFloat( $body.css( 'margin-right' ) ) || 0;
				$body.css( {
					overflow: 'hidden',
					'margin-right': bodyMargin + scrollWidth
				} );
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
			$body.css( {
				overflow: '',
				'margin-right': ''
			} );
		}
		this.globalEvents = false;
	}
	$body.data( 'windowManagerGlobalEvents', stackDepth );

	return this;
};

/**
 * Toggle screen reader visibility of content other than the window manager.
 *
 * @private
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
 * Destroy the window manager.
 *
 * Destroying the window manager ensures that it will no longer listen to events. If you would like to
 * continue using the window manager, but wish to remove all windows from it, use the #clearWindows method
 * instead.
 */
OO.ui.WindowManager.prototype.destroy = function () {
	this.toggleGlobalEvents( false );
	this.toggleAriaIsolation( false );
	this.clearWindows();
	this.$element.remove();
};

/**
 * Errors contain a required message (either a string or jQuery selection) that is used to describe what went wrong
 * in a {@link OO.ui.Process process}. The error's #recoverable and #warning configurations are used to customize the
 * appearance and functionality of the error interface.
 *
 * The basic error interface contains a formatted error message as well as two buttons: 'Dismiss' and 'Try again' (i.e., the error
 * is 'recoverable' by default). If the error is not recoverable, the 'Try again' button will not be rendered and the widget
 * that initiated the failed process will be disabled.
 *
 * If the error is a warning, the error interface will include a 'Dismiss' and a 'Continue' button, which will try the
 * process again.
 *
 * For an example of error interfaces, please see the [OOjs UI documentation on MediaWiki][1].
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Windows/Process_Dialogs#Processes_and_errors
 *
 * @class
 *
 * @constructor
 * @param {string|jQuery} message Description of error
 * @param {Object} [config] Configuration options
 * @cfg {boolean} [recoverable=true] Error is recoverable.
 *  By default, errors are recoverable, and users can try the process again.
 * @cfg {boolean} [warning=false] Error is a warning.
 *  If the error is a warning, the error interface will include a
 *  'Dismiss' and a 'Continue' button. It is the responsibility of the developer to ensure that the warning
 *  is not triggered a second time if the user chooses to continue.
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
 * Check if the error is recoverable.
 *
 * If the error is recoverable, users are able to try the process again.
 *
 * @return {boolean} Error is recoverable
 */
OO.ui.Error.prototype.isRecoverable = function () {
	return this.recoverable;
};

/**
 * Check if the error is a warning.
 *
 * If the error is a warning, the error interface will include a 'Dismiss' and a 'Continue' button.
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
 * Get the error message text.
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
 * A Process is a list of steps that are called in sequence. The step can be a number, a jQuery promise,
 * or a function:
 *
 * - **number**: the process will wait for the specified number of milliseconds before proceeding.
 * - **promise**: the process will continue to the next step when the promise is successfully resolved
 *  or stop if the promise is rejected.
 * - **function**: the process will execute the function. The process will stop if the function returns
 *  either a boolean `false` or a promise that is rejected; if the function returns a number, the process
 *  will wait for that number of milliseconds before proceeding.
 *
 * If the process fails, an {@link OO.ui.Error error} is generated. Depending on how the error is
 * configured, users can dismiss the error and try the process again, or not. If a process is stopped,
 * its remaining steps will not be performed.
 *
 * @class
 *
 * @constructor
 * @param {number|jQuery.Promise|Function} step Number of miliseconds to wait before proceeding, promise
 *  that must be resolved before proceeding, or a function to execute. See #createStep for more information. see #createStep for more information
 * @param {Object} [context=null] Execution context of the function. The context is ignored if the step is
 *  a number or promise.
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
 * @return {jQuery.Promise} Promise that is resolved when all steps have successfully completed.
 *  If any of the steps return a promise that is rejected or a boolean false, this promise is rejected
 *  and any remaining steps are not performed.
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
 * - Number of milliseconds to wait before proceeding
 * - Promise that must be resolved before proceeding
 * - Function to execute
 *   - If the function returns a boolean false the process will stop
 *   - If the function returns a promise, the process will continue to the next
 *     step when the promise is resolved or stop if the promise is rejected
 *   - If the function returns a number, the process will wait for that number of
 *     milliseconds before proceeding
 * @param {Object} [context=null] Execution context of the function. The context is
 *  ignored if the step is a number or promise.
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
 * A ToolFactory creates tools on demand. All tools ({@link OO.ui.Tool Tools}, {@link OO.ui.PopupTool PopupTools},
 * and {@link OO.ui.ToolGroupTool ToolGroupTools}) must be registered with a tool factory. Tools are
 * registered by their symbolic name. See {@link OO.ui.Toolbar toolbars} for an example.
 *
 * For more information about toolbars in general, please see the [OOjs UI documentation on MediaWiki][1].
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Toolbars
 *
 * @class
 * @extends OO.Factory
 * @constructor
 */
OO.ui.ToolFactory = function OoUiToolFactory() {
	// Parent constructor
	OO.ui.ToolFactory.parent.call( this );
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
 * ToolGroupFactories create {@link OO.ui.ToolGroup toolgroups} on demand. The toolgroup classes must
 * specify a symbolic name and be registered with the factory. The following classes are registered by
 * default:
 *
 * - {@link OO.ui.BarToolGroup BarToolGroups} (‘bar’)
 * - {@link OO.ui.MenuToolGroup MenuToolGroups} (‘menu’)
 * - {@link OO.ui.ListToolGroup ListToolGroups} (‘list’)
 *
 * See {@link OO.ui.Toolbar toolbars} for an example.
 *
 * For more information about toolbars in general, please see the [OOjs UI documentation on MediaWiki][1].
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Toolbars
 * @class
 * @extends OO.Factory
 * @constructor
 */
OO.ui.ToolGroupFactory = function OoUiToolGroupFactory() {
	var i, l, defaultClasses;
	// Parent constructor
	OO.Factory.call( this );

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
 * Get a default set of classes to be registered on construction.
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
	var $elements = $( [] ),
		classes = this.getElementClasses( element );

	if ( element.$icon ) {
		$elements = $elements.add( element.$icon );
	}
	if ( element.$indicator ) {
		$elements = $elements.add( element.$indicator );
	}

	$elements
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
 *         label: 'fourth',
 *         tabIndex: 4
 *     } );
 *     var button2 = new OO.ui.ButtonWidget( {
 *         label: 'second',
 *         tabIndex: 2
 *     } );
 *     var button3 = new OO.ui.ButtonWidget( {
 *         label: 'third',
 *         tabIndex: 3
 *     } );
 *     var button4 = new OO.ui.ButtonWidget( {
 *         label: 'first',
 *         tabIndex: 1
 *     } );
 *     $( 'body' ).append( button1.$element, button2.$element, button3.$element, button4.$element );
 *
 * @abstract
 * @class
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {jQuery} [$tabIndexed] The element that should use the tabindex functionality. By default,
 *  the functionality is applied to the element created by the class ($element). If a different element is specified, the tabindex
 *  functionality will be applied to it instead.
 * @cfg {number|null} [tabIndex=0] Number that specifies the element’s position in the tab-navigation
 *  order (e.g., 1 for the first focusable element). Use 0 to use the default navigation order; use -1
 *  to remove the element from the tab-navigation flow.
 */
OO.ui.mixin.TabIndexedElement = function OoUiMixinTabIndexedElement( config ) {
	// Configuration initialization
	config = $.extend( { tabIndex: 0 }, config );

	// Properties
	this.$tabIndexed = null;
	this.tabIndex = null;

	// Events
	this.connect( this, { disable: 'onTabIndexedElementDisable' } );

	// Initialization
	this.setTabIndex( config.tabIndex );
	this.setTabIndexedElement( config.$tabIndexed || this.$element );
};

/* Setup */

OO.initClass( OO.ui.mixin.TabIndexedElement );

/* Methods */

/**
 * Set the element that should use the tabindex functionality.
 *
 * This method is used to retarget a tabindex mixin so that its functionality applies
 * to the specified element. If an element is currently using the functionality, the mixin’s
 * effect on that element is removed before the new element is set up.
 *
 * @param {jQuery} $tabIndexed Element that should use the tabindex functionality
 * @chainable
 */
OO.ui.mixin.TabIndexedElement.prototype.setTabIndexedElement = function ( $tabIndexed ) {
	var tabIndex = this.tabIndex;
	// Remove attributes from old $tabIndexed
	this.setTabIndex( null );
	// Force update of new $tabIndexed
	this.$tabIndexed = $tabIndexed;
	this.tabIndex = tabIndex;
	return this.updateTabIndex();
};

/**
 * Set the value of the tabindex.
 *
 * @param {number|null} tabIndex Tabindex value, or `null` for no tabindex
 * @chainable
 */
OO.ui.mixin.TabIndexedElement.prototype.setTabIndex = function ( tabIndex ) {
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
 * @private
 * @chainable
 */
OO.ui.mixin.TabIndexedElement.prototype.updateTabIndex = function () {
	if ( this.$tabIndexed ) {
		if ( this.tabIndex !== null ) {
			// Do not index over disabled elements
			this.$tabIndexed.attr( {
				tabindex: this.isDisabled() ? -1 : this.tabIndex,
				// Support: ChromeVox and NVDA
				// These do not seem to inherit aria-disabled from parent elements
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
OO.ui.mixin.TabIndexedElement.prototype.onTabIndexedElementDisable = function () {
	this.updateTabIndex();
};

/**
 * Get the value of the tabindex.
 *
 * @return {number|null} Tabindex value
 */
OO.ui.mixin.TabIndexedElement.prototype.getTabIndex = function () {
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
 * @cfg {jQuery} [$button] The button element created by the class.
 *  If this configuration is omitted, the button element will use a generated `<a>`.
 * @cfg {boolean} [framed=true] Render the button with a frame
 */
OO.ui.mixin.ButtonElement = function OoUiMixinButtonElement( config ) {
	// Configuration initialization
	config = config || {};

	// Properties
	this.$button = null;
	this.framed = null;
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
	this.setButtonElement( config.$button || $( '<a>' ) );
};

/* Setup */

OO.initClass( OO.ui.mixin.ButtonElement );

/* Static Properties */

/**
 * Cancel mouse down events.
 *
 * This property is usually set to `true` to prevent the focus from changing when the button is clicked.
 * Classes such as {@link OO.ui.mixin.DraggableElement DraggableElement} and {@link OO.ui.ButtonOptionWidget ButtonOptionWidget}
 * use a value of `false` so that dragging behavior is possible and mousedown events can be handled by a
 * parent widget.
 *
 * @static
 * @inheritable
 * @property {boolean}
 */
OO.ui.mixin.ButtonElement.static.cancelButtonMouseDownEvents = true;

/* Events */

/**
 * A 'click' event is emitted when the button element is clicked.
 *
 * @event click
 */

/* Methods */

/**
 * Set the button element.
 *
 * This method is used to retarget a button mixin so that its functionality applies to
 * the specified button element instead of the one created by the class. If a button element
 * is already set, the method will remove the mixin’s effect on that element.
 *
 * @param {jQuery} $button Element to use as button
 */
OO.ui.mixin.ButtonElement.prototype.setButtonElement = function ( $button ) {
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
		.attr( { role: 'button' } )
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
OO.ui.mixin.ButtonElement.prototype.onMouseDown = function ( e ) {
	if ( this.isDisabled() || e.which !== 1 ) {
		return;
	}
	this.$element.addClass( 'oo-ui-buttonElement-pressed' );
	// Run the mouseup handler no matter where the mouse is when the button is let go, so we can
	// reliably remove the pressed class
	OO.ui.addCaptureEventListener( this.getElementDocument(), 'mouseup', this.onMouseUpHandler );
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
OO.ui.mixin.ButtonElement.prototype.onMouseUp = function ( e ) {
	if ( this.isDisabled() || e.which !== 1 ) {
		return;
	}
	this.$element.removeClass( 'oo-ui-buttonElement-pressed' );
	// Stop listening for mouseup, since we only needed this once
	OO.ui.removeCaptureEventListener( this.getElementDocument(), 'mouseup', this.onMouseUpHandler );
};

/**
 * Handles mouse click events.
 *
 * @protected
 * @param {jQuery.Event} e Mouse click event
 * @fires click
 */
OO.ui.mixin.ButtonElement.prototype.onClick = function ( e ) {
	if ( !this.isDisabled() && e.which === 1 ) {
		if ( this.emit( 'click' ) ) {
			return false;
		}
	}
};

/**
 * Handles key down events.
 *
 * @protected
 * @param {jQuery.Event} e Key down event
 */
OO.ui.mixin.ButtonElement.prototype.onKeyDown = function ( e ) {
	if ( this.isDisabled() || ( e.which !== OO.ui.Keys.SPACE && e.which !== OO.ui.Keys.ENTER ) ) {
		return;
	}
	this.$element.addClass( 'oo-ui-buttonElement-pressed' );
	// Run the keyup handler no matter where the key is when the button is let go, so we can
	// reliably remove the pressed class
	OO.ui.addCaptureEventListener( this.getElementDocument(), 'keyup', this.onKeyUpHandler );
};

/**
 * Handles key up events.
 *
 * @protected
 * @param {jQuery.Event} e Key up event
 */
OO.ui.mixin.ButtonElement.prototype.onKeyUp = function ( e ) {
	if ( this.isDisabled() || ( e.which !== OO.ui.Keys.SPACE && e.which !== OO.ui.Keys.ENTER ) ) {
		return;
	}
	this.$element.removeClass( 'oo-ui-buttonElement-pressed' );
	// Stop listening for keyup, since we only needed this once
	OO.ui.removeCaptureEventListener( this.getElementDocument(), 'keyup', this.onKeyUpHandler );
};

/**
 * Handles key press events.
 *
 * @protected
 * @param {jQuery.Event} e Key press event
 * @fires click
 */
OO.ui.mixin.ButtonElement.prototype.onKeyPress = function ( e ) {
	if ( !this.isDisabled() && ( e.which === OO.ui.Keys.SPACE || e.which === OO.ui.Keys.ENTER ) ) {
		if ( this.emit( 'click' ) ) {
			return false;
		}
	}
};

/**
 * Check if button has a frame.
 *
 * @return {boolean} Button is framed
 */
OO.ui.mixin.ButtonElement.prototype.isFramed = function () {
	return this.framed;
};

/**
 * Render the button with or without a frame. Omit the `framed` parameter to toggle the button frame on and off.
 *
 * @param {boolean} [framed] Make button framed, omit to toggle
 * @chainable
 */
OO.ui.mixin.ButtonElement.prototype.toggleFramed = function ( framed ) {
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
 * Set the button to its 'active' state.
 *
 * The active state occurs when a {@link OO.ui.ButtonOptionWidget ButtonOptionWidget} or
 * a {@link OO.ui.ToggleButtonWidget ToggleButtonWidget} is pressed. This method does nothing
 * for other button types.
 *
 * @param {boolean} [value] Make button active
 * @chainable
 */
OO.ui.mixin.ButtonElement.prototype.setActive = function ( value ) {
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
 * @cfg {jQuery} [$group] The container element created by the class. If this configuration
 *  is omitted, the group element will use a generated `<div>`.
 */
OO.ui.mixin.GroupElement = function OoUiMixinGroupElement( config ) {
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
OO.ui.mixin.GroupElement.prototype.setGroupElement = function ( $group ) {
	var i, len;

	this.$group = $group;
	for ( i = 0, len = this.items.length; i < len; i++ ) {
		this.$group.append( this.items[ i ].$element );
	}
};

/**
 * Check if a group contains no items.
 *
 * @return {boolean} Group is empty
 */
OO.ui.mixin.GroupElement.prototype.isEmpty = function () {
	return !this.items.length;
};

/**
 * Get all items in the group.
 *
 * The method returns an array of item references (e.g., [button1, button2, button3]) and is useful
 * when synchronizing groups of items, or whenever the references are required (e.g., when removing items
 * from a group).
 *
 * @return {OO.ui.Element[]} An array of items.
 */
OO.ui.mixin.GroupElement.prototype.getItems = function () {
	return this.items.slice( 0 );
};

/**
 * Get an item by its data.
 *
 * Only the first item with matching data will be returned. To return all matching items,
 * use the #getItemsFromData method.
 *
 * @param {Object} data Item data to search for
 * @return {OO.ui.Element|null} Item with equivalent data, `null` if none exists
 */
OO.ui.mixin.GroupElement.prototype.getItemFromData = function ( data ) {
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
 * All items with matching data will be returned. To return only the first match, use the #getItemFromData method instead.
 *
 * @param {Object} data Item data to search for
 * @return {OO.ui.Element[]} Items with equivalent data
 */
OO.ui.mixin.GroupElement.prototype.getItemsFromData = function ( data ) {
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
 * Aggregate the events emitted by the group.
 *
 * When events are aggregated, the group will listen to all contained items for the event,
 * and then emit the event under a new name. The new event will contain an additional leading
 * parameter containing the item that emitted the original event. Other arguments emitted from
 * the original event are passed through.
 *
 * @param {Object.<string,string|null>} events An object keyed by the name of the event that should be
 *  aggregated  (e.g., ‘click’) and the value of the new name to use (e.g., ‘groupClick’).
 *  A `null` value will remove aggregated events.

 * @throws {Error} An error is thrown if aggregation already exists.
 */
OO.ui.mixin.GroupElement.prototype.aggregate = function ( events ) {
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
					remove[ itemEvent ] = [ 'emit', this.aggregateItemEvents[ itemEvent ], item ];
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
 * Add items to the group.
 *
 * Items will be added to the end of the group array unless the optional `index` parameter specifies
 * a different insertion point. Adding an existing item will move it to the end of the array or the point specified by the `index`.
 *
 * @param {OO.ui.Element[]} items An array of items to add to the group
 * @param {number} [index] Index of the insertion point
 * @chainable
 */
OO.ui.mixin.GroupElement.prototype.addItems = function ( items, index ) {
	var i, len, item, event, events, currentIndex,
		itemElements = [];

	for ( i = 0, len = items.length; i < len; i++ ) {
		item = items[ i ];

		// Check if item exists then remove it first, effectively "moving" it
		currentIndex = this.items.indexOf( item );
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
 * Remove the specified items from a group.
 *
 * Removed items are detached (not removed) from the DOM so that they may be reused.
 * To remove all items from a group, you may wish to use the #clearItems method instead.
 *
 * @param {OO.ui.Element[]} items An array of items to remove
 * @chainable
 */
OO.ui.mixin.GroupElement.prototype.removeItems = function ( items ) {
	var i, len, item, index, remove, itemEvent;

	// Remove specific items
	for ( i = 0, len = items.length; i < len; i++ ) {
		item = items[ i ];
		index = this.items.indexOf( item );
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
 * Clear all items from the group.
 *
 * Cleared items are detached from the DOM, not removed, so that they may be reused.
 * To remove only a subset of items from a group, use the #removeItems method.
 *
 * @chainable
 */
OO.ui.mixin.GroupElement.prototype.clearItems = function () {
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
 * in conjunction with OO.ui.mixin.DraggableGroupElement, which provides a container for
 * the draggable elements.
 *
 * @abstract
 * @class
 *
 * @constructor
 */
OO.ui.mixin.DraggableElement = function OoUiMixinDraggableElement() {
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

OO.initClass( OO.ui.mixin.DraggableElement );

/* Events */

/**
 * @event dragstart
 *
 * A dragstart event is emitted when the user clicks and begins dragging an item.
 * @param {OO.ui.mixin.DraggableElement} item The item the user has clicked and is dragging with the mouse.
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
 * @inheritdoc OO.ui.mixin.ButtonElement
 */
OO.ui.mixin.DraggableElement.static.cancelButtonMouseDownEvents = false;

/* Methods */

/**
 * Respond to dragstart event.
 *
 * @private
 * @param {jQuery.Event} event jQuery event
 * @fires dragstart
 */
OO.ui.mixin.DraggableElement.prototype.onDragStart = function ( e ) {
	var dataTransfer = e.originalEvent.dataTransfer;
	// Define drop effect
	dataTransfer.dropEffect = 'none';
	dataTransfer.effectAllowed = 'move';
	// Support: Firefox
	// We must set up a dataTransfer data property or Firefox seems to
	// ignore the fact the element is draggable.
	try {
		dataTransfer.setData( 'application-x/OOjs-UI-draggable', this.getIndex() );
	} catch ( err ) {
		// The above is only for Firefox. Move on if it fails.
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
OO.ui.mixin.DraggableElement.prototype.onDragEnd = function () {
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
OO.ui.mixin.DraggableElement.prototype.onDrop = function ( e ) {
	e.preventDefault();
	this.emit( 'drop', e );
};

/**
 * In order for drag/drop to work, the dragover event must
 * return false and stop propogation.
 *
 * @private
 */
OO.ui.mixin.DraggableElement.prototype.onDragOver = function ( e ) {
	e.preventDefault();
};

/**
 * Set item index.
 * Store it in the DOM so we can access from the widget drag event
 *
 * @private
 * @param {number} Item index
 */
OO.ui.mixin.DraggableElement.prototype.setIndex = function ( index ) {
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
OO.ui.mixin.DraggableElement.prototype.getIndex = function () {
	return this.index;
};

/**
 * DraggableGroupElement is a mixin class used to create a group element to
 * contain draggable elements, which are items that can be clicked and dragged by a mouse.
 * The class is used with OO.ui.mixin.DraggableElement.
 *
 * @abstract
 * @class
 * @mixins OO.ui.mixin.GroupElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {string} [orientation] Item orientation: 'horizontal' or 'vertical'. The orientation
 *  should match the layout of the items. Items displayed in a single row
 *  or in several rows should use horizontal orientation. The vertical orientation should only be
 *  used when the items are displayed in a single column. Defaults to 'vertical'
 */
OO.ui.mixin.DraggableGroupElement = function OoUiMixinDraggableGroupElement( config ) {
	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.mixin.GroupElement.call( this, config );

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
		dragover: this.onDragOver.bind( this ),
		dragleave: this.onDragLeave.bind( this )
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
OO.mixinClass( OO.ui.mixin.DraggableGroupElement, OO.ui.mixin.GroupElement );

/* Events */

/**
 * A 'reorder' event is emitted when the order of items in the group changes.
 *
 * @event reorder
 * @param {OO.ui.mixin.DraggableElement} item Reordered item
 * @param {number} [newIndex] New index for the item
 */

/* Methods */

/**
 * Respond to item drag start event
 *
 * @private
 * @param {OO.ui.mixin.DraggableElement} item Dragged item
 */
OO.ui.mixin.DraggableGroupElement.prototype.onItemDragStart = function ( item ) {
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
 *
 * @private
 */
OO.ui.mixin.DraggableGroupElement.prototype.onItemDragEnd = function () {
	this.unsetDragItem();
	return false;
};

/**
 * Handle drop event and switch the order of the items accordingly
 *
 * @private
 * @param {OO.ui.mixin.DraggableElement} item Dropped item
 * @fires reorder
 */
OO.ui.mixin.DraggableGroupElement.prototype.onItemDrop = function ( item ) {
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
 *
 * @private
 */
OO.ui.mixin.DraggableGroupElement.prototype.onDragLeave = function () {
	// This means the item was dragged outside the widget
	this.$placeholder
		.css( 'left', 0 )
		.addClass( 'oo-ui-element-hidden' );
};

/**
 * Respond to dragover event
 *
 * @private
 * @param {jQuery.Event} event Event details
 */
OO.ui.mixin.DraggableGroupElement.prototype.onDragOver = function ( e ) {
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
 *
 * @param {OO.ui.mixin.DraggableElement} item Dragged item
 */
OO.ui.mixin.DraggableGroupElement.prototype.setDragItem = function ( item ) {
	this.dragItem = item;
};

/**
 * Unset the current dragged item
 */
OO.ui.mixin.DraggableGroupElement.prototype.unsetDragItem = function () {
	this.dragItem = null;
	this.itemDragOver = null;
	this.$placeholder.addClass( 'oo-ui-element-hidden' );
	this.sideInsertion = '';
};

/**
 * Get the item that is currently being dragged.
 *
 * @return {OO.ui.mixin.DraggableElement|null} The currently dragged item, or `null` if no item is being dragged
 */
OO.ui.mixin.DraggableGroupElement.prototype.getDragItem = function () {
	return this.dragItem;
};

/**
 * Check if an item in the group is currently being dragged.
 *
 * @return {Boolean} Item is being dragged
 */
OO.ui.mixin.DraggableGroupElement.prototype.isDragging = function () {
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
OO.ui.mixin.IconElement = function OoUiMixinIconElement( config ) {
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

OO.initClass( OO.ui.mixin.IconElement );

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
OO.ui.mixin.IconElement.static.icon = null;

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
OO.ui.mixin.IconElement.static.iconTitle = null;

/* Methods */

/**
 * Set the icon element. This method is used to retarget an icon mixin so that its functionality
 * applies to the specified icon element instead of the one created by the class. If an icon
 * element is already set, the mixin’s effect on that element is removed. Generated CSS classes
 * and mixin methods will no longer affect the element.
 *
 * @param {jQuery} $icon Element to use as icon
 */
OO.ui.mixin.IconElement.prototype.setIconElement = function ( $icon ) {
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

	this.updateThemeClasses();
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
OO.ui.mixin.IconElement.prototype.setIcon = function ( icon ) {
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
OO.ui.mixin.IconElement.prototype.setIconTitle = function ( iconTitle ) {
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
OO.ui.mixin.IconElement.prototype.getIcon = function () {
	return this.icon;
};

/**
 * Get the icon title. The title text is displayed when a user moves the mouse over the icon.
 *
 * @return {string} Icon title text
 */
OO.ui.mixin.IconElement.prototype.getIconTitle = function () {
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
OO.ui.mixin.IndicatorElement = function OoUiMixinIndicatorElement( config ) {
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

OO.initClass( OO.ui.mixin.IndicatorElement );

/* Static Properties */

/**
 * Symbolic name of the indicator (e.g., ‘alert’ or  ‘down’).
 * The static property will be overridden if the #indicator configuration is used.
 *
 * @static
 * @inheritable
 * @property {string|null}
 */
OO.ui.mixin.IndicatorElement.static.indicator = null;

/**
 * A text string used as the indicator title, a function that returns title text, or `null`
 * for no title. The static property will be overridden if the #indicatorTitle configuration is used.
 *
 * @static
 * @inheritable
 * @property {string|Function|null}
 */
OO.ui.mixin.IndicatorElement.static.indicatorTitle = null;

/* Methods */

/**
 * Set the indicator element.
 *
 * If an element is already set, it will be cleaned up before setting up the new element.
 *
 * @param {jQuery} $indicator Element to use as indicator
 */
OO.ui.mixin.IndicatorElement.prototype.setIndicatorElement = function ( $indicator ) {
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

	this.updateThemeClasses();
};

/**
 * Set the indicator by its symbolic name: ‘alert’, ‘down’, ‘next’, ‘previous’, ‘required’, ‘up’. Use `null` to remove the indicator.
 *
 * @param {string|null} indicator Symbolic name of indicator, or `null` for no indicator
 * @chainable
 */
OO.ui.mixin.IndicatorElement.prototype.setIndicator = function ( indicator ) {
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
 * Set the indicator title.
 *
 * The title is displayed when a user moves the mouse over the indicator.
 *
 * @param {string|Function|null} indicator Indicator title text, a function that returns text, or
 *   `null` for no indicator title
 * @chainable
 */
OO.ui.mixin.IndicatorElement.prototype.setIndicatorTitle = function ( indicatorTitle ) {
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
 * Get the symbolic name of the indicator (e.g., ‘alert’ or  ‘down’).
 *
 * @return {string} Symbolic name of indicator
 */
OO.ui.mixin.IndicatorElement.prototype.getIndicator = function () {
	return this.indicator;
};

/**
 * Get the indicator title.
 *
 * The title is displayed when a user moves the mouse over the indicator.
 *
 * @return {string} Indicator title text
 */
OO.ui.mixin.IndicatorElement.prototype.getIndicatorTitle = function () {
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
 * @cfg {jQuery|string|Function|OO.ui.HtmlSnippet} [label] The label text. The label can be specified
 *  as a plaintext string, a jQuery selection of elements, or a function that will produce a string
 *  in the future. See the [OOjs UI documentation on MediaWiki] [2] for examples.
 *  [2]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Icons,_Indicators,_and_Labels#Labels
 * @cfg {boolean} [autoFitLabel=true] Fit the label to the width of the parent element.
 *  The label will be truncated to fit if necessary.
 */
OO.ui.mixin.LabelElement = function OoUiMixinLabelElement( config ) {
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

OO.initClass( OO.ui.mixin.LabelElement );

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
OO.ui.mixin.LabelElement.static.label = null;

/* Methods */

/**
 * Set the label element.
 *
 * If an element is already set, it will be cleaned up before setting up the new element.
 *
 * @param {jQuery} $label Element to use as label
 */
OO.ui.mixin.LabelElement.prototype.setLabelElement = function ( $label ) {
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
OO.ui.mixin.LabelElement.prototype.setLabel = function ( label ) {
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
OO.ui.mixin.LabelElement.prototype.getLabel = function () {
	return this.label;
};

/**
 * Fit the label.
 *
 * @chainable
 */
OO.ui.mixin.LabelElement.prototype.fitLabel = function () {
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
OO.ui.mixin.LabelElement.prototype.setLabelContent = function ( label ) {
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
 * LookupElement is a mixin that creates a {@link OO.ui.FloatingMenuSelectWidget menu} of suggested values for
 * a {@link OO.ui.TextInputWidget text input widget}. Suggested values are based on the characters the user types
 * into the text input field and, in general, the menu is only displayed when the user types. If a suggested value is chosen
 * from the lookup menu, that value becomes the value of the input field.
 *
 * Note that a new menu of suggested items is displayed when a value is chosen from the lookup menu. If this is
 * not the desired behavior, disable lookup menus with the #setLookupsDisabled method, then set the value, then
 * re-enable lookups.
 *
 * See the [OOjs UI demos][1] for an example.
 *
 * [1]: https://tools.wmflabs.org/oojs-ui/oojs-ui/demos/index.html#widgets-apex-vector-ltr
 *
 * @class
 * @abstract
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {jQuery} [$overlay] Overlay for the lookup menu; defaults to relative positioning
 * @cfg {jQuery} [$container=this.$element] The container element. The lookup menu is rendered beneath the specified element.
 * @cfg {boolean} [allowSuggestionsWhenEmpty=false] Request and display a lookup menu when the text input is empty.
 *  By default, the lookup menu is not generated and displayed until the user begins to type.
 */
OO.ui.mixin.LookupElement = function OoUiMixinLookupElement( config ) {
	// Configuration initialization
	config = config || {};

	// Properties
	this.$overlay = config.$overlay || this.$element;
	this.lookupMenu = new OO.ui.FloatingMenuSelectWidget( {
		widget: this,
		input: this,
		$container: config.$container || this.$element
	} );

	this.allowSuggestionsWhenEmpty = config.allowSuggestionsWhenEmpty || false;

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
 * @protected
 * @param {jQuery.Event} e Input focus event
 */
OO.ui.mixin.LookupElement.prototype.onLookupInputFocus = function () {
	this.lookupInputFocused = true;
	this.populateLookupMenu();
};

/**
 * Handle input blur event.
 *
 * @protected
 * @param {jQuery.Event} e Input blur event
 */
OO.ui.mixin.LookupElement.prototype.onLookupInputBlur = function () {
	this.closeLookupMenu();
	this.lookupInputFocused = false;
};

/**
 * Handle input mouse down event.
 *
 * @protected
 * @param {jQuery.Event} e Input mouse down event
 */
OO.ui.mixin.LookupElement.prototype.onLookupInputMouseDown = function () {
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
 * @protected
 * @param {string} value New input value
 */
OO.ui.mixin.LookupElement.prototype.onLookupInputChange = function () {
	if ( this.lookupInputFocused ) {
		this.populateLookupMenu();
	}
};

/**
 * Handle the lookup menu being shown/hidden.
 *
 * @protected
 * @param {boolean} visible Whether the lookup menu is now visible.
 */
OO.ui.mixin.LookupElement.prototype.onLookupMenuToggle = function ( visible ) {
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
 * @protected
 * @param {OO.ui.MenuOptionWidget} item Selected item
 */
OO.ui.mixin.LookupElement.prototype.onLookupMenuItemChoose = function ( item ) {
	this.setValue( item.getData() );
};

/**
 * Get lookup menu.
 *
 * @private
 * @return {OO.ui.FloatingMenuSelectWidget}
 */
OO.ui.mixin.LookupElement.prototype.getLookupMenu = function () {
	return this.lookupMenu;
};

/**
 * Disable or re-enable lookups.
 *
 * When lookups are disabled, calls to #populateLookupMenu will be ignored.
 *
 * @param {boolean} disabled Disable lookups
 */
OO.ui.mixin.LookupElement.prototype.setLookupsDisabled = function ( disabled ) {
	this.lookupsDisabled = !!disabled;
};

/**
 * Open the menu. If there are no entries in the menu, this does nothing.
 *
 * @private
 * @chainable
 */
OO.ui.mixin.LookupElement.prototype.openLookupMenu = function () {
	if ( !this.lookupMenu.isEmpty() ) {
		this.lookupMenu.toggle( true );
	}
	return this;
};

/**
 * Close the menu, empty it, and abort any pending request.
 *
 * @private
 * @chainable
 */
OO.ui.mixin.LookupElement.prototype.closeLookupMenu = function () {
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
 * @private
 * @chainable
 */
OO.ui.mixin.LookupElement.prototype.populateLookupMenu = function () {
	var widget = this,
		value = this.getValue();

	if ( this.lookupsDisabled ) {
		return;
	}

	// If the input is empty, clear the menu, unless suggestions when empty are allowed.
	if ( !this.allowSuggestionsWhenEmpty && value === '' ) {
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
 * Highlight the first selectable item in the menu.
 *
 * @private
 * @chainable
 */
OO.ui.mixin.LookupElement.prototype.initializeLookupMenuSelection = function () {
	if ( !this.lookupMenu.getSelectedItem() ) {
		this.lookupMenu.highlightItem( this.lookupMenu.getFirstSelectableItem() );
	}
};

/**
 * Get lookup menu items for the current query.
 *
 * @private
 * @return {jQuery.Promise} Promise object which will be passed menu items as the first argument of
 *   the done event. If the request was aborted to make way for a subsequent request, this promise
 *   will not be rejected: it will remain pending forever.
 */
OO.ui.mixin.LookupElement.prototype.getLookupMenuItems = function () {
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
			.done( function ( response ) {
				// If this is an old request (and aborting it somehow caused it to still succeed),
				// ignore its success completely
				if ( ourRequest === widget.lookupRequest ) {
					widget.lookupQuery = null;
					widget.lookupRequest = null;
					widget.lookupCache[ value ] = widget.getLookupCacheDataFromResponse( response );
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
 *
 * @private
 */
OO.ui.mixin.LookupElement.prototype.abortLookupRequest = function () {
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
 * @protected
 * @abstract
 * @return {jQuery.Promise} jQuery AJAX object, or promise object with an .abort() method
 */
OO.ui.mixin.LookupElement.prototype.getLookupRequest = function () {
	// Stub, implemented in subclass
	return null;
};

/**
 * Pre-process data returned by the request from #getLookupRequest.
 *
 * The return value of this function will be cached, and any further queries for the given value
 * will use the cache rather than doing API requests.
 *
 * @protected
 * @abstract
 * @param {Mixed} response Response from server
 * @return {Mixed} Cached result data
 */
OO.ui.mixin.LookupElement.prototype.getLookupCacheDataFromResponse = function () {
	// Stub, implemented in subclass
	return [];
};

/**
 * Get a list of menu option widgets from the (possibly cached) data returned by
 * #getLookupCacheDataFromResponse.
 *
 * @protected
 * @abstract
 * @param {Mixed} data Cached result data, usually an array
 * @return {OO.ui.MenuOptionWidget[]} Menu items
 */
OO.ui.mixin.LookupElement.prototype.getLookupMenuOptionsFromData = function () {
	// Stub, implemented in subclass
	return [];
};

/**
 * Set the read-only state of the widget.
 *
 * This will also disable/enable the lookups functionality.
 *
 * @param {boolean} readOnly Make input read-only
 * @chainable
 */
OO.ui.mixin.LookupElement.prototype.setReadOnly = function ( readOnly ) {
	// Parent method
	// Note: Calling #setReadOnly this way assumes this is mixed into an OO.ui.TextInputWidget
	OO.ui.TextInputWidget.prototype.setReadOnly.call( this, readOnly );

	this.setLookupsDisabled( readOnly );
	// During construction, #setReadOnly is called before the OO.ui.mixin.LookupElement constructor
	if ( readOnly && this.lookupMenu ) {
		this.closeLookupMenu();
	}

	return this;
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
OO.ui.mixin.PopupElement = function OoUiMixinPopupElement( config ) {
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
OO.ui.mixin.PopupElement.prototype.getPopup = function () {
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
 * The flags affect the appearance of the buttons:
 *
 *     @example
 *     // FlaggedElement is mixed into ButtonWidget to provide styling flags
 *     var button1 = new OO.ui.ButtonWidget( {
 *         label: 'Constructive',
 *         flags: 'constructive'
 *     } );
 *     var button2 = new OO.ui.ButtonWidget( {
 *         label: 'Destructive',
 *         flags: 'destructive'
 *     } );
 *     var button3 = new OO.ui.ButtonWidget( {
 *         label: 'Progressive',
 *         flags: 'progressive'
 *     } );
 *     $( 'body' ).append( button1.$element, button2.$element, button3.$element );
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
 * @cfg {jQuery} [$flagged] The flagged element. By default,
 *  the flagged functionality is applied to the element created by the class ($element).
 *  If a different element is specified, the flagged functionality will be applied to it instead.
 */
OO.ui.mixin.FlaggedElement = function OoUiMixinFlaggedElement( config ) {
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
 * This method is used to retarget a flagged mixin so that its functionality applies to the specified element.
 * If an element is already set, the method will remove the mixin’s effect on that element.
 *
 * @param {jQuery} $flagged Element that should be flagged
 */
OO.ui.mixin.FlaggedElement.prototype.setFlaggedElement = function ( $flagged ) {
	var classNames = Object.keys( this.flags ).map( function ( flag ) {
		return 'oo-ui-flaggedElement-' + flag;
	} ).join( ' ' );

	if ( this.$flagged ) {
		this.$flagged.removeClass( classNames );
	}

	this.$flagged = $flagged.addClass( classNames );
};

/**
 * Check if the specified flag is set.
 *
 * @param {string} flag Name of flag
 * @return {boolean} The flag is set
 */
OO.ui.mixin.FlaggedElement.prototype.hasFlag = function ( flag ) {
	// This may be called before the constructor, thus before this.flags is set
	return this.flags && ( flag in this.flags );
};

/**
 * Get the names of all flags set.
 *
 * @return {string[]} Flag names
 */
OO.ui.mixin.FlaggedElement.prototype.getFlags = function () {
	// This may be called before the constructor, thus before this.flags is set
	return Object.keys( this.flags || {} );
};

/**
 * Clear all flags.
 *
 * @chainable
 * @fires flag
 */
OO.ui.mixin.FlaggedElement.prototype.clearFlags = function () {
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
 * @param {string|string[]|Object.<string, boolean>} flags A flag name, an array of flag names,
 *  or an object keyed by flag name with a boolean value that indicates whether the flag should
 *  be added (`true`) or removed (`false`).
 * @chainable
 * @fires flag
 */
OO.ui.mixin.FlaggedElement.prototype.setFlags = function ( flags ) {
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
 *         label: 'Button with Title',
 *         title: 'I am a button'
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
 *  this config is omitted, the value of the {@link #static-title static title} property is used.
 */
OO.ui.mixin.TitledElement = function OoUiMixinTitledElement( config ) {
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

OO.initClass( OO.ui.mixin.TitledElement );

/* Static Properties */

/**
 * The title text, a function that returns text, or `null` for no title. The value of the static property
 * is overridden if the #title config option is used.
 *
 * @static
 * @inheritable
 * @property {string|Function|null}
 */
OO.ui.mixin.TitledElement.static.title = null;

/* Methods */

/**
 * Set the titled element.
 *
 * This method is used to retarget a titledElement mixin so that its functionality applies to the specified element.
 * If an element is already set, the mixin’s effect on that element is removed before the new element is set up.
 *
 * @param {jQuery} $titled Element that should use the 'titled' functionality
 */
OO.ui.mixin.TitledElement.prototype.setTitledElement = function ( $titled ) {
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
 * @param {string|Function|null} title Title text, a function that returns text, or `null` for no title
 * @chainable
 */
OO.ui.mixin.TitledElement.prototype.setTitle = function ( title ) {
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
OO.ui.mixin.TitledElement.prototype.getTitle = function () {
	return this.title;
};

/**
 * Element that can be automatically clipped to visible boundaries.
 *
 * Whenever the element's natural height changes, you have to call
 * {@link OO.ui.mixin.ClippableElement#clip} to make sure it's still
 * clipping correctly.
 *
 * The dimensions of #$clippableContainer will be compared to the boundaries of the
 * nearest scrollable container. If #$clippableContainer is too tall and/or too wide,
 * then #$clippable will be given a fixed reduced height and/or width and will be made
 * scrollable. By default, #$clippable and #$clippableContainer are the same element,
 * but you can build a static footer by setting #$clippableContainer to an element that contains
 * #$clippable and the footer.
 *
 * @abstract
 * @class
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {jQuery} [$clippable] Node to clip, assigned to #$clippable, omit to use #$element
 * @cfg {jQuery} [$clippableContainer] Node to keep visible, assigned to #$clippableContainer,
 *   omit to use #$clippable
 */
OO.ui.mixin.ClippableElement = function OoUiMixinClippableElement( config ) {
	// Configuration initialization
	config = config || {};

	// Properties
	this.$clippable = null;
	this.$clippableContainer = null;
	this.clipping = false;
	this.clippedHorizontally = false;
	this.clippedVertically = false;
	this.$clippableScrollableContainer = null;
	this.$clippableScroller = null;
	this.$clippableWindow = null;
	this.idealWidth = null;
	this.idealHeight = null;
	this.onClippableScrollHandler = this.clip.bind( this );
	this.onClippableWindowResizeHandler = this.clip.bind( this );

	// Initialization
	if ( config.$clippableContainer ) {
		this.setClippableContainer( config.$clippableContainer );
	}
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
OO.ui.mixin.ClippableElement.prototype.setClippableElement = function ( $clippable ) {
	if ( this.$clippable ) {
		this.$clippable.removeClass( 'oo-ui-clippableElement-clippable' );
		this.$clippable.css( { width: '', height: '', overflowX: '', overflowY: '' } );
		OO.ui.Element.static.reconsiderScrollbars( this.$clippable[ 0 ] );
	}

	this.$clippable = $clippable.addClass( 'oo-ui-clippableElement-clippable' );
	this.clip();
};

/**
 * Set clippable container.
 *
 * This is the container that will be measured when deciding whether to clip. When clipping,
 * #$clippable will be resized in order to keep the clippable container fully visible.
 *
 * If the clippable container is unset, #$clippable will be used.
 *
 * @param {jQuery|null} $clippableContainer Container to keep visible, or null to unset
 */
OO.ui.mixin.ClippableElement.prototype.setClippableContainer = function ( $clippableContainer ) {
	this.$clippableContainer = $clippableContainer;
	if ( this.$clippable ) {
		this.clip();
	}
};

/**
 * Toggle clipping.
 *
 * Do not turn clipping on until after the element is attached to the DOM and visible.
 *
 * @param {boolean} [clipping] Enable clipping, omit to toggle
 * @chainable
 */
OO.ui.mixin.ClippableElement.prototype.toggleClipping = function ( clipping ) {
	clipping = clipping === undefined ? !this.clipping : !!clipping;

	if ( this.clipping !== clipping ) {
		this.clipping = clipping;
		if ( clipping ) {
			this.$clippableScrollableContainer = $( this.getClosestScrollableElementContainer() );
			// If the clippable container is the root, we have to listen to scroll events and check
			// jQuery.scrollTop on the window because of browser inconsistencies
			this.$clippableScroller = this.$clippableScrollableContainer.is( 'html, body' ) ?
				$( OO.ui.Element.static.getWindow( this.$clippableScrollableContainer ) ) :
				this.$clippableScrollableContainer;
			this.$clippableScroller.on( 'scroll', this.onClippableScrollHandler );
			this.$clippableWindow = $( this.getElementWindow() )
				.on( 'resize', this.onClippableWindowResizeHandler );
			// Initial clip after visible
			this.clip();
		} else {
			this.$clippable.css( { width: '', height: '', overflowX: '', overflowY: '' } );
			OO.ui.Element.static.reconsiderScrollbars( this.$clippable[ 0 ] );

			this.$clippableScrollableContainer = null;
			this.$clippableScroller.off( 'scroll', this.onClippableScrollHandler );
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
OO.ui.mixin.ClippableElement.prototype.isClipping = function () {
	return this.clipping;
};

/**
 * Check if the bottom or right of the element is being clipped by the nearest scrollable container.
 *
 * @return {boolean} Part of the element is being clipped
 */
OO.ui.mixin.ClippableElement.prototype.isClipped = function () {
	return this.clippedHorizontally || this.clippedVertically;
};

/**
 * Check if the right of the element is being clipped by the nearest scrollable container.
 *
 * @return {boolean} Part of the element is being clipped
 */
OO.ui.mixin.ClippableElement.prototype.isClippedHorizontally = function () {
	return this.clippedHorizontally;
};

/**
 * Check if the bottom of the element is being clipped by the nearest scrollable container.
 *
 * @return {boolean} Part of the element is being clipped
 */
OO.ui.mixin.ClippableElement.prototype.isClippedVertically = function () {
	return this.clippedVertically;
};

/**
 * Set the ideal size. These are the dimensions the element will have when it's not being clipped.
 *
 * @param {number|string} [width] Width as a number of pixels or CSS string with unit suffix
 * @param {number|string} [height] Height as a number of pixels or CSS string with unit suffix
 */
OO.ui.mixin.ClippableElement.prototype.setIdealSize = function ( width, height ) {
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
OO.ui.mixin.ClippableElement.prototype.clip = function () {
	var $container, extraHeight, extraWidth, ccOffset,
		$scrollableContainer, scOffset, scHeight, scWidth,
		ccWidth, scrollerIsWindow, scrollTop, scrollLeft,
		desiredWidth, desiredHeight, allotedWidth, allotedHeight,
		naturalWidth, naturalHeight, clipWidth, clipHeight,
		buffer = 7; // Chosen by fair dice roll

	if ( !this.clipping ) {
		// this.$clippableScrollableContainer and this.$clippableWindow are null, so the below will fail
		return this;
	}

	$container = this.$clippableContainer || this.$clippable;
	extraHeight = $container.outerHeight() - this.$clippable.outerHeight();
	extraWidth = $container.outerWidth() - this.$clippable.outerWidth();
	ccOffset = $container.offset();
	$scrollableContainer = this.$clippableScrollableContainer.is( 'html, body' ) ?
		this.$clippableWindow : this.$clippableScrollableContainer;
	scOffset = $scrollableContainer.offset() || { top: 0, left: 0 };
	scHeight = $scrollableContainer.innerHeight() - buffer;
	scWidth = $scrollableContainer.innerWidth() - buffer;
	ccWidth = $container.outerWidth() + buffer;
	scrollerIsWindow = this.$clippableScroller[ 0 ] === this.$clippableWindow[ 0 ];
	scrollTop = scrollerIsWindow ? this.$clippableScroller.scrollTop() : 0;
	scrollLeft = scrollerIsWindow ? this.$clippableScroller.scrollLeft() : 0;
	desiredWidth = ccOffset.left < 0 ?
		ccWidth + ccOffset.left :
		( scOffset.left + scrollLeft + scWidth ) - ccOffset.left;
	desiredHeight = ( scOffset.top + scrollTop + scHeight ) - ccOffset.top;
	allotedWidth = desiredWidth - extraWidth;
	allotedHeight = desiredHeight - extraHeight;
	naturalWidth = this.$clippable.prop( 'scrollWidth' );
	naturalHeight = this.$clippable.prop( 'scrollHeight' );
	clipWidth = allotedWidth < naturalWidth;
	clipHeight = allotedHeight < naturalHeight;

	if ( clipWidth ) {
		this.$clippable.css( { overflowX: 'scroll', width: Math.max( 0, allotedWidth ) } );
	} else {
		this.$clippable.css( { width: this.idealWidth ? this.idealWidth - extraWidth : '', overflowX: '' } );
	}
	if ( clipHeight ) {
		this.$clippable.css( { overflowY: 'scroll', height: Math.max( 0, allotedHeight ) } );
	} else {
		this.$clippable.css( { height: this.idealHeight ? this.idealHeight - extraHeight : '', overflowY: '' } );
	}

	// If we stopped clipping in at least one of the dimensions
	if ( ( this.clippedHorizontally && !clipWidth ) || ( this.clippedVertically && !clipHeight ) ) {
		OO.ui.Element.static.reconsiderScrollbars( this.$clippable[ 0 ] );
	}

	this.clippedHorizontally = clipWidth;
	this.clippedVertically = clipHeight;

	return this;
};

/**
 * AccessKeyedElement is mixed into other classes to provide an `accesskey` attribute.
 * Accesskeys allow an user to go to a specific element by using
 * a shortcut combination of a browser specific keys + the key
 * set to the field.
 *
 *     @example
 *     // AccessKeyedElement provides an 'accesskey' attribute to the
 *     // ButtonWidget class
 *     var button = new OO.ui.ButtonWidget( {
 *         label: 'Button with Accesskey',
 *         accessKey: 'k'
 *     } );
 *     $( 'body' ).append( button.$element );
 *
 * @abstract
 * @class
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {jQuery} [$accessKeyed] The element to which the `accesskey` attribute is applied.
 *  If this config is omitted, the accesskey functionality is applied to $element, the
 *  element created by the class.
 * @cfg {string|Function} [accessKey] The key or a function that returns the key. If
 *  this config is omitted, no accesskey will be added.
 */
OO.ui.mixin.AccessKeyedElement = function OoUiMixinAccessKeyedElement( config ) {
	// Configuration initialization
	config = config || {};

	// Properties
	this.$accessKeyed = null;
	this.accessKey = null;

	// Initialization
	this.setAccessKey( config.accessKey || null );
	this.setAccessKeyedElement( config.$accessKeyed || this.$element );
};

/* Setup */

OO.initClass( OO.ui.mixin.AccessKeyedElement );

/* Static Properties */

/**
 * The access key, a function that returns a key, or `null` for no accesskey.
 *
 * @static
 * @inheritable
 * @property {string|Function|null}
 */
OO.ui.mixin.AccessKeyedElement.static.accessKey = null;

/* Methods */

/**
 * Set the accesskeyed element.
 *
 * This method is used to retarget a AccessKeyedElement mixin so that its functionality applies to the specified element.
 * If an element is already set, the mixin's effect on that element is removed before the new element is set up.
 *
 * @param {jQuery} $accessKeyed Element that should use the 'accesskeyes' functionality
 */
OO.ui.mixin.AccessKeyedElement.prototype.setAccessKeyedElement = function ( $accessKeyed ) {
	if ( this.$accessKeyed ) {
		this.$accessKeyed.removeAttr( 'accesskey' );
	}

	this.$accessKeyed = $accessKeyed;
	if ( this.accessKey ) {
		this.$accessKeyed.attr( 'accesskey', this.accessKey );
	}
};

/**
 * Set accesskey.
 *
 * @param {string|Function|null} accesskey Key, a function that returns a key, or `null` for no accesskey
 * @chainable
 */
OO.ui.mixin.AccessKeyedElement.prototype.setAccessKey = function ( accessKey ) {
	accessKey = typeof accessKey === 'string' ? OO.ui.resolveMsg( accessKey ) : null;

	if ( this.accessKey !== accessKey ) {
		if ( this.$accessKeyed ) {
			if ( accessKey !== null ) {
				this.$accessKeyed.attr( 'accesskey', accessKey );
			} else {
				this.$accessKeyed.removeAttr( 'accesskey' );
			}
		}
		this.accessKey = accessKey;
	}

	return this;
};

/**
 * Get accesskey.
 *
 * @return {string} accessKey string
 */
OO.ui.mixin.AccessKeyedElement.prototype.getAccessKey = function () {
	return this.accessKey;
};

/**
 * Tools, together with {@link OO.ui.ToolGroup toolgroups}, constitute {@link OO.ui.Toolbar toolbars}.
 * Each tool is configured with a static name, title, and icon and is customized with the command to carry
 * out when the tool is selected. Tools must also be registered with a {@link OO.ui.ToolFactory tool factory},
 * which creates the tools on demand.
 *
 * Tools are added to toolgroups ({@link OO.ui.ListToolGroup ListToolGroup},
 * {@link OO.ui.BarToolGroup BarToolGroup}, or {@link OO.ui.MenuToolGroup MenuToolGroup}), which determine how
 * the tool is displayed in the toolbar. See {@link OO.ui.Toolbar toolbars} for an example.
 *
 * For more information, please see the [OOjs UI documentation on MediaWiki][1].
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Toolbars
 *
 * @abstract
 * @class
 * @extends OO.ui.Widget
 * @mixins OO.ui.mixin.IconElement
 * @mixins OO.ui.mixin.FlaggedElement
 * @mixins OO.ui.mixin.TabIndexedElement
 *
 * @constructor
 * @param {OO.ui.ToolGroup} toolGroup
 * @param {Object} [config] Configuration options
 * @cfg {string|Function} [title] Title text or a function that returns text. If this config is omitted, the value of
 *  the {@link #static-title static title} property is used.
 *
 *  The title is used in different ways depending on the type of toolgroup that contains the tool. The
 *  title is used as a tooltip if the tool is part of a {@link OO.ui.BarToolGroup bar} toolgroup, or as the label text if the tool is
 *  part of a {@link OO.ui.ListToolGroup list} or {@link OO.ui.MenuToolGroup menu} toolgroup.
 *
 *  For bar toolgroups, a description of the accelerator key is appended to the title if an accelerator key
 *  is associated with an action by the same name as the tool and accelerator functionality has been added to the application.
 *  To add accelerator key functionality, you must subclass OO.ui.Toolbar and override the {@link OO.ui.Toolbar#getToolAccelerator getToolAccelerator} method.
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
	OO.ui.Tool.parent.call( this, config );

	// Properties
	this.toolGroup = toolGroup;
	this.toolbar = this.toolGroup.getToolbar();
	this.active = false;
	this.$title = $( '<span>' );
	this.$accel = $( '<span>' );
	this.$link = $( '<a>' );
	this.title = null;

	// Mixin constructors
	OO.ui.mixin.IconElement.call( this, config );
	OO.ui.mixin.FlaggedElement.call( this, config );
	OO.ui.mixin.TabIndexedElement.call( this, $.extend( {}, config, { $tabIndexed: this.$link } ) );

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
		.attr( 'role', 'button' );
	this.$element
		.data( 'oo-ui-tool', this )
		.addClass(
			'oo-ui-tool ' + 'oo-ui-tool-name-' +
			this.constructor.static.name.replace( /^([^\/]+)\/([^\/]+).*$/, '$1-$2' )
		)
		.toggleClass( 'oo-ui-tool-with-label', this.constructor.static.displayBothIconAndLabel )
		.append( this.$link );
	this.setTitle( config.title || this.constructor.static.title );
};

/* Setup */

OO.inheritClass( OO.ui.Tool, OO.ui.Widget );
OO.mixinClass( OO.ui.Tool, OO.ui.mixin.IconElement );
OO.mixinClass( OO.ui.Tool, OO.ui.mixin.FlaggedElement );
OO.mixinClass( OO.ui.Tool, OO.ui.mixin.TabIndexedElement );

/* Static Properties */

/**
 * @static
 * @inheritdoc
 */
OO.ui.Tool.static.tagName = 'span';

/**
 * Symbolic name of tool.
 *
 * The symbolic name is used internally to register the tool with a {@link OO.ui.ToolFactory ToolFactory}. It can
 * also be used when adding tools to toolgroups.
 *
 * @abstract
 * @static
 * @inheritable
 * @property {string}
 */
OO.ui.Tool.static.name = '';

/**
 * Symbolic name of the group.
 *
 * The group name is used to associate tools with each other so that they can be selected later by
 * a {@link OO.ui.ToolGroup toolgroup}.
 *
 * @abstract
 * @static
 * @inheritable
 * @property {string}
 */
OO.ui.Tool.static.group = '';

/**
 * Tool title text or a function that returns title text. The value of the static property is overridden if the #title config option is used.
 *
 * @abstract
 * @static
 * @inheritable
 * @property {string|Function}
 */
OO.ui.Tool.static.title = '';

/**
 * Display both icon and label when the tool is used in a {@link OO.ui.BarToolGroup bar} toolgroup.
 * Normally only the icon is displayed, or only the label if no icon is given.
 *
 * @static
 * @inheritable
 * @property {boolean}
 */
OO.ui.Tool.static.displayBothIconAndLabel = false;

/**
 * Add tool to catch-all groups automatically.
 *
 * A catch-all group, which contains all tools that do not currently belong to a toolgroup,
 * can be included in a toolgroup using the wildcard selector, an asterisk (*).
 *
 * @static
 * @inheritable
 * @property {boolean}
 */
OO.ui.Tool.static.autoAddToCatchall = true;

/**
 * Add tool to named groups automatically.
 *
 * By default, tools that are configured with a static ‘group’ property are added
 * to that group and will be selected when the symbolic name of the group is specified (e.g., when
 * toolgroups include tools by group name).
 *
 * @static
 * @property {boolean}
 * @inheritable
 */
OO.ui.Tool.static.autoAddToGroup = true;

/**
 * Check if this tool is compatible with given data.
 *
 * This is a stub that can be overriden to provide support for filtering tools based on an
 * arbitrary piece of information  (e.g., where the cursor is in a document). The implementation
 * must also call this method so that the compatibility check can be performed.
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
 * @protected
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
 * @protected
 * @abstract
 */
OO.ui.Tool.prototype.onSelect = function () {
	throw new Error(
		'OO.ui.Tool.onSelect not implemented in this subclass:' + this.constructor
	);
};

/**
 * Check if the tool is active.
 *
 * Tools become active when their #onSelect or #onUpdateState handlers change them to appear pressed
 * with the #setActive method. Additional CSS is applied to the tool to reflect the active state.
 *
 * @return {boolean} Tool is active
 */
OO.ui.Tool.prototype.isActive = function () {
	return this.active;
};

/**
 * Make the tool appear active or inactive.
 *
 * This method should be called within #onSelect or #onUpdateState event handlers to make the tool
 * appear pressed or not.
 *
 * @param {boolean} state Make tool appear active
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
 * Set the tool #title.
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
 * Get the tool #title.
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
 *
 * Destroying the tool removes all event handlers and the tool’s DOM elements.
 * Call this method whenever you are done using a tool.
 */
OO.ui.Tool.prototype.destroy = function () {
	this.toolbar.disconnect( this );
	this.$element.remove();
};

/**
 * Toolbars are complex interface components that permit users to easily access a variety
 * of {@link OO.ui.Tool tools} (e.g., formatting commands) and actions, which are additional commands that are
 * part of the toolbar, but not configured as tools.
 *
 * Individual tools are customized and then registered with a {@link OO.ui.ToolFactory tool factory}, which creates
 * the tools on demand. Each tool has a symbolic name (used when registering the tool), a title (e.g., ‘Insert
 * picture’), and an icon.
 *
 * Individual tools are organized in {@link OO.ui.ToolGroup toolgroups}, which can be {@link OO.ui.MenuToolGroup menus}
 * of tools, {@link OO.ui.ListToolGroup lists} of tools, or a single {@link OO.ui.BarToolGroup bar} of tools.
 * The arrangement and order of the toolgroups is customized when the toolbar is set up. Tools can be presented in
 * any order, but each can only appear once in the toolbar.
 *
 * The following is an example of a basic toolbar.
 *
 *     @example
 *     // Example of a toolbar
 *     // Create the toolbar
 *     var toolFactory = new OO.ui.ToolFactory();
 *     var toolGroupFactory = new OO.ui.ToolGroupFactory();
 *     var toolbar = new OO.ui.Toolbar( toolFactory, toolGroupFactory );
 *
 *     // We will be placing status text in this element when tools are used
 *     var $area = $( '<p>' ).text( 'Toolbar example' );
 *
 *     // Define the tools that we're going to place in our toolbar
 *
 *     // Create a class inheriting from OO.ui.Tool
 *     function PictureTool() {
 *         PictureTool.parent.apply( this, arguments );
 *     }
 *     OO.inheritClass( PictureTool, OO.ui.Tool );
 *     // Each tool must have a 'name' (used as an internal identifier, see later) and at least one
 *     // of 'icon' and 'title' (displayed icon and text).
 *     PictureTool.static.name = 'picture';
 *     PictureTool.static.icon = 'picture';
 *     PictureTool.static.title = 'Insert picture';
 *     // Defines the action that will happen when this tool is selected (clicked).
 *     PictureTool.prototype.onSelect = function () {
 *         $area.text( 'Picture tool clicked!' );
 *         // Never display this tool as "active" (selected).
 *         this.setActive( false );
 *     };
 *     // Make this tool available in our toolFactory and thus our toolbar
 *     toolFactory.register( PictureTool );
 *
 *     // Register two more tools, nothing interesting here
 *     function SettingsTool() {
 *         SettingsTool.parent.apply( this, arguments );
 *     }
 *     OO.inheritClass( SettingsTool, OO.ui.Tool );
 *     SettingsTool.static.name = 'settings';
 *     SettingsTool.static.icon = 'settings';
 *     SettingsTool.static.title = 'Change settings';
 *     SettingsTool.prototype.onSelect = function () {
 *         $area.text( 'Settings tool clicked!' );
 *         this.setActive( false );
 *     };
 *     toolFactory.register( SettingsTool );
 *
 *     // Register two more tools, nothing interesting here
 *     function StuffTool() {
 *         StuffTool.parent.apply( this, arguments );
 *     }
 *     OO.inheritClass( StuffTool, OO.ui.Tool );
 *     StuffTool.static.name = 'stuff';
 *     StuffTool.static.icon = 'ellipsis';
 *     StuffTool.static.title = 'More stuff';
 *     StuffTool.prototype.onSelect = function () {
 *         $area.text( 'More stuff tool clicked!' );
 *         this.setActive( false );
 *     };
 *     toolFactory.register( StuffTool );
 *
 *     // This is a PopupTool. Rather than having a custom 'onSelect' action, it will display a
 *     // little popup window (a PopupWidget).
 *     function HelpTool( toolGroup, config ) {
 *         OO.ui.PopupTool.call( this, toolGroup, $.extend( { popup: {
 *             padded: true,
 *             label: 'Help',
 *             head: true
 *         } }, config ) );
 *         this.popup.$body.append( '<p>I am helpful!</p>' );
 *     }
 *     OO.inheritClass( HelpTool, OO.ui.PopupTool );
 *     HelpTool.static.name = 'help';
 *     HelpTool.static.icon = 'help';
 *     HelpTool.static.title = 'Help';
 *     toolFactory.register( HelpTool );
 *
 *     // Finally define which tools and in what order appear in the toolbar. Each tool may only be
 *     // used once (but not all defined tools must be used).
 *     toolbar.setup( [
 *         {
 *             // 'bar' tool groups display tools' icons only, side-by-side.
 *             type: 'bar',
 *             include: [ 'picture', 'help' ]
 *         },
 *         {
 *             // 'list' tool groups display both the titles and icons, in a dropdown list.
 *             type: 'list',
 *             indicator: 'down',
 *             label: 'More',
 *             include: [ 'settings', 'stuff' ]
 *         }
 *         // Note how the tools themselves are toolgroup-agnostic - the same tool can be displayed
 *         // either in a 'list' or a 'bar'. There is a 'menu' tool group too, not showcased here,
 *         // since it's more complicated to use. (See the next example snippet on this page.)
 *     ] );
 *
 *     // Create some UI around the toolbar and place it in the document
 *     var frame = new OO.ui.PanelLayout( {
 *         expanded: false,
 *         framed: true
 *     } );
 *     var contentFrame = new OO.ui.PanelLayout( {
 *         expanded: false,
 *         padded: true
 *     } );
 *     frame.$element.append(
 *         toolbar.$element,
 *         contentFrame.$element.append( $area )
 *     );
 *     $( 'body' ).append( frame.$element );
 *
 *     // Here is where the toolbar is actually built. This must be done after inserting it into the
 *     // document.
 *     toolbar.initialize();
 *
 * The following example extends the previous one to illustrate 'menu' toolgroups and the usage of
 * 'updateState' event.
 *
 *     @example
 *     // Create the toolbar
 *     var toolFactory = new OO.ui.ToolFactory();
 *     var toolGroupFactory = new OO.ui.ToolGroupFactory();
 *     var toolbar = new OO.ui.Toolbar( toolFactory, toolGroupFactory );
 *
 *     // We will be placing status text in this element when tools are used
 *     var $area = $( '<p>' ).text( 'Toolbar example' );
 *
 *     // Define the tools that we're going to place in our toolbar
 *
 *     // Create a class inheriting from OO.ui.Tool
 *     function PictureTool() {
 *         PictureTool.parent.apply( this, arguments );
 *     }
 *     OO.inheritClass( PictureTool, OO.ui.Tool );
 *     // Each tool must have a 'name' (used as an internal identifier, see later) and at least one
 *     // of 'icon' and 'title' (displayed icon and text).
 *     PictureTool.static.name = 'picture';
 *     PictureTool.static.icon = 'picture';
 *     PictureTool.static.title = 'Insert picture';
 *     // Defines the action that will happen when this tool is selected (clicked).
 *     PictureTool.prototype.onSelect = function () {
 *         $area.text( 'Picture tool clicked!' );
 *         // Never display this tool as "active" (selected).
 *         this.setActive( false );
 *     };
 *     // The toolbar can be synchronized with the state of some external stuff, like a text
 *     // editor's editing area, highlighting the tools (e.g. a 'bold' tool would be shown as active
 *     // when the text cursor was inside bolded text). Here we simply disable this feature.
 *     PictureTool.prototype.onUpdateState = function () {
 *     };
 *     // Make this tool available in our toolFactory and thus our toolbar
 *     toolFactory.register( PictureTool );
 *
 *     // Register two more tools, nothing interesting here
 *     function SettingsTool() {
 *         SettingsTool.parent.apply( this, arguments );
 *         this.reallyActive = false;
 *     }
 *     OO.inheritClass( SettingsTool, OO.ui.Tool );
 *     SettingsTool.static.name = 'settings';
 *     SettingsTool.static.icon = 'settings';
 *     SettingsTool.static.title = 'Change settings';
 *     SettingsTool.prototype.onSelect = function () {
 *         $area.text( 'Settings tool clicked!' );
 *         // Toggle the active state on each click
 *         this.reallyActive = !this.reallyActive;
 *         this.setActive( this.reallyActive );
 *         // To update the menu label
 *         this.toolbar.emit( 'updateState' );
 *     };
 *     SettingsTool.prototype.onUpdateState = function () {
 *     };
 *     toolFactory.register( SettingsTool );
 *
 *     // Register two more tools, nothing interesting here
 *     function StuffTool() {
 *         StuffTool.parent.apply( this, arguments );
 *         this.reallyActive = false;
 *     }
 *     OO.inheritClass( StuffTool, OO.ui.Tool );
 *     StuffTool.static.name = 'stuff';
 *     StuffTool.static.icon = 'ellipsis';
 *     StuffTool.static.title = 'More stuff';
 *     StuffTool.prototype.onSelect = function () {
 *         $area.text( 'More stuff tool clicked!' );
 *         // Toggle the active state on each click
 *         this.reallyActive = !this.reallyActive;
 *         this.setActive( this.reallyActive );
 *         // To update the menu label
 *         this.toolbar.emit( 'updateState' );
 *     };
 *     StuffTool.prototype.onUpdateState = function () {
 *     };
 *     toolFactory.register( StuffTool );
 *
 *     // This is a PopupTool. Rather than having a custom 'onSelect' action, it will display a
 *     // little popup window (a PopupWidget). 'onUpdateState' is also already implemented.
 *     function HelpTool( toolGroup, config ) {
 *         OO.ui.PopupTool.call( this, toolGroup, $.extend( { popup: {
 *             padded: true,
 *             label: 'Help',
 *             head: true
 *         } }, config ) );
 *         this.popup.$body.append( '<p>I am helpful!</p>' );
 *     }
 *     OO.inheritClass( HelpTool, OO.ui.PopupTool );
 *     HelpTool.static.name = 'help';
 *     HelpTool.static.icon = 'help';
 *     HelpTool.static.title = 'Help';
 *     toolFactory.register( HelpTool );
 *
 *     // Finally define which tools and in what order appear in the toolbar. Each tool may only be
 *     // used once (but not all defined tools must be used).
 *     toolbar.setup( [
 *         {
 *             // 'bar' tool groups display tools' icons only, side-by-side.
 *             type: 'bar',
 *             include: [ 'picture', 'help' ]
 *         },
 *         {
 *             // 'menu' tool groups display both the titles and icons, in a dropdown menu.
 *             // Menu label indicates which items are selected.
 *             type: 'menu',
 *             indicator: 'down',
 *             include: [ 'settings', 'stuff' ]
 *         }
 *     ] );
 *
 *     // Create some UI around the toolbar and place it in the document
 *     var frame = new OO.ui.PanelLayout( {
 *         expanded: false,
 *         framed: true
 *     } );
 *     var contentFrame = new OO.ui.PanelLayout( {
 *         expanded: false,
 *         padded: true
 *     } );
 *     frame.$element.append(
 *         toolbar.$element,
 *         contentFrame.$element.append( $area )
 *     );
 *     $( 'body' ).append( frame.$element );
 *
 *     // Here is where the toolbar is actually built. This must be done after inserting it into the
 *     // document.
 *     toolbar.initialize();
 *     toolbar.emit( 'updateState' );
 *
 * @class
 * @extends OO.ui.Element
 * @mixins OO.EventEmitter
 * @mixins OO.ui.mixin.GroupElement
 *
 * @constructor
 * @param {OO.ui.ToolFactory} toolFactory Factory for creating tools
 * @param {OO.ui.ToolGroupFactory} toolGroupFactory Factory for creating toolgroups
 * @param {Object} [config] Configuration options
 * @cfg {boolean} [actions] Add an actions section to the toolbar. Actions are commands that are included
 *  in the toolbar, but are not configured as tools. By default, actions are displayed on the right side of
 *  the toolbar.
 * @cfg {boolean} [shadow] Add a shadow below the toolbar.
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
	OO.ui.Toolbar.parent.call( this, config );

	// Mixin constructors
	OO.EventEmitter.call( this );
	OO.ui.mixin.GroupElement.call( this, config );

	// Properties
	this.toolFactory = toolFactory;
	this.toolGroupFactory = toolGroupFactory;
	this.groups = [];
	this.tools = {};
	this.$bar = $( '<div>' );
	this.$actions = $( '<div>' );
	this.initialized = false;
	this.onWindowResizeHandler = this.onWindowResize.bind( this );

	// Events
	this.$element
		.add( this.$bar ).add( this.$group ).add( this.$actions )
		.on( 'mousedown keydown', this.onPointerDown.bind( this ) );

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
OO.mixinClass( OO.ui.Toolbar, OO.ui.mixin.GroupElement );

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
 * Get the toolgroup factory.
 *
 * @return {OO.Factory} Toolgroup factory
 */
OO.ui.Toolbar.prototype.getToolGroupFactory = function () {
	return this.toolGroupFactory;
};

/**
 * Handles mouse down events.
 *
 * @private
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
 * Handle window resize event.
 *
 * @private
 * @param {jQuery.Event} e Window resize event
 */
OO.ui.Toolbar.prototype.onWindowResize = function () {
	this.$element.toggleClass(
		'oo-ui-toolbar-narrow',
		this.$bar.width() <= this.narrowThreshold
	);
};

/**
 * Sets up handles and preloads required information for the toolbar to work.
 * This must be called after it is attached to a visible document and before doing anything else.
 */
OO.ui.Toolbar.prototype.initialize = function () {
	this.initialized = true;
	this.narrowThreshold = this.$group.width() + this.$actions.width();
	$( this.getElementWindow() ).on( 'resize', this.onWindowResizeHandler );
	this.onWindowResize();
};

/**
 * Set up the toolbar.
 *
 * The toolbar is set up with a list of toolgroup configurations that specify the type of
 * toolgroup ({@link OO.ui.BarToolGroup bar}, {@link OO.ui.MenuToolGroup menu}, or {@link OO.ui.ListToolGroup list})
 * to add and which tools to include, exclude, promote, or demote within that toolgroup. Please
 * see {@link OO.ui.ToolGroup toolgroups} for more information about including tools in toolgroups.
 *
 * @param {Object.<string,Array>} groups List of toolgroup configurations
 * @param {Array|string} [groups.include] Tools to include in the toolgroup
 * @param {Array|string} [groups.exclude] Tools to exclude from the toolgroup
 * @param {Array|string} [groups.promote] Tools to promote to the beginning of the toolgroup
 * @param {Array|string} [groups.demote] Tools to demote to the end of the toolgroup
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
 * Remove all tools and toolgroups from the toolbar.
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
 * Destroy the toolbar.
 *
 * Destroying the toolbar removes all event handlers and DOM elements that constitute the toolbar. Call
 * this method whenever you are done using a toolbar.
 */
OO.ui.Toolbar.prototype.destroy = function () {
	$( this.getElementWindow() ).off( 'resize', this.onWindowResizeHandler );
	this.reset();
	this.$element.remove();
};

/**
 * Check if the tool is available.
 *
 * Available tools are ones that have not yet been added to the toolbar.
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
 * The OOjs UI library does not contain an accelerator system, but this is the hook for one. To
 * use an accelerator system, subclass the toolbar and override this method, which is meant to return a label
 * that describes the accelerator keys for the tool passed (by symbolic name) to the method.
 *
 * @param {string} name Symbolic name of tool
 * @return {string|undefined} Tool accelerator label if available
 */
OO.ui.Toolbar.prototype.getToolAccelerator = function () {
	return undefined;
};

/**
 * ToolGroups are collections of {@link OO.ui.Tool tools} that are used in a {@link OO.ui.Toolbar toolbar}.
 * The type of toolgroup ({@link OO.ui.ListToolGroup list}, {@link OO.ui.BarToolGroup bar}, or {@link OO.ui.MenuToolGroup menu})
 * to which a tool belongs determines how the tool is arranged and displayed in the toolbar. Toolgroups
 * themselves are created on demand with a {@link OO.ui.ToolGroupFactory toolgroup factory}.
 *
 * Toolgroups can contain individual tools, groups of tools, or all available tools:
 *
 * To include an individual tool (or array of individual tools), specify tools by symbolic name:
 *
 *      include: [ 'tool-name' ] or [ { name: 'tool-name' }]
 *
 * To include a group of tools, specify the group name. (The tool's static ‘group’ config is used to assign the tool to a group.)
 *
 *      include: [ { group: 'group-name' } ]
 *
 *  To include all tools that are not yet assigned to a toolgroup, use the catch-all selector, an asterisk (*):
 *
 *      include: '*'
 *
 * See {@link OO.ui.Toolbar toolbars} for a full example. For more information about toolbars in general,
 * please see the [OOjs UI documentation on MediaWiki][1].
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Toolbars
 *
 * @abstract
 * @class
 * @extends OO.ui.Widget
 * @mixins OO.ui.mixin.GroupElement
 *
 * @constructor
 * @param {OO.ui.Toolbar} toolbar
 * @param {Object} [config] Configuration options
 * @cfg {Array|string} [include=[]] List of tools to include in the toolgroup.
 * @cfg {Array|string} [exclude=[]] List of tools to exclude from the toolgroup.
 * @cfg {Array|string} [promote=[]] List of tools to promote to the beginning of the toolgroup.
 * @cfg {Array|string} [demote=[]] List of tools to demote to the end of the toolgroup.
 *  This setting is particularly useful when tools have been added to the toolgroup
 *  en masse (e.g., via the catch-all selector).
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
	OO.ui.ToolGroup.parent.call( this, config );

	// Mixin constructors
	OO.ui.mixin.GroupElement.call( this, config );

	// Properties
	this.toolbar = toolbar;
	this.tools = {};
	this.pressed = null;
	this.autoDisabled = false;
	this.include = config.include || [];
	this.exclude = config.exclude || [];
	this.promote = config.promote || [];
	this.demote = config.demote || [];
	this.onCapturedMouseKeyUpHandler = this.onCapturedMouseKeyUp.bind( this );

	// Events
	this.$element.on( {
		mousedown: this.onMouseKeyDown.bind( this ),
		mouseup: this.onMouseKeyUp.bind( this ),
		keydown: this.onMouseKeyDown.bind( this ),
		keyup: this.onMouseKeyUp.bind( this ),
		focus: this.onMouseOverFocus.bind( this ),
		blur: this.onMouseOutBlur.bind( this ),
		mouseover: this.onMouseOverFocus.bind( this ),
		mouseout: this.onMouseOutBlur.bind( this )
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
OO.mixinClass( OO.ui.ToolGroup, OO.ui.mixin.GroupElement );

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
 * Note: The OOjs UI library does not include an accelerator system, but does contain
 * a hook for one. To use an accelerator system, subclass the {@link OO.ui.Toolbar toolbar} and
 * override the {@link OO.ui.Toolbar#getToolAccelerator getToolAccelerator} method, which is
 * meant to return a label that describes the accelerator keys for a given tool (e.g., 'Ctrl + M').
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
	return this.autoDisabled || OO.ui.ToolGroup.parent.prototype.isDisabled.apply( this, arguments );
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
	OO.ui.ToolGroup.parent.prototype.updateDisabled.apply( this, arguments );
};

/**
 * Handle mouse down and key down events.
 *
 * @protected
 * @param {jQuery.Event} e Mouse down or key down event
 */
OO.ui.ToolGroup.prototype.onMouseKeyDown = function ( e ) {
	if (
		!this.isDisabled() &&
		( e.which === 1 || e.which === OO.ui.Keys.SPACE || e.which === OO.ui.Keys.ENTER )
	) {
		this.pressed = this.getTargetTool( e );
		if ( this.pressed ) {
			this.pressed.setActive( true );
			OO.ui.addCaptureEventListener( this.getElementDocument(), 'mouseup', this.onCapturedMouseKeyUpHandler );
			OO.ui.addCaptureEventListener( this.getElementDocument(), 'keyup', this.onCapturedMouseKeyUpHandler );
		}
		return false;
	}
};

/**
 * Handle captured mouse up and key up events.
 *
 * @protected
 * @param {Event} e Mouse up or key up event
 */
OO.ui.ToolGroup.prototype.onCapturedMouseKeyUp = function ( e ) {
	OO.ui.removeCaptureEventListener( this.getElementDocument(), 'mouseup', this.onCapturedMouseKeyUpHandler );
	OO.ui.removeCaptureEventListener( this.getElementDocument(), 'keyup', this.onCapturedMouseKeyUpHandler );
	// onMouseKeyUp may be called a second time, depending on where the mouse is when the button is
	// released, but since `this.pressed` will no longer be true, the second call will be ignored.
	this.onMouseKeyUp( e );
};

/**
 * Handle mouse up and key up events.
 *
 * @protected
 * @param {jQuery.Event} e Mouse up or key up event
 */
OO.ui.ToolGroup.prototype.onMouseKeyUp = function ( e ) {
	var tool = this.getTargetTool( e );

	if (
		!this.isDisabled() && this.pressed && this.pressed === tool &&
		( e.which === 1 || e.which === OO.ui.Keys.SPACE || e.which === OO.ui.Keys.ENTER )
	) {
		this.pressed.onSelect();
		this.pressed = null;
		return false;
	}

	this.pressed = null;
};

/**
 * Handle mouse over and focus events.
 *
 * @protected
 * @param {jQuery.Event} e Mouse over or focus event
 */
OO.ui.ToolGroup.prototype.onMouseOverFocus = function ( e ) {
	var tool = this.getTargetTool( e );

	if ( this.pressed && this.pressed === tool ) {
		this.pressed.setActive( true );
	}
};

/**
 * Handle mouse out and blur events.
 *
 * @protected
 * @param {jQuery.Event} e Mouse out or blur event
 */
OO.ui.ToolGroup.prototype.onMouseOutBlur = function ( e ) {
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
 * @protected
 * @param {string} name Symbolic name of tool
 */
OO.ui.ToolGroup.prototype.onToolFactoryRegister = function () {
	this.populate();
};

/**
 * Get the toolbar that contains the toolgroup.
 *
 * @return {OO.ui.Toolbar} Toolbar that contains the toolgroup
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
 * Destroy toolgroup.
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
 * MessageDialogs display a confirmation or alert message. By default, the rendered dialog box
 * consists of a header that contains the dialog title, a body with the message, and a footer that
 * contains any {@link OO.ui.ActionWidget action widgets}. The MessageDialog class is the only type
 * of {@link OO.ui.Dialog dialog} that is usually instantiated directly.
 *
 * There are two basic types of message dialogs, confirmation and alert:
 *
 * - **confirmation**: the dialog title describes what a progressive action will do and the message provides
 *  more details about the consequences.
 * - **alert**: the dialog title describes which event occurred and the message provides more information
 *  about why the event occurred.
 *
 * The MessageDialog class specifies two actions: ‘accept’, the primary
 * action (e.g., ‘ok’) and ‘reject,’ the safe action (e.g., ‘cancel’). Both will close the window,
 * passing along the selected action.
 *
 * For more information and examples, please see the [OOjs UI documentation on MediaWiki][1].
 *
 *     @example
 *     // Example: Creating and opening a message dialog window.
 *     var messageDialog = new OO.ui.MessageDialog();
 *
 *     // Create and append a window manager.
 *     var windowManager = new OO.ui.WindowManager();
 *     $( 'body' ).append( windowManager.$element );
 *     windowManager.addWindows( [ messageDialog ] );
 *     // Open the window.
 *     windowManager.openWindow( messageDialog, {
 *         title: 'Basic message dialog',
 *         message: 'This is the message'
 *     } );
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Windows/Message_Dialogs
 *
 * @class
 * @extends OO.ui.Dialog
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
OO.ui.MessageDialog = function OoUiMessageDialog( config ) {
	// Parent constructor
	OO.ui.MessageDialog.parent.call( this, config );

	// Properties
	this.verticalActionLayout = null;

	// Initialization
	this.$element.addClass( 'oo-ui-messageDialog' );
};

/* Setup */

OO.inheritClass( OO.ui.MessageDialog, OO.ui.Dialog );

/* Static Properties */

OO.ui.MessageDialog.static.name = 'message';

OO.ui.MessageDialog.static.size = 'small';

OO.ui.MessageDialog.static.verbose = false;

/**
 * Dialog title.
 *
 * The title of a confirmation dialog describes what a progressive action will do. The
 * title of an alert dialog describes which event occurred.
 *
 * @static
 * @inheritable
 * @property {jQuery|string|Function|null}
 */
OO.ui.MessageDialog.static.title = null;

/**
 * The message displayed in the dialog body.
 *
 * A confirmation message describes the consequences of a progressive action. An alert
 * message describes why an event occurred.
 *
 * @static
 * @inheritable
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
	OO.ui.MessageDialog.parent.prototype.setManager.call( this, manager );

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
	return OO.ui.MessageDialog.parent.prototype.onActionResize.call( this, action );
};

/**
 * Handle window resized events.
 *
 * @private
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
 *
 * @private
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
	return OO.ui.MessageDialog.parent.prototype.getActionProcess.call( this, action );
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
	return OO.ui.MessageDialog.parent.prototype.getSetupProcess.call( this, data )
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
OO.ui.MessageDialog.prototype.getReadyProcess = function ( data ) {
	data = data || {};

	// Parent method
	return OO.ui.MessageDialog.parent.prototype.getReadyProcess.call( this, data )
		.next( function () {
			// Focus the primary action button
			var actions = this.actions.get();
			actions = actions.filter( function ( action ) {
				return action.getFlags().indexOf( 'primary' ) > -1;
			} );
			if ( actions.length > 0 ) {
				actions[ 0 ].$button.focus();
			}
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
	OO.ui.MessageDialog.parent.prototype.setDimensions.call( this, dim );

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
	OO.ui.MessageDialog.parent.prototype.initialize.call( this );

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
	OO.ui.MessageDialog.parent.prototype.attachActions.call( this );

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
 *
 * @private
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
 * ProcessDialog windows encapsulate a {@link OO.ui.Process process} and all of the code necessary
 * to complete it. If the process terminates with an error, a customizable {@link OO.ui.Error error
 * interface} alerts users to the trouble, permitting the user to dismiss the error and try again when
 * relevant. The ProcessDialog class is always extended and customized with the actions and content
 * required for each process.
 *
 * The process dialog box consists of a header that visually represents the ‘working’ state of long
 * processes with an animation. The header contains the dialog title as well as
 * two {@link OO.ui.ActionWidget action widgets}:  a ‘safe’ action on the left (e.g., ‘Cancel’) and
 * a ‘primary’ action on the right (e.g., ‘Done’).
 *
 * Like other windows, the process dialog is managed by a {@link OO.ui.WindowManager window manager}.
 * Please see the [OOjs UI documentation on MediaWiki][1] for more information and examples.
 *
 *     @example
 *     // Example: Creating and opening a process dialog window.
 *     function MyProcessDialog( config ) {
 *         MyProcessDialog.parent.call( this, config );
 *     }
 *     OO.inheritClass( MyProcessDialog, OO.ui.ProcessDialog );
 *
 *     MyProcessDialog.static.title = 'Process dialog';
 *     MyProcessDialog.static.actions = [
 *         { action: 'save', label: 'Done', flags: 'primary' },
 *         { label: 'Cancel', flags: 'safe' }
 *     ];
 *
 *     MyProcessDialog.prototype.initialize = function () {
 *         MyProcessDialog.parent.prototype.initialize.apply( this, arguments );
 *         this.content = new OO.ui.PanelLayout( { padded: true, expanded: false } );
 *         this.content.$element.append( '<p>This is a process dialog window. The header contains the title and two buttons: \'Cancel\' (a safe action) on the left and \'Done\' (a primary action)  on the right.</p>' );
 *         this.$body.append( this.content.$element );
 *     };
 *     MyProcessDialog.prototype.getActionProcess = function ( action ) {
 *         var dialog = this;
 *         if ( action ) {
 *             return new OO.ui.Process( function () {
 *                 dialog.close( { action: action } );
 *             } );
 *         }
 *         return MyProcessDialog.parent.prototype.getActionProcess.call( this, action );
 *     };
 *
 *     var windowManager = new OO.ui.WindowManager();
 *     $( 'body' ).append( windowManager.$element );
 *
 *     var dialog = new MyProcessDialog();
 *     windowManager.addWindows( [ dialog ] );
 *     windowManager.openWindow( dialog );
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Windows/Process_Dialogs
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
	OO.ui.ProcessDialog.parent.call( this, config );

	// Properties
	this.fitOnOpen = false;

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
 *
 * @private
 */
OO.ui.ProcessDialog.prototype.onDismissErrorButtonClick = function () {
	this.hideErrors();
};

/**
 * Handle retry button click events.
 *
 * Hides errors and then tries again.
 *
 * @private
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
	return OO.ui.ProcessDialog.parent.prototype.onActionResize.call( this, action );
};

/**
 * @inheritdoc
 */
OO.ui.ProcessDialog.prototype.initialize = function () {
	// Parent method
	OO.ui.ProcessDialog.parent.prototype.initialize.call( this );

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
OO.ui.ProcessDialog.prototype.getActionWidgets = function ( actions ) {
	var i, len, widgets = [];
	for ( i = 0, len = actions.length; i < len; i++ ) {
		widgets.push(
			new OO.ui.ActionWidget( $.extend( { framed: true }, actions[ i ] ) )
		);
	}
	return widgets;
};

/**
 * @inheritdoc
 */
OO.ui.ProcessDialog.prototype.attachActions = function () {
	var i, len, other, special, others;

	// Parent method
	OO.ui.ProcessDialog.parent.prototype.attachActions.call( this );

	special = this.actions.getSpecial();
	others = this.actions.getOthers();
	if ( special.primary ) {
		this.$primaryActions.append( special.primary.$element );
	}
	for ( i = 0, len = others.length; i < len; i++ ) {
		other = others[ i ];
		this.$otherActions.append( other.$element );
	}
	if ( special.safe ) {
		this.$safeActions.append( special.safe.$element );
	}

	this.fitLabel();
	this.$body.css( 'bottom', this.$foot.outerHeight( true ) );
};

/**
 * @inheritdoc
 */
OO.ui.ProcessDialog.prototype.executeAction = function ( action ) {
	var process = this;
	return OO.ui.ProcessDialog.parent.prototype.executeAction.call( this, action )
		.fail( function ( errors ) {
			process.showErrors( errors || [] );
		} );
};

/**
 * @inheritdoc
 */
OO.ui.ProcessDialog.prototype.setDimensions = function () {
	// Parent method
	OO.ui.ProcessDialog.parent.prototype.setDimensions.apply( this, arguments );

	this.fitLabel();
};

/**
 * Fit label between actions.
 *
 * @private
 * @chainable
 */
OO.ui.ProcessDialog.prototype.fitLabel = function () {
	var safeWidth, primaryWidth, biggerWidth, labelWidth, navigationWidth, leftWidth, rightWidth,
		size = this.getSizeProperties();

	if ( typeof size.width !== 'number' ) {
		if ( this.isOpened() ) {
			navigationWidth = this.$head.width() - 20;
		} else if ( this.isOpening() ) {
			if ( !this.fitOnOpen ) {
				// Size is relative and the dialog isn't open yet, so wait.
				this.manager.opening.done( this.fitLabel.bind( this ) );
				this.fitOnOpen = true;
			}
			return;
		} else {
			return;
		}
	} else {
		navigationWidth = size.width - 20;
	}

	safeWidth = this.$safeActions.is( ':visible' ) ? this.$safeActions.width() : 0;
	primaryWidth = this.$primaryActions.is( ':visible' ) ? this.$primaryActions.width() : 0;
	biggerWidth = Math.max( safeWidth, primaryWidth );

	labelWidth = this.title.$element.width();

	if ( 2 * biggerWidth + labelWidth < navigationWidth ) {
		// We have enough space to center the label
		leftWidth = rightWidth = biggerWidth;
	} else {
		// Let's hope we at least have enough space not to overlap, because we can't wrap the label…
		if ( this.getDir() === 'ltr' ) {
			leftWidth = safeWidth;
			rightWidth = primaryWidth;
		} else {
			leftWidth = primaryWidth;
			rightWidth = safeWidth;
		}
	}

	this.$location.css( { paddingLeft: leftWidth, paddingRight: rightWidth } );

	return this;
};

/**
 * Handle errors that occurred during accept or reject processes.
 *
 * @private
 * @param {OO.ui.Error[]|OO.ui.Error} errors Errors to be handled
 */
OO.ui.ProcessDialog.prototype.showErrors = function ( errors ) {
	var i, len, $item, actions,
		items = [],
		abilities = {},
		recoverable = true,
		warning = false;

	if ( errors instanceof OO.ui.Error ) {
		errors = [ errors ];
	}

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
		abilities[ this.currentAction ] = true;
		// Copy the flags from the first matching action
		actions = this.actions.get( { actions: this.currentAction } );
		if ( actions.length ) {
			this.retryButton.clearFlags().setFlags( actions[ 0 ].getFlags() );
		}
	} else {
		abilities[ this.currentAction ] = false;
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
 *
 * @private
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
	return OO.ui.ProcessDialog.parent.prototype.getTeardownProcess.call( this, data )
		.first( function () {
			// Make sure to hide errors
			this.hideErrors();
			this.fitOnOpen = false;
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
 * @mixins OO.ui.mixin.LabelElement
 * @mixins OO.ui.mixin.TitledElement
 *
 * @constructor
 * @param {OO.ui.Widget} fieldWidget Field widget
 * @param {Object} [config] Configuration options
 * @cfg {string} [align='left'] Alignment of the label: 'left', 'right', 'top' or 'inline'
 * @cfg {Array} [errors] Error messages about the widget, which will be displayed below the widget.
 *  The array may contain strings or OO.ui.HtmlSnippet instances.
 * @cfg {Array} [notices] Notices about the widget, which will be displayed below the widget.
 *  The array may contain strings or OO.ui.HtmlSnippet instances.
 * @cfg {string|OO.ui.HtmlSnippet} [help] Help text. When help text is specified, a "help" icon will appear
 *  in the upper-right corner of the rendered field; clicking it will display the text in a popup.
 *  For important messages, you are advised to use `notices`, as they are always shown.
 *
 * @throws {Error} An error is thrown if no widget is specified
 */
OO.ui.FieldLayout = function OoUiFieldLayout( fieldWidget, config ) {
	var hasInputWidget, div, i;

	// Allow passing positional parameters inside the config object
	if ( OO.isPlainObject( fieldWidget ) && config === undefined ) {
		config = fieldWidget;
		fieldWidget = config.fieldWidget;
	}

	// Make sure we have required constructor arguments
	if ( fieldWidget === undefined ) {
		throw new Error( 'Widget not found' );
	}

	hasInputWidget = fieldWidget.constructor.static.supportsSimpleLabel;

	// Configuration initialization
	config = $.extend( { align: 'left' }, config );

	// Parent constructor
	OO.ui.FieldLayout.parent.call( this, config );

	// Mixin constructors
	OO.ui.mixin.LabelElement.call( this, config );
	OO.ui.mixin.TitledElement.call( this, $.extend( {}, config, { $titled: this.$label } ) );

	// Properties
	this.fieldWidget = fieldWidget;
	this.errors = config.errors || [];
	this.notices = config.notices || [];
	this.$field = $( '<div>' );
	this.$messages = $( '<ul>' );
	this.$body = $( '<' + ( hasInputWidget ? 'label' : 'div' ) + '>' );
	this.align = null;
	if ( config.help ) {
		this.popupButtonWidget = new OO.ui.PopupButtonWidget( {
			classes: [ 'oo-ui-fieldLayout-help' ],
			framed: false,
			icon: 'info'
		} );

		div = $( '<div>' );
		if ( config.help instanceof OO.ui.HtmlSnippet ) {
			div.html( config.help.toString() );
		} else {
			div.text( config.help );
		}
		this.popupButtonWidget.getPopup().$body.append(
			div.addClass( 'oo-ui-fieldLayout-help-content' )
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
	if ( this.errors.length || this.notices.length ) {
		this.$element.append( this.$messages );
	}
	this.$body.addClass( 'oo-ui-fieldLayout-body' );
	this.$messages.addClass( 'oo-ui-fieldLayout-messages' );
	this.$field
		.addClass( 'oo-ui-fieldLayout-field' )
		.toggleClass( 'oo-ui-fieldLayout-disable', this.fieldWidget.isDisabled() )
		.append( this.fieldWidget.$element );

	for ( i = 0; i < this.notices.length; i++ ) {
		this.$messages.append( this.makeMessage( 'notice', this.notices[ i ] ) );
	}
	for ( i = 0; i < this.errors.length; i++ ) {
		this.$messages.append( this.makeMessage( 'error', this.errors[ i ] ) );
	}

	this.setAlignment( config.align );
};

/* Setup */

OO.inheritClass( OO.ui.FieldLayout, OO.ui.Layout );
OO.mixinClass( OO.ui.FieldLayout, OO.ui.mixin.LabelElement );
OO.mixinClass( OO.ui.FieldLayout, OO.ui.mixin.TitledElement );

/* Methods */

/**
 * Handle field disable events.
 *
 * @private
 * @param {boolean} value Field is disabled
 */
OO.ui.FieldLayout.prototype.onFieldDisable = function ( value ) {
	this.$element.toggleClass( 'oo-ui-fieldLayout-disabled', value );
};

/**
 * Handle label mouse click events.
 *
 * @private
 * @param {jQuery.Event} e Mouse click event
 */
OO.ui.FieldLayout.prototype.onLabelClick = function () {
	this.fieldWidget.simulateLabelClick();
	return false;
};

/**
 * Get the widget contained by the field.
 *
 * @return {OO.ui.Widget} Field widget
 */
OO.ui.FieldLayout.prototype.getField = function () {
	return this.fieldWidget;
};

/**
 * @param {string} kind 'error' or 'notice'
 * @param {string|OO.ui.HtmlSnippet} text
 * @return {jQuery}
 */
OO.ui.FieldLayout.prototype.makeMessage = function ( kind, text ) {
	var $listItem, $icon, message;
	$listItem = $( '<li>' );
	if ( kind === 'error' ) {
		$icon = new OO.ui.IconWidget( { icon: 'alert', flags: [ 'warning' ] } ).$element;
	} else if ( kind === 'notice' ) {
		$icon = new OO.ui.IconWidget( { icon: 'info' } ).$element;
	} else {
		$icon = '';
	}
	message = new OO.ui.LabelWidget( { label: text } );
	$listItem
		.append( $icon, message.$element )
		.addClass( 'oo-ui-fieldLayout-messages-' + kind );
	return $listItem;
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
 * ActionFieldLayouts are used with OO.ui.FieldsetLayout. The layout consists of a field-widget, a button,
 * and an optional label and/or help text. The field-widget (e.g., a {@link OO.ui.TextInputWidget TextInputWidget}),
 * is required and is specified before any optional configuration settings.
 *
 * Labels can be aligned in one of four ways:
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
 * Help text is accessed via a help icon that appears in the upper right corner of the rendered field layout when help
 * text is specified.
 *
 *     @example
 *     // Example of an ActionFieldLayout
 *     var actionFieldLayout = new OO.ui.ActionFieldLayout(
 *         new OO.ui.TextInputWidget( {
 *             placeholder: 'Field widget'
 *         } ),
 *         new OO.ui.ButtonWidget( {
 *             label: 'Button'
 *         } ),
 *         {
 *             label: 'An ActionFieldLayout. This label is aligned top',
 *             align: 'top',
 *             help: 'This is help text'
 *         }
 *     );
 *
 *     $( 'body' ).append( actionFieldLayout.$element );
 *
 *
 * @class
 * @extends OO.ui.FieldLayout
 *
 * @constructor
 * @param {OO.ui.Widget} fieldWidget Field widget
 * @param {OO.ui.ButtonWidget} buttonWidget Button widget
 */
OO.ui.ActionFieldLayout = function OoUiActionFieldLayout( fieldWidget, buttonWidget, config ) {
	// Allow passing positional parameters inside the config object
	if ( OO.isPlainObject( fieldWidget ) && config === undefined ) {
		config = fieldWidget;
		fieldWidget = config.fieldWidget;
		buttonWidget = config.buttonWidget;
	}

	// Parent constructor
	OO.ui.ActionFieldLayout.parent.call( this, fieldWidget, config );

	// Properties
	this.buttonWidget = buttonWidget;
	this.$button = $( '<div>' );
	this.$input = $( '<div>' );

	// Initialization
	this.$element
		.addClass( 'oo-ui-actionFieldLayout' );
	this.$button
		.addClass( 'oo-ui-actionFieldLayout-button' )
		.append( this.buttonWidget.$element );
	this.$input
		.addClass( 'oo-ui-actionFieldLayout-input' )
		.append( this.fieldWidget.$element );
	this.$field
		.append( this.$input, this.$button );
};

/* Setup */

OO.inheritClass( OO.ui.ActionFieldLayout, OO.ui.FieldLayout );

/**
 * FieldsetLayouts are composed of one or more {@link OO.ui.FieldLayout FieldLayouts},
 * which each contain an individual widget and, optionally, a label. Each Fieldset can be
 * configured with a label as well. For more information and examples,
 * please see the [OOjs UI documentation on MediaWiki][1].
 *
 *     @example
 *     // Example of a fieldset layout
 *     var input1 = new OO.ui.TextInputWidget( {
 *         placeholder: 'A text input field'
 *     } );
 *
 *     var input2 = new OO.ui.TextInputWidget( {
 *         placeholder: 'A text input field'
 *     } );
 *
 *     var fieldset = new OO.ui.FieldsetLayout( {
 *         label: 'Example of a fieldset layout'
 *     } );
 *
 *     fieldset.addItems( [
 *         new OO.ui.FieldLayout( input1, {
 *             label: 'Field One'
 *         } ),
 *         new OO.ui.FieldLayout( input2, {
 *             label: 'Field Two'
 *         } )
 *     ] );
 *     $( 'body' ).append( fieldset.$element );
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Layouts/Fields_and_Fieldsets
 *
 * @class
 * @extends OO.ui.Layout
 * @mixins OO.ui.mixin.IconElement
 * @mixins OO.ui.mixin.LabelElement
 * @mixins OO.ui.mixin.GroupElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {OO.ui.FieldLayout[]} [items] An array of fields to add to the fieldset. See OO.ui.FieldLayout for more information about fields.
 */
OO.ui.FieldsetLayout = function OoUiFieldsetLayout( config ) {
	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.FieldsetLayout.parent.call( this, config );

	// Mixin constructors
	OO.ui.mixin.IconElement.call( this, config );
	OO.ui.mixin.LabelElement.call( this, config );
	OO.ui.mixin.GroupElement.call( this, config );

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
OO.mixinClass( OO.ui.FieldsetLayout, OO.ui.mixin.IconElement );
OO.mixinClass( OO.ui.FieldsetLayout, OO.ui.mixin.LabelElement );
OO.mixinClass( OO.ui.FieldsetLayout, OO.ui.mixin.GroupElement );

/**
 * FormLayouts are used to wrap {@link OO.ui.FieldsetLayout FieldsetLayouts} when you intend to use browser-based
 * form submission for the fields instead of handling them in JavaScript. Form layouts can be configured with an
 * HTML form action, an encoding type, and a method using the #action, #enctype, and #method configs, respectively.
 * See the [OOjs UI documentation on MediaWiki] [1] for more information and examples.
 *
 * Only widgets from the {@link OO.ui.InputWidget InputWidget} family support form submission. It
 * includes standard form elements like {@link OO.ui.CheckboxInputWidget checkboxes}, {@link
 * OO.ui.RadioInputWidget radio buttons} and {@link OO.ui.TextInputWidget text fields}, as well as
 * some fancier controls. Some controls have both regular and InputWidget variants, for example
 * OO.ui.DropdownWidget and OO.ui.DropdownInputWidget – only the latter support form submission and
 * often have simplified APIs to match the capabilities of HTML forms.
 * See the [OOjs UI Inputs documentation on MediaWiki] [2] for more information about InputWidgets.
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Layouts/Forms
 * [2]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Inputs
 *
 *     @example
 *     // Example of a form layout that wraps a fieldset layout
 *     var input1 = new OO.ui.TextInputWidget( {
 *         placeholder: 'Username'
 *     } );
 *     var input2 = new OO.ui.TextInputWidget( {
 *         placeholder: 'Password',
 *         type: 'password'
 *     } );
 *     var submit = new OO.ui.ButtonInputWidget( {
 *         label: 'Submit'
 *     } );
 *
 *     var fieldset = new OO.ui.FieldsetLayout( {
 *         label: 'A form layout'
 *     } );
 *     fieldset.addItems( [
 *         new OO.ui.FieldLayout( input1, {
 *             label: 'Username',
 *             align: 'top'
 *         } ),
 *         new OO.ui.FieldLayout( input2, {
 *             label: 'Password',
 *             align: 'top'
 *         } ),
 *         new OO.ui.FieldLayout( submit )
 *     ] );
 *     var form = new OO.ui.FormLayout( {
 *         items: [ fieldset ],
 *         action: '/api/formhandler',
 *         method: 'get'
 *     } )
 *     $( 'body' ).append( form.$element );
 *
 * @class
 * @extends OO.ui.Layout
 * @mixins OO.ui.mixin.GroupElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {string} [method] HTML form `method` attribute
 * @cfg {string} [action] HTML form `action` attribute
 * @cfg {string} [enctype] HTML form `enctype` attribute
 * @cfg {OO.ui.FieldsetLayout[]} [items] Fieldset layouts to add to the form layout.
 */
OO.ui.FormLayout = function OoUiFormLayout( config ) {
	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.FormLayout.parent.call( this, config );

	// Mixin constructors
	OO.ui.mixin.GroupElement.call( this, $.extend( {}, config, { $group: this.$element } ) );

	// Events
	this.$element.on( 'submit', this.onFormSubmit.bind( this ) );

	// Make sure the action is safe
	if ( config.action !== undefined && !OO.ui.isSafeUrl( config.action ) ) {
		throw new Error( 'Potentially unsafe action provided: ' + config.action );
	}

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
OO.mixinClass( OO.ui.FormLayout, OO.ui.mixin.GroupElement );

/* Events */

/**
 * A 'submit' event is emitted when the form is submitted.
 *
 * @event submit
 */

/* Static Properties */

OO.ui.FormLayout.static.tagName = 'form';

/* Methods */

/**
 * Handle form submit events.
 *
 * @private
 * @param {jQuery.Event} e Submit event
 * @fires submit
 */
OO.ui.FormLayout.prototype.onFormSubmit = function () {
	if ( this.emit( 'submit' ) ) {
		return false;
	}
};

/**
 * MenuLayouts combine a menu and a content {@link OO.ui.PanelLayout panel}. The menu is positioned relative to the content (after, before, top, or bottom)
 * and its size is customized with the #menuSize config. The content area will fill all remaining space.
 *
 *     @example
 *     var menuLayout = new OO.ui.MenuLayout( {
 *         position: 'top'
 *     } ),
 *         menuPanel = new OO.ui.PanelLayout( { padded: true, expanded: true, scrollable: true } ),
 *         contentPanel = new OO.ui.PanelLayout( { padded: true, expanded: true, scrollable: true } ),
 *         select = new OO.ui.SelectWidget( {
 *             items: [
 *                 new OO.ui.OptionWidget( {
 *                     data: 'before',
 *                     label: 'Before',
 *                 } ),
 *                 new OO.ui.OptionWidget( {
 *                     data: 'after',
 *                     label: 'After',
 *                 } ),
 *                 new OO.ui.OptionWidget( {
 *                     data: 'top',
 *                     label: 'Top',
 *                 } ),
 *                 new OO.ui.OptionWidget( {
 *                     data: 'bottom',
 *                     label: 'Bottom',
 *                 } )
 *              ]
 *         } ).on( 'select', function ( item ) {
 *            menuLayout.setMenuPosition( item.getData() );
 *         } );
 *
 *     menuLayout.$menu.append(
 *         menuPanel.$element.append( '<b>Menu panel</b>', select.$element )
 *     );
 *     menuLayout.$content.append(
 *         contentPanel.$element.append( '<b>Content panel</b>', '<p>Note that the menu is positioned relative to the content panel: top, bottom, after, before.</p>')
 *     );
 *     $( 'body' ).append( menuLayout.$element );
 *
 * If menu size needs to be overridden, it can be accomplished using CSS similar to the snippet
 * below. MenuLayout's CSS will override the appropriate values with 'auto' or '0' to display the
 * menu correctly. If `menuPosition` is known beforehand, CSS rules corresponding to other positions
 * may be omitted.
 *
 *     .oo-ui-menuLayout-menu {
 *         height: 200px;
 *         width: 200px;
 *     }
 *     .oo-ui-menuLayout-content {
 *         top: 200px;
 *         left: 200px;
 *         right: 200px;
 *         bottom: 200px;
 *     }
 *
 * @class
 * @extends OO.ui.Layout
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {boolean} [showMenu=true] Show menu
 * @cfg {string} [menuPosition='before'] Position of menu: `top`, `after`, `bottom` or `before`
 */
OO.ui.MenuLayout = function OoUiMenuLayout( config ) {
	// Configuration initialization
	config = $.extend( {
		showMenu: true,
		menuPosition: 'before'
	}, config );

	// Parent constructor
	OO.ui.MenuLayout.parent.call( this, config );

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
	this.$menu
		.addClass( 'oo-ui-menuLayout-menu' );
	this.$content.addClass( 'oo-ui-menuLayout-content' );
	this.$element
		.addClass( 'oo-ui-menuLayout' )
		.append( this.$content, this.$menu );
	this.setMenuPosition( config.menuPosition );
	this.toggleMenu( config.showMenu );
};

/* Setup */

OO.inheritClass( OO.ui.MenuLayout, OO.ui.Layout );

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
		this.$element
			.toggleClass( 'oo-ui-menuLayout-showMenu', this.showMenu )
			.toggleClass( 'oo-ui-menuLayout-hideMenu', !this.showMenu );
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
 * Set menu position.
 *
 * @param {string} position Position of menu, either `top`, `after`, `bottom` or `before`
 * @throws {Error} If position value is not supported
 * @chainable
 */
OO.ui.MenuLayout.prototype.setMenuPosition = function ( position ) {
	this.$element.removeClass( 'oo-ui-menuLayout-' + this.menuPosition );
	this.menuPosition = position;
	this.$element.addClass( 'oo-ui-menuLayout-' + position );

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
 * BookletLayouts contain {@link OO.ui.PageLayout page layouts} as well as
 * an {@link OO.ui.OutlineSelectWidget outline} that allows users to easily navigate
 * through the pages and select which one to display. By default, only one page is
 * displayed at a time and the outline is hidden. When a user navigates to a new page,
 * the booklet layout automatically focuses on the first focusable element, unless the
 * default setting is changed. Optionally, booklets can be configured to show
 * {@link OO.ui.OutlineControlsWidget controls} for adding, moving, and removing items.
 *
 *     @example
 *     // Example of a BookletLayout that contains two PageLayouts.
 *
 *     function PageOneLayout( name, config ) {
 *         PageOneLayout.parent.call( this, name, config );
 *         this.$element.append( '<p>First page</p><p>(This booklet has an outline, displayed on the left)</p>' );
 *     }
 *     OO.inheritClass( PageOneLayout, OO.ui.PageLayout );
 *     PageOneLayout.prototype.setupOutlineItem = function () {
 *         this.outlineItem.setLabel( 'Page One' );
 *     };
 *
 *     function PageTwoLayout( name, config ) {
 *         PageTwoLayout.parent.call( this, name, config );
 *         this.$element.append( '<p>Second page</p>' );
 *     }
 *     OO.inheritClass( PageTwoLayout, OO.ui.PageLayout );
 *     PageTwoLayout.prototype.setupOutlineItem = function () {
 *         this.outlineItem.setLabel( 'Page Two' );
 *     };
 *
 *     var page1 = new PageOneLayout( 'one' ),
 *         page2 = new PageTwoLayout( 'two' );
 *
 *     var booklet = new OO.ui.BookletLayout( {
 *         outlined: true
 *     } );
 *
 *     booklet.addPages ( [ page1, page2 ] );
 *     $( 'body' ).append( booklet.$element );
 *
 * @class
 * @extends OO.ui.MenuLayout
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {boolean} [continuous=false] Show all pages, one after another
 * @cfg {boolean} [autoFocus=true] Focus on the first focusable element when a new page is displayed.
 * @cfg {boolean} [outlined=false] Show the outline. The outline is used to navigate through the pages of the booklet.
 * @cfg {boolean} [editable=false] Show controls for adding, removing and reordering pages
 */
OO.ui.BookletLayout = function OoUiBookletLayout( config ) {
	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.BookletLayout.parent.call( this, config );

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
 * A 'set' event is emitted when a page is {@link #setPage set} to be displayed by the booklet layout.
 * @event set
 * @param {OO.ui.PageLayout} page Current page
 */

/**
 * An 'add' event is emitted when pages are {@link #addPages added} to the booklet layout.
 *
 * @event add
 * @param {OO.ui.PageLayout[]} page Added pages
 * @param {number} index Index pages were added at
 */

/**
 * A 'remove' event is emitted when pages are {@link #clearPages cleared} or
 * {@link #removePages removed} from the booklet.
 *
 * @event remove
 * @param {OO.ui.PageLayout[]} pages Removed pages
 */

/* Methods */

/**
 * Handle stack layout focus.
 *
 * @private
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
 * @private
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
 * @param {number} [itemIndex] A specific item to focus on
 */
OO.ui.BookletLayout.prototype.focus = function ( itemIndex ) {
	var $input, page,
		items = this.stackLayout.getItems();

	if ( itemIndex !== undefined && items[ itemIndex ] ) {
		page = items[ itemIndex ];
	} else {
		page = this.stackLayout.getCurrentItem();
	}

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
 * Find the first focusable input in the booklet layout and focus
 * on it.
 */
OO.ui.BookletLayout.prototype.focusFirstFocusable = function () {
	var i, len,
		found = false,
		items = this.stackLayout.getItems(),
		checkAndFocus = function () {
			if ( OO.ui.isFocusableElement( $( this ) ) ) {
				$( this ).focus();
				found = true;
				return false;
			}
		};

	for ( i = 0, len = items.length; i < len; i++ ) {
		if ( found ) {
			break;
		}
		// Find all potentially focusable elements in the item
		// and check if they are focusable
		items[ i ].$element
			.find( 'input, select, textarea, button, object' )
			/* jshint loopfunc:true */
			.each( checkAndFocus );
	}
};

/**
 * Handle outline widget select events.
 *
 * @private
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
 * @return {boolean} Booklet has an outline
 */
OO.ui.BookletLayout.prototype.isOutlined = function () {
	return this.outlined;
};

/**
 * Check if booklet has editing controls.
 *
 * @return {boolean} Booklet is editable
 */
OO.ui.BookletLayout.prototype.isEditable = function () {
	return this.editable;
};

/**
 * Check if booklet has a visible outline.
 *
 * @return {boolean} Outline is visible
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
 * Get the page closest to the specified page.
 *
 * @param {OO.ui.PageLayout} page Page to use as a reference point
 * @return {OO.ui.PageLayout|null} Page closest to the specified page
 */
OO.ui.BookletLayout.prototype.getClosestPage = function ( page ) {
	var next, prev, level,
		pages = this.stackLayout.getItems(),
		index = pages.indexOf( page );

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
 * If the booklet is not outlined, the method will return `null`.
 *
 * @return {OO.ui.OutlineSelectWidget|null} Outline widget, or null if the booklet is not outlined
 */
OO.ui.BookletLayout.prototype.getOutline = function () {
	return this.outlineSelectWidget;
};

/**
 * Get the outline controls widget.
 *
 * If the outline is not editable, the method will return `null`.
 *
 * @return {OO.ui.OutlineControlsWidget|null} The outline controls widget.
 */
OO.ui.BookletLayout.prototype.getOutlineControls = function () {
	return this.outlineControlsWidget;
};

/**
 * Get a page by its symbolic name.
 *
 * @param {string} name Symbolic name of page
 * @return {OO.ui.PageLayout|undefined} Page, if found
 */
OO.ui.BookletLayout.prototype.getPage = function ( name ) {
	return this.pages[ name ];
};

/**
 * Get the current page.
 *
 * @return {OO.ui.PageLayout|undefined} Current page, if found
 */
OO.ui.BookletLayout.prototype.getCurrentPage = function () {
	var name = this.getCurrentPageName();
	return name ? this.getPage( name ) : undefined;
};

/**
 * Get the symbolic name of the current page.
 *
 * @return {string|null} Symbolic name of the current page
 */
OO.ui.BookletLayout.prototype.getCurrentPageName = function () {
	return this.currentPageName;
};

/**
 * Add pages to the booklet layout
 *
 * When pages are added with the same names as existing pages, the existing pages will be
 * automatically removed before the new pages are added.
 *
 * @param {OO.ui.PageLayout[]} pages Pages to add
 * @param {number} index Index of the insertion point
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
			currentIndex = stackLayoutPages.indexOf( this.pages[ name ] );
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
 * Remove the specified pages from the booklet layout.
 *
 * To remove all pages from the booklet, you may wish to use the #clearPages method instead.
 *
 * @param {OO.ui.PageLayout[]} pages An array of pages to remove
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
 * Clear all pages from the booklet layout.
 *
 * To remove only a subset of pages from the booklet, use the #removePages method.
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
 * Set the current page by symbolic name.
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
				this.outlineSelectWidget.selectItemByData( name );
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
 * IndexLayouts contain {@link OO.ui.CardLayout card layouts} as well as
 * {@link OO.ui.TabSelectWidget tabs} that allow users to easily navigate through the cards and
 * select which one to display. By default, only one card is displayed at a time. When a user
 * navigates to a new card, the index layout automatically focuses on the first focusable element,
 * unless the default setting is changed.
 *
 * TODO: This class is similar to BookletLayout, we may want to refactor to reduce duplication
 *
 *     @example
 *     // Example of a IndexLayout that contains two CardLayouts.
 *
 *     function CardOneLayout( name, config ) {
 *         CardOneLayout.parent.call( this, name, config );
 *         this.$element.append( '<p>First card</p>' );
 *     }
 *     OO.inheritClass( CardOneLayout, OO.ui.CardLayout );
 *     CardOneLayout.prototype.setupTabItem = function () {
 *         this.tabItem.setLabel( 'Card One' );
 *     };
 *
 *     function CardTwoLayout( name, config ) {
 *         CardTwoLayout.parent.call( this, name, config );
 *         this.$element.append( '<p>Second card</p>' );
 *     }
 *     OO.inheritClass( CardTwoLayout, OO.ui.CardLayout );
 *     CardTwoLayout.prototype.setupTabItem = function () {
 *         this.tabItem.setLabel( 'Card Two' );
 *     };
 *
 *     var card1 = new CardOneLayout( 'one' ),
 *         card2 = new CardTwoLayout( 'two' );
 *
 *     var index = new OO.ui.IndexLayout();
 *
 *     index.addCards ( [ card1, card2 ] );
 *     $( 'body' ).append( index.$element );
 *
 * @class
 * @extends OO.ui.MenuLayout
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {boolean} [continuous=false] Show all cards, one after another
 * @cfg {boolean} [autoFocus=true] Focus on the first focusable element when a new card is displayed.
 */
OO.ui.IndexLayout = function OoUiIndexLayout( config ) {
	// Configuration initialization
	config = $.extend( {}, config, { menuPosition: 'top' } );

	// Parent constructor
	OO.ui.IndexLayout.parent.call( this, config );

	// Properties
	this.currentCardName = null;
	this.cards = {};
	this.ignoreFocus = false;
	this.stackLayout = new OO.ui.StackLayout( { continuous: !!config.continuous } );
	this.$content.append( this.stackLayout.$element );
	this.autoFocus = config.autoFocus === undefined || !!config.autoFocus;

	this.tabSelectWidget = new OO.ui.TabSelectWidget();
	this.tabPanel = new OO.ui.PanelLayout();
	this.$menu.append( this.tabPanel.$element );

	this.toggleMenu( true );

	// Events
	this.stackLayout.connect( this, { set: 'onStackLayoutSet' } );
	this.tabSelectWidget.connect( this, { select: 'onTabSelectWidgetSelect' } );
	if ( this.autoFocus ) {
		// Event 'focus' does not bubble, but 'focusin' does
		this.stackLayout.$element.on( 'focusin', this.onStackLayoutFocus.bind( this ) );
	}

	// Initialization
	this.$element.addClass( 'oo-ui-indexLayout' );
	this.stackLayout.$element.addClass( 'oo-ui-indexLayout-stackLayout' );
	this.tabPanel.$element
		.addClass( 'oo-ui-indexLayout-tabPanel' )
		.append( this.tabSelectWidget.$element );
};

/* Setup */

OO.inheritClass( OO.ui.IndexLayout, OO.ui.MenuLayout );

/* Events */

/**
 * A 'set' event is emitted when a card is {@link #setCard set} to be displayed by the index layout.
 * @event set
 * @param {OO.ui.CardLayout} card Current card
 */

/**
 * An 'add' event is emitted when cards are {@link #addCards added} to the index layout.
 *
 * @event add
 * @param {OO.ui.CardLayout[]} card Added cards
 * @param {number} index Index cards were added at
 */

/**
 * A 'remove' event is emitted when cards are {@link #clearCards cleared} or
 * {@link #removeCards removed} from the index.
 *
 * @event remove
 * @param {OO.ui.CardLayout[]} cards Removed cards
 */

/* Methods */

/**
 * Handle stack layout focus.
 *
 * @private
 * @param {jQuery.Event} e Focusin event
 */
OO.ui.IndexLayout.prototype.onStackLayoutFocus = function ( e ) {
	var name, $target;

	// Find the card that an element was focused within
	$target = $( e.target ).closest( '.oo-ui-cardLayout' );
	for ( name in this.cards ) {
		// Check for card match, exclude current card to find only card changes
		if ( this.cards[ name ].$element[ 0 ] === $target[ 0 ] && name !== this.currentCardName ) {
			this.setCard( name );
			break;
		}
	}
};

/**
 * Handle stack layout set events.
 *
 * @private
 * @param {OO.ui.PanelLayout|null} card The card panel that is now the current panel
 */
OO.ui.IndexLayout.prototype.onStackLayoutSet = function ( card ) {
	var layout = this;
	if ( card ) {
		card.scrollElementIntoView( { complete: function () {
			if ( layout.autoFocus ) {
				layout.focus();
			}
		} } );
	}
};

/**
 * Focus the first input in the current card.
 *
 * If no card is selected, the first selectable card will be selected.
 * If the focus is already in an element on the current card, nothing will happen.
 * @param {number} [itemIndex] A specific item to focus on
 */
OO.ui.IndexLayout.prototype.focus = function ( itemIndex ) {
	var $input, card,
		items = this.stackLayout.getItems();

	if ( itemIndex !== undefined && items[ itemIndex ] ) {
		card = items[ itemIndex ];
	} else {
		card = this.stackLayout.getCurrentItem();
	}

	if ( !card ) {
		this.selectFirstSelectableCard();
		card = this.stackLayout.getCurrentItem();
	}
	if ( !card ) {
		return;
	}
	// Only change the focus if is not already in the current card
	if ( !card.$element.find( ':focus' ).length ) {
		$input = card.$element.find( ':input:first' );
		if ( $input.length ) {
			$input[ 0 ].focus();
		}
	}
};

/**
 * Find the first focusable input in the index layout and focus
 * on it.
 */
OO.ui.IndexLayout.prototype.focusFirstFocusable = function () {
	var i, len,
		found = false,
		items = this.stackLayout.getItems(),
		checkAndFocus = function () {
			if ( OO.ui.isFocusableElement( $( this ) ) ) {
				$( this ).focus();
				found = true;
				return false;
			}
		};

	for ( i = 0, len = items.length; i < len; i++ ) {
		if ( found ) {
			break;
		}
		// Find all potentially focusable elements in the item
		// and check if they are focusable
		items[ i ].$element
			.find( 'input, select, textarea, button, object' )
			.each( checkAndFocus );
	}
};

/**
 * Handle tab widget select events.
 *
 * @private
 * @param {OO.ui.OptionWidget|null} item Selected item
 */
OO.ui.IndexLayout.prototype.onTabSelectWidgetSelect = function ( item ) {
	if ( item ) {
		this.setCard( item.getData() );
	}
};

/**
 * Get the card closest to the specified card.
 *
 * @param {OO.ui.CardLayout} card Card to use as a reference point
 * @return {OO.ui.CardLayout|null} Card closest to the specified card
 */
OO.ui.IndexLayout.prototype.getClosestCard = function ( card ) {
	var next, prev, level,
		cards = this.stackLayout.getItems(),
		index = cards.indexOf( card );

	if ( index !== -1 ) {
		next = cards[ index + 1 ];
		prev = cards[ index - 1 ];
		// Prefer adjacent cards at the same level
		level = this.tabSelectWidget.getItemFromData( card.getName() ).getLevel();
		if (
			prev &&
			level === this.tabSelectWidget.getItemFromData( prev.getName() ).getLevel()
		) {
			return prev;
		}
		if (
			next &&
			level === this.tabSelectWidget.getItemFromData( next.getName() ).getLevel()
		) {
			return next;
		}
	}
	return prev || next || null;
};

/**
 * Get the tabs widget.
 *
 * @return {OO.ui.TabSelectWidget} Tabs widget
 */
OO.ui.IndexLayout.prototype.getTabs = function () {
	return this.tabSelectWidget;
};

/**
 * Get a card by its symbolic name.
 *
 * @param {string} name Symbolic name of card
 * @return {OO.ui.CardLayout|undefined} Card, if found
 */
OO.ui.IndexLayout.prototype.getCard = function ( name ) {
	return this.cards[ name ];
};

/**
 * Get the current card.
 *
 * @return {OO.ui.CardLayout|undefined} Current card, if found
 */
OO.ui.IndexLayout.prototype.getCurrentCard = function () {
	var name = this.getCurrentCardName();
	return name ? this.getCard( name ) : undefined;
};

/**
 * Get the symbolic name of the current card.
 *
 * @return {string|null} Symbolic name of the current card
 */
OO.ui.IndexLayout.prototype.getCurrentCardName = function () {
	return this.currentCardName;
};

/**
 * Add cards to the index layout
 *
 * When cards are added with the same names as existing cards, the existing cards will be
 * automatically removed before the new cards are added.
 *
 * @param {OO.ui.CardLayout[]} cards Cards to add
 * @param {number} index Index of the insertion point
 * @fires add
 * @chainable
 */
OO.ui.IndexLayout.prototype.addCards = function ( cards, index ) {
	var i, len, name, card, item, currentIndex,
		stackLayoutCards = this.stackLayout.getItems(),
		remove = [],
		items = [];

	// Remove cards with same names
	for ( i = 0, len = cards.length; i < len; i++ ) {
		card = cards[ i ];
		name = card.getName();

		if ( Object.prototype.hasOwnProperty.call( this.cards, name ) ) {
			// Correct the insertion index
			currentIndex = stackLayoutCards.indexOf( this.cards[ name ] );
			if ( currentIndex !== -1 && currentIndex + 1 < index ) {
				index--;
			}
			remove.push( this.cards[ name ] );
		}
	}
	if ( remove.length ) {
		this.removeCards( remove );
	}

	// Add new cards
	for ( i = 0, len = cards.length; i < len; i++ ) {
		card = cards[ i ];
		name = card.getName();
		this.cards[ card.getName() ] = card;
		item = new OO.ui.TabOptionWidget( { data: name } );
		card.setTabItem( item );
		items.push( item );
	}

	if ( items.length ) {
		this.tabSelectWidget.addItems( items, index );
		this.selectFirstSelectableCard();
	}
	this.stackLayout.addItems( cards, index );
	this.emit( 'add', cards, index );

	return this;
};

/**
 * Remove the specified cards from the index layout.
 *
 * To remove all cards from the index, you may wish to use the #clearCards method instead.
 *
 * @param {OO.ui.CardLayout[]} cards An array of cards to remove
 * @fires remove
 * @chainable
 */
OO.ui.IndexLayout.prototype.removeCards = function ( cards ) {
	var i, len, name, card,
		items = [];

	for ( i = 0, len = cards.length; i < len; i++ ) {
		card = cards[ i ];
		name = card.getName();
		delete this.cards[ name ];
		items.push( this.tabSelectWidget.getItemFromData( name ) );
		card.setTabItem( null );
	}
	if ( items.length ) {
		this.tabSelectWidget.removeItems( items );
		this.selectFirstSelectableCard();
	}
	this.stackLayout.removeItems( cards );
	this.emit( 'remove', cards );

	return this;
};

/**
 * Clear all cards from the index layout.
 *
 * To remove only a subset of cards from the index, use the #removeCards method.
 *
 * @fires remove
 * @chainable
 */
OO.ui.IndexLayout.prototype.clearCards = function () {
	var i, len,
		cards = this.stackLayout.getItems();

	this.cards = {};
	this.currentCardName = null;
	this.tabSelectWidget.clearItems();
	for ( i = 0, len = cards.length; i < len; i++ ) {
		cards[ i ].setTabItem( null );
	}
	this.stackLayout.clearItems();

	this.emit( 'remove', cards );

	return this;
};

/**
 * Set the current card by symbolic name.
 *
 * @fires set
 * @param {string} name Symbolic name of card
 */
OO.ui.IndexLayout.prototype.setCard = function ( name ) {
	var selectedItem,
		$focused,
		card = this.cards[ name ];

	if ( name !== this.currentCardName ) {
		selectedItem = this.tabSelectWidget.getSelectedItem();
		if ( selectedItem && selectedItem.getData() !== name ) {
			this.tabSelectWidget.selectItemByData( name );
		}
		if ( card ) {
			if ( this.currentCardName && this.cards[ this.currentCardName ] ) {
				this.cards[ this.currentCardName ].setActive( false );
				// Blur anything focused if the next card doesn't have anything focusable - this
				// is not needed if the next card has something focusable because once it is focused
				// this blur happens automatically
				if ( this.autoFocus && !card.$element.find( ':input' ).length ) {
					$focused = this.cards[ this.currentCardName ].$element.find( ':focus' );
					if ( $focused.length ) {
						$focused[ 0 ].blur();
					}
				}
			}
			this.currentCardName = name;
			this.stackLayout.setItem( card );
			card.setActive( true );
			this.emit( 'set', card );
		}
	}
};

/**
 * Select the first selectable card.
 *
 * @chainable
 */
OO.ui.IndexLayout.prototype.selectFirstSelectableCard = function () {
	if ( !this.tabSelectWidget.getSelectedItem() ) {
		this.tabSelectWidget.selectItem( this.tabSelectWidget.getFirstSelectableItem() );
	}

	return this;
};

/**
 * PanelLayouts expand to cover the entire area of their parent. They can be configured with scrolling, padding,
 * and a frame, and are often used together with {@link OO.ui.StackLayout StackLayouts}.
 *
 *     @example
 *     // Example of a panel layout
 *     var panel = new OO.ui.PanelLayout( {
 *         expanded: false,
 *         framed: true,
 *         padded: true,
 *         $content: $( '<p>A panel layout with padding and a frame.</p>' )
 *     } );
 *     $( 'body' ).append( panel.$element );
 *
 * @class
 * @extends OO.ui.Layout
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {boolean} [scrollable=false] Allow vertical scrolling
 * @cfg {boolean} [padded=false] Add padding between the content and the edges of the panel.
 * @cfg {boolean} [expanded=true] Expand the panel to fill the entire parent element.
 * @cfg {boolean} [framed=false] Render the panel with a frame to visually separate it from outside content.
 */
OO.ui.PanelLayout = function OoUiPanelLayout( config ) {
	// Configuration initialization
	config = $.extend( {
		scrollable: false,
		padded: false,
		expanded: true,
		framed: false
	}, config );

	// Parent constructor
	OO.ui.PanelLayout.parent.call( this, config );

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
	if ( config.framed ) {
		this.$element.addClass( 'oo-ui-panelLayout-framed' );
	}
};

/* Setup */

OO.inheritClass( OO.ui.PanelLayout, OO.ui.Layout );

/**
 * CardLayouts are used within {@link OO.ui.IndexLayout index layouts} to create cards that users can select and display
 * from the index's optional {@link OO.ui.TabSelectWidget tab} navigation. Cards are usually not instantiated directly,
 * rather extended to include the required content and functionality.
 *
 * Each card must have a unique symbolic name, which is passed to the constructor. In addition, the card's tab
 * item is customized (with a label) using the #setupTabItem method. See
 * {@link OO.ui.IndexLayout IndexLayout} for an example.
 *
 * @class
 * @extends OO.ui.PanelLayout
 *
 * @constructor
 * @param {string} name Unique symbolic name of card
 * @param {Object} [config] Configuration options
 */
OO.ui.CardLayout = function OoUiCardLayout( name, config ) {
	// Allow passing positional parameters inside the config object
	if ( OO.isPlainObject( name ) && config === undefined ) {
		config = name;
		name = config.name;
	}

	// Configuration initialization
	config = $.extend( { scrollable: true }, config );

	// Parent constructor
	OO.ui.CardLayout.parent.call( this, config );

	// Properties
	this.name = name;
	this.tabItem = null;
	this.active = false;

	// Initialization
	this.$element.addClass( 'oo-ui-cardLayout' );
};

/* Setup */

OO.inheritClass( OO.ui.CardLayout, OO.ui.PanelLayout );

/* Events */

/**
 * An 'active' event is emitted when the card becomes active. Cards become active when they are
 * shown in a index layout that is configured to display only one card at a time.
 *
 * @event active
 * @param {boolean} active Card is active
 */

/* Methods */

/**
 * Get the symbolic name of the card.
 *
 * @return {string} Symbolic name of card
 */
OO.ui.CardLayout.prototype.getName = function () {
	return this.name;
};

/**
 * Check if card is active.
 *
 * Cards become active when they are shown in a {@link OO.ui.IndexLayout index layout} that is configured to display
 * only one card at a time. Additional CSS is applied to the card's tab item to reflect the active state.
 *
 * @return {boolean} Card is active
 */
OO.ui.CardLayout.prototype.isActive = function () {
	return this.active;
};

/**
 * Get tab item.
 *
 * The tab item allows users to access the card from the index's tab
 * navigation. The tab item itself can be customized (with a label, level, etc.) using the #setupTabItem method.
 *
 * @return {OO.ui.TabOptionWidget|null} Tab option widget
 */
OO.ui.CardLayout.prototype.getTabItem = function () {
	return this.tabItem;
};

/**
 * Set or unset the tab item.
 *
 * Specify a {@link OO.ui.TabOptionWidget tab option} to set it,
 * or `null` to clear the tab item. To customize the tab item itself (e.g., to set a label or tab
 * level), use #setupTabItem instead of this method.
 *
 * @param {OO.ui.TabOptionWidget|null} tabItem Tab option widget, null to clear
 * @chainable
 */
OO.ui.CardLayout.prototype.setTabItem = function ( tabItem ) {
	this.tabItem = tabItem || null;
	if ( tabItem ) {
		this.setupTabItem();
	}
	return this;
};

/**
 * Set up the tab item.
 *
 * Use this method to customize the tab item (e.g., to add a label or tab level). To set or unset
 * the tab item itself (with a {@link OO.ui.TabOptionWidget tab option} or `null`), use
 * the #setTabItem method instead.
 *
 * @param {OO.ui.TabOptionWidget} tabItem Tab option widget to set up
 * @chainable
 */
OO.ui.CardLayout.prototype.setupTabItem = function () {
	return this;
};

/**
 * Set the card to its 'active' state.
 *
 * Cards become active when they are shown in a index layout that is configured to display only one card at a time. Additional
 * CSS is applied to the tab item to reflect the card's active state. Outside of the index
 * context, setting the active state on a card does nothing.
 *
 * @param {boolean} value Card is active
 * @fires active
 */
OO.ui.CardLayout.prototype.setActive = function ( active ) {
	active = !!active;

	if ( active !== this.active ) {
		this.active = active;
		this.$element.toggleClass( 'oo-ui-cardLayout-active', this.active );
		this.emit( 'active', this.active );
	}
};

/**
 * PageLayouts are used within {@link OO.ui.BookletLayout booklet layouts} to create pages that users can select and display
 * from the booklet's optional {@link OO.ui.OutlineSelectWidget outline} navigation. Pages are usually not instantiated directly,
 * rather extended to include the required content and functionality.
 *
 * Each page must have a unique symbolic name, which is passed to the constructor. In addition, the page's outline
 * item is customized (with a label, outline level, etc.) using the #setupOutlineItem method. See
 * {@link OO.ui.BookletLayout BookletLayout} for an example.
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
	OO.ui.PageLayout.parent.call( this, config );

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
 * An 'active' event is emitted when the page becomes active. Pages become active when they are
 * shown in a booklet layout that is configured to display only one page at a time.
 *
 * @event active
 * @param {boolean} active Page is active
 */

/* Methods */

/**
 * Get the symbolic name of the page.
 *
 * @return {string} Symbolic name of page
 */
OO.ui.PageLayout.prototype.getName = function () {
	return this.name;
};

/**
 * Check if page is active.
 *
 * Pages become active when they are shown in a {@link OO.ui.BookletLayout booklet layout} that is configured to display
 * only one page at a time. Additional CSS is applied to the page's outline item to reflect the active state.
 *
 * @return {boolean} Page is active
 */
OO.ui.PageLayout.prototype.isActive = function () {
	return this.active;
};

/**
 * Get outline item.
 *
 * The outline item allows users to access the page from the booklet's outline
 * navigation. The outline item itself can be customized (with a label, level, etc.) using the #setupOutlineItem method.
 *
 * @return {OO.ui.OutlineOptionWidget|null} Outline option widget
 */
OO.ui.PageLayout.prototype.getOutlineItem = function () {
	return this.outlineItem;
};

/**
 * Set or unset the outline item.
 *
 * Specify an {@link OO.ui.OutlineOptionWidget outline option} to set it,
 * or `null` to clear the outline item. To customize the outline item itself (e.g., to set a label or outline
 * level), use #setupOutlineItem instead of this method.
 *
 * @param {OO.ui.OutlineOptionWidget|null} outlineItem Outline option widget, null to clear
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
 * Set up the outline item.
 *
 * Use this method to customize the outline item (e.g., to add a label or outline level). To set or unset
 * the outline item itself (with an {@link OO.ui.OutlineOptionWidget outline option} or `null`), use
 * the #setOutlineItem method instead.
 *
 * @param {OO.ui.OutlineOptionWidget} outlineItem Outline option widget to set up
 * @chainable
 */
OO.ui.PageLayout.prototype.setupOutlineItem = function () {
	return this;
};

/**
 * Set the page to its 'active' state.
 *
 * Pages become active when they are shown in a booklet layout that is configured to display only one page at a time. Additional
 * CSS is applied to the outline item to reflect the page's active state. Outside of the booklet
 * context, setting the active state on a page does nothing.
 *
 * @param {boolean} value Page is active
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
 * StackLayouts contain a series of {@link OO.ui.PanelLayout panel layouts}. By default, only one panel is displayed
 * at a time, though the stack layout can also be configured to show all contained panels, one after another,
 * by setting the #continuous option to 'true'.
 *
 *     @example
 *     // A stack layout with two panels, configured to be displayed continously
 *     var myStack = new OO.ui.StackLayout( {
 *         items: [
 *             new OO.ui.PanelLayout( {
 *                 $content: $( '<p>Panel One</p>' ),
 *                 padded: true,
 *                 framed: true
 *             } ),
 *             new OO.ui.PanelLayout( {
 *                 $content: $( '<p>Panel Two</p>' ),
 *                 padded: true,
 *                 framed: true
 *             } )
 *         ],
 *         continuous: true
 *     } );
 *     $( 'body' ).append( myStack.$element );
 *
 * @class
 * @extends OO.ui.PanelLayout
 * @mixins OO.ui.mixin.GroupElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {boolean} [continuous=false] Show all panels, one after another. By default, only one panel is displayed at a time.
 * @cfg {OO.ui.Layout[]} [items] Panel layouts to add to the stack layout.
 */
OO.ui.StackLayout = function OoUiStackLayout( config ) {
	// Configuration initialization
	config = $.extend( { scrollable: true }, config );

	// Parent constructor
	OO.ui.StackLayout.parent.call( this, config );

	// Mixin constructors
	OO.ui.mixin.GroupElement.call( this, $.extend( {}, config, { $group: this.$element } ) );

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
OO.mixinClass( OO.ui.StackLayout, OO.ui.mixin.GroupElement );

/* Events */

/**
 * A 'set' event is emitted when panels are {@link #addItems added}, {@link #removeItems removed},
 * {@link #clearItems cleared} or {@link #setItem displayed}.
 *
 * @event set
 * @param {OO.ui.Layout|null} item Current panel or `null` if no panel is shown
 */

/* Methods */

/**
 * Get the current panel.
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
 * Add panel layouts to the stack layout.
 *
 * Panels will be added to the end of the stack layout array unless the optional index parameter specifies a different
 * insertion point. Adding a panel that is already in the stack will move it to the end of the array or the point specified
 * by the index.
 *
 * @param {OO.ui.Layout[]} items Panels to add
 * @param {number} [index] Index of the insertion point
 * @chainable
 */
OO.ui.StackLayout.prototype.addItems = function ( items, index ) {
	// Update the visibility
	this.updateHiddenState( items, this.currentItem );

	// Mixin method
	OO.ui.mixin.GroupElement.prototype.addItems.call( this, items, index );

	if ( !this.currentItem && items.length ) {
		this.setItem( items[ 0 ] );
	}

	return this;
};

/**
 * Remove the specified panels from the stack layout.
 *
 * Removed panels are detached from the DOM, not removed, so that they may be reused. To remove all panels,
 * you may wish to use the #clearItems method instead.
 *
 * @param {OO.ui.Layout[]} items Panels to remove
 * @chainable
 * @fires set
 */
OO.ui.StackLayout.prototype.removeItems = function ( items ) {
	// Mixin method
	OO.ui.mixin.GroupElement.prototype.removeItems.call( this, items );

	if ( items.indexOf( this.currentItem ) !== -1 ) {
		if ( this.items.length ) {
			this.setItem( this.items[ 0 ] );
		} else {
			this.unsetCurrentItem();
		}
	}

	return this;
};

/**
 * Clear all panels from the stack layout.
 *
 * Cleared panels are detached from the DOM, not removed, so that they may be reused. To remove only
 * a subset of panels, use the #removeItems method.
 *
 * @chainable
 * @fires set
 */
OO.ui.StackLayout.prototype.clearItems = function () {
	this.unsetCurrentItem();
	OO.ui.mixin.GroupElement.prototype.clearItems.call( this );

	return this;
};

/**
 * Show the specified panel.
 *
 * If another panel is currently displayed, it will be hidden.
 *
 * @param {OO.ui.Layout} item Panel to show
 * @chainable
 * @fires set
 */
OO.ui.StackLayout.prototype.setItem = function ( item ) {
	if ( item !== this.currentItem ) {
		this.updateHiddenState( this.items, item );

		if ( this.items.indexOf( item ) !== -1 ) {
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
 * @private
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
 * HorizontalLayout arranges its contents in a single line (using `display: inline-block` for its
 * items), with small margins between them. Convenient when you need to put a number of block-level
 * widgets on a single line next to each other.
 *
 * Note that inline elements, such as OO.ui.ButtonWidgets, do not need this wrapper.
 *
 *     @example
 *     // HorizontalLayout with a text input and a label
 *     var layout = new OO.ui.HorizontalLayout( {
 *       items: [
 *         new OO.ui.LabelWidget( { label: 'Label' } ),
 *         new OO.ui.TextInputWidget( { value: 'Text' } )
 *       ]
 *     } );
 *     $( 'body' ).append( layout.$element );
 *
 * @class
 * @extends OO.ui.Layout
 * @mixins OO.ui.mixin.GroupElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {OO.ui.Widget[]|OO.ui.Layout[]} [items] Widgets or other layouts to add to the layout.
 */
OO.ui.HorizontalLayout = function OoUiHorizontalLayout( config ) {
	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.HorizontalLayout.parent.call( this, config );

	// Mixin constructors
	OO.ui.mixin.GroupElement.call( this, $.extend( {}, config, { $group: this.$element } ) );

	// Initialization
	this.$element.addClass( 'oo-ui-horizontalLayout' );
	if ( Array.isArray( config.items ) ) {
		this.addItems( config.items );
	}
};

/* Setup */

OO.inheritClass( OO.ui.HorizontalLayout, OO.ui.Layout );
OO.mixinClass( OO.ui.HorizontalLayout, OO.ui.mixin.GroupElement );

/**
 * BarToolGroups are one of three types of {@link OO.ui.ToolGroup toolgroups} that are used to
 * create {@link OO.ui.Toolbar toolbars} (the other types of groups are {@link OO.ui.MenuToolGroup MenuToolGroup}
 * and {@link OO.ui.ListToolGroup ListToolGroup}). The {@link OO.ui.Tool tools} in a BarToolGroup are
 * displayed by icon in a single row. The title of the tool is displayed when users move the mouse over
 * the tool.
 *
 * BarToolGroups are created by a {@link OO.ui.ToolGroupFactory tool group factory} when the toolbar is
 * set up.
 *
 *     @example
 *     // Example of a BarToolGroup with two tools
 *     var toolFactory = new OO.ui.ToolFactory();
 *     var toolGroupFactory = new OO.ui.ToolGroupFactory();
 *     var toolbar = new OO.ui.Toolbar( toolFactory, toolGroupFactory );
 *
 *     // We will be placing status text in this element when tools are used
 *     var $area = $( '<p>' ).text( 'Example of a BarToolGroup with two tools.' );
 *
 *     // Define the tools that we're going to place in our toolbar
 *
 *     // Create a class inheriting from OO.ui.Tool
 *     function PictureTool() {
 *         PictureTool.parent.apply( this, arguments );
 *     }
 *     OO.inheritClass( PictureTool, OO.ui.Tool );
 *     // Each tool must have a 'name' (used as an internal identifier, see later) and at least one
 *     // of 'icon' and 'title' (displayed icon and text).
 *     PictureTool.static.name = 'picture';
 *     PictureTool.static.icon = 'picture';
 *     PictureTool.static.title = 'Insert picture';
 *     // Defines the action that will happen when this tool is selected (clicked).
 *     PictureTool.prototype.onSelect = function () {
 *         $area.text( 'Picture tool clicked!' );
 *         // Never display this tool as "active" (selected).
 *         this.setActive( false );
 *     };
 *     // Make this tool available in our toolFactory and thus our toolbar
 *     toolFactory.register( PictureTool );
 *
 *     // This is a PopupTool. Rather than having a custom 'onSelect' action, it will display a
 *     // little popup window (a PopupWidget).
 *     function HelpTool( toolGroup, config ) {
 *         OO.ui.PopupTool.call( this, toolGroup, $.extend( { popup: {
 *             padded: true,
 *             label: 'Help',
 *             head: true
 *         } }, config ) );
 *         this.popup.$body.append( '<p>I am helpful!</p>' );
 *     }
 *     OO.inheritClass( HelpTool, OO.ui.PopupTool );
 *     HelpTool.static.name = 'help';
 *     HelpTool.static.icon = 'help';
 *     HelpTool.static.title = 'Help';
 *     toolFactory.register( HelpTool );
 *
 *     // Finally define which tools and in what order appear in the toolbar. Each tool may only be
 *     // used once (but not all defined tools must be used).
 *     toolbar.setup( [
 *         {
 *             // 'bar' tool groups display tools by icon only
 *             type: 'bar',
 *             include: [ 'picture', 'help' ]
 *         }
 *     ] );
 *
 *     // Create some UI around the toolbar and place it in the document
 *     var frame = new OO.ui.PanelLayout( {
 *         expanded: false,
 *         framed: true
 *     } );
 *     var contentFrame = new OO.ui.PanelLayout( {
 *         expanded: false,
 *         padded: true
 *     } );
 *     frame.$element.append(
 *         toolbar.$element,
 *         contentFrame.$element.append( $area )
 *     );
 *     $( 'body' ).append( frame.$element );
 *
 *     // Here is where the toolbar is actually built. This must be done after inserting it into the
 *     // document.
 *     toolbar.initialize();
 *
 * For more information about how to add tools to a bar tool group, please see {@link OO.ui.ToolGroup toolgroup}.
 * For more information about toolbars in general, please see the [OOjs UI documentation on MediaWiki][1].
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Toolbars
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
	OO.ui.BarToolGroup.parent.call( this, toolbar, config );

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
 * PopupToolGroup is an abstract base class used by both {@link OO.ui.MenuToolGroup MenuToolGroup}
 * and {@link OO.ui.ListToolGroup ListToolGroup} to provide a popup--an overlaid menu or list of tools with an
 * optional icon and label. This class can be used for other base classes that also use this functionality.
 *
 * @abstract
 * @class
 * @extends OO.ui.ToolGroup
 * @mixins OO.ui.mixin.IconElement
 * @mixins OO.ui.mixin.IndicatorElement
 * @mixins OO.ui.mixin.LabelElement
 * @mixins OO.ui.mixin.TitledElement
 * @mixins OO.ui.mixin.ClippableElement
 * @mixins OO.ui.mixin.TabIndexedElement
 *
 * @constructor
 * @param {OO.ui.Toolbar} toolbar
 * @param {Object} [config] Configuration options
 * @cfg {string} [header] Text to display at the top of the popup
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
	OO.ui.PopupToolGroup.parent.call( this, toolbar, config );

	// Properties
	this.active = false;
	this.dragging = false;
	this.onBlurHandler = this.onBlur.bind( this );
	this.$handle = $( '<span>' );

	// Mixin constructors
	OO.ui.mixin.IconElement.call( this, config );
	OO.ui.mixin.IndicatorElement.call( this, config );
	OO.ui.mixin.LabelElement.call( this, config );
	OO.ui.mixin.TitledElement.call( this, config );
	OO.ui.mixin.ClippableElement.call( this, $.extend( {}, config, { $clippable: this.$group } ) );
	OO.ui.mixin.TabIndexedElement.call( this, $.extend( {}, config, { $tabIndexed: this.$handle } ) );

	// Events
	this.$handle.on( {
		keydown: this.onHandleMouseKeyDown.bind( this ),
		keyup: this.onHandleMouseKeyUp.bind( this ),
		mousedown: this.onHandleMouseKeyDown.bind( this ),
		mouseup: this.onHandleMouseKeyUp.bind( this )
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
OO.mixinClass( OO.ui.PopupToolGroup, OO.ui.mixin.IconElement );
OO.mixinClass( OO.ui.PopupToolGroup, OO.ui.mixin.IndicatorElement );
OO.mixinClass( OO.ui.PopupToolGroup, OO.ui.mixin.LabelElement );
OO.mixinClass( OO.ui.PopupToolGroup, OO.ui.mixin.TitledElement );
OO.mixinClass( OO.ui.PopupToolGroup, OO.ui.mixin.ClippableElement );
OO.mixinClass( OO.ui.PopupToolGroup, OO.ui.mixin.TabIndexedElement );

/* Methods */

/**
 * @inheritdoc
 */
OO.ui.PopupToolGroup.prototype.setDisabled = function () {
	// Parent method
	OO.ui.PopupToolGroup.parent.prototype.setDisabled.apply( this, arguments );

	if ( this.isDisabled() && this.isElementAttached() ) {
		this.setActive( false );
	}
};

/**
 * Handle focus being lost.
 *
 * The event is actually generated from a mouseup/keyup, so it is not a normal blur event object.
 *
 * @protected
 * @param {jQuery.Event} e Mouse up or key up event
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
OO.ui.PopupToolGroup.prototype.onMouseKeyUp = function ( e ) {
	// Only close toolgroup when a tool was actually selected
	if (
		!this.isDisabled() && this.pressed && this.pressed === this.getTargetTool( e ) &&
		( e.which === 1 || e.which === OO.ui.Keys.SPACE || e.which === OO.ui.Keys.ENTER )
	) {
		this.setActive( false );
	}
	return OO.ui.PopupToolGroup.parent.prototype.onMouseKeyUp.call( this, e );
};

/**
 * Handle mouse up and key up events.
 *
 * @protected
 * @param {jQuery.Event} e Mouse up or key up event
 */
OO.ui.PopupToolGroup.prototype.onHandleMouseKeyUp = function ( e ) {
	if (
		!this.isDisabled() &&
		( e.which === 1 || e.which === OO.ui.Keys.SPACE || e.which === OO.ui.Keys.ENTER )
	) {
		return false;
	}
};

/**
 * Handle mouse down and key down events.
 *
 * @protected
 * @param {jQuery.Event} e Mouse down or key down event
 */
OO.ui.PopupToolGroup.prototype.onHandleMouseKeyDown = function ( e ) {
	if (
		!this.isDisabled() &&
		( e.which === 1 || e.which === OO.ui.Keys.SPACE || e.which === OO.ui.Keys.ENTER )
	) {
		this.setActive( !this.active );
		return false;
	}
};

/**
 * Switch into 'active' mode.
 *
 * When active, the popup is visible. A mouseup event anywhere in the document will trigger
 * deactivation.
 */
OO.ui.PopupToolGroup.prototype.setActive = function ( value ) {
	var containerWidth, containerLeft;
	value = !!value;
	if ( this.active !== value ) {
		this.active = value;
		if ( value ) {
			OO.ui.addCaptureEventListener( this.getElementDocument(), 'mouseup', this.onBlurHandler );
			OO.ui.addCaptureEventListener( this.getElementDocument(), 'keyup', this.onBlurHandler );

			this.$clippable.css( 'left', '' );
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
			if ( this.isClippedHorizontally() ) {
				// Anchoring to the right also caused the popup to clip, so just make it fill the container
				containerWidth = this.$clippableContainer.width();
				containerLeft = this.$clippableContainer.offset().left;

				this.toggleClipping( false );
				this.$element.removeClass( 'oo-ui-popupToolGroup-right' );

				this.$clippable.css( {
					left: -( this.$element.offset().left - containerLeft ),
					width: containerWidth
				} );
			}
		} else {
			OO.ui.removeCaptureEventListener( this.getElementDocument(), 'mouseup', this.onBlurHandler );
			OO.ui.removeCaptureEventListener( this.getElementDocument(), 'keyup', this.onBlurHandler );
			this.$element.removeClass(
				'oo-ui-popupToolGroup-active oo-ui-popupToolGroup-left  oo-ui-popupToolGroup-right'
			);
			this.toggleClipping( false );
		}
	}
};

/**
 * ListToolGroups are one of three types of {@link OO.ui.ToolGroup toolgroups} that are used to
 * create {@link OO.ui.Toolbar toolbars} (the other types of groups are {@link OO.ui.MenuToolGroup MenuToolGroup}
 * and {@link OO.ui.BarToolGroup BarToolGroup}). The {@link OO.ui.Tool tools} in a ListToolGroup are displayed
 * by label in a dropdown menu. The title of the tool is used as the label text. The menu itself can be configured
 * with a label, icon, indicator, header, and title.
 *
 * ListToolGroups can be configured to be expanded and collapsed. Collapsed lists will have a ‘More’ option that
 * users can select to see the full list of tools. If a collapsed toolgroup is expanded, a ‘Fewer’ option permits
 * users to collapse the list again.
 *
 * ListToolGroups are created by a {@link OO.ui.ToolGroupFactory toolgroup factory} when the toolbar is set up. The factory
 * requires the ListToolGroup's symbolic name, 'list', which is specified along with the other configurations. For more
 * information about how to add tools to a ListToolGroup, please see {@link OO.ui.ToolGroup toolgroup}.
 *
 *     @example
 *     // Example of a ListToolGroup
 *     var toolFactory = new OO.ui.ToolFactory();
 *     var toolGroupFactory = new OO.ui.ToolGroupFactory();
 *     var toolbar = new OO.ui.Toolbar( toolFactory, toolGroupFactory );
 *
 *     // Configure and register two tools
 *     function SettingsTool() {
 *         SettingsTool.parent.apply( this, arguments );
 *     }
 *     OO.inheritClass( SettingsTool, OO.ui.Tool );
 *     SettingsTool.static.name = 'settings';
 *     SettingsTool.static.icon = 'settings';
 *     SettingsTool.static.title = 'Change settings';
 *     SettingsTool.prototype.onSelect = function () {
 *         this.setActive( false );
 *     };
 *     toolFactory.register( SettingsTool );
 *     // Register two more tools, nothing interesting here
 *     function StuffTool() {
 *         StuffTool.parent.apply( this, arguments );
 *     }
 *     OO.inheritClass( StuffTool, OO.ui.Tool );
 *     StuffTool.static.name = 'stuff';
 *     StuffTool.static.icon = 'ellipsis';
 *     StuffTool.static.title = 'Change the world';
 *     StuffTool.prototype.onSelect = function () {
 *         this.setActive( false );
 *     };
 *     toolFactory.register( StuffTool );
 *     toolbar.setup( [
 *         {
 *             // Configurations for list toolgroup.
 *             type: 'list',
 *             label: 'ListToolGroup',
 *             indicator: 'down',
 *             icon: 'picture',
 *             title: 'This is the title, displayed when user moves the mouse over the list toolgroup',
 *             header: 'This is the header',
 *             include: [ 'settings', 'stuff' ],
 *             allowCollapse: ['stuff']
 *         }
 *     ] );
 *
 *     // Create some UI around the toolbar and place it in the document
 *     var frame = new OO.ui.PanelLayout( {
 *         expanded: false,
 *         framed: true
 *     } );
 *     frame.$element.append(
 *         toolbar.$element
 *     );
 *     $( 'body' ).append( frame.$element );
 *     // Build the toolbar. This must be done after the toolbar has been appended to the document.
 *     toolbar.initialize();
 *
 * For more information about toolbars in general, please see the [OOjs UI documentation on MediaWiki][1].
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Toolbars
 *
 * @class
 * @extends OO.ui.PopupToolGroup
 *
 * @constructor
 * @param {OO.ui.Toolbar} toolbar
 * @param {Object} [config] Configuration options
 * @cfg {Array} [allowCollapse] Allow the specified tools to be collapsed. By default, collapsible tools
 *  will only be displayed if users click the ‘More’ option displayed at the bottom of the list. If
 *  the list is expanded, a ‘Fewer’ option permits users to collapse the list again. Any tools that
 *  are included in the toolgroup, but are not designated as collapsible, will always be displayed.
 *  To open a collapsible list in its expanded state, set #expanded to 'true'.
 * @cfg {Array} [forceExpand] Expand the specified tools. All other tools will be designated as collapsible.
 *  Unless #expanded is set to true, the collapsible tools will be collapsed when the list is first opened.
 * @cfg {boolean} [expanded=false] Expand collapsible tools. This config is only relevant if tools have
 *  been designated as collapsible. When expanded is set to true, all tools in the group will be displayed
 *  when the list is first opened. Users can collapse the list with a ‘Fewer’ option at the bottom.
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
	OO.ui.ListToolGroup.parent.call( this, toolbar, config );

	// Initialization
	this.$element.addClass( 'oo-ui-listToolGroup' );
};

/* Setup */

OO.inheritClass( OO.ui.ListToolGroup, OO.ui.PopupToolGroup );

/* Static Properties */

OO.ui.ListToolGroup.static.name = 'list';

/* Methods */

/**
 * @inheritdoc
 */
OO.ui.ListToolGroup.prototype.populate = function () {
	var i, len, allowCollapse = [];

	OO.ui.ListToolGroup.parent.prototype.populate.call( this );

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
	var ExpandCollapseTool;
	if ( this.expandCollapseTool === undefined ) {
		ExpandCollapseTool = function () {
			ExpandCollapseTool.parent.apply( this, arguments );
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
OO.ui.ListToolGroup.prototype.onMouseKeyUp = function ( e ) {
	// Do not close the popup when the user wants to show more/fewer tools
	if (
		$( e.target ).closest( '.oo-ui-tool-name-more-fewer' ).length &&
		( e.which === 1 || e.which === OO.ui.Keys.SPACE || e.which === OO.ui.Keys.ENTER )
	) {
		// HACK: Prevent the popup list from being hidden. Skip the PopupToolGroup implementation (which
		// hides the popup list when a tool is selected) and call ToolGroup's implementation directly.
		return OO.ui.ListToolGroup.parent.parent.prototype.onMouseKeyUp.call( this, e );
	} else {
		return OO.ui.ListToolGroup.parent.prototype.onMouseKeyUp.call( this, e );
	}
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
 * MenuToolGroups are one of three types of {@link OO.ui.ToolGroup toolgroups} that are used to
 * create {@link OO.ui.Toolbar toolbars} (the other types of groups are {@link OO.ui.BarToolGroup BarToolGroup}
 * and {@link OO.ui.ListToolGroup ListToolGroup}). MenuToolGroups contain selectable {@link OO.ui.Tool tools},
 * which are displayed by label in a dropdown menu. The tool's title is used as the label text, and the
 * menu label is updated to reflect which tool or tools are currently selected. If no tools are selected,
 * the menu label is empty. The menu can be configured with an indicator, icon, title, and/or header.
 *
 * MenuToolGroups are created by a {@link OO.ui.ToolGroupFactory tool group factory} when the toolbar
 * is set up. Note that all tools must define an {@link OO.ui.Tool#onUpdateState onUpdateState} method if
 * a MenuToolGroup is used.
 *
 *     @example
 *     // Example of a MenuToolGroup
 *     var toolFactory = new OO.ui.ToolFactory();
 *     var toolGroupFactory = new OO.ui.ToolGroupFactory();
 *     var toolbar = new OO.ui.Toolbar( toolFactory, toolGroupFactory );
 *
 *     // We will be placing status text in this element when tools are used
 *     var $area = $( '<p>' ).text( 'An example of a MenuToolGroup. Select a tool from the dropdown menu.' );
 *
 *     // Define the tools that we're going to place in our toolbar
 *
 *     function SettingsTool() {
 *         SettingsTool.parent.apply( this, arguments );
 *         this.reallyActive = false;
 *     }
 *     OO.inheritClass( SettingsTool, OO.ui.Tool );
 *     SettingsTool.static.name = 'settings';
 *     SettingsTool.static.icon = 'settings';
 *     SettingsTool.static.title = 'Change settings';
 *     SettingsTool.prototype.onSelect = function () {
 *         $area.text( 'Settings tool clicked!' );
 *         // Toggle the active state on each click
 *         this.reallyActive = !this.reallyActive;
 *         this.setActive( this.reallyActive );
 *         // To update the menu label
 *         this.toolbar.emit( 'updateState' );
 *     };
 *     SettingsTool.prototype.onUpdateState = function () {
 *     };
 *     toolFactory.register( SettingsTool );
 *
 *     function StuffTool() {
 *         StuffTool.parent.apply( this, arguments );
 *         this.reallyActive = false;
 *     }
 *     OO.inheritClass( StuffTool, OO.ui.Tool );
 *     StuffTool.static.name = 'stuff';
 *     StuffTool.static.icon = 'ellipsis';
 *     StuffTool.static.title = 'More stuff';
 *     StuffTool.prototype.onSelect = function () {
 *         $area.text( 'More stuff tool clicked!' );
 *         // Toggle the active state on each click
 *         this.reallyActive = !this.reallyActive;
 *         this.setActive( this.reallyActive );
 *         // To update the menu label
 *         this.toolbar.emit( 'updateState' );
 *     };
 *     StuffTool.prototype.onUpdateState = function () {
 *     };
 *     toolFactory.register( StuffTool );
 *
 *     // Finally define which tools and in what order appear in the toolbar. Each tool may only be
 *     // used once (but not all defined tools must be used).
 *     toolbar.setup( [
 *         {
 *             type: 'menu',
 *             header: 'This is the (optional) header',
 *             title: 'This is the (optional) title',
 *             indicator: 'down',
 *             include: [ 'settings', 'stuff' ]
 *         }
 *     ] );
 *
 *     // Create some UI around the toolbar and place it in the document
 *     var frame = new OO.ui.PanelLayout( {
 *         expanded: false,
 *         framed: true
 *     } );
 *     var contentFrame = new OO.ui.PanelLayout( {
 *         expanded: false,
 *         padded: true
 *     } );
 *     frame.$element.append(
 *         toolbar.$element,
 *         contentFrame.$element.append( $area )
 *     );
 *     $( 'body' ).append( frame.$element );
 *
 *     // Here is where the toolbar is actually built. This must be done after inserting it into the
 *     // document.
 *     toolbar.initialize();
 *     toolbar.emit( 'updateState' );
 *
 * For more information about how to add tools to a MenuToolGroup, please see {@link OO.ui.ToolGroup toolgroup}.
 * For more information about toolbars in general, please see the [OOjs UI documentation on MediaWiki] [1].
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Toolbars
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
	OO.ui.MenuToolGroup.parent.call( this, toolbar, config );

	// Events
	this.toolbar.connect( this, { updateState: 'onUpdateState' } );

	// Initialization
	this.$element.addClass( 'oo-ui-menuToolGroup' );
};

/* Setup */

OO.inheritClass( OO.ui.MenuToolGroup, OO.ui.PopupToolGroup );

/* Static Properties */

OO.ui.MenuToolGroup.static.name = 'menu';

/* Methods */

/**
 * Handle the toolbar state being updated.
 *
 * When the state changes, the title of each active item in the menu will be joined together and
 * used as a label for the group. The label will be empty if none of the items are active.
 *
 * @private
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
 * Popup tools open a popup window when they are selected from the {@link OO.ui.Toolbar toolbar}. Each popup tool is configured
 * with a static name, title, and icon, as well with as any popup configurations. Unlike other tools, popup tools do not require that developers specify
 * an #onSelect or #onUpdateState method, as these methods have been implemented already.
 *
 *     // Example of a popup tool. When selected, a popup tool displays
 *     // a popup window.
 *     function HelpTool( toolGroup, config ) {
 *        OO.ui.PopupTool.call( this, toolGroup, $.extend( { popup: {
 *            padded: true,
 *            label: 'Help',
 *            head: true
 *        } }, config ) );
 *        this.popup.$body.append( '<p>I am helpful!</p>' );
 *     };
 *     OO.inheritClass( HelpTool, OO.ui.PopupTool );
 *     HelpTool.static.name = 'help';
 *     HelpTool.static.icon = 'help';
 *     HelpTool.static.title = 'Help';
 *     toolFactory.register( HelpTool );
 *
 * For an example of a toolbar that contains a popup tool, see {@link OO.ui.Toolbar toolbars}. For more information about
 * toolbars in genreral, please see the [OOjs UI documentation on MediaWiki][1].
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Toolbars
 *
 * @abstract
 * @class
 * @extends OO.ui.Tool
 * @mixins OO.ui.mixin.PopupElement
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
	OO.ui.PopupTool.parent.call( this, toolGroup, config );

	// Mixin constructors
	OO.ui.mixin.PopupElement.call( this, config );

	// Initialization
	this.$element
		.addClass( 'oo-ui-popupTool' )
		.append( this.popup.$element );
};

/* Setup */

OO.inheritClass( OO.ui.PopupTool, OO.ui.Tool );
OO.mixinClass( OO.ui.PopupTool, OO.ui.mixin.PopupElement );

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
 * A ToolGroupTool is a special sort of tool that can contain other {@link OO.ui.Tool tools}
 * and {@link OO.ui.ToolGroup toolgroups}. The ToolGroupTool was specifically designed to be used
 * inside a {@link OO.ui.BarToolGroup bar} toolgroup to provide access to additional tools from
 * the bar item. Included tools will be displayed in a dropdown {@link OO.ui.ListToolGroup list}
 * when the ToolGroupTool is selected.
 *
 *     // Example: ToolGroupTool with two nested tools, 'setting1' and 'setting2', defined elsewhere.
 *
 *     function SettingsTool() {
 *         SettingsTool.parent.apply( this, arguments );
 *     };
 *     OO.inheritClass( SettingsTool, OO.ui.ToolGroupTool );
 *     SettingsTool.static.name = 'settings';
 *     SettingsTool.static.title = 'Change settings';
 *     SettingsTool.static.groupConfig = {
 *         icon: 'settings',
 *         label: 'ToolGroupTool',
 *         include: [  'setting1', 'setting2'  ]
 *     };
 *     toolFactory.register( SettingsTool );
 *
 * For more information, please see the [OOjs UI documentation on MediaWiki][1].
 *
 * Please note that this implementation is subject to change per [T74159] [2].
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Toolbars#ToolGroupTool
 * [2]: https://phabricator.wikimedia.org/T74159
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
	OO.ui.ToolGroupTool.parent.call( this, toolGroup, config );

	// Properties
	this.innerToolGroup = this.createGroup( this.constructor.static.groupConfig );

	// Events
	this.innerToolGroup.connect( this, { disable: 'onToolGroupDisable' } );

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
 * Toolgroup configuration.
 *
 * The toolgroup configuration consists of the tools to include, as well as an icon and label
 * to use for the bar item. Tools can be included by symbolic name, group, or with the
 * wildcard selector. Please see {@link OO.ui.ToolGroup toolgroup} for more information.
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
 * Synchronize disabledness state of the tool with the inner toolgroup.
 *
 * @private
 * @param {boolean} disabled Element is disabled
 */
OO.ui.ToolGroupTool.prototype.onToolGroupDisable = function ( disabled ) {
	this.setDisabled( disabled );
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
 * Build a {@link OO.ui.ToolGroup toolgroup} from the specified configuration.
 *
 * @param {Object.<string,Array>} group Toolgroup configuration. Please see {@link OO.ui.ToolGroup toolgroup} for
 *  more information.
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
 * Mixin for OO.ui.Widget subclasses to provide OO.ui.mixin.GroupElement.
 *
 * Use together with OO.ui.mixin.ItemWidget to make disabled state inheritable.
 *
 * @private
 * @abstract
 * @class
 * @extends OO.ui.mixin.GroupElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
OO.ui.mixin.GroupWidget = function OoUiMixinGroupWidget( config ) {
	// Parent constructor
	OO.ui.mixin.GroupWidget.parent.call( this, config );
};

/* Setup */

OO.inheritClass( OO.ui.mixin.GroupWidget, OO.ui.mixin.GroupElement );

/* Methods */

/**
 * Set the disabled state of the widget.
 *
 * This will also update the disabled state of child widgets.
 *
 * @param {boolean} disabled Disable widget
 * @chainable
 */
OO.ui.mixin.GroupWidget.prototype.setDisabled = function ( disabled ) {
	var i, len;

	// Parent method
	// Note: Calling #setDisabled this way assumes this is mixed into an OO.ui.Widget
	OO.ui.Widget.prototype.setDisabled.call( this, disabled );

	// During construction, #setDisabled is called before the OO.ui.mixin.GroupElement constructor
	if ( this.items ) {
		for ( i = 0, len = this.items.length; i < len; i++ ) {
			this.items[ i ].updateDisabled();
		}
	}

	return this;
};

/**
 * Mixin for widgets used as items in widgets that mix in OO.ui.mixin.GroupWidget.
 *
 * Item widgets have a reference to a OO.ui.mixin.GroupWidget while they are attached to the group. This
 * allows bidirectional communication.
 *
 * Use together with OO.ui.mixin.GroupWidget to make disabled state inheritable.
 *
 * @private
 * @abstract
 * @class
 *
 * @constructor
 */
OO.ui.mixin.ItemWidget = function OoUiMixinItemWidget() {
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
OO.ui.mixin.ItemWidget.prototype.isDisabled = function () {
	return this.disabled ||
		( this.elementGroup instanceof OO.ui.Widget && this.elementGroup.isDisabled() );
};

/**
 * Set group element is in.
 *
 * @param {OO.ui.mixin.GroupElement|null} group Group element, null if none
 * @chainable
 */
OO.ui.mixin.ItemWidget.prototype.setElementGroup = function ( group ) {
	// Parent method
	// Note: Calling #setElementGroup this way assumes this is mixed into an OO.ui.Element
	OO.ui.Element.prototype.setElementGroup.call( this, group );

	// Initialize item disabled states
	this.updateDisabled();

	return this;
};

/**
 * OutlineControlsWidget is a set of controls for an {@link OO.ui.OutlineSelectWidget outline select widget}.
 * Controls include moving items up and down, removing items, and adding different kinds of items.
 *
 * **Currently, this class is only used by {@link OO.ui.BookletLayout booklet layouts}.**
 *
 * @class
 * @extends OO.ui.Widget
 * @mixins OO.ui.mixin.GroupElement
 * @mixins OO.ui.mixin.IconElement
 *
 * @constructor
 * @param {OO.ui.OutlineSelectWidget} outline Outline to control
 * @param {Object} [config] Configuration options
 * @cfg {Object} [abilities] List of abilties
 * @cfg {boolean} [abilities.move=true] Allow moving movable items
 * @cfg {boolean} [abilities.remove=true] Allow removing removable items
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
	OO.ui.OutlineControlsWidget.parent.call( this, config );

	// Mixin constructors
	OO.ui.mixin.GroupElement.call( this, config );
	OO.ui.mixin.IconElement.call( this, config );

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
	this.abilities = { move: true, remove: true };

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
	this.setAbilities( config.abilities || {} );
};

/* Setup */

OO.inheritClass( OO.ui.OutlineControlsWidget, OO.ui.Widget );
OO.mixinClass( OO.ui.OutlineControlsWidget, OO.ui.mixin.GroupElement );
OO.mixinClass( OO.ui.OutlineControlsWidget, OO.ui.mixin.IconElement );

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
 * Set abilities.
 *
 * @param {Object} abilities List of abilties
 * @param {boolean} [abilities.move] Allow moving movable items
 * @param {boolean} [abilities.remove] Allow removing removable items
 */
OO.ui.OutlineControlsWidget.prototype.setAbilities = function ( abilities ) {
	var ability;

	for ( ability in this.abilities ) {
		if ( abilities[ ability ] !== undefined ) {
			this.abilities[ ability ] = !!abilities[ ability ];
		}
	}

	this.onOutlineChange();
};

/**
 *
 * @private
 * Handle outline change events.
 */
OO.ui.OutlineControlsWidget.prototype.onOutlineChange = function () {
	var i, len, firstMovable, lastMovable,
		items = this.outline.getItems(),
		selectedItem = this.outline.getSelectedItem(),
		movable = this.abilities.move && selectedItem && selectedItem.isMovable(),
		removable = this.abilities.remove && selectedItem && selectedItem.isRemovable();

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
 * ToggleWidget implements basic behavior of widgets with an on/off state.
 * Please see OO.ui.ToggleButtonWidget and OO.ui.ToggleSwitchWidget for examples.
 *
 * @abstract
 * @class
 * @extends OO.ui.Widget
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {boolean} [value=false] The toggle’s initial on/off state.
 *  By default, the toggle is in the 'off' state.
 */
OO.ui.ToggleWidget = function OoUiToggleWidget( config ) {
	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.ToggleWidget.parent.call( this, config );

	// Properties
	this.value = null;

	// Initialization
	this.$element.addClass( 'oo-ui-toggleWidget' );
	this.setValue( !!config.value );
};

/* Setup */

OO.inheritClass( OO.ui.ToggleWidget, OO.ui.Widget );

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
 *         label: 'Select a category',
 *         icon: 'menu',
 *         popup: {
 *             $content: $( '<p>List of categories...</p>' ),
 *             padded: true,
 *             align: 'left'
 *         }
 *     } );
 *     var button2 = new OO.ui.ButtonWidget( {
 *         label: 'Add item'
 *     });
 *     var buttonGroup = new OO.ui.ButtonGroupWidget( {
 *         items: [button1, button2]
 *     } );
 *     $( 'body' ).append( buttonGroup.$element );
 *
 * @class
 * @extends OO.ui.Widget
 * @mixins OO.ui.mixin.GroupElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {OO.ui.ButtonWidget[]} [items] Buttons to add
 */
OO.ui.ButtonGroupWidget = function OoUiButtonGroupWidget( config ) {
	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.ButtonGroupWidget.parent.call( this, config );

	// Mixin constructors
	OO.ui.mixin.GroupElement.call( this, $.extend( {}, config, { $group: this.$element } ) );

	// Initialization
	this.$element.addClass( 'oo-ui-buttonGroupWidget' );
	if ( Array.isArray( config.items ) ) {
		this.addItems( config.items );
	}
};

/* Setup */

OO.inheritClass( OO.ui.ButtonGroupWidget, OO.ui.Widget );
OO.mixinClass( OO.ui.ButtonGroupWidget, OO.ui.mixin.GroupElement );

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
 *         label: 'Button with Icon',
 *         icon: 'remove',
 *         iconTitle: 'Remove'
 *     } );
 *     $( 'body' ).append( button.$element );
 *
 * NOTE: HTML form buttons should use the OO.ui.ButtonInputWidget class.
 *
 * @class
 * @extends OO.ui.Widget
 * @mixins OO.ui.mixin.ButtonElement
 * @mixins OO.ui.mixin.IconElement
 * @mixins OO.ui.mixin.IndicatorElement
 * @mixins OO.ui.mixin.LabelElement
 * @mixins OO.ui.mixin.TitledElement
 * @mixins OO.ui.mixin.FlaggedElement
 * @mixins OO.ui.mixin.TabIndexedElement
 * @mixins OO.ui.mixin.AccessKeyedElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {string} [href] Hyperlink to visit when the button is clicked.
 * @cfg {string} [target] The frame or window in which to open the hyperlink.
 * @cfg {boolean} [noFollow] Search engine traversal hint (default: true)
 */
OO.ui.ButtonWidget = function OoUiButtonWidget( config ) {
	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.ButtonWidget.parent.call( this, config );

	// Mixin constructors
	OO.ui.mixin.ButtonElement.call( this, config );
	OO.ui.mixin.IconElement.call( this, config );
	OO.ui.mixin.IndicatorElement.call( this, config );
	OO.ui.mixin.LabelElement.call( this, config );
	OO.ui.mixin.TitledElement.call( this, $.extend( {}, config, { $titled: this.$button } ) );
	OO.ui.mixin.FlaggedElement.call( this, config );
	OO.ui.mixin.TabIndexedElement.call( this, $.extend( {}, config, { $tabIndexed: this.$button } ) );
	OO.ui.mixin.AccessKeyedElement.call( this, $.extend( {}, config, { $accessKeyed: this.$button } ) );

	// Properties
	this.href = null;
	this.target = null;
	this.noFollow = false;

	// Events
	this.connect( this, { disable: 'onDisable' } );

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
OO.mixinClass( OO.ui.ButtonWidget, OO.ui.mixin.ButtonElement );
OO.mixinClass( OO.ui.ButtonWidget, OO.ui.mixin.IconElement );
OO.mixinClass( OO.ui.ButtonWidget, OO.ui.mixin.IndicatorElement );
OO.mixinClass( OO.ui.ButtonWidget, OO.ui.mixin.LabelElement );
OO.mixinClass( OO.ui.ButtonWidget, OO.ui.mixin.TitledElement );
OO.mixinClass( OO.ui.ButtonWidget, OO.ui.mixin.FlaggedElement );
OO.mixinClass( OO.ui.ButtonWidget, OO.ui.mixin.TabIndexedElement );
OO.mixinClass( OO.ui.ButtonWidget, OO.ui.mixin.AccessKeyedElement );

/* Methods */

/**
 * @inheritdoc
 */
OO.ui.ButtonWidget.prototype.onMouseDown = function ( e ) {
	if ( !this.isDisabled() ) {
		// Remove the tab-index while the button is down to prevent the button from stealing focus
		this.$button.removeAttr( 'tabindex' );
	}

	return OO.ui.mixin.ButtonElement.prototype.onMouseDown.call( this, e );
};

/**
 * @inheritdoc
 */
OO.ui.ButtonWidget.prototype.onMouseUp = function ( e ) {
	if ( !this.isDisabled() ) {
		// Restore the tab-index after the button is up to restore the button's accessibility
		this.$button.attr( 'tabindex', this.tabIndex );
	}

	return OO.ui.mixin.ButtonElement.prototype.onMouseUp.call( this, e );
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
	if ( href !== null ) {
		if ( !OO.ui.isSafeUrl( href ) ) {
			throw new Error( 'Potentially unsafe href provided: ' + href );
		}

	}

	if ( href !== this.href ) {
		this.href = href;
		this.updateHref();
	}

	return this;
};

/**
 * Update the `href` attribute, in case of changes to href or
 * disabled state.
 *
 * @private
 * @chainable
 */
OO.ui.ButtonWidget.prototype.updateHref = function () {
	if ( this.href !== null && !this.isDisabled() ) {
		this.$button.attr( 'href', this.href );
	} else {
		this.$button.removeAttr( 'href' );
	}

	return this;
};

/**
 * Handle disable events.
 *
 * @private
 * @param {boolean} disabled Element is disabled
 */
OO.ui.ButtonWidget.prototype.onDisable = function () {
	this.updateHref();
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
 * of the actions.
 *
 * Both actions and action sets are primarily used with {@link OO.ui.Dialog Dialogs}.
 * Please see the [OOjs UI documentation on MediaWiki] [1] for more information
 * and examples.
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Windows/Process_Dialogs#Action_sets
 *
 * @class
 * @extends OO.ui.ButtonWidget
 * @mixins OO.ui.mixin.PendingElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {string} [action] Symbolic name of the action (e.g., ‘continue’ or ‘cancel’).
 * @cfg {string[]} [modes] Symbolic names of the modes (e.g., ‘edit’ or ‘read’) in which the action
 *  should be made available. See the action set's {@link OO.ui.ActionSet#setMode setMode} method
 *  for more information about setting modes.
 * @cfg {boolean} [framed=false] Render the action button with a frame
 */
OO.ui.ActionWidget = function OoUiActionWidget( config ) {
	// Configuration initialization
	config = $.extend( { framed: false }, config );

	// Parent constructor
	OO.ui.ActionWidget.parent.call( this, config );

	// Mixin constructors
	OO.ui.mixin.PendingElement.call( this, config );

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
OO.mixinClass( OO.ui.ActionWidget, OO.ui.mixin.PendingElement );

/* Events */

/**
 * A resize event is emitted when the size of the widget changes.
 *
 * @event resize
 */

/* Methods */

/**
 * Check if the action is configured to be available in the specified `mode`.
 *
 * @param {string} mode Name of mode
 * @return {boolean} The action is configured with the mode
 */
OO.ui.ActionWidget.prototype.hasMode = function ( mode ) {
	return this.modes.indexOf( mode ) !== -1;
};

/**
 * Get the symbolic name of the action (e.g., ‘continue’ or ‘cancel’).
 *
 * @return {string}
 */
OO.ui.ActionWidget.prototype.getAction = function () {
	return this.action;
};

/**
 * Get the symbolic name of the mode or modes for which the action is configured to be available.
 *
 * The current mode is set with the action set's {@link OO.ui.ActionSet#setMode setMode} method.
 * Only actions that are configured to be avaiable in the current mode will be visible. All other actions
 * are hidden.
 *
 * @return {string[]}
 */
OO.ui.ActionWidget.prototype.getModes = function () {
	return this.modes.slice();
};

/**
 * Emit a resize event if the size has changed.
 *
 * @private
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
	OO.ui.mixin.IconElement.prototype.setIcon.apply( this, arguments );
	this.propagateResize();

	return this;
};

/**
 * @inheritdoc
 */
OO.ui.ActionWidget.prototype.setLabel = function () {
	// Mixin method
	OO.ui.mixin.LabelElement.prototype.setLabel.apply( this, arguments );
	this.propagateResize();

	return this;
};

/**
 * @inheritdoc
 */
OO.ui.ActionWidget.prototype.setFlags = function () {
	// Mixin method
	OO.ui.mixin.FlaggedElement.prototype.setFlags.apply( this, arguments );
	this.propagateResize();

	return this;
};

/**
 * @inheritdoc
 */
OO.ui.ActionWidget.prototype.clearFlags = function () {
	// Mixin method
	OO.ui.mixin.FlaggedElement.prototype.clearFlags.apply( this, arguments );
	this.propagateResize();

	return this;
};

/**
 * Toggle the visibility of the action button.
 *
 * @param {boolean} [show] Show button, omit to toggle visibility
 * @chainable
 */
OO.ui.ActionWidget.prototype.toggle = function () {
	// Parent method
	OO.ui.ActionWidget.parent.prototype.toggle.apply( this, arguments );
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
 *             align: 'force-left'
 *         }
 *     } );
 *     // Append the button to the DOM.
 *     $( 'body' ).append( popupButton.$element );
 *
 * @class
 * @extends OO.ui.ButtonWidget
 * @mixins OO.ui.mixin.PopupElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
OO.ui.PopupButtonWidget = function OoUiPopupButtonWidget( config ) {
	// Parent constructor
	OO.ui.PopupButtonWidget.parent.call( this, config );

	// Mixin constructors
	OO.ui.mixin.PopupElement.call( this, config );

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
OO.mixinClass( OO.ui.PopupButtonWidget, OO.ui.mixin.PopupElement );

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
 * configured with {@link OO.ui.mixin.IconElement icons}, {@link OO.ui.mixin.IndicatorElement indicators},
 * {@link OO.ui.mixin.TitledElement titles}, {@link OO.ui.mixin.FlaggedElement styling flags},
 * and {@link OO.ui.mixin.LabelElement labels}. Please see
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
 * @extends OO.ui.ToggleWidget
 * @mixins OO.ui.mixin.ButtonElement
 * @mixins OO.ui.mixin.IconElement
 * @mixins OO.ui.mixin.IndicatorElement
 * @mixins OO.ui.mixin.LabelElement
 * @mixins OO.ui.mixin.TitledElement
 * @mixins OO.ui.mixin.FlaggedElement
 * @mixins OO.ui.mixin.TabIndexedElement
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
	OO.ui.ToggleButtonWidget.parent.call( this, config );

	// Mixin constructors
	OO.ui.mixin.ButtonElement.call( this, config );
	OO.ui.mixin.IconElement.call( this, config );
	OO.ui.mixin.IndicatorElement.call( this, config );
	OO.ui.mixin.LabelElement.call( this, config );
	OO.ui.mixin.TitledElement.call( this, $.extend( {}, config, { $titled: this.$button } ) );
	OO.ui.mixin.FlaggedElement.call( this, config );
	OO.ui.mixin.TabIndexedElement.call( this, $.extend( {}, config, { $tabIndexed: this.$button } ) );

	// Events
	this.connect( this, { click: 'onAction' } );

	// Initialization
	this.$button.append( this.$icon, this.$label, this.$indicator );
	this.$element
		.addClass( 'oo-ui-toggleButtonWidget' )
		.append( this.$button );
};

/* Setup */

OO.inheritClass( OO.ui.ToggleButtonWidget, OO.ui.ToggleWidget );
OO.mixinClass( OO.ui.ToggleButtonWidget, OO.ui.mixin.ButtonElement );
OO.mixinClass( OO.ui.ToggleButtonWidget, OO.ui.mixin.IconElement );
OO.mixinClass( OO.ui.ToggleButtonWidget, OO.ui.mixin.IndicatorElement );
OO.mixinClass( OO.ui.ToggleButtonWidget, OO.ui.mixin.LabelElement );
OO.mixinClass( OO.ui.ToggleButtonWidget, OO.ui.mixin.TitledElement );
OO.mixinClass( OO.ui.ToggleButtonWidget, OO.ui.mixin.FlaggedElement );
OO.mixinClass( OO.ui.ToggleButtonWidget, OO.ui.mixin.TabIndexedElement );

/* Methods */

/**
 * Handle the button action being triggered.
 *
 * @private
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
		// Might be called from parent constructor before ButtonElement constructor
		if ( this.$button ) {
			this.$button.attr( 'aria-pressed', value.toString() );
		}
		this.setActive( value );
	}

	// Parent method
	OO.ui.ToggleButtonWidget.parent.prototype.setValue.call( this, value );

	return this;
};

/**
 * @inheritdoc
 */
OO.ui.ToggleButtonWidget.prototype.setButtonElement = function ( $button ) {
	if ( this.$button ) {
		this.$button.removeAttr( 'aria-pressed' );
	}
	OO.ui.mixin.ButtonElement.prototype.setButtonElement.call( this, $button );
	this.$button.attr( 'aria-pressed', this.value.toString() );
};

/**
 * CapsuleMultiSelectWidgets are something like a {@link OO.ui.ComboBoxWidget combo box widget}
 * that allows for selecting multiple values.
 *
 * For more information about menus and options, please see the [OOjs UI documentation on MediaWiki][1].
 *
 *     @example
 *     // Example: A CapsuleMultiSelectWidget.
 *     var capsule = new OO.ui.CapsuleMultiSelectWidget( {
 *         label: 'CapsuleMultiSelectWidget',
 *         selected: [ 'Option 1', 'Option 3' ],
 *         menu: {
 *             items: [
 *                 new OO.ui.MenuOptionWidget( {
 *                     data: 'Option 1',
 *                     label: 'Option One'
 *                 } ),
 *                 new OO.ui.MenuOptionWidget( {
 *                     data: 'Option 2',
 *                     label: 'Option Two'
 *                 } ),
 *                 new OO.ui.MenuOptionWidget( {
 *                     data: 'Option 3',
 *                     label: 'Option Three'
 *                 } ),
 *                 new OO.ui.MenuOptionWidget( {
 *                     data: 'Option 4',
 *                     label: 'Option Four'
 *                 } ),
 *                 new OO.ui.MenuOptionWidget( {
 *                     data: 'Option 5',
 *                     label: 'Option Five'
 *                 } )
 *             ]
 *         }
 *     } );
 *     $( 'body' ).append( capsule.$element );
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Selects_and_Options#Menu_selects_and_options
 *
 * @class
 * @extends OO.ui.Widget
 * @mixins OO.ui.mixin.TabIndexedElement
 * @mixins OO.ui.mixin.GroupElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {boolean} [allowArbitrary=false] Allow data items to be added even if not present in the menu.
 * @cfg {Object} [menu] Configuration options to pass to the {@link OO.ui.MenuSelectWidget menu select widget}.
 * @cfg {Object} [popup] Configuration options to pass to the {@link OO.ui.PopupWidget popup widget}.
 *  If specified, this popup will be shown instead of the menu (but the menu
 *  will still be used for item labels and allowArbitrary=false). The widgets
 *  in the popup should use this.addItemsFromData() or this.addItems() as necessary.
 * @cfg {jQuery} [$overlay] Render the menu or popup into a separate layer.
 *  This configuration is useful in cases where the expanded menu is larger than
 *  its containing `<div>`. The specified overlay layer is usually on top of
 *  the containing `<div>` and has a larger area. By default, the menu uses
 *  relative positioning.
 */
OO.ui.CapsuleMultiSelectWidget = function OoUiCapsuleMultiSelectWidget( config ) {
	var $tabFocus;

	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.CapsuleMultiSelectWidget.parent.call( this, config );

	// Properties (must be set before mixin constructor calls)
	this.$input = config.popup ? null : $( '<input>' );
	this.$handle = $( '<div>' );

	// Mixin constructors
	OO.ui.mixin.GroupElement.call( this, config );
	if ( config.popup ) {
		config.popup = $.extend( {}, config.popup, {
			align: 'forwards',
			anchor: false
		} );
		OO.ui.mixin.PopupElement.call( this, config );
		$tabFocus = $( '<span>' );
		OO.ui.mixin.TabIndexedElement.call( this, $.extend( {}, config, { $tabIndexed: $tabFocus } ) );
	} else {
		this.popup = null;
		$tabFocus = null;
		OO.ui.mixin.TabIndexedElement.call( this, $.extend( {}, config, { $tabIndexed: this.$input } ) );
	}
	OO.ui.mixin.IndicatorElement.call( this, config );
	OO.ui.mixin.IconElement.call( this, config );

	// Properties
	this.allowArbitrary = !!config.allowArbitrary;
	this.$overlay = config.$overlay || this.$element;
	this.menu = new OO.ui.FloatingMenuSelectWidget( $.extend(
		{
			widget: this,
			$input: this.$input,
			$container: this.$element,
			filterFromInput: true,
			disabled: this.isDisabled()
		},
		config.menu
	) );

	// Events
	if ( this.popup ) {
		$tabFocus.on( {
			focus: this.onFocusForPopup.bind( this )
		} );
		this.popup.$element.on( 'focusout', this.onPopupFocusOut.bind( this ) );
		if ( this.popup.$autoCloseIgnore ) {
			this.popup.$autoCloseIgnore.on( 'focusout', this.onPopupFocusOut.bind( this ) );
		}
		this.popup.connect( this, {
			toggle: function ( visible ) {
				$tabFocus.toggle( !visible );
			}
		} );
	} else {
		this.$input.on( {
			focus: this.onInputFocus.bind( this ),
			blur: this.onInputBlur.bind( this ),
			'propertychange change click mouseup keydown keyup input cut paste select': this.onInputChange.bind( this ),
			keydown: this.onKeyDown.bind( this ),
			keypress: this.onKeyPress.bind( this )
		} );
	}
	this.menu.connect( this, {
		choose: 'onMenuChoose',
		add: 'onMenuItemsChange',
		remove: 'onMenuItemsChange'
	} );
	this.$handle.on( {
		click: this.onClick.bind( this )
	} );

	// Initialization
	if ( this.$input ) {
		this.$input.prop( 'disabled', this.isDisabled() );
		this.$input.attr( {
			role: 'combobox',
			'aria-autocomplete': 'list'
		} );
		this.$input.width( '1em' );
	}
	if ( config.data ) {
		this.setItemsFromData( config.data );
	}
	this.$group.addClass( 'oo-ui-capsuleMultiSelectWidget-group' );
	this.$handle.addClass( 'oo-ui-capsuleMultiSelectWidget-handle' )
		.append( this.$indicator, this.$icon, this.$group );
	this.$element.addClass( 'oo-ui-capsuleMultiSelectWidget' )
		.append( this.$handle );
	if ( this.popup ) {
		this.$handle.append( $tabFocus );
		this.$overlay.append( this.popup.$element );
	} else {
		this.$handle.append( this.$input );
		this.$overlay.append( this.menu.$element );
	}
	this.onMenuItemsChange();
};

/* Setup */

OO.inheritClass( OO.ui.CapsuleMultiSelectWidget, OO.ui.Widget );
OO.mixinClass( OO.ui.CapsuleMultiSelectWidget, OO.ui.mixin.GroupElement );
OO.mixinClass( OO.ui.CapsuleMultiSelectWidget, OO.ui.mixin.PopupElement );
OO.mixinClass( OO.ui.CapsuleMultiSelectWidget, OO.ui.mixin.TabIndexedElement );
OO.mixinClass( OO.ui.CapsuleMultiSelectWidget, OO.ui.mixin.IndicatorElement );
OO.mixinClass( OO.ui.CapsuleMultiSelectWidget, OO.ui.mixin.IconElement );

/* Events */

/**
 * @event change
 *
 * A change event is emitted when the set of selected items changes.
 *
 * @param {Mixed[]} datas Data of the now-selected items
 */

/* Methods */

/**
 * Get the data of the items in the capsule
 * @return {Mixed[]}
 */
OO.ui.CapsuleMultiSelectWidget.prototype.getItemsData = function () {
	return $.map( this.getItems(), function ( e ) { return e.data; } );
};

/**
 * Set the items in the capsule by providing data
 * @chainable
 * @param {Mixed[]} datas
 * @return {OO.ui.CapsuleMultiSelectWidget}
 */
OO.ui.CapsuleMultiSelectWidget.prototype.setItemsFromData = function ( datas ) {
	var widget = this,
		menu = this.menu,
		items = this.getItems();

	$.each( datas, function ( i, data ) {
		var j, label,
			item = menu.getItemFromData( data );

		if ( item ) {
			label = item.label;
		} else if ( widget.allowArbitrary ) {
			label = String( data );
		} else {
			return;
		}

		item = null;
		for ( j = 0; j < items.length; j++ ) {
			if ( items[ j ].data === data && items[ j ].label === label ) {
				item = items[ j ];
				items.splice( j, 1 );
				break;
			}
		}
		if ( !item ) {
			item = new OO.ui.CapsuleItemWidget( { data: data, label: label } );
		}
		widget.addItems( [ item ], i );
	} );

	if ( items.length ) {
		widget.removeItems( items );
	}

	return this;
};

/**
 * Add items to the capsule by providing their data
 * @chainable
 * @param {Mixed[]} datas
 * @return {OO.ui.CapsuleMultiSelectWidget}
 */
OO.ui.CapsuleMultiSelectWidget.prototype.addItemsFromData = function ( datas ) {
	var widget = this,
		menu = this.menu,
		items = [];

	$.each( datas, function ( i, data ) {
		var item;

		if ( !widget.getItemFromData( data ) ) {
			item = menu.getItemFromData( data );
			if ( item ) {
				items.push( new OO.ui.CapsuleItemWidget( { data: data, label: item.label } ) );
			} else if ( widget.allowArbitrary ) {
				items.push( new OO.ui.CapsuleItemWidget( { data: data, label: String( data ) } ) );
			}
		}
	} );

	if ( items.length ) {
		this.addItems( items );
	}

	return this;
};

/**
 * Remove items by data
 * @chainable
 * @param {Mixed[]} datas
 * @return {OO.ui.CapsuleMultiSelectWidget}
 */
OO.ui.CapsuleMultiSelectWidget.prototype.removeItemsFromData = function ( datas ) {
	var widget = this,
		items = [];

	$.each( datas, function ( i, data ) {
		var item = widget.getItemFromData( data );
		if ( item ) {
			items.push( item );
		}
	} );

	if ( items.length ) {
		this.removeItems( items );
	}

	return this;
};

/**
 * @inheritdoc
 */
OO.ui.CapsuleMultiSelectWidget.prototype.addItems = function ( items ) {
	var same, i, l,
		oldItems = this.items.slice();

	OO.ui.mixin.GroupElement.prototype.addItems.call( this, items );

	if ( this.items.length !== oldItems.length ) {
		same = false;
	} else {
		same = true;
		for ( i = 0, l = oldItems.length; same && i < l; i++ ) {
			same = same && this.items[ i ] === oldItems[ i ];
		}
	}
	if ( !same ) {
		this.emit( 'change', this.getItemsData() );
	}

	return this;
};

/**
 * @inheritdoc
 */
OO.ui.CapsuleMultiSelectWidget.prototype.removeItems = function ( items ) {
	var same, i, l,
		oldItems = this.items.slice();

	OO.ui.mixin.GroupElement.prototype.removeItems.call( this, items );

	if ( this.items.length !== oldItems.length ) {
		same = false;
	} else {
		same = true;
		for ( i = 0, l = oldItems.length; same && i < l; i++ ) {
			same = same && this.items[ i ] === oldItems[ i ];
		}
	}
	if ( !same ) {
		this.emit( 'change', this.getItemsData() );
	}

	return this;
};

/**
 * @inheritdoc
 */
OO.ui.CapsuleMultiSelectWidget.prototype.clearItems = function () {
	if ( this.items.length ) {
		OO.ui.mixin.GroupElement.prototype.clearItems.call( this );
		this.emit( 'change', this.getItemsData() );
	}
	return this;
};

/**
 * Get the capsule widget's menu.
 * @return {OO.ui.MenuSelectWidget} Menu widget
 */
OO.ui.CapsuleMultiSelectWidget.prototype.getMenu = function () {
	return this.menu;
};

/**
 * Handle focus events
 *
 * @private
 * @param {jQuery.Event} event
 */
OO.ui.CapsuleMultiSelectWidget.prototype.onInputFocus = function () {
	if ( !this.isDisabled() ) {
		this.menu.toggle( true );
	}
};

/**
 * Handle blur events
 *
 * @private
 * @param {jQuery.Event} event
 */
OO.ui.CapsuleMultiSelectWidget.prototype.onInputBlur = function () {
	this.clearInput();
};

/**
 * Handle focus events
 *
 * @private
 * @param {jQuery.Event} event
 */
OO.ui.CapsuleMultiSelectWidget.prototype.onFocusForPopup = function () {
	if ( !this.isDisabled() ) {
		this.popup.setSize( this.$handle.width() );
		this.popup.toggle( true );
		this.popup.$element.find( '*' )
			.filter( function () { return OO.ui.isFocusableElement( $( this ), true ); } )
			.first()
			.focus();
	}
};

/**
 * Handles popup focus out events.
 *
 * @private
 * @param {Event} e Focus out event
 */
OO.ui.CapsuleMultiSelectWidget.prototype.onPopupFocusOut = function () {
	var widget = this.popup;

	setTimeout( function () {
		if (
			widget.isVisible() &&
			!OO.ui.contains( widget.$element[ 0 ], document.activeElement, true ) &&
			( !widget.$autoCloseIgnore || !widget.$autoCloseIgnore.has( document.activeElement ).length )
		) {
			widget.toggle( false );
		}
	} );
};

/**
 * Handle mouse click events.
 *
 * @private
 * @param {jQuery.Event} e Mouse click event
 */
OO.ui.CapsuleMultiSelectWidget.prototype.onClick = function ( e ) {
	if ( e.which === 1 ) {
		this.focus();
		return false;
	}
};

/**
 * Handle key press events.
 *
 * @private
 * @param {jQuery.Event} e Key press event
 */
OO.ui.CapsuleMultiSelectWidget.prototype.onKeyPress = function ( e ) {
	var item;

	if ( !this.isDisabled() ) {
		if ( e.which === OO.ui.Keys.ESCAPE ) {
			this.clearInput();
			return false;
		}

		if ( !this.popup ) {
			this.menu.toggle( true );
			if ( e.which === OO.ui.Keys.ENTER ) {
				item = this.menu.getItemFromLabel( this.$input.val(), true );
				if ( item ) {
					this.addItemsFromData( [ item.data ] );
					this.clearInput();
				} else if ( this.allowArbitrary && this.$input.val().trim() !== '' ) {
					this.addItemsFromData( [ this.$input.val() ] );
					this.clearInput();
				}
				return false;
			}

			// Make sure the input gets resized.
			setTimeout( this.onInputChange.bind( this ), 0 );
		}
	}
};

/**
 * Handle key down events.
 *
 * @private
 * @param {jQuery.Event} e Key down event
 */
OO.ui.CapsuleMultiSelectWidget.prototype.onKeyDown = function ( e ) {
	if ( !this.isDisabled() ) {
		// 'keypress' event is not triggered for Backspace
		if ( e.keyCode === OO.ui.Keys.BACKSPACE && this.$input.val() === '' ) {
			if ( this.items.length ) {
				this.removeItems( this.items.slice( -1 ) );
			}
			return false;
		}
	}
};

/**
 * Handle input change events.
 *
 * @private
 * @param {jQuery.Event} e Event of some sort
 */
OO.ui.CapsuleMultiSelectWidget.prototype.onInputChange = function () {
	if ( !this.isDisabled() ) {
		this.$input.width( this.$input.val().length + 'em' );
	}
};

/**
 * Handle menu choose events.
 *
 * @private
 * @param {OO.ui.OptionWidget} item Chosen item
 */
OO.ui.CapsuleMultiSelectWidget.prototype.onMenuChoose = function ( item ) {
	if ( item && item.isVisible() ) {
		this.addItemsFromData( [ item.getData() ] );
		this.clearInput();
	}
};

/**
 * Handle menu item change events.
 *
 * @private
 */
OO.ui.CapsuleMultiSelectWidget.prototype.onMenuItemsChange = function () {
	this.setItemsFromData( this.getItemsData() );
	this.$element.toggleClass( 'oo-ui-capsuleMultiSelectWidget-empty', this.menu.isEmpty() );
};

/**
 * Clear the input field
 * @private
 */
OO.ui.CapsuleMultiSelectWidget.prototype.clearInput = function () {
	if ( this.$input ) {
		this.$input.val( '' );
		this.$input.width( '1em' );
	}
	if ( this.popup ) {
		this.popup.toggle( false );
	}
	this.menu.toggle( false );
	this.menu.selectItem();
	this.menu.highlightItem();
};

/**
 * @inheritdoc
 */
OO.ui.CapsuleMultiSelectWidget.prototype.setDisabled = function ( disabled ) {
	var i, len;

	// Parent method
	OO.ui.CapsuleMultiSelectWidget.parent.prototype.setDisabled.call( this, disabled );

	if ( this.$input ) {
		this.$input.prop( 'disabled', this.isDisabled() );
	}
	if ( this.menu ) {
		this.menu.setDisabled( this.isDisabled() );
	}
	if ( this.popup ) {
		this.popup.setDisabled( this.isDisabled() );
	}

	if ( this.items ) {
		for ( i = 0, len = this.items.length; i < len; i++ ) {
			this.items[ i ].updateDisabled();
		}
	}

	return this;
};

/**
 * Focus the widget
 * @chainable
 * @return {OO.ui.CapsuleMultiSelectWidget}
 */
OO.ui.CapsuleMultiSelectWidget.prototype.focus = function () {
	if ( !this.isDisabled() ) {
		if ( this.popup ) {
			this.popup.setSize( this.$handle.width() );
			this.popup.toggle( true );
			this.popup.$element.find( '*' )
				.filter( function () { return OO.ui.isFocusableElement( $( this ), true ); } )
				.first()
				.focus();
		} else {
			this.menu.toggle( true );
			this.$input.focus();
		}
	}
	return this;
};

/**
 * CapsuleItemWidgets are used within a {@link OO.ui.CapsuleMultiSelectWidget
 * CapsuleMultiSelectWidget} to display the selected items.
 *
 * @class
 * @extends OO.ui.Widget
 * @mixins OO.ui.mixin.ItemWidget
 * @mixins OO.ui.mixin.IndicatorElement
 * @mixins OO.ui.mixin.LabelElement
 * @mixins OO.ui.mixin.FlaggedElement
 * @mixins OO.ui.mixin.TabIndexedElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
OO.ui.CapsuleItemWidget = function OoUiCapsuleItemWidget( config ) {
	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.CapsuleItemWidget.parent.call( this, config );

	// Properties (must be set before mixin constructor calls)
	this.$indicator = $( '<span>' );

	// Mixin constructors
	OO.ui.mixin.ItemWidget.call( this );
	OO.ui.mixin.IndicatorElement.call( this, $.extend( {}, config, { $indicator: this.$indicator, indicator: 'clear' } ) );
	OO.ui.mixin.LabelElement.call( this, config );
	OO.ui.mixin.FlaggedElement.call( this, config );
	OO.ui.mixin.TabIndexedElement.call( this, $.extend( {}, config, { $tabIndexed: this.$indicator } ) );

	// Events
	this.$indicator.on( {
		keydown: this.onCloseKeyDown.bind( this ),
		click: this.onCloseClick.bind( this )
	} );
	this.$element.on( 'click', false );

	// Initialization
	this.$element
		.addClass( 'oo-ui-capsuleItemWidget' )
		.append( this.$indicator, this.$label );
};

/* Setup */

OO.inheritClass( OO.ui.CapsuleItemWidget, OO.ui.Widget );
OO.mixinClass( OO.ui.CapsuleItemWidget, OO.ui.mixin.ItemWidget );
OO.mixinClass( OO.ui.CapsuleItemWidget, OO.ui.mixin.IndicatorElement );
OO.mixinClass( OO.ui.CapsuleItemWidget, OO.ui.mixin.LabelElement );
OO.mixinClass( OO.ui.CapsuleItemWidget, OO.ui.mixin.FlaggedElement );
OO.mixinClass( OO.ui.CapsuleItemWidget, OO.ui.mixin.TabIndexedElement );

/* Methods */

/**
 * Handle close icon clicks
 * @param {jQuery.Event} event
 */
OO.ui.CapsuleItemWidget.prototype.onCloseClick = function () {
	var element = this.getElementGroup();

	if ( !this.isDisabled() && element && $.isFunction( element.removeItems ) ) {
		element.removeItems( [ this ] );
		element.focus();
	}
};

/**
 * Handle close keyboard events
 * @param {jQuery.Event} event Key down event
 */
OO.ui.CapsuleItemWidget.prototype.onCloseKeyDown = function ( e ) {
	if ( !this.isDisabled() && $.isFunction( this.getElementGroup().removeItems ) ) {
		switch ( e.which ) {
			case OO.ui.Keys.ENTER:
			case OO.ui.Keys.BACKSPACE:
			case OO.ui.Keys.SPACE:
				this.getElementGroup().removeItems( [ this ] );
				return false;
		}
	}
};

/**
 * DropdownWidgets are not menus themselves, rather they contain a menu of options created with
 * OO.ui.MenuOptionWidget. The DropdownWidget takes care of opening and displaying the menu so that
 * users can interact with it.
 *
 * If you want to use this within a HTML form, such as a OO.ui.FormLayout, use
 * OO.ui.DropdownInputWidget instead.
 *
 *     @example
 *     // Example: A DropdownWidget with a menu that contains three options
 *     var dropDown = new OO.ui.DropdownWidget( {
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
 *     $( 'body' ).append( dropDown.$element );
 *
 * For more information, please see the [OOjs UI documentation on MediaWiki] [1].
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Selects_and_Options#Menu_selects_and_options
 *
 * @class
 * @extends OO.ui.Widget
 * @mixins OO.ui.mixin.IconElement
 * @mixins OO.ui.mixin.IndicatorElement
 * @mixins OO.ui.mixin.LabelElement
 * @mixins OO.ui.mixin.TitledElement
 * @mixins OO.ui.mixin.TabIndexedElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {Object} [menu] Configuration options to pass to {@link OO.ui.FloatingMenuSelectWidget menu select widget}
 * @cfg {jQuery} [$overlay] Render the menu into a separate layer. This configuration is useful in cases where
 *  the expanded menu is larger than its containing `<div>`. The specified overlay layer is usually on top of the
 *  containing `<div>` and has a larger area. By default, the menu uses relative positioning.
 */
OO.ui.DropdownWidget = function OoUiDropdownWidget( config ) {
	// Configuration initialization
	config = $.extend( { indicator: 'down' }, config );

	// Parent constructor
	OO.ui.DropdownWidget.parent.call( this, config );

	// Properties (must be set before TabIndexedElement constructor call)
	this.$handle = this.$( '<span>' );
	this.$overlay = config.$overlay || this.$element;

	// Mixin constructors
	OO.ui.mixin.IconElement.call( this, config );
	OO.ui.mixin.IndicatorElement.call( this, config );
	OO.ui.mixin.LabelElement.call( this, config );
	OO.ui.mixin.TitledElement.call( this, $.extend( {}, config, { $titled: this.$label } ) );
	OO.ui.mixin.TabIndexedElement.call( this, $.extend( {}, config, { $tabIndexed: this.$handle } ) );

	// Properties
	this.menu = new OO.ui.FloatingMenuSelectWidget( $.extend( {
		widget: this,
		$container: this.$element
	}, config.menu ) );

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
		.append( this.$handle );
	this.$overlay.append( this.menu.$element );
};

/* Setup */

OO.inheritClass( OO.ui.DropdownWidget, OO.ui.Widget );
OO.mixinClass( OO.ui.DropdownWidget, OO.ui.mixin.IconElement );
OO.mixinClass( OO.ui.DropdownWidget, OO.ui.mixin.IndicatorElement );
OO.mixinClass( OO.ui.DropdownWidget, OO.ui.mixin.LabelElement );
OO.mixinClass( OO.ui.DropdownWidget, OO.ui.mixin.TitledElement );
OO.mixinClass( OO.ui.DropdownWidget, OO.ui.mixin.TabIndexedElement );

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
		this.setLabel( null );
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
	if ( !this.isDisabled() &&
		( ( e.which === OO.ui.Keys.SPACE && !this.menu.isVisible() ) || e.which === OO.ui.Keys.ENTER )
	) {
		this.menu.toggle();
		return false;
	}
};

/**
 * SelectFileWidgets allow for selecting files, using the HTML5 File API. These
 * widgets can be configured with {@link OO.ui.mixin.IconElement icons} and {@link
 * OO.ui.mixin.IndicatorElement indicators}.
 * Please see the [OOjs UI documentation on MediaWiki] [1] for more information and examples.
 *
 *     @example
 *     // Example of a file select widget
 *     var selectFile = new OO.ui.SelectFileWidget();
 *     $( 'body' ).append( selectFile.$element );
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets
 *
 * @class
 * @extends OO.ui.Widget
 * @mixins OO.ui.mixin.IconElement
 * @mixins OO.ui.mixin.IndicatorElement
 * @mixins OO.ui.mixin.PendingElement
 * @mixins OO.ui.mixin.LabelElement
 * @mixins OO.ui.mixin.TabIndexedElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {string[]|null} [accept=null] MIME types to accept. null accepts all types.
 * @cfg {string} [placeholder] Text to display when no file is selected.
 * @cfg {string} [notsupported] Text to display when file support is missing in the browser.
 * @cfg {boolean} [droppable=true] Whether to accept files by drag and drop.
 * @cfg {boolean} [dragDropUI=false] Whether to render the drag and drop UI.
 */
OO.ui.SelectFileWidget = function OoUiSelectFileWidget( config ) {
	var dragHandler,
		placeholderMsg = ( config && config.dragDropUI ) ?
			'ooui-selectfile-dragdrop-placeholder' :
			'ooui-selectfile-placeholder';

	// Configuration initialization
	config = $.extend( {
		accept: null,
		placeholder: OO.ui.msg( placeholderMsg ),
		notsupported: OO.ui.msg( 'ooui-selectfile-not-supported' ),
		droppable: true,
		dragDropUI: false
	}, config );

	// Parent constructor
	OO.ui.SelectFileWidget.parent.call( this, config );

	// Properties (must be set before TabIndexedElement constructor call)
	this.$handle = $( '<span>' );

	// Mixin constructors
	OO.ui.mixin.IconElement.call( this, config );
	OO.ui.mixin.IndicatorElement.call( this, config );
	OO.ui.mixin.PendingElement.call( this, $.extend( {}, config, { $pending: this.$handle } ) );
	OO.ui.mixin.LabelElement.call( this, $.extend( {}, config, { autoFitLabel: true } ) );
	OO.ui.mixin.TabIndexedElement.call( this, $.extend( {}, config, { $tabIndexed: this.$handle } ) );

	// Properties
	this.active = false;
	this.dragDropUI = config.dragDropUI;
	this.isSupported = this.constructor.static.isSupported();
	this.currentFile = null;
	if ( Array.isArray( config.accept ) ) {
		this.accept = config.accept;
	} else {
		this.accept = null;
	}
	this.placeholder = config.placeholder;
	this.notsupported = config.notsupported;
	this.onFileSelectedHandler = this.onFileSelected.bind( this );

	this.clearButton = new OO.ui.ButtonWidget( {
		classes: [ 'oo-ui-selectFileWidget-clearButton' ],
		framed: false,
		icon: 'remove',
		disabled: this.disabled
	} );

	// Events
	this.$handle.on( {
		keypress: this.onKeyPress.bind( this )
	} );
	this.clearButton.connect( this, {
		click: 'onClearClick'
	} );
	if ( config.droppable ) {
		dragHandler = this.onDragEnterOrOver.bind( this );
		this.$handle.on( {
			dragenter: dragHandler,
			dragover: dragHandler,
			dragleave: this.onDragLeave.bind( this ),
			drop: this.onDrop.bind( this )
		} );
	}

	// Initialization
	this.addInput();
	this.updateUI();
	this.$label.addClass( 'oo-ui-selectFileWidget-label' );
	this.$handle
		.addClass( 'oo-ui-selectFileWidget-handle' )
		.append( this.$icon, this.$label, this.clearButton.$element, this.$indicator );
	this.$element
		.addClass( 'oo-ui-selectFileWidget' )
		.append( this.$handle );
	if ( config.droppable ) {
		if ( config.dragDropUI ) {
			this.$element.addClass( 'oo-ui-selectFileWidget-dragdrop-ui' );
			this.$element.on( {
				mouseover: this.onMouseOver.bind( this ),
				mouseleave: this.onMouseLeave.bind( this )
			} );
		} else {
			this.$element.addClass( 'oo-ui-selectFileWidget-droppable' );
		}
	}
};

/* Setup */

OO.inheritClass( OO.ui.SelectFileWidget, OO.ui.Widget );
OO.mixinClass( OO.ui.SelectFileWidget, OO.ui.mixin.IconElement );
OO.mixinClass( OO.ui.SelectFileWidget, OO.ui.mixin.IndicatorElement );
OO.mixinClass( OO.ui.SelectFileWidget, OO.ui.mixin.PendingElement );
OO.mixinClass( OO.ui.SelectFileWidget, OO.ui.mixin.LabelElement );
OO.mixinClass( OO.ui.SelectFileWidget, OO.ui.mixin.TabIndexedElement );

/* Static Properties */

/**
 * Check if this widget is supported
 *
 * @static
 * @return {boolean}
 */
OO.ui.SelectFileWidget.static.isSupported = function () {
	var $input;
	if ( OO.ui.SelectFileWidget.static.isSupportedCache === null ) {
		$input = $( '<input type="file">' );
		OO.ui.SelectFileWidget.static.isSupportedCache = $input[ 0 ].files !== undefined;
	}
	return OO.ui.SelectFileWidget.static.isSupportedCache;
};

OO.ui.SelectFileWidget.static.isSupportedCache = null;

/* Events */

/**
 * @event change
 *
 * A change event is emitted when the on/off state of the toggle changes.
 *
 * @param {File|null} value New value
 */

/* Methods */

/**
 * Get the current value of the field
 *
 * @return {File|null}
 */
OO.ui.SelectFileWidget.prototype.getValue = function () {
	return this.currentFile;
};

/**
 * Set the current value of the field
 *
 * @param {File|null} file File to select
 */
OO.ui.SelectFileWidget.prototype.setValue = function ( file ) {
	if ( this.currentFile !== file ) {
		this.currentFile = file;
		this.updateUI();
		this.emit( 'change', this.currentFile );
	}
};

/**
 * Update the user interface when a file is selected or unselected
 *
 * @protected
 */
OO.ui.SelectFileWidget.prototype.updateUI = function () {
	if ( !this.isSupported ) {
		this.$element.addClass( 'oo-ui-selectFileWidget-notsupported' );
		this.$element.removeClass( 'oo-ui-selectFileWidget-empty' );
		this.setLabel( this.notsupported );
	} else if ( this.currentFile ) {
		this.$element.removeClass( 'oo-ui-selectFileWidget-empty' );
		this.setLabel( this.currentFile.name +
			( this.currentFile.type !== '' ? OO.ui.msg( 'ooui-semicolon-separator' ) + this.currentFile.type : '' )
		);
	} else {
		this.$element.addClass( 'oo-ui-selectFileWidget-empty' );
		this.setLabel( this.placeholder );
	}

	if ( this.$input ) {
		this.$input.attr( 'title', this.getLabel() );
	}
};

/**
 * Add the input to the handle
 *
 * @private
 */
OO.ui.SelectFileWidget.prototype.addInput = function () {
	if ( this.$input ) {
		this.$input.remove();
	}

	if ( !this.isSupported ) {
		this.$input = null;
		return;
	}

	this.$input = $( '<input type="file">' );
	this.$input.on( 'change', this.onFileSelectedHandler );
	this.$input.attr( {
		tabindex: -1,
		title: this.getLabel()
	} );
	if ( this.accept ) {
		this.$input.attr( 'accept', this.accept.join( ', ' ) );
	}
	this.$handle.append( this.$input );
};

/**
 * Determine if we should accept this file
 *
 * @private
 * @param {File} file
 * @return {boolean}
 */
OO.ui.SelectFileWidget.prototype.isFileAcceptable = function ( file ) {
	var i, mime, mimeTest;

	if ( !this.accept || file.type === '' ) {
		return true;
	}

	mime = file.type;
	for ( i = 0; i < this.accept.length; i++ ) {
		mimeTest = this.accept[ i ];
		if ( mimeTest === mime ) {
			return true;
		} else if ( mimeTest.substr( -2 ) === '/*' ) {
			mimeTest = mimeTest.substr( 0, mimeTest.length - 1 );
			if ( mime.substr( 0, mimeTest.length ) === mimeTest ) {
				return true;
			}
		}
	}

	return false;
};

/**
 * Handle file selection from the input
 *
 * @private
 * @param {jQuery.Event} e
 */
OO.ui.SelectFileWidget.prototype.onFileSelected = function ( e ) {
	var file = null;

	if ( e.target.files && e.target.files[ 0 ] ) {
		file = e.target.files[ 0 ];
		if ( !this.isFileAcceptable( file ) ) {
			file = null;
		}
	}

	this.setValue( file );
	this.addInput();
};

/**
 * Handle clear button click events.
 *
 * @private
 */
OO.ui.SelectFileWidget.prototype.onClearClick = function () {
	this.setValue( null );
	return false;
};

/**
 * Handle key press events.
 *
 * @private
 * @param {jQuery.Event} e Key press event
 */
OO.ui.SelectFileWidget.prototype.onKeyPress = function ( e ) {
	if ( this.isSupported && !this.isDisabled() && this.$input &&
		( e.which === OO.ui.Keys.SPACE || e.which === OO.ui.Keys.ENTER )
	) {
		this.$input.click();
		return false;
	}
};

/**
 * Handle drag enter and over events
 *
 * @private
 * @param {jQuery.Event} e Drag event
 */
OO.ui.SelectFileWidget.prototype.onDragEnterOrOver = function ( e ) {
	var file = null,
		dt = e.originalEvent.dataTransfer;

	e.preventDefault();
	e.stopPropagation();

	if ( this.isDisabled() || !this.isSupported ) {
		this.$element.removeClass( 'oo-ui-selectFileWidget-canDrop' );
		this.setActive( false );
		dt.dropEffect = 'none';
		return false;
	}

	if ( dt && dt.files && dt.files[ 0 ] ) {
		file = dt.files[ 0 ];
		if ( !this.isFileAcceptable( file ) ) {
			file = null;
		}
	} else if ( dt && dt.types && dt.types.indexOf( 'Files' ) !== -1 ) {
		// We know we have files so set 'file' to something truthy, we just
		// can't know any details about them.
		// * https://bugzilla.mozilla.org/show_bug.cgi?id=640534
		file = 'Files exist, but details are unknown';
	}
	if ( file ) {
		this.$element.addClass( 'oo-ui-selectFileWidget-canDrop' );
		this.setActive( true );
	} else {
		this.$element.removeClass( 'oo-ui-selectFileWidget-canDrop' );
		this.setActive( false );
		dt.dropEffect = 'none';
	}

	return false;
};

/**
 * Handle drag leave events
 *
 * @private
 * @param {jQuery.Event} e Drag event
 */
OO.ui.SelectFileWidget.prototype.onDragLeave = function () {
	this.$element.removeClass( 'oo-ui-selectFileWidget-canDrop' );
	this.setActive( false );
};

/**
 * Handle drop events
 *
 * @private
 * @param {jQuery.Event} e Drop event
 */
OO.ui.SelectFileWidget.prototype.onDrop = function ( e ) {
	var file = null,
		dt = e.originalEvent.dataTransfer;

	e.preventDefault();
	e.stopPropagation();
	this.$element.removeClass( 'oo-ui-selectFileWidget-canDrop' );
	this.setActive( false );

	if ( this.isDisabled() || !this.isSupported ) {
		return false;
	}

	if ( dt && dt.files && dt.files[ 0 ] ) {
		file = dt.files[ 0 ];
		if ( !this.isFileAcceptable( file ) ) {
			file = null;
		}
	}
	if ( file ) {
		this.setValue( file );
	}

	return false;
};

/**
 * Handle mouse over events.
 *
 * @private
 * @param {jQuery.Event} e Mouse over event
 */
OO.ui.SelectFileWidget.prototype.onMouseOver = function () {
	this.setActive( true );
};

/**
 * Handle mouse leave events.
 *
 * @private
 * @param {jQuery.Event} e Mouse over event
 */
OO.ui.SelectFileWidget.prototype.onMouseLeave = function () {
	this.setActive( false );
};

/**
 * @inheritdoc
 */
OO.ui.SelectFileWidget.prototype.setDisabled = function ( state ) {
	OO.ui.SelectFileWidget.parent.prototype.setDisabled.call( this, state );
	if ( this.clearButton ) {
		this.clearButton.setDisabled( state );
	}
	return this;
};

/**
 * Set 'active' (hover) state, only matters for widgets with `dragDropUI: true`.
 *
 * @param {boolean} value Whether widget is active
 * @chainable
 */
OO.ui.SelectFileWidget.prototype.setActive = function ( value ) {
	if ( this.dragDropUI ) {
		this.active = value;
		this.updateThemeClasses();
	}
	return this;
};

/**
 * IconWidget is a generic widget for {@link OO.ui.mixin.IconElement icons}. In general, IconWidgets should be used with OO.ui.LabelWidget,
 * which creates a label that identifies the icon’s function. See the [OOjs UI documentation on MediaWiki] [1]
 * for a list of icons included in the library.
 *
 *     @example
 *     // An icon widget with a label
 *     var myIcon = new OO.ui.IconWidget( {
 *         icon: 'help',
 *         iconTitle: 'Help'
 *      } );
 *      // Create a label.
 *      var iconLabel = new OO.ui.LabelWidget( {
 *          label: 'Help'
 *      } );
 *      $( 'body' ).append( myIcon.$element, iconLabel.$element );
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Icons,_Indicators,_and_Labels#Icons
 *
 * @class
 * @extends OO.ui.Widget
 * @mixins OO.ui.mixin.IconElement
 * @mixins OO.ui.mixin.TitledElement
 * @mixins OO.ui.mixin.FlaggedElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
OO.ui.IconWidget = function OoUiIconWidget( config ) {
	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.IconWidget.parent.call( this, config );

	// Mixin constructors
	OO.ui.mixin.IconElement.call( this, $.extend( {}, config, { $icon: this.$element } ) );
	OO.ui.mixin.TitledElement.call( this, $.extend( {}, config, { $titled: this.$element } ) );
	OO.ui.mixin.FlaggedElement.call( this, $.extend( {}, config, { $flagged: this.$element } ) );

	// Initialization
	this.$element.addClass( 'oo-ui-iconWidget' );
};

/* Setup */

OO.inheritClass( OO.ui.IconWidget, OO.ui.Widget );
OO.mixinClass( OO.ui.IconWidget, OO.ui.mixin.IconElement );
OO.mixinClass( OO.ui.IconWidget, OO.ui.mixin.TitledElement );
OO.mixinClass( OO.ui.IconWidget, OO.ui.mixin.FlaggedElement );

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
 *     } );
 *
 *     // Create a fieldset layout to add a label
 *     var fieldset = new OO.ui.FieldsetLayout();
 *     fieldset.addItems( [
 *         new OO.ui.FieldLayout( indicator1, { label: 'An alert indicator:' } )
 *     ] );
 *     $( 'body' ).append( fieldset.$element );
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Icons,_Indicators,_and_Labels#Indicators
 *
 * @class
 * @extends OO.ui.Widget
 * @mixins OO.ui.mixin.IndicatorElement
 * @mixins OO.ui.mixin.TitledElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
OO.ui.IndicatorWidget = function OoUiIndicatorWidget( config ) {
	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.IndicatorWidget.parent.call( this, config );

	// Mixin constructors
	OO.ui.mixin.IndicatorElement.call( this, $.extend( {}, config, { $indicator: this.$element } ) );
	OO.ui.mixin.TitledElement.call( this, $.extend( {}, config, { $titled: this.$element } ) );

	// Initialization
	this.$element.addClass( 'oo-ui-indicatorWidget' );
};

/* Setup */

OO.inheritClass( OO.ui.IndicatorWidget, OO.ui.Widget );
OO.mixinClass( OO.ui.IndicatorWidget, OO.ui.mixin.IndicatorElement );
OO.mixinClass( OO.ui.IndicatorWidget, OO.ui.mixin.TitledElement );

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
 * @mixins OO.ui.mixin.FlaggedElement
 * @mixins OO.ui.mixin.TabIndexedElement
 * @mixins OO.ui.mixin.TitledElement
 * @mixins OO.ui.mixin.AccessKeyedElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {string} [name=''] The value of the input’s HTML `name` attribute.
 * @cfg {string} [value=''] The value of the input.
 * @cfg {string} [accessKey=''] The access key of the input.
 * @cfg {Function} [inputFilter] The name of an input filter function. Input filters modify the value of an input
 *  before it is accepted.
 */
OO.ui.InputWidget = function OoUiInputWidget( config ) {
	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.InputWidget.parent.call( this, config );

	// Properties
	this.$input = this.getInputElement( config );
	this.value = '';
	this.inputFilter = config.inputFilter;

	// Mixin constructors
	OO.ui.mixin.FlaggedElement.call( this, config );
	OO.ui.mixin.TabIndexedElement.call( this, $.extend( {}, config, { $tabIndexed: this.$input } ) );
	OO.ui.mixin.TitledElement.call( this, $.extend( {}, config, { $titled: this.$input } ) );
	OO.ui.mixin.AccessKeyedElement.call( this, $.extend( {}, config, { $accessKeyed: this.$input } ) );

	// Events
	this.$input.on( 'keydown mouseup cut paste change input select', this.onEdit.bind( this ) );

	// Initialization
	this.$input
		.addClass( 'oo-ui-inputWidget-input' )
		.attr( 'name', config.name )
		.prop( 'disabled', this.isDisabled() );
	this.$element
		.addClass( 'oo-ui-inputWidget' )
		.append( this.$input );
	this.setValue( config.value );
	this.setAccessKey( config.accessKey );
};

/* Setup */

OO.inheritClass( OO.ui.InputWidget, OO.ui.Widget );
OO.mixinClass( OO.ui.InputWidget, OO.ui.mixin.FlaggedElement );
OO.mixinClass( OO.ui.InputWidget, OO.ui.mixin.TabIndexedElement );
OO.mixinClass( OO.ui.InputWidget, OO.ui.mixin.TitledElement );
OO.mixinClass( OO.ui.InputWidget, OO.ui.mixin.AccessKeyedElement );

/* Static Properties */

OO.ui.InputWidget.static.supportsSimpleLabel = true;

/* Events */

/**
 * @event change
 *
 * A change event is emitted when the value of the input changes.
 *
 * @param {string} value
 */

/* Methods */

/**
 * Get input element.
 *
 * Subclasses of OO.ui.InputWidget use the `config` parameter to produce different elements in
 * different circumstances. The element must have a `value` property (like form elements).
 *
 * @protected
 * @param {Object} config Configuration options
 * @return {jQuery} Input element
 */
OO.ui.InputWidget.prototype.getInputElement = function () {
	return $( '<input>' );
};

/**
 * Handle potentially value-changing events.
 *
 * @private
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
 * Set the direction of the input, either RTL (right-to-left) or LTR (left-to-right).
 *
 * @param {boolean} isRTL
 * Direction is right-to-left
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
 * Set the input's access key.
 * FIXME: This is the same code as in OO.ui.mixin.ButtonElement, maybe find a better place for it?
 *
 * @param {string} accessKey Input's access key, use empty string to remove
 * @chainable
 */
OO.ui.InputWidget.prototype.setAccessKey = function ( accessKey ) {
	accessKey = typeof accessKey === 'string' && accessKey.length ? accessKey : null;

	if ( this.accessKey !== accessKey ) {
		if ( this.$input ) {
			if ( accessKey !== null ) {
				this.$input.attr( 'accesskey', accessKey );
			} else {
				this.$input.removeAttr( 'accesskey' );
			}
		}
		this.accessKey = accessKey;
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
 * Simulate the behavior of clicking on a label bound to this input. This method is only called by
 * {@link OO.ui.LabelWidget LabelWidget} and {@link OO.ui.FieldLayout FieldLayout}. It should not be
 * called directly.
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
	OO.ui.InputWidget.parent.prototype.setDisabled.call( this, state );
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
 * @inheritdoc
 */
OO.ui.InputWidget.prototype.gatherPreInfuseState = function ( node ) {
	var
		state = OO.ui.InputWidget.parent.prototype.gatherPreInfuseState.call( this, node ),
		$input = state.$input || $( node ).find( '.oo-ui-inputWidget-input' );
	state.value = $input.val();
	// Might be better in TabIndexedElement, but it's awkward to do there because mixins are awkward
	state.focus = $input.is( ':focus' );
	return state;
};

/**
 * @inheritdoc
 */
OO.ui.InputWidget.prototype.restorePreInfuseState = function ( state ) {
	OO.ui.InputWidget.parent.prototype.restorePreInfuseState.call( this, state );
	if ( state.value !== undefined && state.value !== this.getValue() ) {
		this.setValue( state.value );
	}
	if ( state.focus ) {
		this.focus();
	}
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
 * @mixins OO.ui.mixin.ButtonElement
 * @mixins OO.ui.mixin.IconElement
 * @mixins OO.ui.mixin.IndicatorElement
 * @mixins OO.ui.mixin.LabelElement
 * @mixins OO.ui.mixin.TitledElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {string} [type='button'] The value of the HTML `'type'` attribute: 'button', 'submit' or 'reset'.
 * @cfg {boolean} [useInputTag=false] Use an `<input/>` tag instead of a `<button/>` tag, the default.
 *  Widgets configured to be an `<input/>` do not support {@link #icon icons} and {@link #indicator indicators},
 *  non-plaintext {@link #label labels}, or {@link #value values}. In general, useInputTag should only
 *  be set to `true` when there’s need to support IE6 in a form with multiple buttons.
 */
OO.ui.ButtonInputWidget = function OoUiButtonInputWidget( config ) {
	// Configuration initialization
	config = $.extend( { type: 'button', useInputTag: false }, config );

	// Properties (must be set before parent constructor, which calls #setValue)
	this.useInputTag = config.useInputTag;

	// Parent constructor
	OO.ui.ButtonInputWidget.parent.call( this, config );

	// Mixin constructors
	OO.ui.mixin.ButtonElement.call( this, $.extend( {}, config, { $button: this.$input } ) );
	OO.ui.mixin.IconElement.call( this, config );
	OO.ui.mixin.IndicatorElement.call( this, config );
	OO.ui.mixin.LabelElement.call( this, config );
	OO.ui.mixin.TitledElement.call( this, $.extend( {}, config, { $titled: this.$input } ) );

	// Initialization
	if ( !config.useInputTag ) {
		this.$input.append( this.$icon, this.$label, this.$indicator );
	}
	this.$element.addClass( 'oo-ui-buttonInputWidget' );
};

/* Setup */

OO.inheritClass( OO.ui.ButtonInputWidget, OO.ui.InputWidget );
OO.mixinClass( OO.ui.ButtonInputWidget, OO.ui.mixin.ButtonElement );
OO.mixinClass( OO.ui.ButtonInputWidget, OO.ui.mixin.IconElement );
OO.mixinClass( OO.ui.ButtonInputWidget, OO.ui.mixin.IndicatorElement );
OO.mixinClass( OO.ui.ButtonInputWidget, OO.ui.mixin.LabelElement );
OO.mixinClass( OO.ui.ButtonInputWidget, OO.ui.mixin.TitledElement );

/* Static Properties */

/**
 * Disable generating `<label>` elements for buttons. One would very rarely need additional label
 * for a button, and it's already a big clickable target, and it causes unexpected rendering.
 */
OO.ui.ButtonInputWidget.static.supportsSimpleLabel = false;

/* Methods */

/**
 * @inheritdoc
 * @protected
 */
OO.ui.ButtonInputWidget.prototype.getInputElement = function ( config ) {
	var type = [ 'button', 'submit', 'reset' ].indexOf( config.type ) !== -1 ?
		config.type :
		'button';
	return $( '<' + ( config.useInputTag ? 'input' : 'button' ) + ' type="' + type + '">' );
};

/**
 * Set label value.
 *
 * If #useInputTag is `true`, the label is set as the `value` of the `<input/>` tag.
 *
 * @param {jQuery|string|Function|null} label Label nodes, text, a function that returns nodes or
 *  text, or `null` for no label
 * @chainable
 */
OO.ui.ButtonInputWidget.prototype.setLabel = function ( label ) {
	OO.ui.mixin.LabelElement.prototype.setLabel.call( this, label );

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
 * This method is disabled for button inputs configured as {@link #useInputTag <input/> tags}, as
 * they do not support {@link #value values}.
 *
 * @param {string} value New value
 * @chainable
 */
OO.ui.ButtonInputWidget.prototype.setValue = function ( value ) {
	if ( !this.useInputTag ) {
		OO.ui.ButtonInputWidget.parent.prototype.setValue.call( this, value );
	}
	return this;
};

/**
 * CheckboxInputWidgets, like HTML checkboxes, can be selected and/or configured with a value.
 * Note that these {@link OO.ui.InputWidget input widgets} are best laid out
 * in {@link OO.ui.FieldLayout field layouts} that use the {@link OO.ui.FieldLayout#align inline}
 * alignment. For more information, please see the [OOjs UI documentation on MediaWiki][1].
 *
 * This widget can be used inside a HTML form, such as a OO.ui.FormLayout.
 *
 *     @example
 *     // An example of selected, unselected, and disabled checkbox inputs
 *     var checkbox1=new OO.ui.CheckboxInputWidget( {
 *          value: 'a',
 *          selected: true
 *     } );
 *     var checkbox2=new OO.ui.CheckboxInputWidget( {
 *         value: 'b'
 *     } );
 *     var checkbox3=new OO.ui.CheckboxInputWidget( {
 *         value:'c',
 *         disabled: true
 *     } );
 *     // Create a fieldset layout with fields for each checkbox.
 *     var fieldset = new OO.ui.FieldsetLayout( {
 *         label: 'Checkboxes'
 *     } );
 *     fieldset.addItems( [
 *         new OO.ui.FieldLayout( checkbox1, { label: 'Selected checkbox', align: 'inline' } ),
 *         new OO.ui.FieldLayout( checkbox2, { label: 'Unselected checkbox', align: 'inline' } ),
 *         new OO.ui.FieldLayout( checkbox3, { label: 'Disabled checkbox', align: 'inline' } ),
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
	OO.ui.CheckboxInputWidget.parent.call( this, config );

	// Initialization
	this.$element
		.addClass( 'oo-ui-checkboxInputWidget' )
		// Required for pretty styling in MediaWiki theme
		.append( $( '<span>' ) );
	this.setSelected( config.selected !== undefined ? config.selected : false );
};

/* Setup */

OO.inheritClass( OO.ui.CheckboxInputWidget, OO.ui.InputWidget );

/* Methods */

/**
 * @inheritdoc
 * @protected
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
 * @inheritdoc
 */
OO.ui.CheckboxInputWidget.prototype.gatherPreInfuseState = function ( node ) {
	var
		state = OO.ui.CheckboxInputWidget.parent.prototype.gatherPreInfuseState.call( this, node ),
		$input = $( node ).find( '.oo-ui-inputWidget-input' );
	state.$input = $input; // shortcut for performance, used in InputWidget
	state.checked = $input.prop( 'checked' );
	return state;
};

/**
 * @inheritdoc
 */
OO.ui.CheckboxInputWidget.prototype.restorePreInfuseState = function ( state ) {
	OO.ui.CheckboxInputWidget.parent.prototype.restorePreInfuseState.call( this, state );
	if ( state.checked !== undefined && state.checked !== this.isSelected() ) {
		this.setSelected( state.checked );
	}
};

/**
 * DropdownInputWidget is a {@link OO.ui.DropdownWidget DropdownWidget} intended to be used
 * within a HTML form, such as a OO.ui.FormLayout. The selected value is synchronized with the value
 * of a hidden HTML `input` tag. Please see the [OOjs UI documentation on MediaWiki][1] for
 * more information about input widgets.
 *
 * A DropdownInputWidget always has a value (one of the options is always selected), unless there
 * are no options. If no `value` configuration option is provided, the first option is selected.
 * If you need a state representing no value (no option being selected), use a DropdownWidget.
 *
 * This and OO.ui.RadioSelectInputWidget support the same configuration options.
 *
 *     @example
 *     // Example: A DropdownInputWidget with three options
 *     var dropdownInput = new OO.ui.DropdownInputWidget( {
 *         options: [
 *             { data: 'a', label: 'First' },
 *             { data: 'b', label: 'Second'},
 *             { data: 'c', label: 'Third' }
 *         ]
 *     } );
 *     $( 'body' ).append( dropdownInput.$element );
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Inputs
 *
 * @class
 * @extends OO.ui.InputWidget
 * @mixins OO.ui.mixin.TitledElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {Object[]} [options=[]] Array of menu options in the format `{ data: …, label: … }`
 * @cfg {Object} [dropdown] Configuration options for {@link OO.ui.DropdownWidget DropdownWidget}
 */
OO.ui.DropdownInputWidget = function OoUiDropdownInputWidget( config ) {
	// Configuration initialization
	config = config || {};

	// Properties (must be done before parent constructor which calls #setDisabled)
	this.dropdownWidget = new OO.ui.DropdownWidget( config.dropdown );

	// Parent constructor
	OO.ui.DropdownInputWidget.parent.call( this, config );

	// Mixin constructors
	OO.ui.mixin.TitledElement.call( this, config );

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
OO.mixinClass( OO.ui.DropdownInputWidget, OO.ui.mixin.TitledElement );

/* Methods */

/**
 * @inheritdoc
 * @protected
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
	value = this.cleanUpValue( value );
	this.dropdownWidget.getMenu().selectItemByData( value );
	OO.ui.DropdownInputWidget.parent.prototype.setValue.call( this, value );
	return this;
};

/**
 * @inheritdoc
 */
OO.ui.DropdownInputWidget.prototype.setDisabled = function ( state ) {
	this.dropdownWidget.setDisabled( state );
	OO.ui.DropdownInputWidget.parent.prototype.setDisabled.call( this, state );
	return this;
};

/**
 * Set the options available for this input.
 *
 * @param {Object[]} options Array of menu options in the format `{ data: …, label: … }`
 * @chainable
 */
OO.ui.DropdownInputWidget.prototype.setOptions = function ( options ) {
	var
		value = this.getValue(),
		widget = this;

	// Rebuild the dropdown menu
	this.dropdownWidget.getMenu()
		.clearItems()
		.addItems( options.map( function ( opt ) {
			var optValue = widget.cleanUpValue( opt.data );
			return new OO.ui.MenuOptionWidget( {
				data: optValue,
				label: opt.label !== undefined ? opt.label : optValue
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
 * This widget can be used inside a HTML form, such as a OO.ui.FormLayout.
 *
 *     @example
 *     // An example of selected, unselected, and disabled radio inputs
 *     var radio1 = new OO.ui.RadioInputWidget( {
 *         value: 'a',
 *         selected: true
 *     } );
 *     var radio2 = new OO.ui.RadioInputWidget( {
 *         value: 'b'
 *     } );
 *     var radio3 = new OO.ui.RadioInputWidget( {
 *         value: 'c',
 *         disabled: true
 *     } );
 *     // Create a fieldset layout with fields for each radio button.
 *     var fieldset = new OO.ui.FieldsetLayout( {
 *         label: 'Radio inputs'
 *     } );
 *     fieldset.addItems( [
 *         new OO.ui.FieldLayout( radio1, { label: 'Selected', align: 'inline' } ),
 *         new OO.ui.FieldLayout( radio2, { label: 'Unselected', align: 'inline' } ),
 *         new OO.ui.FieldLayout( radio3, { label: 'Disabled', align: 'inline' } ),
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
	OO.ui.RadioInputWidget.parent.call( this, config );

	// Initialization
	this.$element
		.addClass( 'oo-ui-radioInputWidget' )
		// Required for pretty styling in MediaWiki theme
		.append( $( '<span>' ) );
	this.setSelected( config.selected !== undefined ? config.selected : false );
};

/* Setup */

OO.inheritClass( OO.ui.RadioInputWidget, OO.ui.InputWidget );

/* Methods */

/**
 * @inheritdoc
 * @protected
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
 * @inheritdoc
 */
OO.ui.RadioInputWidget.prototype.gatherPreInfuseState = function ( node ) {
	var
		state = OO.ui.RadioInputWidget.parent.prototype.gatherPreInfuseState.call( this, node ),
		$input = $( node ).find( '.oo-ui-inputWidget-input' );
	state.$input = $input; // shortcut for performance, used in InputWidget
	state.checked = $input.prop( 'checked' );
	return state;
};

/**
 * @inheritdoc
 */
OO.ui.RadioInputWidget.prototype.restorePreInfuseState = function ( state ) {
	OO.ui.RadioInputWidget.parent.prototype.restorePreInfuseState.call( this, state );
	if ( state.checked !== undefined && state.checked !== this.isSelected() ) {
		this.setSelected( state.checked );
	}
};

/**
 * RadioSelectInputWidget is a {@link OO.ui.RadioSelectWidget RadioSelectWidget} intended to be used
 * within a HTML form, such as a OO.ui.FormLayout. The selected value is synchronized with the value
 * of a hidden HTML `input` tag. Please see the [OOjs UI documentation on MediaWiki][1] for
 * more information about input widgets.
 *
 * This and OO.ui.DropdownInputWidget support the same configuration options.
 *
 *     @example
 *     // Example: A RadioSelectInputWidget with three options
 *     var radioSelectInput = new OO.ui.RadioSelectInputWidget( {
 *         options: [
 *             { data: 'a', label: 'First' },
 *             { data: 'b', label: 'Second'},
 *             { data: 'c', label: 'Third' }
 *         ]
 *     } );
 *     $( 'body' ).append( radioSelectInput.$element );
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
OO.ui.RadioSelectInputWidget = function OoUiRadioSelectInputWidget( config ) {
	// Configuration initialization
	config = config || {};

	// Properties (must be done before parent constructor which calls #setDisabled)
	this.radioSelectWidget = new OO.ui.RadioSelectWidget();

	// Parent constructor
	OO.ui.RadioSelectInputWidget.parent.call( this, config );

	// Events
	this.radioSelectWidget.connect( this, { select: 'onMenuSelect' } );

	// Initialization
	this.setOptions( config.options || [] );
	this.$element
		.addClass( 'oo-ui-radioSelectInputWidget' )
		.append( this.radioSelectWidget.$element );
};

/* Setup */

OO.inheritClass( OO.ui.RadioSelectInputWidget, OO.ui.InputWidget );

/* Static Properties */

OO.ui.RadioSelectInputWidget.static.supportsSimpleLabel = false;

/* Methods */

/**
 * @inheritdoc
 * @protected
 */
OO.ui.RadioSelectInputWidget.prototype.getInputElement = function () {
	return $( '<input type="hidden">' );
};

/**
 * Handles menu select events.
 *
 * @private
 * @param {OO.ui.RadioOptionWidget} item Selected menu item
 */
OO.ui.RadioSelectInputWidget.prototype.onMenuSelect = function ( item ) {
	this.setValue( item.getData() );
};

/**
 * @inheritdoc
 */
OO.ui.RadioSelectInputWidget.prototype.setValue = function ( value ) {
	value = this.cleanUpValue( value );
	this.radioSelectWidget.selectItemByData( value );
	OO.ui.RadioSelectInputWidget.parent.prototype.setValue.call( this, value );
	return this;
};

/**
 * @inheritdoc
 */
OO.ui.RadioSelectInputWidget.prototype.setDisabled = function ( state ) {
	this.radioSelectWidget.setDisabled( state );
	OO.ui.RadioSelectInputWidget.parent.prototype.setDisabled.call( this, state );
	return this;
};

/**
 * Set the options available for this input.
 *
 * @param {Object[]} options Array of menu options in the format `{ data: …, label: … }`
 * @chainable
 */
OO.ui.RadioSelectInputWidget.prototype.setOptions = function ( options ) {
	var
		value = this.getValue(),
		widget = this;

	// Rebuild the radioSelect menu
	this.radioSelectWidget
		.clearItems()
		.addItems( options.map( function ( opt ) {
			var optValue = widget.cleanUpValue( opt.data );
			return new OO.ui.RadioOptionWidget( {
				data: optValue,
				label: opt.label !== undefined ? opt.label : optValue
			} );
		} ) );

	// Restore the previous value, or reset to something sensible
	if ( this.radioSelectWidget.getItemFromData( value ) ) {
		// Previous value is still available, ensure consistency with the radioSelect
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
OO.ui.RadioSelectInputWidget.prototype.gatherPreInfuseState = function ( node ) {
	var state = OO.ui.RadioSelectInputWidget.parent.prototype.gatherPreInfuseState.call( this, node );
	state.value = $( node ).find( '.oo-ui-radioInputWidget .oo-ui-inputWidget-input:checked' ).val();
	return state;
};

/**
 * TextInputWidgets, like HTML text inputs, can be configured with options that customize the
 * size of the field as well as its presentation. In addition, these widgets can be configured
 * with {@link OO.ui.mixin.IconElement icons}, {@link OO.ui.mixin.IndicatorElement indicators}, an optional
 * validation-pattern (used to determine if an input value is valid or not) and an input filter,
 * which modifies incoming values rather than validating them.
 * Please see the [OOjs UI documentation on MediaWiki] [1] for more information and examples.
 *
 * This widget can be used inside a HTML form, such as a OO.ui.FormLayout.
 *
 *     @example
 *     // Example of a text input widget
 *     var textInput = new OO.ui.TextInputWidget( {
 *         value: 'Text input'
 *     } )
 *     $( 'body' ).append( textInput.$element );
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Inputs
 *
 * @class
 * @extends OO.ui.InputWidget
 * @mixins OO.ui.mixin.IconElement
 * @mixins OO.ui.mixin.IndicatorElement
 * @mixins OO.ui.mixin.PendingElement
 * @mixins OO.ui.mixin.LabelElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {string} [type='text'] The value of the HTML `type` attribute: 'text', 'password', 'search',
 *  'email' or 'url'. Ignored if `multiline` is true.
 *
 *  Some values of `type` result in additional behaviors:
 *
 *  - `search`: implies `icon: 'search'` and `indicator: 'clear'`; when clicked, the indicator
 *    empties the text field
 * @cfg {string} [placeholder] Placeholder text
 * @cfg {boolean} [autofocus=false] Use an HTML `autofocus` attribute to
 *  instruct the browser to focus this widget.
 * @cfg {boolean} [readOnly=false] Prevent changes to the value of the text input.
 * @cfg {number} [maxLength] Maximum number of characters allowed in the input.
 * @cfg {boolean} [multiline=false] Allow multiple lines of text
 * @cfg {number} [rows] If multiline, number of visible lines in textarea. If used with `autosize`,
 *  specifies minimum number of rows to display.
 * @cfg {boolean} [autosize=false] Automatically resize the text input to fit its content.
 *  Use the #maxRows config to specify a maximum number of displayed rows.
 * @cfg {boolean} [maxRows] Maximum number of rows to display when #autosize is set to true.
 *  Defaults to the maximum of `10` and `2 * rows`, or `10` if `rows` isn't provided.
 * @cfg {string} [labelPosition='after'] The position of the inline label relative to that of
 *  the value or placeholder text: `'before'` or `'after'`
 * @cfg {boolean} [required=false] Mark the field as required. Implies `indicator: 'required'`.
 * @cfg {boolean} [autocomplete=true] Should the browser support autocomplete for this field
 * @cfg {RegExp|Function|string} [validate] Validation pattern: when string, a symbolic name of a
 *  pattern defined by the class: 'non-empty' (the value cannot be an empty string) or 'integer'
 *  (the value must contain only numbers); when RegExp, a regular expression that must match the
 *  value for it to be considered valid; when Function, a function receiving the value as parameter
 *  that must return true, or promise resolving to true, for it to be considered valid.
 */
OO.ui.TextInputWidget = function OoUiTextInputWidget( config ) {
	// Configuration initialization
	config = $.extend( {
		type: 'text',
		labelPosition: 'after'
	}, config );
	if ( config.type === 'search' ) {
		if ( config.icon === undefined ) {
			config.icon = 'search';
		}
		// indicator: 'clear' is set dynamically later, depending on value
	}
	if ( config.required ) {
		if ( config.indicator === undefined ) {
			config.indicator = 'required';
		}
	}

	// Parent constructor
	OO.ui.TextInputWidget.parent.call( this, config );

	// Mixin constructors
	OO.ui.mixin.IconElement.call( this, config );
	OO.ui.mixin.IndicatorElement.call( this, config );
	OO.ui.mixin.PendingElement.call( this, $.extend( {}, config, { $pending: this.$input } ) );
	OO.ui.mixin.LabelElement.call( this, config );

	// Properties
	this.type = this.getSaneType( config );
	this.readOnly = false;
	this.multiline = !!config.multiline;
	this.autosize = !!config.autosize;
	this.minRows = config.rows !== undefined ? config.rows : '';
	this.maxRows = config.maxRows || Math.max( 2 * ( this.minRows || 0 ), 10 );
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
		blur: this.onBlur.bind( this )
	} );
	this.$input.one( {
		focus: this.onElementAttach.bind( this )
	} );
	this.$icon.on( 'mousedown', this.onIconMouseDown.bind( this ) );
	this.$indicator.on( 'mousedown', this.onIndicatorMouseDown.bind( this ) );
	this.on( 'labelChange', this.updatePosition.bind( this ) );
	this.connect( this, {
		change: 'onChange',
		disable: 'onDisable'
	} );

	// Initialization
	this.$element
		.addClass( 'oo-ui-textInputWidget oo-ui-textInputWidget-type-' + this.type )
		.append( this.$icon, this.$indicator );
	this.setReadOnly( !!config.readOnly );
	this.updateSearchIndicator();
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
		this.$input.attr( 'required', 'required' );
		this.$input.attr( 'aria-required', 'true' );
	}
	if ( config.autocomplete === false ) {
		this.$input.attr( 'autocomplete', 'off' );
	}
	if ( this.multiline && config.rows ) {
		this.$input.attr( 'rows', config.rows );
	}
	if ( this.label || config.autosize ) {
		this.installParentChangeDetector();
	}
};

/* Setup */

OO.inheritClass( OO.ui.TextInputWidget, OO.ui.InputWidget );
OO.mixinClass( OO.ui.TextInputWidget, OO.ui.mixin.IconElement );
OO.mixinClass( OO.ui.TextInputWidget, OO.ui.mixin.IndicatorElement );
OO.mixinClass( OO.ui.TextInputWidget, OO.ui.mixin.PendingElement );
OO.mixinClass( OO.ui.TextInputWidget, OO.ui.mixin.LabelElement );

/* Static Properties */

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
		if ( this.type === 'search' ) {
			// Clear the text field
			this.setValue( '' );
		}
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
 * Handle blur events.
 *
 * @private
 * @param {jQuery.Event} e Blur event
 */
OO.ui.TextInputWidget.prototype.onBlur = function () {
	this.setValidityFlag();
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
 * Handle change events.
 *
 * @param {string} value
 * @private
 */
OO.ui.TextInputWidget.prototype.onChange = function () {
	this.updateSearchIndicator();
	this.setValidityFlag();
	this.adjustSize();
};

/**
 * Handle disable events.
 *
 * @param {boolean} disabled Element is disabled
 * @private
 */
OO.ui.TextInputWidget.prototype.onDisable = function () {
	this.updateSearchIndicator();
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
	this.updateSearchIndicator();
	return this;
};

/**
 * Support function for making #onElementAttach work across browsers.
 *
 * This whole function could be replaced with one line of code using the DOMNodeInsertedIntoDocument
 * event, but it's not supported by Firefox and allegedly deprecated, so we only use it as fallback.
 *
 * Due to MutationObserver performance woes, #onElementAttach is only somewhat reliably called the
 * first time that the element gets attached to the documented.
 */
OO.ui.TextInputWidget.prototype.installParentChangeDetector = function () {
	var mutationObserver, onRemove, topmostNode, fakeParentNode,
		MutationObserver = window.MutationObserver || window.WebKitMutationObserver || window.MozMutationObserver,
		widget = this;

	if ( MutationObserver ) {
		// The new way. If only it wasn't so ugly.

		if ( this.$element.closest( 'html' ).length ) {
			// Widget is attached already, do nothing. This breaks the functionality of this function when
			// the widget is detached and reattached. Alas, doing this correctly with MutationObserver
			// would require observation of the whole document, which would hurt performance of other,
			// more important code.
			return;
		}

		// Find topmost node in the tree
		topmostNode = this.$element[ 0 ];
		while ( topmostNode.parentNode ) {
			topmostNode = topmostNode.parentNode;
		}

		// We have no way to detect the $element being attached somewhere without observing the entire
		// DOM with subtree modifications, which would hurt performance. So we cheat: we hook to the
		// parent node of $element, and instead detect when $element is removed from it (and thus
		// probably attached somewhere else). If there is no parent, we create a "fake" one. If it
		// doesn't get attached, we end up back here and create the parent.

		mutationObserver = new MutationObserver( function ( mutations ) {
			var i, j, removedNodes;
			for ( i = 0; i < mutations.length; i++ ) {
				removedNodes = mutations[ i ].removedNodes;
				for ( j = 0; j < removedNodes.length; j++ ) {
					if ( removedNodes[ j ] === topmostNode ) {
						setTimeout( onRemove, 0 );
						return;
					}
				}
			}
		} );

		onRemove = function () {
			// If the node was attached somewhere else, report it
			if ( widget.$element.closest( 'html' ).length ) {
				widget.onElementAttach();
			}
			mutationObserver.disconnect();
			widget.installParentChangeDetector();
		};

		// Create a fake parent and observe it
		fakeParentNode = $( '<div>' ).append( topmostNode )[ 0 ];
		mutationObserver.observe( fakeParentNode, { childList: true } );
	} else {
		// Using the DOMNodeInsertedIntoDocument event is much nicer and less magical, and works for
		// detachment and reattachment, but it's not supported by Firefox and allegedly deprecated.
		this.$element.on( 'DOMNodeInsertedIntoDocument', this.onElementAttach.bind( this ) );
	}
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
			.attr( 'rows', this.minRows )
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
 * @protected
 */
OO.ui.TextInputWidget.prototype.getInputElement = function ( config ) {
	return config.multiline ?
		$( '<textarea>' ) :
		$( '<input type="' + this.getSaneType( config ) + '" />' );
};

/**
 * Get sanitized value for 'type' for given config.
 *
 * @param {Object} config Configuration options
 * @return {string|null}
 * @private
 */
OO.ui.TextInputWidget.prototype.getSaneType = function ( config ) {
	var type = [ 'text', 'password', 'search', 'email', 'url' ].indexOf( config.type ) !== -1 ?
		config.type :
		'text';
	return config.multiline ? 'multiline' : type;
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
 * Focus the input and move the cursor to the end.
 */
OO.ui.TextInputWidget.prototype.moveCursorToEnd = function () {
	var textRange,
		element = this.$input[ 0 ];
	this.focus();
	if ( element.selectionStart !== undefined ) {
		element.selectionStart = element.selectionEnd = element.value.length;
	} else if ( element.createTextRange ) {
		// IE 8 and below
		textRange = element.createTextRange();
		textRange.collapse( false );
		textRange.select();
	}
};

/**
 * Set the validation pattern.
 *
 * The validation pattern is either a regular expression, a function, or the symbolic name of a
 * pattern defined by the class: 'non-empty' (the value cannot be an empty string) or 'integer' (the
 * value must contain only numbers).
 *
 * @param {RegExp|Function|string|null} validate Regular expression, function, or the symbolic name
 *  of a pattern (either ‘integer’ or ‘non-empty’) defined by the class.
 */
OO.ui.TextInputWidget.prototype.setValidation = function ( validate ) {
	if ( validate instanceof RegExp || validate instanceof Function ) {
		this.validate = validate;
	} else {
		this.validate = this.constructor.static.validationPatterns[ validate ] || /.*/;
	}
};

/**
 * Sets the 'invalid' flag appropriately.
 *
 * @param {boolean} [isValid] Optionally override validation result
 */
OO.ui.TextInputWidget.prototype.setValidityFlag = function ( isValid ) {
	var widget = this,
		setFlag = function ( valid ) {
			if ( !valid ) {
				widget.$input.attr( 'aria-invalid', 'true' );
			} else {
				widget.$input.removeAttr( 'aria-invalid' );
			}
			widget.setFlags( { invalid: !valid } );
		};

	if ( isValid !== undefined ) {
		setFlag( isValid );
	} else {
		this.getValidity().then( function () {
			setFlag( true );
		}, function () {
			setFlag( false );
		} );
	}
};

/**
 * Check if a value is valid.
 *
 * This method returns a promise that resolves with a boolean `true` if the current value is
 * considered valid according to the supplied {@link #validate validation pattern}.
 *
 * @deprecated
 * @return {jQuery.Promise} A promise that resolves to a boolean `true` if the value is valid.
 */
OO.ui.TextInputWidget.prototype.isValid = function () {
	var result;

	if ( this.validate instanceof Function ) {
		result = this.validate( this.getValue() );
		if ( $.isFunction( result.promise ) ) {
			return result.promise();
		} else {
			return $.Deferred().resolve( !!result ).promise();
		}
	} else {
		return $.Deferred().resolve( !!this.getValue().match( this.validate ) ).promise();
	}
};

/**
 * Get the validity of current value.
 *
 * This method returns a promise that resolves if the value is valid and rejects if
 * it isn't. Uses the {@link #validate validation pattern}  to check for validity.
 *
 * @return {jQuery.Promise} A promise that resolves if the value is valid, rejects if not.
 */
OO.ui.TextInputWidget.prototype.getValidity = function () {
	var result, promise;

	function rejectOrResolve( valid ) {
		if ( valid ) {
			return $.Deferred().resolve().promise();
		} else {
			return $.Deferred().reject().promise();
		}
	}

	if ( this.validate instanceof Function ) {
		result = this.validate( this.getValue() );

		if ( $.isFunction( result.promise ) ) {
			promise = $.Deferred();

			result.then( function ( valid ) {
				if ( valid ) {
					promise.resolve();
				} else {
					promise.reject();
				}
			}, function () {
				promise.reject();
			} );

			return promise.promise();
		} else {
			return rejectOrResolve( result );
		}
	} else {
		return rejectOrResolve( this.getValue().match( this.validate ) );
	}
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
 * @chainable
 */
OO.ui.TextInputWidget.prototype.updatePosition = function () {
	var after = this.labelPosition === 'after';

	this.$element
		.toggleClass( 'oo-ui-textInputWidget-labelPosition-after', !!this.label && after )
		.toggleClass( 'oo-ui-textInputWidget-labelPosition-before', !!this.label && !after );

	this.positionLabel();

	return this;
};

/**
 * Update the 'clear' indicator displayed on type: 'search' text fields, hiding it when the field is
 * already empty or when it's not editable.
 */
OO.ui.TextInputWidget.prototype.updateSearchIndicator = function () {
	if ( this.type === 'search' ) {
		if ( this.getValue() === '' || this.isDisabled() || this.isReadOnly() ) {
			this.setIndicator( null );
		} else {
			this.setIndicator( 'clear' );
		}
	}
};

/**
 * Position the label by setting the correct padding on the input.
 *
 * @private
 * @chainable
 */
OO.ui.TextInputWidget.prototype.positionLabel = function () {
	var after, rtl, property;
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

	after = this.labelPosition === 'after';
	rtl = this.$element.css( 'direction' ) === 'rtl';
	property = after === rtl ? 'padding-left' : 'padding-right';

	this.$input.css( property, this.$label.outerWidth( true ) );

	return this;
};

/**
 * @inheritdoc
 */
OO.ui.TextInputWidget.prototype.gatherPreInfuseState = function ( node ) {
	var
		state = OO.ui.TextInputWidget.parent.prototype.gatherPreInfuseState.call( this, node ),
		$input = $( node ).find( '.oo-ui-inputWidget-input' );
	state.$input = $input; // shortcut for performance, used in InputWidget
	if ( this.multiline ) {
		state.scrollTop = $input.scrollTop();
	}
	return state;
};

/**
 * @inheritdoc
 */
OO.ui.TextInputWidget.prototype.restorePreInfuseState = function ( state ) {
	OO.ui.TextInputWidget.parent.prototype.restorePreInfuseState.call( this, state );
	if ( state.scrollTop !== undefined ) {
		this.$input.scrollTop( state.scrollTop );
	}
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
 *     var comboBox = new OO.ui.ComboBoxWidget( {
 *         label: 'ComboBoxWidget',
 *         input: { value: 'Option One' },
 *         menu: {
 *             items: [
 *                 new OO.ui.MenuOptionWidget( {
 *                     data: 'Option 1',
 *                     label: 'Option One'
 *                 } ),
 *                 new OO.ui.MenuOptionWidget( {
 *                     data: 'Option 2',
 *                     label: 'Option Two'
 *                 } ),
 *                 new OO.ui.MenuOptionWidget( {
 *                     data: 'Option 3',
 *                     label: 'Option Three'
 *                 } ),
 *                 new OO.ui.MenuOptionWidget( {
 *                     data: 'Option 4',
 *                     label: 'Option Four'
 *                 } ),
 *                 new OO.ui.MenuOptionWidget( {
 *                     data: 'Option 5',
 *                     label: 'Option Five'
 *                 } )
 *             ]
 *         }
 *     } );
 *     $( 'body' ).append( comboBox.$element );
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Selects_and_Options#Menu_selects_and_options
 *
 * @class
 * @extends OO.ui.Widget
 * @mixins OO.ui.mixin.TabIndexedElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {Object} [menu] Configuration options to pass to the {@link OO.ui.FloatingMenuSelectWidget menu select widget}.
 * @cfg {Object} [input] Configuration options to pass to the {@link OO.ui.TextInputWidget text input widget}.
 * @cfg {jQuery} [$overlay] Render the menu into a separate layer. This configuration is useful in cases where
 *  the expanded menu is larger than its containing `<div>`. The specified overlay layer is usually on top of the
 *  containing `<div>` and has a larger area. By default, the menu uses relative positioning.
 */
OO.ui.ComboBoxWidget = function OoUiComboBoxWidget( config ) {
	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.ComboBoxWidget.parent.call( this, config );

	// Properties (must be set before TabIndexedElement constructor call)
	this.$indicator = this.$( '<span>' );

	// Mixin constructors
	OO.ui.mixin.TabIndexedElement.call( this, $.extend( {}, config, { $tabIndexed: this.$indicator } ) );

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
	this.menu = new OO.ui.FloatingMenuSelectWidget( $.extend(
		{
			widget: this,
			input: this.input,
			$container: this.input.$element,
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
OO.mixinClass( OO.ui.ComboBoxWidget, OO.ui.mixin.TabIndexedElement );

/* Methods */

/**
 * Get the combobox's menu.
 * @return {OO.ui.FloatingMenuSelectWidget} Menu widget
 */
OO.ui.ComboBoxWidget.prototype.getMenu = function () {
	return this.menu;
};

/**
 * Get the combobox's text input widget.
 * @return {OO.ui.TextInputWidget} Text input widget
 */
OO.ui.ComboBoxWidget.prototype.getInput = function () {
	return this.input;
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
		return false;
	}
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
	this.input.setValue( item.getData() );
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
	OO.ui.ComboBoxWidget.parent.prototype.setDisabled.call( this, disabled );

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
 *     var label1 = new OO.ui.LabelWidget( {
 *         label: 'plaintext label'
 *     } );
 *     var label2 = new OO.ui.LabelWidget( {
 *         label: $( '<a href="default.html">jQuery label</a>' )
 *     } );
 *     // Create a fieldset layout with fields for each example
 *     var fieldset = new OO.ui.FieldsetLayout();
 *     fieldset.addItems( [
 *         new OO.ui.FieldLayout( label1 ),
 *         new OO.ui.FieldLayout( label2 )
 *     ] );
 *     $( 'body' ).append( fieldset.$element );
 *
 *
 * @class
 * @extends OO.ui.Widget
 * @mixins OO.ui.mixin.LabelElement
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
	OO.ui.LabelWidget.parent.call( this, config );

	// Mixin constructors
	OO.ui.mixin.LabelElement.call( this, $.extend( {}, config, { $label: this.$element } ) );
	OO.ui.mixin.TitledElement.call( this, config );

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
OO.mixinClass( OO.ui.LabelWidget, OO.ui.mixin.LabelElement );
OO.mixinClass( OO.ui.LabelWidget, OO.ui.mixin.TitledElement );

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
 * @mixins OO.ui.mixin.LabelElement
 * @mixins OO.ui.mixin.FlaggedElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
OO.ui.OptionWidget = function OoUiOptionWidget( config ) {
	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.OptionWidget.parent.call( this, config );

	// Mixin constructors
	OO.ui.mixin.ItemWidget.call( this );
	OO.ui.mixin.LabelElement.call( this, config );
	OO.ui.mixin.FlaggedElement.call( this, config );

	// Properties
	this.selected = false;
	this.highlighted = false;
	this.pressed = false;

	// Initialization
	this.$element
		.data( 'oo-ui-optionWidget', this )
		.attr( 'role', 'option' )
		.attr( 'aria-selected', 'false' )
		.addClass( 'oo-ui-optionWidget' )
		.append( this.$label );
};

/* Setup */

OO.inheritClass( OO.ui.OptionWidget, OO.ui.Widget );
OO.mixinClass( OO.ui.OptionWidget, OO.ui.mixin.ItemWidget );
OO.mixinClass( OO.ui.OptionWidget, OO.ui.mixin.LabelElement );
OO.mixinClass( OO.ui.OptionWidget, OO.ui.mixin.FlaggedElement );

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
	return this.constructor.static.selectable && !this.isDisabled() && this.isVisible();
};

/**
 * Check if the option can be highlighted. A highlight indicates that the option
 * may be selected when a user presses enter or clicks. Disabled items cannot
 * be highlighted.
 *
 * @return {boolean} Item is highlightable
 */
OO.ui.OptionWidget.prototype.isHighlightable = function () {
	return this.constructor.static.highlightable && !this.isDisabled() && this.isVisible();
};

/**
 * Check if the option can be pressed. The pressed state occurs when a user mouses
 * down on an item, but has not yet let go of the mouse.
 *
 * @return {boolean} Item is pressable
 */
OO.ui.OptionWidget.prototype.isPressable = function () {
	return this.constructor.static.pressable && !this.isDisabled() && this.isVisible();
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
 * with an {@link OO.ui.mixin.IconElement icon} and/or {@link OO.ui.mixin.IndicatorElement indicator}.
 * This class is used with OO.ui.SelectWidget to create a selection of mutually exclusive
 * options. For more information about options and selects, please see the
 * [OOjs UI documentation on MediaWiki][1].
 *
 *     @example
 *     // Decorated options in a select widget
 *     var select = new OO.ui.SelectWidget( {
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
 *     $( 'body' ).append( select.$element );
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Selects_and_Options
 *
 * @class
 * @extends OO.ui.OptionWidget
 * @mixins OO.ui.mixin.IconElement
 * @mixins OO.ui.mixin.IndicatorElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
OO.ui.DecoratedOptionWidget = function OoUiDecoratedOptionWidget( config ) {
	// Parent constructor
	OO.ui.DecoratedOptionWidget.parent.call( this, config );

	// Mixin constructors
	OO.ui.mixin.IconElement.call( this, config );
	OO.ui.mixin.IndicatorElement.call( this, config );

	// Initialization
	this.$element
		.addClass( 'oo-ui-decoratedOptionWidget' )
		.prepend( this.$icon )
		.append( this.$indicator );
};

/* Setup */

OO.inheritClass( OO.ui.DecoratedOptionWidget, OO.ui.OptionWidget );
OO.mixinClass( OO.ui.DecoratedOptionWidget, OO.ui.mixin.IconElement );
OO.mixinClass( OO.ui.DecoratedOptionWidget, OO.ui.mixin.IndicatorElement );

/**
 * ButtonOptionWidget is a special type of {@link OO.ui.mixin.ButtonElement button element} that
 * can be selected and configured with data. The class is
 * used with OO.ui.ButtonSelectWidget to create a selection of button options. Please see the
 * [OOjs UI documentation on MediaWiki] [1] for more information.
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Selects_and_Options#Button_selects_and_options
 *
 * @class
 * @extends OO.ui.DecoratedOptionWidget
 * @mixins OO.ui.mixin.ButtonElement
 * @mixins OO.ui.mixin.TabIndexedElement
 * @mixins OO.ui.mixin.TitledElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
OO.ui.ButtonOptionWidget = function OoUiButtonOptionWidget( config ) {
	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.ButtonOptionWidget.parent.call( this, config );

	// Mixin constructors
	OO.ui.mixin.ButtonElement.call( this, config );
	OO.ui.mixin.TitledElement.call( this, $.extend( {}, config, { $titled: this.$button } ) );
	OO.ui.mixin.TabIndexedElement.call( this, $.extend( {}, config, {
		$tabIndexed: this.$button,
		tabIndex: -1
	} ) );

	// Initialization
	this.$element.addClass( 'oo-ui-buttonOptionWidget' );
	this.$button.append( this.$element.contents() );
	this.$element.append( this.$button );
};

/* Setup */

OO.inheritClass( OO.ui.ButtonOptionWidget, OO.ui.DecoratedOptionWidget );
OO.mixinClass( OO.ui.ButtonOptionWidget, OO.ui.mixin.ButtonElement );
OO.mixinClass( OO.ui.ButtonOptionWidget, OO.ui.mixin.TitledElement );
OO.mixinClass( OO.ui.ButtonOptionWidget, OO.ui.mixin.TabIndexedElement );

/* Static Properties */

// Allow button mouse down events to pass through so they can be handled by the parent select widget
OO.ui.ButtonOptionWidget.static.cancelButtonMouseDownEvents = false;

OO.ui.ButtonOptionWidget.static.highlightable = false;

/* Methods */

/**
 * @inheritdoc
 */
OO.ui.ButtonOptionWidget.prototype.setSelected = function ( state ) {
	OO.ui.ButtonOptionWidget.parent.prototype.setSelected.call( this, state );

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
	OO.ui.RadioOptionWidget.parent.call( this, config );

	// Events
	this.radio.$input.on( 'focus', this.onInputFocus.bind( this ) );

	// Initialization
	// Remove implicit role, we're handling it ourselves
	this.radio.$input.attr( 'role', 'presentation' );
	this.$element
		.addClass( 'oo-ui-radioOptionWidget' )
		.attr( 'role', 'radio' )
		.attr( 'aria-checked', 'false' )
		.removeAttr( 'aria-selected' )
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
 * @param {jQuery.Event} e Focus event
 * @private
 */
OO.ui.RadioOptionWidget.prototype.onInputFocus = function () {
	this.radio.$input.blur();
	this.$element.parent().focus();
};

/**
 * @inheritdoc
 */
OO.ui.RadioOptionWidget.prototype.setSelected = function ( state ) {
	OO.ui.RadioOptionWidget.parent.prototype.setSelected.call( this, state );

	this.radio.setSelected( state );
	this.$element
		.attr( 'aria-checked', state.toString() )
		.removeAttr( 'aria-selected' );

	return this;
};

/**
 * @inheritdoc
 */
OO.ui.RadioOptionWidget.prototype.setDisabled = function ( disabled ) {
	OO.ui.RadioOptionWidget.parent.prototype.setDisabled.call( this, disabled );

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
	OO.ui.MenuOptionWidget.parent.call( this, config );

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
 * MenuSectionOptionWidgets are used inside {@link OO.ui.MenuSelectWidget menu select widgets} to group one or more related
 * {@link OO.ui.MenuOptionWidget menu options}. MenuSectionOptionWidgets cannot be highlighted or selected.
 *
 *     @example
 *     var myDropdown = new OO.ui.DropdownWidget( {
 *         menu: {
 *             items: [
 *                 new OO.ui.MenuSectionOptionWidget( {
 *                     label: 'Dogs'
 *                 } ),
 *                 new OO.ui.MenuOptionWidget( {
 *                     data: 'corgi',
 *                     label: 'Welsh Corgi'
 *                 } ),
 *                 new OO.ui.MenuOptionWidget( {
 *                     data: 'poodle',
 *                     label: 'Standard Poodle'
 *                 } ),
 *                 new OO.ui.MenuSectionOptionWidget( {
 *                     label: 'Cats'
 *                 } ),
 *                 new OO.ui.MenuOptionWidget( {
 *                     data: 'lion',
 *                     label: 'Lion'
 *                 } )
 *             ]
 *         }
 *     } );
 *     $( 'body' ).append( myDropdown.$element );
 *
 *
 * @class
 * @extends OO.ui.DecoratedOptionWidget
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
OO.ui.MenuSectionOptionWidget = function OoUiMenuSectionOptionWidget( config ) {
	// Parent constructor
	OO.ui.MenuSectionOptionWidget.parent.call( this, config );

	// Initialization
	this.$element.addClass( 'oo-ui-menuSectionOptionWidget' );
};

/* Setup */

OO.inheritClass( OO.ui.MenuSectionOptionWidget, OO.ui.DecoratedOptionWidget );

/* Static Properties */

OO.ui.MenuSectionOptionWidget.static.selectable = false;

OO.ui.MenuSectionOptionWidget.static.highlightable = false;

/**
 * OutlineOptionWidget is an item in an {@link OO.ui.OutlineSelectWidget OutlineSelectWidget}.
 *
 * Currently, this class is only used by {@link OO.ui.BookletLayout booklet layouts}, which contain
 * {@link OO.ui.PageLayout page layouts}. See {@link OO.ui.BookletLayout BookletLayout}
 * for an example.
 *
 * @class
 * @extends OO.ui.DecoratedOptionWidget
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {number} [level] Indentation level
 * @cfg {boolean} [movable] Allow modification from {@link OO.ui.OutlineControlsWidget outline controls}.
 */
OO.ui.OutlineOptionWidget = function OoUiOutlineOptionWidget( config ) {
	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.OutlineOptionWidget.parent.call( this, config );

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
 * Movability is used by {@link OO.ui.OutlineControlsWidget outline controls}.
 *
 * @return {boolean} Item is movable
 */
OO.ui.OutlineOptionWidget.prototype.isMovable = function () {
	return this.movable;
};

/**
 * Check if item is removable.
 *
 * Removability is used by {@link OO.ui.OutlineControlsWidget outline controls}.
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
 * Movability is used by {@link OO.ui.OutlineControlsWidget outline controls}.
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
 * Removability is used by {@link OO.ui.OutlineControlsWidget outline controls}.
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
 * TabOptionWidget is an item in a {@link OO.ui.TabSelectWidget TabSelectWidget}.
 *
 * Currently, this class is only used by {@link OO.ui.IndexLayout index layouts}, which contain
 * {@link OO.ui.CardLayout card layouts}. See {@link OO.ui.IndexLayout IndexLayout}
 * for an example.
 *
 * @class
 * @extends OO.ui.OptionWidget
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
OO.ui.TabOptionWidget = function OoUiTabOptionWidget( config ) {
	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.TabOptionWidget.parent.call( this, config );

	// Initialization
	this.$element.addClass( 'oo-ui-tabOptionWidget' );
};

/* Setup */

OO.inheritClass( OO.ui.TabOptionWidget, OO.ui.OptionWidget );

/* Static Properties */

OO.ui.TabOptionWidget.static.highlightable = false;

/**
 * PopupWidget is a container for content. The popup is overlaid and positioned absolutely.
 * By default, each popup has an anchor that points toward its origin.
 * Please see the [OOjs UI documentation on Mediawiki] [1] for more information and examples.
 *
 *     @example
 *     // A popup widget.
 *     var popup = new OO.ui.PopupWidget( {
 *         $content: $( '<p>Hi there!</p>' ),
 *         padded: true,
 *         width: 300
 *     } );
 *
 *     $( 'body' ).append( popup.$element );
 *     // To display the popup, toggle the visibility to 'true'.
 *     popup.toggle( true );
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Popups
 *
 * @class
 * @extends OO.ui.Widget
 * @mixins OO.ui.mixin.LabelElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {number} [width=320] Width of popup in pixels
 * @cfg {number} [height] Height of popup in pixels. Omit to use the automatic height.
 * @cfg {boolean} [anchor=true] Show anchor pointing to origin of popup
 * @cfg {string} [align='center'] Alignment of the popup: `center`, `force-left`, `force-right`, `backwards` or `forwards`.
 *  If the popup is forced-left the popup body is leaning towards the left. For force-right alignment, the body of the
 *  popup is leaning towards the right of the screen.
 *  Using 'backwards' is a logical direction which will result in the popup leaning towards the beginning of the sentence
 *  in the given language, which means it will flip to the correct positioning in right-to-left languages.
 *  Using 'forward' will also result in a logical alignment where the body of the popup leans towards the end of the
 *  sentence in the given language.
 * @cfg {jQuery} [$container] Constrain the popup to the boundaries of the specified container.
 *  See the [OOjs UI docs on MediaWiki][3] for an example.
 *  [3]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Popups#containerExample
 * @cfg {number} [containerPadding=10] Padding between the popup and its container, specified as a number of pixels.
 * @cfg {jQuery} [$content] Content to append to the popup's body
 * @cfg {jQuery} [$footer] Content to append to the popup's footer
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
	OO.ui.PopupWidget.parent.call( this, config );

	// Properties (must be set before ClippableElement constructor call)
	this.$body = $( '<div>' );
	this.$popup = $( '<div>' );

	// Mixin constructors
	OO.ui.mixin.LabelElement.call( this, config );
	OO.ui.mixin.ClippableElement.call( this, $.extend( {}, config, {
		$clippable: this.$body,
		$clippableContainer: this.$popup
	} ) );

	// Properties
	this.$head = $( '<div>' );
	this.$footer = $( '<div>' );
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
	this.setAlignment( config.align );
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
	this.$footer.addClass( 'oo-ui-popupWidget-footer' );
	if ( !config.head ) {
		this.$head.addClass( 'oo-ui-element-hidden' );
	}
	if ( !config.$footer ) {
		this.$footer.addClass( 'oo-ui-element-hidden' );
	}
	this.$popup
		.addClass( 'oo-ui-popupWidget-popup' )
		.append( this.$head, this.$body, this.$footer );
	this.$element
		.addClass( 'oo-ui-popupWidget' )
		.append( this.$popup, this.$anchor );
	// Move content, which was added to #$element by OO.ui.Widget, to the body
	if ( config.$content instanceof jQuery ) {
		this.$body.append( config.$content );
	}
	if ( config.$footer instanceof jQuery ) {
		this.$footer.append( config.$footer );
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
OO.mixinClass( OO.ui.PopupWidget, OO.ui.mixin.LabelElement );
OO.mixinClass( OO.ui.PopupWidget, OO.ui.mixin.ClippableElement );

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
	OO.ui.addCaptureEventListener( this.getElementWindow(), 'mousedown', this.onMouseDownHandler );
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
	OO.ui.removeCaptureEventListener( this.getElementWindow(), 'mousedown', this.onMouseDownHandler );
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
	OO.ui.addCaptureEventListener( this.getElementWindow(), 'keydown', this.onDocumentKeyDownHandler );
};

/**
 * Unbind key down listener.
 *
 * @private
 */
OO.ui.PopupWidget.prototype.unbindKeyDownListener = function () {
	OO.ui.removeCaptureEventListener( this.getElementWindow(), 'keydown', this.onDocumentKeyDownHandler );
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
	var change;
	show = show === undefined ? !this.isVisible() : !!show;

	change = show !== this.isVisible();

	// Parent method
	OO.ui.PopupWidget.parent.prototype.toggle.call( this, show );

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
		align = this.align,
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

	// If we are in RTL, we need to flip the alignment, unless it is center
	if ( align === 'forwards' || align === 'backwards' ) {
		if ( this.$container.css( 'direction' ) === 'rtl' ) {
			align = ( { forwards: 'force-left', backwards: 'force-right' } )[ this.align ];
		} else {
			align = ( { forwards: 'force-right', backwards: 'force-left' } )[ this.align ];
		}

	}

	// Compute initial popupOffset based on alignment
	popupOffset = this.width * ( { 'force-left': -1, center: -0.5, 'force-right': 0 } )[ align ];

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
 * Set popup alignment
 * @param {string} align Alignment of the popup, `center`, `force-left`, `force-right`,
 *  `backwards` or `forwards`.
 */
OO.ui.PopupWidget.prototype.setAlignment = function ( align ) {
	// Validate alignment and transform deprecated values
	if ( [ 'left', 'right', 'force-left', 'force-right', 'backwards', 'forwards', 'center' ].indexOf( align ) > -1 ) {
		this.align = { left: 'force-right', right: 'force-left' }[ align ] || align;
	} else {
		this.align = 'center';
	}
};

/**
 * Get popup alignment
 * @return {string} align Alignment of the popup, `center`, `force-left`, `force-right`,
 *  `backwards` or `forwards`.
 */
OO.ui.PopupWidget.prototype.getAlignment = function () {
	return this.align;
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
 *     var progressBar1 = new OO.ui.ProgressBarWidget( {
 *         progress: 33
 *     } );
 *     var progressBar2 = new OO.ui.ProgressBarWidget();
 *
 *     // Create a FieldsetLayout to layout progress bars
 *     var fieldset = new OO.ui.FieldsetLayout;
 *     fieldset.addItems( [
 *        new OO.ui.FieldLayout( progressBar1, {label: 'Determinate', align: 'top'}),
 *        new OO.ui.FieldLayout( progressBar2, {label: 'Indeterminate', align: 'top'})
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
	OO.ui.ProgressBarWidget.parent.call( this, config );

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
 * SearchWidgets combine a {@link OO.ui.TextInputWidget text input field}, where users can type a search query,
 * and a menu of search results, which is displayed beneath the query
 * field. Unlike {@link OO.ui.mixin.LookupElement lookup menus}, search result menus are always visible to the user.
 * Users can choose an item from the menu or type a query into the text field to search for a matching result item.
 * In general, search widgets are used inside a separate {@link OO.ui.Dialog dialog} window.
 *
 * Each time the query is changed, the search result menu is cleared and repopulated. Please see
 * the [OOjs UI demos][1] for an example.
 *
 * [1]: https://tools.wmflabs.org/oojs-ui/oojs-ui/demos/#dialogs-mediawiki-vector-ltr
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
	OO.ui.SearchWidget.parent.call( this, config );

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

/* Methods */

/**
 * Handle query key down events.
 *
 * @private
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
 * @private
 * @param {string} value New value
 */
OO.ui.SearchWidget.prototype.onQueryChange = function () {
	// Reset
	this.results.clearItems();
};

/**
 * Handle select widget enter key events.
 *
 * Chooses highlighted item.
 *
 * @private
 * @param {string} value New value
 */
OO.ui.SearchWidget.prototype.onQueryEnter = function () {
	// Reset
	this.results.chooseItem( this.results.getHighlightedItem() );
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
 * Get the search results menu.
 *
 * @return {OO.ui.SelectWidget} Menu of search results
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
 *     var select = new OO.ui.SelectWidget( {
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
 *             } )
 *         ]
 *     } );
 *     $( 'body' ).append( select.$element );
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Selects_and_Options
 *
 * @abstract
 * @class
 * @extends OO.ui.Widget
 * @mixins OO.ui.mixin.GroupWidget
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
	OO.ui.SelectWidget.parent.call( this, config );

	// Mixin constructors
	OO.ui.mixin.GroupWidget.call( this, $.extend( {}, config, { $group: this.$element } ) );

	// Properties
	this.pressed = false;
	this.selecting = null;
	this.onMouseUpHandler = this.onMouseUp.bind( this );
	this.onMouseMoveHandler = this.onMouseMove.bind( this );
	this.onKeyDownHandler = this.onKeyDown.bind( this );
	this.onKeyPressHandler = this.onKeyPress.bind( this );
	this.keyPressBuffer = '';
	this.keyPressBufferTimer = null;

	// Events
	this.connect( this, {
		toggle: 'onToggle'
	} );
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
OO.mixinClass( OO.ui.SelectWidget, OO.ui.mixin.GroupElement );
OO.mixinClass( OO.ui.SelectWidget, OO.ui.mixin.GroupWidget );

/* Static */
OO.ui.SelectWidget.static.passAllFilter = function () {
	return true;
};

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
 * @param {OO.ui.OptionWidget} item Chosen item
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
			OO.ui.addCaptureEventListener(
				this.getElementDocument(),
				'mouseup',
				this.onMouseUpHandler
			);
			OO.ui.addCaptureEventListener(
				this.getElementDocument(),
				'mousemove',
				this.onMouseMoveHandler
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

	OO.ui.removeCaptureEventListener( this.getElementDocument(), 'mouseup',
		this.onMouseUpHandler );
	OO.ui.removeCaptureEventListener( this.getElementDocument(), 'mousemove',
		this.onMouseMoveHandler );

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
				this.clearKeyPressBuffer();
				nextItem = this.getRelativeSelectableItem( currentItem, -1 );
				handled = true;
				break;
			case OO.ui.Keys.DOWN:
			case OO.ui.Keys.RIGHT:
				this.clearKeyPressBuffer();
				nextItem = this.getRelativeSelectableItem( currentItem, 1 );
				handled = true;
				break;
			case OO.ui.Keys.ESCAPE:
			case OO.ui.Keys.TAB:
				if ( currentItem && currentItem.constructor.static.highlightable ) {
					currentItem.setHighlighted( false );
				}
				this.unbindKeyDownListener();
				this.unbindKeyPressListener();
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
	OO.ui.addCaptureEventListener( this.getElementWindow(), 'keydown', this.onKeyDownHandler );
};

/**
 * Unbind key down listener.
 *
 * @protected
 */
OO.ui.SelectWidget.prototype.unbindKeyDownListener = function () {
	OO.ui.removeCaptureEventListener( this.getElementWindow(), 'keydown', this.onKeyDownHandler );
};

/**
 * Clear the key-press buffer
 *
 * @protected
 */
OO.ui.SelectWidget.prototype.clearKeyPressBuffer = function () {
	if ( this.keyPressBufferTimer ) {
		clearTimeout( this.keyPressBufferTimer );
		this.keyPressBufferTimer = null;
	}
	this.keyPressBuffer = '';
};

/**
 * Handle key press events.
 *
 * @protected
 * @param {jQuery.Event} e Key press event
 */
OO.ui.SelectWidget.prototype.onKeyPress = function ( e ) {
	var c, filter, item;

	if ( !e.charCode ) {
		if ( e.keyCode === OO.ui.Keys.BACKSPACE && this.keyPressBuffer !== '' ) {
			this.keyPressBuffer = this.keyPressBuffer.substr( 0, this.keyPressBuffer.length - 1 );
			return false;
		}
		return;
	}
	if ( String.fromCodePoint ) {
		c = String.fromCodePoint( e.charCode );
	} else {
		c = String.fromCharCode( e.charCode );
	}

	if ( this.keyPressBufferTimer ) {
		clearTimeout( this.keyPressBufferTimer );
	}
	this.keyPressBufferTimer = setTimeout( this.clearKeyPressBuffer.bind( this ), 1500 );

	item = this.getHighlightedItem() || this.getSelectedItem();

	if ( this.keyPressBuffer === c ) {
		// Common (if weird) special case: typing "xxxx" will cycle through all
		// the items beginning with "x".
		if ( item ) {
			item = this.getRelativeSelectableItem( item, 1 );
		}
	} else {
		this.keyPressBuffer += c;
	}

	filter = this.getItemMatcher( this.keyPressBuffer, false );
	if ( !item || !filter( item ) ) {
		item = this.getRelativeSelectableItem( item, 1, filter );
	}
	if ( item ) {
		if ( item.constructor.static.highlightable ) {
			this.highlightItem( item );
		} else {
			this.chooseItem( item );
		}
		item.scrollElementIntoView();
	}

	return false;
};

/**
 * Get a matcher for the specific string
 *
 * @protected
 * @param {string} s String to match against items
 * @param {boolean} [exact=false] Only accept exact matches
 * @return {Function} function ( OO.ui.OptionItem ) => boolean
 */
OO.ui.SelectWidget.prototype.getItemMatcher = function ( s, exact ) {
	var re;

	if ( s.normalize ) {
		s = s.normalize();
	}
	s = exact ? s.trim() : s.replace( /^\s+/, '' );
	re = '^\\s*' + s.replace( /([\\{}()|.?*+\-\^$\[\]])/g, '\\$1' ).replace( /\s+/g, '\\s+' );
	if ( exact ) {
		re += '\\s*$';
	}
	re = new RegExp( re, 'i' );
	return function ( item ) {
		var l = item.getLabel();
		if ( typeof l !== 'string' ) {
			l = item.$label.text();
		}
		if ( l.normalize ) {
			l = l.normalize();
		}
		return re.test( l );
	};
};

/**
 * Bind key press listener.
 *
 * @protected
 */
OO.ui.SelectWidget.prototype.bindKeyPressListener = function () {
	OO.ui.addCaptureEventListener( this.getElementWindow(), 'keypress', this.onKeyPressHandler );
};

/**
 * Unbind key down listener.
 *
 * If you override this, be sure to call this.clearKeyPressBuffer() from your
 * implementation.
 *
 * @protected
 */
OO.ui.SelectWidget.prototype.unbindKeyPressListener = function () {
	OO.ui.removeCaptureEventListener( this.getElementWindow(), 'keypress', this.onKeyPressHandler );
	this.clearKeyPressBuffer();
};

/**
 * Visibility change handler
 *
 * @protected
 * @param {boolean} visible
 */
OO.ui.SelectWidget.prototype.onToggle = function ( visible ) {
	if ( !visible ) {
		this.clearKeyPressBuffer();
	}
};

/**
 * Get the closest item to a jQuery.Event.
 *
 * @private
 * @param {jQuery.Event} e
 * @return {OO.ui.OptionWidget|null} Outline item widget, `null` if none was found
 */
OO.ui.SelectWidget.prototype.getTargetItem = function ( e ) {
	return $( e.target ).closest( '.oo-ui-optionWidget' ).data( 'oo-ui-optionWidget' ) || null;
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
 * Fetch an item by its label.
 *
 * @param {string} label Label of the item to select.
 * @param {boolean} [prefix=false] Allow a prefix match, if only a single item matches
 * @return {OO.ui.Element|null} Item with equivalent label, `null` if none exists
 */
OO.ui.SelectWidget.prototype.getItemFromLabel = function ( label, prefix ) {
	var i, item, found,
		len = this.items.length,
		filter = this.getItemMatcher( label, true );

	for ( i = 0; i < len; i++ ) {
		item = this.items[ i ];
		if ( item instanceof OO.ui.OptionWidget && item.isSelectable() && filter( item ) ) {
			return item;
		}
	}

	if ( prefix ) {
		found = null;
		filter = this.getItemMatcher( label, false );
		for ( i = 0; i < len; i++ ) {
			item = this.items[ i ];
			if ( item instanceof OO.ui.OptionWidget && item.isSelectable() && filter( item ) ) {
				if ( found ) {
					return null;
				}
				found = item;
			}
		}
		if ( found ) {
			return found;
		}
	}

	return null;
};

/**
 * Programmatically select an option by its label. If the item does not exist,
 * all options will be deselected.
 *
 * @param {string} [label] Label of the item to select.
 * @param {boolean} [prefix=false] Allow a prefix match, if only a single item matches
 * @fires select
 * @chainable
 */
OO.ui.SelectWidget.prototype.selectItemByLabel = function ( label, prefix ) {
	var itemFromLabel = this.getItemFromLabel( label, !!prefix );
	if ( label === undefined || !itemFromLabel ) {
		return this.selectItem();
	}
	return this.selectItem( itemFromLabel );
};

/**
 * Programmatically select an option by its data. If the `data` parameter is omitted,
 * or if the item does not exist, all options will be deselected.
 *
 * @param {Object|string} [data] Value of the item to select, omit to deselect all
 * @fires select
 * @chainable
 */
OO.ui.SelectWidget.prototype.selectItemByData = function ( data ) {
	var itemFromData = this.getItemFromData( data );
	if ( data === undefined || !itemFromData ) {
		return this.selectItem();
	}
	return this.selectItem( itemFromData );
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
 * @param {Function} filter Only consider items for which this function returns
 *  true. Function takes an OO.ui.OptionWidget and returns a boolean.
 * @return {OO.ui.OptionWidget|null} Item at position, `null` if there are no items in the select
 */
OO.ui.SelectWidget.prototype.getRelativeSelectableItem = function ( item, direction, filter ) {
	var currentIndex, nextIndex, i,
		increase = direction > 0 ? 1 : -1,
		len = this.items.length;

	if ( !$.isFunction( filter ) ) {
		filter = OO.ui.SelectWidget.static.passAllFilter;
	}

	if ( item instanceof OO.ui.OptionWidget ) {
		currentIndex = this.items.indexOf( item );
		nextIndex = ( currentIndex + increase + len ) % len;
	} else {
		// If no item is selected and moving forward, start at the beginning.
		// If moving backward, start at the end.
		nextIndex = direction > 0 ? 0 : len - 1;
	}

	for ( i = 0; i < len; i++ ) {
		item = this.items[ nextIndex ];
		if ( item instanceof OO.ui.OptionWidget && item.isSelectable() && filter( item ) ) {
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
	OO.ui.mixin.GroupWidget.prototype.addItems.call( this, items, index );

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
	OO.ui.mixin.GroupWidget.prototype.removeItems.call( this, items );

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
	OO.ui.mixin.GroupWidget.prototype.clearItems.call( this );

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
 *         title: 'Button option 1'
 *     } );
 *
 *     var option2 = new OO.ui.ButtonOptionWidget( {
 *         data: 2,
 *         label: 'Option 2',
 *         title: 'Button option 2'
 *     } );
 *
 *     var option3 = new OO.ui.ButtonOptionWidget( {
 *         data: 3,
 *         label: 'Option 3',
 *         title: 'Button option 3'
 *     } );
 *
 *     var buttonSelect=new OO.ui.ButtonSelectWidget( {
 *         items: [ option1, option2, option3 ]
 *     } );
 *     $( 'body' ).append( buttonSelect.$element );
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Selects_and_Options
 *
 * @class
 * @extends OO.ui.SelectWidget
 * @mixins OO.ui.mixin.TabIndexedElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
OO.ui.ButtonSelectWidget = function OoUiButtonSelectWidget( config ) {
	// Parent constructor
	OO.ui.ButtonSelectWidget.parent.call( this, config );

	// Mixin constructors
	OO.ui.mixin.TabIndexedElement.call( this, config );

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
OO.mixinClass( OO.ui.ButtonSelectWidget, OO.ui.mixin.TabIndexedElement );

/**
 * RadioSelectWidget is a {@link OO.ui.SelectWidget select widget} that contains radio
 * options and is used together with OO.ui.RadioOptionWidget. The RadioSelectWidget provides
 * an interface for adding, removing and selecting options.
 * Please see the [OOjs UI documentation on MediaWiki][1] for more information.
 *
 * If you want to use this within a HTML form, such as a OO.ui.FormLayout, use
 * OO.ui.RadioSelectInputWidget instead.
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
 *         items: [ option1, option2 ]
 *      } );
 *
 *     // Select 'option 1' using the RadioSelectWidget's selectItem() method.
 *     radioSelect.selectItem( option1 );
 *
 *     $( 'body' ).append( radioSelect.$element );
 *
 * [1]: https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Selects_and_Options

 *
 * @class
 * @extends OO.ui.SelectWidget
 * @mixins OO.ui.mixin.TabIndexedElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
OO.ui.RadioSelectWidget = function OoUiRadioSelectWidget( config ) {
	// Parent constructor
	OO.ui.RadioSelectWidget.parent.call( this, config );

	// Mixin constructors
	OO.ui.mixin.TabIndexedElement.call( this, config );

	// Events
	this.$element.on( {
		focus: this.bindKeyDownListener.bind( this ),
		blur: this.unbindKeyDownListener.bind( this )
	} );

	// Initialization
	this.$element
		.addClass( 'oo-ui-radioSelectWidget' )
		.attr( 'role', 'radiogroup' );
};

/* Setup */

OO.inheritClass( OO.ui.RadioSelectWidget, OO.ui.SelectWidget );
OO.mixinClass( OO.ui.RadioSelectWidget, OO.ui.mixin.TabIndexedElement );

/**
 * MenuSelectWidget is a {@link OO.ui.SelectWidget select widget} that contains options and
 * is used together with OO.ui.MenuOptionWidget. It is designed be used as part of another widget.
 * See {@link OO.ui.DropdownWidget DropdownWidget}, {@link OO.ui.ComboBoxWidget ComboBoxWidget},
 * and {@link OO.ui.mixin.LookupElement LookupElement} for examples of widgets that contain menus.
 * MenuSelectWidgets themselves are not instantiated directly, rather subclassed
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
 * @mixins OO.ui.mixin.ClippableElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {OO.ui.TextInputWidget} [input] Text input used to implement option highlighting for menu items that match
 *  the text the user types. This config is used by {@link OO.ui.ComboBoxWidget ComboBoxWidget}
 *  and {@link OO.ui.mixin.LookupElement LookupElement}
 * @cfg {jQuery} [$input] Text input used to implement option highlighting for menu items that match
 *  the text the user types. This config is used by {@link OO.ui.CapsuleMultiSelectWidget CapsuleMultiSelectWidget}
 * @cfg {OO.ui.Widget} [widget] Widget associated with the menu's active state. If the user clicks the mouse
 *  anywhere on the page outside of this widget, the menu is hidden. For example, if there is a button
 *  that toggles the menu's visibility on click, the menu will be hidden then re-shown when the user clicks
 *  that button, unless the button (or its parent widget) is passed in here.
 * @cfg {boolean} [autoHide=true] Hide the menu when the mouse is pressed outside the menu.
 * @cfg {boolean} [filterFromInput=false] Filter the displayed options from the input
 */
OO.ui.MenuSelectWidget = function OoUiMenuSelectWidget( config ) {
	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.MenuSelectWidget.parent.call( this, config );

	// Mixin constructors
	OO.ui.mixin.ClippableElement.call( this, $.extend( {}, config, { $clippable: this.$group } ) );

	// Properties
	this.newItems = null;
	this.autoHide = config.autoHide === undefined || !!config.autoHide;
	this.filterFromInput = !!config.filterFromInput;
	this.$input = config.$input ? config.$input : config.input ? config.input.$input : null;
	this.$widget = config.widget ? config.widget.$element : null;
	this.onDocumentMouseDownHandler = this.onDocumentMouseDown.bind( this );
	this.onInputEditHandler = OO.ui.debounce( this.updateItemVisibility.bind( this ), 100 );

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
OO.mixinClass( OO.ui.MenuSelectWidget, OO.ui.mixin.ClippableElement );

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
					OO.ui.MenuSelectWidget.parent.prototype.onKeyDown.call( this, e );
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
				OO.ui.MenuSelectWidget.parent.prototype.onKeyDown.call( this, e );
				return;
		}
	}
};

/**
 * Update menu item visibility after input changes.
 * @protected
 */
OO.ui.MenuSelectWidget.prototype.updateItemVisibility = function () {
	var i, item,
		len = this.items.length,
		showAll = !this.isVisible(),
		filter = showAll ? null : this.getItemMatcher( this.$input.val() );

	for ( i = 0; i < len; i++ ) {
		item = this.items[ i ];
		if ( item instanceof OO.ui.OptionWidget ) {
			item.toggle( showAll || filter( item ) );
		}
	}

	// Reevaluate clipping
	this.clip();
};

/**
 * @inheritdoc
 */
OO.ui.MenuSelectWidget.prototype.bindKeyDownListener = function () {
	if ( this.$input ) {
		this.$input.on( 'keydown', this.onKeyDownHandler );
	} else {
		OO.ui.MenuSelectWidget.parent.prototype.bindKeyDownListener.call( this );
	}
};

/**
 * @inheritdoc
 */
OO.ui.MenuSelectWidget.prototype.unbindKeyDownListener = function () {
	if ( this.$input ) {
		this.$input.off( 'keydown', this.onKeyDownHandler );
	} else {
		OO.ui.MenuSelectWidget.parent.prototype.unbindKeyDownListener.call( this );
	}
};

/**
 * @inheritdoc
 */
OO.ui.MenuSelectWidget.prototype.bindKeyPressListener = function () {
	if ( this.$input ) {
		if ( this.filterFromInput ) {
			this.$input.on( 'keydown mouseup cut paste change input select', this.onInputEditHandler );
		}
	} else {
		OO.ui.MenuSelectWidget.parent.prototype.bindKeyPressListener.call( this );
	}
};

/**
 * @inheritdoc
 */
OO.ui.MenuSelectWidget.prototype.unbindKeyPressListener = function () {
	if ( this.$input ) {
		if ( this.filterFromInput ) {
			this.$input.off( 'keydown mouseup cut paste change input select', this.onInputEditHandler );
			this.updateItemVisibility();
		}
	} else {
		OO.ui.MenuSelectWidget.parent.prototype.unbindKeyPressListener.call( this );
	}
};

/**
 * Choose an item.
 *
 * When a user chooses an item, the menu is closed.
 *
 * Note that ‘choose’ should never be modified programmatically. A user can choose an option with the keyboard
 * or mouse and it becomes selected. To select an item programmatically, use the #selectItem method.
 * @param {OO.ui.OptionWidget} item Item to choose
 * @chainable
 */
OO.ui.MenuSelectWidget.prototype.chooseItem = function ( item ) {
	OO.ui.MenuSelectWidget.parent.prototype.chooseItem.call( this, item );
	this.toggle( false );
	return this;
};

/**
 * @inheritdoc
 */
OO.ui.MenuSelectWidget.prototype.addItems = function ( items, index ) {
	var i, len, item;

	// Parent method
	OO.ui.MenuSelectWidget.parent.prototype.addItems.call( this, items, index );

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
	OO.ui.MenuSelectWidget.parent.prototype.removeItems.call( this, items );

	// Reevaluate clipping
	this.clip();

	return this;
};

/**
 * @inheritdoc
 */
OO.ui.MenuSelectWidget.prototype.clearItems = function () {
	// Parent method
	OO.ui.MenuSelectWidget.parent.prototype.clearItems.call( this );

	// Reevaluate clipping
	this.clip();

	return this;
};

/**
 * @inheritdoc
 */
OO.ui.MenuSelectWidget.prototype.toggle = function ( visible ) {
	var i, len, change;

	visible = ( visible === undefined ? !this.visible : !!visible ) && !!this.items.length;
	change = visible !== this.isVisible();

	// Parent method
	OO.ui.MenuSelectWidget.parent.prototype.toggle.call( this, visible );

	if ( change ) {
		if ( visible ) {
			this.bindKeyDownListener();
			this.bindKeyPressListener();

			if ( this.newItems && this.newItems.length ) {
				for ( i = 0, len = this.newItems.length; i < len; i++ ) {
					this.newItems[ i ].fitLabel();
				}
				this.newItems = null;
			}
			this.toggleClipping( true );

			// Auto-hide
			if ( this.autoHide ) {
				OO.ui.addCaptureEventListener( this.getElementDocument(), 'mousedown', this.onDocumentMouseDownHandler );
			}
		} else {
			this.unbindKeyDownListener();
			this.unbindKeyPressListener();
			OO.ui.removeCaptureEventListener( this.getElementDocument(), 'mousedown', this.onDocumentMouseDownHandler );
			this.toggleClipping( false );
		}
	}

	return this;
};

/**
 * FloatingMenuSelectWidget is a menu that will stick under a specified
 * container, even when it is inserted elsewhere in the document (for example,
 * in a OO.ui.Window's $overlay). This is sometimes necessary to prevent the
 * menu from being clipped too aggresively.
 *
 * The menu's position is automatically calculated and maintained when the menu
 * is toggled or the window is resized.
 *
 * See OO.ui.ComboBoxWidget for an example of a widget that uses this class.
 *
 * @class
 * @extends OO.ui.MenuSelectWidget
 *
 * @constructor
 * @param {OO.ui.Widget} [inputWidget] Widget to provide the menu for.
 *   Deprecated, omit this parameter and specify `$container` instead.
 * @param {Object} [config] Configuration options
 * @cfg {jQuery} [$container=inputWidget.$element] Element to render menu under
 */
OO.ui.FloatingMenuSelectWidget = function OoUiFloatingMenuSelectWidget( inputWidget, config ) {
	// Allow 'inputWidget' parameter and config for backwards compatibility
	if ( OO.isPlainObject( inputWidget ) && config === undefined ) {
		config = inputWidget;
		inputWidget = config.inputWidget;
	}

	// Configuration initialization
	config = config || {};

	// Parent constructor
	OO.ui.FloatingMenuSelectWidget.parent.call( this, config );

	// Properties
	this.inputWidget = inputWidget; // For backwards compatibility
	this.$container = config.$container || this.inputWidget.$element;
	this.onWindowResizeHandler = this.onWindowResize.bind( this );

	// Initialization
	this.$element.addClass( 'oo-ui-floatingMenuSelectWidget' );
	// For backwards compatibility
	this.$element.addClass( 'oo-ui-textInputMenuSelectWidget' );
};

/* Setup */

OO.inheritClass( OO.ui.FloatingMenuSelectWidget, OO.ui.MenuSelectWidget );

// For backwards compatibility
OO.ui.TextInputMenuSelectWidget = OO.ui.FloatingMenuSelectWidget;

/* Methods */

/**
 * Handle window resize event.
 *
 * @private
 * @param {jQuery.Event} e Window resize event
 */
OO.ui.FloatingMenuSelectWidget.prototype.onWindowResize = function () {
	this.position();
};

/**
 * @inheritdoc
 */
OO.ui.FloatingMenuSelectWidget.prototype.toggle = function ( visible ) {
	var change;
	visible = visible === undefined ? !this.isVisible() : !!visible;

	change = visible !== this.isVisible();

	if ( change && visible ) {
		// Make sure the width is set before the parent method runs.
		// After this we have to call this.position(); again to actually
		// position ourselves correctly.
		this.position();
	}

	// Parent method
	OO.ui.FloatingMenuSelectWidget.parent.prototype.toggle.call( this, visible );

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
 * @private
 * @chainable
 */
OO.ui.FloatingMenuSelectWidget.prototype.position = function () {
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
 * OutlineSelectWidget is a structured list that contains {@link OO.ui.OutlineOptionWidget outline options}
 * A set of controls can be provided with an {@link OO.ui.OutlineControlsWidget outline controls} widget.
 *
 * **Currently, this class is only used by {@link OO.ui.BookletLayout booklet layouts}.**
 *
 * @class
 * @extends OO.ui.SelectWidget
 * @mixins OO.ui.mixin.TabIndexedElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
OO.ui.OutlineSelectWidget = function OoUiOutlineSelectWidget( config ) {
	// Parent constructor
	OO.ui.OutlineSelectWidget.parent.call( this, config );

	// Mixin constructors
	OO.ui.mixin.TabIndexedElement.call( this, config );

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
OO.mixinClass( OO.ui.OutlineSelectWidget, OO.ui.mixin.TabIndexedElement );

/**
 * TabSelectWidget is a list that contains {@link OO.ui.TabOptionWidget tab options}
 *
 * **Currently, this class is only used by {@link OO.ui.IndexLayout index layouts}.**
 *
 * @class
 * @extends OO.ui.SelectWidget
 * @mixins OO.ui.mixin.TabIndexedElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 */
OO.ui.TabSelectWidget = function OoUiTabSelectWidget( config ) {
	// Parent constructor
	OO.ui.TabSelectWidget.parent.call( this, config );

	// Mixin constructors
	OO.ui.mixin.TabIndexedElement.call( this, config );

	// Events
	this.$element.on( {
		focus: this.bindKeyDownListener.bind( this ),
		blur: this.unbindKeyDownListener.bind( this )
	} );

	// Initialization
	this.$element.addClass( 'oo-ui-tabSelectWidget' );
};

/* Setup */

OO.inheritClass( OO.ui.TabSelectWidget, OO.ui.SelectWidget );
OO.mixinClass( OO.ui.TabSelectWidget, OO.ui.mixin.TabIndexedElement );

/**
 * NumberInputWidgets combine a {@link OO.ui.TextInputWidget text input} (where a value
 * can be entered manually) and two {@link OO.ui.ButtonWidget button widgets}
 * (to adjust the value in increments) to allow the user to enter a number.
 *
 *     @example
 *     // Example: A NumberInputWidget.
 *     var numberInput = new OO.ui.NumberInputWidget( {
 *         label: 'NumberInputWidget',
 *         input: { value: 5, min: 1, max: 10 }
 *     } );
 *     $( 'body' ).append( numberInput.$element );
 *
 * @class
 * @extends OO.ui.Widget
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {Object} [input] Configuration options to pass to the {@link OO.ui.TextInputWidget text input widget}.
 * @cfg {Object} [minusButton] Configuration options to pass to the {@link OO.ui.ButtonWidget decrementing button widget}.
 * @cfg {Object} [plusButton] Configuration options to pass to the {@link OO.ui.ButtonWidget incrementing button widget}.
 * @cfg {boolean} [isInteger=false] Whether the field accepts only integer values.
 * @cfg {number} [min=-Infinity] Minimum allowed value
 * @cfg {number} [max=Infinity] Maximum allowed value
 * @cfg {number} [step=1] Delta when using the buttons or up/down arrow keys
 * @cfg {number|null} [pageStep] Delta when using the page-up/page-down keys. Defaults to 10 times #step.
 */
OO.ui.NumberInputWidget = function OoUiNumberInputWidget( config ) {
	// Configuration initialization
	config = $.extend( {
		isInteger: false,
		min: -Infinity,
		max: Infinity,
		step: 1,
		pageStep: null
	}, config );

	// Parent constructor
	OO.ui.NumberInputWidget.parent.call( this, config );

	// Properties
	this.input = new OO.ui.TextInputWidget( $.extend(
		{
			disabled: this.isDisabled()
		},
		config.input
	) );
	this.minusButton = new OO.ui.ButtonWidget( $.extend(
		{
			disabled: this.isDisabled(),
			tabIndex: -1
		},
		config.minusButton,
		{
			classes: [ 'oo-ui-numberInputWidget-minusButton' ],
			label: '−'
		}
	) );
	this.plusButton = new OO.ui.ButtonWidget( $.extend(
		{
			disabled: this.isDisabled(),
			tabIndex: -1
		},
		config.plusButton,
		{
			classes: [ 'oo-ui-numberInputWidget-plusButton' ],
			label: '+'
		}
	) );

	// Events
	this.input.connect( this, {
		change: this.emit.bind( this, 'change' ),
		enter: this.emit.bind( this, 'enter' )
	} );
	this.input.$input.on( {
		keydown: this.onKeyDown.bind( this ),
		'wheel mousewheel DOMMouseScroll': this.onWheel.bind( this )
	} );
	this.plusButton.connect( this, {
		click: [ 'onButtonClick', +1 ]
	} );
	this.minusButton.connect( this, {
		click: [ 'onButtonClick', -1 ]
	} );

	// Initialization
	this.setIsInteger( !!config.isInteger );
	this.setRange( config.min, config.max );
	this.setStep( config.step, config.pageStep );

	this.$field = $( '<div>' ).addClass( 'oo-ui-numberInputWidget-field' )
		.append(
			this.minusButton.$element,
			this.input.$element,
			this.plusButton.$element
		);
	this.$element.addClass( 'oo-ui-numberInputWidget' ).append( this.$field );
	this.input.setValidation( this.validateNumber.bind( this ) );
};

/* Setup */

OO.inheritClass( OO.ui.NumberInputWidget, OO.ui.Widget );

/* Events */

/**
 * A `change` event is emitted when the value of the input changes.
 *
 * @event change
 */

/**
 * An `enter` event is emitted when the user presses 'enter' inside the text box.
 *
 * @event enter
 */

/* Methods */

/**
 * Set whether only integers are allowed
 * @param {boolean} flag
 */
OO.ui.NumberInputWidget.prototype.setIsInteger = function ( flag ) {
	this.isInteger = !!flag;
	this.input.setValidityFlag();
};

/**
 * Get whether only integers are allowed
 * @return {boolean} Flag value
 */
OO.ui.NumberInputWidget.prototype.getIsInteger = function () {
	return this.isInteger;
};

/**
 * Set the range of allowed values
 * @param {number} min Minimum allowed value
 * @param {number} max Maximum allowed value
 */
OO.ui.NumberInputWidget.prototype.setRange = function ( min, max ) {
	if ( min > max ) {
		throw new Error( 'Minimum (' + min + ') must not be greater than maximum (' + max + ')' );
	}
	this.min = min;
	this.max = max;
	this.input.setValidityFlag();
};

/**
 * Get the current range
 * @return {number[]} Minimum and maximum values
 */
OO.ui.NumberInputWidget.prototype.getRange = function () {
	return [ this.min, this.max ];
};

/**
 * Set the stepping deltas
 * @param {number} step Normal step
 * @param {number|null} pageStep Page step. If null, 10 * step will be used.
 */
OO.ui.NumberInputWidget.prototype.setStep = function ( step, pageStep ) {
	if ( step <= 0 ) {
		throw new Error( 'Step value must be positive' );
	}
	if ( pageStep === null ) {
		pageStep = step * 10;
	} else if ( pageStep <= 0 ) {
		throw new Error( 'Page step value must be positive' );
	}
	this.step = step;
	this.pageStep = pageStep;
};

/**
 * Get the current stepping values
 * @return {number[]} Step and page step
 */
OO.ui.NumberInputWidget.prototype.getStep = function () {
	return [ this.step, this.pageStep ];
};

/**
 * Get the current value of the widget
 * @return {string}
 */
OO.ui.NumberInputWidget.prototype.getValue = function () {
	return this.input.getValue();
};

/**
 * Get the current value of the widget as a number
 * @return {number} May be NaN, or an invalid number
 */
OO.ui.NumberInputWidget.prototype.getNumericValue = function () {
	return +this.input.getValue();
};

/**
 * Set the value of the widget
 * @param {string} value Invalid values are allowed
 */
OO.ui.NumberInputWidget.prototype.setValue = function ( value ) {
	this.input.setValue( value );
};

/**
 * Adjust the value of the widget
 * @param {number} delta Adjustment amount
 */
OO.ui.NumberInputWidget.prototype.adjustValue = function ( delta ) {
	var n, v = this.getNumericValue();

	delta = +delta;
	if ( isNaN( delta ) || !isFinite( delta ) ) {
		throw new Error( 'Delta must be a finite number' );
	}

	if ( isNaN( v ) ) {
		n = 0;
	} else {
		n = v + delta;
		n = Math.max( Math.min( n, this.max ), this.min );
		if ( this.isInteger ) {
			n = Math.round( n );
		}
	}

	if ( n !== v ) {
		this.setValue( n );
	}
};

/**
 * Validate input
 * @private
 * @param {string} value Field value
 * @return {boolean}
 */
OO.ui.NumberInputWidget.prototype.validateNumber = function ( value ) {
	var n = +value;
	if ( isNaN( n ) || !isFinite( n ) ) {
		return false;
	}

	/*jshint bitwise: false */
	if ( this.isInteger && ( n | 0 ) !== n ) {
		return false;
	}
	/*jshint bitwise: true */

	if ( n < this.min || n > this.max ) {
		return false;
	}

	return true;
};

/**
 * Handle mouse click events.
 *
 * @private
 * @param {number} dir +1 or -1
 */
OO.ui.NumberInputWidget.prototype.onButtonClick = function ( dir ) {
	this.adjustValue( dir * this.step );
};

/**
 * Handle mouse wheel events.
 *
 * @private
 * @param {jQuery.Event} event
 */
OO.ui.NumberInputWidget.prototype.onWheel = function ( event ) {
	var delta = 0;

	// Standard 'wheel' event
	if ( event.originalEvent.deltaMode !== undefined ) {
		this.sawWheelEvent = true;
	}
	if ( event.originalEvent.deltaY ) {
		delta = -event.originalEvent.deltaY;
	} else if ( event.originalEvent.deltaX ) {
		delta = event.originalEvent.deltaX;
	}

	// Non-standard events
	if ( !this.sawWheelEvent ) {
		if ( event.originalEvent.wheelDeltaX ) {
			delta = -event.originalEvent.wheelDeltaX;
		} else if ( event.originalEvent.wheelDeltaY ) {
			delta = event.originalEvent.wheelDeltaY;
		} else if ( event.originalEvent.wheelDelta ) {
			delta = event.originalEvent.wheelDelta;
		} else if ( event.originalEvent.detail ) {
			delta = -event.originalEvent.detail;
		}
	}

	if ( delta ) {
		delta = delta < 0 ? -1 : 1;
		this.adjustValue( delta * this.step );
	}

	return false;
};

/**
 * Handle key down events.
 *
 *
 * @private
 * @param {jQuery.Event} e Key down event
 */
OO.ui.NumberInputWidget.prototype.onKeyDown = function ( e ) {
	if ( !this.isDisabled() ) {
		switch ( e.which ) {
			case OO.ui.Keys.UP:
				this.adjustValue( this.step );
				return false;
			case OO.ui.Keys.DOWN:
				this.adjustValue( -this.step );
				return false;
			case OO.ui.Keys.PAGEUP:
				this.adjustValue( this.pageStep );
				return false;
			case OO.ui.Keys.PAGEDOWN:
				this.adjustValue( -this.pageStep );
				return false;
		}
	}
};

/**
 * @inheritdoc
 */
OO.ui.NumberInputWidget.prototype.setDisabled = function ( disabled ) {
	// Parent method
	OO.ui.NumberInputWidget.parent.prototype.setDisabled.call( this, disabled );

	if ( this.input ) {
		this.input.setDisabled( this.isDisabled() );
	}
	if ( this.minusButton ) {
		this.minusButton.setDisabled( this.isDisabled() );
	}
	if ( this.plusButton ) {
		this.plusButton.setDisabled( this.isDisabled() );
	}

	return this;
};

/**
 * ToggleSwitches are switches that slide on and off. Their state is represented by a Boolean
 * value (`true` for ‘on’, and `false` otherwise, the default). The ‘off’ state is represented
 * visually by a slider in the leftmost position.
 *
 *     @example
 *     // Toggle switches in the 'off' and 'on' position.
 *     var toggleSwitch1 = new OO.ui.ToggleSwitchWidget();
 *     var toggleSwitch2 = new OO.ui.ToggleSwitchWidget( {
 *         value: true
 *     } );
 *
 *     // Create a FieldsetLayout to layout and label switches
 *     var fieldset = new OO.ui.FieldsetLayout( {
 *        label: 'Toggle switches'
 *     } );
 *     fieldset.addItems( [
 *         new OO.ui.FieldLayout( toggleSwitch1, { label: 'Off', align: 'top' } ),
 *         new OO.ui.FieldLayout( toggleSwitch2, { label: 'On', align: 'top' } )
 *     ] );
 *     $( 'body' ).append( fieldset.$element );
 *
 * @class
 * @extends OO.ui.ToggleWidget
 * @mixins OO.ui.mixin.TabIndexedElement
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {boolean} [value=false] The toggle switch’s initial on/off state.
 *  By default, the toggle switch is in the 'off' position.
 */
OO.ui.ToggleSwitchWidget = function OoUiToggleSwitchWidget( config ) {
	// Parent constructor
	OO.ui.ToggleSwitchWidget.parent.call( this, config );

	// Mixin constructors
	OO.ui.mixin.TabIndexedElement.call( this, config );

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

OO.inheritClass( OO.ui.ToggleSwitchWidget, OO.ui.ToggleWidget );
OO.mixinClass( OO.ui.ToggleSwitchWidget, OO.ui.mixin.TabIndexedElement );

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
		return false;
	}
};

/*!
 * Deprecated aliases for classes in the `OO.ui.mixin` namespace.
 */

/**
 * @inheritdoc OO.ui.mixin.ButtonElement
 * @deprecated Use {@link OO.ui.mixin.ButtonElement} instead.
 */
OO.ui.ButtonElement = OO.ui.mixin.ButtonElement;

/**
 * @inheritdoc OO.ui.mixin.ClippableElement
 * @deprecated Use {@link OO.ui.mixin.ClippableElement} instead.
 */
OO.ui.ClippableElement = OO.ui.mixin.ClippableElement;

/**
 * @inheritdoc OO.ui.mixin.DraggableElement
 * @deprecated Use {@link OO.ui.mixin.DraggableElement} instead.
 */
OO.ui.DraggableElement = OO.ui.mixin.DraggableElement;

/**
 * @inheritdoc OO.ui.mixin.DraggableGroupElement
 * @deprecated Use {@link OO.ui.mixin.DraggableGroupElement} instead.
 */
OO.ui.DraggableGroupElement = OO.ui.mixin.DraggableGroupElement;

/**
 * @inheritdoc OO.ui.mixin.FlaggedElement
 * @deprecated Use {@link OO.ui.mixin.FlaggedElement} instead.
 */
OO.ui.FlaggedElement = OO.ui.mixin.FlaggedElement;

/**
 * @inheritdoc OO.ui.mixin.GroupElement
 * @deprecated Use {@link OO.ui.mixin.GroupElement} instead.
 */
OO.ui.GroupElement = OO.ui.mixin.GroupElement;

/**
 * @inheritdoc OO.ui.mixin.GroupWidget
 * @deprecated Use {@link OO.ui.mixin.GroupWidget} instead.
 */
OO.ui.GroupWidget = OO.ui.mixin.GroupWidget;

/**
 * @inheritdoc OO.ui.mixin.IconElement
 * @deprecated Use {@link OO.ui.mixin.IconElement} instead.
 */
OO.ui.IconElement = OO.ui.mixin.IconElement;

/**
 * @inheritdoc OO.ui.mixin.IndicatorElement
 * @deprecated Use {@link OO.ui.mixin.IndicatorElement} instead.
 */
OO.ui.IndicatorElement = OO.ui.mixin.IndicatorElement;

/**
 * @inheritdoc OO.ui.mixin.ItemWidget
 * @deprecated Use {@link OO.ui.mixin.ItemWidget} instead.
 */
OO.ui.ItemWidget = OO.ui.mixin.ItemWidget;

/**
 * @inheritdoc OO.ui.mixin.LabelElement
 * @deprecated Use {@link OO.ui.mixin.LabelElement} instead.
 */
OO.ui.LabelElement = OO.ui.mixin.LabelElement;

/**
 * @inheritdoc OO.ui.mixin.LookupElement
 * @deprecated Use {@link OO.ui.mixin.LookupElement} instead.
 */
OO.ui.LookupElement = OO.ui.mixin.LookupElement;

/**
 * @inheritdoc OO.ui.mixin.PendingElement
 * @deprecated Use {@link OO.ui.mixin.PendingElement} instead.
 */
OO.ui.PendingElement = OO.ui.mixin.PendingElement;

/**
 * @inheritdoc OO.ui.mixin.PopupElement
 * @deprecated Use {@link OO.ui.mixin.PopupElement} instead.
 */
OO.ui.PopupElement = OO.ui.mixin.PopupElement;

/**
 * @inheritdoc OO.ui.mixin.TabIndexedElement
 * @deprecated Use {@link OO.ui.mixin.TabIndexedElement} instead.
 */
OO.ui.TabIndexedElement = OO.ui.mixin.TabIndexedElement;

/**
 * @inheritdoc OO.ui.mixin.TitledElement
 * @deprecated Use {@link OO.ui.mixin.TitledElement} instead.
 */
OO.ui.TitledElement = OO.ui.mixin.TitledElement;

}( OO ) );

/*!
 * OOjs UI v0.12.6
 * https://www.mediawiki.org/wiki/OOjs_UI
 *
 * Copyright 2011–2015 OOjs UI Team and other contributors.
 * Released under the MIT license
 * http://oojs.mit-license.org
 *
 * Date: 2015-08-26T00:14:36Z
 */
/**
 * @class
 * @extends OO.ui.Theme
 *
 * @constructor
 */
OO.ui.ApexTheme = function OoUiApexTheme() {
	// Parent constructor
	OO.ui.ApexTheme.parent.call( this );
};

/* Setup */

OO.inheritClass( OO.ui.ApexTheme, OO.ui.Theme );

/* Instantiation */

OO.ui.theme = new OO.ui.ApexTheme();

/*!
 * UnicodeJS v0.1.5
 * https://www.mediawiki.org/wiki/UnicodeJS
 *
 * Copyright 2013-2015 UnicodeJS Team and other contributors.
 * Released under the MIT license
 * http://unicodejs.mit-license.org/
 *
 * Date: 2015-07-02T17:38:25Z
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
unicodeJS.derivedbidiclasses = {
	// partial extraction only
	L: [[0x0041, 0x005A], [0x0061, 0x007A], 0x00AA, 0x00B5, 0x00BA, [0x00C0, 0x00D6], [0x00D8, 0x00F6], [0x00F8, 0x02B8], [0x02BB, 0x02C1], 0x02D0, 0x02D1, [0x02E0, 0x02E4], 0x02EE, [0x0370, 0x0373], 0x0376, 0x0377, [0x037A, 0x037D], 0x037F, 0x0386, [0x0388, 0x038A], 0x038C, [0x038E, 0x03A1], [0x03A3, 0x03F5], [0x03F7, 0x0482], [0x048A, 0x052F], [0x0531, 0x0556], [0x0559, 0x055F], [0x0561, 0x0587], 0x0589, [0x0903, 0x0939], 0x093B, [0x093D, 0x0940], [0x0949, 0x094C], [0x094E, 0x0950], [0x0958, 0x0961], [0x0964, 0x0980], 0x0982, 0x0983, [0x0985, 0x098C], 0x098F, 0x0990, [0x0993, 0x09A8], [0x09AA, 0x09B0], 0x09B2, [0x09B6, 0x09B9], [0x09BD, 0x09C0], 0x09C7, 0x09C8, 0x09CB, 0x09CC, 0x09CE, 0x09D7, 0x09DC, 0x09DD, [0x09DF, 0x09E1], [0x09E6, 0x09F1], [0x09F4, 0x09FA], 0x0A03, [0x0A05, 0x0A0A], 0x0A0F, 0x0A10, [0x0A13, 0x0A28], [0x0A2A, 0x0A30], 0x0A32, 0x0A33, 0x0A35, 0x0A36, 0x0A38, 0x0A39, [0x0A3E, 0x0A40], [0x0A59, 0x0A5C], 0x0A5E, [0x0A66, 0x0A6F], [0x0A72, 0x0A74], 0x0A83, [0x0A85, 0x0A8D], [0x0A8F, 0x0A91], [0x0A93, 0x0AA8], [0x0AAA, 0x0AB0], 0x0AB2, 0x0AB3, [0x0AB5, 0x0AB9], [0x0ABD, 0x0AC0], 0x0AC9, 0x0ACB, 0x0ACC, 0x0AD0, 0x0AE0, 0x0AE1, [0x0AE6, 0x0AF0], 0x0AF9, 0x0B02, 0x0B03, [0x0B05, 0x0B0C], 0x0B0F, 0x0B10, [0x0B13, 0x0B28], [0x0B2A, 0x0B30], 0x0B32, 0x0B33, [0x0B35, 0x0B39], 0x0B3D, 0x0B3E, 0x0B40, 0x0B47, 0x0B48, 0x0B4B, 0x0B4C, 0x0B57, 0x0B5C, 0x0B5D, [0x0B5F, 0x0B61], [0x0B66, 0x0B77], 0x0B83, [0x0B85, 0x0B8A], [0x0B8E, 0x0B90], [0x0B92, 0x0B95], 0x0B99, 0x0B9A, 0x0B9C, 0x0B9E, 0x0B9F, 0x0BA3, 0x0BA4, [0x0BA8, 0x0BAA], [0x0BAE, 0x0BB9], 0x0BBE, 0x0BBF, 0x0BC1, 0x0BC2, [0x0BC6, 0x0BC8], [0x0BCA, 0x0BCC], 0x0BD0, 0x0BD7, [0x0BE6, 0x0BF2], [0x0C01, 0x0C03], [0x0C05, 0x0C0C], [0x0C0E, 0x0C10], [0x0C12, 0x0C28], [0x0C2A, 0x0C39], 0x0C3D, [0x0C41, 0x0C44], [0x0C58, 0x0C5A], 0x0C60, 0x0C61, [0x0C66, 0x0C6F], 0x0C7F, 0x0C82, 0x0C83, [0x0C85, 0x0C8C], [0x0C8E, 0x0C90], [0x0C92, 0x0CA8], [0x0CAA, 0x0CB3], [0x0CB5, 0x0CB9], [0x0CBD, 0x0CC4], [0x0CC6, 0x0CC8], 0x0CCA, 0x0CCB, 0x0CD5, 0x0CD6, 0x0CDE, 0x0CE0, 0x0CE1, [0x0CE6, 0x0CEF], 0x0CF1, 0x0CF2, 0x0D02, 0x0D03, [0x0D05, 0x0D0C], [0x0D0E, 0x0D10], [0x0D12, 0x0D3A], [0x0D3D, 0x0D40], [0x0D46, 0x0D48], [0x0D4A, 0x0D4C], 0x0D4E, 0x0D57, [0x0D5F, 0x0D61], [0x0D66, 0x0D75], [0x0D79, 0x0D7F], 0x0D82, 0x0D83, [0x0D85, 0x0D96], [0x0D9A, 0x0DB1], [0x0DB3, 0x0DBB], 0x0DBD, [0x0DC0, 0x0DC6], [0x0DCF, 0x0DD1], [0x0DD8, 0x0DDF], [0x0DE6, 0x0DEF], [0x0DF2, 0x0DF4], [0x0E01, 0x0E30], 0x0E32, 0x0E33, [0x0E40, 0x0E46], [0x0E4F, 0x0E5B], 0x0E81, 0x0E82, 0x0E84, 0x0E87, 0x0E88, 0x0E8A, 0x0E8D, [0x0E94, 0x0E97], [0x0E99, 0x0E9F], [0x0EA1, 0x0EA3], 0x0EA5, 0x0EA7, 0x0EAA, 0x0EAB, [0x0EAD, 0x0EB0], 0x0EB2, 0x0EB3, 0x0EBD, [0x0EC0, 0x0EC4], 0x0EC6, [0x0ED0, 0x0ED9], [0x0EDC, 0x0EDF], [0x0F00, 0x0F17], [0x0F1A, 0x0F34], 0x0F36, 0x0F38, [0x0F3E, 0x0F47], [0x0F49, 0x0F6C], 0x0F7F, 0x0F85, [0x0F88, 0x0F8C], [0x0FBE, 0x0FC5], [0x0FC7, 0x0FCC], [0x0FCE, 0x0FDA], [0x1000, 0x102C], 0x1031, 0x1038, 0x103B, 0x103C, [0x103F, 0x1057], [0x105A, 0x105D], [0x1061, 0x1070], [0x1075, 0x1081], 0x1083, 0x1084, [0x1087, 0x108C], [0x108E, 0x109C], [0x109E, 0x10C5], 0x10C7, 0x10CD, [0x10D0, 0x1248], [0x124A, 0x124D], [0x1250, 0x1256], 0x1258, [0x125A, 0x125D], [0x1260, 0x1288], [0x128A, 0x128D], [0x1290, 0x12B0], [0x12B2, 0x12B5], [0x12B8, 0x12BE], 0x12C0, [0x12C2, 0x12C5], [0x12C8, 0x12D6], [0x12D8, 0x1310], [0x1312, 0x1315], [0x1318, 0x135A], [0x1360, 0x137C], [0x1380, 0x138F], [0x13A0, 0x13F5], [0x13F8, 0x13FD], [0x1401, 0x167F], [0x1681, 0x169A], [0x16A0, 0x16F8], [0x1700, 0x170C], [0x170E, 0x1711], [0x1720, 0x1731], 0x1735, 0x1736, [0x1740, 0x1751], [0x1760, 0x176C], [0x176E, 0x1770], [0x1780, 0x17B3], 0x17B6, [0x17BE, 0x17C5], 0x17C7, 0x17C8, [0x17D4, 0x17DA], 0x17DC, [0x17E0, 0x17E9], [0x1810, 0x1819], [0x1820, 0x1877], [0x1880, 0x18A8], 0x18AA, [0x18B0, 0x18F5], [0x1900, 0x191E], [0x1923, 0x1926], [0x1929, 0x192B], 0x1930, 0x1931, [0x1933, 0x1938], [0x1946, 0x196D], [0x1970, 0x1974], [0x1980, 0x19AB], [0x19B0, 0x19C9], [0x19D0, 0x19DA], [0x1A00, 0x1A16], 0x1A19, 0x1A1A, [0x1A1E, 0x1A55], 0x1A57, 0x1A61, 0x1A63, 0x1A64, [0x1A6D, 0x1A72], [0x1A80, 0x1A89], [0x1A90, 0x1A99], [0x1AA0, 0x1AAD], [0x1B04, 0x1B33], 0x1B35, 0x1B3B, [0x1B3D, 0x1B41], [0x1B43, 0x1B4B], [0x1B50, 0x1B6A], [0x1B74, 0x1B7C], [0x1B82, 0x1BA1], 0x1BA6, 0x1BA7, 0x1BAA, [0x1BAE, 0x1BE5], 0x1BE7, [0x1BEA, 0x1BEC], 0x1BEE, 0x1BF2, 0x1BF3, [0x1BFC, 0x1C2B], 0x1C34, 0x1C35, [0x1C3B, 0x1C49], [0x1C4D, 0x1C7F], [0x1CC0, 0x1CC7], 0x1CD3, 0x1CE1, [0x1CE9, 0x1CEC], [0x1CEE, 0x1CF3], 0x1CF5, 0x1CF6, [0x1D00, 0x1DBF], [0x1E00, 0x1F15], [0x1F18, 0x1F1D], [0x1F20, 0x1F45], [0x1F48, 0x1F4D], [0x1F50, 0x1F57], 0x1F59, 0x1F5B, 0x1F5D, [0x1F5F, 0x1F7D], [0x1F80, 0x1FB4], [0x1FB6, 0x1FBC], 0x1FBE, [0x1FC2, 0x1FC4], [0x1FC6, 0x1FCC], [0x1FD0, 0x1FD3], [0x1FD6, 0x1FDB], [0x1FE0, 0x1FEC], [0x1FF2, 0x1FF4], [0x1FF6, 0x1FFC], 0x200E, 0x2071, 0x207F, [0x2090, 0x209C], 0x2102, 0x2107, [0x210A, 0x2113], 0x2115, [0x2119, 0x211D], 0x2124, 0x2126, 0x2128, [0x212A, 0x212D], [0x212F, 0x2139], [0x213C, 0x213F], [0x2145, 0x2149], 0x214E, 0x214F, [0x2160, 0x2188], [0x2336, 0x237A], 0x2395, [0x249C, 0x24E9], 0x26AC, [0x2800, 0x28FF], [0x2C00, 0x2C2E], [0x2C30, 0x2C5E], [0x2C60, 0x2CE4], [0x2CEB, 0x2CEE], 0x2CF2, 0x2CF3, [0x2D00, 0x2D25], 0x2D27, 0x2D2D, [0x2D30, 0x2D67], 0x2D6F, 0x2D70, [0x2D80, 0x2D96], [0x2DA0, 0x2DA6], [0x2DA8, 0x2DAE], [0x2DB0, 0x2DB6], [0x2DB8, 0x2DBE], [0x2DC0, 0x2DC6], [0x2DC8, 0x2DCE], [0x2DD0, 0x2DD6], [0x2DD8, 0x2DDE], [0x3005, 0x3007], [0x3021, 0x3029], 0x302E, 0x302F, [0x3031, 0x3035], [0x3038, 0x303C], [0x3041, 0x3096], [0x309D, 0x309F], [0x30A1, 0x30FA], [0x30FC, 0x30FF], [0x3105, 0x312D], [0x3131, 0x318E], [0x3190, 0x31BA], [0x31F0, 0x321C], [0x3220, 0x324F], [0x3260, 0x327B], [0x327F, 0x32B0], [0x32C0, 0x32CB], [0x32D0, 0x32FE], [0x3300, 0x3376], [0x337B, 0x33DD], [0x33E0, 0x33FE], [0x3400, 0x4DB5], [0x4E00, 0x9FD5], [0xA000, 0xA48C], [0xA4D0, 0xA60C], [0xA610, 0xA62B], [0xA640, 0xA66E], [0xA680, 0xA69D], [0xA6A0, 0xA6EF], [0xA6F2, 0xA6F7], [0xA722, 0xA787], [0xA789, 0xA7AD], [0xA7B0, 0xA7B7], [0xA7F7, 0xA801], [0xA803, 0xA805], [0xA807, 0xA80A], [0xA80C, 0xA824], 0xA827, [0xA830, 0xA837], [0xA840, 0xA873], [0xA880, 0xA8C3], [0xA8CE, 0xA8D9], [0xA8F2, 0xA8FD], [0xA900, 0xA925], [0xA92E, 0xA946], 0xA952, 0xA953, [0xA95F, 0xA97C], [0xA983, 0xA9B2], 0xA9B4, 0xA9B5, 0xA9BA, 0xA9BB, [0xA9BD, 0xA9CD], [0xA9CF, 0xA9D9], [0xA9DE, 0xA9E4], [0xA9E6, 0xA9FE], [0xAA00, 0xAA28], 0xAA2F, 0xAA30, 0xAA33, 0xAA34, [0xAA40, 0xAA42], [0xAA44, 0xAA4B], 0xAA4D, [0xAA50, 0xAA59], [0xAA5C, 0xAA7B], [0xAA7D, 0xAAAF], 0xAAB1, 0xAAB5, 0xAAB6, [0xAAB9, 0xAABD], 0xAAC0, 0xAAC2, [0xAADB, 0xAAEB], [0xAAEE, 0xAAF5], [0xAB01, 0xAB06], [0xAB09, 0xAB0E], [0xAB11, 0xAB16], [0xAB20, 0xAB26], [0xAB28, 0xAB2E], [0xAB30, 0xAB65], [0xAB70, 0xABE4], 0xABE6, 0xABE7, [0xABE9, 0xABEC], [0xABF0, 0xABF9], [0xAC00, 0xD7A3], [0xD7B0, 0xD7C6], [0xD7CB, 0xD7FB], [0xE000, 0xFA6D], [0xFA70, 0xFAD9], [0xFB00, 0xFB06], [0xFB13, 0xFB17], [0xFF21, 0xFF3A], [0xFF41, 0xFF5A], [0xFF66, 0xFFBE], [0xFFC2, 0xFFC7], [0xFFCA, 0xFFCF], [0xFFD2, 0xFFD7], [0xFFDA, 0xFFDC], [0x10000, 0x1000B], [0x1000D, 0x10026], [0x10028, 0x1003A], 0x1003C, 0x1003D, [0x1003F, 0x1004D], [0x10050, 0x1005D], [0x10080, 0x100FA], 0x10100, 0x10102, [0x10107, 0x10133], [0x10137, 0x1013F], [0x101D0, 0x101FC], [0x10280, 0x1029C], [0x102A0, 0x102D0], [0x10300, 0x10323], [0x10330, 0x1034A], [0x10350, 0x10375], [0x10380, 0x1039D], [0x1039F, 0x103C3], [0x103C8, 0x103D5], [0x10400, 0x1049D], [0x104A0, 0x104A9], [0x10500, 0x10527], [0x10530, 0x10563], 0x1056F, [0x10600, 0x10736], [0x10740, 0x10755], [0x10760, 0x10767], 0x11000, [0x11002, 0x11037], [0x11047, 0x1104D], [0x11066, 0x1106F], [0x11082, 0x110B2], 0x110B7, 0x110B8, [0x110BB, 0x110C1], [0x110D0, 0x110E8], [0x110F0, 0x110F9], [0x11103, 0x11126], 0x1112C, [0x11136, 0x11143], [0x11150, 0x11172], [0x11174, 0x11176], [0x11182, 0x111B5], [0x111BF, 0x111C9], 0x111CD, [0x111D0, 0x111DF], [0x111E1, 0x111F4], [0x11200, 0x11211], [0x11213, 0x1122E], 0x11232, 0x11233, 0x11235, [0x11238, 0x1123D], [0x11280, 0x11286], 0x11288, [0x1128A, 0x1128D], [0x1128F, 0x1129D], [0x1129F, 0x112A9], [0x112B0, 0x112DE], [0x112E0, 0x112E2], [0x112F0, 0x112F9], 0x11302, 0x11303, [0x11305, 0x1130C], 0x1130F, 0x11310, [0x11313, 0x11328], [0x1132A, 0x11330], 0x11332, 0x11333, [0x11335, 0x11339], [0x1133D, 0x1133F], [0x11341, 0x11344], 0x11347, 0x11348, [0x1134B, 0x1134D], 0x11350, 0x11357, [0x1135D, 0x11363], [0x11480, 0x114B2], 0x114B9, [0x114BB, 0x114BE], 0x114C1, [0x114C4, 0x114C7], [0x114D0, 0x114D9], [0x11580, 0x115B1], [0x115B8, 0x115BB], 0x115BE, [0x115C1, 0x115DB], [0x11600, 0x11632], 0x1163B, 0x1163C, 0x1163E, [0x11641, 0x11644], [0x11650, 0x11659], [0x11680, 0x116AA], 0x116AC, 0x116AE, 0x116AF, 0x116B6, [0x116C0, 0x116C9], [0x11700, 0x11719], 0x11720, 0x11721, 0x11726, [0x11730, 0x1173F], [0x118A0, 0x118F2], 0x118FF, [0x11AC0, 0x11AF8], [0x12000, 0x12399], [0x12400, 0x1246E], [0x12470, 0x12474], [0x12480, 0x12543], [0x13000, 0x1342E], [0x14400, 0x14646], [0x16800, 0x16A38], [0x16A40, 0x16A5E], [0x16A60, 0x16A69], 0x16A6E, 0x16A6F, [0x16AD0, 0x16AED], 0x16AF5, [0x16B00, 0x16B2F], [0x16B37, 0x16B45], [0x16B50, 0x16B59], [0x16B5B, 0x16B61], [0x16B63, 0x16B77], [0x16B7D, 0x16B8F], [0x16F00, 0x16F44], [0x16F50, 0x16F7E], [0x16F93, 0x16F9F], 0x1B000, 0x1B001, [0x1BC00, 0x1BC6A], [0x1BC70, 0x1BC7C], [0x1BC80, 0x1BC88], [0x1BC90, 0x1BC99], 0x1BC9C, 0x1BC9F, [0x1D000, 0x1D0F5], [0x1D100, 0x1D126], [0x1D129, 0x1D166], [0x1D16A, 0x1D172], 0x1D183, 0x1D184, [0x1D18C, 0x1D1A9], [0x1D1AE, 0x1D1E8], [0x1D360, 0x1D371], [0x1D400, 0x1D454], [0x1D456, 0x1D49C], 0x1D49E, 0x1D49F, 0x1D4A2, 0x1D4A5, 0x1D4A6, [0x1D4A9, 0x1D4AC], [0x1D4AE, 0x1D4B9], 0x1D4BB, [0x1D4BD, 0x1D4C3], [0x1D4C5, 0x1D505], [0x1D507, 0x1D50A], [0x1D50D, 0x1D514], [0x1D516, 0x1D51C], [0x1D51E, 0x1D539], [0x1D53B, 0x1D53E], [0x1D540, 0x1D544], 0x1D546, [0x1D54A, 0x1D550], [0x1D552, 0x1D6A5], [0x1D6A8, 0x1D6DA], [0x1D6DC, 0x1D714], [0x1D716, 0x1D74E], [0x1D750, 0x1D788], [0x1D78A, 0x1D7C2], [0x1D7C4, 0x1D7CB], [0x1D800, 0x1D9FF], [0x1DA37, 0x1DA3A], [0x1DA6D, 0x1DA74], [0x1DA76, 0x1DA83], [0x1DA85, 0x1DA8B], [0x1F110, 0x1F12E], [0x1F130, 0x1F169], [0x1F170, 0x1F19A], [0x1F1E6, 0x1F202], [0x1F210, 0x1F23A], [0x1F240, 0x1F248], 0x1F250, 0x1F251, [0x20000, 0x2A6D6], [0x2A700, 0x2B734], [0x2B740, 0x2B81D], [0x2B820, 0x2CEA1], [0x2F800, 0x2FA1D], [0xF0000, 0xFFFFD], [0x100000, 0x10FFFD]],
	R: [0x0590, 0x05BE, 0x05C0, 0x05C3, 0x05C6, [0x05C8, 0x05FF], [0x07C0, 0x07EA], 0x07F4, 0x07F5, [0x07FA, 0x0815], 0x081A, 0x0824, 0x0828, [0x082E, 0x0858], [0x085C, 0x089F], 0x200F, 0xFB1D, [0xFB1F, 0xFB28], [0xFB2A, 0xFB4F], [0x10800, 0x1091E], [0x10920, 0x10A00], 0x10A04, [0x10A07, 0x10A0B], [0x10A10, 0x10A37], [0x10A3B, 0x10A3E], [0x10A40, 0x10AE4], [0x10AE7, 0x10B38], [0x10B40, 0x10E5F], [0x10E7F, 0x10FFF], [0x1E800, 0x1E8CF], [0x1E8D7, 0x1EDFF], [0x1EF00, 0x1EFFF]],
	AL: [0x0608, 0x060B, 0x060D, [0x061B, 0x064A], [0x066D, 0x066F], [0x0671, 0x06D5], 0x06E5, 0x06E6, 0x06EE, 0x06EF, [0x06FA, 0x0710], [0x0712, 0x072F], [0x074B, 0x07A5], [0x07B1, 0x07BF], [0x08A0, 0x08E2], [0xFB50, 0xFD3D], [0xFD40, 0xFDCF], [0xFDF0, 0xFDFC], 0xFDFE, 0xFDFF, [0xFE70, 0xFEFE], [0x1EE00, 0x1EEEF], [0x1EEF2, 0x1EEFF]]
};

// This file is GENERATED by tools/unicodejs-properties.py
// DO NOT EDIT
unicodeJS.derivedcoreproperties = {
	// partial extraction only
	Alphabetic: [[0x0041, 0x005A], [0x0061, 0x007A], 0x00AA, 0x00B5, 0x00BA, [0x00C0, 0x00D6], [0x00D8, 0x00F6], [0x00F8, 0x02C1], [0x02C6, 0x02D1], [0x02E0, 0x02E4], 0x02EC, 0x02EE, 0x0345, [0x0370, 0x0374], 0x0376, 0x0377, [0x037A, 0x037D], 0x037F, 0x0386, [0x0388, 0x038A], 0x038C, [0x038E, 0x03A1], [0x03A3, 0x03F5], [0x03F7, 0x0481], [0x048A, 0x052F], [0x0531, 0x0556], 0x0559, [0x0561, 0x0587], [0x05B0, 0x05BD], 0x05BF, 0x05C1, 0x05C2, 0x05C4, 0x05C5, 0x05C7, [0x05D0, 0x05EA], [0x05F0, 0x05F2], [0x0610, 0x061A], [0x0620, 0x0657], [0x0659, 0x065F], [0x066E, 0x06D3], [0x06D5, 0x06DC], [0x06E1, 0x06E8], [0x06ED, 0x06EF], [0x06FA, 0x06FC], 0x06FF, [0x0710, 0x073F], [0x074D, 0x07B1], [0x07CA, 0x07EA], 0x07F4, 0x07F5, 0x07FA, [0x0800, 0x0817], [0x081A, 0x082C], [0x0840, 0x0858], [0x08A0, 0x08B4], [0x08E3, 0x08E9], [0x08F0, 0x093B], [0x093D, 0x094C], [0x094E, 0x0950], [0x0955, 0x0963], [0x0971, 0x0983], [0x0985, 0x098C], 0x098F, 0x0990, [0x0993, 0x09A8], [0x09AA, 0x09B0], 0x09B2, [0x09B6, 0x09B9], [0x09BD, 0x09C4], 0x09C7, 0x09C8, 0x09CB, 0x09CC, 0x09CE, 0x09D7, 0x09DC, 0x09DD, [0x09DF, 0x09E3], 0x09F0, 0x09F1, [0x0A01, 0x0A03], [0x0A05, 0x0A0A], 0x0A0F, 0x0A10, [0x0A13, 0x0A28], [0x0A2A, 0x0A30], 0x0A32, 0x0A33, 0x0A35, 0x0A36, 0x0A38, 0x0A39, [0x0A3E, 0x0A42], 0x0A47, 0x0A48, 0x0A4B, 0x0A4C, 0x0A51, [0x0A59, 0x0A5C], 0x0A5E, [0x0A70, 0x0A75], [0x0A81, 0x0A83], [0x0A85, 0x0A8D], [0x0A8F, 0x0A91], [0x0A93, 0x0AA8], [0x0AAA, 0x0AB0], 0x0AB2, 0x0AB3, [0x0AB5, 0x0AB9], [0x0ABD, 0x0AC5], [0x0AC7, 0x0AC9], 0x0ACB, 0x0ACC, 0x0AD0, [0x0AE0, 0x0AE3], 0x0AF9, [0x0B01, 0x0B03], [0x0B05, 0x0B0C], 0x0B0F, 0x0B10, [0x0B13, 0x0B28], [0x0B2A, 0x0B30], 0x0B32, 0x0B33, [0x0B35, 0x0B39], [0x0B3D, 0x0B44], 0x0B47, 0x0B48, 0x0B4B, 0x0B4C, 0x0B56, 0x0B57, 0x0B5C, 0x0B5D, [0x0B5F, 0x0B63], 0x0B71, 0x0B82, 0x0B83, [0x0B85, 0x0B8A], [0x0B8E, 0x0B90], [0x0B92, 0x0B95], 0x0B99, 0x0B9A, 0x0B9C, 0x0B9E, 0x0B9F, 0x0BA3, 0x0BA4, [0x0BA8, 0x0BAA], [0x0BAE, 0x0BB9], [0x0BBE, 0x0BC2], [0x0BC6, 0x0BC8], [0x0BCA, 0x0BCC], 0x0BD0, 0x0BD7, [0x0C00, 0x0C03], [0x0C05, 0x0C0C], [0x0C0E, 0x0C10], [0x0C12, 0x0C28], [0x0C2A, 0x0C39], [0x0C3D, 0x0C44], [0x0C46, 0x0C48], [0x0C4A, 0x0C4C], 0x0C55, 0x0C56, [0x0C58, 0x0C5A], [0x0C60, 0x0C63], [0x0C81, 0x0C83], [0x0C85, 0x0C8C], [0x0C8E, 0x0C90], [0x0C92, 0x0CA8], [0x0CAA, 0x0CB3], [0x0CB5, 0x0CB9], [0x0CBD, 0x0CC4], [0x0CC6, 0x0CC8], [0x0CCA, 0x0CCC], 0x0CD5, 0x0CD6, 0x0CDE, [0x0CE0, 0x0CE3], 0x0CF1, 0x0CF2, [0x0D01, 0x0D03], [0x0D05, 0x0D0C], [0x0D0E, 0x0D10], [0x0D12, 0x0D3A], [0x0D3D, 0x0D44], [0x0D46, 0x0D48], [0x0D4A, 0x0D4C], 0x0D4E, 0x0D57, [0x0D5F, 0x0D63], [0x0D7A, 0x0D7F], 0x0D82, 0x0D83, [0x0D85, 0x0D96], [0x0D9A, 0x0DB1], [0x0DB3, 0x0DBB], 0x0DBD, [0x0DC0, 0x0DC6], [0x0DCF, 0x0DD4], 0x0DD6, [0x0DD8, 0x0DDF], 0x0DF2, 0x0DF3, [0x0E01, 0x0E3A], [0x0E40, 0x0E46], 0x0E4D, 0x0E81, 0x0E82, 0x0E84, 0x0E87, 0x0E88, 0x0E8A, 0x0E8D, [0x0E94, 0x0E97], [0x0E99, 0x0E9F], [0x0EA1, 0x0EA3], 0x0EA5, 0x0EA7, 0x0EAA, 0x0EAB, [0x0EAD, 0x0EB9], [0x0EBB, 0x0EBD], [0x0EC0, 0x0EC4], 0x0EC6, 0x0ECD, [0x0EDC, 0x0EDF], 0x0F00, [0x0F40, 0x0F47], [0x0F49, 0x0F6C], [0x0F71, 0x0F81], [0x0F88, 0x0F97], [0x0F99, 0x0FBC], [0x1000, 0x1036], 0x1038, [0x103B, 0x103F], [0x1050, 0x1062], [0x1065, 0x1068], [0x106E, 0x1086], 0x108E, 0x109C, 0x109D, [0x10A0, 0x10C5], 0x10C7, 0x10CD, [0x10D0, 0x10FA], [0x10FC, 0x1248], [0x124A, 0x124D], [0x1250, 0x1256], 0x1258, [0x125A, 0x125D], [0x1260, 0x1288], [0x128A, 0x128D], [0x1290, 0x12B0], [0x12B2, 0x12B5], [0x12B8, 0x12BE], 0x12C0, [0x12C2, 0x12C5], [0x12C8, 0x12D6], [0x12D8, 0x1310], [0x1312, 0x1315], [0x1318, 0x135A], 0x135F, [0x1380, 0x138F], [0x13A0, 0x13F5], [0x13F8, 0x13FD], [0x1401, 0x166C], [0x166F, 0x167F], [0x1681, 0x169A], [0x16A0, 0x16EA], [0x16EE, 0x16F8], [0x1700, 0x170C], [0x170E, 0x1713], [0x1720, 0x1733], [0x1740, 0x1753], [0x1760, 0x176C], [0x176E, 0x1770], 0x1772, 0x1773, [0x1780, 0x17B3], [0x17B6, 0x17C8], 0x17D7, 0x17DC, [0x1820, 0x1877], [0x1880, 0x18AA], [0x18B0, 0x18F5], [0x1900, 0x191E], [0x1920, 0x192B], [0x1930, 0x1938], [0x1950, 0x196D], [0x1970, 0x1974], [0x1980, 0x19AB], [0x19B0, 0x19C9], [0x1A00, 0x1A1B], [0x1A20, 0x1A5E], [0x1A61, 0x1A74], 0x1AA7, [0x1B00, 0x1B33], [0x1B35, 0x1B43], [0x1B45, 0x1B4B], [0x1B80, 0x1BA9], [0x1BAC, 0x1BAF], [0x1BBA, 0x1BE5], [0x1BE7, 0x1BF1], [0x1C00, 0x1C35], [0x1C4D, 0x1C4F], [0x1C5A, 0x1C7D], [0x1CE9, 0x1CEC], [0x1CEE, 0x1CF3], 0x1CF5, 0x1CF6, [0x1D00, 0x1DBF], [0x1DE7, 0x1DF4], [0x1E00, 0x1F15], [0x1F18, 0x1F1D], [0x1F20, 0x1F45], [0x1F48, 0x1F4D], [0x1F50, 0x1F57], 0x1F59, 0x1F5B, 0x1F5D, [0x1F5F, 0x1F7D], [0x1F80, 0x1FB4], [0x1FB6, 0x1FBC], 0x1FBE, [0x1FC2, 0x1FC4], [0x1FC6, 0x1FCC], [0x1FD0, 0x1FD3], [0x1FD6, 0x1FDB], [0x1FE0, 0x1FEC], [0x1FF2, 0x1FF4], [0x1FF6, 0x1FFC], 0x2071, 0x207F, [0x2090, 0x209C], 0x2102, 0x2107, [0x210A, 0x2113], 0x2115, [0x2119, 0x211D], 0x2124, 0x2126, 0x2128, [0x212A, 0x212D], [0x212F, 0x2139], [0x213C, 0x213F], [0x2145, 0x2149], 0x214E, [0x2160, 0x2188], [0x24B6, 0x24E9], [0x2C00, 0x2C2E], [0x2C30, 0x2C5E], [0x2C60, 0x2CE4], [0x2CEB, 0x2CEE], 0x2CF2, 0x2CF3, [0x2D00, 0x2D25], 0x2D27, 0x2D2D, [0x2D30, 0x2D67], 0x2D6F, [0x2D80, 0x2D96], [0x2DA0, 0x2DA6], [0x2DA8, 0x2DAE], [0x2DB0, 0x2DB6], [0x2DB8, 0x2DBE], [0x2DC0, 0x2DC6], [0x2DC8, 0x2DCE], [0x2DD0, 0x2DD6], [0x2DD8, 0x2DDE], [0x2DE0, 0x2DFF], 0x2E2F, [0x3005, 0x3007], [0x3021, 0x3029], [0x3031, 0x3035], [0x3038, 0x303C], [0x3041, 0x3096], [0x309D, 0x309F], [0x30A1, 0x30FA], [0x30FC, 0x30FF], [0x3105, 0x312D], [0x3131, 0x318E], [0x31A0, 0x31BA], [0x31F0, 0x31FF], [0x3400, 0x4DB5], [0x4E00, 0x9FD5], [0xA000, 0xA48C], [0xA4D0, 0xA4FD], [0xA500, 0xA60C], [0xA610, 0xA61F], 0xA62A, 0xA62B, [0xA640, 0xA66E], [0xA674, 0xA67B], [0xA67F, 0xA6EF], [0xA717, 0xA71F], [0xA722, 0xA788], [0xA78B, 0xA7AD], [0xA7B0, 0xA7B7], [0xA7F7, 0xA801], [0xA803, 0xA805], [0xA807, 0xA80A], [0xA80C, 0xA827], [0xA840, 0xA873], [0xA880, 0xA8C3], [0xA8F2, 0xA8F7], 0xA8FB, 0xA8FD, [0xA90A, 0xA92A], [0xA930, 0xA952], [0xA960, 0xA97C], [0xA980, 0xA9B2], [0xA9B4, 0xA9BF], 0xA9CF, [0xA9E0, 0xA9E4], [0xA9E6, 0xA9EF], [0xA9FA, 0xA9FE], [0xAA00, 0xAA36], [0xAA40, 0xAA4D], [0xAA60, 0xAA76], 0xAA7A, [0xAA7E, 0xAABE], 0xAAC0, 0xAAC2, [0xAADB, 0xAADD], [0xAAE0, 0xAAEF], [0xAAF2, 0xAAF5], [0xAB01, 0xAB06], [0xAB09, 0xAB0E], [0xAB11, 0xAB16], [0xAB20, 0xAB26], [0xAB28, 0xAB2E], [0xAB30, 0xAB5A], [0xAB5C, 0xAB65], [0xAB70, 0xABEA], [0xAC00, 0xD7A3], [0xD7B0, 0xD7C6], [0xD7CB, 0xD7FB], [0xF900, 0xFA6D], [0xFA70, 0xFAD9], [0xFB00, 0xFB06], [0xFB13, 0xFB17], [0xFB1D, 0xFB28], [0xFB2A, 0xFB36], [0xFB38, 0xFB3C], 0xFB3E, 0xFB40, 0xFB41, 0xFB43, 0xFB44, [0xFB46, 0xFBB1], [0xFBD3, 0xFD3D], [0xFD50, 0xFD8F], [0xFD92, 0xFDC7], [0xFDF0, 0xFDFB], [0xFE70, 0xFE74], [0xFE76, 0xFEFC], [0xFF21, 0xFF3A], [0xFF41, 0xFF5A], [0xFF66, 0xFFBE], [0xFFC2, 0xFFC7], [0xFFCA, 0xFFCF], [0xFFD2, 0xFFD7], [0xFFDA, 0xFFDC], [0x10000, 0x1000B], [0x1000D, 0x10026], [0x10028, 0x1003A], 0x1003C, 0x1003D, [0x1003F, 0x1004D], [0x10050, 0x1005D], [0x10080, 0x100FA], [0x10140, 0x10174], [0x10280, 0x1029C], [0x102A0, 0x102D0], [0x10300, 0x1031F], [0x10330, 0x1034A], [0x10350, 0x1037A], [0x10380, 0x1039D], [0x103A0, 0x103C3], [0x103C8, 0x103CF], [0x103D1, 0x103D5], [0x10400, 0x1049D], [0x10500, 0x10527], [0x10530, 0x10563], [0x10600, 0x10736], [0x10740, 0x10755], [0x10760, 0x10767], [0x10800, 0x10805], 0x10808, [0x1080A, 0x10835], 0x10837, 0x10838, 0x1083C, [0x1083F, 0x10855], [0x10860, 0x10876], [0x10880, 0x1089E], [0x108E0, 0x108F2], 0x108F4, 0x108F5, [0x10900, 0x10915], [0x10920, 0x10939], [0x10980, 0x109B7], 0x109BE, 0x109BF, [0x10A00, 0x10A03], 0x10A05, 0x10A06, [0x10A0C, 0x10A13], [0x10A15, 0x10A17], [0x10A19, 0x10A33], [0x10A60, 0x10A7C], [0x10A80, 0x10A9C], [0x10AC0, 0x10AC7], [0x10AC9, 0x10AE4], [0x10B00, 0x10B35], [0x10B40, 0x10B55], [0x10B60, 0x10B72], [0x10B80, 0x10B91], [0x10C00, 0x10C48], [0x10C80, 0x10CB2], [0x10CC0, 0x10CF2], [0x11000, 0x11045], [0x11082, 0x110B8], [0x110D0, 0x110E8], [0x11100, 0x11132], [0x11150, 0x11172], 0x11176, [0x11180, 0x111BF], [0x111C1, 0x111C4], 0x111DA, 0x111DC, [0x11200, 0x11211], [0x11213, 0x11234], 0x11237, [0x11280, 0x11286], 0x11288, [0x1128A, 0x1128D], [0x1128F, 0x1129D], [0x1129F, 0x112A8], [0x112B0, 0x112E8], [0x11300, 0x11303], [0x11305, 0x1130C], 0x1130F, 0x11310, [0x11313, 0x11328], [0x1132A, 0x11330], 0x11332, 0x11333, [0x11335, 0x11339], [0x1133D, 0x11344], 0x11347, 0x11348, 0x1134B, 0x1134C, 0x11350, 0x11357, [0x1135D, 0x11363], [0x11480, 0x114C1], 0x114C4, 0x114C5, 0x114C7, [0x11580, 0x115B5], [0x115B8, 0x115BE], [0x115D8, 0x115DD], [0x11600, 0x1163E], 0x11640, 0x11644, [0x11680, 0x116B5], [0x11700, 0x11719], [0x1171D, 0x1172A], [0x118A0, 0x118DF], 0x118FF, [0x11AC0, 0x11AF8], [0x12000, 0x12399], [0x12400, 0x1246E], [0x12480, 0x12543], [0x13000, 0x1342E], [0x14400, 0x14646], [0x16800, 0x16A38], [0x16A40, 0x16A5E], [0x16AD0, 0x16AED], [0x16B00, 0x16B36], [0x16B40, 0x16B43], [0x16B63, 0x16B77], [0x16B7D, 0x16B8F], [0x16F00, 0x16F44], [0x16F50, 0x16F7E], [0x16F93, 0x16F9F], 0x1B000, 0x1B001, [0x1BC00, 0x1BC6A], [0x1BC70, 0x1BC7C], [0x1BC80, 0x1BC88], [0x1BC90, 0x1BC99], 0x1BC9E, [0x1D400, 0x1D454], [0x1D456, 0x1D49C], 0x1D49E, 0x1D49F, 0x1D4A2, 0x1D4A5, 0x1D4A6, [0x1D4A9, 0x1D4AC], [0x1D4AE, 0x1D4B9], 0x1D4BB, [0x1D4BD, 0x1D4C3], [0x1D4C5, 0x1D505], [0x1D507, 0x1D50A], [0x1D50D, 0x1D514], [0x1D516, 0x1D51C], [0x1D51E, 0x1D539], [0x1D53B, 0x1D53E], [0x1D540, 0x1D544], 0x1D546, [0x1D54A, 0x1D550], [0x1D552, 0x1D6A5], [0x1D6A8, 0x1D6C0], [0x1D6C2, 0x1D6DA], [0x1D6DC, 0x1D6FA], [0x1D6FC, 0x1D714], [0x1D716, 0x1D734], [0x1D736, 0x1D74E], [0x1D750, 0x1D76E], [0x1D770, 0x1D788], [0x1D78A, 0x1D7A8], [0x1D7AA, 0x1D7C2], [0x1D7C4, 0x1D7CB], [0x1E800, 0x1E8C4], [0x1EE00, 0x1EE03], [0x1EE05, 0x1EE1F], 0x1EE21, 0x1EE22, 0x1EE24, 0x1EE27, [0x1EE29, 0x1EE32], [0x1EE34, 0x1EE37], 0x1EE39, 0x1EE3B, 0x1EE42, 0x1EE47, 0x1EE49, 0x1EE4B, [0x1EE4D, 0x1EE4F], 0x1EE51, 0x1EE52, 0x1EE54, 0x1EE57, 0x1EE59, 0x1EE5B, 0x1EE5D, 0x1EE5F, 0x1EE61, 0x1EE62, 0x1EE64, [0x1EE67, 0x1EE6A], [0x1EE6C, 0x1EE72], [0x1EE74, 0x1EE77], [0x1EE79, 0x1EE7C], 0x1EE7E, [0x1EE80, 0x1EE89], [0x1EE8B, 0x1EE9B], [0x1EEA1, 0x1EEA3], [0x1EEA5, 0x1EEA9], [0x1EEAB, 0x1EEBB], [0x1F130, 0x1F149], [0x1F150, 0x1F169], [0x1F170, 0x1F189], [0x20000, 0x2A6D6], [0x2A700, 0x2B734], [0x2B740, 0x2B81D], [0x2B820, 0x2CEA1], [0x2F800, 0x2FA1D]]
};

// This file is GENERATED by tools/unicodejs-properties.py
// DO NOT EDIT
unicodeJS.derivedgeneralcategories = {
	// partial extraction only
	M: [[0x0300, 0x036F], [0x0483, 0x0489], [0x0591, 0x05BD], 0x05BF, 0x05C1, 0x05C2, 0x05C4, 0x05C5, 0x05C7, [0x0610, 0x061A], [0x064B, 0x065F], 0x0670, [0x06D6, 0x06DC], [0x06DF, 0x06E4], 0x06E7, 0x06E8, [0x06EA, 0x06ED], 0x0711, [0x0730, 0x074A], [0x07A6, 0x07B0], [0x07EB, 0x07F3], [0x0816, 0x0819], [0x081B, 0x0823], [0x0825, 0x0827], [0x0829, 0x082D], [0x0859, 0x085B], [0x08E3, 0x0903], [0x093A, 0x093C], [0x093E, 0x094F], [0x0951, 0x0957], 0x0962, 0x0963, [0x0981, 0x0983], 0x09BC, [0x09BE, 0x09C4], 0x09C7, 0x09C8, [0x09CB, 0x09CD], 0x09D7, 0x09E2, 0x09E3, [0x0A01, 0x0A03], 0x0A3C, [0x0A3E, 0x0A42], 0x0A47, 0x0A48, [0x0A4B, 0x0A4D], 0x0A51, 0x0A70, 0x0A71, 0x0A75, [0x0A81, 0x0A83], 0x0ABC, [0x0ABE, 0x0AC5], [0x0AC7, 0x0AC9], [0x0ACB, 0x0ACD], 0x0AE2, 0x0AE3, [0x0B01, 0x0B03], 0x0B3C, [0x0B3E, 0x0B44], 0x0B47, 0x0B48, [0x0B4B, 0x0B4D], 0x0B56, 0x0B57, 0x0B62, 0x0B63, 0x0B82, [0x0BBE, 0x0BC2], [0x0BC6, 0x0BC8], [0x0BCA, 0x0BCD], 0x0BD7, [0x0C00, 0x0C03], [0x0C3E, 0x0C44], [0x0C46, 0x0C48], [0x0C4A, 0x0C4D], 0x0C55, 0x0C56, 0x0C62, 0x0C63, [0x0C81, 0x0C83], 0x0CBC, [0x0CBE, 0x0CC4], [0x0CC6, 0x0CC8], [0x0CCA, 0x0CCD], 0x0CD5, 0x0CD6, 0x0CE2, 0x0CE3, [0x0D01, 0x0D03], [0x0D3E, 0x0D44], [0x0D46, 0x0D48], [0x0D4A, 0x0D4D], 0x0D57, 0x0D62, 0x0D63, 0x0D82, 0x0D83, 0x0DCA, [0x0DCF, 0x0DD4], 0x0DD6, [0x0DD8, 0x0DDF], 0x0DF2, 0x0DF3, 0x0E31, [0x0E34, 0x0E3A], [0x0E47, 0x0E4E], 0x0EB1, [0x0EB4, 0x0EB9], 0x0EBB, 0x0EBC, [0x0EC8, 0x0ECD], 0x0F18, 0x0F19, 0x0F35, 0x0F37, 0x0F39, 0x0F3E, 0x0F3F, [0x0F71, 0x0F84], 0x0F86, 0x0F87, [0x0F8D, 0x0F97], [0x0F99, 0x0FBC], 0x0FC6, [0x102B, 0x103E], [0x1056, 0x1059], [0x105E, 0x1060], [0x1062, 0x1064], [0x1067, 0x106D], [0x1071, 0x1074], [0x1082, 0x108D], 0x108F, [0x109A, 0x109D], [0x135D, 0x135F], [0x1712, 0x1714], [0x1732, 0x1734], 0x1752, 0x1753, 0x1772, 0x1773, [0x17B4, 0x17D3], 0x17DD, [0x180B, 0x180D], 0x18A9, [0x1920, 0x192B], [0x1930, 0x193B], [0x1A17, 0x1A1B], [0x1A55, 0x1A5E], [0x1A60, 0x1A7C], 0x1A7F, [0x1AB0, 0x1ABE], [0x1B00, 0x1B04], [0x1B34, 0x1B44], [0x1B6B, 0x1B73], [0x1B80, 0x1B82], [0x1BA1, 0x1BAD], [0x1BE6, 0x1BF3], [0x1C24, 0x1C37], [0x1CD0, 0x1CD2], [0x1CD4, 0x1CE8], 0x1CED, [0x1CF2, 0x1CF4], 0x1CF8, 0x1CF9, [0x1DC0, 0x1DF5], [0x1DFC, 0x1DFF], [0x20D0, 0x20F0], [0x2CEF, 0x2CF1], 0x2D7F, [0x2DE0, 0x2DFF], [0x302A, 0x302F], 0x3099, 0x309A, [0xA66F, 0xA672], [0xA674, 0xA67D], 0xA69E, 0xA69F, 0xA6F0, 0xA6F1, 0xA802, 0xA806, 0xA80B, [0xA823, 0xA827], 0xA880, 0xA881, [0xA8B4, 0xA8C4], [0xA8E0, 0xA8F1], [0xA926, 0xA92D], [0xA947, 0xA953], [0xA980, 0xA983], [0xA9B3, 0xA9C0], 0xA9E5, [0xAA29, 0xAA36], 0xAA43, 0xAA4C, 0xAA4D, [0xAA7B, 0xAA7D], 0xAAB0, [0xAAB2, 0xAAB4], 0xAAB7, 0xAAB8, 0xAABE, 0xAABF, 0xAAC1, [0xAAEB, 0xAAEF], 0xAAF5, 0xAAF6, [0xABE3, 0xABEA], 0xABEC, 0xABED, 0xFB1E, [0xFE00, 0xFE0F], [0xFE20, 0xFE2F], 0x101FD, 0x102E0, [0x10376, 0x1037A], [0x10A01, 0x10A03], 0x10A05, 0x10A06, [0x10A0C, 0x10A0F], [0x10A38, 0x10A3A], 0x10A3F, 0x10AE5, 0x10AE6, [0x11000, 0x11002], [0x11038, 0x11046], [0x1107F, 0x11082], [0x110B0, 0x110BA], [0x11100, 0x11102], [0x11127, 0x11134], 0x11173, [0x11180, 0x11182], [0x111B3, 0x111C0], [0x111CA, 0x111CC], [0x1122C, 0x11237], [0x112DF, 0x112EA], [0x11300, 0x11303], 0x1133C, [0x1133E, 0x11344], 0x11347, 0x11348, [0x1134B, 0x1134D], 0x11357, 0x11362, 0x11363, [0x11366, 0x1136C], [0x11370, 0x11374], [0x114B0, 0x114C3], [0x115AF, 0x115B5], [0x115B8, 0x115C0], 0x115DC, 0x115DD, [0x11630, 0x11640], [0x116AB, 0x116B7], [0x1171D, 0x1172B], [0x16AF0, 0x16AF4], [0x16B30, 0x16B36], [0x16F51, 0x16F7E], [0x16F8F, 0x16F92], 0x1BC9D, 0x1BC9E, [0x1D165, 0x1D169], [0x1D16D, 0x1D172], [0x1D17B, 0x1D182], [0x1D185, 0x1D18B], [0x1D1AA, 0x1D1AD], [0x1D242, 0x1D244], [0x1DA00, 0x1DA36], [0x1DA3B, 0x1DA6C], 0x1DA75, 0x1DA84, [0x1DA9B, 0x1DA9F], [0x1DAA1, 0x1DAAF], [0x1E8D0, 0x1E8D6], [0xE0100, 0xE01EF]],
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
	Extend: [[0x0300, 0x036F], [0x0483, 0x0489], [0x0591, 0x05BD], 0x05BF, 0x05C1, 0x05C2, 0x05C4, 0x05C5, 0x05C7, [0x0610, 0x061A], [0x064B, 0x065F], 0x0670, [0x06D6, 0x06DC], [0x06DF, 0x06E4], 0x06E7, 0x06E8, [0x06EA, 0x06ED], 0x0711, [0x0730, 0x074A], [0x07A6, 0x07B0], [0x07EB, 0x07F3], [0x0816, 0x0819], [0x081B, 0x0823], [0x0825, 0x0827], [0x0829, 0x082D], [0x0859, 0x085B], [0x08E3, 0x0902], 0x093A, 0x093C, [0x0941, 0x0948], 0x094D, [0x0951, 0x0957], 0x0962, 0x0963, 0x0981, 0x09BC, 0x09BE, [0x09C1, 0x09C4], 0x09CD, 0x09D7, 0x09E2, 0x09E3, 0x0A01, 0x0A02, 0x0A3C, 0x0A41, 0x0A42, 0x0A47, 0x0A48, [0x0A4B, 0x0A4D], 0x0A51, 0x0A70, 0x0A71, 0x0A75, 0x0A81, 0x0A82, 0x0ABC, [0x0AC1, 0x0AC5], 0x0AC7, 0x0AC8, 0x0ACD, 0x0AE2, 0x0AE3, 0x0B01, 0x0B3C, 0x0B3E, 0x0B3F, [0x0B41, 0x0B44], 0x0B4D, 0x0B56, 0x0B57, 0x0B62, 0x0B63, 0x0B82, 0x0BBE, 0x0BC0, 0x0BCD, 0x0BD7, 0x0C00, [0x0C3E, 0x0C40], [0x0C46, 0x0C48], [0x0C4A, 0x0C4D], 0x0C55, 0x0C56, 0x0C62, 0x0C63, 0x0C81, 0x0CBC, 0x0CBF, 0x0CC2, 0x0CC6, 0x0CCC, 0x0CCD, 0x0CD5, 0x0CD6, 0x0CE2, 0x0CE3, 0x0D01, 0x0D3E, [0x0D41, 0x0D44], 0x0D4D, 0x0D57, 0x0D62, 0x0D63, 0x0DCA, 0x0DCF, [0x0DD2, 0x0DD4], 0x0DD6, 0x0DDF, 0x0E31, [0x0E34, 0x0E3A], [0x0E47, 0x0E4E], 0x0EB1, [0x0EB4, 0x0EB9], 0x0EBB, 0x0EBC, [0x0EC8, 0x0ECD], 0x0F18, 0x0F19, 0x0F35, 0x0F37, 0x0F39, [0x0F71, 0x0F7E], [0x0F80, 0x0F84], 0x0F86, 0x0F87, [0x0F8D, 0x0F97], [0x0F99, 0x0FBC], 0x0FC6, [0x102D, 0x1030], [0x1032, 0x1037], 0x1039, 0x103A, 0x103D, 0x103E, 0x1058, 0x1059, [0x105E, 0x1060], [0x1071, 0x1074], 0x1082, 0x1085, 0x1086, 0x108D, 0x109D, [0x135D, 0x135F], [0x1712, 0x1714], [0x1732, 0x1734], 0x1752, 0x1753, 0x1772, 0x1773, 0x17B4, 0x17B5, [0x17B7, 0x17BD], 0x17C6, [0x17C9, 0x17D3], 0x17DD, [0x180B, 0x180D], 0x18A9, [0x1920, 0x1922], 0x1927, 0x1928, 0x1932, [0x1939, 0x193B], 0x1A17, 0x1A18, 0x1A1B, 0x1A56, [0x1A58, 0x1A5E], 0x1A60, 0x1A62, [0x1A65, 0x1A6C], [0x1A73, 0x1A7C], 0x1A7F, [0x1AB0, 0x1ABE], [0x1B00, 0x1B03], 0x1B34, [0x1B36, 0x1B3A], 0x1B3C, 0x1B42, [0x1B6B, 0x1B73], 0x1B80, 0x1B81, [0x1BA2, 0x1BA5], 0x1BA8, 0x1BA9, [0x1BAB, 0x1BAD], 0x1BE6, 0x1BE8, 0x1BE9, 0x1BED, [0x1BEF, 0x1BF1], [0x1C2C, 0x1C33], 0x1C36, 0x1C37, [0x1CD0, 0x1CD2], [0x1CD4, 0x1CE0], [0x1CE2, 0x1CE8], 0x1CED, 0x1CF4, 0x1CF8, 0x1CF9, [0x1DC0, 0x1DF5], [0x1DFC, 0x1DFF], 0x200C, 0x200D, [0x20D0, 0x20F0], [0x2CEF, 0x2CF1], 0x2D7F, [0x2DE0, 0x2DFF], [0x302A, 0x302F], 0x3099, 0x309A, [0xA66F, 0xA672], [0xA674, 0xA67D], 0xA69E, 0xA69F, 0xA6F0, 0xA6F1, 0xA802, 0xA806, 0xA80B, 0xA825, 0xA826, 0xA8C4, [0xA8E0, 0xA8F1], [0xA926, 0xA92D], [0xA947, 0xA951], [0xA980, 0xA982], 0xA9B3, [0xA9B6, 0xA9B9], 0xA9BC, 0xA9E5, [0xAA29, 0xAA2E], 0xAA31, 0xAA32, 0xAA35, 0xAA36, 0xAA43, 0xAA4C, 0xAA7C, 0xAAB0, [0xAAB2, 0xAAB4], 0xAAB7, 0xAAB8, 0xAABE, 0xAABF, 0xAAC1, 0xAAEC, 0xAAED, 0xAAF6, 0xABE5, 0xABE8, 0xABED, 0xFB1E, [0xFE00, 0xFE0F], [0xFE20, 0xFE2F], 0xFF9E, 0xFF9F, 0x101FD, 0x102E0, [0x10376, 0x1037A], [0x10A01, 0x10A03], 0x10A05, 0x10A06, [0x10A0C, 0x10A0F], [0x10A38, 0x10A3A], 0x10A3F, 0x10AE5, 0x10AE6, 0x11001, [0x11038, 0x11046], [0x1107F, 0x11081], [0x110B3, 0x110B6], 0x110B9, 0x110BA, [0x11100, 0x11102], [0x11127, 0x1112B], [0x1112D, 0x11134], 0x11173, 0x11180, 0x11181, [0x111B6, 0x111BE], [0x111CA, 0x111CC], [0x1122F, 0x11231], 0x11234, 0x11236, 0x11237, 0x112DF, [0x112E3, 0x112EA], 0x11300, 0x11301, 0x1133C, 0x1133E, 0x11340, 0x11357, [0x11366, 0x1136C], [0x11370, 0x11374], 0x114B0, [0x114B3, 0x114B8], 0x114BA, 0x114BD, 0x114BF, 0x114C0, 0x114C2, 0x114C3, 0x115AF, [0x115B2, 0x115B5], 0x115BC, 0x115BD, 0x115BF, 0x115C0, 0x115DC, 0x115DD, [0x11633, 0x1163A], 0x1163D, 0x1163F, 0x11640, 0x116AB, 0x116AD, [0x116B0, 0x116B5], 0x116B7, [0x1171D, 0x1171F], [0x11722, 0x11725], [0x11727, 0x1172B], [0x16AF0, 0x16AF4], [0x16B30, 0x16B36], [0x16F8F, 0x16F92], 0x1BC9D, 0x1BC9E, 0x1D165, [0x1D167, 0x1D169], [0x1D16E, 0x1D172], [0x1D17B, 0x1D182], [0x1D185, 0x1D18B], [0x1D1AA, 0x1D1AD], [0x1D242, 0x1D244], [0x1DA00, 0x1DA36], [0x1DA3B, 0x1DA6C], 0x1DA75, 0x1DA84, [0x1DA9B, 0x1DA9F], [0x1DAA1, 0x1DAAF], [0x1E8D0, 0x1E8D6], [0xE0100, 0xE01EF]],
	RegionalIndicator: [[0x1F1E6, 0x1F1FF]],
	SpacingMark: [0x0903, 0x093B, [0x093E, 0x0940], [0x0949, 0x094C], 0x094E, 0x094F, 0x0982, 0x0983, 0x09BF, 0x09C0, 0x09C7, 0x09C8, 0x09CB, 0x09CC, 0x0A03, [0x0A3E, 0x0A40], 0x0A83, [0x0ABE, 0x0AC0], 0x0AC9, 0x0ACB, 0x0ACC, 0x0B02, 0x0B03, 0x0B40, 0x0B47, 0x0B48, 0x0B4B, 0x0B4C, 0x0BBF, 0x0BC1, 0x0BC2, [0x0BC6, 0x0BC8], [0x0BCA, 0x0BCC], [0x0C01, 0x0C03], [0x0C41, 0x0C44], 0x0C82, 0x0C83, 0x0CBE, 0x0CC0, 0x0CC1, 0x0CC3, 0x0CC4, 0x0CC7, 0x0CC8, 0x0CCA, 0x0CCB, 0x0D02, 0x0D03, 0x0D3F, 0x0D40, [0x0D46, 0x0D48], [0x0D4A, 0x0D4C], 0x0D82, 0x0D83, 0x0DD0, 0x0DD1, [0x0DD8, 0x0DDE], 0x0DF2, 0x0DF3, 0x0E33, 0x0EB3, 0x0F3E, 0x0F3F, 0x0F7F, 0x1031, 0x103B, 0x103C, 0x1056, 0x1057, 0x1084, 0x17B6, [0x17BE, 0x17C5], 0x17C7, 0x17C8, [0x1923, 0x1926], [0x1929, 0x192B], 0x1930, 0x1931, [0x1933, 0x1938], 0x1A19, 0x1A1A, 0x1A55, 0x1A57, [0x1A6D, 0x1A72], 0x1B04, 0x1B35, 0x1B3B, [0x1B3D, 0x1B41], 0x1B43, 0x1B44, 0x1B82, 0x1BA1, 0x1BA6, 0x1BA7, 0x1BAA, 0x1BE7, [0x1BEA, 0x1BEC], 0x1BEE, 0x1BF2, 0x1BF3, [0x1C24, 0x1C2B], 0x1C34, 0x1C35, 0x1CE1, 0x1CF2, 0x1CF3, 0xA823, 0xA824, 0xA827, 0xA880, 0xA881, [0xA8B4, 0xA8C3], 0xA952, 0xA953, 0xA983, 0xA9B4, 0xA9B5, 0xA9BA, 0xA9BB, [0xA9BD, 0xA9C0], 0xAA2F, 0xAA30, 0xAA33, 0xAA34, 0xAA4D, 0xAAEB, 0xAAEE, 0xAAEF, 0xAAF5, 0xABE3, 0xABE4, 0xABE6, 0xABE7, 0xABE9, 0xABEA, 0xABEC, 0x11000, 0x11002, 0x11082, [0x110B0, 0x110B2], 0x110B7, 0x110B8, 0x1112C, 0x11182, [0x111B3, 0x111B5], 0x111BF, 0x111C0, [0x1122C, 0x1122E], 0x11232, 0x11233, 0x11235, [0x112E0, 0x112E2], 0x11302, 0x11303, 0x1133F, [0x11341, 0x11344], 0x11347, 0x11348, [0x1134B, 0x1134D], 0x11362, 0x11363, 0x114B1, 0x114B2, 0x114B9, 0x114BB, 0x114BC, 0x114BE, 0x114C1, 0x115B0, 0x115B1, [0x115B8, 0x115BB], 0x115BE, [0x11630, 0x11632], 0x1163B, 0x1163C, 0x1163E, 0x116AC, 0x116AE, 0x116AF, 0x116B6, 0x11720, 0x11721, 0x11726, [0x16F51, 0x16F7E], 0x1D166, 0x1D16D],
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
	Extend: [[0x0300, 0x036F], [0x0483, 0x0489], [0x0591, 0x05BD], 0x05BF, 0x05C1, 0x05C2, 0x05C4, 0x05C5, 0x05C7, [0x0610, 0x061A], [0x064B, 0x065F], 0x0670, [0x06D6, 0x06DC], [0x06DF, 0x06E4], 0x06E7, 0x06E8, [0x06EA, 0x06ED], 0x0711, [0x0730, 0x074A], [0x07A6, 0x07B0], [0x07EB, 0x07F3], [0x0816, 0x0819], [0x081B, 0x0823], [0x0825, 0x0827], [0x0829, 0x082D], [0x0859, 0x085B], [0x08E3, 0x0903], [0x093A, 0x093C], [0x093E, 0x094F], [0x0951, 0x0957], 0x0962, 0x0963, [0x0981, 0x0983], 0x09BC, [0x09BE, 0x09C4], 0x09C7, 0x09C8, [0x09CB, 0x09CD], 0x09D7, 0x09E2, 0x09E3, [0x0A01, 0x0A03], 0x0A3C, [0x0A3E, 0x0A42], 0x0A47, 0x0A48, [0x0A4B, 0x0A4D], 0x0A51, 0x0A70, 0x0A71, 0x0A75, [0x0A81, 0x0A83], 0x0ABC, [0x0ABE, 0x0AC5], [0x0AC7, 0x0AC9], [0x0ACB, 0x0ACD], 0x0AE2, 0x0AE3, [0x0B01, 0x0B03], 0x0B3C, [0x0B3E, 0x0B44], 0x0B47, 0x0B48, [0x0B4B, 0x0B4D], 0x0B56, 0x0B57, 0x0B62, 0x0B63, 0x0B82, [0x0BBE, 0x0BC2], [0x0BC6, 0x0BC8], [0x0BCA, 0x0BCD], 0x0BD7, [0x0C00, 0x0C03], [0x0C3E, 0x0C44], [0x0C46, 0x0C48], [0x0C4A, 0x0C4D], 0x0C55, 0x0C56, 0x0C62, 0x0C63, [0x0C81, 0x0C83], 0x0CBC, [0x0CBE, 0x0CC4], [0x0CC6, 0x0CC8], [0x0CCA, 0x0CCD], 0x0CD5, 0x0CD6, 0x0CE2, 0x0CE3, [0x0D01, 0x0D03], [0x0D3E, 0x0D44], [0x0D46, 0x0D48], [0x0D4A, 0x0D4D], 0x0D57, 0x0D62, 0x0D63, 0x0D82, 0x0D83, 0x0DCA, [0x0DCF, 0x0DD4], 0x0DD6, [0x0DD8, 0x0DDF], 0x0DF2, 0x0DF3, 0x0E31, [0x0E34, 0x0E3A], [0x0E47, 0x0E4E], 0x0EB1, [0x0EB4, 0x0EB9], 0x0EBB, 0x0EBC, [0x0EC8, 0x0ECD], 0x0F18, 0x0F19, 0x0F35, 0x0F37, 0x0F39, 0x0F3E, 0x0F3F, [0x0F71, 0x0F84], 0x0F86, 0x0F87, [0x0F8D, 0x0F97], [0x0F99, 0x0FBC], 0x0FC6, [0x102B, 0x103E], [0x1056, 0x1059], [0x105E, 0x1060], [0x1062, 0x1064], [0x1067, 0x106D], [0x1071, 0x1074], [0x1082, 0x108D], 0x108F, [0x109A, 0x109D], [0x135D, 0x135F], [0x1712, 0x1714], [0x1732, 0x1734], 0x1752, 0x1753, 0x1772, 0x1773, [0x17B4, 0x17D3], 0x17DD, [0x180B, 0x180D], 0x18A9, [0x1920, 0x192B], [0x1930, 0x193B], [0x1A17, 0x1A1B], [0x1A55, 0x1A5E], [0x1A60, 0x1A7C], 0x1A7F, [0x1AB0, 0x1ABE], [0x1B00, 0x1B04], [0x1B34, 0x1B44], [0x1B6B, 0x1B73], [0x1B80, 0x1B82], [0x1BA1, 0x1BAD], [0x1BE6, 0x1BF3], [0x1C24, 0x1C37], [0x1CD0, 0x1CD2], [0x1CD4, 0x1CE8], 0x1CED, [0x1CF2, 0x1CF4], 0x1CF8, 0x1CF9, [0x1DC0, 0x1DF5], [0x1DFC, 0x1DFF], 0x200C, 0x200D, [0x20D0, 0x20F0], [0x2CEF, 0x2CF1], 0x2D7F, [0x2DE0, 0x2DFF], [0x302A, 0x302F], 0x3099, 0x309A, [0xA66F, 0xA672], [0xA674, 0xA67D], 0xA69E, 0xA69F, 0xA6F0, 0xA6F1, 0xA802, 0xA806, 0xA80B, [0xA823, 0xA827], 0xA880, 0xA881, [0xA8B4, 0xA8C4], [0xA8E0, 0xA8F1], [0xA926, 0xA92D], [0xA947, 0xA953], [0xA980, 0xA983], [0xA9B3, 0xA9C0], 0xA9E5, [0xAA29, 0xAA36], 0xAA43, 0xAA4C, 0xAA4D, [0xAA7B, 0xAA7D], 0xAAB0, [0xAAB2, 0xAAB4], 0xAAB7, 0xAAB8, 0xAABE, 0xAABF, 0xAAC1, [0xAAEB, 0xAAEF], 0xAAF5, 0xAAF6, [0xABE3, 0xABEA], 0xABEC, 0xABED, 0xFB1E, [0xFE00, 0xFE0F], [0xFE20, 0xFE2F], 0xFF9E, 0xFF9F, 0x101FD, 0x102E0, [0x10376, 0x1037A], [0x10A01, 0x10A03], 0x10A05, 0x10A06, [0x10A0C, 0x10A0F], [0x10A38, 0x10A3A], 0x10A3F, 0x10AE5, 0x10AE6, [0x11000, 0x11002], [0x11038, 0x11046], [0x1107F, 0x11082], [0x110B0, 0x110BA], [0x11100, 0x11102], [0x11127, 0x11134], 0x11173, [0x11180, 0x11182], [0x111B3, 0x111C0], [0x111CA, 0x111CC], [0x1122C, 0x11237], [0x112DF, 0x112EA], [0x11300, 0x11303], 0x1133C, [0x1133E, 0x11344], 0x11347, 0x11348, [0x1134B, 0x1134D], 0x11357, 0x11362, 0x11363, [0x11366, 0x1136C], [0x11370, 0x11374], [0x114B0, 0x114C3], [0x115AF, 0x115B5], [0x115B8, 0x115C0], 0x115DC, 0x115DD, [0x11630, 0x11640], [0x116AB, 0x116B7], [0x1171D, 0x1172B], [0x16AF0, 0x16AF4], [0x16B30, 0x16B36], [0x16F51, 0x16F7E], [0x16F8F, 0x16F92], 0x1BC9D, 0x1BC9E, [0x1D165, 0x1D169], [0x1D16D, 0x1D172], [0x1D17B, 0x1D182], [0x1D185, 0x1D18B], [0x1D1AA, 0x1D1AD], [0x1D242, 0x1D244], [0x1DA00, 0x1DA36], [0x1DA3B, 0x1DA6C], 0x1DA75, 0x1DA84, [0x1DA9B, 0x1DA9F], [0x1DAA1, 0x1DAAF], [0x1E8D0, 0x1E8D6], [0xE0100, 0xE01EF]],
	RegionalIndicator: [[0x1F1E6, 0x1F1FF]],
	Format: [0x00AD, [0x0600, 0x0605], 0x061C, 0x06DD, 0x070F, 0x180E, 0x200E, 0x200F, [0x202A, 0x202E], [0x2060, 0x2064], [0x2066, 0x206F], 0xFEFF, [0xFFF9, 0xFFFB], 0x110BD, [0x1BCA0, 0x1BCA3], [0x1D173, 0x1D17A], 0xE0001, [0xE0020, 0xE007F]],
	Katakana: [[0x3031, 0x3035], 0x309B, 0x309C, [0x30A0, 0x30FA], [0x30FC, 0x30FF], [0x31F0, 0x31FF], [0x32D0, 0x32FE], [0x3300, 0x3357], [0xFF66, 0xFF9D], 0x1B000],
	ALetter: [[0x0041, 0x005A], [0x0061, 0x007A], 0x00AA, 0x00B5, 0x00BA, [0x00C0, 0x00D6], [0x00D8, 0x00F6], [0x00F8, 0x02C1], [0x02C6, 0x02D1], [0x02E0, 0x02E4], 0x02EC, 0x02EE, [0x0370, 0x0374], 0x0376, 0x0377, [0x037A, 0x037D], 0x037F, 0x0386, [0x0388, 0x038A], 0x038C, [0x038E, 0x03A1], [0x03A3, 0x03F5], [0x03F7, 0x0481], [0x048A, 0x052F], [0x0531, 0x0556], 0x0559, [0x0561, 0x0587], 0x05F3, [0x0620, 0x064A], 0x066E, 0x066F, [0x0671, 0x06D3], 0x06D5, 0x06E5, 0x06E6, 0x06EE, 0x06EF, [0x06FA, 0x06FC], 0x06FF, 0x0710, [0x0712, 0x072F], [0x074D, 0x07A5], 0x07B1, [0x07CA, 0x07EA], 0x07F4, 0x07F5, 0x07FA, [0x0800, 0x0815], 0x081A, 0x0824, 0x0828, [0x0840, 0x0858], [0x08A0, 0x08B4], [0x0904, 0x0939], 0x093D, 0x0950, [0x0958, 0x0961], [0x0971, 0x0980], [0x0985, 0x098C], 0x098F, 0x0990, [0x0993, 0x09A8], [0x09AA, 0x09B0], 0x09B2, [0x09B6, 0x09B9], 0x09BD, 0x09CE, 0x09DC, 0x09DD, [0x09DF, 0x09E1], 0x09F0, 0x09F1, [0x0A05, 0x0A0A], 0x0A0F, 0x0A10, [0x0A13, 0x0A28], [0x0A2A, 0x0A30], 0x0A32, 0x0A33, 0x0A35, 0x0A36, 0x0A38, 0x0A39, [0x0A59, 0x0A5C], 0x0A5E, [0x0A72, 0x0A74], [0x0A85, 0x0A8D], [0x0A8F, 0x0A91], [0x0A93, 0x0AA8], [0x0AAA, 0x0AB0], 0x0AB2, 0x0AB3, [0x0AB5, 0x0AB9], 0x0ABD, 0x0AD0, 0x0AE0, 0x0AE1, 0x0AF9, [0x0B05, 0x0B0C], 0x0B0F, 0x0B10, [0x0B13, 0x0B28], [0x0B2A, 0x0B30], 0x0B32, 0x0B33, [0x0B35, 0x0B39], 0x0B3D, 0x0B5C, 0x0B5D, [0x0B5F, 0x0B61], 0x0B71, 0x0B83, [0x0B85, 0x0B8A], [0x0B8E, 0x0B90], [0x0B92, 0x0B95], 0x0B99, 0x0B9A, 0x0B9C, 0x0B9E, 0x0B9F, 0x0BA3, 0x0BA4, [0x0BA8, 0x0BAA], [0x0BAE, 0x0BB9], 0x0BD0, [0x0C05, 0x0C0C], [0x0C0E, 0x0C10], [0x0C12, 0x0C28], [0x0C2A, 0x0C39], 0x0C3D, [0x0C58, 0x0C5A], 0x0C60, 0x0C61, [0x0C85, 0x0C8C], [0x0C8E, 0x0C90], [0x0C92, 0x0CA8], [0x0CAA, 0x0CB3], [0x0CB5, 0x0CB9], 0x0CBD, 0x0CDE, 0x0CE0, 0x0CE1, 0x0CF1, 0x0CF2, [0x0D05, 0x0D0C], [0x0D0E, 0x0D10], [0x0D12, 0x0D3A], 0x0D3D, 0x0D4E, [0x0D5F, 0x0D61], [0x0D7A, 0x0D7F], [0x0D85, 0x0D96], [0x0D9A, 0x0DB1], [0x0DB3, 0x0DBB], 0x0DBD, [0x0DC0, 0x0DC6], 0x0F00, [0x0F40, 0x0F47], [0x0F49, 0x0F6C], [0x0F88, 0x0F8C], [0x10A0, 0x10C5], 0x10C7, 0x10CD, [0x10D0, 0x10FA], [0x10FC, 0x1248], [0x124A, 0x124D], [0x1250, 0x1256], 0x1258, [0x125A, 0x125D], [0x1260, 0x1288], [0x128A, 0x128D], [0x1290, 0x12B0], [0x12B2, 0x12B5], [0x12B8, 0x12BE], 0x12C0, [0x12C2, 0x12C5], [0x12C8, 0x12D6], [0x12D8, 0x1310], [0x1312, 0x1315], [0x1318, 0x135A], [0x1380, 0x138F], [0x13A0, 0x13F5], [0x13F8, 0x13FD], [0x1401, 0x166C], [0x166F, 0x167F], [0x1681, 0x169A], [0x16A0, 0x16EA], [0x16EE, 0x16F8], [0x1700, 0x170C], [0x170E, 0x1711], [0x1720, 0x1731], [0x1740, 0x1751], [0x1760, 0x176C], [0x176E, 0x1770], [0x1820, 0x1877], [0x1880, 0x18A8], 0x18AA, [0x18B0, 0x18F5], [0x1900, 0x191E], [0x1A00, 0x1A16], [0x1B05, 0x1B33], [0x1B45, 0x1B4B], [0x1B83, 0x1BA0], 0x1BAE, 0x1BAF, [0x1BBA, 0x1BE5], [0x1C00, 0x1C23], [0x1C4D, 0x1C4F], [0x1C5A, 0x1C7D], [0x1CE9, 0x1CEC], [0x1CEE, 0x1CF1], 0x1CF5, 0x1CF6, [0x1D00, 0x1DBF], [0x1E00, 0x1F15], [0x1F18, 0x1F1D], [0x1F20, 0x1F45], [0x1F48, 0x1F4D], [0x1F50, 0x1F57], 0x1F59, 0x1F5B, 0x1F5D, [0x1F5F, 0x1F7D], [0x1F80, 0x1FB4], [0x1FB6, 0x1FBC], 0x1FBE, [0x1FC2, 0x1FC4], [0x1FC6, 0x1FCC], [0x1FD0, 0x1FD3], [0x1FD6, 0x1FDB], [0x1FE0, 0x1FEC], [0x1FF2, 0x1FF4], [0x1FF6, 0x1FFC], 0x2071, 0x207F, [0x2090, 0x209C], 0x2102, 0x2107, [0x210A, 0x2113], 0x2115, [0x2119, 0x211D], 0x2124, 0x2126, 0x2128, [0x212A, 0x212D], [0x212F, 0x2139], [0x213C, 0x213F], [0x2145, 0x2149], 0x214E, [0x2160, 0x2188], [0x24B6, 0x24E9], [0x2C00, 0x2C2E], [0x2C30, 0x2C5E], [0x2C60, 0x2CE4], [0x2CEB, 0x2CEE], 0x2CF2, 0x2CF3, [0x2D00, 0x2D25], 0x2D27, 0x2D2D, [0x2D30, 0x2D67], 0x2D6F, [0x2D80, 0x2D96], [0x2DA0, 0x2DA6], [0x2DA8, 0x2DAE], [0x2DB0, 0x2DB6], [0x2DB8, 0x2DBE], [0x2DC0, 0x2DC6], [0x2DC8, 0x2DCE], [0x2DD0, 0x2DD6], [0x2DD8, 0x2DDE], 0x2E2F, 0x3005, 0x303B, 0x303C, [0x3105, 0x312D], [0x3131, 0x318E], [0x31A0, 0x31BA], [0xA000, 0xA48C], [0xA4D0, 0xA4FD], [0xA500, 0xA60C], [0xA610, 0xA61F], 0xA62A, 0xA62B, [0xA640, 0xA66E], [0xA67F, 0xA69D], [0xA6A0, 0xA6EF], [0xA717, 0xA71F], [0xA722, 0xA788], [0xA78B, 0xA7AD], [0xA7B0, 0xA7B7], [0xA7F7, 0xA801], [0xA803, 0xA805], [0xA807, 0xA80A], [0xA80C, 0xA822], [0xA840, 0xA873], [0xA882, 0xA8B3], [0xA8F2, 0xA8F7], 0xA8FB, 0xA8FD, [0xA90A, 0xA925], [0xA930, 0xA946], [0xA960, 0xA97C], [0xA984, 0xA9B2], 0xA9CF, [0xAA00, 0xAA28], [0xAA40, 0xAA42], [0xAA44, 0xAA4B], [0xAAE0, 0xAAEA], [0xAAF2, 0xAAF4], [0xAB01, 0xAB06], [0xAB09, 0xAB0E], [0xAB11, 0xAB16], [0xAB20, 0xAB26], [0xAB28, 0xAB2E], [0xAB30, 0xAB5A], [0xAB5C, 0xAB65], [0xAB70, 0xABE2], [0xAC00, 0xD7A3], [0xD7B0, 0xD7C6], [0xD7CB, 0xD7FB], [0xFB00, 0xFB06], [0xFB13, 0xFB17], [0xFB50, 0xFBB1], [0xFBD3, 0xFD3D], [0xFD50, 0xFD8F], [0xFD92, 0xFDC7], [0xFDF0, 0xFDFB], [0xFE70, 0xFE74], [0xFE76, 0xFEFC], [0xFF21, 0xFF3A], [0xFF41, 0xFF5A], [0xFFA0, 0xFFBE], [0xFFC2, 0xFFC7], [0xFFCA, 0xFFCF], [0xFFD2, 0xFFD7], [0xFFDA, 0xFFDC], [0x10000, 0x1000B], [0x1000D, 0x10026], [0x10028, 0x1003A], 0x1003C, 0x1003D, [0x1003F, 0x1004D], [0x10050, 0x1005D], [0x10080, 0x100FA], [0x10140, 0x10174], [0x10280, 0x1029C], [0x102A0, 0x102D0], [0x10300, 0x1031F], [0x10330, 0x1034A], [0x10350, 0x10375], [0x10380, 0x1039D], [0x103A0, 0x103C3], [0x103C8, 0x103CF], [0x103D1, 0x103D5], [0x10400, 0x1049D], [0x10500, 0x10527], [0x10530, 0x10563], [0x10600, 0x10736], [0x10740, 0x10755], [0x10760, 0x10767], [0x10800, 0x10805], 0x10808, [0x1080A, 0x10835], 0x10837, 0x10838, 0x1083C, [0x1083F, 0x10855], [0x10860, 0x10876], [0x10880, 0x1089E], [0x108E0, 0x108F2], 0x108F4, 0x108F5, [0x10900, 0x10915], [0x10920, 0x10939], [0x10980, 0x109B7], 0x109BE, 0x109BF, 0x10A00, [0x10A10, 0x10A13], [0x10A15, 0x10A17], [0x10A19, 0x10A33], [0x10A60, 0x10A7C], [0x10A80, 0x10A9C], [0x10AC0, 0x10AC7], [0x10AC9, 0x10AE4], [0x10B00, 0x10B35], [0x10B40, 0x10B55], [0x10B60, 0x10B72], [0x10B80, 0x10B91], [0x10C00, 0x10C48], [0x10C80, 0x10CB2], [0x10CC0, 0x10CF2], [0x11003, 0x11037], [0x11083, 0x110AF], [0x110D0, 0x110E8], [0x11103, 0x11126], [0x11150, 0x11172], 0x11176, [0x11183, 0x111B2], [0x111C1, 0x111C4], 0x111DA, 0x111DC, [0x11200, 0x11211], [0x11213, 0x1122B], [0x11280, 0x11286], 0x11288, [0x1128A, 0x1128D], [0x1128F, 0x1129D], [0x1129F, 0x112A8], [0x112B0, 0x112DE], [0x11305, 0x1130C], 0x1130F, 0x11310, [0x11313, 0x11328], [0x1132A, 0x11330], 0x11332, 0x11333, [0x11335, 0x11339], 0x1133D, 0x11350, [0x1135D, 0x11361], [0x11480, 0x114AF], 0x114C4, 0x114C5, 0x114C7, [0x11580, 0x115AE], [0x115D8, 0x115DB], [0x11600, 0x1162F], 0x11644, [0x11680, 0x116AA], [0x118A0, 0x118DF], 0x118FF, [0x11AC0, 0x11AF8], [0x12000, 0x12399], [0x12400, 0x1246E], [0x12480, 0x12543], [0x13000, 0x1342E], [0x14400, 0x14646], [0x16800, 0x16A38], [0x16A40, 0x16A5E], [0x16AD0, 0x16AED], [0x16B00, 0x16B2F], [0x16B40, 0x16B43], [0x16B63, 0x16B77], [0x16B7D, 0x16B8F], [0x16F00, 0x16F44], 0x16F50, [0x16F93, 0x16F9F], [0x1BC00, 0x1BC6A], [0x1BC70, 0x1BC7C], [0x1BC80, 0x1BC88], [0x1BC90, 0x1BC99], [0x1D400, 0x1D454], [0x1D456, 0x1D49C], 0x1D49E, 0x1D49F, 0x1D4A2, 0x1D4A5, 0x1D4A6, [0x1D4A9, 0x1D4AC], [0x1D4AE, 0x1D4B9], 0x1D4BB, [0x1D4BD, 0x1D4C3], [0x1D4C5, 0x1D505], [0x1D507, 0x1D50A], [0x1D50D, 0x1D514], [0x1D516, 0x1D51C], [0x1D51E, 0x1D539], [0x1D53B, 0x1D53E], [0x1D540, 0x1D544], 0x1D546, [0x1D54A, 0x1D550], [0x1D552, 0x1D6A5], [0x1D6A8, 0x1D6C0], [0x1D6C2, 0x1D6DA], [0x1D6DC, 0x1D6FA], [0x1D6FC, 0x1D714], [0x1D716, 0x1D734], [0x1D736, 0x1D74E], [0x1D750, 0x1D76E], [0x1D770, 0x1D788], [0x1D78A, 0x1D7A8], [0x1D7AA, 0x1D7C2], [0x1D7C4, 0x1D7CB], [0x1E800, 0x1E8C4], [0x1EE00, 0x1EE03], [0x1EE05, 0x1EE1F], 0x1EE21, 0x1EE22, 0x1EE24, 0x1EE27, [0x1EE29, 0x1EE32], [0x1EE34, 0x1EE37], 0x1EE39, 0x1EE3B, 0x1EE42, 0x1EE47, 0x1EE49, 0x1EE4B, [0x1EE4D, 0x1EE4F], 0x1EE51, 0x1EE52, 0x1EE54, 0x1EE57, 0x1EE59, 0x1EE5B, 0x1EE5D, 0x1EE5F, 0x1EE61, 0x1EE62, 0x1EE64, [0x1EE67, 0x1EE6A], [0x1EE6C, 0x1EE72], [0x1EE74, 0x1EE77], [0x1EE79, 0x1EE7C], 0x1EE7E, [0x1EE80, 0x1EE89], [0x1EE8B, 0x1EE9B], [0x1EEA1, 0x1EEA3], [0x1EEA5, 0x1EEA9], [0x1EEAB, 0x1EEBB], [0x1F130, 0x1F149], [0x1F150, 0x1F169], [0x1F170, 0x1F189]],
	MidLetter: [0x003A, 0x00B7, 0x02D7, 0x0387, 0x05F4, 0x2027, 0xFE13, 0xFE55, 0xFF1A],
	MidNum: [0x002C, 0x003B, 0x037E, 0x0589, 0x060C, 0x060D, 0x066C, 0x07F8, 0x2044, 0xFE10, 0xFE14, 0xFE50, 0xFE54, 0xFF0C, 0xFF1B],
	MidNumLet: [0x002E, 0x2018, 0x2019, 0x2024, 0xFE52, 0xFF07, 0xFF0E],
	Numeric: [[0x0030, 0x0039], [0x0660, 0x0669], 0x066B, [0x06F0, 0x06F9], [0x07C0, 0x07C9], [0x0966, 0x096F], [0x09E6, 0x09EF], [0x0A66, 0x0A6F], [0x0AE6, 0x0AEF], [0x0B66, 0x0B6F], [0x0BE6, 0x0BEF], [0x0C66, 0x0C6F], [0x0CE6, 0x0CEF], [0x0D66, 0x0D6F], [0x0DE6, 0x0DEF], [0x0E50, 0x0E59], [0x0ED0, 0x0ED9], [0x0F20, 0x0F29], [0x1040, 0x1049], [0x1090, 0x1099], [0x17E0, 0x17E9], [0x1810, 0x1819], [0x1946, 0x194F], [0x19D0, 0x19D9], [0x1A80, 0x1A89], [0x1A90, 0x1A99], [0x1B50, 0x1B59], [0x1BB0, 0x1BB9], [0x1C40, 0x1C49], [0x1C50, 0x1C59], [0xA620, 0xA629], [0xA8D0, 0xA8D9], [0xA900, 0xA909], [0xA9D0, 0xA9D9], [0xA9F0, 0xA9F9], [0xAA50, 0xAA59], [0xABF0, 0xABF9], [0x104A0, 0x104A9], [0x11066, 0x1106F], [0x110F0, 0x110F9], [0x11136, 0x1113F], [0x111D0, 0x111D9], [0x112F0, 0x112F9], [0x114D0, 0x114D9], [0x11650, 0x11659], [0x116C0, 0x116C9], [0x11730, 0x11739], [0x118E0, 0x118E9], [0x16A60, 0x16A69], [0x16B50, 0x16B59], [0x1D7CE, 0x1D7FF]],
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
	 * Evaluates whether a position within some text is a word boundary.
	 *
	 * The text object elements may be code units, codepoints or clusters.
	 * @param {Object} string TextString-like object with read( pos ) returning string|null
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

		// Do not break inside surrogate pair
		if (
			string.read( pos - 1 ).match( /[\uD800-\uDBFF]/ ) &&
			string.read( pos ).match( /[\uDC00-\uDFFF]/ )
		) {
			return false;
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
 * @return {number} Current time
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
 * @return {boolean} Object inherits from one or more of the classes
 */
ve.isInstanceOfAny = function ( subject, classes ) {
	var i = classes.length;

	while ( classes[ --i ] ) {
		if ( subject instanceof classes[ i ] ) {
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
 * @inheritdoc OO#getObjectValues
 */
ve.getObjectValues = OO.getObjectValues;

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
 * @method
 * @inheritdoc OO.ui#debounce
 */
ve.debounce = OO.ui.debounce;

/**
 * @method
 * @inheritdoc OO.ui.Element#scrollIntoView
 */
ve.scrollIntoView = OO.ui.Element.static.scrollIntoView.bind( OO.ui.Element.static );

/**
 * Copy an array of DOM elements, optionally into a different document.
 *
 * @param {HTMLElement[]} domElements DOM elements to copy
 * @param {HTMLDocument} [doc] Document to create the copies in; if unset, simply clone each element
 * @return {HTMLElement[]} Copy of domElements with copies of each element
 */
ve.copyDomElements = function ( domElements, doc ) {
	return domElements.map( function ( domElement ) {
		return doc ? doc.importNode( domElement, true ) : domElement.cloneNode( true );
	} );
};

/**
 * Check if two arrays of DOM elements are equal (according to .isEqualNode())
 *
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
		if ( !domElements1[ i ].isEqualNode( domElements2[ i ] ) ) {
			return false;
		}
	}
	return true;
};

/**
 * Compare two class lists, either whitespace separated strings or arrays
 *
 * Class lists are equivalent if they contain the same members,
 * excluding duplicates and ignoring order.
 *
 * @param {string[]|string} classList1 First class list
 * @param {string[]|string} classList2 Second class list
 * @return {boolean} Class lists are equivalent
 */
ve.compareClassLists = function ( classList1, classList2 ) {
	var removeEmpty = function ( c ) {
		return c !== '';
	};

	classList1 = Array.isArray( classList1 ) ? classList1 : classList1.trim().split( /\s+/ );
	classList2 = Array.isArray( classList2 ) ? classList2 : classList2.trim().split( /\s+/ );

	classList1 = classList1.filter( removeEmpty );
	classList2 = classList2.filter( removeEmpty );

	return ve.compare( OO.unique( classList1 ).sort(), OO.unique( classList2 ).sort() );
};

/**
 * Check to see if an object is a plain object (created using "{}" or "new Object").
 *
 * @method
 * @source <http://api.jquery.com/jQuery.isPlainObject/>
 * @param {Object} obj The object that will be checked to see if it's a plain object
 * @return {boolean}
 */
ve.isPlainObject = $.isPlainObject;

/**
 * Check to see if an object is empty (contains no properties).
 *
 * @method
 * @source <http://api.jquery.com/jQuery.isEmptyObject/>
 * @param {Object} obj The object that will be checked to see if it's empty
 * @return {boolean}
 */
ve.isEmptyObject = $.isEmptyObject;

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
 * @param {...Mixed} [sources] Variadic list of objects containing properties
 * to be merged into the target.
 * @return {Mixed} Modified version of first or second argument
 */
ve.extendObject = $.extend;

/**
 * @private
 * @property {boolean}
 */
ve.supportsSplice = ( function () {
	var a, n;

	// This returns false in Safari 8
	a = new Array( 100000 );
	a.splice( 30, 0, 'x' );
	a.splice( 20, 1 );
	if ( a.indexOf( 'x' ) !== 29 ) {
		return false;
	}

	// This returns false in Opera 12.15
	a = [];
	n = 256;
	a[ n ] = 'a';
	a.splice( n + 1, 0, 'b' );
	if ( a[ n ] !== 'a' ) {
		return false;
	}

	// Splice is supported
	return true;
} )();

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
 * Includes a replacement for broken implementations of Array.prototype.splice().
 *
 * @param {Array|ve.dm.BranchNode} arr Target object (must have `splice` method, object will be modified)
 * @param {number} offset Offset in arr to splice at. This may NOT be negative, unlike the
 *  'index' parameter in Array#splice.
 * @param {number} remove Number of elements to remove at the offset. May be zero
 * @param {Array} data Array of items to insert at the offset. Must be non-empty if remove=0
 * @return {Array} Array of items removed
 */
ve.batchSplice = function ( arr, offset, remove, data ) {
	// We need to splice insertion in in batches, because of parameter list length limits which vary
	// cross-browser - 1024 seems to be a safe batch size on all browsers
	var splice, spliced,
		index = 0,
		batchSize = 1024,
		toRemove = remove,
		removed = [];

	if ( !Array.isArray( arr ) ) {
		splice = arr.splice;
	} else {
		if ( ve.supportsSplice ) {
			splice = Array.prototype.splice;
		} else {
			// Standard Array.prototype.splice() function implemented using .slice() and .push().
			splice = function ( offset, remove/*, data... */ ) {
				var data, begin, removed, end;

				data = Array.prototype.slice.call( arguments, 2 );

				begin = this.slice( 0, offset );
				removed = this.slice( offset, offset + remove );
				end = this.slice( offset + remove );

				this.length = 0;
				ve.batchPush( this, begin );
				ve.batchPush( this, data );
				ve.batchPush( this, end );

				return removed;
			};
		}
	}

	if ( data.length === 0 ) {
		// Special case: data is empty, so we're just doing a removal
		// The code below won't handle that properly, so we do it here
		return splice.call( arr, offset, remove );
	}

	while ( index < data.length ) {
		// Call arr.splice( offset, remove, i0, i1, i2, ..., i1023 );
		// Only set remove on the first call, and set it to zero on subsequent calls
		spliced = splice.apply(
			arr, [ index + offset, toRemove ].concat( data.slice( index, index + batchSize ) )
		);
		if ( toRemove > 0 ) {
			removed = spliced;
		}
		index += batchSize;
		toRemove = 0;
	}
	return removed;
};

/**
 * Insert one array into another.
 *
 * Shortcut for `ve.batchSplice( arr, offset, 0, src )`.
 *
 * @see #batchSplice
 * @param {Array|ve.dm.BranchNode} arr Target object (must have `splice` method)
 * @param {number} offset Offset in arr where items will be inserted
 * @param {Array} src Items to insert at offset
 */
ve.insertIntoArray = function ( arr, offset, src ) {
	ve.batchSplice( arr, offset, 0, src );
};

/**
 * Push one array into another.
 *
 * This is the equivalent of arr.push( d1, d2, d3, ... ) except that arguments are
 * specified as an array rather than separate parameters.
 *
 * @param {Array|ve.dm.BranchNode} arr Object supporting .push() to insert at the end of the array. Will be modified
 * @param {Array} data Array of items to insert.
 * @return {number} length of the new array
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
 * Use binary search to locate an element in a sorted array.
 *
 * searchFunc is given an element from the array. `searchFunc(elem)` must return a number
 * above 0 if the element we're searching for is to the right of (has a higher index than) elem,
 * below 0 if it is to the left of elem, or zero if it's equal to elem.
 *
 * To search for a specific value with a comparator function (a `function cmp(a,b)` that returns
 * above 0 if `a > b`, below 0 if `a < b`, and 0 if `a == b`), you can use
 * `searchFunc = cmp.bind( null, value )`.
 *
 * @param {Array} arr Array to search in
 * @param {Function} searchFunc Search function
 * @param {boolean} [forInsertion] If not found, return index where val could be inserted
 * @return {number|null} Index where val was found, or null if not found
 */
ve.binarySearch = function ( arr, searchFunc, forInsertion ) {
	var mid, cmpResult,
		left = 0,
		right = arr.length;
	while ( left < right ) {
		// Equivalent to Math.floor( ( left + right ) / 2 ) but much faster
		/*jshint bitwise:false */
		mid = ( left + right ) >> 1;
		cmpResult = searchFunc( arr[ mid ] );
		if ( cmpResult < 0 ) {
			right = mid;
		} else if ( cmpResult > 0 ) {
			left = mid + 1;
		} else {
			return mid;
		}
	}
	return forInsertion ? right : null;
};

/**
 * Log data to the console.
 *
 * This implementation does nothing, to add a real implementation ve.debug needs to be loaded.
 *
 * @param {...Mixed} [args] Data to log
 */
ve.log = ve.log || function () {
	// don't do anything, this is just a stub
};

/**
 * Log error to the console.
 *
 * This implementation does nothing, to add a real implementation ve.debug needs to be loaded.
 *
 * @param {...Mixed} [args] Data to log
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
 * Select the contents of an element
 *
 * @param {HTMLElement} element Element
 */
ve.selectElement = function ( element ) {
	var win = OO.ui.Element.static.getWindow( element ),
		nativeRange = win.document.createRange(),
		nativeSelection = win.getSelection();
	nativeRange.setStart( element, 0 );
	nativeRange.setEnd( element, element.childNodes.length );
	nativeSelection.removeAllRanges();
	nativeSelection.addRange( nativeRange );
};

/**
 * Get a localized message.
 *
 * @param {string} key Message key
 * @param {...Mixed} [params] Message parameters
 * @return {string} Localized message
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
 * @return {Mixed|Object} Config value, or keyed object of config values if list of keys provided
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
 * @return {boolean} The text is unattached combining marks
 */
ve.isUnattachedCombiningMark = function ( text ) {
	return ( /^[\u0300-\u036F]+$/ ).test( text );
};

/**
 * Convert a grapheme cluster offset to a byte offset.
 *
 * @param {string} text Text in which to calculate offset
 * @param {number} clusterOffset Grapheme cluster offset
 * @return {number} Byte offset
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
 * @return {number} Grapheme cluster offset
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
 * @return {string} Substring of text
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
 * @return {string} Escaped attribute value
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
 * @return {string} HTML attributes
 */
ve.getHtmlAttributes = function ( attributes ) {
	var attrName, attrValue,
		parts = [];

	if ( !ve.isPlainObject( attributes ) || ve.isEmptyObject( attributes ) ) {
		return '';
	}

	for ( attrName in attributes ) {
		attrValue = attributes[ attrName ];
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
 * @param {string} tagName HTML tag name
 * @param {Object} [attributes] Key-value map of attributes for the tag
 * @return {string} Opening HTML tag
 */
ve.getOpeningHtmlTag = function ( tagName, attributes ) {
	var attr = ve.getHtmlAttributes( attributes );
	return '<' + tagName + ( attr ? ' ' + attr : '' ) + '>';
};

/**
 * Get the attributes of a DOM element as an object with key/value pairs.
 *
 * @param {HTMLElement} element
 * @return {Object}
 */
ve.getDomAttributes = function ( element ) {
	var i,
		result = {};
	for ( i = 0; i < element.attributes.length; i++ ) {
		result[ element.attributes[ i ].name ] = element.attributes[ i ].value;
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
		if ( attributes[ key ] === undefined || attributes[ key ] === null ) {
			element.removeAttribute( key );
		} else {
			element.setAttribute( key, attributes[ key ] );
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
 * @return {Object} Summary of element.
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
			summary.attributes[ element.attributes[ i ].name ] = element.attributes[ i ].value;
		}
	}
	// Summarize children
	if ( element.childNodes ) {
		for ( i = 0; i < element.childNodes.length; i++ ) {
			summary.children.push( ve.getDomElementSummary( element.childNodes[ i ], includeHtml ) );
		}
	}
	return summary;
};

/**
 * Callback for #copy to convert nodes to a comparable summary.
 *
 * @private
 * @param {Object} value Value in the object/array
 * @return {Object} DOM element summary if value is a node, otherwise just the value
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
 * @return {boolean} Element is a block element
 */
ve.isBlockElement = function ( element ) {
	var elementName = typeof element === 'string' ? element : element.nodeName;
	return ve.elementTypes.block.indexOf( elementName.toLowerCase() ) !== -1;
};

/**
 * Check whether a given DOM element is a void element (can't have children).
 *
 * @param {HTMLElement|string} element Element or element name
 * @return {boolean} Element is a void element
 */
ve.isVoidElement = function ( element ) {
	var elementName = typeof element === 'string' ? element : element.nodeName;
	return ve.elementTypes.void.indexOf( elementName.toLowerCase() ) !== -1;
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
 * @return {HTMLDocument} Document constructed from the HTML string
 */
ve.createDocumentFromHtml = function ( html ) {
	var newDocument;

	newDocument = ve.createDocumentFromHtmlUsingDomParser( html );
	if ( newDocument ) {
		return newDocument;
	}

	newDocument = ve.createDocumentFromHtmlUsingIframe( html );
	if ( newDocument ) {
		return newDocument;
	}

	return ve.createDocumentFromHtmlUsingInnerHtml( html );
};

/**
 * Private method for creating an HTMLDocument using the DOMParser
 *
 * @private
 * @param {string} html HTML string
 * @return {HTMLDocument|undefined} Document constructed from the HTML string or undefined if it failed
 */
ve.createDocumentFromHtmlUsingDomParser = function ( html ) {
	var newDocument;

	// IE doesn't like empty strings
	html = html || '<body></body>';

	try {
		newDocument = new DOMParser().parseFromString( html, 'text/html' );
		if ( newDocument ) {
			return newDocument;
		}
	} catch ( e ) { }
};

/**
 * Private fallback for browsers which don't support DOMParser
 *
 * @private
 * @param {string} html HTML string
 * @return {HTMLDocument|undefined} Document constructed from the HTML string or undefined if it failed
 */
ve.createDocumentFromHtmlUsingIframe = function ( html ) {
	var newDocument, $iframe, iframe;
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

	html = html || '<body></body>';

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
		return;
	}

	return newDocument;
};

/**
 * Private fallback for browsers which don't support iframe technique
 *
 * @private
 * @param {string} html HTML string
 * @return {HTMLDocument} Document constructed from the HTML string
 */
ve.createDocumentFromHtmlUsingInnerHtml = function ( html ) {
	var i, htmlAttributes, wrapper, attributes,
		newDocument = document.implementation.createHTMLDocument( '' );

	html = html || '<body></body>';

	// Carefully unwrap the HTML out of the root node (and doctype, if any).
	newDocument.documentElement.innerHTML = html
		.replace( /^\s*(?:<!doctype[^>]*>)?\s*<html[^>]*>/i, '' )
		.replace( /<\/html>\s*$/i, '' );

	// Preserve <html> attributes, if any
	htmlAttributes = html.match( /<html([^>]*>)/i );
	if ( htmlAttributes && htmlAttributes[ 1 ] ) {
		wrapper = document.createElement( 'div' );
		wrapper.innerHTML = '<div ' + htmlAttributes[ 1 ] + '></div>';
		attributes = wrapper.firstChild.attributes;
		for ( i = 0; i < attributes.length; i++ ) {
			newDocument.documentElement.setAttribute(
				attributes[ i ].name,
				attributes[ i ].value
			);
		}
	}

	return newDocument;
};

/**
 * Resolve a URL relative to a given base.
 *
 * @param {string} url URL to resolve
 * @param {HTMLDocument} base Document whose base URL to use
 * @return {string} Resolved URL
 */
ve.resolveUrl = function ( url, base ) {
	var node = base.createElement( 'a' );
	node.setAttribute( 'href', url );
	// If doc.baseURI isn't set, node.href will be an empty string
	// This is crazy, returning the original URL is better
	return node.href || url;
};

/**
 * Modify a set of DOM elements to resolve attributes in the context of another document.
 *
 * This performs node.setAttribute( 'attr', nodeInDoc[attr] ); for every node.
 *
 * @param {jQuery} $elements Set of DOM elements to modify
 * @param {HTMLDocument} doc Document to resolve against (different from $elements' .ownerDocument)
 * @param {string[]} attrs Attributes to resolve
 */
ve.resolveAttributes = function ( $elements, doc, attrs ) {
	var i, len, attr;

	/**
	 * Callback for jQuery.fn.each that resolves the value of attr to the computed
	 * property value. Called in the context of an HTMLElement.
	 *
	 * @private
	 */
	function resolveAttribute() {
		var nodeInDoc = doc.createElement( this.nodeName );
		nodeInDoc.setAttribute( attr, this.getAttribute( attr ) );
		if ( nodeInDoc[ attr ] ) {
			this.setAttribute( attr, nodeInDoc[ attr ] );
		}
	}

	for ( i = 0, len = attrs.length; i < len; i++ ) {
		attr = attrs[ i ];
		$elements.find( '[' + attr + ']' ).each( resolveAttribute );
		$elements.filter( '[' + attr + ']' ).each( resolveAttribute );
	}
};

/**
 * Take a target document with a possibly relative base URL, and modify it to be absolute.
 * The base URL of the target document is resolved using the base URL of the source document.
 *
 * Note that the the fallbackBase parameter will be used if there is no <base> tag, even if
 * the document does have a valid base URL: this is to work around Firefox's behavior of having
 * documents created by DOMParser inherit the base URL of the main document.
 *
 * @param {HTMLDocument} targetDoc Document whose base URL should be resolved
 * @param {HTMLDocument} sourceDoc Document whose base URL should be used for resolution
 * @param {string} [fallbackBase] Base URL to use if resolving the base URL fails or there is no <base> tag
 */
ve.fixBase = function ( targetDoc, sourceDoc, fallbackBase ) {
	var baseNode = targetDoc.getElementsByTagName( 'base' )[ 0 ];
	if ( baseNode ) {
		if ( !targetDoc.baseURI ) {
			// <base> tag present but not valid, try resolving its URL
			baseNode.setAttribute( 'href', ve.resolveUrl( baseNode.getAttribute( 'href' ), sourceDoc ) );
			if ( !targetDoc.baseURI && fallbackBase ) {
				// That didn't work, use the fallback
				baseNode.setAttribute( 'href', fallbackBase );
			}
		}
		// else: <base> tag present and valid, do nothing
	} else if ( fallbackBase ) {
		// No <base> tag, add one
		baseNode = targetDoc.createElement( 'base' );
		baseNode.setAttribute( 'href', fallbackBase );
		targetDoc.head.appendChild( baseNode );
	}
};

/**
 * Check if a string is a valid URI component.
 *
 * A URI component is considered invalid if decodeURIComponent() throws an exception.
 *
 * @param {string} s String to test
 * @return {boolean} decodeURIComponent( s ) did not throw an exception
 * @see #safeDecodeURIComponent
 */
ve.isUriComponentValid = function ( s ) {
	try {
		decodeURIComponent( s );
	} catch ( e ) {
		return false;
	}
	return true;
};

/**
 * Safe version of decodeURIComponent() that doesn't throw exceptions.
 *
 * If the native decodeURIComponent() call threw an exception, the original string
 * will be returned.
 *
 * @param {string} s String to decode
 * @return {string} Decoded string, or same string if decoding failed
 * @see #isUriComponentValid
 */
ve.safeDecodeURIComponent = function ( s ) {
	try {
		s = decodeURIComponent( s );
	} catch ( e ) {}
	return s;
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
 * @return {string} Inner HTML
 */
ve.properInnerHtml = function ( element ) {
	return ve.fixupPreBug( element ).innerHTML;
};

/**
 * Get the actual outer HTML of a DOM node.
 *
 * @see ve#properInnerHtml
 * @param {HTMLElement} element HTML element to get outer HTML of
 * @return {string} Outer HTML
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
 * @return {HTMLElement} Either element, or a fixed-up clone of it
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
			if ( matches && matches[ 1 ] ) {
				// Prepend a newline exactly like the one we saw
				this.firstChild.insertData( 0, matches[ 1 ] );
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
 * @return {string} HTML string modified to mask/unmask broken attributes
 */
ve.transformStyleAttributes = function ( html, unmask ) {
	var xmlDoc, fromAttr, toAttr, i, len,
		maskAttrs = [
			'style', // IE normalizes 'color:#ffd' to 'color: rgb(255, 255, 221);'
			'bgcolor', // IE normalizes '#FFDEAD' to '#ffdead'
			'color', // IE normalizes 'Red' to 'red'
			'width', // IE normalizes '240px' to '240'
			'height', // Same as width
			'rowspan', // IE and Firefox normalize rowspan="02" to rowspan="2"
			'colspan' // Same as rowspan
		];

	// Parse the HTML into an XML DOM
	xmlDoc = new DOMParser().parseFromString( html, 'text/xml' );

	// Go through and mask/unmask each attribute on all elements that have it
	for ( i = 0, len = maskAttrs.length; i < len; i++ ) {
		fromAttr = unmask ? 'data-ve-' + maskAttrs[ i ] : maskAttrs[ i ];
		toAttr = unmask ? maskAttrs[ i ] : 'data-ve-' + maskAttrs[ i ];
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
 *
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
 *
 * @param {Array} rects Full list of rectangles
 * @return {Object|null} Object containing two rectangles: start and end, or null if there are no rectangles
 */
ve.getStartAndEndRects = function ( rects ) {
	var i, l, startRect, endRect;
	if ( !rects || !rects.length ) {
		return null;
	}
	for ( i = 0, l = rects.length; i < l; i++ ) {
		if ( !startRect || rects[ i ].top < startRect.top ) {
			// Use ve.extendObject as ve.copy copies non-plain objects by reference
			startRect = ve.extendObject( {}, rects[ i ] );
		} else if ( rects[ i ].top === startRect.top ) {
			// Merge rects with the same top coordinate
			startRect.left = Math.min( startRect.left, rects[ i ].left );
			startRect.right = Math.max( startRect.right, rects[ i ].right );
			startRect.width = startRect.right - startRect.left;
		}
		if ( !endRect || rects[ i ].bottom > endRect.bottom ) {
			// Use ve.extendObject as ve.copy copies non-plain objects by reference
			endRect = ve.extendObject( {}, rects[ i ] );
		} else if ( rects[ i ].bottom === endRect.bottom ) {
			// Merge rects with the same bottom coordinate
			endRect.left = Math.min( endRect.left, rects[ i ].left );
			endRect.right = Math.max( endRect.right, rects[ i ].right );
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
 * @param {...Node} DOM nodes in the same document
 * @return {Node|null} Nearest common ancestor node
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
 * Compare two tuples in lexicographical order.
 *
 * This function first compares `a[0]` with `b[0]`, then `a[1]` with `b[1]`, etc.
 * until it encounters a pair where `a[k] != b[k]`; then returns `a[k] - b[k]`.
 *
 * If `a[k] == b[k]` for every `k`, this function returns 0.
 *
 * If a and b are of unequal length, but `a[k] == b[k]` for all `k` that exist in both a and b, then
 * this function returns `Infinity` (if a is longer) or `-Infinity` (if b is longer).
 *
 * @param {number[]} a First tuple
 * @param {number[]} b Second tuple
 * @return {number} `a[k] - b[k]` where k is the lowest k such that `a[k] != b[k]`
 */
ve.compareTuples = function ( a, b ) {
	var i, len;
	for ( i = 0, len = Math.min( a.length, b.length ); i < len; i++ ) {
		if ( a[ i ] !== b[ i ] ) {
			return a[ i ] - b[ i ];
		}
	}
	if ( a.length > b.length ) {
		return Infinity;
	}
	if ( a.length < b.length ) {
		return -Infinity;
	}
	return 0;
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
	return ve.compareTuples(
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
 * @return {string} Client platform string
 */
ve.getSystemPlatform = function () {
	return ( ve.init.platform && ve.init.platform.constructor || ve.init.Platform ).static.getSystemPlatform();
};

/**
 * Highlight text where a substring query matches
 *
 * @param {string} text Text
 * @param {string} query Query to find
 * @return {jQuery} Text with query substring wrapped in highlighted span
 */
ve.highlightQuery = function ( text, query ) {
	var $result = $( '<span>' ),
		offset = text.toLowerCase().indexOf( query.toLowerCase() );

	if ( !query.length || offset === -1 ) {
		return $result.text( text );
	}
	$result.append(
		document.createTextNode( text.slice( 0, offset ) ),
		$( '<span>' )
			.addClass( 've-ui-query-highlight' )
			.text( text.slice( offset, offset + query.length ) ),
		document.createTextNode( text.slice( offset + query.length ) )
	);
	return $result.contents();
};

/**
 * Get the closest matching DOM position in document order (forward or reverse)
 *
 * A DOM position is represented as an object with "node" and "offset" properties. The noDescend
 * option can be used to exclude the positions inside certain element nodes; it is a jQuery
 * selector/function ( used as a test by $node.is() - see http://api.jquery.com/is/ ); it defaults
 * to ve.rejectsCursor. Void elements (those matching ve.isVoidElement) are always excluded.
 *
 * If the skipSoft option is true (default), positions cursor-equivalent to the start position are
 * stepped over and the nearest non-equivalent position is returned. Cursor-equivalent positions
 * include just before/just after the boundary of a text element or an annotation element. So in
 * &lt;#text&gt;X&lt;/#text&gt;&lt;b&gt;&lt;#text&gt;y&lt;/#text&gt;&lt;/b&gt; there are four
 * cursor-equivalent positions between X and Y.
 * Chromium normalizes cursor focus/offset, when they are set, to the start-most equivalent
 * position in document order. Firefox does not normalize, but jumps when cursoring over positions
 * that are equivalent to the start position.
 *
 * As well as the end position, an array of the steps taken is returned. This will have length 1
 * unless skipSoft is true. Each step gives the node, the type of crossing (which can be
 * "enter", "leave", or "cross" for any node, or "internal" for a step over a
 * character in a text node), and the offset (defined for "internal" steps only).
 *
 * Limitation: skipSoft treats the interior of grapheme clusters as non-equivalent, but in fact
 * browser cursoring does skip over most grapheme clusters e.g. 'x\u0301' (though not all e.g.
 * '\u062D\u0627').
 *
 * Limitation: some DOM positions cannot actually hold the cursor; e.g. the start of the interior
 * of a table node.
 *
 * @param {Object} position Start position
 * @param {Node} position.node Start node
 * @param {Node} position.offset Start offset
 * @param {number} direction +1 for forward, -1 for reverse
 * @param {Object} [options]
 * @param {Function|string} [options.noDescend] Selector or function: nodes to skip over
 * @param {boolean} [options.skipSoft] Skip tags that don't expend a cursor press (default: true)
 * @return {Object} The adjacent DOM position encountered
 * @return {Node|null} return.node The node, or null if we stepped past the root node
 * @return {number|null} return.offset The offset, or null if we stepped past the root node
 * @return {Object[]} return.steps Steps taken {node: x, type: leave|cross|enter|internal, offset: n}
 */
ve.adjacentDomPosition = function ( position, direction, options ) {
	var forward, childNode, isHard, noDescend, skipSoft,
		node = position.node,
		offset = position.offset,
		steps = [];

	options = options || {};
	noDescend = options.noDescend || ve.rejectsCursor;
	skipSoft = 'skipSoft' in options ? options.skipSoft : true;

	direction = direction < 0 ? -1 : 1;
	forward = ( direction === 1 );

	while ( true ) {
		// If we're at the node's leading edge, move to the adjacent position in the parent node
		if ( offset === ( forward ? node.length || node.childNodes.length : 0 ) ) {
			steps.push( {
				node: node,
				type: 'leave'
			} );
			isHard = ve.hasHardCursorBoundaries( node );
			if ( node.parentNode === null ) {
				return {
					node: null,
					offset: null,
					steps: steps
				};
			}
			offset = Array.prototype.indexOf.call( node.parentNode.childNodes, node ) +
				( forward ? 1 : 0 );
			node = node.parentNode;
			if ( !skipSoft || isHard ) {
				return {
					node: node,
					offset: offset,
					steps: steps
				};
			}
			// Else take another step
			continue;
		}
		// Else we're in the interior of a node

		// If we're in a text node, move to the position in this node at the next offset
		if ( node.nodeType === Node.TEXT_NODE ) {
			steps.push( {
				node: node,
				type: 'internal',
				offset: offset - ( forward ? 0 : 1 )
			} );
			return {
				node: node,
				offset: offset + direction,
				steps: steps
			};
		}
		// Else we're in the interior of an element node

		childNode = node.childNodes[ forward ? offset : offset - 1 ];

		// If the child is uncursorable, or is an element matching noDescend, do not
		// descend into it: instead, return the position just beyond it in the current node
		if (
			childNode.nodeType === Node.ELEMENT_NODE &&
			( ve.isVoidElement( childNode ) || $( childNode ).is( noDescend ) )
		) {
			steps.push( {
				node: childNode,
				type: 'cross'
			} );
			return {
				node: node,
				offset: offset + ( forward ? 1 : -1 ),
				steps: steps
			};
		}

		// Go to the closest offset inside the child node
		isHard = ve.hasHardCursorBoundaries( childNode );
		node = childNode;
		offset = forward ? 0 : node.length || node.childNodes.length;
		steps.push( {
			node: node,
			type: 'enter'
		} );
		if ( !skipSoft || isHard ) {
			return {
				node: node,
				offset: offset,
				steps: steps
			};
		}
	}
};

/**
 * Test whether crossing a node's boundaries uses up a cursor press
 *
 * Essentially, this is true unless the node is a text node or an annotation node
 *
 * @param {Node} node Element node or text node
 * @return {boolean} Whether crossing the node's boundaries uses up a cursor press
 */
ve.hasHardCursorBoundaries = function ( node ) {
	return node.nodeType === node.ELEMENT_NODE && (
		ve.isBlockElement( node ) || ve.isVoidElement( node )
	);
};

/**
 * Tests whether an adjacent cursor would be prevented from entering the node
 *
 * @param {Node} [node] Element node or text node; defaults to "this" if a Node
 * @return {boolean} Whether an adjacent cursor would be prevented from entering
 */
ve.rejectsCursor = function ( node ) {
	if ( !node && this instanceof Node ) {
		node = this;
	}
	if ( node.nodeType === node.TEXT_NODE ) {
		return false;
	}
	if ( ve.isVoidElement( node ) ) {
		return true;
	}
	// We don't need to check whether the ancestor-nearest contenteditable tag is
	// false, because if so then there can be no adjacent cursor.
	return node.contentEditable === 'false';
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
ve.TriggerListener = function VeTriggerListener( commands, commandRegistry ) {
	// Properties
	this.commands = [];
	this.commandRegistry = commandRegistry;
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
			command = this.commands[ i ];
			triggers = ve.ui.triggerRegistry.lookup( command );
			if ( triggers ) {
				for ( j = triggers.length - 1; j >= 0; j-- ) {
					this.commandsByTrigger[ triggers[ j ].toString() ] = this.commandRegistry.lookup( command );
				}
				this.triggers[ command ] = triggers;
			}
		}
	}
};

/**
 * Get list of commands.
 *
 * @return {string[]} Commands
 */
ve.TriggerListener.prototype.getCommands = function () {
	return this.commands;
};

/**
 * Get command associated with trigger string.
 *
 * @method
 * @param {string} trigger Trigger string
 * @return {ve.ui.Command|undefined} Command
 */
ve.TriggerListener.prototype.getCommandByTrigger = function ( trigger ) {
	return this.commandsByTrigger[ trigger ];
};

/**
 * Get triggers for a specified name.
 *
 * @param {string} name Trigger name
 * @return {ve.ui.Trigger[]|undefined} Triggers
 */
ve.TriggerListener.prototype.getTriggers = function ( name ) {
	return this.triggers[ name ];
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

	// Register
	ve.init.platform = this;

	// Provide messages to OOUI
	OO.ui.getUserLanguages = this.getUserLanguages.bind( this );
	OO.ui.msg = this.getMessage.bind( this );

	// Notify those waiting for a platform that they can finish initialization
	setTimeout( function () {
		ve.init.Platform.static.deferredPlatform.resolve( ve.init.platform );
	} );
};

/* Inheritance */

OO.mixinClass( ve.init.Platform, OO.EventEmitter );

/* Static Properties */

/**
 * A jQuery.Deferred that tracks when the platform has been created.
 * @private
 */
ve.init.Platform.static.deferredPlatform = $.Deferred();

/**
 * A promise that tracks when ve.init.platform is ready for use.  When
 * this promise is resolved the platform will have been created and
 * initialized.
 *
 * This promise is safe to access early in VE startup before
 * `ve.init.platform` has been set.
 *
 * @property {jQuery.Promise}
 */
ve.init.Platform.static.initializedPromise = ve.init.Platform.static.deferredPlatform.promise().then( function ( platform ) {
	return platform.getInitializedPromise();
} );

/* Static Methods */

/**
 * Get client platform string from browser.
 *
 * @static
 * @method
 * @inheritable
 * @return {string} Client platform string
 */
ve.init.Platform.static.getSystemPlatform = function () {
	return $.client.profile().platform;
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
 * @return {boolean} We are in IE
 */
ve.init.Platform.static.isInternetExplorer = function () {
	return $.client.profile().name === 'msie';
};

/**
 * Check whether we are running on iOS
 *
 * @static
 * @method
 * @inheritable
 * @return {boolean} We are running on iOS
 */
ve.init.Platform.static.isIos = function () {
	return /ipad|iphone|ipod/i.test( navigator.userAgent );
};

/* Methods */

/**
 * Get an anchored regular expression that matches allowed external link URLs
 * starting at the beginning of an input string.
 *
 * @method
 * @abstract
 * @return {RegExp} Regular expression object
 */
ve.init.Platform.prototype.getExternalLinkUrlProtocolsRegExp = null;

/**
 * Get an unanchored regular expression that matches allowed external link URLs
 * anywhere in an input string.
 *
 * @method
 * @abstract
 * @return {RegExp} Regular expression object
 */
ve.init.Platform.prototype.getUnanchoredExternalLinkUrlProtocolsRegExp = null;

/**
 * Get a config value from the platform.
 *
 * @method
 * @abstract
 * @param {string|string[]} key Config key, or list of keys
 * @return {Mixed|Object} Config value, or keyed object of config values if list of keys provided
 */
ve.init.Platform.prototype.getConfig = null;

/**
 * Add multiple messages to the localization system.
 *
 * @method
 * @abstract
 * @param {Object} messages Containing plain message values
 */
ve.init.Platform.prototype.addMessages = null;

/**
 * Get a message from the localization system.
 *
 * @method
 * @abstract
 * @param {string} key Message key
 * @param {...Mixed} [args] List of arguments which will be injected at $1, $2, etc. in the message
 * @return {string} Localized message, or key or '<' + key + '>' if message not found
 */
ve.init.Platform.prototype.getMessage = null;

/**
 * Add multiple parsed messages to the localization system.
 *
 * @method
 * @abstract
 * @param {Object} messages Map of message-key/html pairs
 */
ve.init.Platform.prototype.addParsedMessages = null;

/**
 * Get a parsed message as HTML string.
 *
 * Does not support $# replacements.
 *
 * @method
 * @abstract
 * @param {string} key Message key
 * @return {string} Parsed localized message as HTML string
 */
ve.init.Platform.prototype.getParsedMessage = null;

/**
 * Get the user language and any fallback languages.
 *
 * @method
 * @abstract
 * @return {string[]} User language strings
 */
ve.init.Platform.prototype.getUserLanguages = null;

/**
 * Get a list of URL entry points where media can be found.
 *
 * @method
 * @abstract
 * @return {string[]} API URLs
 */
ve.init.Platform.prototype.getMediaSources = null;

/**
 * Get a list of all language codes.
 *
 * @method
 * @abstract
 * @return {string[]} Language codes
 */
ve.init.Platform.prototype.getLanguageCodes = null;

/**
 * Get a language's name from its code, in the current user language if possible.
 *
 * @method
 * @abstract
 * @param {string} code Language code
 * @return {string} Language name
 */
ve.init.Platform.prototype.getLanguageName = null;

/**
 * Get a language's autonym from its code.
 *
 * @method
 * @abstract
 * @param {string} code Language code
 * @return {string} Language autonym
 */
ve.init.Platform.prototype.getLanguageAutonym = null;

/**
 * Get a language's direction from its code.
 *
 * @method
 * @abstract
 * @param {string} code Language code
 * @return {string} Language direction
 */
ve.init.Platform.prototype.getLanguageDirection = null;

/**
 * Initialize the platform. The default implementation is to do nothing and return a resolved
 * promise. Subclasses should override this if they have asynchronous initialization work to do.
 *
 * External callers should not call this. Instead, call #getInitializedPromise.
 *
 * @private
 * @return {jQuery.Promise} Promise that will be resolved once initialization is done
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
 * @return {jQuery.Promise} Promise that will be resolved once the platform is ready
 */
ve.init.Platform.prototype.getInitializedPromise = function () {
	if ( !this.initialized ) {
		this.initialized = this.initialize();
	}
	return this.initialized;
};

/**
 * Fetch the special character list object
 *
 * Returns a promise which resolves with the character list
 *
 * @return {jQuery.Promise}
 */
ve.init.Platform.prototype.fetchSpecialCharList = function () {
	var charsObj = {};

	try {
		charsObj = JSON.parse(
			ve.msg( 'visualeditor-specialcharinspector-characterlist-insert' )
		);
	} catch ( err ) {
		// There was no character list found, or the character list message is
		// invalid json string. Force a fallback to the minimal character list
		ve.log( 've.init.Platform: Could not parse the Special Character list.' );
		ve.log( err.message );
	}

	// This implementation always resolves instantly
	return $.Deferred().resolve( charsObj ).promise();
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
 * @param {Object} [config] Configuration options
 * @cfg {Object} [toolbarConfig] Configuration options for the toolbar
 * @cfg {ve.ui.CommandRegistry} [commandRegistry] Command registry to use
 * @cfg {ve.ui.SequenceRegistry} [sequenceRegistry] Sequence registry to use
 * @cfg {ve.ui.DataTransferHandlerFactory} [dataTransferHandlerFactory] Data transfer handler factory to use
 */
ve.init.Target = function VeInitTarget( config ) {
	config = config || {};

	// Parent constructor
	ve.init.Target.super.call( this, config );

	// Mixin constructors
	OO.EventEmitter.call( this );

	// Register
	ve.init.target = this;

	// Properties
	this.surfaces = [];
	this.surface = null;
	this.toolbar = null;
	this.toolbarConfig = config.toolbarConfig;
	this.commandRegistry = config.commandRegistry || ve.ui.commandRegistry;
	this.sequenceRegistry = config.sequenceRegistry || ve.ui.sequenceRegistry;
	this.dataTransferHandlerFactory = config.dataTransferHandlerFactory || ve.ui.dataTransferHandlerFactory;
	this.documentTriggerListener = new ve.TriggerListener( this.constructor.static.documentCommands, this.commandRegistry );
	this.targetTriggerListener = new ve.TriggerListener( this.constructor.static.targetCommands, this.commandRegistry );
	this.$scrollContainer = this.getScrollContainer();
	this.toolbarScrollOffset = 0;

	// Initialization
	this.$element.addClass( 've-init-target' );

	if ( ve.init.platform.constructor.static.isInternetExplorer() ) {
		this.$element.addClass( 've-init-target-ie' );
	}

	// Events
	this.onDocumentKeyDownHandler = this.onDocumentKeyDown.bind( this );
	this.onTargetKeyDownHandler = this.onTargetKeyDown.bind( this );
	this.onContainerScrollHandler = this.onContainerScroll.bind( this );
	this.bindHandlers();
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
		icon: 'listBullet',
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
		icon: 'table',
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
ve.init.Target.static.documentCommands = [ 'commandHelp' ];

/**
 * List of commands which can be triggered from within the target element
 *
 * @type {string[]} List of command names
 */
ve.init.Target.static.targetCommands = [ 'findAndReplace', 'findNext', 'findPrevious' ];

/**
 * List of commands to include in the target
 *
 * Null means all commands in the registry are used (excluding excludeCommands)
 *
 * @type {string[]|null} List of command names
 */
ve.init.Target.static.includeCommands = null;

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
			'textStyle/span', 'textStyle/font',
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
	this.$scrollContainer.on( 'scroll', this.onContainerScrollHandler );
};

/**
 * Unbind event handlers on target and document
 */
ve.init.Target.prototype.unbindHandlers = function () {
	$( this.getElementDocument() ).off( 'keydown', this.onDocumentKeyDownHandler );
	this.$element.off( 'keydown', this.onTargetKeyDownHandler );
	this.$scrollContainer.off( 'scroll', this.onContainerScrollHandler );
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
 * Get the target's scroll container
 *
 * @return {jQuery} The target's scroll container
 */
ve.init.Target.prototype.getScrollContainer = function () {
	return $( this.getElementWindow() );
};

/**
 * Handle scroll container scroll events
 */
ve.init.Target.prototype.onContainerScroll = function () {
	var scrollTop,
		toolbar = this.getToolbar();

	if ( toolbar.isFloatable() ) {
		scrollTop = this.$scrollContainer.scrollTop();

		if ( scrollTop + this.toolbarScrollOffset > toolbar.getElementOffset().top ) {
			toolbar.float();
		} else {
			toolbar.unfloat();
		}
	}
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
 * Handle toolbar resize events
 */
ve.init.Target.prototype.onToolbarResize = function () {
	this.getSurface().setToolbarHeight( this.getToolbar().getHeight() + this.toolbarScrollOffset );
};

/**
 * Create a surface.
 *
 * @method
 * @param {ve.dm.Document} dmDoc Document model
 * @param {Object} [config] Configuration options
 * @return {ve.ui.DesktopSurface}
 */
ve.init.Target.prototype.createSurface = function ( dmDoc, config ) {
	return new ve.ui.DesktopSurface( new ve.dm.Surface( dmDoc ),
		this.commandRegistry, this.sequenceRegistry, this.getSurfaceConfig( config ) );
};

/**
 * Get surface configuration options
 *
 * @param {Object} config Configuration option overrides
 * @return {Object} Surface configuration options
 */
ve.init.Target.prototype.getSurfaceConfig = function ( config ) {
	return ve.extendObject( {
		includeCommands: this.constructor.static.includeCommands,
		excludeCommands: OO.simpleArrayUnion(
			this.constructor.static.excludeCommands,
			this.constructor.static.documentCommands,
			this.constructor.static.targetCommands
		),
		importRules: this.constructor.static.importRules
	}, config );
};

/**
 * Add a surface to the target
 *
 * @param {ve.dm.Document} dmDoc Document model
 * @param {Object} [config] Configuration options
 * @return {ve.ui.DesktopSurface}
 */
ve.init.Target.prototype.addSurface = function ( dmDoc, config ) {
	var surface = this.createSurface( dmDoc, config );
	this.surfaces.push( surface );
	surface.getView().connect( this, {
		focus: this.onSurfaceViewFocus.bind( this, surface ),
		keyup: this.onSurfaceViewKeyUp.bind( this, surface )
	} );
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
 * Handle key up events from a surface's view
 *
 * @param {ve.ui.Surface} surface Surface firing the event
 */
ve.init.Target.prototype.onSurfaceViewKeyUp = function ( surface ) {
	this.scrollCursorIntoView( surface );
};

/**
 * Check if the toolbar is overlapping the surface
 *
 * @return {boolean} Toolbar is overlapping the surface
 */
ve.init.Target.prototype.isToolbarOverSurface = function () {
	return this.getToolbar().isFloating();
};

/**
 * Scroll the cursor into view.
 *
 * @param {ve.ui.Surface} surface Surface to scroll
 */
ve.init.Target.prototype.scrollCursorIntoView = function ( surface ) {
	var nativeRange, clientRect, cursorTop, scrollTo, toolbarBottom;

	if ( !this.isToolbarOverSurface() ) {
		return;
	}

	nativeRange = surface.getView().getNativeRange();
	if ( !nativeRange ) {
		return;
	}

	clientRect = RangeFix.getBoundingClientRect( nativeRange );
	if ( !clientRect ) {
		return;
	}

	cursorTop = clientRect.top - 5;
	toolbarBottom = this.getSurface().toolbarHeight;

	if ( cursorTop < toolbarBottom ) {
		scrollTo = this.$scrollContainer.scrollTop() + cursorTop - toolbarBottom;
		this.scrollTo( scrollTo );
	}
};

/**
 * Scroll the scroll container to a specific offset
 *
 * @param {number} offset Scroll offset
 */
ve.init.Target.prototype.scrollTo = function ( offset ) {
	this.$scrollContainer.scrollTop( offset );
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
 * Get the target's active surface, if it exists
 *
 * @return {ve.ui.Surface|null} Surface
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
	var toolbar = this.getToolbar();

	toolbar.connect( this, { resize: 'onToolbarResize' } );

	toolbar.setup( this.constructor.static.toolbarGroups, surface );
	this.attachToolbar( surface );
	toolbar.$bar.append( surface.getToolbarDialogs().$element );
	this.onContainerScroll();
};

/**
 * Attach the toolbar to the DOM
 */
ve.init.Target.prototype.attachToolbar = function () {
	this.getToolbar().$element.insertBefore( this.getToolbar().getSurface().$element );
	this.getToolbar().initialize();
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
 * @param {number} from Anchor offset
 * @param {number} [to=from] Focus offset
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
 * @return {ve.Range} Range that spans all of the given ranges
 */
ve.Range.static.newCoveringRange = function ( ranges, backwards ) {
	var minStart, maxEnd, i, range;
	if ( !ranges || ranges.length === 0 ) {
		throw new Error( 'newCoveringRange() requires at least one range' );
	}
	minStart = ranges[ 0 ].start;
	maxEnd = ranges[ 0 ].end;
	for ( i = 1; i < ranges.length; i++ ) {
		if ( ranges[ i ].start < minStart ) {
			minStart = ranges[ i ].start;
		}
		if ( ranges[ i ].end > maxEnd ) {
			maxEnd = ranges[ i ].end;
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
 * @return {ve.Range} Clone of range
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
 * @return {boolean} If offset is within the range
 */
ve.Range.prototype.containsOffset = function ( offset ) {
	return offset >= this.start && offset < this.end;
};

/**
 * Check if another range is within the range.
 *
 * @param {ve.Range} range Range to check
 * @return {boolean} If other range is within the range
 */
ve.Range.prototype.containsRange = function ( range ) {
	return range.start >= this.start && range.end <= this.end;
};

/**
 * Check if another range is intersects with this range.
 *
 * @param {ve.Range} other Range to check
 * @return {boolean} If other range intersects with the range
 */
ve.Range.prototype.intersects = function ( other ) {
	return !( other.end < this.start || other.start > this.end );
};

/**
 * Get the length of the range.
 *
 * @return {number} Length of range
 */
ve.Range.prototype.getLength = function () {
	return this.end - this.start;
};

/**
 * Gets a range with reversed direction.
 *
 * @return {ve.Range} A new range
 */
ve.Range.prototype.flip = function () {
	return new ve.Range( this.to, this.from );
};

/**
 * Get a range that's a translated version of this one.
 *
 * @param {number} distance Distance to move range by
 * @return {ve.Range} New translated range
 */
ve.Range.prototype.translate = function ( distance ) {
	return new ve.Range( this.from + distance, this.to + distance );
};

/**
 * Check if two ranges are equal, taking direction into account.
 *
 * @param {ve.Range|null} other
 * @return {boolean}
 */
ve.Range.prototype.equals = function ( other ) {
	return other && this.from === other.from && this.to === other.to;
};

/**
 * Check if two ranges are equal, ignoring direction.
 *
 * @param {ve.Range|null} other
 * @return {boolean}
 */
ve.Range.prototype.equalsSelection = function ( other ) {
	return other && this.end === other.end && this.start === other.start;
};

/**
 * Create a new range with a limited length.
 *
 * @param {number} length Length of the new range (negative for truncate from right)
 * @return {ve.Range} A new range
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
	return ve.Range.static.newCoveringRange( [ this, other ], this.isBackwards() );
};

/**
 * Check if the range is collapsed.
 *
 * A collapsed range has equal start and end values making its length zero.
 *
 * @return {boolean} Range is collapsed
 */
ve.Range.prototype.isCollapsed = function () {
	return this.from === this.to;
};

/**
 * Check if the range is backwards, i.e. from > to
 *
 * @return {boolean} Range is backwards
 */
ve.Range.prototype.isBackwards = function () {
	return this.from > this.to;
};

/**
 * Get a object summarizing the range for JSON serialization
 *
 * @return {Object} Object for JSON serialization
 */
ve.Range.prototype.toJSON = function () {
	return {
		type: 'range',
		from: this.from,
		to: this.to
	};
};

/*!
 * VisualEditor DOM selection-like class
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Like the DOM Selection object, but not updated live from the actual selection
 *
 * WARNING: the Nodes are still live and mutable, which can change the meaning
 * of the offsets or invalidate the value of isBackwards.
 *
 * @class
 *
 * @constructor
 * @param {ve.SelectionState|Selection|Object} selection DOM Selection-like object
 * @param {Node|null} selection.anchorNode the Anchor node (null if no selection)
 * @param {number} selection.anchorOffset the Anchor offset (0 if no selection)
 * @param {Node|null} selection.focusNode the Focus node (null if no selection)
 * @param {number} selection.focusOffset the Focusoffset (0 if no selection)
 * @param {boolean} [selection.isCollapsed] Whether the anchor and focus are the same
 * @param {boolean} [selection.isBackwards] Whether the focus is before the anchor in document order
 */
ve.SelectionState = function VeSelectionState( selection ) {
	this.anchorNode = selection.anchorNode;
	this.anchorOffset = selection.anchorOffset;
	this.focusNode = selection.focusNode;
	this.focusOffset = selection.focusOffset;

	this.isCollapsed = selection.isCollapsed;
	if ( this.isCollapsed === undefined ) {
		// Set to true if nodes are null (matches DOM Selection object's behaviour)
		this.isCollapsed = this.anchorNode === this.focusNode &&
			this.anchorOffset === this.focusOffset;
	}
	this.isBackwards = selection.isBackwards;
	if ( this.isBackwards === undefined ) {
		// Set to false if nodes are null
		this.isBackwards = this.focusNode !== null && ve.compareDocumentOrder(
			this.focusNode,
			this.focusOffset,
			this.anchorNode,
			this.anchorOffset
		) < 0;
	}
};

/* Inheritance */

OO.initClass( ve.SelectionState );

/* Static methods */

/**
 * Create a selection state object representing no selection
 *
 * @return {ve.SelectionState} Object representing no selection
 */
ve.SelectionState.static.newNullSelection = function () {
	return new ve.SelectionState( {
		focusNode: null,
		focusOffset: 0,
		anchorNode: null,
		anchorOffset: 0
	} );
};

/* Methods */

/**
 * Returns the selection with the anchor and focus swapped
 *
 * @return {ve.SelectionState} selection with anchor/focus swapped. Object-identical to this if isCollapsed
 */
ve.SelectionState.prototype.flip = function () {
	if ( this.isCollapsed ) {
		return this;
	}
	return new ve.SelectionState( {
		anchorNode: this.focusNode,
		anchorOffset: this.focusOffset,
		focusNode: this.anchorNode,
		focusOffset: this.anchorOffset,
		isCollapsed: false,
		isBackwards: !this.isBackwards
	} );
};

/**
 * Whether the selection represents is the same range as another DOM Selection-like object
 *
 * @param {Object} other DOM Selection-like object
 * @return {boolean} True if the anchors/focuses are equal (including null)
 */
ve.SelectionState.prototype.equalsSelection = function ( other ) {
	return this.anchorNode === other.anchorNode &&
		this.anchorOffset === other.anchorOffset &&
		this.focusNode === other.focusNode &&
		this.focusOffset === other.focusOffset;
};

/**
 * Get a range representation of the selection
 *
 * N.B. Range objects do not show whether the selection is backwards
 *
 * @param {HTMLDocument} doc The owner document of the selection nodes
 * @return {Range|null} Range
 */
ve.SelectionState.prototype.getNativeRange = function ( doc ) {
	var range;
	if ( this.anchorNode === null ) {
		return null;
	}
	range = doc.createRange();
	if ( this.isBackwards ) {
		range.setStart( this.focusNode, this.focusOffset );
		range.setEnd( this.anchorNode, this.anchorOffset );
	} else {
		range.setStart( this.anchorNode, this.anchorOffset );
		if ( !this.isCollapsed ) {
			range.setEnd( this.focusNode, this.focusOffset );
		}
	}
	return range;
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
 * @return {string[]|null} List of node types allowed as children or null if any type is allowed
 */
ve.Node.prototype.getChildNodeTypes = null;

/**
 * Get allowed parent node types.
 *
 * @method
 * @abstract
 * @return {string[]|null} List of node types allowed as parents or null if any type is allowed
 */
ve.Node.prototype.getParentNodeTypes = null;

/**
 * Check if the specified type is an allowed child node type
 *
 * @param {string} type Node type
 * @return {boolean} The type is allowed
 */
ve.Node.prototype.isAllowedChildNodeType = function ( type ) {
	var childTypes = this.getChildNodeTypes();
	return childTypes === null || childTypes.indexOf( type ) !== -1;
};

/**
 * Check if the specified type is an allowed child node type
 *
 * @param {string} type Node type
 * @return {boolean} The type is allowed
 */
ve.Node.prototype.isAllowedParentNodeType = function ( type ) {
	var parentTypes = this.getParentNodeTypes();
	return parentTypes === null || parentTypes.indexOf( type ) !== -1;
};

/**
 * Get suggested parent node types.
 *
 * @method
 * @abstract
 * @return {string[]|null} List of node types suggested as parents or null if any type is suggested
 */
ve.Node.prototype.getSuggestedParentNodeTypes = null;

/**
 * Check if the node can have children.
 *
 * @method
 * @abstract
 * @return {boolean} Node can have children
 */
ve.Node.prototype.canHaveChildren = null;

/**
 * Check if the node can have children but not content nor be content.
 *
 * @method
 * @abstract
 * @return {boolean} Node can have children but not content nor be content
 */
ve.Node.prototype.canHaveChildrenNotContent = null;

/**
 * Check if the node can contain content.
 *
 * @method
 * @abstract
 * @return {boolean} Node can contain content
 */
ve.Node.prototype.canContainContent = null;

/**
 * Check if the node is content.
 *
 * @method
 * @abstract
 * @return {boolean} Node is content
 */
ve.Node.prototype.isContent = null;

/**
 * Check if the node has a wrapped element in the document data.
 *
 * @method
 * @abstract
 * @return {boolean} Node represents a wrapped element
 */
ve.Node.prototype.isWrapped = null;

/**
 * Check if the node is focusable
 *
 * @method
 * @abstract
 * @return {boolean} Node is focusable
 */
ve.Node.prototype.isFocusable = null;

/**
 * Check if the node is alignable
 *
 * @method
 * @abstract
 * @return {boolean} Node is alignable
 */
ve.Node.prototype.isAlignable = null;

/**
 * Check if the node can behave as a table cell
 *
 * @method
 * @abstract
 * @return {boolean} Node can behave as a table cell
 */
ve.Node.prototype.isCellable = null;

/**
 * Check the node, behaving as a table cell, can be edited in place
 *
 * @method
 * @abstract
 * @return {boolean} Node can be edited in place
 */
ve.Node.prototype.isCellEditable = null;

/**
 * Check if the node has significant whitespace.
 *
 * Can only be true if canContainContent is also true.
 *
 * @method
 * @abstract
 * @return {boolean} Node has significant whitespace
 */
ve.Node.prototype.hasSignificantWhitespace = null;

/**
 * Check if the node handles its own children
 *
 * @method
 * @abstract
 * @return {boolean} Node handles its own children
 */
ve.Node.prototype.handlesOwnChildren = null;

/**
 * Check if the node's children should be ignored.
 *
 * @method
 * @abstract
 * @return {boolean} Node's children should be ignored
 */
ve.Node.prototype.shouldIgnoreChildren = null;

/**
 * Get the length of the node.
 *
 * @method
 * @abstract
 * @return {number} Node length
 */
ve.Node.prototype.getLength = null;

/**
 * Get the offset of the node within the document.
 *
 * If the node has no parent than the result will always be 0.
 *
 * @method
 * @abstract
 * @return {number} Offset of node
 * @throws {Error} Node not found in parent's children array
 */
ve.Node.prototype.getOffset = null;

/**
 * Get the range inside the node.
 *
 * @method
 * @param {boolean} backwards Return a backwards range
 * @return {ve.Range} Inner node range
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
 * @return {ve.Range} Node outer range
 */
ve.Node.prototype.getOuterRange = function ( backwards ) {
	var range = new ve.Range( this.getOffset(), this.getOffset() + this.getOuterLength() );
	return backwards ? range.flip() : range;
};

/**
 * Get the outer length of the node, which includes wrappers if present.
 *
 * @method
 * @return {number} Node outer length
 */
ve.Node.prototype.getOuterLength = function () {
	return this.getLength() + ( this.isWrapped() ? 2 : 0 );
};

/* Methods */

/**
 * Get the symbolic node type name.
 *
 * @method
 * @return {string} Symbolic name of element type
 */
ve.Node.prototype.getType = function () {
	return this.type;
};

/**
 * Get a reference to the node's parent.
 *
 * @method
 * @return {ve.Node} Reference to the node's parent
 */
ve.Node.prototype.getParent = function () {
	return this.parent;
};

/**
 * Get the root node of the tree the node is currently attached to.
 *
 * @method
 * @return {ve.Node} Root node
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
 * @return {ve.Document} Document the node is a part of
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
 * @return {ve.Node|null} Node which caused the traversal to stop, or null if it didn't
 */
ve.Node.prototype.traverseUpstream = function ( callback ) {
	var node = this;
	while ( node ) {
		if ( callback( node ) === false ) {
			return node;
		}
		node = node.getParent();
	}
	return null;
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

/* Setup */

OO.initClass( ve.BranchNode );

/* Static Methods */

/**
 * Traverse a branch node depth-first.
 *
 * @param {ve.BranchNode} node Branch node to traverse
 * @param {Function} callback Callback to execute for each traversed node
 * @param {ve.Node} callback.node Node being traversed
 */
ve.BranchNode.static.traverse = function ( node, callback ) {
	var i, len,
		children = node.getChildren();

	for ( i = 0, len = children.length; i < len; i++ ) {
		callback.call( this, children[ i ] );
		if ( children[ i ] instanceof ve.ce.BranchNode ) {
			this.traverse( children[ i ], callback );
		}
	}
};

/* Methods */

/**
 * Check if the node has children.
 *
 * @method
 * @return {boolean} Whether the node has children
 */
ve.BranchNode.prototype.hasChildren = function () {
	return true;
};

/**
 * Get child nodes.
 *
 * @method
 * @return {ve.Node[]} List of child nodes
 */
ve.BranchNode.prototype.getChildren = function () {
	return this.children;
};

/**
 * Get the index of a child node.
 *
 * @method
 * @param {ve.dm.Node} node Child node to find index of
 * @return {number} Index of child node or -1 if node was not found
 */
ve.BranchNode.prototype.indexOf = function ( node ) {
	return this.children.indexOf( node );
};

/**
 * Set the root node.
 *
 * @method
 * @see ve.Node#setRoot
 * @param {ve.Node} root Node to use as root
 */
ve.BranchNode.prototype.setRoot = function ( root ) {
	var i;
	if ( root === this.root ) {
		// Nothing to do, don't recurse into all descendants
		return;
	}
	this.root = root;
	for ( i = 0; i < this.children.length; i++ ) {
		this.children[ i ].setRoot( root );
	}
};

/**
 * Set the document the node is a part of.
 *
 * @method
 * @see ve.Node#setDocument
 * @param {ve.Document} doc Document this node is a part of
 */
ve.BranchNode.prototype.setDocument = function ( doc ) {
	var i;
	if ( doc === this.doc ) {
		// Nothing to do, don't recurse into all descendants
		return;
	}
	this.doc = doc;
	for ( i = 0; i < this.children.length; i++ ) {
		this.children[ i ].setDocument( doc );
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
 * @return {ve.Node|null} Node at offset, or null if none was found
 */
ve.BranchNode.prototype.getNodeFromOffset = function ( offset, shallow ) {
	var i, length, nodeLength, childNode, nodeOffset;
	if ( offset === 0 ) {
		return this;
	}
	// TODO a lot of logic is duplicated in selectNodes(), abstract that into a traverser or something
	if ( this.children.length ) {
		nodeOffset = 0;
		for ( i = 0, length = this.children.length; i < length; i++ ) {
			childNode = this.children[ i ];
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
 * @return {boolean} Whether the node has children
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
	this.documentNode.setDocument( this );
};

/* Inheritance */

OO.mixinClass( ve.Document, OO.EventEmitter );

/* Methods */

/**
 * Get the root of the document's node tree.
 *
 * @method
 * @return {ve.Node} Root of node tree
 */
ve.Document.prototype.getDocumentNode = function () {
	return this.documentNode;
};

/**
 * Get a node a an offset.
 *
 * @method
 * @param {number} offset Offset to get node at
 * @return {ve.Node|null} Node at offset
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
 * @return {Array} List of objects describing nodes in the selection and the ranges therein:
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
		currentFrame = stack[ 0 ],
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
	left = doc.children[ 0 ].isWrapped() ? 1 : 0;

	do {
		node = currentFrame.node.children[ currentFrame.index ];
		prevNode = currentFrame.node.children[ currentFrame.index - 1 ];
		nextNode = currentFrame.node.children[ currentFrame.index + 1 ];
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
		isEmptyBranch = ( node.getLength() === 0 || node.shouldIgnoreChildren() ) &&
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
			parentFrame = stack[ stack.length - 2 ];
			if ( parentFrame ) {
				retval[ retval.length - 1 ].index = parentFrame.index;
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
			parentFrame = stack[ stack.length - 2 ];
			if ( parentFrame ) {
				retval[ 0 ].index = parentFrame.index;
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
				node.children && node.children.length && !node.shouldIgnoreChildren()
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
				if ( node.children[ 0 ].isWrapped() ) {
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
				if ( node.children[ 0 ].isWrapped() ) {
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
					retval[ 0 ].indexInNode = 0;
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
				if ( node.children[ 0 ].isWrapped() ) {
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
				if ( node.children[ 0 ].isWrapped() ) {
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
				if ( node.children[ 0 ].isWrapped() ) {
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
				if ( node.children[ 0 ].isWrapped() ) {
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
					parentFrame = stack[ stack.length - 2 ];
					if ( parentFrame ) {
						retval[ 0 ].index = parentFrame.index;
					}
				}

				// Move up the stack
				stack.pop();
				if ( stack.length === 0 ) {
					// This shouldn't be possible
					return retval;
				}
				currentFrame = stack[ stack.length - 1 ];
				currentFrame.index++;
				nextNode = currentFrame.node.children[ currentFrame.index ];
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
 * @return {Array} Array of objects. Each object has the following keys:
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
		if ( leaves[ i ].nodeOuterRange.end <= lastEndOffset ) {
			// This range is contained within a range we've already processed
			continue;
		}
		node = leaves[ i ].node;
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
			groups[ groups.length - 1 ].nodes.push( siblingNode );
			lastCoveredSibling = siblingNode;
			i++;
			if ( leaves[ i ] === undefined ) {
				break;
			}
			// Traverse up to a content branch from content elements
			siblingNode = leaves[ i ].node;
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
 * @return {boolean} Whether the range lies within a single node
 */
ve.Document.prototype.rangeInsideOneLeafNode = function ( range ) {
	var selected = this.selectNodes( range, 'leaves' );
	return selected.length === 1 && selected[ 0 ].nodeRange.containsRange( range ) && selected[ 0 ].indexInNode === undefined;
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
	 * @return {Function} An event handler
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
		eventName = eventNames[ i ];
		this.onListenersForEvent[ eventName ] = [];
		this.afterListenersForEvent[ eventName ] = [];
		this.afterOneListenersForEvent[ eventName ] = [];
		this.eventHandlers[ eventName ] = makeEventHandler( eventName );
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
 *
 * @method
 * @param {Function|Function[]} listeners Listener(s) that take no arguments
 * @chainable
 */
ve.EventSequencer.prototype.onLoop = function ( listeners ) {
	if ( !Array.isArray( listeners ) ) {
		listeners = [ listeners ];
	}
	ve.batchPush( this.onLoopListeners, listeners );
	return this;
};

/**
 * Add listeners to be fired just before the browser native action
 *
 * @method
 * @param {Object.<string,Function>} listeners Function for each event
 * @chainable
 */
ve.EventSequencer.prototype.on = function ( listeners ) {
	var eventName;
	for ( eventName in listeners ) {
		this.onListenersForEvent[ eventName ].push( listeners[ eventName ] );
	}
	return this;
};

/**
 * Add listeners to be fired as soon as possible after the native action
 *
 * @method
 * @param {Object.<string,Function>} listeners Function for each event
 * @chainable
 */
ve.EventSequencer.prototype.after = function ( listeners ) {
	var eventName;
	for ( eventName in listeners ) {
		this.afterListenersForEvent[ eventName ].push( listeners[ eventName ] );
	}
	return this;
};

/**
 * Add listeners to be fired once, as soon as possible after the native action
 *
 * @method
 * @param {Object.<string,Function[]>} listeners Function for each event
 * @chainable
 */
ve.EventSequencer.prototype.afterOne = function ( listeners ) {
	var eventName;
	for ( eventName in listeners ) {
		this.afterOneListenersForEvent[ eventName ].push( listeners[ eventName ] );
	}
	return this;
};

/**
 * Add listeners to be fired at the end of the Javascript event loop iteration
 *
 * @method
 * @param {Function|Function[]} listeners Listener(s) that take no arguments
 * @chainable
 */
ve.EventSequencer.prototype.afterLoop = function ( listeners ) {
	if ( !Array.isArray( listeners ) ) {
		listeners = [ listeners ];
	}
	ve.batchPush( this.afterLoopListeners, listeners );
	return this;
};

/**
 * Add listeners to be fired once, at the end of the Javascript event loop iteration
 *
 * @method
 * @param {Function|Function[]} listeners Listener(s) that take no arguments
 * @chainable
 */
ve.EventSequencer.prototype.afterLoopOne = function ( listeners ) {
	if ( !Array.isArray( listeners ) ) {
		listeners = [ listeners ];
	}
	ve.batchPush( this.afterLoopOneListeners, listeners );
	return this;
};

/**
 * Generic listener method which does the sequencing
 *
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
		onListener = onListeners[ i ];
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
 *
 * @private
 * @method
 * @param {string} eventName Javascript name of the event, e.g. 'keydown'
 * @param {jQuery.Event} ev The browser event
 */
ve.EventSequencer.prototype.afterEvent = function ( eventName, ev ) {
	var i, len, afterListeners, afterOneListeners;

	// Snapshot the listener lists, and blank *OneListener list.
	// This ensures reasonable behaviour if a function called adds another listener.
	afterListeners = ( this.afterListenersForEvent[ eventName ] || [] ).slice();
	afterOneListeners = ( this.afterOneListenersForEvent[ eventName ] || [] ).slice();
	( this.afterOneListenersForEvent[ eventName ] || [] ).length = 0;

	for ( i = 0, len = afterListeners.length; i < len; i++ ) {
		this.callListener( 'after', eventName, i, afterListeners[ i ], ev );
	}

	for ( i = 0, len = afterOneListeners.length; i < len; i++ ) {
		this.callListener( 'afterOne', eventName, i, afterOneListeners[ i ], ev );
	}
};

/**
 * Call each onLoopListener once
 *
 * @private
 * @method
 */
ve.EventSequencer.prototype.doOnLoop = function () {
	var i, len;
	// Length cache 'len' is required, as the functions called may add another listener
	for ( i = 0, len = this.onLoopListeners.length; i < len; i++ ) {
		this.callListener( 'onLoop', null, i, this.onLoopListeners[ i ], null );
	}
};

/**
 * Call each afterLoopListener once, unless the setTimeout is already cancelled
 *
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

	for ( i = 0, len = afterLoopListeners.length; i < len; i++ ) {
		this.callListener( 'afterLoop', null, i, this.afterLoopListeners[ i ], null );
	}

	for ( i = 0, len = afterLoopOneListeners.length; i < len; i++ ) {
		this.callListener( 'afterLoopOne', null, i, afterLoopOneListeners[ i ], null );
	}
	this.doneOnLoop = false;
};

/**
 * Push any pending doAfterLoop to end of task queue (cancel, then re-set)
 *
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
 *
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
		pendingCall = this.pendingCalls[ i ];
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
 * @return {number} Unique postponed timeout id
 */
ve.EventSequencer.prototype.postpone = function ( callback ) {
	return setTimeout( callback );
};

/**
 * Cancel a postponed call.
 *
 * This is a separate function because that makes it easier to replace when testing
 *
 * @param {number} timeoutId Unique postponed timeout id
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
 *     @example
 *     var platform = new ve.init.sa.Platform( ve.messagePaths );
 *     platform.initialize().done( function () {
 *         $( 'body' ).append( $( '<p>' ).text(
 *             platform.getMessage( 'visualeditor' )
 *         ) );
 *     } );
 *
 * @class
 * @extends ve.init.Platform
 *
 * @constructor
 * @param {string[]} [messagePaths] Message folder paths
 */
ve.init.sa.Platform = function VeInitSaPlatform( messagePaths ) {
	// Parent constructor
	ve.init.Platform.call( this );

	// Properties
	this.externalLinkUrlProtocolsRegExp = /^https?\:\/\//i;
	this.unanchoredExternalLinkUrlProtocolsRegExp = /https?\:\/\//i;
	this.messagePaths = messagePaths || [];
	this.parsedMessages = {};
	this.userLanguages = [ 'en' ];
};

/* Inheritance */

OO.inheritClass( ve.init.sa.Platform, ve.init.Platform );

/* Methods */

/** @inheritdoc */
ve.init.sa.Platform.prototype.getExternalLinkUrlProtocolsRegExp = function () {
	return this.externalLinkUrlProtocolsRegExp;
};

/** @inheritdoc */
ve.init.sa.Platform.prototype.getUnanchoredExternalLinkUrlProtocolsRegExp = function () {
	return this.unanchoredExternalLinkUrlProtocolsRegExp;
};

/**
 * Get message folder paths
 *
 * @return {string[]} Message folder paths
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
	var key;
	for ( key in messages ) {
		this.parsedMessages[ key ] = messages[ key ];
	}
};

/** @inheritdoc */
ve.init.sa.Platform.prototype.getParsedMessage = function ( key ) {
	if ( Object.prototype.hasOwnProperty.call( this.parsedMessages, key ) ) {
		return this.parsedMessages[ key ];
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
		fallbacks = $.i18n.fallbacks[ locale ];

	if ( !fallbacks ) {
		// Try to find something that has fallbacks (which means it's a language we know about)
		// by stripping things from the end. But collect all the intermediate ones in case we
		// go past languages that don't have fallbacks but do exist.
		localeParts = locale.split( '-' );
		localeParts.pop();
		while ( localeParts.length && !fallbacks ) {
			partialLocale = localeParts.join( '-' );
			languages.push( partialLocale );
			fallbacks = $.i18n.fallbacks[ partialLocale ];
			localeParts.pop();
		}
	}

	if ( fallbacks ) {
		languages = languages.concat( fallbacks );
	}

	this.userLanguages = languages;

	for ( i = 0, iLen = languages.length; i < iLen; i++ ) {
		if ( languagesCovered[ languages[ i ] ] ) {
			continue;
		}
		languagesCovered[ languages[ i ] ] = true;

		// Lower-case the language code for the filename. jQuery.i18n does not case-fold
		// language codes, so we should not case-fold the second argument in #load.
		filename = languages[ i ].toLowerCase() + '.json';

		for ( j = 0, jLen = messagePaths.length; j < jLen; j++ ) {
			deferred = $.Deferred();
			$.i18n().load( messagePaths[ j ] + filename, languages[ i ] )
				.always( deferred.resolve );
			promises.push( deferred.promise() );
		}
	}
	return $.when.apply( $, promises );
};

/*!
 * VisualEditor Standalone Initialization Target class.
 *
 * @copyright 2011-2015 VisualEditor Team and others; see http://ve.mit-license.org
 */

/**
 * Initialization Standalone target.
 *
 * A platform must be constructed first. See ve.init.sa.Platform for an example.
 *
 *     @example
 *     ve.init.platform.initialize().done( function () {
 *         var target = new ve.init.sa.DesktopTarget();
 *         target.addSurface(
 *             ve.dm.converter.getModelFromDom(
 *                 ve.createDocumentFromHtml( '<p>Hello, World!</p>' )
 *             )
 *         );
 *         $( 'body' ).append( target.$element );
 *     } );
 *
 * @abstract
 * @class
 * @extends ve.init.Target
 *
 * @constructor
 * @param {Object} [config] Configuration options
 * @cfg {Object} [toolbarConfig] Configuration options for the toolbar
 */
ve.init.sa.Target = function VeInitSaTarget( config ) {
	config = config || {};
	config.toolbarConfig = $.extend( { shadow: true, actions: true, floatable: true }, config.toolbarConfig );

	// Parent constructor
	ve.init.sa.Target.super.call( this, config );

	this.actions = null;

	this.$element.addClass( 've-init-sa-target' );
};

/* Inheritance */

OO.inheritClass( ve.init.sa.Target, ve.init.Target );

/* Static properties */

ve.init.sa.Target.static.actionGroups = [
	{
		type: 'list',
		icon: 'menu',
		title: OO.ui.deferMsg( 'visualeditor-pagemenu-tooltip' ),
		include: [ 'findAndReplace', 'commandHelp' ]
	}
];

/* Methods */

/**
 * @inheritdoc
 */
ve.init.sa.Target.prototype.addSurface = function () {
	var surface = ve.init.sa.Target.super.prototype.addSurface.apply( this, arguments );
	this.$element.append( $( '<div>' ).addClass( 've-init-sa-target-surfaceWrapper' ).append( surface.$element ) );
	if ( !this.getSurface() ) {
		this.setSurface( surface );
	}
	surface.initialize();
	return surface;
};

/**
 * @inheritdoc
 */
ve.init.sa.Target.prototype.setupToolbar = function ( surface ) {
	// Parent method
	ve.init.sa.Target.super.prototype.setupToolbar.call( this, surface );

	this.getToolbar().$element.addClass( 've-init-sa-target-toolbar' );
};
