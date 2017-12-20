require 'rltk/ast'

module Tf
  module Hcl
    INDENT_SPACES = 2
    class BaseNode < RLTK::ASTNode
      def value
        values.first
      end

      # lines arg can either be:
      # :all - indent all lines
      # Integer - indent the first int number of lines, leave the rest as is
      def indent(hcl, level = 0, lines = :all)
        indent_spaces = ' ' * level * INDENT_SPACES
        parts = hcl.split("\n")
        indented_parts =
          if lines == :all
            parts.map { |l| indent_spaces + l }
          elsif lines.is_a?(::Integer)
            (parts.take(lines).map { |l| indent_spaces + l } + parts.drop(lines))
          else
            parts
          end
        indented_parts.join("\n")
      end
    end

    class Comment < BaseNode
      value :value, ::String

      def to_hcl
        "##{value}"
      end
    end

    class MultiLineComment < Comment
      def to_hcl
        "/* #{value.split("\n").map(&:strip).join("\n   ").sub(/[[:blank:]]*\Z/, '')}*/"
      end
    end

    class Key < BaseNode
      value :name, ::String

      def to_hcl
        if value[0] =~ /[A-Za-z]/
          value
        else
          "\"#{value}\""
        end
      end
    end

    class Value < BaseNode
      def to_hcl(level = 0)
        value
      end
    end


    class MultiLineString < Value
      value :value, ::String
      value :identifier, ::String

      def to_hcl(level = 0)
        "<<#{identifier}#{value}#{identifier}"
      end
    end

    class Integer < Value
      value :value, ::Integer
    end

    class Float < Value
      value :value, ::Float
    end

    class String < Value
      value :value, ::String

      def to_hcl(level = 0)
        "\"#{value}\""
      end
    end

    class Boolean < Value
      value :value, ::Object
    end

    class List < Value
      child :value, [Value]

      def to_hcl(level = 0)
        "[#{value.map(&:to_hcl).join(', ')}]"
      end
    end

    class Attribute < BaseNode
      child :key, Key
      child :value, Value
      child :line_comment, Comment
      child :lead_comments, [Comment]

      attr_accessor :inline

      def initialize(key:, value:, line_comment: nil, lead_comments: [], inline: false)
        @inline = inline
        super(key, value, line_comment, lead_comments)
      end

      def to_hcl(level = 0)
        attr_format = inline ? '%{key} %{value}' : '%{key} = %{value}'
        attr_hcl = indent(attr_format % { key: key.to_hcl, value: value.to_hcl(level) }, level, 1)
        lead_comment_hcl = indent(lead_comments.map(&:to_hcl).join("\n"), level)
        case
          when lead_comments.any? && !line_comment.nil?
            "\n%s\n%s %s" % [lead_comment_hcl, attr_hcl, indent(line_comment.to_hcl, level)]
          when lead_comments.any?
            "\n%s\n%s" % [lead_comment_hcl, attr_hcl]
          when !line_comment.nil?
            '%s %s' % [attr_hcl, indent(line_comment.to_hcl, level)]
          else
            attr_hcl
        end
      end
    end

    class Object < Value
      child :attributes, [Attribute]

      def to_hcl(level = 0)
        "{\n#{attributes.map { |a| a.to_hcl(level + 1) }.join("\n")}\n#{indent('}', level)}"
      end
    end

    class Variable < BaseNode
      value :name, ::String
      child :attributes, [Attribute]
      child :comments, [Comment]

      def type
        attributes.find { |a| a.key.value == 'type' }
      end

      def default
        attributes.find { |a| a.key.value == 'default' }
      end

      def to_hcl
        "#{comments.map(&:to_hcl).join("\n")}\nvariable \"#{name}\" {\n#{attributes.map { |a| a.to_hcl(1) }.join("\n")}\n}"
      end
    end

    class Module < BaseNode
      value :name, ::String
      child :attributes, [Attribute]
      child :comments, [Comment]

      def to_hcl
        "#{comments.map(&:to_hcl).join("\n")}\nmodule \"#{name}\" {\n#{attributes.map { |a| a.to_hcl(1) }.join("\n")}\n}"
      end
    end

    class Resource < BaseNode
      value :type, ::String
      value :name, ::String
      child :attributes, [Attribute]
      child :comments, [Comment]

      def to_hcl
        "#{comments.map(&:to_hcl).join("\n")}\nresource \"#{type}\" \"#{name}\" {\n#{attributes.map { |a| a.to_hcl(1) }.join("\n")}\n}"
      end
    end

    class Data < BaseNode
      value :type, ::String
      value :name, ::String
      child :attributes, [Attribute]
      child :comments, [Comment]

      def to_hcl
        "#{comments.map(&:to_hcl).join("\n")}\ndata \"#{type}\" \"#{name}\" {\n#{attributes.map { |a| a.to_hcl(1) }.join("\n")}\n}"
      end
    end


    class Locals < BaseNode
      child :attributes, [Attribute]
      child :comments, [Comment]

      def to_hcl
        "#{comments.map(&:to_hcl).join("\n")}\nlocals {\n#{attributes.map { |a| a.to_hcl(1) }.join("\n")}\n}"
      end
    end

    class Terraform < BaseNode
      child :attributes, [Attribute]
      child :comments, [Comment]

      def to_hcl
        "#{comments.map(&:to_hcl).join("\n")}\nterraform {\n#{attributes.map { |a| a.to_hcl(1) }.join("\n")}\n}"
      end
    end

    class Provider < BaseNode
      value :name, ::String
      child :attributes, [Attribute]
      child :comments, [Comment]

      def to_hcl
        "#{comments.map(&:to_hcl).join("\n")}\nprovider \"#{name}\" {\n#{attributes.map { |a| a.to_hcl(1) }.join("\n")}\n}"
      end
    end

    class Output < BaseNode
      value :name, ::String
      child :attributes, [Attribute]
      child :comments, [Comment]

      def to_hcl
        "#{comments.map(&:to_hcl).join("\n")}\noutput \"#{name}\" {\n#{attributes.map { |a| a.to_hcl(1) }.join("\n")}\n}"
      end
    end
  end
end