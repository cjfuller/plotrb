module Plotrb

  # Scales are functions that transform a domain of data values to a range of
  #   visual values.
  # See {https://github.com/trifacta/vega/wiki/Scales}
  class Scale

    include ::Plotrb::Base

    # @!attributes name
    #   @return [String] the name of the scale
    # @!attributes type
    #   @return [Symbol] the type of the scale
    # @!attributes domain
    #   @return [Array(Numeric, Numeric), Array, String] the domain of the
    #     scale, representing the set of data values
    # @!attributes domain_min
    #   @return [Numeric, String] the minimum value in the scale domain
    # @!attributes domain_max
    #   @return [Numeric, String] the maximum value in the scale domain
    # @!attributes range
    #   @return [Array(Numeric, Numeric), Array, String] the range of the
    #     scale, representing the set of visual values
    # @!attributes range_min
    #   @return [Numeric, String] the minimum value in the scale range
    # @!attributes range_max
    #   @return [Numeric, String] the maximum value in the scale range
    # @!attributes reverse
    #   @return [Boolean] whether flips the scale range
    # @!attributes round
    #   @return [Boolean] whether rounds numeric output values to integers
    # @!attributes points
    #   @return [Boolean] whether distributes the ordinal values over a
    #     quantitative range at uniformly spaced points or bands
    # @!attributes clamp
    #   @return [Boolean] whether clamps values that exceed the data domain
    #     to either to minimum or maximum range value
    # @!attributes nice
    #   @return [Symbol, Boolean, nil] scale domain in a more human-friendly
    #     value range
    # @!attributes exponent
    #   @return [Numeric] the exponent of the scale transformation
    # @!attributes zero
    #   @return [Boolean] whether zero baseline value is included
    # @!attributes padding
    #   @return [Numeric] the spacing among ordinal elements in the scale range
    # @!attributes sort
    #   @return [Boolean] whether values in the scale domain will be sorted
    #     according to their natural order
    add_attributes :name, :type, :domain, :domain_min, :domain_max, :range,
                  :range_min, :range_max, :reverse, :round, :points, :clamp,
                  :nice, :exponent, :zero, :padding, :sort

    RANGE_LITERALS = %i(width height shapes colors more_colors)
    TIME_SCALE_NICE = %i(second minute hour day week month year)

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
          @name = args[0]
          self.instance_eval(&block) if block_given?
          self
        else
          raise ArgumentError
      end
    end

    def type(*args, &block)
      case args.size
        when 0
          @type
        when 1
          @type = args[0].to_sym
          self.instance_eval(&block) if block_given?
          self
        else
          raise ArgumentError
      end
    end

    def domain(*args, &block)
      case args.size
        when 0
          @domain
        when 1
          @domain = parse_domain(args[0])
          self.instance_eval(&block) if block_given?
          self
        when 3
          @domain = parse_domain(args[0])
          @domain_min = parse_domain(args[1])
          @domain_max = parse_domain(args[2])
          self.instance_eval(&block) if block_given?
          self
        else
          raise ArgumentError
      end
    end
    alias_method :from, :domain

    def domain_min(*args, &block)
      case args.size
        when 0
          @domain_min
        when 1
          @domain_min = parse_domain(args[0])
          self.instance_eval(&block) if block_given?
          self
        else
          raise ArgumentError
      end
    end

    def domain_max(*args, &block)
      case args.size
        when 0
          @domain_max
        when 1
          @domain_max = parse_domain(args[0])
          self.instance_eval(&block) if block_given?
          self
        else
          raise ArgumentError
      end
    end

    def range(*args, &block)
      case args.size
        when 0
          @range
        when 1
          @range = parse_range(args[0])
          self.instance_eval(&block) if block_given?
          self
        when 3
          @range = parse_range(args[0])
          @range_min = parse_range(args[1])
          @range_max = parse_range(args[2])
          self.instance_eval(&block) if block_given?
          self
        else
          raise ArgumentError
      end
    end
    alias_method :to, :range

    def range_min(*args, &block)
      case args.size
        when 0
          @range_min
        when 1
          @range_min = parse_domain(args[0])
          self.instance_eval(&block) if block_given?
          self
        else
          raise ArgumentError
      end
    end

    def range_max(*args, &block)
      case args.size
        when 0
          @range_max
        when 1
          @range_max = parse_domain(args[0])
          self.instance_eval(&block) if block_given?
          self
        else
          raise ArgumentError
      end
    end

    def reverse(&block)
      @reverse = true
      self.instance_eval(&block) if block_given?
      self
    end

    def reverse?
      @reverse
    end

    def round(&block)
      @round = true
      self.instance_eval(&block) if block_given?
      self
    end

    def round?
      @round
    end

    def points(&block)
      @points = true
      self.instance_eval(&block) if block_given?
      self
    end
    alias_method :as_points, :points

    def points?
      @points
    end
    alias_method :as_points?, :points?

    def bands(&block)
      @points = false
      self.instance_eval(&block) if block_given?
      self
    end
    alias_method :as_bands, :bands

    def bands?
      !@points
    end
    alias_method :as_bands?, :bands?

    def padding(*args, &block)
      case args.size
        when 0
          @padding
        when 1
          @padding = args[0].to_f
          self.instance_eval(&block) if block_given?
          self
        else
          raise ArgumentError
      end
    end

    def sort(&block)
      @sort = true
      self.instance_eval(&block) if block_given?
      self
    end

    def sort?
      @sort
    end

    def exponent(*args, &block)
      case args.size
        when 0
          @exponent
        when 1
          @exponent = args[0]
          self.instance_eval(&block) if block_given?
          self
        else
          raise ArgumentError
      end
    end
    alias_method :in_exponent, :exponent

    def nice(*args, &block)
      if %i(time utc).include?(@type)
        # nice literals only for time and utc types
        case args.size
          when 0
            # getter
            @nice
          when 1
            # setter
            @nice = args[0].to_sym
            self.instance_eval(&block) if block_given?
            self
          else
            raise ArgumentError
        end
      else
        # boolean for all other types
        case args.size
          when 0
            # setter
            @nice = true
            self.instance_eval(&block) if block_given?
            self
          else
            raise ArgumentError
        end
      end
    end
    alias_method :nicely, :nice

    def nice?
      if %i(time utc).include?(@type)
        raise NoMethodError
      else
        # getter
        @nice
      end
    end
    alias_method :nicely?, :nice?

    def zero(&block)
      @zero = true
      self.instance_eval(&block) if block_given?
      self
    end
    alias_method :include_zero, :zero

    def zero?
      @zero
    end
    alias_method :include_zero?, :zero?

    def clamp(&block)
      @clamp = true
      self.instance_eval(&block) if block_given?
      self
    end

    def clamp?
      @clamp
    end

    def method_missing(method, *args, &block)
      case method.to_s
        when /in_(\w+)s$/ # set @nice for time and utc type, eg. in_seconds
          if TIME_SCALE_NICE.include?($1.to_sym)
            self.nice($1.to_sym, &block)
          else
            super
          end
        when /to_(\w+)$/ # set range literals, eg. to_more_colors
          if RANGE_LITERALS.include?($1.to_sym)
            self.range($1.to_sym, &block)
          else
            super
          end
        else
          super
      end
    end

  private

    def parse_domain(domain)
      case domain
        when String
          source, field = domain.split('.', 2)
          if field.nil? || field == 'index'
            ::Plotrb::DataRef.new(data: source, field: 'index')
          else
            ::Plotrb::DataRef.new(data: source, field: "data.#{field}")
          end
        else
          domain
      end
    end

    def parse_range(range)
      case range
        when String, Symbol
          range_literal(range.to_sym)
        else
          range
      end
    end

    def range_literal(literal)
      case literal
        when :colors
          :category10
        when :more_colors
          :category20
        when :width, :height, :shapes
          literal
        else
          raise ArgumentError
      end
    end

  end

  # A data reference specifies the field for a given scale property
  class DataRef

    include ::Plotrb::Base

    # @!attributes data
    #   @return [String] the name of a data set
    # @!attributes field
    #   @return [String] A field from which to pull a data values
    add_attributes :data, :field

    def initialize(args={})
      args.each do |k, v|
        self.instance_variable_set("@#{k}", v) if self.attributes.include?(k)
      end
    end

    def data(*args, &block)
      case args.size
        when 0
          @data
        when 1
          @data = args[0]
          self.instance_eval(&block) if block_given?
          self
        else
          raise ArgumentError
      end
    end

    def field(*args, &block)
      case args.size
        when 0
          @field
        when 1
          @field = args[0]
          self.instance_eval(&block) if block_given?
          self
        else
          raise ArgumentError
      end
    end

  end

end