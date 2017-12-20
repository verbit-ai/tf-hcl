module Tf
  module Hcl
    class Parser < RLTK::Parser

      list(:sections, 'section')

      production(:comment) {
        clause('COMMENT') { |e0| Tf::Hcl::Comment.new(e0) }
        clause('MULTILINE_COMMENT') { |e0| Tf::Hcl::MultiLineComment.new(e0) }
      }

      list(:comments, 'comment')

      production(:section) do
        clause('comments VARIABLE STRING object') { |e0, _, e1, e2| Tf::Hcl::Variable.new(e1, e2, e0) }
        clause('VARIABLE STRING object') { |_, e1, e2| Tf::Hcl::Variable.new(e1, e2, []) }
        clause('comments OUTPUT STRING object') { |e0, _, e1, e2| Tf::Hcl::Output.new(e1, e2, e0) }
        clause('OUTPUT STRING object') { |_, e1, e2| Tf::Hcl::Output.new(e1, e2, []) }
        clause('comments PROVIDER STRING object') { |e0, _, e1, e2| Tf::Hcl::Provider.new(e1, e2, e0) }
        clause('PROVIDER STRING object') { |_, e1, e2| Tf::Hcl::Provider.new(e1, e2, []) }
        clause('comments MODULE STRING object') { |e0, _, e1, e2| Tf::Hcl::Module.new(e1, e2, e0) }
        clause('MODULE STRING object') { |_, e1, e2| Tf::Hcl::Module.new(e1, e2, []) }

        clause('comments DATA STRING STRING object') { |e0, _, e1, e2, e3| Tf::Hcl::Data.new(e1, e2, e3, e0) }
        clause('DATA STRING STRING object') { |_, e1, e2, e3| Tf::Hcl::Data.new(e1, e2, e3, []) }
        clause('comments RESOURCE STRING STRING object') { |e0, _, e1, e2, e3| Tf::Hcl::Resource.new(e1, e2, e3, e0) }
        clause('RESOURCE STRING STRING object') { |_, e1, e2, e3| Tf::Hcl::Resource.new(e1, e2, e3, []) }

        clause('comments LOCALS object') { |e0, _, e1| Tf::Hcl::Locals.new(e1, e0) }
        clause('LOCALS object') { |_, e1| Tf::Hcl::Locals.new(e1, []) }
        clause('comments TERRAFORM object') { |e0, _, e1| Tf::Hcl::Terraform.new(e1, e0) }
        clause('TERRAFORM object') { |_, e1| Tf::Hcl::Terraform.new(e1, []) }
      end

      production(:object) do
        clause('LBRACE attributes RBRACE') { |_, e0, _| e0 }
      end

      production(:list) do
        clause('LBRACKET list_values RBRACKET') { |_, e0, _| e0 }
      end

      production(:list_values) do
        clause('') { [] }
        clause('value') { |e0| [e0] }
        clause('value COMMA list_values') { |e0, _, e1| [e0] + e1 }
      end

      production(:value) do
        clause('BOOLEAN') { |i| Tf::Hcl::Boolean.new(i) }
        clause('INTEGER') { |i| Tf::Hcl::Integer.new(i) }
        clause('FLOAT') { |i| Tf::Hcl::Float.new(i) }
        clause('HEXADECIMAL') {|i| Tf::Hcl::Hexadecimal.new(i)}
        clause('OCTAL') {|i| Tf::Hcl::Octal.new(i)}
        clause('SCIENTIFIC_NOTATION') {|i| Tf::Hcl::BigDecimal.new(i)}
        clause('STRING') { |i| Tf::Hcl::String.new(i) }
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
    end
  end
end
