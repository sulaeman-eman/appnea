require "vips"

# Generates a deterministic ocean-toned gradient for seed data.
#
# These stand in for photography so the layout can be judged with images in
# place. They are obviously not photos, which is the point — nobody should
# mistake seed data for real content and ship it.
module Seeds
  module PlaceholderImage
    PALETTES = [
      [ [ 4, 40, 63 ],    [ 18, 168, 160 ] ],
      [ [ 7, 59, 88 ],    [ 13, 85, 112 ] ],
      [ [ 11, 127, 121 ], [ 4, 40, 63 ] ],
      [ [ 16, 36, 47 ],   [ 18, 120, 150 ] ]
    ].freeze

    module_function

    def jpeg(seed:, width: 1800, height: 900)
      top, bottom = PALETTES[seed.sum % PALETTES.size]

      xy = Vips::Image.xyz(width, height)
      # 0 at the top row, 1 at the bottom, used to mix the two colours.
      ratio = xy[1].cast(:float) / (height - 1)

      bands = (0..2).map { |channel| ratio * (bottom[channel] - top[channel]) + top[channel] }

      Vips::Image
        .bandjoin(bands)
        .cast(:uchar)
        .copy(interpretation: :srgb)
        .jpegsave_buffer(Q: 82)
    end
  end
end
