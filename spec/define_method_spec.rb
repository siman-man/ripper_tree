RSpec.describe RipperTree do
  describe '.parse' do
    it 'define empty method' do
      code, expect =<<-CODE, <<-EXPECT
def void
end
      CODE
:program
 └──── :def
         ├──── :@ident ["void"] 1:4
         ├──── :params
         │       ├──── nil
         │       ├──── nil
         │       ├──── nil
         │       ├──── nil
         │       ├──── nil
         │       ├──── nil
         │       └──── nil
         └──── :bodystmt
                 ├──── :void_stmt
                 ├──── nil
                 ├──── nil
                 └──── nil
      EXPECT

      expect(RipperTree.create(code).to_s.uncolorize).to eq(expect)
    end

    context 'with arguments' do
      it 'req arguments' do
        code, expect =<<-CODE, <<-EXPECT
def func(req)
end
        CODE
:program
 └──── :def
         ├──── :@ident ["func"] 1:4
         ├──── :paren
         │       └──── :params
         │               ├──── :pars
         │               │       └──── :@ident ["req"] 1:9
         │               ├──── nil
         │               ├──── nil
         │               ├──── nil
         │               ├──── nil
         │               ├──── nil
         │               └──── nil
         └──── :bodystmt
                 ├──── :void_stmt
                 ├──── nil
                 ├──── nil
                 └──── nil
        EXPECT

        expect(RipperTree.create(code).to_s.uncolorize).to eq(expect)
      end

      it 'opt arguments' do
        code, expect =<<-CODE, <<-EXPECT
def func(opt=3)
end
        CODE
:program
 └──── :def
         ├──── :@ident ["func"] 1:4
         ├──── :paren
         │       └──── :params
         │               ├──── nil
         │               ├──── :opts
         │               │       └──── arg1
         │               │               ├──── :@ident ["opt"] 1:9
         │               │               └──── :@int ["3"] 1:13
         │               ├──── nil
         │               ├──── nil
         │               ├──── nil
         │               ├──── nil
         │               └──── nil
         └──── :bodystmt
                 ├──── :void_stmt
                 ├──── nil
                 ├──── nil
                 └──── nil
        EXPECT

        expect(RipperTree.create(code).to_s.uncolorize).to eq(expect)
      end

      it 'rest arguments' do
        code, expect =<<-CODE, <<-EXPECT
def func(*rest)
end
        CODE
:program
 └──── :def
         ├──── :@ident ["func"] 1:4
         ├──── :paren
         │       └──── :params
         │               ├──── nil
         │               ├──── nil
         │               ├──── :rest
         │               │       └──── :@ident ["rest"] 1:10
         │               ├──── nil
         │               ├──── nil
         │               ├──── nil
         │               └──── nil
         └──── :bodystmt
                 ├──── :void_stmt
                 ├──── nil
                 ├──── nil
                 └──── nil
        EXPECT

        expect(RipperTree.create(code).to_s.uncolorize).to eq(expect)
      end

      xit 'key arguments' do
        code, expect =<<-CODE, <<-EXPECT
def func(key:)
end
        CODE
:program
 └──── :def
         ├──── :@ident ["func"] 1:4
         ├──── :paren
         │       └──── :params
         │               ├──── nil
         │               ├──── nil
         │               ├──── nil
         │               ├──── nil
         │               ├──── :keyreq_param
         │               │       └──── :@label ["key:"] 1:9
         │               ├──── nil
         │               └──── nil
         └──── :bodystmt
                 ├──── :void_stmt
                 ├──── nil
                 ├──── nil
                 └──── nil
        EXPECT

        expect(RipperTree.create(code).to_s.uncolorize).to eq(expect)
      end

      it 'keyrest arguments' do
        code, expect =<<-CODE, <<-EXPECT
def func(**keyrest)
end
        CODE
:program
 └──── :def
         ├──── :@ident ["func"] 1:4
         ├──── :paren
         │       └──── :params
         │               ├──── nil
         │               ├──── nil
         │               ├──── nil
         │               ├──── nil
         │               ├──── nil
         │               ├──── :kwrest
         │               │       └──── :@ident ["keyrest"] 1:11
         │               └──── nil
         └──── :bodystmt
                 ├──── :void_stmt
                 ├──── nil
                 ├──── nil
                 └──── nil
        EXPECT

        expect(RipperTree.create(code).to_s.uncolorize).to eq(expect)
      end

      it 'block arguments' do
        code, expect =<<-CODE, <<-EXPECT
def func(&block)
end
        CODE
:program
 └──── :def
         ├──── :@ident ["func"] 1:4
         ├──── :paren
         │       └──── :params
         │               ├──── nil
         │               ├──── nil
         │               ├──── nil
         │               ├──── nil
         │               ├──── nil
         │               ├──── nil
         │               └──── :blk
         │                       └──── :@ident ["block"] 1:10
         └──── :bodystmt
                 ├──── :void_stmt
                 ├──── nil
                 ├──── nil
                 └──── nil
        EXPECT

        expect(RipperTree.create(code).to_s.uncolorize).to eq(expect)
      end

      it 'call method with empty block' do
        code, expect =<<-CODE, <<-EXPECT
x {}
        CODE
:program
 └──── :method_add_block
         ├──── :method_add_arg
         │       ├──── :fcall
         │       │       └──── :@ident ["x"] 1:0
         │       └──── []
         └──── :brace_block
                 ├──── nil
                 └──── :void_stmt
        EXPECT

        expect(RipperTree.create(code).to_s.uncolorize).to eq(expect)
      end
    end
  end
end
