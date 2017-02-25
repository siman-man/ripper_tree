RSpec.describe RipperTree do
  describe '.parse' do
    context 'simple output' do
      it 'puts' do
        code, expect =<<-CODE, <<-EXPECT
puts "hello world"
        CODE
:program
 └──── :command
         ├──── :@ident ["puts"] 1:0
         └──── :args_add_block
                 ├──── :string_literal
                 │       └──── :string_content
                 │               └──── :@tstring_content ["hello world"] 1:6
                 └──── false
        EXPECT

        expect(RipperTree.create(code).to_s.uncolorize).to eq(expect)
      end

      it 'print' do
        code, expect =<<-CODE, <<-EXPECT
print "hello world\n"
        CODE
:program
 └──── :command
         ├──── :@ident ["print"] 1:0
         └──── :args_add_block
                 ├──── :string_literal
                 │       └──── :string_content
                 │               └──── :@tstring_content ["hello world\\n"] 1:7
                 └──── false
        EXPECT

        expect(RipperTree.create(code).to_s.uncolorize).to eq(expect)
      end
    end
  end
end
