" Vim syntax file
" " Language: Spiderscript
" " Maintainer: Alex Bierwagen
" " Latest Revisions: November 22 2014

if !exists("main_syntax")
  if version < 600
    syntax clear
  elseif exists("b:current_syntax")
    finish
  endif
  let main_syntax = 'spiderscript'
endif

if !exists('g:spidersript_conceal')
  let g:spidersript_conceal = 0
endif

"" Drop fold if it is set but VIM doesn't support it.
let b:spidersript_fold='true'
if version < 600    " Don't support the old version
  unlet! b:spidersript_fold
endif

"" dollar sign is permittd anywhere in an identifier
setlocal iskeyword+=$

syntax sync fromstart

syntax match   spNoise           /\%(:\|,\|\;\|\.\)/

"" Program Keywords
syntax keyword spStorageClass   const var let
syntax keyword spOperator       delete instanceof typeof void new in
syntax match   spOperator       /\(!\||\|&\|+\|-\|<\|>\|=\|%\|\/\|*\|\~\|\^\)/
syntax keyword spBooleanTrue    true
syntax keyword spBooleanFalse   false

"" spidersript comments
syntax keyword spCommentTodo    TODO FIXME XXX TBD contained
syntax region  spLineComment    start=+\/\/+ end=+$+ keepend contains=spCommentTodo,@Spell
syntax region  spEnvComment     start="\%^#!" end="$" display
syntax region  spLineComment    start=+^\s*\/\/+ skip=+\n\s*\/\/+ end=+$+ keepend contains=spCommentTodo,@Spell fold
syntax region  spCvsTag         start="\$\cid:" end="\$" oneline contained
syntax region  spComment        start="/\*"  end="\*/" contains=spCommentTodo,spCvsTag,@Spell fold

"" spDoc / spDoc Toolkit
if !exists("spidersript_ignore_spidersriptdoc")
  syntax case ignore

  "" syntax coloring for javadoc comments (HTML)
  "syntax include @javaHtml <sfile>:p:h/html.vim
  "unlet b:current_syntax

  syntax region spDocComment      matchgroup=spComment start="/\*\*\s*"  end="\*/" contains=spDocTags,spCommentTodo,spCvsTag,@spHtml,@Spell fold

  " tags containing a param
  syntax match  spDocTags         contained "@\(alias\|augments\|borrows\|class\|constructs\|default\|defaultvalue\|emits\|exception\|exports\|extends\|file\|fires\|kind\|listens\|member\|member[oO]f\|mixes\|module\|name\|namespace\|requires\|throws\|var\|variation\|version\)\>" nextgroup=spDocParam skipwhite
  " tags containing type and param
  syntax match  spDocTags         contained "@\(arg\|argument\|param\|property\)\>" nextgroup=spDocType skipwhite
  " tags containing type but no param
  syntax match  spDocTags         contained "@\(callback\|enum\|external\|this\|type\|typedef\|return\|returns\)\>" nextgroup=spDocTypeNoParam skipwhite
  " tags containing references
  syntax match  spDocTags         contained "@\(lends\|see\|tutorial\)\>" nextgroup=spDocSeeTag skipwhite
  " other tags (no extra syntax)
  syntax match  spDocTags         contained "@\(abstract\|access\|author\|classdesc\|constant\|const\|constructor\|copyright\|deprecated\|desc\|description\|event\|example\|file[oO]verview\|func\|global\|ignore\|inner\|instance\|license\|method\|mixin\|overview\|private\|protected\|public\|readonly\|since\|static\|todo\|summary\|undocumented\|virtual\)\>"

  syntax region spDocType         start="{" end="}" oneline contained nextgroup=spDocParam skipwhite
  syntax match  spDocType         contained "\%(#\|\"\|\w\|\.\|:\|\/\)\+" nextgroup=spDocParam skipwhite
  syntax region spDocTypeNoParam  start="{" end="}" oneline contained
  syntax match  spDocTypeNoParam  contained "\%(#\|\"\|\w\|\.\|:\|\/\)\+"
  syntax match  spDocParam        contained "\%(#\|\"\|{\|}\|\w\|\.\|:\|\/\)\+"
  syntax region spDocSeeTag       contained matchgroup=spDocSeeTag start="{" end="}" contains=spDocTags

  syntax case match
endif   "" spDoc end

