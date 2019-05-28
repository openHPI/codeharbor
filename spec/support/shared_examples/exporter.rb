# frozen_string_literal: true

RSpec.shared_examples 'zipped task node xml' do
  it { is_expected.to be_a StringIO }

  it 'contains the zipped xml-file' do
    expect { zip_files['task.xml'] }.not_to raise_error
  end

  it 'contains through schema validatable xml' do
    expect(Nokogiri::XML::Schema(File.open(Proforma::SCHEMA_PATH)).validate(doc)).to be_empty
  end

  it 'adds task root-node' do
    expect(xml.xpath('/task')).to have(1).item
  end

  it 'adds title node' do
    expect(xml.xpath('/task/title')).to have(1).item
  end

  it 'adds description node' do
    expect(xml.xpath('/task/description')).to have(1).item
  end

  it 'adds proglang node' do
    expect(xml.xpath('/task/proglang')).to have(1).item
  end

  it 'adds files node' do
    expect(xml.xpath('/task/files')).to have(1).item
  end

  it 'adds file node to files' do
    expect(xml.xpath('/task/files/file')).to have_at_least(1).item
  end

  it 'adds model-solutions node' do
    expect(xml.xpath('/task/model-solutions')).to have(1).item
  end

  it 'adds model-solution node to model-solutions' do
    expect(xml.xpath('/task/model-solutions/model-solution')).to have(1).item
  end

  it 'adds filerefs node to model-solution' do
    expect(xml.xpath('/task/model-solutions/model-solution/filerefs')).to have(1).item
  end

  it 'adds fileref node to filerefs' do
    expect(xml.xpath('/task/model-solutions/model-solution/filerefs/fileref')).to have(1).item
  end

  it 'adds tests node' do
    expect(xml.xpath('/task/tests')).to have(1).item
  end

  it 'adds meta-data node' do
    expect(xml.xpath('/task/meta-data')).to have(1).item
  end
end

RSpec.shared_examples 'populated task node' do
  it 'adds uuid attribute to task node' do
    expect(xml.xpath('/task').attribute('uuid').value).to eql task.uuid
  end

  it 'adds parent-uuid attribute to task node' do
    expect(xml.xpath('/task').attribute('parent-uuid').value).to eql task.parent_uuid
  end

  it 'adds lang attribute to task node' do
    expect(xml.xpath('/task').attribute('lang').value).to eql task.language
  end

  it 'adds content to title node' do
    expect(xml.xpath('/task/title').text).to eql task.title
  end

  it 'adds content to description node' do
    expect(xml.xpath('/task/description').text).to eql task.description
  end

  it 'adds content to internal-description node' do
    expect(xml.xpath('/task/internal-description').text).to eql task.internal_description
  end

  it 'adds content to proglang node' do
    expect(xml.xpath('/task/proglang').text).to eql task.proglang[:name]
  end

  it 'adds version attribute to proglang node' do
    expect(xml.xpath('/task/proglang').attribute('version').value).to eql task.proglang[:version]
  end
end

RSpec.shared_examples 'task node with embedded file' do |text_bin|
  it_behaves_like 'task node with file', 'embedded', text_bin

  it 'adds filename-attribute to file node' do
    expect(
      xml.xpath("/task/files/file[@id!='ms-placeholder-file']/embedded-#{text_bin}-file").attribute('filename').value
    ).to eql file.filename
  end
end

RSpec.shared_examples 'task node with attached file' do |text_bin|
  it_behaves_like 'task node with file', 'attached', text_bin

  it 'adds filename to file node' do
    expect(xml.xpath("/task/files/file[@id!='ms-placeholder-file']/attached-#{text_bin}-file").text).to eql file.filename
  end

  it 'adds attached file to zip' do
    expect(zip_files[file.filename]).not_to be nil
  end
end
RSpec.shared_examples 'task node without model-solution with file' do
  it 'adds file nodes to files' do
    expect(xml.xpath('/task/files/file')).to have(2).items
  end
end

RSpec.shared_examples 'task node with file' do |text_bin, att_emb|
  it 'adds id to attributes of file node' do
    expect(xml.xpath("/task/files/file[@id!='ms-placeholder-file']").attribute('id').value).to eql file.id
  end

  it 'adds used-by-grader to attributes of file node' do
    expect(xml.xpath("/task/files/file[@id!='ms-placeholder-file']").attribute('used-by-grader').value).to eql file.used_by_grader.to_s
  end

  it 'adds visible to attributes of file node' do
    expect(xml.xpath("/task/files/file[@id!='ms-placeholder-file']").attribute('visible').value).to eql file.visible
  end

  it 'adds usage-by-lms to attributes of file node' do
    expect(xml.xpath("/task/files/file[@id!='ms-placeholder-file']").attribute('usage-by-lms').value).to eql file.usage_by_lms
  end

  it 'adds mimetype to attributes of file node' do
    expect(xml.xpath("/task/files/file[@id!='ms-placeholder-file']").attribute('mimetype').value).to eql file.mimetype
  end

  it 'adds mimetype to attributes of file node' do
    expect(xml.xpath("/task/files/file[@id!='ms-placeholder-file']/internal-description").text).to eql file.internal_description
  end

  it "adds file node for #{att_emb} #{text_bin} file to files" do
    expect(xml.xpath("/task/files/file[@id!='ms-placeholder-file']/#{text_bin}-#{att_emb}-file")).to have(1).item
  end
end

RSpec.shared_examples 'task node with test' do
  it 'adds test node to tests' do
    expect(xml.xpath('/task/tests/test')).to have(1).item
  end

  it 'adds id attribute to test node' do
    expect(xml.xpath('/task/tests/test').attribute('id').value).to eql test.id
  end

  it 'adds content to title node' do
    expect(xml.xpath('/task/tests/test/title').text).to eql test.title
  end

  it 'adds content to test-type node' do
    expect(xml.xpath('/task/tests/test/test-type').text).to eql test.test_type
  end

  it 'adds test-configuration node to test node' do
    expect(xml.xpath('/task/tests/test/test-configuration')).to have(1).item
  end

  it 'adds namespace to task' do
    expect(doc.xpath('/xmlns:task').first.namespaces['xmlns:c']).to eql 'codeharbor'
  end
end
