RSpec.describe RipperTree do
  describe '.parse' do
    context 'simple assignment' do
      it 'integer' do
        code, expect =<<-CODE, <<-EXPECT
n = 1
        CODE
:program
 └──── :assign
         ├──── :var_field
         │       └──── :@ident [n] 1:0
         └──── :@int [1] 1:4
        EXPECT

        expect(RipperTree.create(code).to_s.uncolorize).to eq(expect)
      end

      it 'float' do
        code, expect =<<-CODE, <<-EXPECT
pi = 3.14
        CODE
:program
 └──── :assign
         ├──── :var_field
         │       └──── :@ident [pi] 1:0
         └──── :@float [3.14] 1:5
        EXPECT

        expect(RipperTree.create(code).to_s.uncolorize).to eq(expect)
      end

      it 'rational' do
        code, expect =<<-CODE, <<-EXPECT
n = 1/2r
        CODE
:program
 └──── :assign
         ├──── :var_field
         │       └──── :@ident [n] 1:0
         └──── :binary
                 ├──── :@int [1] 1:4
                 ├──── :/
                 └──── :@rational [2r] 1:6
        EXPECT

        expect(RipperTree.create(code).to_s.uncolorize).to eq(expect)
      end

      it 'complex' do
        code, expect =<<-CODE, <<-EXPECT
n = 1+2i
        CODE
:program
 └──── :assign
         ├──── :var_field
         │       └──── :@ident [n] 1:0
         └──── :binary
                 ├──── :@int [1] 1:4
                 ├──── :+
                 └──── :@imaginary [2i] 1:6
        EXPECT

        expect(RipperTree.create(code).to_s.uncolorize).to eq(expect)
      end

      it 'multiple integer assing' do
        code, expect =<<-CODE, <<-EXPECT
n = 1
m = 2
        CODE
:program
 ├──── :assign
 │       ├──── :var_field
 │       │       └──── :@ident [n] 1:0
 │       └──── :@int [1] 1:4
 └──── :assign
         ├──── :var_field
         │       └──── :@ident [m] 2:0
         └──── :@int [2] 2:4
        EXPECT

        expect(RipperTree.create(code).to_s.uncolorize).to eq(expect)
      end

      it 'integer array' do
        code, expect =<<-CODE, <<-EXPECT
array = [1,2,3]
        CODE
:program
 └──── :assign
         ├──── :var_field
         │       └──── :@ident [array] 1:0
         └──── :array
                 ├──── :@int [1] 1:9
                 ├──── :@int [2] 1:11
                 └──── :@int [3] 1:13
        EXPECT

        expect(RipperTree.create(code).to_s.uncolorize).to eq(expect)
      end

      it 'various array' do
        code, expect =<<-CODE, <<-EXPECT
array = [1,2.0,1/3r,2i,'hello',:world]
        CODE
:program
 └──── :assign
         ├──── :var_field
         │       └──── :@ident [array] 1:0
         └──── :array
                 ├──── :@int [1] 1:9
                 ├──── :@float [2.0] 1:11
                 ├──── :binary
                 │       ├──── :@int [1] 1:15
                 │       ├──── :/
                 │       └──── :@rational [3r] 1:17
                 ├──── :@imaginary [2i] 1:20
                 ├──── :string_literal
                 │       └──── :string_content
                 │               └──── :@tstring_content ["hello"] 1:24
                 └──── :symbol_literal
                         └──── :symbol
                                 └──── :@ident [world] 1:32
        EXPECT

        expect(RipperTree.create(code).to_s.uncolorize).to eq(expect)
      end

      it 'const' do
        code, expect =<<-CODE, <<-EXPECT
N = 3
        CODE
:program
 └──── :assign
         ├──── :var_field
         │       └──── :@const [N] 1:0
         └──── :@int [3] 1:4
        EXPECT

        expect(RipperTree.create(code).to_s.uncolorize).to eq(expect)
      end

      it '$global' do
        code, expect =<<-CODE, <<-EXPECT
$a = :global
        CODE
:program
 └──── :assign
         ├──── :var_field
         │       └──── :@gvar [$a] 1:0
         └──── :symbol_literal
                 └──── :symbol
                         └──── :@ident [global] 1:6
        EXPECT

        expect(RipperTree.create(code).to_s.uncolorize).to eq(expect)
      end

      it 'character' do
        code, expect =<<-CODE, <<-EXPECT
c = ?a
        CODE
:program
 └──── :assign
         ├──── :var_field
         │       └──── :@ident [c] 1:0
         └──── :@CHAR [?a] 1:4
        EXPECT

        expect(RipperTree.create(code).to_s.uncolorize).to eq(expect)
      end

      it 'empty hash' do
        code, expect =<<-CODE, <<-EXPECT
hash = {}
        CODE
:program
 └──── :assign
         ├──── :var_field
         │       └──── :@ident [hash] 1:0
         └──── :hash
        EXPECT

        expect(RipperTree.create(code).to_s.uncolorize).to eq(expect)
      end

      it 'empty array' do
        code, expect =<<-CODE, <<-EXPECT
array = []
        CODE
:program
 └──── :assign
         ├──── :var_field
         │       └──── :@ident [array] 1:0
         └──── :array
        EXPECT

        expect(RipperTree.create(code).to_s.uncolorize).to eq(expect)
      end
    end
  end
end
