RSpec.describe Tf::Hcl do
  it "has a version number" do
    expect(Tf::Hcl::VERSION).not_to be nil
  end

  Dir.glob("spec/sample_data/**/*.tf").each do |file|
    describe "terraform sample: #{Pathname.new(file).relative_path_from(Pathname.new('spec/sample_data'))}" do
      it 'can be loaded' do
        expect{Tf::Hcl.load_file(file)}.to_not raise_exception
      end
      
      it 'can be dumped' do
        expect{Tf::Hcl.dump(Tf::Hcl.load_file(file))}.to_not raise_exception
      end
    end
  end
end
