# frozen_string_literal: true

RSpec.shared_examples 'zipped task node xml' do
  it { is_expected.to be_a StringIO }

  it 'contains the zipped xml-file' do
    expect { zip_files['task.xml'] }.not_to raise_error
  end

  it 'contains through schema validatable xml' do
    expect(ProformaXML::Validator.new(xml_with_namespaces).perform).to be_empty
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
    # Since model-solutions are optional since ProFormA v2.1,
    # we no longer need to add a dummy file to the task.
    expect(xml.xpath('/task/files/file')).to have_at_least(0).items
  end

  it 'adds model-solutions node' do
    # model-solutions are optional since ProFormA v2.1
    expect(xml.xpath('/task/model-solutions')).to have(0).items
  end

  it 'adds model-solution node to model-solutions' do
    # model-solutions are optional since ProFormA v2.1
    expect(xml.xpath('/task/model-solutions/model-solution')).to have(0).items
  end

  it 'adds filerefs node to model-solution' do
    # model-solutions are optional since ProFormA v2.1
    expect(xml.xpath('/task/model-solutions/model-solution/filerefs')).to have(0).items
  end

  it 'adds fileref node to filerefs' do
    # model-solutions are optional since ProFormA v2.1
    expect(xml.xpath('/task/model-solutions/model-solution/filerefs/fileref')).to have(0).items
  end

  it 'adds tests node' do
    expect(xml.xpath('/task/tests')).to have(1).item
  end

  it 'adds meta-data node' do
    expect(xml.xpath('/task/meta-data')).to have(1).item
  end
end

RSpec.shared_examples 'task node with file' do
  it 'adds a file node' do
    expect(xml.xpath("/task/files/file[@id!='ms-placeholder-file']")).to have(1).item
  end

  it 'adds id-attribute to file node' do
    expect(xml.xpath("/task/files/file[@id!='ms-placeholder-file']").attribute('id').value).to eql file.xml_id
  end

  it 'adds used-by-grader-attribute to file node' do
    expect(
      xml.xpath("/task/files/file[@id!='ms-placeholder-file']").attribute('used-by-grader').value
    ).to eql(file.used_by_grader.to_s)
  end

  it 'adds visible-attribute to file node' do
    expect(xml.xpath("/task/files/file[@id!='ms-placeholder-file']").attribute('visible').value).to eql file.visible
  end

  it 'adds usage-by-lms-attribute to file node' do
    expect(
      xml.xpath("/task/files/file[@id!='ms-placeholder-file']").attribute('usage-by-lms').value
    ).to eql file.usage_by_lms
  end

  it 'adds a embedded-txt-file node to the file node' do
    expect(xml.xpath("/task/files/file[@id!='ms-placeholder-file']/embedded-txt-file")).to have(1).item
  end

  it 'adds a filename attribute to the embedded-txt-file node' do
    expect(
      xml.xpath("/task/files/file[@id!='ms-placeholder-file']/embedded-txt-file").attribute('filename').value
    ).to eql file.full_file_name
  end

  it 'adds the content to the embedded-txt-file node' do
    expect(
      xml.xpath("/task/files/file[@id!='ms-placeholder-file']/embedded-txt-file").text
    ).to eql file.content
  end

  it 'adds internal-description' do
    expect(
      xml.xpath("/task/files/file[@id!='ms-placeholder-file']/internal-description").text
    ).to eql file.internal_description
  end
end
