# Create the ceph keyring
#
# == Parameters
#
# [*secret*]
#   Key string to use for auth key
#
# [*permisisons*]
#   Permissions granted to the key
#
# [*keyring_path*]
#   Location of key
#
define ceph::key (
  $secret       = undef,
  $permissions  = undef,
  $keyring_path = "/var/lib/ceph/tmp/${name}.keyring",
) {

  if $permissions {
    $permission_option = "--cap ${permissions}"
  }

  exec { "ceph-key-${name}":
    command => "ceph-authtool ${keyring_path} --create-keyring --name='client.${name}' --add-key='${secret}' ${permissions_option}",
    creates => $keyring_path,
    require => Package['ceph'],
  }

}
