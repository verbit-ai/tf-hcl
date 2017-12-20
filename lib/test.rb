require 'rltk'
require 'rltk/ast'
require 'pry'

module Test
  class Lexer < RLTK::Lexer
    rule(/\s/)
    rule(/# (.*)/) { [:COMMENT, match[1]] }
    rule(/SECTION_A (.*)/) { [:SECTION_A, match[1]] }
    rule(/SECTION_B (.*)/) { [:SECTION_B, match[1]] }
  end

  class SectionA < RLTK::ASTNode
    value :comment, String
    value :value, String
  end

  class SectionB < RLTK::ASTNode
    value :comment, String
    value :value, String
  end

  class Parser < RLTK::Parser
    list(:sections, 'section')

    production(:section) do
      clause('COMMENT SECTION_A') { |t1, t2| SectionA.new(t1, t2) }
      clause('COMMENT SECTION_B') { |t1, t2| SectionB.new(t1, t2) }
    end

    finalize
  end
end

sample = <<EOF
# comment1
SECTION_A hello
# comment1
SECTION_A hello2
# comment2
SECTION_B goodbye
EOF

res = Test::Parser.parse(Test::Lexer.lex(sample))