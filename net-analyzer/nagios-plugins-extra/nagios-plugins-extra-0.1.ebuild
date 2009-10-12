# Copyright 2009 Enchanted Technology
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="Extra Nagios plugins"
HOMEPAGE=""
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"

KEYWORDS="x86 amd64"

IUSE=""

DEPEND="net-analyzer/nagios-nrpe[command-args]
net-analyzer/nagios-plugins"

RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}"

src_install() {
	keepdir /usr/lib/nagios/plugins/extra

	exeinto /usr/lib/nagios/plugins/extra
	doexe ${FILESDIR}/${PV}/*
}

pkg_postinst() {
	 einfo "test"
}

pkg_config() {
	einfo "config test"
	patch -d /tmp -N -p0 -o /tmp/nrpe.cfg.new /etc/nagios/nrpe.cfg ${FILESDIR}/nrpe.cfg.extra.patch
	cp /etc/nagios/nrpe.cfg /etc/nagios/nrpe.cfg.bak
	cp /tmp/nrpe.cfg.new /etc/nagios/nrpe.cfg
}