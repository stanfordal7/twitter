require 'addressable/uri'
require 'memoizable'

module Twitter
  module Profile
    PROFILE_IMAGE_SUFFIX_REGEX = /_normal(\.gif|\.jpe?g|\.png)$/i
    PREDICATE_URI_METHOD_REGEX = /_uri\?$/
    include Memoizable

    class << self
    private

      def alias_predicate_uri_methods(method)
        %w(_url? _uri_https? _url_https?).each do |replacement|
          alias_method_sub(method, PREDICATE_URI_METHOD_REGEX, replacement)
        end
      end

      def alias_method_sub(method, pattern, replacement)
        alias_method(method.to_s.sub(pattern, replacement).to_sym, method)
      end
    end

    # Return the URL to the user's profile banner image
    #
    # @param size [String, Symbol] The size of the image. Must be one of: 'mobile', 'mobile_retina', 'web', 'web_retina', 'ipad', or 'ipad_retina'
    # @return [String]
    def profile_banner_uri(size = :web)
      parse_encoded_uri(insecure_uri([@attrs[:profile_banner_url], size].join('/'))) if @attrs[:profile_banner_url]
    end
    alias_method :profile_banner_url, :profile_banner_uri

    # Return the secure URL to the user's profile banner image
    #
    # @param size [String, Symbol] The size of the image. Must be one of: 'mobile', 'mobile_retina', 'web', 'web_retina', 'ipad', or 'ipad_retina'
    # @return [String]
    def profile_banner_uri_https(size = :web)
      parse_encoded_uri([@attrs[:profile_banner_url], size].join('/')) if @attrs[:profile_banner_url]
    end
    alias_method :profile_banner_url_https, :profile_banner_uri_https

    # @return [Boolean]
    def profile_banner_uri?
      !!@attrs[:profile_banner_url]
    end
    memoize :profile_banner_uri?
    alias_predicate_uri_methods :profile_banner_uri?

    # Return the URL to the user's profile image
    #
    # @param size [String, Symbol] The size of the image. Must be one of: 'mini', 'normal', 'bigger' or 'original'
    # @return [String]
    def profile_image_uri(size = :normal)
      parse_encoded_uri(insecure_uri(profile_image_uri_https(size))) if @attrs[:profile_image_url_https]
    end
    alias_method :profile_image_url, :profile_image_uri

    # Return the secure URL to the user's profile image
    #
    # @param size [String, Symbol] The size of the image. Must be one of: 'mini', 'normal', 'bigger' or 'original'
    # @return [String]
    def profile_image_uri_https(size = :normal)
      # The profile image URL comes in looking like like this:
      # https://a0.twimg.com/profile_images/1759857427/image1326743606_normal.png
      # It can be converted to any of the following sizes:
      # https://a0.twimg.com/profile_images/1759857427/image1326743606.png
      # https://a0.twimg.com/profile_images/1759857427/image1326743606_mini.png
      # https://a0.twimg.com/profile_images/1759857427/image1326743606_bigger.png
      parse_encoded_uri(@attrs[:profile_image_url_https].sub(PROFILE_IMAGE_SUFFIX_REGEX, profile_image_suffix(size))) if @attrs[:profile_image_url_https]
    end
    alias_method :profile_image_url_https, :profile_image_uri_https

    # @return [Boolean]
    def profile_image_uri?
      !!@attrs[:profile_image_url_https]
    end
    memoize :profile_image_uri?
    alias_predicate_uri_methods :profile_image_uri?

  private

    def parse_encoded_uri(uri)
      Addressable::URI.parse(URI.encode(uri))
    end

    def insecure_uri(uri)
      uri.to_s.sub(/^https/i, 'http')
    end

    def profile_image_suffix(size)
      :original == size.to_sym ? '\\1' : "_#{size}\\1"
    end
  end
end