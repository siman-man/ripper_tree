require 'ripper'
require 'colorize'

class RipperTree
  OPTIONS = { space_size: 8, color: true }
  T_LINE = '├────'
  I_LINE = '│'
  L_LINE = '└────'
  SCANNER_EVENT = /^(@CHAR|@const|@cvar|@float|@gvar|@ident|@imaginary|@int|@ivar|@kw|@label|@op|@period|@rational|@regexp_end|@tstring_content)$/

  def self.create(code)
    new.tap do |rtree|
      rtree.parse(Ripper.sexp(code))
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

  def output_event_id(id)
    "#{id.inspect}\n".colorize(:magenta)
  end

  def output_value_node(node)
    "#{node[0].inspect.colorize(:blue)} [#{node[1].inspect.colorize(:red)}] #{node[2].join(':')}\n"
  end

  def parse_method_arguments(parent, space: ' ')
    id = parent.first

    @queue << output_event_id(id)

    params = parent[1..-1].zip(%i(pars opts rest pars2 kws kwrest blk))

    until params.empty?
      param, arg_type = params.shift

      @queue << get_line(end_line: params.empty?, space: space)

      if param.instance_of?(Array)
        @queue << output_event_id(arg_type)

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
    event_id, *nodes = parent

    if parent.first.instance_of?(Array)
      parse(parent.first, space: space)
      return
    end

    case event_id
      when SCANNER_EVENT
        @queue << output_value_node(parent)
        return
      when /array/
        @queue << output_event_id(event_id)
        nodes = parent[1].nil? ? [] : parent[1]

        until nodes.empty?
          node = nodes.shift
          next if node == :args_add_star
          next if node == []

          @queue << get_line(end_line: nodes.empty?, space: space)
          parse(node, space: space + get_space(end_line: nodes.empty?))
        end

        return
      when /params/
        parse_method_arguments(parent, space: space)
        return
      when /void_stmt/
        @queue << output_event_id(event_id)
        return
      else
        @queue << output_event_id(event_id)
    end

    event_count = nodes.count { |n| n.instance_of?(Array) }

    if event_count.zero?
      unless nodes.all?(&:nil?)
        @queue << "#{space}#{parent[1..-1].map(&:inspect).join(', ')}"
      end
    else
      until nodes.empty?
        node = nodes.shift

        if node.instance_of?(Array)
          if node.all? { |e| e.instance_of?(Array) }
            until node.empty?
              event = node.shift
              @queue << get_line(end_line: nodes.empty? && node.empty?, space: space)
              parse(event, space: space + get_space(end_line: nodes.empty? && node.empty?))
            end
          else
            @queue << get_line(end_line: nodes.empty?, space: space)
            parse(node, space: space + get_space(end_line: nodes.empty?))
          end
        else
          @queue << get_line(end_line: nodes.empty?, space: space)
          @queue << "#{node.inspect}\n"
        end
      end
    end
  end
end
