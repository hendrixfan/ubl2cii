# UblToCiiConverter

A Ruby Gem to convert UBL XML files to CII XML files.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ubl_to_cii_converter'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install ubl_to_cii_converter
```

## Usage

### Basic Usage Example

Here is a simple example of converting a UBL XML file to a CII XML file using the `Ubl2Cii::Converter` class.

```ruby
require 'ubl2cii'

# Read the UBL XML file
ubl_xml = File.read('path/to/ubl_invoice.xml')

# Initialize the converter
converter = Ubl2Cii::Converter.new(ubl_xml)

# Convert to CII XML
cii_xml = converter.convert_to_cii

# Output the resulting CII XML
File.write('path/to/cii_invoice.xml', cii_xml)
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hendrixfan/ubl2cii. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/hendrixfan/ubl2cii/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Dependencies

This project depends on the following gems:

- `nokogiri` (>= 1.18)

## Running Tests

To run the tests, execute:

```bash
$ bundle exec rake spec
```
