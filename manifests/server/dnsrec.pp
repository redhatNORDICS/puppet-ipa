# FreeIPA templating module by James
# Copyright (C) 2012-2013+ James Shubin
# Written by James Shubin <james@shubin.ca>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

define ipa::server::dnsrec(
	$zone_name = undef,		# DNS Zone
        $record_name = undef,		# DNS Record
        $record_type = undef,		# IPv4: --a-rec, --a-ip-address
					# IPv6: --aaaa-rec, --aaaa-ip-address
        $record_data = undef,		# IP address, IPv6 address.
        $create_reverse = undef,	# IPv4: --a-create-reverse
					# IPv6: -aaaa-create-reverse
) {
	# FIXME: what if the name exist with a different IP?
	# ipa dnsrecord-find lab.arn.redhat.com --name=idm02 --a-rec=10.32.212.191
	$exists = "/usr/bin/ipa dnsrecord-find \
			$zone_name \
			--name=$record_name \
			> /dev/null 2>&1"

	$args = "$zone_name $record_name $record_type=$record_data $create_reverse"
	exec { 'dnsrecord-a-add-$record_name.$zone_name-$record_data':
		# This runs if the dns record does not already exist.
		command    => "/usr/bin/ipa dnsrecord-add $args",
		logoutput  => on_failure,
		unless     => "${exists}",
		require    => Exec['ipa-server-kinit'],
	}
}
