# frozen_string_literal: true

require 'spec_helper'

describe Ubl2Cii::Mapper::Dsl do
  let(:document) { instance_double(Ubl2Cii::Document) }
  let(:xml_builder) { Nokogiri::XML::Builder.new }

  subject { described_class.new }

  describe '#process' do
    before do
      allow(document).to receive(:content_at).with('//cbc:CustomizationID').and_return('urn:cen.eu:en16931:2017')
      allow(document).to receive(:content_at).with('//cbc:ID').and_return('INV-001')
      allow(document).to receive(:content_at).with('//cbc:InvoiceTypeCode').and_return('380')
      allow(document).to receive(:content_at).with('//cbc:IssueDate').and_return('2023-01-01')
      allow(document).to receive(:content_at).with('//cbc:Note').and_return('Test note')
    end

    it 'builds the XML structure correctly' do
      subject.process(xml_builder, document)
      xml = xml_builder.to_xml

      expect(xml).to include('<rsm:ExchangedDocumentContext>')
      expect(xml).to include('<ram:GuidelineSpecifiedDocumentContextParameter>')
      expect(xml).to include('<ram:ID>urn:cen.eu:en16931:2017</ram:ID>')
      expect(xml).to include('<rsm:ExchangedDocument>')
      expect(xml).to include('<ram:ID>INV-001</ram:ID>')
      expect(xml).to include('<ram:TypeCode>380</ram:TypeCode>')
      expect(xml).to include('<ram:IssueDateTime>')
      expect(xml).to include('<udt:DateTimeString format="102">20230101</udt:DateTimeString>')
      expect(xml).to include('<ram:IncludedNote>')
      expect(xml).to include('<ram:Content>Test note</ram:Content>')
    end
  end
end
