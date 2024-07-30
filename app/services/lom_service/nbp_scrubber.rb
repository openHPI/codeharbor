# frozen_string_literal: true

module LomService
  class NbpScrubber < Rails::HTML::PermitScrubber
    ALLOW_LIST = YAML.safe_load_file(Rails.root.join('app/services/lom_service/nbp_scrubber_allow_list.yml'))

    def initialize
      super
      self.tags = ALLOW_LIST['tags']
      self.attributes = ALLOW_LIST['attributes']
    end
  end
end
