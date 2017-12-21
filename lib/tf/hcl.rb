require 'bigdecimal'
require 'benchmark'
require 'rltk'
require 'rltk/ast'
require 'tf/hcl/version'
require 'tf/hcl/parser'
require 'tf/hcl/lexer'
require 'tf/hcl/ast'

module Tf
  module Hcl
    def load(str)
      Tf::Hcl::Parser.parse(Tf::Hcl::Lexer.lex(str))
    end

    module_function :load

    def load_file(file)
      Tf::Hcl::Parser.parse(Tf::Hcl::Lexer.lex_file(file))
    end

    module_function :load_file

    def dump(ast)
      if ast.respond_to?(:each)
        ast.map(&:to_hcl).join("\n")
      else
        ast.to_hcl
      end
    end

    module_function :dump
  end
end
