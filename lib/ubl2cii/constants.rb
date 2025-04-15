# frozen_string_literal: true

module Ubl2Cii
  # Elements that should be preserved even when empty
  REQUIRED_ELEMENTS = %w[ExchangedDocumentContext].freeze

  # Elements that need special formatting
  FORMATABLE_ELEMENTS = %w[DateTimeString].freeze

  # XML Namespace URIs
  NAMESPACE_RSM = 'urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100'.freeze
  NAMESPACE_RAM = 'urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100'.freeze
  NAMESPACE_UDT = 'urn:un:unece:uncefact:data:standard:UnqualifiedDataType:100'.freeze
  NAMESPACE_QDT = 'urn:un:unece:uncefact:data:standard:QualifiedDataType:100'.freeze
  NAMESPACE_CBC = 'urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2'.freeze
  NAMESPACE_CAC = 'urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2'.freeze

  PREFIX_RSM = 'rsm'.freeze
  PREFIX_RAM = 'ram'.freeze
  PREFIX_UDT = 'udt'.freeze
  PREFIX_CBC = 'cbc'.freeze
  PREFIX_CAC = 'cac'.freeze
  PREFIX_QDT = 'qdt'.freeze

  OUTPUT_ENCODING = 'UTF-8'.freeze
end
