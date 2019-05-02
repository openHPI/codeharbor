# frozen_string_literal: true

module ProformaService
  class Import < ServiceBase
    def initialize(zip: nil)
      @zip = zip
    end

    def execute
      @test * 666
    end
  end
end
