root = exports ? this

LPAREN = '('
RPAREN = ')'
IDENT = 'IDENT'
EOF = -1

class root.Lexer
  constructor: (source) ->
    @source = source
    @line = 1
    @column = 1
    @token = ""
    @pos = 0
    
  is_whitespace: (c) ->
    switch c
      when " ", ",", "\t", "\n", "\r"
        true
      else
        false
        
  reset: ->
    @token = ''
    
  current: ->
    if @pos >= @source.length
      return EOF;
    else
      @source.charAt @pos

  next: ->
    char = @current()
    if char is '\r\n' or char is '\r' or char is '\n'
      @line += 1
      @column = 0
    @pos += 1
    @column += 1
    @current()
    
  save: ->
    @token += @current()

  scan_whitespace: ->
    while @is_whitespace @current()
      @next()

  scan_ident: ->
    @reset()
    while (char = @current()) isnt EOF and char.match(/[^\s\(\)\[\],:]/)
      @save()
      @next()
    @token

  scan_string: ->
    @reset()
    while (char = @current()) isnt EOF and char isnt "\""
      @save()
      @next()
    @next()
    @token

  scan: ->
    while (char = @current()) isnt EOF
      if char is LPAREN
        @next()
        return ['OPEN-LIST', LPAREN]
      else if char is RPAREN
        @next()
        return ['CLOSE-LIST', RPAREN]
      else if char is "["
        @next()
        return ['OPEN-ARRAY', '[']
      else if char is "]"
        @next()
        return ['CLOSE-ARRAY', ']']
      else if char is ":"
        @next()
        return ['START-SYMBOL', ':']
      else if char is "'"
        @next()
        return ['QUOTE', "'"]
      else if char is "\""
        @next()
        return ['STRING', @scan_string()]
      else if char.match /[^0-9\s\(\)\[\],]/
        return ['IDENTIFIER', @scan_ident()]
      else if @is_whitespace char 
        @scan_whitespace()
      else
        console.log("unexpected input on line", this.line);
        return EOF
    EOF
    