require 'spec_helper'

describe file('/opt/splunkforwarder/bin') do
  it { should exist }
  it { should be_directory }
end

describe service('splunk') do
  it { should be_enabled }
end

describe 'inputs config should be configured per node attributes' do
  describe file('/opt/splunkforwarder/etc/system/local/inputs.conf') do
    it { should be_file }
    its(:content) { should match(/\[tcp:\/\/:123123\]/) }
    its(:content) { should match(/connection_host = dns/) }
    its(:content) { should match(/sourcetype = syslog/) }
    its(:content) { should match(/source = tcp:123123/) }
  end
end

describe 'outputs config should be configured per node attributes' do
  describe file('/opt/splunkforwarder/etc/system/local/outputs.conf') do
    it { should be_file }
    its(:content) { should match(/defaultGroup = group1/) }
    its(:content) { should match(/forwardedindex.0.whitelist = .*/) }
    its(:content) { should match(/forwardedindex.1.blacklist = _.*/) }
    its(:content) { should match(/forwardedindex.2.whitelist = _audit/) }
    its(:content) { should match(/forwardedindex.filter.disable = false/) }
    its(:content) { should match(/tcpout:group1/) }
    its(:content) { should match(/server = 192.168.10.1:9997, 192.168.10.2:9997, 192.168.10.3:9997/) }
    its(:content) { should match(/sslCertPath = \$SPLUNK_HOME\/etc\/certs\/cert.pem/) }
    its(:content) { should match(/sslCommonNameToCheck = sslCommonName/) }
    its(:content) { should match(/sslRootCAPath = \$SPLUNK_HOME\/etc\/certs\/cacert.pem/) }
    its(:content) { should match(/sslVerifyServerCert = false/) }
  end
end

describe 'splunk app bistro 1.0.3 should be installed' do
  describe file('/opt/splunkforwarder/etc/apps/bistro-1.0.3/default/app.conf') do
    it { should exist }
    it { should be_file }
    its(:content) { should match(/version = 1.0.3/) }
    its(:content) { should match(/id = bistro/) }
  end
  describe command('/opt/splunkforwarder/bin/splunk btool --app=bistro-1.0.3 app list') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should_not match /disabled\s*=\s*(0|false)/ }
  end
end

describe 'splunk app sanitycheck should be installed' do
  describe file('/opt/splunkforwarder/etc/apps/sanitycheck') do
    it { should exist }
    it { should be_directory}
  end
end

describe 'splunk app bistro-1.0.2 should be removed' do
  describe file('/opt/splunkforwarder/etc/apps/bistro-1.0.2') do
    it { should_not exist }
  end
end

describe 'splunk app generallogs_inputs should be installed' do
  describe file('/opt/splunkforwarder/etc/apps/generallogs_inputs/local/inputs.conf') do
    it { should exist }
    it { should be_file }
    its(:content) { should match(/index = kitchen/) }
    its(:content) { should match(/sourcetype = syslog/) }
    its(:content) { should match(/disabled = false/) }
  end
  describe command('/opt/splunkforwarder/bin/splunk btool --app=generallogs_inputs app list') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should_not match /disabled\s*=\s*(0|false)/ }
  end
end