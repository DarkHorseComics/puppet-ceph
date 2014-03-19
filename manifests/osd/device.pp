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
#   Name of the cluster to join
#
# [*cluster_uuid*]
#   UUID of the cluster to join
#
# [*journal_path*]
#   Path used to store the journal for this OSD.
#   If not specified, it will be on the same disk as the OSD data partition
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
  $cluster_name,
  $cluster_uuid,
  $journal_path = undef,
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

  exec { "ceph_prepare_${name}":
    command => "ceph-disk prepare ${cluster_name_option} ${cluster_uuid_option} --fs-type ${fs_type} --zap-disk ${name} ${journal_path}",
    unless  => "ceph-disk list | grep -E \"${name}[0-9]+ ceph data, prepared\"",
    require => Package['btrfs-tools', 'xfsprogs'],
  } ->
  exec { "ceph_activate_${name}":
    command => "ceph-disk activate ${name}",
    unless  => "ceph-disk list | grep -E \"${name}[0-9]+ ceph data, prepared\"",
  }

}
