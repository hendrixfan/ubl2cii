# frozen_string_literal: true

module Ubl2Cii
  # Elements that should be preserved even when empty
  REQUIRED_ELEMENTS = %w[ExchangedDocumentContext].freeze

  # Elements that need special formatting
  FORMATABLE_ELEMENTS = %w[DateTimeString].freeze

  # XML Namespace URIs
  NAMESPACE_RSM = 'urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100'
  NAMESPACE_RAM = 'urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100'
  NAMESPACE_UDT = 'urn:un:unece:uncefact:data:standard:UnqualifiedDataType:100'
  NAMESPACE_QDT = 'urn:un:unece:uncefact:data:standard:QualifiedDataType:100'
  NAMESPACE_CBC = 'urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2'
  NAMESPACE_CAC = 'urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2'

  PREFIX_RSM = 'rsm'
  PREFIX_RAM = 'ram'
  PREFIX_UDT = 'udt'
  PREFIX_CBC = 'cbc'
  PREFIX_CAC = 'cac'
  PREFIX_QDT = 'qdt'

  OUTPUT_ENCODING = 'UTF-8'
end
