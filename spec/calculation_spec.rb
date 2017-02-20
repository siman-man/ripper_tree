RSpec.describe RipperTree do
  describe '.parse' do
    context 'when formula' do
      it 'sum' do
        code, expect =<<-CODE, <<-EXPECT
1 + 1 + 300
        CODE
:program
 └──── :binary
         ├──── :binary
         │       ├──── :@int [1] 1:0
         │       ├──── :+
         │       └──── :@int [1] 1:4
         ├──── :+
         └──── :@int [300] 1:8
        EXPECT

        expect(RipperTree.create(code).to_s.uncolorize).to eq(expect)
      end

      it 'difference' do
        code, expect =<<-CODE, <<-EXPECT
3 - 2 - 1
        CODE
:program
 └──── :binary
         ├──── :binary
         │       ├──── :@int [3] 1:0
         │       ├──── :-
         │       └──── :@int [2] 1:4
         ├──── :-
         └──── :@int [1] 1:8
        EXPECT

        expect(RipperTree.create(code).to_s.uncolorize).to eq(expect)
      end
    end
  end
end
