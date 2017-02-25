require 'ripper'
require 'colorize'

class RipperTree
  OPTIONS = { space_size: 8, color: true }
  T_LINE = '├────'
  I_LINE = '│'
  L_LINE = '└────'
  SCANNER_EVENT = /^(@CHAR|@const|@cvar|@float|@gvar|@ident|@imaginary|@int|@ivar|@kw|@label|@op|@period|@rational|@regexp_end|@tstring_content)$/

  def self.create(src)
    new.tap do |rtree|
      rtree.parse(Ripper.sexp(src))
    end
  end

  def initialize
    @queue = []
  end

  def to_s
    RipperTree::OPTIONS[:color] ? @queue.join : @queue.join.uncolorize
  end

  def get_line(end_line: nil, space: '')
    end_line ? "#{space}#{L_LINE} " : "#{space}#{T_LINE} "
  end

  def get_space(end_line: nil)
    end_line ? ' ' * RipperTree::OPTIONS[:space_size] : I_LINE + ' ' * (RipperTree::OPTIONS[:space_size]-1)
  end

  def output_id(id)
    "#{id.inspect}\n".colorize(:magenta)
  end

  def output_string_node(node)
    "#{node[0].inspect.colorize(:blue)} [#{node[1].inspect.colorize(:red)}] #{node[2].join(':')}\n"
  end

  def output_value_node(node)
    "#{node[0].inspect.colorize(:blue)} [#{node[1]}] #{node[2].join(':')}\n"
  end

  def parse_method_arguments(parent, space: ' ')
    id = parent.first

    @queue << output_id(id)

    params = parent[1..-1].zip(%i(pars opts rest pars2 kws kwrest blk))

    until params.empty?
      param, arg_type = params.shift

      @queue << get_line(end_line: params.empty?, space: space)

      if param.instance_of?(Array)
        @queue << output_id(arg_type)

        if arg_type == :kwrest
          s = space + get_space(end_line: params.empty? && param.empty?)
          @queue << "#{s}#{L_LINE} "
          @queue << output_value_node(param)
          next
        end

        arg_count = 0

        until param.empty?
          e = param.shift
          arg_count += 1
          next if e == :rest_param
          next if e == :blockarg
          next if e.nil?

          s = space + get_space(end_line: params.empty? && param.empty?)
          @queue << get_line(end_line: param.empty?, space: s)

          case arg_type
            when :opts
              ident = e.first
              val = e.last
              @queue << "arg#{arg_count}\n"

              ss = s + get_space(end_line: param.empty?)
              @queue << get_line(end_line: false, space: ss)
              @queue << output_value_node(ident)
              @queue << get_line(end_line: true, space: ss)

              case val.first
                when /var_ref/
                  v = val.last
                  @queue << output_value_node(v)
                when /symbol_literal|string_literal|array|hash|call|paren/
                  sss = ss + get_space(end_line: param.empty?)
                  parse(val, space: sss)
                else
                  @queue << output_value_node(val)
              end
            else
              parse(e, space: space + s)
          end
        end
      else
        if param =~ /\d+/
          @queue << ":kwrest\n"
        else
          @queue << "#{param.inspect}\n"
        end
      end
    end
  end

  def parse(parent, space: ' ')
    if parent.first.instance_of?(Array)
      parse(parent.first, space: space)
      return
    end

    id = parent.first

    case id
      when SCANNER_EVENT
        @queue << output_value_node(parent)
        return
      when /array/
        @queue << output_id(id)
        children = parent[1].nil? ? [] : parent[1]

        until children.empty?
          child = children.shift
          next if child == :args_add_star
          next if child == []

          @queue << get_line(end_line: children.empty?, space: space)
          parse(child, space: space + get_space(end_line: children.empty?))
        end

        return
      when /params/
        parse_method_arguments(parent, space: space)
        return
      when /void_stmt/
        @queue << output_id(id)
        return
      else
        @queue << output_id(id)
    end

    child_count = parent[1..-1].count { |e| e.instance_of?(Array) }

    if child_count.zero?
      unless parent[1..-1].all?(&:nil?)
        @queue << "#{space}#{parent[1..-1].map(&:inspect).join(', ')}"
      end
    else
      children = parent[1..-1]

      until children.empty?
        child = children.shift

        if child.instance_of?(Array)
          if child.all? { |e| e.instance_of?(Array) }
            until child.empty?
              node = child.shift
              @queue << get_line(end_line: children.empty? && child.empty?, space: space)
              parse(node, space: space + get_space(end_line: children.empty? && child.empty?))
            end
          else
            @queue << get_line(end_line: children.empty?, space: space)
            parse(child, space: space + get_space(end_line: children.empty?))
          end
        else
          @queue << get_line(end_line: children.empty?, space: space)
          @queue << "#{child.inspect}\n"
        end
      end
    end
  end
end
