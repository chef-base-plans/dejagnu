title 'Tests to confirm dejagnu works as expected'

plan_origin = ENV['HAB_ORIGIN']
plan_name = input('plan_name', value: 'dejagnu')

control 'core-plans-dejagnu-works' do
  impact 1.0
  title 'Ensure dejagnu works as expected'
  desc '
  Note: although the stderr contains a WARNING, the stdout contains the required 
  version information so this test achieves its aim of detecting the dejagnu version
  '
  plan_installation_directory = command("hab pkg path #{plan_origin}/#{plan_name}")
  describe plan_installation_directory do
    its('exit_status') { should eq 0 }
    its('stdout') { should_not be_empty }
  end
  
  plan_pkg_ident = ((plan_installation_directory.stdout.strip).match /(?<=pkgs\/)(.*)/)[1]
  plan_pkg_version = (plan_pkg_ident.match /^#{plan_origin}\/#{plan_name}\/(?<version>.*)\//)[:version]
  describe command("DEBUG=true; hab pkg exec #{plan_pkg_ident} runtest --version") do
    its('exit_status') { should eq 0 }
    its('stdout') { should_not be_empty }
    its('stdout') { should match /DejaGnu version\s+#{plan_pkg_version}/ }
    its('stderr') { should match /WARNING: Couldn't find the global config file/ }
  end
end
