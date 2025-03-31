# frozen_string_literal: true

require 'spec_helper'

describe Ubl2Cii do
  let(:ubl_xml) do
    <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <Invoice xmlns="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2">
        <ID>INVOICE-001</ID>
      </Invoice>
    XML
  end

  it "has a version number" do
    expect(Ubl2Cii::VERSION).not_to be nil
  end

  describe "Converter" do
    subject(:converter) { Ubl2Cii::Converter.new(ubl_xml) }

    describe "#convert_to_cii" do
      let(:cii_xml) { converter.convert_to_cii }

      it "converts UBL to CII format" do
        expect(cii_xml).to include('xmlns:ram="urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100"')
        expect(cii_xml).to include("<ID>INVOICE-001</ID>")
      end
    end

    describe "#convert_to_cii" do

    end
  end
end
