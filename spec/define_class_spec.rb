RSpec.describe RipperTree do
  describe '.parse' do
    it 'define empty class' do
      code, expect =<<-CODE, <<-EXPECT
class Parent
end
      CODE
:program
 └──── :class
         ├──── :const_ref
         │       └──── :@const ["Parent"] 1:6
         ├──── nil
         └──── :bodystmt
                 ├──── :void_stmt
                 ├──── nil
                 ├──── nil
                 └──── nil
      EXPECT

      expect(RipperTree.create(code).to_s.uncolorize).to eq(expect)
    end

    it 'empty class define' do
      code, expect =<<-CODE, <<-EXPECT
class Child < Parent
end
      CODE
:program
 └──── :class
         ├──── :const_ref
         │       └──── :@const ["Child"] 1:6
         ├──── :var_ref
         │       └──── :@const ["Parent"] 1:14
         └──── :bodystmt
                 ├──── :void_stmt
                 ├──── nil
                 ├──── nil
                 └──── nil
      EXPECT

      expect(RipperTree.create(code).to_s.uncolorize).to eq(expect)
    end

    it 'class variables' do
      code, expect =<<-CODE, <<-EXPECT
class Child
  N = 3
  @value = 'class'
  @@num = 123
end
      CODE
:program
 └──── :class
         ├──── :const_ref
         │       └──── :@const ["Child"] 1:6
         ├──── nil
         └──── :bodystmt
                 ├──── :void_stmt
                 ├──── :assign
                 │       ├──── :var_field
                 │       │       └──── :@const ["N"] 2:2
                 │       └──── :@int ["3"] 2:6
                 ├──── :assign
                 │       ├──── :var_field
                 │       │       └──── :@ivar ["@value"] 3:2
                 │       └──── :string_literal
                 │               └──── :string_content
                 │                       └──── :@tstring_content ["class"] 3:12
                 ├──── :assign
                 │       ├──── :var_field
                 │       │       └──── :@cvar ["@@num"] 4:2
                 │       └──── :@int ["123"] 4:10
                 ├──── nil
                 ├──── nil
                 └──── nil
      EXPECT

      if RUBY_VERSION < '2.3.0'
        expect =~ /\n(.*void_stmt.*\n)/
        expect.gsub!($1, '')
      end

      expect(RipperTree.create(code).to_s.uncolorize).to eq(expect)
    end

    it 'class method' do
      code, expect =<<-CODE, <<-EXPECT
class Child
  def self.hello
  end
end
      CODE
:program
 └──── :class
         ├──── :const_ref
         │       └──── :@const ["Child"] 1:6
         ├──── nil
         └──── :bodystmt
                 ├──── :void_stmt
                 ├──── :defs
                 │       ├──── :var_ref
                 │       │       └──── :@kw ["self"] 2:6
                 │       ├──── :@period ["."] 2:10
                 │       ├──── :@ident ["hello"] 2:11
                 │       ├──── :params
                 │       │       ├──── nil
                 │       │       ├──── nil
                 │       │       ├──── nil
                 │       │       ├──── nil
                 │       │       ├──── nil
                 │       │       ├──── nil
                 │       │       └──── nil
                 │       └──── :bodystmt
                 │               ├──── :void_stmt
                 │               ├──── nil
                 │               ├──── nil
                 │               └──── nil
                 ├──── nil
                 ├──── nil
                 └──── nil
      EXPECT

      if RUBY_VERSION < '2.3.0'
        expect =~ /\n(.*void_stmt.*\n)/
        expect.gsub!($1, '')
      end

      expect(RipperTree.create(code).to_s.uncolorize).to eq(expect)
    end
  end
end
