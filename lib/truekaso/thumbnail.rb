
module Truekaso
  module Thumbnail
    HOST = 'digitaloceanspaces.com'
    CDN_HOST = 'cdn.digitaloceanspaces.com'
    ## rewrites url to use Digital Ocean's cached CDN
    def setup_url(url_object, type = :original, size = nil)
      if type == :original || size.nil?
        url_object.url.gsub(HOST, CDN_HOST)
      else
        # url_object.variant(resize_and_pad: [size, size, gravity: 'north', background: '#000']).processed.url.gsub(HOST, CDN_HOST)
        if Rails.env.development?
          url_object.variant(resize: "#{size}x#{size}>").processed.url
        else
          url_object.variant(resize: "#{size}x#{size}>").processed.url.gsub(HOST, CDN_HOST)
        end
      end
    end

    def prepare_thumbnail(url, size)
      setup_url(url, :thumbnail, size)
    end
  end
end