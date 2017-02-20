RSpec.describe RipperTree do
  describe '.parse' do
    it 'define empty module' do
      code, expect =<<-CODE, <<-EXPECT
module Plugin
end
      CODE
:program
 └──── :module
         ├──── :const_ref
         │       └──── :@const [Plugin] 1:7
         └──── :bodystmt
                 ├──── :void_stmt
                 ├──── nil
                 ├──── nil
                 └──── nil
      EXPECT

      expect(RipperTree.create(code).to_s.uncolorize).to eq(expect)
    end
  end
end
