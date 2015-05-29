module OpenStax::Cnx::V1::Fragment
  class Interactive < Embedded
    include ActsAsFragment

    self.default_width = 960
    self.default_height = 560
  end
end
