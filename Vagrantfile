# -*- mode: ruby -*-
# # vi: set ft=ruby :

require 'fileutils'

Vagrant.require_version ">= 1.6.0"

# Make sure the vagrant-ignition plugin is installed
required_plugins = %w(vagrant-ignition)

plugins_to_install = required_plugins.select { |plugin| not Vagrant.has_plugin? plugin }
if not plugins_to_install.empty?
  puts "Installing plugins: #{plugins_to_install.join(' ')}"
  if system "vagrant plugin install #{plugins_to_install.join(' ')}"
    exec "vagrant #{ARGV.join(' ')}"
  else
    abort "Installation of one or more plugins has failed. Aborting."
  end
end

IGNITION_CONFIG_PATH = File.join(File.dirname(__FILE__), "config.ign")

# Defaults for config options defined in CONFIG
$etcd_cluster_count = 2
$etcd_instance_pre = "core-etcd"
$etcd_start_ip = 100
$kube_masters = 1
$kube_masters_start_ip = 100 + $etcd_cluster_count
$kube_master_pre = "core-master"
$kube_workers = 1
$kube_workers_start_ip = 100 + $etcd_cluster_count + $kube_masters
$kube_worker_pre = "core-work"


# $num_instances = 3
# $instance_name_prefix = "core"
$enable_serial_logging = false
$share_home = false
$vm_gui = false
$vm_memory = 1024
$vm_cpus = 1
$vb_cpuexecutioncap = 100
$shared_folders = {}
$forwarded_ports = {}

# Use old vb_xxx config variables when set
def vm_gui
  $vb_gui.nil? ? $vm_gui : $vb_gui
end

def vm_memory
  $vb_memory.nil? ? $vm_memory : $vb_memory
end

def vm_cpus
  $vb_cpus.nil? ? $vm_cpus : $vb_cpus
end

