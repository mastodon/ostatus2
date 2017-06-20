# This is a backport of the following:
# Document block for Struct.new if present by akihikodaki · Pull Request #1099 · lsegal/yard
# https://github.com/lsegal/yard/pull/1099
class OStatus2YARDHandler < YARD::Handlers::Ruby::Base
  include YARD::Handlers::Ruby::StructHandlerMethods
  handles :assign

  process do
    if statement[1].call? && statement[1][0][0] == s(:const, 'Struct') && statement[1][2] == s(:ident, 'new')
      parse_block(statement[1].block[1],
                  namespace: create_class(statement[0][0][0], P(:Struct)))
    end
  end
end
