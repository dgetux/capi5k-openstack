class openstackg5k::role::compute inherits ::openstack::role {
  class { '::openstack::profile::firewall': }
  class { '::openstackg5k::profile::nova::compute': } ->
  class { '::openstackg5k::profile::ceilometer::agent': } ->
  class { '::openstackg5k::profile::nova::storage': }
}
