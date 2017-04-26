define :splunk_installer, url: nil do # ~FC015
  cache_dir = Chef::Config[:file_cache_path]
  package_file = splunk_file(params[:url])
  cached_package = ::File.join(cache_dir, package_file)

  remote_file cached_package do
    source params[:url]
    action :create_if_missing
  end

  if %w( omnios ).include?(node['platform'])
    pkgopts = [
      "-a #{cache_dir}/#{params[:name]}-nocheck",
      "-r #{cache_dir}/splunk-response"
    ]

    execute "uncompress #{cached_package}" do
      not_if { ::File.exist?("#{cache_dir}/#{package_file.gsub(/\.Z/, '')}") }
    end

    cookbook_file "#{cache_dir}/#{params[:name]}-nocheck" do
      source 'splunk-nocheck'
    end

    file "#{cache_dir}/splunk-response" do
      content 'BASEDIR=/opt'
    end

    execute "usermod -d #{node['splunk']['user']['home']} splunk" do
      only_if 'grep -q /home/splunk /etc/passwd'
    end
  end

  local_package_resource = case node['platform_family']
                           when 'rhel', 'fedora'  then :rpm_package
                           when 'debian'          then :dpkg_package
                           when 'omnios'          then :solaris_package
                           end

  declare_resource local_package_resource, params[:name] do
    source cached_package.gsub(/\.Z/, '')
    options pkgopts.join(' ') if platform?('omnios')
  end
end
