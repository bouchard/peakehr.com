require 'rqrcode'

module RQRCode

  Mime::Type.register "image/svg+xml", :svg unless Mime::Type.lookup_by_extension(:svg)

  module Renderers
    class SVG
      class << self
        # Render the SVG from the qrcode string provided from the RQRCode gem
        #   Options:
        #   offset - Padding around the QR Code (e.g. 10)
        #   unit   - How many pixels per module (Default: 10)
        #   fill   - Background color (e.g "ffffff" or :white)
        #   color  - Foreground color for the code (e.g. "000000" or :black)

        def render(qrcode, options = {})
          offset  = options[:offset].to_i || 0
          color   = options[:color]       || "000000"
          unit    = options[:unit]        || 10

          # height and width dependent on offset and QR complexity
          dimension = qrcode.module_count * unit + 2 * offset

          xml_tag   = %{<?xml version="1.0" standalone="yes"?>}
          open_tag  = %{<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:ev="http://www.w3.org/2001/xml-events" width="#{dimension}" height="#{dimension}">}
          close_tag = %{</svg>}

          result = []
          qrcode.modules.each_index do |c|
            tmp = []
            qrcode.modules.each_index do |r|
              y = c * unit + offset
              x = r * unit + offset
              next unless qrcode.is_dark(c, r)
              result << %{<rect width="#{unit}" height="#{unit}" x="#{x}" y="#{y}" style="fill:##{color}"/>}
            end
          end

          if options[:fill]
            result.unshift %{<rect width="#{dimension}" height="#{dimension}" x="0" y="0" style="fill:##{options[:fill]}"/>}
          end
          svg = [xml_tag, open_tag, result, close_tag].flatten.join("\n")
        end
      end
    end
  end

  def render_qrcode(string, format, options)
    size   = options[:size]  || RQRCode.minimum_qr_size_from_string(string)
    level  = options[:level] || :h

    qrcode = RQRCode::QRCode.new(string, size: size, level: level)
    svg    = RQRCode::Renderers::SVG::render(qrcode, options)
  end
  module_function :render_qrcode

  ActionController::Renderers.add :qrcode do |string, options|
    format = self.request.format.symbol
    data = RQRCode.render_qrcode(string, format, options)
    self.response_body = render_to_string(text: data, template: nil)
  end

  private

  QR_CHAR_SIZE_VS_SIZE = [7, 14, 24, 34, 44, 58, 64, 84, 98, 119, 137, 155, 177, 194]
  def minimum_qr_size_from_string(string)
    QR_CHAR_SIZE_VS_SIZE.each_with_index do |size, index|
      return (index + 1) if string.size < size
    end
    # If it's particularly big, we'll try and create codes until it accepts.
    i = QR_CHAR_SIZE_VS_SIZE.size
    begin
      i += 1
      RQRCode::QRCode.new(string, size: i)
      return i
    rescue RQRCode::QRCodeRunTimeError
      retry
    end
  end
  module_function :minimum_qr_size_from_string

end