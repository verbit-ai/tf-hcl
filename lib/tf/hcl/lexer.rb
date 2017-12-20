module Tf
  module Hcl
    class Lexer < RLTK::Lexer
      rule(/\s/)
      rule(/{/) { :LBRACE }
      rule(/}/) { :RBRACE }
      rule(/\[/) { :LBRACKET }
      rule(/\]/) { :RBRACKET }
      rule(/,/) { :COMMA }
      rule(/:/) { :COLON }
      # Keywords
      rule(/variable/) { :VARIABLE }
      rule(/module/) { :MODULE }
      rule(/resource/) { :RESOURCE }
      rule(/output/) { :OUTPUT }
      rule(/locals/) { :LOCALS }
      rule(/provider/) { :PROVIDER }
      rule(/data/) { :DATA }
      rule(/terraform/) { :TERRAFORM }
      rule(/atlas/) { :ATLAS }
      rule(/=/) { :ASSIGN }
      # Booleans
      rule(/true|false/) { |t| [:BOOLEAN, t == 'true' ? true : false] }
      # Strings: Ignore any double quotes inside interpolation ${}, also ignore escaped double quotes i.e. \"
      rule(/"/) { push_state :string }
      rule(/\$\{.*?\}/m, :string) { |t| append(t) }
      rule(/[^"]/m, :string) { |t| append(t) }
      rule(/\\"/, :string) { |t| append(t) }
      rule(/"/, :string) { |t| pop_state; [:STRING, reset] }
      # Floats
      rule(/\d*?\.\d+/) { |t| [:FLOAT, t.to_f] }
      # Integers
      rule(/\d+/) { |t| [:INTEGER, t.to_i] }
      # Hexadecimal
      rule(/0x[A-Fa-f\d]+/) {|t| [:HEXADECIMAL, t.to_i(16)]}
      # Octal
      rule(/0\d+/) { [:OCTAL, t.to_i(8)] }
      # Scientific Notation
      rule(/\d*?\.?\d+[eE]\d+/) { |t| [:BIG_DECIMAL, BigDecimal.new(t)] }
      # Identifiers
      rule(/[A-Za-z][A-Za-z0-9\-\_.]*/) { |t| [:IDENT, t] }
      # Single line comments
      rule(/#/) { |t| push_state :comment }
      rule(/.*/, :comment) { |t| [:COMMENT, t] }
      rule(/\n/, :comment) { pop_state }
      # Multiline comments
      rule(/\/\*(.*?)\*\//m) { |t| [:MULTILINE_COMMENT, match[1]] }
      # Multiline strings
      rule(/<<([A-Za-z0-9]+)(.*?)\1/m) { |t| [:MULTILINE_STRING, [match[2], match[1]]] }

      class Environment < Environment

        def append(c)
          @str = '' if @str.nil?
          @str += c
          nil
        end

        def reset
          str_copy = @str.dup
          @str = ''
          str_copy
        end
      end
    end
  end
end
