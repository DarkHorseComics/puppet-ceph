# Create the ceph keyring
#
# == Parameters
#
# [*secret*]
#   Key string to use for auth key
#
# [*permisisons*]
#   Array of permissions granted to the key
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
    $permissions_option = join(prefix($permissions, "--cap "), ' ')
  }

  exec { "ceph-key-${name}":
    command => "ceph-authtool ${keyring_path} --create-keyring --name='client.${name}' --add-key='${secret}' ${permissions_option}",
    creates => $keyring_path,
    require => Package['ceph'],
  }

}