Vagrant.configure("2") do |config|
  # always use Vagrants insecure key
  config.ssh.insert_key = false
  # forward ssh agent to easily ssh into the different machines
  config.ssh.forward_agent = true

  config.vm.box = "coreos-alpha"
  config.vm.box_url = "https://alpha.release.core-os.net/amd64-usr/current/coreos_production_vagrant_virtualbox.json"

  config.vm.provider :virtualbox do |v|
    # On VirtualBox, we don't have guest additions or a functional vboxsf
    # in CoreOS, so tell Vagrant that so it can be smarter.
    v.check_guest_additions = false
    v.functional_vboxsf     = false
    # enable ignition (this is always done on virtualbox as this is how the ssh key is added to the system)
    config.ignition.enabled = true
  end

  # plugin conflict
  if Vagrant.has_plugin?("vagrant-vbguest") then
    config.vbguest.auto_update = false
  end


  # etcd cluster config
  (1..$etcd_cluster_count).each do |i|
    config.vm.define vm_name = "%s-%02d" % [$etcd_instance_pre, i] do |config|
      config.vm.hostname = vm_name

      if $enable_serial_logging
        logdir = File.join(File.dirname(__FILE__), "log")
        FileUtils.mkdir_p(logdir)

        serialFile = File.join(logdir, "%s-serial.txt" % vm_name)
        FileUtils.touch(serialFile)

        config.vm.provider :virtualbox do |vb, override|
          vb.customize ["modifyvm", :id, "--uart1", "0x3F8", "4"]
          vb.customize ["modifyvm", :id, "--uartmode1", serialFile]
        end
      end

      if $expose_docker_tcp
        config.vm.network "forwarded_port", guest: 2375, host: ($expose_docker_tcp + i - 1), host_ip: "127.0.0.1", auto_correct: true
      end

      $forwarded_ports.each do |guest, host|
        config.vm.network "forwarded_port", guest: guest, host: host, auto_correct: true
      end

      config.vm.provider :virtualbox do |vb|
        vb.gui = vm_gui
        vb.memory = vm_memory
        vb.cpus = vm_cpus
        vb.customize ["modifyvm", :id, "--cpuexecutioncap", "#{$vb_cpuexecutioncap}"]
        config.ignition.config_obj = vb
      end

      ip = "172.17.8.#{i+100}"
      config.vm.network :private_network, ip: ip
      # This tells Ignition what the IP for eth1 (the host-only adapter) should be
      config.ignition.ip = ip

      config.vm.provider :virtualbox do |vb|
        config.ignition.hostname = vm_name
        config.ignition.drive_name = "config-etcd" + i.to_s
        # when the ignition config doesn't exist, the plugin automatically generates a very basic Ignition with the ssh key
        # and previously specified options (ip and hostname). Otherwise, it appends those to the provided config.ign below
        if File.exist?(IGNITION_CONFIG_PATH)
          config.ignition.path = 'config.ign'
        end
      end
    end
  end



  # kube master config
  (1..$kube_masters).each do |i|
    config.vm.define vm_name = "%s-%02d" % [$kube_master_pre, i] do |config|
      config.vm.hostname = vm_name

      if $enable_serial_logging
        logdir = File.join(File.dirname(__FILE__), "log")
        FileUtils.mkdir_p(logdir)

        serialFile = File.join(logdir, "%s-serial.txt" % vm_name)
        FileUtils.touch(serialFile)

        config.vm.provider :virtualbox do |vb, override|
          vb.customize ["modifyvm", :id, "--uart1", "0x3F8", "4"]
          vb.customize ["modifyvm", :id, "--uartmode1", serialFile]
        end
      end

      if $expose_docker_tcp
        config.vm.network "forwarded_port", guest: 2375, host: ($expose_docker_tcp + i - 1), host_ip: "127.0.0.1", auto_correct: true
      end

      $forwarded_ports.each do |guest, host|
        config.vm.network "forwarded_port", guest: guest, host: host, auto_correct: true
      end

      config.vm.provider :virtualbox do |vb|
        vb.gui = vm_gui
        vb.memory = vm_memory
        vb.cpus = vm_cpus
        vb.customize ["modifyvm", :id, "--cpuexecutioncap", "#{$vb_cpuexecutioncap}"]
        config.ignition.config_obj = vb
      end

      ip = "172.17.8.#{i+$kube_masters_start_ip}"
      config.vm.network :private_network, ip: ip
      # This tells Ignition what the IP for eth1 (the host-only adapter) should be
      config.ignition.ip = ip

      config.vm.provider :virtualbox do |vb|
        config.ignition.hostname = vm_name
        config.ignition.drive_name = "config-kubeM" + i.to_s
        # when the ignition config doesn't exist, the plugin automatically generates a very basic Ignition with the ssh key
        # and previously specified options (ip and hostname). Otherwise, it appends those to the provided config.ign below
        if File.exist?(IGNITION_CONFIG_PATH)
          config.ignition.path = 'config.ign'
        end
      end
    end
  end




  # kube worker config
  (1..$kube_workers).each do |i|
    config.vm.define vm_name = "%s-%02d" % [$kube_worker_pre, i] do |config|
      config.vm.hostname = vm_name

      if $enable_serial_logging
        logdir = File.join(File.dirname(__FILE__), "log")
        FileUtils.mkdir_p(logdir)

        serialFile = File.join(logdir, "%s-serial.txt" % vm_name)
        FileUtils.touch(serialFile)

        config.vm.provider :virtualbox do |vb, override|
          vb.customize ["modifyvm", :id, "--uart1", "0x3F8", "4"]
          vb.customize ["modifyvm", :id, "--uartmode1", serialFile]
        end
      end

      if $expose_docker_tcp
        config.vm.network "forwarded_port", guest: 2375, host: ($expose_docker_tcp + i - 1), host_ip: "127.0.0.1", auto_correct: true
      end

      $forwarded_ports.each do |guest, host|
        config.vm.network "forwarded_port", guest: guest, host: host, auto_correct: true
      end

      config.vm.provider :virtualbox do |vb|
        vb.gui = vm_gui
        vb.memory = vm_memory
        vb.cpus = vm_cpus
        vb.customize ["modifyvm", :id, "--cpuexecutioncap", "#{$vb_cpuexecutioncap}"]
        config.ignition.config_obj = vb
      end

      ip = "172.17.8.#{i+$kube_workers_start_ip}"
      config.vm.network :private_network, ip: ip
      # This tells Ignition what the IP for eth1 (the host-only adapter) should be
      config.ignition.ip = ip

      config.vm.provider :virtualbox do |vb|
        config.ignition.hostname = vm_name
        config.ignition.drive_name = "config-kubeW" + i.to_s
        # when the ignition config doesn't exist, the plugin automatically generates a very basic Ignition with the ssh key
        # and previously specified options (ip and hostname). Otherwise, it appends those to the provided config.ign below
        if File.exist?(IGNITION_CONFIG_PATH)
          config.ignition.path = 'config.ign'
        end
      end
    end
  end
end
