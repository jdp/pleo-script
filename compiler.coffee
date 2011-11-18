root = exports ? this

_ = require "underscore"
parser = require "./parser"

qualify = (name) ->
  pieces = name.replace(/-/g, '_').split(/\./)
  instance = pieces[pieces.length-1] is ""
  if instance then pieces.pop()
  qualified = pieces[0] + _.map(pieces.slice(1), (term) -> "['#{term}']").join("")
  if instance then "new #{qualified}" else qualified

class root.Compiler
  constructor: () ->
    @output = ""

  compile_define_form: (node) ->
    "var #{node[1]} = #{@compile(node[2])};"

  compile_begin_form: (node) ->
    forms = _.map node.slice(1), (n) => @compile n
    forms[forms.length-1] = "return #{forms[forms.length-1]}"
    "(function() { #{forms.join('; ')} })()"

  compile_if_form: (node) ->
    if node.length < 3
      throw "if form requires 3 elements"
    output  = "(function() { "
    output += "if (#{@compile(node[1])}) { return #{@compile(node[2])}; } "
    output += "else { return #{if node.length is 4 then @compile(node[3]) else null}; } "
    output += "})()"
    output
    
  compile_let_form: (node) ->
    [names, values] = [[], []]
    _.each node[1].slice(0), (e, k) =>
      if k % 2 == 0
        names.push e
      else
        values.push e
    if not names.length == values.length
      throw "name-value binding mismatched"
    bindings = _.map _.zip(names, values), (binding) =>
      "#{binding[0]} = #{@compile(binding[1])}"
    "(function() { var #{bindings.join(', ')}; return #{@compile(node[2])}; })()"
    
  compile_fn_form: (node) ->
  	"function(#{node[1].slice(0).join(', ')}) { return #{@compile(node[2])}; }"

  compile_array_form: (node) ->
  	"[" + _.map(node.slice(1), (n) => @compile n).join(', ') + "]"

  compile_binary_op: (node, op) ->
  	tests = _.map(node.slice(1), (n) => @compile n)
  	"(" + tests.join(" " + op + " ") + ")"

  compile_js_interop: (node, form) ->
  	@compile(node[1]) + "[#{node[2]}]"

  compile: (root) ->
    if root instanceof Array
      switch root[0]
        when "define", "begin", "let", "if", "fn", "array"
          this["compile_#{root[0]}_form"](root)
        when "and", "or", ">=", ">", "<=", "<", "=", "+", "-", "*", "/"
          table =
            and: "&&"
            or: "||"
            "=": "==="
          @compile_binary_op root, if root[0] of table then table[root[0]] else root[0]
        else
          if root.token
            return "#{root}"
          else
            args = _.map root.slice(1), (n) => @compile n
            "#{qualify(root[0])}(#{args.join(', ')})"
    else if typeof(root) is "string"
      "(#{qualify(root)})"
    else
      "(#{root})"
      