syntax case match

"" Syntax in the spidersript code
syntax match   spFuncCall        /\k\+\%(\s*(\)\@=/
syntax match   spSpecial         "\v\\%(0|\\x\x\{2\}\|\\u\x\{4\}\|\c[A-Z]|.)" contained
syntax match   spTemplateVar     "\${.\{-}}" contained
syntax region  spStringD         start=+"+  skip=+\\\\\|\\$"+  end=+"+  contains=spSpecial,@htmlPreproc,@Spell
syntax region  spStringS         start=+'+  skip=+\\\\\|\\$'+  end=+'+  contains=spSpecial,@htmlPreproc,@Spell
syntax region  spTemplateString  start=+`+  skip=+\\\\\|\\$`+  end=+`+  contains=spTemplateVar,spSpecial,@htmlPreproc
syntax region  spRegexpCharClass start=+\[+ skip=+\\.+ end=+\]+ contained
syntax match   spRegexpBoundary   "\v%(\<@![\^$]|\\[bB])" contained
syntax match   spRegexpBackRef   "\v\\[1-9][0-9]*" contained
syntax match   spRegexpQuantifier "\v\\@<!%([?*+]|\{\d+%(,|,\d+)?})\??" contained
syntax match   spRegexpOr        "\v\<@!\|" contained
syntax match   spRegexpMod       "\v\(@<=\?[:=!>]" contained
syntax cluster spRegexpSpecial   contains=spSpecial,spRegexpBoundary,spRegexpBackRef,spRegexpQuantifier,spRegexpOr,spRegexpMod
syntax region  spRegexpGroup     start="\\\@<!(" end="\\\@<!)" contained contains=spRegexpCharClass,@spRegexpSpecial keepend
syntax region  spRegexpString    start=+\(\(\(return\|case\)\s\+\)\@<=\|\(\([)\]"']\|\d\|\w\)\s*\)\@<!\)/\(\*\|/\)\@!+ skip=+\\.\|\[\(\\.\|[^]]\)*\]+ end=+/[gimy]\{,4}+ contains=spRegexpCharClass,spRegexpGroup,@spRegexpSpecial,@htmlPreproc oneline keepend
syntax match   spNumber          /\<-\=\d\+L\=\>\|\<0[xX]\x\+\>/
syntax keyword spNumber          Infinity
syntax match   spFloat           /\<-\=\%(\d\+\.\d\+\|\d\+\.\|\.\d\+\)\%([eE][+-]\=\d\+\)\=\>/
syntax match   spObjectKey       /\<[a-zA-Z_$][0-9a-zA-Z_$]*\(\s*:\)\@=/ contains=spFunctionKey contained
syntax match   spFunctionKey     /\<[a-zA-Z_$][0-9a-zA-Z_$]*\(\s*:\s*func\s*\|\s*->\s*\)\@=/ contained

if g:spidersript_conceal == 1
  syntax keyword spNull           null conceal cchar=ø
  syntax keyword spThis           this conceal cchar=@
  syntax keyword spReturn         return conceal cchar=⇚
  syntax keyword spUndefined      undefined conceal cchar=¿
  syntax keyword spNan            NaN conceal cchar=ℕ
  syntax keyword spPrototype      prototype conceal cchar=¶
else
  syntax keyword spNull           null
  syntax keyword spThis           this
  syntax keyword spReturn         return
  syntax keyword spUndefined      undefined
  syntax keyword spNan            NaN
  syntax keyword spPrototype      prototype
endif

"" Statement Keywords
syntax keyword spStatement      break continue with
syntax keyword spConditional    if else switch
syntax keyword spRepeat         do while for
syntax keyword spLabel          case default
syntax keyword spKeyword        yield
syntax keyword spException      try catch throw finally

syntax keyword spGlobalObjects   Array Boolean Date Function Iterator Number Object RegExp String Proxy ParallelArray ArrayBuffer DataView Float32Array Float64Array Int16Array Int32Array Int8Array Uint16Array Uint32Array Uint8Array Uint8ClampedArray Intl spON Math console document window
syntax match   spGlobalObjects  /\%(Intl\.\)\@<=\(Collator\|DateTimeFormat\|NumberFormat\)/

syntax keyword spExceptions     Error EvalError InternalError RangeError ReferenceError StopIteration SyntaxError TypeError URIError

syntax keyword spBuiltins       decodeURI decodeURIComponent encodeURI encodeURIComponent eval isFinite isNaN parseFloat parseInt uneval

syntax keyword spFutureKeys     abstract enum int short boolean export interface static byte extends long super char final native synchronized class float package throws goto private transient debugger implements protected volatile double import public

"" DOM/HTML/CSS specified things

" DOM2 Objects
syntax keyword spGlobalObjects  DOMImplementation DocumentFragment Document Node NodeList NamedNodeMap CharacterData Attr Element Text Comment CDATASection DocumentType Notation Entity EntityReference ProcessingInstruction
syntax keyword spExceptions     DOMException

" DOM2 CONSTANT
syntax keyword spDomErrNo       INDEX_SIZE_ERR DOMSTRING_SIZE_ERR HIERARCHY_REQUEST_ERR WRONG_DOCUMENT_ERR INVALID_CHARACTER_ERR NO_DATA_ALLOWED_ERR NO_MODIFICATION_ALLOWED_ERR NOT_FOUND_ERR NOT_SUPPORTED_ERR INUSE_ATTRIBUTE_ERR INVALID_STATE_ERR SYNTAX_ERR INVALID_MODIFICATION_ERR NAMESPACE_ERR INVALID_ACCESS_ERR
syntax keyword spDomNodeConsts  ELEMENT_NODE ATTRIBUTE_NODE TEXT_NODE CDATA_SECTION_NODE ENTITY_REFERENCE_NODE ENTITY_NODE PROCESSING_INSTRUCTION_NODE COMMENT_NODE DOCUMENT_NODE DOCUMENT_TYPE_NODE DOCUMENT_FRAGMENT_NODE NOTATION_NODE

" HTML events and internal variables
syntax case ignore
syntax keyword spHtmlEvents     onblur onclick oncontextmenu ondblclick onfocus onkeydown onkeypress onkeyup onmousedown onmousemove onmouseout onmouseover onmouseup onresize
syntax case match

" Follow stuff should be highligh within a special context
" While it can't be handled with context depended with Regex based highlight
" So, turn it off by default
if exists("spidersript_enable_domhtmlcss")

    " DOM2 things
    syntax match spDomElemAttrs     contained /\%(nodeName\|nodeValue\|nodeType\|parentNode\|childNodes\|firstChild\|lastChild\|previousSibling\|nextSibling\|attributes\|ownerDocument\|namespaceURI\|prefix\|localName\|tagName\)\>/
    syntax match spDomElemFuncs     contained /\%(insertBefore\|replaceChild\|removeChild\|appendChild\|hasChildNodes\|cloneNode\|normalize\|isSupported\|hasAttributes\|getAttribute\|setAttribute\|removeAttribute\|getAttributeNode\|setAttributeNode\|removeAttributeNode\|getElementsByTagName\|getAttributeNS\|setAttributeNS\|removeAttributeNS\|getAttributeNodeNS\|setAttributeNodeNS\|getElementsByTagNameNS\|hasAttribute\|hasAttributeNS\)\>/ nextgroup=spParen skipwhite
    " HTML things
    syntax match spHtmlElemAttrs    contained /\%(className\|clientHeight\|clientLeft\|clientTop\|clientWidth\|dir\|id\|innerHTML\|lang\|length\|offsetHeight\|offsetLeft\|offsetParent\|offsetTop\|offsetWidth\|scrollHeight\|scrollLeft\|scrollTop\|scrollWidth\|style\|tabIndex\|title\)\>/
    syntax match spHtmlElemFuncs    contained /\%(blur\|click\|focus\|scrollIntoView\|addEventListener\|dispatchEvent\|removeEventListener\|item\)\>/ nextgroup=spParen skipwhite

    " CSS Styles in spidersript
    syntax keyword spCssStyles      contained color font fontFamily fontSize fontSizeAdjust fontStretch fontStyle fontVariant fontWeight letterSpacing lineBreak lineHeight quotes rubyAlign rubyOverhang rubyPosition
    syntax keyword spCssStyles      contained textAlign textAlignLast textAutospace textDecoration textIndent textJustify textJustifyTrim textKashidaSpace textOverflowW6 textShadow textTransform textUnderlinePosition
    syntax keyword spCssStyles      contained unicodeBidi whiteSpace wordBreak wordSpacing wordWrap writingMode
    syntax keyword spCssStyles      contained bottom height left position right top width zIndex
    syntax keyword spCssStyles      contained border borderBottom borderLeft borderRight borderTop borderBottomColor borderLeftColor borderTopColor borderBottomStyle borderLeftStyle borderRightStyle borderTopStyle borderBottomWidth borderLeftWidth borderRightWidth borderTopWidth borderColor borderStyle borderWidth borderCollapse borderSpacing captionSide emptyCells tableLayout
    syntax keyword spCssStyles      contained margin marginBottom marginLeft marginRight marginTop outline outlineColor outlineStyle outlineWidth padding paddingBottom paddingLeft paddingRight paddingTop
    syntax keyword spCssStyles      contained listStyle listStyleImage listStylePosition listStyleType
    syntax keyword spCssStyles      contained background backgroundAttachment backgroundColor backgroundImage gackgroundPosition backgroundPositionX backgroundPositionY backgroundRepeat
    syntax keyword spCssStyles      contained clear clip clipBottom clipLeft clipRight clipTop content counterIncrement counterReset cssFloat cursor direction display filter layoutGrid layoutGridChar layoutGridLine layoutGridMode layoutGridType
    syntax keyword spCssStyles      contained marks maxHeight maxWidth minHeight minWidth opacity MozOpacity overflow overflowX overflowY verticalAlign visibility zoom cssText
    syntax keyword spCssStyles      contained scrollbar3dLightColor scrollbarArrowColor scrollbarBaseColor scrollbarDarkShadowColor scrollbarFaceColor scrollbarHighlightColor scrollbarShadowColor scrollbarTrackColor

    " Highlight ways
    syntax match spDotNotation      "\." nextgroup=spPrototype,spDomElemAttrs,spDomElemFuncs,spHtmlElemAttrs,spHtmlElemFuncs
    syntax match spDotNotation      "\.style\." nextgroup=spCssStyles

endif "DOM/HTML/CSS

"" end DOM/HTML/CSS specified things


"" Code blocks
syntax cluster spExpression contains=spComment,spLineComment,spDocComment,spTemplateString,spStringD,spStringS,spRegexpString,spNumber,spFloat,spThis,spOperator,spBooleanTrue,spBooleanFalse,spNull,spFunction,spArrowFunction,spGlobalObjects,spExceptions,spFutureKeys,spDomErrNo,spDomNodeConsts,spHtmlEvents,spDotNotation,spBracket,spParen,spBlock,spFuncCall,spUndefined,spNan,spKeyword,spStorageClass,spPrototype,spBuiltins,spNoise
syntax cluster spAll        contains=@spExpression,spLabel,spConditional,spRepeat,spReturn,spStatement,spTernaryIf,spException
syntax region  spBracket    matchgroup=spBrackets     start="\[" end="\]" contains=@spAll,spParensErrB,spParensErrC,spBracket,spParen,spBlock,@htmlPreproc fold
syntax region  spParen      matchgroup=spParens       start="("  end=")"  contains=@spAll,spParensErrA,spParensErrC,spParen,spBracket,spBlock,@htmlPreproc fold
syntax region  spBlock      matchgroup=spBraces       start="{"  end="}"  contains=@spAll,spParensErrA,spParensErrB,spParen,spBracket,spBlock,spObjectKey,@htmlPreproc fold
syntax region  spFuncBlock  matchgroup=spFuncBraces   start="{"  end="}"  contains=@spAll,spParensErrA,spParensErrB,spParen,spBracket,spBlock,@htmlPreproc contained fold
syntax region  spTernaryIf  matchgroup=spTernaryIfOperator start=+?+  end=+:+  contains=@spExpression,spTernaryIf

"" catch errors caused by wrong parenthesis
syntax match   spParensError    ")\|}\|\]"
syntax match   spParensErrA     contained "\]"
syntax match   spParensErrB     contained ")"
syntax match   spParensErrC     contained "}"

if main_syntax == "spidersript"
  syntax sync clear
  syntax sync ccomment spComment minlines=200
  syntax sync match spHighlight grouphere spBlock /{/
endif

if g:spidersript_conceal == 1
  syntax match   spFunction       /\<func\>/ nextgroup=spFuncName,spFuncArgs skipwhite conceal cchar=ƒ
else
  syntax match   spFunction       /\<func\>/ nextgroup=spFuncName,spFuncArgs skipwhite
endif

syntax match   spFuncName       contained /\<[a-zA-Z_$][0-9a-zA-Z_$]*/ nextgroup=spFuncArgs skipwhite
syntax region  spFuncArgs       contained matchgroup=spFuncParens start='(' end=')' contains=spFuncArgCommas,spFuncArgRest nextgroup=spFuncBlock keepend skipwhite skipempty
syntax match   spFuncArgCommas  contained ','
syntax match   spFuncArgRest    contained /\%(\.\.\.[a-zA-Z_$][0-9a-zA-Z_$]*\))/
syntax keyword spArgsObj        arguments contained containedin=spFuncBlock

syntax match spArrowFunction /->/

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_spidersript_syn_inits")
  if version < 508
    let did_spidersript_syn_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif
  HiLink spFuncArgRest          Special
  HiLink spComment              Comment
  HiLink spLineComment          Comment
  HiLink spEnvComment           PreProc
  HiLink spDocComment           Comment
  HiLink spCommentTodo          Todo
  HiLink spCvsTag               Function
  HiLink spDocTags              Special
  HiLink spDocSeeTag            Function
  HiLink spDocType              Type
  HiLink spDocTypeNoParam       Type
  HiLink spDocParam             Label
  HiLink spStringS              String
  HiLink spStringD              String
  HiLink spTemplateString       String
  HiLink spTernaryIfOperator    Conditional
  HiLink spRegexpString         String
  HiLink spRegexpBoundary       SpecialChar
  HiLink spRegexpQuantifier     SpecialChar
  HiLink spRegexpOr             Conditional
  HiLink spRegexpMod            SpecialChar
  HiLink spRegexpBackRef        SpecialChar
  HiLink spRegexpGroup          spRegexpString
  HiLink spRegexpCharClass      Character
  HiLink spCharacter            Character
  HiLink spPrototype            Special
  HiLink spConditional          Conditional
  HiLink spBranch               Conditional
  HiLink spLabel                Label
  HiLink spReturn               Statement
  HiLink spRepeat               Repeat
  HiLink spStatement            Statement
  HiLink spException            Exception
  HiLink spKeyword              Keyword
  HiLink spArrowFunction        Type
  HiLink spFunction             Type
  HiLink spFuncName             Function
  HiLink spArgsObj              Special
  HiLink spError                Error
  HiLink spParensError          Error
  HiLink spParensErrA           Error
  HiLink spParensErrB           Error
  HiLink spParensErrC           Error
  HiLink spOperator             Operator
  HiLink spStorageClass         StorageClass
  HiLink spThis                 Special
  HiLink spNan                  Number
  HiLink spNull                 Type
  HiLink spUndefined            Type
  HiLink spNumber               Number
  HiLink spFloat                Float
  HiLink spBooleanTrue          Boolean
  HiLink spBooleanFalse         Boolean
  HiLink spNoise                Noise
  HiLink spBrackets             Noise
  HiLink spParens               Noise
  HiLink spBraces               Noise
  HiLink spFuncBraces           Noise
  HiLink spFuncParens           Noise
  HiLink spSpecial              Special
  HiLink spTemplateVar          Special
  HiLink spGlobalObjects        Special
  HiLink spExceptions           Special
  HiLink spFutureKeys           Special
  HiLink spBuiltins             Special

  HiLink spDomErrNo             Constant
  HiLink spDomNodeConsts        Constant
  HiLink spDomElemAttrs         Label
  HiLink spDomElemFuncs         PreProc

  HiLink spHtmlEvents           Special
  HiLink spHtmlElemAttrs        Label
  HiLink spHtmlElemFuncs        PreProc

  HiLink spCssStyles            Label

  delcommand HiLink
endif

" Define the htmlspidersript for HTML syntax html.vim
"syntax clear htmlspidersript
"syntax clear spExpression
syntax cluster  htmlspidersript       contains=@spAll,spBracket,spParen,spBlock
syntax cluster  spidersriptExpression contains=@spAll,spBracket,spParen,spBlock,@htmlPreproc
" Vim's default html.vim highlights all spidersript as 'Special'
hi! def link spidersript              NONE

let b:current_syntax = "spidersript"
if main_syntax == 'spidersript'
  unlet main_syntax
endif
