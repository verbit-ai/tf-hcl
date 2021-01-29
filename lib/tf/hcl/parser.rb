module Tf
  module Hcl
    class Parser < RLTK::Parser

      list(:sections, 'csection')

      production(:comment) do
        clause('COMMENT') { |c| Tf::Hcl::Comment.new(c) }
        clause('MULTILINE_COMMENT') { |c| Tf::Hcl::MultiLineComment.new(c) }
      end

      list(:comments, 'comment')

      production(:section) do
        clause('VARIABLE STRING object') { |_, name, obj| Tf::Hcl::Variable.new(name, obj) }
        clause('OUTPUT STRING object') { |_, name, obj| Tf::Hcl::Output.new(name, obj) }
        clause('PROVIDER STRING object') { |_, name, obj| Tf::Hcl::Provider.new(name, obj) }
        clause('MODULE STRING object') { |_, name, obj| Tf::Hcl::Module.new(name, obj) }

        clause('DATA STRING STRING object') { |_, name, type, obj| Tf::Hcl::Data.new(name, type, obj) }
        clause('RESOURCE STRING STRING object') { |_, name, type, obj| Tf::Hcl::Resource.new(name, type, obj) }

        clause('LOCALS object') { |_, obj| Tf::Hcl::Locals.new(obj) }
        clause('TERRAFORM object') { |_, obj| Tf::Hcl::Terraform.new(obj) }
      end

      production(:csection, 'comments section') { |c, s| s.comments = c; s }

      production(:object) do
        clause('LBRACE attributes RBRACE') { |_, attrs, _| attrs }
      end

      production(:list) do
        clause('LBRACKET list_values RBRACKET') { |_, vals, _| vals }
      end

      production(:list_values) do
        clause('') { [] }
        clause('value') { |v| [v] }
        clause('value COMMA list_values') { |val, _, vals| [val] + vals }
      end

      production(:value) do
        clause('BOOLEAN') { |i| Tf::Hcl::Boolean.new(i) }
        clause('INTEGER') { |i| Tf::Hcl::Integer.new(i) }
        clause('FLOAT') { |i| Tf::Hcl::Float.new(i) }
        clause('HEXADECIMAL') { |i| Tf::Hcl::Hexadecimal.new(i) }
        clause('OCTAL') { |i| Tf::Hcl::Octal.new(i) }
        clause('SCIENTIFIC_NOTATION') { |i| Tf::Hcl::BigDecimal.new(i) }
        clause('STRING') { |i| Tf::Hcl::String.new(i) }
        clause('IDENT') { |i| Tf::Hcl::String.new(i) }
        clause('MULTILINE_STRING') { |i| Tf::Hcl::MultiLineString.new(*i) }
        clause('list') { |i| Tf::Hcl::List.new(i) }
        clause('object') { |i| Tf::Hcl::Object.new(i) }
      end

      production(:attribute) do
        clause('IDENT ASSIGN value') { |k, _, v| { key: Tf::Hcl::Key.new(k), value: v } }
        clause('IDENT ASSIGN value comment') { |k, _, v, c| { key: Tf::Hcl::Key.new(k), value: v, line_comment: c } }
        clause('STRING ASSIGN value') { |k, _, v| { key: Tf::Hcl::Key.new(k), value: v } }
        clause('STRING ASSIGN value comment') { |k, _, v, c| { key: Tf::Hcl::Key.new(k), value: v, line_comment: c } }
        clause('IDENT value') { |k, v| { key: Tf::Hcl::Key.new(k), value: v, inline: true } }
      end

      production(:cattribute, 'comments attribute') { |c, a| Tf::Hcl::Attribute.new(a.merge(lead_comments: c)) }

      list(:attributes, 'cattribute', 'COMMA?')

      finalize
      #finalize(precedence: false, use: '/tmp/tf-hcl.parser', lookahead: false, explain: true)
    end
  end
end
