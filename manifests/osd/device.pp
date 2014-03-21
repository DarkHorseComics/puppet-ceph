# Configure a ceph osd device
#
# == Namevar
# the resource name is the full path to the device to be used.
#
# == Parameters
#
# [*fs_type*]
#   Filesystem type used to format the OSD
#
# [*cluster_name*]
#   Name of the cluster to join, default is ceph
#
# [*cluster_uuid*]
#   UUID of the cluster to join
#
# [*journal_path*]
#   Path used to store the journal for this OSD.
#   If not specified, it will be on the same disk as the OSD data partition
#
# [*bootstrap_key*]
#   Location of the auth key to use for joining the cluster
#
# == Dependencies
#
# none
#
# == Authors
#
#  François Charlier francois.charlier@enovance.com
#
# == Copyright
#
# Copyright 2013 eNovance <licensing@enovance.com>
#

define ceph::osd::device (
  $fs_type = 'xfs',
  $cluster_name = undef,
  $cluster_uuid = undef,
  $journal_path = undef,
  $bootstrap_key = undef,
) {

  include ceph::osd
  include ceph::conf
  include ceph::params

  if $cluster_name {
    $cluster_name_option = "--cluster ${cluster_name}"
  }

  if $cluster_uuid {
    $cluster_uuid_option = "--cluster-uuid ${cluster_uuid}"
  }

  if $bootstrap_key {
    $bootstrap_key_option = "--activate-key ${bootstrap_key}"
  }

  exec { "ceph_prepare_${name}":
    command => "ceph-disk prepare ${cluster_name_option} ${cluster_uuid_option} --fs-type ${fs_type} --zap-disk ${name} ${journal_path}",
    unless  => "ceph-disk list | grep -E \"${name}[0-9]+ ceph data, prepared\"",
    require => Package['btrfs-tools', 'xfsprogs','ceph'],
  } ->
  exec { "ceph_activate_${name}":
    command => "ceph-disk activate ${name}1 ${bootstrap_key_option}",
    unless  => "ceph-disk list | grep -E \"${name}[0-9]+ ceph data, prepared.*osd\.\"",
  }

}
