_ = require "underscore"
rl = require "readline"

Lexer = require("./lexer").Lexer
Parser = require("./parser").Parser
Compiler = require("./compiler").Compiler

root = exports ? this
      
rli = rl.createInterface process.stdin, process.stdout,  ->
process.stdout.write "> "
rli.on "line", (source) =>
  lexer = new Lexer(source)
  parser = new Parser(lexer)
  ast = parser.parse()
  compiler = new Compiler()
  for root in ast
  	js = compiler.compile root
  	console.log js
  	try
  		console.log eval(js)
  	catch e
      console.log e
  process.stdout.write('> ');
