root = exports ? this

EOF = -1

class ASTNode extends Array
  constructor: (@token) ->
  
class SymbolNode extends ASTNode
  constructor: (@token) ->
  
  toString: ->
    "'#{@token}'"

class StringNode extends ASTNode
    constructor: (@token) ->

    toString: ->
      "\"#{@token}\""
    
class ListNode extends ASTNode
  constructor: ->
    
class ArrayNode extends ASTNode
  constructor: ->

class root.Parser
  constructor: (@lexer) ->
    
  error: (msg) ->
    throw "Parse Error: #{msg} at line #{@lexer.line} col #{@lexer.column}"
    
  expect: (type) ->
    token = @lexer.scan()
    if not token[0] is type
      @error "Expected #{type} but got #{token[0]}"
    token[1]

  parse: () ->
    form = []
    form_stack = []
    depths =
      list: [0]
      array: [0]
    
    enter = (type) ->
      depths[type].push 0
    exit = (type) =>
      if not depths[type][depths[type].length-1] is 0
        @error "Unbalanced #{type}"
      depths[type].pop()
    open = (type) ->
      depths[type][depths[type].length-1] += 1
    close = (type) =>
      if depths[type][depths[type].length-1] is 0
        @error "Underflow for #{type}"
      depths[type][depths[type].length-1] -= 1
    
    while (token = @lexer.scan()) isnt EOF
      switch token[0]
        when 'OPEN-LIST'
          open 'list'
          enter 'array'
          newform = new ListNode
          form.push newform
          form_stack.push form
          form = newform
        when 'OPEN-ARRAY'
          open 'array'
          enter 'list'
          newform = new ArrayNode
          form.push newform
          form_stack.push form
          form = newform
        when 'CLOSE-LIST'
          close 'list'
          exit 'array'
          form = form_stack.pop()
        when 'CLOSE-ARRAY'
          close 'array'
          exit 'list'
          form = form_stack.pop()
        when 'START-SYMBOL'
          ident = @expect "IDENTIFIER"
          form.push new SymbolNode(ident)
        when 'STRING'
          form.push new StringNode(token[1])
        else
          form.push token[1]
    form