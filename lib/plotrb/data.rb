module Plotrb

  # The basic tabular data model used by Vega.
  # See {https://github.com/trifacta/vega/wiki/Data}
  class Data

    include ::Plotrb::Base

    # @!attributes name
    #   @return [String] the name of the data set
    # @!attributes format
    #   @return [Hash] the format of the data file
    # @!attributes values
    #   @return [Hash] the actual data set
    # @!attributes source
    #   @return [String] the name of another data set to use as source
    # @!attributes url
    #   @return [String] the url from which to load the data set
    # @!attributes transform
    #   @return [Array<Transform>] an array of transform definitions
    add_attributes :name, :format, :values, :source, :url, :transform

    def initialize(args={}, &block)
      args.each do |k, v|
        self.instance_variable_set("@#{k}", v) if self.attributes.include?(k)
      end
      self.instance_eval(&block) if block_given?
      self
    end

    def name(*args, &block)
      case args.size
        when 0
          @name
        when 1
          @name = args[0].to_s
          self.instance_eval(&block) if block_given?
          self
        else
          raise ArgumentError
      end
    end

    # TODO: parse format properly
    def format(*args, &block)
      case args.size
        when 0
          @format
        when 1
          @format = args[0].to_sym
          self.instance_eval(&block) if block_given?
          self
        else
          raise ArgumentError
      end
    end

    def values(*args, &block)
      case args.size
        when 0
          @values
        else
          @values = args
      end
    end

    def source(*args, &block)
      case args.size
        when 0
          @source
        when 1
          @source = parse_source(args[0])
          self.instance_eval(&block) if block_given?
          self
        else
          raise ArgumentError
      end
    end

    def url(*args, &block)
      case args.size
        when 0
          @url
        when 1
          @url = parse_url(args[0])
          self.instance_eval(&block) if block_given?
          self
        else
          raise ArgumentError
      end
    end

    def transform(*args, &block)
      case args.size
        when 0
          @transform
        else
          @transform = parse_transform(args)
          self.instance_eval(&block) if block_given?
          self
      end
    end

    class FormatValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        record.errors.add(attribute, 'invalid format') unless
            valid_format_key?(value) && valid_format_value?(value)
      end

      def valid_format_key?(format)
        format.is_a?(Hash) && [:json, :csv, :tsv].include?(format[:type])
      end

      def valid_format_value?(format)
        valid = true
        if format[:parse]
          format[:parse].each do |_, v|
            valid = false unless [:number, :boolean, :date].include?(v)
          end
        end
        valid
      end
    end

  private

    def parse_transform(transform)
      case transform
        when Array
          transform.collect { |t| parse_transform(t) }
        when String
          transform
        when ::Plotrb::Transform
          transform.name
        else
          raise ArgumentError
      end
    end

    def parse_source(source)
      case source
        when String
          source
        when ::Plotrb::Data
          source.name
        else
          raise ArgumentError
      end
    end

    def parse_url(url)
      url if URI.parse(url)
    rescue URI::InvalidURIError
      raise ArgumentError
    end

  end

end