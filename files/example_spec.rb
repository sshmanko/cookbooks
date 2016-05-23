require 'spec_helper'

describe file('/opt/appuser/webapp-master') do
    it { should be_directory }
    it { should be_owned_by 'appuser' }
    it { should be_grouped_into 'appuser' }
end

describe port(5000) do
  it { should be_listening }
end
