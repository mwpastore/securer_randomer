require_relative 'spec_helper'

describe SecurerRandomer do
  context 'SecurerRandomer::VERSION' do
    Then { SecurerRandomer.const_defined?(:VERSION) }
    And { !SecurerRandomer::VERSION.nil? }
  end
end
